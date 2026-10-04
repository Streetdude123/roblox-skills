return function(V, parent, spec)
	local cell = spec.cell or 2
	local rng = Random.new(spec.seed or 5)
	local grid = {}
	local function mark(ix, iz)
		grid[iz] = grid[iz] or {}
		grid[iz][ix] = true
	end
	local function distSeg(px, pz, a, b)
		local abx, abz = b.X - a.X, b.Z - a.Z
		local t = ((px - a.X) * abx + (pz - a.Z) * abz) / (abx * abx + abz * abz)
		t = math.clamp(t, 0, 1)
		local qx, qz = a.X + abx * t, a.Z + abz * t
		return math.sqrt((px - qx) ^ 2 + (pz - qz) ^ 2)
	end
	local x0, x1, z0, z1 = spec.x0, spec.x1, spec.z0, spec.z1
	for iz = math.floor(z0 / cell), math.ceil(z1 / cell) do
		for ix = math.floor(x0 / cell), math.ceil(x1 / cell) do
			local px, pz = (ix + 0.5) * cell, (iz + 0.5) * cell
			local hit = false
			for _, r in spec.rings or {} do
				local d = math.sqrt((px - r.c.X) ^ 2 + (pz - r.c.Z) ^ 2)
				local jitter = rng:NextNumber(-0.9, 0.9)
				if d >= r.inner + jitter and d <= r.outer + jitter then
					hit = true
				end
			end
			if not hit then
				for _, s in spec.segments or {} do
					local d = distSeg(px, pz, s[1], s[2])
					if d <= s[3] / 2 + rng:NextNumber(-0.8, 0.8) then
						hit = true
						break
					end
				end
			end
			if hit and spec.keep and not spec.keep(px, pz) then
				hit = false
			end
			if hit then
				mark(ix, iz)
			end
		end
	end
	local n = 0
	for iz, row in grid do
		local xs = {}
		for ix in row do
			table.insert(xs, ix)
		end
		table.sort(xs)
		local i = 1
		while i <= #xs do
			local j = i
			while j < #xs and xs[j + 1] == xs[j] + 1 do
				j += 1
			end
			local a, b = xs[i] * cell, (xs[j] + 1) * cell
			local p = V.part(parent, "Path", CFrame.new((a + b) / 2, spec.y + spec.thick / 2, (iz + 0.5) * cell), Vector3.new(b - a, spec.thick, cell), V.tint(spec.color, 0.03), "studs")
			p.CanCollide = spec.collide ~= false
			n += 1
			i = j + 1
		end
	end
	return n
end
