local Poser = require(script.Parent.Poser)

local V = {}
V.FLOOR = -1.642
V.LEGS = {"LeftArm", "RightArm", "LeftLeg"}
local FRONT = {LeftArm = true, RightArm = true}

local function corners(size)
	local list = {}
	for _, dx in {-1, 1} do
		for _, dy in {-1, 1} do
			for _, dz in {-1, 1} do
				table.insert(list, Vector3.new(dx * size.X / 2, dy * size.Y / 2, dz * size.Z / 2))
			end
		end
	end
	return list
end

function V.read(model, pivots)
	local geo = {joints = {}, legs = {}, order = {}, model = model, boxes = {}}
	local list = {}
	for _, m in model:GetDescendants() do
		if m:IsA("Motor6D") and m.Part0 and m.Part1 then
			local j = {p0 = m.Part0.Name, p1 = m.Part1.Name, c0 = m.C0, c1 = m.C1, r = m.C0.Rotation, rinv = m.C0.Rotation:Inverse(), part = m.Part1}
			geo.joints[j.p1] = j
			table.insert(list, j)
		end
	end
	local placed = {HumanoidRootPart = true}
	while #geo.order < #list do
		for _, j in list do
			if placed[j.p0] and not placed[j.p1] then
				table.insert(geo.order, j)
				placed[j.p1] = true
			end
		end
	end
	for _, j in list do
		local part = j.part
		local boxes = {{rel = CFrame.identity, pts = corners(part.Size)}}
		for _, d in part:GetDescendants() do
			if d:IsA("BasePart") then
				local rel = part.CFrame:Inverse() * d.CFrame
				local pts = {}
				for _, c in corners(d.Size) do
					table.insert(pts, rel * c)
				end
				table.insert(boxes, {pts = pts})
			end
		end
		local all = {}
		for _, b in boxes do
			for _, c in b.pts do
				table.insert(all, c)
			end
		end
		geo.boxes[j.p1] = all
	end
	geo.rootR = geo.joints.MainTorso.r
	local world = V.fk(geo, {})
	for _, name in V.LEGS do
		local j = geo.joints[name]
		local sole = Vector3.new(0, -j.part.Size.Y / 2, 0)
		local s0 = j.r * (j.c1:Inverse() * sole)
		geo.legs[name] = {j = j, sole = sole, s0 = s0, len = s0.Magnitude, rest = world[name] * sole, pivotY = pivots and pivots[name] or j.c1.Position.Y}
	end
	local f, h = geo.legs.LeftArm.j.c0.Position.Z, geo.legs.LeftLeg.j.c0.Position.Z
	geo.front, geo.hind = f, h
	return geo
end

function V.fk(geo, poses, rootCF)
	local world = {HumanoidRootPart = rootCF or CFrame.identity}
	for _, j in geo.order do
		local pose = poses[j.p1] or CFrame.identity
		world[j.p1] = world[j.p0] * j.c0 * (j.rinv * pose * j.r) * j.c1:Inverse()
	end
	return world
end

local function aim(u)
	return CFrame.Angles(0, 0, math.atan2(u.X, math.max(-u.Y, 0.05))) * CFrame.Angles(math.asin(math.clamp(-u.Z, -1, 1)), 0, 0)
end

function V.scaleOf(geo, name, t)
	local f = geo.scale
	if not f or not geo.legs[name] then
		return 1
	end
	return type(f) == "number" and f or f(name, t or 0)
end

function V.legPoint(geo, name, s, p)
	if s == 1 then
		return p
	end
	return Vector3.new(p.X, p.Y * s + geo.legs[name].pivotY * (1 - s), p.Z)
end

local function lowOf(geo, name, cf, t)
	local s = V.scaleOf(geo, name, t)
	local lo = math.huge
	for _, c in geo.boxes[name] do
		lo = math.min(lo, (cf * V.legPoint(geo, name, s, c)).Y)
	end
	return lo
end
V.lowOf = lowOf

function V.solveLeg(geo, name, torsoCF, target, maxTuck, planted, t)
	local leg = geo.legs[name]
	local j = leg.j
	local sole = V.legPoint(geo, name, V.scaleOf(geo, name, t), leg.sole)
	local s0 = j.r * (j.c1:Inverse() * sole)
	local len = s0.Magnitude
	local pivot = torsoCF * j.c0.Position
	local goal = target
	local pose, ext
	for _ = 1, 3 do
		local d = torsoCF.Rotation:Inverse() * (goal - pivot)
		ext = d.Magnitude - len
		local q = aim(d.Unit) * aim(s0.Unit):Inverse()
		pose = CFrame.new(d.Unit * math.clamp(ext, -(maxTuck or 0.45), 0)) * q
		local cf = torsoCF * j.c0 * (j.rinv * pose * j.r) * j.c1:Inverse()
		local drop = (cf * sole).Y - lowOf(geo, name, cf, t)
		goal = Vector3.new(target.X, target.Y + drop, target.Z)
	end
	return pose, ext
end

local function flow(p, v, w, tau)
	if w == 0 then
		return p + Vector3.new(0, 0, v * tau)
	end
	local c = Vector3.new(-v / w, p.Y, 0)
	return c + CFrame.Angles(0, -w * tau, 0) * (p - c)
end

local function groundVel(p, v, w)
	return Vector3.new(-w * p.Z, 0, v + w * p.X)
end

function V.foot(geo, gait, name, t)
	local leg = gait.legs[name]
	if leg.path then
		return leg.path(t)
	end
	local rest = leg.at or geo.legs[name].rest
	local mid = Vector3.new(rest.X + (leg.dx or 0), V.FLOOR, rest.Z + (leg.fwd or 0))
	if leg.fixed then
		return mid, true
	end
	local T, v, w = gait.T, gait.v, gait.w or 0
	local st = leg.duty * T
	local since = ((t / T - leg.phase) % 1) * T
	if since < st then
		return flow(mid, v, w, since - st / 2), true
	end
	local sw = T - st
	local u = (since - st) / sw
	local a = flow(mid, v, w, st / 2)
	local b = flow(mid, v, w, -st / 2)
	local va, vb = groundVel(a, v, w) * sw, groundVel(b, v, w) * sw
	local u2, u3 = u * u, u * u * u
	local p = a * (2 * u3 - 3 * u2 + 1) + va * (u3 - 2 * u2 + u) + b * (-2 * u3 + 3 * u2) + vb * (u3 - u2)
	local lift = (leg.h or 0.3) * math.sin(math.pi * u ^ (leg.early or 0.85)) ^ 1.2
	return Vector3.new(p.X, V.FLOOR + lift, p.Z), false
end

local function torsoPose(auth, df, dh, geo)
	local span = geo.hind - geo.front
	local pitch = math.atan2(dh - df, span)
	local y = df + (dh - df) * (0 - geo.front) / span
	return CFrame.new(0, -y, 0) * CFrame.Angles(pitch, 0, 0) * auth
end

local function need(geo, gait, auth, t)
	local df, dh = 0, 0
	for _ = 1, 6 do
		local torsoCF = torsoPose(auth, df, dh, geo) * geo.rootR
		local ef, eh = -math.huge, -math.huge
		for name in gait.legs do
			local target, planted = V.foot(geo, gait, name, t)
			if planted then
				local _, ext = V.solveLeg(geo, name, torsoCF, target, gait.needTuck or 0.45, true, t)
				if FRONT[name] then
					ef = math.max(ef, ext)
				else
					eh = math.max(eh, ext)
				end
			end
		end
		if ef <= 1e-4 and eh <= 1e-4 then
			break
		end
		df += math.max(0, ef) * 1.05
		dh += math.max(0, eh) * 1.05
	end
	return df, dh
end

function V.gait(geo, clip, gait)
	Poser.compile(clip)
	local len = clip.length
	local n = math.max(1, math.floor(len * 60 + 0.5))
	local loop = clip.loop
	local reqF, reqH = {}, {}
	for i = 0, n do
		local t = math.min(len, i / 60)
		local auth = clip.joints.MainTorso and Poser.sample(clip, "MainTorso", t) or CFrame.identity
		reqF[i], reqH[i] = need(geo, gait, auth, t)
	end
	local function smooth(req)
		local cur = table.clone(req)
		for _ = 1, gait.smooth or 24 do
			local nxt = {}
			for i = 0, n do
				local a, b
				if loop then
					a, b = cur[(i - 1) % n], cur[(i + 1) % n]
				else
					a, b = cur[math.max(0, i - 1)], cur[math.min(n, i + 1)]
				end
				nxt[i] = math.max(req[i], (a + 2 * cur[i] + b) / 4)
			end
			if loop then
				nxt[n] = nxt[0]
			end
			cur = nxt
		end
		return cur
	end
	local dropF, dropH = smooth(reqF), smooth(reqH)
	gait.dropF, gait.dropH, gait.n = dropF, dropH, n
	local function at(arr, t)
		local x = math.clamp(t, 0, len) * 60
		local i = math.floor(x)
		local f = x - i
		return arr[math.min(n, i)] + ((arr[math.min(n, i + 1)] or arr[n]) - arr[math.min(n, i)]) * f
	end
	clip.post = function(poses, t)
		local auth = poses.MainTorso or CFrame.identity
		local torso = torsoPose(auth, at(dropF, t), at(dropH, t), geo)
		poses.MainTorso = torso
		local torsoCF = torso * geo.rootR
		for name in gait.legs do
			local target, planted = V.foot(geo, gait, name, t)
			poses[name] = (V.solveLeg(geo, name, torsoCF, target, gait.tuck or 0.45, planted, t))
		end
	end
	for name in gait.legs do
		clip.joints[name] = clip.joints[name] or {{t = 0, r = {0, 0, 0}}}
	end
	clip.joints.MainTorso = clip.joints.MainTorso or {{t = 0, r = {0, 0, 0}}}
	clip.compiled = nil
	Poser.compile(clip)
	return clip
end

local ghosts
function V.clear()
	for _, m in workspace:GetChildren() do
		if m.Name == "VerixStrip" then
			m:Destroy()
		end
	end
	ghosts = nil
end

local FACE = {side = math.pi / 2, front = 0, rear = math.pi, rear34 = math.pi * 0.8, front34 = math.pi * 0.22}

function V.strip(geo, clip, times, opts)
	opts = opts or {}
	V.clear()
	ghosts = Instance.new("Model")
	ghosts.Name = "VerixStrip"
	local spacing = opts.spacing or (opts.facing == "front" and 3 or 5.5)
	local origin = opts.origin or Vector3.new(300, 1.642, 300)
	local yaw = FACE[opts.facing or "side"]
	local src = geo.model
	local was = src.Archivable
	src.Archivable = true
	for i, t in times do
		local poses = Poser.posesAt(clip, t)
		local rootCF = CFrame.new(origin + Vector3.new(-(i - 1) * spacing, 0, 0)) * CFrame.Angles(0, yaw, 0)
		if opts.travel then
			rootCF *= CFrame.new(0, 0, -opts.travel * t)
		end
		local world = V.fk(geo, poses, rootCF)
		local g = src:Clone()
		for _, d in g:GetDescendants() do
			if d:IsA("JointInstance") or d:IsA("LuaSourceContainer") or d:IsA("Humanoid") or d:IsA("KeyframeSequence") or d:IsA("ObjectValue") then
				d:Destroy()
			end
		end
		for _, p in g:GetChildren() do
			if p:IsA("BasePart") and world[p.Name] then
				local rels = {}
				for _, d in p:GetDescendants() do
					if d:IsA("BasePart") then
						rels[d] = p.CFrame:Inverse() * d.CFrame
					end
				end
				local sc = V.scaleOf(geo, p.Name, t)
				p.Anchored = true
				p.CanCollide = false
				p.CFrame = world[p.Name] * CFrame.new(V.legPoint(geo, p.Name, sc, Vector3.zero))
				p.Size = p.Size * Vector3.new(1, sc, 1)
				for d, rel in rels do
					d.Anchored = true
					d.CanCollide = false
					d.CFrame = world[p.Name] * CFrame.new(V.legPoint(geo, p.Name, sc, rel.Position)) * rel.Rotation
					local ax = rel.Rotation:VectorToObjectSpace(Vector3.yAxis)
					d.Size = d.Size * (Vector3.one + Vector3.new(math.abs(ax.X), math.abs(ax.Y), math.abs(ax.Z)) * (sc - 1))
				end
			elseif p:IsA("BasePart") then
				p:Destroy()
			end
		end
		g.Name = ("%s_%.2f"):format(clip.name or "clip", t)
		g.Parent = ghosts
	end
	src.Archivable = was
	ghosts.Parent = workspace
	local count = #times
	local mid = origin + Vector3.new(-(count - 1) * spacing / 2, -0.4, 0)
	local dist = opts.dist or math.max(6, count * spacing * 0.42)
	local camPos = mid + Vector3.new(0, opts.up or 1.2, -dist)
	return camPos, mid
end

function V.feet(geo, clip, gait, opts)
	opts = opts or {}
	local len = opts.length or clip.length
	local v, w = gait and gait.v or 0, gait and gait.w or 0
	local res = {}
	local prev = {}
	local yaw, pos = 0, Vector3.zero
	local lastT = 0
	Poser.each(clip, 60, function(t, poses)
		local dt = t - lastT
		lastT = t
		pos += CFrame.Angles(0, yaw, 0) * Vector3.new(0, 0, -v * dt)
		yaw += w * dt
		local rootCF = CFrame.new(pos) * CFrame.Angles(0, yaw, 0)
		local world = V.fk(geo, poses)
		for _, name in V.LEGS do
			local r = res[name] or {low = math.huge, high = -math.huge, slide = 0, planted = 0, frames = 0}
			res[name] = r
			local lo = lowOf(geo, name, world[name], t)
			local soleW = rootCF * (world[name] * V.legPoint(geo, name, V.scaleOf(geo, name, t), geo.legs[name].sole))
			local on = lo < V.FLOOR + 0.03
			r.frames += 1
			if on then
				r.planted += 1
				r.low = math.min(r.low, lo - V.FLOOR)
				r.high = math.max(r.high, lo - V.FLOOR)
				if prev[name] then
					local d = soleW - prev[name]
					r.slide = math.max(r.slide, Vector3.new(d.X, 0, d.Z).Magnitude * 60)
				end
				prev[name] = soleW
			else
				prev[name] = nil
			end
		end
	end, {length = len})
	local out = {}
	for _, name in V.LEGS do
		local r = res[name]
		table.insert(out, ("%s planted %d/%d lowest %.3f highest %.3f slideSpeed %.2f"):format(name, r.planted, r.frames, r.low == math.huge and 0 or r.low, r.high == -math.huge and 0 or r.high, r.slide))
	end
	return table.concat(out, "\n"), res
end

return V
