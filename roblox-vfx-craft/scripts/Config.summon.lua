local Config = {}

Config.Key = Enum.KeyCode.Q
Config.Keys = {
	Summon = Enum.KeyCode.Q,
	Barrage = Enum.KeyCode.E,
	TimeStop = Enum.KeyCode.F,
}
-- seconds between a summon and the next toggle
Config.Cooldown = 3
-- kept for the ultimate only since the summon never takes the camera
Config.Cinematic = false
-- the long aut summon sound plays on the pop when this is on; the short summon voice always plays
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

-- the sparkle field list stays for the sword ultimate; the world never uses stars
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
Config.FloatOffset = Vector3.new(3.0, 1.7, 1.4)
-- where it stands for a barrage: in front of the user at chest height
Config.BarrageOffset = Vector3.new(0.6, 0.9, -3.6)

-- the barrage holds while e is down up to the swing clip length and the finisher lands on its last hit
Config.Barrage = {
	MaxHold = 3.6,
	MinHold = 1.0,
	Cooldown = 5,
	TickRate = 0.1,
	TickDamage = 3.0,
	FinishDamage = 22,
	Reach = 9,
	Width = 7,
	Knockback = 62,
	-- the user stands still and points through the rush
	WalkSpeed = 0,
}

-- the m1 chain is the model's five hit set on the stand with dio's command gestures under it; a hit is
-- accepted once the current clip has mostly played, the chain resets after the window, the fifth flings
Config.M1 = {
	Lengths = {0.417, 0.417, 0.417, 0.333, 0.333},
	Strike = {0.20, 0.20, 0.20, 0.10, 0.10},
	Damage = {6, 6, 7, 7, 10},
	Window = 0.9,
	Cooldown = 1.1,
	Reach = 8,
	Width = 6,
	Fling = 34,
	HitStop = {0, 0, 0.05, 0.05, 0.08},
}

-- the time stop keys everything off the voice line "the world 2": za warudo 0.13 to 0.85, a pause, toki wo
-- tomare 1.35 to 2.88 so the snap lands on the last syllable and the world freezes with it
Config.TimeStop = {
	Beats = {
		call = 0.0,
		pause = 0.85,
		command = 1.35,
		snap = 2.45,
		frames = 2.5,
		-- the sphere swallows the camera here and the colour drains with it
		engulf = 3.35,
		done = 3.9,
	},
	Duration = 6,
	Cooldown = 28,
	-- where the stand rises to over dio during the call
	StandOffset = Vector3.new(0.5, 3.4, 1.6),
	Voice = {
		call = "TSSFX",
		snap = "Bass",
		resume = "TSEndSFX",
		heartbeat = "Heartbeat",
	},
}

return Config
