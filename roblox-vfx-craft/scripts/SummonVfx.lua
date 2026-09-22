local Players = game:GetService("Players")
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
SummonVfx.mixSetup = mixSetup

function SummonVfx.mix()
	return activeMix or SoundService:FindFirstChild("StandMix")
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
	s.SoundGroup = SummonVfx.mix()
	s.Parent = at
	s:Play()
	Debris:AddItem(s, 10 * Tw.S())
	return s
end
SummonVfx.sfx = sfx

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

-- the base parts the artist left invisible carry Tr 1 and never join a ghost or a fade
local function standParts(stand)
	local list = {}
	for _, d in ipairs(stand:GetDescendants()) do
		if d:IsA("BasePart") and d.Name ~= "StandHumanoidRootPart" and d:GetAttribute("Tr") ~= 1 then
			table.insert(list, d)
		end
	end
	return list
end
SummonVfx.standParts = standParts

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

-- a time echo: the visible stand parts frozen where they are as gold neon that fades, the mark of a body
-- that moves faster than time; the clone keeps only its mesh so it draws flat
function SummonVfx.afterimage(stand, parent, life, color, start)
	local m = Instance.new("Model")
	m.Name = "Echo"
	for _, p in ipairs(standParts(stand)) do
		if p.Transparency < 0.9 then
			local c = p:Clone()
			for _, d in ipairs(c:GetChildren()) do
				if d:IsA("DataModelMesh") then
					pcall(function()
						d.TextureId = ""
					end)
				else
					d:Destroy()
				end
			end
			if c:IsA("MeshPart") then
				c.TextureID = ""
			end
			c.Anchored = true
			c.CanCollide = false
			c.CanQuery = false
			c.CanTouch = false
			c.CastShadow = false
			c.Massless = true
			c.Material = Enum.Material.Neon
			c.Color = color or P.gold
			c.Transparency = start or 0.55
			c.CFrame = p.CFrame
			c.Parent = m
			Tw.play(c, {Transparency = 1}, life or 0.35, Quad, In)
		end
	end
	m.Parent = parent
	Debris:AddItem(m, (life or 0.35) * Tw.S() + 0.1)
	return m
end

local function backOf(state)
	return state.torso.CFrame * CFrame.new(0.4, 0.3, 1.1)
end

-- the wind up draws a clock behind dio's back: a gold rune ring stood on its edge with a thin rim, one
-- beam hand that spins faster and faster, and a little gold light; time winds up before the world breaks out
local function phaseGather(state)
	local back = backOf(state)
	local face = back * CFrame.Angles(math.pi / 2, 0, 0)
	local ring = Kit.spawn("ChainRing", face, state.fx)
	if ring then
		Kit.tint(ring, P.gold, P.pale)
		Kit.scale(ring, 1.5)
		Kit.glow(ring, 1)
		Kit.set(ring, {RotSpeed = NumberRange.new(120, 160)}, {Floor1 = 1, Floor2 = 1, Floor3 = 1})
		Kit.enable(ring, true, {Floor1 = 1, Floor2 = 1, Floor3 = 1})
		Kit.eachBeam(ring, function(b)
			b.Enabled = false
		end)
		follow(state, ring, state.torso, CFrame.new(0.4, 0.3, 1.1) * CFrame.Angles(math.pi / 2, 0, 0))
		state.ring = ring
	end
	local rim = Kit.mesh("EyeRing", state.fx, back, V3(5.2, 5.2, 0.14), P.gold, 1)
	if rim then
		rim.Anchored = true
		rim.CanCollide = false
		rim.CanQuery = false
		rim.Material = Enum.Material.Neon
		Tw.play(rim, {Transparency = 0.5}, T.pop, Quad, Out)
		follow(state, rim, state.torso, CFrame.new(0.4, 0.3, 1.1))
		state.rim = rim
	end
	-- the clock hand is one beam from the centre to the rim on a carrier the follow loop turns
	local hub = Emitters.carrier(state.fx, back, V3(0.2, 0.2, 0.2))
	local a0 = Instance.new("Attachment")
	a0.Parent = hub
	local a1 = Instance.new("Attachment")
	a1.Position = V3(0, 2.3, 0)
	a1.Parent = hub
	local hand = Instance.new("Beam")
	hand.Attachment0 = a0
	hand.Attachment1 = a1
	hand.Texture = Emitters.TEX.lightray
	hand.TextureMode = Enum.TextureMode.Stretch
	hand.Width0 = 0.12
	hand.Width1 = 0.5
	hand.Color = ColorSequence.new(P.pale)
	hand.Transparency = NumberSequence.new(0.1)
	hand.LightEmission = 1
	hand.FaceCamera = true
	hand.Parent = hub
	state.hand = hub
	state.handAngle = 0
	state.handSpeed = 3
	state.follows[hub] = function()
		if not state.handStopped then
			state.handAngle += state.handSpeed * math.pi * 2 / 60
			state.handSpeed = math.min(14, state.handSpeed + 0.35)
		end
		hub.CFrame = state.torso.CFrame * CFrame.new(0.4, 0.3, 1.15) * CFrame.Angles(0, 0, -state.handAngle)
	end
	state.backLight = light(state.torso, P.gold, 0, 9)
	Tw.play(state.backLight, {Brightness = 1.2}, T.pop, Quad, In)
	sfx("Ambience", state.hrp, 0.35, 0.9)
end

-- the pop is the tick: the hand stops dead on twelve, the clock flashes white, the glass of the moment cracks
-- and the shards fly while the gold ghost shows; one ring at the feet so the ground knows
local function phasePop(state)
	local back = backOf(state)
	state.handStopped = true
	state.handAngle = 0
	if state.rim then
		state.rim.Color = P.white
		state.rim.Transparency = 0.1
		Tw.play(state.rim, {Transparency = 0.5}, 0.12, Quad, Out)
		task.delay(0.05 * Tw.S(), function()
			if state.rim.Parent then
				state.rim.Color = P.gold
			end
		end)
	end
	if state.ring then
		Kit.tint(state.ring, P.white, P.gold)
		Kit.set(state.ring, {RotSpeed = NumberRange.new(0, 0)}, {Floor1 = 1, Floor2 = 1, Floor3 = 1})
	end
	ghost(state, 0.35)
	Kit.burst("Crack", back * CFrame.new(0, 0, 0.1) * CFrame.Angles(math.pi / 2, 0, 0), state.fx, {Floor1 = 1, Floor2 = 1}, {color = P.pale, scale = 1.3, glow = 1, life = 1.0})
	Kit.burst("ShieldBreak", back, state.fx, {Specs = 14, Shockwave = 1}, {color = P.gold, color2 = P.pale, scale = 1.2, glow = 1, life = 1.0})
	Emitters.burst(state.fx, back, V3(2, 2, 1), {
		texture = "shards",
		Speed = NumberRange.new(6, 14),
		Drag = 3,
		Acceleration = V3(0, -12, 0),
		SpreadAngle = Vector2.new(180, 180),
		Lifetime = NumberRange.new(0.5, 0.9),
		Size = Tw.seq({{0, 0.5}, {1, 0.2}}),
		Color = Tw.cseq({{0, P.white}, {0.4, P.gold}, {1, P.amber}}),
		Transparency = Tw.seq({{0, 0.1}, {0.7, 0.2}, {1, 1}}),
		Rotation = NumberRange.new(0, 360),
		RotSpeed = NumberRange.new(-240, 240),
	}, 12, 1.2)
	Kit.burst("Shock", state.base * CFrame.new(0, 0.4, 0) * CFrame.Angles(math.pi / 2, 0, 0), state.fx, 1, {color = P.lavender, scale = 1.2, glow = 1, life = 0.8})
	Tw.play(state.backLight, {Brightness = 3, Range = 12}, 0.04)
	Tw.play(state.backLight, {Brightness = 0.6, Range = 9}, 0.5, Quad, Out, 0.06)
	CameraRig.kick(0.22)
	sfx("SummonSound", state.hrp, 1.2, 1)
	sfx("StandSFX", state.hrp, 0.9, 1.05)
	if Config.Voice then
		sfx("WRYsfx", state.hrp, 0.5, 1)
	end
end

-- the rise turns the ghost real and leaves three gold echoes behind it while the clock fades out
local function phaseRise(state)
	state.rigStand:play(Clips.WorldAppear, {fadeIn = 0})
	task.delay(0.12 * Tw.S(), function()
		if state.alive then
			materialize(state, 0.22)
		end
	end)
	for i, at in ipairs({0.06, 0.13, 0.2}) do
		task.delay(at * Tw.S(), function()
			if state.alive then
				SummonVfx.afterimage(state.stand, state.fx, 0.3 + i * 0.04, P.gold, 0.5)
			end
		end)
	end
	if state.ring then
		Kit.kill(state.ring, 1.0)
	end
	if state.rim then
		Tw.play(state.rim, {Transparency = 1, Size = V3(6.5, 6.5, 0.14)}, 0.3, Quad, In)
	end
	if state.hand then
		for _, b in ipairs(state.hand:GetDescendants()) do
			if b:IsA("Beam") then
				Tw.play(b, {Width0 = 0, Width1 = 0}, 0.25, Quad, In)
			end
		end
	end
	local torso = state.stand["Stand Torso"]
	state.standLight = light(torso, P.gold, 0, 10)
	Tw.play(state.standLight, {Brightness = 1.6}, T.settle - T.rise, Quad, Out)
end

-- the heart of the world beats green under the gold: one light pulse every 0.86 s
local function heartbeat(state, torso)
	local heart = torso:FindFirstChild("HeartLight") or light(torso, P.green, 0.25, 6)
	heart.Name = "HeartLight"
	state.heart = heart
	state.heartRunning = true
	task.spawn(function()
		while state.heartRunning and heart.Parent do
			Tw.play(heart, {Brightness = 1.0, Range = 7}, 0.09, Quad, Out)
			Tw.play(heart, {Brightness = 0.25, Range = 6}, 0.5, Quad, Out, 0.1)
			Tw.wait(0.86)
		end
	end)
end

-- the settle drops every summon piece and leaves a slow gold draw of energy into the torso and the heartbeat
local function phaseSettle(state)
	local torso = state.stand["Stand Torso"]
	Tw.play(state.backLight, {Brightness = 0}, 0.4)
	Tw.play(state.standLight, {Brightness = 0.7, Range = 8}, 0.6)
	local idle = state.stand:FindFirstChild("IdleAura")
	if not idle then
		idle = Kit.spawn("Charge", torso.CFrame, state.stand)
		if idle then
			idle.Name = "IdleAura"
			idle.Anchored = false
			idle.Massless = true
			idle.CanCollide = false
			idle.CanQuery = false
			local weld = Instance.new("Weld")
			weld.Part0 = torso
			weld.Part1 = idle
			weld.Parent = idle
			Kit.tint(idle, P.gold, P.amber)
			Kit.glow(idle, 1)
			Kit.scale(idle, 0.7)
			Kit.set(idle, {Rate = 4}, {Energy1 = 1, Energy2 = 1})
			Kit.set(idle, {Rate = 0}, "Core1")
		end
	end
	if idle then
		Kit.enable(idle, true, {Energy1 = 1, Energy2 = 1})
		state.idleAura = idle
	end
	heartbeat(state, torso)
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
		old.heartRunning = false
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

-- the stand rig of a live summon so a move can drive the same joints
function SummonVfx.rigOf(character)
	local state = active[character]
	return state and state.rigStand, state
end

-- the dismiss folds the stand back into the body and fades it out behind two echoes
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
	for i, at in ipairs({0.04, 0.12}) do
		task.delay(at * Tw.S(), function()
			if stand.Parent then
				SummonVfx.afterimage(stand, fx, 0.28 + i * 0.04, P.gold, 0.55)
			end
		end)
	end
	for _, p in ipairs(standParts(stand)) do
		Tw.play(p, {Transparency = 1}, 0.26, Quad, In, 0.08)
	end
	task.delay(0.36 * Tw.S(), function()
		rigStand:stop(0)
	end)
	if state then
		state.alive = false
		state.heartRunning = false
		if state.idleAura then
			Kit.enable(state.idleAura, false)
		end
		if state.standLight then
			state.standLight:Destroy()
		end
		if state.backLight then
			state.backLight:Destroy()
		end
		if state.heart then
			state.heart:Destroy()
		end
	else
		local idle = stand:FindFirstChild("IdleAura")
		if idle then
			Kit.enable(idle, false)
		end
		local torso = stand:FindFirstChild("Stand Torso")
		local heart = torso and torso:FindFirstChild("HeartLight")
		if heart then
			heart:Destroy()
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
	for _, name in ipairs({"ChainRing", "Crack", "ShieldBreak", "Shock", "Charge", "Hit1", "Hit3", "Wind", "RingShock", "Slashes", "SlashImpact", "BigCrack", "BigExplosion", "RealExplosion", "PackExplosion", "PackF", "Smoke", "Rays"}) do
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
	-- the road roller draws once too
	local rr = root.Assets.RoadRoller:Clone()
	for _, p in ipairs(rr:GetDescendants()) do
		if p:IsA("BasePart") then
			p.Transparency = 0.98
			p.Anchored = true
		end
	end
	rr:PivotTo(at * CFrame.new(0, 6, 0))
	rr.Parent = fx
	for _, name in ipairs({"EyeRing", "Sphere", "Ripple"}) do
		local m = Kit.mesh(name, fx, at, V3(2, 2, 2), P.gold, 0.98)
		if m then
			m.Anchored = true
			m.CanCollide = false
			m.Material = Enum.Material.Neon
		end
	end
	local ff = Instance.new("Part")
	ff.Shape = Enum.PartType.Ball
	ff.Material = Enum.Material.ForceField
	ff.Transparency = 0.98
	ff.Size = V3(2, 2, 2)
	ff.Anchored = true
	ff.CanCollide = false
	ff.CFrame = at
	ff.Parent = fx
	local sp = Emitters.carrier(fx, at, V3(1, 1, 1))
	for _, tex in ipairs({"shards", "lightray", "windA", "circle", "glow"}) do
		local e = Emitters.make(sp, {texture = tex, Lifetime = NumberRange.new(0.05, 0.1), Transparency = NumberSequence.new(1)})
		e:Emit(1)
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
	-- the impact frames draw neon clones inside a viewport, a separate first draw: the body, the stand and the roller go through it once here
	local gui = Instance.new("ScreenGui")
	gui.Name = "StandWarmViewport"
	gui.ResetOnSpawn = false
	local vp = Instance.new("ViewportFrame")
	vp.Size = UDim2.fromScale(1, 1)
	vp.BackgroundTransparency = 1
	vp.ImageTransparency = 0.99
	vp.Parent = gui
	local vcam = Instance.new("Camera")
	vcam.CFrame = CFrame.lookAt(at.Position + V3(0, 6, 18), at.Position + V3(0, 4, 0))
	vcam.Parent = vp
	vp.CurrentCamera = vcam
	local sources = {rr.PrimaryPart}
	for _, p in ipairs(character:GetDescendants()) do
		if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
			table.insert(sources, p)
		end
	end
	for _, src in ipairs(sources) do
		if src then
			local c = src:Clone()
			for _, d in ipairs(c:GetChildren()) do
				if not d:IsA("DataModelMesh") then
					d:Destroy()
				end
			end
			c.Material = Enum.Material.Neon
			c.Transparency = 0
			c.Anchored = true
			if c:IsA("MeshPart") then
				c.TextureID = ""
			end
			c.CFrame = at * CFrame.new(0, 4, 0)
			c.Parent = vp
		end
	end
	gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	RunService.RenderStepped:Wait()
	RunService.RenderStepped:Wait()
	gui:Destroy()
	fx:Destroy()
end

return SummonVfx
