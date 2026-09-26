local Feet = require(script.Parent.Feet)
local Ex = require(script.Parent.ExampleClips)
local K, T, aim = Ex.helpers.K, Ex.helpers.T, Ex.helpers.aim
local V3 = Vector3.new

local Example = {}

local S = {
	torso = {-1, 4, 0},
	head = {-4, -3, 1},
	rArm = {35, 0, -5},
	lArm = {30, 0, 18},
	rFoot = {0.5, 0.12, -6},
	lFoot = {-0.5, -0.1, 8},
}

local GRIP = math.rad(25)
local GRIP_R = CFrame.fromMatrix(Vector3.zero, Vector3.xAxis, Vector3.new(0, math.sin(GRIP), -math.cos(GRIP)))

local function staff(post)
	return function(poses, t, ctx)
		post(poses, t, ctx)
		local arm = (poses.Torso * CFrame.new(1, 0.5, 0) * poses["Right Arm"]).Rotation
		local pitch = math.deg(math.asin(math.clamp(-arm.YVector.Y, -1, 1)))
		local lean = math.rad(-8 + 38 * math.clamp(-pitch / 90, 0, 1))
		local up = Vector3.new(0.12, math.cos(lean), -math.sin(lean)).Unit
		local side = (Vector3.xAxis - up * up.X).Unit
		poses.Grip = arm:Inverse() * CFrame.fromMatrix(Vector3.zero, side, up) * GRIP_R:Inverse()
	end
end

local stand = staff(Feet.post({r = S.rFoot, l = S.lFoot}))

local function add(v, d)
	return {v[1] + d[1], v[2] + d[2], v[3] + d[3]}
end

Example.CalmIdle = {
	name = "CalmIdle",
	length = 4,
	loop = true,
	curve = "spline",
	joints = {
		Torso = {
			T(0, S.torso, V3(0, 0, 0)),
			T(1.8, add(S.torso, {2, 1, 0}), V3(0, 0.03, 0)),
			T(4, S.torso, V3(0, 0, 0)),
		},
		Head = {
			K(0, S.head),
			K(1.3, {-3, 3, 0}),
			K(2.9, {-6, -5, 2}),
			K(4, S.head),
		},
		["Right Arm"] = {
			K(0, S.rArm),
			K(2, add(S.rArm, {-3, 0, 0})),
			K(4, S.rArm),
		},
		["Left Arm"] = {
			K(0, S.lArm),
			K(2.2, add(S.lArm, {-4, 0, 1})),
			K(4, S.lArm),
		},
		["Right Leg"] = {K(0)},
		["Left Leg"] = {K(0)},
		Grip = {K(0)},
	},
	lag = {Head = 0.4, ["Right Arm"] = 0.6, ["Left Arm"] = 0.7},
	life = 1,
	post = stand,
}

local AIM = aim(14, 0.05)

Example.Zoltraak = {
	name = "Zoltraak",
	length = 2.8,
	curve = "spline",
	events = {circle = 0.65, fire = 1.3, beam = 1.43, beamEnd = 2.05},
	joints = {
		Torso = {
			T(0, S.torso, V3(0, 0, 0)),
			T(0.3, {-1, 6, 0}, V3(0, 0.02, 0)),
			T(0.62, {-3, 14, -2}, V3(0, 0, -0.03)),
			T(1.25, {-4, 16, -2}, V3(0, -0.01, -0.05)),
			T(1.36, {1, 13, -1}, V3(0, 0, 0.03)),
			T(1.5, {-1, 14, -1}, V3(0, 0, 0)),
			T(2.05, {-2, 15, -2}, V3(0, -0.01, -0.02)),
			T(2.45, {-1, 8, -1}, V3(0, 0, 0)),
			T(2.8, S.torso, V3(0, 0, 0)),
		},
		Head = {
			K(0, S.head),
			K(0.25, {2, -4, 0}),
			K(0.55, {1, -12, 0}),
			K(1.25, {0, -13, 0}),
			K(1.36, {3, -12, -1}),
			K(2.05, {0, -13, 0}),
			K(2.5, {-3, -7, 1}),
			K(2.8, S.head),
		},
		["Right Arm"] = {
			K(0, S.rArm),
			K(0.4, {48, 0, -5}),
			K(0.62, AIM, V3(0, 0.05, -0.08)),
			K(0.72, add(AIM, {2, 0, 0}), V3(0, 0.05, -0.1)),
			K(1.25, add(AIM, {1, 0, -1}), V3(0, 0.05, -0.12)),
			K(1.36, add(AIM, {7, 0, 0}), V3(0, 0.06, -0.02)),
			K(1.5, AIM, V3(0, 0.05, -0.08)),
			K(2.05, add(AIM, {1, 0, 0}), V3(0, 0.05, -0.1)),
			K(2.35, {55, 0, -6}),
			K(2.8, S.rArm),
		},
		["Left Arm"] = {
			K(0, S.lArm),
			K(0.6, {26, 0, 14}),
			K(1.36, {22, 0, 12}),
			K(2.05, {25, 0, 14}),
			K(2.8, S.lArm),
		},
		["Right Leg"] = {K(0)},
		["Left Leg"] = {K(0)},
		Grip = {K(0)},
	},
	lag = {["Left Arm"] = 0.1},
	springs = {["Left Arm"] = "follow"},
	life = 0.8,
	post = stand,
}

local B = {torso = {-1, 8, 0}, head = {-2, -6, 0}, rArm = aim(8, 0.45), lArm = {20, 0, 12}}

Example.BarrierRaise = {
	name = "BarrierRaise",
	length = 0.7,
	curve = "spline",
	events = {raise = 0.3},
	joints = {
		Torso = {
			T(0, S.torso, V3(0, 0, 0)),
			T(0.3, B.torso, V3(0, 0, -0.02)),
			T(0.7, B.torso, V3(0, 0, 0)),
		},
		Head = {
			K(0, S.head),
			K(0.14, {0, -4, 0}),
			K(0.7, B.head),
		},
		["Right Arm"] = {
			K(0, S.rArm),
			K(0.12, {44, 0, -5}),
			K(0.3, B.rArm, V3(0, 0.04, -0.08)),
			K(0.36, add(B.rArm, {2, 0, 0}), V3(0, 0.04, -0.11)),
			K(0.7, B.rArm, V3(0, 0.04, -0.08)),
		},
		["Left Arm"] = {
			K(0, S.lArm),
			K(0.4, B.lArm),
			K(0.7, B.lArm),
		},
		["Right Leg"] = {K(0)},
		["Left Leg"] = {K(0)},
		Grip = {K(0)},
	},
	springs = {["Left Arm"] = "follow"},
	life = 0.6,
	post = stand,
}

Example.BarrierHold = {
	name = "BarrierHold",
	length = 3.2,
	loop = true,
	curve = "spline",
	joints = {
		Torso = {
			T(0, B.torso, V3(0, 0, 0)),
			T(1.5, add(B.torso, {2, 0, 0}), V3(0, 0.03, 0)),
			T(3.2, B.torso, V3(0, 0, 0)),
		},
		Head = {
			K(0, B.head),
			K(1.6, add(B.head, {-1.5, 2, 0})),
			K(3.2, B.head),
		},
		["Right Arm"] = {
			K(0, B.rArm, V3(0, 0.04, -0.08)),
			K(1.6, add(B.rArm, {-2, 0, 1}), V3(0, 0.05, -0.1)),
			K(3.2, B.rArm, V3(0, 0.04, -0.08)),
		},
		["Left Arm"] = {
			K(0, B.lArm),
			K(1.7, add(B.lArm, {-3, 0, 0})),
			K(3.2, B.lArm),
		},
		["Right Leg"] = {K(0)},
		["Left Leg"] = {K(0)},
		Grip = {K(0)},
	},
	lag = {Head = 0.4, ["Left Arm"] = 0.6},
	life = 0.8,
	post = stand,
}

Example.BarrierHit = {
	name = "BarrierHit",
	length = 0.45,
	curve = "spline",
	events = {hit = 0},
	joints = {
		Torso = {
			T(0, B.torso, V3(0, 0, 0)),
			T(0.07, add(B.torso, {3, -2, 0}), V3(0, 0, 0.05)),
			T(0.45, B.torso, V3(0, 0, 0)),
		},
		Head = {
			K(0, B.head),
			K(0.1, add(B.head, {3, 1, 0})),
			K(0.45, B.head),
		},
		["Right Arm"] = {
			K(0, B.rArm, V3(0, 0.04, -0.08)),
			K(0.05, add(B.rArm, {5, 0, 2}), V3(0, 0.04, 0)),
			K(0.2, add(B.rArm, {-1, 0, 0}), V3(0, 0.04, -0.1)),
			K(0.45, B.rArm, V3(0, 0.04, -0.08)),
		},
		["Left Arm"] = {
			K(0, B.lArm),
			K(0.45, B.lArm),
		},
		["Right Leg"] = {K(0)},
		["Left Leg"] = {K(0)},
		Grip = {K(0)},
	},
	springs = {Head = "follow", ["Left Arm"] = "follow"},
	life = 0.6,
	post = stand,
}

local CUP = {r = {62, 0, -80}, l = {68, 0, 92}}

Example.Flowers = {
	name = "Flowers",
	length = 3.6,
	curve = "spline",
	events = {gather = 0.75, release = 1.9, bloom = 2.25},
	joints = {
		Torso = {
			T(0, S.torso, V3(0, 0, 0)),
			T(0.35, {-1, 3, 0}, V3(0, 0, 0)),
			T(0.8, {-4, 2, 0}, V3(0, -0.02, 0)),
			T(1.85, {-3, 1, 0}, V3(0, 0, 0)),
			T(2.25, {1, 2, 0}, V3(0, 0.03, 0)),
			T(3.1, {0, 6, 0}, V3(0, 0, 0)),
			T(3.6, S.torso, V3(0, 0, 0)),
		},
		Head = {
			K(0, S.head),
			K(0.15, {-6, -2, 0}),
			K(0.7, {-18, 0, 2}),
			K(1.6, {-14, 1, 2}),
			K(2.2, {6, 0, 0}),
			K(2.6, {-6, 12, -1}),
			K(3.1, {-8, -4, 1}),
			K(3.6, S.head),
		},
		["Right Arm"] = {
			K(0, S.rArm),
			K(0.25, {44, 0, -30}),
			K(0.75, CUP.r, V3(0, 0.03, 0)),
			K(1.85, add(CUP.r, {4, 0, -10}), V3(0, 0.06, 0)),
			K(2.25, {50, 0, 28}, V3(0, 0.05, 0)),
			K(3.1, {42, 0, 10}),
			K(3.6, S.rArm),
		},
		["Left Arm"] = {
			K(0, S.lArm),
			K(0.3, {36, 0, 24}),
			K(0.78, CUP.l, V3(0, 0.03, 0)),
			K(1.85, add(CUP.l, {4, 0, 10}), V3(0, 0.06, 0)),
			K(2.31, {60, 0, -20}, V3(0, 0.05, 0)),
			K(3.1, {40, 0, -12}),
			K(3.6, S.lArm),
		},
		["Right Leg"] = {K(0)},
		["Left Leg"] = {K(0)},
		Grip = {K(0)},
	},
	lag = {Torso = 0.1},
	life = 0.8,
	post = stand,
}

local SHOTS = {0.35, 0.53, 0.71, 0.89, 1.07}

local function volleyArm()
	local keys = {K(0, S.rArm), K(0.15, add(AIM, {8, 0, 0}), V3(0, 0.05, -0.06)), K(0.24, AIM, V3(0, 0.05, -0.1))}
	for i, t in ipairs(SHOTS) do
		table.insert(keys, K(t, add(AIM, {1, 0, 0}), V3(0, 0.05, -0.1)))
		table.insert(keys, K(t + 0.05, add(AIM, {5 + i * 0.5, 0, 0}), V3(0, 0.06, -0.04)))
	end
	table.insert(keys, K(1.3, add(AIM, {1, 0, 0}), V3(0, 0.05, -0.1)))
	table.insert(keys, K(1.62, {52, 0, -6}))
	table.insert(keys, K(1.9, S.rArm))
	return keys
end

Example.ZoltraakVolley = {
	name = "ZoltraakVolley",
	length = 1.9,
	curve = "spline",
	events = {circle = 0.15, shot1 = SHOTS[1], shot2 = SHOTS[2], shot3 = SHOTS[3], shot4 = SHOTS[4], shot5 = SHOTS[5]},
	joints = {
		Torso = {
			T(0, S.torso, V3(0, 0, 0)),
			T(0.16, {-3, 15, -2}, V3(0, -0.02, -0.03)),
			T(0.6, {-4, 16, -2}, V3(0, -0.03, -0.04)),
			T(1.1, {-2, 15, -1}, V3(0, -0.02, -0.02)),
			T(1.5, {-1, 9, -1}, V3(0, 0, 0)),
			T(1.9, S.torso, V3(0, 0, 0)),
		},
		Head = {
			K(0, S.head),
			K(0.08, {1, -12, 0}),
			K(1.2, {0, -14, 0}),
			K(1.6, {-3, -7, 1}),
			K(1.9, S.head),
		},
		["Right Arm"] = volleyArm(),
		["Left Arm"] = {
			K(0, S.lArm),
			K(0.2, {24, 0, 13}),
			K(1.2, {22, 0, 12}),
			K(1.9, S.lArm),
		},
		["Right Leg"] = {K(0)},
		["Left Leg"] = {K(0)},
		Grip = {K(0)},
	},
	lag = {["Left Arm"] = 0.08},
	springs = {["Left Arm"] = "follow"},
	life = 0.6,
	post = stand,
}

local WALK = {cycle = 0.66, speed = 6, stance = 0.55, width = 0.42, lift = 0.3}

local function walkFoot(offset, x, yaw)
	return function(t)
		local c = WALK.cycle
		local u = ((t / c + offset) % 1)
		local reach = WALK.speed * c * WALK.stance / 2
		if u < WALK.stance then
			return {x, -reach + WALK.speed * c * u, yaw}
		end
		local v = (u - WALK.stance) / (1 - WALK.stance)
		local e = v * v * (3 - 2 * v)
		return {x, reach - WALK.speed * c * e + WALK.speed * c * (1 - WALK.stance) * v, yaw, WALK.lift * math.sin(math.pi * v)}
	end
end

local function walkDrop(t)
	local c = WALK.cycle
	local reach = WALK.speed * c * WALK.stance / 2
	local drop = 0
	for _, offset in ipairs({0, 0.5}) do
		local u = (t / c + offset) % 1
		if u < WALK.stance then
			local z = -reach + WALK.speed * c * u
			drop = math.max(drop, 2 - math.sqrt(4 - z * z))
		end
	end
	return drop
end

local function walkKeys()
	local joints = {Torso = {}, Head = {}, ["Right Arm"] = {}, ["Left Arm"] = {}, ["Right Leg"] = {K(0)}, ["Left Leg"] = {K(0)}, Grip = {K(0)}}
	local n = 12
	for i = 0, n do
		local t = WALK.cycle * i / n
		local w = math.cos(2 * math.pi * i / n)
		table.insert(joints.Torso, T(t, {-4, -5 * w, 0}, V3(0, -walkDrop(t) - 0.01, 0)))
		table.insert(joints.Head, K(t, {-2, 5 * w, 0}))
		table.insert(joints["Right Arm"], K(t, {35 - 4 * w, 0, -4}))
		table.insert(joints["Left Arm"], K(t, {18 * w + 2, 0, -3}))
	end
	return joints
end

Example.CalmWalk = {
	name = "CalmWalk",
	length = WALK.cycle,
	loop = true,
	curve = "spline",
	travel = WALK.speed,
	joints = walkKeys(),
	lag = {Head = 0.06, ["Right Arm"] = 0.05, ["Left Arm"] = 0.05},
	life = 0.5,
	post = staff(Feet.post({r = walkFoot(0, WALK.width, -4), l = walkFoot(0.5, -WALK.width, 4)})),
}

Example.LeanDodge = {
	name = "LeanDodge",
	length = 0.8,
	curve = "spline",
	events = {clear = 0.1},
	joints = {
		Torso = {
			T(0, S.torso, V3(0, 0, 0)),
			T(0.1, {-2, 8, 14}, V3(-0.32, -0.16, 0)),
			T(0.32, {-2, 9, 15}, V3(-0.35, -0.17, 0)),
			T(0.8, S.torso, V3(0, 0, 0)),
		},
		Head = {
			K(0, S.head),
			K(0.1, {-2, -6, -11}),
			K(0.34, {-2, -7, -12}),
			K(0.8, S.head),
		},
		["Right Arm"] = {
			K(0, S.rArm),
			K(0.12, {38, 0, 22}),
			K(0.36, {39, 0, 24}),
			K(0.8, S.rArm),
		},
		["Left Arm"] = {
			K(0, S.lArm),
			K(0.1, {26, 0, -6}),
			K(0.34, {27, 0, -7}),
			K(0.8, S.lArm),
		},
		["Right Leg"] = {K(0)},
		["Left Leg"] = {K(0)},
		Grip = {K(0)},
	},
	springs = {Head = "follow"},
	life = 0.6,
	post = stand,
}

local function foot(keys)
	return function(t)
		local a = keys[1]
		if t <= a[1] then
			return {a[2], a[3], a[4]}
		end
		for i = 2, #keys do
			local b = keys[i]
			if t < b[1] then
				local u = (t - a[1]) / (b[1] - a[1])
				local e = u * u * (3 - 2 * u)
				return {a[2] + (b[2] - a[2]) * e, a[3] + (b[3] - a[3]) * e, a[4] + (b[4] - a[4]) * e, (b[5] or 0) * math.sin(math.pi * u)}
			end
			a = b
		end
		return {a[2], a[3], a[4]}
	end
end

local function aimAt(tw, down, d)
	return add(aim(tw, down), d or {0, 0, 0})
end

local function tremor(list, make, t0, t1, a, b, o)
	for i = #list, 1, -1 do
		if list[i].t > t0 and list[i].t < t1 then
			table.remove(list, i)
		end
	end
	local n = math.floor((t1 - t0) / o.step + 0.5)
	for i = 1, n - 1 do
		local u = i / n
		local s = (i % 2 == 0 and 1 or -1) * (o.amp0 + (o.amp1 - o.amp0) * u) * (0.7 + 0.6 * math.abs(math.noise(i * 0.37, o.seed)))
		local r = {}
		for k = 1, 3 do
			r[k] = a.r[k] + (b.r[k] - a.r[k]) * u + s * o.dir[k]
		end
		local p = a.p and a.p:Lerp(b.p, u) + (o.pdir or Vector3.zero) * s
		table.insert(list, make(t0 + (t1 - t0) * u, r, p))
	end
	table.sort(list, function(x, y)
		return x.t < y.t
	end)
end

Example.ZoltraakCine = {
	name = "ZoltraakCine",
	length = 15,
	curve = "spline",
	events = {sense = 0.95, land = 2.9, roar = 4.1, calm = 5.4, stomp = 6.8, thrust = 7.5, fire = 10.0, release = 10.3, crash = 12.6, fade = 14.2, done = 15},
	joints = {
		Torso = {
			T(0, S.torso, V3(0, 0, 0)),
			T(0.95, {-1, 5, 0}, V3(0, 0.01, 0)),
			T(1.8, {-2, 1, 0}, V3(0, 0.02, 0.01)),
			T(2.45, {-3, -6, 1}, V3(0.02, -0.02, 0.05)),
			T(2.92, {-3, 0, 0}, V3(0.01, -0.03, 0.06)),
			T(3.05, {-6, 0, -1}, V3(0, -0.12, 0.08)),
			T(3.4, {-3, 1, 0}, V3(0, -0.05, 0.08)),
			T(3.95, {-1, 2, 0}, V3(0, -0.04, 0.09)),
			T(4.12, {2, -2, 1}, V3(0, -0.02, 0.12)),
			T(4.3, {-12, -12, 3}, V3(-0.05, -0.2, 0.2)),
			T(4.9, {-13, -14, 3}, V3(-0.06, -0.22, 0.22)),
			T(5.35, {-10, -10, 2}, V3(-0.04, -0.18, 0.2)),
			T(5.9, {-3, 2, 0}, V3(0, -0.07, 0.15)),
			T(6.25, {-2, -6, 0}, V3(0, -0.06, 0.15)),
			T(6.45, {-2, -18, -2}, V3(0.02, -0.08, 0.14)),
			T(6.66, {4, -6, 1}, V3(0, 0.02, 0.06)),
			T(6.8, {-16, 8, 2}, V3(-0.05, -0.32, -0.22)),
			T(6.95, {-13, 9, 2}, V3(-0.04, -0.3, -0.22)),
			T(7.3, {-4, 11, 0}, V3(0, -0.2, -0.2)),
			T(7.5, {-6, 16, -1}, V3(0, -0.22, -0.26)),
			T(7.62, {-5, 17, -1}, V3(0, -0.22, -0.27)),
			T(8.6, {-6, 17, -2}, V3(0, -0.26, -0.28)),
			T(9.55, {-8, 18, -2}, V3(0, -0.32, -0.3)),
			T(9.95, {-6, 23, -3}, V3(0.02, -0.33, -0.2)),
			T(10.22, {-11, 12, -1}, V3(0, -0.34, -0.42)),
			T(10.42, {8, 16, 2}, V3(0, -0.26, 0.2)),
			T(10.7, {-4, 15, 0}, V3(0, -0.3, 0.22)),
			T(11.2, {-8, 14, -1}, V3(0, -0.32, 0.2)),
			T(11.7, {-6, 15, -1}, V3(0, -0.33, 0.21)),
			T(12.35, {-9, 14, -2}, V3(0, -0.34, 0.19)),
			T(12.7, {-2, 13, 0}, V3(0, -0.24, 0.22)),
			T(12.85, {-4, 12, 0}, V3(0, -0.28, 0.23)),
			T(13.3, {-2, 10, 0}, V3(0, -0.2, 0.24)),
			T(13.7, {-2, 8, 0}, V3(0.02, -0.12, 0.2)),
			T(14.2, {-1, 5, 0}, V3(0, -0.03, 0.05)),
			T(15, S.torso, V3(0, 0, 0)),
		},
		Head = {
			K(0, S.head),
			K(0.35, {-5, -4, 1}),
			K(0.75, {-3, -2, 1}),
			K(0.95, {12, 8, 0}),
			K(1.5, {10, 2, 0}),
			K(2.1, {7, -8, 0}),
			K(2.75, {9, -2, 0}),
			K(2.95, {12, 0, 0}),
			K(3.1, {6, 2, -2}),
			K(3.6, {12, -1, 0}),
			K(4.0, {16, 0, 0}),
			K(4.15, {10, -6, 2}),
			K(4.35, {-12, -26, 3}),
			K(5.0, {-14, -28, 4}),
			K(5.45, {-10, -20, 2}),
			K(5.8, {4, -6, 0}),
			K(6.2, {6, -3, 0}),
			K(6.45, {2, 10, 0}),
			K(6.66, {8, 4, -1}),
			K(6.8, {-8, -6, 0}),
			K(7.1, {2, -9, 0}),
			K(7.35, {10, -11, 0}),
			K(7.5, {6, -14, 0}),
			K(8.6, {5, -15, 1}),
			K(9.55, {3, -16, 0}),
			K(9.95, {4, -20, 0}),
			K(10.22, {6, -11, 0}),
			K(10.42, {14, -14, -3}),
			K(10.75, {4, -13, 0}),
			K(11.6, {5, -14, 1}),
			K(12.35, {3, -13, 0}),
			K(12.75, {8, -12, 0}),
			K(13.3, {4, -9, 1}),
			K(14.0, {-2, -5, 1}),
			K(15, S.head),
		},
		["Right Arm"] = {
			K(0, S.rArm),
			K(1.0, add(S.rArm, {-2, 0, 0})),
			K(2.45, add(S.rArm, {4, 0, 2})),
			K(3.05, add(S.rArm, {10, 0, 4})),
			K(3.5, add(S.rArm, {3, 0, 2})),
			K(4.12, add(S.rArm, {8, 0, 6})),
			K(4.35, {-12, 0, 22}),
			K(5.0, {-14, 0, 24}),
			K(5.5, {5, 0, 14}),
			K(6.1, {30, 0, 0}),
			K(6.45, {-40, 0, 14}),
			K(6.58, {110, 0, 22}),
			K(6.68, {165, 0, 10}),
			K(6.8, {28, 0, -4}, V3(0, 0.05, -0.05)),
			K(6.95, {24, 0, -5}),
			K(7.3, {92, 0, 4}),
			K(7.5, aimAt(16, 0.05, {6, 0, 0}), V3(0, 0.05, -0.08)),
			K(7.6, aimAt(16, 0.05), V3(0, 0.05, -0.1)),
			K(7.65, aimAt(16, 0.05, {3, 0, 0}), V3(0, 0.05, -0.13)),
			K(7.72, aimAt(16, 0.05), V3(0, 0.05, -0.1)),
			K(7.8, aimAt(16, 0.05, {3, 0, 0}), V3(0, 0.05, -0.14)),
			K(7.87, aimAt(16, 0.05), V3(0, 0.05, -0.11)),
			K(7.95, aimAt(16, 0.05, {3, 0, 0}), V3(0, 0.05, -0.15)),
			K(8.05, aimAt(16, 0.05), V3(0, 0.05, -0.12)),
			K(9.55, aimAt(18, 0.05, {1, 0, -1}), V3(0, 0.04, -0.16)),
			K(9.95, aimAt(23, 0.05, {-5, 0, 0}), V3(0, 0.05, -0.02)),
			K(10.22, aimAt(12, 0.05, {2, 0, 0}), V3(0, 0.06, -0.22)),
			K(10.4, aimAt(16, 0.05, {12, 0, 0}), V3(0, 0.07, 0)),
			K(10.75, aimAt(15, 0.05), V3(0, 0.05, -0.12)),
			K(11.0, aimAt(15, 0.05, {3, 0, 0}), V3(0, 0.05, -0.17)),
			K(11.45, aimAt(14, 0.05, {1, 0, 0}), V3(0, 0.05, -0.13)),
			K(11.7, aimAt(15, 0.05, {3, 0, 0}), V3(0, 0.05, -0.17)),
			K(12.35, aimAt(14, 0.05, {1, 0, 0}), V3(0, 0.05, -0.16)),
			K(12.65, aimAt(13, 0.05, {-12, 0, 0}), V3(0, 0.04, -0.08)),
			K(13.1, {58, 0, -4}),
			K(13.8, {40, 0, -5}),
			K(14.5, add(S.rArm, {2, 0, 0})),
			K(15, S.rArm),
		},
		["Left Arm"] = {
			K(0, S.lArm),
			K(1.0, add(S.lArm, {2, 0, -3})),
			K(2.45, {36, 0, 10}),
			K(3.05, {44, 0, 14}),
			K(3.5, {33, 0, 16}),
			K(4.12, {40, 0, 20}),
			K(4.3, {112, 0, 34}),
			K(5.0, {116, 0, 36}),
			K(5.35, {104, 0, 30}),
			K(5.95, {40, 0, 16}),
			K(6.45, {55, 0, -12}),
			K(6.68, {30, 0, -30}),
			K(6.8, {-22, 0, -34}),
			K(7.3, {72, 0, -58}),
			K(7.5, {30, 0, -34}),
			K(8.1, {46, 0, -8}),
			K(8.4, aimAt(17, 0.25, {0, 0, 14})),
			K(9.55, aimAt(18, 0.22, {2, 0, 16})),
			K(9.95, aimAt(23, 0.2, {-4, 0, 18})),
			K(10.22, aimAt(12, 0.25, {2, 0, 12})),
			K(10.42, {18, 0, -30}),
			K(10.85, aimAt(15, 0.22, {0, 0, 14})),
			K(12.35, aimAt(14, 0.22, {1, 0, 15})),
			K(12.75, {40, 0, 4}),
			K(13.6, {34, 0, 12}),
			K(14.6, add(S.lArm, {1, 0, 1})),
			K(15, S.lArm),
		},
		["Right Leg"] = {K(0)},
		["Left Leg"] = {K(0)},
		Grip = {K(0)},
	},
	lag = {["Left Arm"] = 0.04},
	springs = {["Left Arm"] = "follow"},
	life = 1.2,
	lifeRate = 0.6,
	post = staff(Feet.post({
		r = foot({{0, 0.5, 0.12, -6}, {2.2, 0.5, 0.12, -6}, {2.5, 0.55, 0.45, -10, 0.2}, {4.12, 0.55, 0.45, -10}, {4.35, 0.6, 0.7, -12}, {10.3, 0.6, 0.7, -12}, {10.6, 0.62, 1.2, -12}, {13.45, 0.62, 1.2, -12}, {13.85, 0.5, 0.12, -6, 0.3}}),
		l = foot({{0, -0.5, -0.1, 8}, {6.55, -0.5, -0.1, 8}, {6.8, -0.6, -0.95, 14, 0.4}, {10.3, -0.6, -0.95, 14}, {10.6, -0.6, -0.45, 14}, {13.95, -0.6, -0.45, 14}, {14.25, -0.5, -0.1, 8, 0.15}}),
	})),
}

do
	local j = Example.ZoltraakCine.joints
	tremor(j.Torso, T, 4.3, 5.35, {r = {-12, -12, 3}, p = V3(-0.05, -0.2, 0.2)}, {r = {-10, -10, 2}, p = V3(-0.04, -0.18, 0.2)}, {step = 0.16, amp0 = 1.8, amp1 = 0.9, dir = {1, 0.4, 0.8}, pdir = V3(0, 0, 0.02), seed = 1})
	tremor(j["Left Arm"], K, 4.3, 5.35, {r = {112, 0, 34}}, {r = {104, 0, 30}}, {step = 0.14, amp0 = 5, amp1 = 2.5, dir = {1, 0, 0.5}, seed = 2})
	tremor(j.Head, K, 4.35, 5.45, {r = {-12, -26, 3}}, {r = {-10, -20, 2}}, {step = 0.18, amp0 = 3, amp1 = 1.5, dir = {0.5, 1, 0.3}, seed = 3})
	tremor(j["Right Arm"], K, 8.05, 9.55, {r = aimAt(16, 0.05), p = V3(0, 0.05, -0.12)}, {r = aimAt(18, 0.05, {1, 0, -1}), p = V3(0, 0.04, -0.16)}, {step = 0.1, amp0 = 0.6, amp1 = 2.4, dir = {1, 0, 0.6}, pdir = V3(0, 0.004, -0.01), seed = 4})
	tremor(j["Left Arm"], K, 8.4, 9.55, {r = aimAt(17, 0.25, {0, 0, 14})}, {r = aimAt(18, 0.22, {2, 0, 16})}, {step = 0.12, amp0 = 0.8, amp1 = 3, dir = {1, 0, 0.5}, seed = 5})
	tremor(j.Torso, T, 8.6, 9.55, {r = {-6, 17, -2}, p = V3(0, -0.26, -0.28)}, {r = {-8, 18, -2}, p = V3(0, -0.32, -0.3)}, {step = 0.2, amp0 = 0.5, amp1 = 1.5, dir = {1, 0.5, 0.5}, pdir = V3(0, 0.01, 0), seed = 6})
	tremor(j["Right Arm"], K, 10.75, 12.35, {r = aimAt(15, 0.05), p = V3(0, 0.05, -0.12)}, {r = aimAt(14, 0.05, {1, 0, 0}), p = V3(0, 0.05, -0.16)}, {step = 0.09, amp0 = 3, amp1 = 2, dir = {1, 0.2, 0.7}, pdir = V3(0, 0.01, -0.02), seed = 7})
	tremor(j["Left Arm"], K, 10.85, 12.35, {r = aimAt(15, 0.22, {0, 0, 14})}, {r = aimAt(14, 0.22, {1, 0, 15})}, {step = 0.1, amp0 = 3, amp1 = 2, dir = {1, 0, 0.5}, seed = 8})
	tremor(j.Torso, T, 10.7, 12.35, {r = {-4, 15, 0}, p = V3(0, -0.3, 0.22)}, {r = {-9, 14, -2}, p = V3(0, -0.34, 0.19)}, {step = 0.14, amp0 = 1.5, amp1 = 1, dir = {1, 0.3, 0.5}, pdir = V3(0, 0, -0.02), seed = 9})
	tremor(j.Head, K, 10.75, 12.35, {r = {4, -13, 0}}, {r = {3, -13, 0}}, {step = 0.16, amp0 = 2, amp1 = 1.5, dir = {1, 0.5, 0.8}, seed = 10})
end

local BARRAGE = {}
for i = 0, 23 do
	table.insert(BARRAGE, 3.8 + i * 0.17)
end

local function barrageArm()
	local keys = {
		K(0, S.rArm),
		K(1.6, add(S.rArm, {3, 0, 0})),
		K(2.0, {60, 0, -5}),
		K(2.22, add(AIM, {6, 0, 0}), V3(0, 0.05, -0.06)),
		K(2.36, AIM, V3(0, 0.05, -0.1)),
		K(3.7, add(AIM, {1, 0, -1}), V3(0, 0.05, -0.12)),
	}
	for i, t in ipairs(BARRAGE) do
		table.insert(keys, K(t + 0.045, add(AIM, {4.5 + i % 3, 0, 0}), V3(0, 0.06, -0.05)))
		table.insert(keys, K(t + 0.12, add(AIM, {1, 0, 0}), V3(0, 0.05, -0.1)))
	end
	table.insert(keys, K(8.1, add(AIM, {-2, 0, 0}), V3(0, 0.05, -0.14)))
	table.insert(keys, K(8.26, add(AIM, {10, 0, 0}), V3(0, 0.07, 0)))
	table.insert(keys, K(8.7, AIM, V3(0, 0.05, -0.08)))
	table.insert(keys, K(10.4, add(AIM, {1, 0, 0}), V3(0, 0.05, -0.1)))
	table.insert(keys, K(11.2, {58, 0, -6}))
	table.insert(keys, K(12.0, {40, 0, -5}))
	table.insert(keys, K(13, S.rArm))
	return keys
end

Example.VolleyCine = {
	name = "VolleyCine",
	length = 13,
	curve = "spline",
	events = {notice = 0.8, raise = 2.0, circles = 2.4, fire = 3.8, big = 8.2, frames = 8.3, whiteout = 8.45, fall = 8.6, crash = 10.2, lower = 10.5, fade = 11.8, done = 12.6},
	shots = BARRAGE,
	joints = {
		Torso = {
			T(0, S.torso, V3(0, 0, 0)),
			T(1.2, {-3, 5, 0}, V3(0, 0, 0.01)),
			T(2.2, {-3, 15, -2}, V3(0, -0.01, -0.03)),
			T(3.7, {-4, 16, -2}, V3(0, -0.02, -0.04)),
			T(7.8, {-4, 16, -2}, V3(0, -0.02, -0.05)),
			T(8.1, {-5, 17, -2}, V3(0, -0.03, -0.06)),
			T(8.26, {1, 13, -1}, V3(0, 0, 0.05)),
			T(8.7, {-1, 14, -1}, V3(0, 0, 0.01)),
			T(10.4, {-2, 15, -2}, V3(0, -0.01, -0.02)),
			T(11.4, {-1, 8, -1}, V3(0, 0, 0)),
			T(13, S.torso, V3(0, 0, 0)),
		},
		Head = {
			K(0, S.head),
			K(0.8, {4, -4, 0}),
			K(1.5, {9, -8, 0}),
			K(2.3, {6, -12, 0}),
			K(7.8, {6, -13, 0}),
			K(8.26, {8, -12, -1}),
			K(8.9, {5, -13, 0}),
			K(9.6, {1, -11, 0}),
			K(10.4, {-2, -10, 0}),
			K(11.6, {-3, -6, 1}),
			K(13, S.head),
		},
		["Right Arm"] = barrageArm(),
		["Left Arm"] = {
			K(0, S.lArm),
			K(2.2, {24, 0, 13}),
			K(8.1, {26, 0, 15}),
			K(8.26, {21, 0, 11}),
			K(10.4, {24, 0, 13}),
			K(13, S.lArm),
		},
		["Right Leg"] = {K(0)},
		["Left Leg"] = {K(0)},
		Grip = {K(0)},
	},
	lag = {["Left Arm"] = 0.08},
	springs = {["Left Arm"] = "follow"},
	life = 1.3,
	lifeRate = 0.5,
	post = stand,
}

Example.FlowersCine = {
	name = "FlowersCine",
	length = 14,
	curve = "spline",
	events = {look = 0.8, plant = 2.0, cup = 3.0, gather = 3.6, rise = 6.4, release = 6.6, bloom = 6.95, turn = 9.0, fade = 12.6, done = 13.4},
	joints = {
		Torso = {
			T(0, S.torso, V3(0, 0, 0)),
			T(0.9, {-2, 3, 0}, V3(0, 0, 0)),
			T(1.9, {4, 6, -2}, V3(0, -0.08, 0)),
			T(2.4, {0, 4, 0}, V3(0, -0.02, 0)),
			T(3.6, {-4, 2, 0}, V3(0, -0.02, 0)),
			T(6.3, {-3, 1, 0}, V3(0, 0, 0)),
			T(6.7, {1, 2, 0}, V3(0, 0.03, 0)),
			T(8.6, {0, 5, 0}, V3(0, 0, 0)),
			T(9.4, {-1, 8, 0}, V3(0, 0, 0)),
			T(11.5, {-1, 6, 0}, V3(0, 0, 0)),
			T(14, S.torso, V3(0, 0, 0)),
		},
		Head = {
			K(0, S.head),
			K(0.5, {-2, -2, 0}),
			K(1.0, {-12, -6, 1}),
			K(2.3, {-14, -4, 1}),
			K(3.2, {-18, 0, 2}),
			K(5.8, {-14, 1, 2}),
			K(6.6, {6, 0, 0}),
			K(7.2, {12, 2, -1}),
			K(8.4, {2, 6, 0}),
			K(9.2, {-6, 14, -1}),
			K(10.6, {-7, -10, 1}),
			K(12.0, {-5, -4, 1}),
			K(14, S.head),
		},
		["Right Arm"] = {
			K(0, S.rArm),
			K(1.3, {22, 0, -8}),
			K(1.9, {12, 0, -14}, V3(0, -0.1, 0)),
			K(2.1, {10, 0, -15}, V3(0, -0.1, 0)),
			K(2.5, {12, 0, -10}),
			K(3.1, CUP.r, V3(0, 0.03, 0)),
			K(6.3, add(CUP.r, {4, 0, -10}), V3(0, 0.06, 0)),
			K(6.8, {50, 0, 28}, V3(0, 0.05, 0)),
			K(8.6, {34, 0, 18}),
			K(10.0, {20, 0, 6}),
			K(12.0, {12, 0, -2}),
			K(14, {8, 0, -3}),
		},
		["Left Arm"] = {
			K(0, S.lArm),
			K(1.5, {24, 0, 14}),
			K(3.15, CUP.l, V3(0, 0.03, 0)),
			K(6.3, add(CUP.l, {4, 0, 10}), V3(0, 0.06, 0)),
			K(6.86, {60, 0, -20}, V3(0, 0.05, 0)),
			K(8.6, {40, 0, -12}),
			K(10.0, {28, 0, 4}),
			K(12.0, {22, 0, 10}),
			K(14, {24, 0, 12}),
		},
		["Right Leg"] = {K(0)},
		["Left Leg"] = {K(0)},
		Grip = {K(0)},
	},
	life = 1.3,
	lifeRate = 0.5,
	post = stand,
}

return Example
