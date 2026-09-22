-- a worked example of the motion-first method on a stock r6 character: an orthodox guard that breathes and a right
-- cross that starts and ends in it. Keys are poses; the spline carries speed through breakdowns, lag offsets the
-- joints, springs add follow-through, life keeps holds from freezing and a post pass plants the feet on the floor
-- after all of it. Needs Poser (with its Tw) and Feet next to it.
local Feet = require(script.Parent.Feet)

local V3 = Vector3.new
local sin, cos = math.sin, math.cos

local Example = {}

local function K(t, r, p, e)
	return {t = t, r = r, p = p, e = e}
end

-- an arm {lift, 0, side} that points dead ahead in root space while the torso is twisted by tw
local function aim(tw, down)
	local dx, dy, dz = sin(math.rad(tw)), -down, -cos(math.rad(tw))
	local n = math.sqrt(dx * dx + dy * dy + dz * dz)
	return {math.deg(math.asin(dz / -n)), 0, math.deg(math.atan2(dx / n, -dy / n))}
end

-- r6 has no waist: the torso turns about its centre, so a forward lean swings the hips back and a roll swings them
-- sideways; waist(r, p) adds the offset that keeps the hip centre where p puts it, so the body bends at the waist
local function waist(r, p)
	local l, s = math.rad(r[1]), math.rad(r[3])
	local keep = V3(-math.sin(s) * math.cos(l), -1 + math.cos(s) * math.cos(l), math.sin(l))
	return (p or Vector3.zero) + keep
end

-- a torso key that bends at the waist
local function T(t, r, p, e)
	return K(t, r, waist(r, p), e)
end

-- the guard: left side to the target (torso turned right), weight low, hands up and forward, face on the target
local G = {
	torso = {-8, -22, 0}, torsoY = -0.1,
	head = {6, 20, 0},
	rArm = {80, 0, -34}, rArmP = V3(0, 0.08, 0.05),
	lArm = {84, 0, 16}, lArmP = V3(0, 0.1, 0),
	-- the soles in root space (x right, z forward negative) and the toe yaw (positive turns to the left)
	rFoot = {0.6, 0.55, -18},
	lFoot = {-0.42, -0.5, 8},
}

local function guardKeys(t, breath)
	-- breath lifts the chest (lean back) and the root a little; the arms and head get it later through lag
	local b = breath or 0
	local ty = G.torsoY + 0.03 * b
	return {
		Torso = T(t, {G.torso[1] + 2 * b, G.torso[2], G.torso[3]}, V3(0, ty, 0)),
		Head = K(t, {G.head[1] - 1.2 * b, G.head[2], G.head[3]}),
		["Right Arm"] = K(t, {G.rArm[1] - 2 * b, G.rArm[2], G.rArm[3]}, G.rArmP),
		["Left Arm"] = K(t, {G.lArm[1] - 2.5 * b, G.lArm[2], G.lArm[3]}, G.lArmP),
		["Right Leg"] = K(t),
		["Left Leg"] = K(t),
	}
end

local function collect(list)
	local joints = {}
	for _, keys in ipairs(list) do
		for name, k in pairs(keys) do
			joints[name] = joints[name] or {}
			table.insert(joints[name], k)
		end
	end
	return joints
end

-- one breath every 3.2 s; the head answers 0.4 s later and the arms 0.6 s later, and life drifts on top
Example.Guard = {
	name = "Guard",
	length = 3.2,
	loop = true,
	curve = "spline",
	joints = collect({guardKeys(0, 0), guardKeys(1.4, 1), guardKeys(3.2, 0)}),
	lag = {Head = 0.4, ["Right Arm"] = 0.6, ["Left Arm"] = 0.7},
	life = 1,
	post = Feet.post({r = G.rFoot, l = G.lFoot}),
}

-- the cross, contact at 0.29 (Example.Cross.events.hit): GUARD -> LOAD at 0.12 (sink onto the back leg, shoulders
-- turn away, the rear fist draws back, 7 frames so the input still feels instant) -> the load keeps winding to 0.20
-- (a moving hold, never a freeze) -> STRIKE breakdown at 0.25 (hips and shoulders square, fist half way) -> CONTACT at
-- 0.29 (shoulder driven through, the body sitting down 0.36 into the punch, fist pistoned 0.35 forward, the lead hand
-- back to the chin, the back heel turned out) -> FOLLOW at 0.35 (the body keeps going past the contact) -> the
-- extended pose drifts to 0.45 -> the fist snaps home first at 0.55 while the torso and head trail -> GUARD at 0.72.
-- A rigid r6 leg cannot bend, so the 56 degree turn from guard to contact is only possible because the torso drops:
-- a search over turn, drop and stance kept every hip gap at 0 with a 34 degree contact turn and a 0.36 drop.
local LOAD = {torso = {-10, -36, 3}, torsoY = -0.2, torsoZ = 0.06, head = {4, 34, -2}}
local HIT = {torso = {-14, 34, -4}, torsoY = -0.36, torsoZ = -0.14, head = {-2, -31, 3}}
Example.Cross = {
	name = "Cross",
	length = 0.72,
	curve = "spline",
	events = {hit = 0.29},
	joints = {
		Torso = {
			T(0.00, G.torso, V3(0, G.torsoY, 0)),
			T(0.12, LOAD.torso, V3(0, LOAD.torsoY, LOAD.torsoZ)),
			T(0.20, {-11, -42, 4}, V3(0, -0.22, 0.08)),
			T(0.25, {-12, 0, 0}, V3(0, -0.28, -0.07)),
			T(0.29, HIT.torso, V3(0, HIT.torsoY, HIT.torsoZ)),
			T(0.35, {-16, 41, -5}, V3(0, -0.37, -0.18)),
			T(0.45, {-15, 43, -5}, V3(0, -0.36, -0.17)),
			T(0.58, {-10, 5, -1}, V3(0, -0.23, -0.05)),
			T(0.72, G.torso, V3(0, G.torsoY, 0)),
		},
		-- the eyes stay on the target: the head counters the torso twist on the torso's own frames
		Head = {
			K(0.00, G.head),
			K(0.12, LOAD.head),
			K(0.20, {3, 40, -2}),
			K(0.25, {1, 1, 0}),
			K(0.29, HIT.head),
			K(0.35, {-3, -38, 3}),
			K(0.45, {-3, -40, 3}),
			K(0.58, {4, -5, 1}),
			K(0.72, G.head),
		},
		["Right Arm"] = {
			K(0.00, G.rArm, G.rArmP),
			K(0.12, {58, 0, -24}, V3(0, 0.06, 0.16)),
			K(0.20, {54, 0, -22}, V3(0, 0.05, 0.2)),
			K(0.25, {78, 0, -18}, V3(0, 0.05, -0.05)),
			K(0.29, aim(34, 0.05), V3(0.04, 0.05, -0.36)),
			K(0.35, aim(41, 0.08), V3(0.05, 0.04, -0.4)),
			K(0.45, aim(43, 0.1), V3(0.05, 0.04, -0.38)),
			K(0.55, {76, 0, -30}, V3(0, 0.07, 0)),
			K(0.72, G.rArm, G.rArmP),
		},
		["Left Arm"] = {
			K(0.00, G.lArm, G.lArmP),
			K(0.12, {88, 0, 10}, V3(0, 0.1, -0.08)),
			K(0.20, {89, 0, 8}, V3(0, 0.1, -0.1)),
			-- the lead hand comes back to cover the chin: a straight r6 arm reaches it pointing up, forward and across; the
			-- crossed breakdown keeps the hand in front of the body (without it the euler path swung it 1.9 studs out)
			K(0.25, {55, 0, 100}, V3(0.03, 0.08, 0)),
			K(0.29, {46, 0, 120}, V3(0.05, 0.05, 0.05)),
			K(0.37, {44, 0, 118}, V3(0.05, 0.05, 0.06)),
			K(0.50, {48, 0, 114}, V3(0.05, 0.05, 0.05)),
			K(0.72, G.lArm, G.lArmP),
		},
		["Right Leg"] = {K(0)},
		["Left Leg"] = {K(0)},
	},
	-- no lag: the lead hand is pulled back on purpose, and a lagged lead arm was carried 1.95 studs out to the side by
	-- the torso's turn; the torso and the fist carry their overshoot in keys (0.35 is past the contact, 0.45 drifts
	-- further), because a spring on a part that must hit a frame trails it; the lead arm settles on a follow spring
	springs = {["Left Arm"] = "follow"},
	life = 0.6,
	-- the feet stay where the guard put them; the back heel turns out 30 degrees as the hips drive (a pivot on the ball,
	-- not a slide) and turns back in on the recovery
	post = Feet.post({
		r = function(t)
			local u = math.clamp((t - 0.2) / 0.09, 0, 1)
			local back = math.clamp((t - 0.5) / 0.2, 0, 1)
			local e = u * u * (3 - 2 * u) * (1 - back * back * (3 - 2 * back))
			return {G.rFoot[1], G.rFoot[2], G.rFoot[3] + 30 * e}
		end,
		l = G.lFoot,
	}),
}

Example.helpers = {K = K, T = T, waist = waist, aim = aim, collect = collect}

return Example
