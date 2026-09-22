local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local root = ReplicatedStorage:WaitForChild("Stand")
local Config = require(root.Config)
local Remotes = root.Remotes
local Template = root.Assets.TheWorld

local lastToggle = {}

-- the stand joins every character at spawn hidden so a summon only reveals it and never clones sixty parts mid fight
local function attach(character)
	local hrp = character:WaitForChild("HumanoidRootPart", 10)
	if not hrp or character:FindFirstChild("Stand") then
		return nil
	end
	local stand = Template:Clone()
	stand.Name = "Stand"
	for _, d in ipairs(stand:GetDescendants()) do
		if d:IsA("BasePart") and d.Name ~= "StandHumanoidRootPart" then
			d.Transparency = 1
		elseif d:IsA("Trail") then
			d.Enabled = false
		end
	end
	local standRoot = stand.StandHumanoidRootPart
	stand:PivotTo(hrp.CFrame * CFrame.new(Config.FloatOffset))
	local motor = Instance.new("Motor6D")
	motor.Name = "StandRoot"
	motor.Part0 = hrp
	motor.Part1 = standRoot
	motor.Parent = hrp
	stand.Parent = character
	character:SetAttribute("StandOut", false)
	return stand
end

local function watch(player)
	if player.Character then
		task.spawn(attach, player.Character)
	end
	player.CharacterAdded:Connect(function(character)
		task.spawn(attach, character)
	end)
end
for _, player in ipairs(Players:GetPlayers()) do
	watch(player)
end
Players.PlayerAdded:Connect(watch)

Remotes.SummonRequest.OnServerEvent:Connect(function(player)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 or not character:FindFirstChild("Stand") then
		return
	end
	local now = os.clock()
	if lastToggle[player] and now - lastToggle[player] < Config.Cooldown then
		return
	end
	lastToggle[player] = now
	local out = not character:GetAttribute("StandOut")
	character:SetAttribute("StandOut", out)
	Remotes.Summon:FireAllClients(player, out)
end)

Players.PlayerRemoving:Connect(function(player)
	lastToggle[player] = nil
end)
