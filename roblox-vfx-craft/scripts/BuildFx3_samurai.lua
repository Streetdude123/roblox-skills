local fx = game.ReplicatedStorage.Samurai.Assets.Fx
for _, n in ipairs({"Storm", "StormBurst", "LionRoar", "DashTrail", "WingBurst", "Landing"}) do
	local o = fx:FindFirstChild(n)
	if o then
		o:Destroy()
	end
end

local rgb = Color3.fromRGB
local P = {
	core = rgb(232, 255, 246), mint = rgb(150, 255, 220), jade = rgb(30, 235, 185), teal = rgb(0, 170, 140),
	deep = rgb(0, 62, 60), dark = rgb(4, 30, 32),
}
local id = function(n)
	return "rbxassetid://" .. n
end
local T = {
	claw = id(5039755229), wingSlash = id(5039755602), swoosh = id(5039755921), hook = id(5039756237),
	spark = id(8037777212), dot = id(12082081459), glow = id(1075864321), flare = id(867619398),
	smoke = id(7538163753), wisp = id(10337713824), ring = id(16950679789), thinRing = id(11948622097),
	spiky = id(9573351641), star = id(16670162492), lion = id(129170861176068),
	featherA = id(107483578603804), featherB = id(119359586668380),
}

local function seq(points)
	local k = {}
	for _, p in ipairs(points) do
		table.insert(k, NumberSequenceKeypoint.new(p[1], p[2], p[3] or 0))
	end
	return NumberSequence.new(k)
end
local function cseq(points)
	local k = {}
	for _, p in ipairs(points) do
		table.insert(k, ColorSequenceKeypoint.new(p[1], p[2]))
	end
	return ColorSequence.new(k)
end
local function carrier(name, size)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size or Vector3.new(1, 1, 1)
	p.Transparency = 1
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	p.Massless = true
	return p
end
local function emitter(parent, name, props)
	local e = Instance.new("ParticleEmitter")
	e.Name = name
	e.Enabled = false
	e.Rate = 0
	e.LightInfluence = 0
	e.LightEmission = 1
	for k, v in pairs(props) do
		e[k] = v
	end
	e.Parent = parent
	return e
end
local function light(parent, range)
	local l = Instance.new("PointLight")
	l.Name = "Light"
	l.Color = P.jade
	l.Range = range
	l.Brightness = 0
	l.Shadows = false
	l.Parent = parent
end

local HOT = cseq({{0, P.core}, {0.35, P.mint}, {1, P.jade}})
local COOL = cseq({{0, P.mint}, {0.5, P.jade}, {1, P.teal}})
local CYL = Enum.ParticleEmitterShape.Cylinder
local SURF = Enum.ParticleEmitterShapeStyle.Surface
local VOL = Enum.ParticleEmitterShapeStyle.Volume
local ALONG = Enum.ParticleOrientation.VelocityParallel
local FLAT = Enum.ParticleOrientation.VelocityPerpendicular

local storm = Instance.new("Model")
storm.Name = "Storm"
local base = carrier("Base")
base.Parent = storm
storm.PrimaryPart = base
light(base, 26)
local LAYERS = {{"L1", 5, 3, 1.5}, {"L2", 8, 4, 5}, {"L3", 11.5, 4, 9}, {"L4", 15, 4.5, 13}}
for i, l in ipairs(LAYERS) do
	local s = l[2] / 8
	local p = carrier(l[1], Vector3.new(l[2], l[3], l[2]))
	p.CFrame = CFrame.new(0, l[4], 0)
	p:SetAttribute("Y", l[4])
	p:SetAttribute("Spin", (i % 2 == 0 and -1 or 1) * (10 + i * 2.5))
	p.Parent = storm
	emitter(p, "Curl", {
		Texture = i % 2 == 0 and T.hook or T.claw, Color = COOL, LockedToPart = true,
		Size = seq({{0, 0}, {0.25, 1.6 * s + 0.5}, {1, 2.2 * s + 0.6}}), Transparency = seq({{0, 1}, {0.15, 0.35}, {0.6, 0.55}, {1, 1}}),
		Lifetime = NumberRange.new(0.25, 0.45), Speed = NumberRange.new(0.5, 2), Rotation = NumberRange.new(-180, 180),
		RotSpeed = NumberRange.new(-420, 420), Shape = CYL, ShapeStyle = SURF, EmissionDirection = Enum.NormalId.Top, LightEmission = 0.9,
	}):SetAttribute("Rate", 34 + i * 6)
	emitter(p, "Swoosh", {
		Texture = T.swoosh, Color = COOL, LockedToPart = true,
		Size = seq({{0, 0.4}, {0.3, 1.6 * s + 0.8}, {1, 2 * s + 1}}), Transparency = seq({{0, 1}, {0.2, 0.25}, {1, 1}}),
		Lifetime = NumberRange.new(0.2, 0.35), Speed = NumberRange.new(0.5, 1.5), Rotation = NumberRange.new(-180, 180),
		RotSpeed = NumberRange.new(-300, 300), Shape = CYL, ShapeStyle = SURF, EmissionDirection = Enum.NormalId.Top,
	}):SetAttribute("Rate", 30 + i * 5)
	emitter(p, "Streak", {
		Texture = T.spark, Color = HOT, LockedToPart = true, Orientation = ALONG,
		Size = seq({{0, 0.3}, {0.3, 1.1}, {1, 0}}), Squash = seq({{0, 3}, {1, 4.5}}), Transparency = seq({{0, 0}, {1, 1}}),
		Lifetime = NumberRange.new(0.22, 0.4), Speed = NumberRange.new(12, 24), SpreadAngle = Vector2.new(12, 12),
		Shape = CYL, ShapeStyle = SURF, EmissionDirection = Enum.NormalId.Top,
	}):SetAttribute("Rate", 70)
	emitter(p, "Motes", {
		Texture = T.dot, Color = cseq({{0, P.core}, {1, P.mint}}), LockedToPart = true,
		Size = seq({{0, 0}, {0.2, 0.45}, {0.5, 0.2}, {0.7, 0.4}, {1, 0}}), Transparency = seq({{0, 0}, {1, 0.4}}),
		Lifetime = NumberRange.new(0.4, 0.8), Speed = NumberRange.new(4, 10), Acceleration = Vector3.new(0, 6, 0),
		Shape = CYL, ShapeStyle = VOL, EmissionDirection = Enum.NormalId.Top,
	}):SetAttribute("Rate", 36)
	if i == 2 or i == 3 then
		emitter(p, "Glow", {
			Texture = T.glow, Color = ColorSequence.new(P.jade), LockedToPart = true,
			Size = seq({{0, 5}, {1, 8}}), Transparency = seq({{0, 1}, {0.3, 0.8}, {1, 1}}),
			Lifetime = NumberRange.new(0.3, 0.5), Speed = NumberRange.new(0, 0), Shape = CYL, ShapeStyle = VOL,
		}):SetAttribute("Rate", 12)
	end
	if i == 1 then
		emitter(p, "Dust", {
			Texture = T.smoke, Color = cseq({{0, P.teal}, {1, P.deep}}), LockedToPart = true, LightEmission = 0.15,
			Size = seq({{0, 2}, {1, 5.5}}), Transparency = seq({{0, 1}, {0.2, 0.55}, {1, 1}}),
			Lifetime = NumberRange.new(0.6, 1), Speed = NumberRange.new(5, 9), Rotation = NumberRange.new(-180, 180),
			RotSpeed = NumberRange.new(-90, 90), Shape = CYL, ShapeStyle = SURF, ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward,
		}):SetAttribute("Rate", 34)
	end
end
storm.Parent = fx

local sb = Instance.new("Model")
sb.Name = "StormBurst"
local body = carrier("Body", Vector3.new(5, 10, 5))
body.CFrame = CFrame.new(0, 5, 0)
body.Parent = sb
sb.PrimaryPart = body
light(body, 34)
local OUT = Enum.ParticleEmitterShapeInOut.Outward
emitter(body, "Curl", {
	Texture = T.claw, Color = COOL, Size = seq({{0, 1}, {0.3, 4}, {1, 5.5}}), Transparency = seq({{0, 0}, {0.6, 0.3}, {1, 1}}),
	Lifetime = NumberRange.new(0.3, 0.5), Speed = NumberRange.new(40, 70), Drag = 4, Rotation = NumberRange.new(-180, 180),
	RotSpeed = NumberRange.new(-360, 360), Shape = CYL, ShapeStyle = SURF, ShapeInOut = OUT,
})
emitter(body, "Wing", {
	Texture = T.wingSlash, Color = HOT, Size = seq({{0, 1}, {0.3, 5}, {1, 7}}), Transparency = seq({{0, 0}, {0.5, 0.3}, {1, 1}}),
	Lifetime = NumberRange.new(0.25, 0.4), Speed = NumberRange.new(45, 75), Drag = 5, Rotation = NumberRange.new(-30, 30),
	Shape = CYL, ShapeStyle = SURF, ShapeInOut = OUT,
})
emitter(body, "Streak", {
	Texture = T.spark, Color = HOT, Orientation = ALONG, Size = seq({{0, 0.6}, {0.2, 1.7}, {1, 0}}), Squash = seq({{0, 4}, {1, 5}}),
	Transparency = seq({{0, 0}, {1, 1}}), Lifetime = NumberRange.new(0.3, 0.55), Speed = NumberRange.new(60, 110), Drag = 3,
	SpreadAngle = Vector2.new(20, 20), Shape = CYL, ShapeStyle = SURF, ShapeInOut = OUT,
})
emitter(body, "Swoosh", {
	Texture = T.swoosh, Color = COOL, Size = seq({{0, 2}, {1, 5}}), Transparency = seq({{0, 0.1}, {1, 1}}),
	Lifetime = NumberRange.new(0.3, 0.5), Speed = NumberRange.new(35, 60), Drag = 3, Rotation = NumberRange.new(-180, 180),
	RotSpeed = NumberRange.new(-200, 200), Shape = CYL, ShapeStyle = SURF, ShapeInOut = OUT,
})
emitter(body, "Motes", {
	Texture = T.dot, Color = cseq({{0, P.core}, {1, P.mint}}), Size = seq({{0, 0.2}, {0.3, 0.55}, {1, 0}}),
	Lifetime = NumberRange.new(0.6, 1.2), Speed = NumberRange.new(18, 45), Drag = 2.5, Acceleration = Vector3.new(0, -8, 0),
	SpreadAngle = Vector2.new(180, 180), Shape = CYL, ShapeStyle = VOL,
})
emitter(body, "Flare", {
	Texture = T.flare, Color = ColorSequence.new(P.jade), Size = seq({{0, 6}, {1, 13}}), Transparency = seq({{0, 0.5}, {1, 1}}),
	Lifetime = NumberRange.new(0.3, 0.35), Speed = NumberRange.new(0, 0), ZOffset = -2,
})
emitter(body, "Spiky", {
	Texture = T.spiky, Color = HOT, Size = seq({{0, 4}, {1, 20}}), Transparency = seq({{0, 0}, {1, 1}}),
	Lifetime = NumberRange.new(0.3, 0.3), Speed = NumberRange.new(0, 0), Rotation = NumberRange.new(-180, 180),
})
local floor = carrier("Floor", Vector3.new(6, 0.2, 6))
floor.CFrame = CFrame.new(0, 0.2, 0)
floor.Parent = sb
emitter(floor, "Ring", {
	Texture = T.ring, Color = ColorSequence.new(P.mint), Orientation = FLAT, EmissionDirection = Enum.NormalId.Top,
	Size = seq({{0, 3}, {1, 26}}), Transparency = seq({{0, 0}, {1, 1}}), Lifetime = NumberRange.new(0.45, 0.45), Speed = NumberRange.new(0.01, 0.01),
})
emitter(floor, "Dust", {
	Texture = T.smoke, Color = cseq({{0, P.teal}, {1, P.deep}}), LightEmission = 0.15, Size = seq({{0, 3}, {1, 7}}),
	Transparency = seq({{0, 0.4}, {1, 1}}), Lifetime = NumberRange.new(0.7, 1.2), Speed = NumberRange.new(18, 30), Drag = 3,
	Rotation = NumberRange.new(-180, 180), RotSpeed = NumberRange.new(-60, 60), Shape = CYL, ShapeStyle = SURF, ShapeInOut = OUT,
})
sb.Parent = fx

local roar = carrier("LionRoar", Vector3.new(13, 13, 0.5))
light(roar, 24)
emitter(roar, "Face", {
	Texture = T.lion, Color = ColorSequence.new(Color3.new(1, 1, 1)), LockedToPart = true, LightEmission = 0.3, Brightness = 2,
	Size = seq({{0, 8}, {0.12, 13}, {0.5, 14}, {1, 16}}), Transparency = seq({{0, 1}, {0.08, 0}, {0.45, 0.05}, {0.75, 0.6}, {1, 1}}),
	Lifetime = NumberRange.new(0.8, 0.8), Speed = NumberRange.new(0, 0), ZOffset = 1,
})
emitter(roar, "Echo", {
	Texture = T.lion, Color = ColorSequence.new(P.mint), LockedToPart = true,
	Size = seq({{0, 12}, {1, 22}}), Transparency = seq({{0, 1}, {0.06, 0.45}, {1, 1}}),
	Lifetime = NumberRange.new(0.4, 0.4), Speed = NumberRange.new(0, 0),
})
emitter(roar, "Shards", {
	Texture = T.spark, Color = HOT, Orientation = ALONG, Size = seq({{0, 0.5}, {0.2, 1.3}, {1, 0}}), Squash = seq({{0, 3}, {1, 4}}),
	Transparency = seq({{0, 0}, {1, 1}}), Lifetime = NumberRange.new(0.4, 0.8), Speed = NumberRange.new(18, 42), Drag = 3,
	SpreadAngle = Vector2.new(180, 180), Shape = Enum.ParticleEmitterShape.Box, ShapeStyle = VOL,
})
emitter(roar, "Flakes", {
	Texture = T.claw, Color = COOL, Size = seq({{0, 0.6}, {0.4, 1.6}, {1, 0}}), Transparency = seq({{0, 0.1}, {1, 1}}),
	Lifetime = NumberRange.new(0.5, 0.9), Speed = NumberRange.new(8, 20), Drag = 2, Rotation = NumberRange.new(-180, 180),
	RotSpeed = NumberRange.new(-300, 300), SpreadAngle = Vector2.new(180, 180), Shape = Enum.ParticleEmitterShape.Box, ShapeStyle = VOL,
})
emitter(roar, "Embers", {
	Texture = T.dot, Color = cseq({{0, P.core}, {1, P.mint}}), Size = seq({{0, 0}, {0.2, 0.5}, {0.5, 0.25}, {0.7, 0.45}, {1, 0}}),
	Lifetime = NumberRange.new(0.8, 1.4), Speed = NumberRange.new(2, 7), Acceleration = Vector3.new(0, 7, 0), Drag = 1,
	SpreadAngle = Vector2.new(180, 180), Shape = Enum.ParticleEmitterShape.Box, ShapeStyle = VOL,
})
emitter(roar, "Wisps", {
	Texture = T.wisp, Color = COOL, LightEmission = 0.7, Size = seq({{0, 3}, {1, 6.5}}), Transparency = seq({{0, 0.45}, {1, 1}}),
	Lifetime = NumberRange.new(0.6, 1), Speed = NumberRange.new(4, 10), Rotation = NumberRange.new(-180, 180),
	RotSpeed = NumberRange.new(-80, 80), SpreadAngle = Vector2.new(180, 180), Shape = Enum.ParticleEmitterShape.Box, ShapeStyle = VOL,
})
emitter(roar, "Shock", {
	Texture = T.spiky, Color = COOL, Size = seq({{0, 3}, {1, 20}}), Transparency = seq({{0, 0.4}, {1, 1}}),
	Lifetime = NumberRange.new(0.35, 0.35), Speed = NumberRange.new(0, 0), ZOffset = -1, Rotation = NumberRange.new(-180, 180),
})
emitter(roar, "Flare", {
	Texture = T.flare, Color = ColorSequence.new(P.jade), Size = seq({{0, 6}, {1, 10}}), Transparency = seq({{0, 0.55}, {1, 1}}),
	Lifetime = NumberRange.new(0.22, 0.22), Speed = NumberRange.new(0, 0), ZOffset = -2,
})
roar.Parent = fx

local trail = carrier("DashTrail", Vector3.new(1, 1.2, 1))
emitter(trail, "Streaks", {
	Texture = T.spark, Color = HOT, Orientation = ALONG, Size = seq({{0, 0.5}, {0.3, 1.4}, {1, 0}}), Squash = seq({{0, 5}, {1, 6}}),
	Transparency = seq({{0, 0}, {1, 1}}), Lifetime = NumberRange.new(0.2, 0.4), Speed = NumberRange.new(30, 60), Drag = 2,
	SpreadAngle = Vector2.new(8, 8), EmissionDirection = Enum.NormalId.Front, Shape = Enum.ParticleEmitterShape.Box, ShapeStyle = VOL,
})
emitter(trail, "Wind", {
	Texture = T.swoosh, Color = COOL, Size = seq({{0, 1}, {1, 3.5}}), Transparency = seq({{0, 0.1}, {1, 1}}),
	Lifetime = NumberRange.new(0.25, 0.4), Speed = NumberRange.new(10, 20), Rotation = NumberRange.new(-20, 20),
	EmissionDirection = Enum.NormalId.Front, Shape = Enum.ParticleEmitterShape.Box, ShapeStyle = VOL,
})
emitter(trail, "Motes", {
	Texture = T.dot, Color = cseq({{0, P.core}, {1, P.mint}}), Size = seq({{0, 0}, {0.2, 0.45}, {1, 0}}),
	Lifetime = NumberRange.new(0.6, 1.1), Speed = NumberRange.new(2, 6), Acceleration = Vector3.new(0, 3, 0),
	SpreadAngle = Vector2.new(180, 180), Shape = Enum.ParticleEmitterShape.Box, ShapeStyle = VOL,
})
emitter(trail, "Dust", {
	Texture = T.smoke, Color = cseq({{0, P.teal}, {1, P.deep}}), LightEmission = 0.15, Size = seq({{0, 1.5}, {1, 4}}),
	Transparency = seq({{0, 0.55}, {1, 1}}), Lifetime = NumberRange.new(0.5, 0.9), Speed = NumberRange.new(2, 5),
	Rotation = NumberRange.new(-180, 180), SpreadAngle = Vector2.new(60, 60), EmissionDirection = Enum.NormalId.Top,
	Shape = Enum.ParticleEmitterShape.Box, ShapeStyle = VOL,
})
trail.Parent = fx

local wb = carrier("WingBurst", Vector3.new(4, 2, 4))
emitter(wb, "Ring", {
	Texture = T.thinRing, Color = ColorSequence.new(P.mint), Orientation = FLAT, EmissionDirection = Enum.NormalId.Top,
	Size = seq({{0, 2}, {1, 18}}), Transparency = seq({{0, 0}, {1, 1}}), Lifetime = NumberRange.new(0.4, 0.4), Speed = NumberRange.new(0.01, 0.01),
})
emitter(wb, "Feathers", {
	Texture = T.featherA, Color = ColorSequence.new(Color3.new(1, 1, 1)), LightEmission = 0.6, Size = seq({{0, 0.5}, {0.3, 1.1}, {1, 0.6}}),
	Transparency = seq({{0, 0}, {0.7, 0.2}, {1, 1}}), Lifetime = NumberRange.new(0.8, 1.4), Speed = NumberRange.new(10, 26), Drag = 2.2,
	Acceleration = Vector3.new(0, -3, 0), Rotation = NumberRange.new(-180, 180), RotSpeed = NumberRange.new(-240, 240),
	SpreadAngle = Vector2.new(180, 180), Shape = CYL, ShapeStyle = SURF, ShapeInOut = OUT,
})
emitter(wb, "Feathers2", {
	Texture = T.featherB, Color = ColorSequence.new(Color3.new(1, 1, 1)), LightEmission = 0.6, Size = seq({{0, 0.4}, {0.3, 0.9}, {1, 0.5}}),
	Transparency = seq({{0, 0}, {0.7, 0.2}, {1, 1}}), Lifetime = NumberRange.new(0.8, 1.4), Speed = NumberRange.new(8, 22), Drag = 2.2,
	Acceleration = Vector3.new(0, -3, 0), Rotation = NumberRange.new(-180, 180), RotSpeed = NumberRange.new(-240, 240),
	SpreadAngle = Vector2.new(180, 180), Shape = CYL, ShapeStyle = SURF, ShapeInOut = OUT,
})
emitter(wb, "Swoosh", {
	Texture = T.claw, Color = COOL, Size = seq({{0, 0.6}, {0.3, 2.2}, {1, 2.8}}), Transparency = seq({{0, 0.2}, {1, 1}}),
	Lifetime = NumberRange.new(0.25, 0.4), Speed = NumberRange.new(20, 36), Drag = 4, Rotation = NumberRange.new(-180, 180),
	RotSpeed = NumberRange.new(-400, 400), Shape = CYL, ShapeStyle = SURF, ShapeInOut = OUT,
})
emitter(wb, "Sparks", {
	Texture = T.spark, Color = HOT, Orientation = ALONG, Size = seq({{0, 0.4}, {0.2, 1.2}, {1, 0}}), Squash = seq({{0, 3}, {1, 4}}),
	Transparency = seq({{0, 0}, {1, 1}}), Lifetime = NumberRange.new(0.25, 0.5), Speed = NumberRange.new(30, 60), Drag = 3,
	SpreadAngle = Vector2.new(180, 180), Shape = CYL, ShapeStyle = SURF, ShapeInOut = OUT,
})
wb.Parent = fx

local land = carrier("Landing", Vector3.new(4, 0.2, 4))
emitter(land, "Ring", {
	Texture = T.ring, Color = ColorSequence.new(P.mint), Orientation = FLAT, EmissionDirection = Enum.NormalId.Top,
	Size = seq({{0, 2}, {1, 20}}), Transparency = seq({{0, 0}, {1, 1}}), Lifetime = NumberRange.new(0.4, 0.4), Speed = NumberRange.new(0.01, 0.01),
})
emitter(land, "Dust", {
	Texture = T.smoke, Color = cseq({{0, P.teal}, {1, P.deep}}), LightEmission = 0.15, Size = seq({{0, 2}, {1, 6}}),
	Transparency = seq({{0, 0.35}, {1, 1}}), Lifetime = NumberRange.new(0.6, 1.1), Speed = NumberRange.new(14, 26), Drag = 3,
	Rotation = NumberRange.new(-180, 180), Shape = CYL, ShapeStyle = SURF, ShapeInOut = OUT,
})
emitter(land, "Sparks", {
	Texture = T.spark, Color = HOT, Orientation = ALONG, Size = seq({{0, 0.5}, {0.2, 1.4}, {1, 0}}), Squash = seq({{0, 3}, {1, 4}}),
	Transparency = seq({{0, 0}, {1, 1}}), Lifetime = NumberRange.new(0.25, 0.5), Speed = NumberRange.new(30, 60), Drag = 3,
	Acceleration = Vector3.new(0, -30, 0), SpreadAngle = Vector2.new(70, 70), EmissionDirection = Enum.NormalId.Top,
})
emitter(land, "Swoosh", {
	Texture = T.swoosh, Color = COOL, Size = seq({{0, 1}, {1, 3.5}}), Transparency = seq({{0, 0.1}, {1, 1}}),
	Lifetime = NumberRange.new(0.25, 0.4), Speed = NumberRange.new(20, 34), Drag = 3, Rotation = NumberRange.new(-180, 180),
	Shape = CYL, ShapeStyle = SURF, ShapeInOut = OUT,
})
land.Parent = fx

return "built Storm, StormBurst, LionRoar, DashTrail, WingBurst, Landing"
