local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Poser = require(ReplicatedStorage.Anim.Modules.Poser)
local Clips = require(ReplicatedStorage.Anim.Modules.ExampleFrieren)
local Vfx = require(ReplicatedStorage.Frieren.Modules.FrierenVfx)

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local char, hum, hrp, rig, shield, walkSpeed
local state = "wait"

local moves = {
	Zoltraak = {Clips.Zoltraak, Vfx.zoltraak},
	Volley = {Clips.ZoltraakVolley, Vfx.volley},
	Flowers = {Clips.Flowers, Vfx.flowers},
	Dodge = {Clips.LeanDodge},
}

local keys = {
	[Enum.KeyCode.One] = "Zoltraak",
	[Enum.KeyCode.Two] = "Volley",
	[Enum.KeyCode.Three] = "Flowers",
	[Enum.KeyCode.Q] = "Dodge",
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

local function spawned(c)
	char = c
	hum = c:WaitForChild("Humanoid")
	hrp = c:WaitForChild("HumanoidRootPart")
	c:WaitForChild("Animate"):Destroy()
	for _, track in hum.Animator:GetPlayingAnimationTracks() do
		track:Stop(0)
	end
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
	if keys[input.KeyCode] then
		cast(keys[input.KeyCode])
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
	end
end)

player:GetAttributeChangedSignal("BarrierHit"):Connect(function()
	local point = player:GetAttribute("BarrierHit")
	if point and shield then
		block(point)
	end
end)

if player.Character then
	spawned(player.Character)
end
player.CharacterAdded:Connect(spawned)
