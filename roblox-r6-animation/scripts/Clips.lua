local root = script.Parent.Parent
local Config = require(root.Config)
local Poser = require(script.Parent.Poser)

local V3 = Vector3.new
local F = Config.FloatOffset
local TAU = math.pi * 2
local sin, cos = math.sin, math.cos
local pose = Poser.poseCF

-- a key is time then r {lift twist side} in degrees then p offset then ease name then direction then overshoot
local function K(t, r, p, e, d, s)
	return {t = t, r = r, p = p, e = e, d = d, s = s}
end

local Clips = {}

-- the idle copies the structure of a professional r6 idle: one 3 s chest breath is the engine, the head and
-- the arms follow it a fifth of a cycle later at half the size, the legs shift weight in phase, and the
-- stance itself is built with part offsets (staggered feet, back foot turned out) not with rotation
local function idleKey(name, t, ctx)
	local w = t * TAU / 3
	local breath = sin(w)
	local lag = sin(w - 1.36)
	local open = ctx.stand and 4 or 0
	if name == "Torso" then
		return {p = V3(0, -0.09 - 0.02 * breath, -0.05 - 0.02 * breath), r = {-4.2 - 1.9 * breath, -6 + 0.3 * lag, 0}}
	elseif name == "Head" then
		return {r = {5 - 1.0 * lag, 6, 0}}
	elseif name == "Right Arm" then
		return {p = V3(0, -0.06 - 0.01 * breath, 0), r = {14 + open + 2.3 * lag, -7.5, 4 + open * 0.5}}
	elseif name == "Left Arm" then
		return {p = V3(0, -0.05, 0), r = {-2 + 2.2 * lag, 13, -3 - open * 0.5}}
	elseif name == "Right Leg" then
		return {p = V3(0.07, 0.11, -0.33), r = {-7.8 + 3.4 * breath, -12, 3}}
	elseif name == "Left Leg" then
		return {p = V3(-0.01, 0.15, -0.47), r = {0.3 + 3.3 * breath, 3.5, -4.9}}
	end
	return {}
end

-- the walk follows what four community r6 cycles do: legs swing further back than forward, the back leg
-- pushes down so the foot stays planted, the knee lifts on the forward pass, the torso leans and bobs
-- twice a cycle, the arms swing with a wrist twist from dropped shoulders and the head counters the twist
local function legKey(s, c, a, mirror)
	local lift = s > 0 and 32 * a * s or 48 * a * s
	local knee = 0.24 * a * math.max(0, c)
	local plant = 0.9 * (1 - cos(math.rad(lift))) * (s < 0 and 1 or 0.25)
	return {p = V3(0, knee - plant, 0), r = {lift, 0, mirror and -6 or 6}}
end

local function walkKey(name, ctx)
	local ph = ctx.phase
	local a = math.clamp(ctx.speed / 16, 0.55, 1.15)
	local s, c, c2 = sin(ph), cos(ph), cos(2 * ph)
	if name == "Torso" then
		return {p = V3(0.03 * s * a, 0.055 * (c2 + 1) * a - 0.07, -0.04), r = {-6 - 1.5 * c2, 4 * s * a, 1.5 * s * a}}
	elseif name == "Head" then
		return {r = {3 + 1 * c2, -2 * s * a, -1 * s * a}}
	elseif name == "Right Arm" then
		local lift = 8 - 36 * a * s
		return {p = V3(0, -0.2, 0), r = {lift, 0.6 * lift - 4, 9 + 3 * s}}
	elseif name == "Left Arm" then
		local lift = 8 + 36 * a * s
		return {p = V3(0, -0.2, 0), r = {lift, -0.6 * lift + 4, -9 + 3 * s}}
	elseif name == "Right Leg" then
		return legKey(s, c, a, false)
	elseif name == "Left Leg" then
		return legKey(-s, -c, a, true)
	end
	return {}
end

-- in the air one knee comes up and the arms open so a jump reads as a jump not a frozen walk
local function airKey(name, ctx)
	local up = ctx.jump or 0
	if name == "Torso" then
		return {p = V3(0, 0.02, 0), r = {-6 + 4 * up, 0, 0}}
	elseif name == "Head" then
		return {r = {8, 0, 0}}
	elseif name == "Right Arm" then
		return {r = {-22 - 20 * up, 0, 32}}
	elseif name == "Left Arm" then
		return {r = {-22 - 20 * up, 0, -32}}
	elseif name == "Right Leg" then
		return {r = {20 + 10 * up, 0, 10}}
	elseif name == "Left Leg" then
		return {r = {-10, 0, -10}}
	end
	return {}
end

-- a landing folds the body the way the professional landing does: the torso drops most of a stud and folds
-- forward, the legs fold up into the body, the arms fly forward for balance, the head comes up first
local function landOffset(name, land)
	if land <= 0 then
		return CFrame.new()
	end
	if name == "Torso" then
		return pose({p = V3(0, -0.85 * land, -0.32 * land), r = {-32 * land, 0, 0}})
	elseif name == "Head" then
		return pose({r = {-22 * land, 0, 0}})
	elseif name == "Right Arm" then
		return pose({p = V3(0, -0.3 * land, 0), r = {48 * land, 30 * land, 12 * land}})
	elseif name == "Left Arm" then
		return pose({p = V3(0, -0.3 * land, 0), r = {34 * land, -30 * land, -12 * land}})
	elseif name == "Right Leg" then
		return pose({p = V3(0, 1.0 * land, -0.7 * land), r = {10 * land, 0, 4 * land}})
	elseif name == "Left Leg" then
		return pose({p = V3(0, 0.95 * land, -0.6 * land), r = {32 * land, 0, -6 * land}})
	end
	return CFrame.new()
end

-- the run copies a professional r6 sprint: a 27 degree lean, hips twisting 25 each way with the head
-- countering one to one, two bobs a cycle, legs that swing 54 forward and 78 back while the leg parts drive
-- a stud up and forward at the knee, and arms that pump 60 forward and 84 back
local function runLeg(s, phi, a, mirror)
	local lift = s > 0 and 54 * s or 78 * s
	local knee = math.max(0, sin(phi + 0.35))
	local thigh = math.max(0, sin(phi + 0.6))
	local back = math.max(0, -s)
	return {p = V3(0, 0.95 * a * knee * knee - 0.45 * back, -1.4 * a * thigh * thigh + 0.3 * back), r = {lift, 0, mirror and -4 or 4}}
end

local function runKey(name, ctx)
	local ph = ctx.phase
	local a = 1
	local s, c = sin(ph), cos(ph)
	if name == "Torso" then
		return {p = V3(0.02 * c, -0.36 - 0.08 * sin(2 * ph), -0.29), r = {-27, -24.6 * c, -2 * c}}
	elseif name == "Head" then
		return {r = {3.7 + 5.8 * c * c, 24 * c, 2.3 * c}}
	elseif name == "Right Arm" then
		local lift = 24 - 60 * s
		return {p = V3(0, -0.15 - 0.35 * math.max(0, lift / 84), 0), r = {lift, 0.5 * lift, 10 + 8 * math.abs(s)}}
	elseif name == "Left Arm" then
		local lift = 24 + 60 * s
		return {p = V3(0, -0.15 - 0.35 * math.max(0, lift / 84), 0), r = {lift, -0.5 * lift, -10 - 8 * math.abs(s)}}
	elseif name == "Right Leg" then
		return runLeg(s, ph, a, false)
	elseif name == "Left Leg" then
		return runLeg(-s, ph + math.pi, a, true)
	end
	return {}
end

local function moveJoint(name)
	return function(t, ctx)
		local cf = pose(idleKey(name, t, ctx))
		local walk = ctx.walk or 0
		if walk > 0.001 then
			cf = cf:Lerp(pose(walkKey(name, ctx)), walk)
		end
		local run = ctx.run or 0
		if run > 0.001 then
			cf = cf:Lerp(pose(runKey(name, ctx)), run)
		end
		local air = ctx.air or 0
		if air > 0.001 then
			cf = cf:Lerp(pose(airKey(name, ctx)), air)
		end
		local land = ctx.land or 0
		if land > 0.001 then
			cf = cf * landOffset(name, land)
		end
		return cf
	end
end

-- the locomotion clip never ends so idle walk jump and land all live in one procedural pose
Clips.DioMove = {
	name = "DioMove",
	length = 100000,
	loop = true,
	joints = {
		["Torso"] = moveJoint("Torso"),
		["Head"] = moveJoint("Head"),
		["Right Arm"] = moveJoint("Right Arm"),
		["Left Arm"] = moveJoint("Left Arm"),
		["Right Leg"] = moveJoint("Right Leg"),
		["Left Leg"] = moveJoint("Left Leg"),
	},
}

-- the same pose functions as a bakeable idle and walk so the animation editor can publish them
Clips.DioIdleBake = {
	name = "DioIdle",
	length = 10,
	loop = true,
	joints = Clips.DioMove.joints,
	ctxAt = function(t)
		return {phase = 0, speed = 0, walk = 0, air = 0, land = 0, t = t}
	end,
}

Clips.DioWalkBake = {
	name = "DioWalk",
	length = 13 / 16,
	loop = true,
	joints = Clips.DioMove.joints,
	ctxAt = function(t)
		return {phase = t * TAU * 16 / 13, speed = 16, walk = 1, air = 0, land = 0, t = t}
	end,
}

Clips.DioRunBake = {
	name = "DioRun",
	length = 0.533,
	loop = true,
	joints = Clips.DioMove.joints,
	ctxAt = function(t)
		return {phase = t * TAU / 0.533, speed = 28, walk = 1, run = 1, air = 0, land = 0, t = t}
	end,
}

-- the summon uses the snap hold snap settle timing of the sword kit: three frames into the wind up, a short
-- hold, three frames of backhand fling through a high arc into a side lunge, a settle, then a long breathing hold
-- the head and the free arm land two frames after the torso so the body has overlap
Clips.DioSummon = {
	name = "DioSummon",
	length = 1.2,
	joints = {
		["Torso"] = {
			K(0.00, {3, -8, 0}, V3(0, 0, 0)),
			K(0.08, {-6, 16, 2}, V3(-0.05, -0.12, 0.05), "cubic", "out"),
			K(0.15, {-7, 18, 2}, V3(-0.05, -0.14, 0.05), "sine", "inout"),
			K(0.25, {8, -30, -16}, V3(0.22, -0.22, -0.06), "quart", "out"),
			K(0.34, {6, -26, -13}, V3(0.18, -0.18, -0.04), "sine", "out"),
			K(0.50, {9, -26, -13}, V3(0.18, -0.14, -0.10), "sine", "inout"),
			K(0.64, {6, -26, -13}, V3(0.18, -0.18, -0.04), "sine", "inout"),
			K(0.84, {7, -25, -12}, V3(0.17, -0.16, -0.03), "sine", "inout"),
			K(1.00, {4, -16, -6}, V3(0.09, -0.08, -0.02), "sine", "inout"),
			K(1.20, {3, -8, 0}, V3(0, 0, 0), "sine", "inout"),
		},
		["Head"] = {
			K(0.00, {4, 6, 0}),
			K(0.11, {-14, -3, 2}, nil, "cubic", "out"),
			K(0.17, {-16, -3, 2}, nil, "sine", "inout"),
			K(0.28, {14, 12, -16}, nil, "quart", "out"),
			K(0.37, {12, 12, -14}, nil, "sine", "out"),
			K(0.52, {15, 11, -14}, nil, "sine", "inout"),
			K(0.66, {12, 12, -14}, nil, "sine", "inout"),
			K(0.86, {11, 11, -12}, nil, "sine", "inout"),
			K(1.20, {4, 6, 0}, nil, "sine", "inout"),
		},
		["Right Arm"] = {
			K(0.00, {18, 0, 14}),
			K(0.08, {70, 12, -28}, nil, "cubic", "out"),
			K(0.15, {74, 12, -30}, nil, "sine", "inout"),
			K(0.20, {70, 0, 30}, nil, "quart", "out"),
			K(0.26, {6, -10, 104}, nil, "quart", "out"),
			K(0.35, {8, -10, 96}, nil, "sine", "out"),
			K(0.50, {10, -10, 98}, nil, "sine", "inout"),
			K(0.64, {8, -10, 96}, nil, "sine", "inout"),
			K(0.86, {8, -8, 92}, nil, "sine", "inout"),
			K(1.20, {18, 0, 14}, nil, "sine", "inout"),
		},
		["Left Arm"] = {
			K(0.00, {-6, 0, -14}),
			K(0.10, {-16, 0, -12}, nil, "cubic", "out"),
			K(0.17, {-18, 0, -12}, nil, "sine", "inout"),
			K(0.27, {-34, 4, -22}, nil, "quart", "out"),
			K(0.36, {-30, 4, -20}, nil, "sine", "out"),
			K(0.86, {-26, 3, -18}, nil, "sine", "inout"),
			K(1.20, {-6, 0, -14}, nil, "sine", "inout"),
		},
		["Right Leg"] = {
			K(0.00, {6, 0, 8}),
			K(0.08, {10, 0, 8}, nil, "cubic", "out"),
			K(0.15, {11, 0, 8}, nil, "sine", "inout"),
			K(0.25, {-4, 0, 34}, nil, "quart", "out"),
			K(0.34, {-3, 0, 30}, nil, "sine", "out"),
			K(0.86, {-2, 0, 28}, nil, "sine", "inout"),
			K(1.20, {6, 0, 8}, nil, "sine", "inout"),
		},
		["Left Leg"] = {
			K(0.00, {-6, 0, -8}),
			K(0.08, {-8, 0, -8}, nil, "cubic", "out"),
			K(0.15, {-8, 0, -8}, nil, "sine", "inout"),
			K(0.25, {6, 0, -6}, nil, "quart", "out"),
			K(0.34, {5, 0, -6}, nil, "sine", "out"),
			K(0.86, {4, 0, -6}, nil, "sine", "inout"),
			K(1.20, {-6, 0, -8}, nil, "sine", "inout"),
		},
	},
}

-- the world starts folded inside the back of dio then shoots up past its float height and unfolds
-- the arms open a few frames after the body arrives so the unfold has overlap instead of one jelly pop
Clips.WorldAppear = {
	name = "WorldAppear",
	length = 0.95,
	joints = {
		["StandHumanoidRootPart"] = {
			K(0.00, {-30, 0, 0}, V3(0, -0.9, 0.7)),
			K(0.10, {14, -6, 6}, V3(0.4, F.Y + 2.3, F.Z - 0.6), "cubic", "out"),
			K(0.19, {8, -4, 2}, V3(F.X - 0.2, F.Y + 1.0, F.Z - 0.2), "back", "out", 1.4),
			K(0.36, {4, -2, 0}, V3(F.X, F.Y + 0.3, F.Z), "quad", "out"),
			K(0.66, {2, 0, 0}, V3(F.X, F.Y - 0.05, F.Z), "sine", "inout"),
			K(0.95, {3, 0, 0}, V3(F.X, F.Y + 0.1, F.Z), "sine", "inout"),
		},
		["Stand Head"] = {
			K(0.00, {-30, 0, 0}),
			K(0.10, {0, 0, 0}, nil, "cubic", "out"),
			K(0.22, {14, -8, 0}, nil, "back", "out", 1.4),
			K(0.39, {10, -6, 0}, nil, "quad", "out"),
			K(0.95, {8, -4, 0}, nil, "sine", "inout"),
		},
		["Stand Right Arm"] = {
			K(0.00, {75, 60, -50}),
			K(0.10, {62, 40, -30}, nil, "cubic", "out"),
			K(0.23, {52, -25, 30}, nil, "back", "out", 1.4),
			K(0.40, {44, -22, 24}, nil, "quad", "out"),
			K(0.95, {43, -20, 23}, nil, "sine", "inout"),
		},
		["Stand Left Arm"] = {
			K(0.00, {75, -60, 50}),
			K(0.10, {62, -40, 30}, nil, "cubic", "out"),
			K(0.23, {22, 25, -42}, nil, "back", "out", 1.4),
			K(0.40, {18, 22, -36}, nil, "quad", "out"),
			K(0.95, {17, 20, -35}, nil, "sine", "inout"),
		},
		["Stand Right Leg"] = {
			K(0.00, {30, 0, 4}),
			K(0.10, {12, 0, 6}, nil, "cubic", "out"),
			K(0.21, {30, 0, 16}, nil, "back", "out", 1.4),
			K(0.38, {26, 0, 14}, nil, "quad", "out"),
			K(0.95, {24, 0, 13}, nil, "sine", "inout"),
		},
		["Stand Left Leg"] = {
			K(0.00, {30, 0, -4}),
			K(0.10, {12, 0, -6}, nil, "cubic", "out"),
			K(0.21, {-14, 0, -18}, nil, "back", "out", 1.4),
			K(0.38, {-12, 0, -16}, nil, "quad", "out"),
			K(0.95, {-10, 0, -15}, nil, "sine", "inout"),
		},
	},
}

-- the float idle bobs and sways and when the user walks the stand leans in and trails a little behind
local function floatJoint(name)
	return function(t, ctx)
		local walk = ctx.walk or 0
		local ph = ctx.phase or 0
		local bob = sin(t * TAU * 0.4)
		if name == "StandHumanoidRootPart" then
			return {
				p = V3(F.X + 0.05 * sin(t * TAU * 0.15), F.Y + 0.15 * bob + 0.06 * sin(2 * ph) * walk, F.Z + 0.35 * walk),
				r = {3 - 9 * walk + 1.5 * sin(t * TAU * 0.35 + 1), 2 * sin(t * TAU * 0.2) - 3 * sin(ph) * walk, 1.5 * sin(t * TAU * 0.15) - 2 * sin(ph) * walk},
			}
		elseif name == "Stand Head" then
			return {r = {8 - 3 * walk + 2 * sin(t * TAU * 0.4 + 0.5), -4 + 3 * sin(t * TAU * 0.1), 0}}
		elseif name == "Stand Right Arm" then
			return {r = {43 - 8 * walk + 2.5 * sin(t * TAU * 0.4 + 0.8), -20, 23 + 1.5 * bob}}
		elseif name == "Stand Left Arm" then
			return {r = {17 - 6 * walk + 2 * sin(t * TAU * 0.4 + 1.6), 20, -35 - 1.5 * bob}}
		elseif name == "Stand Right Leg" then
			return {r = {24 - 6 * walk + 2 * sin(t * TAU * 0.4 + 2.2), 0, 13}}
		elseif name == "Stand Left Leg" then
			return {r = {-10 - 4 * walk + 2 * sin(t * TAU * 0.4 + 2.9), 0, -15}}
		end
		return {}
	end
end

Clips.WorldFloat = {
	name = "WorldFloat",
	length = 100000,
	loop = true,
	joints = {
		["StandHumanoidRootPart"] = floatJoint("StandHumanoidRootPart"),
		["Stand Head"] = floatJoint("Stand Head"),
		["Stand Right Arm"] = floatJoint("Stand Right Arm"),
		["Stand Left Arm"] = floatJoint("Stand Left Arm"),
		["Stand Right Leg"] = floatJoint("Stand Right Leg"),
		["Stand Left Leg"] = floatJoint("Stand Left Leg"),
	},
}

Clips.WorldIdleBake = {
	name = "WorldIdle",
	length = 5,
	loop = true,
	joints = Clips.WorldFloat.joints,
	ctxAt = function(t)
		return {phase = 0, walk = 0, t = t}
	end,
}

-- the stand folds back in and dives into the back of dio when it is dismissed
Clips.WorldVanish = {
	name = "WorldVanish",
	length = 0.36,
	joints = {
		["StandHumanoidRootPart"] = {
			K(0.00, {3, 0, 0}, V3(F.X, F.Y + 0.1, F.Z)),
			K(0.12, {-6, 0, 0}, V3(F.X, F.Y + 0.6, F.Z), "sine", "out"),
			K(0.36, {-30, 0, 0}, V3(0, -0.6, 0.6), "cubic", "in"),
		},
		["Stand Head"] = {
			K(0.00, {8, -4, 0}),
			K(0.36, {-30, 0, 0}, nil, "cubic", "in"),
		},
		["Stand Right Arm"] = {
			K(0.00, {43, -20, 23}),
			K(0.36, {75, 60, -50}, nil, "cubic", "in"),
		},
		["Stand Left Arm"] = {
			K(0.00, {17, 20, -35}),
			K(0.36, {75, -60, 50}, nil, "cubic", "in"),
		},
		["Stand Right Leg"] = {
			K(0.00, {24, 0, 13}),
			K(0.36, {30, 0, 4}, nil, "cubic", "in"),
		},
		["Stand Left Leg"] = {
			K(0.00, {-10, 0, -15}),
			K(0.36, {30, 0, -4}, nil, "cubic", "in"),
		},
	},
}

return Clips
