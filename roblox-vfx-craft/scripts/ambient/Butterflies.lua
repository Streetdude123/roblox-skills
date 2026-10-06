local RunService = game:GetService("RunService")

local butterflies = {}

local RANGE = 150
local MAX = 32
local KINDS = { PatchFlowers = 4, PatchMeadow = 3 }

local tpl = script.Parent.Fx.Butterfly
local cam = workspace.CurrentCamera
local half = tpl.WingL.Width0 / 2

local rp = RaycastParams.new()
rp.FilterType = Enum.RaycastFilterType.Include
rp.FilterDescendantsInstances = { workspace.Terrain }

local homes = {}
local flock = {}
local pool = {}

local function ground(pos)
	local hit = workspace:Raycast(pos + Vector3.new(0, 40, 0), Vector3.new(0, -120, 0), rp)
	return hit and hit.Position or pos
end

local function add(p)
	local most = KINDS[p.Name]
	if not most then
		return
	end
	local pos = p.Position
	local n = math.floor((math.sin(pos.X * 12.9898 + pos.Z * 78.233) * 43758.5453) % 1 * (most + 1))
	if n > 0 then
		homes[p] = { ground(pos), n }
	end
end

local function make(home)
	local b = table.remove(pool)
	if not b then
		local m = tpl:Clone()
		b = { m = m, bl = m.BackL, fl = m.FrontL, br = m.BackR, fr = m.FrontR, tail = m.Tail, head = m.Head }
	end
	b.home = home
	b.pos = home[1] + Vector3.new(math.random(-6, 6), 2 + math.random() * 4, math.random(-6, 6))
	b.dir = math.random() * math.pi * 2
	b.seed = math.random() * 1000
	b.hz = 5.5 + math.random() * 2
	b.ph = math.random()
	b.speed = 3 + math.random() * 1.6
	b.alt = 2 + math.random() * 4
	b.mode = "fly"
	b.timer = 6 + math.random() * 10
	b.glide = 0
	b.m.Parent = cam
	return b
end

local function flap(b, dt)
	b.ph = (b.ph + dt * b.hz) % 1
	if b.glide > 0 then
		b.glide -= dt
		return 0.2
	end
	if math.random() < dt * 0.3 then
		b.glide = 0.25 + math.random() * 0.4
	end
	if b.ph < 0.38 then
		local t = b.ph / 0.38
		return 1.2 - 1.65 * t * t * (3 - 2 * t)
	end
	local t = (b.ph - 0.38) / 0.62
	return -0.45 + 1.65 * t * t * (3 - 2 * t)
end

local function step(b, dt, now)
	local f = Vector3.new(math.cos(b.dir), 0, math.sin(b.dir))
	if b.mode == "rest" then
		b.timer -= dt
		if b.timer <= 0 then
			b.mode = "fly"
			b.timer = 8 + math.random() * 12
		end
		return CFrame.lookAt(b.pos, b.pos + f), 1.5 - 1.1 * math.max(0, math.sin(now * 0.9 + b.seed)) ^ 3
	end
	local e = flap(b, dt)
	local vel
	if b.mode == "land" then
		local to = b.spot - b.pos
		local d = to.Magnitude
		if d < 0.35 then
			b.mode = "rest"
			b.pos = b.spot
			b.timer = 4 + math.random() * 6
			return CFrame.lookAt(b.pos, b.pos + f), 1.4
		end
		vel = to / d * math.min(b.speed * 0.8, d * 3)
		if to.X * to.X + to.Z * to.Z > 0.01 then
			b.dir = math.atan2(to.Z, to.X)
		end
	else
		local to = b.home[1] - b.pos
		local flat = Vector3.new(to.X, 0, to.Z)
		local d = flat.Magnitude
		local turn = 0
		if d > 0.5 then
			turn = Vector3.new(-f.Z, 0, f.X):Dot(flat / d) * (1 - math.exp(-d * d / 140))
		end
		b.dir += (math.noise(b.seed, now * 0.7) * 3 + turn * 2.6) * dt
		local h = b.home[1].Y + b.alt + math.noise(b.seed, now * 0.3, 7) * 2.5
		vel = f * b.speed + Vector3.new(0, (h - b.pos.Y) * 0.9 + math.sin(b.ph * math.pi * 2) * 1.6, 0)
		b.timer -= dt
		if b.timer <= 0 then
			b.mode = "land"
			local a = math.random() * math.pi * 2
			b.spot = ground(b.home[1] + Vector3.new(math.cos(a), 0, math.sin(a)) * math.random() * 9) + Vector3.new(0, 2, 0)
		end
	end
	b.pos += vel * dt
	return CFrame.lookAt(b.pos, b.pos + f) * CFrame.Angles(math.clamp(vel.Y / 6, -0.4, 0.5) + 0.2, 0, 0), e
end

local function place(b, cf, e)
	local p, fwd, up, right = cf.Position, cf.LookVector, cf.UpVector, cf.RightVector
	local c, s = math.cos(e), math.sin(e)
	local outL = up * s - right * c
	local outR = up * s + right * c
	local midL, midR = p + outL * half, p + outR * half
	b.bl.CFrame = CFrame.fromMatrix(midL - fwd * half, fwd, outL)
	b.fl.CFrame = CFrame.fromMatrix(midL + fwd * half, fwd, outL)
	b.br.CFrame = CFrame.fromMatrix(midR - fwd * half, fwd, outR)
	b.fr.CFrame = CFrame.fromMatrix(midR + fwd * half, fwd, outR)
	b.tail.Position = p - fwd * 0.3
	b.head.Position = p + fwd * 0.25
end

function butterflies.start(patches)
	for _, p in patches:GetChildren() do
		add(p)
	end
	patches.ChildAdded:Connect(add)
	patches.ChildRemoved:Connect(function(p)
		homes[p] = nil
	end)

	local acc = 1
	RunService.Heartbeat:Connect(function(dt)
		acc += dt
		if acc > 1 then
			acc = 0
			local pos = cam.CFrame.Position
			local near = {}
			for _, h in homes do
				local d = (h[1] - pos).Magnitude
				if d < RANGE then
					table.insert(near, { h, d })
				end
			end
			table.sort(near, function(a, b)
				return a[2] < b[2]
			end)
			local keep, count = {}, 0
			for _, x in near do
				if count + x[1][2] > MAX then
					break
				end
				keep[x[1]] = 0
				count += x[1][2]
			end
			for i = #flock, 1, -1 do
				local b = flock[i]
				if keep[b.home] then
					keep[b.home] += 1
				else
					b.m.Parent = nil
					table.insert(pool, b)
					table.remove(flock, i)
				end
			end
			for h, have in keep do
				for _ = have + 1, h[2] do
					table.insert(flock, make(h))
				end
			end
		end

		local now = os.clock()
		for _, b in flock do
			place(b, step(b, dt, now))
		end
	end)
end

return butterflies
