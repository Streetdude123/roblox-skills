local Poser = require(script.Parent.Poser)
local Feet = require(script.Parent.Feet)

local V3 = Vector3.new
local CF = CFrame.new
local pose = Poser.poseCF

local Rig = {}
Rig.Feet = Feet

-- solving every key costs over a second so results get baked into astasolvecache and looked up by their inputs and a miss just solves
local CACHE = {}
do
	local m = script.Parent:FindFirstChild("AstaSolveCache")
	if m then
		local ok, t = pcall(require, m)
		if ok and type(t) == "table" then
			CACHE = t
		end
	end
end
Rig.fresh = {}
Rig.hits, Rig.misses = 0, 0

local function keyOf(parts)
	local out = table.create(#parts)
	for i, v in ipairs(parts) do
		out[i] = ("%.4f"):format(v)
	end
	return table.concat(out, ",")
end

local function cfNums(cf, list)
	for _, v in ipairs({cf:GetComponents()}) do
		table.insert(list, v)
	end
end

-- fresh results as a module source for astasolvecache
function Rig.dumpCache()
	local lines = {"return {"}
	local keys = {}
	for k in pairs(Rig.fresh) do
		table.insert(keys, k)
	end
	table.sort(keys)
	for _, k in ipairs(keys) do
		local v = Rig.fresh[k]
		local nums = table.create(#v)
		for i, x in ipairs(v) do
			nums[i] = ("%.6f"):format(x)
		end
		table.insert(lines, ('\t["%s"] = {%s},'):format(k, table.concat(nums, ",")))
	end
	table.insert(lines, "}")
	return table.concat(lines, "\n")
end

-- grip in handle space and the blade tip measured off the demon slayer model
Rig.GRIP_Y = 0.35
Rig.TIP_Y = -6.33
Rig.POMMEL_Y = 1.81
Rig.REACH = Rig.GRIP_Y - Rig.TIP_Y
-- where the fist holds the handle in arm space
Rig.HAND = V3(0, -0.9, 0)
-- handle x to arm x and handle y (pommel) to arm z and handle z (one edge) to arm -y
Rig.GRIP_R = CFrame.fromMatrix(Vector3.zero, V3(1, 0, 0), V3(0, 0, 1), V3(0, -1, 0))

-- r6 has no waist so a lean swings the hips - this keeps the hip centre where p puts it
function Rig.waist(r, p)
	local l, s = math.rad(r[1]), math.rad(r[3])
	return (p or Vector3.zero) + V3(-math.sin(s) * math.cos(l), -1 + math.cos(s) * math.cos(l), math.sin(l))
end

function Rig.torso(r, p)
	return pose({r = r, p = p})
end

-- arm in root space for a torso pose and an arm pose (s is 1 right and -1 left)
function Rig.arm(tp, s, armCF)
	return tp * CF(s, 0.5, 0) * armCF * CF(0.5 * s, -0.5, 0)
end

-- sword handle in root space and scale shrinks the grip offset with the model
function Rig.handle(armCF, wristCF, scale)
	return armCF * CF(0, -0.9, 0) * wristCF * Rig.GRIP_R * CF(0, -Rig.GRIP_Y * (scale or 1), 0)
end

function Rig.gripPoint(armCF)
	return armCF * Rig.HAND
end

-- nelder mead so every key can be a hand point and a blade direction instead of euler guesses
local function minimize(f, x0, step, iters)
	local n = #x0
	local pts, vals = {}, {}
	pts[1] = table.clone(x0)
	vals[1] = f(pts[1])
	for i = 1, n do
		local p = table.clone(x0)
		p[i] += step[i]
		pts[i + 1] = p
		vals[i + 1] = f(p)
	end
	for _ = 1, iters do
		local order = {}
		for i = 1, n + 1 do
			order[i] = i
		end
		table.sort(order, function(a, b)
			return vals[a] < vals[b]
		end)
		local P, Vv = {}, {}
		for i, k in ipairs(order) do
			P[i], Vv[i] = pts[k], vals[k]
		end
		pts, vals = P, Vv
		local c = table.create(n, 0)
		for i = 1, n do
			for j = 1, n do
				c[j] += pts[i][j] / n
			end
		end
		local worst = pts[n + 1]
		local function lerp(t)
			local q = table.create(n)
			for j = 1, n do
				q[j] = c[j] + t * (worst[j] - c[j])
			end
			return q
		end
		local xr = lerp(-1)
		local fr = f(xr)
		if fr < vals[1] then
			local xe = lerp(-2)
			local fe = f(xe)
			if fe < fr then
				pts[n + 1], vals[n + 1] = xe, fe
			else
				pts[n + 1], vals[n + 1] = xr, fr
			end
		elseif fr < vals[n] then
			pts[n + 1], vals[n + 1] = xr, fr
		else
			local xc = lerp(0.5)
			local fc = f(xc)
			if fc < vals[n + 1] then
				pts[n + 1], vals[n + 1] = xc, fc
			else
				for i = 2, n + 1 do
					for j = 1, n do
						pts[i][j] = pts[1][j] + 0.5 * (pts[i][j] - pts[1][j])
					end
					vals[i] = f(pts[i])
				end
			end
		end
	end
	local best, bv = pts[1], vals[1]
	for i = 2, n + 1 do
		if vals[i] < bv then
			best, bv = pts[i], vals[i]
		end
	end
	return best, bv
end
Rig.minimize = minimize

local function over(x, lim)
	local e = math.abs(x) - lim
	return e > 0 and e * e or 0
end

-- how far an arm is turned about its own length vs the same arm swung straight from pointing forward - a raise over the head sideways reads 180 since the block lands on the wrong side of its offset pivot
function Rig.physTwist(R)
	local d = R:VectorToWorldSpace(V3(0, -1, 0))
	local ref = V3(0, 0, -1)
	local axis = ref:Cross(d)
	local s, c = axis.Magnitude, ref:Dot(d)
	local S
	if s < 1e-6 then
		S = c > 0 and CFrame.identity or CFrame.fromAxisAngle(Vector3.xAxis, math.pi)
	else
		S = CFrame.fromAxisAngle(axis / s, math.atan2(s, c))
	end
	local fq = (S * CFrame.Angles(math.pi / 2, 0, 0)):VectorToWorldSpace(V3(0, 0, -1))
	local f = R:VectorToWorldSpace(V3(0, 0, -1))
	return math.deg(math.atan2(d:Dot(fq:Cross(f)), fq:Dot(f)))
end

-- same rotation as {lift twist side} written nearest a previous key since poser splines each channel and two keys on different branches spin the joint the long way round
function Rig.nearestEuler(r, prev)
	local best, bd
	for _, cand in ipairs({{r[1], r[2], r[3]}, {180 - r[1], r[2] + 180, r[3] + 180}}) do
		for i = 1, 3 do
			while cand[i] - prev[i] > 180 do
				cand[i] -= 360
			end
			while cand[i] - prev[i] < -180 do
				cand[i] += 360
			end
		end
		local d = (cand[1] - prev[1]) ^ 2 + (cand[2] - prev[2]) ^ 2 + (cand[3] - prev[3]) ^ 2
		if not bd or d < bd then
			best, bd = cand, d
		end
	end
	return best
end

-- sword arm for a hand point and blade direction in root space - edge is where the handle +z edge faces and seed keeps it near the last key
local solveSwordRaw
function Rig.solveSword(tp, hand, blade, edge, seed)
	seed = seed or {40, 0, 10, 0, 0, 0}
	for i = #seed + 1, 6 do
		seed[i] = 0
	end
	local parts = {}
	cfNums(tp, parts)
	local e = edge or Vector3.zero
	for _, v in ipairs({hand.X, hand.Y, hand.Z, blade.Unit.X, blade.Unit.Y, blade.Unit.Z, e.X, e.Y, e.Z}) do
		table.insert(parts, v)
	end
	for i = 1, 6 do
		table.insert(parts, seed[i])
	end
	local k = "S" .. keyOf(parts)
	local v = CACHE[k]
	if v then
		Rig.hits += 1
		return {r = {v[1], v[2], v[3]}, p = V3(v[4], v[5], v[6])}, {r = {v[7], v[8], v[9]}}, {v[10], v[11], v[12], v[13], v[14], v[15]}, v[16], v[17]
	end
	Rig.misses += 1
	local arm, wrist, best, left, err = solveSwordRaw(tp, hand, blade, edge, seed)
	-- rounded the way the cache stores them so a baked run and a fresh run feed the next key the same seeds
	local v2 = {arm.r[1], arm.r[2], arm.r[3], arm.p.X, arm.p.Y, arm.p.Z, wrist.r[1], wrist.r[2], wrist.r[3], best[1], best[2], best[3], best[4], best[5], best[6], left, err}
	for i, x in ipairs(v2) do
		v2[i] = tonumber(("%.6f"):format(x))
	end
	Rig.fresh[k] = v2
	return {r = {v2[1], v2[2], v2[3]}, p = V3(v2[4], v2[5], v2[6])}, {r = {v2[7], v2[8], v2[9]}}, {v2[10], v2[11], v2[12], v2[13], v2[14], v2[15]}, v2[16], v2[17]
end

function solveSwordRaw(tp, hand, blade, edge, seed)
	blade = blade.Unit
	local ep
	if edge then
		ep = edge - blade * edge:Dot(blade)
		ep = ep.Magnitude > 1e-3 and ep.Unit or nil
	end
	local pivot = (tp * CF(1, 0.5, 0)).Position
	local want = (hand - pivot).Unit
	local prevArm = pose({r = {seed[1], seed[2], seed[3]}})
	local prevWrist = pose({r = {seed[4], seed[5], seed[6]}})
	local function cost(x)
		local a = Rig.arm(tp, 1, pose({r = {x[1], x[2], x[3]}}))
		local g = a * Rig.HAND
		local h = Rig.handle(a, pose({r = {x[4], x[5], x[6]}}))
		local bd = h:VectorToWorldSpace(V3(0, -1, 0))
		-- arm is rigid so the hand gets matched by its direction from the shoulder and p takes the distance
		local c = 60 * (1 - (g - pivot).Unit:Dot(want)) + 40 * (1 - bd:Dot(blade))
		if ep then
			c += 10 * (1 - h:VectorToWorldSpace(V3(0, 0, 1)):Dot(ep))
		end
		-- r6 shoulder pivots on the arm's inner edge so a big twist swings the whole block around it - the fist has no visible orientation so the handle can turn any way as long as the blade doesn't fold back into the forearm
		local tw = Rig.physTwist(pose({r = {x[1], x[2], x[3]}}))
		c += 0.5 * (tw / 35) ^ 2 + 2 * over(tw, 65) / 25
		local fold = bd:Dot(a.UpVector)
		if fold > 0.35 then
			c += 40 * (fold - 0.35) ^ 2
		end
		c += 0.08 * ((x[4] / 90) ^ 2 + (x[5] / 90) ^ 2 + (x[6] / 90) ^ 2)
		-- stay physically near the last key (the rotation between them not the channel numbers) or a strike flips to a lookalike solution and whips the sword around
		local _, aa = (prevArm:Inverse() * pose({r = {x[1], x[2], x[3]}})):ToAxisAngle()
		local _, wa = (prevWrist:Inverse() * pose({r = {x[4], x[5], x[6]}})):ToAxisAngle()
		c += 0.9 * (aa / (math.pi / 2)) ^ 2 + 0.45 * (wa / (math.pi / 2)) ^ 2
		return c
	end
	local best, bv
	for _, d in ipairs({{0, 0, 0}, {35, 0, 0}, {-35, 0, 0}, {0, 35, 0}, {0, -35, 0}, {0, 0, 35}, {0, 0, -35}}) do
		local s = table.clone(seed)
		s[4] += d[1]
		s[5] += d[2]
		s[6] += d[3]
		local x = minimize(cost, s, {20, 10, 20, 25, 25, 25}, 320)
		x = minimize(cost, x, {5, 3, 5, 6, 6, 6}, 200)
		local v = cost(x)
		if not bv or v < bv - 1e-4 then
			best, bv = x, v
		end
	end
	local armR = Rig.nearestEuler({best[1], best[2], best[3]}, {seed[1], seed[2], seed[3]})
	local wristR = Rig.nearestEuler({best[4], best[5], best[6]}, {seed[4], seed[5], seed[6]})
	best = {armR[1], armR[2], armR[3], wristR[1], wristR[2], wristR[3]}
	local a = Rig.arm(tp, 1, pose({r = {best[1], best[2], best[3]}}))
	local miss = hand - a * Rig.HAND
	-- whatever the rigid arm can't reach comes from sliding it in the socket but never more than a third of a stud
	local p = tp.Rotation:Inverse() * miss
	if p.Magnitude > 0.32 then
		p = p.Unit * 0.32
	end
	local h = Rig.handle(Rig.arm(tp, 1, pose({r = {best[1], best[2], best[3]}, p = p})), pose({r = {best[4], best[5], best[6]}}))
	local bladeErr = math.deg(math.acos(math.clamp(h:VectorToWorldSpace(V3(0, -1, 0)):Dot(blade), -1, 1)))
	local left = (hand - Rig.arm(tp, 1, pose({r = {best[1], best[2], best[3]}, p = p})) * Rig.HAND).Magnitude
	return {r = {best[1], best[2], best[3]}, p = p}, {r = {best[4], best[5], best[6]}}, best, left, bladeErr
end

-- free arm's grip point on a target like the other hand on the handle
local solveReachRaw
function Rig.solveReach(tp, s, target, seed)
	seed = seed or {30, 0, -10 * s}
	local parts = {}
	cfNums(tp, parts)
	for _, v in ipairs({s, target.X, target.Y, target.Z, seed[1], seed[2], seed[3]}) do
		table.insert(parts, v)
	end
	local k = "R" .. keyOf(parts)
	local v = CACHE[k]
	if v then
		Rig.hits += 1
		return {r = {v[1], v[2], v[3]}, p = V3(v[4], v[5], v[6])}, {v[7], v[8], v[9]}
	end
	Rig.misses += 1
	local arm, x = solveReachRaw(tp, s, target, seed)
	local v2 = {arm.r[1], arm.r[2], arm.r[3], arm.p.X, arm.p.Y, arm.p.Z, x[1], x[2], x[3]}
	for i, n in ipairs(v2) do
		v2[i] = tonumber(("%.6f"):format(n))
	end
	Rig.fresh[k] = v2
	return {r = {v2[1], v2[2], v2[3]}, p = V3(v2[4], v2[5], v2[6])}, {v2[7], v2[8], v2[9]}
end

function solveReachRaw(tp, s, target, seed)
	local function cost(x)
		local R = pose({r = {x[1], x[2], x[3]}})
		local a = Rig.arm(tp, s, R)
		local tw = Rig.physTwist(R)
		local c = 40 * (a * Rig.HAND - target).Magnitude ^ 2 + 0.5 * (tw / 35) ^ 2 + 2 * over(tw, 65) / 25
		for i = 1, 3 do
			c += 0.6 * ((x[i] - seed[i]) / 90) ^ 2
		end
		return c
	end
	local x = minimize(cost, table.clone(seed), {25, 30, 25}, 220)
	x = minimize(cost, x, {6, 8, 6}, 120)
	local a = Rig.arm(tp, s, pose({r = {x[1], x[2], x[3]}}))
	local p = tp.Rotation:Inverse() * (target - a * Rig.HAND)
	if p.Magnitude > 0.3 then
		p = p.Unit * 0.3
	end
	return {r = {x[1], x[2], x[3]}, p = p}, x
end

-- torso offset that seats the body on its feet for a lean then crouches lower (legs slide up into the hips which reads as bent knees)
function Rig.seat(r, tx, tz, crouch, feet)
	local lo, hi = -2.5, 0.8
	for _ = 1, 22 do
		local mid = (lo + hi) / 2
		local tp = pose({p = Rig.waist(r, V3(tx, mid, tz)), r = r})
		local g = math.max(Feet.gap(tp, 1, feet.r[1], feet.r[2]), Feet.gap(tp, -1, feet.l[1], feet.l[2]))
		if g > 0.002 then
			hi = mid
		else
			lo = mid
		end
	end
	return Rig.waist(r, V3(tx, lo - (crouch or 0), tz))
end

-- whole body key from a def in root space: torso and hip centre and crouch and head and the sword hand {point blade edge} and the free hand as angles or a point or grip - seed carries the last solution
function Rig.body(def, seed)
	seed = seed or {}
	local p = def.torsoP or Rig.seat(def.torso, def.tx or 0, def.tz or 0, def.crouch, def.feet)
	-- rise lifts the body off its seat for a jump and the feet lift in the post pass
	if def.rise then
		p += V3(0, def.rise, 0)
	end
	local tp = pose({p = p, r = def.torso})
	-- swordLocal is the sword spec in torso space so a spinning body carries the blade round with it
	if def.swordLocal then
		local s = def.swordLocal
		def.sword = {tp * s[1], tp:VectorToWorldSpace(s[2]), tp:VectorToWorldSpace(s[3]), exact = s.exact}
	end
	local out = {torso = def.torso, torsoP = p, head = def.head, tp = tp}
	if def.sword then
		local hand = def.sword[1]
		-- rigid arm can't reach a point closer than its length so the hand point only gives the direction and the fist sits at arm's length - exact keeps the point for the hilt grab
		if def.sword.dir then
			hand = (tp * CF(1, 0.5, 0)).Position + def.sword.dir.Unit * 1.487
		elseif not def.sword.exact then
			local pivot = (tp * CF(1, 0.5, 0)).Position
			hand = pivot + (hand - pivot).Unit * 1.487
		end
		local arm, wrist, x, miss, err = Rig.solveSword(tp, hand, def.sword[2], def.sword[3], seed.sword)
		out.rArm, out.rArmP, out.wrist, out.miss, out.bladeErr = arm.r, arm.p, wrist.r, miss, err
		seed.sword = x
		out.handle = Rig.handle(Rig.arm(tp, 1, pose(arm)), pose(wrist))
	else
		out.rArm, out.rArmP = def.rArm, def.rArmP or V3(0, -0.04, 0)
		out.wrist = def.wrist or {0, 0, 0}
	end
	local l = def.lArm
	if l == "grip" and out.handle then
		local target = out.handle * V3(0, Rig.GRIP_Y + 1.05, 0)
		local k, x = Rig.solveReach(tp, -1, target, seed.left)
		out.lArm, out.lArmP = k.r, k.p
		seed.left = x
		-- how far the left fist stays off the handle so a two handed key the arm cannot reach shows up
		out.leftMiss = (Rig.gripPoint(Rig.arm(tp, -1, pose(k))) - target).Magnitude
	elseif typeof(l) == "Vector3" then
		local k, x = Rig.solveReach(tp, -1, l, seed.left)
		out.lArm, out.lArmP = k.r, k.p
		seed.left = x
	else
		out.lArm, out.lArmP = l, def.lArmP or V3(0, -0.04, 0)
		seed.left = nil
	end
	return out, seed
end

return Rig
