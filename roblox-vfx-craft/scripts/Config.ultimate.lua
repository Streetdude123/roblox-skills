local Config = {}

Config.Key = Enum.KeyCode.E
Config.Cooldown = 20
-- the caster's camera goes cinematic for the whole sequence when this is on
Config.Cinematic = true

Config.Palette = {
	crimson = Color3.fromRGB(255, 36, 64),
	pink = Color3.fromRGB(255, 70, 190),
	white = Color3.fromRGB(255, 255, 255),
	blue = Color3.fromRGB(80, 170, 255),
	cyan = Color3.fromRGB(60, 240, 255),
	navy = Color3.fromRGB(12, 16, 48),
	ember = Color3.fromRGB(255, 130, 60),
	black = Color3.fromRGB(0, 0, 0),
	rock = Color3.fromRGB(96, 88, 100),
}

-- the megumin field is every colour at once so each star emitter gets one of these
Config.Sparkle = {
	Color3.fromRGB(70, 255, 245),
	Color3.fromRGB(120, 255, 130),
	Color3.fromRGB(255, 240, 90),
	Color3.fromRGB(255, 70, 220),
	Color3.fromRGB(255, 130, 200),
	Color3.fromRGB(190, 150, 255),
	Color3.fromRGB(255, 255, 255),
}

Config.PillarHeight = 160
-- the impact point sits where the blade tip is on the slam frame in root space
Config.ImpactOffset = Vector3.new(-2, 4, -2.6)
Config.PillarOffset = Vector3.new(-1.5, 0, -5)

return Config
