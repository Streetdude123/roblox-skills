local K = require(script.Parent.Kit)

local V3 = K.V3

K.named("Stance")
local seed = {}
local base = {torsoP = V3(), torso = {0, 0, 0}}

local function key(t, head, r, l)
	local def = table.clone(base)
	def.head, def.r, def.l = head, r, l
	return K.body(def, seed, nil, t)
end

local A = key(0, {-8, -4, 0},
	{V3(0.15, -0.75, -0.64), V3(-0.3, 0.35, -0.89), V3(0, -1, 0)},
	{V3(-0.15, -0.8, -0.58), V3(0.4, 0.15, -0.9), V3(0, -1, 0)})
local B = key(1.5, {-5, -1, 0},
	{V3(0.17, -0.69, -0.69), V3(-0.27, 0.42, -0.87), V3(0, -1, 0)},
	{V3(-0.17, -0.75, -0.63), V3(0.4, 0.21, -0.89), V3(0, -1, 0)})

local ONLY = {Head = true, ["Right Arm"] = true, ["Left Arm"] = true, RightKatana = true, LeftKatana = true}

return {
	name = "SamuraiStance",
	loop = true,
	length = 3,
	curve = "spline",
	life = 1.2,
	lag = {Head = 0.3, ["Left Arm"] = 0.14, LeftKatana = 0.2, RightKatana = 0.06},
	joints = K.track({
		{t = 0, pose = A},
		{t = 1.5, pose = B},
		{t = 3, pose = A},
	}, ONLY),
}
