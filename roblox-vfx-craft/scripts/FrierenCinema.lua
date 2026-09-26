local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")

local root = script.Parent.Parent
local Tw = require(script.Parent.Tw)
local Vfx = require(script.Parent.FrierenVfx)
local kit = Vfx.kit
local Assets = root.Assets
local Poser = require(root.Parent.Anim.Modules.Poser)
local DragonClips = require(root.Parent.Anim.Modules.ExampleDragon)
local Clips = require(root.Parent.Anim.Modules.ExampleFrieren)

local player = Players.LocalPlayer
local cam = workspace.CurrentCamera
local Grade = Lighting.Grade
local Focus = Lighting.DepthOfField
local V = Vector3.new
local QUAD, SINE = Enum.EasingStyle.Quad, Enum.EasingStyle.Sine
local OUT, IN, INOUT = Enum.EasingDirection.Out, Enum.EasingDirection.In, Enum.EasingDirection.InOut

local Cinema = {}

local view = {trauma = 0, frozen = 0, floor = 0}
local current

local function now()
	return current and current.t or os.clock() / Tw.S()
end

local function later(dt, fn)
	if current then
		current.after(dt, fn)
	else
		kit.at(dt, fn)
	end
end

local function cleanup(inst, life)
	later(life, function()
		inst:Destroy()
	end)
end

local function smooth(u)
	u = math.clamp(u, 0, 1)
	return u * u * (3 - 2 * u)
end

local function timeline(warps)
	local tl = {t = 0, rate = 1, events = {}, rigs = {}, emitters = {}}
	local function rateAt(t)
		for _, w in ipairs(warps) do
			if t >= w[1] and t < w[2] then
				local u = (t - w[1]) / (w[2] - w[1])
				local k = smooth(u / 0.25) * smooth((1 - u) / 0.25)
				return 1 - (1 - w[3]) * k
			end
		end
		return 1
	end
	local function retime(e)
		e.TimeScale = tl.rate / Tw.S()
	end
	for _, d in ipairs(kit.fx:GetDescendants()) do
		if d:IsA("ParticleEmitter") then
			tl.emitters[d] = true
		end
	end
	tl.added = kit.fx.DescendantAdded:Connect(function(d)
		if d:IsA("ParticleEmitter") then
			tl.emitters[d] = true
			retime(d)
		end
	end)
	function tl.at(t, fn)
		table.insert(tl.events, {t, fn})
		table.sort(tl.events, function(a, b)
			return a[1] < b[1]
		end)
	end
	function tl.after(dt, fn)
		tl.at(tl.t + dt, fn)
	end
	function tl.drive(r, clip, opts)
		r:play(clip, opts)
		tl.rigs[r] = tl.t
	end
	tl.conn = RunService.RenderStepped:Connect(function(dt)
		local r = rateAt(tl.t)
		local hold = root:GetAttribute("CineHold")
		if hold and tl.t >= hold then
			r = 0
		end
		tl.t += dt / Tw.S() * r
		if r ~= tl.rate then
			tl.rate = r
			for e in pairs(tl.emitters) do
				if e.Parent then
					retime(e)
				else
					tl.emitters[e] = nil
				end
			end
		end
		for rg, t0 in pairs(tl.rigs) do
			local a = rg.active
			if a then
				rg:setSpeed(math.max(0, r + (tl.t - t0 - a.time) * 4))
			end
		end
		while tl.events[1] and tl.events[1][1] <= tl.t do
			table.remove(tl.events, 1)[2]()
		end
	end)
	function tl.stop()
		tl.conn:Disconnect()
		tl.added:Disconnect()
		current = nil
		for _, e in ipairs(tl.events) do
			task.delay(math.max(0, e[1] - tl.t) * Tw.S(), e[2])
		end
		tl.events = {}
		for rg in pairs(tl.rigs) do
			rg:setSpeed(1)
		end
		for e in pairs(tl.emitters) do
			if e.Parent then
				e.TimeScale = 1 / Tw.S()
			end
		end
		kit.clock(nil)
		current = nil
	end
	current = tl
	kit.clock(function()
		return tl.t
	end, tl.after)
	return tl
end

local function kick(a)
	view.trauma = math.min(1, view.trauma + a)
end

local EASE = {
	sine = function(u)
		return 0.5 - 0.5 * math.cos(math.pi * u)
	end,
	out = function(u)
		return 1 - (1 - u) ^ 3
	end,
	inn = function(u)
		return u * u * u
	end,
	lin = function(u)
		return u
	end,
}

local function place(origin, p)
	return typeof(p) == "function" and p() or origin:PointToWorldSpace(p)
end

local function shoot(origin, shots)
	view.trauma, view.frozen, view.floor = 0, 0, 0
	cam.CameraType = Enum.CameraType.Scriptable
	RunService:BindToRenderStep("FrierenCine", Enum.RenderPriority.Camera.Value + 2, function(dt)
		local rate = current and current.rate or 1
		view.trauma = math.max(view.floor, view.trauma - dt * 1.4 / Tw.S() * rate)
		if os.clock() < view.frozen then
			return
		end
		local t = now()
		local shot = shots[1]
		for _, s in ipairs(shots) do
			if s.t <= t then
				shot = s
			end
		end
		local u = EASE[shot.ease or "sine"](math.clamp((t - shot.t) / shot.len, 0, 1))
		local a, b = shot.a, shot.b
		local from = place(origin, a[1]):Lerp(place(origin, b[1]), u)
		local look = place(origin, a[2]):Lerp(place(origin, b[2]), u)
		local roll = (a[4] or 0) + ((b[4] or 0) - (a[4] or 0)) * u
		local n = t * 0.45
		local drift = V(math.noise(n, 11.5), math.noise(n, 12.5), math.noise(n, 13.5)) * (shot.drift or 0.12)
		local k = view.trauma * view.trauma
		local s = t * 14
		local shake = CFrame.new(math.noise(s, 21.5) * k * 1.4, math.noise(s, 22.5) * k * 1.4, 0) * CFrame.Angles(math.noise(s, 23.5) * k * 0.03, math.noise(s, 24.5) * k * 0.03, math.noise(s, 25.5) * k * 0.05)
		cam.CFrame = CFrame.lookAt(from + drift, look) * CFrame.Angles(0, 0, math.rad(roll)) * shake
		cam.FieldOfView = a[3] + (b[3] - a[3]) * u
		local d = (look - from).Magnitude
		Focus.FocusDistance = shot.focus or d
		Focus.InFocusRadius = shot.depth or math.max(3, d * 0.4)
	end)
end

local function screen()
	return player.PlayerGui:WaitForChild("FrierenCinema")
end

local function fade(to, dur)
	Tw.play(screen().Fade, {BackgroundTransparency = 1 - to}, dur, SINE, INOUT)
end

local function whiteout(strength, hold, dur)
	local w = screen().White
	w.BackgroundTransparency = 1 - strength
	Tw.play(w, {BackgroundTransparency = 1}, dur, QUAD, IN, hold)
end

local function bars(on, dur)
	local g = screen()
	local h = on and 0.1 or 0
	Tw.play(g.Top, {Size = UDim2.fromScale(1, h)}, dur, SINE, INOUT)
	Tw.play(g.Bottom, {Size = UDim2.fromScale(1, h)}, dur, SINE, INOUT)
	Tw.play(g.Vignette, {GroupTransparency = on and 0.1 or 1}, dur, SINE, INOUT)
end

local saved

local function stage()
	saved = {
		exposure = Lighting.ExposureCompensation,
		brightness = Grade.Brightness,
		contrast = Grade.Contrast,
		saturation = Grade.Saturation,
		tint = Grade.TintColor,
		dof = Focus.Enabled,
		far = Focus.FarIntensity,
		near = Focus.NearIntensity,
		focus = Focus.FocusDistance,
		radius = Focus.InFocusRadius,
	}
	Focus.Enabled = true
	Focus.NearIntensity = 0
	Focus.FarIntensity = 0.28
end

local function grade(props, dur, style, dir)
	style, dir = style or SINE, dir or INOUT
	local g = {}
	for _, k in ipairs({"Brightness", "Contrast", "Saturation", "TintColor"}) do
		if props[k] then
			g[k] = props[k]
		end
	end
	if next(g) then
		Tw.play(Grade, g, dur, style, dir)
	end
	if props.Exposure then
		Tw.play(Lighting, {ExposureCompensation = saved.exposure + props.Exposure}, dur, style, dir)
	end
end

local function unstage()
	Lighting.ExposureCompensation = saved.exposure
	Grade.Brightness, Grade.Contrast, Grade.Saturation, Grade.TintColor = saved.brightness, saved.contrast, saved.saturation, saved.tint
	Focus.Enabled, Focus.FarIntensity, Focus.NearIntensity = saved.dof, saved.far, saved.near
	Focus.FocusDistance, Focus.InFocusRadius = saved.focus, saved.radius
end

local STYLES = {
	white = {Color3.new(1, 1, 1), Color3.fromRGB(10, 8, 18)},
	black = {Color3.fromRGB(8, 6, 14), Color3.new(1, 1, 1)},
	lilac = {Color3.fromRGB(204, 210, 233), Color3.fromRGB(22, 20, 36)},
}

local function frames(targets, steps)
	local imp = screen().Impact
	local vp = imp.View
	local lens = vp.CurrentCamera
	if not lens then
		lens = Instance.new("Camera")
		lens.Parent = vp
		vp.CurrentCamera = lens
	end
	local parts = {}
	for _, t in ipairs(targets) do
		for _, d in ipairs(t:GetDescendants()) do
			if d:IsA("BasePart") and d.Transparency < 1 then
				table.insert(parts, d)
			end
		end
	end
	view.frozen = os.clock() + 100
	lens.CFrame, lens.FieldOfView = cam.CFrame, cam.FieldOfView
	imp.Visible = true
	for _, step in ipairs(steps) do
		local style = STYLES[step[1]]
		for _, c in ipairs(vp:GetChildren()) do
			if c ~= lens then
				c:Destroy()
			end
		end
		imp.Bg.BackgroundColor3 = style[1]
		local dark = style[2].R + style[2].G + style[2].B < 1.5
		vp.Ambient = dark and style[2] or Color3.new(1, 1, 1)
		for _, p in ipairs(parts) do
			local c = p:Clone()
			for _, x in ipairs(c:GetChildren()) do
				if not x:IsA("DataModelMesh") and not x:IsA("Bone") then
					x:Destroy()
				end
			end
			c.Anchored = true
			c.Material = dark and Enum.Material.SmoothPlastic or Enum.Material.Neon
			c.Color = dark and Color3.new(1, 1, 1) or style[2]
			if c:IsA("MeshPart") then
				c.TextureID = ""
			end
			c.CFrame = p.CFrame
			c.Parent = vp
		end
		task.wait(step[2] * Tw.S())
	end
	imp.Visible = false
	for _, c in ipairs(vp:GetChildren()) do
		if c ~= lens then
			c:Destroy()
		end
	end
	view.frozen = 0
end

local function dragon(cf, tl)
	local d = Assets.Dragon:Clone()
	for _, p in ipairs(d:GetDescendants()) do
		if p:IsA("BasePart") then
			p.Color = Color3.fromRGB(58, 44, 56)
			p.Material = Enum.Material.SmoothPlastic
		end
	end
	d:PivotTo(cf)
	d.Parent = kit.fx
	local r = Poser.attach(d)
	local bones = {}
	for _, b in ipairs(d:GetDescendants()) do
		if b:IsA("Bone") then
			local n = b.Name:gsub("%.%d+$", "")
			r.joints[n] = {motor = b, r = CFrame.identity, rinv = CFrame.identity}
			bones[n] = b
		end
	end
	local st = {cf = cf, model = d, rig = r, bones = bones, trails = {}}
	for _, side in ipairs({"l_", "r_"}) do
		table.insert(st.trails, {kit.spawn("WingTrail", cf), bones[side .. "fingerD_04"]})
	end
	function st.chest()
		return bones.spine_06.TransformedWorldCFrame.Position
	end
	function st.mouth()
		local h = bones.head.TransformedWorldCFrame.Position
		local n = bones.neck_06.TransformedWorldCFrame.Position
		return h + (h - n).Unit * 3.5
	end
	st.conn = RunService.RenderStepped:Connect(function()
		d:PivotTo(st.cf)
		for _, w in ipairs(st.trails) do
			w[1].CFrame = w[2].TransformedWorldCFrame
		end
		if st.maw then
			st.maw.CFrame = CFrame.new(st.mouth())
		end
	end)
	function st.play(name, fade, after)
		local opts = {fadeIn = fade or 0.25, onDone = after and function()
			st.play(after, 0.3)
		end}
		if tl then
			tl.drive(r, DragonClips[name], opts)
		else
			r:play(DragonClips[name], opts)
		end
	end
	function st.wings(on)
		for _, w in ipairs(st.trails) do
			w[1].Trail.Enabled = on
		end
	end
	function st.clear()
		st.conn:Disconnect()
		r:stop(0)
		for _, w in ipairs(st.trails) do
			w[1]:Destroy()
		end
		if st.maw then
			st.maw:Destroy()
		end
		d:Destroy()
	end
	return st
end

local function blast(pos, list, light, life)
	local h = kit.spawn("Blast", CFrame.new(pos))
	kit.emit(h, list)
	h.Light.Brightness = light or 0
	Tw.play(h.Light, {Brightness = 0}, 1.2, QUAD, IN)
	cleanup(h, life or 4)
	return h
end

local function dustWave(center, reach, count)
	local d = kit.spawn("DustWave", CFrame.new(center))
	for ring = 0, 2 do
		later(ring * 0.07, function()
			for i = 0, count - 1 do
				local a = (i + ring * 0.5) / count * 2 * math.pi
				local dir = V(math.cos(a), 0, math.sin(a))
				local p = center + dir * reach * (0.25 + ring * 0.2) + V(0, 0.6, 0)
				d.CFrame = CFrame.lookAt(p, p + dir)
				d.Dust:Emit(2)
				if ring == 0 then
					d.Grit:Emit(1)
				end
			end
		end)
	end
	cleanup(d, 3.5)
	return d
end

local function gale(at, toward, list, dur)
	local g = kit.spawn("Gale", CFrame.lookAt(at, at - toward))
	kit.rates(g, list)
	later(dur, function()
		kit.rates(g, {Streaks = 0, Dust = 0, Bits = 0})
	end)
	cleanup(g, dur + 1.5)
	return g
end

local function handback(char, parts, finish)
	RunService:UnbindFromRenderStep("FrierenCine")
	for _, p in ipairs(parts) do
		if typeof(p) == "RBXScriptConnection" then
			p:Disconnect()
		elseif typeof(p) == "Instance" then
			p:Destroy()
		else
			p()
		end
	end
	if current and current.stop then
		current.stop()
	end
	current = nil
	if saved then
		unstage()
		saved = nil
	end
	local g = screen()
	g.Top.Size, g.Bottom.Size = UDim2.fromScale(1, 0), UDim2.fromScale(1, 0)
	g.Vignette.GroupTransparency = 1
	cam.CameraType = Enum.CameraType.Custom
	cam.FieldOfView = 70
	local hrp = char.HumanoidRootPart
	cam.CFrame = CFrame.lookAt(hrp.Position - hrp.CFrame.LookVector * 12 + V(0, 5, 0), hrp.Position + V(0, 1.5, 0))
	finish()
	fade(0, 0.6)
end

local function circle(center, dir, k, dur, flip)
	local c = kit.spawn("Circle", CFrame.lookAt(center, center + dir) * CFrame.Angles(0, flip and math.pi or 0, 0))
	local conn, _, close = kit.grow(c, k, dur, 0.8, 8)
	return c, conn, close
end

local function beam(from, to, width, hold)
	local len = (to - from).Magnitude
	local line = kit.spawn("Beam", CFrame.lookAt((from + to) / 2, to))
	line.Size = V(1.2, 1.2, len)
	line.Start.Position = V(0, 0, len / 2)
	line.Finish.Position = V(0, 0, -len / 2)
	local w = kit.beams(line)
	for _, name in ipairs({"Edge", "Fringe", "Glow", "Core"}) do
		local b = line[name]
		kit.show(b, {w[b][1] * width, w[b][2] * width}, 0.07, Enum.EasingStyle.Back)
		kit.hide(b, 0.25, hold)
	end
	kit.rates(line, {Streaks = 120, Arcs = 60})
	local t0 = now()
	local pulse = RunService.RenderStepped:Connect(function()
		local t = now() - t0
		if t < 0.08 or t > hold then
			return
		end
		local k = width * (1 + 0.07 * math.sin(t * 40) + 0.05 * math.sin(t * 23))
		for _, name in ipairs({"Edge", "Fringe", "Glow", "Core"}) do
			local b = line[name]
			b.Width0, b.Width1 = w[b][1] * k, w[b][2] * k
		end
	end)
	later(hold, function()
		pulse:Disconnect()
		kit.rates(line, {Streaks = 0, Arcs = 0})
	end)
	cleanup(line, hold + 0.8)
	return line
end

function Cinema.zoltraak(char, finish, body)
	local hrp = char.HumanoidRootPart
	local sun = Lighting:GetSunDirection()
	local look = V(sun.X, 0, sun.Z).Unit
	hrp.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + look)
	local origin = hrp.CFrame
	local function P(x, y, z)
		return origin:PointToWorldSpace(V(x, y, z))
	end
	local floor = kit.ground(hrp.Position, char)
	local tl = timeline({{2.86, 3.26, 0.3}, {9.7, 10.14, 0.18}, {10.3, 10.52, 0.45}})
	stage()
	tl.drive(body, Clips.ZoltraakCine, {fadeIn = 0.15})

	local landFloor = kit.ground(P(0, 0, -50), char)
	local land = landFloor + V(0, 6.2, 0)
	local from, ctrl = P(-70, 34, -250), P(40, 30, -120)
	local drag = dragon(CFrame.lookAt(from, ctrl), tl)
	drag.play("Fly", 0)
	drag.wings(true)
	tl.at(1.5, function()
		drag.play("Land", 0.3, "Idle")
	end)
	tl.at(3.38, function()
		drag.play("Roar", 0.3, "Idle")
	end)
	tl.at(9.2, function()
		drag.play("Roar", 0.3)
	end)
	tl.at(10.3, function()
		drag.play("Hit", 0.06)
	end)
	tl.at(11.0, function()
		drag.play("Hit", 0.1)
	end)
	tl.at(11.8, function()
		drag.play("Down", 0.2)
	end)

	local face = V(hrp.Position.X - land.X, 0, hrp.Position.Z - land.Z).Unit
	local path = RunService.RenderStepped:Connect(function()
		local t = tl.t
		if t < 2.9 then
			local s = 1 - (1 - t / 2.9) ^ 1.7
			local q = 1 - s
			local pos = from * q * q + ctrl * 2 * q * s + land * s * s
			local vel = (ctrl - from) * 2 * q + (land - ctrl) * 2 * s
			local w = smooth((t - 1.5) / 1.3)
			local dir = vel.Unit:Lerp(face, w)
			drag.cf = CFrame.lookAt(pos, pos + dir) * CFrame.Angles(0, 0, math.sin(t * 1.4) * 0.35 * (1 - w))
			return
		end
		local base = land + face * 2.5 * EASE.out(math.min(1, (t - 2.9) / 0.6))
		local pos = base - V(0, 0.8 * math.sin(math.pi * math.min(1, (t - 2.9) / 0.5)), 0)
		if t >= 10.3 then
			local u = EASE.out(math.min(1, (t - 10.3) / 1.3))
			pos = base - face * 9 * u + V(math.noise(t * 9, 1.5), 0, math.noise(t * 9, 2.5)) * 0.4 * (1 - u)
		end
		if t >= 11.8 then
			local u = math.min(1, (t - 11.8) / 0.8)
			pos = base - face * (9 + 2 * u) - V(0, 2.4 * u * u, 0)
		end
		drag.cf = CFrame.lookAt(pos, pos + face)
	end)

	local function flat()
		local p = drag.cf.Position
		local f = drag.cf.LookVector * V(1, 0, 1)
		return CFrame.lookAt(p, p + f.Unit)
	end
	local function above(p)
		return V(p.X, math.max(p.Y, floor.Y + 3.6), p.Z)
	end
	local function side()
		return above(flat() * V(-34, -1, 10))
	end
	local function ahead()
		return flat() * V(0, 0, -10)
	end
	local shots = {
		{t = 0, len = 1.7, a = {V(3.8, -0.2, 11), V(-2, 4.5, -60), 46}, b = {V(3.3, 0, 9.8), V(-1, 4.5, -60), 44}},
		{t = 1.7, len = 1.05, a = {side, ahead, 50, -2}, b = {side, ahead, 46, 2}, drift = 0.3},
		{t = 2.75, len = 1.15, a = {V(5, 1.8, 7), V(-1, 4.5, -48), 36}, b = {V(4.4, 2, 5.5), V(-1, 5, -48), 34, 1}, ease = "out"},
		{t = 3.9, len = 0.65, a = {V(4.2, 1.6, 7), V(0, 6.5, -26), 44}, b = {V(3.8, 1.4, 6), V(0, 7.5, -26), 40, -2}},
		{t = 4.55, len = 0.75, a = {V(-4, 1.1, -3.6), V(0, 1, 0), 40, 2}, b = {V(-3.5, 1.2, -3.1), V(0, 1, 0), 38, 3}},
		{t = 5.3, len = 1, a = {V(0.8, 1.45, -3.4), V(0, 1.5, 0), 32}, b = {V(0.6, 1.5, -2.8), V(0, 1.55, 0), 29}, drift = 0.04},
		{t = 6.3, len = 0.5, a = {V(-4.5, 1, -6.5), V(0, 1.6, 0), 46}, b = {V(-5.2, 1.2, -5.5), V(0, 1.4, 0), 44, 2}},
		{t = 6.8, len = 0.7, a = {V(-6.5, 5, -6.5), V(0, -2, -0.5), 55}, b = {V(-7.5, 8, -7.5), V(0, -2.5, -1), 58, 3}, ease = "out"},
		{t = 7.5, len = 1.1, a = {V(5, 2.2, 10), V(0.4, 2.2, -14), 48}, b = {V(4.2, 2.2, 8.4), V(0.3, 2.4, -14), 45}},
		{t = 8.6, len = 0.65, a = {V(-10, 3, -14), V(0.8, 1.8, -3), 42}, b = {V(-8.5, 2.8, -12.5), V(0.8, 1.8, -3), 38}},
		{t = 9.25, len = 0.35, a = {V(-7, 2.4, -19), drag.mouth, 44}, b = {V(-6.4, 2.2, -20), drag.mouth, 40, -3}},
		{t = 9.6, len = 0.35, a = {V(-0.8, 1.2, -3), V(0.12, 1.2, -0.9), 20}, b = {V(-0.7, 1.2, -2.7), V(0.12, 1.2, -0.9), 17}, drift = 0.02},
		{t = 9.95, len = 0.35, a = {V(-8, 2.4, -6), V(0.4, 1.9, -8), 40}, b = {V(-7.6, 2.4, -6.3), V(0.4, 1.9, -8), 37}, drift = 0.03},
		{t = 10.3, len = 1.4, a = {V(34, 3, -8), V(0, 4, -22), 58, 4}, b = {V(32, 3.6, -11), V(0, 4, -24), 55, 2}},
		{t = 11.7, len = 1, a = {V(-12, 3, -14), drag.chest, 46}, b = {V(-11, 2.6, -16), drag.chest, 44, -2}},
		{t = 12.7, len = 2.3, a = {V(-3.5, 0.6, 7.5), V(0, 2, -40), 48}, b = {V(-6, 5, 17), V(0, 3.5, -50), 54}, ease = "out"},
	}
	screen().Fade.BackgroundTransparency = 0
	shoot(origin, shots)
	bars(true, 0.8)
	fade(0, 0.9)

	tl.at(2.2, function()
		dustWave(landFloor, 8, 12)
	end)
	tl.at(2.55, function()
		dustWave(landFloor, 11, 14)
	end)
	tl.at(2.9, function()
		drag.wings(false)
		blast(landFloor + V(0, 1, 0), {Smoke = 8, Rocks = 10, Ring = 1}, 3, 5)
		dustWave(landFloor, 18, 14)
		kick(0.75)
	end)
	tl.at(3.15, function()
		gale(P(0, 0.5, -9), -look, {Dust = 26}, 0.7)
	end)
	tl.at(4.08, function()
		local m = drag.mouth()
		blast(m, {Ring = 1, Ring2 = 2}, 0, 2)
		for i = 1, 4 do
			later(0.22 * i, function()
				blast(drag.mouth(), {Ring2 = 1}, 0, 1.5)
			end)
		end
		gale(P(0, 1, -10), -look, {Streaks = 110, Dust = 40, Bits = 40}, 1.1)
		kick(0.6)
		view.floor = 0.32
		grade({Contrast = 0.22}, 0.2)
	end)
	tl.at(5.2, function()
		view.floor = 0
		grade({Contrast = saved.contrast}, 0.8)
	end)

	local draft
	tl.at(5.6, function()
		draft = kit.updraft(char, {Motes = 16, Streaks = 4, Glints = 2}, 9)
	end)
	local sigil, sigilConn, sigilClose
	tl.at(6.8, function()
		sigil, sigilConn, sigilClose = kit.floorCircle(char, 1.6, 0.8)
		kit.rates(sigil, {Rise = 50, Lines = 20})
		local w = kit.spawn("Wave", CFrame.new(floor + V(0, 0.3, 0)))
		kit.emit(w, {Ring = 1, Thin = 1})
		cleanup(w, 2)
		dustWave(floor, 7, 16)
		kick(0.35)
		kit.rates(draft, {Motes = 18, Streaks = 6, Glints = 3})
	end)
	tl.at(6.9, function()
		local p = kit.spawn("Pillars", hrp.CFrame)
		local i = 0
		for b, w in pairs(kit.beams(p)) do
			i += 1
			b.Width0, b.Width1 = 0, 0
			later(0.03 * i, function()
				kit.show(b, {w[1] * 1.4, w[2] * 1.4}, 0.15)
				kit.hide(b, 0.4, 0.8)
			end)
		end
		cleanup(p, 4)
	end)

	local rings, charge, center = {}, nil, nil
	tl.at(7.55, function()
		center = kit.gem(char) + look * 2.5
		table.insert(rings, {circle(center, look, 1.2, 2.8)})
		for i, step in ipairs({{2.2, 0.8}, {4, 0.55}}) do
			later(0.15 * i, function()
				table.insert(rings, {circle(center + look * step[1], look, 1.2 * step[2], 2.6, i % 2 == 1)})
			end)
		end
		charge = kit.spawn("Charge", CFrame.lookAt(center, center + look))
		kit.rates(charge, {Gather = 80, Arcs = 14, Core = 14})
		Tw.play(charge.Light, {Brightness = 2}, 2.8, QUAD, IN)
		kick(0.2)
	end)
	tl.at(8.6, function()
		grade({Exposure = -0.55, Saturation = saved.saturation - 0.35}, 1.4)
	end)
	tl.at(9.0, function()
		kit.rates(charge, {Gather = 150, Arcs = 24, Core = 24})
	end)
	tl.at(9.25, function()
		drag.maw = kit.spawn("Maw", CFrame.new(drag.mouth()))
		kit.rates(drag.maw, {Core = 30, Gather = 40, Embers = 24, Smoke = 10})
		Tw.play(drag.maw.Light, {Brightness = 5}, 1, QUAD, IN)
	end)
	tl.at(10.0, function()
		local target = drag.chest()
		local len = (target - center).Magnitude
		local line = kit.spawn("Beam", CFrame.lookAt((center + target) / 2, target))
		line.Size = V(1.2, 1.2, len)
		line.Start.Position = V(0, 0, len / 2)
		line.Finish.Position = V(0, 0, -len / 2)
		local w = kit.beams(line)
		kit.show(line.Line, w[line.Line], 0.03)
		kit.hide(line.Line, 0.05, 0.12)
		cleanup(line, 1)
		kick(0.2)
	end)
	tl.at(10.14, function()
		task.spawn(frames, {char, drag.model}, {{"white", 0.05}, {"black", 0.05}, {"white", 0.04}})
	end)
	tl.at(10.3, function()
		whiteout(1, 0.1, 0.5)
		grade({Exposure = 0.9, Saturation = saved.saturation}, 0.05)
		later(0.12, function()
			grade({Exposure = 0}, 0.9)
		end)
		kick(0.85)
		kit.rates(charge, {Gather = 0, Arcs = 0, Core = 0})
		Tw.play(charge.Light, {Brightness = 0}, 0.6, QUAD, IN)
		kit.emit(rings[1][1], {Flash = 1, Glint = 1, Specks = 50, Gust = 70, Hoops = 8, Star = 1, Shock = 3, Streak = 1})
		kit.rates(rings[1][1], {Stream = 30})
		for i = 2, #rings do
			kit.emit(rings[i][1], {Flash = 1, Shock = 1})
		end
		local target = drag.chest()
		beam(center, target, 2.1, 2.05)
		blast(target, {Flash = 1, Star = 1, Spikes = 1, Ring = 1, Ring2 = 1, Sparks = 60, Smoke = 20, Glint = 1, Rocks = 10}, 9, 4)
		kit.emit(drag.maw, {Burst = 1, Embers = 60})
		kit.rates(drag.maw, {Core = 0, Gather = 0, Embers = 0, Smoke = 0})
		Tw.play(drag.maw.Light, {Brightness = 0}, 0.4, QUAD, IN)
		gale(P(0, 1, -3), -look, {Streaks = 160, Dust = 30}, 0.45)
		dustWave(floor, 11, 9)
		for i = 1, 18 do
			later(0.1 * i, function()
				blast(drag.chest(), {Sparks = 10, Smoke = 3}, 0, 2)
			end)
		end
	end)
	for i, t in ipairs({10.62, 10.95}) do
		tl.at(t, function()
			local p = drag.chest() + V(math.random() * 6 - 3, math.random() * 4, math.random() * 6 - 3)
			blast(p, {Flash = 1, Star = 1, Ring2 = 1, Sparks = 30, Smoke = 12}, 5, 3)
			kick(0.3 / i)
		end)
	end
	tl.at(12.35, function()
		kit.rates(rings[1][1], {Stream = 0})
		for _, r in ipairs(rings) do
			r[3](0.35)
		end
		sigilClose(0.5)
		kit.rates(sigil, {Rise = 0, Lines = 0})
		kit.rates(draft, {Motes = 10, Streaks = 2, Glints = 2})
	end)
	tl.at(12.6, function()
		local p = drag.chest()
		local g = kit.ground(p, char)
		blast(g + V(0, 1, 0), {Flash = 1, Ring = 1, Smoke = 50, Rocks = 16, Sparks = 20}, 4, 6)
		dustWave(g, 24, 26)
		kick(0.8)
	end)
	for i = 0, 5 do
		tl.at(12.9 + i * 0.3, function()
			blast(drag.chest() + V(0, 3, 0), {Smoke = 3, Sparks = 4}, 0, 3)
		end)
	end
	tl.at(14.2, function()
		fade(1, 0.8)
	end)
	tl.at(15.0, function()
		local list = {path, sigilConn, sigil, charge, drag.clear}
		for _, r in ipairs(rings) do
			table.insert(list, r[2])
			table.insert(list, r[1])
		end
		handback(char, list, finish)
	end)
end

function Cinema.volley(char, finish, body, clip)
	local hrp = char.HumanoidRootPart
	local sun = Lighting:GetSunDirection()
	local look = V(sun.X, 0, sun.Z).Unit
	hrp.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + look)
	local origin = hrp.CFrame
	local function P(x, y, z)
		return origin:PointToWorldSpace(V(x, y, z))
	end
	local floor = kit.ground(hrp.Position, char)
	local tl = timeline({{8.12, 8.42, 0.25}, {9.55, 9.78, 0.4}})
	stage()
	tl.drive(body, clip, {fadeIn = 0.15})

	local from, ctrl, hover = P(-150, 9, -80), P(-50, 7, -46), P(0, 14, -34)
	local landFloor = kit.ground(P(0, 0, -46), char)
	local drag = dragon(CFrame.lookAt(from, ctrl), tl)
	drag.play("Fly", 0)
	drag.wings(true)
	tl.at(1.9, function()
		drag.play("Hover", 0.5)
	end)
	tl.at(2.75, function()
		drag.play("AirRoar", 0.3, "Hover")
	end)
	tl.at(8.3, function()
		drag.play("AirHit", 0.05)
	end)
	tl.at(8.8, function()
		drag.play("Down", 0.3)
	end)

	local face = V(hrp.Position.X - hover.X, 0, hrp.Position.Z - hover.Z).Unit
	local shove, sink, shake = 0, 0, 0
	local blown
	local path = RunService.RenderStepped:Connect(function()
		local t = tl.t
		if t < 2.7 then
			local s = 1 - (1 - t / 2.7) ^ 2.2
			local q = 1 - s
			local pos = from * q * q + ctrl * 2 * q * s + hover * s * s
			local vel = (ctrl - from) * 2 * q + (hover - ctrl) * 2 * s
			local w = smooth((t - 1.8) / 0.9)
			local dir = (vel * V(1, 0.3, 1)).Unit:Lerp(face, w)
			drag.cf = CFrame.lookAt(pos, pos + dir) * CFrame.Angles(0, 0, math.sin(t * 2.2) * 0.3 * (1 - w))
			return
		end
		shake = math.max(0, shake - 0.08)
		local pos = hover - face * shove + V(0, 0.8 * math.sin(2 * math.pi * t) - sink, 0) + V(math.noise(t * 12, 1.5), math.noise(t * 12, 2.5), 0) * shake
		if t >= 8.3 then
			blown = blown or pos
			local u = math.min(1, (t - 8.3) / 0.4)
			pos = blown - face * 8 * EASE.out(u) + V(0, 2 * u, 0)
			if t >= 8.7 then
				local f = math.min(1, (t - 8.7) / 0.9)
				local top = blown - face * 8 + V(0, 2, 0)
				local low = V(landFloor.X, landFloor.Y + 6.2, landFloor.Z) - face * (shove + 11)
				pos = top:Lerp(V(low.X, top.Y, low.Z), f) - V(0, (top.Y - low.Y) * f * f, 0)
			end
			if t >= 9.6 then
				pos -= V(0, 2.4 * math.min(1, (t - 9.6) / 0.3), 0)
			end
		end
		drag.cf = CFrame.lookAt(pos, pos + face)
	end)

	local function flat()
		local p = drag.cf.Position
		local f = drag.cf.LookVector * V(1, 0, 1)
		return CFrame.lookAt(p, p + f.Unit)
	end
	local function above(p)
		return V(p.X, math.max(p.Y, floor.Y + 3.6), p.Z)
	end
	local function side()
		return above(flat() * V(24, -3, -8))
	end
	local function nose()
		return flat() * V(0, 1, -12)
	end
	local function back()
		return flat() * V(14, 14, 4)
	end
	local function her()
		return hrp.Position + V(0, 0.5, 0)
	end
	local shots = {
		{t = 0, len = 1.75, a = {side, nose, 56, -3}, b = {side, nose, 52, 2}, drift = 0.3},
		{t = 1.75, len = 1, a = {V(3.4, 1.2, 6.5), V(-6, 8, -40), 50}, b = {V(2.9, 1.3, 5.2), V(0, 11, -34), 46}},
		{t = 2.75, len = 1.2, a = {V(-40, 8, -8), V(0, 11, -24), 50}, b = {V(-38, 9, -11), V(0, 11.5, -25), 48, 2}},
		{t = 3.95, len = 1, a = {back, her, 55}, b = {back, her, 52, -2}, drift = 0.2},
		{t = 4.95, len = 1.1, a = {V(-22, 6, -44), drag.chest, 52}, b = {V(-14, 9, -58), drag.chest, 50, 3}},
		{t = 6.05, len = 0.95, a = {V(-3.6, 1.6, -4), V(0, 1.4, 0), 42}, b = {V(-3.1, 1.8, -3.5), V(0, 1.5, 0), 40, 2}},
		{t = 7.0, len = 0.7, a = {V(-4, 0.8, -26), drag.chest, 60}, b = {V(-3.5, 0.6, -27), drag.chest, 58}},
		{t = 7.7, len = 0.6, a = {V(-7, 1.8, -2), V(0.4, 1.8, -2), 44}, b = {V(-6.3, 1.9, -2.6), V(0.4, 1.8, -2), 40}, drift = 0.04},
		{t = 8.45, len = 1.45, a = {V(30, 6, -14), drag.chest, 58, 3}, b = {V(28, 5, -17), drag.chest, 56}},
		{t = 9.9, len = 2.7, a = {V(3.5, 0.6, 7.5), V(0, 2, -40), 48}, b = {V(5.5, 4.5, 15), V(0, 3, -48), 54}, ease = "out"},
	}
	screen().Fade.BackgroundTransparency = 0
	shoot(origin, shots)
	bars(true, 0.8)
	fade(0, 0.8)

	for i = 0, 7 do
		tl.at(0.3 + i * 0.3, function()
			local p = kit.ground(drag.cf.Position, char)
			dustWave(p, 7, 6)
		end)
	end
	local sigil, sigilConn, sigilClose
	tl.at(2.0, function()
		sigil, sigilConn, sigilClose = kit.floorCircle(char, 1.2, 0.5)
		kit.rates(sigil, {Rise = 40, Lines = 16})
		local w = kit.spawn("Wave", CFrame.new(floor + V(0, 0.3, 0)))
		kit.emit(w, {Ring = 1, Thin = 1})
		cleanup(w, 2)
		kick(0.15)
	end)
	tl.at(2.8, function()
		drag.wings(false)
	end)
	local small, main = {}, nil
	tl.at(2.4, function()
		local g = kit.gem(char)
		local dir = (hover - g).Unit
		main = {circle(g + dir * 1.6, dir, 0.8, 1.2)}
	end)
	tl.at(3.0, function()
		local chest = drag.chest()
		local toward = (V(hrp.Position.X, chest.Y, hrp.Position.Z) - chest).Unit
		local across = toward:Cross(Vector3.yAxis)
		for i = 0, 11 do
			later(0.075 * i, function()
				local a = math.rad(-70 + 140 * i / 11) + (math.random() - 0.5) * 0.2
				local dir = toward * math.cos(a) + across * math.sin(a)
				local p = chest + dir * (13 + math.random() * 4) + V(0, -3 + i % 4 * 3 + math.random() * 2, 0)
				local c = kit.spawn("SmallCircle", CFrame.lookAt(p, chest) * CFrame.Angles(0, 0, math.random() * 6.28))
				local conn, _, close = kit.grow(c, 1.1 + math.random() * 0.5, 0.25, 0.1, 4)
				kit.emit(c, {Flash = 1, Glint = 1})
				table.insert(small, {c, conn, close, p})
			end)
		end
	end)
	tl.at(3.3, function()
		blast(drag.mouth(), {Ring = 1, Ring2 = 2}, 0, 2)
		for i = 1, 3 do
			later(0.22 * i, function()
				blast(drag.mouth(), {Ring2 = 1}, 0, 1.5)
			end)
		end
		gale(P(0, 1, -10), -look, {Streaks = 90, Dust = 26, Bits = 24}, 0.8)
		kick(0.4)
		view.floor = 0.22
	end)
	tl.at(3.95, function()
		view.floor = 0
	end)

	local bolts, hits = {}, 0
	local fly = RunService.RenderStepped:Connect(function(dt)
		for b, s in pairs(bolts) do
			local target = drag.chest() + s.off
			local dir = (target - s.pos).Unit
			local step = s.speed * dt / Tw.S() * tl.rate
			if (target - s.pos).Magnitude <= step then
				bolts[b] = nil
				if s.big then
					blast(target, {Flash = 1, Glint = 1}, 4, 1)
				else
					local h = kit.spawn("Hit", CFrame.new(target))
					kit.emit(h, {Glint = 1, Ring = 1, Star = 1, Sparks = 12, Smoke = 3, Debris = 2})
					cleanup(h, 1.3)
					hits += 1
					shove = math.min(6, shove + 0.28)
					sink = math.min(2.5, sink + 0.1)
					shake = 0.6
					if hits % 3 == 0 then
						drag.play("AirHit", 0.05, "Hover")
						kick(0.12)
					else
						kick(0.05)
					end
				end
				kit.rates(b, {Glow = 0, Dashes = 0, Rings = 0})
				for beam in pairs(kit.beams(b)) do
					kit.hide(beam, 0.06)
				end
				cleanup(b, 0.3)
			else
				s.pos += dir * step
				b.CFrame = CFrame.lookAt(s.pos, s.pos + dir)
			end
		end
	end)
	local function fire(at, big)
		local target = drag.chest()
		local b = kit.spawn("Bolt", CFrame.lookAt(at, target))
		if big then
			for beam, w in pairs(kit.beams(b)) do
				beam.Width0 = w[1] * 2.6
			end
		end
		kit.rates(b, {Glow = 60, Dashes = 50, Rings = big and 90 or 40})
		bolts[b] = {pos = at, speed = big and 300 or 110, big = big, off = big and V(0, 0, 0) or V(math.random() * 8 - 4, math.random() * 5 - 2, math.random() * 4 - 2)}
	end
	for i, t in ipairs(clip.shots) do
		tl.at(t, function()
			local c = small[(i - 1) % #small + 1]
			kit.emit(c[1], {Star = 1, Shock = 1})
			fire(c[4], false)
		end)
	end
	local charge
	tl.at(7.6, function()
		local p = main[1].Position
		charge = kit.spawn("Charge", CFrame.lookAt(p, drag.chest()))
		kit.rates(charge, {Gather = 120, Arcs = 20, Core = 18})
		Tw.play(charge.Light, {Brightness = 1.2}, 0.6, QUAD, IN)
		kit.emit(main[1], {Gust = 30, Hoops = 3})
	end)
	tl.at(8.2, function()
		kit.emit(main[1], {Flash = 1, Star = 1, Shock = 2, Streak = 1, Gust = 40, Hoops = 4})
		kit.rates(charge, {Gather = 0, Arcs = 0, Core = 0})
		Tw.play(charge.Light, {Brightness = 0}, 0.4, QUAD, IN)
		fire(main[1].Position, true)
		gale(P(0, 1, -3), -look, {Streaks = 140, Dust = 24}, 0.4)
		kick(0.35)
	end)
	tl.at(8.3, function()
		task.spawn(frames, {char, drag.model}, {{"white", 0.05}, {"black", 0.05}, {"lilac", 0.04}})
	end)
	tl.at(8.45, function()
		whiteout(1, 0.1, 0.5)
		grade({Exposure = 0.8}, 0.05)
		later(0.12, function()
			grade({Exposure = 0}, 0.8)
		end)
		kick(0.8)
		blast(drag.chest(), {Flash = 1, Star = 1, Spikes = 1, Ring = 1, Ring2 = 1, Sparks = 60, Smoke = 24, Glint = 1, Rocks = 12}, 9, 4)
		for i = 1, 8 do
			later(0.1 * i, function()
				blast(drag.chest(), {Sparks = 8, Smoke = 3}, 0, 2)
			end)
		end
	end)
	tl.at(9.6, function()
		local g = kit.ground(drag.chest(), char)
		blast(g + V(0, 1, 0), {Flash = 1, Ring = 1, Smoke = 40, Rocks = 16, Sparks = 20}, 4, 6)
		dustWave(g, 24, 24)
		kick(0.8)
	end)
	tl.at(10.2, function()
		for _, c in ipairs(small) do
			c[3](0.3)
		end
		main[3](0.35)
		sigilClose(0.5)
		kit.rates(sigil, {Rise = 0, Lines = 0})
	end)
	for i = 0, 4 do
		tl.at(10.3 + i * 0.3, function()
			blast(drag.chest() + V(0, 3, 0), {Smoke = 3, Sparks = 4}, 0, 3)
		end)
	end
	tl.at(11.8, function()
		fade(1, 0.8)
	end)
	tl.at(12.6, function()
		local list = {path, fly, drag.clear, sigilConn, sigil, main[2], main[1], charge}
		for _, c in ipairs(small) do
			table.insert(list, c[2])
			table.insert(list, c[1])
		end
		for b in pairs(bolts) do
			table.insert(list, b)
		end
		handback(char, list, finish)
	end)
end

function Cinema.flowers(char, finish, body, clip)
	local hrp = char.HumanoidRootPart
	local sun = Lighting:GetSunDirection()
	local look = V(sun.X, 0, sun.Z).Unit
	hrp.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + look)
	local origin = hrp.CFrame
	local function P(x, y, z)
		return origin:PointToWorldSpace(V(x, y, z))
	end
	local floor = kit.ground(hrp.Position, char)
	local tl = timeline({{6.55, 6.85, 0.35}})
	stage()
	tl.drive(body, clip, {fadeIn = 0.15})

	local staff = char.Staff
	local grip = char["Right Arm"].Grip
	local shots = {
		{t = 0, len = 1.9, a = {V(-5, 0.8, 9), V(1, 3, -40), 46}, b = {V(-4.2, 2.2, 7.6), V(1, 3.5, -40), 44}},
		{t = 1.9, len = 0.8, a = {V(8.5, 1.4, -3), V(0.8, 0.2, -0.5), 42}, b = {V(8, 1.5, -3.4), V(0.8, 0.3, -0.5), 40}, drift = 0.05},
		{t = 2.7, len = 2.2, a = {V(0.8, 0.1, -5.2), V(0, 0.5, -0.8), 38}, b = {V(0.6, 0.2, -4.6), V(0, 0.55, -0.8), 34}, drift = 0.05},
		{t = 4.9, len = 0.8, a = {V(-4.5, 0.8, -1.2), V(0, 0.4, -0.8), 38}, b = {V(-4.2, 0.9, -1.6), V(0, 0.45, -0.8), 36, 2}, drift = 0.05},
		{t = 5.7, len = 0.9, a = {V(2.2, -0.4, -7.5), V(0, 1.8, 0), 46}, b = {V(1.8, -0.2, -6.5), V(0, 2.6, 0), 50}},
		{t = 6.6, len = 0.6, a = {V(0.8, 0.4, -3.5), V(0, 10, -2), 62}, b = {V(0.8, 0.4, -3.5), V(0, 14, -2), 64}},
		{t = 7.2, len = 2.4, a = {V(-6, 8, 6), V(0, -2, -2), 55}, b = {V(-14, 26, 20), V(0, -3, -6), 60}, ease = "out"},
		{t = 9.6, len = 1.8, a = {V(4, 0.8, 12), V(0, 1.5, -30), 42}, b = {V(3.4, 1, 10), V(0, 1.8, -30), 40}},
		{t = 11.4, len = 2.6, a = {V(-7, 1.5, -6), V(0, 1.6, 0), 40}, b = {V(-3.4, 2.1, -8.2), V(0, 1.8, 0), 36}},
	}
	screen().Fade.BackgroundTransparency = 0
	shoot(origin, shots)
	bars(true, 0.8)
	fade(0, 0.9)

	local draft = kit.updraft(char, {Motes = 8, Streaks = 2, Glints = 2}, 12)
	tl.at(2.0, function()
		local g = staff.Grip.Position
		grip.Enabled = false
		for _, p in ipairs(staff:GetDescendants()) do
			if p:IsA("BasePart") then
				p.Anchored = true
			end
		end
		staff:PivotTo(CFrame.new(g.X, floor.Y + 1.6, g.Z) * CFrame.Angles(0, math.atan2(-look.X, -look.Z), math.rad(-6)))
		local base = V(g.X, floor.Y, g.Z)
		blast(base + V(0, 0.5, 0), {Glint = 1}, 2, 2)
		local w = kit.spawn("Wave", CFrame.new(base + V(0, 0.3, 0)))
		kit.emit(w, {Thin = 1, Star = 1})
		cleanup(w, 2)
		kick(0.15)
	end)
	tl.at(2.85, function()
		Vfx.flowers(char, {Gather = 3.0, Radius = 42, Near = 2.5, Speed = 11, Count = 220, Life = 9, Petals = 220, Scale = 2.6, Space = 16, Light = 1.2, Core = 8, CupLift = 0.7})
	end)
	tl.at(3.6, function()
		kit.rates(draft, {Motes = 26, Streaks = 6, Glints = 5})
		grade({Exposure = -0.25, Saturation = saved.saturation - 0.1}, 2)
	end)
	tl.at(6.6, function()
		whiteout(0.6, 0.1, 0.8)
		grade({Exposure = 0.5, Saturation = saved.saturation + 0.1}, 0.08)
		later(0.2, function()
			grade({Exposure = 0.05}, 1.5)
		end)
		blast(P(0, 30, -2), {Flash = 1, Star = 1, Glint = 1, Ring2 = 1}, 0, 3)
		later(0.3, function()
			blast(P(0, 34, -3), {Star = 1, Ring2 = 1}, 0, 3)
		end)
		kick(0.3)
		kit.rates(draft, {Motes = 40, Streaks = 10, Glints = 8})
	end)
	tl.at(8.2, function()
		kit.rates(draft, {Motes = 14, Streaks = 3, Glints = 4})
	end)
	tl.at(12.6, function()
		fade(1, 0.8)
	end)
	tl.at(13.4, function()
		for _, p in ipairs(staff:GetDescendants()) do
			if p:IsA("BasePart") then
				p.Anchored = false
			end
		end
		grip.Enabled = true
		handback(char, {}, finish)
	end)
end

return Cinema
