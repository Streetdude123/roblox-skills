local Dragon = {}

local FINGERS = {
	fingerA = 3, fingerB = 3, fingerC = 3, fingerD = 4, fingerE = 4, fingerF = 4, fingerG = 3,
}
local ORDER = {fingerA = -3, fingerB = -2, fingerC = -1, fingerD = 0, fingerE = 1, fingerF = 2, fingerG = 3}
local FLAPS = {wingFlapA = 4, wingFlapB = 4, wingFlapC = 2, wingFlapD = 1}

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
		elseif key == "close" or key == "lift" then
		elseif key:sub(1, 1) == "_" then
			put(key:sub(2), v)
		else
			pair(key, v)
		end
	end
	if pose.close then
		for f, k in pairs(ORDER) do
			for _, s in ipairs({"l_", "r_"}) do
				local n = s .. f .. "_01"
				local v = out[n] or {0, 0, 0}
				out[n] = {v[1], v[2], v[3] + pose.close * k}
			end
		end
	end
	return out
end

local function lagOf(name)
	local i = tonumber(name:match("_(%d+)$"))
	if name:match("^neck_") then
		return 0.015 * i
	elseif name:match("^tail_") then
		return 0.02 * i
	elseif name:match("forearm$") then
		return 0.035
	elseif name:match("hand$") or name:match("handMid$") then
		return 0.07
	elseif name:match("finger") then
		return 0.09 + 0.015 * (i or 0)
	elseif name:match("wingFlap") then
		return 0.12
	elseif name == "head" then
		return 0.05
	elseif name:match("^jaw") then
		return 0.03
	end
	return nil
end

local function clip(name, length, loop, beats, extra)
	local joints, all = {}, {}
	local expanded = {}
	local lifts = false
	for i, b in ipairs(beats) do
		expanded[i] = expand(b[2])
		for n in pairs(expanded[i]) do
			all[n] = true
		end
		lifts = lifts or b[2].lift ~= nil
	end
	if lifts then
		all.root = true
	end
	for n in pairs(all) do
		local keys = {}
		for i, b in ipairs(beats) do
			local r = expanded[i][n] or {0, 0, 0}
			local p = n == "root" and lifts and Vector3.new(0, b[2].lift or 0, 0) or nil
			table.insert(keys, {t = b[1], r = r, p = p, e = b[3]})
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

local function wing(v)
	return {clavicle = {v[1], 0, 0}, shoulder = v[2], forearm = v[3], hand = v[4], fingers = v[5], close = v[6]}
end

local W = {
	fold = wing({21.5, {32, -18.5, -68}, {-14, 10.5, 92.5}, {-14.5, -56, -124}, {0, 0, 0}, 37.5}),
	loose = wing({14, {24, -12, -52}, {-8, 6, 78}, {-6, -40, -104}, {2, 0, 0}, 30}),
	half = wing({8, {14, -6, -26}, {-2, 2, 52}, {0, -20, -64}, {3, 0, 0}, 18}),
	threat = wing({-28, {-5, -2, 1}, {12.5, -42, 3.5}, {24.5, -19.5, -52}, {5, 0, 0}, 15}),
	up = wing({-4, {-40, 0, 6}, {-8, 0, 8}, {-6, 0, 0}, {-3, 0, 0}, 0}),
	mid = wing({0, {-5, 0, 16}, {2, 0, 2}, {2, 0, 0}, {2, 0, 0}, 0}),
	down = wing({8, {38, 0, 8}, {-14, 0, 4}, {-12, 0, 0}, {-7, 0, 0}, -3}),
	rec = wing({2, {-12, 0, -18}, {8, 0, 80}, {4, 0, -115}, {3, 0, 0}, 24}),
	flare = wing({-12, {-22, 0, 26}, {16, 0, 6}, {10, 0, 4}, {5, 0, 0}, -4}),
	brake = wing({6, {30, 0, 28}, {-6, 0, 10}, {-8, 0, 0}, {-5, 0, 0}, -4}),
	balance = wing({-20, {-2, -2, 1}, {12, -36, 3}, {20, -16, -46}, {4, 0, 0}, 12}),
	flinch = wing({-6, {-8, 0, 10}, {10, 0, 46}, {0, 0, -46}, {4, 0, 0}, 12}),
	sprawl = wing({-4, {-4, 0, -12}, {20, 0, 14}, {8, 0, -12}, {6, 0, 0}, 2}),
	hoverUp = wing({-10, {-38, 0, 22}, {-6, 0, 8}, {-4, 0, 0}, {-3, 0, 0}, 0}),
	hoverDown = wing({6, {34, 0, 26}, {-10, 0, 8}, {-12, 0, 0}, {-6, 0, 0}, -3}),
}

local function tail(down, flat, side)
	return function(i)
		return i <= 9 and {down, 0, side} or i <= 18 and {flat, 0, side * 1.3} or {0, 0, side * 0.8}
	end
end

local function neck(low, high, yaw)
	return function(i)
		return {i <= 5 and low or high, 0, yaw or 0}
	end
end

local function pose(...)
	local out = {}
	for _, part in ipairs({...}) do
		for k, v in pairs(part) do
			out[k] = v
		end
	end
	return out
end

local P = {}

local GROUND = {_root = {2, 0, 0}, spine = {0.4, 0, 0}, hip = {45, 0, 6}, knee = {-20, 0, 0}, ankle = {15, 0, 0}}

P.stand = pose(GROUND, W.fold, {neck = neck(-4, 2.5), head = {6, 0, 0}, _jaw_01 = {2, 0, 0}, tail = tail(0.55, -0.35, 0.8), lift = 0})
P.breath = pose(P.stand, {spine = {-0.35, 0, 0}, clavicle = {19.5, 0, 0}, neck = neck(-4.6, 2.3, 0.35), head = {5, 0, 3}, tail = tail(0.5, -0.35, 1.2), lift = 0.12})
P.look = pose(P.stand, {neck = neck(-4.2, 2.6, -0.45), head = {7, 0, -4}, tail = tail(0.5, -0.35, 0.4)})
P.lookBack = pose(P.stand, {neck = neck(-4.3, 2.4, 0.5), head = {5, 0, 4}, tail = tail(0.55, -0.35, 1.1), lift = 0.05})

P.coil = pose(GROUND, W.loose, {_root = {-2, 0, 0}, spine = {0.8, 0, 0}, hip = {50, 0, 6}, knee = {-32, 0, 0}, ankle = {20, 0, 0}, neck = neck(-2, 4.2), head = {14, 0, 0}, _jaw_01 = {6, 0, 0}, tail = tail(0.95, -0.35, 1.6), lift = -0.5})
P.roar = pose(GROUND, W.threat, {_root = {8, 0, 0}, spine = {-1.2, 0, 0}, hip = {36, 0, 8}, knee = {-22, 0, 0}, ankle = {18, 0, 0}, neck = neck(-6, 2.5), head = {4, 0, 0}, _jaw_01 = {52, 0, 0}, tail = tail(-0.25, -0.35, -1.2), lift = 0.5})
local function shake(yaw, jaw)
	return pose(P.roar, {neck = neck(-6, 2.5, yaw), head = {4, 0, yaw * 7}, _jaw_01 = {jaw, 0, 0}})
end
P.roarHold = pose(P.roar, W.threat, {shoulder = {0, -2, 1}, neck = neck(-5.6, 2.7), head = {6, 0, -2}, _jaw_01 = {44, 0, 0}, tail = tail(-0.3, -0.35, 0.6), lift = 0.35})

P.hit = pose(GROUND, W.flinch, {_root = {12, 0, -8}, spine = {-1.2, 0, 0.6}, hip = {30, 0, 6}, knee = {-48, 0, 0}, ankle = {30, 0, 0}, neck = neck(-3, -2, 2), head = {-18, 0, 12}, _jaw_01 = {32, 0, 0}, tail = tail(-0.85, -0.35, -1.4), lift = 0.3})
P.stagger = pose(GROUND, W.half, {_root = {4, 0, 5}, spine = {0.6, 0, -0.3}, hip = {52, 0, 6}, knee = {-38, 0, 0}, ankle = {26, 0, 0}, neck = neck(0.5, 2.5, -1), head = {6, 0, -8}, _jaw_01 = {16, 0, 0}, tail = tail(0.15, -0.35, 1.5), lift = -0.4})
P.reel = pose(P.stagger, {_root = {0, 0, 9}, neck = neck(1.5, 3.4, -0.8), head = {10, 0, -6}, _jaw_01 = {12, 0, 0}, knee = {-48, 0, 0}, hip = {56, 0, 6}, tail = tail(0.5, -0.35, 1.8), lift = -0.6})

P.buckle = pose(GROUND, W.sprawl, {_root = {-4, 0, 6}, spine = {0.8, 0, 0.4}, hip = {70, 0, 10}, knee = {-75, 0, 0}, ankle = {40, 0, 0}, neck = neck(-1, 1, 1), head = {-4, 0, 0}, _jaw_01 = {20, 0, 0}, tail = tail(0.4, -0.3, 1), lift = -0.3})
P.down = pose(P.buckle, {_root = {-6, 0, 10}, hip = {85, 0, 15}, knee = {-80, 0, 0}, ankle = {50, 0, 0}, neck = neck(1, 2.5, 1), head = {6, 0, 0}, tail = tail(0.4, -0.3, 1.2), lift = -0.6})
P.slump = pose(P.down, {neck = neck(5, 6, 1.5), head = {22, 0, 2}, _jaw_01 = {18, 0, 0}})
P.rest = pose(P.down, {neck = neck(5.5, 5.5, 1.8), head = {24, 0, 3}, _jaw_01 = {10, 0, 0}, tail = tail(0.4, -0.3, 1.6)})

local FLY = {spine = {0, 0, 0}, hip = {70, 0, 0}, knee = {-30, 0, 0}, ankle = {40, 0, 0}, head = {4, 0, 0}, _jaw_01 = {0, 0, 0}}
P.flyUp = pose(FLY, W.up, {_root = {2, 0, 0}, neck = neck(-0.2, -0.2), tail = tail(0.25, 0.25, 0), lift = -0.5})
P.flyMid = pose(FLY, W.mid, {_root = {-1, 0, 0}, neck = neck(-0.4, -0.4), tail = tail(0, 0, 0), lift = 0.2})
P.flyDown = pose(FLY, W.down, {_root = {-3, 0, 0}, neck = neck(-0.6, -0.5), tail = tail(-0.3, -0.3, 0), lift = 0.6})
P.flyRec = pose(FLY, W.rec, {_root = {1, 0, 0}, neck = neck(-0.3, -0.3), tail = tail(0.15, 0.15, 0), lift = 0.3})

local LEGS = {hip = {30, 0, 6}, knee = {-42, 0, 0}, ankle = {38, 0, 0}}
P.flare = pose(W.flare, {_root = {30, 0, 0}, spine = {-0.5, 0, 0}, hip = {-5, 0, 6}, knee = {-10, 0, 0}, ankle = {25, 0, 0}, neck = neck(-1, -1), head = {15, 0, 0}, _jaw_01 = {4, 0, 0}, tail = tail(1.2, 1.2, 0), lift = 0})
P.brake = pose(P.flare, W.brake, {_root = {26, 0, 0}, tail = tail(1.6, 1.4, 0), lift = 0.4})
P.reach = pose(P.flare, {_root = {22, 0, 0}, hip = {10, 0, 6}, knee = {-15, 0, 0}, ankle = {30, 0, 0}, tail = tail(1.4, 1, 0), lift = 0.1})
P.touch = pose(GROUND, W.balance, {_root = {-4, 0, 0}, spine = {1.2, 0, 0}, hip = {60, 0, 6}, knee = {-45, 0, 0}, ankle = {40, 0, 0}, neck = neck(2, 3), head = {-4, 0, 0}, _jaw_01 = {6, 0, 0}, tail = tail(1.3, -0.35, 0.4), lift = 0})
P.absorb = pose(P.touch, {_root = {-7, 0, 0}, hip = {62, 0, 6}, knee = {-58, 0, 0}, neck = neck(2.8, 3.6), head = {-8, 0, 0}, tail = tail(1.5, -0.35, 0.6), lift = -1.1})
P.rise = pose(GROUND, W.half, {_root = {1, 0, 0}, hip = {48, 0, 6}, knee = {-28, 0, 0}, neck = neck(-3.5, 2), head = {8, 0, 0}, _jaw_01 = {2, 0, 0}, tail = tail(0.6, -0.35, 0.7), lift = -0.2})

P.hover = pose(LEGS, W.hoverUp, {_root = {24, 0, 0}, spine = {-0.3, 0, 0}, neck = neck(-1.2, -1), head = {10, 0, 0}, _jaw_01 = {2, 0, 0}, tail = tail(0.4, 0.1, 0), lift = -0.3})
P.hoverDown = pose(P.hover, W.hoverDown, {_root = {20, 0, 0}, neck = neck(-1, -0.8), head = {8, 0, 0}, tail = tail(0.2, 0.05, 0), lift = 0.4})
P.hoverRec = pose(P.hover, W.rec, {_root = {23, 0, 0}, tail = tail(0.3, 0.1, 0), lift = 0.2})
P.airHit = pose(P.hover, W.flinch, {_root = {34, 0, -10}, hip = {60, 0, 10}, knee = {-30, 0, 0}, ankle = {45, 0, 0}, neck = neck(-3, -2, 2), head = {-16, 0, 10}, _jaw_01 = {30, 0, 0}, tail = tail(0.2, 0.2, -1.2), lift = 0.4})
P.airCatch = pose(P.hover, W.flare, {_root = {28, 0, -5}, neck = neck(-1.5, -0.5, 1), head = {2, 0, 6}, _jaw_01 = {14, 0, 0}, lift = 0.1})
P.airCoil = pose(P.hover, W.up, {_root = {22, 0, 0}, neck = neck(1, 3.5), head = {16, 0, 0}, _jaw_01 = {6, 0, 0}, tail = tail(0.5, 0.2, 1), lift = -0.4})
P.airRoar = pose(P.hover, W.threat, {_root = {30, 0, 0}, neck = neck(-5, 2), head = {2, 0, 0}, _jaw_01 = {52, 0, 0}, tail = tail(0.3, 0.1, -1), lift = 0.5})
local function airShake(yaw, jaw)
	return pose(P.airRoar, {neck = neck(-5, 2, yaw), head = {2, 0, yaw * 7}, _jaw_01 = {jaw, 0, 0}})
end

Dragon.poses = P
Dragon.wings = W
Dragon.expand = expand

local CALM = {life = {spine_04 = 1, neck_06 = 1.2, head = 2, tail_10 = 1.5, tail_20 = 2, l_clavicle = 0.8, r_clavicle = 0.8}, lifeRate = 0.6}

Dragon.Fly = clip("DragonFly", 1.1, true, {{0, P.flyUp}, {0.2, P.flyMid}, {0.42, P.flyDown}, {0.75, P.flyRec}, {1.1, P.flyUp}})

Dragon.Land = clip("DragonLand", 2.6, false, {
	{0, P.flyUp},
	{0.3, P.flare},
	{0.55, P.brake},
	{0.8, P.reach},
	{1.05, P.brake},
	{1.38, P.touch, "flat"},
	{1.62, P.absorb},
	{2.05, P.rise},
	{2.6, P.look},
}, {events = {touch = 1.4}, life = CALM.life, lifeRate = 0.6})

Dragon.Idle = clip("DragonIdle", 3.6, true, {{0, P.stand}, {0.9, P.look}, {1.8, P.breath}, {2.7, P.lookBack}, {3.6, P.stand}}, CALM)

Dragon.Roar = clip("DragonRoar", 2.6, false, {
	{0, P.stand},
	{0.42, P.coil},
	{0.7, P.roar},
	{0.9, shake(0.8, 54)},
	{1.08, shake(-0.7, 50)},
	{1.26, shake(0.5, 52)},
	{1.46, shake(-0.3, 48)},
	{1.9, P.roarHold},
	{2.6, P.stand},
}, {events = {roar = 0.7}, life = {spine_04 = 1, neck_06 = 1.4, head = 2.2, tail_10 = 1.5, tail_20 = 2}, lifeRate = 1.6})

Dragon.Hit = clip("DragonHit", 1.1, false, {
	{0, P.stand},
	{0.07, P.hit},
	{0.42, P.stagger},
	{1.1, P.reel},
}, CALM)

Dragon.Hover = clip("DragonHover", 1.0, true, {{0, P.hover}, {0.4, P.hoverDown}, {0.7, P.hoverRec}, {1.0, P.hover}})

Dragon.AirHit = clip("DragonAirHit", 0.55, false, {
	{0, P.hover},
	{0.07, P.airHit},
	{0.3, P.airCatch},
	{0.55, P.hover},
})

Dragon.AirRoar = clip("DragonAirRoar", 1.9, false, {
	{0, P.hover},
	{0.35, P.airCoil},
	{0.55, P.airRoar},
	{0.75, airShake(0.8, 54)},
	{0.93, airShake(-0.6, 50)},
	{1.12, airShake(0.3, 52)},
	{1.4, P.airRoar},
	{1.9, P.hover},
}, {events = {roar = 0.55}, life = {spine_04 = 1, neck_06 = 1.4, head = 2.2, tail_10 = 1.5, tail_20 = 2}, lifeRate = 1.6})

Dragon.Down = clip("DragonDown", 1.8, false, {
	{0, P.reel},
	{0.35, P.buckle},
	{0.8, P.down},
	{1.15, P.slump},
	{1.8, P.rest},
}, {events = {crash = 0.8}, life = CALM.life, lifeRate = 0.3})

return Dragon
