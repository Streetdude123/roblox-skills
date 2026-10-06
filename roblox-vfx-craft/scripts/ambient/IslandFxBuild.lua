local RS = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local island = RS.Client.Island

local old = island:FindFirstChild("Fx")
if old then
	old:Destroy()
end
local fx = Instance.new("Folder")
fx.Name = "Fx"

local function seq(...)
	local t = { ... }
	local k = {}
	for i = 1, #t, 2 do
		table.insert(k, NumberSequenceKeypoint.new(t[i], t[i + 1]))
	end
	return NumberSequence.new(k)
end

local function rgb(r, g, b)
	return Color3.fromRGB(r, g, b)
end

local function holder(name, size, parent)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	p.Transparency = 1
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end

local shaft = holder("Shaft", Vector3.new(1, 1, 1), fx)
local top = Instance.new("Attachment")
top.Name = "Top"
top.Position = Vector3.new(0, 150, 0)
top.Parent = shaft
local bottom = Instance.new("Attachment")
bottom.Name = "Bottom"
bottom.Position = Vector3.new(0, 1, 0)
bottom.Parent = shaft
local function beam(name, tex, w0, w1, tr, col)
	local b = Instance.new("Beam")
	b.Name = name
	b.Attachment0 = top
	b.Attachment1 = bottom
	b.Texture = tex
	b.TextureMode = Enum.TextureMode.Stretch
	b.TextureLength = 1
	b.Width0 = w0
	b.Width1 = w1
	b.FaceCamera = true
	b.LightEmission = 1
	b.LightInfluence = 0
	b.Segments = 12
	b.Color = ColorSequence.new(col)
	b.Transparency = tr
	b.Parent = shaft
	return b
end
beam("Glow", "rbxassetid://2382169232", 24, 28, seq(0, 1, 0.2, 0.86, 0.8, 0.86, 1, 1), rgb(255, 244, 210))
beam("Body", "rbxassetid://107106421823337", 13, 15, seq(0, 1, 0.22, 0.62, 0.78, 0.66, 1, 1), rgb(255, 250, 228))

local fly = holder("Butterfly", Vector3.new(1, 1, 1), fx)
fly.CFrame = CFrame.new()
local S = 0.8
local function att(name)
	local a = Instance.new("Attachment")
	a.Name = name
	a.Parent = fly
	return a
end
local function wing(name, a0, a1)
	local b = Instance.new("Beam")
	b.Name = name
	b.Attachment0 = a0
	b.Attachment1 = a1
	b.Texture = "rbxassetid://102207236507154"
	b.TextureMode = Enum.TextureMode.Stretch
	b.TextureLength = 1
	b.Width0 = S
	b.Width1 = S
	b.FaceCamera = false
	b.Segments = 1
	b.LightEmission = 0.05
	b.LightInfluence = 0.75
	b.Transparency = NumberSequence.new(0)
	b.Color = ColorSequence.new(rgb(255, 232, 205))
	b.Parent = fly
end
local backL, frontL = att("BackL"), att("FrontL")
local backR, frontR = att("BackR"), att("FrontR")
backL.Position = Vector3.new(-S / 2, 0, S / 2)
frontL.Position = Vector3.new(-S / 2, 0, -S / 2)
backR.Position = Vector3.new(S / 2, 0, S / 2)
frontR.Position = Vector3.new(S / 2, 0, -S / 2)
wing("WingL", backL, frontL)
wing("WingR", backR, frontR)
local tail, head = att("Tail"), att("Head")
tail.Position = Vector3.new(0, 0, 0.3)
head.Position = Vector3.new(0, 0, -0.25)
local body = Instance.new("Beam")
body.Name = "Body"
body.Attachment0 = tail
body.Attachment1 = head
body.Texture = "rbxassetid://115779798511538"
body.TextureMode = Enum.TextureMode.Stretch
body.TextureLength = 1
body.Width0 = 0.15
body.Width1 = 0.15
body.FaceCamera = true
body.Segments = 1
body.LightInfluence = 0.75
body.Transparency = NumberSequence.new(0)
body.Parent = fly

local mist = holder("Mist", Vector3.new(64, 6, 64), fx)
local function cloud(name, tex, size, tr, col, life, speed, light, rates)
	local e = Instance.new("ParticleEmitter")
	e.Name = name
	e.Texture = tex
	e.Size = size
	e.Transparency = tr
	e.Color = ColorSequence.new(col)
	e.Lifetime = life
	e.Speed = speed
	e.SpreadAngle = Vector2.new(80, 80)
	e.EmissionDirection = Enum.NormalId.Top
	e.Acceleration = Vector3.new(0, -0.03, 0)
	e.Drag = 0.15
	e.Rotation = NumberRange.new(0, 360)
	e.RotSpeed = NumberRange.new(-3, 3)
	e.LightEmission = 0
	e.LightInfluence = light
	e.Rate = 0
	e.Enabled = true
	for zone, r in rates do
		e:SetAttribute(zone, r)
	end
	e.Parent = mist
end
cloud("Bank", "rbxassetid://12565968570", seq(0, 30, 1, 58), seq(0, 1, 0.2, 0.72, 0.8, 0.72, 1, 1), rgb(178, 178, 192), NumberRange.new(16, 24), NumberRange.new(0.4, 1), 0.5, { Eishu = 0, Hojo = 0.3, Horai = 0 })
cloud("Layer", "rbxassetid://244514423", seq(0, 44, 1, 76), seq(0, 1, 0.25, 0.82, 0.75, 0.82, 1, 1), rgb(184, 184, 198), NumberRange.new(18, 26), NumberRange.new(0.3, 0.8), 0.45, { Eishu = 0, Hojo = 0.14, Horai = 0.04 })
cloud("Haze", "rbxassetid://1077212019", seq(0, 26, 1, 44), seq(0, 1, 0.25, 0.8, 0.75, 0.8, 1, 1), rgb(232, 240, 226), NumberRange.new(14, 20), NumberRange.new(0.4, 1), 0.2, { Eishu = 0.16, Hojo = 0, Horai = 0 })

local zones = Instance.new("Folder")
zones.Name = "Zones"
zones.Parent = fx
local function zone(name, atm, cc)
	local f = Instance.new("Folder")
	f.Name = name
	local a = Instance.new("Atmosphere")
	for k, v in atm do
		a[k] = v
	end
	a.Parent = f
	local c = Instance.new("ColorCorrectionEffect")
	c.Enabled = false
	for k, v in cc do
		c[k] = v
	end
	c.Parent = f
	f.Parent = zones
end
local la, lc = Lighting:FindFirstChildOfClass("Atmosphere"), Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
zone("Eishu", { Density = la.Density, Offset = la.Offset, Haze = la.Haze, Glare = la.Glare, Color = la.Color, Decay = la.Decay }, { Brightness = lc.Brightness, Contrast = lc.Contrast, Saturation = lc.Saturation, TintColor = lc.TintColor })
zone("Hojo", { Density = 0.55, Offset = 0.6, Haze = 3.2, Glare = 0, Color = rgb(176, 176, 190), Decay = rgb(110, 106, 128) }, { Brightness = -0.04, Contrast = -0.04, Saturation = -0.25, TintColor = rgb(230, 228, 245) })
zone("Horai", { Density = 0.34, Offset = 0.22, Haze = 1.6, Glare = 0.25, Color = rgb(200, 202, 198), Decay = rgb(150, 148, 140) }, { Brightness = 0.01, Contrast = 0.1, Saturation = 0.02, TintColor = rgb(255, 250, 242) })

fx.Parent = island
return "fx built"
