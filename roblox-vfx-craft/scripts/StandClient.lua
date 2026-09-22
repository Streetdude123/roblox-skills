local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")

local root = ReplicatedStorage:WaitForChild("Stand")
local Config = require(root.Config)
local Emitters = require(root.Modules.Emitters)
local SummonVfx = require(root.Modules.SummonVfx)
local Locomotion = require(root.Modules.Locomotion)
local Clips = require(root.Modules.Clips)
local Remotes = root.Remotes

local player = Players.LocalPlayer
local busy = false

-- the first summon must not miss a sound or a sprite so everything is pulled in at join
task.spawn(function()
	local list = {}
	for _, s in ipairs(root.Assets.Sounds:GetChildren()) do
		if s.SoundId ~= "" then
			table.insert(list, s)
		end
	end
	local holder = Instance.new("ScreenGui")
	holder.Name = "StandPreload"
	holder.Enabled = false
	holder.ResetOnSpawn = false
	local seen = {}
	local function img(id)
		if id == "" or seen[id] then
			return
		end
		seen[id] = true
		local i = Instance.new("ImageLabel")
		i.Image = id
		i.Parent = holder
		table.insert(list, i)
	end
	for _, id in pairs(Emitters.TEX) do
		img(id)
	end
	for _, d in ipairs(root.Assets.Vfx:GetDescendants()) do
		if d:IsA("ParticleEmitter") or d:IsA("Beam") then
			img(d.Texture)
		end
	end
	-- the stand meshes load at join so the first summon never hitches on them
	for _, d in ipairs(root.Assets.TheWorld:GetDescendants()) do
		if d:IsA("MeshPart") or d:IsA("SpecialMesh") then
			table.insert(list, d)
		end
	end
	holder.Parent = player:WaitForChild("PlayerGui")
	pcall(ContentProvider.PreloadAsync, ContentProvider, list)
	holder:Destroy()
	-- the summon pieces draw once at join so the first summon never hitches on a first draw
	local character = player.Character or player.CharacterAdded:Wait()
	character:WaitForChild("Stand", 10)
	SummonVfx.warm(character)
end)

-- every body in the game runs the code posed idle and walk on this client so the stand user always moves the same
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

local function request()
	if busy then
		return
	end
	Remotes.SummonRequest:FireServer()
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end
	if input.KeyCode == Config.Key then
		request()
	end
end)

Remotes.Summon.OnClientEvent:Connect(function(caster, on)
	local character = caster.Character
	if not character then
		return
	end
	local isLocal = caster == player
	if on then
		if isLocal then
			busy = true
		end
		local ok, err = pcall(SummonVfx.summon, character, isLocal)
		if not ok then
			warn("summon failed", err)
		end
		if isLocal then
			busy = false
		end
	else
		local ok, err = pcall(SummonVfx.dismiss, character, isLocal)
		if not ok then
			warn("dismiss failed", err)
		end
	end
end)

-- a studio test hook so the summon can be fired from the command bar without any input
player:GetAttributeChangedSignal("CastStand"):Connect(function()
	if player:GetAttribute("CastStand") then
		player:SetAttribute("CastStand", nil)
		request()
	end
end)

-- a studio hook that freezes the body in one pose so a pose sheet can be captured
-- "walk:0.25" holds the walk at a quarter cycle, "idle" holds the idle, "DioSummon:0.36" holds a clip frame, nil releases
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
