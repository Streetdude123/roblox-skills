local Lighting = game:GetService("Lighting")
local terrain = workspace.Terrain

local SIZE, RES = 1024, 4
local LOW, HIGH = -24, 88
local POND = Vector3.new(-110, 0, -48)
local SUN = Vector2.new(-0.91, -0.4).Unit

local function smooth(a, b, x)
	local t = math.clamp((x - a) / (b - a), 0, 1)
	return t * t * (3 - 2 * t)
end

local function height(x, z)
	local r = math.sqrt(x * x + z * z)
	local dir = Vector2.new(x, z) / math.max(r, 1)
	local open = 1 - 0.75 * math.max(0, dir:Dot(SUN))
	local h = math.noise(x / 60, z / 60, 1.7) * 0.8
	h += (math.noise(x / 170, z / 170, 4.1) * 16 + math.noise(x / 70, z / 70, 8.3) * 5 + 7) * smooth(50, 190, r) * open
	h += (math.noise(x / 110, z / 110, 2.9) * 22 + 30) * smooth(280, 480, r) * open
	local p = Vector2.new(x - POND.X, z - POND.Z).Magnitude
	h = h - 5 * (1 - smooth(18, 34, p))
	return h
end

terrain:Clear()
local cells = SIZE / RES
local ys = (HIGH - LOW) / RES
local heights = {}
for i = 1, cells + 2 do
	heights[i] = {}
	for k = 1, cells + 2 do
		heights[i][k] = height(-SIZE / 2 + (i - 1.5) * RES, -SIZE / 2 + (k - 1.5) * RES)
	end
end

local CHUNK = 64
for ci = 0, cells / CHUNK - 1 do
	for ck = 0, cells / CHUNK - 1 do
		local mats, occ = {}, {}
		for i = 1, CHUNK do
			mats[i], occ[i] = {}, {}
			local gi = ci * CHUNK + i + 1
			for j = 1, ys do
				mats[i][j], occ[i][j] = {}, {}
				local y0 = LOW + (j - 1) * RES
				for k = 1, CHUNK do
					local gk = ck * CHUNK + k + 1
					local h = heights[gi][gk]
					local slope = math.max(math.abs(heights[gi + 1][gk] - heights[gi - 1][gk]), math.abs(heights[gi][gk + 1] - heights[gi][gk - 1])) / (2 * RES)
					local x = -SIZE / 2 + (gi - 1.5) * RES
					local z = -SIZE / 2 + (gk - 1.5) * RES
					local fill = math.clamp((h - y0) / RES, 0, 1)
					local m = Enum.Material.Grass
					if slope > 0.75 then
						m = Enum.Material.Rock
					elseif h < -1.5 then
						m = Enum.Material.Mud
					end
					if fill <= 0 and y0 < -0.8 and Vector2.new(x - POND.X, z - POND.Z).Magnitude < 34 then
						m = Enum.Material.Water
						fill = math.clamp((-0.8 - y0) / RES, 0, 1)
					end
					mats[i][j][k] = fill > 0 and m or Enum.Material.Air
					occ[i][j][k] = fill
				end
			end
		end
		local from = Vector3.new(-SIZE / 2 + ci * CHUNK * RES, LOW, -SIZE / 2 + ck * CHUNK * RES)
		terrain:WriteVoxels(Region3.new(from, from + Vector3.new(CHUNK * RES, HIGH - LOW, CHUNK * RES)), RES, mats, occ)
	end
end

terrain:SetMaterialColor(Enum.Material.Grass, Color3.fromRGB(78, 98, 46))
terrain:SetMaterialColor(Enum.Material.Mud, Color3.fromRGB(88, 72, 58))
terrain:SetMaterialColor(Enum.Material.Rock, Color3.fromRGB(122, 112, 104))
terrain.WaterColor = Color3.fromRGB(70, 92, 110)
terrain.WaterReflectance = 0.9
terrain.WaterTransparency = 0.6
terrain.WaterWaveSize = 0.08
terrain.WaterWaveSpeed = 6

local base = workspace:FindFirstChild("Baseplate")
if base then
	base:Destroy()
end
local spawn = workspace.SpawnLocation
spawn.Position = Vector3.new(0, height(0, 0) + 0.5, 0)
spawn.Transparency = 1
spawn.CanCollide = false
for _, d in spawn:GetChildren() do
	if d:IsA("Decal") then
		d.Transparency = 1
	end
end

local sky = Lighting:FindFirstChildOfClass("Sky")
if sky then
	sky:Destroy()
end
sky = Instance.new("Sky")
sky.SkyboxBk = "rbxassetid://5133008838"
sky.SkyboxDn = "rbxassetid://5132998156"
sky.SkyboxFt = "rbxassetid://5132998362"
sky.SkyboxLf = "rbxassetid://5132998795"
sky.SkyboxRt = "rbxassetid://5132998563"
sky.SkyboxUp = "rbxassetid://5132999149"
sky.CelestialBodiesShown = false
sky.Parent = Lighting

Lighting.ClockTime = 17.55
Lighting.GeographicLatitude = 0
Lighting.Brightness = 2.4
Lighting.ExposureCompensation = 0.15
Lighting.Ambient = Color3.fromRGB(70, 58, 72)
Lighting.OutdoorAmbient = Color3.fromRGB(150, 112, 110)
Lighting.EnvironmentDiffuseScale = 0.7
Lighting.EnvironmentSpecularScale = 0.8
Lighting.ShadowSoftness = 0.3

local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
atmosphere.Density = 0.28
atmosphere.Offset = 0.2
atmosphere.Color = Color3.fromRGB(255, 196, 150)
atmosphere.Decay = Color3.fromRGB(170, 110, 130)
atmosphere.Glare = 0.35
atmosphere.Haze = 1.2

local bloom = Lighting:FindFirstChildOfClass("BloomEffect")
bloom.Intensity = 0.7
bloom.Size = 40
bloom.Threshold = 0.9

local rays = Lighting:FindFirstChildOfClass("SunRaysEffect")
rays.Intensity = 0.12
rays.Spread = 0.8

local grade = Lighting:FindFirstChild("Grade") or Instance.new("ColorCorrectionEffect")
grade.Name = "Grade"
grade.Brightness = 0.01
grade.Contrast = 0.1
grade.Saturation = 0.15
grade.TintColor = Color3.fromRGB(255, 240, 228)
grade.Parent = Lighting

local motes = workspace:FindFirstChild("Motes") or Instance.new("Part")
motes.Name = "Motes"
motes.Anchored = true
motes.CanCollide = false
motes.CanQuery = false
motes.CanTouch = false
motes.CastShadow = false
motes.Transparency = 1
motes.Size = Vector3.new(160, 24, 160)
motes.Position = Vector3.new(0, height(0, 0) + 12, 0)
motes:ClearAllChildren()
motes.Parent = workspace
local e = Instance.new("ParticleEmitter")
e.Name = "Dust"
e.Texture = "rbxassetid://12082081459"
e.Color = ColorSequence.new(Color3.fromRGB(255, 226, 170), Color3.fromRGB(255, 190, 150))
e.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.08), NumberSequenceKeypoint.new(0.5, 0.16), NumberSequenceKeypoint.new(1, 0.06)})
e.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.2, 0.2), NumberSequenceKeypoint.new(0.8, 0.3), NumberSequenceKeypoint.new(1, 1)})
e.Lifetime = NumberRange.new(6, 10)
e.Rate = 60
e.Speed = NumberRange.new(0.2, 0.6)
e.SpreadAngle = Vector2.new(180, 180)
e.Acceleration = Vector3.new(0.3, 0.05, 0.15)
e.RotSpeed = NumberRange.new(-20, 20)
e.LightEmission = 1
e.LightInfluence = 0
e.Parent = motes

return string.format("field built: centre height %.2f, pond height %.2f", height(0, 0), height(POND.X, POND.Z))
