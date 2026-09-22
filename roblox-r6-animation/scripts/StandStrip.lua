-- run in the client datamodel in play: copies of the character with the stand visible, each holding a stand
-- clip at one time (and the body at the matching DioSummon time); prints the camera for a rear or front view
settings().Rendering.QualityLevel = Enum.QualityLevel.Level21
local Players = game:GetService("Players")
local root = game.ReplicatedStorage.Stand
local Poser = require(root.Modules.Poser)
local Clips = require(root.Modules.Clips)
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
char:WaitForChild("Stand", 10)
if not char.Stand["Stand Torso"]:GetAttribute("Mat") then task.wait(2) end
char.Archivable = true

local function standStrip(clipName, times, spacing, facing, zOff, dioClip, dioOffset)
	local old = workspace:FindFirstChild("Strip")
	if old then old:Destroy() end
	local folder = Instance.new("Folder")
	folder.Name = "Strip"
	folder.Parent = workspace
	local base = hrp.CFrame * CFrame.new(-spacing * (#times - 1) / 2, 0, zOff)
	for i, t in ipairs(times) do
		local clone = char:Clone()
		clone.Name = "Ghost" .. i
		for _, d in ipairs(clone:GetDescendants()) do
			if d:IsA("LuaSourceContainer") or d:IsA("Sound") or d:IsA("ParticleEmitter") or d:IsA("PointLight") or d:IsA("Trail") then
				d:Destroy()
			end
		end
		local h = clone:FindFirstChildOfClass("Humanoid")
		if h then h:Destroy() end
		clone.HumanoidRootPart.Anchored = true
		clone:PivotTo(base * CFrame.new(spacing * (i - 1), 0, 0) * CFrame.Angles(0, facing, 0))
		clone.Parent = folder
		for _, p in ipairs(clone.Stand:GetDescendants()) do
			if p:IsA("BasePart") and p.Name ~= "StandHumanoidRootPart" then
				p.Transparency = p:GetAttribute("Tr") or 0
			end
		end
		local ctx = {phase = 0, walk = 0, speed = 0, air = 0, land = 0, jump = 0, stand = true, t = t}
		local rigS = Poser.attach(clone, ctx)
		rigS:play(Clips[clipName], {fadeIn = 0, speed = 0, startAt = t})
		if dioClip then
			local rigD = Poser.attach(clone, ctx)
			rigD:play(Clips[dioClip], {fadeIn = 0, speed = 0, startAt = math.min(Clips[dioClip].length or 100, t + dioOffset)})
		end
	end
	local lp = Instance.new("Part")
	lp.Anchored = true
	lp.CanCollide = false
	lp.Transparency = 1
	lp.CFrame = base * CFrame.new(spacing * (#times - 1) / 2, 6, 6)
	lp.Parent = folder
	local l = Instance.new("PointLight")
	l.Brightness = 2
	l.Range = 70
	l.Parent = lp
	return base
end
_G.standStrip = standStrip
local function w(x, y, z)
	local p = hrp.CFrame:PointToWorldSpace(Vector3.new(x, y, z))
	return string.format("[%.2f,%.2f,%.2f]", p.X, p.Y, p.Z)
end
_G.stripCam = function(x, y, z, lx, ly, lz) return "cam " .. w(x, y, z) .. " look " .. w(lx, ly, lz) end
