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

-- the roller mesh is 16 long and 8.6 tall and lies along dio's line, front away from him; rays over the mesh gave
-- the rear hood top a flat 1.16 above the centre (z 3 to 6) and the front housing top a flat 3.4 at z -5, so dio rides
-- the hood 4.8 behind the centre (both feet on the flat part in every pose) with his root 3 above it, and the
-- world dives at the housing with its fists on the metal
local ROLLER_H = 8.6
local ROOT_H = 3
local REAR = 4.8
local HOOD_H = 1.16
local DECK = V3(0, 3.4, -5)
local SEAT = CFrame.new(0, HOOD_H + ROOT_H, REAR)
-- real scale gravity (9.81 m/s2 at 0.28 m a stud): the leap is one parabola from the takeoff to the roller's landing,
-- so he rises fast, slows through the top and falls faster and faster with no hang; the jump off uses it too
local G = 35
-- the jump off lands 13.5 behind the impact, on the ground measured there at the cast
local BACK = V3(0, 0, 13.5)

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

-- dio's root in the impact frame from the takeoff to the landing: x and z at a constant speed, y a parabola that
-- leaves the start at the leap beat and meets the landed roller's seat at the land beat
local function flight(state, t)
	local s = state.startLocal
	local tau = T.land - T.leap
	local seat = V3(0, ROLLER_H / 2 + HOOD_H + ROOT_H, REAR)
	local u = math.clamp(t - T.leap, 0, tau)
	local vy = (seat.Y - s.Y + G / 2 * tau * tau) / tau
	local k = u / tau
	return V3(s.X + (seat.X - s.X) * k, s.Y + vy * u - G / 2 * u * u, s.Z + (seat.Z - s.Z) * k)
end

-- the roller's centre height above the impact ground once it is down: it squashes on the land, then sinks under
-- the rush
local function rollerY(t)
	local landed = ROLLER_H / 2
	if t < T.land + 0.12 then
		return landed - 0.35 * quadOut((t - T.land) / 0.12)
	elseif t < T.land + 0.4 then
		return landed - 0.35 + 0.2 * quadOut((t - T.land - 0.12) / 0.28)
	else
		return landed - 0.15 - 1.25 * math.clamp((t - T.land - 0.4) / (T.boom - T.land - 0.4), 0, 1)
	end
end

-- the roller from the cut on: under dio's feet on his parabola until the land, then on the ground with the rush's
-- shake; nil before the cut
local function rollerCF(state, t)
	if t < T.catch then
		return nil
	elseif t < T.land then
		return state.impact * CFrame.new(flight(state, t)) * SEAT:Inverse()
	end
	local j = (t > T.land + 0.4 and t < T.boom) and 0.06 * math.sin(t * math.pi * 2 * 12) or 0
	return state.impact * CFrame.new(j, rollerY(t), 0)
end

-- dio's root through the cutscene in the impact frame: still through the crouch, the parabola, the seat on the
-- roller, then the jump off with the blast: a second parabola from the seat to the ground behind the wreck
local function rootAt(state, t)
	local impact = state.impact
	if t < T.leap then
		return impact * CFrame.new(state.startLocal)
	elseif t < T.catch then
		return impact * CFrame.new(flight(state, t))
	elseif t < T.boom then
		return rollerCF(state, t) * SEAT
	elseif t < T.touch then
		local air = T.touch - T.boom
		local from = V3(0, rollerY(T.boom) + HOOD_H + ROOT_H, REAR)
		local u = t - T.boom
		local back = state.back
		local vy = (back.Y - from.Y + G / 2 * air * air) / air
		local k = u / air
		return impact * CFrame.new(from.X + (back.X - from.X) * k, from.Y + vy * u - G / 2 * u * u, from.Z + (back.Z - from.Z) * k)
	end
	return impact * CFrame.new(state.back)
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
		-- the opening orbits dio where he stands (the impact point is ten studs ahead of him)
		CameraRig.take(impact * CFrame.new(state.startLocal.X, state.startLocal.Y - ROOT_H, state.startLocal.Z), {angle = 150, dist = 13, height = 3.2, lookY = 3, fov = 60})
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
		if isLocal and t < T.touch + 0.1 then
			hrp.CFrame = rootAt(state, t)
		end
		if state.trail then
			state.trail.CFrame = hrp.CFrame * CFrame.new(0, -2.5, 0) * CFrame.Angles(math.pi, 0, 0)
		end
		local rc = rollerCF(state, t)
		if rc and roller.PrimaryPart and t < T.boom then
			roller:PivotTo(rc)
			state.rollerCF = rc
			if roller.PrimaryPart.Transparency > 0 and t >= T.catch then
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
				local deck = (state.rollerCF or hrp.CFrame) * CFrame.new(DECK.X + (math.random() - 0.5) * 3.2, DECK.Y + 0.15, DECK.Z + (math.random() - 0.5) * 1.6)
				state.flash.CFrame = deck
				state.flashE:Emit(1)
				state.sparkE:Emit(5)
				if beat % 6 == 0 then
					sfx(RR.Voice.hit, hrp, 0.55, 0.9 + math.random() * 0.2)
					Kit.burst("RingShock", deck * CFrame.new(0, 0.1, 0), state.fx, 1, {color = P.gold, color2 = P.pale, scale = 1.1, glow = 1, life = 0.6})
					Kit.burst("PackF", deck, state.fx, {brightershards = 4, BLACKSHARDS = 2}, {scale = 0.5, life = 1.2})
				end
				if beat % 3 == 0 then
					Kit.burst("Hit2", deck, state.fx, 1, {color = P.gold, color2 = P.white, scale = 0.55, glow = 1, life = 0.4})
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
	local feet = impact * CFrame.new(state.startLocal - V3(0, ROOT_H, 0))
	Kit.burst("Shock", feet * CFrame.new(0, 0.4, 0) * CFrame.Angles(math.pi / 2, 0, 0), state.fx, 1, {color = P.gold, scale = 1.4, glow = 1, life = 0.8})
	Kit.burst("Smoke", feet * CFrame.new(0, 0.5, 0), state.fx, {Smoke1 = 14}, {color = Color3.fromRGB(165, 150, 125), scale = 1.4, life = 1.6})
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
	-- the cut: the roller is under his feet (fetched in stopped time, a gold ring where it arrived) and the shot looks
	-- down from the sky
	Tw.wait(T.catch - T.leap)
	if not state.alive then
		return
	end
	sfx("Impact", hrp, 0.5, 1.2)
	local arrive = rollerCF(state, T.catch)
	if arrive then
		Kit.burst("RingShock", arrive, state.fx, 1, {color = P.gold, color2 = P.pale, scale = 2.6, glow = 1, life = 0.7})
	end
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
			-- the rush orbits dio on the hood: front right for the scream, drifting to his side for the punches, the world
			-- pounding the housing on the right of the frame
			CameraRig.cutTo({angle = 132, dist = 17, height = 9.5, lookY = 9, fov = 60, roll = 0}, impact * CFrame.new(0, 0, REAR))
			CameraRig.shot({angle = 96, dist = 15, height = 9}, T.boom - T.land - 0.2, Sine, InOut)
			CameraRig.floor(0.2)
		end
	end)
	-- the rush on the roller: dio stands up on it and screams, then rides it low with the world hammering the deck
	Tw.wait(T.point - T.land)
	if not state.alive then
		return
	end
	state.rigDio:play(Clips.DioRollerRide, {fadeIn = 0.05})
	state.rigStand:play(Clips.WorldRollerBarrage, {fadeIn = 0.22})
	local flash = Emitters.carrier(state.fx, hrp.CFrame, V3(2.4, 1.2, 2.4))
	state.flash = flash
	state.flashE = Emitters.make(flash, {
		texture = "glow",
		Shape = Enum.ParticleEmitterShape.Box,
		ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume,
		Speed = NumberRange.new(0, 0),
		Lifetime = NumberRange.new(0.08, 0.14),
		Size = Tw.seq({{0, 1.2}, {0.3, 0.8}, {1, 0}}),
		Color = Tw.cseq({{0, P.white}, {0.5, P.gold}, {1, P.amber}}),
		Transparency = Tw.seq({{0, 0.1}, {1, 1}}),
		Rotation = NumberRange.new(0, 360),
	})
	state.sparkE = Emitters.make(flash, {
		texture = "spark",
		Shape = Enum.ParticleEmitterShape.Box,
		ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume,
		Speed = NumberRange.new(14, 30),
		Acceleration = V3(0, -40, 0),
		Drag = 2,
		SpreadAngle = Vector2.new(70, 70),
		EmissionDirection = Enum.NormalId.Top,
		Lifetime = NumberRange.new(0.25, 0.5),
		Size = Tw.seq({{0, 0.45}, {1, 0}}),
		Color = Tw.cseq({{0, P.white}, {0.4, P.gold}, {1, P.amber}}),
		Transparency = Tw.seq({{0, 0}, {1, 1}}),
		RotSpeed = NumberRange.new(-400, 400),
	})
	state.standLight = light(stand["Stand Torso"], P.gold, 0.7, 9)
	state.echo = true
	task.spawn(function()
		while state.alive and state.echo do
			SummonVfx.afterimage(stand, state.fx, 0.18, P.gold, 0.82)
			Tw.wait(0.45)
		end
	end)
	-- the crouch for the jump off, then the blast as his feet leave the roller
	Tw.wait(T.jump - T.point)
	if not state.alive then
		return
	end
	state.rigDio:play(Clips.DioRollerOff, {fadeIn = 0.05})
	Tw.wait(T.boom - T.jump)
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
	if isLocal then
		CameraRig.cutTo({angle = 70, dist = 44, height = 14, lookY = 6, fov = 66, roll = 0}, impact)
		task.delay(0.5 * Tw.S(), function()
			if state.alive then
				CameraRig.shot({dist = 36, angle = 55, height = 11}, T.fade - T.boom - 0.5, Sine, Out)
			end
		end)
	end
	-- the touch down behind the wreck: a puff of dust under the feet, then the laugh on the ground
	Tw.wait(T.touch - T.boom)
	if not state.alive then
		return
	end
	Kit.burst("Smoke", impact * CFrame.new(state.back - V3(0, ROOT_H - 0.5, 0)), state.fx, {Smoke1 = 12}, {color = Color3.fromRGB(165, 150, 125), scale = 1.2, life = 1.4})
	sfx("GroundSlamSFX", hrp, 0.35, 1.3)
	-- the laugh gets its own shot: front three quarters from his left (the world floats at his right) on dio where he
	-- landed, pushing in slowly until the fade
	if isLocal then
		task.delay(0.3 * Tw.S(), function()
			if state.alive then
				CameraRig.cutTo({angle = 212, dist = 12, height = 3.5, lookY = 4.3, fov = 55, roll = 0}, impact * CFrame.new(state.back.X, state.back.Y - ROOT_H, state.back.Z))
				CameraRig.shot({angle = 200, dist = 9.5, height = 3}, T.fade - T.touch - 0.3, Sine, Out)
			end
		end)
	end
	-- the laugh ends in the stance and the walk gets the body back
	Tw.wait(T.free - T.touch)
	if not state.alive then
		return
	end
	if isLocal then
		hrp.Anchored = false
		ctrl.frozen = false
	end
	state.rigDio:play(Clips.DioMove, {fadeIn = 0.3})
	-- the fade out, the hand back in the dark, the fade in
	Tw.wait(T.fade - T.free)
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
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {character}
	local hit = workspace:Raycast((info.impact * CFrame.new(BACK.X, 8, BACK.Z)).Position, V3(0, -30, 0), params)
	state.back = V3(BACK.X, (hit and info.impact:PointToObjectSpace(hit.Position).Y or 0) + ROOT_H, BACK.Z)
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
