local Debris = game:GetService("Debris")

local root = script.Parent.Parent
local Config = require(root.Config)
local Tw = require(script.Parent.Tw)

local Emitters = {}

Emitters.TEX = {
	star4 = "rbxassetid://1084970835",
	spark = "rbxassetid://8037777212",
	lightrays = "rbxassetid://1084975295",
	lightray = "rbxassetid://1053548563",
	core = "rbxassetid://1075864321",
	flare = "rbxassetid://867619398",
	circle = "rbxassetid://1084982817",
	specs = "rbxassetid://9997556038",
	shards = "rbxassetid://10439119562",
	blackshards = "rbxassetid://12130244331",
	rocks = "rbxassetid://12111686783",
	smoke = "rbxassetid://16669188960",
	smokeB = "rbxassetid://14006773822",
	darksmoke = "rbxassetid://10180479311",
	shock = "rbxassetid://16477162837",
	impact = "rbxassetid://16954586568",
	impactB = "rbxassetid://16670162492",
	burst = "rbxassetid://9573351641",
	windspin = "rbxassetid://16669803246",
	windspinB = "rbxassetid://16669505937",
	crackA = "rbxassetid://16937144632",
	crackB = "rbxassetid://16937229477",
	crescentRing = "rbxassetid://11948622097",
	fire = "rbxassetid://11395089850",
	stars = "rbxassetid://1851669703",
	windRing = "rbxassetid://16950679789",
	windA = "rbxassetid://10337713824",
	glow = "rbxassetid://12082081459",
}

-- spec keys are emitter properties except texture which is a tex name and flip which is {layout mode fps}
function Emitters.make(parent, spec)
	local e = Instance.new("ParticleEmitter")
	e.Enabled = false
	e.Rate = 0
	e.LightEmission = 1
	e.LightInfluence = 0
	e.Texture = Emitters.TEX[spec.texture] or spec.texture
	if spec.flip then
		e.FlipbookLayout = spec.flip[1]
		e.FlipbookMode = spec.flip[2] or Enum.ParticleFlipbookMode.OneShot
		e.FlipbookFramerate = NumberRange.new(spec.flip[3] or 16)
	end
	for k, v in pairs(spec) do
		if k ~= "texture" and k ~= "flip" then
			e[k] = v
		end
	end
	e.TimeScale = 1 / Tw.S()
	e.Parent = parent
	return e
end

-- a carrier part gives the emitter a shape volume and a world position and never renders itself
function Emitters.carrier(parent, cf, size)
	local p = Instance.new("Part")
	p.Name = "Carrier"
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	p.Transparency = 1
	p.Size = size or Vector3.new(0.2, 0.2, 0.2)
	p.CFrame = cf
	p.Parent = parent
	return p
end

-- one shot that cleans itself up after life seconds
function Emitters.burst(parent, cf, size, spec, count, life)
	local p = Emitters.carrier(parent, cf, size)
	local e = Emitters.make(p, spec)
	e:Emit(count)
	Debris:AddItem(p, (life or 3) * Tw.S())
	return e
end

local function twinkle(s)
	return Tw.seq({{0, 0}, {0.12, s}, {0.4, s * 0.45}, {0.62, s}, {1, 0}})
end

-- the megumin field is stars in every colour with tiny white stars and rings and dots and rays mixed in
function Emitters.sparkles(parent, o)
	local list = {}
	local rate = o.rate or 20
	local size = o.size or 1
	local common = {
		Shape = o.shape or Enum.ParticleEmitterShape.Box,
		ShapeStyle = o.style or Enum.ParticleEmitterShapeStyle.Volume,
		ShapeInOut = o.inOut or Enum.ParticleEmitterShapeInOut.Outward,
		Speed = o.speed or NumberRange.new(1, 5),
		Drag = o.drag or 1,
		Acceleration = o.accel or Vector3.new(0, 1.5, 0),
		SpreadAngle = o.spread or Vector2.new(180, 180),
		Lifetime = o.life or NumberRange.new(0.9, 1.8),
		Rotation = NumberRange.new(0, 90),
		RotSpeed = NumberRange.new(-60, 60),
		ZOffset = o.zoffset or 0,
		Enabled = o.enabled == true,
	}
	local function add(spec, mul)
		for k, v in pairs(common) do
			if spec[k] == nil then
				spec[k] = v
			end
		end
		spec.Rate = rate * (mul or 1)
		local e = Emitters.make(parent, spec)
		table.insert(list, {e = e, mul = mul or 1})
		return e
	end
	for i, col in ipairs(Config.Sparkle) do
		local s = size * (1.6 + (i % 3) * 0.9)
		add({
			texture = "star4",
			Size = twinkle(s),
			Color = Tw.cseq({{0, Color3.new(1, 1, 1)}, {0.3, col}, {1, col}}),
			Transparency = Tw.seq({{0, 0}, {0.8, 0.1}, {1, 1}}),
		}, 1)
	end
	add({
		texture = "star4",
		Size = twinkle(size * 0.7),
		Color = ColorSequence.new(Color3.new(1, 1, 1)),
	}, 3)
	for i, col in ipairs({Config.Sparkle[1], Config.Sparkle[4], Config.Sparkle[3]}) do
		add({
			texture = "crescentRing",
			Size = Tw.seq({{0, 0}, {0.2, size * (1.2 + i * 0.5)}, {1, size * (2.2 + i * 0.5)}}),
			Color = ColorSequence.new(col),
			Transparency = Tw.seq({{0, 0.2}, {1, 1}}),
			RotSpeed = NumberRange.new(-20, 20),
		}, 0.5)
	end
	for i, col in ipairs({Config.Sparkle[2], Config.Sparkle[5], Config.Sparkle[6], Config.Sparkle[1]}) do
		add({
			texture = "circle",
			Size = Tw.seq({{0, 0}, {0.1, size * 0.35}, {1, 0}}),
			Color = ColorSequence.new(col),
		}, 1.2)
	end
	for _, col in ipairs({Config.Sparkle[1], Config.Sparkle[4], Config.Sparkle[7]}) do
		add({
			texture = "lightray",
			Size = Tw.seq({{0, 0}, {0.15, size * 5}, {1, size * 7}}),
			Color = ColorSequence.new(col),
			Transparency = Tw.seq({{0, 1}, {0.15, 0.2}, {1, 1}}),
			Rotation = NumberRange.new(0, 360),
			RotSpeed = NumberRange.new(-10, 10),
			Lifetime = NumberRange.new(0.4, 0.8),
		}, 0.5)
	end
	return list
end

function Emitters.setSparkles(list, on)
	for _, item in ipairs(list) do
		item.e.Enabled = on
	end
end

-- count is the star count per colour so a burst of 40 throws around 400 pieces in total
function Emitters.sparkleBurst(parent, cf, size, count, o)
	local p = Emitters.carrier(parent, cf, size)
	o = o or {}
	o.enabled = false
	local list = Emitters.sparkles(p, o)
	for _, item in ipairs(list) do
		item.e:Emit(math.floor(count * item.mul))
	end
	Debris:AddItem(p, ((o.life and o.life.Max or 1.8) + 0.5) * Tw.S())
	return p
end

return Emitters
