local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local mist = {}

local CELL = 64
local RING = 2

local fx = script.Parent.Fx
local zones = fx.Zones
local cam = workspace.CurrentCamera

local rp = RaycastParams.new()
rp.FilterType = Enum.RaycastFilterType.Include
rp.FilterDescendantsInstances = { workspace.Terrain }

local props = {
	Atmosphere = { "Density", "Offset", "Haze", "Glare", "Color", "Decay" },
	ColorCorrectionEffect = { "Brightness", "Contrast", "Saturation", "TintColor" },
}

local function smooth(a, b, x)
	local t = math.clamp((x - a) / (b - a), 0, 1)
	return t * t * (3 - 2 * t)
end

local function weights(pos)
	local r = math.sqrt(pos.X * pos.X + pos.Z * pos.Z)
	local inner = smooth(880, 1000, r)
	local outer = smooth(1880, 2040, r)
	return { Horai = 1 - inner, Hojo = inner * (1 - outer), Eishu = outer }
end

local function blend(class, w)
	local goal = {}
	for _, name in props[class] do
		local v
		for zone, k in w do
			local x = zones[zone]:FindFirstChildOfClass(class)[name]
			if typeof(x) == "Color3" then
				v = (v or Vector3.zero) + Vector3.new(x.R, x.G, x.B) * k
			else
				v = (v or 0) + x * k
			end
		end
		goal[name] = v
	end
	return goal
end

local function apply(inst, goal, a)
	for name, v in goal do
		local cur = inst[name]
		if typeof(cur) == "Color3" then
			local c = Vector3.new(cur.R, cur.G, cur.B):Lerp(v, a)
			inst[name] = Color3.new(c.X, c.Y, c.Z)
		else
			inst[name] = cur + (v - cur) * a
		end
	end
end

function mist.start()
	local atm = Lighting:FindFirstChildOfClass("Atmosphere")
	local cc = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
	local carriers = {}
	for i = 1, (RING * 2 + 1) ^ 2 do
		local part = fx.Mist:Clone()
		part.Parent = cam
		carriers[i] = { part = part, emitters = part:GetChildren() }
	end

	local acc = 0
	RunService.Heartbeat:Connect(function(dt)
		acc += dt
		if acc < 0.2 then
			return
		end
		local a = 1 - math.exp(-acc * 1.2)
		acc = 0
		local pos = cam.CFrame.Position
		local w = weights(pos)
		apply(atm, blend("Atmosphere", w), a)
		apply(cc, blend("ColorCorrectionEffect", w), a)
		local cx, cz = math.floor(pos.X / CELL), math.floor(pos.Z / CELL)
		local i = 0
		for x = cx - RING, cx + RING do
			for z = cz - RING, cz + RING do
				i += 1
				local c = carriers[i]
				local key = x * 4096 + z
				if c.key ~= key then
					c.key = key
					local mid = Vector3.new((x + 0.5) * CELL, 0, (z + 0.5) * CELL)
					local hit = workspace:Raycast(mid + Vector3.new(0, 700, 0), Vector3.new(0, -900, 0), rp)
					c.wet = not hit or hit.Material == Enum.Material.Water
					c.part.Position = (hit and hit.Position or mid) + Vector3.new(0, 4, 0)
				end
				for _, e in c.emitters do
					e.Rate = c.wet and 0 or e:GetAttribute("Eishu") * w.Eishu + e:GetAttribute("Hojo") * w.Hojo + e:GetAttribute("Horai") * w.Horai
				end
			end
		end
	end)
end

return mist
