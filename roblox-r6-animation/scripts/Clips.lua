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

-- a leg offset that keeps the foot on the floor under a dropped torso and a swung leg
local function legY(torsoY, lift)
	return -torsoY - 2 * (1 - cos(math.rad(lift))) + 0.02
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
	rLeg = {10, 0, 8}, rLegP = V3(0.06, legY(-0.12, 10), -0.3),
	lLeg = {-12, 12, -8}, lLegP = V3(-0.08, legY(-0.12, -12), 0.35),
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
			K(0.36, {26, 0, 8}, V3(0.06, legY(-0.24, 26), -0.55), "back", "out", 1.3),
			K(0.60, STANCE.rLeg, STANCE.rLegP, "sine", "inout"),
		},
		["Left Leg"] = {
			K(0.00, POINT.lLeg, POINT.lLegP),
			K(0.12, {-18, 12, -8}, V3(-0.08, legY(-0.08, -18), 0.45), "cubic", "out"),
			K(0.28, {-20, 12, -8}, V3(-0.08, legY(-0.06, -20), 0.48), "sine", "inout"),
			K(0.36, {-32, 12, -10}, V3(-0.08, legY(-0.24, -32), 0.5), "back", "out", 1.3),
			K(0.60, STANCE.lLeg, STANCE.lLegP, "sine", "inout"),
		},
	},
}

-- dio's command gestures under the stand's five hits, chained end pose to start pose like the stand's own
-- clips; silhouettes: A guard -> B jab point -> C left chop -> D rising fist -> E lean back and sweep -> lunge
-- point -> the stance; the torso is the engine on every hit and lands on a back ease, the head counters it
-- onto the target two frames later, the free arm three, the legs four; every step is a part offset
local A = {
	torso = {-4, 14, 2}, torsoP = V3(0.02, -0.1, -0.02),
	head = {2, -12, 0},
	rArm = {30, 0, 14}, rArmP = V3(0, -0.05, -0.05),
	lArm = {24, -4, -16}, lArmP = V3(0, -0.05, -0.05),
	rLeg = {8, 0, 8}, rLegP = V3(0.05, legY(-0.1, 8), -0.25),
	lLeg = {-8, 8, -8}, lLegP = V3(-0.05, legY(-0.1, -8), 0.25),
}
local B = {
	torso = {-10, 20, 3}, torsoP = V3(0.02, -0.14, -0.2),
	head = {0, -20, 0},
	rArm = aim(20, 0.0), rArmP = V3(0.03, 0.02, -0.2),
	lArm = {-18, 0, -20}, lArmP = V3(0, -0.05, 0),
	rLeg = {14, 0, 8}, rLegP = V3(0.05, legY(-0.14, 14), -0.35),
	lLeg = {-14, 8, -8}, lLegP = V3(-0.05, legY(-0.14, -14), 0.3),
}
local C = {
	torso = {-12, -12, -3}, torsoP = V3(-0.02, -0.14, -0.2),
	head = {2, 12, 0},
	rArm = {36, 0, 18}, rArmP = V3(0, -0.02, -0.1),
	lArm = {78, 8, -10}, lArmP = V3(-0.03, 0.02, -0.2),
	rLeg = {-4, 0, 8}, rLegP = V3(0.05, legY(-0.14, -4), 0.1),
	lLeg = {10, 6, -8}, lLegP = V3(-0.05, legY(-0.14, 10), -0.15),
}
local D = {
	torso = {6, 14, 3}, torsoP = V3(0, 0.02, 0.03),
	head = {12, -12, 0},
	rArm = {146, -10, -8}, rArmP = V3(0.05, 0.08, -0.1),
	lArm = {-26, 0, -24}, lArmP = V3(0, -0.05, 0.02),
	rLeg = {6, 0, 8}, rLegP = V3(0.05, legY(0.02, 6), -0.15),
	lLeg = {-8, 6, -8}, lLegP = V3(-0.05, legY(0.02, -8), 0.2),
}
local E = {
	torso = {14, -14, -5}, torsoP = V3(0, -0.06, 0.15),
	head = {12, 10, -4},
	rArm = {38, 0, 92}, rArmP = V3(0.05, 0, -0.05),
	lArm = {28, 0, -16}, lArmP = V3(0, -0.04, -0.05),
	rLeg = {16, 0, 8}, rLegP = V3(0.05, legY(-0.06, 16), -0.35),
	lLeg = {-16, 10, -10}, lLegP = V3(-0.06, legY(-0.06, -16), 0.35),
}
local LUNGE = {
	torso = {-16, 22, 5}, torsoP = V3(0.03, -0.24, -0.55),
	head = {-4, -22, 2},
	rArm = aim(22, -0.1), rArmP = V3(0.04, 0.02, -0.4),
	lArm = {-36, 6, -28}, lArmP = V3(0, -0.05, 0.05),
	rLeg = {28, 0, 8}, rLegP = V3(0.06, legY(-0.24, 28), -0.55),
	lLeg = {-32, 10, -10}, lLegP = V3(-0.06, legY(-0.24, -32), 0.5),
}

local function chainClip(name, length, keys)
	return {name = name, length = length, joints = keys}
end

Clips.DioM1 = {
	-- hit 1: the pointing shoulder coils back in five frames, creeps through the hold, the jab point lands at 0.25
	chainClip("DioM1_1", 0.417, {
		["Torso"] = {
			K(0.00, A.torso, A.torsoP),
			K(0.08, {-2, 2, 1}, V3(0, -0.1, 0.06), "cubic", "out"),
			K(0.16, {-1, -2, 1}, V3(0, -0.1, 0.09), "sine", "inout"),
			K(0.25, {-11, 22, 3}, V3(0.02, -0.15, -0.24), "back", "out", 1.25),
			K(0.32, {-11, 22, 3}, V3(0.02, -0.15, -0.22), "quad", "out"),
			K(0.417, B.torso, B.torsoP, "sine", "inout"),
		},
		["Head"] = {
			K(0.00, A.head),
			K(0.10, {2, 0, 0}, nil, "cubic", "out"),
			K(0.17, {2, 3, 0}, nil, "sine", "inout"),
			K(0.27, {0, -22, 0}, nil, "back", "out", 1.2),
			K(0.34, {0, -22, 0}, nil, "quad", "out"),
			K(0.417, B.head, nil, "sine", "inout"),
		},
		["Right Arm"] = {
			K(0.00, A.rArm, A.rArmP),
			K(0.11, {10, 0, 22}, V3(0, -0.06, 0.06), "cubic", "out"),
			K(0.18, {6, 0, 24}, V3(0, -0.06, 0.08), "sine", "inout"),
			K(0.21, {50, 0, 50}, V3(0.02, 0, -0.08), "quad", "out"),
			K(0.25, aim(22, -0.02), V3(0.03, 0.02, -0.28), "back", "out", 1.3),
			K(0.33, aim(22, -0.02), V3(0.03, 0.02, -0.26), "quad", "out"),
			K(0.417, B.rArm, B.rArmP, "sine", "inout"),
		},
		["Left Arm"] = {
			K(0.00, A.lArm, A.lArmP),
			K(0.12, {30, -4, -18}, V3(0, -0.05, -0.08), "cubic", "out"),
			K(0.19, {32, -4, -18}, V3(0, -0.05, -0.09), "sine", "inout"),
			K(0.28, {-20, 0, -22}, V3(0, -0.05, 0.02), "back", "out", 1.2),
			K(0.417, B.lArm, B.lArmP, "sine", "inout"),
		},
		["Right Leg"] = {
			K(0.00, A.rLeg, A.rLegP),
			K(0.13, {4, 0, 8}, V3(0.05, legY(-0.1, 4), -0.15), "cubic", "out"),
			K(0.20, {3, 0, 8}, V3(0.05, legY(-0.1, 3), -0.13), "sine", "inout"),
			K(0.30, {16, 0, 8}, V3(0.05, legY(-0.15, 16), -0.38), "back", "out", 1.3),
			K(0.417, B.rLeg, B.rLegP, "sine", "inout"),
		},
		["Left Leg"] = {
			K(0.00, A.lLeg, A.lLegP),
			K(0.13, {-6, 8, -8}, V3(-0.05, legY(-0.1, -6), 0.2), "cubic", "out"),
			K(0.20, {-5, 8, -8}, V3(-0.05, legY(-0.1, -5), 0.18), "sine", "inout"),
			K(0.30, {-16, 8, -8}, V3(-0.05, legY(-0.15, -16), 0.32), "back", "out", 1.3),
			K(0.417, B.lLeg, B.lLegP, "sine", "inout"),
		},
	}),
	-- hit 2: the pointing hand pulls to a guard while the torso coils the other way, then the left hand chops
	chainClip("DioM1_2", 0.417, {
		["Torso"] = {
			K(0.00, B.torso, B.torsoP),
			K(0.08, {-6, 28, 4}, V3(0.03, -0.1, -0.06), "cubic", "out"),
			K(0.16, {-5, 31, 4}, V3(0.03, -0.1, -0.03), "sine", "inout"),
			K(0.25, {-13, -14, -3}, V3(-0.02, -0.15, -0.24), "back", "out", 1.25),
			K(0.32, {-13, -14, -3}, V3(-0.02, -0.15, -0.22), "quad", "out"),
			K(0.417, C.torso, C.torsoP, "sine", "inout"),
		},
		["Head"] = {
			K(0.00, B.head),
			K(0.10, {0, -26, 0}, nil, "cubic", "out"),
			K(0.17, {0, -29, 0}, nil, "sine", "inout"),
			K(0.27, {2, 14, 0}, nil, "back", "out", 1.2),
			K(0.34, {2, 14, 0}, nil, "quad", "out"),
			K(0.417, C.head, nil, "sine", "inout"),
		},
		["Right Arm"] = {
			K(0.00, B.rArm, B.rArmP),
			K(0.12, {44, 0, 22}, V3(0, -0.02, -0.12), "cubic", "out"),
			K(0.19, {46, 0, 22}, V3(0, -0.02, -0.13), "sine", "inout"),
			K(0.28, {36, 0, 18}, V3(0, -0.02, -0.1), "back", "out", 1.2),
			K(0.417, C.rArm, C.rArmP, "sine", "inout"),
		},
		["Left Arm"] = {
			K(0.00, B.lArm, B.lArmP),
			K(0.11, {-30, 0, -26}, V3(0, -0.06, 0.06), "cubic", "out"),
			K(0.18, {-34, 0, -28}, V3(0, -0.06, 0.08), "sine", "inout"),
			K(0.21, {40, 0, -48}, V3(-0.02, 0, -0.08), "quad", "out"),
			K(0.25, {80, 10, -8}, V3(-0.03, 0.02, -0.28), "back", "out", 1.3),
			K(0.33, {80, 10, -8}, V3(-0.03, 0.02, -0.26), "quad", "out"),
			K(0.417, C.lArm, C.lArmP, "sine", "inout"),
		},
		["Right Leg"] = {
			K(0.00, B.rLeg, B.rLegP),
			K(0.13, {12, 0, 8}, V3(0.05, legY(-0.1, 12), -0.3), "cubic", "out"),
			K(0.20, {11, 0, 8}, V3(0.05, legY(-0.1, 11), -0.28), "sine", "inout"),
			K(0.30, {-4, 0, 8}, V3(0.05, legY(-0.15, -4), 0.08), "back", "out", 1.3),
			K(0.417, C.rLeg, C.rLegP, "sine", "inout"),
		},
		["Left Leg"] = {
			K(0.00, B.lLeg, B.lLegP),
			K(0.13, {-12, 8, -8}, V3(-0.05, legY(-0.1, -12), 0.26), "cubic", "out"),
			K(0.20, {-11, 8, -8}, V3(-0.05, legY(-0.1, -11), 0.24), "sine", "inout"),
			K(0.30, {12, 6, -8}, V3(-0.05, legY(-0.15, 12), -0.18), "back", "out", 1.3),
			K(0.417, C.lLeg, C.lLegP, "sine", "inout"),
		},
	}),
	-- hit 3: the body dips and the fist drops for the load, then the torso rises and leans back while the fist
	-- swings forward and up through an arc to above the head
	chainClip("DioM1_3", 0.417, {
		["Torso"] = {
			K(0.00, C.torso, C.torsoP),
			K(0.08, {-18, -6, -2}, V3(-0.01, -0.24, -0.1), "cubic", "out"),
			K(0.16, {-20, -4, -2}, V3(-0.01, -0.26, -0.08), "sine", "inout"),
			K(0.25, {8, 16, 4}, V3(0, 0.02, 0.06), "back", "out", 1.25),
			K(0.32, {8, 16, 4}, V3(0, 0.02, 0.05), "quad", "out"),
			K(0.417, D.torso, D.torsoP, "sine", "inout"),
		},
		["Head"] = {
			K(0.00, C.head),
			K(0.10, {-6, 8, 0}, nil, "cubic", "out"),
			K(0.17, {-8, 6, 0}, nil, "sine", "inout"),
			K(0.27, {16, -14, 0}, nil, "back", "out", 1.2),
			K(0.34, {16, -14, 0}, nil, "quad", "out"),
			K(0.417, D.head, nil, "sine", "inout"),
		},
		["Right Arm"] = {
			K(0.00, C.rArm, C.rArmP),
			K(0.11, {8, 0, 26}, V3(0.02, -0.1, 0.06), "cubic", "out"),
			K(0.18, {4, 0, 28}, V3(0.02, -0.1, 0.08), "sine", "inout"),
			K(0.21, {108, 0, 14}, V3(0.04, 0.02, -0.16), "quad", "out"),
			K(0.25, {150, -10, -8}, V3(0.05, 0.1, -0.1), "back", "out", 1.3),
			K(0.33, {150, -10, -8}, V3(0.05, 0.1, -0.1), "quad", "out"),
			K(0.417, D.rArm, D.rArmP, "sine", "inout"),
		},
		["Left Arm"] = {
			K(0.00, C.lArm, C.lArmP),
			K(0.12, {60, 6, -14}, V3(-0.02, 0, -0.14), "cubic", "out"),
			K(0.19, {58, 6, -14}, V3(-0.02, 0, -0.13), "sine", "inout"),
			K(0.28, {-30, 0, -26}, V3(0, -0.05, 0.02), "back", "out", 1.2),
			K(0.417, D.lArm, D.lArmP, "sine", "inout"),
		},
		["Right Leg"] = {
			K(0.00, C.rLeg, C.rLegP),
			K(0.13, {-2, 0, 10}, V3(0.05, legY(-0.24, -2), 0.06), "cubic", "out"),
			K(0.20, {-2, 0, 10}, V3(0.05, legY(-0.26, -2), 0.06), "sine", "inout"),
			K(0.30, {6, 0, 8}, V3(0.05, legY(0.02, 6), -0.15), "back", "out", 1.3),
			K(0.417, D.rLeg, D.rLegP, "sine", "inout"),
		},
		["Left Leg"] = {
			K(0.00, C.lLeg, C.lLegP),
			K(0.13, {8, 6, -10}, V3(-0.05, legY(-0.24, 8), -0.1), "cubic", "out"),
			K(0.20, {8, 6, -10}, V3(-0.05, legY(-0.26, 8), -0.1), "sine", "inout"),
			K(0.30, {-8, 6, -8}, V3(-0.05, legY(0.02, -8), 0.2), "back", "out", 1.3),
			K(0.417, D.lLeg, D.lLegP, "sine", "inout"),
		},
	}),
	-- hit 4: no load, the previous pose is the load; the torso leans back and turns while the raised fist
	-- sweeps down and out to the side in six frames, then the pose drifts
	chainClip("DioM1_4", 0.333, {
		["Torso"] = {
			K(0.00, D.torso, D.torsoP),
			K(0.10, {16, -16, -6}, V3(0, -0.06, 0.15), "back", "out", 1.25),
			K(0.17, {16, -16, -6}, V3(0, -0.06, 0.15), "quad", "out"),
			K(0.25, {15, -15, -6}, V3(0, -0.06, 0.15), "sine", "inout"),
			K(0.333, E.torso, E.torsoP, "sine", "inout"),
		},
		["Head"] = {
			K(0.00, D.head),
			K(0.12, {13, 12, -4}, nil, "back", "out", 1.2),
			K(0.19, {13, 12, -4}, nil, "quad", "out"),
			K(0.333, E.head, nil, "sine", "inout"),
		},
		["Right Arm"] = {
			K(0.00, D.rArm, D.rArmP),
			K(0.05, {110, 0, 60}, V3(0.05, 0.04, -0.08), "quad", "out"),
			K(0.10, {38, 0, 94}, V3(0.05, 0, -0.05), "back", "out", 1.3),
			K(0.18, {38, 0, 94}, V3(0.05, 0, -0.05), "quad", "out"),
			K(0.25, {38, 0, 93}, V3(0.05, 0, -0.05), "sine", "inout"),
			K(0.333, E.rArm, E.rArmP, "sine", "inout"),
		},
		["Left Arm"] = {
			K(0.00, D.lArm, D.lArmP),
			K(0.13, {32, 0, -18}, V3(0, -0.04, -0.06), "back", "out", 1.2),
			K(0.20, {32, 0, -18}, V3(0, -0.04, -0.06), "quad", "out"),
			K(0.333, E.lArm, E.lArmP, "sine", "inout"),
		},
		["Right Leg"] = {
			K(0.00, D.rLeg, D.rLegP),
			K(0.14, {18, 0, 8}, V3(0.05, legY(-0.06, 18), -0.38), "back", "out", 1.3),
			K(0.21, {18, 0, 8}, V3(0.05, legY(-0.06, 18), -0.38), "quad", "out"),
			K(0.333, E.rLeg, E.rLegP, "sine", "inout"),
		},
		["Left Leg"] = {
			K(0.00, D.lLeg, D.lLegP),
			K(0.14, {-18, 10, -10}, V3(-0.06, legY(-0.06, -18), 0.38), "back", "out", 1.3),
			K(0.21, {-18, 10, -10}, V3(-0.06, legY(-0.06, -18), 0.38), "quad", "out"),
			K(0.333, E.lLeg, E.lLegP, "sine", "inout"),
		},
	}),
	-- hit 5: the lunge point on the stab in six frames with the fist first through the arc and the chin down on
	-- the target, a breathing hold, then the recovery into the stance the walk takes over
	chainClip("DioM1_5", 0.333, {
		["Torso"] = {
			K(0.00, E.torso, E.torsoP),
			K(0.10, LUNGE.torso, LUNGE.torsoP, "back", "out", 1.25),
			K(0.17, LUNGE.torso, LUNGE.torsoP + V3(0, 0.02, 0), "quad", "out"),
			K(0.25, {-17, 23, 5}, V3(0.03, -0.23, -0.53), "sine", "inout"),
			K(0.333, STANCE.torso, STANCE.torsoP, "sine", "inout"),
		},
		["Head"] = {
			K(0.00, E.head),
			K(0.12, LUNGE.head, nil, "back", "out", 1.2),
			K(0.19, LUNGE.head, nil, "quad", "out"),
			K(0.25, {-5, -23, 2}, nil, "sine", "inout"),
			K(0.333, STANCE.head, nil, "sine", "inout"),
		},
		["Right Arm"] = {
			K(0.00, E.rArm, E.rArmP),
			K(0.05, {70, 0, 50}, V3(0.04, 0.02, -0.15), "quad", "out"),
			K(0.10, LUNGE.rArm, LUNGE.rArmP, "back", "out", 1.3),
			K(0.18, LUNGE.rArm, LUNGE.rArmP + V3(0, 0, 0.02), "quad", "out"),
			K(0.25, aim(23, -0.12), V3(0.04, 0.02, -0.38), "sine", "inout"),
			K(0.333, STANCE.rArm, STANCE.rArmP, "sine", "inout"),
		},
		["Left Arm"] = {
			K(0.00, E.lArm, E.lArmP),
			K(0.13, LUNGE.lArm, LUNGE.lArmP, "back", "out", 1.2),
			K(0.20, LUNGE.lArm, LUNGE.lArmP, "quad", "out"),
			K(0.25, {-38, 6, -28}, V3(0, -0.05, 0.05), "sine", "inout"),
			K(0.333, STANCE.lArm, STANCE.lArmP, "sine", "inout"),
		},
		["Right Leg"] = {
			K(0.00, E.rLeg, E.rLegP),
			K(0.14, LUNGE.rLeg, LUNGE.rLegP, "back", "out", 1.3),
			K(0.21, LUNGE.rLeg, LUNGE.rLegP, "quad", "out"),
			K(0.25, {27, 0, 8}, V3(0.06, legY(-0.23, 27), -0.54), "sine", "inout"),
			K(0.333, STANCE.rLeg, STANCE.rLegP, "sine", "inout"),
		},
		["Left Leg"] = {
			K(0.00, E.lLeg, E.lLegP),
			K(0.14, LUNGE.lLeg, LUNGE.lLegP, "back", "out", 1.3),
			K(0.21, LUNGE.lLeg, LUNGE.lLegP, "quad", "out"),
			K(0.25, {-31, 10, -10}, V3(-0.06, legY(-0.23, -31), 0.49), "sine", "inout"),
			K(0.333, STANCE.lLeg, STANCE.lLegP, "sine", "inout"),
		},
	}),
}

-- the chain clips are reachable by name too so the pose hold hook can freeze any hit
for _, c in ipairs(Clips.DioM1) do
	Clips[c.name] = c
end

-- the time stop on dio, keyed to the voice line; silhouettes: STANCE -> a dip (anticipation) -> ZA WARUDO (the
-- right hand overhead through an up and out arc with the block dropped so it reads bent, the left arm flung
-- out and back, chest out, head thrown back, weight on the rear foot) held with the raised hand trembling
-- through the pause -> COIL inward on the command while the head comes down -> the fist whips down and forward
-- into the point with a 0.6 stud lunge on the last syllable, the head a frame behind, the free arm and the legs
-- after -> the point holds breathing to the end
local TS = Config.TimeStop.Beats
local ZA = {
	torso = {16, -10, -4}, torsoP = V3(0, -0.08, 0.25),
	head = {24, 8, -4},
	rArm = {160, 0, 16}, rArmP = V3(-0.35, 0.15, -0.15),
	lArm = {-20, 0, -110}, lArmP = V3(-0.1, 0.1, 0.05),
	rLeg = {18, -4, 10}, rLegP = V3(0.05, legY(-0.08, 18), -0.35),
	lLeg = {-20, 10, -10}, lLegP = V3(-0.06, legY(-0.08, -20), 0.4),
}
local COIL = {
	torso = {6, 14, 0}, torsoP = V3(0.01, -0.18, 0.12),
	head = {6, -6, 0},
	rArm = {150, -10, 30}, rArmP = V3(-0.3, 0.05, 0.1),
	lArm = {30, 0, -50}, lArmP = V3(0, -0.2, -0.1),
	rLeg = {12, -4, 10}, rLegP = V3(0.05, legY(-0.18, 12), -0.3),
	lLeg = {-16, 10, -10}, lLegP = V3(-0.06, legY(-0.18, -16), 0.35),
}
local SNAP = {
	torso = {-14, -4, 4}, torsoP = V3(0.02, -0.24, -0.6),
	head = {-12, 6, 3},
	rArm = aim(-4, -0.05), rArmP = V3(0.05, 0.02, -0.4),
	lArm = {-38, 8, -28}, lArmP = V3(0, -0.05, 0.05),
	rLeg = {26, 0, 8}, rLegP = V3(0.06, legY(-0.24, 26), -0.5),
	lLeg = {-30, 10, -10}, lLegP = V3(-0.06, legY(-0.24, -30), 0.5),
}
Clips.DioTimeStop = {
	name = "DioTimeStop",
	length = TS.done,
	joints = {
		["Torso"] = {
			K(0.00, STANCE.torso, STANCE.torsoP),
			K(0.06, {-4, 2, 0}, V3(0.01, -0.14, 0.02), "cubic", "out"),
			K(0.18, ZA.torso, ZA.torsoP, "back", "out", 1.25),
			K(0.60, {17.5, -10, -4}, V3(0, -0.09, 0.26), "sine", "inout"),
			K(1.10, {15, -11, -4}, V3(0, -0.07, 0.24), "sine", "inout"),
			K(1.35, {16, -10, -4}, ZA.torsoP, "sine", "inout"),
			K(2.10, COIL.torso, COIL.torsoP, "sine", "inout"),
			K(2.45, {4, 26, -2}, V3(0.02, -0.2, 0.16), "sine", "in"),
			K(2.50, SNAP.torso, SNAP.torsoP, "back", "out", 1.25),
			K(2.58, SNAP.torso, SNAP.torsoP + V3(0, 0.02, 0), "quad", "out"),
			K(2.85, {-15, -4, 4}, V3(0.02, -0.25, -0.58), "sine", "inout"),
			K(3.10, SNAP.torso, SNAP.torsoP, "sine", "inout"),
		},
		["Head"] = {
			K(0.00, STANCE.head),
			K(0.08, {-4, 0, 0}, nil, "cubic", "out"),
			K(0.21, ZA.head, nil, "back", "out", 1.2),
			K(0.60, {26, 8, -4}, nil, "sine", "inout"),
			K(1.10, {22, 9, -4}, nil, "sine", "inout"),
			K(1.35, ZA.head, nil, "sine", "inout"),
			K(2.10, COIL.head, nil, "sine", "inout"),
			K(2.45, {2, -12, 0}, nil, "sine", "in"),
			K(2.52, SNAP.head, nil, "back", "out", 1.2),
			K(2.60, SNAP.head, nil, "quad", "out"),
			K(2.85, {-13, 6, 3}, nil, "sine", "inout"),
			K(3.10, SNAP.head, nil, "sine", "inout"),
		},
		["Right Arm"] = {
			K(0.00, STANCE.rArm, STANCE.rArmP),
			K(0.09, {50, 0, 30}, V3(0, -0.02, -0.06), "cubic", "out"),
			K(0.14, {100, 0, 60}, V3(-0.05, 0.05, -0.12), "quad", "out"),
			K(0.22, ZA.rArm, ZA.rArmP, "back", "out", 1.4),
			K(0.45, {158, 0, 17}, V3(-0.35, 0.14, -0.15), "sine", "inout"),
			K(0.60, {161, 0, 15}, V3(-0.35, 0.16, -0.15), "sine", "inout"),
			K(0.75, {159, 0, 17}, V3(-0.35, 0.14, -0.15), "sine", "inout"),
			K(0.90, {162, 0, 15}, V3(-0.35, 0.16, -0.15), "sine", "inout"),
			K(1.05, {159, 0, 16}, V3(-0.35, 0.15, -0.15), "sine", "inout"),
			K(1.20, {161, 0, 16}, V3(-0.35, 0.16, -0.15), "sine", "inout"),
			K(1.35, ZA.rArm, ZA.rArmP, "sine", "inout"),
			K(2.10, COIL.rArm, COIL.rArmP, "sine", "inout"),
			K(2.45, {156, -10, 36}, V3(-0.34, 0.02, 0.14), "sine", "in"),
			K(2.47, {120, 0, -14}, V3(-0.05, 0.1, -0.2), "quad", "out"),
			K(2.50, SNAP.rArm, SNAP.rArmP, "back", "out", 1.3),
			K(2.58, SNAP.rArm, SNAP.rArmP + V3(0, 0, 0.02), "quad", "out"),
			K(2.85, aim(-4, -0.06), V3(0.05, 0.02, -0.42), "sine", "inout"),
			K(3.10, SNAP.rArm, SNAP.rArmP, "sine", "inout"),
		},
		["Left Arm"] = {
			K(0.00, STANCE.lArm, STANCE.lArmP),
			K(0.10, {20, 0, -40}, V3(-0.02, 0, -0.05), "cubic", "out"),
			K(0.16, {30, 0, -70}, V3(-0.05, 0.05, -0.05), "quad", "out"),
			K(0.24, ZA.lArm, ZA.lArmP, "back", "out", 1.4),
			K(0.60, {-22, 0, -112}, V3(-0.1, 0.11, 0.05), "sine", "inout"),
			K(1.10, {-18, 0, -108}, V3(-0.1, 0.09, 0.05), "sine", "inout"),
			K(1.35, ZA.lArm, ZA.lArmP, "sine", "inout"),
			K(2.10, COIL.lArm, COIL.lArmP, "sine", "inout"),
			K(2.45, {36, 0, -56}, V3(0, -0.22, -0.12), "sine", "in"),
			K(2.53, SNAP.lArm, SNAP.lArmP, "back", "out", 1.2),
			K(2.61, SNAP.lArm, SNAP.lArmP, "quad", "out"),
			K(2.85, {-40, 8, -29}, V3(0, -0.05, 0.06), "sine", "inout"),
			K(3.10, SNAP.lArm, SNAP.lArmP, "sine", "inout"),
		},
		["Right Leg"] = {
			K(0.00, STANCE.rLeg, STANCE.rLegP),
			K(0.11, {4, 0, 8}, V3(0.04, legY(-0.14, 4), -0.12), "cubic", "out"),
			K(0.25, ZA.rLeg, ZA.rLegP, "back", "out", 1.3),
			K(1.35, {19, -4, 10}, V3(0.05, legY(-0.08, 19), -0.36), "sine", "inout"),
			K(2.10, COIL.rLeg, COIL.rLegP, "sine", "inout"),
			K(2.45, {8, -4, 10}, V3(0.05, legY(-0.2, 8), -0.22), "sine", "in"),
			K(2.55, SNAP.rLeg, SNAP.rLegP, "back", "out", 1.3),
			K(2.63, SNAP.rLeg, SNAP.rLegP, "quad", "out"),
			K(2.85, {25, 0, 8}, V3(0.06, legY(-0.25, 25), -0.49), "sine", "inout"),
			K(3.10, SNAP.rLeg, SNAP.rLegP, "sine", "inout"),
		},
		["Left Leg"] = {
			K(0.00, STANCE.lLeg, STANCE.lLegP),
			K(0.11, {-4, 4, -8}, V3(-0.04, legY(-0.14, -4), 0.12), "cubic", "out"),
			K(0.25, ZA.lLeg, ZA.lLegP, "back", "out", 1.3),
			K(1.35, {-21, 10, -10}, V3(-0.06, legY(-0.08, -21), 0.41), "sine", "inout"),
			K(2.10, COIL.lLeg, COIL.lLegP, "sine", "inout"),
			K(2.45, {-12, 10, -10}, V3(-0.06, legY(-0.2, -12), 0.28), "sine", "in"),
			K(2.55, SNAP.lLeg, SNAP.lLegP, "back", "out", 1.3),
			K(2.63, SNAP.lLeg, SNAP.lLegP, "quad", "out"),
			K(2.85, {-29, 10, -10}, V3(-0.06, legY(-0.25, -29), 0.49), "sine", "inout"),
			K(3.10, SNAP.lLeg, SNAP.lLegP, "sine", "inout"),
		},
	},
}

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

return Clips
