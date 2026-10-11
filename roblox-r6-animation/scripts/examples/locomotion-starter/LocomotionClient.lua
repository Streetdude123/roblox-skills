-- StarterPlayerScripts entry for a fresh place: every character runs the code posed idle, walk, run, air and land,
-- Shift sprints so the run blend can reach 1, and the PoseHold attribute freezes a pose for a capture
-- expects ReplicatedStorage.Anim.Modules.{Tw, Poser, Clips, Locomotion} (see SKILL.md, Install into a fresh place)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local root = ReplicatedStorage:WaitForChild("Anim")
local Locomotion = require(root.Modules.Locomotion)
local Clips = require(root.Modules.Clips)

local player = Players.LocalPlayer
local WALK, SPRINT = 16, 26

local function watch(other)
	local function onCharacter(character)
		task.spawn(Locomotion.start, character)
	end
	if other.Character then
		onCharacter(other.Character)
	end
	other.CharacterAdded:Connect(onCharacter)
end
for _, other in ipairs(Players:GetPlayers()) do
	watch(other)
end
Players.PlayerAdded:Connect(watch)

-- the run blend starts at speed 18 and the default walk is 16, so a sprint key is what makes the run exist
local function setSpeed(v)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid.WalkSpeed > 0 then
		humanoid.WalkSpeed = v
	end
end
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.LeftShift then
		setSpeed(SPRINT)
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.LeftShift then
		setSpeed(WALK)
	end
end)

-- "walk:0.25" holds the walk at a quarter cycle, "idle" holds the idle, "Move:0.36" holds a clip frame, nil releases
player:GetAttributeChangedSignal("PoseHold"):Connect(function()
	local v = player:GetAttribute("PoseHold")
	local character = player.Character
	local ctrl = character and Locomotion.get(character)
	if not ctrl then
		return
	end
	if not v or v == "" then
		ctrl.frozen = false
		Locomotion.release(character, 0.2)
		return
	end
	local name, arg = tostring(v):match("^(%w+):?([%d%.]*)$")
	if name == "walk" then
		ctrl.frozen = true
		ctrl.ctx.walk = 1
		ctrl.ctx.speed = 16
		ctrl.ctx.air = 0
		ctrl.ctx.phase = (tonumber(arg) or 0) * math.pi * 2
		Locomotion.release(character, 0)
	elseif name == "idle" then
		ctrl.frozen = true
		ctrl.ctx.walk = 0
		ctrl.ctx.air = 0
		Locomotion.release(character, 0)
	elseif Clips[name] then
		ctrl.frozen = true
		ctrl.rig:play(Clips[name], {fadeIn = 0, speed = 0, startAt = tonumber(arg) or 0})
	end
end)
