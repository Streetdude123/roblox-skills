local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")
local SoundService = game:GetService("SoundService")

local root = script.Parent.Parent
local Config = require(root.Config)
local Tw = require(script.Parent.Tw)
local Emitters = require(script.Parent.Emitters)
local ImpactFrames = require(script.Parent.ImpactFrames)
local SpeedLines = require(script.Parent.SpeedLines)
local CameraRig = require(script.Parent.CameraRig)
local ScreenFx = require(script.Parent.ScreenFx)

local Meshes = root.Assets.Meshes
local Sounds = root.Assets.Sounds
local Animations = root.Assets.Animations
local P = Config.Palette
local SP = Config.Sparkle
local R = math.rad
local V3 = Vector3.new

local UltimateVfx = {}

local Quad, Quart, Back, Sine, Bounce = Enum.EasingStyle.Quad, Enum.EasingStyle.Quart, Enum.EasingStyle.Back, Enum.EasingStyle.Sine, Enum.EasingStyle.Bounce
local In, Out, InOut = Enum.EasingDirection.In, Enum.EasingDirection.Out, Enum.EasingDirection.InOut

-- wall clock beats in seconds so the clip speed changes and the effects share one schedule
local T = {
	hold = 1.4,
	charge = 3.4,
	peak = 3.95,
	slash = 4.5,
	impact = 4.55,
	follow = 4.69,
	crown = 4.77,
	crownEnd = 5.2,
	pillar = 5.36,
	ret = 6.41,
	mid = 6.85,
	freeze = 7.29,
	collapse = 7.85,
	burst = 8.11,
	wave2 = 8.55,
	wave3 = 9.0,
	after = 10.35,
	fade = 11.25,
	black = 12.05,
	fadeIn = 12.55,
}

local function newModel(name)
	local m = Instance.new("Model")
	m.Name = name
	m.Parent = workspace
	return m
end

local function mesh(name, parent, cf, size, color, transparency)
	local m = Meshes[name]:Clone()
	m.CFrame = cf
	m.Size = size
	m.Color = color
	m.Transparency = transparency or 0
	m.Parent = parent
	return m
end

local function prim(shape, parent, cf, size, color, transparency, material)
	local p = Instance.new("Part")
	p.Shape = shape
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	p.Material = material or Enum.Material.Neon
	p.Color = color
	p.Transparency = transparency or 0
	p.Size = size
	p.CFrame = cf
	p.Parent = parent
	return p
end

local function ball(parent, cf, d, color, transparency)
	return prim(Enum.PartType.Ball, parent, cf, V3(d, d, d), color, transparency)
end

-- a roblox cylinder runs along x so it is rolled onto y and sized as length then diameter
local function cyl(parent, baseCF, height, d, color, transparency)
	return prim(Enum.PartType.Cylinder, parent, baseCF * CFrame.new(0, height / 2, 0) * CFrame.Angles(0, 0, R(90)), V3(height, d, d), color, transparency)
end

local function cylTo(part, baseCF, height, d, dur, style, dir, delayTime)
	return Tw.play(part, {Size = V3(height, d, d), CFrame = baseCF * CFrame.new(0, height / 2, 0) * CFrame.Angles(0, 0, R(90))}, dur, style, dir, delayTime)
end

local function fade(part, dur, delayTime, kill)
	local t = Tw.play(part, {Transparency = 1}, dur, Quad, Out, delayTime)
	if kill ~= false then
		t.Completed:Once(function()
			part:Destroy()
		end)
	end
	return t
end

local activeMix, activeHits

-- a hard knee at the top keeps every stacked layer under the master ceiling
local function limiter(parent, priority)
	local comp = Instance.new("CompressorSoundEffect")
	comp.Threshold = -9
	comp.Ratio = 12
	comp.Attack = 0.001
	comp.Release = 0.12
	comp.GainMakeup = 0
	comp.Priority = priority
	comp.Parent = parent
	return comp
end

-- the bed group ducks and muffles as a whole and the hits group only gets limited so a hit cuts through a duck
local function mixSetup(state)
	local h = SoundService:FindFirstChild("UltHits") or Instance.new("SoundGroup")
	h.Name = "UltHits"
	h.Volume = 1
	h:ClearAllChildren()
	h.Parent = SoundService
	limiter(h, 1)
	local air = Instance.new("EqualizerSoundEffect")
	air.HighGain = 3
	air.MidGain = 0
	air.LowGain = 0
	air.Priority = 0
	air.Parent = h
	local g = SoundService:FindFirstChild("UltMix") or Instance.new("SoundGroup")
	g.Name = "UltMix"
	g.Volume = 1
	g:ClearAllChildren()
	g.Parent = SoundService
	limiter(g, 2)
	local eq = Instance.new("EqualizerSoundEffect")
	eq.HighGain = 0
	eq.MidGain = 0
	eq.LowGain = 0
	eq.Priority = 1
	eq.Parent = g
	local air2 = Instance.new("EqualizerSoundEffect")
	air2.HighGain = 3
	air2.MidGain = 0
	air2.LowGain = 0
	air2.Priority = 3
	air2.Parent = g
	local rev = Instance.new("ReverbSoundEffect")
	rev.DecayTime = 2.2
	rev.WetLevel = -80
	rev.DryLevel = 0
	rev.Diffusion = 1
	rev.Density = 1
	rev.Priority = 0
	rev.Parent = g
	state.mix, state.hits, state.eq, state.reverb = g, h, eq, rev
	activeMix, activeHits = g, h
end

local function mixReset(state)
	if state.mix then
		state.mix.Volume = 1
		state.eq.HighGain = 0
		state.eq.MidGain = 0
		state.reverb.WetLevel = -80
	end
	activeMix, activeHits = nil, nil
end

local function duck(state, vol, dur, delayTime)
	Tw.play(state.mix, {Volume = vol}, dur, Quad, Out, delayTime)
end

local function muffle(state, high, mid, dur, delayTime)
	Tw.play(state.eq, {HighGain = high, MidGain = mid}, dur, Quad, Out, delayTime)
end

-- a hit goes to the hits group so it still cuts through a full duck on the bed
local function sfx(name, at, volume, speed, hit)
	local template = Sounds:FindFirstChild(name)
	if not template or template.SoundId == "" then
		return nil
	end
	local s = template:Clone()
	s.Volume = volume or template.Volume
	s.PlaybackSpeed = (speed or 1) / Tw.S()
	s.RollOffMode = Enum.RollOffMode.InverseTapered
	s.RollOffMinDistance = 40
	s.RollOffMaxDistance = 500
	s.SoundGroup = hit and activeHits or activeMix
	s.Parent = at
	s:Play()
	local start = template:GetAttribute("Start")
	if start then
		s.TimePosition = start
	end
	if not s.Looped then
		Debris:AddItem(s, 12 * Tw.S())
	end
	return s
end

-- a stab holds a clip for a moment then fades it so a slowed hit does not turn into a drone
local function stab(sound, hold, fadeTime)
	if sound then
		Tw.play(sound, {Volume = 0}, fadeTime, Quad, Out, hold)
		Debris:AddItem(sound, (hold + fadeTime + 0.1) * Tw.S())
	end
	return sound
end

local function polar(base, angle, radius, y)
	return base * CFrame.Angles(0, angle, 0) * CFrame.new(0, y or 0, -radius)
end

local function rnd(a, b)
	return a + math.random() * (b - a)
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

-- spinners compose their cframe every frame so a spinning part can still ride a tweened number value
local function startSpinners(state)
	state.spinners = {}
	state.spinConn = RunService.Heartbeat:Connect(function(dt)
		for part, fn in pairs(state.spinners) do
			if part.Parent then
				fn(dt / Tw.S())
			else
				state.spinners[part] = nil
			end
		end
	end)
end

local function spin(state, part, w, extra)
	local angle = V3(0, 0, 0)
	local cf0 = part.CFrame
	state.spinners[part] = function(dt)
		angle += w * dt
		local base = extra and extra() or cf0
		part.CFrame = base * CFrame.fromEulerAnglesXYZ(angle.X, angle.Y, angle.Z)
	end
end

local function stopEmitters(carrier, life)
	if not carrier or not carrier.Parent then
		return
	end
	for _, e in ipairs(carrier:GetChildren()) do
		if e:IsA("ParticleEmitter") then
			e.Enabled = false
		end
	end
	Debris:AddItem(carrier, (life or 3) * Tw.S())
end

-- every plate probes its own floor so a step or a dais edge does not leave a slab poking out at rest
local function rockPlates(state)
	local plates = {}
	local n = 12
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {state.character, state.fxHard, state.fxSoft}
	for i = 1, n do
		local ang = (i / n) * math.pi * 2 + math.random() * 0.3
		local r = 9.5 + math.random() * 4
		local sz = 4 + math.random() * 3
		local size = V3(sz, sz * 0.55, sz * 0.9)
		local probe = polar(state.pbase, ang, r, 6)
		local hit = workspace:Raycast(probe.Position, V3(0, -20, 0), params)
		local floorY = hit and hit.Position.Y or state.pbase.Position.Y
		local ground = CFrame.new(0, floorY - state.pbase.Position.Y, 0)
		local rest = ground * polar(state.pbase, ang, r, -size.Y / 2 - 0.35)
		local plate = mesh(({"RockA", "RockB", "RockC"})[math.random(3)], state.fxSoft, rest * CFrame.Angles(0, math.random() * 6.28, 0), size, P.rock)
		plate.Material = Enum.Material.Slate
		local glow = prim(Enum.PartType.Block, state.fxSoft, ground * polar(state.pbase, ang, r, 0.08), V3(size.X + 1.2, 0.2, size.Z + 1.2), P.crimson, 1)
		table.insert(plates, {part = plate, glow = glow, ang = ang, r = r, size = size, tilt = R(22 + math.random() * 22), ground = ground})
	end
	state.plates = plates
end

local function platesUp(state, lift, dur)
	for _, pl in ipairs(state.plates) do
		local cf = pl.ground * polar(state.pbase, pl.ang, pl.r, lift + pl.size.Y / 2) * CFrame.Angles(pl.tilt, 0, 0)
		Tw.play(pl.part, {CFrame = cf}, dur, Back, Out)
		Tw.play(pl.glow, {Transparency = 0.1}, dur * 0.6)
	end
end

local function platesHover(state)
	for _, pl in ipairs(state.plates) do
		local cf = pl.ground * polar(state.pbase, pl.ang, pl.r + 1.5, 4 + math.random() * 3 + pl.size.Y / 2) * CFrame.Angles(pl.tilt + R(10), 0, 0)
		Tw.play(pl.part, {CFrame = cf}, 1.8, Sine, InOut)
	end
end

-- the burst throws the plates out and up and gravity brings them down later as debris
local function platesFling(state)
	for _, pl in ipairs(state.plates) do
		local up = pl.ground * polar(state.pbase, pl.ang, pl.r + 14, 18 + math.random() * 14) * CFrame.Angles(pl.tilt + R(60), R(math.random(-40, 40)), 0)
		Tw.play(pl.part, {CFrame = up}, 0.7, Quart, Out)
		local down = pl.ground * polar(state.pbase, pl.ang, pl.r + 22 + math.random() * 8, -0.45) * CFrame.Angles(R(math.random(-12, 12)), R(math.random(0, 180)), R(math.random(-12, 12)))
		Tw.play(pl.part, {CFrame = down}, 0.9, Bounce, Out, 0.8 + math.random() * 0.3)
		Tw.play(pl.glow, {Transparency = 1}, 0.4)
		Debris:AddItem(pl.part, 6 * Tw.S())
		Debris:AddItem(pl.glow, 6 * Tw.S())
	end
end

local function flatShock(state, cf, size0, size1, life, color, count, fps)
	local carrier = Emitters.carrier(state.fxSoft, cf * CFrame.new(0, 0.4, 0))
	local e = Emitters.make(carrier, {
		texture = "shock",
		flip = {Enum.ParticleFlipbookLayout.Grid4x4, Enum.ParticleFlipbookMode.OneShot, fps or 32},
		Orientation = Enum.ParticleOrientation.VelocityPerpendicular,
		EmissionDirection = Enum.NormalId.Top,
		Speed = NumberRange.new(0.05),
		Lifetime = NumberRange.new(life),
		Size = Tw.seq({{0, size0}, {1, size1}}),
		Transparency = Tw.seq({{0, 0}, {0.7, 0.1}, {1, 1}}),
		Color = ColorSequence.new(color),
		Rotation = NumberRange.new(0, 360),
	})
	e:Emit(count or 1)
	Debris:AddItem(carrier, (life + 0.5) * Tw.S())
end

local function flatCrack(state, cf, tex, size, life, ttl)
	local carrier = Emitters.carrier(state.fxSoft, cf * CFrame.new(0, 0.3, 0))
	Emitters.make(carrier, {
		texture = tex,
		Orientation = Enum.ParticleOrientation.VelocityPerpendicular,
		EmissionDirection = Enum.NormalId.Top,
		Speed = NumberRange.new(0.02),
		Lifetime = NumberRange.new(life),
		Size = Tw.seq({{0, size * 0.6}, {0.05, size}, {1, size * 1.05}}),
		Transparency = Tw.seq({{0, 0}, {0.35, 0.15}, {1, 1}}),
		Color = Tw.cseq({{0, P.white}, {0.15, P.crimson}, {1, Color3.fromRGB(100, 8, 26)}}),
		Rotation = NumberRange.new(0, 360),
		ZOffset = 0.2,
	}):Emit(1)
	Debris:AddItem(carrier, (ttl or life + 0.5) * Tw.S())
end

-- a flat glow disc on the floor that breathes under the pillar and the burst
local function floorGlow(state, cf, size, color, life)
	local carrier = Emitters.carrier(state.fxSoft, cf * CFrame.new(0, 0.5, 0))
	local e = Emitters.make(carrier, {
		texture = "glow",
		Orientation = Enum.ParticleOrientation.VelocityPerpendicular,
		EmissionDirection = Enum.NormalId.Top,
		Speed = NumberRange.new(0.02),
		Lifetime = NumberRange.new(life),
		Size = Tw.seq({{0, size * 0.5}, {0.15, size}, {0.85, size}, {1, size * 0.6}}),
		Transparency = Tw.seq({{0, 1}, {0.1, 0.35}, {0.85, 0.4}, {1, 1}}),
		Color = ColorSequence.new(color),
		ZOffset = -0.5,
	})
	e:Emit(1)
	Debris:AddItem(carrier, (life + 0.5) * Tw.S())
end

local function popStar(state, cf, size, color, dur)
	local s = mesh("Star", state.fxHard, cf * CFrame.Angles(math.random() * 6, math.random() * 6, 0), V3(0.2, 0.2, 0.2), color)
	spin(state, s, V3(0, 3, 1.5))
	Tw.play(s, {Size = V3(size, size, size)}, dur * 0.35, Back, Out)
	Tw.play(s, {Size = V3(0.1, 0.1, 0.1)}, dur * 0.5, Quad, In, dur * 0.5)
	Debris:AddItem(s, dur * Tw.S() + 0.1)
end

local function glowBurst(state, cf, tex, size0, size1, life, color, count, z)
	Emitters.burst(state.fxSoft, cf, nil, {
		texture = tex,
		Speed = NumberRange.new(0),
		Lifetime = NumberRange.new(life),
		Size = Tw.seq({{0, size0}, {0.3, size1}, {1, size1 * 1.1}}),
		Transparency = Tw.seq({{0, 0}, {0.6, 0.2}, {1, 1}}),
		Color = ColorSequence.new(color),
		Rotation = NumberRange.new(0, 360),
		ZOffset = z or 2,
	}, count or 1, life + 0.5)
end

-- a two frame red then cyan tint reads as lens aberration on a hit
local function glitch(state)
	Tw.play(state.cc, {TintColor = Color3.fromRGB(255, 140, 140)}, 0.02)
	task.delay(0.05 * Tw.S(), function()
		Tw.play(state.cc, {TintColor = Color3.fromRGB(140, 215, 255)}, 0.02)
	end)
	task.delay(0.1 * Tw.S(), function()
		Tw.play(state.cc, {TintColor = Color3.fromRGB(255, 228, 232)}, 0.2)
	end)
end

local function exposure(state, peak, dur)
	Tw.play(Lighting, {ExposureCompensation = peak}, 0.04)
	Tw.play(Lighting, {ExposureCompensation = state.exposure0}, dur, Quad, Out, 0.06)
end

local function dof(state, focus, radius, far, dur)
	if state.dof then
		Tw.play(state.dof, {FocusDistance = focus, InFocusRadius = radius, FarIntensity = far}, dur, Sine, InOut)
	end
end

-- ghost copies of the body left along the slash the way anime draws a fast swing
local function afterimage(state, color, count, gap, life)
	task.spawn(function()
		for _ = 1, count do
			for _, part in ipairs(state.character:GetDescendants()) do
				if part:IsA("BasePart") and part.Transparency < 1 then
					local g = part:Clone()
					for _, d in ipairs(g:GetChildren()) do
						if not d:IsA("DataModelMesh") then
							d:Destroy()
						end
					end
					g.Anchored = true
					g.CanCollide = false
					g.CanQuery = false
					g.CanTouch = false
					g.CastShadow = false
					g.Material = Enum.Material.Neon
					g.Color = color
					g.Transparency = 0.5
					if g:IsA("MeshPart") then
						g.TextureID = ""
					end
					g.CFrame = part.CFrame
					g.Parent = state.fxSoft
					fade(g, life)
				end
			end
			task.wait(gap * Tw.S())
		end
	end)
end

local function impactFrames(state, pattern)
	if state.isLocal then
		local total = 0
		for _, step in ipairs(pattern) do
			total += step[2]
		end
		CameraRig.freeze(total)
	end
	task.spawn(ImpactFrames.play, {state.character, state.fxHard}, pattern)
end

-- a bolt is a chain of short beams through jittered points so it reads as lightning not a curve
local function bolt(p0, p1, color, width, life)
	local dir = p1 - p0
	local len = dir.Magnitude
	if len < 0.5 then
		return
	end
	local u = dir.Unit
	local side = u:Cross(V3(0, 1, 0))
	if side.Magnitude < 0.1 then
		side = u:Cross(V3(1, 0, 0))
	end
	side = side.Unit
	local up = u:Cross(side)
	local n = 6
	local atts = {}
	for i = 0, n do
		local t = i / n
		local jitter = (i == 0 or i == n) and 0 or len * 0.13
		local a = Instance.new("Attachment")
		a.WorldPosition = p0 + dir * t + side * ((math.random() - 0.5) * 2 * jitter) + up * ((math.random() - 0.5) * 2 * jitter)
		a.Parent = workspace.Terrain
		Debris:AddItem(a, life * Tw.S())
		atts[i + 1] = a
	end
	for i = 1, n do
		local b = Instance.new("Beam")
		b.Attachment0 = atts[i]
		b.Attachment1 = atts[i + 1]
		b.Width0 = width
		b.Width1 = width
		b.LightEmission = 1
		b.LightInfluence = 0
		b.Color = ColorSequence.new(color)
		b.Transparency = NumberSequence.new(0.05)
		b.FaceCamera = true
		b.Segments = 1
		b.Parent = atts[i]
	end
end

-- keeps throwing bolts around a centre for dur seconds so a phase crackles without a script per bolt
local function arcs(state, centerFn, radius, height, per, dur, colors, width)
	task.spawn(function()
		local t0 = os.clock()
		while os.clock() - t0 < dur * Tw.S() and state.alive do
			local c = centerFn()
			for _ = 1, per do
				local a1, a2 = math.random() * 6.28, math.random() * 6.28
				local p0 = c + V3(math.sin(a1) * radius, rnd(0, height), math.cos(a1) * radius)
				local p1 = c + V3(math.sin(a2) * radius * rnd(0.3, 1), rnd(0, height), math.cos(a2) * radius * rnd(0.3, 1))
				bolt(p0, p1, colors[math.random(#colors)], width, rnd(0.06, 0.12))
			end
			task.wait(0.05 * Tw.S())
		end
	end)
end

local function smokeRing(state, cf, radius, speed, size0, size1, count, life, color, dark)
	Emitters.burst(state.fxSoft, cf * CFrame.new(0, 1.2, 0), V3(radius, 0.2, radius), {
		texture = dark and "darksmoke" or "smoke",
		flip = (not dark) and {Enum.ParticleFlipbookLayout.Grid4x4, Enum.ParticleFlipbookMode.OneShot, 12} or nil,
		Shape = Enum.ParticleEmitterShape.Disc,
		ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward,
		ShapeStyle = Enum.ParticleEmitterShapeStyle.Surface,
		Speed = NumberRange.new(speed * 0.8, speed * 1.2),
		Drag = 3.5,
		Lifetime = NumberRange.new(life * 0.85, life * 1.15),
		Size = Tw.seq({{0, size0}, {0.4, size1 * 0.8}, {1, size1}}),
		Color = Tw.cseq({{0, color}, {0.4, Color3.fromRGB(190, 160, 180)}, {1, Color3.fromRGB(80, 60, 80)}}),
		Transparency = Tw.seq({{0, 0.15}, {0.6, 0.4}, {1, 1}}),
		LightEmission = dark and 0 or 0.35,
		LightInfluence = dark and 1 or 0,
		Rotation = NumberRange.new(0, 360),
		RotSpeed = NumberRange.new(-50, 50),
	}, count, life + 0.5)
end

local function rockBurst(state, cf, radius, speed, count, size)
	Emitters.burst(state.fxSoft, cf * CFrame.new(0, 1, 0), V3(radius, 0.2, radius), {
		texture = "rocks",
		flip = {Enum.ParticleFlipbookLayout.Grid2x2, Enum.ParticleFlipbookMode.Random, 1},
		Shape = Enum.ParticleEmitterShape.Disc,
		EmissionDirection = Enum.NormalId.Top,
		SpreadAngle = Vector2.new(60, 60),
		Speed = NumberRange.new(speed * 0.6, speed),
		Acceleration = V3(0, -100, 0),
		Lifetime = NumberRange.new(1.2, 2.2),
		Size = Tw.seq({{0, size * 0.5}, {0.2, size}, {1, size * 0.8}}),
		Color = ColorSequence.new(P.rock),
		LightEmission = 0.25,
		LightInfluence = 0.5,
		Rotation = NumberRange.new(0, 360),
		RotSpeed = NumberRange.new(-300, 300),
		Drag = 0.4,
	}, count, 3)
end

local function sparkBurst(state, cf, count, speed, color2)
	Emitters.burst(state.fxSoft, cf, V3(3, 3, 3), {
		texture = "spark",
		Shape = Enum.ParticleEmitterShape.Sphere,
		Speed = NumberRange.new(speed * 0.5, speed),
		Drag = 2,
		Lifetime = NumberRange.new(0.6, 1.2),
		Size = Tw.seq({{0, 1}, {0.2, 6}, {1, 0}}),
		Color = Tw.cseq({{0, P.white}, {1, color2 or P.crimson}}),
		Orientation = Enum.ParticleOrientation.VelocityParallel,
	}, count, 2)
end

local function shardBurst(state, cf, count, speed, color)
	Emitters.burst(state.fxSoft, cf, V3(3, 3, 3), {
		texture = "shards",
		Shape = Enum.ParticleEmitterShape.Sphere,
		Speed = NumberRange.new(speed * 0.6, speed),
		Drag = 1.5,
		Lifetime = NumberRange.new(0.5, 1),
		Size = Tw.seq({{0, 0}, {0.2, 7}, {1, 0}}),
		Color = Tw.cseq({{0, P.white}, {1, color}}),
		Orientation = Enum.ParticleOrientation.VelocityParallel,
		Transparency = Tw.seq({{0, 0.2}, {1, 0}}),
	}, count, 1.5)
end

-- a ramp drives the speed along a shape every frame and a small correction keeps the clip on its schedule
local function ramp(track, dur, span, shape)
	local n = 60
	local cum = {}
	local sum = 0
	for i = 1, n do
		sum += shape((i - 0.5) / n)
		cum[i] = sum
	end
	local peak = span / (sum / n * dur)
	local S = Tw.S()
	local t0 = os.clock()
	local start = track.TimePosition
	while true do
		local u = (os.clock() - t0) / (dur * S)
		if u >= 1 then
			break
		end
		local expected = start + span * cum[math.clamp(math.floor(u * n) + 1, 1, n)] / sum
		local err = expected - track.TimePosition
		track:AdjustSpeed(math.max(0, peak * shape(u) + err * 6) / S)
		task.wait()
	end
	track:AdjustSpeed(0)
end

-- the clip speed changes are wall clock beats so spectators and effects stay on the same schedule
local function driveClip(state)
	local track = state.track
	if not track then
		return
	end
	local S = Tw.S()
	task.spawn(function()
		track:Play(0.08, 1, 0)
		-- the raise creeps from still and gathers speed late then eases to still at the top
		ramp(track, T.hold, 1.0, function(u)
			return math.sin(math.pi * u) ^ 0.7 * (0.45 + u)
		end)
		-- a tiny sway on the held pose so the body breathes instead of freezing like a statue
		local t0 = os.clock()
		while os.clock() - t0 < (T.slash - T.hold) * S do
			local t = (os.clock() - t0) / S
			track.TimePosition = 1.0 - 0.012 * (1 - math.cos(t * 4.2)) / 2
			task.wait()
		end
		track.TimePosition = 1.0
		track:AdjustSpeed(1.6 / S)
		Tw.wait(T.impact - T.slash)
		track:AdjustSpeed(0)
		Tw.wait(T.follow - T.impact)
		track.TimePosition = 1.08
		track:AdjustSpeed(0.55 / S)
		Tw.wait(T.pillar - T.follow)
		track:AdjustSpeed(1 / S)
		Tw.wait(T.ret - T.pillar)
		-- the return decelerates into the freeze instead of stopping dead
		ramp(track, T.freeze - T.ret, 0.66, function(u)
			return 1 - u * u
		end)
	end)
end

-- the raise itself only moves air so the body reads clean before any energy shows
local function preWind(state)
	local base, blade = state.base, state.blade
	Tw.play(Lighting, {Brightness = 1.1, OutdoorAmbient = Color3.fromRGB(58, 46, 78), Ambient = Color3.fromRGB(26, 20, 38)}, T.charge, Sine, InOut)
	if state.atmos then
		Tw.play(state.atmos, {Density = 0.55}, T.charge, Sine, InOut)
	end
	local att = Instance.new("Attachment")
	att.CFrame = CFrame.new(0, 0, 0.6)
	att.Parent = blade
	Emitters.make(att, {
		texture = "windspin",
		Speed = NumberRange.new(0),
		Lifetime = NumberRange.new(0.35, 0.5),
		Size = Tw.seq({{0, 2.5}, {1, 6}}),
		Color = ColorSequence.new(Color3.fromRGB(220, 225, 240)),
		Transparency = Tw.seq({{0, 1}, {0.15, 0.55}, {1, 1}}),
		Rotation = NumberRange.new(0, 360),
		RotSpeed = NumberRange.new(-200, 200),
		LightEmission = 0.4,
		Enabled = true,
		Rate = 9,
	})
	Emitters.make(att, {
		texture = "windA",
		Speed = NumberRange.new(1, 3),
		Lifetime = NumberRange.new(0.4, 0.7),
		Size = Tw.seq({{0, 1.5}, {1, 4}}),
		Color = ColorSequence.new(Color3.fromRGB(235, 235, 245)),
		Transparency = Tw.seq({{0, 1}, {0.2, 0.6}, {1, 1}}),
		Rotation = NumberRange.new(0, 360),
		RotSpeed = NumberRange.new(-60, 60),
		LightEmission = 0.3,
		Enabled = true,
		Rate = 8,
	})
	local a0 = Instance.new("Attachment")
	a0.CFrame = CFrame.new(0, 0, -1.6)
	a0.Parent = blade
	local a1 = Instance.new("Attachment")
	a1.CFrame = CFrame.new(0, 0, 2)
	a1.Parent = blade
	local trail = Instance.new("Trail")
	trail.Attachment0 = a0
	trail.Attachment1 = a1
	trail.Lifetime = 0.18
	trail.MinLength = 0.05
	trail.LightEmission = 0.5
	trail.LightInfluence = 0
	trail.WidthScale = Tw.seq({{0, 1}, {1, 0.3}})
	trail.Color = ColorSequence.new(Color3.fromRGB(230, 235, 250))
	trail.Transparency = Tw.seq({{0, 0.65}, {1, 1}})
	trail.Parent = blade
	local dust = Emitters.carrier(state.fxSoft, base * CFrame.new(0, 0.5, 0), V3(8, 0.2, 8))
	Emitters.make(dust, {
		texture = "darksmoke",
		Shape = Enum.ParticleEmitterShape.Disc,
		ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward,
		ShapeStyle = Enum.ParticleEmitterShapeStyle.Surface,
		Speed = NumberRange.new(3, 6),
		Drag = 2,
		Lifetime = NumberRange.new(0.8, 1.2),
		Size = Tw.seq({{0, 2}, {1, 5}}),
		Color = ColorSequence.new(Color3.fromRGB(150, 140, 160)),
		Transparency = Tw.seq({{0, 1}, {0.2, 0.7}, {1, 1}}),
		LightEmission = 0,
		LightInfluence = 0.8,
		Rotation = NumberRange.new(0, 360),
		RotSpeed = NumberRange.new(-30, 30),
		Enabled = true,
		Rate = 10,
	})
	local pebbles = Emitters.carrier(state.fxSoft, base * CFrame.new(0, 0.6, 0), V3(18, 0.2, 18))
	Emitters.make(pebbles, {
		texture = "rocks",
		flip = {Enum.ParticleFlipbookLayout.Grid2x2, Enum.ParticleFlipbookMode.Random, 1},
		Shape = Enum.ParticleEmitterShape.Disc,
		EmissionDirection = Enum.NormalId.Top,
		SpreadAngle = Vector2.new(6, 6),
		Speed = NumberRange.new(1.2, 3),
		Acceleration = V3(0, 1.2, 0),
		Lifetime = NumberRange.new(1.8, 3),
		Size = Tw.seq({{0, 0}, {0.1, 0.7}, {0.9, 0.7}, {1, 0}}),
		Color = ColorSequence.new(P.rock),
		LightEmission = 0.2,
		LightInfluence = 0.6,
		Rotation = NumberRange.new(0, 360),
		RotSpeed = NumberRange.new(-60, 60),
		Enabled = false,
		Rate = 14,
	})
	state.pebbles = pebbles
	task.delay(0.8 * Tw.S(), function()
		if state.alive then
			sfx("Wind", state.anchor, 0.45, 0.85)
		end
	end)
	task.delay((T.hold + 0.6) * Tw.S(), function()
		if state.alive then
			pebbles.ParticleEmitter.Enabled = true
		end
	end)
	state.preWind = {att, a0, a1, trail, dust}
	sfx("Wind", state.anchor, 0.4, 0.95)
	if state.isLocal then
		task.spawn(function()
			for i = 1, 5 do
				Tw.wait(0.28)
				CameraRig.kick(0.04 + i * 0.02)
			end
		end)
	end
end

local function stopPreWind(state)
	for _, x in ipairs(state.preWind or {}) do
		if x:IsA("Attachment") or x:IsA("BasePart") then
			for _, e in ipairs(x:GetChildren()) do
				if e:IsA("ParticleEmitter") then
					e.Enabled = false
				end
			end
			Debris:AddItem(x, 1.5 * Tw.S())
		else
			Debris:AddItem(x, 0.3 * Tw.S())
		end
	end
end

-- phase a gathers energy on the blade while the sword rises and the whole arena fills with the sparkle field
local function phaseCharge(state)
	state.fxHard:SetAttribute("Phase", "charge")
	local base, blade = state.base, state.blade
	local sigil = mesh("RingSketch", state.fxHard, base * CFrame.new(0, 0.25, 0), V3(0.5, 0.35, 0.5), P.crimson, 0.2)
	Tw.play(sigil, {Size = V3(14, 0.35, 14)}, 0.6, Back, Out)
	spin(state, sigil, V3(0, 1.4, 0))
	local sigil2 = mesh("RingSketch", state.fxHard, base * CFrame.new(0, 0.3, 0), V3(0.5, 0.25, 0.5), P.pink, 0.6)
	Tw.play(sigil2, {Size = V3(18, 0.25, 18)}, 0.75, Back, Out, 0.1)
	spin(state, sigil2, V3(0, -2.2, 0))
	local ripple = mesh("RingRipple", state.fxHard, base * CFrame.new(0, 0.15, 0), V3(0.5, 0.3, 0.5), P.white, 0.55)
	Tw.play(ripple, {Size = V3(12, 0.3, 12)}, 0.65, Back, Out, 0.15)
	spin(state, ripple, V3(0, 0.7, 0))
	local ripple2 = mesh("RingRipple", state.fxHard, base * CFrame.new(0, 0.18, 0), V3(0.5, 0.3, 0.5), P.cyan, 0.6)
	Tw.play(ripple2, {Size = V3(26, 0.3, 26)}, 0.9, Back, Out, 0.25)
	spin(state, ripple2, V3(0, -0.5, 0))
	state.sigils = {sigil, sigil2, ripple, ripple2}

	local bodyC = base * CFrame.new(0, 3.5, 0)
	local orbits = {}
	for i, spec in ipairs({{P.crimson, V3(R(70), 0, 0), V3(0, 2.6, 0)}, {P.pink, V3(R(-60), R(30), 0), V3(0, -2.1, 0)}, {P.cyan, V3(R(15), R(90), 0), V3(0, 1.7, 0)}}) do
		local o = mesh("RingSketch", state.fxHard, bodyC, V3(0.5, 0.3, 0.5), spec[1], 0.35)
		local tilt = CFrame.fromEulerAnglesXYZ(spec[2].X, spec[2].Y, spec[2].Z)
		spin(state, o, spec[3], function()
			return bodyC * tilt
		end)
		Tw.play(o, {Size = V3(7 + i * 1.6, 0.35, 7 + i * 1.6)}, 0.6, Back, Out, 0.1 * i)
		table.insert(orbits, o)
	end
	state.orbits = orbits

	local light = Instance.new("PointLight")
	light.Color = P.crimson
	light.Brightness = 0
	light.Range = 46
	light.Shadows = true
	light.Parent = state.anchor
	Tw.play(light, {Brightness = 5}, 1.2)
	state.light = light

	local bladeAtt = Instance.new("Attachment")
	bladeAtt.CFrame = CFrame.new(0, 0, 0.8)
	bladeAtt.Parent = blade
	state.bladeAtt = bladeAtt
	Emitters.make(bladeAtt, {
		texture = "star4",
		Speed = NumberRange.new(0),
		Lifetime = NumberRange.new(0.35, 0.6),
		Size = Tw.seq({{0, 0}, {0.3, 1.8}, {1, 0}}),
		Color = Tw.cseq({{0, P.white}, {1, P.crimson}}),
		Rotation = NumberRange.new(0, 90),
		RotSpeed = NumberRange.new(-120, 120),
		Enabled = true,
		Rate = 40,
	})
	Emitters.make(bladeAtt, {
		texture = "core",
		Speed = NumberRange.new(0),
		Lifetime = NumberRange.new(0.2),
		Size = Tw.seq({{0, 3.5}, {1, 5}}),
		Color = ColorSequence.new(P.crimson),
		Transparency = Tw.seq({{0, 0.55}, {1, 1}}),
		Enabled = true,
		Rate = 24,
	})
	Emitters.make(bladeAtt, {
		texture = "windspin",
		Speed = NumberRange.new(0),
		Lifetime = NumberRange.new(0.45, 0.6),
		Size = Tw.seq({{0, 5}, {1, 11}}),
		Color = Tw.cseq({{0, P.pink}, {1, P.crimson}}),
		Transparency = Tw.seq({{0, 1}, {0.15, 0.3}, {1, 1}}),
		Rotation = NumberRange.new(0, 360),
		RotSpeed = NumberRange.new(-300, 300),
		ZOffset = 0.5,
		Enabled = true,
		Rate = 14,
	})
	Emitters.sparkles(bladeAtt, {rate = 4, size = 0.6, speed = NumberRange.new(2, 6), enabled = true, life = NumberRange.new(0.5, 1)})

	local pull = Emitters.carrier(state.fxSoft, base * CFrame.new(0, 4, 0), V3(26, 26, 26))
	Emitters.make(pull, {
		texture = "spark",
		Shape = Enum.ParticleEmitterShape.Sphere,
		ShapeInOut = Enum.ParticleEmitterShapeInOut.Inward,
		ShapeStyle = Enum.ParticleEmitterShapeStyle.Surface,
		Speed = NumberRange.new(24, 36),
		Lifetime = NumberRange.new(0.45, 0.65),
		Size = Tw.seq({{0, 0}, {0.3, 2.4}, {1, 0.2}}),
		Color = Tw.cseq({{0, P.crimson}, {0.6, P.pink}, {1, P.white}}),
		Orientation = Enum.ParticleOrientation.VelocityParallel,
		Enabled = true,
		Rate = 60,
	})
	Emitters.make(pull, {
		texture = "shards",
		Shape = Enum.ParticleEmitterShape.Sphere,
		ShapeInOut = Enum.ParticleEmitterShapeInOut.Inward,
		ShapeStyle = Enum.ParticleEmitterShapeStyle.Surface,
		Speed = NumberRange.new(28, 42),
		Lifetime = NumberRange.new(0.4, 0.6),
		Size = Tw.seq({{0, 0}, {0.4, 5}, {1, 0}}),
		Color = Tw.cseq({{0, P.white}, {1, P.cyan}}),
		Orientation = Enum.ParticleOrientation.VelocityParallel,
		Transparency = Tw.seq({{0, 0.3}, {1, 0}}),
		Enabled = true,
		Rate = 24,
	})
	Emitters.make(pull, {
		texture = "specs",
		Shape = Enum.ParticleEmitterShape.Sphere,
		ShapeInOut = Enum.ParticleEmitterShapeInOut.Inward,
		ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume,
		Speed = NumberRange.new(10, 24),
		Lifetime = NumberRange.new(0.6, 1),
		Size = Tw.seq({{0, 0.6}, {1, 0}}),
		Color = ColorSequence.new(P.blue),
		Enabled = true,
		Rate = 40,
	})
	state.pull = pull

	local wisps = Emitters.carrier(state.fxSoft, base * CFrame.new(0, 0.5, 0), V3(22, 0.2, 22))
	Emitters.make(wisps, {
		texture = "shards",
		Shape = Enum.ParticleEmitterShape.Disc,
		EmissionDirection = Enum.NormalId.Top,
		SpreadAngle = Vector2.new(8, 8),
		Speed = NumberRange.new(6, 14),
		Lifetime = NumberRange.new(1, 1.6),
		Size = Tw.seq({{0, 0}, {0.3, 4}, {1, 0}}),
		Color = Tw.cseq({{0, P.crimson}, {1, P.pink}}),
		Orientation = Enum.ParticleOrientation.VelocityParallel,
		Transparency = Tw.seq({{0, 0.4}, {1, 0.1}}),
		Enabled = true,
		Rate = 20,
	})
	state.wisps = wisps

	local dust = Emitters.carrier(state.fxSoft, base * CFrame.new(0, 0.6, 0), V3(30, 0.2, 30))
	Emitters.make(dust, {
		texture = "darksmoke",
		Shape = Enum.ParticleEmitterShape.Disc,
		ShapeInOut = Enum.ParticleEmitterShapeInOut.Inward,
		ShapeStyle = Enum.ParticleEmitterShapeStyle.Surface,
		Speed = NumberRange.new(7, 12),
		Lifetime = NumberRange.new(0.9, 1.3),
		Size = Tw.seq({{0, 3}, {1, 7}}),
		Color = ColorSequence.new(Color3.fromRGB(110, 80, 100)),
		Transparency = Tw.seq({{0, 1}, {0.2, 0.55}, {1, 1}}),
		LightEmission = 0.1,
		LightInfluence = 0.8,
		Rotation = NumberRange.new(0, 360),
		RotSpeed = NumberRange.new(-40, 40),
		Enabled = true,
		Rate = 22,
	})
	state.dust = dust

	local auraAtt = Instance.new("Attachment")
	auraAtt.Parent = state.hrp
	Emitters.make(auraAtt, {
		texture = "core",
		Shape = Enum.ParticleEmitterShape.Box,
		Speed = NumberRange.new(2, 4),
		EmissionDirection = Enum.NormalId.Top,
		SpreadAngle = Vector2.new(30, 30),
		Lifetime = NumberRange.new(0.5, 0.8),
		Size = Tw.seq({{0, 2}, {0.4, 4.5}, {1, 1}}),
		Color = Tw.cseq({{0, P.crimson}, {1, P.pink}}),
		Transparency = Tw.seq({{0, 1}, {0.2, 0.7}, {1, 1}}),
		ZOffset = -1,
		Enabled = true,
		Rate = 22,
	})
	Emitters.make(auraAtt, {
		texture = "windA",
		Speed = NumberRange.new(3, 6),
		EmissionDirection = Enum.NormalId.Top,
		SpreadAngle = Vector2.new(20, 20),
		Lifetime = NumberRange.new(0.6, 0.9),
		Size = Tw.seq({{0, 2}, {1, 6}}),
		Color = Tw.cseq({{0, P.pink}, {1, P.crimson}}),
		Transparency = Tw.seq({{0, 1}, {0.2, 0.6}, {1, 1}}),
		Rotation = NumberRange.new(0, 360),
		RotSpeed = NumberRange.new(-80, 80),
		Enabled = true,
		Rate = 10,
	})
	state.auraAtt = auraAtt

	local field = Emitters.carrier(state.fxSoft, base * CFrame.new(0, 9, 0), V3(44, 22, 44))
	state.field = Emitters.sparkles(field, {rate = 13, size = 1, speed = NumberRange.new(1, 4), enabled = true, life = NumberRange.new(1, 1.9)})
	state.fieldCarrier = field
	local wide = Emitters.carrier(state.fxSoft, base * CFrame.new(0, 24, 0), V3(190, 60, 190))
	state.wide = Emitters.sparkles(wide, {rate = 8, size = 1.6, speed = NumberRange.new(0.5, 2), enabled = true, life = NumberRange.new(1.4, 2.6)})
	state.wideCarrier = wide

	arcs(state, function()
		return blade.CFrame.Position
	end, 3.5, 2, 1, T.slash - T.charge, {P.white, P.crimson, P.cyan}, 0.25)
	local snap = mesh("RingRipple", state.fxHard, base * CFrame.new(0, 3.5, 0) * CFrame.Angles(R(90), 0, 0), V3(30, 0.4, 30), P.white, 0.4)
	Tw.play(snap, {Size = V3(3, 0.5, 3)}, 0.3, Quart, In)
	fade(snap, 0.15, 0.2)
	glowBurst(state, blade.CFrame * CFrame.new(0, 0, 0.8), "burst", 2, 9, 0.25, P.white, 1, 1)

	local charge = sfx("Charge", state.anchor, 0.55, 0.85)
	if charge then
		Tw.play(charge, {Volume = 1.0, PlaybackSpeed = 1.05 / Tw.S()}, T.peak - T.charge, Quad, In)
	end
	for _, e in ipairs(state.pull:GetChildren()) do
		if e:IsA("ParticleEmitter") then
			Tw.play(e, {Rate = e.Rate * 2.2}, T.slash - T.charge, Quad, In)
		end
	end
	if state.isLocal then
		CameraRig.cutTo({angle = 118, dist = 7.8, height = 6.4, lookY = 5.8, fov = 44, roll = -4})
		CameraRig.shot({dist = 7, fov = 42, roll = -5}, T.slash - T.charge, Sine, Out)
		CameraRig.kick(0.2)
		dof(state, 7, 4, 0.6, 0.3)
		ScreenFx.flare(state.blade.Position, P.pink, 0.35, 0.5)
		task.spawn(function()
			for i = 1, 6 do
				CameraRig.kick(0.06 + i * 0.03)
				Tw.wait(0.2)
			end
		end)
	end
	Tw.play(state.cc, {Saturation = -0.15, Brightness = -0.02, Contrast = 0.1, TintColor = Color3.fromRGB(255, 230, 235)}, 1.2)
	if state.bloom then
		Tw.play(state.bloom, {Intensity = 0.7, Size = 34, Threshold = 0.92}, 1.2)
	end
end

-- the hold at the top of the raise gets one pulse so the pause reads as pressure not a stall
local function chargePeak(state)
	state.fxHard:SetAttribute("Phase", "peak")
	local base, blade = state.base, state.blade
	stab(sfx("Impact", state.anchor, 0.55, 0.45), 0.2, 0.35)
	sfx("RingWhoosh", state.anchor, 0.35, 1.4)
	glowBurst(state, blade.CFrame * CFrame.new(0, 0, 0.8), "burst", 4, 16, 0.3, P.white, 1, 1)
	popStar(state, blade.CFrame * CFrame.new(0, 0, 1.2), 7, P.white, 0.4)
	local pulse = mesh("RingSketch", state.fxHard, base * CFrame.new(0, 0.4, 0), V3(6, 0.4, 6), P.white, 0.2)
	Tw.play(pulse, {Size = V3(40, 0.4, 40)}, 0.45, Quart, Out)
	fade(pulse, 0.3, 0.12)
	local pulse2 = mesh("RingRipple", state.fxHard, base * CFrame.new(0, 3.5, 0) * CFrame.Angles(R(90), 0, 0), V3(4, 0.4, 4), P.cyan, 0.3)
	Tw.play(pulse2, {Size = V3(36, 0.4, 36)}, 0.45, Quart, Out)
	fade(pulse2, 0.3, 0.12)
	Emitters.sparkleBurst(state.fxSoft, blade.CFrame * CFrame.new(0, 0, 0.8), V3(1, 1, 1), 10, {size = 0.9, speed = NumberRange.new(16, 34), drag = 3, life = NumberRange.new(0.6, 1.1)})
	sparkBurst(state, base * CFrame.new(0, 4, 0), 30, 40, P.pink)
	for _, o in ipairs(state.orbits) do
		Tw.play(o, {Size = V3(o.Size.X * 1.35, 0.5, o.Size.Z * 1.35)}, 0.12, Quad, Out)
		Tw.play(o, {Size = V3(o.Size.X, 0.35, o.Size.Z)}, 0.3, Quad, Out, 0.12)
	end
	Tw.play(state.light, {Brightness = 9}, 0.08)
	Tw.play(state.light, {Brightness = 5}, 0.3, Quad, Out, 0.08)
	local charge2 = sfx("Charge", state.anchor, 0.7, 1.1)
	if charge2 then
		Tw.play(charge2, {Volume = 1.2, PlaybackSpeed = 1.3 / Tw.S()}, T.slash - T.peak, Quad, In)
	end
	if state.isLocal then
		CameraRig.kick(0.3)
		ScreenFx.flare(state.blade.Position, P.white, 0.5, 0.35)
	end
	-- a second pulse halfway to the slash so the charge keeps building
	task.delay((T.slash - T.peak) * 0.5 * Tw.S(), function()
		if not state.alive then
			return
		end
		local pulse3 = mesh("RingSketch", state.fxHard, base * CFrame.new(0, 0.4, 0), V3(6, 0.4, 6), P.cyan, 0.2)
		spin(state, pulse3, V3(0, -1.5, 0))
		Tw.play(pulse3, {Size = V3(48, 0.4, 48)}, 0.5, Quart, Out)
		fade(pulse3, 0.35, 0.15)
		glowBurst(state, blade.CFrame * CFrame.new(0, 0, 0.8), "burst", 6, 22, 0.35, P.cyan, 1, 1)
		Emitters.sparkleBurst(state.fxSoft, blade.CFrame * CFrame.new(0, 0, 0.8), V3(1, 1, 1), 14, {size = 1.1, speed = NumberRange.new(20, 40), drag = 3, life = NumberRange.new(0.7, 1.2)})
		Tw.play(state.light, {Brightness = 11}, 0.08)
		Tw.play(state.light, {Brightness = 6}, 0.3, Quad, Out, 0.08)
		sfx("RingWhoosh", state.anchor, 0.45, 1.6)
		if state.isLocal then
			CameraRig.kick(0.4)
			ScreenFx.flare(blade.Position, P.cyan, 0.6, 0.4)
		end
	end)
end

-- the slash itself is a crescent through the blade path plus a trail so the cut reads before the dome lands
local function slashArc(state)
	state.fxHard:SetAttribute("Phase", "slash")
	local hrp = state.hrp
	local blade = state.blade
	local a0 = Instance.new("Attachment")
	a0.CFrame = CFrame.new(0, 0, -1.9)
	a0.Parent = blade
	local a1 = Instance.new("Attachment")
	a1.CFrame = CFrame.new(0, 0, 2.1)
	a1.Parent = blade
	local trail = Instance.new("Trail")
	trail.Attachment0 = a0
	trail.Attachment1 = a1
	trail.Lifetime = 0.3
	trail.MinLength = 0.05
	trail.LightEmission = 1
	trail.LightInfluence = 0
	trail.WidthScale = Tw.seq({{0, 1}, {1, 0.2}})
	trail.Color = Tw.cseq({{0, P.white}, {0.4, P.crimson}, {1, P.pink}})
	trail.Transparency = Tw.seq({{0, 0}, {1, 1}})
	trail.Texture = Emitters.TEX.lightray
	trail.TextureMode = Enum.TextureMode.Stretch
	trail.Parent = blade
	Debris:AddItem(trail, 1.2 * Tw.S())
	Debris:AddItem(a0, 1.2 * Tw.S())
	Debris:AddItem(a1, 1.2 * Tw.S())
	local cf = hrp.CFrame * CFrame.new(-0.8, 1.2, -3) * CFrame.Angles(R(90), 0, 0) * CFrame.Angles(0, R(-52), 0)
	for i, spec in ipairs({{P.white, V3(18, 0.3, 7), 0}, {P.crimson, V3(26, 0.3, 10), 0.35}, {P.pink, V3(34, 0.3, 13), 0.6}, {P.cyan, V3(42, 0.3, 16), 0.75}}) do
		local s = mesh("Slash", state.fxHard, cf * CFrame.new(0, 0, 0.3 * i), V3(2, 0.3, 1), spec[1], spec[3])
		Tw.play(s, {Size = spec[2]}, 0.14 + i * 0.03, Quart, Out)
		fade(s, 0.22, 0.12 + i * 0.03)
	end
	Emitters.sparkleBurst(state.fxSoft, cf, V3(10, 1, 4), 6, {size = 0.8, speed = NumberRange.new(10, 30), drag = 3, life = NumberRange.new(0.5, 0.9)})
	for _, o in ipairs(state.orbits) do
		Tw.play(o, {Size = V3(o.Size.X * 4, 0.2, o.Size.Z * 4)}, 0.3, Quart, Out)
		fade(o, 0.3)
	end
	sfx("Swing", state.anchor, 1.8, 1.05)
end

local function stopCharge(state)
	for _, c in ipairs({state.pull, state.dust, state.wisps, state.pebbles}) do
		stopEmitters(c, 2)
	end
	if state.auraAtt then
		for _, e in ipairs(state.auraAtt:GetChildren()) do
			if e:IsA("ParticleEmitter") then
				e.Enabled = false
			end
		end
		Debris:AddItem(state.auraAtt, 1.5 * Tw.S())
	end
	for _, e in ipairs(state.bladeAtt:GetChildren()) do
		if e:IsA("ParticleEmitter") then
			e.Enabled = false
		end
	end
	Debris:AddItem(state.bladeAtt, 2 * Tw.S())
	for _, s in ipairs(state.sigils) do
		Tw.play(s, {Size = V3(s.Size.X * 2.4, s.Size.Y, s.Size.Z * 2.4)}, 0.35, Quart, Out)
		fade(s, 0.35)
	end
end

-- phase c is the dome at the blade tip then the crown of spikes that pops up around the impact
local function phaseDome(state)
	state.fxHard:SetAttribute("Phase", "dome")
	local pbase, center = state.pbase, state.impact
	local core = ball(state.fxSoft, center, 2, P.white, 0.35)
	Tw.play(core, {Size = V3(12, 12, 12)}, 0.2, Quart, Out)
	fade(core, 0.3, 0.06)
	glowBurst(state, center, "glow", 6, 40, 0.45, P.pink, 2, 1)
	Tw.play(state.light, {Brightness = 12, Range = 110}, 0.15)
	local shell = mesh("SphereWind", state.fxHard, center, V3(2, 2, 2), P.crimson, 0.05)
	spin(state, shell, V3(0.8, 1.9, 0.5))
	Tw.play(shell, {Size = V3(32, 32, 32)}, 0.38, Back, Out)
	fade(shell, 0.55, 0.3)
	local outer = mesh("SphereFancy", state.fxHard, center * CFrame.Angles(1, 0.5, 0), V3(4, 4, 4), P.pink, 0.35)
	spin(state, outer, V3(-0.5, 1.2, 0.3))
	Tw.play(outer, {Size = V3(46, 46, 46)}, 0.5, Quart, Out)
	fade(outer, 0.5, 0.35)
	local outer2 = mesh("SphereStreak", state.fxHard, center * CFrame.Angles(0.3, 2, 1), V3(4, 4, 4), P.cyan, 0.5)
	spin(state, outer2, V3(0.9, -1.4, 0.2))
	Tw.play(outer2, {Size = V3(58, 58, 58)}, 0.6, Quart, Out)
	fade(outer2, 0.5, 0.4)
	local ring = mesh("RingSketch", state.fxHard, pbase * CFrame.new(0, 0.5, 0), V3(4, 0.5, 4), P.crimson, 0.15)
	spin(state, ring, V3(0, 1.2, 0))
	Tw.play(ring, {Size = V3(70, 0.5, 70)}, 0.55, Quart, Out)
	fade(ring, 0.4, 0.2)
	local ring2 = mesh("RingRipple", state.fxHard, pbase * CFrame.new(0, 1.5, 0), V3(4, 0.4, 4), P.cyan, 0.4)
	Tw.play(ring2, {Size = V3(56, 0.4, 56)}, 0.45, Quart, Out)
	fade(ring2, 0.35, 0.15)
	flatShock(state, pbase, 16, 90, 0.5, P.white, 1, 32)
	flatShock(state, pbase, 8, 55, 0.45, P.crimson, 1, 36)
	flatShock(state, pbase, 24, 130, 0.65, P.cyan, 1, 28)
	floorGlow(state, pbase, 60, P.crimson, 1.4)
	glowBurst(state, center, "impact", 8, 34, 0.28, P.white, 2, 2)
	Emitters.burst(state.fxSoft, center, nil, {
		texture = "lightrays",
		Speed = NumberRange.new(0),
		Lifetime = NumberRange.new(0.35),
		Size = Tw.seq({{0, 20}, {1, 100}}),
		Transparency = Tw.seq({{0, 0.1}, {1, 1}}),
		Color = ColorSequence.new(P.crimson),
		RotSpeed = NumberRange.new(60),
		ZOffset = -1,
	}, 2, 1)
	rockBurst(state, pbase, 6, 80, 55, 2.8)
	smokeRing(state, pbase, 8, 40, 6, 20, 40, 1.1, P.pink)
	smokeRing(state, pbase, 14, 26, 8, 22, 20, 1.5, Color3.fromRGB(120, 90, 110), true)
	sparkBurst(state, center, 50, 90, P.crimson)
	shardBurst(state, center, 36, 110, P.cyan)
	Emitters.sparkleBurst(state.fxSoft, center, V3(4, 4, 4), 16, {size = 1.1, speed = NumberRange.new(20, 60), drag = 2.5, life = NumberRange.new(0.8, 1.5)})
	flatCrack(state, pbase, "crackA", 52, 5.5, 6.5)
	platesUp(state, 1.4, 0.4)
	arcs(state, function()
		return center.Position
	end, 16, 6, 2, 0.45, {P.white, P.crimson, P.cyan}, 0.35)
	task.delay((T.follow - T.impact) * Tw.S(), function()
		sfx("Dome", state.anchor, 1)
		stab(sfx("Impact", state.anchor, 0.75, 0.7, true), 0.3, 0.4)
	end)
	if state.isLocal then
		CameraRig.shot({dist = 32, height = 10, angle = 118, lookY = 7, fov = 70, roll = -2}, 0.6, Quart, Out, T.follow - T.impact + 0.05)
		CameraRig.shot({angle = 132}, T.pillar - T.follow, Sine, InOut, T.follow - T.impact + 0.4)
	end
	Tw.wait(T.crown - T.impact)

	state.fxHard:SetAttribute("Phase", "crown")
	local crowns = {}
	local function crown(name, color, size, tr, w)
		local c = mesh(name, state.fxHard, pbase * CFrame.new(0, 0.5, 0), V3(1, 0.5, 1), color, tr)
		local y = Instance.new("NumberValue")
		y.Value = 0.3
		local ang = math.random() * 6.28
		spin(state, c, V3(0, w, 0), function()
			return pbase * CFrame.new(0, y.Value, 0) * CFrame.Angles(0, ang, 0)
		end)
		Tw.play(c, {Size = size}, 0.24, Back, Out)
		Tw.play(y, {Value = size.Y / 2}, 0.24, Back, Out)
		table.insert(crowns, {part = c, y = y})
		return c
	end
	crown("Crown", P.pink, V3(36, 32, 36), 0.35, 0.6)
	crown("CrownSpikes", P.white, V3(28, 27, 28), 0.65, -0.9)
	crown("CrownTall", P.crimson, V3(44, 24, 44), 0.5, 0.35)
	crown("CrownSpikes", P.cyan, V3(22, 34, 22), 0.5, 1.4)
	crown("SpikeCluster", P.pink, V3(18, 40, 18), 0.6, -0.4)
	glowBurst(state, pbase * CFrame.new(0, 14, 0), "glow", 20, 70, 0.5, P.pink, 2, -1)
	impactFrames(state, {{"blue", 0.05}, {"black", 0.04}, {"blue", 0.05}})
	sfx("Crown", state.anchor, 1.3, 1.05, true)
	sfx("RingWhoosh", state.anchor, 0.45, 1.3)
	for i = 1, 8 do
		popStar(state, polar(pbase, math.random() * 6.28, 12 + math.random() * 14, 4 + math.random() * 18), 3 + math.random() * 5, SP[(i % #SP) + 1], 0.55)
	end
	Emitters.sparkleBurst(state.fxSoft, center, V3(3, 3, 3), 22, {size = 1.3, speed = NumberRange.new(30, 70), drag = 3, life = NumberRange.new(0.7, 1.4)})
	Emitters.burst(state.fxSoft, pbase * CFrame.new(0, 10, 0), V3(30, 20, 30), {
		texture = "windspin",
		Shape = Enum.ParticleEmitterShape.Sphere,
		Speed = NumberRange.new(20, 40),
		Drag = 2,
		Lifetime = NumberRange.new(0.6, 0.9),
		Size = Tw.seq({{0, 6}, {1, 18}}),
		Color = Tw.cseq({{0, P.pink}, {1, P.cyan}}),
		Transparency = Tw.seq({{0, 1}, {0.15, 0.3}, {1, 1}}),
		Rotation = NumberRange.new(0, 360),
		RotSpeed = NumberRange.new(-200, 200),
	}, 14, 1.5)
	if state.isLocal then
		CameraRig.kick(0.75)
		SpeedLines.pulse(0.5, 0.4)
		CameraRig.shot({dist = 44, height = 17, lookY = 12, roll = 3}, 0.6, Quart, Out)
		ScreenFx.flare(pbase.Position + V3(0, 12, 0), P.pink, 0.5, 0.4)
		dof(state, 40, 40, 0.25, 0.6)
	end
	Tw.wait(T.crownEnd - T.crown)
	for _, c in ipairs(crowns) do
		Tw.play(c.part, {Size = V3(c.part.Size.X * 0.7, 0.2, c.part.Size.Z * 0.7)}, 0.22, Back, In)
		Tw.play(c.y, {Value = 0.2}, 0.22, Back, In)
		Debris:AddItem(c.part, 0.24 * Tw.S())
	end
	Tw.wait(T.pillar - T.crownEnd)
end

-- phase d raises the pillar and keeps rings sparks rocks and bolts climbing it until the collapse
local function phasePillar(state)
	state.fxHard:SetAttribute("Phase", "pillar")
	local pbase, H = state.pbase, Config.PillarHeight
	local pillar = {}
	local function up(part, d, dur, delayTime)
		cylTo(part, pbase, H, d, dur, Quart, Out, delayTime)
		table.insert(pillar, part)
	end
	local coreC = cyl(state.fxHard, pbase, 0.5, 3, P.white, 0.1)
	up(coreC, 3.5, 0.18)
	local midC = cyl(state.fxHard, pbase, 0.5, 5, P.crimson, 0.55)
	up(midC, 9, 0.2, 0.02)
	state.pillarCore = coreC
	state.pillarParts = pillar

	local function sleeve(name, color, d, tr, w, delayTime)
		local s = mesh(name, state.fxHard, pbase * CFrame.new(0, 0.3, 0), V3(0.5, 0.5, 0.5), color, tr)
		local y = Instance.new("NumberValue")
		y.Value = 0.3
		spin(state, s, V3(0, w, 0), function()
			return pbase * CFrame.new(0, y.Value, 0)
		end)
		Tw.play(s, {Size = V3(d, H, d)}, 0.22, Quart, Out, delayTime)
		Tw.play(y, {Value = H / 2}, 0.22, Quart, Out, delayTime)
		table.insert(pillar, s)
		return s
	end
	sleeve("PillarSpiral", P.crimson, 26, 0.45, 3.2, 0.03)
	sleeve("PillarSpiral2", P.white, 34, 0.6, -2.4, 0.05)
	sleeve("PillarHoles", P.cyan, 42, 0.72, 1.1, 0.07)
	sleeve("Ribbon", P.pink, 30, 0.55, -1.6, 0.06)

	local a0 = Instance.new("Attachment")
	a0.CFrame = pbase * CFrame.new(0, 1, 0)
	a0.Parent = workspace.Terrain
	local a1 = Instance.new("Attachment")
	a1.CFrame = pbase * CFrame.new(0, H, 0)
	a1.Parent = workspace.Terrain
	state.beamAtt = {a0, a1}
	local beams = {}
	local function beam(tex, width, speed, len, color, tr, z)
		local b = Instance.new("Beam")
		b.Attachment0 = a0
		b.Attachment1 = a1
		b.Texture = Emitters.TEX[tex]
		b.TextureLength = len
		b.TextureSpeed = speed
		b.TextureMode = Enum.TextureMode.Wrap
		b.Width0 = 0
		b.Width1 = 0
		b.LightEmission = 1
		b.LightInfluence = 0
		b.FaceCamera = true
		b.Segments = 1
		b.ZOffset = z or 0
		b.Color = color
		b.Transparency = tr
		b.Parent = a0
		Tw.play(b, {Width0 = width, Width1 = width * 1.25}, 0.25, Quart, Out)
		table.insert(beams, b)
		return b
	end
	beam("lightray", 22, -5, 30, Tw.cseq({{0, P.white}, {0.5, P.crimson}, {1, P.pink}}), Tw.seq({{0, 0.35}, {0.85, 0.5}, {1, 1}}), 1)
	beam("windspin", 34, -3, 40, Tw.cseq({{0, P.crimson}, {1, P.pink}}), Tw.seq({{0, 0.5}, {0.85, 0.6}, {1, 1}}), 0.5)
	beam("windA", 28, -2, 36, Tw.cseq({{0, P.pink}, {1, P.white}}), Tw.seq({{0, 0.55}, {0.85, 0.65}, {1, 1}}), 0.8)
	beam("core", 46, -1.5, 60, Tw.cseq({{0, P.crimson}, {1, P.cyan}}), Tw.seq({{0, 0.5}, {0.9, 0.65}, {1, 1}}), -0.5)
	-- soft glow rising inside the column so it reads as flowing energy and not a tube
	local column = Emitters.carrier(state.fxSoft, pbase * CFrame.new(0, H * 0.45, 0), V3(10, H * 0.85, 10))
	Emitters.make(column, {
		texture = "core",
		Shape = Enum.ParticleEmitterShape.Box,
		EmissionDirection = Enum.NormalId.Top,
		SpreadAngle = Vector2.new(8, 8),
		Speed = NumberRange.new(30, 55),
		Lifetime = NumberRange.new(1.4, 2.2),
		Size = Tw.seq({{0, 10}, {0.3, 24}, {1, 16}}),
		Color = Tw.cseq({{0, P.white}, {0.4, P.crimson}, {1, P.pink}}),
		Transparency = Tw.seq({{0, 1}, {0.15, 0.5}, {0.8, 0.7}, {1, 1}}),
		Rotation = NumberRange.new(0, 360),
		RotSpeed = NumberRange.new(-30, 30),
		ZOffset = 0.5,
		Enabled = true,
		Rate = 55,
	})
	Emitters.make(column, {
		texture = "windA",
		Shape = Enum.ParticleEmitterShape.Box,
		EmissionDirection = Enum.NormalId.Top,
		SpreadAngle = Vector2.new(12, 12),
		Speed = NumberRange.new(40, 70),
		Lifetime = NumberRange.new(1, 1.6),
		Size = Tw.seq({{0, 14}, {1, 30}}),
		Color = Tw.cseq({{0, P.pink}, {1, P.cyan}}),
		Transparency = Tw.seq({{0, 1}, {0.2, 0.55}, {1, 1}}),
		Rotation = NumberRange.new(0, 360),
		RotSpeed = NumberRange.new(-60, 60),
		ZOffset = 1,
		Enabled = true,
		Rate = 22,
	})
	state.column = column
	state.beams = beams

	local sparks = Emitters.carrier(state.fxSoft, pbase * CFrame.new(0, 2, 0), V3(14, 0.2, 14))
	Emitters.make(sparks, {
		texture = "spark",
		Shape = Enum.ParticleEmitterShape.Disc,
		EmissionDirection = Enum.NormalId.Top,
		SpreadAngle = Vector2.new(6, 6),
		Speed = NumberRange.new(90, 170),
		Lifetime = NumberRange.new(1, 1.5),
		Size = Tw.seq({{0, 1}, {0.2, 4}, {1, 0}}),
		Color = Tw.cseq({{0, P.white}, {0.5, P.crimson}, {1, P.pink}}),
		Orientation = Enum.ParticleOrientation.VelocityParallel,
		Enabled = true,
		Rate = 70,
	})
	Emitters.make(sparks, {
		texture = "star4",
		Shape = Enum.ParticleEmitterShape.Disc,
		EmissionDirection = Enum.NormalId.Top,
		SpreadAngle = Vector2.new(16, 16),
		Speed = NumberRange.new(50, 120),
		Lifetime = NumberRange.new(1.2, 1.9),
		Size = Tw.seq({{0, 0}, {0.2, 3}, {1, 0}}),
		Color = Tw.cseq({{0, P.white}, {1, P.cyan}}),
		RotSpeed = NumberRange.new(-200, 200),
		Enabled = true,
		Rate = 30,
	})
	Emitters.make(sparks, {
		texture = "specs",
		Shape = Enum.ParticleEmitterShape.Disc,
		EmissionDirection = Enum.NormalId.Top,
		SpreadAngle = Vector2.new(24, 24),
		Speed = NumberRange.new(40, 100),
		Lifetime = NumberRange.new(1.5, 2.4),
		Size = Tw.seq({{0, 0.8}, {1, 0}}),
		Color = Tw.cseq({{0, P.cyan}, {1, P.pink}}),
		Enabled = true,
		Rate = 60,
	})
	Emitters.make(sparks, {
		texture = "rocks",
		flip = {Enum.ParticleFlipbookLayout.Grid2x2, Enum.ParticleFlipbookMode.Random, 1},
		Shape = Enum.ParticleEmitterShape.Disc,
		ShapeStyle = Enum.ParticleEmitterShapeStyle.Surface,
		EmissionDirection = Enum.NormalId.Top,
		SpreadAngle = Vector2.new(30, 30),
		Speed = NumberRange.new(12, 28),
		Acceleration = V3(0, 9, 0),
		Lifetime = NumberRange.new(2.2, 3),
		Size = Tw.seq({{0, 0}, {0.1, 2.4}, {0.9, 2.4}, {1, 0}}),
		Color = ColorSequence.new(P.rock),
		LightEmission = 0.25,
		LightInfluence = 0.5,
		Rotation = NumberRange.new(0, 360),
		RotSpeed = NumberRange.new(-90, 90),
		Enabled = true,
		Rate = 8,
	})
	state.sparks = sparks
	Tw.play(sparks, {Size = V3(34, 0.2, 34)}, 0.5)

	local crescents = Emitters.carrier(state.fxSoft, pbase * CFrame.new(0, 34, 0), V3(4, 44, 4))
	Emitters.make(crescents, {
		texture = "windspin",
		Shape = Enum.ParticleEmitterShape.Box,
		Speed = NumberRange.new(20, 40),
		EmissionDirection = Enum.NormalId.Top,
		Lifetime = NumberRange.new(0.7, 1),
		Size = Tw.seq({{0, 26}, {1, 52}}),
		Color = Tw.cseq({{0, P.pink}, {1, P.crimson}}),
		Transparency = Tw.seq({{0, 1}, {0.15, 0.35}, {1, 1}}),
		Rotation = NumberRange.new(0, 360),
		RotSpeed = NumberRange.new(-120, 120),
		ZOffset = 3,
		Enabled = true,
		Rate = 5,
	})
	state.crescents = crescents

	local wind = Emitters.carrier(state.fxSoft, pbase * CFrame.new(0, 1.2, 0), V3(10, 0.2, 10))
	Emitters.make(wind, {
		texture = "smoke",
		flip = {Enum.ParticleFlipbookLayout.Grid4x4, Enum.ParticleFlipbookMode.OneShot, 12},
		Shape = Enum.ParticleEmitterShape.Disc,
		ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward,
		ShapeStyle = Enum.ParticleEmitterShapeStyle.Surface,
		Speed = NumberRange.new(26, 40),
		Drag = 3,
		Lifetime = NumberRange.new(0.9, 1.3),
		Size = Tw.seq({{0, 6}, {0.4, 14}, {1, 18}}),
		Color = Tw.cseq({{0, P.pink}, {0.5, Color3.fromRGB(170, 140, 170)}, {1, Color3.fromRGB(70, 55, 70)}}),
		Transparency = Tw.seq({{0, 0.3}, {0.6, 0.5}, {1, 1}}),
		LightEmission = 0.3,
		Rotation = NumberRange.new(0, 360),
		RotSpeed = NumberRange.new(-50, 50),
		Enabled = true,
		Rate = 16,
	})
	state.wind = wind

	local rain = Emitters.carrier(state.fxSoft, pbase * CFrame.new(0, 120, 0), V3(120, 2, 120))
	Emitters.make(rain, {
		texture = "spark",
		Shape = Enum.ParticleEmitterShape.Box,
		EmissionDirection = Enum.NormalId.Bottom,
		SpreadAngle = Vector2.new(10, 10),
		Speed = NumberRange.new(30, 60),
		Acceleration = V3(0, -20, 0),
		Lifetime = NumberRange.new(1.6, 2.4),
		Size = Tw.seq({{0, 0}, {0.2, 3.5}, {1, 0}}),
		Color = Tw.cseq({{0, P.white}, {1, P.pink}}),
		Orientation = Enum.ParticleOrientation.VelocityParallel,
		Enabled = true,
		Rate = 30,
	})
	state.rain = rain
	local pfield = Emitters.carrier(state.fxSoft, pbase * CFrame.new(0, 70, 0), V3(90, 150, 90))
	state.pfield = Emitters.sparkles(pfield, {rate = 16, size = 1.6, speed = NumberRange.new(2, 8), enabled = true, life = NumberRange.new(1.2, 2.2), accel = V3(0, 6, 0)})
	state.pfieldCarrier = pfield

	local top = pbase * CFrame.new(0, H, 0)
	local cap = mesh("Burst", state.fxHard, top, V3(1, 1, 1), P.white, 0.1)
	spin(state, cap, V3(0.9, 1.6, 0.7))
	Tw.play(cap, {Size = V3(50, 50, 50)}, 0.35, Back, Out, 0.15)
	table.insert(pillar, cap)
	local skyRing = mesh("RingSketch", state.fxHard, top, V3(2, 0.5, 2), P.cyan, 0.35)
	spin(state, skyRing, V3(0, 0.6, 0))
	Tw.play(skyRing, {Size = V3(140, 1, 140)}, 1.4, Quart, Out, 0.2)
	table.insert(pillar, skyRing)
	glowBurst(state, top, "impactB", 20, 80, 0.5, P.pink, 2, 2)
	smokeRing(state, top * CFrame.new(0, -4, 0), 24, 70, 30, 70, 50, 2.2, Color3.fromRGB(90, 70, 100), true)
	Emitters.sparkleBurst(state.fxSoft, top, V3(6, 6, 6), 30, {size = 2.2, speed = NumberRange.new(30, 80), drag = 2, life = NumberRange.new(1, 2)})

	Tw.play(state.light, {Brightness = 16, Range = 160}, 0.3)
	local light2 = Instance.new("PointLight")
	light2.Color = P.pink
	light2.Brightness = 7
	light2.Range = 140
	light2.Parent = Emitters.carrier(state.fxSoft, pbase * CFrame.new(0, 70, 0))
	state.light2 = light2
	Tw.play(state.cc, {Saturation = -0.12, Brightness = -0.03, Contrast = 0.14, TintColor = Color3.fromRGB(226, 232, 255)}, 0.6)
	if state.bloom then
		Tw.play(state.bloom, {Intensity = 0.8, Size = 38, Threshold = 0.9}, 0.5)
	end
	platesHover(state)
	arcs(state, function()
		return pbase.Position
	end, 20, H * 0.9, 1, T.collapse - T.pillar, {P.white, P.cyan, P.pink}, 0.5)
	state.pillarLoop = sfx("PillarLoop", state.anchor, 0, 0.95)
	if state.pillarLoop then
		-- the loop clip is bass heavy so it gets its own tilt toward the highs
		local tilt = Instance.new("EqualizerSoundEffect")
		tilt.HighGain = 5
		tilt.MidGain = 1
		tilt.LowGain = -2
		tilt.Parent = state.pillarLoop
		Tw.play(state.pillarLoop, {Volume = 1.9}, 0.4)
		Tw.play(state.pillarLoop, {PlaybackSpeed = 1.18 / Tw.S()}, T.collapse - T.pillar, Sine, In)
	end
	state.bed = sfx("Rumble", state.anchor, 0)
	if state.bed then
		Tw.play(state.bed, {Volume = 0.5}, 0.6)
	end
	Tw.play(state.reverb, {WetLevel = -14}, 0.6)
	if state.isLocal then
		SpeedLines.pulse(0.5, 0.5)
		CameraRig.kick(0.7)
		CameraRig.cutTo({angle = 150, dist = 128, height = 50, lookY = 60, fov = 54, roll = -3})
		CameraRig.shot({dist = 138, height = 54, lookY = 64}, 1.8, Sine, Out)
		CameraRig.shot({angle = 232}, T.collapse - T.pillar, Sine, InOut)
		exposure(state, 0.4, 0.6)
		ScreenFx.flare(pbase.Position + V3(0, 30, 0), P.crimson, 0.55, 0.6)
		dof(state, 120, 140, 0.15, 1.6)
	end

	state.pillarAlive = true
	task.spawn(function()
		local i = 0
		while state.pillarAlive do
			i += 1
			local name = i % 4 == 0 and "RingBand" or (i % 2 == 0 and "RingSketch" or "RingRipple")
			local color = i % 2 == 0 and P.crimson or (i % 3 == 0 and P.white or P.cyan)
			local r = mesh(name, state.fxHard, pbase * CFrame.new(0, 2, 0), V3(18, name == "RingBand" and 2.6 or 0.4, 18), color, name == "RingBand" and 0.45 or 0.15)
			local y = Instance.new("NumberValue")
			y.Value = 2
			local tilt = CFrame.Angles(R(math.random(-9, 9)), 0, R(math.random(-9, 9)))
			spin(state, r, V3(0, (i % 2 == 0 and 2 or -2), 0), function()
				return pbase * CFrame.new(0, y.Value, 0) * tilt
			end)
			Tw.play(y, {Value = H * 0.92}, 0.85, Quad, Out)
			Tw.play(r, {Size = V3(40, r.Size.Y * 0.5, 40)}, 0.85, Quad, Out)
			fade(r, 0.45, 0.4)
			if i % 4 == 0 then
				sfx("RingWhoosh", state.anchor, 0.4 + math.random() * 0.2, 0.9 + math.random() * 0.5)
			end
			if state.isLocal then
				CameraRig.kick(0.1)
			end
			if i % 4 == 0 then
				local pulse = mesh("RingRipple", state.fxHard, pbase * CFrame.new(0, 0.5, 0), V3(8, 0.4, 8), i % 8 == 0 and P.cyan or P.crimson, 0.3)
				Tw.play(pulse, {Size = V3(100, 0.4, 100)}, 0.7, Quart, Out)
				fade(pulse, 0.5, 0.2)
				floorGlow(state, pbase, 70, i % 8 == 0 and P.cyan or P.crimson, 0.8)
			end
			if i % 9 == 0 then
				local vr = mesh("RingSketch", state.fxHard, pbase * CFrame.new(0, rnd(20, 100), 0) * CFrame.Angles(R(90), rnd(0, 3), 0), V3(4, 0.6, 4), P.pink, 0.35)
				Tw.play(vr, {Size = V3(90, 1, 90)}, 0.6, Quart, Out)
				fade(vr, 0.4, 0.2)
			end
			Tw.wait(0.1)
		end
	end)

	Tw.wait(T.mid - T.pillar)
	if state.isLocal then
		CameraRig.cutTo({angle = 250, dist = 36, height = 3, lookY = 70, fov = 62, roll = 4})
		CameraRig.shot({dist = 32, lookY = 84}, T.freeze - T.mid, Sine, Out)
	end
	impactFrames(state, {{"white", 0.05}, {"black", 0.045}})
	ScreenFx.flash(0.5, 0.3)
	if state.isLocal then
		glitch(state)
		ScreenFx.flare(pbase.Position + V3(0, 40, 0), P.white, 0.6, 0.4)
	end
	stab(sfx("Impact", state.anchor, 1.5, 0.85, true), 0.35, 0.4)
	if state.pillarLoop then
		Tw.play(state.pillarLoop, {Volume = 2.5}, 0.08)
		Tw.play(state.pillarLoop, {Volume = 1.9}, 0.4, Quad, Out, 0.1)
	end
	Tw.play(coreC, {Size = V3(H, 10, 10)}, 0.06, Quad, Out)
	Tw.play(coreC, {Size = V3(H, 5, 5)}, 0.3, Quad, Out, 0.08)
	flatShock(state, pbase, 20, 120, 0.5, P.crimson, 1, 32)
	Emitters.sparkleBurst(state.fxSoft, pbase * CFrame.new(0, 40, 0), V3(20, 60, 20), 20, {size = 1.8, speed = NumberRange.new(20, 60), drag = 2, life = NumberRange.new(1, 2)})
	if state.isLocal then
		CameraRig.kick(0.55)
	end
	Tw.wait(T.freeze - T.mid)
	if state.isLocal then
		CameraRig.cutTo({angle = 206, dist = 9.5, height = 3.6, lookY = 3.4, fov = 40, roll = -2})
		CameraRig.shot({dist = 8.4, roll = 0}, T.collapse - T.freeze, Sine, Out)
		dof(state, 9, 5, 0.6, 0.3)
	end
	-- sparkles keep breathing on the blade through the freeze
	local freezeAtt = Instance.new("Attachment")
	freezeAtt.CFrame = CFrame.new(0, 0, 0.6)
	freezeAtt.Parent = state.blade
	state.freezeSparkles = Emitters.sparkles(freezeAtt, {rate = 3, size = 0.5, speed = NumberRange.new(1, 3), enabled = true, life = NumberRange.new(0.6, 1.2)})
	state.freezeAtt = freezeAtt
	glowBurst(state, state.hrp.CFrame * CFrame.new(0, 1, 0), "burst", 4, 18, 0.3, P.white, 1, 1)
	Emitters.sparkleBurst(state.fxSoft, state.hrp.CFrame, V3(2, 4, 2), 8, {size = 0.8, speed = NumberRange.new(6, 18), drag = 3, life = NumberRange.new(0.6, 1.2)})
	if state.isLocal then
		CameraRig.kick(0.3)
	end
	Tw.wait(T.collapse - T.freeze)
end

-- phase e folds the pillar in on itself then blows out in three waves each bigger than the last
local function phaseBurst(state)
	state.fxHard:SetAttribute("Phase", "collapse")
	local pbase, H = state.pbase, Config.PillarHeight
	local center = pbase * CFrame.new(0, 6, 0)
	local sky = pbase * CFrame.new(0, 70, 0)
	state.pillarAlive = false
	stopEmitters(state.sparks, 3)
	stopEmitters(state.crescents, 2)
	stopEmitters(state.wind, 2)
	stopEmitters(state.rain, 3)
	stopEmitters(state.column, 2.5)
	for _, p in ipairs(state.pillarParts) do
		if p.Parent then
			if p:IsA("Part") then
				Tw.play(p, {Size = V3(p.Size.X, 0.1, 0.1)}, 0.26, Back, In)
			else
				Tw.play(p, {Size = V3(0.1, p.Size.Y, 0.1)}, 0.26, Back, In)
			end
			Debris:AddItem(p, 0.28 * Tw.S())
		end
	end
	for _, b in ipairs(state.beams) do
		Tw.play(b, {Width0 = 0, Width1 = 0}, 0.26, Back, In)
	end
	local suck = Emitters.carrier(state.fxSoft, center, V3(70, 70, 70))
	Emitters.make(suck, {
		texture = "star4",
		Shape = Enum.ParticleEmitterShape.Sphere,
		ShapeInOut = Enum.ParticleEmitterShapeInOut.Inward,
		ShapeStyle = Enum.ParticleEmitterShapeStyle.Surface,
		Speed = NumberRange.new(90, 150),
		Lifetime = NumberRange.new(0.25, 0.35),
		Size = Tw.seq({{0, 0}, {0.3, 2.5}, {1, 0}}),
		Color = Tw.cseq({{0, P.cyan}, {1, P.white}}),
		Orientation = Enum.ParticleOrientation.VelocityParallel,
		Enabled = true,
		Rate = 200,
	})
	task.delay(0.24 * Tw.S(), function()
		stopEmitters(suck, 1)
	end)
	Tw.play(state.light, {Brightness = 2}, 0.25)
	if state.pillarLoop then
		Tw.play(state.pillarLoop, {Volume = 0, PlaybackSpeed = 0.45 / Tw.S()}, T.burst - T.collapse, Quad, In)
		Debris:AddItem(state.pillarLoop, 0.4 * Tw.S())
	end
	if state.bed then
		Tw.play(state.bed, {Volume = 0}, 0.2)
		Debris:AddItem(state.bed, 0.3 * Tw.S())
	end
	sfx("RingWhoosh", state.anchor, 0.7, 0.55)
	muffle(state, -35, -14, T.burst - T.collapse, 0)
	duck(state, 0.6, T.burst - T.collapse)
	if state.isLocal then
		CameraRig.cutTo({angle = 262, dist = 64, height = 22, lookY = 16, fov = 62, roll = 0})
		CameraRig.shot({dist = 70, height = 24, lookY = 18}, T.burst - T.collapse, Sine, In)
		dof(state, 70, 40, 0.3, T.burst - T.collapse)
	end
	Tw.wait(T.burst - T.collapse)

	state.fxHard:SetAttribute("Phase", "burst")
	duck(state, 1, 0.01)
	muffle(state, 0, 0, 0.01)
	Tw.play(state.reverb, {WetLevel = -6, DecayTime = 3}, 0.05)
	sfx("Explosion", state.anchor, 1.9, 1, true)
	stab(sfx("Impact", state.anchor, 1.7, 0.55, true), 0.4, 0.5)
	-- the rumble loop sits under the explosion tail and fades out under the waves
	local rumble = sfx("Rumble", state.anchor, 0.85)
	if rumble then
		Tw.play(rumble, {Volume = 0}, 2.5, Quad, Out, 0.8)
		Debris:AddItem(rumble, 3.5 * Tw.S())
	end
	impactFrames(state, {{"white", 0.06}, {"black", 0.05}, {"white", 0.05}, {"black", 0.04}})
	ScreenFx.flash(1, 0.45)
	Tw.play(state.cc, {Brightness = 0.35, Saturation = 0.1}, 0.05)
	Tw.play(state.cc, {Brightness = -0.03, Saturation = -0.15}, 0.6, Quad, Out, 0.08)
	if state.isLocal then
		CameraRig.kick(1)
		SpeedLines.pulse(0.6, 0.5)
		CameraRig.shot({fov = 90, dist = 58, roll = 6}, 0.06, Quad, Out)
		CameraRig.shot({fov = 58, dist = 130, height = 48, lookY = 36, roll = -2}, 2.6, Quart, Out, 0.06)
		CameraRig.shot({angle = 300}, T.after - T.burst, Sine, InOut)
		glitch(state)
		exposure(state, 1.1, 0.8)
		ScreenFx.flare(center.Position, P.cyan, 1, 0.7)
		dof(state, 120, 160, 0.2, 1)
	else
		CameraRig.kick(0.9)
	end
	Tw.play(state.light, {Brightness = 30, Range = 260}, 0.08)
	Tw.play(state.light, {Brightness = 6}, 1.2, Quad, Out, 0.3)
	Tw.play(state.light2, {Brightness = 0}, 0.5)

	local flash = ball(state.fxSoft, center, 2, P.white, 0.4)
	Tw.play(flash, {Size = V3(80, 80, 80)}, 0.2, Quart, Out)
	fade(flash, 0.4, 0.05)
	glowBurst(state, center, "glow", 20, 160, 0.5, P.white, 2, 2)
	local sa0 = Instance.new("Attachment")
	sa0.CFrame = pbase * CFrame.new(0, 1, 0)
	sa0.Parent = workspace.Terrain
	local sa1 = Instance.new("Attachment")
	sa1.CFrame = pbase * CFrame.new(0, H * 1.6, 0)
	sa1.Parent = workspace.Terrain
	local spear = Instance.new("Beam")
	spear.Attachment0 = sa0
	spear.Attachment1 = sa1
	spear.Texture = Emitters.TEX.core
	spear.TextureLength = 40
	spear.TextureSpeed = -6
	spear.TextureMode = Enum.TextureMode.Wrap
	spear.Width0 = 0
	spear.Width1 = 0
	spear.LightEmission = 1
	spear.LightInfluence = 0
	spear.FaceCamera = true
	spear.Color = ColorSequence.new(P.white)
	spear.Transparency = Tw.seq({{0, 0.1}, {0.8, 0.3}, {1, 1}})
	spear.Parent = sa0
	Tw.play(spear, {Width0 = 16, Width1 = 24}, 0.1, Quart, Out)
	Tw.play(spear, {Width0 = 0, Width1 = 0}, 0.5, Quad, In, 0.14)
	Debris:AddItem(sa0, 0.7 * Tw.S())
	Debris:AddItem(sa1, 0.7 * Tw.S())
	local urchin = mesh("Burst", state.fxHard, center, V3(2, 2, 2), P.crimson, 0.35)
	spin(state, urchin, V3(0.6, 1.1, 0.4))
	Tw.play(urchin, {Size = V3(120, 120, 120)}, 0.35, Back, Out)
	fade(urchin, 0.55, 0.25)
	local shell = mesh("SphereWind", state.fxHard, center * CFrame.Angles(0.5, 1, 0), V3(4, 4, 4), P.pink, 0.2)
	spin(state, shell, V3(1.2, 2, 0.6))
	Tw.play(shell, {Size = V3(110, 110, 110)}, 0.5, Quart, Out)
	fade(shell, 0.5, 0.3)
	local shell2 = mesh("SphereFancy", state.fxHard, center * CFrame.Angles(2, 0.3, 1), V3(4, 4, 4), P.cyan, 0.45)
	spin(state, shell2, V3(-0.8, 1.4, 0.9))
	Tw.play(shell2, {Size = V3(150, 150, 150)}, 0.65, Quart, Out)
	fade(shell2, 0.5, 0.45)
	local ring = mesh("RingSketch", state.fxHard, pbase * CFrame.new(0, 0.5, 0), V3(6, 0.5, 6), P.white, 0.15)
	spin(state, ring, V3(0, 0.8, 0))
	Tw.play(ring, {Size = V3(190, 0.5, 190)}, 0.7, Quart, Out)
	fade(ring, 0.45, 0.3)
	for k = 0, 2 do
		local vr = mesh("RingSketch", state.fxHard, center * CFrame.Angles(R(90), k * R(60), 0), V3(4, 0.6, 4), k == 0 and P.crimson or (k == 1 and P.cyan or P.pink), 0.3)
		Tw.play(vr, {Size = V3(150, 1.2, 150)}, 0.65, Quart, Out)
		fade(vr, 0.45, 0.3)
	end
	flatShock(state, pbase, 30, 220, 0.6, P.white, 1, 30)
	flatShock(state, pbase, 20, 150, 0.5, P.crimson, 1, 36)
	flatShock(state, pbase, 40, 300, 0.8, P.cyan, 1, 24)
	floorGlow(state, pbase, 140, P.white, 1.2)
	Emitters.burst(state.fxSoft, center, nil, {
		texture = "lightrays",
		Speed = NumberRange.new(0),
		Lifetime = NumberRange.new(0.5),
		Size = Tw.seq({{0, 40}, {1, 200}}),
		Transparency = Tw.seq({{0, 0}, {1, 1}}),
		Color = ColorSequence.new(P.white),
		RotSpeed = NumberRange.new(-40, 40),
		ZOffset = -2,
	}, 3, 1)
	glowBurst(state, center, "impact", 30, 110, 0.32, P.white, 3, 3)

	local crownB = mesh("CrownTall", state.fxHard, pbase * CFrame.new(0, 0.3, 0), V3(1, 0.5, 1), P.crimson, 0.15)
	local cy = Instance.new("NumberValue")
	cy.Value = 0.3
	spin(state, crownB, V3(0, 0.5, 0), function()
		return pbase * CFrame.new(0, cy.Value, 0)
	end)
	Tw.play(crownB, {Size = V3(90, 50, 90)}, 0.28, Back, Out)
	Tw.play(cy, {Value = 25}, 0.28, Back, Out)
	local crownC = mesh("Crown", state.fxHard, pbase * CFrame.new(0, 0.3, 0), V3(1, 0.5, 1), P.white, 0.3)
	local cy2 = Instance.new("NumberValue")
	cy2.Value = 0.3
	spin(state, crownC, V3(0, -0.8, 0), function()
		return pbase * CFrame.new(0, cy2.Value, 0) * CFrame.Angles(0, 0.4, 0)
	end)
	Tw.play(crownC, {Size = V3(70, 70, 70)}, 0.32, Back, Out)
	Tw.play(cy2, {Value = 35}, 0.32, Back, Out)
	task.delay(0.6 * Tw.S(), function()
		for _, c in ipairs({{crownB, cy}, {crownC, cy2}}) do
			Tw.play(c[1], {Size = V3(c[1].Size.X * 0.6, 0.2, c[1].Size.Z * 0.6)}, 0.3, Back, In)
			Tw.play(c[2], {Value = 0.2}, 0.3, Back, In)
			Debris:AddItem(c[1], 0.32 * Tw.S())
		end
	end)

	for i = 1, 12 do
		popStar(state, polar(pbase, math.random() * 6.28, 16 + math.random() * 34, 3 + math.random() * 36), 5 + math.random() * 8, SP[(i % #SP) + 1], 0.75)
	end
	Emitters.sparkleBurst(state.fxSoft, center, V3(6, 6, 6), 34, {size = 1.8, speed = NumberRange.new(40, 120), drag = 2.5, life = NumberRange.new(1.2, 2.2)})
	sparkBurst(state, center, 90, 220, P.crimson)
	shardBurst(state, center, 70, 200, P.cyan)
	rockBurst(state, pbase, 12, 130, 70, 3.5)
	smokeRing(state, pbase, 10, 70, 10, 34, 50, 1.5, P.pink)
	smokeRing(state, pbase, 16, 90, 16, 44, 40, 1.8, Color3.fromRGB(140, 110, 130), true)
	arcs(state, function()
		return center.Position
	end, 50, 40, 2, 0.5, {P.white, P.crimson, P.cyan}, 0.7)
	local embers = Emitters.carrier(state.fxSoft, pbase * CFrame.new(0, 1, 0), V3(70, 2, 70))
	Emitters.make(embers, {
		texture = "specs",
		Shape = Enum.ParticleEmitterShape.Box,
		EmissionDirection = Enum.NormalId.Top,
		SpreadAngle = Vector2.new(30, 30),
		Speed = NumberRange.new(6, 18),
		Acceleration = V3(0, 3, 0),
		Drag = 0.5,
		Lifetime = NumberRange.new(1.8, 3.4),
		Size = Tw.seq({{0, 0}, {0.2, 0.9}, {1, 0}}),
		Color = Tw.cseq({{0, P.white}, {0.3, P.ember}, {1, P.crimson}}),
		Enabled = true,
		Rate = 70,
	})
	state.embers = embers
	flatCrack(state, pbase, "crackB", 90, 4.5, 5.5)
	platesFling(state)
	Tw.wait(T.wave2 - T.burst)

	impactFrames(state, {{"white", 0.05}, {"black", 0.05}})
	ScreenFx.flash(0.7, 0.4)
	stab(sfx("Impact", state.anchor, 1.5, 0.7, true), 0.4, 0.5)
	sfx("Explosion", state.anchor, 1.2, 0.85, true)
	sfx("Crown", state.anchor, 0.75, 0.8)
	if state.isLocal then
		CameraRig.kick(0.85)
		SpeedLines.pulse(0.5, 0.4)
		exposure(state, 0.7, 0.6)
		ScreenFx.flare(sky.Position, P.pink, 0.8, 0.6)
	else
		CameraRig.kick(0.7)
	end
	Tw.play(state.light, {Brightness = 26, Range = 300}, 0.06)
	Tw.play(state.light, {Brightness = 4}, 1.4, Quad, Out, 0.2)
	local flash2 = ball(state.fxSoft, center, 10, P.cyan, 0.5)
	Tw.play(flash2, {Size = V3(140, 140, 140)}, 0.3, Quart, Out)
	fade(flash2, 0.5, 0.05)
	local urchin2 = mesh("Burst", state.fxHard, center * CFrame.Angles(1, 2, 0), V3(4, 4, 4), P.pink, 0.45)
	spin(state, urchin2, V3(-0.5, 0.9, 0.7))
	Tw.play(urchin2, {Size = V3(170, 170, 170)}, 0.4, Back, Out)
	fade(urchin2, 0.6, 0.3)
	local cracked = mesh("SphereCracked", state.fxHard, center * CFrame.Angles(0.4, 0.8, 0.2), V3(6, 6, 6), P.crimson, 0.35)
	spin(state, cracked, V3(0.7, -1.1, 0.3))
	Tw.play(cracked, {Size = V3(180, 180, 180)}, 0.6, Quart, Out)
	fade(cracked, 0.6, 0.4)
	local ring2 = mesh("RingSketch", state.fxHard, pbase * CFrame.new(0, 0.5, 0), V3(10, 0.6, 10), P.crimson, 0.2)
	spin(state, ring2, V3(0, -0.6, 0))
	Tw.play(ring2, {Size = V3(260, 0.6, 260)}, 0.9, Quart, Out)
	fade(ring2, 0.5, 0.45)
	local ring3 = mesh("RingRipple", state.fxHard, pbase * CFrame.new(0, 0.7, 0), V3(10, 0.4, 10), P.cyan, 0.2)
	spin(state, ring3, V3(0, 1, 0))
	Tw.play(ring3, {Size = V3(220, 0.4, 220)}, 1, Quart, Out)
	fade(ring3, 0.6, 0.5)
	flatShock(state, pbase, 60, 340, 0.8, P.white, 1, 24)
	Emitters.burst(state.fxSoft, center, nil, {
		texture = "lightrays",
		Speed = NumberRange.new(0),
		Lifetime = NumberRange.new(0.6),
		Size = Tw.seq({{0, 60}, {1, 280}}),
		Transparency = Tw.seq({{0, 0}, {1, 1}}),
		Color = ColorSequence.new(P.cyan),
		RotSpeed = NumberRange.new(-30, 30),
		ZOffset = -2,
	}, 2, 1)
	local skyStar = mesh("Star", state.fxHard, sky * CFrame.Angles(0.4, 0.2, 0), V3(1, 1, 1), P.cyan, 0.1)
	spin(state, skyStar, V3(0, 1.5, 0.8))
	Tw.play(skyStar, {Size = V3(90, 90, 90)}, 0.35, Back, Out)
	fade(skyStar, 0.5, 0.35)
	local skyBurst = mesh("Burst", state.fxHard, sky, V3(1, 1, 1), P.white, 0.2)
	spin(state, skyBurst, V3(1, 0.6, 1.2))
	Tw.play(skyBurst, {Size = V3(130, 130, 130)}, 0.4, Back, Out)
	fade(skyBurst, 0.5, 0.35)
	glowBurst(state, sky, "impactB", 40, 180, 0.5, P.pink, 2, 2)
	for i = 1, 10 do
		popStar(state, polar(pbase, math.random() * 6.28, 24 + math.random() * 44, 10 + math.random() * 60), 7 + math.random() * 10, SP[(i % #SP) + 1], 0.8)
	end
	Emitters.sparkleBurst(state.fxSoft, center, V3(10, 10, 10), 40, {size = 2.4, speed = NumberRange.new(50, 150), drag = 2, life = NumberRange.new(1.4, 2.6)})
	Emitters.sparkleBurst(state.fxSoft, sky, V3(10, 10, 10), 28, {size = 2.8, speed = NumberRange.new(30, 110), drag = 1.5, life = NumberRange.new(1.4, 2.6)})
	sparkBurst(state, center, 120, 260, P.pink)
	shardBurst(state, sky, 70, 180, P.cyan)
	rockBurst(state, pbase, 16, 170, 80, 4)
	smokeRing(state, pbase, 14, 110, 20, 60, 50, 2, P.white)
	arcs(state, function()
		return sky.Position
	end, 60, 30, 2, 0.5, {P.white, P.cyan, P.pink}, 0.8)
	Tw.wait(T.wave3 - T.wave2)

	ScreenFx.flash(0.45, 0.5, P.cyan)
	sfx("Dome", state.anchor, 1, 0.6)
	sfx("Explosion", state.anchor, 0.95, 0.65, true)
	task.delay(0.35 * Tw.S(), function()
		sfx("Explosion", state.anchor, 0.45, 0.5)
	end)
	if state.isLocal then
		CameraRig.kick(0.6)
		CameraRig.shot({dist = 155, height = 58, lookY = 44, fov = 56, roll = 1}, 1.8, Sine, InOut)
		ScreenFx.flare(center.Position + V3(0, 20, 0), P.white, 0.5, 0.8)
	end
	local rip = mesh("RingRipple", state.fxHard, pbase * CFrame.new(0, 0.8, 0), V3(20, 0.4, 20), P.white, 0.25)
	spin(state, rip, V3(0, -0.6, 0))
	Tw.play(rip, {Size = V3(340, 0.4, 340)}, 1.3, Quart, Out)
	fade(rip, 0.7, 0.6)
	local dome = mesh("SphereWind", state.fxHard, center * CFrame.Angles(0.2, 0.7, 0.1), V3(10, 10, 10), P.cyan, 0.6)
	spin(state, dome, V3(0.3, 0.8, 0.2))
	Tw.play(dome, {Size = V3(240, 240, 240)}, 1.2, Quart, Out)
	fade(dome, 0.8, 0.5)
	Emitters.burst(state.fxSoft, center * CFrame.new(0, 10, 0), V3(30, 10, 30), {
		texture = "darksmoke",
		Shape = Enum.ParticleEmitterShape.Box,
		EmissionDirection = Enum.NormalId.Top,
		SpreadAngle = Vector2.new(25, 25),
		Speed = NumberRange.new(30, 60),
		Drag = 1.2,
		Lifetime = NumberRange.new(2.4, 3.6),
		Size = Tw.seq({{0, 14}, {0.5, 40}, {1, 60}}),
		Color = Tw.cseq({{0, P.pink}, {0.3, Color3.fromRGB(120, 80, 110)}, {1, Color3.fromRGB(35, 25, 40)}}),
		Transparency = Tw.seq({{0, 0.3}, {0.5, 0.55}, {1, 1}}),
		LightEmission = 0.1,
		LightInfluence = 0.8,
		Acceleration = V3(0, 4, 0),
		Rotation = NumberRange.new(0, 360),
		RotSpeed = NumberRange.new(-25, 25),
	}, 45, 4.5)
	local debris = Emitters.carrier(state.fxSoft, pbase * CFrame.new(0, 90, 0), V3(120, 4, 120))
	Emitters.make(debris, {
		texture = "rocks",
		flip = {Enum.ParticleFlipbookLayout.Grid2x2, Enum.ParticleFlipbookMode.Random, 1},
		Shape = Enum.ParticleEmitterShape.Box,
		EmissionDirection = Enum.NormalId.Bottom,
		SpreadAngle = Vector2.new(20, 20),
		Speed = NumberRange.new(0, 12),
		Acceleration = V3(0, -70, 0),
		Lifetime = NumberRange.new(1.6, 2.4),
		Size = Tw.seq({{0, 1.2}, {0.1, 3}, {1, 3}}),
		Color = ColorSequence.new(P.rock),
		LightEmission = 0.25,
		LightInfluence = 0.5,
		Rotation = NumberRange.new(0, 360),
		RotSpeed = NumberRange.new(-200, 200),
		Enabled = true,
		Rate = 35,
	})
	Emitters.make(debris, {
		texture = "specs",
		Shape = Enum.ParticleEmitterShape.Box,
		EmissionDirection = Enum.NormalId.Bottom,
		SpreadAngle = Vector2.new(30, 30),
		Speed = NumberRange.new(4, 10),
		Acceleration = V3(0, -6, 0),
		Lifetime = NumberRange.new(3, 4.5),
		Size = Tw.seq({{0, 0.5}, {1, 0.3}}),
		Color = Tw.cseq({{0, P.ember}, {1, Color3.fromRGB(120, 60, 60)}}),
		Enabled = true,
		Rate = 50,
	})
	task.delay(1.6 * Tw.S(), function()
		stopEmitters(debris, 5)
	end)
	local after = Emitters.carrier(state.fxSoft, pbase * CFrame.new(0, 40, 0), V3(160, 90, 160))
	state.afterField = Emitters.sparkles(after, {rate = 16, size = 2.2, speed = NumberRange.new(1, 5), enabled = true, life = NumberRange.new(1.5, 3), accel = V3(0, 1, 0)})
	state.afterCarrier = after
	task.spawn(function()
		for i = 1, 4 do
			Tw.wait(0.22)
			if not state.alive then
				return
			end
			local at = polar(pbase, math.random() * 6.28, 20 + math.random() * 50, 6 + math.random() * 50)
			Emitters.sparkleBurst(state.fxSoft, at, V3(3, 3, 3), 14, {size = 1.8, speed = NumberRange.new(20, 60), drag = 3, life = NumberRange.new(1, 2)})
			local pop = mesh("SphereWind", state.fxHard, at * CFrame.Angles(rnd(0, 6), rnd(0, 6), 0), V3(2, 2, 2), SP[(i % #SP) + 1], 0.5)
			spin(state, pop, V3(0.8, 1.2, 0.5))
			Tw.play(pop, {Size = V3(30, 30, 30)}, 0.35, Quart, Out)
			fade(pop, 0.35, 0.25)
			if state.isLocal then
				CameraRig.kick(0.25)
			end
		end
	end)
	Tw.wait(T.after - T.wave3)
end

-- phase f lets the smoke and sparkles breathe out then fades to black and wakes the default camera behind the body
local function phaseAftermath(state)
	state.fxHard:SetAttribute("Phase", "after")
	Tw.play(state.cc, {Saturation = 0, Brightness = 0, Contrast = 0, TintColor = Color3.new(1, 1, 1)}, 2)
	if state.bloom then
		Tw.play(state.bloom, {Intensity = state.bloom0.Intensity, Size = state.bloom0.Size, Threshold = state.bloom0.Threshold}, 2)
	end
	Tw.play(Lighting, state.world0, 2, Sine, InOut)
	if state.atmos then
		Tw.play(state.atmos, {Density = state.atmos0}, 2, Sine, InOut)
	end
	Tw.play(state.light, {Brightness = 0}, 1.8)
	local tail = sfx("Aftermath", state.anchor, 0)
	if tail then
		Tw.play(tail, {Volume = 4}, 0.6)
	end
	Tw.play(state.reverb, {WetLevel = -10, DecayTime = 2.2}, 1)
	muffle(state, -18, -6, T.fade - T.after)
	duck(state, 0, T.black - T.fade, T.fade - T.after)
	if state.isLocal then
		SpeedLines.stop(0.4)
		CameraRig.shot({dist = 110, height = 36, lookY = 26, fov = 50, roll = 0}, T.fade - T.after + 0.6, Sine, InOut)
		dof(state, 100, 60, 0.4, 1.5)
		ScreenFx.vignette(0.55, 1.5)
	end
	task.delay(0.6 * Tw.S(), function()
		stopEmitters(state.embers, 4)
	end)
	Tw.wait(T.fade - T.after)
	if state.isLocal then
		ScreenFx.fade(1, T.black - T.fade)
	end
	Tw.wait(T.black - T.fade)
	if state.track then
		state.track:Stop(0)
	end
	if state.anchored then
		state.anchored.Anchored = false
	end
	if state.isLocal then
		CameraRig.cut(state.character)
	end
	if state.freezeAtt then
		Debris:AddItem(state.freezeAtt, 0.1)
	end
	for _, list in ipairs({state.afterField, state.wide, state.field, state.pfield, state.freezeSparkles}) do
		if list then
			Emitters.setSparkles(list, false)
		end
	end
	state.fxHard:ClearAllChildren()
	if state.dof then
		state.dof:Destroy()
		state.dof = nil
	end
	Tw.wait(T.fadeIn - T.black)
	if state.isLocal then
		ScreenFx.fade(0, 0.9)
		ScreenFx.vignette(0, 0.9)
		ScreenFx.bars(false, 0.9)
	end
	Tw.wait(1)
end

local function setup(character, origin, isLocal)
	local state = {character = character, origin = origin, isLocal = isLocal, alive = true}
	state.hrp = character:FindFirstChild("HumanoidRootPart")
	local swordModel = character:FindFirstChild("Sword")
	state.blade = (swordModel and swordModel:FindFirstChild("Sword")) or character:FindFirstChild("Right Arm") or character:FindFirstChild("RightHand") or state.hrp
	state.base = groundBelow(origin, character)
	state.pbase = state.base * CFrame.new(Config.PillarOffset)
	state.impact = state.base * CFrame.new(Config.ImpactOffset)
	state.focus = state.base * CFrame.new(Config.PillarOffset * 0.5)
	state.fxHard = newModel("UltFxHard")
	state.fxSoft = newModel("UltFxSoft")
	state.anchor = Emitters.carrier(state.fxSoft, state.impact)
	startSpinners(state)
	mixSetup(state)
	local cc = Instance.new("ColorCorrectionEffect")
	cc.Name = "UltColor"
	cc.Parent = Lighting
	state.cc = cc
	local bloom = Lighting:FindFirstChildOfClass("BloomEffect")
	if bloom then
		state.bloom = bloom
		state.bloom0 = {Intensity = bloom.Intensity, Size = bloom.Size, Threshold = bloom.Threshold}
	end
	state.world0 = {Brightness = Lighting.Brightness, OutdoorAmbient = Lighting.OutdoorAmbient, Ambient = Lighting.Ambient}
	local atm = Lighting:FindFirstChildOfClass("Atmosphere")
	if atm then
		state.atmos = atm
		state.atmos0 = atm.Density
	end
	if isLocal then
		if state.hrp then
			state.hrp.Anchored = true
			state.anchored = state.hrp
		end
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
		if animator then
			local track = animator:LoadAnimation(Animations.Ultimate)
			track.Priority = Enum.AnimationPriority.Action
			-- looped as a guard since frame zero and the last frame are the same stance if the freeze lands late
			track.Looped = true
			state.track = track
		end
		if Config.Cinematic then
			CameraRig.take(state.focus, {angle = 50, dist = 15.5, height = 4.8, lookY = 4, fov = 64, roll = 0})
			ScreenFx.bars(true, 0.5)
			ScreenFx.vignette(0.4, 0.8)
			local d = Instance.new("DepthOfFieldEffect")
			d.Name = "UltDoF"
			d.FocusDistance = 16
			d.InFocusRadius = 10
			d.NearIntensity = 0.25
			d.FarIntensity = 0
			d.Parent = Lighting
			state.dof = d
			Tw.play(d, {FarIntensity = 0.45}, 0.8)
		end
		state.exposure0 = Lighting.ExposureCompensation
	else
		CameraRig.rumble(state.base.Position)
	end
	rockPlates(state)
	return state
end

local function run(state)
	local isLocal = state.isLocal
	driveClip(state)
	if isLocal then
		CameraRig.shot({dist = 12.4, height = 3.4, angle = 82, lookY = 4.2, fov = 58, roll = 3}, T.hold, Sine, InOut)
		dof(state, 12, 7, 0.55, T.hold)
	end
	preWind(state)
	Tw.wait(T.hold)
	-- the sword is up and nothing happens for two seconds but wind the dimming world and a low bed
	for _, x in ipairs(state.preWind or {}) do
		if x:IsA("Attachment") then
			for _, e in ipairs(x:GetChildren()) do
				if e:IsA("ParticleEmitter") then
					e.Enabled = false
				end
			end
		elseif x:IsA("Trail") then
			Debris:AddItem(x, 0.3 * Tw.S())
		end
	end
	if isLocal then
		CameraRig.cutTo({angle = 178, dist = 9.8, height = 1.3, lookY = 5, fov = 48, roll = 3})
		CameraRig.shot({dist = 8.6, height = 1.0, roll = 4}, T.charge - T.hold, Sine, InOut)
		dof(state, 10, 6, 0.5, 0.4)
	end
	state.tension = sfx("Rumble", state.anchor, 0, 0.7)
	if state.tension then
		Tw.play(state.tension, {Volume = 0.3}, T.charge - T.hold, Quad, In)
	end
	Tw.wait(T.charge - T.hold)
	stopPreWind(state)
	if state.tension then
		Tw.play(state.tension, {Volume = 0}, 0.5)
		Debris:AddItem(state.tension, 0.6 * Tw.S())
	end
	phaseCharge(state)
	Tw.wait(T.peak - T.charge)
	chargePeak(state)
	Tw.wait(T.slash - T.peak)
	slashArc(state)
	if isLocal then
		CameraRig.shot({angle = 106, dist = 8.6, roll = -8}, T.impact - T.slash, Quad, Out)
		afterimage(state, P.pink, 3, 0.02, 0.28)
	end
	Tw.wait(T.impact - T.slash)
	sfx("Impact", state.anchor, 2, 1, true)
	duck(state, 0.05, 0.02)
	duck(state, 1, 0.12, T.follow - T.impact)
	muffle(state, -30, -12, 0.01)
	muffle(state, 0, 0, 0.5, T.follow - T.impact)
	stopCharge(state)
	-- the camera stays dead still through the cutout frames and only moves when the hit stop releases
	task.delay((T.follow - T.impact) * Tw.S(), function()
		if isLocal then
			CameraRig.cutTo({fov = 66, dist = 20, angle = 104, height = 7, lookY = 5.5, roll = 2})
			CameraRig.shot({dist = 24}, 0.45, Quart, Out)
			CameraRig.kick(0.9)
			SpeedLines.pulse(0.6, 0.35)
			glitch(state)
			exposure(state, 0.6, 0.5)
			ScreenFx.flare(state.impact.Position, P.cyan, 0.7, 0.45)
			dof(state, 24, 20, 0.35, 0.5)
		else
			CameraRig.kick(0.7)
		end
	end)
	impactFrames(state, {{"white", 0.06}, {"black", 0.05}, {"white", 0.05}})
	ScreenFx.flash(0.6, 0.25)
	phaseDome(state)
	phasePillar(state)
	phaseBurst(state)
	phaseAftermath(state)
	Tw.wait(2.5)
end

-- everything the sequence borrowed goes back even when a phase throws halfway
local function cleanup(state, failed)
	state.alive = false
	state.pillarAlive = false
	mixReset(state)
	if state.spinConn then
		state.spinConn:Disconnect()
	end
	if state.track then
		state.track:Stop(failed and 0 or 0.4)
	end
	if state.anchored then
		state.anchored.Anchored = false
	end
	if state.dof then
		state.dof:Destroy()
	end
	if state.exposure0 then
		Lighting.ExposureCompensation = state.exposure0
	end
	if failed and state.world0 then
		for k, v in pairs(state.world0) do
			Lighting[k] = v
		end
		if state.atmos then
			state.atmos.Density = state.atmos0
		end
	end
	if state.freezeAtt then
		state.freezeAtt:Destroy()
	end
	if state.auraAtt then
		state.auraAtt:Destroy()
	end
	if state.isLocal then
		SpeedLines.stop(0.3)
		if failed then
			ScreenFx.reset()
			CameraRig.cut(state.character)
		end
	else
		CameraRig.stopRumble()
	end
	state.fxHard:Destroy()
	state.fxSoft:Destroy()
	for _, a in ipairs(state.beamAtt or {}) do
		a:Destroy()
	end
	if failed then
		state.cc:Destroy()
		if state.bloom then
			for k, v in pairs(state.bloom0) do
				state.bloom[k] = v
			end
		end
	else
		Tw.play(state.cc, {Saturation = 0, Brightness = 0, Contrast = 0, TintColor = Color3.new(1, 1, 1)}, 0.5).Completed:Once(function()
			state.cc:Destroy()
		end)
	end
end

function UltimateVfx.play(character, origin, isLocal)
	local state = setup(character, origin, isLocal)
	local ok, err = pcall(run, state)
	if not ok then
		warn("ultimate sequence failed", err)
	end
	cleanup(state, not ok)
end

return UltimateVfx
