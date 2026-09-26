local Dragon = {}

local FINGERS = {
	fingerA = 3, fingerB = 3, fingerC = 3, fingerD = 4, fingerE = 4, fingerF = 4, fingerG = 3,
}
local FLAPS = {wingFlapA = 4, wingFlapB = 4, wingFlapC = 2, wingFlapD = 1}
local SIDE = {"clavicle", "shoulder", "shoulderTwist", "forearm", "hand", "handMid", "hipClav", "hip", "knee", "ankle", "ball"}

local function expand(pose)
	local out = {}
	local function put(name, v)
		out[name] = {v[1] or 0, v[2] or 0, v[3] or 0}
	end
	local function pair(base, v)
		put("l_" .. base, v)
		put("r_" .. base, {-(v[1] or 0), -(v[2] or 0), v[3] or 0})
	end
	for key, v in pairs(pose) do
		if key == "neck" or key == "spine" or key == "tail" then
			local count = key == "neck" and 11 or key == "spine" and 8 or 30
			for i = 1, count do
				put(string.format("%s_%02d", key, i), type(v) == "function" and v(i, count) or v)
			end
		elseif key == "fingers" then
			for f, n in pairs(FINGERS) do
				for i = 1, n do
					pair(string.format("%s_%02d", f, i), v)
				end
			end
		elseif key == "flaps" then
			for f, n in pairs(FLAPS) do
				for i = 1, n do
					pair(string.format("%s_%02d", f, i), v)
				end
			end
		elseif key:sub(1, 1) == "_" then
			put(key:sub(2), v)
		else
			pair(key, v)
		end
	end
	return out
end

local function merge(a, b)
	local out = {}
	for k, v in pairs(a) do
		out[k] = v
	end
	for k, v in pairs(b) do
		out[k] = v
	end
	return out
end

local function lagOf(name)
	local i = tonumber(name:match("_(%d+)$"))
	if name:match("^neck_") then
		return 0.018 * i
	elseif name:match("^tail_") then
		return 0.016 * i
	elseif name:match("forearm$") then
		return 0.04
	elseif name:match("hand$") or name:match("handMid$") then
		return 0.08
	elseif name:match("finger") then
		return 0.1 + 0.02 * (i or 0)
	elseif name:match("wingFlap") then
		return 0.12
	elseif name == "head" then
		return 0.22
	elseif name:match("^jaw") then
		return 0.05
	end
	return nil
end

local function clip(name, length, loop, beats, extra)
	local joints, all = {}, {}
	local expanded = {}
	for i, b in ipairs(beats) do
		expanded[i] = expand(b[2])
		for n in pairs(expanded[i]) do
			all[n] = true
		end
	end
	for n in pairs(all) do
		local keys = {}
		for i, b in ipairs(beats) do
			local r = expanded[i][n] or {0, 0, 0}
			table.insert(keys, {t = b[1], r = r, e = b[3]})
		end
		joints[n] = keys
	end
	local lag = {}
	for n in pairs(all) do
		lag[n] = lagOf(n)
	end
	local c = {name = name, length = length, loop = loop, curve = "spline", joints = joints, lag = lag, life = {spine_04 = 0.6, neck_06 = 0.8, head = 1.2, tail_10 = 1, tail_20 = 1.4}, lifeRate = 0.4}
	for k, v in pairs(extra or {}) do
		c[k] = v
	end
	return c
end

local P = {}

P.stand = {
	_root = {2, 0, 0},
	clavicle = {10, 0, 0},
	shoulder = {45, 0, -40},
	forearm = {0, 0, 130},
	hand = {0, 0, -140},
	fingers = {0, 0, -6},
	hip = {45, 0, 6},
	knee = {-20, 0, 0},
	ankle = {15, 0, 0},
	neck = function(i)
		return i <= 4 and {-6, 0, 0} or i <= 8 and {-2, 0, 0} or {6, 0, 0}
	end,
	head = {10, 0, 0},
	_jaw_01 = {0, 0, 0},
	spine = {0.5, 0, 0},
	tail = {1.0, 0, 0.6},
}

P.breath = merge(P.stand, {
	spine = {-0.7, 0, 0},
	neck = function(i)
		return i <= 4 and {-6.5, 0, 0.6} or i <= 8 and {-2, 0, 0.8} or {5.5, 0, 0.8}
	end,
	head = {8, 0, 4},
	tail = {0.9, 0, 1.1},
	shoulder = {43, 0, -38},
})

P.flyUp = {
	_root = {0, 0, 0},
	clavicle = {-8, 0, 0},
	shoulder = {-35, 0, -8},
	forearm = {-12, 0, 10},
	hand = {-8, 0, -15},
	fingers = {-4, 0, -5},
	hip = {70, 0, 0},
	knee = {-30, 0, 0},
	ankle = {40, 0, 0},
	neck = {-0.5, 0, 0},
	head = {4, 0, 0},
	tail = {-0.3, 0, 0},
}

P.flyDown = merge(P.flyUp, {
	clavicle = {8, 0, 0},
	shoulder = {30, 0, 6},
	forearm = {12, 0, -4},
	hand = {10, 0, 4},
	fingers = {6, 0, 2},
	neck = {0.5, 0, 0},
	head = {-3, 0, 0},
	tail = {0.3, 0, 0},
})

P.flare = {
	_root = {28, 0, 0},
	clavicle = {-10, 0, 0},
	shoulder = {-25, 0, 25},
	forearm = {-5, 0, -10},
	hand = {-5, 0, 10},
	fingers = {-3, 0, 4},
	hip = {-5, 0, 6},
	knee = {0, 0, 0},
	ankle = {25, 0, 0},
	neck = {-2.5, 0, 0},
	head = {12, 0, 0},
	tail = {2.2, 0, 0},
}

P.brake = merge(P.flare, {
	shoulder = {35, 0, 20},
	forearm = {10, 0, -5},
	hand = {12, 0, 5},
	fingers = {5, 0, 2},
	clavicle = {8, 0, 0},
})

P.touch = {
	_root = {-6, 0, 0},
	clavicle = {6, 0, 0},
	shoulder = {20, 0, 5},
	forearm = {5, 0, 40},
	hand = {0, 0, -40},
	fingers = {2, 0, -3},
	hip = {60, 0, 6},
	knee = {-45, 0, 0},
	ankle = {40, 0, 0},
	neck = {3, 0, 0},
	head = {-5, 0, 0},
	spine = {1.5, 0, 0},
	tail = {2.5, 0, 0},
}

P.absorb = merge(P.touch, {
	_root = {-8, 0, 0},
	knee = {-55, 0, 0},
	neck = {3.5, 0, 0},
	head = {-8, 0, 0},
	tail = {2.8, 0, 0.4},
	shoulder = {35, 0, -15},
	forearm = {0, 0, 90},
	hand = {0, 0, -100},
})

P.coil = merge(P.stand, {
	_root = {10, 0, 0},
	neck = {-4.5, 0, 0},
	head = {-25, 0, 0},
	spine = {-1, 0, 0},
	shoulder = {20, 0, -20},
	forearm = {0, 0, 70},
	hand = {0, 0, -70},
	tail = {0.4, 0, 0.6},
	hip = {40, 0, 6},
	knee = {-30, 0, 0},
})

P.roar = merge(P.stand, {
	_root = {6, 0, 0},
	neck = function(i)
		return i <= 5 and {-3, 0, 0} or {3, 0, 0}
	end,
	head = {15, 0, 0},
	_jaw_01 = {45, 0, 0},
	clavicle = {-12, 0, 0},
	shoulder = {-30, 0, 10},
	forearm = {-5, 0, 5},
	hand = {-5, 0, -5},
	fingers = {-3, 0, 2},
	spine = {-0.5, 0, 0},
	tail = {-0.8, 0, 0.8},
	hip = {45, 0, 10},
	knee = {-25, 0, 0},
	ankle = {18, 0, 0},
})

P.roarHold = merge(P.roar, {
	neck = function(i)
		return i <= 5 and {-3.2, 0, 0.5} or {3.3, 0, 0.6}
	end,
	head = {18, 0, -3},
	_jaw_01 = {50, 0, 0},
	shoulder = {-26, 0, 12},
	tail = {-0.6, 0, 1.2},
})

P.hit = {
	_root = {14, 0, -8},
	neck = {-5, 0, 2.5},
	head = {-20, 0, 10},
	_jaw_01 = {30, 0, 0},
	clavicle = {-10, 0, 0},
	shoulder = {-20, 0, 25},
	forearm = {0, 0, 10},
	hand = {10, 0, -10},
	fingers = {4, 0, 0},
	spine = {-1.5, 0, 0.5},
	tail = {-1.2, 0, -1.5},
	hip = {20, 0, 6},
	knee = {-50, 0, 0},
	ankle = {30, 0, 0},
}

P.stagger = merge(P.hit, {
	_root = {6, 0, 6},
	neck = {-2, 0, -1.5},
	head = {-6, 0, -6},
	_jaw_01 = {18, 0, 0},
	shoulder = {10, 0, 10},
	forearm = {0, 0, 40},
	hand = {0, 0, -40},
	tail = {0.5, 0, 1.5},
	hip = {50, 0, 6},
	knee = {-35, 0, 0},
})

P.down = {
	_root = {-8, 0, 35},
	neck = {5, 0, 1},
	head = {20, 0, 0},
	_jaw_01 = {15, 0, 0},
	clavicle = {6, 0, 0},
	shoulder = {35, 0, 20},
	forearm = {0, 0, 60},
	hand = {0, 0, -30},
	fingers = {5, 0, 0},
	spine = {1, 0, 0},
	tail = {0.8, 0, 1.2},
	hip = {85, 0, 15},
	knee = {-70, 0, 0},
	ankle = {50, 0, 0},
}

P.rest = merge(P.down, {
	neck = {5.5, 0, 1.4},
	head = {24, 0, 3},
	_jaw_01 = {10, 0, 0},
	tail = {1, 0, 1.6},
	shoulder = {38, 0, 24},
})

Dragon.poses = P
Dragon.expand = expand

Dragon.Fly = clip("DragonFly", 1.2, true, {{0, P.flyUp}, {0.45, P.flyDown}, {1.2, P.flyUp}})

Dragon.Land = clip("DragonLand", 2.6, false, {
	{0, P.flyUp},
	{0.35, P.flare},
	{0.62, P.brake},
	{0.92, P.flare},
	{1.18, P.brake},
	{1.4, P.touch, "flat"},
	{1.65, P.absorb},
	{2.1, merge(P.stand, {knee = {-28, 0, 0}, _root = {0, 0, 0}})},
	{2.6, P.stand},
}, {events = {touch = 1.4}})

Dragon.Idle = clip("DragonIdle", 3.2, true, {{0, P.stand}, {1.6, P.breath}, {3.2, P.stand}})

Dragon.Roar = clip("DragonRoar", 2.6, false, {
	{0, P.stand},
	{0.5, P.coil},
	{0.72, P.roar},
	{1.9, P.roarHold},
	{2.6, P.stand},
}, {events = {roar = 0.72}, life = {spine_04 = 1, neck_06 = 1.4, head = 2.2, tail_10 = 1.5, tail_20 = 2, l_shoulder = 1.5, r_shoulder = 1.5}, lifeRate = 1.6})

Dragon.Hit = clip("DragonHit", 1.1, false, {
	{0, P.stand},
	{0.08, P.hit},
	{0.45, P.stagger},
	{1.1, merge(P.stagger, {knee = {-50, 0, 0}, _root = {2, 0, 10}})},
})

Dragon.Down = clip("DragonDown", 1.8, false, {
	{0, merge(P.stagger, {knee = {-50, 0, 0}, _root = {2, 0, 10}})},
	{0.8, P.down},
	{1.8, P.rest},
}, {events = {crash = 0.8}})

return Dragon
