local Config = {}

Config.Key = Enum.KeyCode.Q
Config.Keys = {
	Summon = Enum.KeyCode.Q,
	Barrage = Enum.KeyCode.E,
	TimeStop = Enum.KeyCode.F,
	RoadRoller = Enum.KeyCode.R,
	Knives = Enum.KeyCode.T,
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

-- the knife throw: seven knives fanned from both hands on the release frame of the throw clip, flown by the server
-- at Speed for Life seconds; while a time stop holds the world they hang where they are and fly when it resumes
Config.Knives = {
	Count = 7,
	Spread = 34,
	Speed = 115,
	Life = 1.3,
	Damage = 7,
	Cooldown = 5,
	-- the clip frame the hands open on
	Release = 0.32,
	-- the clip frame the fans appear in the hands on
	Draw = 0.12,
	StickFor = 5,
	-- how long a knife thrown inside stopped time still flies before it hangs
	FrozenFlight = 0.14,
	Voice = {
		draw = "KnifeShine",
		throw = "KnifeThrown",
		shout = "ThrowVoiceline",
		hit = "KnifeShing",
		stick = "KnifeShing2",
	},
}

-- the road roller is a twelve second cutscene keyed to the "road roller voice" track: the call at 0.7 to 1.7, a
-- silent fall to 3.0, the scream 3.1 to 8.5, a gap at 8.6 for the blast, the laugh to 11.8
Config.RoadRoller = {
	-- leap: the feet leave the floor; catch: the cut to dio on the roller; land: the roller hits; point: he gets up
	-- for the scream; jump: the crouch to jump off; boom: the blast and the takeoff; touch: the feet on the ground;
	-- free: the laugh is over and the walk has the body
	Beats = {
		leap = 0.40,
		catch = 1.80,
		land = 3.00,
		point = 3.50,
		jump = 8.26,
		boom = 8.50,
		touch = 9.20,
		free = 10.9,
		fade = 11.2,
		done = 12.0,
	},
	Cooldown = 45,
	ImpactAhead = 10,
	Apex = 36,
	LandDamage = 45,
	LandRadius = 14,
	BoomDamage = 30,
	BoomRadius = 18,
	Fling = 55,
	-- the stand root over the roller's front housing, 2.45 above and 1.1 behind the fists' landing point so the
	-- barrage's 2.7 stud reach drives into the metal; dio rides the rear hood 9.8 behind that point
	StandOffset = Vector3.new(0.3, 1.65, -8.7),
	Voice = {
		track = "RoadRollerDA",
		bed = "RoadRollerStart",
		windup = "RoadRollerSFX",
		jump = "StandJumpSFX",
		land = "RoadRollerLand",
		hit = "RoadRollerHits",
	},
}

return Config
