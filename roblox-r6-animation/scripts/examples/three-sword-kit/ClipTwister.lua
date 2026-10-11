local K = require(script.Parent.Kit)

local V3 = K.V3

local AIR = {{0.38, 0}, {0.47, 0.72}, {0.9, 0.9}, {1.45, 0.86}, {1.62, 0.5}, {1.74, 0}}
local BASE = {r = {0.55, 0.18, -8}, l = {-0.55, -0.22, 6}}
local feetAt, fr, fl = K.steps({
	{0.08, 0.3, foot = "r", to = {0.25, 0.25, -20}, lift = 0.15},
	{0.12, 0.3, foot = "l", to = {-0.2, -0.1, 10}},
	{1.62, 1.76, foot = "r", to = {0.05, 0, 2}},
	{1.62, 1.78, foot = "l", to = {-0.05, 0, -2}},
	{1.95, 2.2, foot = "r", to = {-0.35, -0.43, 26}, lift = 0.2},
	{2.02, 2.28, foot = "l", to = {0.3, 0.32, -14}, lift = 0.18},
}, AIR, BASE)

K.named("Twister")
local seed = {}
local function key(t, def)
	return K.body(def, seed, feetAt(t), t)
end

local STANCE_R = {V3(0.15, -0.75, -0.64), V3(-0.3, 0.35, -0.89), V3(0, -1, 0)}
local STANCE_L = {V3(-0.15, -0.8, -0.58), V3(0.4, 0.15, -0.9), V3(0, -1, 0)}

local S0 = key(0, {torso = {-4, 4, 0}, head = {-8, -4, 0}, r = STANCE_R, l = STANCE_L})

local L1 = key(0.24, {torso = {-16, -50, 0}, crouch = 0.45, head = {-14, 38, 0},
	r = {V3(0.45, -0.85, 0.25), V3(0.15, 0.2, 1), V3(1, 0, 0)},
	l = {V3(1.1, -0.6, -0.35), V3(0.5, 0.15, 0.85)}})

local L2 = key(0.35, {torso = {-19, -57, 0}, crouch = 0.52, head = {-16, 43, 0},
	r = {V3(0.4, -0.88, 0.3), V3(0.1, 0.25, 1), V3(1, 0, 0)},
	l = {V3(1.1, -0.65, -0.3), V3(0.45, 0.2, 0.87)}})

local W = key(0.45, {torso = {-6, 10, 0}, rise = 0.55, head = {-8, -8, 0},
	r = {V3(1, 0.08, -0.2), V3(0.05, -0.3, -0.95), V3(0, 0, -1)},
	l = {V3(-1, 0.08, 0.2), V3(-0.05, 0.3, 0.95), V3(0, 0, 1)}})

local spinKeys = {}
for i, t in ipairs({0.64, 0.86, 1.08, 1.3, 1.5}) do
	local s = (i % 2 == 0) and 1 or -1
	spinKeys[i] = {t = t, pose = key(t, {torso = {-3 - s * 2, 0, s * 3}, rise = 0.85, head = {-6, s * 4, 0},
		r = {V3(1, 0.1 * s, -0.1), V3(0.05, -0.3 + 0.12 * s, -0.95), V3(0, 0, -1)},
		l = {V3(-1, -0.1 * s, 0.1), V3(-0.05, 0.3 - 0.12 * s, 0.95), V3(0, 0, 1)}}),
		lag = {Head = 0.02, ["Left Arm"] = 0.015, LeftKatana = 0.02}}
end

local BR = key(1.64, {torso = {16, 0, 0}, rise = 0.55, head = {-2, 0, 0},
	r = {V3(0.8, 0.55, 0.1), V3(0, 0.3, -0.95), V3(0, 1, 0)},
	l = {V3(-0.8, 0.55, 0.1), V3(0, 0.3, -0.95), V3(0, 1, 0)}})

local LD = key(1.78, {torso = {-14, 0, 0}, crouch = 0.45, head = {-10, 0, 0},
	r = {V3(0.7, -0.6, -0.4), V3(0.6, 0.1, 0.8)},
	l = {V3(-0.7, -0.6, -0.4), V3(-0.6, 0.1, 0.8)}})

local L3 = key(1.9, {torso = {-16, 0, 0}, crouch = 0.48, head = {-11, 2, 0},
	r = {V3(0.72, -0.6, -0.36), V3(0.62, 0.08, 0.78)},
	l = {V3(-0.72, -0.62, -0.34), V3(-0.62, 0.06, 0.78)}})

local RC = key(2.05, {torso = {-6, 3, 0}, crouch = 0.12, head = {-9, -5, 0},
	r = {V3(0.12, -0.72, -0.68), V3(-0.22, 0.3, -0.93), V3(0, -1, 0)},
	l = {V3(-0.12, -0.78, -0.62), V3(0.35, 0.12, -0.93), V3(0, -1, 0)}})

local S1 = key(2.35, {torso = {0, 0, 0}, head = {-8, -4, 0}, r = STANCE_R, l = STANCE_L})

local beats = {
	{t = 0, pose = S0},
	{t = 0.24, pose = L1, lag = {Head = 0.03, RightKatana = 0.02, LeftKatana = 0.025}},
	{t = 0.35, pose = L2, lag = {Head = 0.02}},
	{t = 0.45, pose = W},
}
for _, k in ipairs(spinKeys) do
	table.insert(beats, k)
end
for _, k in ipairs({
	{t = 1.64, pose = BR},
	{t = 1.78, pose = LD, lag = {Head = 0.02, LeftKatana = 0.015}},
	{t = 1.9, pose = L3, lag = {Head = 0.03}},
	{t = 2.05, pose = RC, lag = {Head = 0.03, ["Left Arm"] = 0.02, LeftKatana = 0.03}},
	{t = 2.35, pose = S1, lag = {Head = 0.02}},
}) do
	table.insert(beats, k)
end

return {
	name = "DragonTwister",
	length = 2.35,
	curve = "spline",
	life = 0.8,
	lockAt = 2.05,
	spin = K.monotone({{0.4, 0}, {0.52, 70}, {1.46, 1380}, {1.62, 1440}}),
	events = {gather = 0.05, launch = 0.42, spin = 0.5, spinEnd = 1.52, burst = 1.62},
	warp = {{0, 1}, {0.2, 0.8}, {0.36, 0.85}, {0.42, 1.05}, {1.58, 1.05}, {1.64, 0.45}, {1.72, 0.6}, {1.82, 1}},
	post = K.tremble({
		{0.28, 0.42, rate = 18, fade = 0.04, amp = {["Right Arm"] = 1.6, ["Left Arm"] = 1.6, Torso = 0.8, Head = 0.5}},
		{0.6, 1.5, rate = 12, fade = 0.08, amp = {["Right Arm"] = 1.2, ["Left Arm"] = 1.2, Torso = 0.6}},
	}, K.Feet.post({r = fr, l = fl})),
	joints = K.track(beats),
}
