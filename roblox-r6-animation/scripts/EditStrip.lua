-- run in the Edit datamodel through execute_luau: poses anchored copies of an r6 rig by forward kinematics
-- (Part1 = Part0 * C0 * Transform * C1:Inverse()), so a pose strip renders and a foot contact can be measured without
-- Play mode (Motor6D transforms do not solve in Edit). Point POSER at the Poser module and RIG at a stock r6 model.
-- _G.editStrip(clip, times, opts) lays one ghost per time along +X and returns the camera position and look-at point
-- for screen_capture; opts: spacing (4), origin (a CFrame far from the map), facing ("front", "side", "rear", "rear34",
-- "front34"), ctx, plain (false keeps the rig's own colours and clothes; the default paints a mannequin that reads
-- at night: blue torso, pale limbs, the right arm and right leg warm so sides read in a mirror view). _G.feet(clip, opts) returns the lowest sole corner, the planted slide and the hip gap of each leg.
-- _G.clearStrip() removes the ghosts. Cloning needs Archivable; the rig's value is restored after the copy.
local POSER = game.ServerStorage:FindFirstChild("PoserTest") and game.ServerStorage.PoserTest.Modules.Poser
	or game.ReplicatedStorage:FindFirstChild("Anim", true):FindFirstChild("Poser", true)
local RIG = workspace:FindFirstChild("R6", true)
local Poser = require(POSER)

local FACE = {front = 0, side = -math.pi / 2, rear = math.pi, rear34 = math.pi * 0.75, front34 = -math.pi / 4}

-- the motor tree of the rig, root first, read once from the template
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

-- world cframes of every part for one set of pose-space cframes
local function fk(order, rootCF, poses)
	local world = {HumanoidRootPart = rootCF}
	for _, m in ipairs(order) do
		local pose = poses[m.p1] or CFrame.identity
		local transform = m.r:Inverse() * pose * m.r
		world[m.p1] = world[m.p0] * m.c0 * transform * m.c1:Inverse()
	end
	return world
end

local PAINT = {
	Head = Color3.fromRGB(235, 220, 190),
	Torso = Color3.fromRGB(70, 110, 200),
	["Right Arm"] = Color3.fromRGB(235, 150, 110),
	["Left Arm"] = Color3.fromRGB(215, 215, 225),
	["Right Leg"] = Color3.fromRGB(200, 120, 90),
	["Left Leg"] = Color3.fromRGB(170, 175, 190),
}

local function ghost(parent, name, plain)
	local was = RIG.Archivable
	RIG.Archivable = true
	local g = RIG:Clone()
	RIG.Archivable = was
	g.Name = name
	for _, d in ipairs(g:GetDescendants()) do
		if d:IsA("Motor6D") or d:IsA("LuaSourceContainer") or d:IsA("AnimationController") then
			d:Destroy()
		elseif plain and (d:IsA("Clothing") or d:IsA("ShirtGraphic") or d:IsA("Accessory")) then
			d:Destroy()
		elseif d:IsA("BasePart") then
			d.Anchored = true
			d.CanCollide = false
			if plain and PAINT[d.Name] then
				d.Color = PAINT[d.Name]
				d.Material = Enum.Material.SmoothPlastic
			end
		end
	end
	g.Parent = parent
	return g
end

function _G.clearStrip()
	local old = workspace:FindFirstChild("EditStrip")
	if old then
		old:Destroy()
	end
end

function _G.editStrip(clip, times, opts)
	opts = opts or {}
	_G.clearStrip()
	local folder = Instance.new("Folder")
	folder.Name = "EditStrip"
	folder.Parent = workspace
	local order = readRig(RIG)
	local spacing = opts.spacing or 4
	local origin = opts.origin or CFrame.new(600, 3, 600)
	local facing = FACE[opts.facing or "front"] or 0
	for i, t in ipairs(times) do
		local rootCF = origin * CFrame.new(spacing * (i - 1), 0, 0) * CFrame.Angles(0, facing, 0)
		local g = ghost(folder, ("Ghost%02d"):format(i), opts.plain ~= false)
		local world = fk(order, rootCF, Poser.posesAt(clip, t, opts.ctx))
		for name, cf in pairs(world) do
			local part = g:FindFirstChild(name)
			if part then
				part.CFrame = cf
			end
		end
	end
	-- a floor under the ghosts so a sunk or floating foot shows
	local floor = Instance.new("Part")
	floor.Anchored = true
	floor.Size = Vector3.new(spacing * #times + 8, 1, 12)
	floor.CFrame = origin * CFrame.new(spacing * (#times - 1) / 2, -3.5, 0)
	floor.Color = Color3.fromRGB(90, 96, 110)
	floor.Material = Enum.Material.SmoothPlastic
	floor.Parent = folder
	-- light the strip from the camera side and above so a night sky does not hide the poses
	local mid = origin * CFrame.new(spacing * (#times - 1) / 2, 0.5, 0)
	for _, off in ipairs({CFrame.new(0, 7, -6), CFrame.new(0, 5, 6)}) do
		local lp = Instance.new("Part")
		lp.Anchored = true
		lp.CanCollide = false
		lp.Transparency = 1
		lp.Size = Vector3.one
		lp.CFrame = mid * off
		lp.Parent = folder
		local l = Instance.new("PointLight")
		l.Brightness = 3
		l.Range = spacing * #times + 16
		l.Shadows = false
		l.Parent = lp
	end
	local cam = mid * CFrame.new(0, 1.2, -(spacing * #times * 0.5 + 3))
	return {cam.Position.X, cam.Position.Y, cam.Position.Z}, {mid.Position.X, mid.Position.Y, mid.Position.Z}
end

-- the four bottom corners of a 1 x 2 x 1 leg in world space
local function soles(cf, size)
	local h = size / 2
	return {
		cf * Vector3.new(h.X, -h.Y, h.Z),
		cf * Vector3.new(-h.X, -h.Y, h.Z),
		cf * Vector3.new(h.X, -h.Y, -h.Z),
		cf * Vector3.new(-h.X, -h.Y, -h.Z),
	}
end

-- for each leg: the lowest corner's height over the rest floor through the clip (below 0 sinks, above 0 floats), the
-- largest horizontal slide of the sole centre while the foot is planted (lowest corner within 0.06 of the floor; a
-- pivot on the ball turns the foot without sliding its centre) and the worst hip gap (the leg's pivot corner below or
-- beside the torso's hip corner)
function _G.feet(clip, opts)
	opts = opts or {}
	local order = readRig(RIG)
	local rootCF = CFrame.new(0, 3, 0)
	local floorY = 0
	local out = {}
	for _, leg in ipairs({"Right Leg", "Left Leg"}) do
		out[leg] = {low = math.huge, high = -math.huge, slide = 0, gap = 0}
	end
	local anchor = {}
	Poser.each(clip, 60, function(t, poses)
		local world = fk(order, rootCF, poses)
		for leg, r in pairs(out) do
			local cf = world[leg]
			if cf then
				local lowest
				for _, c in ipairs(soles(cf, RIG[leg].Size)) do
					if not lowest or c.Y < lowest.Y then
						lowest = c
					end
				end
				local h = lowest.Y - floorY
				r.low, r.high = math.min(r.low, h), math.max(r.high, h)
				local sole = cf * Vector3.new(0, -RIG[leg].Size.Y / 2, 0)
				if h < 0.06 then
					anchor[leg] = anchor[leg] or sole
					local d = Vector3.new(sole.X - anchor[leg].X, 0, sole.Z - anchor[leg].Z).Magnitude
					r.slide = math.max(r.slide, d)
				else
					anchor[leg] = nil
				end
				local s = leg == "Right Leg" and 1 or -1
				local c = world.Torso:PointToObjectSpace((cf * CFrame.new(0.5 * s, 1, 0)).Position)
				r.gap = math.max(r.gap, math.max(0, -1 - c.Y) + math.sqrt((c.X - s) ^ 2 + c.Z ^ 2))
			end
		end
	end, opts)
	local lines = {}
	for leg, r in pairs(out) do
		table.insert(lines, ("%s lowest corner %.2f..%.2f slide %.2f hip gap %.2f"):format(leg, r.low, r.high, r.slide, r.gap))
	end
	table.sort(lines)
	return table.concat(lines, "; ")
end

return "editStrip ready"
