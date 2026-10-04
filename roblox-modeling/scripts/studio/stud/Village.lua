local V = {}

local C = {
	grass = Color3.fromRGB(30, 108, 50),
	dirt = Color3.fromRGB(134, 94, 66),
	path = Color3.fromRGB(110, 80, 60),
	step = Color3.fromRGB(120, 82, 60),
	stone = Color3.fromRGB(86, 94, 118),
	stoneLight = Color3.fromRGB(108, 116, 138),
	diamond = Color3.fromRGB(104, 116, 152),
	plaster = Color3.fromRGB(226, 214, 186),
	timber = Color3.fromRGB(86, 58, 42),
	timberDark = Color3.fromRGB(64, 44, 32),
	roof = Color3.fromRGB(140, 102, 84),
	trunk = Color3.fromRGB(92, 72, 58),
	leaf = Color3.fromRGB(40, 130, 56),
	red = Color3.fromRGB(226, 64, 60),
	white = Color3.fromRGB(236, 240, 244),
	glow = Color3.fromRGB(255, 214, 84),
	glass = Color3.fromRGB(44, 52, 70),
	water = Color3.fromRGB(64, 204, 236),
	wheat = Color3.fromRGB(232, 200, 112),
	gold = Color3.fromRGB(240, 196, 70),
}
V.C = C

local rng = Random.new(11)
V.rng = rng

local faces = { "Top", "Bottom", "Front", "Back", "Left", "Right" }

function V.tint(c, amt)
	local h, s, v = c:ToHSV()
	return Color3.fromHSV(h, s, math.clamp(v * (1 + rng:NextNumber(-amt, amt)), 0, 1))
end

function V.model(parent, name)
	local m = Instance.new("Model")
	m.Name = name
	m.Parent = parent
	if at then m.WorldPivot = at end
	return m
end

function V.part(parent, name, cf, size, color, kind)
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.CFrame = cf
	p.Size = size
	p.Color = color
	for _, f in faces do
		p[f .. "Surface"] = Enum.SurfaceType.Smooth
	end
	if kind == "studs" then
		p.Material = Enum.Material.Plastic
		p.MaterialVariant = "Studs"
	elseif kind == "inlet" then
		p.Material = Enum.Material.Plastic
		for _, f in faces do
			p[f .. "Surface"] = Enum.SurfaceType.Inlet
		end
	elseif kind == "diamond" then
		p.Material = Enum.Material.DiamondPlate
	elseif kind == "neon" then
		p.Material = Enum.Material.Neon
	elseif kind == "smooth" then
		p.Material = Enum.Material.SmoothPlastic
	else
		p.Material = Enum.Material.Plastic
	end
	p.Parent = parent
	return p
end

local part = V.part
local tint = V.tint

function V.light(p, range, brightness, color)
	local l = Instance.new("PointLight")
	l.Range = range
	l.Brightness = brightness
	l.Color = color or C.glow
	l.Shadows = false
	l.Parent = p
	return l
end

function V.stairs(parent, at, width, steps, rise, run)
	local m = V.model(parent, "Stairs")
	for i = 1, steps do
		local h = rise * i
		part(m, "Step", at * CFrame.new(0, h / 2, -(i - 0.5) * run), Vector3.new(width + 4, h, run), tint(C.step, 0.05), "studs")
	end
	for _, side in { -1, 1 } do
		for i = 1, steps do
			local h = rise * i
			part(m, "Rail", at * CFrame.new(side * (width / 2 + 1), h + 1, -(i - 0.5) * run), Vector3.new(2, 2, run), tint(C.stone, 0.06), "inlet")
		end
	end
	if at then m.WorldPivot = at end
	return m
end

function V.mushroom(parent, at, s)
	local m = V.model(parent, "Mushroom")
	part(m, "Stem", at * CFrame.new(0, 1.4 * s, 0), Vector3.new(1.4, 2.8, 1.4) * s, C.white, "studs")
	part(m, "Cap", at * CFrame.new(0, 3.6 * s, 0), Vector3.new(3.8, 1.8, 3.8) * s, C.red, "studs")
	part(m, "CapTop", at * CFrame.new(0, 4.8 * s, 0), Vector3.new(2.6, 0.7, 2.6) * s, C.red, "studs")
	local spots = { { 1.95, 3.8, 0.7, 0.3, 0.8, 0.8 }, { -1.95, 3.4, -0.6, 0.3, 0.7, 0.7 }, { 0.5, 3.9, 1.95, 0.8, 0.8, 0.3 }, { -0.8, 3.5, -1.95, 0.7, 0.7, 0.3 }, { 0.3, 5.2, -0.4, 0.8, 0.3, 0.8 } }
	for _, o in spots do
		part(m, "Spot", at * CFrame.new(o[1] * s, o[2] * s, o[3] * s), Vector3.new(o[4], o[5], o[6]) * s, C.white, "smooth")
	end
	if at then m.WorldPivot = at end
	return m
end

function V.lampPost(parent, at)
	local m = V.model(parent, "LampPost")
	part(m, "Base", at * CFrame.new(0, 0.5, 0), Vector3.new(2, 1, 2), tint(C.stone, 0.05), "inlet")
	part(m, "Post", at * CFrame.new(0, 4.5, 0), Vector3.new(1.2, 7, 1.2), tint(C.stoneLight, 0.05), "inlet")
	part(m, "Arm", at * CFrame.new(0.9, 8.4, 0), Vector3.new(3, 0.8, 1), tint(C.stoneLight, 0.05), "inlet")
	part(m, "Hook", at * CFrame.new(2, 7.7, 0), Vector3.new(0.4, 0.6, 0.4), C.timberDark)
	local bulb = part(m, "Light", at * CFrame.new(2, 6.8, 0), Vector3.new(1.2, 1.2, 1.2), C.glow, "neon")
	V.light(bulb, 16, 1.4)
	if at then m.WorldPivot = at end
	return m
end

function V.fence(parent, a, b, y)
	local m = V.model(parent, "Fence")
	local dir = (b - a)
	local len = dir.Magnitude
	local n = math.max(1, math.floor(len / 4 + 0.5))
	local flat = Vector3.new(dir.X, 0, dir.Z).Unit
	for i = 0, n do
		local p = a + dir * (i / n)
		local cf = CFrame.lookAt(Vector3.new(p.X, y + 1.5, p.Z), Vector3.new(p.X, y + 1.5, p.Z) + flat) * CFrame.Angles(0, 0, math.rad(rng:NextNumber(-2, 2)))
		part(m, "Post", cf, Vector3.new(0.8, 3, 0.8), tint(C.timber, 0.08), "studs")
	end
	local mid = (a + b) / 2
	for _, h in { 1.1, 2.3 } do
		local cf = CFrame.lookAt(Vector3.new(mid.X, y + h, mid.Z), Vector3.new(mid.X, y + h, mid.Z) + flat)
		part(m, "Rail", cf, Vector3.new(0.4, 0.5, len), tint(C.timber, 0.06), "studs")
	end
	if at then m.WorldPivot = at end
	return m
end

function V.cubeTree(parent, at, s)
	local m = V.model(parent, "CubeTree")
	local trunkH = 9 * s
	part(m, "Trunk", at * CFrame.new(0, trunkH / 2, 0), Vector3.new(2.6, trunkH, 2.6) * Vector3.new(s, 1, s), tint(C.trunk, 0.05), "inlet")
	part(m, "Root", at * CFrame.new(0, 0.5, 0), Vector3.new(4, 1, 4) * s, tint(C.trunk, 0.05), "inlet")
	local base = trunkH
	local layers = { { 8, 1 }, { 11, 1 }, { 13, 1.2 } }
	local y = base
	for _, l in layers do
		part(m, "Leaf", at * CFrame.new(0, y + l[2] / 2, 0), Vector3.new(l[1], l[2], l[1]) * Vector3.new(s, 1, s), tint(C.leaf, 0.04), "studs")
		y += l[2]
	end
	local crown = 9 * s
	part(m, "Crown", at * CFrame.new(0, y + crown / 2, 0), Vector3.new(14, crown, 14) * Vector3.new(s, 1, s), tint(C.leaf, 0.04), "studs")
	for _, o in { { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do
		local w = rng:NextNumber(5, 9) * s
		part(m, "Bump", at * CFrame.new(o[1] * 7.4 * s, y + crown * rng:NextNumber(0.35, 0.65), o[2] * 7.4 * s), Vector3.new(o[1] ~= 0 and 1 or w, rng:NextNumber(3, 5) * s, o[2] ~= 0 and 1 or w), tint(C.leaf, 0.05), "studs")
	end
	part(m, "CrownTop", at * CFrame.new(rng:NextNumber(-1, 1) * s, y + crown + 0.6, rng:NextNumber(-1, 1) * s), Vector3.new(9 * s, 1.2, 9 * s), tint(C.leaf, 0.04), "studs")
	if at then m.WorldPivot = at end
	return m
end

local function frameBox(m, cf, w, h, color, kind, t)
	part(m, "FrameTop", cf * CFrame.new(0, h / 2 - t / 2, 0), Vector3.new(w, t, t), color, kind)
	part(m, "FrameBottom", cf * CFrame.new(0, -h / 2 + t / 2, 0), Vector3.new(w, t, t), color, kind)
	part(m, "FrameLeft", cf * CFrame.new(-w / 2 + t / 2, 0, 0), Vector3.new(t, h, t), color, kind)
	part(m, "FrameRight", cf * CFrame.new(w / 2 - t / 2, 0, 0), Vector3.new(t, h, t), color, kind)
end

local function window(m, cf, w, h, lit)
	part(m, "Glass", cf * CFrame.new(0, 0, 0.1), Vector3.new(w - 0.4, h - 0.4, 0.2), lit and C.glow or C.glass, lit and "neon" or "smooth")
	frameBox(m, cf * CFrame.new(0, 0, -0.15), w, h, C.timberDark, nil, 0.4)
	part(m, "Cross", cf * CFrame.new(0, 0, -0.15), Vector3.new(0.3, h - 0.4, 0.3), C.timberDark)
	part(m, "Sill", cf * CFrame.new(0, -h / 2 - 0.2, -0.3), Vector3.new(w + 0.6, 0.4, 0.8), C.timber, "studs")
end

local function brace(m, cf, w, h, color)
	local len = math.sqrt(w * w + h * h)
	local a = math.atan2(h, w)
	part(m, "Brace", cf * CFrame.Angles(0, 0, a), Vector3.new(len, 0.5, 0.4), color)
end

local function wallFaces(w, d)
	return {
		{ CFrame.new(0, 0, -d / 2), w },
		{ CFrame.new(0, 0, d / 2) * CFrame.Angles(0, math.pi, 0), w },
		{ CFrame.new(-w / 2, 0, 0) * CFrame.Angles(0, math.pi / 2, 0), d },
		{ CFrame.new(w / 2, 0, 0) * CFrame.Angles(0, -math.pi / 2, 0), d },
	}
end

function V.house(parent, at, w, d, opts)
	opts = opts or {}
	local m = V.model(parent, opts.name or "TimberHouse")
	local h1, h2 = 8, 7
	part(m, "Plinth", at * CFrame.new(0, 0.5, 0), Vector3.new(w + 1, 1, d + 1), tint(C.stone, 0.04), "inlet")
	for i, f in wallFaces(w, d) do
		local cf = at * f[1] * CFrame.new(0, 1 + h1 / 2, 0)
		local len = f[2]
		part(m, "Wall", cf * CFrame.new(0, 0, 0.5), Vector3.new(len, h1, 1), tint(C.diamond, 0.03), "diamond")
		if i == 1 then
			part(m, "Door", cf * CFrame.new(0, -h1 / 2 + 3.3, -0.1), Vector3.new(4, 6.6, 0.4), tint(C.timber, 0.05), "studs")
			frameBox(m, cf * CFrame.new(0, -h1 / 2 + 3.5, -0.25), 5, 7, C.timberDark, nil, 0.5)
			part(m, "Knob", cf * CFrame.new(1.2, -h1 / 2 + 3.3, -0.45), Vector3.new(0.4, 0.4, 0.3), C.gold, "smooth")
			for _, sx in { -1, 1 } do
				if len >= 14 then
					window(m, cf * CFrame.new(sx * len * 0.32, 0.6, -0.1), 2.6, 2.8, false)
				end
				local lamp = part(m, "WallLamp", cf * CFrame.new(sx * 2.95, 1.4, -0.5), Vector3.new(0.8, 1, 0.8), C.glow, "neon")
				V.light(lamp, 12, 1.2)
			end
		else
			window(m, cf * CFrame.new(0, 0.6, -0.1), 2.6, 2.8, false)
		end
	end
	for _, c in { { -1, -1 }, { 1, -1 }, { -1, 1 }, { 1, 1 } } do
		part(m, "Corner", at * CFrame.new(c[1] * w / 2, 1 + h1 / 2, c[2] * d / 2), Vector3.new(1.4, h1, 1.4), tint(C.timber, 0.05), "studs")
	end
	local y2 = 1 + h1
	part(m, "Floor", at * CFrame.new(0, y2 + 0.5, 0), Vector3.new(w + 2.4, 1, d + 2.4), tint(C.timberDark, 0.04), "studs")
	local wu, du = w + 2, d + 2
	for i, f in wallFaces(wu, du) do
		local cf = at * f[1] * CFrame.new(0, y2 + 1 + h2 / 2, 0)
		local len = f[2]
		part(m, "Plaster", cf * CFrame.new(0, 0, 0.5), Vector3.new(len, h2, 1), tint(C.plaster, 0.02), "smooth")
		part(m, "BeamLow", cf * CFrame.new(0, -h2 / 2 + 0.3, -0.15), Vector3.new(len, 0.6, 0.5), C.timber, "studs")
		part(m, "BeamHigh", cf * CFrame.new(0, h2 / 2 - 0.3, -0.15), Vector3.new(len, 0.6, 0.5), C.timber, "studs")
		local bays = math.max(2, math.floor(len / 6))
		for b = 1, bays - 1 do
			part(m, "Stud", cf * CFrame.new(-len / 2 + b * len / bays, 0, -0.15), Vector3.new(0.5, h2, 0.5), C.timber)
		end
		for b = 1, bays do
			local bx = -len / 2 + (b - 0.5) * len / bays
			if b == 1 or b == bays then
				brace(m, cf * CFrame.new(bx, 0, -0.2), len / bays - 0.6, h2 - 1.2, C.timber)
			else
				window(m, cf * CFrame.new(bx, 0.2, -0.1), 2.4, 2.6, i == 1 and opts.litTop)
			end
		end
	end
	for _, c in { { -1, -1 }, { 1, -1 }, { -1, 1 }, { 1, 1 } } do
		part(m, "CornerTop", at * CFrame.new(c[1] * wu / 2, y2 + 1 + h2 / 2, c[2] * du / 2), Vector3.new(0.9, h2, 0.9), C.timber, "studs")
	end
	local y3 = y2 + 1 + h2
	local layers = math.floor((wu + 4) / 2 / 1.4)
	for k = 0, layers - 1 do
		local lw = wu + 4 - k * 2.8
		if lw < 1.4 then
			break
		end
		if lw <= 6.4 then
			part(m, "Roof", at * CFrame.new(0, y3 + k + 0.5, 0), Vector3.new(lw, 1, du + 3), tint(C.roof, 0.04), "studs")
		else
			for _, sx in { -1, 1 } do
				part(m, "Roof", at * CFrame.new(sx * (lw / 2 - 1.6), y3 + k + 0.5, 0), Vector3.new(3.2, 1, du + 3), tint(C.roof, 0.04), "studs")
			end
			for _, sz in { -1, 1 } do
				part(m, "Gable", at * CFrame.new(0, y3 + k + 0.5, sz * (du / 2 - 0.5)), Vector3.new(lw - 6.2, 1, 1), tint(C.plaster, 0.02), "smooth")
			end
		end
	end
	for _, sz in { -1, 1 } do
		part(m, "GableBeam", at * CFrame.new(0, y3 + 2, sz * (du / 2 - 0.05)), Vector3.new(0.5, 4, 0.4), C.timber)
	end
	part(m, "Ridge", at * CFrame.new(0, y3 + layers + 0.2, 0), Vector3.new(1, 0.6, du + 3.4), C.timberDark, "studs")
	if opts.chimney then
		part(m, "Chimney", at * CFrame.new(wu * 0.25, y3 + layers * 0.7, du * 0.15), Vector3.new(2, layers * 1.2, 2), tint(C.stone, 0.05), "inlet")
	end
	if at then m.WorldPivot = at end
	return m
end

function V.tower(parent, at, s, opts)
	opts = opts or {}
	local m = V.model(parent, opts.name or "TimberTower")
	local h0, h1, h2 = opts.h0 or 10, opts.h1 or 8, 7
	part(m, "Plinth", at * CFrame.new(0, 0.6, 0), Vector3.new(s + 1.6, 1.2, s + 1.6), tint(C.stone, 0.04), "inlet")
	for i, f in wallFaces(s, s) do
		local cf = at * f[1] * CFrame.new(0, 1.2 + h0 / 2, 0)
		part(m, "Wall", cf * CFrame.new(0, 0, 0.5), Vector3.new(s, h0, 1), tint(C.diamond, 0.03), "diamond")
		if i == 1 then
			part(m, "Door", cf * CFrame.new(0, -h0 / 2 + 3.3, -0.1), Vector3.new(4, 6.6, 0.4), tint(C.timber, 0.05), "studs")
			frameBox(m, cf * CFrame.new(0, -h0 / 2 + 3.5, -0.25), 5, 7, C.timberDark, nil, 0.5)
			for _, sx in { -1, 1 } do
				local lamp = part(m, "WallLamp", cf * CFrame.new(sx * 3.2, -h0 / 2 + 4.6, -0.5), Vector3.new(0.7, 0.9, 0.7), C.glow, "neon")
				V.light(lamp, 12, 1.2)
			end
		else
			window(m, cf * CFrame.new(0, 1, -0.1), 2.2, 2.6, false)
		end
	end
	for _, c in { { -1, -1 }, { 1, -1 }, { -1, 1 }, { 1, 1 } } do
		part(m, "Corner", at * CFrame.new(c[1] * s / 2, 1.2 + h0 / 2, c[2] * s / 2), Vector3.new(1.6, h0, 1.6), tint(C.stoneLight, 0.05), "inlet")
	end
	local y1 = 1.2 + h0
	part(m, "Ledge", at * CFrame.new(0, y1 + 0.5, 0), Vector3.new(s + 2, 1, s + 2), tint(C.stoneLight, 0.04), "inlet")
	part(m, "Band", at * CFrame.new(0, y1 + 1.3, 0), Vector3.new(s + 2.4, 0.6, s + 2.4), C.timber, "studs")
	local n = math.floor((s + 2) / 2.4)
	for _, f in wallFaces(s + 2, s + 2) do
		for k = 0, n - 1 do
			if k % 2 == 0 then
				local x = -(s + 2) / 2 + (k + 0.5) * (s + 2) / n
				part(m, "Merlon", at * f[1] * CFrame.new(x, y1 + 2.2, 0.4), Vector3.new((s + 2) / n, 1.2, 0.8), tint(C.timber, 0.05), "studs")
			end
		end
	end
	local y2 = y1 + 1.6
	local s1 = s - 1
	for _, f in wallFaces(s1, s1) do
		local cf = at * f[1] * CFrame.new(0, y2 + h1 / 2, 0)
		part(m, "Wall", cf * CFrame.new(0, 0, 0.5), Vector3.new(s1, h1, 1), tint(C.diamond, 0.03), "diamond")
		part(m, "Beam", cf * CFrame.new(0, -h1 / 2 + 0.3, -0.15), Vector3.new(s1, 0.6, 0.5), C.timber, "studs")
		part(m, "Beam", cf * CFrame.new(0, 0.6, -0.15), Vector3.new(s1, 0.5, 0.5), C.timber)
		brace(m, cf * CFrame.new(-s1 / 4, -h1 / 4 + 0.3, -0.2), s1 / 2 - 0.4, h1 / 2 - 0.4, C.timber)
		brace(m, cf * CFrame.new(s1 / 4, -h1 / 4 + 0.3, -0.2) * CFrame.Angles(0, math.pi, 0), s1 / 2 - 0.4, h1 / 2 - 0.4, C.timber)
		window(m, cf * CFrame.new(0, 2.4, -0.1), 2.4, 2.2, false)
	end
	for _, c in { { -1, -1 }, { 1, -1 }, { -1, 1 }, { 1, 1 } } do
		part(m, "CornerMid", at * CFrame.new(c[1] * s1 / 2, y2 + h1 / 2, c[2] * s1 / 2), Vector3.new(1, h1, 1), C.timber, "studs")
	end
	local y3 = y2 + h1
	local s2 = s + 1
	part(m, "Floor", at * CFrame.new(0, y3 + 0.4, 0), Vector3.new(s2 + 1, 0.8, s2 + 1), C.timberDark, "studs")
	local bulb = part(m, "Lantern", at * CFrame.new(0, y3 + 0.8 + h2 * 0.5, 0), Vector3.new(1, 1, 1), C.glow, "neon")
	V.light(bulb, 22, 1.6, Color3.fromRGB(255, 190, 90))
	for _, f in wallFaces(s2, s2) do
		local cf = at * f[1] * CFrame.new(0, y3 + 0.8 + h2 / 2, 0)
		part(m, "Inner", cf * CFrame.new(0, 0, 2.4), Vector3.new(s2 - 2, h2 - 0.4, 0.4), Color3.fromRGB(58, 44, 38))
		part(m, "Glim", cf * CFrame.new(0, h2 / 2 - 2.4, 1.8), Vector3.new(0.8, 0.8, 0.8), C.glow, "neon")
		part(m, "Lintel", cf * CFrame.new(0, h2 / 2 - 0.8, 0.4), Vector3.new(s2, 1.6, 1), tint(C.plaster, 0.02), "smooth")
		part(m, "SillWall", cf * CFrame.new(0, -h2 / 2 + 0.7, 0.4), Vector3.new(s2, 1.4, 1), tint(C.plaster, 0.02), "smooth")
		for _, sx in { -1, 1 } do
			part(m, "Jamb", cf * CFrame.new(sx * (s2 / 2 - 0.9), 0, 0.4), Vector3.new(1.8, h2, 1), tint(C.plaster, 0.02), "smooth")
			part(m, "Corbel", cf * CFrame.new(sx * (s2 / 2 - 2.4), h2 / 2 - 2, 0.3), Vector3.new(1.2, 1.2, 0.8), tint(C.plaster, 0.02), "smooth")
		end
		part(m, "Trim", cf * CFrame.new(0, h2 / 2 - 0.2, -0.15), Vector3.new(s2 + 0.2, 0.4, 0.4), C.timber)
		part(m, "Trim", cf * CFrame.new(0, -h2 / 2 + 1.5, -0.15), Vector3.new(s2 + 0.2, 0.4, 0.4), C.timber)
	end
	local y4 = y3 + 0.8 + h2
	part(m, "Eave", at * CFrame.new(0, y4 + 0.3, 0), Vector3.new(s2 + 4, 0.6, s2 + 4), C.timberDark, "studs")
	local k = 0
	local lw = s2 + 3
	while lw > 1 do
		part(m, "Roof", at * CFrame.new(0, y4 + 0.6 + k * 1.1 + 0.55, 0), Vector3.new(lw, 1.1, lw), tint(C.roof, 0.04), "studs")
		lw -= 2
		k += 1
	end
	local top = y4 + 0.6 + k * 1.1
	part(m, "Spire", at * CFrame.new(0, top + 1.5, 0), Vector3.new(0.6, 3, 0.6), C.timberDark)
	part(m, "Tip", at * CFrame.new(0, top + 3.2, 0), Vector3.new(0.7, 0.7, 0.7), C.gold, "neon")
	if at then m.WorldPivot = at end
	return m
end

function V.roundTower(parent, at, r, h, opts)
	opts = opts or {}
	local m = V.model(parent, opts.name or "StoneTower")
	local n = opts.segments or 20
	local chord = 2 * r * math.tan(math.pi / n) + 0.35
	local function ring(name, radius, y, height, depth, color, kind, every)
		for i = 0, n - 1 do
			if not every or i % every == 0 then
				local a = (i + 0.5) / n * math.pi * 2
				local cf = at * CFrame.Angles(0, -a, 0) * CFrame.new(0, y + height / 2, -radius + depth / 2)
				part(m, name, cf, Vector3.new(2 * radius * math.tan(math.pi / n) + 0.35, height, depth), V.tint(color, 0.05), kind)
			end
		end
	end
	local core = Instance.new("Part")
	core.Name = "Core"
	core.Anchored = true
	core.Shape = Enum.PartType.Cylinder
	core.Size = Vector3.new(h, (r - 1.5) * 2, (r - 1.5) * 2)
	core.CFrame = at * CFrame.new(0, h / 2, 0) * CFrame.Angles(0, 0, math.pi / 2)
	core.Color = Color3.fromRGB(60, 66, 84)
	core.Material = Enum.Material.Plastic
	core.Parent = m
	ring("Plinth", r + 0.8, 0, 1.6, 2.6, C.stoneLight, "inlet")
	ring("Wall", r, 1.6, h - 1.6, 2, C.stone, "inlet")
	ring("Band", r + 0.7, h * 0.62, 1.2, 2.4, C.timber, "studs")
	ring("BandStep", r + 1.1, h * 0.62 + 1.2, 0.8, 1.6, C.timber, "studs", 2)
	ring("Ledge", r + 0.8, h, 1.4, 2.6, C.stoneLight, "inlet")
	ring("Band", r + 1, h + 1.4, 0.8, 2.4, C.timber, "studs")
	ring("Merlon", r + 1, h + 2.2, 1.8, 1.6, C.stoneLight, "inlet", 2)
	local roof = Instance.new("Part")
	roof.Name = "Roof"
	roof.Anchored = true
	roof.Shape = Enum.PartType.Cylinder
	roof.Size = Vector3.new(1, r * 2, r * 2)
	roof.CFrame = at * CFrame.new(0, h + 0.9, 0) * CFrame.Angles(0, 0, math.pi / 2)
	roof.Color = C.stone
	roof.Parent = m
	local face = opts.face or 0
	local function onWall(a, y, w, hh, outward)
		return at * CFrame.Angles(0, -a, 0) * CFrame.new(0, y, -(r + (outward or 0)))
	end
	part(m, "Door", onWall(face, 3.6, 0, 0, 0.1), Vector3.new(4.2, 6.6, 0.6), V.tint(C.timber, 0.05), "studs")
	frameBox(m, onWall(face, 3.8, 0, 0, 0.3), 5.4, 7.2, C.stoneLight, "inlet", 0.7)
	for _, w in opts.windows or { { face + 0.9, h * 0.4 }, { face - 0.9, h * 0.4 }, { face + 0.35, h * 0.8 }, { face - 1.6, h * 0.8 } } do
		local cf = onWall(w[1], w[2], 0, 0, 0.15)
		local g = part(m, "Window", cf, Vector3.new(2.6, 1.8, 0.4), C.glow, "neon")
		V.light(g, 14, 1.2, Color3.fromRGB(255, 170, 70))
		frameBox(m, onWall(w[1], w[2], 0, 0, 0.4), 3.6, 2.8, C.stoneLight, "inlet", 0.5)
	end
	if at then m.WorldPivot = at end
	return m
end

function V.pond(parent, center, w, d)
	local m = V.model(parent, "Pond")
	local water = part(m, "Water", CFrame.new(center + Vector3.new(0, 0.15, 0)), Vector3.new(w, 0.3, d), C.water, "smooth")
	water.Transparency = 0.1
	water.CanCollide = false
	part(m, "Bed", CFrame.new(center + Vector3.new(0, 0.02, 0)), Vector3.new(w, 0.04, d), Color3.fromRGB(36, 120, 150), "smooth")
	local x, z = w / 2 + 1, d / 2 + 1
	local edges = {}
	for i = -x, x, 2 do
		table.insert(edges, Vector3.new(i, 0, -z))
		table.insert(edges, Vector3.new(i, 0, z))
	end
	for i = -z + 2, z - 2, 2 do
		table.insert(edges, Vector3.new(-x, 0, i))
		table.insert(edges, Vector3.new(x, 0, i))
	end
	for _, e in edges do
		local hgt = rng:NextNumber(0.8, 1.6)
		part(m, "Rim", CFrame.new(center + e + Vector3.new(0, hgt / 2, 0)) * CFrame.Angles(0, math.rad(rng:NextNumber(-6, 6)), 0), Vector3.new(2, hgt, 2), V.tint(C.stone, 0.08), "inlet")
	end
	if at then m.WorldPivot = at end
	return m
end

function V.wheat(parent, center, w, d)
	local m = V.model(parent, "Wheat")
	for x = -w / 2 + 1, w / 2 - 1, 1.6 do
		for z = -d / 2 + 1, d / 2 - 1, 1.6 do
			local hgt = rng:NextNumber(2.4, 3.6)
			local p = center + Vector3.new(x + rng:NextNumber(-0.3, 0.3), hgt / 2, z + rng:NextNumber(-0.3, 0.3))
			part(m, "Stalk", CFrame.new(p) * CFrame.Angles(math.rad(rng:NextNumber(-5, 5)), 0, math.rad(rng:NextNumber(-5, 5))), Vector3.new(0.5, hgt, 0.5), V.tint(C.wheat, 0.08), "studs")
		end
	end
	if at then m.WorldPivot = at end
	return m
end

function V.disk(parent, name, center, r, color, kind, stepw, thick)
	local m = V.model(parent, name)
	stepw = stepw or 4
	thick = thick or 0.4
	local x = -r
	while x < r do
		local cx = x + stepw / 2
		local half = math.floor(math.sqrt(math.max(0, r * r - cx * cx)) / 2 + 0.5) * 2
		if half > 0 then
			part(m, "Strip", CFrame.new(center + Vector3.new(cx, thick / 2, 0)), Vector3.new(stepw, thick, half * 2), color, kind)
		end
		x += stepw
	end
	if at then m.WorldPivot = at end
	return m
end

function V.block(parent, name, x0, x1, z0, z1, y0, y1, color, kind)
	return part(parent, name, CFrame.new((x0 + x1) / 2, (y0 + y1) / 2, (z0 + z1) / 2), Vector3.new(x1 - x0, y1 - y0, z1 - z0), color, kind)
end

function V.bush(parent, at, s)
	local m = V.model(parent, "Bush")
	part(m, "Leaf", at * CFrame.new(0, 1.2 * s, 0), Vector3.new(3.4, 2.4, 3) * s, tint(C.leaf, 0.06), "studs")
	part(m, "Leaf", at * CFrame.new(1.4 * s, 0.9 * s, 0.9 * s), Vector3.new(2.4, 1.8, 2.4) * s, tint(C.leaf, 0.06), "studs")
	part(m, "Leaf", at * CFrame.new(-1.3 * s, 0.8 * s, -0.8 * s), Vector3.new(2, 1.6, 2.2) * s, tint(C.leaf, 0.06), "studs")
	if at then m.WorldPivot = at end
	return m
end

local petals = { Color3.fromRGB(236, 84, 110), Color3.fromRGB(250, 214, 80), Color3.fromRGB(150, 110, 230), Color3.fromRGB(245, 245, 245), Color3.fromRGB(90, 160, 240) }

function V.flowers(parent, center, r, count)
	local m = V.model(parent, "Flowers")
	local color = petals[rng:NextInteger(1, #petals)]
	for i = 1, count do
		local a = rng:NextNumber(0, math.pi * 2)
		local d = rng:NextNumber(0, r)
		local p = center + Vector3.new(math.cos(a) * d, 0, math.sin(a) * d)
		local h = rng:NextNumber(0.8, 1.4)
		part(m, "Stem", CFrame.new(p + Vector3.new(0, h / 2, 0)), Vector3.new(0.3, h, 0.3), C.leaf)
		local f = part(m, "Petal", CFrame.new(p + Vector3.new(0, h + 0.25, 0)) * CFrame.Angles(0, rng:NextNumber(0, 1.5), 0), Vector3.new(0.9, 0.5, 0.9), rng:NextNumber() < 0.75 and color or petals[rng:NextInteger(1, #petals)], "studs")
		f.CanCollide = false
	end
	if at then m.WorldPivot = at end
	return m
end

function V.bench(parent, at)
	local m = V.model(parent, "Bench")
	part(m, "Seat", at * CFrame.new(0, 1.6, 0), Vector3.new(6, 0.5, 2), tint(C.timber, 0.05), "studs")
	part(m, "Back", at * CFrame.new(0, 2.9, 0.85), Vector3.new(6, 2, 0.4), tint(C.timber, 0.05), "studs")
	for _, x in { -2.4, 2.4 } do
		part(m, "Leg", at * CFrame.new(x, 0.7, 0), Vector3.new(0.6, 1.4, 1.8), tint(C.stone, 0.05), "inlet")
	end
	if at then m.WorldPivot = at end
	return m
end

V.frameBox = frameBox
V.window = window
V.brace = brace
V.wallFaces = wallFaces

return V
