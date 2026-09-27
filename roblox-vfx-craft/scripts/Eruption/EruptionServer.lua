local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remote = ReplicatedStorage.Eruption.Erupt

remote.OnServerEvent:Connect(function(player, pos)
	if typeof(pos) ~= "Vector3" then
		return
	end
	for _, other in Players:GetPlayers() do
		if other ~= player then
			remote:FireClient(other, pos)
		end
	end
end)
