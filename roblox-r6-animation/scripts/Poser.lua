local RunService = game:GetService("RunService")

local Tw = require(script.Parent.Tw)

local Poser = {}

local R = math.rad
local BACK = 1.70158

-- every ease maps u in 0..1 to a blend and the direction wraps it the way tweenservice does
local EASE = {
	linear = function(u)
		return u
	end,
	quad = function(u)
		return u * u
	end,
	cubic = function(u)
		return u * u * u
	end,
	quart = function(u)
		return u * u * u * u
	end,
	sine = function(u)
		return 1 - math.cos(u * math.pi / 2)
	end,
	expo = function(u)
		return u == 0 and 0 or 2 ^ (10 * (u - 1))
	end,
	back = function(u, s)
		s = s or BACK
		return u * u * ((s + 1) * u - s)
	end,
	elastic = function(u)
		if u == 0 or u == 1 then
			return u
		end
		return -(2 ^ (10 * (u - 1))) * math.sin((u - 1.075) * (2 * math.pi) / 0.3)
	end,
	snap = function(u)
		return u >= 1 and 1 or 0
	end,
}

local function ease(name, dir, u, s)
	local f = EASE[name] or EASE.quad
	if dir == "in" then
		return f(u, s)
	elseif dir == "inout" then
		if u < 0.5 then
			return f(u * 2, s) / 2
		end
		return 1 - f((1 - u) * 2, s) / 2
	end
	return 1 - f(1 - u, s)
end

-- curve names that go through the hermite path even inside a legacy clip
local CURVE = {auto = true, flat = true, smooth = true, step = true}

-- follow-through springs for carried parts (f natural frequency in hz, z damping, r initial response), measured on a
-- 100 degree snap in 0.08 s: lead overshoots 6 and settles in 7 frames, follow overshoots 8, drag 12, heavy has no
-- bounce; on a steady move they trail by 0.5, 1.2, 1.7 and 3.1 frames, so a part that must hit a frame (the striking
-- fist, the torso of a strike) keys its overshoot instead of wearing a spring
local SPRINGS = {
	lead = {f = 8, z = 0.6, r = 1.25},
	follow = {f = 6, z = 0.5, r = 0.5},
	drag = {f = 5, z = 0.45, r = 0},
	heavy = {f = 4, z = 0.65, r = 0},
}
Poser.SPRINGS = SPRINGS

-- a key pose lives in the parent part's axes at the joint pivot so lift is about x, twist about y and side about z
-- r is {lift, twist, side} in degrees and p is an offset in studs
local function poseCF(key)
	local p = key.p or Vector3.zero
	local r = key.r or {0, 0, 0}
	return CFrame.new(p) * CFrame.Angles(0, 0, R(r[3])) * CFrame.Angles(R(r[1]), 0, 0) * CFrame.Angles(0, R(r[2]), 0)
end
Poser.poseCF = poseCF

-- channels are {lift, twist, side, x, y, z}: the numbers a curve editor would show for the joint
local function chansOf(key)
	local r = key.r or {0, 0, 0}
	local p = key.p or Vector3.zero
	return {r[1] or 0, r[2] or 0, r[3] or 0, p.X, p.Y, p.Z}
end

local function chanCF(c)
	return CFrame.new(c[4], c[5], c[6]) * CFrame.Angles(0, 0, R(c[3])) * CFrame.Angles(R(c[1]), 0, 0) * CFrame.Angles(0, R(c[2]), 0)
end
Poser.chanCF = chanCF

-- the inverse of chanCF: lift = asin r21, twist = atan2(-r20, r22), side = atan2(-r01, r11)
local function cfChan(cf)
	local x, y, z, _, r01, _, _, r11, _, r20, r21, r22 = cf:GetComponents()
	return {math.deg(math.asin(math.clamp(r21, -1, 1))), math.deg(math.atan2(-r20, r22)), math.deg(math.atan2(-r01, r11)), x, y, z}
end
Poser.cfChan = cfChan

-- transform sits between c0 and c1 so a pose in the parent's axes is wrapped by the c0 rotation
local function toTransform(joint, cf)
	return joint.rinv * cf * joint.r
end

-- one tangent per key and channel so the curve keeps its speed through a breakdown and only stops where the
-- author asks (flat) or where the channel turns around (auto clamps an extreme flat, fritsch-carlson style, so
-- nothing overshoots between keys); smooth never clamps; tn is tension (1 flat, 0 normal, below 0 looser)
local function tangents(clip, keys)
	local n = #keys
	local len = clip.length
	local wrap = clip.loop and len and n > 2 and math.abs(keys[1].t) < 1e-4 and math.abs(keys[n].t - len) < 1e-4
	local spline = clip.curve == "spline"
	for i, k in ipairs(keys) do
		local m = {0, 0, 0, 0, 0, 0}
		k.m = m
		local e = k.e
		local auto = (e == nil and spline) or e == "auto" or e == "smooth"
		local prev, nxt = keys[i - 1], keys[i + 1]
		local pt, nt = prev and prev.t, nxt and nxt.t
		if wrap and i == 1 then
			prev, pt = keys[n - 1], keys[n - 1].t - len
		elseif wrap and i == n then
			nxt, nt = keys[2], keys[2].t + len
		end
		if e == "linear" and prev and k.t > pt then
			for c = 1, 6 do
				m[c] = (k.c[c] - prev.c[c]) / (k.t - pt)
			end
		elseif auto and prev and nxt and k.t > pt and nt > k.t then
			local hp, hn = k.t - pt, nt - k.t
			local scale = 1 - (k.tn or 0)
			for c = 1, 6 do
				local sp = (k.c[c] - prev.c[c]) / hp
				local sn = (nxt.c[c] - k.c[c]) / hn
				local v = (hn * sp + hp * sn) / (hp + hn)
				if e ~= "smooth" then
					if sp * sn <= 0 then
						v = 0
					else
						local lim = 3 * math.min(math.abs(sp), math.abs(sn))
						v = math.clamp(v, -lim, lim)
					end
				end
				m[c] = v * scale
			end
		end
	end
end

-- the channels between key a and key b; the ease named on b shapes the segment (the ease into a key)
local function segChan(a, b, t, spline)
	local span = b.t - a.t
	local u = span > 0 and math.clamp((t - a.t) / span, 0, 1) or 1
	local out = table.create(6)
	local e = b.e
	if e == "step" or e == "snap" then
		local src = u >= 1 and b.c or a.c
		for c = 1, 6 do
			out[c] = src[c]
		end
	elseif e == "linear" then
		for c = 1, 6 do
			out[c] = a.c[c] + (b.c[c] - a.c[c]) * u
		end
	elseif (e == nil and spline) or CURVE[e] then
		local u2, u3 = u * u, u * u * u
		local h00, h10, h01, h11 = 2 * u3 - 3 * u2 + 1, u3 - 2 * u2 + u, -2 * u3 + 3 * u2, u3 - u2
		for c = 1, 6 do
			out[c] = h00 * a.c[c] + h10 * span * a.m[c] + h01 * b.c[c] + h11 * span * b.m[c]
		end
	else
		local w = ease(e or "quad", b.d or "out", u, b.s)
		for c = 1, 6 do
			out[c] = a.c[c] + (b.c[c] - a.c[c]) * w
		end
	end
	return out
end

-- a joint entry is either a sorted key list or a function of time and context that returns a key or a cframe
-- the second return is the channel table when the keys carry one (authored keys do, imported sequences do not)
local function sampleJoint(keys, t, ctx, spline)
	if type(keys) == "function" then
		local v = keys(t, ctx)
		if typeof(v) == "CFrame" then
			return v
		end
		return poseCF(v), chansOf(v)
	end
	local first, last = keys[1], keys[#keys]
	if t <= first.t then
		return first.cf, first.c and table.clone(first.c)
	end
	if t >= last.t then
		return last.cf, last.c and table.clone(last.c)
	end
	for i = 2, #keys do
		local k = keys[i]
		if t <= k.t then
			local a = keys[i - 1]
			if a.c and k.c and (spline or CURVE[k.e]) then
				local c = segChan(a, k, t, spline)
				return chanCF(c), c
			end
			local span = k.t - a.t
			local u = span > 0 and (t - a.t) / span or 1
			local w = ease(k.e or "quad", k.d or "out", u, k.s)
			return a.cf:Lerp(k.cf, w)
		end
	end
	return last.cf, last.c and table.clone(last.c)
end

-- the longest joint lag, so a one-shot is not done until its last trailing joint arrives (a loop wraps instead)
local function tailOf(clip)
	local tail = 0
	if clip.lag and not clip.loop then
		for _, v in pairs(clip.lag) do
			tail = math.max(tail, v)
		end
	end
	return tail
end

-- clip.lag = {[joint] = seconds} offsets a joint's whole curve later in time (the animator's offset keys)
local function localTime(clip, name, t)
	local lag = clip.lag and clip.lag[name]
	if lag and lag ~= 0 then
		t -= lag
		if clip.loop and clip.length then
			return t % clip.length
		end
		return math.max(0, t)
	end
	return t
end

-- clip.life adds a slow drift (two octaves of noise at clip.lifeRate hz, default 0.35) to the rotation channels so a
-- held pose never freezes: a number spreads that many degrees over the upper body (torso 1, head 1.4, arms 1.2, legs
-- 0 so the feet stay planted), a table gives degrees by joint; noise runs on unwrapped time so a loop has no seam
local LIFE = {Torso = 1, Head = 1.4, ["Right Arm"] = 1.2, ["Left Arm"] = 1.2}
local SEED = {Torso = 11.3, Head = 23.7, ["Right Arm"] = 37.1, ["Left Arm"] = 41.9, ["Right Leg"] = 53.3, ["Left Leg"] = 67.9}

local function lifeAmp(clip, name)
	local life = clip.life
	if type(life) == "number" then
		return life * (LIFE[name] or 0)
	elseif type(life) == "table" then
		return life[name] or 0
	end
	return 0
end

-- lag, then the curve, then the life drift: the pose every path (play, pose, bake, check) agrees on
local function samplePose(clip, name, keys, t, ctx, lifeT)
	local cf, ch = sampleJoint(keys, localTime(clip, name, t), ctx, clip.curve == "spline")
	local amp = clip.life and lifeAmp(clip, name) or 0
	if amp ~= 0 then
		ch = ch or cfChan(cf)
		local u = (lifeT or t) * (clip.lifeRate or 0.35)
		local seed = SEED[name] or #name * 7.1
		for c = 1, 3 do
			local s = seed + c * 3.7
			ch[c] += amp * (math.noise(u, s) + 0.5 * math.noise(u * 2.3, s + 1.9)) * 1.6
		end
		cf = chanCF(ch)
	end
	return cf, ch
end

local function springOf(clip, name)
	local s = clip.springs and clip.springs[name]
	if type(s) == "string" then
		s = SPRINGS[s]
	end
	if not s then
		return nil
	end
	local w = 2 * math.pi * s.f
	return {k1 = s.z / (math.pi * s.f), k2 = 1 / (w * w), k3 = (s.r or 0) * s.z / w}
end

local function springNew(k, x)
	return {k1 = k.k1, k2 = k.k2, k3 = k.k3, y = table.clone(x), yd = {0, 0, 0, 0, 0, 0}, xp = table.clone(x)}
end

-- second order dynamics (t3ssel8r): the output chases the sampled pose with its own velocity, so a snap overshoots
-- and settles and a secondary part trails; substeps keep a 30 fps bake on the same curve as 60 fps play and k2 is
-- clamped so a long frame cannot blow it up
local function springStep(s, x, T)
	if T <= 0 then
		return s.y
	end
	local n = math.max(1, math.ceil(T * 60 - 1e-6))
	local h = T / n
	local k2 = math.max(s.k2, h * h / 2 + h * s.k1 / 2, h * s.k1)
	for c = 1, 6 do
		local x0 = s.xp[c]
		local xd = (x[c] - x0) / T
		local y, yd = s.y[c], s.yd[c]
		for j = 1, n do
			local xi = x0 + (x[c] - x0) * (j / n)
			y += h * yd
			yd += h * (xi + s.k3 * xd - y - s.k1 * yd) / k2
		end
		s.y[c], s.yd[c], s.xp[c] = y, yd, x[c]
	end
	return s.y
end

-- a clip's warp {{t, speed}, ...} plays its own clock faster or slower (a strike snaps, a contact hangs), linear
-- between the keys; play, the check in real time and the bake all read it
local function warpAt(clip, t)
	local w = clip.warp
	if not w then
		return 1
	end
	if t <= w[1][1] then
		return w[1][2]
	end
	for i = 2, #w do
		local a, b = w[i - 1], w[i]
		if t <= b[1] then
			return a[2] + (b[2] - a[2]) * (t - a[1]) / math.max(1e-6, b[1] - a[1])
		end
	end
	return w[#w][2]
end
Poser.warpAt = warpAt

-- real seconds a warped clip takes to reach clip time t
function Poser.realTime(clip, t)
	if not clip.warp then
		return t
	end
	local sum, s = 0, 0
	while s < t - 1e-9 do
		local d = math.min(1 / 480, t - s)
		sum += d / warpAt(clip, s + d * 0.5)
		s += d
	end
	return sum
end

-- a clip is compiled once so every key carries its cframe, channels and tangents and the keys are sorted by time
function Poser.compile(clip)
	if clip.compiled then
		return clip
	end
	for _, keys in pairs(clip.joints) do
		if type(keys) == "table" then
			table.sort(keys, function(a, b)
				return a.t < b.t
			end)
			for _, k in ipairs(keys) do
				k.cf = poseCF(k)
				k.c = chansOf(k)
			end
			tangents(clip, keys)
		end
	end
	clip.compiled = true
	return clip
end

-- a keyframesequence becomes a clip of raw keys: every pose cframe is a transform already so it is wrapped back into
-- pose space with the wraps table (part name to c0 rotation) and the same wrap undoes it at play time
-- opts.map renames pose names to rig joint names, opts.trimStart drops the lead in so a loop is seamless,
-- opts.extra adds procedural joints (a float root), opts.loop overrides the sequence flag, opts.only keeps
-- a set of joints, opts.pScale (a number or a table by joint) scales the offsets and opts.rollScale (a table
-- by joint) scales the side channel
function Poser.fromSequence(kfs, wraps, opts)
	opts = opts or {}
	local map = opts.map or {}
	local start = opts.trimStart or 0
	local clip = {name = opts.name or kfs.Name, joints = {}, loop = kfs.Loop, compiled = true}
	if opts.loop ~= nil then
		clip.loop = opts.loop
	end
	local frames = kfs:GetKeyframes()
	table.sort(frames, function(a, b)
		return a.Time < b.Time
	end)
	local last = 0
	for _, kf in ipairs(frames) do
		local t = kf.Time - start
		if t >= -0.0001 then
			t = math.max(0, t)
			last = math.max(last, t)
			for _, p in ipairs(kf:GetDescendants()) do
				if p:IsA("Pose") and p.Weight > 0 and p.Name ~= "HumanoidRootPart" then
					local name = map[p.Name] or p.Name
					local r = wraps[name]
					if r and (not opts.only or opts.only[name]) then
						local keys = clip.joints[name]
						if not keys then
							keys = {}
							clip.joints[name] = keys
						end
						local cf = r * p.CFrame * r:Inverse()
						-- opts.pScale shrinks a joint's offsets so a stand's floating limbs fit a planted body
						local scale = opts.pScale and (type(opts.pScale) == "table" and opts.pScale[name] or opts.pScale)
						if type(scale) == "number" and scale ~= 1 then
							cf = CFrame.new(cf.Position * scale) * cf.Rotation
						end
						-- opts.rollScale shrinks the side channel only, so a floating stand's torso roll fits a standing body
						local rs = opts.rollScale and opts.rollScale[name]
						if rs and rs ~= 1 then
							local c = cfChan(cf)
							c[3] *= rs
							cf = chanCF(c)
						end
						table.insert(keys, {t = t, cf = cf, e = "linear"})
					end
				end
			end
		end
	end
	for _, keys in pairs(clip.joints) do
		table.sort(keys, function(a, b)
			return a.t < b.t
		end)
	end
	clip.length = opts.length or last
	if opts.extra then
		for name, fn in pairs(opts.extra) do
			clip.joints[name] = fn
		end
	end
	return clip
end

-- the wrap table for a template so clips can be built before any rig is attached
function Poser.wrapsOf(model)
	local wraps = {}
	for _, m in ipairs(model:GetDescendants()) do
		if m:IsA("Motor6D") and m.Part1 then
			wraps[m.Part1.Name] = m.C0.Rotation
		end
	end
	return wraps
end

-- samples one joint of a clip at a time into pose space (lag applied, springs not) so a clip can start from another
-- clip's pose
function Poser.sample(clip, name, t, ctx)
	Poser.compile(clip)
	local keys = clip.joints[name]
	if not keys then
		return CFrame.new()
	end
	return (samplePose(clip, name, keys, t, ctx or {}))
end

-- every joint at t without springs, then the post pass (clip.post(poses, t, ctx) edits pose-space cframes after the
-- curves, life and springs, the place for foot and hand contacts solved against the final torso)
local function posesNow(clip, t, ctx, lifeT)
	local poses = {}
	for name, keys in pairs(clip.joints) do
		poses[name] = (samplePose(clip, name, keys, t, ctx, lifeT))
	end
	if clip.post then
		clip.post(poses, t, ctx)
	end
	return poses
end

-- runs a clip from 0 to upto at 60 fps with lag and springs and returns the spring states and the last poses, so a
-- pose sheet, a bake or a check shows exactly what play shows; visit(t, poses, realT) sees every step, and real steps
-- a warped clip at 60 real frames a second the way play does
local function simulate(clip, upto, ctx, visit, ctxAt, real)
	Poser.compile(clip)
	local states = {}
	local poses = {}
	local prevT = 0
	local times, reals = {}, {}
	if real and clip.warp then
		local t, rt = 0, 0
		while t < upto - 1e-6 do
			table.insert(times, t)
			table.insert(reals, rt)
			local sp = warpAt(clip, t)
			t += sp / 60
			rt += 1 / 60
			if t > upto then
				rt -= (t - upto) / sp
			end
		end
		table.insert(times, upto)
		table.insert(reals, rt)
	else
		local steps = math.max(0, math.ceil(upto * 60 - 1e-6))
		for i = 0, steps do
			local t = math.min(upto, i / 60)
			table.insert(times, t)
			table.insert(reals, t)
		end
	end
	for i, t in ipairs(times) do
		local c = ctxAt and ctxAt(t) or ctx or {}
		for name, keys in pairs(clip.joints) do
			local cf, ch = samplePose(clip, name, keys, t, c)
			local k = springOf(clip, name)
			if k then
				ch = ch or cfChan(cf)
				local s = states[name]
				if not s then
					s = springNew(k, ch)
					states[name] = s
				end
				cf = chanCF(springStep(s, ch, t - prevT))
			end
			poses[name] = cf
		end
		if clip.post then
			clip.post(poses, t, c)
		end
		if visit then
			visit(t, poses, reals[i])
		end
		prevT = t
	end
	return states, poses
end

local rigs = {}
local conn

local function step(dt)
	for rig in pairs(rigs) do
		local a = rig.active
		if a and rig.model.Parent then
			local scaled = dt / Tw.S()
			a.elapsed += scaled
			if os.clock() < a.holdUntil then
				scaled = 0
			end
			local adv = scaled * a.speed * warpAt(a.clip, a.time)
			a.time += adv
			local clip = a.clip
			local t = a.time
			if clip.loop then
				t = t % clip.length
			elseif clip.length and t > clip.length + tailOf(clip) then
				t = clip.length + tailOf(clip)
				if a.onDone then
					local f = a.onDone
					a.onDone = nil
					task.spawn(f)
				end
			end
			local blend = a.fadeIn > 0 and math.min(1, a.elapsed / a.fadeIn) or 1
			local poses = {}
			for name, keys in pairs(clip.joints) do
				local cf, ch = samplePose(clip, name, keys, t, rig.ctx, a.time)
				local s = a.springs and a.springs[name]
				if s then
					cf = chanCF(springStep(s, ch or cfChan(cf), adv))
				end
				poses[name] = cf
			end
			if clip.post then
				clip.post(poses, t, rig.ctx)
			end
			for name in pairs(clip.joints) do
				local joint = rig.joints[name]
				if joint and joint.motor.Parent then
					local target = toTransform(joint, poses[name])
					if blend < 1 and a.from[name] then
						if a.offset and a.offset[name] then
							-- inertial: the old pose rides on top of the moving new clip as an offset that dies away, so
							-- the new motion shows from the first frame instead of fading in from a frozen pose
							local w = blend * blend * (3 - 2 * blend)
							target = a.offset[name]:Lerp(CFrame.identity, w) * target
						else
							target = a.from[name]:Lerp(target, blend)
						end
					end
					joint.motor.Transform = target
					rig.last[name] = target
				end
			end
		elseif a and not rig.model.Parent then
			rigs[rig] = nil
		end
	end
	if next(rigs) == nil and conn then
		conn:Disconnect()
		conn = nil
	end
end

-- advances every playing rig by dt once; PreSimulation calls it in play, and an Edit-mode test calls it by hand to
-- compare the runtime path with Poser.posesAt
Poser.step = step

local function ensureLoop()
	if not conn then
		conn = RunService.PreSimulation:Connect(step)
	end
end

local Rig = {}
Rig.__index = Rig

-- joints are keyed by the child part name so a stand inside a character never collides with the body's own shoulder
function Poser.attach(model, ctx)
	local rig = setmetatable({model = model, joints = {}, ctx = ctx or {}, last = {}}, Rig)
	rig:refresh()
	return rig
end

function Rig:refresh()
	for _, m in ipairs(self.model:GetDescendants()) do
		if m:IsA("Motor6D") and m.Part1 and not self.joints[m.Part1.Name] then
			local rot = m.C0.Rotation
			self.joints[m.Part1.Name] = {motor = m, r = rot, rinv = rot:Inverse()}
		end
	end
end

-- a new clip starts from whatever the joints show right now so a switch never pops; opts.blend "inertial" (the
-- default for spline clips) keeps the new clip moving under a dying offset, "cross" fades in from the frozen pose
function Rig:play(clip, opts)
	opts = opts or {}
	Poser.compile(clip)
	self:refresh()
	local startAt = opts.startAt or 0
	-- the animator zeroes every transform before presimulation so a clip started inside a step blends from the pose this rig last wrote
	local from = {}
	for name in pairs(clip.joints) do
		local joint = self.joints[name]
		if joint then
			from[name] = self.last[name] or joint.motor.Transform
		end
	end
	local springs, poses
	if clip.springs then
		springs, poses = simulate(clip, startAt, self.ctx)
	end
	local offset
	local mode = opts.blend or (clip.curve == "spline" and "inertial" or "cross")
	if mode == "inertial" then
		offset = {}
		poses = poses or posesNow(clip, startAt, self.ctx)
		for name in pairs(clip.joints) do
			local joint = self.joints[name]
			if joint and from[name] and poses[name] then
				offset[name] = from[name] * toTransform(joint, poses[name]):Inverse()
			end
		end
	end
	self.active = {
		clip = clip,
		time = startAt,
		elapsed = 0,
		speed = opts.speed or 1,
		fadeIn = opts.fadeIn or 0.12,
		from = from,
		offset = offset,
		springs = springs,
		holdUntil = 0,
		onDone = opts.onDone,
	}
	rigs[self] = true
	ensureLoop()
	return self.active
end

function Rig:playing(clip)
	return self.active ~= nil and (clip == nil or self.active.clip == clip)
end

function Rig:setSpeed(s)
	if self.active then
		self.active.speed = s
	end
end

-- a hold freezes the clip clock and its springs for a hit stop while the effects keep their own schedule
function Rig:hold(dur)
	if self.active then
		self.active.holdUntil = os.clock() + dur * Tw.S()
	end
end

function Rig:seek(t)
	if self.active then
		self.active.time = t
	end
end

-- a stop eases every driven joint back to rest over fade seconds then lets the animator have them
function Rig:stop(fade)
	local a = self.active
	if not a then
		return
	end
	self.active = nil
	rigs[self] = nil
	local names = {}
	for name in pairs(a.clip.joints) do
		names[name] = self.joints[name]
	end
	if not fade or fade <= 0 then
		for name, joint in pairs(names) do
			joint.motor.Transform = CFrame.new()
			self.last[name] = nil
		end
		return
	end
	local t0 = os.clock()
	local from = {}
	for name, joint in pairs(names) do
		from[name] = self.last[name] or joint.motor.Transform
	end
	local c
	c = RunService.PreSimulation:Connect(function()
		local w = math.min(1, (os.clock() - t0) / (fade * Tw.S()))
		for name, joint in pairs(names) do
			if joint.motor.Parent then
				joint.motor.Transform = from[name]:Lerp(CFrame.new(), w)
				self.last[name] = w < 1 and joint.motor.Transform or nil
			end
		end
		if w >= 1 or self.active then
			c:Disconnect()
		end
	end)
end

-- samples a clip at one time and writes it so a pose sheet can be rendered frame by frame (springs are run from 0)
function Rig:pose(clip, t)
	Poser.compile(clip)
	self:refresh()
	local poses
	if clip.springs then
		_, poses = simulate(clip, t, self.ctx)
	else
		poses = posesNow(clip, t, self.ctx)
	end
	for name, cf in pairs(poses) do
		local joint = self.joints[name]
		if joint then
			joint.motor.Transform = toTransform(joint, cf)
			self.last[name] = joint.motor.Transform
		end
	end
end

-- bakes a clip into a keyframesequence at fps so the animation editor can publish it as a real asset
-- a procedural clip gives ctxAt(t) so the walk phase and speed exist for every sampled frame
function Poser.bake(clip, rig, fps, name, length)
	Poser.compile(clip)
	rig:refresh()
	local kfs = Instance.new("KeyframeSequence")
	kfs.Name = name or clip.name or "Clip"
	kfs.Loop = clip.loop == true
	kfs.Priority = Enum.AnimationPriority.Action
	length = length or (clip.length + tailOf(clip))
	-- a held clip carries a 100000 s length so it never ends in play; baked without an explicit length it loops for
	-- millions of frames, floods memory and crashes studio, so the bake refuses anything over a minute
	if length > 60 then
		error(("bake %s: length %s needs an explicit bake length"):format(tostring(name or clip.name), tostring(length)))
	end
	local root
	for _, joint in pairs(rig.joints) do
		local p0 = joint.motor.Part0
		if p0 and not rig.joints[p0.Name] then
			root = p0
		end
	end
	local nextT = 0
	simulate(clip, length, rig.ctx, function(t, poses, rt)
		-- simulate steps at 60 fps; keep the steps on the bake grid and always the exact end, and a warped clip bakes
		-- in real seconds so the asset plays at the speed play shows
		if rt + 1e-6 < nextT and t < length then
			return
		end
		nextT = rt + 1 / fps
		local kf = Instance.new("Keyframe")
		kf.Time = rt
		local made = {}
		local function poseFor(part)
			if made[part] then
				return made[part]
			end
			local pose = Instance.new("Pose")
			pose.Name = part.Name
			pose.EasingStyle = Enum.PoseEasingStyle.Linear
			pose.Weight = 1
			made[part] = pose
			local joint = rig.joints[part.Name]
			if joint and joint.motor.Part0 then
				local cf = poses[part.Name]
				pose.CFrame = cf and toTransform(joint, cf) or CFrame.new()
				pose.Parent = poseFor(joint.motor.Part0)
			else
				pose.CFrame = CFrame.new()
				pose.Parent = kf
			end
			return pose
		end
		if root then
			poseFor(root)
		end
		for jname, joint in pairs(rig.joints) do
			if clip.joints[jname] then
				poseFor(joint.motor.Part1)
			end
		end
		kf.Parent = kfs
	end, clip.ctxAt, true)
	return kfs
end

-- the angle in degrees between two rotations
local function turn(a, b)
	local _, _, _, a00, a01, a02, a10, a11, a12, a20, a21, a22 = a:GetComponents()
	local _, _, _, b00, b01, b02, b10, b11, b12, b20, b21, b22 = b:GetComponents()
	local tr = a00 * b00 + a01 * b01 + a02 * b02 + a10 * b10 + a11 * b11 + a12 * b12 + a20 * b20 + a21 * b21 + a22 * b22
	return math.deg(math.acos(math.clamp((tr - 1) / 2, -1, 1)))
end

-- measures how alive a clip moves at 60 fps (lag, life and springs included) with the definitions and thresholds of
-- scripts/motion_check.js: speeds over a 4 frame window; frozen% (nothing over 1.5 deg/s or 0.06 stud/s across 16
-- frames), still% and the longest still (nothing over 12 deg/s or 0.3 stud/s), rest% (time an active joint spends
-- under a tenth of its own peak), stops per second per active joint (rests of 4 frames or more), unison per second
-- (three or more active joints start resting together), contrast (peak body speed over its median) and spread (frames
-- between the active joints' fastest moments); an active joint peaks at 60 or more (deg/s plus 30 per stud/s)
function Poser.check(clip, opts)
	opts = opts or {}
	local length = opts.length or math.min(20, (clip.length or 1) + tailOf(clip))
	local frames = {}
	-- opts.real measures a warped clip in the real seconds play shows instead of its own clock
	local realLen = length
	simulate(clip, length, opts.ctx, function(_, poses, rt)
		table.insert(frames, table.clone(poses))
		realLen = rt
	end, opts.ctxAt or clip.ctxAt, opts.real)
	if opts.real then
		length = realLen
	end
	local names = {}
	for name in pairs(frames[1] or {}) do
		table.insert(names, name)
	end
	table.sort(names)
	local n = #frames
	local function speedAt(name, i, w)
		local a, b = frames[math.max(1, i - w)][name], frames[math.min(n, i + w)][name]
		local dt = (math.min(n, i + w) - math.max(1, i - w)) / 60
		if dt <= 0 then
			return 0, 0
		end
		return turn(a, b) / dt, (b.Position - a.Position).Magnitude / dt
	end
	local rot, mov, v, frozenAt = {}, {}, {}, {}
	for _, name in ipairs(names) do
		rot[name], mov[name], v[name], frozenAt[name] = {}, {}, {}, {}
		for i = 1, n do
			local r, m = speedAt(name, i, 2)
			rot[name][i], mov[name][i], v[name][i] = r, m, r + 30 * m
			local fr, fm = speedAt(name, i, 8)
			frozenAt[name][i] = fr < 1.5 and fm < 0.06
		end
	end
	local frozen, still, run, longest = 0, 0, 0, 0
	for i = 1, n do
		local allFrozen, moving = true, false
		for _, name in ipairs(names) do
			allFrozen = allFrozen and frozenAt[name][i]
			moving = moving or rot[name][i] > 12 or mov[name][i] > 0.3
		end
		if allFrozen then
			frozen += 1
		end
		if moving then
			run = 0
		else
			still += 1
			run += 1
			longest = math.max(longest, run)
		end
	end
	local active, resting, peakAt = {}, {}, {}
	for _, name in ipairs(names) do
		local pk, at = 0, 1
		for i = 1, n do
			if v[name][i] > pk then
				pk, at = v[name][i], i
			end
		end
		if pk >= 60 then
			table.insert(active, name)
			local r = {}
			for i = 1, n do
				r[i] = v[name][i] < 0.1 * pk
			end
			resting[name] = r
			peakAt[name] = at
		end
	end
	local rest, stops = 0, 0
	for _, name in ipairs(active) do
		local r, count, runLen = resting[name], 0, 0
		for i = 1, n + 1 do
			if i <= n and r[i] then
				count += 1
				runLen += 1
			else
				if runLen >= 4 and runLen < n then
					stops += 1
				end
				runLen = 0
			end
		end
		rest += count / n
	end
	local unison, was = 0, false
	for i = 1, n do
		local c = 0
		for _, name in ipairs(active) do
			if resting[name][i] then
				c += 1
			end
		end
		local all = c >= 3
		if all and not was and i > 1 then
			unison += 1
		end
		was = all
	end
	local body = {}
	for i = 1, n do
		local s = 0
		for _, name in ipairs(names) do
			s += v[name][i]
		end
		body[i] = s
	end
	table.sort(body)
	local contrast = (body[n] or 0) / math.max(1, body[math.floor(n / 2) + 1] or 0)
	local mean, spread = 0, 0
	for _, name in ipairs(active) do
		mean += peakAt[name] / #active
	end
	for _, name in ipairs(active) do
		spread += (peakAt[name] - mean) ^ 2 / #active
	end
	local na = math.max(1, #active)
	local r = {
		clip = clip.name or "?",
		length = length,
		frozenPct = 100 * frozen / n,
		stillPct = 100 * still / n,
		longestStill = longest / 60,
		restPct = 100 * rest / na,
		stopsPerSec = stops / na / length,
		unisonPerSec = unison / length,
		contrast = contrast,
		peakSpread = math.sqrt(spread),
	}
	r.text = ("%s len %.2f frozen %.1f%% still %.1f%% longest %.2fs rest %.1f%% stops %.2f/s unison %.2f/s contrast %.1f spread %.1f"):format(
		r.clip, r.length, r.frozenPct, r.stillPct, r.longestStill, r.restPct, r.stopsPerSec, r.unisonPerSec, r.contrast, r.peakSpread)
	return r
end

-- every joint's pose-space cframe at time t with lag, life and springs run from 0, for forward kinematics and pose
-- sheets in Edit mode where Motor6D transforms do not solve
function Poser.posesAt(clip, t, ctx)
	local _, poses = simulate(clip, t, ctx)
	return table.clone(poses)
end

-- visits the clip at fps with the same poses play shows (visit(t, poses), poses reused between calls)
function Poser.each(clip, fps, visit, opts)
	opts = opts or {}
	local length = opts.length or math.min(60, (clip.length or 1) + tailOf(clip))
	local nextT = 0
	simulate(clip, length, opts.ctx, function(t, poses)
		if t + 1e-6 < nextT and t < length then
			return
		end
		nextT = t + 1 / (fps or 60)
		visit(t, poses)
	end, opts.ctxAt or clip.ctxAt)
end

-- writes a clip as ReadClips decode text (60 fps, springs and lag included) for scripts/motion_check.js
function Poser.dump(clip, fps, name)
	fps = fps or 60
	name = name or clip.name or "Clip"
	local length = math.min(20, (clip.length or 1) + tailOf(clip))
	local lines = {}
	local nextT = 0
	local count = 0
	simulate(clip, length, nil, function(t, poses)
		if t + 1e-6 < nextT and t < length then
			return
		end
		nextT = t + 1 / fps
		count += 1
		local names = {}
		for jn in pairs(poses) do
			table.insert(names, jn)
		end
		table.sort(names)
		for _, jn in ipairs(names) do
			local c = cfChan(poses[jn])
			table.insert(lines, ("%s|%s|%.3f|%.1f|%.1f|%.1f|%.2f|%.2f|%.2f|Linear|In"):format(name, jn, t, c[1], c[2], c[3], c[4], c[5], c[6]))
		end
	end, clip.ctxAt)
	table.insert(lines, 1, ("#%s len=%.3f loop=%s frames=%d prio=Action"):format(name, length, tostring(clip.loop == true), count))
	return table.concat(lines, "\n")
end

return Poser
