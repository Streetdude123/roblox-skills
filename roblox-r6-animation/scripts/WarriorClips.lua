-- the Licensed To Strike warrior's idle, walk and run (2026-09-29 rebuild) on the motion-first method and the lesson
-- videos: one breath engine with the head and the free arm following it, a pull-back, hitch and settle of the sword
-- on the shoulder, a glance with an anticipation; a walk with contact, down, passing and up, the body rolling over the
-- stance leg, the free arm on an arc and the shouldered sword bobbing and settling each step; a run with a 22 degree
-- lean, flight, a back kick and a knee-up, both arms pumping and the sword held forward, pointing where the warrior faces. The warrior is an
-- r6-style custom rig (joints named by part: Torso, Head, RightArm, LeftArm, RightLeg, LeftLeg, Sword, Shield; C0 and C1
-- without rotation; hips at the legs' top centre 1.01 under the torso centre; legs 2.37 from hip to sole), so the feet
-- are planted with RigFeet instead of Feet. Warrior.build(rf) takes RigFeet.new(RigFeet.fromRig(...)) and returns
-- {Idle, Walk, Run, speeds}.
local V3 = Vector3.new
local rad, sin, cos, pi = math.rad, math.sin, math.cos, math.pi

local Warrior = {}

local HIP = 1.01
local CARRY_R = {8.2, -179.9, 172.0}
local CARRY_P = V3(-0.057, -2.08, 0.216)
local SWORD = {-7.0, 29.0, -16.0}

local function K(t, r, p, e)
	return {t = t, r = r, p = p, e = e}
end

-- the warrior's torso turns about its centre, so a lean swings the hips; this offset keeps the hip centre where p
-- puts it so the body bends at the waist (the hips sit HIP under the centre)
local function waist(r, p)
	local l, s = rad(r[1]), rad(r[3])
	return (p or Vector3.zero) + HIP * V3(-cos(l) * sin(s), -1 + cos(l) * cos(s), sin(l))
end

-- rows {u, lift, twist, side, x, y, z} at cycle fractions from 0; the first row closes the loop at u = 1
local function loop(T, rows, bend)
	local keys = {}
	local function add(u, row)
		local r = {row[2], row[3], row[4]}
		local p = V3(row[5] or 0, row[6] or 0, row[7] or 0)
		table.insert(keys, K(u * T, r, bend and waist(r, p) or p))
	end
	for _, row in ipairs(rows) do
		add(row[1], row)
	end
	add(1, rows[1])
	return keys
end

local function still(T)
	return {K(0), K(T)}
end

-- catmull-rom through points {w, a, b} (w from 0 to 1), returning a and b at w
local function path(points)
	return function(w)
		local n = #points
		local i = 1
		while i < n - 1 and points[i + 1][1] < w do
			i += 1
		end
		local p1, p2 = points[i], points[i + 1]
		local p0, p3 = points[math.max(1, i - 1)], points[math.min(n, i + 2)]
		local u = (w - p1[1]) / math.max(1e-6, p2[1] - p1[1])
		local out = {}
		for c = 2, 3 do
			local m1 = (p2[c] - p0[c]) / math.max(1e-6, p2[1] - p0[1]) * (p2[1] - p1[1])
			local m2 = (p3[c] - p1[c]) / math.max(1e-6, p3[1] - p1[1]) * (p2[1] - p1[1])
			local u2, u3 = u * u, u * u * u
			out[c - 1] = (2 * u3 - 3 * u2 + 1) * p1[c] + (u3 - 2 * u2 + u) * m1 + (-2 * u3 + 3 * u2) * p2[c] + (u3 - u2) * m2
		end
		return out[1], out[2]
	end
end

-- a gait foot in root space: planted from contact for duty of the cycle while the root moves at v (the sole slides
-- back exactly at v, so it stays put in the world), then a swing along swingPts {w, zFrac, lift} where zFrac 0 is the
-- toe-off spot and 1 the next contact
local function gaitFoot(T, v, phase, duty, x, zFront, yaw, swingPts)
	local S = v * T * duty
	local zBack = zFront + S
	local swing = path(swingPts)
	return function(t)
		local u = (t / T + phase) % 1
		if u < duty then
			return {x, zFront + v * u * T, yaw, 0}
		end
		local f, lift = swing((u - duty) / (1 - duty))
		return {x, zBack + (zFront - zBack) * f, yaw, math.max(0, lift)}
	end
end

function Warrior.build(rf)
	local out = {speeds = {}}

	-- idle: left foot forward (the shield side), the sword shoulder back; one breath engine at 3.2 s
	do
		local T = 3.2
		local post, stats = rf.post({r = {0.66, 0.3, -14}, l = {-0.56, -0.4, 9}})
		out.Idle = {
			name = "Warrior Idle (fixed)", length = T, loop = true, curve = "spline", post = post, stats = stats,
			life = {Torso = 0.5, Head = 1.0, LeftArm = 0.8},
			lag = {Head = 0.25, LeftArm = 0.45},
			springs = {Sword = "follow"},
			joints = {
				Torso = loop(T, {
					{0.0, -4.0, -9.0, 1.0, 0.02, -0.06},
					{0.28, -6.4, -8.2, 1.6, 0.05, -0.1},
					{0.55, -4.8, -9.6, 0.8, 0.03, -0.07},
					{0.72, -3.2, -10.0, 0.3, -0.01, -0.04},
				}, true),
				Head = loop(T, {
					{0.0, 4.0, 8.0, -1.0},
					{0.3, 6.0, 9.0, -1.5},
					{0.5, 5.0, 6.5, -0.5},
					{0.6, 3.0, 22.0, 1.0},
					{0.72, 3.5, 24.5, 1.5},
					{0.86, 4.5, 9.5, -0.5},
				}),
				LeftArm = loop(T, {
					{0.0, 6.0, 10.0, -7.0},
					{0.35, 9.0, 12.0, -9.0},
					{0.75, 5.0, 9.0, -6.5},
				}),
				RightArm = loop(T, {
					{0.0, CARRY_R[1], CARRY_R[2], CARRY_R[3], CARRY_P.X, CARRY_P.Y, CARRY_P.Z},
					{0.3, 7.2, CARRY_R[2], 172.3, CARRY_P.X, -2.09, CARRY_P.Z},
					{0.4, 7.6, CARRY_R[2], 172.0, CARRY_P.X, -2.1, CARRY_P.Z},
					{0.46, 9.8, CARRY_R[2], 171.2, CARRY_P.X, -2.05, CARRY_P.Z},
					{0.52, 8.4, CARRY_R[2], 171.8, CARRY_P.X, -2.074, CARRY_P.Z},
					{0.75, 8.8, CARRY_R[2], 172.0, CARRY_P.X, -2.076, CARRY_P.Z},
				}),
				Sword = loop(T, {
					{0.0, SWORD[1], SWORD[2], SWORD[3]},
					{0.45, SWORD[1] - 1.5, SWORD[2], SWORD[3]},
					{0.75, SWORD[1] + 0.5, SWORD[2], SWORD[3]},
				}),
				RightLeg = still(T),
				LeftLeg = still(T),
			},
		}
	end

	-- brisk walk built for 4.8 studs/s (he found 2 studs/s "WAY too slow"; WarriorConfig WalkSpeed, BackwardsWalkSpeed
	-- and the walk reference 4.8 play it at 1.0x): 0.84 s cycle, right contact at 0, left at 0.5; duty 0.59 gives a
	-- 2.38 stud stance, about the most a rigid 2.37 stud leg plants; the body lowest just after each contact
	do
		local T, v, duty = 0.84, 4.8, 0.59
		local swing = {{0, 0, 0}, {0.2, 0.08, 0.2}, {0.5, 0.5, 0.3}, {0.8, 0.94, 0.14}, {1, 1, 0}}
		local post, stats = rf.post({
			r = gaitFoot(T, v, 0, duty, 0.5, -1.08, -5, swing),
			l = gaitFoot(T, v, 0.5, duty, -0.5, -1.08, 5, swing),
		})
		out.speeds.Walk = v
		out.Walk = {
			name = "Warrior Walk (fixed)", length = T, loop = true, curve = "spline", post = post, stats = stats,
			life = {Head = 0.6},
			lag = {Head = 0.04, LeftArm = 0.03, RightArm = 0.04},
			springs = {Sword = "follow"},
			joints = {
				Torso = loop(T, {
					{0.0, -7.0, 4.0, -0.9, 0.02, -0.08},
					{0.1, -8.0, 3.0, -1.8, 0.05, -0.14},
					{0.3, -6.0, 0.0, -1.3, 0.05, -0.02},
					{0.38, -5.6, -1.2, -0.8, 0.04, 0.0},
					{0.5, -7.0, -4.0, 0.9, -0.02, -0.08},
					{0.6, -8.0, -3.0, 1.8, -0.05, -0.14},
					{0.8, -6.0, 0.0, 1.3, -0.05, -0.02},
					{0.88, -5.6, 1.2, 0.8, -0.04, 0.0},
				}, true),
				Head = loop(T, {
					{0.0, 8.0, -4.0, 0.8},
					{0.12, 9.5, -2.6, 1.5},
					{0.35, 7.0, 1.2, 1.0},
					{0.5, 8.0, 4.0, -0.8},
					{0.62, 9.5, 2.6, -1.5},
					{0.85, 7.0, -1.2, -1.0},
				}),
				LeftArm = loop(T, {
					{0.0, 24.0, 12.0, -8.0},
					{0.06, 26.0, 13.0, -8.5},
					{0.3, 4.0, 9.0, -5.0},
					{0.56, -22.0, 6.0, -9.0},
					{0.8, 3.0, 8.0, -5.0},
				}),
				RightArm = loop(T, {
					{0.0, CARRY_R[1], CARRY_R[2], CARRY_R[3], CARRY_P.X, CARRY_P.Y, CARRY_P.Z},
					{0.14, 6.4, CARRY_R[2], 172.6, CARRY_P.X, -2.12, CARRY_P.Z},
					{0.36, 9.6, CARRY_R[2], 171.4, CARRY_P.X, -2.05, CARRY_P.Z},
					{0.5, CARRY_R[1], CARRY_R[2], CARRY_R[3], CARRY_P.X, CARRY_P.Y, CARRY_P.Z},
					{0.64, 6.4, CARRY_R[2], 172.6, CARRY_P.X, -2.12, CARRY_P.Z},
					{0.86, 9.6, CARRY_R[2], 171.4, CARRY_P.X, -2.05, CARRY_P.Z},
				}),
				Sword = loop(T, {
					{0.0, SWORD[1], SWORD[2], SWORD[3]},
					{0.14, SWORD[1] - 3.0, SWORD[2], SWORD[3]},
					{0.36, SWORD[1] + 1.5, SWORD[2], SWORD[3]},
					{0.5, SWORD[1], SWORD[2], SWORD[3]},
					{0.64, SWORD[1] - 3.0, SWORD[2], SWORD[3]},
					{0.86, SWORD[1] + 1.5, SWORD[2], SWORD[3]},
				}),
				RightLeg = still(T),
				LeftLeg = still(T),
			},
		}
	end

	-- run built for 15 studs/s (set the run reference speed to 15; a 25 studs/s sprint plays it at 1.67x): right
	-- contact at 0, left at 0.5; duty 0.25 (flight between); swing: back kick, tuck, knee-up, reach
	do
		local T, v, duty = 0.64, 15.0, 0.25
		local swing = {{0, 0, 0}, {0.25, -0.12, 1.2}, {0.5, 0.55, 0.95}, {0.74, 1.13, 1.4}, {1, 1, 0}}
		local post, stats = rf.post({
			r = gaitFoot(T, v, 0, duty, 0.46, -1.05, -4, swing),
			l = gaitFoot(T, v, 0.5, duty, -0.46, -1.05, 4, swing),
		})
		out.speeds.Run = v
		out.Run = {
			name = "Warrior Run (fixed)", length = T, loop = true, curve = "spline", post = post, stats = stats,
			lag = {Head = 0.03},
			springs = {Sword = "follow"},
			joints = {
				Torso = loop(T, {
					{0.0, -22.0, -8.0, -2.0, 0.04, -0.12},
					{0.12, -24.0, -3.0, -3.0, 0.06, -0.2},
					{0.26, -21.5, 4.0, -1.0, 0.03, -0.14},
					{0.39, -20.0, 8.0, 1.0, 0.0, 0.1},
					{0.5, -22.0, 8.0, 2.0, -0.04, -0.12},
					{0.62, -24.0, 3.0, 3.0, -0.06, -0.2},
					{0.76, -21.5, -4.0, 1.0, -0.03, -0.14},
					{0.89, -20.0, -8.0, -1.0, 0.0, 0.1},
				}, true),
				Head = loop(T, {
					{0.0, 20.0, 6.0, 1.0},
					{0.12, 22.0, 2.0, 1.5},
					{0.39, 18.0, -6.0, -1.0},
					{0.5, 20.0, -6.0, -1.0},
					{0.62, 22.0, -2.0, -1.5},
					{0.89, 18.0, 6.0, 1.0},
				}),
				LeftArm = loop(T, {
					{0.0, 60.0, 18.0, 10.0},
					{0.04, 62.0, 20.0, 12.0},
					{0.27, 10.0, 6.0, -2.0},
					{0.52, -42.0, -5.0, -14.0},
					{0.77, 10.0, 6.0, -2.0},
				}),
				-- the sword arm pumps opposite the free arm ("the arm holding the sword while running needs to move"): 2 to
				-- 60 degrees against the leaned torso, one frame behind the free arm, crossing in on the forward swing and
				-- sliding up into the shoulder there for a bent-elbow read; the blade points where the warrior faces and
				-- rocks with the fist, the wrist giving at most 15 degrees off square so the tip stays off the floor
				RightArm = loop(T, {
					{0.0, 4.0, 3.0, 1.0, 0, 0.0},
					{0.05, 2.0, 3.0, 1.5, 0, 0.0},
					{0.29, 30.0, 1.0, -4.0, 0, 0.07},
					{0.54, 60.0, -2.0, -10.0, 0, 0.16, -0.05},
					{0.58, 58.0, -2.0, -10.0, 0, 0.16, -0.05},
					{0.79, 30.0, 1.0, -4.0, 0, 0.07},
				}),
				Sword = loop(T, {
					{0.0, 13.0, 0.0, 0.0},
					{0.05, 15.0, 0.0, 0.0},
					{0.29, 1.0, 0.0, 0.0},
					{0.56, -14.0, 0.0, 0.0},
					{0.79, 1.0, 0.0, 0.0},
				}),
				RightLeg = still(T),
				LeftLeg = still(T),
			},
		}
	end

	return out
end

return Warrior
