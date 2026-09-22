-- run in the client datamodel in play: freezes copies of the character along a line so one capture
-- shows a whole cycle or a whole move; needs Poser and Clips in ReplicatedStorage.Stand.Modules
-- strip("DioMove", phases, spacing, facing, zOffset) or strip("DioSummon", times, ...)
local Players = game:GetService("Players")
local root = game.ReplicatedStorage.Stand
local Poser = require(root.Modules.Poser)
local Clips = require(root.Modules.Clips)
local char = Players.LocalPlayer.Character
local hrp = char.HumanoidRootPart
char.Archivable = true
local function strip(clipName, ctxList, spacing, facing, zOff)
	local old = workspace:FindFirstChild("Strip")
	if old then old:Destroy() end
	local folder = Instance.new("Folder")
	folder.Name = "Strip"
	folder.Parent = workspace
	local base = hrp.CFrame * CFrame.new(-spacing * (#ctxList - 1) / 2, 0, zOff or -8)
	for i, c in ipairs(ctxList) do
		local clone = char:Clone()
		clone.Name = "Ghost" .. i
		for _, d in ipairs(clone:GetDescendants()) do
			if d:IsA("LuaSourceContainer") or d:IsA("Sound") or d:IsA("ParticleEmitter") or d:IsA("PointLight") then
				d:Destroy()
			end
		end
		local h = clone:FindFirstChildOfClass("Humanoid")
		if h then h:Destroy() end
		local st = clone:FindFirstChild("Stand")
		if st then st:Destroy() end
		local m = clone.HumanoidRootPart:FindFirstChild("StandRoot")
		if m then m:Destroy() end
		clone.HumanoidRootPart.Anchored = true
		clone:PivotTo(base * CFrame.new(spacing * (i - 1), 0, 0) * CFrame.Angles(0, facing or 0, 0))
		clone.Parent = folder
		local rig = Poser.attach(clone, table.clone(c))
		rig:play(Clips[clipName], {fadeIn = 0, speed = 0, startAt = c.t or 0})
	end
	-- a light so the strip reads at dusk
	local lp = Instance.new("Part")
	lp.Anchored = true
	lp.CanCollide = false
	lp.Transparency = 1
	lp.CFrame = base * CFrame.new(spacing * (#ctxList - 1) / 2, 4, -8)
	lp.Parent = folder
	local l = Instance.new("PointLight")
	l.Brightness = 2.2
	l.Range = 45
	l.Parent = lp
	return base
end
_G.strip = strip
-- example: eight walk phases seen from the side; camera at local (0, 4.6, zOff - 9) looking at (0, 4, zOff)
local list = {}
for i = 0, 7 do
	table.insert(list, {phase = i / 8 * math.pi * 2, speed = 16, walk = 1, air = 0, land = 0, jump = 0, t = 0})
end
strip("DioMove", list, 3.4, -math.pi / 2, -8)
local camPos = hrp.CFrame:PointToWorldSpace(Vector3.new(0, 4.6, -17))
local look = hrp.CFrame:PointToWorldSpace(Vector3.new(0, 4, -8))
return string.format("cam=[%.2f,%.2f,%.2f] target=[%.2f,%.2f,%.2f]", camPos.X, camPos.Y, camPos.Z, look.X, look.Y, look.Z)
