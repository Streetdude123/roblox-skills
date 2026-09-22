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

-- the stand's own clips come from the world model's animation set: raw keyframe sequences played through the
-- poser with the pose names mapped onto the stand joints, and a procedural root that keeps the float
local Anims = root.Assets.Anims
local WRAPS = Poser.wrapsOf(root.Assets.TheWorld)
local MAP = {
	Torso = "Stand Torso",
	Head = "Stand Head",
	["Right Arm"] = "Stand Right Arm",
	["Left Arm"] = "Stand Left Arm",
	["Right Leg"] = "Stand Right Leg",
	["Left Leg"] = "Stand Left Leg",
}

-- the hover is the first frame of the world idle: a floating body that leans in 15 degrees with the torso
-- raised half a stud, the right arm out at 53, the left hand raised across the chest, both legs trailing back
local HOVER = {
	root = {0, 0, 0},
	torso = {-14.7, -8.1, -6.0},
	torsoP = V3(0, 0.46, 0),
	head = {3.8, 13.5, -3.5},
	rArm = {-5.6, -93.5, 53.3},
	lArm = {26.3, -92.4, 124.4},
	rLeg = {-42.3, -1.7, 27.6},
	lLeg = {-33.6, -0.2, -8.0},
	rArmP = V3(0.16, -0.07, -0.36),
	lArmP = V3(0.16, -0.62, -0.15),
	rLegP = V3(0.09, 0.13, -0.55),
	lLegP = V3(-0.24, 0.37, -1.0),
}
-- the fold is the shape it takes inside dio's back: chin tucked, arms crossed, knees pulled up
local FOLD = {
	root = {-35, -40, 0},
	rootP = V3(0, -0.9, 0.6),
	torso = {-10, 0, 0},
	head = {-30, 0, 0},
	rArm = {55, 20, -50},
	lArm = {60, -20, 55},
	rLeg = {60, 0, 8},
	lLeg = {62, 0, -8},
	legP = V3(0, 0.45, -0.2),
}
local APEX = V3(F.X - 0.5, F.Y + 1.0, F.Z - 0.3)

-- the world bursts out of dio's back on one arc, flares open at the apex like a threat display, coils into a
-- claw guard, then relaxes into the model's own idle; the root is the engine, the head follows two frames
-- later, the arms three, the legs four
Clips.WorldAppear = {
	name = "WorldAppear",
	length = 1.0,
	joints = {
		["StandHumanoidRootPart"] = {
			K(0.00, FOLD.root, FOLD.rootP),
			K(0.10, {16, -6, 4}, APEX, "cubic", "out"),
			K(0.24, {12, 0, 2}, APEX + V3(0.1, 0.12, 0), "sine", "inout"),
			K(0.36, {-8, 0, -2}, V3(F.X, F.Y - 0.05, F.Z), "back", "out", 1.25),
			K(0.50, {-6, 0, 0}, V3(F.X, F.Y + 0.06, F.Z), "quad", "out"),
			K(0.72, {-4, 0, 0}, V3(F.X, F.Y + 0.02, F.Z), "sine", "inout"),
			K(1.00, HOVER.root, V3(F.X, F.Y, F.Z), "sine", "inout"),
		},
		["Stand Torso"] = {
			K(0.00, FOLD.torso, V3(0, 0, 0)),
			K(0.12, {12, 0, 0}, V3(0, 0.2, 0), "cubic", "out"),
			K(0.26, {8, 0, 0}, V3(0, 0.25, 0), "sine", "inout"),
			K(0.40, {-22, -6, -6}, V3(0, 0.5, 0), "back", "out", 1.2),
			K(0.54, {-16, -8, -6}, V3(0, 0.44, 0), "quad", "out"),
			K(1.00, HOVER.torso, HOVER.torsoP, "sine", "inout"),
		},
		["Stand Head"] = {
			K(0.00, FOLD.head),
			K(0.12, {22, 0, 0}, nil, "cubic", "out"),
			K(0.26, {18, -5, 3}, nil, "sine", "inout"),
			K(0.40, {-14, -10, -4}, nil, "quart", "out"),
			K(0.52, {-8, -8, -2}, nil, "quad", "out"),
			K(1.00, HOVER.head, nil, "sine", "inout"),
		},
		["Stand Right Arm"] = {
			K(0.00, FOLD.rArm, V3(0, 0, 0)),
			K(0.06, {50, 15, -40}, V3(0, 0, 0), "sine", "inout"),
			K(0.16, {22, 0, 128}, V3(0, 0.08, 0), "back", "out", 1.5),
			K(0.26, {26, -8, 120}, V3(0, 0.08, 0), "sine", "inout"),
			K(0.40, {146, -22, -44}, V3(0, 0.05, 0), "back", "out", 1.2),
			K(0.52, {136, -20, -39}, V3(0, 0.05, 0), "quad", "out"),
			K(0.72, {120, -40, -20}, V3(0.05, 0, -0.1), "sine", "inout"),
			K(1.00, HOVER.rArm, HOVER.rArmP, "sine", "inout"),
		},
		["Stand Left Arm"] = {
			K(0.00, FOLD.lArm, V3(0, 0, 0)),
			K(0.07, {54, -15, 45}, V3(0, 0, 0), "sine", "inout"),
			K(0.18, {20, 0, -128}, V3(0, 0.08, 0), "back", "out", 1.5),
			K(0.28, {24, 8, -120}, V3(0, 0.08, 0), "sine", "inout"),
			K(0.43, {134, 16, 50}, V3(0, 0.02, 0), "back", "out", 1.2),
			K(0.55, {124, 15, 44}, V3(0, 0.02, 0), "quad", "out"),
			K(0.76, {80, -50, 100}, V3(0.1, -0.3, -0.1), "sine", "inout"),
			K(1.00, HOVER.lArm, HOVER.lArmP, "sine", "inout"),
		},
		["Stand Right Leg"] = {
			K(0.00, FOLD.rLeg, FOLD.legP),
			K(0.08, {55, 0, 8}, FOLD.legP - V3(0, 0.05, 0), "sine", "inout"),
			K(0.18, {-14, 0, 16}, V3(0, 0, 0), "back", "out", 1.3),
			K(0.28, {-10, 0, 14}, V3(0, 0, 0), "sine", "inout"),
			K(0.44, {20, 0, 10}, V3(0, 0.12, -0.15), "back", "out", 1.2),
			K(0.56, {15, 0, 10}, V3(0, 0.1, -0.12), "quad", "out"),
			K(1.00, HOVER.rLeg, HOVER.rLegP, "sine", "inout"),
		},
		["Stand Left Leg"] = {
			K(0.00, FOLD.lLeg, FOLD.legP),
			K(0.08, {56, 0, -8}, FOLD.legP - V3(0, 0.05, 0), "sine", "inout"),
			K(0.20, {-12, 0, -16}, V3(0, 0, 0), "back", "out", 1.3),
			K(0.30, {-8, 0, -14}, V3(0, 0, 0), "sine", "inout"),
			K(0.46, {-11, 6, -8}, V3(0, -0.04, 0.06), "back", "out", 1.2),
			K(0.58, {-7, 6, -8}, V3(0, -0.04, 0.06), "quad", "out"),
			K(1.00, HOVER.lLeg, HOVER.lLegP, "sine", "inout"),
		},
	},
}

-- the float root: the model's idle already breathes 0.27 studs on the torso so the root only sways at half
-- speed, leans in and trails a third of a stud when the user walks
local function floatRoot(t, ctx)
	local walk = ctx.walk or 0
	local ph = ctx.phase or 0
	local w = t * TAU / 2.5
	local sway = sin(w * 0.5)
	return {
		p = V3(F.X + 0.05 * sway, F.Y + 0.04 * sin(w) + 0.06 * sin(2 * ph) * walk, F.Z + 0.35 * walk),
		r = {1.2 * sin(w) - 9 * walk, 2 * sway - 3 * sin(ph) * walk, 1.2 * sway - 2 * sin(ph) * walk},
	}
end

Clips.WorldFloat = Poser.fromSequence(Anims.idle, WRAPS, {
	name = "WorldFloat",
	map = MAP,
	loop = true,
	extra = {["StandHumanoidRootPart"] = floatRoot},
})

Clips.WorldIdleBake = {
	name = "WorldIdle",
	length = 5.0,
	loop = true,
	joints = Clips.WorldFloat.joints,
	ctxAt = function(t)
		return {phase = 0, walk = 0, t = t}
	end,
}

-- the vanish is a short threat first: a chest out lift with the arms half open, then the fold and a dive
-- back into dio's back with the same spin the appear unwound
Clips.WorldVanish = {
	name = "WorldVanish",
	length = 0.36,
	joints = {
		["StandHumanoidRootPart"] = {
			K(0.00, HOVER.root, V3(F.X, F.Y, F.Z)),
			K(0.10, {8, 0, 0}, V3(F.X - 0.2, F.Y + 0.45, F.Z - 0.1), "sine", "out"),
			K(0.36, FOLD.root, FOLD.rootP, "cubic", "in"),
		},
		["Stand Torso"] = {
			K(0.00, HOVER.torso, HOVER.torsoP),
			K(0.10, {6, -4, 0}, V3(0, 0.5, 0), "sine", "out"),
			K(0.36, FOLD.torso, V3(0, 0, 0), "cubic", "in"),
		},
		["Stand Head"] = {
			K(0.00, HOVER.head),
			K(0.12, {12, -4, 0}, nil, "sine", "out"),
			K(0.36, FOLD.head, nil, "cubic", "in"),
		},
		["Stand Right Arm"] = {
			K(0.00, HOVER.rArm, HOVER.rArmP),
			K(0.11, {30, -10, 125}, V3(0, 0.08, 0), "sine", "out"),
			K(0.33, FOLD.rArm, V3(0, 0, 0), "cubic", "in"),
		},
		["Stand Left Arm"] = {
			K(0.00, HOVER.lArm, HOVER.lArmP),
			K(0.12, {28, 8, -125}, V3(0, 0.08, 0), "sine", "out"),
			K(0.34, FOLD.lArm, V3(0, 0, 0), "cubic", "in"),
		},
		["Stand Right Leg"] = {
			K(0.00, HOVER.rLeg, HOVER.rLegP),
			K(0.12, {-6, 0, 12}, V3(0, 0, 0), "sine", "out"),
			K(0.35, FOLD.rLeg, FOLD.legP, "cubic", "in"),
		},
		["Stand Left Leg"] = {
			K(0.00, HOVER.lLeg, HOVER.lLegP),
			K(0.13, {-12, 0, -12}, V3(0, 0, 0), "sine", "out"),
			K(0.36, FOLD.lLeg, FOLD.legP, "cubic", "in"),
		},
	},
}

-- the barrage puts the stand in front of the user at chest height; the model's own loop drives the body
-- (the torso swings 110 degrees every five frames) and the root only shivers at 12 Hz so the rush vibrates
local FRONT = Config.BarrageOffset
local function barrageRoot(t, ctx)
	local j = sin(t * TAU * 12)
	local k = cos(t * TAU * 9.3)
	return {p = V3(FRONT.X + 0.04 * j, FRONT.Y + 0.05 * k, FRONT.Z + 0.06 * j), r = {-8 + 1.5 * k, 0, 1.5 * j}}
end

-- the entry frames of the loop come from the idle so they are trimmed and the loop runs 0.083 to 0.667
Clips.WorldBarrage = Poser.fromSequence(Anims.Barrage, WRAPS, {
	name = "WorldBarrage",
	map = MAP,
	loop = true,
	trimStart = 0.083,
	extra = {["StandHumanoidRootPart"] = barrageRoot},
})

-- the finisher is the model's heavy punch: a two frame strike with the arm arcing over the head and a hop
Clips.WorldHeavy = Poser.fromSequence(Anims.HeavyPunch, WRAPS, {
	name = "WorldHeavy",
	map = MAP,
	loop = false,
	extra = {
		["StandHumanoidRootPart"] = function(t)
			local lunge = math.clamp((t - 0.3) / 0.05, 0, 1)
			return {p = V3(FRONT.X, FRONT.Y - 0.2 * lunge, FRONT.Z - 1.2 * lunge), r = {-6 - 10 * lunge, 0, 0}}
		end,
	},
})

-- the five hit chain of the model links end pose to start pose so each clip is the wind up of the next
Clips.WorldCombo = {}
for i, name in ipairs({"LeftPunch", "RightPunch", "LeftUpperCut", "RightKick", "LeftStab"}) do
	Clips.WorldCombo[i] = Poser.fromSequence(Anims[name], WRAPS, {
		name = "World" .. name,
		map = MAP,
		loop = false,
		extra = {
			["StandHumanoidRootPart"] = function()
				return {p = FRONT, r = {-6, 0, 0}}
			end,
		},
	})
end

-- an arm that points dead ahead in root space while the torso is turned: the turn is taken back out of the
-- arm, so {lift, 0, side} comes from the wanted direction (sin tw, -down, -cos tw) in the torso's axes
local function aim(tw, down)
	local dx, dy, dz = sin(math.rad(tw)), -down, -cos(math.rad(tw))
	local n = math.sqrt(dx * dx + dy * dy + dz * dz)
	dx, dy, dz = dx / n, dy / n, dz / n
	local L = math.deg(math.asin(-dz))
	local S = math.deg(math.atan2(dx, -dy))
	return {L, 0, S}
end

-- a leg offset that keeps the foot on the floor under a dropped torso and a swung leg; the torso pitch
-- swings the hips too (a forward lean reads as the legs trailing) so it adds to the leg's own lift
local function legY(torsoY, lift, torsoLift)
	return -torsoY - 2 * (1 - cos(math.rad(lift + (torsoLift or 0)))) + 0.02
end

local function mix(a, b, e)
	return {a[1] + (b[1] - a[1]) * e, a[2] + (b[2] - a[2]) * e, a[3] + (b[3] - a[3]) * e}
end
local function add(a, b)
	return {a[1] + b[1], a[2] + b[2], a[3] + b[3]}
end
local function quartOut(u)
	u = math.clamp(u, 0, 1)
	return 1 - (1 - u) ^ 4
end
local function backOut(u, s)
	u = math.clamp(u, 0, 1)
	s = s or 1.70158
	local v = 1 - u
	return 1 - v * v * ((s + 1) * v - s)
end

-- silhouettes: WIND (turned away, fist drawn back low) -> POINT (the reference: the arm dead straight at the
-- enemy at shoulder height with the fist pushed a third of a stud out, the free arm a bent forearm rising
-- from the left ribs to the collar, chin down and the eyes up from under the brow, the pointing shoulder
-- ten degrees forward, lead foot forward, rear foot back and turned out, weight low)
local POINT = {
	torso = {-6, 10, 3}, torsoP = V3(0.02, -0.12, -0.04),
	head = {-14, -10, 5},
	rArm = aim(10, 0.05), rArmP = V3(0.04, 0.03, -0.3),
	lArm = {150, 0, -10}, lArmP = V3(0.45, -0.75, -0.25),
	rLeg = {10, 0, 8}, rLegP = V3(0.06, legY(-0.12, 10, -6), -0.3),
	lLeg = {-12, 12, -8}, lLegP = V3(-0.08, legY(-0.12, -12, -6), 0.35),
}
local WIND = {
	torso = {3, -12, -2}, torsoP = V3(-0.02, -0.06, 0.28),
	head = {4, 10, 0},
	rArm = {-30, 0, 20}, rArmP = V3(0, -0.04, 0.04),
	lArm = {20, -6, -18}, lArmP = V3(0, -0.02, 0),
	rLeg = {6, 0, 8}, rLegP = V3(0.03, legY(-0.06, 6), -0.1),
	lLeg = {-6, 0, -8}, lLegP = V3(-0.03, legY(-0.06, -6), 0.1),
}
-- the arms pass forward and out on the way so nothing cuts through the torso
local ARC = {rArm = {50, 0, 55}, rArmP = V3(0.02, 0, -0.12), lArm = {90, 0, -60}, lArmP = V3(0, -0.4, -0.2)}

-- the torso whips in four frames and travels a third of a stud forward, the head follows two frames later,
-- the arms three (through the arc, landing with a back overshoot), the legs four; after that the pose only
-- breathes: one 3.4 s chest wave, the head and the arms a fifth of a cycle behind at half size, the legs
-- shifting weight in phase and a slow 9 s weight shift under it all
local function pointJoint(name)
	return function(t)
		local torsoE = quartOut(t / 0.07)
		local headE = backOut((t - 0.03) / 0.08, 1.2)
		local armE1 = quartOut((t - 0.05) / 0.05)
		local armE2 = backOut((t - 0.10) / 0.08, 1.4)
		local legE = backOut((t - 0.07) / 0.09, 1.3)
		local w = t * TAU / 3.4
		local breath = sin(w) * torsoE
		local lag = sin(w - 1.36) * torsoE
		local shift = sin(t * TAU / 9.1) * torsoE
		if name == "Torso" then
			return {p = WIND.torsoP:Lerp(POINT.torsoP, torsoE) + V3(0.02 * shift, -0.02 * breath, -0.02 * breath), r = add(mix(WIND.torso, POINT.torso, torsoE), {-1.6 * breath, 0.5 * shift, 0.4 * shift})}
		elseif name == "Head" then
			return {r = add(mix(WIND.head, POINT.head, headE), {1.0 * lag, -0.6 * shift, 0.3 * lag})}
		elseif name == "Right Arm" then
			local r = t < 0.10 and mix(WIND.rArm, ARC.rArm, armE1) or mix(ARC.rArm, POINT.rArm, armE2)
			local p = t < 0.10 and WIND.rArmP:Lerp(ARC.rArmP, armE1) or ARC.rArmP:Lerp(POINT.rArmP, armE2)
			return {p = p + V3(0, 0.01 * lag, -0.01 * lag), r = add(r, {1.2 * lag, 0, 0.3 * shift})}
		elseif name == "Left Arm" then
			local r = t < 0.10 and mix(WIND.lArm, ARC.lArm, armE1) or mix(ARC.lArm, POINT.lArm, armE2)
			local p = t < 0.10 and WIND.lArmP:Lerp(ARC.lArmP, armE1) or ARC.lArmP:Lerp(POINT.lArmP, armE2)
			return {p = p + V3(0, 0.015 * lag, 0), r = add(r, {1.5 * lag, 0, -0.8 * lag})}
		elseif name == "Right Leg" then
			return {p = WIND.rLegP:Lerp(POINT.rLegP, legE), r = add(mix(WIND.rLeg, POINT.rLeg, legE), {1.2 * breath, 0, 0.5 * shift})}
		elseif name == "Left Leg" then
			return {p = WIND.lLegP:Lerp(POINT.lLegP, legE), r = add(mix(WIND.lLeg, POINT.lLeg, legE), {-1.0 * breath, 0, -0.5 * shift})}
		end
		return {}
	end
end

Clips.DioPoint = {
	name = "DioPoint",
	length = 100000,
	loop = true,
	joints = {
		["Torso"] = pointJoint("Torso"),
		["Head"] = pointJoint("Head"),
		["Right Arm"] = pointJoint("Right Arm"),
		["Left Arm"] = pointJoint("Left Arm"),
		["Right Leg"] = pointJoint("Right Leg"),
		["Left Leg"] = pointJoint("Left Leg"),
	},
}
Clips.DioBarrage = Clips.DioPoint

-- the neutral stance every chain ends on and the walk blends from
local STANCE = {
	torso = {-2, 6, 1}, torsoP = V3(0.02, -0.08, -0.02),
	head = {3, -4, 0},
	rArm = {26, 0, 12}, rArmP = V3(0, -0.05, 0),
	lArm = {-6, 0, -14}, lArmP = V3(0, -0.05, 0),
	rLeg = {6, 0, 6}, rLegP = V3(0.04, legY(-0.08, 6), -0.15),
	lLeg = {-6, 4, -8}, lLegP = V3(-0.04, legY(-0.08, -6), 0.15),
}

-- silhouettes: POINT -> COIL (the pointing shoulder wound back, fist by the hip, creeping through the hold) ->
-- THROW (the point thrown as a punch: torso whips 44 of yaw and lunges 0.6 forward and 0.24 down, the fist first
-- through the arc, the head on the target a frame later, the rear leg driving) -> settle -> recovery to the stance
-- the stand's strike lands at 0.32 so the throw arrives at 0.32
Clips.DioHeavy = {
	name = "DioHeavy",
	length = 0.6,
	joints = {
		["Torso"] = {
			K(0.00, POINT.torso, POINT.torsoP),
			K(0.06, {8, -14, -3}, V3(-0.02, -0.08, 0.1), "cubic", "out"),
			K(0.16, {9, -18, -4}, V3(-0.02, -0.07, 0.12), "sine", "inout"),
			K(0.26, {10, -22, -4}, V3(-0.02, -0.06, 0.14), "sine", "inout"),
			K(0.32, {-16, 22, 6}, V3(0.02, -0.24, -0.6), "back", "out", 1.25),
			K(0.40, {-16, 22, 6}, V3(0.02, -0.22, -0.6), "quad", "out"),
			K(0.50, {-9, 14, 3}, V3(0.02, -0.15, -0.3), "sine", "inout"),
			K(0.60, STANCE.torso, STANCE.torsoP, "sine", "inout"),
		},
		["Head"] = {
			K(0.00, POINT.head),
			K(0.08, {-6, 16, 2}, nil, "cubic", "out"),
			K(0.18, {-7, 18, 3}, nil, "sine", "inout"),
			K(0.27, {-8, 21, 3}, nil, "sine", "inout"),
			K(0.33, {-6, -22, -2}, nil, "back", "out", 1.2),
			K(0.41, {-7, -22, -2}, nil, "quad", "out"),
			K(0.60, STANCE.head, nil, "sine", "inout"),
		},
		["Right Arm"] = {
			K(0.00, POINT.rArm, POINT.rArmP),
			K(0.09, {40, 0, 34}, V3(0.02, 0.02, 0.12), "cubic", "out"),
			K(0.19, {37, 0, 38}, V3(0.02, 0.02, 0.15), "sine", "inout"),
			K(0.27, {34, 0, 42}, V3(0.02, 0.02, 0.18), "sine", "inout"),
			K(0.30, {64, 0, 56}, V3(0.03, 0.04, -0.1), "quad", "out"),
			K(0.32, aim(22, -0.1), V3(0.05, 0.03, -0.44), "back", "out", 1.3),
			K(0.41, aim(22, -0.1), V3(0.05, 0.03, -0.42), "quad", "out"),
			K(0.52, {60, 0, 20}, V3(0.02, 0, -0.2), "sine", "inout"),
			K(0.60, STANCE.rArm, STANCE.rArmP, "sine", "inout"),
		},
		["Left Arm"] = {
			K(0.00, POINT.lArm, POINT.lArmP),
			K(0.10, {110, 0, -40}, V3(0, -0.5, -0.15), "cubic", "out"),
			K(0.20, {104, 0, -44}, V3(0, -0.47, -0.12), "sine", "inout"),
			K(0.28, {100, 0, -46}, V3(0, -0.45, -0.1), "sine", "inout"),
			K(0.35, {-40, 8, -30}, V3(0, -0.05, 0.05), "back", "out", 1.2),
			K(0.43, {-40, 8, -30}, V3(0, -0.05, 0.05), "quad", "out"),
			K(0.60, STANCE.lArm, STANCE.lArmP, "sine", "inout"),
		},
		["Right Leg"] = {
			K(0.00, POINT.rLeg, POINT.rLegP),
			K(0.11, {4, 0, 8}, V3(0.05, legY(-0.08, 4), -0.15), "cubic", "out"),
			K(0.28, {2, 0, 8}, V3(0.05, legY(-0.06, 2), -0.12), "sine", "inout"),
			K(0.36, {26, 0, 8}, V3(0.06, legY(-0.24, 26, -16), -0.55), "back", "out", 1.3),
			K(0.60, STANCE.rLeg, STANCE.rLegP, "sine", "inout"),
		},
		["Left Leg"] = {
			K(0.00, POINT.lLeg, POINT.lLegP),
			K(0.12, {-18, 12, -8}, V3(-0.08, legY(-0.08, -18), 0.45), "cubic", "out"),
			K(0.28, {-20, 12, -8}, V3(-0.08, legY(-0.06, -20), 0.48), "sine", "inout"),
			K(0.36, {-32, 12, -10}, V3(-0.08, legY(-0.24, -32, -16), 0.5), "back", "out", 1.3),
			K(0.60, STANCE.lLeg, STANCE.lLegP, "sine", "inout"),
		},
	},
}

-- the knife throw from the show's three frames: silhouettes STANCE -> LOAD (a low crouch wound to the left, the
-- right hand with its fan of knives crossed high to the left collar, the left hand with the second fan drawn low
-- behind the hip, chin down) -> creep -> the THROW (both arms flung wide and forward in one whip, the torso
-- unwinding to the right and opening, the chest out, the head thrown back with the shout, the front foot driving)
-- -> FOLLOW (the arms held wide and open, the "MUDA" frame) -> recovery to the stance. The fans appear at Draw and
-- the hands open at Release, both from Config.Knives.
local KN = Config.Knives
local KLOAD = {
	torso = {-14, 26, 3}, torsoP = V3(0, -0.35, -0.1),
	head = {-10, -20, 0},
	rArm = {145, 0, 52}, rArmP = V3(-0.35, 0.25, -0.3),
	lArm = {-32, 0, -18}, lArmP = V3(-0.05, -0.05, 0.1),
	rLeg = {-22, 12, 6}, rLegP = V3(0.08, legY(-0.35, -22, -14) - 0.08, 0.45),
	lLeg = {14, 0, -6}, lLegP = V3(-0.06, legY(-0.35, 14, -14), -0.35),
}
local KTHROW = {
	-- the torso dips instead of rising so both legs stay in their hips: a leg key's translation is the hip gap
	torso = {8, -16, -4}, torsoP = V3(0, -0.12, -0.15),
	head = {16, 12, 0},
	rArm = {40, 0, 100}, rArmP = V3(0.15, 0.1, -0.1),
	lArm = {25, 0, -110}, lArmP = V3(-0.15, 0.1, -0.1),
	rLeg = {-10, 10, 8}, rLegP = V3(0.1, legY(-0.12, -10, 8), 0.4),
	lLeg = {14, 0, -8}, lLegP = V3(-0.08, legY(-0.12, 14, 8), -0.4),
}
Clips.DioKnifeThrow = {
	name = "DioKnifeThrow",
	length = 1.05,
	joints = {
		["Torso"] = {
			K(0.00, STANCE.torso, STANCE.torsoP),
			K(0.10, KLOAD.torso, KLOAD.torsoP, "quart", "out"),
			K(0.18, {-15, 29, 3}, V3(0, -0.36, -0.1), "sine", "inout"),
			K(0.26, {-16, 32, 4}, V3(0, -0.37, -0.11), "sine", "inout"),
			K(0.30, KTHROW.torso, KTHROW.torsoP, "back", "out", 1.3),
			K(0.38, {9, -17, -4}, V3(0, -0.1, -0.15), "quad", "out"),
			K(0.50, {10, -18, -4}, V3(0, -0.11, -0.14), "sine", "inout"),
			K(0.62, {9, -17, -4}, V3(0, -0.12, -0.13), "sine", "inout"),
			K(0.85, {2, -4, -1}, V3(0.01, -0.03, -0.06), "sine", "inout"),
			K(1.05, STANCE.torso, STANCE.torsoP, "sine", "inout"),
		},
		["Head"] = {
			K(0.00, STANCE.head),
			K(0.11, KLOAD.head, nil, "quart", "out"),
			K(0.19, {-11, -22, 0}, nil, "sine", "inout"),
			K(0.27, {-12, -24, 0}, nil, "sine", "inout"),
			K(0.31, KTHROW.head, nil, "back", "out", 1.25),
			K(0.39, {17, 13, 0}, nil, "quad", "out"),
			K(0.50, {18, 14, 0}, nil, "sine", "inout"),
			K(0.62, {16, 13, 0}, nil, "sine", "inout"),
			K(0.85, {6, 3, 0}, nil, "sine", "inout"),
			K(1.05, STANCE.head, nil, "sine", "inout"),
		},
		["Right Arm"] = {
			K(0.00, STANCE.rArm, STANCE.rArmP),
			K(0.06, {70, 0, 20}, V3(-0.1, 0.1, -0.25), "cubic", "out"),
			K(0.12, KLOAD.rArm, KLOAD.rArmP, "back", "out", 1.25),
			K(0.20, {147, 0, 54}, V3(-0.37, 0.26, -0.3), "sine", "inout"),
			K(0.27, {149, 0, 56}, V3(-0.38, 0.27, -0.31), "sine", "inout"),
			K(0.29, {80, 0, 30}, V3(0, 0.1, -0.35), "quart", "out"),
			K(0.32, KTHROW.rArm, KTHROW.rArmP, "back", "out", 1.4),
			K(0.40, {40, 0, 103}, V3(0.16, 0.1, -0.1), "quad", "out"),
			K(0.52, {38, 0, 105}, V3(0.16, 0.09, -0.09), "sine", "inout"),
			K(0.64, {39, 0, 104}, V3(0.16, 0.1, -0.1), "sine", "inout"),
			K(0.86, {30, 0, 50}, V3(0.06, 0.02, -0.05), "sine", "inout"),
			K(1.05, STANCE.rArm, STANCE.rArmP, "sine", "inout"),
		},
		["Left Arm"] = {
			K(0.00, STANCE.lArm, STANCE.lArmP),
			K(0.07, {-20, 0, -16}, V3(-0.03, -0.05, 0.05), "cubic", "out"),
			K(0.13, KLOAD.lArm, KLOAD.lArmP, "back", "out", 1.25),
			K(0.21, {-34, 0, -19}, V3(-0.05, -0.05, 0.11), "sine", "inout"),
			K(0.28, {-36, 0, -20}, V3(-0.05, -0.06, 0.12), "sine", "inout"),
			K(0.30, {30, 0, -50}, V3(-0.08, 0.05, -0.2), "quart", "out"),
			K(0.33, KTHROW.lArm, KTHROW.lArmP, "back", "out", 1.4),
			K(0.41, {25, 0, -113}, V3(-0.16, 0.1, -0.1), "quad", "out"),
			K(0.53, {23, 0, -115}, V3(-0.16, 0.09, -0.09), "sine", "inout"),
			K(0.65, {24, 0, -114}, V3(-0.16, 0.1, -0.1), "sine", "inout"),
			K(0.87, {10, 0, -50}, V3(-0.06, 0.02, -0.05), "sine", "inout"),
			K(1.05, STANCE.lArm, STANCE.lArmP, "sine", "inout"),
		},
		["Right Leg"] = {
			K(0.00, STANCE.rLeg, STANCE.rLegP),
			K(0.13, KLOAD.rLeg, KLOAD.rLegP, "back", "out", 1.3),
			K(0.27, {-23, 12, 6}, V3(0.08, legY(-0.37, -23, -16) - 0.08, 0.46), "sine", "inout"),
			K(0.34, KTHROW.rLeg, KTHROW.rLegP, "back", "out", 1.3),
			K(0.62, {-10, 10, 8}, V3(0.1, legY(-0.12, -10, 9), 0.4), "sine", "inout"),
			K(0.86, {0, 4, 7}, V3(0.06, legY(-0.03, 0, 2), 0.1), "sine", "inout"),
			K(1.05, STANCE.rLeg, STANCE.rLegP, "sine", "inout"),
		},
		["Left Leg"] = {
			K(0.00, STANCE.lLeg, STANCE.lLegP),
			K(0.14, KLOAD.lLeg, KLOAD.lLegP, "back", "out", 1.3),
			K(0.27, {15, 0, -6}, V3(-0.06, legY(-0.37, 15, -16) - 0.12, -0.36), "sine", "inout"),
			K(0.35, KTHROW.lLeg, KTHROW.lLegP, "back", "out", 1.3),
			K(0.62, {14, 0, -8}, V3(-0.08, legY(-0.12, 14, 9), -0.4), "sine", "inout"),
			K(0.86, {4, 2, -8}, V3(-0.05, legY(-0.03, 4, 2), -0.05), "sine", "inout"),
			K(1.05, STANCE.lLeg, STANCE.lLegP, "sine", "inout"),
		},
	},
}

-- dio copies the stand's five hits the way a stand user throws the punch in the show: the torso, head and
-- arms are the model's own tracks (the 124 degree torso whip, the countering head, the piston fists) with
-- the arm offsets scaled to a planted body, and only the legs are authored: a step that lands four frames
-- after the strike on a back ease, chained from hit to hit; the caller starts dio three frames ahead so he
-- leads and the stand follows
local UPPER = {Torso = true, Head = true, ["Right Arm"] = true, ["Left Arm"] = true}
-- dio's rig is standard r6 like the stand's so the same c0 wraps serve under his own joint names
local DIOWRAPS = {}
for pose, joint in pairs(MAP) do
	DIOWRAPS[pose] = WRAPS[joint]
end
local PSCALE = {Torso = 1, Head = 1, ["Right Arm"] = 0.4, ["Left Arm"] = 0.4}
-- leg silhouettes per hit: guard, right step, left step, rise, knee up for the kick, the lunge, the stance
local LEGS = {
	{r = {8, 0, 8}, rp = V3(0.05, 0, -0.25), l = {-8, 8, -8}, lp = V3(-0.05, 0, 0.25)},
	{r = {16, 0, 8}, rp = V3(0.05, 0, -0.38), l = {-16, 8, -8}, lp = V3(-0.05, 0, 0.32)},
	{r = {-4, 0, 8}, rp = V3(0.05, 0, 0.1), l = {12, 6, -8}, lp = V3(-0.05, 0, -0.18)},
	{r = {6, 0, 8}, rp = V3(0.05, 0, -0.15), l = {-8, 6, -8}, lp = V3(-0.05, 0, 0.2)},
	{r = {50, 0, 10}, rp = V3(0.05, 0.3, -0.4), l = {-18, 10, -10}, lp = V3(-0.06, 0, 0.38)},
	{r = {28, 0, 8}, rp = V3(0.06, 0, -0.55), l = {-32, 10, -10}, lp = V3(-0.06, 0, 0.5)},
	{r = STANCE.rLeg, rp = V3(0.04, 0, -0.15), l = STANCE.lLeg, lp = V3(-0.04, 0, 0.15)},
}
-- the foot bottom sits at hip + leg pose + (-0.5 sideSign, -2, 0) in the torso's axes and the torso pose sits in
-- root axes, so the leg offset that puts it on the floor (three studs under the root) is one linear solve
local function solveFootY(tp, r, p, sideSign)
	local hip = CFrame.new(sideSign, -1, 0)
	local legPose = Poser.poseCF({p = V3(p.X, 0, p.Z), r = r})
	local foot0 = (tp * hip * legPose * CFrame.new(-0.5 * sideSign, -2, 0)).Position.Y
	local upY = math.max(0.5, tp.Rotation.UpVector.Y)
	return (-3 - foot0) / upY
end
local M1LEN = {0.417, 0.417, 0.417, 0.333, 0.333}
local M1STRIKE = {0.25, 0.25, 0.25, 0.12, 0.12}

-- the stand's torso rides 0.09 above its root through the set so the feet are solved against that
local function legTrack(i, side)
	local from, to = LEGS[i], LEGS[i + 1]
	local arrive = M1STRIKE[i] + 0.07
	local len = M1LEN[i]
	return function(t)
		local e = backOut((t - (arrive - 0.10)) / 0.10, 1.3)
		local rest = i == 5 and quartOut((t - 0.22) / 0.11) or 0
		local a = side == "r" and from.r or from.l
		local b = side == "r" and to.r or to.l
		local pa = side == "r" and from.rp or from.lp
		local pb = side == "r" and to.rp or to.lp
		-- a planted foot is solved onto the floor, a lifted one (the kick) keeps its authored height, and the
		-- two heights blend through the step so no seam opens between hits
		local r = mix(a, b, e)
		local p = pa:Lerp(pb, e)
		local lifted = pa.Y + (pb.Y - pa.Y) * e
		if rest > 0 then
			local sr = side == "r" and LEGS[7].r or LEGS[7].l
			local sp = side == "r" and LEGS[7].rp or LEGS[7].lp
			r = mix(r, sr, rest)
			p = p:Lerp(sp, rest)
			lifted = lifted * (1 - rest)
		end
		-- the copied torso leans up to 33 and rolls up to 30, so a planted foot is solved onto the floor from
		-- the sampled torso pose and the r6 hip geometry; a lifted foot (the kick) keeps its authored height
		local tp = Poser.sample(Clips.DioM1[i], "Torso", t)
		local y = solveFootY(tp, r, p, side == "r" and 1 or -1) + lifted
		return {p = V3(p.X, y, p.Z), r = r}
	end
end

Clips.DioM1 = {}
for i, name in ipairs({"LeftPunch", "RightPunch", "LeftUpperCut", "RightKick", "LeftStab"}) do
	Clips.DioM1[i] = Poser.fromSequence(Anims[name], DIOWRAPS, {
		name = "DioM1_" .. i,
		only = UPPER,
		pScale = PSCALE,
		rollScale = {Torso = 0.45},
		loop = false,
		extra = {
			["Right Leg"] = legTrack(i, "r"),
			["Left Leg"] = legTrack(i, "l"),
		},
	})
end

-- the chain clips are reachable by name too so the pose hold hook can freeze any hit
for _, c in ipairs(Clips.DioM1) do
	Clips[c.name] = c
end

-- the time stop on dio from the show's two frames: silhouettes STANCE -> a dip -> CROSS (a forward crouch with
-- both forearms crossed in an X in front of the face, the block-elbow trick puts the hands at the chin, chin
-- down with the eyes forward) held and tightening through the breath -> the FLING into the V (both arms thrown
-- up and out over the head with open hands, chest out, head back, the stance wide) on "za warudo" -> the V
-- held with a tremble and rising tension through "toki wo tomare" -> the JOLT of the freeze (a 12 degree
-- forward snap, the arms dropping 15, the head forward) -> the V held breathing to the end
local TS = Config.TimeStop.Beats
local CROSS = {
	torso = {-20, 0, 0}, torsoP = V3(0, -0.32, -0.1),
	head = {-12, 0, 0},
	rArm = {155, 0, 78}, rArmP = V3(-0.4, 0.3, -0.55),
	lArm = {155, 0, -78}, lArmP = V3(0.4, 0.2, -0.35),
	rLeg = {6, 0, 10}, rLegP = V3(0.05, legY(-0.32, 6, -20), -0.15),
	lLeg = {-6, 4, -10}, lLegP = V3(-0.05, legY(-0.32, -6, -20), 0.15),
}
local VEE = {
	torso = {14, 0, 0}, torsoP = V3(0, 0.02, 0.06),
	head = {20, 0, 0},
	rArm = {166, 0, -40}, rArmP = V3(0.1, 0.2, 0),
	lArm = {164, 0, 44}, lArmP = V3(-0.1, 0.2, 0),
	rLeg = {4, 0, 14}, rLegP = V3(0.06, legY(0.02, 4, 14), -0.08),
	lLeg = {-4, 4, -14}, lLegP = V3(-0.06, legY(0.02, -4, 14), 0.08),
}
local TENSE = {
	torso = {18, 0, 0}, torsoP = V3(0, 0.03, 0.08),
	head = {24, 0, 0},
	rArm = {169, 0, -44}, rArmP = V3(0.1, 0.22, 0),
	lArm = {167, 0, 48}, lArmP = V3(-0.1, 0.22, 0),
	rLeg = {4, 0, 15}, rLegP = V3(0.06, legY(0.03, 4, 18), -0.08),
	lLeg = {-4, 4, -15}, lLegP = V3(-0.06, legY(0.03, -4, 18), 0.08),
}
local JOLT = {
	torso = {8, 0, 0}, torsoP = V3(0, -0.02, 0.0),
	head = {6, 0, 0},
	rArm = {152, 0, -40}, rArmP = V3(0.1, 0.12, 0),
	lArm = {150, 0, 44}, lArmP = V3(-0.1, 0.12, 0),
	rLeg = {4, 0, 14}, rLegP = V3(0.06, legY(-0.02, 4, 8), -0.08),
	lLeg = {-4, 4, -14}, lLegP = V3(-0.06, legY(-0.02, -4, 8), 0.08),
}
Clips.DioTimeStop = {
	name = "DioTimeStop",
	length = TS.done,
	joints = {
		["Torso"] = {
			K(0.00, STANCE.torso, STANCE.torsoP),
			K(0.05, {-8, 0, 0}, V3(0, -0.12, -0.02), "cubic", "out"),
			K(0.14, CROSS.torso, CROSS.torsoP, "back", "out", 1.25),
			K(0.26, {-22, 0, 0}, V3(0, -0.34, -0.12), "sine", "inout"),
			K(0.31, {-16, 0, 0}, V3(0, -0.2, -0.06), "quart", "out"),
			K(0.40, VEE.torso, VEE.torsoP, "back", "out", 1.3),
			K(0.60, {15, 0, 0}, VEE.torsoP, "sine", "inout"),
			K(0.90, {13, 0, 0}, V3(0, 0.01, 0.05), "sine", "inout"),
			K(1.20, {15, 0, 0}, VEE.torsoP, "sine", "inout"),
			K(1.35, VEE.torso, VEE.torsoP, "sine", "inout"),
			K(2.10, TENSE.torso, TENSE.torsoP, "sine", "inout"),
			K(2.42, {20, 0, 0}, V3(0, 0.03, 0.1), "sine", "in"),
			K(2.50, JOLT.torso, JOLT.torsoP, "back", "out", 1.25),
			K(2.58, JOLT.torso, JOLT.torsoP + V3(0, 0.02, 0), "quad", "out"),
			K(2.85, {9.5, 0, 0}, V3(0, -0.01, 0.01), "sine", "inout"),
			K(3.25, {7, 0, 0}, JOLT.torsoP, "sine", "inout"),
			K(3.60, {9, 0, 0}, V3(0, -0.01, 0.01), "sine", "inout"),
			K(TS.done, JOLT.torso, JOLT.torsoP, "sine", "inout"),
		},
		["Head"] = {
			K(0.00, STANCE.head),
			K(0.07, {-4, 0, 0}, nil, "cubic", "out"),
			K(0.16, CROSS.head, nil, "back", "out", 1.2),
			K(0.27, {-14, 0, 0}, nil, "sine", "inout"),
			K(0.33, {0, 0, 0}, nil, "quart", "out"),
			K(0.42, VEE.head, nil, "back", "out", 1.2),
			K(0.62, {22, 0, 0}, nil, "sine", "inout"),
			K(0.92, {19, 0, 0}, nil, "sine", "inout"),
			K(1.22, {21, 0, 0}, nil, "sine", "inout"),
			K(1.35, VEE.head, nil, "sine", "inout"),
			K(2.10, TENSE.head, nil, "sine", "inout"),
			K(2.42, {26, 0, 0}, nil, "sine", "in"),
			K(2.52, JOLT.head, nil, "back", "out", 1.2),
			K(2.60, JOLT.head, nil, "quad", "out"),
			K(2.85, {7.5, 0, 0}, nil, "sine", "inout"),
			K(3.25, {5, 0, 0}, nil, "sine", "inout"),
			K(3.60, {7, 0, 0}, nil, "sine", "inout"),
			K(TS.done, JOLT.head, nil, "sine", "inout"),
		},
		["Right Arm"] = {
			K(0.00, STANCE.rArm, STANCE.rArmP),
			K(0.07, {40, 0, 30}, V3(0, -0.02, -0.05), "cubic", "out"),
			K(0.11, {80, 0, 60}, V3(-0.2, 0.05, -0.15), "quad", "out"),
			K(0.17, CROSS.rArm, CROSS.rArmP, "back", "out", 1.3),
			K(0.27, {157, 0, 82}, V3(-0.45, 0.3, -0.56), "sine", "inout"),
			K(0.32, {140, 0, 30}, V3(-0.2, 0.1, -0.3), "quart", "out"),
			K(0.37, {125, 0, -70}, V3(0.1, 0.12, 0), "quad", "out"),
			K(0.44, VEE.rArm, VEE.rArmP, "back", "out", 1.5),
			K(0.60, {167.5, 0, -40}, VEE.rArmP, "sine", "inout"),
			K(0.75, {164.5, 0, -41}, V3(0.1, 0.19, 0), "sine", "inout"),
			K(0.90, {167, 0, -39}, V3(0.1, 0.21, 0), "sine", "inout"),
			K(1.05, {164.5, 0, -41}, V3(0.1, 0.19, 0), "sine", "inout"),
			K(1.20, {167.5, 0, -40}, V3(0.1, 0.21, 0), "sine", "inout"),
			K(1.35, VEE.rArm, VEE.rArmP, "sine", "inout"),
			K(2.10, TENSE.rArm, TENSE.rArmP, "sine", "inout"),
			K(2.42, {171, 0, -46}, V3(0.1, 0.23, 0), "sine", "in"),
			K(2.52, JOLT.rArm, JOLT.rArmP, "back", "out", 1.2),
			K(2.60, JOLT.rArm, JOLT.rArmP, "quad", "out"),
			K(2.85, {153.5, 0, -40}, V3(0.1, 0.13, 0), "sine", "inout"),
			K(3.25, {151, 0, -41}, V3(0.1, 0.11, 0), "sine", "inout"),
			K(3.60, {153, 0, -40}, V3(0.1, 0.13, 0), "sine", "inout"),
			K(TS.done, JOLT.rArm, JOLT.rArmP, "sine", "inout"),
		},
		["Left Arm"] = {
			K(0.00, STANCE.lArm, STANCE.lArmP),
			K(0.08, {40, 0, -30}, V3(0, -0.02, -0.05), "cubic", "out"),
			K(0.12, {80, 0, -60}, V3(0.2, 0.02, -0.08), "quad", "out"),
			K(0.18, CROSS.lArm, CROSS.lArmP, "back", "out", 1.3),
			K(0.28, {157, 0, -82}, V3(0.45, 0.2, -0.36), "sine", "inout"),
			K(0.33, {140, 0, -30}, V3(0.2, 0.05, -0.2), "quart", "out"),
			K(0.38, {125, 0, 70}, V3(-0.1, 0.12, 0), "quad", "out"),
			K(0.46, VEE.lArm, VEE.lArmP, "back", "out", 1.5),
			K(0.62, {165.5, 0, 44}, VEE.lArmP, "sine", "inout"),
			K(0.77, {162.5, 0, 45}, V3(-0.1, 0.19, 0), "sine", "inout"),
			K(0.92, {165, 0, 43}, V3(-0.1, 0.21, 0), "sine", "inout"),
			K(1.07, {162.5, 0, 45}, V3(-0.1, 0.19, 0), "sine", "inout"),
			K(1.22, {165.5, 0, 44}, V3(-0.1, 0.21, 0), "sine", "inout"),
			K(1.35, VEE.lArm, VEE.lArmP, "sine", "inout"),
			K(2.10, TENSE.lArm, TENSE.lArmP, "sine", "inout"),
			K(2.42, {169, 0, 50}, V3(-0.1, 0.23, 0), "sine", "in"),
			K(2.53, JOLT.lArm, JOLT.lArmP, "back", "out", 1.2),
			K(2.61, JOLT.lArm, JOLT.lArmP, "quad", "out"),
			K(2.85, {151.5, 0, 46}, V3(-0.1, 0.13, 0), "sine", "inout"),
			K(3.25, {149, 0, 47}, V3(-0.1, 0.11, 0), "sine", "inout"),
			K(3.60, {151, 0, 46}, V3(-0.1, 0.13, 0), "sine", "inout"),
			K(TS.done, JOLT.lArm, JOLT.lArmP, "sine", "inout"),
		},
		["Right Leg"] = {
			K(0.00, STANCE.rLeg, STANCE.rLegP),
			K(0.09, {4, 0, 8}, V3(0.04, legY(-0.12, 4, -8), -0.12), "cubic", "out"),
			K(0.18, CROSS.rLeg, CROSS.rLegP, "back", "out", 1.3),
			K(0.28, {6, 0, 10}, V3(0.05, legY(-0.34, 6, -22), -0.15), "sine", "inout"),
			K(0.34, {5, 0, 12}, V3(0.05, legY(-0.2, 5, -16), -0.1), "quart", "out"),
			K(0.46, VEE.rLeg, VEE.rLegP, "back", "out", 1.3),
			K(1.35, {4, 0, 14}, V3(0.06, legY(0.02, 4, 14), -0.08), "sine", "inout"),
			K(2.10, TENSE.rLeg, TENSE.rLegP, "sine", "inout"),
			K(2.42, {4, 0, 15}, V3(0.06, legY(0.03, 4, 20), -0.08), "sine", "in"),
			K(2.54, JOLT.rLeg, JOLT.rLegP, "back", "out", 1.3),
			K(2.62, JOLT.rLeg, JOLT.rLegP, "quad", "out"),
			K(3.25, {4, 0, 14}, V3(0.06, legY(-0.02, 4, 7), -0.08), "sine", "inout"),
			K(TS.done, JOLT.rLeg, JOLT.rLegP, "sine", "inout"),
		},
		["Left Leg"] = {
			K(0.00, STANCE.lLeg, STANCE.lLegP),
			K(0.09, {-4, 4, -8}, V3(-0.04, legY(-0.12, -4, -8), 0.12), "cubic", "out"),
			K(0.18, CROSS.lLeg, CROSS.lLegP, "back", "out", 1.3),
			K(0.28, {-6, 4, -10}, V3(-0.05, legY(-0.34, -6, -22), 0.15), "sine", "inout"),
			K(0.34, {-5, 4, -12}, V3(-0.05, legY(-0.2, -5, -16), 0.1), "quart", "out"),
			K(0.46, VEE.lLeg, VEE.lLegP, "back", "out", 1.3),
			K(1.35, {-4, 4, -14}, V3(-0.06, legY(0.02, -4, 14), 0.08), "sine", "inout"),
			K(2.10, TENSE.lLeg, TENSE.lLegP, "sine", "inout"),
			K(2.42, {-4, 4, -15}, V3(-0.06, legY(0.03, -4, 20), 0.08), "sine", "in"),
			K(2.54, JOLT.lLeg, JOLT.lLegP, "back", "out", 1.3),
			K(2.62, JOLT.lLeg, JOLT.lLegP, "quad", "out"),
			K(3.25, {-4, 4, -14}, V3(-0.06, legY(-0.02, -4, 7), 0.08), "sine", "inout"),
			K(TS.done, JOLT.lLeg, JOLT.lLegP, "sine", "inout"),
		},
	},
}

-- the road roller on dio, four chained beats under a scripted root: LOAD (a deep crouch) -> SPRING (arms flung
-- up, knees tucked) -> REACH (both hands straight up to the roller) -> RIDE (a crouched grip on the falling
-- roller with the right fist thrown high) -> BRACE (the impact fold) -> the point during the barrage -> LEAP OFF
-- (a spring back with the arms spread) -> LAND (the fold) -> the stance
local RR = Config.RoadRoller.Beats
local LOAD = {
	torso = {-16, 0, 0}, torsoP = V3(0, -0.35, 0.05),
	head = {-6, 0, 0},
	rArm = {-40, 0, 25}, rArmP = V3(0, -0.04, 0.05),
	lArm = {-40, 0, -25}, lArmP = V3(0, -0.04, 0.05),
	rLeg = {8, 0, 10}, rLegP = V3(0.05, legY(-0.35, 8, -16), -0.15),
	lLeg = {-8, 4, -10}, lLegP = V3(-0.05, legY(-0.35, -8, -16), 0.15),
}
local SPRING = {
	torso = {12, 0, 0}, torsoP = V3(0, 0.15, -0.05),
	head = {26, 0, 0},
	rArm = {150, 0, -25}, rArmP = V3(0.1, 0.15, 0),
	lArm = {150, 0, 25}, lArmP = V3(-0.1, 0.15, 0),
	rLeg = {60, 0, 10}, rLegP = V3(0.05, 0.6, -0.5),
	lLeg = {50, 0, -10}, lLegP = V3(-0.05, 0.5, -0.4),
}
local REACH = {
	torso = {6, 0, 0}, torsoP = V3(0, 0.05, 0),
	head = {30, 0, 0},
	rArm = {175, 0, -8}, rArmP = V3(0.05, 0.2, 0),
	lArm = {175, 0, 8}, lArmP = V3(-0.05, 0.2, 0),
	rLeg = {30, 0, 8}, rLegP = V3(0.05, 0.3, -0.3),
	lLeg = {20, 0, -8}, lLegP = V3(-0.05, 0.2, -0.2),
}
local RIDE = {
	torso = {-14, 10, 0}, torsoP = V3(0, -0.3, -0.1),
	head = {-6, -10, 0},
	rArm = {170, 0, -25}, rArmP = V3(0.1, 0.2, 0),
	lArm = {50, 0, -20}, lArmP = V3(0, -0.3, -0.2),
	rLeg = {10, 0, 16}, rLegP = V3(0.06, legY(-0.3, 10, -14), -0.2),
	lLeg = {-10, 4, -16}, lLegP = V3(-0.06, legY(-0.3, -10, -14), 0.2),
}
local BRACE = {
	torso = {-30, 6, 0}, torsoP = V3(0, -0.6, -0.15),
	head = {-20, -6, 0},
	rArm = {60, 0, 20}, rArmP = V3(0, -0.1, -0.2),
	lArm = {60, 0, -20}, lArmP = V3(0, -0.1, -0.2),
	rLeg = {12, 0, 18}, rLegP = V3(0.06, legY(-0.6, 12, -30), -0.25),
	lLeg = {-12, 4, -18}, lLegP = V3(-0.06, legY(-0.6, -12, -30), 0.25),
}
local FLY = {
	torso = {20, 0, 0}, torsoP = V3(0, 0.1, 0.1),
	head = {14, 0, 0},
	rArm = {30, 0, 100}, rArmP = V3(0.05, 0.05, 0),
	lArm = {30, 0, -100}, lArmP = V3(-0.05, 0.05, 0),
	rLeg = {40, 0, 10}, rLegP = V3(0.05, 0.4, -0.3),
	lLeg = {40, 0, -10}, lLegP = V3(-0.05, 0.4, -0.3),
}
local LAND = {
	torso = {-28, 0, 0}, torsoP = V3(0, -0.7, -0.1),
	head = {-16, 0, 0},
	rArm = {50, 0, 15}, rArmP = V3(0, -0.1, -0.15),
	lArm = {50, 0, -15}, lArmP = V3(0, -0.1, -0.15),
	rLeg = {10, 0, 16}, rLegP = V3(0.06, legY(-0.7, 10, -28), -0.2),
	lLeg = {-10, 4, -16}, lLegP = V3(-0.06, legY(-0.7, -10, -28), 0.2),
}

-- one chained clip runs from the cast to the brace; the point takes over on the roller
Clips.DioRollerUp = {
	name = "DioRollerUp",
	length = RR.brace + 0.5,
	joints = {
		["Torso"] = {
			K(0.00, STANCE.torso, STANCE.torsoP),
			K(0.10, LOAD.torso, LOAD.torsoP, "cubic", "out"),
			K(0.22, {-18, 0, 0}, V3(0, -0.38, 0.06), "sine", "inout"),
			K(RR.leap, {-10, 0, 0}, V3(0, -0.2, 0), "quart", "out"),
			K(RR.leap + 0.12, SPRING.torso, SPRING.torsoP, "back", "out", 1.3),
			K(RR.leap + 0.45, {10, 0, 0}, V3(0, 0.12, -0.04), "sine", "inout"),
			K(RR.reach, REACH.torso, REACH.torsoP, "back", "out", 1.2),
			K(RR.catch, {4, 0, 0}, REACH.torsoP, "sine", "inout"),
			K(RR.catch + 0.14, RIDE.torso, RIDE.torsoP, "back", "out", 1.25),
			K(RR.catch + 0.5, {-16, 12, 1}, V3(0, -0.32, -0.1), "sine", "inout"),
			K(RR.catch + 0.85, {-13, 9, -1}, V3(0, -0.29, -0.1), "sine", "inout"),
			K(RR.land, RIDE.torso, RIDE.torsoP, "sine", "inout"),
			K(RR.land + 0.08, BRACE.torso, BRACE.torsoP, "back", "out", 1.25),
			K(RR.land + 0.16, BRACE.torso, BRACE.torsoP + V3(0, 0.03, 0), "quad", "out"),
			K(RR.brace + 0.5, {-6, 4, 0}, V3(0, -0.15, -0.05), "sine", "inout"),
		},
		["Head"] = {
			K(0.00, STANCE.head),
			K(0.12, LOAD.head, nil, "cubic", "out"),
			K(0.23, {-8, 0, 0}, nil, "sine", "inout"),
			K(RR.leap + 0.02, {0, 0, 0}, nil, "quart", "out"),
			K(RR.leap + 0.14, SPRING.head, nil, "back", "out", 1.2),
			K(RR.reach + 0.02, REACH.head, nil, "back", "out", 1.2),
			K(RR.catch + 0.16, RIDE.head, nil, "back", "out", 1.2),
			K(RR.catch + 0.55, {-8, -12, 0}, nil, "sine", "inout"),
			K(RR.land, RIDE.head, nil, "sine", "inout"),
			K(RR.land + 0.10, BRACE.head, nil, "back", "out", 1.2),
			K(RR.brace + 0.5, {2, -4, 0}, nil, "sine", "inout"),
		},
		["Right Arm"] = {
			K(0.00, STANCE.rArm, STANCE.rArmP),
			K(0.13, LOAD.rArm, LOAD.rArmP, "cubic", "out"),
			K(0.24, {-44, 0, 27}, LOAD.rArmP, "sine", "inout"),
			K(RR.leap + 0.03, {40, 0, 60}, V3(0.05, 0.05, -0.1), "quad", "out"),
			K(RR.leap + 0.15, SPRING.rArm, SPRING.rArmP, "back", "out", 1.5),
			K(RR.reach + 0.03, REACH.rArm, REACH.rArmP, "back", "out", 1.2),
			K(RR.catch + 0.18, RIDE.rArm, RIDE.rArmP, "back", "out", 1.3),
			K(RR.catch + 0.55, {172, 0, -27}, V3(0.1, 0.22, 0), "sine", "inout"),
			K(RR.land, RIDE.rArm, RIDE.rArmP, "sine", "inout"),
			K(RR.land + 0.11, BRACE.rArm, BRACE.rArmP, "back", "out", 1.2),
			K(RR.brace + 0.5, {30, 0, 14}, V3(0, -0.05, -0.05), "sine", "inout"),
		},
		["Left Arm"] = {
			K(0.00, STANCE.lArm, STANCE.lArmP),
			K(0.14, LOAD.lArm, LOAD.lArmP, "cubic", "out"),
			K(0.25, {-44, 0, -27}, LOAD.lArmP, "sine", "inout"),
			K(RR.leap + 0.04, {40, 0, -60}, V3(-0.05, 0.05, -0.1), "quad", "out"),
			K(RR.leap + 0.16, SPRING.lArm, SPRING.lArmP, "back", "out", 1.5),
			K(RR.reach + 0.04, REACH.lArm, REACH.lArmP, "back", "out", 1.2),
			K(RR.catch + 0.19, RIDE.lArm, RIDE.lArmP, "back", "out", 1.3),
			K(RR.catch + 0.55, {52, 0, -22}, V3(0, -0.32, -0.2), "sine", "inout"),
			K(RR.land, RIDE.lArm, RIDE.lArmP, "sine", "inout"),
			K(RR.land + 0.12, BRACE.lArm, BRACE.lArmP, "back", "out", 1.2),
			K(RR.brace + 0.5, {24, -4, -16}, V3(0, -0.05, -0.05), "sine", "inout"),
		},
		["Right Leg"] = {
			K(0.00, STANCE.rLeg, STANCE.rLegP),
			K(0.15, LOAD.rLeg, LOAD.rLegP, "cubic", "out"),
			K(RR.leap + 0.05, {20, 0, 10}, V3(0.05, 0.1, -0.2), "quad", "out"),
			K(RR.leap + 0.18, SPRING.rLeg, SPRING.rLegP, "back", "out", 1.3),
			K(RR.reach + 0.05, REACH.rLeg, REACH.rLegP, "back", "out", 1.3),
			K(RR.catch + 0.2, RIDE.rLeg, RIDE.rLegP, "back", "out", 1.3),
			K(RR.land, RIDE.rLeg, RIDE.rLegP, "sine", "inout"),
			K(RR.land + 0.13, BRACE.rLeg, BRACE.rLegP, "back", "out", 1.3),
			K(RR.brace + 0.5, {8, 0, 8}, V3(0.05, legY(-0.15, 8, -6), -0.2), "sine", "inout"),
		},
		["Left Leg"] = {
			K(0.00, STANCE.lLeg, STANCE.lLegP),
			K(0.15, LOAD.lLeg, LOAD.lLegP, "cubic", "out"),
			K(RR.leap + 0.05, {10, 0, -10}, V3(-0.05, 0.1, -0.1), "quad", "out"),
			K(RR.leap + 0.19, SPRING.lLeg, SPRING.lLegP, "back", "out", 1.3),
			K(RR.reach + 0.06, REACH.lLeg, REACH.lLegP, "back", "out", 1.3),
			K(RR.catch + 0.21, RIDE.lLeg, RIDE.lLegP, "back", "out", 1.3),
			K(RR.land, RIDE.lLeg, RIDE.lLegP, "sine", "inout"),
			K(RR.land + 0.14, BRACE.lLeg, BRACE.lLegP, "back", "out", 1.3),
			K(RR.brace + 0.5, {-8, 4, -8}, V3(-0.05, legY(-0.15, -8, -6), 0.2), "sine", "inout"),
		},
	},
}

Clips.DioRollerOff = {
	name = "DioRollerOff",
	length = 1.2,
	joints = {
		["Torso"] = {
			K(0.00, POINT.torso, POINT.torsoP),
			K(0.08, {-14, 0, 0}, V3(0, -0.3, 0.05), "cubic", "out"),
			K(0.18, FLY.torso, FLY.torsoP, "back", "out", 1.3),
			K(0.45, {22, 0, 0}, V3(0, 0.12, 0.12), "sine", "inout"),
			K(0.66, {10, 0, 0}, V3(0, 0, 0.05), "quart", "out"),
			K(0.74, LAND.torso, LAND.torsoP, "back", "out", 1.25),
			K(0.82, LAND.torso, LAND.torsoP + V3(0, 0.03, 0), "quad", "out"),
			K(1.00, {-12, 0, 0}, V3(0, -0.3, -0.05), "sine", "inout"),
			K(1.20, STANCE.torso, STANCE.torsoP, "sine", "inout"),
		},
		["Head"] = {
			K(0.00, POINT.head),
			K(0.10, {-8, 0, 0}, nil, "cubic", "out"),
			K(0.20, FLY.head, nil, "back", "out", 1.2),
			K(0.45, {16, 0, 0}, nil, "sine", "inout"),
			K(0.76, LAND.head, nil, "back", "out", 1.2),
			K(0.98, {-4, 0, 0}, nil, "sine", "inout"),
			K(1.20, STANCE.head, nil, "sine", "inout"),
		},
		["Right Arm"] = {
			K(0.00, POINT.rArm, POINT.rArmP),
			K(0.11, {-30, 0, 25}, V3(0, -0.04, 0.05), "cubic", "out"),
			K(0.16, {20, 0, 70}, V3(0.05, 0.05, 0), "quad", "out"),
			K(0.21, FLY.rArm, FLY.rArmP, "back", "out", 1.5),
			K(0.45, {34, 0, 102}, FLY.rArmP, "sine", "inout"),
			K(0.77, LAND.rArm, LAND.rArmP, "back", "out", 1.2),
			K(1.00, {36, 0, 14}, V3(0, -0.06, -0.06), "sine", "inout"),
			K(1.20, STANCE.rArm, STANCE.rArmP, "sine", "inout"),
		},
		["Left Arm"] = {
			K(0.00, POINT.lArm, POINT.lArmP),
			K(0.12, {-30, 0, -25}, V3(0, -0.04, 0.05), "cubic", "out"),
			K(0.17, {20, 0, -70}, V3(-0.05, 0.05, 0), "quad", "out"),
			K(0.22, FLY.lArm, FLY.lArmP, "back", "out", 1.5),
			K(0.45, {34, 0, -102}, FLY.lArmP, "sine", "inout"),
			K(0.78, LAND.lArm, LAND.lArmP, "back", "out", 1.2),
			K(1.00, {2, 0, -14}, V3(0, -0.06, -0.02), "sine", "inout"),
			K(1.20, STANCE.lArm, STANCE.lArmP, "sine", "inout"),
		},
		["Right Leg"] = {
			K(0.00, POINT.rLeg, POINT.rLegP),
			K(0.13, {12, 0, 12}, V3(0.05, legY(-0.3, 12, -14), -0.2), "cubic", "out"),
			K(0.24, FLY.rLeg, FLY.rLegP, "back", "out", 1.3),
			K(0.66, {20, 0, 10}, V3(0.05, 0.1, -0.2), "quart", "out"),
			K(0.79, LAND.rLeg, LAND.rLegP, "back", "out", 1.3),
			K(1.20, STANCE.rLeg, STANCE.rLegP, "sine", "inout"),
		},
		["Left Leg"] = {
			K(0.00, POINT.lLeg, POINT.lLegP),
			K(0.13, {-12, 4, -12}, V3(-0.05, legY(-0.3, -12, -14), 0.2), "cubic", "out"),
			K(0.25, FLY.lLeg, FLY.lLegP, "back", "out", 1.3),
			K(0.66, {10, 4, -10}, V3(-0.05, 0.1, -0.1), "quart", "out"),
			K(0.80, LAND.lLeg, LAND.lLegP, "back", "out", 1.3),
			K(1.20, STANCE.lLeg, STANCE.lLegP, "sine", "inout"),
		},
	},
}

-- the world on the roller: the model's rush loop with the root pitched 65 down over the front housing so the fists
-- (2.7 studs along the look at full extension) land on the metal 2.45 below and 1.1 ahead of the root
local ROLL = Config.RoadRoller.StandOffset
Clips.WorldRollerBarrage = Poser.fromSequence(Anims.Barrage, WRAPS, {
	name = "WorldRollerBarrage",
	map = MAP,
	loop = true,
	trimStart = 0.083,
	extra = {
		["StandHumanoidRootPart"] = function(t)
			local j = sin(t * TAU * 12)
			return {p = V3(ROLL.X + 0.04 * j, ROLL.Y + 0.05 * cos(t * TAU * 9.3), ROLL.Z + 0.06 * j), r = {-65 + 2 * j, 0, 1.5 * j}}
		end,
	},
})

-- the world rises over dio on the call and spreads wide like a threat display, gathers both hands high on
-- the command, then snaps a double palm thrust at the camera on the last syllable and hangs there
local TSP = Config.TimeStop.StandOffset
Clips.WorldTimeStop = {
	name = "WorldTimeStop",
	length = TS.done,
	joints = {
		["StandHumanoidRootPart"] = {
			K(0.00, HOVER.root, V3(F.X, F.Y, F.Z)),
			K(0.40, {6, 0, 0}, TSP + V3(0, 0.4, 0), "cubic", "out"),
			K(0.85, {4, 0, 0}, TSP, "sine", "inout"),
			K(1.35, {6, 0, 0}, TSP + V3(0, 0.15, 0), "sine", "inout"),
			K(TS.snap - 0.35, {10, 0, 0}, TSP + V3(0, 0.4, 0.3), "sine", "inout"),
			K(TS.snap, {-10, 0, 0}, TSP + V3(0, -0.2, -0.8), "quart", "out"),
			K(TS.snap + 0.12, {-8, 0, 0}, TSP + V3(0, -0.1, -0.6), "sine", "out"),
			K(TS.done, {-6, 0, 0}, TSP + V3(0, 0, -0.5), "sine", "inout"),
		},
		["Stand Torso"] = {
			K(0.00, HOVER.torso, HOVER.torsoP),
			K(0.40, {10, 0, 0}, V3(0, 0.5, 0), "cubic", "out"),
			K(0.85, {12, 0, 0}, V3(0, 0.48, 0), "sine", "inout"),
			K(TS.snap - 0.35, {16, 0, 0}, V3(0, 0.55, 0.1), "sine", "inout"),
			K(TS.snap, {-18, 0, 0}, V3(0, 0.3, -0.25), "quart", "out"),
			K(TS.done, {-14, 0, 0}, V3(0, 0.35, -0.2), "sine", "inout"),
		},
		["Stand Head"] = {
			K(0.00, HOVER.head),
			K(0.42, {22, 0, 0}, nil, "cubic", "out"),
			K(0.85, {24, 0, 0}, nil, "sine", "inout"),
			K(TS.snap - 0.33, {28, 0, 0}, nil, "sine", "inout"),
			K(TS.snap + 0.03, {-8, 0, 0}, nil, "quart", "out"),
			K(TS.done, {-4, 0, 0}, nil, "sine", "inout"),
		},
		["Stand Right Arm"] = {
			K(0.00, HOVER.rArm, HOVER.rArmP),
			K(0.20, {60, -40, 90}, V3(0.1, 0.1, -0.2), "sine", "inout"),
			K(0.44, {10, 0, 124}, V3(0.1, 0.15, 0), "back", "out", 1.4),
			K(0.85, {12, 0, 120}, V3(0.1, 0.15, 0), "sine", "inout"),
			K(1.35, {14, 0, 122}, V3(0.1, 0.15, 0), "sine", "inout"),
			K(TS.snap - 0.35, {150, -20, -30}, V3(0.05, 0.2, 0.1), "sine", "inout"),
			K(TS.snap, {88, 0, 14}, V3(0.1, 0, -0.6), "quart", "out"),
			K(TS.snap + 0.1, {92, 0, 12}, V3(0.1, 0, -0.55), "sine", "out"),
			K(TS.done, {90, 0, 12}, V3(0.1, 0, -0.5), "sine", "inout"),
		},
		["Stand Left Arm"] = {
			K(0.00, HOVER.lArm, HOVER.lArmP),
			K(0.22, {60, 40, -90}, V3(-0.1, 0.1, -0.2), "sine", "inout"),
			K(0.47, {10, 0, -124}, V3(-0.1, 0.15, 0), "back", "out", 1.4),
			K(0.85, {12, 0, -120}, V3(-0.1, 0.15, 0), "sine", "inout"),
			K(1.35, {14, 0, -122}, V3(-0.1, 0.15, 0), "sine", "inout"),
			K(TS.snap - 0.33, {150, 20, 30}, V3(-0.05, 0.2, 0.1), "sine", "inout"),
			K(TS.snap + 0.02, {88, 0, -14}, V3(-0.1, 0, -0.6), "quart", "out"),
			K(TS.snap + 0.12, {92, 0, -12}, V3(-0.1, 0, -0.55), "sine", "out"),
			K(TS.done, {90, 0, -12}, V3(-0.1, 0, -0.5), "sine", "inout"),
		},
		["Stand Right Leg"] = {
			K(0.00, HOVER.rLeg, HOVER.rLegP),
			K(0.46, {-30, 0, 24}, V3(0.1, 0.2, -0.5), "sine", "inout"),
			K(TS.snap - 0.35, {-36, 0, 26}, V3(0.1, 0.25, -0.5), "sine", "inout"),
			K(TS.snap + 0.02, {-52, 0, 20}, V3(0.1, 0.1, -0.7), "quart", "out"),
			K(TS.done, {-48, 0, 22}, V3(0.1, 0.12, -0.65), "sine", "inout"),
		},
		["Stand Left Leg"] = {
			K(0.00, HOVER.lLeg, HOVER.lLegP),
			K(0.48, {-24, 0, -20}, V3(-0.2, 0.35, -0.9), "sine", "inout"),
			K(TS.snap - 0.35, {-28, 0, -22}, V3(-0.2, 0.4, -0.9), "sine", "inout"),
			K(TS.snap + 0.03, {-44, 0, -16}, V3(-0.2, 0.25, -1.1), "quart", "out"),
			K(TS.done, {-40, 0, -18}, V3(-0.2, 0.28, -1.05), "sine", "inout"),
		},
	},
}

-- while time is stopped the world hangs in the thrust pose and breathes, the root sways at half speed
Clips.WorldStopped = {
	name = "WorldStopped",
	length = 100000,
	loop = true,
	joints = {
		["StandHumanoidRootPart"] = function(t, ctx)
			local walk = ctx.walk or 0
			local w = t * TAU / 2.5
			return {p = V3(F.X + 0.05 * sin(w * 0.5), F.Y + 0.06 * sin(w), F.Z + 0.35 * walk), r = {-6 + 1.5 * sin(w) - 8 * walk, 0, 1.2 * sin(w * 0.5)}}
		end,
		["Stand Torso"] = function(t)
			local w = t * TAU / 2.5
			return {p = V3(0, 0.35 - 0.08 * sin(w), -0.2), r = {-14 - 2 * sin(w), -4, -3}}
		end,
		["Stand Head"] = function(t)
			return {r = {-4 + 2 * sin(t * TAU / 2.5 - 1.2), 6, 0}}
		end,
		["Stand Right Arm"] = function(t)
			local lag = sin(t * TAU / 2.5 - 1.2)
			return {p = V3(0.1, 0.02 * lag, -0.5), r = {90 + 3 * lag, 0, 12 + 2 * lag}}
		end,
		["Stand Left Arm"] = function(t)
			local lag = sin(t * TAU / 2.5 - 1.2)
			return {p = V3(-0.1, 0.02 * lag, -0.5), r = {90 + 3 * lag, 0, -12 - 2 * lag}}
		end,
		["Stand Right Leg"] = function(t)
			return {p = V3(0.1, 0.12, -0.65), r = {-48 + 2.5 * sin(t * TAU / 2.5), 0, 22}}
		end,
		["Stand Left Leg"] = function(t)
			return {p = V3(-0.2, 0.28, -1.05), r = {-40 - 2 * sin(t * TAU / 2.5), 0, -18}}
		end,
	},
}

-- a leg key's translation is a gap at the hip (the hip pivots at the leg's top corner, so a slid leg leaves the
-- torso), so every authored dio clip moves its foot placements into the hip angles instead: p.z becomes a forward
-- swing, p.x a side swing, and the leg is never pulled more than HIP_GAP below the torso; the foot lands where it
-- did and may float a few hundredths. "it can be a tiny little bit off the body but not like that" (2026-09-22)
local HIP_GAP = 0.12
local function attachLegs(clip)
	for _, j in ipairs({"Right Leg", "Left Leg"}) do
		local keys = clip.joints[j]
		local function fix(p, r)
			local dl = math.deg(math.asin(math.clamp(-p.Z / 2, -1, 1)))
			local ds = math.deg(math.asin(math.clamp(p.X / 2, -1, 1)))
			return {r[1] + dl, r[2], r[3] + ds}, V3(0, math.max(p.Y, -HIP_GAP), 0)
		end
		if type(keys) == "table" then
			for _, k in ipairs(keys) do
				if k.p and k.r then
					k.r, k.p = fix(k.p, k.r)
				end
			end
		elseif type(keys) == "function" then
			-- a procedural leg (the point's breath and weight shift) gets the same transfer on every sample
			clip.joints[j] = function(t, ctx)
				local s = keys(t, ctx)
				if s and s.p and s.r then
					local r, p = fix(s.p, s.r)
					return {r = r, p = p}
				end
				return s
			end
		end
	end
end
for _, name in ipairs({"DioSummon", "DioPoint", "DioHeavy", "DioTimeStop", "DioRollerUp", "DioRollerOff", "DioKnifeThrow"}) do
	attachLegs(Clips[name])
end

return Clips
