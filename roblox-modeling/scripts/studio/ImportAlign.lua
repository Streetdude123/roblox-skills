local root, centers, sizes = ...

local parts = {}
for _, d in root:GetDescendants() do
	if d:IsA("MeshPart") then
		parts[d.Name] = d
	end
end

local maps = {
	front = function(v) return Vector3.new(-v.X, v.Z, v.Y) end,
	back = function(v) return Vector3.new(v.X, v.Z, -v.Y) end,
}

local best, bestErr, bestBase
for name, map in maps do
	local sum, n = Vector3.zero, 0
	local offs = {}
	for key, c in centers do
		local p = parts[key]
		if p then
			local o = p.Position - map(c)
			table.insert(offs, o)
			sum += o
			n += 1
		end
	end
	local mean = sum / math.max(n, 1)
	local err = 0
	for _, o in offs do
		err = math.max(err, (o - mean).Magnitude)
	end
	if not bestErr or err < bestErr then
		best, bestErr, bestBase = name, err, mean
	end
end

local sizeErr = 0
for key, s in sizes do
	local p = parts[key]
	if p then
		local m = maps[best](s)
		local want = Vector3.new(math.abs(m.X), math.abs(m.Y), math.abs(m.Z))
		sizeErr = math.max(sizeErr, (p.Size - want).Magnitude)
	end
end

return best, bestErr, bestBase, sizeErr
