local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local eruption = ReplicatedStorage:WaitForChild("Eruption")
local Cast = require(eruption.Cast)
local remote = eruption.Erupt

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local params = RaycastParams.new()
params.FilterType = Enum.RaycastFilterType.Exclude

UserInputService.InputBegan:Connect(function(input, used)
	if used or input.UserInputType ~= Enum.UserInputType.MouseButton1 then
		return
	end
	local ray = camera:ScreenPointToRay(input.Position.X, input.Position.Y)
	params.FilterDescendantsInstances = {player.Character}
	local hit = workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
	if not hit or hit.Normal.Y < 0.7 then
		return
	end
	Cast.play(hit.Position)
	remote:FireServer(hit.Position)
end)

remote.OnClientEvent:Connect(Cast.play)

Cast.warm()
