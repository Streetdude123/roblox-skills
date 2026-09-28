local K = require(script.Parent.Kit)

local V3 = K.V3

local AIR = {{0.41, 0}, {0.44, 0.35}, {0.49, 0.3}, {0.52, 0}}
local BASE = {r = {0.55, 0.18, -8}, l = {-0.55, -0.22, 6}}
local feetAt, fr, fl = K.steps({
	{0.08, 0.3, foot = "l", to = {-0.1, -0.9, -4}, lift = 0.2},
	{0.12, 0.32, foot = "r", to = {0.1, 0.6, -10}},
	{1.05, 1.3, foot = "l", to = {0.15, 1.12, -2}, lift = 0.22},
	{1.12, 1.4, foot = "r", to = {-0.15, -0.78, 18}, lift = 0.18},
}, AIR, BASE)

K.named("Lion")
local seed = {}
local function key(t, def)
	return K.body(def, seed, feetAt(t), t)
end

local STANCE_R = {V3(0.15, -0.75, -0.64), V3(-0.3, 0.35, -0.89), V3(0, -1, 0)}
local STANCE_L = {V3(-0.15, -0.8, -0.58), V3(0.4, 0.15, -0.9), V3(0, -1, 0)}

local S0 = key(0, {torso = {-4, 4, 0}, head = {-8, -4, 0}, r = STANCE_R, l = STANCE_L})

local G1 = key(0.26, {torso = {-26, -25, 0}, tz = 0.08, crouch = 0.6, head = {14, 22, 0},
	r = {V3(0.3, -0.9, 0.4), V3(0.2, 0.15, 0.97), V3(1, 0, 0)},
	l = {V3(-0.3, -0.9, 0.4), V3(-0.2, 0.15, 0.97), V3(-1, 0, 0)}})

local G2 = key(0.4, {torso = {-30, -28, 0}, tz = 0.1, crouch = 0.68, head = {17, 25, 0},
	r = {V3(0.32, -0.88, 0.45), V3(0.18, 0.2, 0.96), V3(1, 0, 0)},
	l = {V3(-0.32, -0.88, 0.45), V3(-0.18, 0.2, 0.96), V3(-1, 0, 0)}})

local D1 = key(0.46, {torso = {-34, 0, 0}, crouch = 0.35, head = {20, 0, 0},
	r = {V3(-0.2, -0.3, -0.93), V3(-0.95, 0.1, 0.2), V3(0, 0, -1)},
	l = {V3(0.2, -0.3, -0.93), V3(0.95, 0.1, 0.2), V3(0, 0, -1)}})

local A1 = key(0.52, {torso = {-8, 0, 0}, tz = -0.12, crouch = 0.5, head = {2, 0, 0},
	r = {V3(0.95, -0.2, 0.2), V3(-0.1, -0.2, 0.97), V3(1, 0, 0)},
	l = {V3(-0.95, -0.2, 0.2), V3(0.1, -0.2, 0.97), V3(-1, 0, 0)}})

local A2 = key(0.72, {torso = {-10, 1, 0}, tz = -0.12, crouch = 0.53, head = {0, -3, 0},
	r = {V3(0.95, -0.24, 0.22), V3(-0.12, -0.22, 0.96), V3(1, 0, 0)},
	l = {V3(-0.95, -0.25, 0.22), V3(0.12, -0.22, 0.96), V3(-1, 0, 0)}})

local A3 = key(0.9, {torso = {-11, 2, 0}, tz = -0.12, crouch = 0.55, head = {-1, -5, 0},
	r = {V3(0.94, -0.27, 0.23), V3(-0.13, -0.24, 0.96), V3(1, 0, 0)},
	l = {V3(-0.94, -0.28, 0.23), V3(0.13, -0.24, 0.96), V3(-1, 0, 0)}})

local CL = key(0.97, {torso = {-4, 0, 0}, crouch = 0.4, head = {-6, -6, 0},
	r = {V3(0.4, -0.9, 0.1), V3(0.1, -0.12, -0.99), V3(0, -1, 0)},
	l = {V3(-0.4, -0.9, 0.1), V3(-0.1, -0.12, -0.99), V3(0, -1, 0)}})

local RC = key(1.25, {torso = {-6, 3, 0}, crouch = 0.12, head = {-9, -5, 0},
	r = {V3(0.12, -0.72, -0.68), V3(-0.22, 0.3, -0.93), V3(0, -1, 0)},
	l = {V3(-0.12, -0.78, -0.62), V3(0.35, 0.12, -0.93), V3(0, -1, 0)}})

local S1 = key(1.55, {torso = {0, 0, 0}, head = {-8, -4, 0}, r = STANCE_R, l = STANCE_L})

return {
	name = "LionsPassage",
	length = 1.55,
	curve = "spline",
	life = 0.8,
	lockAt = 1.25,
	dash = {0.42, 0.5},
	events = {gather = 0.02, dash = 0.42, arrive = 0.5, click = 0.97},
	warp = {{0, 1}, {0.25, 0.7}, {0.4, 0.8}, {0.42, 1}, {0.5, 1}, {0.53, 0.5}, {0.6, 0.8}, {0.9, 0.8}, {0.95, 1}},
	post = K.tremble({
		{0.3, 0.42, rate = 20, fade = 0.03, amp = {["Right Arm"] = 1.8, ["Left Arm"] = 1.8, Torso = 1, Head = 0.6}},
	}, K.Feet.post({r = fr, l = fl})),
	joints = K.track({
		{t = 0, pose = S0},
		{t = 0.26, pose = G1, lag = {Head = 0.03, RightKatana = 0.02, LeftKatana = 0.02}},
		{t = 0.4, pose = G2, lag = {Head = 0.02}},
		{t = 0.46, pose = D1},
		{t = 0.52, pose = A1},
		{t = 0.72, pose = A2, lag = {Head = 0.04, LeftKatana = 0.02}},
		{t = 0.9, pose = A3, lag = {Head = 0.02}},
		{t = 0.97, pose = CL},
		{t = 1.25, pose = RC, lag = {Head = 0.03, ["Left Arm"] = 0.02, LeftKatana = 0.03}},
		{t = 1.55, pose = S1, lag = {Head = 0.02}},
	}),
}
