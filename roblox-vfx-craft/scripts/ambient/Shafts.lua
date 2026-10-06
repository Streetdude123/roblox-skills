local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local shafts = {}

local RANGE = 230
local CELL = 34
local MAX = 18
local FADE = 1.6
local BUDGET = 0.0015

local tpl = script.Parent.Fx.Shaft
local cam = workspace.CurrentCamera

local rp = RaycastParams.new()
rp.FilterType = Enum.RaycastFilterType.Include
rp.FilterDescendantsInstances = { workspace.Terrain }

local crowns = {}
local cache = {}
local live = {}
local pool = {}
local seqs = {}

for _, b in tpl:GetChildren() do
	if b:IsA("Beam") then
		seqs[b.Name] = { b.Transparency.Keypoints, b.Width0, b.Width1 }
	end
end

local function forget(x, z)
	local cx, cz = math.floor(x / CELL), math.floor(z / CELL)
	for i = cx - 4, cx + 4 do
		for j = cz - 4, cz + 4 do
			cache[i * 4096 + j] = nil
		end
	end
end

local function add(p)
	if p.Name:sub(-6) ~= "Leaves" then
		return
	end
	local pos, s = p.Position, p.Size
	local k = math.floor(pos.X / 128) * 1000 + math.floor(pos.Z / 128)
	crowns[k] = crowns[k] or {}
	crowns[k][p] = { pos.X, pos.Z, pos.Y + s.Y * 0.5, pos.Y - s.Y * 0.05, ((s.X + s.Z) * 0.21) ^ 2 }
	forget(pos.X, pos.Z)
end

local function remove(p)
	local pos = p.Position
	local list = crowns[math.floor(pos.X / 128) * 1000 + math.floor(pos.Z / 128)]
	if list and list[p] then
		list[p] = nil
		forget(pos.X, pos.Z)
	end
end

local function shade(x, y, z)
	local gx, gz = math.floor(x / 128), math.floor(z / 128)
	for i = gx - 1, gx + 1 do
		for j = gz - 1, gz + 1 do
			local list = crowns[i * 1000 + j]
			if list then
				for _, c in list do
					if y < c[3] and y > c[4] then
						local dx, dz = x - c[1], z - c[2]
						if dx * dx + dz * dz < c[5] then
							return true
						end
					end
				end
			end
		end
	end
	return false
end

local function lit(g, sun)
	for h = 30, 150, 30 do
		local p = g + sun * (h / sun.Y)
		if shade(p.X, p.Y, p.Z) then
			return false
		end
	end
	return true
end

local function rand(a, b, s)
	local n = math.sin(a * 127.1 + b * 311.7 + s * 74.7) * 43758.5453
	return n - math.floor(n)
end

local function solve(cx, cz, sun)
	local x = (cx + 0.2 + rand(cx, cz, 1) * 0.6) * CELL
	local z = (cz + 0.2 + rand(cx, cz, 2) * 0.6) * CELL
	local hit = workspace:Raycast(Vector3.new(x, 700, z), Vector3.new(0, -900, 0), rp)
	if not hit or hit.Material == Enum.Material.Water then
		return false
	end
	local g = hit.Position
	if not lit(g, sun) then
		return false
	end
	local dark = 0
	for i = 0, 5 do
		local a = i * math.pi / 3
		if not lit(g + Vector3.new(math.cos(a) * 30, 0, math.sin(a) * 30), sun) then
			dark += 1
		end
	end
	if dark < 4 then
		return false
	end
	local open = 0
	for i = 0, 3 do
		local a = i * math.pi / 2 + 0.4
		if lit(g + Vector3.new(math.cos(a) * 11, 0, math.sin(a) * 11), sun) then
			open += 1
		end
	end
	local top, n = 0, 0
	local gx, gz = math.floor(g.X / 128), math.floor(g.Z / 128)
	for i = gx - 1, gx + 1 do
		for j = gz - 1, gz + 1 do
			local list = crowns[i * 1000 + j]
			if list then
				for _, c in list do
					local dx, dz = g.X - c[1], g.Z - c[2]
					if dx * dx + dz * dz < 8000 then
						top += (c[3] + c[4]) * 0.5
						n += 1
					end
				end
			end
		end
	end
	return { g, open, n > 0 and math.max(top / n - g.Y, 40) or 120 }
end

local function tint(s, a)
	s.a = a
	for _, b in s.beams do
		local kp = {}
		for i, k in seqs[b.Name][1] do
			kp[i] = NumberSequenceKeypoint.new(k.Time, 1 - (1 - k.Value) * a)
		end
		b.Transparency = NumberSequence.new(kp)
	end
end

local function spawnShaft(spot, sun)
	local s = table.remove(pool)
	if not s then
		local part = tpl:Clone()
		local beams = {}
		for _, b in part:GetChildren() do
			if b:IsA("Beam") then
				table.insert(beams, b)
			end
		end
		s = { part = part, top = part.Top, beams = beams, a = 0 }
	end
	local w = 0.7 + spot[2] * 0.15
	s.part.CFrame = CFrame.new(spot[1])
	s.top.Position = sun * (spot[3] / sun.Y)
	for _, b in s.beams do
		local d = seqs[b.Name]
		b.Width0 = d[2] * w
		b.Width1 = d[3] * w
	end
	tint(s, 0)
	s.part.Parent = cam
	return s
end

function shafts.start(trees)
	for _, p in trees:GetChildren() do
		add(p)
	end
	trees.ChildAdded:Connect(add)
	trees.ChildRemoved:Connect(remove)

	local sun = Lighting:GetSunDirection()
	Lighting:GetPropertyChangedSignal("ClockTime"):Connect(function()
		sun = Lighting:GetSunDirection()
		table.clear(cache)
	end)

	local queue, qi = {}, 1
	local wanted = {}
	local acc = 1

	RunService.Heartbeat:Connect(function(dt)
		local t0 = os.clock()
		while qi <= #queue and os.clock() - t0 < BUDGET do
			local c = queue[qi]
			qi += 1
			local k = c[1] * 4096 + c[2]
			if cache[k] == nil then
				cache[k] = solve(c[1], c[2], sun)
			end
		end

		acc += dt
		if acc > 0.5 then
			acc = 0
			local pos = cam.CFrame.Position
			local cx0, cz0 = math.floor(pos.X / CELL), math.floor(pos.Z / CELL)
			local n = math.ceil(RANGE / CELL)
			local spots = {}
			table.clear(queue)
			qi = 1
			for i = cx0 - n, cx0 + n do
				for j = cz0 - n, cz0 + n do
					local d = ((i + 0.5) * CELL - pos.X) ^ 2 + ((j + 0.5) * CELL - pos.Z) ^ 2
					if d < RANGE * RANGE then
						local k = i * 4096 + j
						local r = cache[k]
						if r == nil then
							table.insert(queue, { i, j, d })
						elseif r then
							table.insert(spots, { k, d, r })
						end
					end
				end
			end
			table.sort(queue, function(a, b)
				return a[3] < b[3]
			end)
			table.sort(spots, function(a, b)
				return a[2] < b[2]
			end)
			table.clear(wanted)
			for i = 1, math.min(MAX, #spots) do
				local sp = spots[i]
				wanted[sp[1]] = true
				if not live[sp[1]] then
					live[sp[1]] = spawnShaft(sp[3], sun)
				end
			end
		end

		for k, s in live do
			local goal = wanted[k] and 1 or 0
			if s.a ~= goal then
				local a = s.a + math.clamp(goal - s.a, -dt / FADE, dt / FADE)
				tint(s, a)
				if a <= 0 then
					s.part.Parent = nil
					live[k] = nil
					table.insert(pool, s)
				end
			end
		end
	end)
end

return shafts
