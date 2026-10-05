local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GOLD = Color3.fromRGB(255, 196, 64)
local DEEP = Color3.fromRGB(255, 150, 40)
local PALE = Color3.fromRGB(255, 244, 214)
local WHITE = Color3.fromRGB(255, 255, 255)

local TEX = {
	twinkle = "rbxassetid://110324134347385",
	star = "rbxassetid://4963436775",
	glint = "rbxassetid://10598374841",
	dot = "rbxassetid://12082081459",
	circle = "rbxassetid://257730458",
	coin = "rbxassetid://82039572999398",
	flash = "rbxassetid://867619398",
	rays = "rbxassetid://1085001473",
	ring = "rbxassetid://7919579655",
	confetti = "rbxassetid://284872195",
	exclaim = "rbxassetid://85961443128549",
	anger = "rbxassetid://100652641974586",
}

local function ns(t)
	local k = {}
	for i = 1, #t, 2 do
		table.insert(k, NumberSequenceKeypoint.new(t[i], t[i + 1]))
	end
	return NumberSequence.new(k)
end

local function cs(a, b)
	return ColorSequence.new(a, b or a)
end

local function emitter(parent, name, p)
	local e = Instance.new("ParticleEmitter")
	e.Name = name
	e.Texture = p.tex
	e.Color = p.color or cs(GOLD, PALE)
	e.Size = p.size
	e.Transparency = p.alpha or ns({0, 0, 0.8, 0, 1, 1})
	e.Lifetime = NumberRange.new(p.life[1], p.life[2])
	e.Speed = NumberRange.new(p.speed and p.speed[1] or 0, p.speed and p.speed[2] or 0)
	e.SpreadAngle = p.spread or Vector2.new(0, 0)
	e.Acceleration = p.accel or Vector3.zero
	e.Drag = p.drag or 0
	e.Rotation = NumberRange.new(p.rot and p.rot[1] or 0, p.rot and p.rot[2] or 0)
	e.RotSpeed = NumberRange.new(p.spin and p.spin[1] or 0, p.spin and p.spin[2] or 0)
	e.LightEmission = p.le or 0
	e.Brightness = p.bright or 1
	e.EmissionDirection = p.dir or Enum.NormalId.Top
	e.Rate = p.rate or 0
	e.Enabled = p.rate ~= nil
	e.LockedToPart = p.locked or false
	e.ZOffset = p.z or 0
	if p.flip then
		e.FlipbookLayout = Enum.ParticleFlipbookLayout.Grid4x4
		e.FlipbookMode = Enum.ParticleFlipbookMode.OneShot
	end
	if p.shape then
		e.Shape = p.shape
		e.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
		e.ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward
	end
	if p.count then
		e:SetAttribute("Count", p.count)
	end
	if p.delay then
		e:SetAttribute("Delay", p.delay)
	end
	if p.again then
		e:SetAttribute("Again", p.again)
	end
	e.Parent = parent
	return e
end

local function attach(parent, name, cf)
	local a = Instance.new("Attachment")
	a.Name = name
	a.CFrame = cf or CFrame.new()
	a.Parent = parent
	return a
end

local twinkleSize = ns({0, 0, 0.12, 1, 0.4, 0.45, 0.62, 1, 1, 0})

local tent = workspace.Decoration["Merchant Tent"]
local old = tent:FindFirstChild("ShopFx")
if old then
	old:Destroy()
end
local stand = Instance.new("Model")
stand.Name = "ShopFx"

local function zone(name, cf, size)
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.CastShadow = false
	p.Transparency = 1
	p.Size = size
	p.CFrame = cf
	p.Parent = stand
	return p
end

local awning = zone("Awning", CFrame.new(-47, 20.6, -42.4), Vector3.new(5, 0.8, 21))
emitter(awning, "Twinkles", {tex = TEX.twinkle, flip = true, size = ns({0, 0.5, 0.45, 0.9, 0.7, 1.9, 1, 1.3}), alpha = ns({0, 0.1, 0.75, 0.1, 1, 1}), life = {0.9, 1.3}, rot = {0, 360}, le = 0.5, bright = 2, color = cs(GOLD, DEEP), rate = 13})
emitter(awning, "Glints", {tex = TEX.star, size = ns({0, 0, 0.15, 1.7, 0.5, 0.7, 0.7, 1.5, 1, 0}), alpha = ns({0, 0, 1, 0}), life = {1.2, 1.6}, rot = {0, 90}, spin = {-40, 40}, le = 0.8, bright = 2, color = cs(PALE, GOLD), rate = 2})

local counter = zone("Counter", CFrame.new(-48.0, 14.0, -41.5), Vector3.new(6.5, 1.2, 14.5))
emitter(counter, "Dust", {tex = TEX.dot, size = ns({0, 0.18, 1, 0.12}), alpha = ns({0, 1, 0.15, 0.2, 0.8, 0.3, 1, 1}), life = {3, 4.5}, speed = {0.3, 0.8}, spread = Vector2.new(30, 30), accel = Vector3.new(0, 0.35, 0), le = 0.8, bright = 2, color = cs(GOLD), rate = 14})
emitter(counter, "Coins", {tex = TEX.coin, size = ns({0, 0.5, 1, 0.5}), alpha = ns({0, 1, 0.12, 0, 0.75, 0, 1, 1}), life = {1.6, 2.1}, speed = {1.5, 2.4}, spread = Vector2.new(15, 15), accel = Vector3.new(0, -0.7, 0), rot = {-20, 20}, spin = {-70, 70}, le = 0.1, color = cs(WHITE), rate = 0.45})
emitter(counter, "Shine", {tex = TEX.glint, size = ns({0, 0, 0.3, 0.9, 1, 0}), alpha = ns({0, 0, 1, 0}), life = {0.5, 0.8}, rot = {0, 45}, le = 0.9, bright = 2, color = cs(PALE, GOLD), rate = 3})
local light = Instance.new("PointLight")
light.Color = Color3.fromRGB(255, 205, 120)
light.Brightness = 0.7
light.Range = 10
light.Shadows = false
light.Parent = counter

stand.Parent = tent

local shop = ReplicatedStorage.ShopCounter
local oldFx = shop:FindFirstChild("Fx")
if oldFx then
	oldFx:Destroy()
end
local fx = Instance.new("Folder")
fx.Name = "Fx"

local buy = Instance.new("Folder")
buy.Name = "Buy"
buy.Parent = fx
local core = attach(buy, "Core")
emitter(core, "Flash", {tex = TEX.flash, size = ns({0, 1.5, 0.25, 4.5, 1, 3.5}), alpha = ns({0, 0, 1, 1}), life = {0.18, 0.18}, le = 0.9, bright = 1.5, color = cs(PALE, GOLD), count = 1, z = 1})
emitter(core, "Rays", {tex = TEX.rays, size = ns({0, 1.5, 0.3, 5, 1, 5.5}), alpha = ns({0, 0.2, 1, 1}), life = {0.5, 0.5}, rot = {0, 360}, spin = {40, 40}, le = 0.6, bright = 1.2, color = cs(GOLD, DEEP), count = 1})
emitter(core, "Ring", {tex = TEX.ring, size = ns({0, 1, 1, 6}), alpha = ns({0, 0, 1, 1}), life = {0.45, 0.45}, le = 0.8, bright = 2, color = cs(WHITE, GOLD), count = 1})
local spill = attach(buy, "Spill", CFrame.Angles(math.rad(20), 0, 0))
emitter(spill, "Coins", {tex = TEX.coin, size = ns({0, 0.6, 0.85, 0.6, 1, 0}), alpha = ns({0, 0, 0.8, 0, 1, 1}), life = {0.75, 0.95}, speed = {7, 11}, spread = Vector2.new(55, 55), accel = Vector3.new(0, -30, 0), drag = 0.8, rot = {0, 360}, spin = {-360, 360}, le = 0.1, color = cs(WHITE), count = 22})
emitter(core, "Sparks", {tex = TEX.star, size = ns({0, 0, 0.1, 1.1, 1, 0}), alpha = ns({0, 0, 1, 0}), life = {0.6, 1}, speed = {5, 9}, spread = Vector2.new(180, 180), drag = 5, rot = {0, 90}, spin = {-120, 120}, le = 0.7, bright = 1.5, color = cs(GOLD, WHITE), count = 26})
emitter(spill, "ConfettiGold", {tex = TEX.confetti, size = ns({0, 0.45, 0.85, 0.45, 1, 0}), alpha = ns({0, 0, 1, 0}), life = {1.4, 1.8}, speed = {6, 10}, spread = Vector2.new(70, 70), accel = Vector3.new(0, -10, 0), drag = 2.5, rot = {0, 360}, spin = {-400, 400}, le = 0.3, color = cs(GOLD, DEEP), count = 20, delay = 0.05})
emitter(spill, "ConfettiWhite", {tex = TEX.confetti, size = ns({0, 0.4, 0.85, 0.4, 1, 0}), alpha = ns({0, 0, 1, 0}), life = {1.4, 1.8}, speed = {6, 10}, spread = Vector2.new(70, 70), accel = Vector3.new(0, -10, 0), drag = 2.5, rot = {0, 360}, spin = {-400, 400}, le = 0.3, color = cs(WHITE, PALE), count = 16, delay = 0.05})
emitter(core, "Twinkles", {tex = TEX.twinkle, flip = true, size = ns({0, 0.9, 1, 1.2}), alpha = ns({0, 0.1, 0.75, 0.1, 1, 1}), life = {0.8, 1.2}, speed = {2, 4}, spread = Vector2.new(180, 180), drag = 3, rot = {0, 360}, le = 0.6, bright = 1.2, count = 14, delay = 0.15})

local equip = Instance.new("Folder")
equip.Name = "Equip"
equip.Parent = fx
local pop = attach(equip, "Core")
emitter(pop, "Ring", {tex = TEX.ring, size = ns({0, 0.5, 1, 6}), alpha = ns({0, 0, 1, 1}), life = {0.35, 0.35}, le = 0.8, bright = 2, color = cs(WHITE, GOLD), count = 1})
emitter(pop, "Sparks", {tex = TEX.star, size = ns({0, 0, 0.1, 0.8, 1, 0}), alpha = ns({0, 0, 1, 0}), life = {0.5, 0.8}, speed = {6, 10}, spread = Vector2.new(180, 180), drag = 4, rot = {0, 90}, le = 0.8, bright = 2, color = cs(GOLD, WHITE), count = 12})
emitter(pop, "Glint", {tex = TEX.glint, size = ns({0, 0, 0.2, 3, 1, 0}), alpha = ns({0, 0, 1, 0}), life = {0.35, 0.35}, rot = {0, 45}, le = 1, bright = 2, color = cs(WHITE, PALE), count = 1, z = 1})

local happy = Instance.new("Folder")
happy.Name = "Happy"
happy.Parent = fx
local h = attach(happy, "Exclaim", CFrame.new(0, 0.3, -0.3))
emitter(h, "Mark", {tex = TEX.exclaim, size = ns({0, 0, 0.1, 0.85, 0.2, 0.65, 0.85, 0.65, 1, 0}), alpha = ns({0, 0, 0.85, 0, 1, 1}), life = {1.3, 1.3}, rot = {0, 0}, color = cs(WHITE), count = 1})

local think = Instance.new("Folder")
think.Name = "Thinking"
think.Parent = fx
for i = 1, 3 do
	local d = attach(think, "Dot" .. i, CFrame.new(0.8 + (i - 1) * 0.42, 0.3, -0.3))
	emitter(d, "Dot", {tex = TEX.circle, size = ns({0, 0, 0.12, 0.29, 0.22, 0.26, 0.85, 0.26, 1, 0}), alpha = ns({0, 0, 0.85, 0, 1, 1}), life = {1.6 - (i - 1) * 0.28, 1.6 - (i - 1) * 0.28}, le = 0.1, color = cs(WHITE), count = 1, delay = (i - 1) * 0.28})
end

local annoyed = Instance.new("Folder")
annoyed.Name = "Annoyed"
annoyed.Parent = fx
local m = attach(annoyed, "Vein", CFrame.new(0.85, 0.05, -0.45))
emitter(m, "Mark", {tex = TEX.anger, size = ns({0, 0, 0.08, 0.75, 0.18, 0.6, 0.32, 0.75, 0.46, 0.6, 0.6, 0.75, 0.85, 0.7, 1, 0}), alpha = ns({0, 0, 0.85, 0, 1, 1}), life = {1.4, 1.4}, color = cs(WHITE), count = 1})

fx.Parent = shop

local n = 0
for _, d in stand:GetDescendants() do
	if d:IsA("ParticleEmitter") then
		n += 1
	end
end
local m = 0
for _, d in fx:GetDescendants() do
	if d:IsA("ParticleEmitter") then
		m += 1
	end
end
return "stand emitters " .. n .. ", templates " .. m
