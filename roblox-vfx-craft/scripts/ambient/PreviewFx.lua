local function seq(...)
	local pts = { ... }
	local kps = {}
	for i = 1, #pts, 2 do
		table.insert(kps, NumberSequenceKeypoint.new(pts[i], pts[i + 1]))
	end
	return NumberSequence.new(kps)
end

local function cseq(a, b)
	return ColorSequence.new(a, b)
end

local function rgb(r, g, b)
	return Color3.fromRGB(r, g, b)
end

local function holder(parent, name, cf, size)
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Transparency = 1
	p.Size = size
	p.CFrame = cf
	p.Parent = parent
	return p
end

local function emitter(parent, name, props)
	local e = Instance.new("ParticleEmitter")
	e.Name = name
	for k, v in props do
		e[k] = v
	end
	e.Parent = parent
	return e
end

local function flat(parent, name, tex, size, color, light, bright, rot, life, rate, transp, z)
	return emitter(parent, name, {
		Texture = "rbxassetid://" .. tex,
		Size = seq(0, size * 0.92, 1, size),
		Color = color,
		LightEmission = light,
		Brightness = bright,
		Transparency = transp,
		RotSpeed = NumberRange.new(rot),
		Rotation = NumberRange.new(0, 360),
		Lifetime = NumberRange.new(life),
		Rate = rate,
		Speed = NumberRange.new(0.001),
		EmissionDirection = Enum.NormalId.Top,
		Orientation = Enum.ParticleOrientation.VelocityPerpendicular,
		LockedToPart = true,
		ZOffset = z,
	})
end

local function ringEmitter(ring, name, props)
	props.Shape = Enum.ParticleEmitterShape.Disc
	props.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
	return emitter(ring, name, props)
end

local function sideFall(folder, carrier, name, tex, size, color, rate)
	for _, side in { -1, 1 } do
		local box = holder(folder, name .. "Box", carrier.CFrame * CFrame.new(0.5, 13.5, side * 17.6), Vector3.new(1.6, 2, 3.6))
		emitter(box, name, {
			Texture = "rbxassetid://" .. tex,
			Size = seq(0, 0, 0.06, size, 0.9, size * 0.9, 1, 0),
			Color = color,
			LightEmission = 0.15,
			Brightness = 1.4,
			Transparency = seq(0, 0, 0.88, 0, 1, 1),
			RotSpeed = NumberRange.new(-160, 160),
			Rotation = NumberRange.new(0, 360),
			Lifetime = NumberRange.new(5, 6.5),
			Rate = rate,
			Speed = NumberRange.new(0.7, 1.4),
			EmissionDirection = Enum.NormalId.Bottom,
			SpreadAngle = Vector2.new(9, 9),
			Acceleration = Vector3.new(0, -1.6, 0),
			Drag = 0.5,
		})
	end
end

return function(model, theme)
	local carrier = model.Part
	local old = model:FindFirstChild("PreviewFx")
	if old then
		old:Destroy()
	end
	local folder = Instance.new("Folder")
	folder.Name = "PreviewFx"
	folder.Parent = model
	local face = carrier.CFrame * CFrame.Angles(0, 0, -math.pi / 2)
	local back = holder(folder, "Back", face * CFrame.new(0, -0.7, 0), Vector3.new(1, 0.2, 1))
	local front = holder(folder, "Front", face * CFrame.new(0, 0.5, 0), Vector3.new(1, 0.2, 1))
	local ring = holder(folder, "Ring", face * CFrame.new(0, 0.3, 0), Vector3.new(34, 0.2, 34))
	local floor = model["cylinder mesh base"]
	local pad = holder(folder, "PadBox", CFrame.new(floor.Position + Vector3.new(0, 2.5, 0)), Vector3.new(34, 4, 34))
	local light = Instance.new("PointLight")
	light.Range = 32
	light.Brightness = 2
	light.Shadows = false
	light.Parent = front
	if theme == "Forest" then
		light.Color = rgb(150, 255, 140)
		flat(back, "Halo", 243664672, 46, cseq(rgb(170, 255, 140), rgb(90, 220, 90)), 1, 1.1, 0, 3, 0.9, seq(0, 1, 0.3, 0.62, 0.7, 0.62, 1, 1), -4)
		flat(back, "SwirlDeep", 14426232568, 38, cseq(rgb(30, 110, 50), rgb(18, 70, 34)), 0, 1, -16, 8, 0.45, seq(0, 1, 0.25, 0.2, 0.75, 0.2, 1, 1), -3)
		flat(back, "Swirl", 14426232568, 41, cseq(rgb(185, 255, 140), rgb(70, 205, 85)), 0.8, 2, 24, 6, 0.75, seq(0, 1, 0.2, 0.12, 0.8, 0.12, 1, 1), -2)
		flat(front, "Rim", 16951115765, 34, cseq(rgb(245, 255, 200), rgb(160, 250, 110)), 1, 3, 40, 2.4, 1.4, seq(0, 1, 0.25, 0, 0.75, 0, 1, 1), 1)
		flat(front, "RimSpin", 16951115765, 35.5, cseq(rgb(255, 245, 170), rgb(190, 255, 120)), 1, 2, -55, 1.8, 1, seq(0, 1, 0.3, 0.2, 0.7, 0.2, 1, 1), 1)
		sideFall(folder, carrier, "Leaves", 241386641, 1.8, cseq(rgb(160, 245, 115), rgb(95, 190, 75)), 5)
		sideFall(folder, carrier, "LeavesGold", 5057182105, 1.5, cseq(rgb(255, 245, 165), rgb(245, 210, 115)), 2.2)
		ringEmitter(ring, "Fireflies", {
			Texture = "rbxassetid://243664672",
			ShapePartial = 0.55,
			Size = seq(0, 0, 0.15, 0.95, 0.35, 0.4, 0.55, 1, 0.8, 0.45, 1, 0),
			Color = cseq(rgb(255, 245, 150), rgb(190, 255, 120)),
			LightEmission = 1,
			Brightness = 3.5,
			Lifetime = NumberRange.new(3, 6),
			Rate = 22,
			Speed = NumberRange.new(0.4, 1.3),
			SpreadAngle = Vector2.new(180, 180),
			Acceleration = Vector3.new(0, 0.3, 0),
			Drag = 0.4,
		})
		ringEmitter(ring, "Glints", {
			Texture = "rbxassetid://10598374841",
			ShapePartial = 0.9,
			Size = seq(0, 0, 0.4, 2.3, 1, 0),
			Color = cseq(rgb(255, 250, 200), rgb(200, 255, 150)),
			LightEmission = 1,
			Brightness = 2.5,
			Lifetime = NumberRange.new(0.7, 1.2),
			Rate = 12,
			Speed = NumberRange.new(0.05),
			RotSpeed = NumberRange.new(-40, 40),
			Rotation = NumberRange.new(0, 90),
		})
		emitter(pad, "PadFireflies", {
			Texture = "rbxassetid://243664672",
			Size = seq(0, 0, 0.2, 0.8, 0.5, 0.35, 0.8, 0.8, 1, 0),
			Color = cseq(rgb(255, 245, 150), rgb(190, 255, 120)),
			LightEmission = 1,
			Brightness = 3,
			Lifetime = NumberRange.new(3, 5),
			Rate = 10,
			Speed = NumberRange.new(0.3, 1),
			SpreadAngle = Vector2.new(180, 180),
			Acceleration = Vector3.new(0, 0.6, 0),
		})
	else
		light.Color = rgb(170, 225, 255)
		flat(back, "Halo", 243664672, 46, cseq(rgb(190, 228, 255), rgb(120, 185, 255)), 1, 1, 0, 3, 0.9, seq(0, 1, 0.3, 0.72, 0.7, 0.72, 1, 1), -4)
		flat(back, "SwirlDeep", 14426232568, 38, cseq(rgb(60, 110, 185), rgb(36, 72, 140)), 0, 1, 14, 8, 0.45, seq(0, 1, 0.25, 0.22, 0.75, 0.22, 1, 1), -3)
		flat(back, "Swirl", 14426232568, 41, cseq(rgb(205, 235, 255), rgb(110, 180, 250)), 0.55, 1.3, -22, 6, 0.75, seq(0, 1, 0.2, 0.22, 0.8, 0.22, 1, 1), -2)
		flat(front, "Rim", 16951115765, 34, cseq(rgb(250, 254, 255), rgb(170, 225, 255)), 1, 3, -40, 2.4, 1.4, seq(0, 1, 0.25, 0, 0.75, 0, 1, 1), 1)
		flat(front, "RimSpin", 16951115765, 35.5, cseq(rgb(225, 245, 255), rgb(140, 205, 255)), 1, 2, 55, 1.8, 1, seq(0, 1, 0.3, 0.2, 0.7, 0.2, 1, 1), 1)
		local top = holder(folder, "SnowBox", carrier.CFrame * CFrame.new(1.5, 19, 0), Vector3.new(9, 2, 46))
		emitter(top, "Snow", {
			Texture = "rbxassetid://8163218169",
			FlipbookLayout = Enum.ParticleFlipbookLayout.Grid2x2,
			FlipbookMode = Enum.ParticleFlipbookMode.Random,
			Size = NumberSequence.new(1.7),
			Color = cseq(rgb(255, 255, 255), rgb(215, 240, 255)),
			LightEmission = 0.45,
			Brightness = 1.6,
			Transparency = seq(0, 1, 0.06, 0, 0.88, 0, 1, 1),
			RotSpeed = NumberRange.new(-70, 70),
			Rotation = NumberRange.new(0, 360),
			Lifetime = NumberRange.new(8, 10),
			Rate = 34,
			Speed = NumberRange.new(2, 3.2),
			EmissionDirection = Enum.NormalId.Bottom,
			SpreadAngle = Vector2.new(22, 22),
			Acceleration = Vector3.new(0.6, -0.6, 0),
			Drag = 0.25,
		})
		emitter(pad, "Mist", {
			Texture = "rbxassetid://12565968570",
			Size = seq(0, 6, 1, 12),
			Color = cseq(rgb(235, 247, 255), rgb(195, 225, 252)),
			LightEmission = 0.2,
			Transparency = seq(0, 1, 0.25, 0.66, 0.7, 0.72, 1, 1),
			RotSpeed = NumberRange.new(-12, 12),
			Rotation = NumberRange.new(0, 360),
			Lifetime = NumberRange.new(5, 7),
			Rate = 6,
			Speed = NumberRange.new(0.4, 1),
			SpreadAngle = Vector2.new(70, 70),
			Acceleration = Vector3.new(0, 0.15, 0),
		})
		ringEmitter(ring, "MistRim", {
			Texture = "rbxassetid://12565968570",
			ShapePartial = 0.9,
			Size = seq(0, 3.5, 1, 7),
			Color = cseq(rgb(245, 252, 255), rgb(205, 232, 255)),
			LightEmission = 0.3,
			Transparency = seq(0, 1, 0.3, 0.72, 0.7, 0.78, 1, 1),
			RotSpeed = NumberRange.new(-10, 10),
			Rotation = NumberRange.new(0, 360),
			Lifetime = NumberRange.new(4, 6),
			Rate = 8,
			Speed = NumberRange.new(0.3, 0.8),
			SpreadAngle = Vector2.new(180, 180),
		})
		ringEmitter(ring, "Sparkle", {
			Texture = "rbxassetid://14590086212",
			ShapePartial = 0.8,
			Size = seq(0, 0, 0.35, 3.3, 1, 0),
			Color = cseq(rgb(255, 255, 255), rgb(170, 225, 255)),
			LightEmission = 1,
			Brightness = 3,
			Lifetime = NumberRange.new(0.8, 1.4),
			Rate = 16,
			Speed = NumberRange.new(0.05),
			RotSpeed = NumberRange.new(-30, 30),
			Rotation = NumberRange.new(0, 90),
		})
		ringEmitter(ring, "Frost", {
			Texture = "rbxassetid://243664672",
			ShapePartial = 0.6,
			Size = seq(0, 0, 0.2, 0.7, 1, 0),
			Color = cseq(rgb(235, 250, 255), rgb(160, 215, 255)),
			LightEmission = 1,
			Brightness = 3,
			Lifetime = NumberRange.new(2, 4),
			Rate = 18,
			Speed = NumberRange.new(0.3, 0.9),
			SpreadAngle = Vector2.new(180, 180),
			Acceleration = Vector3.new(0, -0.3, 0),
		})
	end
	return folder
end
