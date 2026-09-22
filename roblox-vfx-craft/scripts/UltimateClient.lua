local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")

local root = ReplicatedStorage:WaitForChild("Ultimate")
local Config = require(root.Config)
local Emitters = require(root.Modules.Emitters)
local UltimateVfx = require(root.Modules.UltimateVfx)
local Remotes = root.Remotes

local player = Players.LocalPlayer
local busy = false

-- the first cast after a join must not miss a clip or a sprite so everything is pulled in up front
task.spawn(function()
	local list = {}
	for _, s in ipairs(root.Assets.Sounds:GetChildren()) do
		if s.SoundId ~= "" then
			table.insert(list, s)
		end
	end
	for _, a in ipairs(root.Assets.Animations:GetChildren()) do
		table.insert(list, a)
	end
	local holder = Instance.new("ScreenGui")
	holder.Name = "UltPreload"
	holder.Enabled = false
	holder.ResetOnSpawn = false
	for _, id in pairs(Emitters.TEX) do
		local img = Instance.new("ImageLabel")
		img.Image = id
		img.Parent = holder
		table.insert(list, img)
	end
	holder.Parent = player:WaitForChild("PlayerGui")
	pcall(ContentProvider.PreloadAsync, ContentProvider, list)
	holder:Destroy()
end)

local function request()
	if busy then
		return
	end
	Remotes.CastRequest:FireServer()
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end
	if input.KeyCode == Config.Key then
		request()
	end
end)

Remotes.Cast.OnClientEvent:Connect(function(caster, origin)
	local character = caster.Character
	if not character then
		return
	end
	local isLocal = caster == player
	if isLocal then
		busy = true
	end
	local ok, err = pcall(UltimateVfx.play, character, origin, isLocal)
	if not ok then
		warn("ultimate failed", err)
	end
	if isLocal then
		busy = false
	end
end)

-- a studio test hook so the cast can be fired from the command bar without any input
player:GetAttributeChangedSignal("CastUlt"):Connect(function()
	if player:GetAttribute("CastUlt") then
		player:SetAttribute("CastUlt", nil)
		request()
	end
end)
