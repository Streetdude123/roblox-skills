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

local function at(t, fn)
	task.delay(t * Tw.S(), fn)
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
	Tw.play(white, {BackgroundTransparency = 1}, 0.2, QUAD, IN, 0.08)
end

local function tip(arm)
	return (arm.CFrame * CFrame.new(0, -1, 0)).Position
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

	updraft(char, {Motes = 30, Streaks = 14, Glints = 4}, fire)

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

	local circle, base, parts, conn
	at(0.65, function()
		local center = tip(char["Right Arm"]) + look * Z.Ahead
		base = CFrame.lookAt(center, center + look)
		circle = spawn("Circle", base)
		parts = beams(circle)
		local spots = {}
		for _, a in ipairs(circle:GetChildren()) do
			if a:IsA("Attachment") then
				spots[a] = a.Position
			end
		end
		local k = Z.Radius / 3
		local start = os.clock()
		local spin, grown = 0, false
		conn = RunService.RenderStepped:Connect(function(dt)
			local e = (os.clock() - start) / Tw.S()
			local u = math.min(1, e / Z.Circle)
			local ease = 1 - (1 - u) ^ 4
			spin += dt / Tw.S() * (1.2 + 5 * (1 - ease))
			circle.CFrame = base * CFrame.Angles(0, 0, spin)
			if grown then
				return
			end
			local s = k * (0.35 + 0.65 * ease)
			for a, p in pairs(spots) do
				a.Position = p * s
			end
			for b, w in pairs(parts) do
				if b.Enabled or b:GetAttribute("Order") <= e / 0.3 then
					b.Enabled = true
					b.Width0, b.Width1 = w[1] * s, w[2] * s
					b.CurveSize0, b.CurveSize1 = w[3] * s, w[4] * s
				end
			end
			grown = u >= 1
		end)
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

		at(Z.Line, function()
			hide(line.Line, 0.05)
			emit(circle, {Flash = 1, Glint = 1, Specks = 24})
			if Z.Flash then
				flash()
			end
			for _, name in ipairs({"Edge", "Fringe", "Glow", "Core"}) do
				local b = line[name]
				show(b, {w[b][1] * Z.Width, w[b][2] * Z.Width}, 0.06, BACK)
				hide(b, 0.18, Z.Hold)
			end
			rates(line, {Streaks = 70})
			at(Z.Hold, function()
				rates(line, {Streaks = 0})
			end)
			Debris:AddItem(line, (Z.Hold + 0.6) * Tw.S())

			local h = spawn("Hit", CFrame.new(finish))
			emit(h, {Flash = 1, Glint = 1, Ring = 1, Sparks = 24, Smoke = 10})
			if hit then
				emit(h, {Debris = 12})
			end
			h.Light.Brightness = 3
			Tw.play(h.Light, {Brightness = 0}, Z.Hold + 0.3, QUAD, IN)
			for i = 1, math.floor(Z.Hold / 0.12) do
				at(0.12 * i, function()
					emit(h, {Sparks = 6, Smoke = 2})
				end)
			end
			Debris:AddItem(h, (Z.Hold + 1.5) * Tw.S())
		end)
	end)

	at(stop, function()
		for b in pairs(parts) do
			hide(b, 0.3)
		end
		at(0.35, function()
			conn:Disconnect()
			circle:Destroy()
		end)
	end)

	return stop + 0.35
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
		local right = Vector3.yAxis:Cross(dir).Unit
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
				emit(c, {Flash = 1, Glint = 1})
			end
			if list then
				table.insert(list, c)
			end
		end)
	end

	local function close(c)
		cells[c] = nil
		emit(c, {Rings = 5, Shards = 3})
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

function Frieren.flowers(char)
	local F = Config.Flowers
	local hrp = char.HumanoidRootPart
	local rarm, larm = char["Right Arm"], char["Left Arm"]
	local gather, release, bloomAt = 0.75, 0.75 + F.Gather, 0.75 + F.Gather + 0.35

	updraft(char, {Motes = 10, Streaks = 3, Glints = 2}, release + 0.5)

	local cup, follow
	at(gather, function()
		cup = spawn("Cup", CFrame.new((tip(rarm) + tip(larm)) / 2))
		rates(cup, {Core = 24, Glints = 5, Lines = 6, Motes = 10})
		Tw.play(cup.Light, {Brightness = 2.2}, F.Gather, QUAD, OUT)
		follow = RunService.RenderStepped:Connect(function()
			cup.CFrame = CFrame.new((tip(rarm) + tip(larm)) / 2 + Vector3.new(0, 0.15, 0))
		end)
	end)

	at(release, function()
		follow:Disconnect()
		rates(cup, {Core = 0, Glints = 0, Lines = 0, Motes = 0})
		Tw.play(cup.Light, {Brightness = 0}, 0.4, QUAD, IN)
		Debris:AddItem(cup, 1.8 * Tw.S())
		local rise = spawn("Rise", cup.CFrame)
		emit(rise, {Glint = 1})
		for b, w in pairs(beams(rise)) do
			show(b, w, 0.15)
			hide(b, 0.5, 0.6)
		end
		Debris:AddItem(rise, 1.4 * Tw.S())
	end)

	local floor = hrp.Position.Y - 3
	local spots = {}
	for _ = 1, F.Count * 3 do
		local r = F.Near + (F.Radius - F.Near) * math.sqrt(math.random())
		local a = math.random() * 2 * math.pi
		local x, z = hrp.Position.X + math.cos(a) * r, hrp.Position.Z + math.sin(a) * r
		local free = true
		for _, s in ipairs(spots) do
			if (s[1].X - x) ^ 2 + (s[1].Z - z) ^ 2 < 1.2 then
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

	local growing = {}
	local grow = RunService.RenderStepped:Connect(function()
		local now = os.clock()
		for f, g in pairs(growing) do
			local u = math.min(1, (now - g[2]) / (g[3] * Tw.S()))
			local y
			if g[4] then
				y = -0.3 * u * u
			else
				local s = 1.70158
				y = -0.9 + 0.9 * (1 + (s + 1) * (u - 1) ^ 3 + s * (u - 1) ^ 2)
			end
			f:PivotTo(g[1] * CFrame.new(0, y, 0))
			if u >= 1 then
				growing[f] = nil
				if g[4] then
					f:Destroy()
				end
			end
		end
	end)

	at(bloomAt, function()
		local field = spawn("Bloom", CFrame.new(hrp.Position.X, floor, hrp.Position.Z))
		rates(field, {Drift = 12})
		local pop = field.Pop
		for n, s in ipairs(spots) do
			at(s[2] / F.Speed, function()
				local base = CFrame.new(s[1]) * CFrame.Angles(0, s[3], 0)
				local f = spawn("Flower", base * CFrame.new(0, -0.9, 0))
				growing[f] = {base, os.clock(), 0.3}
				if n % 3 == 0 then
					pop.WorldPosition = s[1] + Vector3.new(0, 0.7, 0)
					emit(pop, {Specks = 3, Glint = 1})
				end
				at(F.Life, function()
					for _, p in ipairs(f:GetChildren()) do
						Tw.play(p, {Transparency = 1}, 0.8, QUAD, IN)
					end
					growing[f] = {base, os.clock(), 0.8, true}
				end)
			end)
		end
		local last = F.Radius / F.Speed + F.Life + 1
		at(last - 1.5, function()
			rates(field, {Drift = 0})
		end)
		at(last, function()
			grow:Disconnect()
			field:Destroy()
		end)
	end)

	return bloomAt + F.Radius / F.Speed + F.Life + 1
end

return Frieren
