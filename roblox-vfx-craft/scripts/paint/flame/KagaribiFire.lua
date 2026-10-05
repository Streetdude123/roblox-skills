local RS = game:GetService("ReplicatedStorage")
local CS = game:GetService("CollectionService")
local fx = RS.Assets.Fx
local old = fx:FindFirstChild("KagaribiFire")
if old then old:Destroy() end

local FLAME_A = "rbxassetid://118340173564501"
local FLAME_B = "rbxassetid://121999875479986"
local NS, CSq, NR = NumberSequence.new, ColorSequence.new, NumberRange.new
local function kp(t)
	local k = {}
	for _, v in t do
		table.insert(k, NumberSequenceKeypoint.new(v[1], v[2], v[3] or 0))
	end
	return NS(k)
end

local model = Instance.new("Model")
model.Name = "KagaribiFire"

local function src(name, size, y)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = CFrame.new(0, y, 0)
	p.Transparency = 1
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	p.Locked = true
	p.Parent = model
	return p
end

local function em(parent, name, props)
	local e = Instance.new("ParticleEmitter")
	e.Name = name
	e.Shape = Enum.ParticleEmitterShape.Box
	e.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
	e.EmissionDirection = Enum.NormalId.Top
	e.LightInfluence = 0
	for k, v in props do
		e[k] = v
	end
	e.Parent = parent
	return e
end

local base = src("Base", Vector3.new(1.6, 0.2, 1.6), 0)
model.PrimaryPart = base

local flame = src("FlameSrc", Vector3.new(1.5, 0.2, 1.5), 1.05)
for i, tex in {FLAME_A, FLAME_B} do
	em(flame, i == 1 and "FlameA" or "FlameB", {
		Texture = tex, FlipbookLayout = Enum.ParticleFlipbookLayout.Grid8x8, FlipbookMode = Enum.ParticleFlipbookMode.OneShot,
		Lifetime = NR(0.75, 1.0), Rate = 12, Speed = NR(0.25, 0.6), SpreadAngle = Vector2.new(6, 6),
		Size = kp({{0, 2.3, 0.25}, {1, 2.6, 0.25}}), Rotation = NR(-10, 10), Acceleration = Vector3.new(0.3, 0.5, 0.1),
		LightEmission = 0.35, Brightness = 1, ZOffset = 0.4, Transparency = kp({{0, 0}, {1, 0}}),
	})
end

local core = src("CoreSrc", Vector3.new(0.9, 0.2, 0.9), 0.75)
em(core, "Core", {
	Texture = FLAME_A, FlipbookLayout = Enum.ParticleFlipbookLayout.Grid8x8, FlipbookMode = Enum.ParticleFlipbookMode.OneShot,
	Lifetime = NR(0.5, 0.7), Rate = 14, Speed = NR(0.2, 0.5), SpreadAngle = Vector2.new(6, 6),
	Size = kp({{0, 1.5, 0.15}, {1, 1.8, 0.15}}), Rotation = NR(-12, 12), Acceleration = Vector3.new(0.15, 0.3, 0.05),
	LightEmission = 0.55, Brightness = 1, ZOffset = 0.5,
})

local spark = src("SparkSrc", Vector3.new(1.1, 0.2, 1.1), 0.5)
em(spark, "Embers", {
	Texture = "rbxassetid://8068783649", Lifetime = NR(1.4, 2.8), Rate = 9, Speed = NR(3, 7), SpreadAngle = Vector2.new(22, 22),
	Acceleration = Vector3.new(1.4, 0.8, 0.5), Drag = 0.8, Size = kp({{0, 0.16}, {1, 0.05}}),
	Orientation = Enum.ParticleOrientation.VelocityParallel, Squash = kp({{0, 0.5}, {1, 0.2}}),
	RotSpeed = NR(0, 0), LightEmission = 1, Brightness = 2,
	Color = CSq(Color3.fromRGB(255, 206, 120), Color3.fromRGB(255, 110, 40)),
	Transparency = kp({{0, 0}, {0.15, 0.4}, {0.3, 0}, {0.5, 0.5}, {0.65, 0.1}, {1, 1}}), ZOffset = 0.6,
})

local smoke = src("SmokeSrc", Vector3.new(1, 0.2, 1), 2.8)
em(smoke, "Smoke", {
	Texture = "rbxassetid://11414939890", FlipbookLayout = Enum.ParticleFlipbookLayout.Grid8x8, FlipbookMode = Enum.ParticleFlipbookMode.OneShot,
	Lifetime = NR(4, 6), Rate = 3, Speed = NR(1.5, 2.5), SpreadAngle = Vector2.new(8, 8),
	Size = kp({{0, 1.5}, {1, 6.5}}), Rotation = NR(0, 360), RotSpeed = NR(-10, 10), Acceleration = Vector3.new(1, 0.3, 0.35),
	LightInfluence = 1, LightEmission = 0, Color = CSq(Color3.fromRGB(60, 52, 48), Color3.fromRGB(120, 112, 106)),
	Transparency = kp({{0, 1}, {0.1, 0.55}, {0.6, 0.75}, {1, 1}}), ZOffset = -0.3,
})

em(flame, "Glow", {
	Texture = "rbxassetid://243664672", Lifetime = NR(0.4, 0.7), Rate = 8, Speed = NR(0, 0), LockedToPart = true,
	Size = kp({{0, 4.2, 0.4}, {1, 4.2, 0.4}}), LightEmission = 1, Color = CSq(Color3.fromRGB(255, 140, 60)),
	Transparency = kp({{0, 1}, {0.3, 0.9}, {0.7, 0.91}, {1, 1}}), ZOffset = -1,
})

local light = Instance.new("PointLight")
light.Name = "Light"
light.Color = Color3.fromRGB(255, 150, 80)
light.Brightness = 2.4
light.Range = 20
light.Shadows = true
light.Parent = flame
CS:AddTag(light, "FireLight")

model.Parent = fx

local placed = 0
for _, b in workspace.Lobby.Shore.FireBaskets:GetChildren() do
	local basket = b:FindFirstChild("Basket")
	for _, c in basket:GetChildren() do
		if c.Name == "KagaribiFire" then c:Destroy() end
	end
	local f = b:FindFirstChild("Fire")
	if f then f:Destroy() end
	f = model:Clone()
	f.Name = "Fire"
	f:PivotTo(CFrame.new(basket.Position + Vector3.new(0, basket.Size.X / 2 - 0.1, 0)))
	f.Parent = b
	placed += 1
end
return "fire template rebuilt, placed " .. placed
