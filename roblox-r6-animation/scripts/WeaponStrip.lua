local T = game.ServerStorage.AstaTest.Modules
local Poser = require(T.Poser)
local Clips = require(T.AstaClips)
local Rig = require(T.AstaRig)
local RIG = workspace.Preview.R6
local BOOK = game.ReplicatedStorage.Asta.Assets.Grimoire

local V3 = Vector3.new
local FACE = {front = 0, side = -math.pi / 2, rear = math.pi, rear34 = math.pi * 0.75, front34 = -math.pi / 4, side34 = -math.pi * 0.3}

local function readRig(model)
	local motors = {}
	for _, m in ipairs(model:GetDescendants()) do
		if m:IsA("Motor6D") and m.Part0 and m.Part1 then
			table.insert(motors, {p0 = m.Part0.Name, p1 = m.Part1.Name, c0 = m.C0, c1 = m.C1, r = m.C0.Rotation})
		end
	end
	local order, placed = {}, {HumanoidRootPart = true}
	while #order < #motors do
		local grew = false
		for _, m in ipairs(motors) do
			if placed[m.p0] and not placed[m.p1] then
				table.insert(order, m)
				placed[m.p1] = true
				grew = true
			end
		end
		if not grew then
			break
		end
	end
	return order
end

local function fk(order, rootCF, poses)
	local world = {HumanoidRootPart = rootCF}
	for _, m in ipairs(order) do
		local p = poses[m.p1] or CFrame.identity
		world[m.p1] = world[m.p0] * m.c0 * (m.r:Inverse() * p * m.r) * m.c1:Inverse()
	end
	return world
end

local PAINT = {
	Head = Color3.fromRGB(235, 220, 190), Torso = Color3.fromRGB(70, 110, 200),
	["Right Arm"] = Color3.fromRGB(235, 150, 110), ["Left Arm"] = Color3.fromRGB(215, 215, 225),
	["Right Leg"] = Color3.fromRGB(200, 120, 90), ["Left Leg"] = Color3.fromRGB(170, 175, 190),
}

local function anchorAll(m)
	for _, d in ipairs(m:GetDescendants()) do
		if d:IsA("BasePart") then
			d.Anchored = true
			d.CanCollide = false
		end
	end
end

local function ghost(parent, name, plain)
	local was = RIG.Archivable
	RIG.Archivable = true
	local g = RIG:Clone()
	RIG.Archivable = was
	g.Name = name
	for _, d in ipairs(g:GetDescendants()) do
		if d:IsA("LuaSourceContainer") then
			d:Destroy()
		elseif plain and (d:IsA("Clothing") or d:IsA("Accessory")) then
			d:Destroy()
		elseif d:IsA("BasePart") and plain and PAINT[d.Name] then
			d.Color = PAINT[d.Name]
			d.Material = Enum.Material.SmoothPlastic
		end
	end
	anchorAll(g)
	g.Parent = parent
	return g
end

-- the blade part stretched along its length so it ends k of the way out
local function setBlade(handle, blade, k, s)
	s = s or 1
	local base = blade:GetAttribute("BaseSize") or blade.Size
	local len = math.max(0.05, base.Y * k * s)
	blade.Size = V3(base.X * s, len, base.Z * s)
	blade.CFrame = handle.CFrame * CFrame.new(-0.003 * s, -0.84 * s - len / 2, 0)
	blade.Transparency = k < 0.02 and 1 or 0
end

local function placeBook(parent, cf, cover)
	local b = BOOK:Clone()
	anchorAll(b)
	local root = b.Grimoire
	root.CFrame = cf * CFrame.new(0, -0.135 * 0.62, 0)
	for _, m in ipairs(b:GetDescendants()) do
		if m:IsA("Motor6D") and m.Part0 == root then
			local rot = m.Name == "GrimoireHinge" and CFrame.Angles(math.rad(cover or 0), 0, 0) or CFrame.identity
			m.Part1.CFrame = root.CFrame * m.C0 * rot * m.C1:Inverse()
		end
	end
	for _, m in ipairs(b:GetDescendants()) do
		if m:IsA("Motor6D") and m.Part0 ~= root then
			m.Part1.CFrame = m.Part0.CFrame * m.C0 * m.C1:Inverse()
		end
	end
	b.Parent = parent
	return b
end

local function propSword(parent, cf, k, scale)
	local s = game.ReplicatedStorage.Asta.Assets.DemonSlayer:Clone()
	anchorAll(s)
	scale = scale or 1
	s.Sword.Size = s.Sword.Size * scale
	s.Sword.CFrame = cf
	s.Sword.Transparency = 0
	setBlade(s.Sword, s.Blade, k, scale)
	s.Parent = parent
	return s
end

function _G.clearStrip()
	local old = workspace:FindFirstChild("AstaStrip")
	if old then
		old:Destroy()
	end
end

local function dot(parent, pos, color, size)
	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = false
	p.Shape = Enum.PartType.Ball
	p.Size = V3(size, size, size)
	p.Material = Enum.Material.Neon
	p.Color = color
	p.CFrame = CFrame.new(pos)
	p.Parent = parent
end

-- one ghost per time along +x; opts: spacing, origin, facing, plain, ctx, path = {t0, t1} tip dots on each ghost,
-- release (sheathe) to run the toss prop; returns camera and look-at points for screen_capture
function _G.astaStrip(clip, times, opts)
	opts = opts or {}
	_G.clearStrip()
	local folder = Instance.new("Folder")
	folder.Name = "AstaStrip"
	folder.Parent = workspace
	local order = readRig(RIG)
	local spacing = opts.spacing or 6
	local origin = opts.origin or CFrame.new(600, 3, 600)
	local facing = FACE[opts.facing or "front"] or 0
	local props = clip.props
	local releaseCF
	if props and props.release then
		local w = fk(order, CFrame.identity, Poser.posesAt(clip, props.release, opts.ctx))
		releaseCF = w.Sword
	end
	for i, t in ipairs(times) do
		local rootCF = origin * CFrame.new(spacing * (i - 1), 0, 0) * CFrame.Angles(0, facing, 0)
		local g = ghost(folder, ("Ghost%02d"):format(i), opts.plain ~= false)
		local poses = Poser.posesAt(clip, t, opts.ctx)
		local world = fk(order, rootCF, poses)
		for name, cf in pairs(world) do
			local part = g:FindFirstChild(name, true)
			if part and part:IsA("BasePart") then
				part.CFrame = cf
			end
		end
		local handle, blade = g:FindFirstChild("Sword", true), g:FindFirstChild("Blade", true)
		local k, show = opts.blade or 1, opts.sword ~= false
		if props then
			local mode, bookCF = Clips.P.book(props, t)
			local cover = Clips.P.cover(props, t)
			bookCF = bookCF or (Clips.FLOAT or CFrame.new(-2.2, 1.35, 0.7))
			placeBook(g, rootCF * bookCF, cover)
			local rootHandle = rootCF:ToObjectSpace(handle.CFrame)
			local st
			if props.grab then
				st = Clips.P.draw(props, t, rootHandle, bookCF)
			elseif props.release then
				st = Clips.P.toss(props, t, releaseCF, bookCF)
			end
			if st then
				show = st.hand
				k = st.blade or 1
				if st.prop then
					propSword(g, rootCF * st.prop, st.propBlade or 1, st.propScale)
				end
			end
		end
		if handle then
			handle.Transparency = show and 0 or 1
			setBlade(handle, blade, show and k or 0)
		end
		if opts.path then
			local t0, t1 = opts.path[1], math.min(t, opts.path[2])
			local s = t0
			while s <= t1 + 1e-6 do
				local w = fk(order, rootCF, Poser.posesAt(clip, s, opts.ctx))
				local u = (s - t0) / math.max(1e-3, opts.path[2] - t0)
				dot(g, w.Sword * V3(0, Rig.TIP_Y, 0), Color3.new(u, 1 - u, 0.2), 0.22)
				dot(g, w.Sword * V3(0, Rig.GRIP_Y, 0), Color3.new(0.3, 0.5, 1), 0.14)
				s += 1 / 60
			end
		end
	end
	local floor = Instance.new("Part")
	floor.Anchored = true
	floor.Size = V3(spacing * #times + 14, 1, 20)
	floor.CFrame = origin * CFrame.new(spacing * (#times - 1) / 2, -3.5, 0)
	floor.Color = Color3.fromRGB(90, 96, 110)
	floor.Material = Enum.Material.SmoothPlastic
	floor.Parent = folder
	local mid = origin * CFrame.new(spacing * (#times - 1) / 2, 0.5, 0)
	for _, off in ipairs({CFrame.new(0, 9, -8), CFrame.new(0, 6, 8)}) do
		local lp = Instance.new("Part")
		lp.Anchored = true
		lp.CanCollide = false
		lp.Transparency = 1
		lp.Size = Vector3.one
		lp.CFrame = mid * off
		lp.Parent = folder
		local l = Instance.new("PointLight")
		l.Brightness = 2.5
		l.Range = spacing * #times + 20
		l.Shadows = false
		l.Parent = lp
	end
	local cam = mid * CFrame.new(0, 2, -(spacing * #times * 0.55 + 5))
	return {cam.Position.X, cam.Position.Y, cam.Position.Z}, {mid.Position.X, mid.Position.Y + 0.8, mid.Position.Z}
end

-- one body at each of the given times (the last solid, the rest ghosted) and a faded sword every step between t0 and
-- t1, all on one root, so a swing reads as a smear the way the eye sees it
function _G.astaOnion(clip, bodies, t0, t1, opts)
	opts = opts or {}
	_G.clearStrip()
	local folder = Instance.new("Folder")
	folder.Name = "AstaStrip"
	folder.Parent = workspace
	local order = readRig(RIG)
	local rootCF = (opts.origin or CFrame.new(600, 3, 600)) * CFrame.Angles(0, FACE[opts.facing or "front"] or 0, 0)
	for i, t in ipairs(bodies) do
		local g = ghost(folder, ("Body%02d"):format(i), true)
		local world = fk(order, rootCF, Poser.posesAt(clip, t, opts.ctx))
		for name, cf in pairs(world) do
			local part = g:FindFirstChild(name, true)
			if part and part:IsA("BasePart") then
				part.CFrame = cf
				if i < #bodies then
					part.Transparency = math.max(part.Transparency, 0.72)
				end
			end
		end
		local h = g:FindFirstChild("Sword", true)
		if h then
			setBlade(h, g:FindFirstChild("Blade", true), opts.blade or 1)
		end
	end
	local s = t0
	local n = 0
	while s <= t1 + 1e-6 do
		local world = fk(order, rootCF, Poser.posesAt(clip, s, opts.ctx))
		local sw = game.ReplicatedStorage.Asta.Assets.DemonSlayer:Clone()
		anchorAll(sw)
		sw.Sword.CFrame = world.Sword
		setBlade(sw.Sword, sw.Blade, opts.blade or 1)
		local u = (s - t0) / math.max(1e-3, t1 - t0)
		for _, p in ipairs({sw.Sword, sw.Blade}) do
			p.Transparency = 0.55 + 0.35 * (1 - u)
			p.Color = Color3.new(1 - u, 0.2, u)
			for _, d in ipairs(p:GetChildren()) do
				if d:IsA("SurfaceAppearance") then
					d:Destroy()
				end
			end
		end
		sw.Parent = folder
		n += 1
		s += opts.step or 1 / 60
	end
	local floor = Instance.new("Part")
	floor.Anchored = true
	floor.Size = V3(30, 1, 30)
	floor.CFrame = rootCF * CFrame.new(0, -3.5, 0)
	floor.Color = Color3.fromRGB(90, 96, 110)
	floor.Parent = folder
	local lp = Instance.new("Part")
	lp.Anchored = true
	lp.Transparency = 1
	lp.CanCollide = false
	lp.CFrame = rootCF * CFrame.new(0, 9, 4)
	lp.Parent = folder
	local l = Instance.new("PointLight")
	l.Range = 30
	l.Brightness = 2
	l.Parent = lp
	-- the player's view: behind and above the right shoulder, and a front three quarter view
	local rear = rootCF * CFrame.new(3, 6.5, 11)
	local front = rootCF * CFrame.new(-6, 4.5, -10)
	local top = rootCF * CFrame.new(0, 16, -1)
	local look = rootCF * V3(0, 0.5, -2.5)
	local function v(c)
		return {c.X, c.Y, c.Z}
	end
	return {rear = v(rear.Position), front = v(front.Position), top = v(top.Position), look = v(look), swords = n}
end

local function soles(cf, size)
	local h = size / 2
	return {cf * V3(h.X, -h.Y, h.Z), cf * V3(-h.X, -h.Y, h.Z), cf * V3(h.X, -h.Y, -h.Z), cf * V3(-h.X, -h.Y, -h.Z)}
end

-- lowest sole corner, planted slide and hip gap per leg, plus the lowest blade tip (under -3 cuts the floor)
function _G.astaFeet(clip, opts)
	opts = opts or {}
	local order = readRig(RIG)
	local out, anchor, tipLow = {}, {}, math.huge
	for _, leg in ipairs({"Right Leg", "Left Leg"}) do
		out[leg] = {low = math.huge, high = -math.huge, slide = 0, gap = 0}
	end
	Poser.each(clip, 60, function(t, poses)
		local world = fk(order, CFrame.identity, poses)
		if world.Sword then
			tipLow = math.min(tipLow, (world.Sword * V3(0, Rig.TIP_Y, 0)).Y)
		end
		for leg, r in pairs(out) do
			local cf = world[leg]
			local lowest
			for _, c in ipairs(soles(cf, RIG[leg].Size)) do
				if not lowest or c.Y < lowest.Y then
					lowest = c
				end
			end
			local h = lowest.Y + 3
			r.low, r.high = math.min(r.low, h), math.max(r.high, h)
			local sole = cf * V3(0, -1, 0)
			if h < 0.06 then
				anchor[leg] = anchor[leg] or sole
				r.slide = math.max(r.slide, V3(sole.X - anchor[leg].X, 0, sole.Z - anchor[leg].Z).Magnitude)
			else
				anchor[leg] = nil
			end
			local s = leg == "Right Leg" and 1 or -1
			local c = world.Torso:PointToObjectSpace((cf * CFrame.new(0.5 * s, 1, 0)).Position)
			r.gap = math.max(r.gap, math.max(0, -1 - c.Y) + math.sqrt((c.X - s) ^ 2 + c.Z ^ 2))
		end
	end, opts)
	local lines = {}
	for leg, r in pairs(out) do
		table.insert(lines, ("%s low %.2f..%.2f slide %.2f gap %.2f"):format(leg, r.low, r.high, r.slide, r.gap))
	end
	table.sort(lines)
	table.insert(lines, ("tip low %.2f"):format(tipLow + 3))
	return table.concat(lines, "; ")
end

-- the body joints only, so the metrics compare with the pro clips
function _G.astaCheck(clip, opts)
	local body = {}
	for k, v in pairs(clip) do
		body[k] = v
	end
	body.joints = {}
	for _, n in ipairs({"Torso", "Head", "Right Arm", "Left Arm", "Right Leg", "Left Leg"}) do
		body.joints[n] = clip.joints[n]
	end
	body.compiled = nil
	return Poser.check(body, opts).text
end

return "astaStrip ready"
