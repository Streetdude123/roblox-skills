-- run in the client datamodel in play through execute_luau: freezes copies of the character along a line so one
-- capture shows a whole cycle or a whole move; needs Poser and Clips in ReplicatedStorage.Anim or .Stand Modules
-- walk:  strip("DioMove", {{phase = 0, speed = 16, walk = 1, t = 0}, ...}, 3.4, FACE.side, -8)
-- move:  strip("DioSummon", {{t = 0}, {t = 0.08}, {t = 0.15}, {t = 0.25}, {t = 0.34}, {t = 0.5}, {t = 0.86}, {t = 1.2}}, 3.4, FACE.rear, -8)
-- pick the beat times from the beat table (every snap, hold, arrival and settle key), then capture rear first, front second
-- the returned string is the screen_capture camera_position and look_at_position; nudge them 0.1 stud between captures
local Players = game:GetService("Players")
local root = game.ReplicatedStorage:FindFirstChild("Anim") or game.ReplicatedStorage.Stand
local Poser = require(root.Modules.Poser)
local Clips = require(root.Modules.Clips)
local char = Players.LocalPlayer.Character
local hrp = char.HumanoidRootPart
char.Archivable = true
-- ghosts face the camera at local -z: front shows the face, rear shows what the player sees, side shows the arcs
local FACE = {front = 0, side = -math.pi / 2, rear = math.pi, rear34 = math.pi * 0.75, front34 = -math.pi / 4}
_G.FACE = FACE
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
-- for a move: replace the list with the keyed times above and use FACE.rear34 then FACE.front
local list = {}
for i = 0, 7 do
	table.insert(list, {phase = i / 8 * math.pi * 2, speed = 16, walk = 1, air = 0, land = 0, jump = 0, t = 0})
end
strip("DioMove", list, 3.4, FACE.side, -8)
local camPos = hrp.CFrame:PointToWorldSpace(Vector3.new(0, 4.6, -17))
local look = hrp.CFrame:PointToWorldSpace(Vector3.new(0, 4, -8))
return string.format("cam=[%.2f,%.2f,%.2f] target=[%.2f,%.2f,%.2f]", camPos.X, camPos.Y, camPos.Z, look.X, look.Y, look.Z)
