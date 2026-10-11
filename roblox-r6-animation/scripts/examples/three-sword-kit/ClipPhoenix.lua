local K = require(script.Parent.Kit)

local V3 = K.V3

local AIR = {{0.38, 0}, {0.44, 0.35}, {0.52, 0.75}, {0.64, 0.7}, {0.74, 0.3}, {0.8, 0}}
local BASE = {r = {0.55, 0.18, -8}, l = {-0.55, -0.22, 6}}
local feetAt, fr, fl = K.steps({
	{0.08, 0.22, foot = "r", to = {0.15, 0.3, -6}},
	{0.1, 0.24, foot = "l", to = {-0.15, -0.25, 6}},
	{0.7, 0.8, foot = "r", to = {-0.12, -1.35, 10}},
	{0.7, 0.8, foot = "l", to = {0.05, 0.95, -4}},
	{1.2, 1.42, foot = "r", to = {-0.08, 0.87, 4}, lift = 0.2},
	{1.26, 1.48, foot = "l", to = {0.15, -0.48, -8}, lift = 0.15},
}, AIR, BASE)

local UP = 3.2
local fwd = K.monotone({{0.38, 0}, {0.6, 1.4}, {0.8, 4.6}, {0.9, 5}})
local yaw = K.monotone({{0.42, 0}, {0.5, 55}, {0.64, 320}, {0.72, 360}})

local function root(t)
	local u = math.clamp((t - 0.4) / 0.4, 0, 1)
	return UP * 4 * u * (1 - u), fwd(t), yaw(t)
end

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

local STANCE_R = {V3(0.15, -0.75, -0.64), V3(-0.3, 0.35, -0.89), V3(0, -1, 0)}
local STANCE_L = {V3(-0.15, -0.8, -0.58), V3(0.4, 0.15, -0.9), V3(0, -1, 0)}

local S0 = key(0, {torso = {-4, 4, 0}, head = {-8, -4, 0}, r = STANCE_R, l = STANCE_L})

local F1 = key(0.22, {torso = {-26, 14, 0}, tz = 0.06, crouch = 0.72, head = {-30, 24, 0},
	r = {V3(-1.35, -0.15, -0.85), V3(-0.5, 0.7, 0.5)},
	l = {V3(1.35, -0.5, -0.95), V3(0.5, 0.7, 0.5)}})

local F2 = key(0.36, {torso = {-32, 18, 0}, tz = 0.08, crouch = 0.85, head = {-34, 28, 0},
	r = {V3(-1.4, -0.2, -0.8), V3(-0.45, 0.72, 0.58)},
	l = {V3(1.4, -0.55, -0.9), V3(0.45, 0.72, 0.58)}})

local r, l = both({V3(0.9, 0.1, -0.25), V3(0.1, 0.9, -0.4), V3(-1, 0, 0)})
local LA = key(0.42, {torso = {6, 4, 0}, head = {-2, 6, 0}, r = r, l = l})

r, l = both({V3(0.88, 0.42, 0.2), V3(0.25, 0.93, 0.25), V3(-1, 0, 0)})
local SP = key(0.5, {torso = {18, 0, 0}, head = {4, 2, 0}, r = r, l = l})

r, l = both({V3(0.78, 0.58, 0.25), V3(0.38, 0.88, 0.28), V3(-1, 0, 0)})
local SB = key(0.61, {torso = {24, -1, 0}, head = {8, -2, 0}, r = r, l = l})

r, l = both({V3(0.95, 0.3, 0.05), V3(0.2, 0.7, 0.68), V3(-1, 0, 0)})
local DV = key(0.7, {torso = {-4, 0, 0}, head = {-6, -4, 0}, r = r, l = l})

r, l = both({V3(0.95, 0.05, 0.05), V3(0.45, 0.02, 0.89), V3(0, 0, -1)})
local MD = key(0.76, {torso = {-14, 0, 0}, crouch = 0.1, head = {-8, -8, 0}, r = r, l = l})

r, l = both({V3(0.6, -0.15, -0.78), V3(0.45, 0.04, -0.89), V3(-1, 0, 0)})
local FW = key(0.79, {torso = {-22, 0, 0}, crouch = 0.35, head = {-10, -14, 0}, r = r, l = l})

local CL = key(0.81, {torso = {-30, 0, 0}, tz = -0.1, crouch = 0.62, head = {-14, -26, 0},
	r = {V3(0.2, -0.2, -0.96), V3(-0.92, 0.14, -0.38), V3(-0.38, 0, 0.92)},
	l = {V3(-0.2, -0.28, -0.94), V3(0.92, 0.05, -0.38), V3(0.38, 0, 0.92)}})

local FT = key(0.9, {torso = {-34, -4, 0}, tz = -0.12, crouch = 0.74, head = {-16, -32, 0},
	r = {V3(-0.25, -0.3, -0.92), V3(-0.78, 0.22, 0.58)},
	l = {V3(0.25, -0.38, -0.9), V3(0.78, 0.16, 0.58)}})

local F3 = key(1.1, {torso = {-36, -6, 0}, tz = -0.12, crouch = 0.78, head = {-17, -30, 0},
	r = {V3(-0.3, -0.34, -0.9), V3(-0.74, 0.26, 0.62)},
	l = {V3(0.3, -0.42, -0.86), V3(0.74, 0.2, 0.62)}})

local RC = key(1.32, {torso = {-7, 3, 0}, crouch = 0.14, head = {-10, -6, 0},
	r = {V3(0.12, -0.72, -0.68), V3(-0.22, 0.3, -0.93), V3(0, -1, 0)},
	l = {V3(-0.12, -0.78, -0.62), V3(0.35, 0.12, -0.93), V3(0, -1, 0)}})

local S1 = key(1.55, {torso = {0, 0, 0}, head = {-8, -4, 0}, r = STANCE_R, l = STANCE_L})

return {
	name = "CaliberPhoenix",
	length = 1.55,
	curve = "spline",
	life = 0.8,
	lockAt = 1.3,
	root = root,
	rootEnd = 0.92,
	events = {gather = 0.06, fold = 0.22, launch = 0.4, spread = 0.5, apex = 0.61, sweep = 0.76, release = 0.8, contact = 0.81, recover = 1.2},
	warp = {{0, 1}, {0.2, 0.85}, {0.36, 0.8}, {0.4, 1.25}, {0.5, 0.9}, {0.56, 0.55}, {0.64, 0.55}, {0.7, 1.25}, {0.8, 1.1}, {0.82, 0.4}, {0.9, 0.55}, {0.98, 1}},
	post = K.tremble({
		{0.24, 0.39, rate = 18, fade = 0.04, amp = {["Right Arm"] = 2, ["Left Arm"] = 2, Torso = 1, Head = 0.6}},
		{0.84, 1.0, rate = 14, fade = 0.03, amp = {["Right Arm"] = 1.3, ["Left Arm"] = 1.3, Torso = 0.6}},
	}, K.Feet.post({r = fr, l = fl})),
	joints = K.track({
		{t = 0, pose = S0},
		{t = 0.22, pose = F1, lag = {Head = 0.03, RightKatana = 0.02, LeftKatana = 0.025, ["Left Arm"] = 0.01}},
		{t = 0.36, pose = F2, lag = {Head = 0.02, RightKatana = 0.01}},
		{t = 0.42, pose = LA, lag = {Head = 0.02, RightKatana = 0.015, LeftKatana = 0.015}},
		{t = 0.5, pose = SP, lag = {Head = 0.02, RightKatana = 0.02, LeftKatana = 0.02}},
		{t = 0.61, pose = SB, lag = {Head = 0.01}},
		{t = 0.7, pose = DV, lag = {RightKatana = 0.01, LeftKatana = 0.01}},
		{t = 0.76, pose = MD},
		{t = 0.79, pose = FW},
		{t = 0.81, pose = CL},
		{t = 0.9, pose = FT, lag = {Head = 0.02, RightKatana = 0.015, LeftKatana = 0.015}},
		{t = 1.1, pose = F3, lag = {Head = 0.03, LeftKatana = 0.02}},
		{t = 1.32, pose = RC, lag = {Head = 0.03, ["Left Arm"] = 0.02, LeftKatana = 0.03}},
		{t = 1.55, pose = S1, lag = {Head = 0.02}},
	}),
}
