local Modules = script.Parent.Parent
local Poser = require(Modules.Poser)
local Feet = require(Modules.Feet)
local Rig = require(Modules.SwordRig)

local V3 = Vector3.new
local sin = math.sin
local pose = Poser.poseCF

local K = {Poser = Poser, Feet = Feet, Rig = Rig, V3 = V3, pose = pose}

local PR, PL = V3(1, 0.5, 0), V3(-1, 0.5, 0)
local REACH = 1.487
local TIP = -4.5

K.STANCE = {
	feet = {r = {0.62, 0.34, -16}, l = {-0.66, -0.52, 12}},
	torso = {-4, 8, 0},
	head = {-8, -6, 0},
}

K.log = {}
local building = "?"
function K.named(n)
	building = n
end

local function gripOff(arm, handle)
	local along = math.abs(handle.UpVector:Dot(arm.UpVector))
	return 90 - math.deg(math.acos(math.clamp(along, 0, 1)))
end

function K.body(def, seed, feet, t)
	def.feet = feet or K.STANCE.feet
	local p = def.torsoP or Rig.seat(def.torso, def.tx or 0, def.tz or 0, def.crouch, def.feet)
	if def.rise then
		p += V3(0, def.rise, 0)
	end
	local tp = pose({p = p, r = def.torso})
	local out = {torso = def.torso, torsoP = p, head = def.head, tp = tp}
	local function spec(s, pivot)
		local hand = tp * (pivot + s[1].Unit * REACH)
		return hand, tp:VectorToWorldSpace(s[2].Unit), s[3] and tp:VectorToWorldSpace(s[3])
	end
	local h, b, e = spec(def.r, PR)
	local arm, wrist, x, miss, err = Rig.solveSword(tp, h, b, e, seed.r)
	seed.r = x
	out.rArm, out.rArmP, out.wrist = arm.r, arm.p, wrist.r
	local ra = Rig.arm(tp, 1, pose(arm))
	local rh = Rig.handle(ra, pose(wrist))
	h, b, e = spec(def.l, PL)
	local armL, wristL, xl, missL, errL = Rig.solveLeft(tp, h, b, e, seed.l)
	seed.l = xl
	out.lArm, out.lArmP, out.lwrist = armL.r, armL.p, wristL.r
	local la = Rig.arm(tp, -1, pose(armL))
	local lh = Rig.handle(la, pose(wristL))
	out.rHandle, out.lHandle = rh, lh
	table.insert(K.log, ("%s %.3f R miss %.2f blade %d grip %d tip %.2f | L miss %.2f blade %d grip %d tip %.2f"):format(
		building, t or -1, miss, err, gripOff(ra, rh), (rh * V3(0, TIP, 0)).Y + 3, missL, errL, gripOff(la, lh), (lh * V3(0, TIP, 0)).Y + 3))
	return out
end

local JOINTS = {
	{"Torso", "torso", "torsoP"}, {"Head", "head"}, {"Right Arm", "rArm", "rArmP"}, {"Left Arm", "lArm", "lArmP"},
	{"RightKatana", "wrist"}, {"LeftKatana", "lwrist"},
}
local BRANCH = {["Right Arm"] = true, ["Left Arm"] = true, RightKatana = true, LeftKatana = true}

function K.track(beats, only)
	local joints = {}
	for _, j in ipairs(JOINTS) do
		if not only or only[j[1]] then
			local keys, used = {}, {}
			for _, b in ipairs(beats) do
				local p = b.pose
				local r = p[j[2]]
				if r then
					local t = math.max(0, b.t + (b.lag and b.lag[j[1]] or 0))
					t = math.floor(t * 1000 + 0.5) / 1000
					while used[t] do
						t += 0.001
					end
					used[t] = true
					local e = b.e
					if b.flat and b.flat[j[1]] then
						e = "flat"
					end
					table.insert(keys, {t = t, r = r, p = j[3] and p[j[3]] or nil, e = e})
				end
			end
			table.sort(keys, function(x, y)
				return x.t < y.t
			end)
			if BRANCH[j[1]] then
				for i = 2, #keys do
					keys[i].r = Rig.nearestEuler(keys[i].r, keys[i - 1].r)
				end
				local i = 1
				while i < #keys do
					local a, b = keys[i], keys[i + 1]
					local ca, cb = pose(a), pose(b)
					local _, ang = (ca.Rotation:Inverse() * cb.Rotation):ToAxisAngle()
					if math.deg(math.abs(ang)) > 45 and b.t - a.t > 0.02 then
						local ch = Poser.cfChan(ca:Lerp(cb, 0.5))
						local r = Rig.nearestEuler({ch[1], ch[2], ch[3]}, a.r)
						table.insert(keys, i + 1, {t = math.floor((a.t + b.t) * 500 + 0.5) / 1000, r = r, p = V3(ch[4], ch[5], ch[6])})
						keys[i + 2].r = Rig.nearestEuler(keys[i + 2].r, r)
					else
						i += 1
					end
				end
				for k = 2, #keys do
					keys[k].r = Rig.nearestEuler(keys[k].r, keys[k - 1].r)
				end
			end
			joints[j[1]] = keys
		end
	end
	if not only then
		joints["Right Leg"] = {{t = 0, r = {0, 0, 0}}}
		joints["Left Leg"] = {{t = 0, r = {0, 0, 0}}}
	end
	return joints
end

local function ramp(t, a, b)
	local u = math.clamp((t - a) / (b - a), 0, 1)
	return u * u * (3 - 2 * u)
end
K.ramp = ramp

local function lin(list, t)
	if t <= list[1][1] then
		return list[1][2]
	end
	for i = 2, #list do
		local a, b = list[i - 1], list[i]
		if t <= b[1] then
			return a[2] + (b[2] - a[2]) * (t - a[1]) / math.max(1e-6, b[1] - a[1])
		end
	end
	return list[#list][2]
end
K.lin = lin

function K.monotone(points)
	local n = #points
	local m = {}
	for i = 1, n do
		if i == 1 or i == n then
			m[i] = 0
		else
			local d0 = (points[i][2] - points[i - 1][2]) / (points[i][1] - points[i - 1][1])
			local d1 = (points[i + 1][2] - points[i][2]) / (points[i + 1][1] - points[i][1])
			m[i] = (d0 * d1 <= 0) and 0 or 2 / (1 / d0 + 1 / d1)
		end
	end
	return function(t)
		if t <= points[1][1] then
			return points[1][2]
		end
		for i = 2, n do
			local a, b = points[i - 1], points[i]
			if t <= b[1] then
				local h = b[1] - a[1]
				local s = (t - a[1]) / h
				local s2, s3 = s * s, s * s * s
				return (2 * s3 - 3 * s2 + 1) * a[2] + (s3 - 2 * s2 + s) * h * m[i - 1] + (-2 * s3 + 3 * s2) * b[2] + (s3 - s2) * h * m[i]
			end
		end
		return points[n][2]
	end
end

function K.steps(list, air, base)
	base = base or K.STANCE.feet
	local function foot(key)
		return function(t)
			local f = base[key]
			local x, z, yaw, lift = f[1], f[2], f[3], air and lin(air, t) or 0
			for _, s in ipairs(list) do
				if s.foot == key then
					local k = ramp(t, s[1], s[2])
					x += (s.to[1] or 0) * k
					z += (s.to[2] or 0) * k
					yaw += (s.to[3] or 0) * k
					if s.lift and t > s[1] and t < s[2] then
						lift = math.max(lift, s.lift * sin(math.pi * (t - s[1]) / (s[2] - s[1])))
					end
				end
			end
			return {x, z, yaw, lift}
		end
	end
	local r, l = foot("r"), foot("l")
	return function(t)
		return {r = r(t), l = l(t)}
	end, r, l
end

function K.tremble(windows, inner)
	return function(poses, t, ctx)
		for _, w in ipairs(windows) do
			if t > w[1] and t < w[2] then
				local k = ramp(t, w[1], w[1] + w.fade) * (1 - ramp(t, w[2] - w.fade, w[2]))
				for name, deg in pairs(w.amp) do
					local cf = poses[name]
					if cf then
						local seed = #name * 1.7
						local a = math.rad(deg * k)
						poses[name] = cf * CFrame.Angles(math.noise(t * w.rate, seed, 0.3) * a, math.noise(t * w.rate, seed, 4.1) * a * 0.6, math.noise(t * w.rate, seed, 7.9) * a)
					end
				end
			end
		end
		if inner then
			inner(poses, t, ctx)
		end
	end
end

return K
