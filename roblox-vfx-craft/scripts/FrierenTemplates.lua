local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local root = ReplicatedStorage.Frieren
local Config = require(root.Config)
local P = Config.Palette

local TEX = {
	glow = "rbxassetid://12082081459",
	star = "rbxassetid://1084970835",
	spark = "rbxassetid://8037777212",
	specs = "rbxassetid://9997556038",
	shards = "rbxassetid://10439119562",
	rocks = "rbxassetid://12111686783",
	smoke = "rbxassetid://10180479311",
	shock = "rbxassetid://16477162837",
	ring = "rbxassetid://1084982817",
}

local function folder(parent, name)
	local f = parent:FindFirstChild(name) or Instance.new("Folder")
	f.Name = name
	f.Parent = parent
	return f
end

local assets = folder(root, "Assets")
local vfx = folder(assets, "Vfx")
vfx:ClearAllChildren()

local function new(class, parent, props)
	local inst = Instance.new(class)
	for k, v in pairs(props) do
		inst[k] = v
	end
	inst.Parent = parent
	return inst
end

local function seq(points)
	local list = {}
	for _, p in ipairs(points) do
		table.insert(list, NumberSequenceKeypoint.new(p[1], p[2], p[3] or 0))
	end
	return NumberSequence.new(list)
end

local function carrier(name, size)
	return new("Part", vfx, {
		Name = name,
		Anchored = true,
		CanCollide = false,
		CanQuery = false,
		CanTouch = false,
		CastShadow = false,
		Transparency = 1,
		Size = size or Vector3.new(0.2, 0.2, 0.2),
	})
end

local function emitter(parent, name, props)
	local e = new("ParticleEmitter", parent, props)
	e.Name = name
	e.Enabled = true
	e.Rate = 0
	e.LightInfluence = 0
	return e
end

local function beam(parent, name, a0, a1, props)
	local b = new("Beam", parent, props)
	b.Name = name
	b.Attachment0 = a0
	b.Attachment1 = a1
	b.LightInfluence = 0
	return b
end

local function att(parent, name, cf)
	return new("Attachment", parent, {Name = name, CFrame = cf})
end

local function flat(pos, along, width)
	return CFrame.fromMatrix(pos, along, width)
end

local circle = carrier("Circle")

local function ring(host, name, r, n, width, color, fade, z, faceCamera, order, centre)
	local list = {}
	centre = centre or Vector3.zero
	for i = 0, n - 1 do
		local a = 2 * math.pi * i / n
		local radial = Vector3.new(math.cos(a), math.sin(a), 0)
		local along = Vector3.new(-math.sin(a), math.cos(a), 0)
		list[i] = att(host, name .. "A" .. i, flat(centre + radial * r, along, radial))
	end
	local curve = 4 / 3 * math.tan(math.pi / (2 * n)) * r
	for i = 0, n - 1 do
		local b = beam(host, name .. i, list[i], list[(i + 1) % n], {
			Width0 = width,
			Width1 = width,
			CurveSize0 = curve,
			CurveSize1 = curve,
			Segments = 4,
			FaceCamera = faceCamera,
			Color = ColorSequence.new(color),
			Transparency = NumberSequence.new(fade),
			LightEmission = 1,
			ZOffset = z,
			Enabled = false,
		})
		b:SetAttribute("Order", order + 0.5 * i / n)
	end
end

local function spoke(host, name, a, r0, r1, width, color, fade, order)
	local radial = Vector3.new(math.cos(a), math.sin(a), 0)
	local side = Vector3.new(-math.sin(a), math.cos(a), 0)
	local p0 = att(host, name .. "A", flat(radial * r0, radial, side))
	local p1 = att(host, name .. "B", flat(radial * r1, radial, side))
	local b = beam(host, name, p0, p1, {
		Width0 = width,
		Width1 = width,
		Segments = 1,
		FaceCamera = true,
		Color = ColorSequence.new(color),
		Transparency = NumberSequence.new(fade),
		LightEmission = 1,
		ZOffset = 1,
		Enabled = false,
	})
	b:SetAttribute("Order", order)
end

ring(circle, "Outer", 3, 16, 0.1, P.white, 0, 2, true, 0)
ring(circle, "Band", 2.78, 16, 0.44, P.lavender, 0.72, 0, false, 0.1)
ring(circle, "Inner", 2.55, 16, 0.07, P.lilac, 0.05, 2, true, 0.2)
ring(circle, "Mid", 1.35, 12, 0.06, P.white, 0, 2, true, 0.35)
ring(circle, "Core", 0.45, 8, 0.05, P.white, 0, 2, true, 0.5)
for i = 0, 7 do
	spoke(circle, "Spoke" .. i, (i + 0.5) * math.pi / 4, 0.45, 2.55, 0.04, P.lilac, 0.15, 0.4 + i * 0.02)
end
local runes = {0.18, 0.3, 0.12, 0.24, 0.3, 0.1}
for i = 0, 35 do
	spoke(circle, "Rune" .. i, i * math.pi / 18, 2.61, 2.61 + runes[i % #runes + 1], 0.05, P.white, 0.1, 0.3 + 0.4 * i / 36)
end
for k = 0, 7 do
	local a = k * math.pi / 4
	ring(circle, "Knot" .. k .. "_", 0.28, 6, 0.04, P.lilac, 0.1, 1, true, 0.55 + 0.05 * k, Vector3.new(math.cos(a), math.sin(a), 0) * 1.95)
end
emitter(circle, "Flash", {
	Texture = TEX.glow,
	Color = ColorSequence.new(P.white, P.lilac),
	Size = seq({{0, 2}, {0.3, 7}, {1, 0}}),
	Transparency = seq({{0, 0}, {1, 1}}),
	Lifetime = NumberRange.new(0.12),
	Speed = NumberRange.new(0),
	LockedToPart = true,
	LightEmission = 1,
	ZOffset = 3,
})
emitter(circle, "Glint", {
	Texture = TEX.star,
	Color = ColorSequence.new(P.white),
	Size = seq({{0, 0}, {0.2, 3.4}, {1, 0}}),
	Transparency = seq({{0, 0}, {1, 0.4}}),
	Lifetime = NumberRange.new(0.16),
	Speed = NumberRange.new(0),
	LockedToPart = true,
	LightEmission = 1,
	ZOffset = 4,
})
emitter(circle, "Gust", {
	Texture = TEX.spark,
	Color = ColorSequence.new(P.white),
	Size = seq({{0, 0.12}, {1, 0.05}}),
	Squash = seq({{0, 2.5}, {1, 2.5}}),
	Transparency = seq({{0, 0.1}, {1, 1}}),
	Lifetime = NumberRange.new(0.2, 0.3),
	Speed = NumberRange.new(40, 60),
	SpreadAngle = Vector2.new(25, 25),
	EmissionDirection = Enum.NormalId.Back,
	Orientation = Enum.ParticleOrientation.VelocityParallel,
	LightEmission = 1,
})
emitter(circle, "Hoops", {
	Texture = TEX.ring,
	Color = ColorSequence.new(P.white, P.lilac),
	Size = seq({{0, 1.4}, {1, 3.2}}),
	Transparency = seq({{0, 0.2}, {1, 1}}),
	Lifetime = NumberRange.new(0.35),
	Speed = NumberRange.new(8, 20),
	EmissionDirection = Enum.NormalId.Front,
	Orientation = Enum.ParticleOrientation.VelocityPerpendicular,
	LightEmission = 1,
})
emitter(circle, "Specks", {
	Texture = TEX.specs,
	Color = ColorSequence.new(P.white, P.lavender),
	Size = seq({{0, 0.12}, {1, 0}}),
	Lifetime = NumberRange.new(0.4, 0.7),
	Speed = NumberRange.new(2, 5),
	SpreadAngle = Vector2.new(180, 180),
	Drag = 3,
	LightEmission = 1,
})

local ray = carrier("Beam")
local start = att(ray, "Start", CFrame.new())
local finish = att(ray, "Finish", CFrame.new(0, 0, -10))
local fade = seq({{0, 0.6}, {0.03, 0}, {0.94, 0}, {1, 0.7}})
local function layer(name, width, color, t, le, z)
	local b = beam(ray, name, start, finish, {
		Width0 = width,
		Width1 = width,
		Segments = 1,
		FaceCamera = true,
		Color = ColorSequence.new(color),
		Transparency = t,
		LightEmission = le,
		ZOffset = z,
		Enabled = false,
	})
	b:SetAttribute("Width", width)
	return b
end
layer("Edge", 1.9, P.ink, seq({{0, 0.9}, {0.03, 0.35}, {0.94, 0.35}, {1, 1}}), 0, 0)
layer("Fringe", 1.55, P.fringe, seq({{0, 0.9}, {0.03, 0.55}, {0.94, 0.55}, {1, 1}}), 1, 1)
layer("Glow", 1.25, P.lilac, seq({{0, 0.8}, {0.03, 0.25}, {0.94, 0.25}, {1, 0.9}}), 1, 2)
layer("Core", 0.55, P.white, fade, 1, 3)
layer("Line", 0.07, P.white, NumberSequence.new(0), 1, 4)
emitter(ray, "Streaks", {
	Texture = TEX.spark,
	Color = ColorSequence.new(P.white, P.lilac),
	Size = seq({{0, 0.1}, {1, 0.04}}),
	Squash = seq({{0, 2.5}, {1, 2.5}}),
	Transparency = seq({{0, 0.2}, {1, 1}}),
	Lifetime = NumberRange.new(0.12, 0.2),
	Speed = NumberRange.new(120, 180),
	Orientation = Enum.ParticleOrientation.VelocityParallel,
	EmissionDirection = Enum.NormalId.Front,
	LightEmission = 1,
})

local hit = carrier("Hit", Vector3.new(1, 1, 1))
emitter(hit, "Flash", {
	Texture = TEX.glow,
	Color = ColorSequence.new(P.white, P.lilac),
	Size = seq({{0, 3}, {0.25, 8}, {1, 0}}),
	Transparency = seq({{0, 0}, {1, 1}}),
	Lifetime = NumberRange.new(0.1),
	Speed = NumberRange.new(0),
	LightEmission = 1,
	ZOffset = 2,
})
emitter(hit, "Glint", {
	Texture = TEX.star,
	Color = ColorSequence.new(P.white),
	Size = seq({{0, 0}, {0.2, 4.5}, {1, 0}}),
	Lifetime = NumberRange.new(0.18),
	Speed = NumberRange.new(0),
	LightEmission = 1,
	ZOffset = 3,
})
emitter(hit, "Ring", {
	Texture = TEX.shock,
	Color = ColorSequence.new(P.white),
	Size = seq({{0, 0.5}, {1, 9}}),
	Transparency = seq({{0, 0}, {0.6, 0.4}, {1, 1}}),
	Lifetime = NumberRange.new(0.22),
	Speed = NumberRange.new(0),
	LightEmission = 1,
})
emitter(hit, "Sparks", {
	Texture = TEX.spark,
	Color = ColorSequence.new(P.spark, P.white),
	Size = seq({{0, 0.22}, {1, 0.06}}),
	Squash = seq({{0, 2}, {1, 2}}),
	Lifetime = NumberRange.new(0.12, 0.2),
	Speed = NumberRange.new(40, 90),
	SpreadAngle = Vector2.new(180, 180),
	Orientation = Enum.ParticleOrientation.VelocityParallel,
	Drag = 5,
	LightEmission = 1,
})
emitter(hit, "Smoke", {
	Texture = TEX.smoke,
	Color = ColorSequence.new(P.smoke, P.smokeDark),
	Size = seq({{0, 2.5}, {1, 5.5}}),
	Transparency = seq({{0, 0}, {0.7, 0.1}, {1, 1}}),
	Lifetime = NumberRange.new(0.7, 1.1),
	Speed = NumberRange.new(4, 9),
	SpreadAngle = Vector2.new(180, 180),
	Rotation = NumberRange.new(0, 360),
	RotSpeed = NumberRange.new(-30, 30),
	Drag = 4,
	LightEmission = 0,
})
emitter(hit, "Debris", {
	Texture = TEX.rocks,
	Color = ColorSequence.new(P.ink),
	Size = seq({{0, 0.55}, {1, 0.4}}),
	Lifetime = NumberRange.new(0.8, 1.2),
	Speed = NumberRange.new(20, 40),
	SpreadAngle = Vector2.new(70, 70),
	EmissionDirection = Enum.NormalId.Top,
	Acceleration = Vector3.new(0, -60, 0),
	Rotation = NumberRange.new(0, 360),
	RotSpeed = NumberRange.new(-200, 200),
	LightEmission = 0,
})
new("PointLight", hit, {Name = "Light", Color = P.lilac, Brightness = 0, Range = 14, Shadows = false})

local burst = carrier("Burst")
for i = 1, 12 do
	local y = 1 - 2 * (i - 0.5) / 12
	local r = math.sqrt(1 - y * y)
	local a = i * 2.39996
	local dir = Vector3.new(math.cos(a) * r, y, math.sin(a) * r)
	local len = 1.6 + (i % 4) * 0.5
	local b = beam(burst, "Spike" .. i, att(burst, "In" .. i, CFrame.new(dir * 0.3)), att(burst, "Out" .. i, CFrame.new(dir * len)), {
		Width0 = 0.16,
		Width1 = 0,
		Segments = 1,
		FaceCamera = true,
		Color = ColorSequence.new(P.white),
		Transparency = NumberSequence.new(0),
		LightEmission = 1,
		ZOffset = 3,
		Enabled = false,
	})
	b:SetAttribute("Width", 0.16)
end

local small = carrier("SmallCircle")
ring(small, "Outer", 1.1, 12, 0.06, P.white, 0, 2, true, 0)
ring(small, "Inner", 0.85, 12, 0.04, P.lilac, 0.05, 2, true, 0.25)
ring(small, "Core", 0.3, 6, 0.04, P.white, 0, 2, true, 0.5)
for i = 0, 5 do
	spoke(small, "Spoke" .. i, (i + 0.5) * math.pi / 3, 0.3, 0.85, 0.03, P.lilac, 0.15, 0.4 + i * 0.03)
end
for i = 0, 15 do
	spoke(small, "Rune" .. i, i * math.pi / 8, 0.9, 0.9 + runes[i % #runes + 1] * 0.5, 0.035, P.white, 0.1, 0.3 + 0.4 * i / 16)
end
emitter(small, "Flash", {
	Texture = TEX.glow,
	Color = ColorSequence.new(P.white, P.lilac),
	Size = seq({{0, 1}, {0.3, 3}, {1, 0}}),
	Lifetime = NumberRange.new(0.1),
	Speed = NumberRange.new(0),
	LockedToPart = true,
	LightEmission = 1,
	ZOffset = 3,
})
emitter(small, "Glint", {
	Texture = TEX.star,
	Color = ColorSequence.new(P.white),
	Size = seq({{0, 0}, {0.2, 1.6}, {1, 0}}),
	Lifetime = NumberRange.new(0.14),
	Speed = NumberRange.new(0),
	LockedToPart = true,
	LightEmission = 1,
	ZOffset = 4,
})

local bolt = carrier("Bolt")
local head, tail = att(bolt, "Head", CFrame.new()), att(bolt, "Tail", CFrame.new(0, 0, 5))
for _, l in ipairs({{"Shell", 1.1, P.lilac, 0.35, 0}, {"Body", 0.7, P.white, 0, 1}}) do
	local b = beam(bolt, l[1], head, tail, {
		Width0 = l[2],
		Width1 = 0,
		Segments = 1,
		FaceCamera = true,
		Color = ColorSequence.new(l[3]),
		Transparency = seq({{0, l[4]}, {0.7, (1 + l[4]) / 2}, {1, 1}}),
		LightEmission = 1,
		ZOffset = l[5],
	})
	b:SetAttribute("Width", l[2])
end
emitter(bolt, "Glow", {
	Texture = TEX.glow,
	Color = ColorSequence.new(P.white, P.lilac),
	Size = seq({{0, 1.3}, {1, 1}}),
	Transparency = seq({{0, 0.1}, {1, 1}}),
	Lifetime = NumberRange.new(0.08),
	Speed = NumberRange.new(0),
	LockedToPart = true,
	LightEmission = 1,
	ZOffset = 2,
})
emitter(bolt, "Dashes", {
	Texture = TEX.spark,
	Color = ColorSequence.new(P.white),
	Size = seq({{0, 0.08}, {1, 0.03}}),
	Squash = seq({{0, 2.5}, {1, 2.5}}),
	Transparency = seq({{0, 0.2}, {1, 1}}),
	Lifetime = NumberRange.new(0.12, 0.2),
	Speed = NumberRange.new(4, 10),
	SpreadAngle = Vector2.new(30, 30),
	EmissionDirection = Enum.NormalId.Back,
	Orientation = Enum.ParticleOrientation.VelocityParallel,
	LightEmission = 1,
})

local pillars = carrier("Pillars")
local spots = {{0.3, 2.2, 7}, {1.1, 3.1, 5}, {1.9, 1.7, 9}, {2.6, 2.8, 6}, {3.3, 3.4, 8}, {4.0, 2.0, 4.5}, {4.7, 3.0, 7.5}, {5.5, 2.4, 6}, {6.0, 3.6, 5}, {2.2, 1.6, 8.5}}
for i, s in ipairs(spots) do
	local x, z = math.cos(s[1]) * s[2], math.sin(s[1]) * s[2]
	local b = beam(pillars, "Pillar" .. i, att(pillars, "Low" .. i, CFrame.new(x, -3, z)), att(pillars, "High" .. i, CFrame.new(x, -3 + s[3], z)), {
		Width0 = 0.25 + 0.05 * (i % 4),
		Width1 = 0.1,
		Segments = 1,
		FaceCamera = true,
		Color = ColorSequence.new(P.white, P.lilac),
		Transparency = seq({{0, 1}, {0.12, 0.1}, {0.7, 0.3}, {1, 1}}),
		LightEmission = 1,
		Enabled = false,
	})
	b:SetAttribute("Width", b.Width0)
end

local ticks = carrier("Ticks")
for i = 1, 10 do
	local a = i * 2.3
	local r = 1.8 + (i % 3) * 0.5
	local y = -1.5 + (i * 0.73) % 4
	local h = 0.4 + (i % 4) * 0.15
	local b = beam(ticks, "Tick" .. i, att(ticks, "Low" .. i, CFrame.new(math.cos(a) * r, y, math.sin(a) * r)), att(ticks, "High" .. i, CFrame.new(math.cos(a) * r, y + h, math.sin(a) * r)), {
		Width0 = 0.05,
		Width1 = 0.05,
		Segments = 1,
		FaceCamera = true,
		Color = ColorSequence.new(P.edge),
		Transparency = NumberSequence.new(0.1),
		LightEmission = 1,
		Enabled = false,
	})
	b:SetAttribute("Width", 0.05)
end

local updraft = carrier("Updraft", Vector3.new(4, 0.4, 4))
emitter(updraft, "Motes", {
	Texture = TEX.specs,
	Color = ColorSequence.new(P.white, P.lilac),
	Size = seq({{0, 0.1}, {1, 0.04}}),
	Transparency = seq({{0, 1}, {0.2, 0.1}, {1, 1}}),
	Lifetime = NumberRange.new(1.2, 1.8),
	Speed = NumberRange.new(1.5, 3),
	SpreadAngle = Vector2.new(25, 25),
	EmissionDirection = Enum.NormalId.Top,
	Acceleration = Vector3.new(0, 3, 0),
	Drag = 0.5,
	LightEmission = 1,
})
emitter(updraft, "Streaks", {
	Texture = TEX.spark,
	Color = ColorSequence.new(P.white),
	Size = seq({{0, 0.07}, {1, 0.03}}),
	Squash = seq({{0, 2.5}, {1, 2.5}}),
	Transparency = seq({{0, 0.3}, {1, 1}}),
	Lifetime = NumberRange.new(0.25, 0.4),
	Speed = NumberRange.new(8, 14),
	EmissionDirection = Enum.NormalId.Top,
	Orientation = Enum.ParticleOrientation.VelocityParallel,
	LightEmission = 1,
})
emitter(updraft, "Glints", {
	Texture = TEX.star,
	Color = ColorSequence.new(P.white),
	Size = seq({{0, 0}, {0.3, 0.35}, {1, 0}}),
	Lifetime = NumberRange.new(0.25),
	Speed = NumberRange.new(0.5, 1),
	EmissionDirection = Enum.NormalId.Top,
	LightEmission = 1,
})

local cell = carrier("Cell")
local r = Config.Barrier.Cell
local apo = r * math.sqrt(3) / 2
local corners = {}
for i = 0, 5 do
	local a = i * math.pi / 3
	local radial = Vector3.new(math.cos(a), math.sin(a), 0)
	local along = Vector3.new(-math.sin(a), math.cos(a), 0)
	corners[i] = att(cell, "C" .. i, flat(radial * r, along, radial))
end
for i = 0, 5 do
	local e = beam(cell, "Edge" .. i, corners[i], corners[(i + 1) % 6], {
		Width0 = 0.06,
		Width1 = 0.06,
		Segments = 1,
		FaceCamera = true,
		Color = ColorSequence.new(P.edge),
		Transparency = NumberSequence.new(0),
		LightEmission = 1,
		ZOffset = 2,
		Enabled = false,
	})
	e:SetAttribute("Width", 0.06)
	local g = beam(cell, "Rim" .. i, corners[i], corners[(i + 1) % 6], {
		Width0 = 0.22,
		Width1 = 0.22,
		Segments = 1,
		FaceCamera = true,
		Color = ColorSequence.new(P.edge),
		Transparency = NumberSequence.new(0.72),
		LightEmission = 1,
		ZOffset = 1,
		Enabled = false,
	})
	g:SetAttribute("Width", 0.22)
end
local up, down = Vector3.new(0, 1, 0), Vector3.new(0, -1, 0)
local left, right = Vector3.new(-1, 0, 0), Vector3.new(1, 0, 0)
local fillFade = seq({{0, 0.84}, {1, 0.7}})
for _, side in ipairs({{"Up", up, left}, {"Down", down, right}}) do
	local b = beam(cell, "Fill" .. side[1], att(cell, "Mid" .. side[1], flat(Vector3.zero, side[2], side[3])), att(cell, "End" .. side[1], flat(side[2] * apo, side[2], side[3])), {
		Width0 = 2 * r,
		Width1 = r,
		Segments = 1,
		FaceCamera = false,
		Color = ColorSequence.new(P.fill, P.edge),
		Transparency = fillFade,
		LightEmission = 0.5,
		ZOffset = 0,
		Enabled = false,
	})
	b:SetAttribute("Width", 2 * r)
end
emitter(cell, "Flash", {
	Texture = TEX.glow,
	Color = ColorSequence.new(P.white, P.edge),
	Size = seq({{0, 0.6}, {0.3, 2}, {1, 0}}),
	Lifetime = NumberRange.new(0.1),
	Speed = NumberRange.new(0),
	LockedToPart = true,
	LightEmission = 1,
	ZOffset = 3,
})
emitter(cell, "Glint", {
	Texture = TEX.star,
	Color = ColorSequence.new(P.white),
	Size = seq({{0, 0}, {0.25, 1.1}, {1, 0}}),
	Lifetime = NumberRange.new(0.14),
	Speed = NumberRange.new(0),
	LockedToPart = true,
	LightEmission = 1,
	ZOffset = 4,
})
emitter(cell, "Rings", {
	Texture = TEX.ring,
	Color = ColorSequence.new(P.edge),
	Size = seq({{0, 0.3}, {1, 0.12}}),
	Transparency = seq({{0, 0}, {0.6, 0.2}, {1, 1}}),
	Lifetime = NumberRange.new(0.35, 0.55),
	Speed = NumberRange.new(2, 5),
	SpreadAngle = Vector2.new(180, 180),
	Drag = 4,
	LightEmission = 1,
})
emitter(cell, "Shards", {
	Texture = TEX.shards,
	Color = ColorSequence.new(P.edge, P.fill),
	Size = seq({{0, 0.3}, {1, 0.1}}),
	Transparency = seq({{0, 0}, {1, 1}}),
	Lifetime = NumberRange.new(0.3, 0.5),
	Speed = NumberRange.new(3, 7),
	SpreadAngle = Vector2.new(180, 180),
	Rotation = NumberRange.new(0, 360),
	RotSpeed = NumberRange.new(-300, 300),
	Drag = 3,
	LightEmission = 0.8,
})

local cup = carrier("Cup")
emitter(cup, "Core", {
	Texture = TEX.glow,
	Color = ColorSequence.new(P.mint, P.sage),
	Size = seq({{0, 0.9}, {0.5, 1.3}, {1, 0.9}}),
	Transparency = seq({{0, 0.2}, {1, 1}}),
	Lifetime = NumberRange.new(0.25),
	Speed = NumberRange.new(0),
	LockedToPart = true,
	LightEmission = 1,
	ZOffset = 1,
})
emitter(cup, "Glints", {
	Texture = TEX.star,
	Color = ColorSequence.new(P.white),
	Size = seq({{0, 0}, {0.3, 0.5}, {1, 0}}),
	Lifetime = NumberRange.new(0.2, 0.3),
	Speed = NumberRange.new(0.5, 1.5),
	SpreadAngle = Vector2.new(180, 180),
	Rotation = NumberRange.new(0, 90),
	LightEmission = 1,
	ZOffset = 2,
})
emitter(cup, "Lines", {
	Texture = TEX.spark,
	Color = ColorSequence.new(P.mint),
	Size = seq({{0, 0.14}, {1, 0.05}}),
	Squash = seq({{0, 2.5}, {1, 2.5}}),
	Transparency = seq({{0, 0.2}, {1, 1}}),
	Lifetime = NumberRange.new(0.2, 0.3),
	Speed = NumberRange.new(3, 5),
	EmissionDirection = Enum.NormalId.Right,
	SpreadAngle = Vector2.new(0, 180),
	Orientation = Enum.ParticleOrientation.VelocityParallel,
	LightEmission = 1,
})
emitter(cup, "Motes", {
	Texture = TEX.specs,
	Color = ColorSequence.new(P.mint, P.sage),
	Size = seq({{0, 0.09}, {1, 0.03}}),
	Lifetime = NumberRange.new(1, 1.6),
	Speed = NumberRange.new(0.5, 1.5),
	EmissionDirection = Enum.NormalId.Top,
	SpreadAngle = Vector2.new(40, 40),
	Acceleration = Vector3.new(0, 1.5, 0),
	LightEmission = 1,
})
new("PointLight", cup, {Name = "Light", Color = P.mint, Brightness = 0, Range = 8, Shadows = false})

local rise = carrier("Rise")
local low, high = att(rise, "Low", CFrame.new()), att(rise, "High", CFrame.new(0, 60, 0))
for _, l in ipairs({{"Pillar", 0.4, 0.06, 0.05, 1}, {"Halo", 1.6, 0.3, 0.75, 0}}) do
	local b = beam(rise, l[1], low, high, {
		Width0 = l[2],
		Width1 = l[3],
		Segments = 1,
		FaceCamera = true,
		Color = ColorSequence.new(P.white, P.mint),
		Transparency = seq({{0, l[4]}, {0.6, (1 + l[4]) / 2}, {1, 1}}),
		LightEmission = 1,
		ZOffset = l[5],
		Enabled = false,
	})
	b:SetAttribute("Width", l[2])
end
emitter(rise, "Glint", {
	Texture = TEX.star,
	Color = ColorSequence.new(P.white),
	Size = seq({{0, 0}, {0.2, 2.6}, {1, 0}}),
	Lifetime = NumberRange.new(0.25),
	Speed = NumberRange.new(0),
	LightEmission = 1,
	ZOffset = 3,
})

local bloom = carrier("Bloom", Vector3.new(32, 1, 32))
local pop = att(bloom, "Pop", CFrame.new())
emitter(pop, "Specks", {
	Texture = TEX.specs,
	Color = ColorSequence.new(P.petal, P.mint),
	Size = seq({{0, 0.1}, {1, 0.03}}),
	Lifetime = NumberRange.new(0.8, 1.4),
	Speed = NumberRange.new(0.5, 2),
	EmissionDirection = Enum.NormalId.Top,
	SpreadAngle = Vector2.new(50, 50),
	Acceleration = Vector3.new(0, 2, 0),
	LightEmission = 1,
})
emitter(pop, "Glint", {
	Texture = TEX.star,
	Color = ColorSequence.new(P.mint),
	Size = seq({{0, 0}, {0.3, 0.35}, {1, 0}}),
	Lifetime = NumberRange.new(0.2),
	Speed = NumberRange.new(0),
	LightEmission = 1,
})
emitter(bloom, "Drift", {
	Texture = TEX.specs,
	Color = ColorSequence.new(P.petal, P.white),
	Size = seq({{0, 0.08}, {1, 0.05}}),
	Transparency = seq({{0, 1}, {0.2, 0.2}, {1, 1}}),
	Lifetime = NumberRange.new(2, 3),
	Speed = NumberRange.new(0.4, 1.2),
	EmissionDirection = Enum.NormalId.Top,
	SpreadAngle = Vector2.new(60, 60),
	Acceleration = Vector3.new(0.6, 0.4, 0),
	Rotation = NumberRange.new(0, 360),
	RotSpeed = NumberRange.new(-60, 60),
	LightEmission = 0.6,
})

local flower = new("Model", vfx, {Name = "Flower"})
local function piece(name, size, cf, color, sphere)
	local p = new("Part", flower, {
		Name = name,
		Anchored = true,
		CanCollide = false,
		CanQuery = false,
		CanTouch = false,
		CastShadow = false,
		Material = Enum.Material.SmoothPlastic,
		Color = color,
		Size = size,
		CFrame = cf,
	})
	if sphere then
		new("SpecialMesh", p, {MeshType = Enum.MeshType.Sphere})
	end
	return p
end
local stems = {}
for k, b in ipairs({{0, 0, 0.7, 0}, {0.35, 0.2, 0.5, 1.2}, {-0.25, 0.3, 0.6, 2.5}}) do
	local x, z, h, turn = b[1], b[2], b[3], b[4]
	local stem = piece("Stem" .. k, Vector3.new(h, 0.06, 0.06), CFrame.new(x, h / 2, z) * CFrame.Angles(0, 0, math.pi / 2), P.stem)
	stem.Shape = Enum.PartType.Cylinder
	stems[k] = stem
	for i = 0, 4 do
		local a = turn + i * 2 * math.pi / 5
		piece("Petal" .. k .. i, Vector3.new(0.28, 0.05, 0.22), CFrame.new(x, h + 0.02, z) * CFrame.Angles(0, a, 0) * CFrame.new(0.12, 0, 0) * CFrame.Angles(0, 0, math.rad(20)), P.petal, true)
	end
	piece("Heart" .. k, Vector3.new(0.1, 0.1, 0.1), CFrame.new(x, h + 0.04, z), P.heart, true)
end
flower.PrimaryPart = stems[1]
flower.WorldPivot = CFrame.new()

local petal = new("Part", vfx, {
	Name = "Petal",
	Anchored = true,
	CanCollide = false,
	CanQuery = false,
	CanTouch = false,
	CastShadow = false,
	Material = Enum.Material.SmoothPlastic,
	Color = P.drift,
	Size = Vector3.new(0.34, 0.03, 0.22),
})
new("SpecialMesh", petal, {MeshType = Enum.MeshType.Sphere})

local gui = StarterGui:FindFirstChild("FrierenFlash")
if gui then
	gui:Destroy()
end
gui = new("ScreenGui", StarterGui, {Name = "FrierenFlash", IgnoreGuiInset = true, DisplayOrder = 70, ResetOnSpawn = false})
new("Frame", gui, {Name = "White", Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1, BorderSizePixel = 0})

return #vfx:GetDescendants() .. " instances in Frieren.Assets.Vfx"
