local Feet = require(script.Parent.Feet)
local Ex = require(script.Parent.ExampleClips)
local K, T, aim = Ex.helpers.K, Ex.helpers.T, Ex.helpers.aim
local V3 = Vector3.new

local Example = {}

local S = {
	torso = {-1, 4, 0},
	head = {-4, -3, 1},
	rArm = {8, 0, -3},
	lArm = {30, 0, 18},
	rFoot = {0.5, 0.12, -6},
	lFoot = {-0.5, -0.1, 8},
}

local stand = Feet.post({r = S.rFoot, l = S.lFoot})

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
			K(0.4, {22, 0, -4}),
			K(0.62, AIM, V3(0, 0.05, -0.08)),
			K(0.72, add(AIM, {2, 0, 0}), V3(0, 0.05, -0.1)),
			K(1.25, add(AIM, {1, 0, -1}), V3(0, 0.05, -0.12)),
			K(1.36, add(AIM, {7, 0, 0}), V3(0, 0.06, -0.02)),
			K(1.5, AIM, V3(0, 0.05, -0.08)),
			K(2.05, add(AIM, {1, 0, 0}), V3(0, 0.05, -0.1)),
			K(2.35, {40, 0, -8}),
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
			K(0.12, {24, 0, -4}),
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
			K(0.25, {14, 0, -10}),
			K(0.75, CUP.r, V3(0, 0.03, 0)),
			K(1.85, add(CUP.r, {4, 0, -10}), V3(0, 0.06, 0)),
			K(2.25, {50, 0, 28}, V3(0, 0.05, 0)),
			K(3.1, {34, 0, 18}),
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
	},
	lag = {Torso = 0.1},
	life = 0.8,
	post = stand,
}

return Example
