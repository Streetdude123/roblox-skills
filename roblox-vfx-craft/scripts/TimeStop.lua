local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")

local root = script.Parent.Parent
local Config = require(root.Config)
local Tw = require(script.Parent.Tw)
local Kit = require(script.Parent.Kit)
local Emitters = require(script.Parent.Emitters)
local CameraRig = require(script.Parent.CameraRig)
local ScreenFx = require(script.Parent.ScreenFx)
local ImpactFrames = require(script.Parent.ImpactFrames)
local Poser = require(script.Parent.Poser)
local Clips = require(script.Parent.Clips)
local Locomotion = require(script.Parent.Locomotion)
local SummonVfx = require(script.Parent.SummonVfx)

local P = Config.Palette
local TS = Config.TimeStop
local T = TS.Beats
local V3 = Vector3.new
local Quad, Sine = Enum.EasingStyle.Quad, Enum.EasingStyle.Sine
local Out, In, InOut = Enum.EasingDirection.Out, Enum.EasingDirection.In, Enum.EasingDirection.InOut
local sfx = SummonVfx.sfx

local TimeStop = {}

local active = {}
local cc

local function newModel(name)
	local m = Instance.new("Model")
	m.Name = name
	m.Parent = workspace
	return m
end

local function standRig(character)
	local rig = SummonVfx.rigOf(character)
	if rig then
		return rig
	end
	local loco = Locomotion.start(character)
	return Poser.attach(character, loco and loco.ctx)
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

-- stopped time is a grey world with a cold violet tint; the correction lives in lighting and is shared
local function correction()
	if cc and cc.Parent then
		return cc
	end
	cc = Lighting:FindFirstChild("TimeStopCC") or Instance.new("ColorCorrectionEffect")
	cc.Name = "TimeStopCC"
	cc.Saturation = 0
	cc.Contrast = 0
	cc.Brightness = 0
	cc.TintColor = Color3.new(1, 1, 1)
	cc.Parent = Lighting
	return cc
end

-- the clock behind the stand: the summon's rune ring three times larger, a rim and one beam hand that
-- spins up through the command and stops dead on the snap
local function clock(state, offset, scale)
	local torso = state.stand["Stand Torso"]
	local at = torso.CFrame * offset
	local ring = Kit.spawn("ChainRing", at * CFrame.Angles(math.pi / 2, 0, 0), state.fx)
	if ring then
		Kit.tint(ring, P.gold, P.amber)
		Kit.scale(ring, scale)
		Kit.glow(ring, 0.7)
		Kit.set(ring, {RotSpeed = NumberRange.new(60, 90)}, {Floor1 = 1, Floor2 = 1, Floor3 = 1})
		Kit.enable(ring, true, {Floor1 = 1, Floor2 = 1, Floor3 = 1})
		Kit.eachBeam(ring, function(b)
			b.Enabled = false
		end)
		state.ring = ring
	end
	local rim = Kit.mesh("EyeRing", state.fx, at, V3(4.0 * scale, 4.0 * scale, 0.14), P.gold, 1)
	if rim then
		rim.Anchored = true
		rim.CanCollide = false
		rim.CanQuery = false
		rim.Material = Enum.Material.Neon
		Tw.play(rim, {Transparency = 0.55}, 0.4, Quad, Out)
		state.rim = rim
	end
	local hub = Emitters.carrier(state.fx, at, V3(0.2, 0.2, 0.2))
	local a0 = Instance.new("Attachment")
	a0.Parent = hub
	local a1 = Instance.new("Attachment")
	a1.Position = V3(0, 1.5 * scale, 0)
	a1.Parent = hub
	local hand = Instance.new("Beam")
	hand.Attachment0 = a0
	hand.Attachment1 = a1
	hand.Texture = Emitters.TEX.lightray
	hand.TextureMode = Enum.TextureMode.Stretch
	hand.Width0 = 0.14
	hand.Width1 = 0.6
	hand.Color = ColorSequence.new(P.pale)
	hand.Transparency = NumberSequence.new(0.1)
	hand.LightEmission = 1
	hand.FaceCamera = true
	hand.Parent = hub
	state.hand = hub
	state.handAngle = 0
	state.handSpeed = 1.5
	state.clockConn = RunService.Heartbeat:Connect(function(dt)
		if not torso.Parent then
			return
		end
		local cf = torso.CFrame * offset
		if state.ring then
			state.ring.CFrame = cf * CFrame.Angles(math.pi / 2, 0, 0)
		end
		if state.rim then
			state.rim.CFrame = cf
		end
		if not state.handStopped then
			state.handAngle += state.handSpeed * math.pi * 2 * dt / Tw.S()
			state.handSpeed = math.min(16, state.handSpeed + 4 * dt / Tw.S())
		end
		hub.CFrame = cf * CFrame.new(0, 0, -0.05) * CFrame.Angles(0, 0, -state.handAngle)
	end)
end

local function clockStop(state)
	state.handStopped = true
	state.handAngle = 0
	if state.rim then
		state.rim.Color = P.white
		state.rim.Transparency = 0.05
		Tw.play(state.rim, {Transparency = 1, Size = state.rim.Size * 1.6}, 0.5, Quad, In)
	end
	if state.ring then
		Kit.tint(state.ring, P.white, P.lavender)
		Kit.set(state.ring, {RotSpeed = NumberRange.new(0, 0)}, {Floor1 = 1, Floor2 = 1, Floor3 = 1})
		Kit.kill(state.ring, 1.2)
	end
	if state.hand then
		for _, b in ipairs(state.hand:GetDescendants()) do
			if b:IsA("Beam") then
				Tw.play(b, {Width0 = 0, Width1 = 0}, 0.4, Quad, In, 0.2)
			end
		end
	end
end

-- the ripple of stopped time: a veined glass sphere and a plain force field ball race out from the stand
-- to the horizon while the colour drains, and a flat ring runs along the ground under them
local function ripple(state, origin, reverse)
	local fx = state.fx
	local veined = Kit.mesh("FancySphere", fx, origin, V3(2, 2, 2), P.lavender, 0.2)
	if veined then
		veined.Anchored = true
		veined.CanCollide = false
		veined.CanQuery = false
		veined.Material = Enum.Material.ForceField
		veined.CastShadow = false
	end
	local ball = Instance.new("Part")
	ball.Shape = Enum.PartType.Ball
	ball.Material = Enum.Material.Glass
	ball.Color = P.lavender
	ball.Transparency = 0.55
	ball.Size = V3(2, 2, 2)
	ball.Anchored = true
	ball.CanCollide = false
	ball.CanQuery = false
	ball.CastShadow = false
	ball.CFrame = origin
	ball.Parent = fx
	local ground = state.base
	local ringMesh = Kit.mesh("Ripple", fx, ground * CFrame.new(0, 0.3, 0), V3(4, 0.05, 4), P.gold, 0.4)
	if ringMesh then
		ringMesh.Anchored = true
		ringMesh.CanCollide = false
		ringMesh.CanQuery = false
		ringMesh.Material = Enum.Material.Neon
	end
	if reverse then
		if veined then
			veined.Size = V3(260, 260, 260)
			veined.Transparency = 0.8
			Tw.play(veined, {Size = V3(2, 2, 2), Transparency = 0.1}, 0.5, Quad, In)
		end
		ball.Size = V3(240, 240, 240)
		ball.Transparency = 0.9
		Tw.play(ball, {Size = V3(2, 2, 2), Transparency = 0.5}, 0.48, Quad, In)
		if ringMesh then
			ringMesh.Size = V3(140, 0.05, 140)
			ringMesh.Transparency = 0.9
			Tw.play(ringMesh, {Size = V3(4, 0.05, 4), Transparency = 0.3}, 0.5, Quad, In)
		end
		Debris:AddItem(veined, 0.6 * Tw.S())
		Debris:AddItem(ball, 0.6 * Tw.S())
		Debris:AddItem(ringMesh, 0.6 * Tw.S())
		return
	end
	if veined then
		Tw.play(veined, {Size = V3(260, 260, 260), Transparency = 1}, 0.8, Quad, Out)
	end
	Tw.play(ball, {Size = V3(240, 240, 240), Transparency = 1}, 0.72, Quad, Out)
	if ringMesh then
		Tw.play(ringMesh, {Size = V3(140, 0.05, 140), Transparency = 1}, 0.7, Quad, Out)
	end
	Kit.burst("RingShock", ground * CFrame.new(0, 0.5, 0), fx, 1, {color = P.lavender, color2 = P.white, scale = 3, glow = 1, life = 1.2})
	Debris:AddItem(veined, 1 * Tw.S())
	Debris:AddItem(ball, 1 * Tw.S())
	Debris:AddItem(ringMesh, 1 * Tw.S())
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

-- the call: 3.1 s keyed to the voice line; dio's hand rises on za warudo, the stand looms and spreads, the
-- pause holds on a low shot of it with one heartbeat, toki wo tomare winds the clock up, and the last
-- syllable snaps the thrust, the impact frames, the ripple and the grey; only the caster's camera moves
local function call(state)
	local character, hrp, stand = state.character, state.hrp, state.stand
	local isLocal = state.isLocal
	state.rig:play(Clips.WorldTimeStop, {fadeIn = 0.1})
	Locomotion.override(character, Clips.DioTimeStop, {fadeIn = 0.1, fadeOut = 0.35})
	SummonVfx.mixSetup(state)
	sfx(TS.Voice.call, hrp, 1.2, 1)
	local torso = stand["Stand Torso"]
	state.standLight = light(torso, P.gold, 0.6, 10)
	Tw.play(state.standLight, {Brightness = 1.6, Range = 14}, T.pause, Quad, Out)
	local aura = stand:FindFirstChild("IdleAura")
	if aura then
		Kit.set(aura, {Rate = 14}, {Energy1 = 1, Energy2 = 1})
	end
	if isLocal then
		state.humanoid.WalkSpeed = 0
		state.humanoid.JumpPower = 0
		state.humanoid.AutoRotate = false
		-- the call orbits from the front left to the front while it pushes in, so the arms open toward the lens
		CameraRig.take(hrp.CFrame, {angle = 140, dist = 15, height = 2.0, lookY = 2.8, fov = 62})
		CameraRig.shot({dist = 10.5, height = 3.6, lookY = 3.8, angle = 172, roll = -2}, T.pause, Sine, Out)
		ScreenFx.bars(true, 0.3)
		ScreenFx.vignette(0.2, 0.4)
	end
	Tw.wait(0.25)
	if not state.alive then
		return
	end
	clock(state, CFrame.new(0, 0.6, 1.4), 2.6)
	Tw.wait(T.pause - 0.25)
	if not state.alive then
		return
	end
	-- the pause: a low shot up at the world, one heartbeat, the frame tightens
	if isLocal then
		CameraRig.cutTo({angle = 196, dist = 9.6, height = 0.5, lookY = 5.4, fov = 58, roll = -3})
		CameraRig.shot({dist = 8.8, roll = 1, lookY = 5.2}, T.command - T.pause, Sine, InOut)
		ScreenFx.vignette(0.4, 0.5)
	end
	task.delay(0.15 * Tw.S(), function()
		if state.alive then
			sfx(TS.Voice.heartbeat, hrp, 0.9, 0.9)
			local heart = torso:FindFirstChild("HeartLight")
			if heart then
				Tw.play(heart, {Brightness = 2.5, Range = 10}, 0.08, Quad, Out)
				Tw.play(heart, {Brightness = 0.25, Range = 6}, 0.6, Quad, Out, 0.1)
			end
		end
	end)
	Tw.wait(T.command - T.pause)
	if not state.alive then
		return
	end
	-- the command: a tight profile on dio for "toki wo", then back to the low stand shot pushing in for "tomare"
	if isLocal then
		CameraRig.cutTo({angle = 96, dist = 5.6, height = 0.9, lookY = 2.3, fov = 50, roll = 2})
		CameraRig.shot({dist = 5.0, angle = 104}, 0.55, Sine, Out)
		task.delay(0.6 * Tw.S(), function()
			if state.alive then
				CameraRig.cutTo({angle = 200, dist = 9.0, height = 0.4, lookY = 5.3, fov = 56, roll = -2})
				CameraRig.shot({dist = 7.2, roll = -5, lookY = 5.0}, T.snap - T.command - 0.6, Sine, In)
			end
		end)
	end
	-- the gold fan opens behind it and the light climbs while the clock races
	local fan = Kit.spawn("Rays", torso.CFrame * CFrame.new(0, 0.4, 1.0), state.fx)
	if fan then
		Kit.tint(fan, P.gold, P.lavender)
		Kit.glow(fan, 1)
		Kit.scale(fan, 1.6)
		Kit.enable(fan, true)
		state.fan = fan
		state.fanConn = RunService.Heartbeat:Connect(function()
			if torso.Parent then
				fan.CFrame = torso.CFrame * CFrame.new(0, 0.4, 1.0)
			end
		end)
	end
	Tw.play(state.standLight, {Brightness = 3.2, Range = 18}, T.snap - T.command, Quad, In)
	Tw.wait(T.snap - T.command)
	if not state.alive then
		return
	end
	-- the snap
	clockStop(state)
	local origin = torso.CFrame * CFrame.new(0, 0, -1.2)
	state.base = groundBelow(hrp.CFrame, character)
	sfx(TS.Voice.snap, hrp, 1.0, 1)
	sfx("Shock", hrp, 0.6, 0.8)
	task.delay(0.16 * Tw.S(), function()
		if hrp.Parent then
			sfx(TS.Voice.snap, hrp, 0.6, 0.85)
		end
	end)
	-- both rigs hang on the thrust for a beat so the pose burns in
	state.rig:hold(0.1)
	local ctrl = Locomotion.get(character)
	if ctrl then
		ctrl.rig:hold(0.1)
	end
	for _, name in ipairs({"Stand Right Arm", "Stand Left Arm"}) do
		local arm = stand:FindFirstChild(name)
		if arm then
			Kit.burst("ShieldBreak", arm.CFrame * CFrame.new(0, -1, 0), state.fx, {Specs = 16, Shockwave = 1}, {color = P.gold, color2 = P.lavender, scale = 1.6, glow = 1, life = 1.2})
		end
	end
	Kit.burst("Crack", origin * CFrame.new(0, 0, -1.5) * CFrame.Angles(math.pi / 2, 0, 0), state.fx, {Floor1 = 1, Floor2 = 1}, {color = P.pale, color2 = P.lavender, scale = 2.6, glow = 1, life = 1.2})
	for i = 1, 3 do
		task.delay((i - 1) * 0.06 * Tw.S(), function()
			if stand.Parent then
				SummonVfx.afterimage(stand, state.fx, 0.3 + i * 0.06, P.gold, 0.5)
			end
		end)
	end
	if state.fan then
		Kit.kill(state.fan, 0.8)
		state.fan = nil
	end
	Tw.play(state.standLight, {Brightness = 1.0, Range = 10}, 0.6, Quad, Out)
	if aura then
		Kit.set(aura, {Rate = 4}, {Energy1 = 1, Energy2 = 1})
	end
	local c = correction()
	c.Brightness = 0.25
	c.TintColor = Color3.fromRGB(190, 160, 255)
	Tw.play(c, {Saturation = -1, Contrast = 0.2, Brightness = -0.06, TintColor = Color3.fromRGB(205, 200, 235)}, 0.45, Quad, Out, 0.06)
	-- stopped time is darker: the exposure drops a third of a stop for as long as the world hangs
	if Lighting:GetAttribute("TSExposure0") == nil then
		Lighting:SetAttribute("TSExposure0", Lighting.ExposureCompensation)
	end
	Tw.play(Lighting, {ExposureCompensation = Lighting:GetAttribute("TSExposure0") - 0.35}, 0.6, Quad, Out, 0.1)
	if isLocal then
		CameraRig.freeze(T.frames - T.snap + 0.1)
		ScreenFx.flash(0.7, 0.14, P.pale)
		task.spawn(ImpactFrames.play, {character, stand}, {{"gold", 0.05}, {"purple", 0.05}, {"white", 0.04}, {"black", 0.03}})
		CameraRig.kick(0.75)
	end
	ripple(state, origin, false)
	Tw.wait(T.frames - T.snap + 0.1)
	if not state.alive then
		return
	end
	-- the pull back: a hard cut to a far rear three quarter that draws in while the ripple runs to the horizon
	if isLocal then
		CameraRig.cutTo({angle = 34, dist = 26, height = 8, lookY = 3, fov = 68, roll = 0})
		CameraRig.shot({dist = 15, angle = 18, height = 5.5}, T.done - T.frames - 0.1, Sine, Out)
		ScreenFx.bars(false, 0.4)
		ScreenFx.vignette(0.15, 0.4)
	end
	Tw.wait(T.done - T.frames - 0.1)
	if not state.alive then
		return
	end
	if isLocal then
		CameraRig.cut(character)
		state.humanoid.WalkSpeed = state.speed0.WalkSpeed
		state.humanoid.JumpPower = state.speed0.JumpPower
		state.humanoid.AutoRotate = state.speed0.AutoRotate
		state.speed0 = nil
	end
	state.rig:play(Clips.WorldStopped, {fadeIn = 0.5})
	-- the heart keeps time while nothing else does, and dio laughs into the silence
	state.beating = true
	task.spawn(function()
		while state.beating and hrp.Parent do
			sfx(TS.Voice.heartbeat, hrp, 0.35, 0.85)
			Tw.wait(0.86)
		end
	end)
	task.delay(0.35 * Tw.S(), function()
		if state.beating and hrp.Parent then
			sfx("Laugh", hrp, 0.9, 1)
		end
	end)
end

local function cleanup(state, failed)
	state.alive = false
	state.beating = false
	if state.clockConn then
		state.clockConn:Disconnect()
	end
	if state.fanConn then
		state.fanConn:Disconnect()
	end
	if state.isLocal and state.speed0 and state.humanoid.Parent then
		state.humanoid.WalkSpeed = state.speed0.WalkSpeed
		state.humanoid.JumpPower = state.speed0.JumpPower
		state.humanoid.AutoRotate = state.speed0.AutoRotate
		state.speed0 = nil
	end
	if failed and state.isLocal then
		CameraRig.cut(state.character)
		ScreenFx.reset()
	end
	if failed then
		Locomotion.release(state.character, 0.3)
	end
	Debris:AddItem(state.fx, 3 * Tw.S())
end

function TimeStop.start(character, isLocal)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	local stand = character:FindFirstChild("Stand")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not hrp or not stand or not humanoid then
		return
	end
	local state = {character = character, hrp = hrp, stand = stand, humanoid = humanoid, isLocal = isLocal, alive = true, fx = newModel("TimeStopFx")}
	state.speed0 = {WalkSpeed = humanoid.WalkSpeed, JumpPower = humanoid.JumpPower, AutoRotate = humanoid.AutoRotate}
	state.rig = standRig(character)
	active[character] = state
	local ok, err = pcall(call, state)
	if not ok then
		warn("time stop failed", err)
	end
	local keep = state.alive
	cleanup(state, not ok)
	state.alive = keep and ok
	if not state.alive then
		active[character] = nil
	end
end

-- the resume: the voice line first, then 1.6 s later the ripple runs back in, the colour returns and the
-- stand drops out of the thrust into its float
function TimeStop.stop(character, isLocal)
	local state = active[character]
	active[character] = nil
	local hrp = character:FindFirstChild("HumanoidRootPart")
	local stand = character:FindFirstChild("Stand")
	if hrp then
		sfx(TS.Voice.resume, hrp, 1.1, 1)
	end
	task.delay(1.6 * Tw.S(), function()
		local c = correction()
		Tw.play(c, {Saturation = 0, Contrast = 0, Brightness = 0, TintColor = Color3.new(1, 1, 1)}, 0.4, Quad, Out)
		local e0 = Lighting:GetAttribute("TSExposure0")
		if e0 ~= nil then
			Tw.play(Lighting, {ExposureCompensation = e0}, 0.5, Quad, Out)
			Lighting:SetAttribute("TSExposure0", nil)
		end
		if isLocal then
			ScreenFx.vignette(0, 0.5)
		end
		local torso = stand and stand:FindFirstChild("Stand Torso")
		local fx = newModel("TimeStopFx")
		Debris:AddItem(fx, 2 * Tw.S())
		if torso and hrp then
			local s = {fx = fx, base = groundBelow(hrp.CFrame, character)}
			ripple(s, torso.CFrame, true)
			sfx("TSEndVoice", hrp, 1.0, 1)
			sfx("Shock", hrp, 0.5, 1.1)
			for i = 1, 2 do
				task.delay((i - 1) * 0.06 * Tw.S(), function()
					if stand.Parent then
						SummonVfx.afterimage(stand, fx, 0.25 + i * 0.05, P.lavender, 0.55)
					end
				end)
			end
		end
		if state then
			state.beating = false
			if state.standLight then
				Tw.play(state.standLight, {Brightness = 0.7, Range = 8}, 0.5)
			end
			if state.rig then
				state.rig:play(Clips.WorldFloat, {fadeIn = 0.4})
			end
		elseif stand then
			local rig = standRig(character)
			rig:play(Clips.WorldFloat, {fadeIn = 0.4})
		end
		if isLocal then
			CameraRig.kick(0.3)
		end
	end)
end

return TimeStop
