local Config = {}

Config.Key = Enum.KeyCode.Q
-- seconds between a summon and the next toggle
Config.Cooldown = 3
-- kept for the ultimate only since the summon never takes the camera
Config.Cinematic = false
-- the wry shout from the model plays on the pop when this is on
Config.Voice = false

Config.Palette = {
	gold = Color3.fromRGB(255, 205, 60),
	amber = Color3.fromRGB(255, 150, 30),
	pale = Color3.fromRGB(255, 240, 170),
	white = Color3.fromRGB(255, 255, 255),
	lavender = Color3.fromRGB(205, 150, 255),
	violet = Color3.fromRGB(135, 50, 225),
	deep = Color3.fromRGB(40, 10, 70),
	green = Color3.fromRGB(90, 255, 130),
	black = Color3.fromRGB(0, 0, 0),
}

-- the sparkle field takes one star emitter per colour so gold and violet dominate with a little green
Config.Sparkle = {
	Color3.fromRGB(255, 205, 60),
	Color3.fromRGB(205, 150, 255),
	Color3.fromRGB(255, 255, 255),
	Color3.fromRGB(255, 150, 30),
	Color3.fromRGB(255, 240, 170),
	Color3.fromRGB(135, 50, 225),
	Color3.fromRGB(90, 255, 130),
}

-- where the stand floats in root space once it is out (x right, y up, z back)
Config.FloatOffset = Vector3.new(3.0, 1.9, 1.2)

return Config
