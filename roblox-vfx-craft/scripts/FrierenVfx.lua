local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")

local root = script.Parent.Parent
local Config = require(root.Config)
local Tw = require(script.Parent.Tw)

local Vfx = root.Assets.Vfx

local fx = workspace:FindFirstChild("FrierenFx") or Instance.new("Folder")
fx.Name = "FrierenFx"
fx.Parent = workspace

local Frieren = {}

local OUT, IN = Enum.EasingDirection.Out, Enum.EasingDirection.In
local QUAD, BACK = Enum.EasingStyle.Quad, Enum.EasingStyle.Back

local source, queue
local offset = 0

local function now()
	return source and source() or os.clock() / Tw.S() + offset
end

local function at(t, fn)
	if queue then
		queue(t, fn)
	else
		task.delay(t * Tw.S(), fn)
	end
end

local function spawn(name, cf)
	local c = Vfx[name]:Clone()
	if c:IsA("Model") then
		c:PivotTo(cf)
	else
		c.CFrame = cf
	end
	for _, e in ipairs(c:GetDescendants()) do
		if e:IsA("ParticleEmitter") then
			e.TimeScale = 1 / Tw.S()
		end
	end
	c.Parent = fx
	return c
end

local function beams(inst)
	local list = {}
	for _, b in ipairs(inst:GetDescendants()) do
		if b:IsA("Beam") then
			list[b] = {b.Width0, b.Width1, b.CurveSize0, b.CurveSize1}
		end
	end
	return list
end

local function show(b, w, dur, style)
	b.Width0, b.Width1 = 0, 0
	b.Enabled = true
	Tw.play(b, {Width0 = w[1], Width1 = w[2]}, dur, style or QUAD, OUT)
end

local function hide(b, dur, delayTime)
	Tw.play(b, {Width0 = 0, Width1 = 0}, dur, QUAD, IN, delayTime)
end

local function rates(inst, list)
	for name, rate in pairs(list) do
		inst:FindFirstChild(name, true).Rate = rate
	end
end

local function emit(inst, list)
	for name, n in pairs(list) do
		inst:FindFirstChild(name, true):Emit(n)
	end
end

local function ray(from, dir, char)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {char, fx}
	return workspace:Raycast(from, dir, params)
end

local function flash()
	local white = Players.LocalPlayer.PlayerGui.FrierenFlash.White
	white.BackgroundTransparency = 0.1
	Tw.play(white, {BackgroundTransparency = 1}, 0.06, QUAD, OUT, 0.03)
end

local trauma = 0
RunService:BindToRenderStep("FrierenKick", Enum.RenderPriority.Camera.Value + 1, function(dt)
	if trauma <= 0 then
		return
	end
	trauma = math.max(0, trauma - dt * 1.8 / Tw.S())
	local t = os.clock() * 13
	local k = trauma * trauma
	workspace.CurrentCamera.CFrame *= CFrame.new(math.noise(t, 1.5) * k * 0.9, math.noise(t, 2.5) * k * 0.9, 0) * CFrame.Angles(0, 0, math.noise(t, 3.5) * k * 0.03)
end)

local function kick(a)
	trauma = math.min(1, trauma + a)
end

local function ground(pos, char)
	local hit = ray(pos + Vector3.new(0, 2, 0), Vector3.new(0, -30, 0), char)
	return hit and hit.Position or pos - Vector3.new(0, 3, 0)
end

local function tip(arm)
	return (arm.CFrame * CFrame.new(0, -1, 0)).Position
end

local function gem(char)
	return char.Staff.Grip.Tip.WorldPosition
end

local function grow(c, k, dur, draw, fast)
	local base = c.CFrame
	local parts = beams(c)
	local spots, turn = {}, {}
	for _, a in ipairs(c:GetChildren()) do
		if a:IsA("Attachment") then
			spots[a] = a.CFrame
		end
	end
	for b in pairs(parts) do
		local t = b:GetAttribute("Spin")
		if t then
			turn[b.Attachment0], turn[b.Attachment1] = t, t
		end
	end
	local start = now()
	local last = start
	local spin, shut = 0, nil
	local conn = RunService.RenderStepped:Connect(function()
		local t = now()
		local e = t - start
		local ease = 1 - (1 - math.min(1, e / dur)) ^ 4
		spin += (t - last) * (1.2 + fast * (1 - ease))
		last = t
		c.CFrame = base * CFrame.Angles(0, 0, spin)
		local s = k * (0.35 + 0.65 * ease)
		if shut then
			local v = math.min(1, (t - shut[1]) / shut[2])
			s *= 1 - v * v
		end
		for a, cf in pairs(spots) do
			a.CFrame = CFrame.Angles(0, 0, (turn[a] or 0) * spin) * (cf.Rotation + cf.Position * s)
		end
		for b, w in pairs(parts) do
			if b.Enabled or b:GetAttribute("Order") <= e / draw then
				b.Enabled = true
				b.Width0, b.Width1 = w[1] * s, w[2] * s
				b.CurveSize0, b.CurveSize1 = w[3] * s, w[4] * s
			end
		end
	end)
	local function close(len)
		shut = {now(), len}
	end
	return conn, parts, close
end

local function floorCircle(char, k, dur)
	local p = ground(char.HumanoidRootPart.Position, char) + Vector3.new(0, 0.15, 0)
	local c = spawn("FloorCircle", CFrame.new(p) * CFrame.Angles(-math.pi / 2, 0, 0))
	local conn, _, close = grow(c, k, dur, 0.3, 3)
	return c, conn, close
end

local function spikes(pos, k)
	local s = spawn("Burst", CFrame.new(pos) * CFrame.Angles(math.random() * 6.28, math.random() * 6.28, 0))
	for _, a in ipairs(s:GetChildren()) do
		if a:IsA("Attachment") then
			a.Position *= k
		end
	end
	for b, w in pairs(beams(s)) do
		show(b, {w[1] * k, 0}, 0.03)
		hide(b, 0.12, 0.05)
	end
	Debris:AddItem(s, 0.4 * Tw.S())
end

local function updraft(char, list, stop)
	local d = spawn("Updraft", char.HumanoidRootPart.CFrame * CFrame.new(0, -2.8, 0))
	rates(d, list)
	at(stop, function()
		rates(d, {Motes = 0, Streaks = 0, Glints = 0})
	end)
	Debris:AddItem(d, (stop + 2) * Tw.S())
	return d
end

function Frieren.zoltraak(char)
	local Z = Config.Zoltraak
	local hrp = char.HumanoidRootPart
	local look = (hrp.CFrame.LookVector * Vector3.new(1, 0, 1)).Unit
	local fire = 0.65 + Z.Circle
	local stop = fire + Z.Line + Z.Hold

	updraft(char, {Motes = 60, Streaks = 30, Glints = 10}, fire)

	local sigil, sigilConn, sigilClose
	at(0.3, function()
		sigil, sigilConn, sigilClose = floorCircle(char, 1, 0.5)
		rates(sigil, {Rise = 30, Lines = 12})
	end)

	at(0.4, function()
		local p = spawn("Pillars", hrp.CFrame)
		local i = 0
		for b, w in pairs(beams(p)) do
			i += 1
			b.Width0, b.Width1 = 0, 0
			at(0.02 * i, function()
				show(b, w, 0.12)
				hide(b, 0.3, 0.2)
			end)
		end
		Debris:AddItem(p, 1.2 * Tw.S())
	end)

	local circle, base, conn, close, charge
	local barrel = {}
	at(0.65, function()
		local center = gem(char) + look * Z.Ahead
		base = CFrame.lookAt(center, center + look)
		circle = spawn("Circle", base)
		conn, _, close = grow(circle, Z.Radius / 3, Z.Circle, 0.3, 5)
		charge = spawn("Charge", base)
		rates(charge, {Gather = 60, Arcs = 10, Core = 20})
		Tw.play(charge.Light, {Brightness = 5}, Z.Circle, QUAD, IN)
		for i, step in ipairs({{1.9, 0.7}, {3.5, 0.45}}) do
			at(0.08 * i, function()
				local p = center + look * step[1]
				local c = spawn("Circle", CFrame.lookAt(p, p + look) * CFrame.Angles(0, (i % 2) * math.pi, 0))
				local cn, _, cl = grow(c, Z.Radius / 3 * step[2], Z.Circle - 0.08 * i, 0.3, 5)
				table.insert(barrel, {c, cn, cl})
			end)
		end
	end)

	at(fire, function()
		local center = base.Position
		local hit = ray(center, look * Z.Range, char)
		local finish = hit and hit.Position or center + look * Z.Range
		local len = (finish - center).Magnitude
		local line = spawn("Beam", CFrame.lookAt(center + look * len / 2, finish))
		line.Size = Vector3.new(1.2, 1.2, len)
		line.Start.Position = Vector3.new(0, 0, len / 2)
		line.Finish.Position = Vector3.new(0, 0, -len / 2)
		local w = beams(line)
		show(line.Line, w[line.Line], 0.03)
		rates(charge, {Gather = 0, Arcs = 0, Core = 0})
		Tw.play(charge.Light, {Brightness = 0}, 0.4, QUAD, IN, Z.Line)
		Debris:AddItem(charge, 1.5 * Tw.S())
		emit(sigil, {Dust = 2})
		kick(0.15)

		at(Z.Line, function()
			hide(line.Line, 0.05)
			emit(circle, {Flash = 1, Glint = 1, Specks = 40, Gust = 50, Hoops = 6, Star = 1, Shock = 2, Streak = 1})
			for _, b in ipairs(barrel) do
				emit(b[1], {Flash = 1, Shock = 1})
			end
			rates(circle, {Stream = 24})
			at(Z.Hold, function()
				rates(circle, {Stream = 0})
			end)
			if Z.Flash then
				flash()
			end
			kick(0.55)
			for _, name in ipairs({"Edge", "Fringe", "Glow", "Core"}) do
				local b = line[name]
				show(b, {w[b][1] * Z.Width, w[b][2] * Z.Width}, 0.06, BACK)
				hide(b, 0.18, Z.Hold)
			end
			local t0 = os.clock()
			local pulse
			at(0.08, function()
				pulse = RunService.RenderStepped:Connect(function()
					local t = (os.clock() - t0) / Tw.S()
					local k = Z.Width * (1 + 0.07 * math.sin(t * 40) + 0.05 * math.sin(t * 23))
					for _, name in ipairs({"Edge", "Fringe", "Glow", "Core"}) do
						local b = line[name]
						b.Width0, b.Width1 = w[b][1] * k, w[b][2] * k
					end
				end)
			end)
			at(Z.Hold - 0.02, function()
				pulse:Disconnect()
			end)
			rates(line, {Streaks = 90, Arcs = 40})
			at(Z.Hold, function()
				rates(line, {Streaks = 0, Arcs = 0})
			end)
			Debris:AddItem(line, (Z.Hold + 0.6) * Tw.S())

			local h = spawn("Blast", CFrame.new(finish))
			emit(h, {Flash = 1, Star = 1, Spikes = 1, Ring = 1, Ring2 = 1, Sparks = 40, Smoke = 14, Glint = 1, Rocks = hit and 18 or 0})
			spikes(finish, 2)
			h.Light.Brightness = 7
			Tw.play(h.Light, {Brightness = 0}, Z.Hold + 0.6, QUAD, IN)
			for i = 1, math.floor(Z.Hold / 0.1) do
				at(0.1 * i, function()
					emit(h, {Sparks = 8, Smoke = 3, Rocks = hit and 2 or 0})
				end)
			end
			at(Z.Hold, function()
				emit(h, {Ring2 = 1, Smoke = 10})
			end)
			Debris:AddItem(h, (Z.Hold + 2.5) * Tw.S())
		end)
	end)

	at(stop, function()
		close(0.3)
		sigilClose(0.4)
		for _, b in ipairs(barrel) do
			b[3](0.25)
		end
		rates(sigil, {Rise = 0, Lines = 0})
		at(0.45, function()
			conn:Disconnect()
			circle:Destroy()
			sigilConn:Disconnect()
			sigil:Destroy()
			for _, b in ipairs(barrel) do
				b[2]:Disconnect()
				b[1]:Destroy()
			end
		end)
	end)

	return stop + 0.45
end

function Frieren.volley(char)
	local V = Config.Volley
	local hrp = char.HumanoidRootPart
	local look = (hrp.CFrame.LookVector * Vector3.new(1, 0, 1)).Unit
	local right = look:Cross(Vector3.yAxis)
	local bolts = {}
	local fly = RunService.RenderStepped:Connect(function(dt)
		for b, s in pairs(bolts) do
			local step = look * V.Speed * dt / Tw.S()
			local hit = ray(s.pos, step, char)
			if hit or (s.pos - s.from).Magnitude > V.Range then
				bolts[b] = nil
				local spot = hit and hit.Position or s.pos
				local h = spawn("Hit", CFrame.new(spot))
				emit(h, {Flash = 1, Glint = 1, Ring = 1, Star = 1, Sparks = 16, Smoke = hit and 6 or 0, Debris = hit and 6 or 0})
				kick(0.1)
				h.Light.Brightness = 3
				Tw.play(h.Light, {Brightness = 0}, 0.3, QUAD, IN)
				Debris:AddItem(h, 1.3 * Tw.S())
				spikes(spot, 0.8)
				rates(b, {Glow = 0, Dashes = 0})
				for beam in pairs(beams(b)) do
					hide(beam, 0.06)
				end
				Debris:AddItem(b, 0.3 * Tw.S())
			else
				s.pos += step
				b.CFrame = CFrame.lookAt(s.pos, s.pos + look)
			end
		end
	end)

	local start = 0.15
	local last = start + (V.Count - 1) * V.Gap + V.Delay
	local sigil, sigilConn, sigilClose = floorCircle(char, 0.75, 0.3)
	rates(sigil, {Rise = 24, Lines = 10})
	at(last + 0.35, function()
		sigilClose(0.35)
		rates(sigil, {Rise = 0, Lines = 0})
		at(0.4, function()
			sigilConn:Disconnect()
			sigil:Destroy()
		end)
	end)
	for k = 0, V.Count - 1 do
		at(start + k * V.Gap, function()
			local off = Vector3.zero
			if k > 0 then
				local a = (k - 1) * 2 * math.pi / (V.Count - 1) + math.pi / 2
				off = (right * math.cos(a) + Vector3.yAxis * math.sin(a)) * V.Spread
			end
			local center = gem(char) + look * V.Ahead + off
			local c = spawn("SmallCircle", CFrame.lookAt(center, center + look))
			local conn, _, close = grow(c, 1, 0.18, 0.1, 4)
			at(V.Delay, function()
				emit(c, {Flash = 1, Glint = 1, Star = 1, Shock = 1})
				kick(0.12)
				local b = spawn("Bolt", CFrame.lookAt(center, center + look))
				rates(b, {Glow = 60, Dashes = 50, Rings = 40})
				bolts[b] = {pos = center, from = center}
			end)
			at(last - start - k * V.Gap + 0.35, function()
				close(0.25)
				at(0.3, function()
					conn:Disconnect()
					c:Destroy()
				end)
			end)
		end)
	end
	at(last + V.Range / V.Speed + 0.2, function()
		fly:Disconnect()
	end)
	return last + V.Range / V.Speed + 0.2
end

function Frieren.barrier(char)
	local B = Config.Barrier
	local hrp = char.HumanoidRootPart
	local shield = {on = true}
	local cells = {}
	local conn = RunService.RenderStepped:Connect(function()
		for c, off in pairs(cells) do
			c.CFrame = hrp.CFrame * off
		end
	end)

	local function place(dir, q, r)
		local right = (math.abs(dir.Y) > 0.95 and Vector3.zAxis or Vector3.yAxis):Cross(dir).Unit
		local up = dir:Cross(right)
		local s = B.Cell * B.Gap
		local x = 1.5 * s * q
		local y = math.sqrt(3) * s * (r + q / 2)
		local n = (dir * B.Radius + right * x + up * y).Unit
		local pos = Vector3.new(0, B.Lift, 0) + n * B.Radius
		return CFrame.lookAt(pos, pos + n, up)
	end

	local function open(off, delayTime, bright, list)
		at(delayTime, function()
			if not shield.on then
				return
			end
			for c, o in pairs(cells) do
				if (o.Position - off.Position).Magnitude < B.Cell then
					emit(c, {Flash = 1, Glint = bright and 1 or 0})
					return
				end
			end
			local c = spawn("Cell", hrp.CFrame * off)
			cells[c] = off
			for b, w in pairs(beams(c)) do
				show(b, w, 0.08)
			end
			if bright then
				emit(c, {Flash = 1, Glint = 1, Star = 1})
				kick(0.08)
			end
			if list then
				table.insert(list, c)
			end
		end)
	end

	local function close(c)
		cells[c] = nil
		emit(c, {Rings = 7, Shards = 5})
		for b in pairs(beams(c)) do
			hide(b, 0.12)
		end
		Debris:AddItem(c, 0.7 * Tw.S())
	end

	local ticks = spawn("Ticks", hrp.CFrame)
	for b, w in pairs(beams(ticks)) do
		b.Width0, b.Width1 = w[1], w[2]
		for i = 0, 3 do
			at(math.random() * 0.3, function()
				b.Enabled = i % 2 == 0
			end)
		end
	end
	at(0.36, function()
		ticks:Destroy()
	end)

	for q = -B.Rings, B.Rings do
		for r = -B.Rings, B.Rings do
			local ring = math.max(math.abs(q), math.abs(r), math.abs(q + r))
			if ring <= B.Rings then
				open(place(Vector3.new(0, 0, -1), q, r), 0.33 + ring * 0.12 + math.random() * 0.1 * math.min(ring, 1), ring == 0)
			end
		end
	end

	local near = {{1, 0}, {1, -1}, {0, -1}, {-1, 0}, {-1, 1}, {0, 1}}
	function shield.hit(point)
		local dir = hrp.CFrame:VectorToObjectSpace(point - (hrp.Position + Vector3.new(0, B.Lift, 0))).Unit
		local list = {}
		local spot = Vector3.new(0, B.Lift, 0) + dir * B.Radius
		for c, o in pairs(cells) do
			at((o.Position - spot).Magnitude / 25, function()
				if cells[c] then
					emit(c, {Flash = 1})
				end
			end)
		end
		local h = spawn("Hit", CFrame.new(hrp.CFrame * spot))
		emit(h, {Flash = 1, Star = 1, Ring = 1, Sparks = 14})
		Debris:AddItem(h, 1 * Tw.S())
		kick(0.18)
		open(place(dir, 0, 0), 0, true, list)
		local pick = math.random(1, 6)
		for i = 0, B.Cluster - 2 do
			local n = near[(pick + i - 1) % 6 + 1]
			open(place(dir, n[1], n[2]), 0.04 + 0.03 * i, false, list)
		end
		at(B.Life, function()
			for _, c in ipairs(list) do
				if cells[c] then
					close(c)
				end
			end
		end)
	end

	function shield.drop()
		shield.on = false
		local i = 0
		for c in pairs(cells) do
			i += 1
			at(0.025 * i, function()
				if cells[c] then
					close(c)
				end
			end)
		end
		at(0.3, function()
			conn:Disconnect()
		end)
	end

	return shield
end

function Frieren.flowers(char, opts)
	local F = setmetatable(opts or {}, {__index = Config.Flowers})
	local hrp = char.HumanoidRootPart
	local rarm, larm = char["Right Arm"], char["Left Arm"]
	local gather, release, bloomAt = 0.75, 0.75 + F.Gather, 0.75 + F.Gather + 0.35
	local k = F.Scale or 1
	local space = F.Space or 3.2

	updraft(char, {Motes = 10, Streaks = 3, Glints = 2}, release + 0.5)

	local cup, follow, charge
	at(gather, function()
		cup = spawn("Cup", CFrame.new((tip(rarm) + tip(larm)) / 2 + Vector3.new(0, 0.15 + (F.CupLift or 0), 0)))
		charge = spawn("Charge", cup.CFrame)
		rates(cup, {Core = F.Core or 24, Glints = 8, Lines = 10, Motes = 16})
		rates(charge, {Gather = 40, Arcs = 6, Core = F.Core and F.Core * 0.6 or 14})
		Tw.play(cup.Light, {Brightness = F.Light or 4}, F.Gather, QUAD, OUT)
		follow = RunService.RenderStepped:Connect(function()
			cup.CFrame = CFrame.new((tip(rarm) + tip(larm)) / 2 + Vector3.new(0, 0.15 + (F.CupLift or 0), 0))
			charge.CFrame = cup.CFrame
		end)
	end)

	local sigil, sigilConn, sigilClose
	at(release - 0.2, function()
		sigil, sigilConn, sigilClose = floorCircle(char, 1.2, 0.4)
		rates(sigil, {Rise = 40, Lines = 16})
		at(1.9, function()
			sigilClose(0.5)
			rates(sigil, {Rise = 0, Lines = 0})
			at(0.55, function()
				sigilConn:Disconnect()
				sigil:Destroy()
			end)
		end)
	end)

	at(release, function()
		follow:Disconnect()
		rates(cup, {Core = 0, Glints = 0, Lines = 0, Motes = 0})
		rates(charge, {Gather = 0, Arcs = 0, Core = 0})
		at(1, function()
			charge:Destroy()
		end)
		kick(0.2)
		Tw.play(cup.Light, {Brightness = 0}, 0.4, QUAD, IN)
		at(1.8, function()
			cup:Destroy()
		end)
		local rise = spawn("Rise", cup.CFrame)
		emit(rise, {Glint = 1})
		for b, w in pairs(beams(rise)) do
			show(b, w, 0.15)
			hide(b, 0.5, 0.6)
		end
		at(1.4, function()
			rise:Destroy()
		end)
	end)

	local floor = hrp.Position.Y - 3
	local spots = {}
	for _ = 1, F.Count * 3 do
		local r = F.Near + (F.Radius - F.Near) * math.sqrt(math.random())
		local a = math.random() * 2 * math.pi
		local x, z = hrp.Position.X + math.cos(a) * r, hrp.Position.Z + math.sin(a) * r
		local free = true
		for _, s in ipairs(spots) do
			if (s[1].X - x) ^ 2 + (s[1].Z - z) ^ 2 < space then
				free = false
				break
			end
		end
		local hit = free and ray(Vector3.new(x, floor + 5, z), Vector3.new(0, -12, 0), char)
		if hit then
			table.insert(spots, {hit.Position, r, math.random() * 2 * math.pi})
		end
		if #spots >= F.Count then
			break
		end
	end

	local shape = {}
	for _, p in ipairs(Vfx.Flower:GetChildren()) do
		shape[p.Name] = p.CFrame.Rotation + p.CFrame.Position * k
	end

	local growing, petals = {}, {}
	local bloom = RunService.RenderStepped:Connect(function()
		local t = now()
		local eye = workspace.CurrentCamera.CFrame.Position
		local moved, cfs = {}, {}
		for p, s in pairs(petals) do
			local age = t - s.t0
			if age > s.life then
				petals[p] = nil
				p:Destroy()
			else
				local sway = Vector3.new(math.sin(age * s.w) * 0.6, 0, math.cos(age * s.w * 0.7) * 0.4)
				p.CFrame = CFrame.new(s.pos + s.vel * age + sway) * CFrame.Angles(age * s.spin.X, age * s.spin.Y, age * s.spin.Z)
				p.Transparency = math.max(math.clamp((age - s.life + 0.5) / 0.5, 0, 1), 1 - math.clamp(((p.Position - eye).Magnitude - 3) / 3, 0, 1))
			end
		end
		for f, g in pairs(growing) do
			local u = math.min(1, (t - g[2]) / g[3])
			local y
			if g[4] then
				y = -0.5 * k * u * u
			else
				local s = 1.70158
				y = (-1.5 + 1.5 * (1 + (s + 1) * (u - 1) ^ 3 + s * (u - 1) ^ 2)) * k
			end
			if g[4] and u >= 1 then
				growing[f] = nil
				f:Destroy()
			else
				local base = g[1] * CFrame.new(0, y, 0)
				for _, p in ipairs(g[5]) do
					table.insert(moved, p)
					table.insert(cfs, base * shape[p.Name])
					if g[4] then
						p.Transparency = u * u
					end
				end
				if u >= 1 then
					growing[f] = nil
				end
			end
		end
		workspace:BulkMoveTo(moved, cfs, Enum.BulkMoveMode.FireCFrameChanged)
	end)

	at(bloomAt, function()
		local field = spawn("Bloom", CFrame.new(hrp.Position.X, floor, hrp.Position.Z))
		rates(field, {Drift = 30})
		local wave = spawn("Wave", CFrame.new(hrp.Position.X, floor + 0.3, hrp.Position.Z))
		emit(wave, {Ring = 1, Thin = 1, Star = 1})
		at(0.25, function()
			emit(wave, {Thin = 1})
		end)
		at(2, function()
			wave:Destroy()
		end)
		local pop = field.Pop
		for n, s in ipairs(spots) do
			at(s[2] / F.Speed, function()
				local base = CFrame.new(s[1]) * CFrame.Angles(0, s[3], 0)
				local f = spawn("Flower", base * CFrame.new(0, -1.5 * k, 0))
				if k ~= 1 then
					f:ScaleTo(f:GetScale() * k)
				end
				growing[f] = {base, now(), 0.3, false, f:GetChildren()}
				pop.WorldPosition = s[1] + Vector3.new(0, 1.2 * k, 0)
				emit(pop, {Specks = n % 2 == 0 and 3 or 0, Glint = 1})
				at(F.Life, function()
					growing[f] = {base, now(), 0.8, true, f:GetChildren()}
				end)
			end)
		end
		for _ = 1, F.Petals do
			at(math.random() * 3, function()
				local r = F.Radius * math.sqrt(math.random())
				local a = math.random() * 2 * math.pi
				local pos = Vector3.new(hrp.Position.X + math.cos(a) * r, floor + 0.4 + math.random() * 3, hrp.Position.Z + math.sin(a) * r)
				local p = spawn("Petal", CFrame.new(pos))
				petals[p] = {
					t0 = now(),
					pos = pos,
					vel = Vector3.new(2.6 + math.random() * 1.4, 0.3 + math.random() * 0.6, 1.1 + math.random() * 0.9),
					w = 2 + math.random() * 2,
					spin = Vector3.new(math.random() * 4 - 2, math.random() * 4 - 2, math.random() * 4 - 2),
					life = 2.5 + math.random() * 1.5,
				}
			end)
		end
		local last = F.Radius / F.Speed + F.Life + 1
		at(last - 1.5, function()
			rates(field, {Drift = 0})
		end)
		at(last, function()
			bloom:Disconnect()
			field:Destroy()
		end)
	end)

	return bloomAt + F.Radius / F.Speed + F.Life + 1
end

Frieren.kit = {
	at = at,
	spawn = spawn,
	beams = beams,
	show = show,
	hide = hide,
	rates = rates,
	emit = emit,
	ray = ray,
	ground = ground,
	floorCircle = floorCircle,
	grow = grow,
	gem = gem,
	spikes = spikes,
	updraft = updraft,
	flash = flash,
	fx = fx,
	now = now,
	clock = function(f, q)
		local base = now()
		if f then
			source = function()
				return base + f()
			end
		else
			source = nil
			offset = base - os.clock() / Tw.S()
		end
		queue = q
	end,
}

return Frieren
