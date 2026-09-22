local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local root = ReplicatedStorage:WaitForChild("Ultimate")
local Config = require(root.Config)
local Remotes = root.Remotes

local lastCast = {}

-- the server only gates the cast and hands every client the same origin so all the effects line up
Remotes.CastRequest.OnServerEvent:Connect(function(player)
	local character = player.Character
	local hrp = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not hrp or not humanoid or humanoid.Health <= 0 then
		return
	end
	local now = os.clock()
	if lastCast[player] and now - lastCast[player] < Config.Cooldown then
		return
	end
	lastCast[player] = now
	Remotes.Cast:FireAllClients(player, hrp.CFrame)
end)

Players.PlayerRemoving:Connect(function(player)
	lastCast[player] = nil
end)
