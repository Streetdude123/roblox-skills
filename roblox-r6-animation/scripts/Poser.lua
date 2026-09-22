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

-- a key pose lives in the parent part's axes at the joint pivot so lift is about x, twist about y and side about z
-- r is {lift, twist, side} in degrees and p is an offset in studs
local function poseCF(key)
	local p = key.p or Vector3.zero
	local r = key.r or {0, 0, 0}
	return CFrame.new(p) * CFrame.Angles(0, 0, R(r[3])) * CFrame.Angles(R(r[1]), 0, 0) * CFrame.Angles(0, R(r[2]), 0)
end
Poser.poseCF = poseCF

-- transform sits between c0 and c1 so a pose in the parent's axes is wrapped by the c0 rotation
local function toTransform(joint, cf)
	return joint.rinv * cf * joint.r
end

-- a joint entry is either a sorted key list or a function of time and context that returns a key or a cframe
local function sampleJoint(keys, t, ctx)
	if type(keys) == "function" then
		local v = keys(t, ctx)
		if typeof(v) == "CFrame" then
			return v
		end
		return poseCF(v)
	end
	local first, last = keys[1], keys[#keys]
	if t <= first.t then
		return first.cf
	end
	if t >= last.t then
		return last.cf
	end
	for i = 2, #keys do
		local k = keys[i]
		if t <= k.t then
			local a = keys[i - 1]
			local span = k.t - a.t
			local u = span > 0 and (t - a.t) / span or 1
			local w = ease(k.e or "quad", k.d or "out", u, k.s)
			return a.cf:Lerp(k.cf, w)
		end
	end
	return last.cf
end

-- a clip is compiled once so every key carries its cframe and the keys are sorted by time
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
			end
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
						if scale and scale ~= 1 then
							cf = CFrame.new(cf.Position * scale) * cf.Rotation
						end
						-- opts.rollScale shrinks the side channel only, so a floating stand's torso roll fits a standing body
						local rs = opts.rollScale and opts.rollScale[name]
						if rs and rs ~= 1 then
							local _, _, _, r00, r01, r02, r10, r11, r12, r20, r21, r22 = cf:GetComponents()
							local lift = math.asin(math.clamp(r21, -1, 1))
							local twist = math.atan2(-r20, r22)
							local side = math.atan2(-r01, r11)
							cf = CFrame.new(cf.Position) * CFrame.Angles(0, 0, side * rs) * CFrame.Angles(lift, 0, 0) * CFrame.Angles(0, twist, 0)
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

-- samples one joint of a clip at a time into pose space so a clip can start from another clip's pose
function Poser.sample(clip, name, t, ctx)
	Poser.compile(clip)
	local keys = clip.joints[name]
	if not keys then
		return CFrame.new()
	end
	return sampleJoint(keys, t, ctx or {})
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
			a.time += scaled * a.speed
			local clip = a.clip
			local t = a.time
			if clip.loop then
				t = t % clip.length
			elseif clip.length and t > clip.length then
				t = clip.length
				if a.onDone then
					local f = a.onDone
					a.onDone = nil
					task.spawn(f)
				end
			end
			local blend = a.fadeIn > 0 and math.min(1, a.elapsed / a.fadeIn) or 1
			for name, keys in pairs(clip.joints) do
				local joint = rig.joints[name]
				if joint and joint.motor.Parent then
					local target = toTransform(joint, sampleJoint(keys, t, rig.ctx))
					if blend < 1 and a.from[name] then
						target = a.from[name]:Lerp(target, blend)
					end
					joint.motor.Transform = target
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

local function ensureLoop()
	if not conn then
		conn = RunService.PreSimulation:Connect(step)
	end
end

local Rig = {}
Rig.__index = Rig

-- joints are keyed by the child part name so a stand inside a character never collides with the body's own shoulder
function Poser.attach(model, ctx)
	local rig = setmetatable({model = model, joints = {}, ctx = ctx or {}}, Rig)
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

-- a new clip blends from whatever the joints show right now so a switch never pops
function Rig:play(clip, opts)
	opts = opts or {}
	Poser.compile(clip)
	self:refresh()
	local from = {}
	for name in pairs(clip.joints) do
		local joint = self.joints[name]
		if joint then
			from[name] = joint.motor.Transform
		end
	end
	self.active = {
		clip = clip,
		time = opts.startAt or 0,
		elapsed = 0,
		speed = opts.speed or 1,
		fadeIn = opts.fadeIn or 0.12,
		from = from,
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

-- a hold freezes the clip clock for a hit stop while the effects keep their own schedule
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
		for _, joint in pairs(names) do
			joint.motor.Transform = CFrame.new()
		end
		return
	end
	local t0 = os.clock()
	local from = {}
	for name, joint in pairs(names) do
		from[name] = joint.motor.Transform
	end
	local c
	c = RunService.PreSimulation:Connect(function()
		local w = math.min(1, (os.clock() - t0) / (fade * Tw.S()))
		for name, joint in pairs(names) do
			if joint.motor.Parent then
				joint.motor.Transform = from[name]:Lerp(CFrame.new(), w)
			end
		end
		if w >= 1 or self.active then
			c:Disconnect()
		end
	end)
end

-- samples a clip at one time and writes it so a pose sheet can be rendered frame by frame
function Rig:pose(clip, t)
	Poser.compile(clip)
	self:refresh()
	for name, keys in pairs(clip.joints) do
		local joint = self.joints[name]
		if joint then
			joint.motor.Transform = toTransform(joint, sampleJoint(keys, t, self.ctx))
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
	length = length or clip.length
	local n = math.floor(length * fps + 0.5)
	local root
	for _, joint in pairs(rig.joints) do
		local p0 = joint.motor.Part0
		if p0 and not rig.joints[p0.Name] then
			root = p0
		end
	end
	for i = 0, n do
		local t = math.min(length, i / fps)
		local ctx = clip.ctxAt and clip.ctxAt(t) or rig.ctx
		local kf = Instance.new("Keyframe")
		kf.Time = t
		local poses = {}
		local function poseFor(part)
			if poses[part] then
				return poses[part]
			end
			local pose = Instance.new("Pose")
			pose.Name = part.Name
			pose.EasingStyle = Enum.PoseEasingStyle.Linear
			pose.Weight = 1
			poses[part] = pose
			local joint = rig.joints[part.Name]
			if joint and joint.motor.Part0 then
				local keys = clip.joints[part.Name]
				pose.CFrame = keys and toTransform(joint, sampleJoint(keys, t, ctx)) or CFrame.new()
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
	end
	return kfs
end

return Poser
