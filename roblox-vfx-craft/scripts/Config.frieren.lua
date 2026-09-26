local Config = {}

Config.Palette = {
	white = Color3.fromRGB(243, 246, 251),
	lilac = Color3.fromRGB(204, 210, 233),
	lavender = Color3.fromRGB(172, 167, 213),
	dusk = Color3.fromRGB(135, 128, 178),
	ink = Color3.fromRGB(22, 20, 36),
	fringe = Color3.fromRGB(150, 255, 190),
	edge = Color3.fromRGB(192, 227, 224),
	fill = Color3.fromRGB(156, 184, 185),
	shade = Color3.fromRGB(127, 158, 159),
	mint = Color3.fromRGB(232, 239, 235),
	sage = Color3.fromRGB(176, 189, 155),
	petal = Color3.fromRGB(128, 170, 240),
	heart = Color3.fromRGB(246, 240, 205),
	stem = Color3.fromRGB(96, 140, 88),
	smoke = Color3.fromRGB(196, 196, 206),
	smokeDark = Color3.fromRGB(128, 126, 142),
	spark = Color3.fromRGB(255, 244, 200),
}

Config.Zoltraak = {
	Radius = 3,
	Ahead = 2,
	Circle = 0.65,
	Line = 0.13,
	Hold = 0.62,
	Range = 120,
	Width = 1,
	Flash = true,
}

Config.Barrier = {
	Radius = 3.2,
	Lift = 1.2,
	Cell = 0.7,
	Gap = 1.08,
	Rings = 2,
	Cluster = 5,
	Life = 0.35,
}

Config.Flowers = {
	Gather = 1.15,
	Radius = 14,
	Near = 2.5,
	Speed = 14,
	Count = 110,
	Life = 7,
}

return Config
