local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local SoundService = game:GetService("SoundService")

local root = script.Parent.Parent
local Config = require(root.Config)
local Tw = require(script.Parent.Tw)
local Kit = require(script.Parent.Kit)
local Emitters = require(script.Parent.Emitters)
local CameraRig = require(script.Parent.CameraRig)
local Poser = require(script.Parent.Poser)
local Clips = require(script.Parent.Clips)
local Locomotion = require(script.Parent.Locomotion)

local Sounds = root.Assets.Sounds
local P = Config.Palette
local V3 = Vector3.new
local Quad, Sine = Enum.EasingStyle.Quad, Enum.EasingStyle.Sine
local Out, In, InOut = Enum.EasingDirection.Out, Enum.EasingDirection.In, Enum.EasingDirection.InOut

local SummonVfx = {}

-- a summon is a small move so every beat sits inside a second and a half
local T = {
	pop = 0.25,
	rise = 0.27,
	settle = 0.55,
	lock = 0.85,
	done = 1.3,
}
SummonVfx.T = T

local active = {}
local activeMix

local function newModel(name)
	local m = Instance.new("Model")
	m.Name = name
	m.Parent = workspace
	return m
end

local function groundBelow(origin, character)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {character}
	local hit = workspace:Raycast(origin.Position, V3(0, -30, 0), params)
	local y = hit and hit.Position.Y or origin.Position.Y - 3
	local look = origin.LookVector * V3(1, 0, 1)
	if look.Magnitude < 0.01 then
		look = V3(0, 0, -1)
	end
	local p = V3(origin.Position.X, y, origin.Position.Z)
	return CFrame.lookAt(p, p + look)
end

local function light(parent, color, brightness, range)
	local l = Instance.new("PointLight")
	l.Color = color
	l.Brightness = brightness
	l.Range = range
	l.Shadows = false
	l.Parent = parent
	return l
end

-- one bed group with a limiter keeps the few summon sounds from stacking into a clip
local function mixSetup(state)
	local g = SoundService:FindFirstChild("StandMix") or Instance.new("SoundGroup")
	g.Name = "StandMix"
	g.Volume = 1
	if not g:FindFirstChildOfClass("CompressorSoundEffect") then
		local comp = Instance.new("CompressorSoundEffect")
		comp.Threshold = -9
		comp.Ratio = 12
		comp.Attack = 0.001
		comp.Release = 0.12
		comp.Parent = g
	end
	g.Parent = SoundService
	state.mix = g
	activeMix = g
end

local function sfx(name, at, volume, speed)
	local template = Sounds:FindFirstChild(name)
	if not template or template.SoundId == "" then
		return nil
	end
	local s = template:Clone()
	s.Volume = volume or template.Volume
	s.PlaybackSpeed = (speed or 1) / Tw.S()
	s.Looped = false
	s.RollOffMode = Enum.RollOffMode.InverseTapered
	s.RollOffMinDistance = 25
	s.RollOffMaxDistance = 300
	s.SoundGroup = activeMix
	s.Parent = at
	s:Play()
	Debris:AddItem(s, 10 * Tw.S())
	return s
end

-- follows keep a piece pinned to a body part while the clip moves it
local function startFollows(state)
	state.follows = {}
	state.followConn = RunService.Heartbeat:Connect(function()
		for part, fn in pairs(state.follows) do
			if part.Parent then
				fn()
			else
				state.follows[part] = nil
			end
		end
	end)
end

local function follow(state, part, target, offset)
	state.follows[part] = function()
		part.CFrame = target.CFrame * offset
	end
end

local function standParts(stand)
	local list = {}
	for _, d in ipairs(stand:GetDescendants()) do
		if d:IsA("BasePart") and d.Name ~= "StandHumanoidRootPart" then
			table.insert(list, d)
		end
	end
	return list
end

-- the stand lives hidden in the character so a summon only reveals it and never clones anything
local function remember(state)
	if state.stand:GetAttribute("Remembered") then
		return
	end
	for _, p in ipairs(standParts(state.stand)) do
		p:SetAttribute("Mat", p.Material.Name)
		p:SetAttribute("Col", p.Color)
		p:SetAttribute("Tr", p:GetAttribute("Tr") or 0)
	end
	state.stand:SetAttribute("Remembered", true)
end

local function ghost(state, transparency)
	for _, p in ipairs(standParts(state.stand)) do
		p.Material = Enum.Material.Neon
		p.Color = P.gold
		p.Transparency = transparency
	end
end

-- the real materials come back over a short tween so the gold ghost fades into metal instead of popping
local function materialize(state, dur)
	for _, p in ipairs(standParts(state.stand)) do
		p.Material = Enum.Material[p:GetAttribute("Mat") or "Metal"]
		p.Color = p:GetAttribute("Col") or p.Color
		if dur > 0 then
			p.Transparency = 0.6
			Tw.play(p, {Transparency = p:GetAttribute("Tr") or 0}, dur, Quad, Out)
		else
			p.Transparency = p:GetAttribute("Tr") or 0
		end
	end
end

local function hide(state)
	for _, p in ipairs(standParts(state.stand)) do
		p.Transparency = 1
	end
end

local function backOf(state)
	return state.torso.CFrame * CFrame.new(0.4, 0.2, 1.0)
end

-- the wind up only gathers a little light at the back so the eye knows where to look
local function phaseGather(state)
	local back = backOf(state)
	local gather = Emitters.carrier(state.fx, back, V3(4, 4, 4))
	follow(state, gather, state.torso, CFrame.new(0.4, 0.2, 1.0))
	Emitters.make(gather, {
		texture = "star4",
		Shape = Enum.ParticleEmitterShape.Sphere,
		ShapeInOut = Enum.ParticleEmitterShapeInOut.Inward,
		ShapeStyle = Enum.ParticleEmitterShapeStyle.Surface,
		Speed = NumberRange.new(5, 8),
		Lifetime = NumberRange.new(0.25, 0.35),
		Size = Tw.seq({{0, 0}, {0.4, 0.5}, {1, 0.1}}),
		Color = Tw.cseq({{0, P.gold}, {1, P.white}}),
		Transparency = Tw.seq({{0, 0.5}, {1, 0}}),
		Enabled = true,
		Rate = 24,
	})
	Emitters.make(gather, {
		texture = "circle",
		Shape = Enum.ParticleEmitterShape.Sphere,
		ShapeInOut = Enum.ParticleEmitterShapeInOut.Inward,
		ShapeStyle = Enum.ParticleEmitterShapeStyle.Surface,
		Speed = NumberRange.new(5, 8),
		Lifetime = NumberRange.new(0.25, 0.35),
		Size = Tw.seq({{0, 0}, {0.4, 0.2}, {1, 0}}),
		Color = ColorSequence.new(P.lavender),
		Enabled = true,
		Rate = 16,
	})
	state.gather = gather
	state.backLight = light(state.torso, P.violet, 0, 8)
	Tw.play(state.backLight, {Brightness = 1.2}, T.pop, Quad, In)
	sfx("Ambience", state.hrp, 0.35, 0.9)
end

-- the pop is one small flash a soft ring at the feet and a handful of stars while the ghost shows
local function phasePop(state)
	local back = backOf(state)
	if state.gather then
		Kit.kill(state.gather, 0.6)
		state.gather = nil
	end
	ghost(state, 0.35)
	Kit.burst("Hit2", back * CFrame.new(0, 0.6, 0), state.fx, 1, {color = P.pale, scale = 1.1, glow = 1, life = 0.8})
	Kit.burst("Shock", state.base * CFrame.new(0, 0.4, 0) * CFrame.Angles(math.pi / 2, 0, 0), state.fx, 1, {color = P.violet, scale = 1.2, glow = 1, life = 0.8})
	Kit.burst("Lightning", back, state.fx, {Lighting1 = 1, Lighting2 = 1}, {color = P.lavender, scale = 1.4, life = 0.6})
	Emitters.sparkleBurst(state.fx, back, V3(2, 2, 2), 7, {speed = NumberRange.new(3, 9), drag = 2.5, size = 0.55, life = NumberRange.new(0.5, 0.9)})
	Tw.play(state.backLight, {Brightness = 3, Range = 11}, 0.04)
	Tw.play(state.backLight, {Brightness = 0.6, Range = 8}, 0.5, Quad, Out, 0.06)
	CameraRig.kick(0.22)
	sfx("SummonSound", state.hrp, 1.2, 1)
	sfx("StandSFX", state.hrp, 0.9, 1.05)
	if Config.Voice then
		sfx("WRYsfx", state.hrp, 0.5, 1)
	end
end

-- the rise turns the ghost real and leaves a thin trail of stars behind the stand
local function phaseRise(state)
	state.rigStand:play(Clips.WorldAppear, {fadeIn = 0})
	task.delay(0.12 * Tw.S(), function()
		if state.alive then
			materialize(state, 0.22)
		end
	end)
	local torso = state.stand["Stand Torso"]
	local trail = Emitters.carrier(state.fx, torso.CFrame, V3(2, 3, 1.5))
	follow(state, trail, torso, CFrame.new())
	Emitters.make(trail, {
		texture = "star4",
		Speed = NumberRange.new(0.5, 1.5),
		Acceleration = V3(0, 1, 0),
		Lifetime = NumberRange.new(0.5, 0.9),
		Size = Tw.seq({{0, 0}, {0.3, 0.45}, {1, 0}}),
		Color = Tw.cseq({{0, P.white}, {0.5, P.gold}, {1, P.violet}}),
		SpreadAngle = Vector2.new(180, 180),
		Enabled = true,
		Rate = 26,
	})
	state.trail = trail
	state.standLight = light(torso, P.gold, 0, 10)
	Tw.play(state.standLight, {Brightness = 1.6}, T.settle - T.rise, Quad, Out)
end

-- the settle drops every summon piece and leaves the small idle aura on the stand
local function phaseSettle(state)
	local torso = state.stand["Stand Torso"]
	if state.trail then
		Kit.kill(state.trail, 1.2)
		state.trail = nil
	end
	Tw.play(state.backLight, {Brightness = 0}, 0.4)
	Tw.play(state.standLight, {Brightness = 0.7, Range = 8}, 0.6)
	local idle = state.stand:FindFirstChild("IdleAura")
	if not idle then
		idle = Emitters.carrier(state.stand, torso.CFrame, V3(2, 4, 2))
		idle.Name = "IdleAura"
		idle.Anchored = false
		idle.Massless = true
		local weld = Instance.new("Weld")
		weld.Part0 = torso
		weld.Part1 = idle
		weld.Parent = idle
		Emitters.make(idle, {
			texture = "star4",
			Speed = NumberRange.new(0.3, 1),
			Acceleration = V3(0, 1, 0),
			Lifetime = NumberRange.new(0.8, 1.3),
			Size = Tw.seq({{0, 0}, {0.3, 0.4}, {1, 0}}),
			Color = Tw.cseq({{0, P.white}, {0.4, P.gold}, {1, P.violet}}),
			SpreadAngle = Vector2.new(180, 180),
			Rate = 4,
		})
		Emitters.make(idle, {
			texture = "circle",
			Speed = NumberRange.new(0.3, 0.8),
			Acceleration = V3(0, 0.8, 0),
			Lifetime = NumberRange.new(0.9, 1.5),
			Size = Tw.seq({{0, 0}, {0.3, 0.16}, {1, 0}}),
			Color = ColorSequence.new(P.lavender),
			SpreadAngle = Vector2.new(180, 180),
			Rate = 6,
		})
	end
	Kit.enable(idle, true)
	state.idleAura = idle
end

local function setup(character, isLocal)
	local state = {character = character, isLocal = isLocal, alive = true}
	state.hrp = character:WaitForChild("HumanoidRootPart", 5)
	state.torso = character:WaitForChild("Torso", 5)
	state.stand = character:WaitForChild("Stand", 5)
	state.humanoid = character:FindFirstChildOfClass("Humanoid")
	if not state.hrp or not state.torso or not state.stand then
		return nil
	end
	state.base = groundBelow(state.hrp.CFrame, character)
	state.fx = newModel("StandFx")
	startFollows(state)
	mixSetup(state)
	remember(state)
	state.loco = Locomotion.start(character)
	if not state.loco then
		return nil
	end
	state.rigDio = state.loco.rig
	state.rigStand = Poser.attach(character, state.loco.ctx)
	-- the stand waits folded inside the body and invisible until the pop
	state.rigStand:play(Clips.WorldAppear, {fadeIn = 0, speed = 0})
	hide(state)
	if isLocal and state.humanoid then
		state.speed0 = {WalkSpeed = state.humanoid.WalkSpeed, JumpPower = state.humanoid.JumpPower, AutoRotate = state.humanoid.AutoRotate}
		state.humanoid.WalkSpeed = 0
		state.humanoid.JumpPower = 0
		state.humanoid.AutoRotate = false
		task.delay(T.lock * Tw.S(), function()
			if state.speed0 and state.humanoid.Parent then
				for k, v in pairs(state.speed0) do
					state.humanoid[k] = v
				end
				state.speed0 = nil
			end
		end)
	end
	CameraRig.rumble(state.base.Position)
	return state
end

local function run(state)
	Locomotion.override(state.character, Clips.DioSummon, {fadeIn = 0.08, fadeOut = 0.35})
	phaseGather(state)
	Tw.wait(T.pop)
	phasePop(state)
	Tw.wait(T.rise - T.pop)
	phaseRise(state)
	Tw.wait(T.settle - T.rise)
	phaseSettle(state)
	Tw.wait(T.done - T.settle)
	state.rigStand:play(Clips.WorldFloat, {fadeIn = 0.45})
	-- the view slides left a little so the stand on the right shoulder never covers the body
	if state.isLocal and state.humanoid then
		Tw.play(state.humanoid, {CameraOffset = V3(-1.4, 0.2, 0)}, 0.7, Sine, InOut)
	end
end

local function cleanup(state, failed)
	state.alive = false
	activeMix = nil
	if state.followConn then
		state.followConn:Disconnect()
	end
	if state.speed0 and state.humanoid then
		for k, v in pairs(state.speed0) do
			state.humanoid[k] = v
		end
		state.speed0 = nil
	end
	if failed then
		materialize(state, 0)
		Locomotion.release(state.character, 0.3)
	end
	CameraRig.stopRumble()
	Debris:AddItem(state.fx, 3 * Tw.S())
end

function SummonVfx.summon(character, isLocal)
	local old = active[character]
	if old then
		old.alive = false
	end
	local state = setup(character, isLocal)
	if not state then
		return
	end
	active[character] = state
	local ok, err = pcall(run, state)
	if not ok then
		warn("stand summon failed", err)
	end
	cleanup(state, not ok)
	if active[character] == state then
		state.alive = true
	end
end

-- the dismiss folds the stand back into the body and fades it out with a few stars
function SummonVfx.dismiss(character, isLocal)
	local state = active[character]
	active[character] = nil
	local stand = character:FindFirstChild("Stand")
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not stand or not hrp then
		return
	end
	local fx = newModel("StandFx")
	Debris:AddItem(fx, 3 * Tw.S())
	local loco = Locomotion.get(character)
	local rigStand = state and state.rigStand or Poser.attach(character, loco and loco.ctx)
	rigStand:play(Clips.WorldVanish, {fadeIn = 0.05})
	local hum = character:FindFirstChildOfClass("Humanoid")
	if isLocal and hum then
		Tw.play(hum, {CameraOffset = V3(0, 0, 0)}, 0.5, Sine, InOut)
	end
	local s = Sounds:FindFirstChild("Desummon")
	if s then
		local c = s:Clone()
		c.Volume = 0.9
		c.Parent = hrp
		c:Play()
		Debris:AddItem(c, 3)
	end
	local torso = stand:FindFirstChild("Stand Torso")
	if torso then
		Emitters.sparkleBurst(fx, torso.CFrame, V3(2, 3, 2), 6, {speed = NumberRange.new(2, 6), size = 0.5, life = NumberRange.new(0.4, 0.8)})
	end
	for _, p in ipairs(standParts(stand)) do
		Tw.play(p, {Transparency = 1}, 0.26, Quad, In, 0.08)
	end
	task.delay(0.36 * Tw.S(), function()
		rigStand:stop(0)
	end)
	if state then
		state.alive = false
		if state.idleAura then
			Kit.enable(state.idleAura, false)
		end
		if state.standLight then
			state.standLight:Destroy()
		end
		if state.backLight then
			state.backLight:Destroy()
		end
	else
		local idle = stand:FindFirstChild("IdleAura")
		if idle then
			Kit.enable(idle, false)
		end
	end
end

-- the first draw of a mesh a material or a sprite costs a frame so the client draws every summon piece once at join nearly invisible
local warmed = false
function SummonVfx.warm(character)
	local stand = character:FindFirstChild("Stand")
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if warmed or not stand or not hrp then
		return
	end
	warmed = true
	local state = {stand = stand}
	remember(state)
	local parts = standParts(stand)
	local fx = newModel("StandWarm")
	local at = hrp.CFrame
	for _, name in ipairs({"Hit2", "Shock", "Lightning"}) do
		local inst = Kit.spawn(name, at, fx)
		if inst then
			for _, d in ipairs(inst:GetDescendants()) do
				if d:IsA("BasePart") then
					d.Transparency = 0.98
				elseif d:IsA("ParticleEmitter") then
					d.Enabled = false
					d.Transparency = NumberSequence.new(1)
					d:Emit(1)
				elseif d:IsA("Beam") or d:IsA("Trail") then
					d.Transparency = NumberSequence.new(1)
				end
			end
			if inst:IsA("BasePart") then
				inst.Transparency = 0.98
			end
		end
	end
	local sp = Emitters.carrier(fx, at, V3(1, 1, 1))
	for _, item in ipairs(Emitters.sparkles(sp, {size = 0.2, life = NumberRange.new(0.05, 0.1)})) do
		item.e.Transparency = NumberSequence.new(1)
		item.e:Emit(1)
	end
	for _, p in ipairs(parts) do
		p.Transparency = 0.98
	end
	RunService.RenderStepped:Wait()
	RunService.RenderStepped:Wait()
	for _, p in ipairs(parts) do
		p.Material = Enum.Material.Neon
		p.Color = P.gold
	end
	RunService.RenderStepped:Wait()
	RunService.RenderStepped:Wait()
	for _, p in ipairs(parts) do
		p.Material = Enum.Material[p:GetAttribute("Mat") or "Metal"]
		p.Color = p:GetAttribute("Col") or p.Color
		p.Transparency = 1
	end
	fx:Destroy()
end

return SummonVfx
