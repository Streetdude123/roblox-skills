local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Poser = require(ReplicatedStorage.Anim.Modules.Poser)
local Clips = require(ReplicatedStorage.Anim.Modules.ExampleFrieren)
local Vfx = require(ReplicatedStorage.Frieren.Modules.FrierenVfx)
local Cinema = require(ReplicatedStorage.Frieren.Modules.FrierenCinema)

local player = Players.LocalPlayer
local Assets = ReplicatedStorage.Frieren.Assets
local tilt = math.rad(25)
local GRIP = CFrame.new(0, -0.8, 0) * CFrame.fromMatrix(Vector3.zero, Vector3.xAxis, Vector3.new(0, math.sin(tilt), -math.cos(tilt)))
local camera = workspace.CurrentCamera

local char, hum, hrp, rig, shield, walkSpeed
local state = "wait"

local moves = {
	Zoltraak = {Clips.Zoltraak, Vfx.zoltraak},
	Volley = {Clips.ZoltraakVolley, Vfx.volley},
	Flowers = {Clips.Flowers, Vfx.flowers},
	Dodge = {Clips.LeanDodge},
}

local cines = {
	CineZoltraak = {Clips.ZoltraakCine, Cinema.zoltraak},
	CineVolley = {Clips.VolleyCine, Cinema.volley},
	CineFlowers = {Clips.FlowersCine, Cinema.flowers},
}

local keys = {
	[Enum.KeyCode.One] = "Zoltraak",
	[Enum.KeyCode.Two] = "Volley",
	[Enum.KeyCode.Three] = "Flowers",
	[Enum.KeyCode.Q] = "Dodge",
	[Enum.KeyCode.Z] = "CineZoltraak",
	[Enum.KeyCode.X] = "CineVolley",
	[Enum.KeyCode.C] = "CineFlowers",
}

local function free()
	return state == "idle" or state == "walk"
end

local function lock()
	walkSpeed = hum.WalkSpeed
	hum.WalkSpeed = 0
	hum.AutoRotate = false
	local look = camera.CFrame.LookVector * Vector3.new(1, 0, 1)
	hrp.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + look)
end

local function rest()
	hum.WalkSpeed = walkSpeed
	hum.AutoRotate = true
	state = "idle"
	rig:play(Clips.CalmIdle, {fadeIn = 0.3})
end

local function cast(name)
	if not free() then
		return
	end
	local move = moves[name]
	lock()
	state = name
	rig:play(move[1], {onDone = rest})
	if move[2] then
		move[2](char)
	end
end

local function cinema(name)
	if not free() then
		return
	end
	local c = cines[name]
	lock()
	state = name
	c[2](char, rest, rig, c[1])
end

local function hold()
	rig:play(Clips.BarrierHold, {fadeIn = 0.1})
end

local function raise()
	if not free() then
		return
	end
	lock()
	state = "barrier"
	shield = Vfx.barrier(char)
	rig:play(Clips.BarrierRaise, {onDone = hold})
end

local function drop()
	shield.drop()
	shield = nil
	rest()
end

local function block(point)
	shield.hit(point)
	rig:play(Clips.BarrierHit, {fadeIn = 0.03, onDone = hold})
end

local function dress(c)
	for _, piece in ipairs(Assets.Outfit:GetChildren()) do
		if piece:IsA("Accessory") then
			local acc = piece:Clone()
			local h = acc.Handle
			local a = h:FindFirstChildOfClass("Attachment")
			local weld = Instance.new("Weld")
			weld.Part0 = c.Head
			weld.Part1 = h
			weld.C0 = c.Head[a.Name].CFrame
			weld.C1 = a.CFrame
			weld.Parent = h
			acc.Parent = c
		else
			local old = c:FindFirstChildOfClass(piece.ClassName)
			if old then
				old:Destroy()
			end
			piece:Clone().Parent = c
		end
	end
	c.Head.Transparency = 1
	c.Head.face.Transparency = 1
end

local function spawned(c)
	char = c
	hum = c:WaitForChild("Humanoid")
	hrp = c:WaitForChild("HumanoidRootPart")
	c:WaitForChild("Animate"):Destroy()
	for _, track in hum.Animator:GetPlayingAnimationTracks() do
		track:Stop(0)
	end
	local staff = Assets.Staff:Clone()
	local grip = Instance.new("Motor6D")
	grip.Name = "Grip"
	grip.Part0 = c["Right Arm"]
	grip.Part1 = staff.Grip
	grip.C0 = GRIP
	grip.Parent = c["Right Arm"]
	staff.Parent = c
	dress(c)
	rig = Poser.attach(c)
	shield = nil
	state = "idle"
	rig:play(Clips.CalmIdle, {fadeIn = 0})
end

RunService.Heartbeat:Connect(function()
	if not free() then
		return
	end
	local v = hrp.AssemblyLinearVelocity
	local speed = Vector3.new(v.X, 0, v.Z).Magnitude
	if state == "idle" and speed > 0.5 then
		state = "walk"
		rig:play(Clips.CalmWalk, {fadeIn = 0.2, speed = speed / Clips.CalmWalk.travel})
	elseif state == "walk" and speed < 0.3 then
		state = "idle"
		rig:play(Clips.CalmIdle, {fadeIn = 0.3})
	elseif state == "walk" then
		rig:setSpeed(speed / Clips.CalmWalk.travel)
	end
end)

UserInputService.InputBegan:Connect(function(input, typing)
	if typing then
		return
	end
	local name = keys[input.KeyCode]
	if cines[name] then
		cinema(name)
	elseif name then
		cast(name)
	elseif input.KeyCode == Enum.KeyCode.F then
		raise()
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.F and shield then
		drop()
	end
end)

player:GetAttributeChangedSignal("Cast"):Connect(function()
	local name = player:GetAttribute("Cast")
	if name == "Barrier" then
		raise()
	elseif name == "Drop" and shield then
		drop()
	elseif moves[name] then
		cast(name)
	elseif cines[name] then
		cinema(name)
	end
end)

player:GetAttributeChangedSignal("BarrierHit"):Connect(function()
	local point = player:GetAttribute("BarrierHit")
	if point and shield then
		block(point)
	end
end)

local function warm()
	game:GetService("ContentProvider"):PreloadAsync({Assets})
	local stage = Instance.new("Folder")
	stage.Name = "Warm"
	local cf = camera.CFrame * CFrame.new(0, 0, -14)
	local list = Assets.Vfx:GetChildren()
	table.insert(list, Assets.Dragon)
	for _, t in ipairs(list) do
		local c = t:Clone()
		for _, d in ipairs(c:GetDescendants()) do
			if d:IsA("BasePart") then
				d.Anchored, d.CanCollide, d.CanQuery = true, false, false
				d.Transparency = math.max(d.Transparency, 0.98)
			elseif d:IsA("ParticleEmitter") then
				d.Enabled = false
				d.Transparency = NumberSequence.new(0.98)
			elseif d:IsA("Beam") then
				d.Transparency = NumberSequence.new(0.98)
			elseif d:IsA("Light") then
				d.Enabled = false
			end
		end
		if c:IsA("PVInstance") then
			c:PivotTo(cf)
		end
		c.Parent = stage
	end
	stage.Parent = workspace
	for _, d in ipairs(stage:GetDescendants()) do
		if d:IsA("ParticleEmitter") then
			d:Emit(1)
		end
	end
	for _ = 1, 3 do
		RunService.RenderStepped:Wait()
	end
	stage:Destroy()
end

task.spawn(warm)
if player.Character then
	spawned(player.Character)
end
player.CharacterAdded:Connect(spawned)
