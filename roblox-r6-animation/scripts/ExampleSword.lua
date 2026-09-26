local Rig = require(script.Parent.WeaponRig)
local Feet = require(script.Parent.Feet)
local V3 = Vector3.new

local Example = {}

local FEET = {r = {0.6, 0.4}, l = {-0.5, -0.5}}

local function keys(defs)
	local joints = {Torso = {}, Head = {}, ["Right Arm"] = {}, ["Left Arm"] = {}, Sword = {}, ["Right Leg"] = {{t = 0}}, ["Left Leg"] = {{t = 0}}}
	local seed, prev = {}, {}
	for _, d in ipairs(defs) do
		d.feet = FEET
		local out
		out, seed = Rig.body(d, seed)
		local arm = prev.arm and Rig.nearestEuler(out.rArm, prev.arm) or out.rArm
		local wrist = prev.wrist and Rig.nearestEuler(out.wrist, prev.wrist) or out.wrist
		prev.arm, prev.wrist = arm, wrist
		table.insert(joints.Torso, {t = d.t, r = out.torso, p = out.torsoP})
		table.insert(joints.Head, {t = d.t, r = d.head})
		table.insert(joints["Right Arm"], {t = d.t, r = arm, p = out.rArmP})
		table.insert(joints.Sword, {t = d.t, r = wrist})
		table.insert(joints["Left Arm"], {t = d.t, r = out.lArm, p = out.lArmP})
	end
	return joints
end

Example.SwordDraw = {
	name = "SwordDraw",
	length = 0.92,
	curve = "spline",
	events = {draw = 0.02, glint = 0.2},
	joints = keys({
		{t = 0.00, torso = {-10, 30, 0}, crouch = 0.1, head = {10, -25, 0}, sword = {V3(-0.9, -0.9, -0.3), V3(0.1, -0.4, 1), V3(0, 1, 0)}, lArm = {20, 0, 20}},
		{t = 0.08, torso = {-8, 5, 0}, crouch = 0.15, head = {8, -5, 0}, sword = {V3(0, -0.3, -1.1), V3(-0.9, 0, 0.4), V3(0, 1, 0)}, lArm = {30, 0, 10}},
		{t = 0.15, torso = {-8, -25, 0}, crouch = 0.2, head = {6, 22, 0}, sword = {V3(1.3, 0.2, -1.0), V3(0.8, 0.05, -0.6), V3(0, 1, 0)}, lArm = {-10, 0, -40}},
		{t = 0.20, torso = {-9, -27, 0}, crouch = 0.21, head = {6, 24, 0}, sword = {V3(1.4, 0.25, -0.95), V3(0.85, 0.1, -0.5), V3(0, 1, 0)}, lArm = {-14, 0, -44}},
		{t = 0.28, torso = {-5, -15, 0}, crouch = 0.12, head = {5, 14, 0}, sword = {V3(0.6, 0.9, -0.6), V3(0.2, 0.9, -0.4), V3(0, 0, -1)}, lArm = {70, 0, 20}},
		{t = 0.48, torso = {-6, -17, 1}, crouch = 0.14, head = {6, 16, 0}, sword = {V3(0.62, 0.95, -0.58), V3(0.18, 0.92, -0.35), V3(0, 0, -1)}, lArm = {72, 0, 22}},
		{t = 0.56, torso = {-12, -18, 0}, crouch = 0.24, head = {11, 16, 0}, sword = {V3(0.7, 0.3, -0.9), V3(0.3, 0.6, -0.75), V3(0, 0.6, -0.8)}, lArm = {20, 0, -10}},
		{t = 0.64, torso = {-18, -20, 0}, crouch = 0.35, head = {16, 18, 0}, sword = {V3(0.6, -0.5, -1.2), V3(0.3, 0.02, -0.95), V3(0, 1, 0)}, lArm = {-20, 0, -30}},
		{t = 0.78, torso = {-21, -24, 1}, crouch = 0.4, head = {18, 21, 0}, sword = {V3(0.64, -0.56, -1.3), V3(0.25, -0.03, -0.97), V3(0, 1, 0)}, lArm = {-26, 0, -35}},
		{t = 0.92, torso = {-23, -26, 2}, crouch = 0.43, head = {19, 23, 0}, sword = {V3(0.66, -0.6, -1.33), V3(0.23, -0.05, -0.97), V3(0, 1, 0)}, lArm = {-29, 0, -37}},
	}),
	life = 0.5,
	post = Feet.post({r = {0.6, 0.4, -20}, l = {-0.5, -0.5, 10}}),
}

return Example
