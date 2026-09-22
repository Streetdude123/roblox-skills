local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")

local root = script.Parent.Parent
local Config = require(root.Config)
local Tw = require(script.Parent.Tw)
local Kit = require(script.Parent.Kit)
local Emitters = require(script.Parent.Emitters)
local CameraRig = require(script.Parent.CameraRig)
local Poser = require(script.Parent.Poser)
local Clips = require(script.Parent.Clips)
local Locomotion = require(script.Parent.Locomotion)
local SummonVfx = require(script.Parent.SummonVfx)

local P = Config.Palette
local B = Config.Barrage
local V3 = Vector3.new
local Quad = Enum.EasingStyle.Quad
local Out, In = Enum.EasingDirection.Out, Enum.EasingDirection.In
local sfx = SummonVfx.sfx

local Moves = {}

local barrages = {}
local lastHitSound = 0

local function newModel(name)
	local m = Instance.new("Model")
	m.Name = name
	m.Parent = workspace
	return m
end

-- the stand rig of a character, made on the spot for a client that missed the summon
local function standRig(character)
	local rig = SummonVfx.rigOf(character)
	if rig then
		return rig
	end
	local loco = Locomotion.start(character)
	return Poser.attach(character, loco and loco.ctx)
end

-- gold echoes of the arms only so a rush leaves fist trails and not a whole second body every beat
local function armEcho(stand, parent, life)
	local m = Instance.new("Model")
	m.Name = "ArmEcho"
	for _, p in ipairs(SummonVfx.standParts(stand)) do
		local arm = p:FindFirstAncestor("Rarm") or p:FindFirstAncestor("Larm")
		if arm and p.Transparency < 0.9 then
			local c = p:Clone()
			for _, d in ipairs(c:GetChildren()) do
				if not d:IsA("DataModelMesh") then
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
			c.Material = Enum.Material.Neon
			c.Color = P.gold
			c.Transparency = 0.6
			c.CFrame = p.CFrame
			c.Parent = m
			Tw.play(c, {Transparency = 1}, life, Quad, In)
		end
	end
	m.Parent = parent
	Debris:AddItem(m, life * Tw.S() + 0.1)
end

-- the barrage: the stand steps in front, the model's rush loop runs, gold wind streaks pour forward from the
-- fists, a fist flash lands in the air every beat, and the arms leave echoes; dio points through it
function Moves.barrage(character, isLocal, on)
	local state = barrages[character]
	if on then
		if state then
			return
		end
		local hrp = character:FindFirstChild("HumanoidRootPart")
		local stand = character:FindFirstChild("Stand")
		if not hrp or not stand then
			return
		end
		state = {character = character, hrp = hrp, stand = stand, alive = true, fx = newModel("BarrageFx")}
		barrages[character] = state
		state.rig = standRig(character)
		state.rig:play(Clips.WorldBarrage, {fadeIn = 0.12})
		Locomotion.override(character, Clips.DioBarrage, {fadeIn = 0.1})
		-- the user plants and points: no turning, no jumping, the server holds the walk speed at zero
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if isLocal and humanoid then
			state.humanoid = humanoid
			state.lock0 = {AutoRotate = humanoid.AutoRotate, JumpPower = humanoid.JumpPower}
			humanoid.AutoRotate = false
			humanoid.JumpPower = 0
		end
		state.voice = sfx("MudaRush", hrp, 0.95, 1)
		state.swing = sfx("BarrageSFX", hrp, 0.6, 1)
		-- the wind carrier sits at the fists and points forward so every streak flies down the rush
		local wind = Kit.spawn("Wind", hrp.CFrame * CFrame.new(0.4, 1.0, -4.6), state.fx)
		if wind then
			Kit.tint(wind, P.gold, P.pale)
			Kit.glow(wind, 1)
			Kit.scale(wind, 0.8)
			Kit.set(wind, {Rate = 28, Speed = NumberRange.new(26, 40), Lifetime = NumberRange.new(0.16, 0.26), SpreadAngle = Vector2.new(14, 14), EmissionDirection = Enum.NormalId.Top})
			Kit.enable(wind, true)
			state.wind = wind
		end
		local flash = Emitters.carrier(state.fx, hrp.CFrame, V3(2.6, 2.6, 1.2))
		state.flashE = Emitters.make(flash, {
			texture = "glow",
			Shape = Enum.ParticleEmitterShape.Box,
			ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume,
			Speed = NumberRange.new(0, 0),
			Lifetime = NumberRange.new(0.08, 0.14),
			Size = Tw.seq({{0, 1.6}, {0.3, 1.1}, {1, 0}}),
			Color = Tw.cseq({{0, P.white}, {0.5, P.gold}, {1, P.amber}}),
			Transparency = Tw.seq({{0, 0.1}, {1, 1}}),
			Rotation = NumberRange.new(0, 360),
		})
		state.flash = flash
		state.light = Instance.new("PointLight")
		state.light.Color = P.gold
		state.light.Brightness = 1.4
		state.light.Range = 11
		state.light.Shadows = false
		state.light.Parent = flash
		local beat = 0
		local acc = 0
		state.conn = RunService.Heartbeat:Connect(function(dt)
			if not hrp.Parent then
				return
			end
			local front = hrp.CFrame * CFrame.new(0.4, 1.0, -4.6)
			if state.wind then
				state.wind.CFrame = front * CFrame.Angles(-math.pi / 2, 0, 0)
			end
			flash.CFrame = front
			acc += dt / Tw.S()
			if acc >= 0.083 then
				acc -= 0.083
				beat += 1
				state.flashE:Emit(2)
				if beat % 2 == 0 then
					armEcho(stand, state.fx, 0.18)
				end
				if isLocal then
					CameraRig.kick(0.09)
				end
			end
		end)
		if isLocal then
			CameraRig.rumble(hrp.Position)
		end
		return
	end
	if not state then
		return
	end
	barrages[character] = nil
	state.alive = false
	if state.conn then
		state.conn:Disconnect()
	end
	if state.wind then
		Kit.kill(state.wind, 0.6)
	end
	if state.swing then
		Tw.play(state.swing, {Volume = 0}, 0.15)
		Debris:AddItem(state.swing, 0.3)
	end
	local hrp, stand = state.hrp, state.stand
	-- the finisher: the model's heavy punch on the stand and a lunge on dio, one strong muda, the hit on its frame
	state.rig:play(Clips.WorldHeavy, {fadeIn = 0.06, onDone = function()
		state.rig:play(Clips.WorldFloat, {fadeIn = 0.4})
	end})
	Locomotion.override(character, Clips.DioHeavy, {fadeIn = 0.06, fadeOut = 0.35})
	sfx("StrongMuda", hrp, 1.0, 1)
	task.delay(0.32 * Tw.S(), function()
		if not hrp.Parent then
			return
		end
		local at = hrp.CFrame * CFrame.new(0.4, 1.0, -5.2)
		Kit.burst("Hit3", at, state.fx, 1, {color = P.gold, color2 = P.white, scale = 1.5, glow = 1, life = 1})
		Kit.burst("RingShock", at, state.fx, 1, {color = P.gold, scale = 1.6, glow = 1, life = 1})
		Kit.burst("SlashImpact", at, state.fx, {SlashImpact1 = 1, Specs1 = 10, Specs2 = 8}, {color = P.pale, color2 = P.amber, scale = 1.3, glow = 1, life = 1})
		sfx("HitStrong", hrp, 0.9, 0.95)
		for i = 1, 3 do
			task.delay((i - 1) * 0.05 * Tw.S(), function()
				if stand.Parent then
					SummonVfx.afterimage(stand, state.fx, 0.25 + i * 0.05, P.gold, 0.5)
				end
			end)
		end
		if isLocal then
			CameraRig.kick(0.55)
		end
	end)
	Debris:AddItem(state.fx, 3 * Tw.S())
	if isLocal then
		task.delay(0.8 * Tw.S(), CameraRig.stopRumble)
		task.delay(0.55 * Tw.S(), function()
			if state.humanoid and state.humanoid.Parent and state.lock0 then
				state.humanoid.AutoRotate = state.lock0.AutoRotate
				state.humanoid.JumpPower = state.lock0.JumpPower
			end
		end)
	end
end

-- a hit on a target: a gold fist flash and a short punch sound, limited so a rush never stacks sixty sounds
function Moves.hit(target, kind, pos)
	local fx = newModel("HitFx")
	Debris:AddItem(fx, 2 * Tw.S())
	local at = CFrame.new(pos)
	local now = os.clock()
	if kind == "Barrage" or kind == "Frozen" then
		local frozen = kind == "Frozen"
		Kit.burst("Hit1", at, fx, 1, {color = frozen and P.lavender or P.gold, color2 = P.white, scale = frozen and 0.8 or 1.0, glow = 1, life = 0.8})
		if now - lastHitSound > 0.11 then
			lastHitSound = now
			sfx(frozen and "LMB1" or "HitSoundTW", fx, frozen and 0.35 or 0.5, 0.95 + math.random() * 0.1)
		end
	elseif kind == "Heavy" then
		Kit.burst("Hit3", at, fx, 1, {color = P.gold, color2 = P.white, scale = 1.4, glow = 1, life = 1})
		Kit.burst("ShieldBreak", at, fx, {Specs = 12, Shockwave = 1}, {color = P.gold, color2 = P.pale, scale = 1.3, glow = 1, life = 1})
		sfx("HitStrong", fx, 0.9, 1)
	elseif kind == "Release" then
		-- every hit that landed in stopped time arrives at once when it moves again
		Kit.burst("Hit3", at, fx, 1, {color = P.lavender, color2 = P.white, scale = 2.0, glow = 1, life = 1.2})
		Kit.burst("ShieldBreak", at, fx, {Specs = 20, Shockwave = 1}, {color = P.lavender, color2 = P.gold, scale = 1.8, glow = 1, life = 1.2})
		Kit.burst("RingShock", at, fx, 1, {color = P.gold, scale = 2.2, glow = 1, life = 1.2})
		Emitters.burst(fx, at, V3(2, 2, 2), {
			texture = "shards",
			Speed = NumberRange.new(10, 22),
			Drag = 3,
			Acceleration = V3(0, -14, 0),
			SpreadAngle = Vector2.new(180, 180),
			Lifetime = NumberRange.new(0.5, 1.0),
			Size = Tw.seq({{0, 0.7}, {1, 0.25}}),
			Color = Tw.cseq({{0, P.white}, {0.4, P.lavender}, {1, P.violet}}),
			Transparency = Tw.seq({{0, 0.1}, {0.7, 0.2}, {1, 1}}),
			Rotation = NumberRange.new(0, 360),
			RotSpeed = NumberRange.new(-300, 300),
		}, 18, 1.4)
		sfx("HitStrong", fx, 1.0, 0.85)
		sfx("Bass", fx, 0.8, 1)
	end
end

-- a frozen body holds every pose: both rigs stop their clocks, its emitters and sounds pause
function Moves.frozen(character, on)
	local ctrl = Locomotion.get(character)
	if ctrl then
		ctrl.frozen = on
		ctrl.rig:setSpeed(on and 0 or 1)
	end
	local rig = SummonVfx.rigOf(character)
	if rig then
		rig:setSpeed(on and 0 or 1)
	end
	for _, d in ipairs(character:GetDescendants()) do
		if d:IsA("ParticleEmitter") then
			d.TimeScale = on and 0 or 1 / Tw.S()
		elseif d:IsA("Sound") and d.IsPlaying and on then
			d:Pause()
		elseif d:IsA("Sound") and d.IsPaused and not on then
			d:Resume()
		end
	end
end

return Moves
