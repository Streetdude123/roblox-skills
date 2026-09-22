local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local root = script.Parent.Parent
local Config = require(root.Config)
local Tw = require(script.Parent.Tw)
local Kit = require(script.Parent.Kit)
local Emitters = require(script.Parent.Emitters)
local CameraRig = require(script.Parent.CameraRig)
local ScreenFx = require(script.Parent.ScreenFx)
local ImpactFrames = require(script.Parent.ImpactFrames)
local SpeedLines = require(script.Parent.SpeedLines)
local Poser = require(script.Parent.Poser)
local Clips = require(script.Parent.Clips)
local Locomotion = require(script.Parent.Locomotion)
local SummonVfx = require(script.Parent.SummonVfx)

local P = Config.Palette
local RR = Config.RoadRoller
local T = RR.Beats
local V3 = Vector3.new
local Quad, Sine = Enum.EasingStyle.Quad, Enum.EasingStyle.Sine
local Out, In, InOut = Enum.EasingDirection.Out, Enum.EasingDirection.In, Enum.EasingDirection.InOut
local sfx = SummonVfx.sfx

local RoadRoller = {}
local active = {}

-- the roller mesh is 16 long and 8.6 tall; dio rides the rear deck with his root 3 above the top
local ROLLER_H = 8.6
local ROOT_H = 3
local REAR = 3

local function newModel(name)
	local m = Instance.new("Model")
	m.Name = name
	m.Parent = workspace
	return m
end

local function quadOut(u)
	u = math.clamp(u, 0, 1)
	return 1 - (1 - u) * (1 - u)
end
local function quadIn(u)
	u = math.clamp(u, 0, 1)
	return u * u
end
local function sineInOut(u)
	u = math.clamp(u, 0, 1)
	return 0.5 - 0.5 * math.cos(u * math.pi)
end

-- the roller's centre height above the impact ground through the cutscene: it drops in from the sky to just
-- under dio's feet at the apex, falls with him to the ground, squashes on the land, then sinks under the rush
local function rollerY(t)
	local apexCentre = RR.Apex - ROOT_H - ROLLER_H / 2
	local landed = ROLLER_H / 2
	if t < T.reach then
		return nil
	elseif t < T.catch then
		return 75 + (apexCentre - 75) * quadIn((t - T.reach) / (T.catch - T.reach))
	elseif t < T.land then
		return apexCentre + (landed - apexCentre) * quadIn((t - T.catch) / (T.land - T.catch))
	elseif t < T.land + 0.12 then
		return landed - 0.35 * quadOut((t - T.land) / 0.12)
	elseif t < T.land + 0.4 then
		return landed - 0.35 + 0.2 * quadOut((t - T.land - 0.12) / 0.28)
	else
		return landed - 0.15 - 1.25 * math.clamp((t - T.land - 0.4) / (T.boom - T.land - 0.4), 0, 1)
	end
end

-- dio's root through the cutscene in the impact frame: a leap to the apex, a settle as he grabs, the fall on
-- the roller, the ride, then an arc back to the ground behind the wreck
local function rootAt(state, t)
	local impact = state.impact
	local start = state.startLocal
	local apex = V3(0, RR.Apex, REAR)
	local p
	if t < T.leap then
		p = start
	elseif t < T.leap + 1.0 then
		local u = (t - T.leap) / 1.0
		p = V3(start.X + (apex.X - start.X) * sineInOut(u), start.Y + (apex.Y - start.Y) * quadOut(u), start.Z + (apex.Z - start.Z) * sineInOut(u))
	elseif t < T.catch then
		local u = (t - T.leap - 1.0) / (T.catch - T.leap - 1.0)
		p = apex - V3(0, 0.4 * sineInOut(u), 0)
	elseif t < T.off then
		local ry = rollerY(t) or (ROLLER_H / 2)
		p = V3(0, ry + ROLLER_H / 2 + ROOT_H, REAR)
	elseif t < T.off + 0.65 then
		local u = (t - T.off) / 0.65
		local from = V3(0, (rollerY(T.off - 0.01) or 3) + ROLLER_H / 2 + ROOT_H, REAR)
		local to = V3(0, ROOT_H, 14)
		p = from:Lerp(to, sineInOut(u)) + V3(0, 6 * 4 * u * (1 - u), 0)
	else
		p = V3(0, ROOT_H, 14)
	end
	return impact * CFrame.new(p)
end

local function rollerCF(state, t)
	local y = rollerY(t)
	if not y then
		return nil
	end
	local tilt = 0
	if t < T.land then
		tilt = -0.14 * quadIn((t - T.reach) / (T.land - T.reach))
	elseif t < T.land + 0.3 then
		tilt = -0.14 + 0.14 * quadOut((t - T.land) / 0.3)
	end
	local j = (t > T.land + 0.4 and t < T.boom) and 0.06 * math.sin(t * math.pi * 2 * 12) or 0
	return state.impact * CFrame.new(j, y, 0) * CFrame.Angles(tilt, math.pi / 2, 0)
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

-- the land: the roller slams the ground under the far shot, the frame freezes, dust and rock and a gold ring
local function landFx(state)
	local at = state.impact
	Kit.burst("BigCrack", at * CFrame.new(0, 0.3, 0), state.fx, {Impact1 = 1, Impact2 = 1, Ash1 = 30, Fire1 = 0}, {color = P.amber, color2 = P.deep, scale = 2.2, glow = 0.6, life = 2})
	Kit.burst("RingShock", at * CFrame.new(0, 0.6, 0), state.fx, 1, {color = P.gold, color2 = P.pale, scale = 4, glow = 1, life = 1.4})
	Kit.burst("PackF", at * CFrame.new(0, 0.5, 0), state.fx, {["rocks(14"] = 22, impact = 1, ground1 = 1}, {scale = 1.8, life = 3})
	Kit.burst("Smoke", at * CFrame.new(0, 1, 0), state.fx, {Smoke1 = 40}, {color = Color3.fromRGB(165, 150, 125), scale = 3, life = 4})
	local l = light(state.roller and state.roller.PrimaryPart or state.hrp, P.amber, 3, 30)
	Tw.play(l, {Brightness = 0}, 0.6, Quad, Out)
	Debris:AddItem(l, 1)
	sfx(RR.Voice.land, state.hrp, 1.0, 1)
	sfx("Bass", state.hrp, 0.9, 0.9)
	sfx("GroundSlamSFX", state.hrp, 0.8, 1)
	if state.isLocal then
		CameraRig.freeze(0.15)
		task.spawn(ImpactFrames.play, {state.character, state.stand, state.roller}, {{"white", 0.05}, {"black", 0.05}, {"gold", 0.04}})
		CameraRig.kick(1.0)
		SpeedLines.pulse(0.8, 0.4)
		ScreenFx.flash(0.6, 0.12, P.pale)
	end
end

-- the blast: the roller vanishes behind an explosion of the kit's pieces, rock and black shards and a fire light
local function boomFx(state)
	local centre = state.roller and state.roller.PrimaryPart and state.roller.PrimaryPart.CFrame or state.impact * CFrame.new(0, 4, 0)
	if state.roller then
		for _, p in ipairs(state.roller:GetDescendants()) do
			if p:IsA("BasePart") then
				p.Transparency = 1
			end
		end
	end
	if state.rollerLight then
		state.rollerLight:Destroy()
		state.rollerLight = nil
	end
	Kit.burst("BigExplosion", centre, state.fx, {Fire1 = 40, Fire2 = 30, Fire3 = 24, SmokeDark1 = 30, Specks1 = 40}, {scale = 2.4, glow = 1, life = 4})
	Kit.burst("RealExplosion", centre, state.fx, 2, {scale = 2.6, life = 3})
	Kit.burst("PackExplosion", centre, state.fx, {Shards = 30, Shockwave = 1, Spark = 40, Specs = 40, SpecsDark = 30, Wind = 2}, {color = P.amber, color2 = P.gold, scale = 2.2, glow = 1, life = 3})
	Kit.burst("PackF", centre, state.fx, {["rocks(14"] = 30, BLACKSHARDS = 24, brightershards = 20, ["flash(1"] = 1}, {scale = 2.2, life = 4})
	Kit.burst("Smoke", centre, state.fx, {Smoke1 = 60}, {color = Color3.fromRGB(60, 55, 50), scale = 4, life = 6})
	local carrier = Emitters.carrier(state.fx, centre, V3(1, 1, 1))
	local l = light(carrier, P.amber, 6, 60)
	Tw.play(l, {Brightness = 0}, 1.6, Quad, Out)
	Debris:AddItem(carrier, 2)
	sfx("Impact", state.hrp, 1.0, 0.9)
	sfx("Bass", state.hrp, 1.0, 0.8)
	sfx("ShadowExplosion", state.hrp, 0.9, 1)
	if state.isLocal then
		CameraRig.freeze(0.1)
		task.spawn(ImpactFrames.play, {state.character, state.stand}, {{"gold", 0.05}, {"red", 0.05}, {"white", 0.04}})
		CameraRig.kick(1.2)
		ScreenFx.flash(0.7, 0.16, P.amber)
		SpeedLines.pulse(0.9, 0.5)
	end
end

local function run(state)
	local character, hrp, stand = state.character, state.hrp, state.stand
	local isLocal = state.isLocal
	local impact = state.impact
	local ctrl = Locomotion.start(character)
	state.rigDio = ctrl.rig
	state.rigStand = SummonVfx.rigOf(character) or Poser.attach(character, ctrl.ctx)
	state.rigDio:play(Clips.DioRollerUp, {fadeIn = 0.08})
	SummonVfx.mixSetup(state)
	sfx(RR.Voice.track, hrp, 1.0, 1)
	sfx(RR.Voice.bed, hrp, 0.7, 1)
	sfx(RR.Voice.windup, hrp, 0.8, 1)
	-- the roller waits in the sky until the reach beat
	local roller = root.Assets.RoadRoller:Clone()
	for _, p in ipairs(roller:GetDescendants()) do
		if p:IsA("BasePart") then
			p.Anchored = true
			p.CanCollide = false
			p.Transparency = 1
		end
	end
	roller.Parent = state.fx
	state.roller = roller
	-- the caster's own root is driven every frame; other clients see it replicate
	if isLocal then
		ctrl.frozen = true
		hrp.Anchored = true
		-- walk speed and jump power are the server's (zeroed at the cast, restored at done); a client restore raced its zero
		state.humanoid.AutoRotate = false
		CameraRig.take(impact, {angle = 150, dist = 16, height = 3, lookY = 3, fov = 60})
		ScreenFx.bars(true, 0.3)
		ScreenFx.vignette(0.3, 0.4)
	end
	local t0 = os.clock()
	local beat, acc = 0, 0
	state.conn = RunService.Heartbeat:Connect(function(dt)
		if not state.alive or not hrp.Parent then
			return
		end
		local t = (os.clock() - t0) / Tw.S()
		if isLocal and t < T.off + 0.7 then
			hrp.CFrame = rootAt(state, t)
		end
		if state.trail then
			state.trail.CFrame = hrp.CFrame * CFrame.new(0, -2.5, 0) * CFrame.Angles(math.pi, 0, 0)
		end
		local rc = rollerCF(state, t)
		if rc and roller.PrimaryPart and t < T.boom then
			roller:PivotTo(rc)
			if roller.PrimaryPart.Transparency > 0 and t >= T.reach then
				for _, p in ipairs(roller:GetDescendants()) do
					if p:IsA("BasePart") then
						p.Transparency = 0
					end
				end
				state.rollerLight = light(roller.PrimaryPart, P.gold, 1.6, 44)
			end
		end
		-- the rush on the deck: a fist flash and sparks every beat, a hit sound every six
		if t > T.land + 0.4 and t < T.boom and state.flashE then
			acc += dt / Tw.S()
			if acc >= 0.083 then
				acc -= 0.083
				beat += 1
				state.flash.CFrame = hrp.CFrame * CFrame.new(0.6 + (math.random() - 0.5) * 1.5, -1.6, -4.5 + (math.random() - 0.5) * 1.5)
				state.flashE:Emit(2)
				state.sparkE:Emit(4)
				if beat % 6 == 0 then
					sfx(RR.Voice.hit, hrp, 0.55, 0.9 + math.random() * 0.2)
				end
				if isLocal then
					CameraRig.kick(0.09)
				end
			end
		end
	end)
	-- the leap
	Tw.wait(T.leap)
	if not state.alive then
		return
	end
	sfx(RR.Voice.jump, hrp, 0.8, 1)
	Kit.burst("Shock", impact * CFrame.new(0, 0.4, 0) * CFrame.Angles(math.pi / 2, 0, 0), state.fx, 1, {color = P.gold, scale = 1.4, glow = 1, life = 0.8})
	local trail = Kit.spawn("Wind", hrp.CFrame * CFrame.new(0, -2.5, 0) * CFrame.Angles(math.pi, 0, 0), state.fx)
	if trail then
		Kit.tint(trail, P.gold, P.pale)
		Kit.glow(trail, 1)
		Kit.scale(trail, 1.1)
		Kit.set(trail, {Rate = 34, Speed = NumberRange.new(30, 46), Lifetime = NumberRange.new(0.18, 0.3), SpreadAngle = Vector2.new(18, 18), EmissionDirection = Enum.NormalId.Top})
		Kit.enable(trail, true)
		state.trail = trail
		task.delay((T.catch - T.leap) * Tw.S(), function()
			Kit.kill(trail, 0.5)
			state.trail = nil
		end)
	end
	if isLocal then
		CameraRig.shot({lookY = RR.Apex - 2, height = 18, dist = 21, angle = 140}, 1.0, Sine, Out)
		SpeedLines.pulse(0.6, 0.4)
	end
	-- the catch: the roller drops onto his hands and the shot goes to the sky looking down
	Tw.wait(T.catch - T.leap)
	if not state.alive then
		return
	end
	sfx("Impact", hrp, 0.5, 1.2)
	if isLocal then
		CameraRig.cutTo({angle = 200, dist = 30, height = 44, lookY = RR.Apex - 6, fov = 60, roll = 0})
		CameraRig.shot({lookY = 6, height = 12, dist = 26}, T.land - T.catch, Quad, In)
	end
	-- the land
	Tw.wait(T.land - T.catch)
	if not state.alive then
		return
	end
	landFx(state)
	task.delay(0.2 * Tw.S(), function()
		if state.alive and isLocal then
			CameraRig.cutTo({angle = 40, dist = 22, height = 7, lookY = 5, fov = 62, roll = 0})
			CameraRig.shot({angle = 110, dist = 20, height = 6}, T.boom - T.land - 0.2, Sine, InOut)
			CameraRig.floor(0.2)
		end
	end)
	-- the rush on the roller: dio in the point, the world hammering the deck, echoes and streaks
	Tw.wait(T.point - T.land)
	if not state.alive then
		return
	end
	state.rigDio:play(Clips.DioPoint, {fadeIn = 0.15})
	state.rigStand:play(Clips.WorldRollerBarrage, {fadeIn = 0.15})
	local flash = Emitters.carrier(state.fx, hrp.CFrame, V3(2.4, 1.2, 2.4))
	state.flash = flash
	state.flashE = Emitters.make(flash, {
		texture = "glow",
		Shape = Enum.ParticleEmitterShape.Box,
		ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume,
		Speed = NumberRange.new(0, 0),
		Lifetime = NumberRange.new(0.08, 0.14),
		Size = Tw.seq({{0, 1.8}, {0.3, 1.2}, {1, 0}}),
		Color = Tw.cseq({{0, P.white}, {0.5, P.gold}, {1, P.amber}}),
		Transparency = Tw.seq({{0, 0.1}, {1, 1}}),
		Rotation = NumberRange.new(0, 360),
	})
	state.sparkE = Emitters.make(flash, {
		texture = "spark",
		Shape = Enum.ParticleEmitterShape.Box,
		ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume,
		Speed = NumberRange.new(10, 22),
		Drag = 4,
		SpreadAngle = Vector2.new(180, 180),
		Lifetime = NumberRange.new(0.15, 0.35),
		Size = Tw.seq({{0, 0.4}, {1, 0}}),
		Color = Tw.cseq({{0, P.white}, {0.4, P.gold}, {1, P.amber}}),
		Transparency = Tw.seq({{0, 0}, {1, 1}}),
		RotSpeed = NumberRange.new(-400, 400),
	})
	state.standLight = light(stand["Stand Torso"], P.gold, 1.6, 12)
	state.echo = true
	task.spawn(function()
		while state.alive and state.echo do
			SummonVfx.afterimage(stand, state.fx, 0.2, P.gold, 0.6)
			Tw.wait(0.25)
		end
	end)
	-- the blast
	Tw.wait(T.boom - T.point)
	if not state.alive then
		return
	end
	state.echo = false
	state.flashE = nil
	if state.standLight then
		state.standLight:Destroy()
	end
	boomFx(state)
	state.rigStand:play(Clips.WorldFloat, {fadeIn = 0.4})
	state.rigDio:play(Clips.DioRollerOff, {fadeIn = 0.06})
	if isLocal then
		CameraRig.cutTo({angle = 70, dist = 44, height = 14, lookY = 6, fov = 66, roll = 0})
		task.delay(0.5 * Tw.S(), function()
			if state.alive then
				CameraRig.shot({dist = 36, angle = 55, height = 11}, T.fade - T.boom - 0.5, Sine, Out)
			end
		end)
	end
	-- back on the ground: the walk gets the body, the laugh runs on the voice track
	Tw.wait(T.off + 0.75 - T.boom)
	if not state.alive then
		return
	end
	if isLocal then
		hrp.Anchored = false
		ctrl.frozen = false
	end
	task.delay(0.5 * Tw.S(), function()
		if state.alive then
			state.rigDio:play(Clips.DioMove, {fadeIn = 0.3})
		end
	end)
	-- the fade out, the hand back in the dark, the fade in
	Tw.wait(T.fade - T.off - 0.75)
	if not state.alive then
		return
	end
	if isLocal then
		ScreenFx.fade(1, 0.4)
		task.delay(0.5 * Tw.S(), function()
			CameraRig.cut(character)
			ScreenFx.bars(false, 0)
			ScreenFx.vignette(0, 0)
			ScreenFx.fade(0, 0.5)
		end)
	end
	Tw.wait(T.done - T.fade)
end

local function cleanup(state, failed)
	state.alive = false
	state.echo = false
	if state.conn then
		state.conn:Disconnect()
	end
	if state.isLocal then
		local hrp = state.hrp
		if hrp.Parent then
			hrp.Anchored = false
		end
		local ctrl = Locomotion.get(state.character)
		if ctrl then
			ctrl.frozen = false
		end
		if state.humanoid.Parent and state.speed0 then
			state.humanoid.AutoRotate = state.speed0.AutoRotate
		end
		if failed then
			CameraRig.cut(state.character)
			ScreenFx.reset()
		end
		CameraRig.floor(0.16)
	end
	if failed then
		Locomotion.release(state.character, 0.3)
		if state.rigStand then
			state.rigStand:play(Clips.WorldFloat, {fadeIn = 0.3})
		end
	end
	Debris:AddItem(state.fx, 6 * Tw.S())
end

function RoadRoller.start(character, isLocal, info)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	local stand = character:FindFirstChild("Stand")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not hrp or not stand or not humanoid or type(info) ~= "table" or typeof(info.impact) ~= "CFrame" then
		return
	end
	local old = active[character]
	if old then
		old.alive = false
	end
	local state = {character = character, hrp = hrp, stand = stand, humanoid = humanoid, isLocal = isLocal, alive = true, fx = newModel("RoadRollerFx")}
	state.impact = info.impact
	-- the start point is kept in the impact frame so the leap lands on the deck whatever the ground did
	state.startLocal = info.impact:PointToObjectSpace(hrp.Position)
	state.speed0 = {AutoRotate = humanoid.AutoRotate}
	active[character] = state
	local ok, err = pcall(run, state)
	if not ok then
		warn("road roller failed", err)
	end
	cleanup(state, not ok)
	if active[character] == state then
		active[character] = nil
	end
end

return RoadRoller
