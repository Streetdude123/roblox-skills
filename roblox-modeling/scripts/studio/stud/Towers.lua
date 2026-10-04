return function(V)
	local C = V.C
	local part = V.part
	local tint = V.tint
	local rng = V.rng
	local frameBox = V.frameBox
	local brace = V.brace
	local wallFaces = V.wallFaces
	local corners = { { 1, 1 }, { 1, -1 }, { -1, 1 }, { -1, -1 } }
	local dark = Color3.fromRGB(58, 44, 38)
	local cloth = Color3.fromRGB(168, 34, 40)

	local function lantern(m, cf, light)
		part(m, "LanternTop", cf * CFrame.new(0, 0.65, 0), Vector3.new(1.1, 0.25, 1.1), C.timberDark)
		part(m, "LanternFrame", cf, Vector3.new(0.9, 1, 0.9), C.timberDark)
		local core = part(m, "LanternGlow", cf, Vector3.new(0.95, 0.7, 0.95), C.glow, "neon")
		part(m, "LanternBase", cf * CFrame.new(0, -0.6, 0), Vector3.new(1, 0.2, 1), C.timberDark)
		if light then
			V.light(core, 12, 1.1)
		end
	end

	local function wallLamp(m, face, x, y)
		part(m, "Bracket", face * CFrame.new(x, y + 1.1, -0.6), Vector3.new(0.3, 0.3, 1.2), C.timberDark)
		part(m, "Hanger", face * CFrame.new(x, y + 0.9, -1.1), Vector3.new(0.15, 0.4, 0.15), C.timberDark)
		lantern(m, face * CFrame.new(x, y, -1.1), true)
	end

	local function arch(m, cf, w, h, t, color, kind)
		local r = w / 2
		for _, s in { -1, 1 } do
			part(m, "Jamb", cf * CFrame.new(s * (r + t / 2), (h - r) / 2, 0), Vector3.new(t, h - r, t), tint(color, 0.05), kind)
		end
		local n = math.max(5, math.floor(math.pi * (r + t / 2) / 1.05))
		if n % 2 == 0 then n += 1 end
		for i = 0, n - 1 do
			local a = math.pi * (i + 0.5) / n
			local p = Vector3.new(math.cos(a) * (r + t / 2), h - r + math.sin(a) * (r + t / 2), 0)
			local key = i == (n - 1) / 2
			part(m, key and "Keystone" or "Voussoir", cf * CFrame.new(p) * CFrame.Angles(0, 0, a - math.pi / 2), Vector3.new(key and 1.25 or 1.15, t * (key and 1.25 or 1), t), tint(key and C.stoneLight or color, 0.05), kind)
		end
	end

	local function arrowSlit(m, face, x, y)
		part(m, "Slit", face * CFrame.new(x, y, -0.05), Vector3.new(0.5, 2.4, 0.2), dark)
		frameBox(m, face * CFrame.new(x, y, -0.2), 1.3, 3.2, C.stoneLight, "inlet", 0.4)
	end

	local function flowerBox(m, cf, w)
		part(m, "FlowerBox", cf, Vector3.new(w, 0.7, 0.8), C.timber, "studs")
		for i = 0, math.floor(w / 0.8) - 1 do
			local x = -w / 2 + 0.4 + i * 0.8
			local f = part(m, "Bloom", cf * CFrame.new(x, 0.55 + rng:NextNumber(0, 0.2), rng:NextNumber(-0.15, 0.15)), Vector3.new(0.5, 0.45, 0.5), i % 3 == 0 and C.red or (i % 3 == 1 and Color3.fromRGB(250, 214, 80) or Color3.fromRGB(150, 110, 230)), "studs")
			f.CanCollide = false
		end
	end

	local function shutteredWindow(m, face, x, y, w, h, lit)
		V.window(m, face * CFrame.new(x, y, -0.1), w, h, lit)
		for _, s in { -1, 1 } do
			part(m, "Shutter", face * CFrame.new(x + s * (w / 2 + 0.55), y, -0.45) * CFrame.Angles(0, s * math.rad(28), 0), Vector3.new(1.1, h, 0.18), tint(Color3.fromRGB(70, 104, 76), 0.06), "studs")
		end
		flowerBox(m, face * CFrame.new(x, y - h / 2 - 0.55, -0.55), w + 0.6)
	end

	local function chamferRing(m, at, y, h, s, c, color, kind, name, out)
		out = out or 0
		local half = s / 2 + out
		local cc = c + out * 0.4
		for _, f in wallFaces(s + out * 2, s + out * 2) do
			part(m, name, at * f[1] * CFrame.new(0, y + h / 2, 0.5), Vector3.new(s + out * 2 - 2 * cc, h, 1), tint(color, 0.04), kind)
		end
		for _, q in corners do
			local mid = Vector3.new(q[1] * (half - cc / 2), 0, q[2] * (half - cc / 2))
			local n = Vector3.new(q[1], 0, q[2]).Unit
			local p = mid - n * 0.5
			part(m, name, at * CFrame.new(0, y + h / 2, 0) * CFrame.lookAt(p, p + n), Vector3.new(cc * math.sqrt(2) + 0.35, h, 1), tint(color, 0.04), kind)
		end
	end

	local function stepRoof(m, at, y, w, d, stepH, shrink, name)
		local k = 0
		while w > 1 and d > 1 do
			part(m, name or "Roof", at * CFrame.new(0, y + k * stepH + stepH / 2, 0), Vector3.new(w, stepH, d), tint(C.roof, 0.04), "studs")
			w -= shrink
			d -= shrink
			k += 1
		end
		return y + k * stepH, k
	end

	function V.tower2(parent, at, s, opts)
		opts = opts or {}
		local m = V.model(parent, opts.name or "TimberTower")
		local c = 2.2
		local baseH = opts.baseH or 10
		part(m, "Plinth", at * CFrame.new(0, 0.4, 0), Vector3.new(s + 3.4, 0.8, s + 3.4), tint(C.stone, 0.04), "inlet")
		chamferRing(m, at, 0.8, 0.8, s + 1, c, C.stoneLight, "inlet", "Plinth")
		local y = 1.6
		local k = 0
		while y < baseH - 0.01 do
			local hh = math.min(2, baseH - y)
			chamferRing(m, at, y, hh, s, c, k % 2 == 0 and C.stone or C.stoneLight, k % 2 == 0 and "inlet" or "studs", "Course")
			y += hh
			k += 1
		end
		for _, q in corners do
			local n = Vector3.new(q[1], 0, q[2]).Unit
			local base = Vector3.new(q[1] * (s / 2 - c / 2), 0, q[2] * (s / 2 - c / 2))
			for _, b in { { 1.6, 3.6, 2.4, 1.8 }, { 5.2, 2.8, 1.7, 1.4 }, { 8, 1.8, 1, 1 } } do
				local p = base + n * (b[3] / 2)
				part(m, "Buttress", at * CFrame.new(0, b[1] + b[2] / 2, 0) * CFrame.lookAt(p, p + n), Vector3.new(b[4], b[2], b[3]), tint(C.stoneLight, 0.05), "inlet")
			end
		end
		local faces = wallFaces(s, s)
		local front = at * faces[1][1]
		part(m, "Door", front * CFrame.new(0, 1.6 + 3, -0.12), Vector3.new(3.4, 6, 0.3), tint(C.timber, 0.05), "studs")
		for _, x in { -1.1, 0, 1.1 } do
			part(m, "Plank", front * CFrame.new(x, 1.6 + 3, -0.3), Vector3.new(0.12, 5.8, 0.1), C.timberDark)
		end
		for _, yy in { 2.8, 6.2 } do
			part(m, "Hinge", front * CFrame.new(-0.6, yy, -0.32), Vector3.new(1.6, 0.25, 0.08), Color3.fromRGB(46, 46, 52), "smooth")
		end
		part(m, "Ring", front * CFrame.new(1.05, 4.4, -0.35), Vector3.new(0.35, 0.35, 0.1), C.gold, "smooth")
		arch(m, front * CFrame.new(0, 1.6, -0.35), 3.6, 6.6, 0.9, C.stoneLight, "inlet")
		part(m, "Step", front * CFrame.new(0, 0.2, -1.6), Vector3.new(5.6, 0.4, 1.4), tint(C.stone, 0.04), "inlet")
		part(m, "Step", front * CFrame.new(0, 0.6, -1.2), Vector3.new(4.8, 0.4, 0.8), tint(C.stoneLight, 0.04), "inlet")
		wallLamp(m, front, -3.2, 5.4)
		wallLamp(m, front, 3.2, 5.4)
		for i = 2, 4 do
			local f = at * faces[i][1]
			arrowSlit(m, f, -2.4, 5.8)
			arrowSlit(m, f, 2.4, 5.8)
		end
		chamferRing(m, at, baseH, 1, s, c, C.stoneLight, "inlet", "Ledge", 0.9)
		for _, f in faces do
			local fc = at * f[1]
			for x = -(s / 2 - c) + 1, (s / 2 - c) - 1, 2 do
				part(m, "Corbel", fc * CFrame.new(x, baseH - 0.45, -0.45), Vector3.new(0.8, 0.9, 1.1), tint(C.stone, 0.05), "inlet")
			end
		end
		local y1 = baseH + 1
		local s1 = s + 0.8
		local h1 = opts.h1 or 8
		part(m, "Floor", at * CFrame.new(0, y1 + 0.3, 0), Vector3.new(s1 + 0.6, 0.6, s1 + 0.6), C.timberDark, "studs")
		for i, f in wallFaces(s1, s1) do
			local fc = at * f[1]
			local cf = fc * CFrame.new(0, y1 + 0.6 + h1 / 2, 0)
			part(m, "Infill", cf * CFrame.new(0, 0, 0.5), Vector3.new(s1, h1, 1), tint(C.diamond, 0.03), "diamond")
			part(m, "Sill", cf * CFrame.new(0, -h1 / 2 + 0.3, -0.15), Vector3.new(s1, 0.6, 0.5), C.timber, "studs")
			part(m, "Head", cf * CFrame.new(0, h1 / 2 - 0.3, -0.15), Vector3.new(s1, 0.6, 0.5), C.timber, "studs")
			part(m, "Rail", cf * CFrame.new(0, -0.6, -0.15), Vector3.new(s1, 0.45, 0.45), C.timber)
			for _, x in { -s1 / 4 - 0.6, s1 / 4 + 0.6 } do
				part(m, "Post", cf * CFrame.new(x, 0, -0.15), Vector3.new(0.5, h1, 0.5), C.timber)
			end
			for _, sx in { -1, 1 } do
				local px = sx * (s1 / 2 - (s1 / 4 - 0.6) / 2 - 0.25)
				local pw = s1 / 4 - 0.9
				brace(m, cf * CFrame.new(px, -h1 / 4 - 0.2, -0.2), pw, h1 / 2 - 1, C.timber)
				brace(m, cf * CFrame.new(px, -h1 / 4 - 0.2, -0.2) * CFrame.Angles(0, math.pi, 0), pw, h1 / 2 - 1, C.timber)
				brace(m, cf * CFrame.new(px, h1 / 4 - 0.3, -0.2), pw, h1 / 2 - 1.2, C.timber)
				brace(m, cf * CFrame.new(px, h1 / 4 - 0.3, -0.2) * CFrame.Angles(0, math.pi, 0), pw, h1 / 2 - 1.2, C.timber)
			end
			shutteredWindow(m, cf, 0, 1, 2.4, 2.6, i == 1 and opts.lit)
			local below = at * wallFaces(s, s)[i][1]
			for _, x in { -s / 3, 0, s / 3 } do
				part(m, "Knee", below * CFrame.new(x, y1 - 0.9, -0.55) * CFrame.Angles(math.rad(-40), 0, 0), Vector3.new(0.45, 1.8, 0.45), C.timberDark)
			end
		end
		for _, q in corners do
			part(m, "CornerPost", at * CFrame.new(q[1] * s1 / 2, y1 + 0.6 + h1 / 2, q[2] * s1 / 2), Vector3.new(0.9, h1, 0.9), C.timber, "studs")
		end
		local fr = at * wallFaces(s1, s1)[1][1]
		for _, sx in { -1, 1 } do
			part(m, "Arm", fr * CFrame.new(sx * (s1 / 2 + 0.2), y1 + h1 - 0.6, -0.9), Vector3.new(0.3, 0.3, 1.6), C.timberDark)
			lantern(m, fr * CFrame.new(sx * (s1 / 2 + 0.2), y1 + h1 - 1.9, -1.5), true)
		end
		local y2 = y1 + 0.6 + h1
		part(m, "Skirt", at * CFrame.new(0, y2 + 0.4, 0), Vector3.new(s1 + 3.6, 0.8, s1 + 3.6), tint(C.roof, 0.04), "studs")
		part(m, "Skirt", at * CFrame.new(0, y2 + 1.2, 0), Vector3.new(s1 + 1.8, 0.8, s1 + 1.8), tint(C.roof, 0.04), "studs")
		part(m, "Fascia", at * CFrame.new(0, y2 + 0.05, 0), Vector3.new(s1 + 3.9, 0.3, s1 + 3.9), C.timberDark)
		local y3 = y2 + 1.6
		local s2 = s + 1
		local h2 = 7.5
		part(m, "Floor", at * CFrame.new(0, y3 + 0.3, 0), Vector3.new(s2 + 0.6, 0.6, s2 + 0.6), C.timberDark, "studs")
		local bulb = part(m, "Lantern", at * CFrame.new(0, y3 + 0.6 + h2 * 0.5, 0), Vector3.new(1, 1, 1), C.glow, "neon")
		V.light(bulb, 22, 1.6, Color3.fromRGB(255, 190, 90))
		for i, f in wallFaces(s2, s2) do
			local cf = at * f[1] * CFrame.new(0, y3 + 0.6 + h2 / 2, 0)
			part(m, "Inner", cf * CFrame.new(0, 0, 2.4), Vector3.new(s2 - 2, h2 - 0.4, 0.4), dark)
			part(m, "Glim", cf * CFrame.new(0, h2 / 2 - 2.4, 1.8), Vector3.new(0.8, 0.8, 0.8), C.glow, "neon")
			part(m, "Lintel", cf * CFrame.new(0, h2 / 2 - 0.8, 0.4), Vector3.new(s2, 1.6, 1), tint(C.plaster, 0.02), "smooth")
			part(m, "SillWall", cf * CFrame.new(0, -h2 / 2 + 0.7, 0.4), Vector3.new(s2, 1.4, 1), tint(C.plaster, 0.02), "smooth")
			local ow = s2 - 3.6
			for _, sx in { -1, 1 } do
				part(m, "Jamb", cf * CFrame.new(sx * (s2 / 2 - 0.9), 0, 0.4), Vector3.new(1.8, h2, 1), tint(C.plaster, 0.02), "smooth")
				for _, sy in { -1, 1 } do
					local cy = sy > 0 and (h2 / 2 - 1.6) or (-h2 / 2 + 1.4)
					part(m, "Chamfer", cf * CFrame.new(sx * (ow / 2), cy, 0.4) * CFrame.Angles(0, 0, math.rad(45)), Vector3.new(1.7, 1.7, 1), tint(C.plaster, 0.02), "smooth")
				end
			end
			part(m, "Trim", cf * CFrame.new(0, h2 / 2 - 0.2, -0.15), Vector3.new(s2 + 0.2, 0.4, 0.4), C.timber)
			part(m, "Trim", cf * CFrame.new(0, -h2 / 2 + 1.5, -0.15), Vector3.new(s2 + 0.2, 0.4, 0.4), C.timber)
			part(m, "Mullion", cf * CFrame.new(0, 0.1, 0.4), Vector3.new(0.4, h2 - 3, 0.6), C.timber)
			if i == 1 then
				local bal = cf * CFrame.new(0, -h2 / 2 + 0.3, -1.3)
				part(m, "Balcony", bal, Vector3.new(6.4, 0.5, 2.6), C.timber, "studs")
				for _, bx in { -2.9, -1, 1, 2.9 } do
					part(m, "Baluster", bal * CFrame.new(bx, 1, -1.1), Vector3.new(0.35, 1.6, 0.35), C.timberDark)
				end
				for _, bx in { -3.05, 3.05 } do
					part(m, "Baluster", bal * CFrame.new(bx, 1, 0), Vector3.new(0.35, 1.6, 0.35), C.timberDark)
				end
				part(m, "Handrail", bal * CFrame.new(0, 1.85, -1.1), Vector3.new(6.4, 0.3, 0.4), C.timber, "studs")
				for _, bx in { -2.4, 2.4 } do
					part(m, "BalconyKnee", bal * CFrame.new(bx, -0.9, 0.3) * CFrame.Angles(math.rad(-38), 0, 0), Vector3.new(0.4, 1.9, 0.4), C.timberDark)
				end
			end
		end
		for _, q in corners do
			part(m, "CornerPost", at * CFrame.new(q[1] * s2 / 2, y3 + 0.6 + h2 / 2, q[2] * s2 / 2), Vector3.new(1, h2, 1), C.timber, "studs")
		end
		local top = y3 + 0.6 + h2
		local roofW = s2 + 4
		if opts.belfry then
			part(m, "Skirt", at * CFrame.new(0, top + 0.4, 0), Vector3.new(s2 + 3, 0.8, s2 + 3), tint(C.roof, 0.04), "studs")
			part(m, "Skirt", at * CFrame.new(0, top + 1.2, 0), Vector3.new(s2 + 1.4, 0.8, s2 + 1.4), tint(C.roof, 0.04), "studs")
			local s3 = s - 3
			local yb = top + 1.6
			local hb = 5.5
			part(m, "BelfryFloor", at * CFrame.new(0, yb + 0.3, 0), Vector3.new(s3 + 0.6, 0.6, s3 + 0.6), tint(C.stone, 0.04), "inlet")
			for _, q in corners do
				part(m, "BelfryPier", at * CFrame.new(q[1] * (s3 / 2 - 0.7), yb + 0.6 + hb / 2, q[2] * (s3 / 2 - 0.7)), Vector3.new(1.4, hb, 1.4), tint(C.stoneLight, 0.05), "inlet")
			end
			for _, f in wallFaces(s3, s3) do
				local cf = at * f[1] * CFrame.new(0, yb + 0.6, 0)
				arch(m, cf * CFrame.new(0, 0, 0.2), s3 - 3.4, hb - 0.4, 0.8, C.stoneLight, "inlet")
				part(m, "BelfryRail", cf * CFrame.new(0, 0.6, 0.2), Vector3.new(s3 - 2.8, 0.3, 0.4), C.timberDark)
			end
			part(m, "Bell", at * CFrame.new(0, yb + 0.6 + hb * 0.55, 0), Vector3.new(1.8, 2, 1.8), C.gold, "smooth")
			part(m, "BellLip", at * CFrame.new(0, yb + 0.6 + hb * 0.55 - 1.1, 0), Vector3.new(2.3, 0.4, 2.3), C.gold, "smooth")
			part(m, "Yoke", at * CFrame.new(0, yb + 0.6 + hb - 0.6, 0), Vector3.new(s3 - 1.6, 0.5, 0.5), C.timberDark)
			top = yb + 0.6 + hb
			roofW = s3 + 3.4
		end
		part(m, "Eave", at * CFrame.new(0, top + 0.3, 0), Vector3.new(roofW + 0.4, 0.6, roofW + 0.4), C.timberDark, "studs")
		local roofTop, layers = stepRoof(m, at, top + 0.6, roofW, roofW, 1.1, 2)
		local mid = top + 0.6 + math.floor(layers * 0.35) * 1.1
		local off = roofW / 2 - math.floor(layers * 0.35) - 1.4
		for _, f in wallFaces(off * 2, off * 2) do
			local cf = at * f[1] * CFrame.new(0, mid, 0)
			part(m, "Dormer", cf * CFrame.new(0, 1.2, -0.6), Vector3.new(2.8, 2.4, 2.2), tint(C.plaster, 0.02), "smooth")
			part(m, "DormerGlass", cf * CFrame.new(0, 1.1, -1.75), Vector3.new(1.4, 1.4, 0.2), C.glow, "neon")
			frameBox(m, cf * CFrame.new(0, 1.1, -1.8), 1.9, 1.9, C.timberDark, nil, 0.3)
			part(m, "DormerRoof", cf * CFrame.new(0, 2.7, -0.6), Vector3.new(3.4, 0.6, 2.8), tint(C.roof, 0.04), "studs")
			part(m, "DormerRoof", cf * CFrame.new(0, 3.2, -0.6), Vector3.new(2, 0.5, 2.8), tint(C.roof, 0.04), "studs")
		end
		part(m, "Cupola", at * CFrame.new(0, roofTop + 0.8, 0), Vector3.new(2.2, 1.6, 2.2), dark)
		for _, q in corners do
			part(m, "CupolaPost", at * CFrame.new(q[1] * 1.05, roofTop + 0.8, q[2] * 1.05), Vector3.new(0.35, 1.6, 0.35), C.timber)
		end
		part(m, "CupolaRoof", at * CFrame.new(0, roofTop + 1.85, 0), Vector3.new(2.8, 0.5, 2.8), tint(C.roof, 0.04), "studs")
		part(m, "CupolaRoof", at * CFrame.new(0, roofTop + 2.3, 0), Vector3.new(1.6, 0.5, 1.6), tint(C.roof, 0.04), "studs")
		part(m, "Spire", at * CFrame.new(0, roofTop + 4.4, 0), Vector3.new(0.4, 3.8, 0.4), C.timberDark)
		part(m, "Finial", at * CFrame.new(0, roofTop + 6.5, 0), Vector3.new(0.7, 0.7, 0.7), C.gold, "neon")
		local flag = part(m, "Pennant", at * CFrame.new(1.45, roofTop + 5.6, 0), Vector3.new(2.6, 1.3, 0.12), cloth, "smooth")
		flag.CanCollide = false
		part(m, "PennantTip", at * CFrame.new(3, roofTop + 5.75, 0), Vector3.new(0.6, 0.7, 0.12), cloth, "smooth")
		m.WorldPivot = at
		return m
	end

	function V.roundTower2(parent, at, r, h, opts)
		opts = opts or {}
		local m = V.model(parent, opts.name or "StoneTower")
		local n = opts.segments or 18
		local function ring(name, radius, y, height, depth, color, kind, step, shift, extra)
			for i = 0, n - 1, step or 1 do
				local a = (i + 0.5 + (shift or 0)) / n * math.pi * 2
				local cf = at * CFrame.Angles(0, -a, 0) * CFrame.new(0, y + height / 2, -radius + depth / 2)
				if extra then cf = cf * extra end
				part(m, name, cf, Vector3.new(2 * radius * math.tan(math.pi / n) + 0.3, height, depth), tint(color, 0.05), kind)
			end
		end
		local core = Instance.new("Part")
		core.Name = "Core"
		core.Anchored = true
		core.Shape = Enum.PartType.Cylinder
		core.Size = Vector3.new(h, (r - 1.6) * 2, (r - 1.6) * 2)
		core.CFrame = at * CFrame.new(0, h / 2, 0) * CFrame.Angles(0, 0, math.pi / 2)
		core.Color = Color3.fromRGB(60, 64, 78)
		core.Parent = m
		ring("Plinth", r + 1.8, 0, 1.2, 3.2, C.stone, "inlet")
		ring("Plinth", r + 1, 1.2, 1.2, 2.6, C.stoneLight, "inlet")
		local gy = math.floor(h * 0.6)
		local y = 2.4
		local k = 0
		while y < h - 0.01 do
			local hh = math.min(2, h - y)
			ring("Course", r, y, hh, 2, k % 2 == 0 and C.stone or C.stoneLight, k % 2 == 0 and "inlet" or "studs")
			y += hh
			k += 1
		end
		local face = opts.face or 0
		local function onWall(a, yy, out)
			return at * CFrame.Angles(0, -a, 0) * CFrame.new(0, yy, -(r + (out or 0)))
		end
		for i = 0, 5 do
			local a = face + math.pi / 6 + i * math.pi / 3
			part(m, "Pilaster", onWall(a, 2.4 + (gy - 2.4) / 2, 0.45), Vector3.new(1.8, gy - 2.4, 1.1), tint(C.stoneLight, 0.05), "inlet")
			part(m, "PilasterCap", onWall(a, gy - 0.2, 0.75), Vector3.new(2.3, 0.6, 1.6), tint(C.stoneLight, 0.05), "inlet")
			part(m, "PilasterFoot", onWall(a, 2.9, 0.75), Vector3.new(2.3, 1, 1.6), tint(C.stone, 0.05), "inlet")
		end
		for _, w in opts.windows or { { face + 0.9, gy * 0.45 }, { face - 0.9, gy * 0.45 }, { face + math.pi, gy * 0.45 }, { face + math.pi * 0.62, gy * 0.75 }, { face - math.pi * 0.62, gy * 0.75 }, { face, gy + 6.2 }, { face + math.pi * 0.66, gy + 6.2 }, { face - math.pi * 0.66, gy + 6.2 } } do
			local cf = onWall(w[1], w[2], 0.12)
			local g = part(m, "Window", cf * CFrame.new(0, 0.4, 0), Vector3.new(1.8, 2.6, 0.3), C.glow, "neon")
			V.light(g, 12, 1, Color3.fromRGB(255, 170, 70))
			part(m, "WindowSill", cf * CFrame.new(0, -1.1, -0.35), Vector3.new(2.8, 0.4, 0.9), tint(C.stoneLight, 0.05), "inlet")
			arch(m, cf * CFrame.new(0, -0.9, -0.3), 1.9, 3.6, 0.6, C.stoneLight, "inlet")
			part(m, "Bar", cf * CFrame.new(0, 0.4, -0.2), Vector3.new(0.15, 2.6, 0.15), C.timberDark)
		end
		ring("GalleryFloor", r + 1.5, gy, 0.6, 3, C.timberDark, "studs")
		for i = 0, n - 1, 2 do
			local a = (i + 0.5) / n * math.pi * 2
			part(m, "Strut", at * CFrame.Angles(0, -a, 0) * CFrame.new(0, gy - 1.1, -(r + 1.1)) * CFrame.Angles(math.rad(-42), 0, 0), Vector3.new(0.45, 2.4, 0.45), C.timberDark)
			part(m, "GalleryPost", at * CFrame.Angles(0, -a, 0) * CFrame.new(0, gy + 0.6 + 1.6, -(r + 2.6)), Vector3.new(0.5, 3.2, 0.5), C.timber, "studs")
		end
		ring("GalleryRail", r + 2.75, gy + 1.5, 0.35, 0.35, C.timber)
		ring("GalleryWall", r + 2.75, gy + 0.6, 0.9, 0.3, C.timber, "studs")
		ring("GalleryRoof", r + 2.2, gy + 3.6, 0.6, 4, C.roof, "studs", nil, nil, CFrame.Angles(math.rad(-24), 0, 0))
		ring("Machicolation", r + 0.7, h - 1.1, 1.1, 1.4, C.stone, "inlet", 1, 0)
		ring("Parapet", r + 1.4, h, 1.6, 2.8, C.stoneLight, "inlet")
		ring("Merlon", r + 1.4, h + 1.6, 1.8, 1.6, C.stoneLight, "inlet", 2)
		local roofY = h + 0.6
		local rr = r - 0.4
		local step = 0
		while rr > 1.2 do
			local disc = Instance.new("Part")
			disc.Name = "Roof"
			disc.Anchored = true
			disc.Shape = Enum.PartType.Cylinder
			disc.Size = Vector3.new(1.3, rr * 2, rr * 2)
			disc.CFrame = at * CFrame.new(0, roofY + step * 1.3 + 0.65, 0) * CFrame.Angles(0, 0, math.pi / 2)
			disc.Color = tint(step % 2 == 0 and C.roof or Color3.fromRGB(150, 110, 92), 0.03)
			disc.Material = Enum.Material.Plastic
			disc.MaterialVariant = "Studs"
			disc.Parent = m
			rr -= 1.5
			step += 1
		end
		local apex = roofY + step * 1.3
		part(m, "Pole", at * CFrame.new(0, apex + 2.6, 0), Vector3.new(0.4, 5.2, 0.4), C.timberDark)
		part(m, "Finial", at * CFrame.new(0, apex + 5.4, 0), Vector3.new(0.8, 0.8, 0.8), C.gold, "neon")
		local flag = part(m, "Flag", at * CFrame.new(1.7, apex + 4.2, 0), Vector3.new(3.2, 2, 0.12), cloth, "smooth")
		flag.CanCollide = false
		part(m, "Emblem", at * CFrame.new(1.7, apex + 4.2, 0), Vector3.new(0.9, 0.9, 0.2), C.gold, "smooth")
		local door = onWall(face, 1.2, 0.15)
		part(m, "Door", door * CFrame.new(0, 3.2, 0), Vector3.new(3.6, 6.2, 0.4), tint(C.timber, 0.05), "studs")
		for _, x in { -1.2, 0, 1.2 } do
			part(m, "Plank", door * CFrame.new(x, 3.2, -0.25), Vector3.new(0.12, 6, 0.1), C.timberDark)
		end
		part(m, "Ring", door * CFrame.new(1.2, 3.6, -0.3), Vector3.new(0.35, 0.35, 0.1), C.gold, "smooth")
		arch(m, door * CFrame.new(0, 0, -0.35), 3.8, 6.8, 1, C.stoneLight, "inlet")
		part(m, "Step", door * CFrame.new(0, -0.4, -1.8), Vector3.new(6, 0.4, 1.6), tint(C.stone, 0.04), "inlet")
		part(m, "Step", door * CFrame.new(0, 0, -1.3), Vector3.new(5, 0.4, 1), tint(C.stoneLight, 0.04), "inlet")
		for _, sx in { -1, 1 } do
			local lampFace = door * CFrame.new(sx * 3.3, 0, 0)
			wallLamp(m, lampFace, 0, 4.4)
		end
		for _, a in { face + 1.25, face - 1.25 } do
			local b = onWall(a, gy - 0.9, 0.3)
			part(m, "BannerRod", b, Vector3.new(3, 0.25, 0.25), C.timberDark)
			local cl = part(m, "Banner", b * CFrame.new(0, -2.7, 0.05), Vector3.new(2.4, 5.2, 0.15), cloth, "smooth")
			cl.CanCollide = false
			part(m, "BannerTail", b * CFrame.new(-0.6, -5.6, 0.05), Vector3.new(1.1, 0.8, 0.15), cloth, "smooth")
			part(m, "BannerTail", b * CFrame.new(0.6, -5.6, 0.05), Vector3.new(1.1, 0.8, 0.15), cloth, "smooth")
			part(m, "BannerCrest", b * CFrame.new(0, -2.4, -0.05), Vector3.new(1, 1, 0.12), C.gold, "smooth")
			part(m, "BannerTrim", b * CFrame.new(0, -0.3, -0.05), Vector3.new(2.4, 0.3, 0.12), C.gold, "smooth")
		end
		m.WorldPivot = at
		return m
	end
end
