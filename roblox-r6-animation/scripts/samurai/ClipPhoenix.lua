local K = require(script.Parent.Kit)

local V3 = K.V3

local AIR = {{0.4, 0}, {0.45, 0.42}, {0.49, 0.52}, {0.54, 0.4}, {0.585, 0.08}, {0.6, 0}}
local BASE = {r = {0.55, 0.18, -8}, l = {-0.55, -0.22, 6}}
local feetAt, fr, fl = K.steps({
	{0.44, 0.6, foot = "l", to = {0.08, -0.78, -6}},
	{0.52, 0.64, foot = "r", to = {0.04, 0.12, -12}},
	{0.9, 1.12, foot = "l", to = {-0.03, 1.0, 0}, lift = 0.22},
	{0.96, 1.16, foot = "r", to = {-0.09, -0.3, 20}, lift = 0.12},
}, AIR, BASE)

K.named("Phoenix")
local seed = {}
local function key(t, def)
	return K.body(def, seed, feetAt(t), t)
end

local function mirror(s)
	local function m(v)
		return v and V3(-v.X, v.Y, v.Z)
	end
	return {m(s[1]), m(s[2]), m(s[3])}
end

local function both(r)
	return r, mirror(r)
end

local S0 = key(0, {torso = {-4, 4, 0}, head = {-8, -4, 0},
	r = {V3(0.15, -0.75, -0.64), V3(-0.3, 0.35, -0.89), V3(0, -1, 0)},
	l = {V3(-0.15, -0.8, -0.58), V3(0.4, 0.15, -0.9), V3(0, -1, 0)}})

local F1 = key(0.24, {torso = {-18, 4, 0}, tz = 0.04, crouch = 0.4, head = {-24, 28, 0},
	r = {V3(-1.35, -0.15, -0.85), V3(-0.5, 0.7, 0.5)},
	l = {V3(1.35, -0.5, -0.95), V3(0.5, 0.7, 0.5)}})

local F2 = key(0.36, {torso = {-22, 4, 0}, tz = 0.05, crouch = 0.5, head = {-27, 32, 0},
	r = {V3(-1.4, -0.2, -0.8), V3(-0.45, 0.72, 0.58)},
	l = {V3(1.4, -0.55, -0.9), V3(0.45, 0.72, 0.58)}})

local r, l = both({V3(0.95, 0.28, 0.2), V3(0.05, 0.97, 0.25), V3(-1, 0, 0)})
local SP = key(0.48, {torso = {14, 0, 0}, rise = 0.55, head = {-6, 2, 0}, r = r, l = l})

r, l = both({V3(0.92, 0.32, 0.25), V3(0.02, 0.96, 0.3), V3(-1, 0, 0)})
local SB = key(0.53, {torso = {17, -1, 0}, rise = 0.45, head = {-4, -2, 0}, r = r, l = l})

r, l = both({V3(0.95, 0.05, 0.05), V3(0.45, 0.02, 0.89), V3(0, 0, -1)})
local MD = key(0.57, {torso = {2, 0, 0}, rise = 0.14, crouch = 0.05, head = {0, -6, 0}, r = r, l = l})

r, l = both({V3(0.6, -0.15, -0.78), V3(0.45, 0.04, -0.89), V3(-1, 0, 0)})
local FW = key(0.585, {torso = {-8, 0, 0}, rise = 0.03, crouch = 0.2, head = {-6, -12, 0}, r = r, l = l})

local CL = key(0.6, {torso = {-16, 0, 0}, tz = -0.08, crouch = 0.42, head = {-10, -22, 0},
	r = {V3(0.2, -0.2, -0.96), V3(-0.92, 0.14, -0.38), V3(-0.38, 0, 0.92)},
	l = {V3(-0.2, -0.28, -0.94), V3(0.92, 0.05, -0.38), V3(0.38, 0, 0.92)}})

local FT = key(0.68, {torso = {-20, 0, 0}, tz = -0.1, crouch = 0.5, head = {-12, -26, 0},
	r = {V3(-0.25, -0.3, -0.92), V3(-0.8, 0.1, 0.58)},
	l = {V3(0.25, -0.38, -0.9), V3(0.8, 0.02, 0.58)}})

local F3 = key(0.8, {torso = {-22, 1, 0}, tz = -0.1, crouch = 0.53, head = {-13, -24, 0},
	r = {V3(-0.3, -0.34, -0.9), V3(-0.78, 0.08, 0.62)},
	l = {V3(0.3, -0.42, -0.86), V3(0.78, 0, 0.62)}})

local RC = key(1.0, {torso = {-7, 3, 0}, crouch = 0.14, head = {-10, -6, 0},
	r = {V3(0.12, -0.72, -0.68), V3(-0.22, 0.3, -0.93), V3(0, -1, 0)},
	l = {V3(-0.12, -0.78, -0.62), V3(0.35, 0.12, -0.93), V3(0, -1, 0)}})

local S1 = key(1.25, {torso = {0, 0, 0}, head = {-8, -4, 0},
	r = {V3(0.15, -0.75, -0.64), V3(-0.3, 0.35, -0.89), V3(0, -1, 0)},
	l = {V3(-0.15, -0.8, -0.58), V3(0.4, 0.15, -0.9), V3(0, -1, 0)}})

local FOLD = {Head = 0.03, RightKatana = 0.02, LeftKatana = 0.025, ["Left Arm"] = 0.01}
local TRAIL = {Head = 0.02, RightKatana = 0.015, LeftKatana = 0.015}

return {
	name = "CaliberPhoenix",
	length = 1.25,
	curve = "spline",
	life = 0.8,
	lockAt = 1.02,
	events = {gather = 0.08, fold = 0.24, spread = 0.44, sweep = 0.56, release = 0.585, contact = 0.6, recover = 0.9},
	warp = {{0, 1}, {0.2, 0.85}, {0.4, 0.9}, {0.45, 0.55}, {0.53, 0.55}, {0.56, 1}, {0.6, 1}, {0.62, 0.45}, {0.67, 0.55}, {0.72, 1}},
	post = K.tremble({
		{0.27, 0.42, rate = 18, fade = 0.04, amp = {["Right Arm"] = 1.6, ["Left Arm"] = 1.6, Torso = 0.8, Head = 0.5}},
		{0.62, 0.76, rate = 14, fade = 0.03, amp = {["Right Arm"] = 1.1, ["Left Arm"] = 1.1, Torso = 0.5}},
	}, K.Feet.post({r = fr, l = fl})),
	joints = K.track({
		{t = 0, pose = S0},
		{t = 0.24, pose = F1, lag = FOLD},
		{t = 0.36, pose = F2, lag = {Head = 0.02, RightKatana = 0.01}},
		{t = 0.48, pose = SP, lag = {Head = 0.02, RightKatana = 0.02, LeftKatana = 0.02}},
		{t = 0.53, pose = SB, lag = {Head = 0.01}},
		{t = 0.57, pose = MD},
		{t = 0.585, pose = FW},
		{t = 0.6, pose = CL},
		{t = 0.68, pose = FT, lag = TRAIL},
		{t = 0.8, pose = F3, lag = {Head = 0.03, LeftKatana = 0.02}},
		{t = 1.0, pose = RC, lag = {Head = 0.03, ["Left Arm"] = 0.02, LeftKatana = 0.03}},
		{t = 1.25, pose = S1, lag = {Head = 0.02}},
	}),
}
