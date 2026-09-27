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
	petal = Color3.fromRGB(168, 177, 229),
	heart = Color3.fromRGB(209, 194, 216),
	drift = Color3.fromRGB(125, 152, 214),
	stem = Color3.fromRGB(96, 140, 88),
	smoke = Color3.fromRGB(196, 196, 206),
	smokeDark = Color3.fromRGB(128, 126, 142),
	spark = Color3.fromRGB(255, 244, 200),
	ember = Color3.fromRGB(255, 176, 96),
	maw = Color3.fromRGB(232, 72, 52),
	soot = Color3.fromRGB(46, 36, 40),
	dust = Color3.fromRGB(206, 186, 166),
	dustDark = Color3.fromRGB(122, 104, 92),
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

Config.Volley = {
	Count = 5,
	Gap = 0.18,
	Delay = 0.2,
	Speed = 160,
	Range = 120,
	Spread = 1.6,
	Ahead = 1.2,
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
	Petals = 90,
	Life = 7,
	Colors = {
		{Color3.fromRGB(168, 177, 229), Color3.fromRGB(246, 232, 170)},
		{Color3.fromRGB(244, 242, 250), Color3.fromRGB(250, 214, 110)},
		{Color3.fromRGB(242, 184, 208), Color3.fromRGB(255, 240, 200)},
		{Color3.fromRGB(198, 172, 234), Color3.fromRGB(250, 226, 150)},
		{Color3.fromRGB(150, 198, 240), Color3.fromRGB(244, 244, 250)},
		{Color3.fromRGB(248, 222, 140), Color3.fromRGB(236, 150, 90)},
		{Color3.fromRGB(246, 170, 160), Color3.fromRGB(255, 236, 190)},
	},
}

return Config
