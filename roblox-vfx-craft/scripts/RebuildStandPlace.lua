-- run in the edit datamodel of a fresh place that holds his VFX packs loose in workspace, the old "Stand" model
-- (the 70 sounds live under its StandHumanoidRootPart), the free model "The World" (8 Moon clips in AnimSaves)
-- and the grey R6 "StarterCharacter": rebuilds every folder the DIO kit needs in one pass, in the order the
-- 2026-09-21/22 sessions did it by hand. The module sources come from the source server afterwards
-- (node serve.js, then Instance.new("ModuleScript") with .Source = GetAsync(...) works from execute_luau).
-- Steps 1 to 4 are the exact scripts of those sessions; step 5 is the road roller (asset 121007269169300).
local HttpService = game:GetService("HttpService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local out = {}
local function note(s) table.insert(out, s) end

-- 1. the kit goes to ServerStorage.VfxKit: groups as they are, loose parts to Loose, decal-only parts to DecalRefs
local keep = {Camera = true, Terrain = true, Baseplate = true, SpawnLocation = true, Stand = true, StarterCharacter = true, ["The World"] = true}
local kit = ServerStorage:FindFirstChild("VfxKit") or Instance.new("Folder")
kit.Name = "VfxKit"
kit.Parent = ServerStorage
local loose = kit:FindFirstChild("Loose") or Instance.new("Folder")
loose.Name = "Loose"
loose.Parent = kit
local decals = kit:FindFirstChild("DecalRefs") or Instance.new("Folder")
decals.Name = "DecalRefs"
decals.Parent = kit
for _, c in ipairs(workspace:GetChildren()) do
	if not keep[c.Name] then
		if c:IsA("BasePart") then
			if c:FindFirstChildWhichIsA("Decal") and not c:FindFirstChildWhichIsA("ParticleEmitter", true) then
				c.Parent = decals
			else
				c.Parent = loose
			end
		else
			c.Parent = kit
		end
	end
end
note("kit archived: " .. #kit:GetDescendants() .. " instances")

-- 2 to 4. the template folders, the sounds and lighting, the free model rig, the dead sounds: the four scripts
-- Build_Templates.lua, Build_Sounds.lua, Build_Rig.lua and Build_Dead.lua served next to the modules
HttpService.HttpEnabled = true
for _, name in ipairs({"Build_Templates", "Build_Sounds", "Build_Rig", "Build_Dead"}) do
	local src = HttpService:GetAsync("http://127.0.0.1:8766/stand/" .. name .. ".lua")
	local fn, err = loadstring(src)
	if not fn then
		note(name .. " SYNTAX " .. tostring(err))
	else
		local ok, res = pcall(fn)
		note(name .. " -> " .. tostring(ok) .. " " .. tostring(res):sub(1, 200))
	end
end

-- 5. the modules and the scripts from the served sources
local root = ReplicatedStorage.Stand
local function make(parent, class, name)
	local old = parent:FindFirstChild(name)
	if old then old:Destroy() end
	local src = HttpService:GetAsync("http://127.0.0.1:8766/stand/" .. name .. ".lua")
	local fn, err = loadstring(src)
	if not fn then
		note(name .. " SYNTAX " .. tostring(err))
		return
	end
	local s = Instance.new(class)
	s.Name = name
	s.Source = src
	s.Parent = parent
end
make(root, "ModuleScript", "Config")
for _, n in ipairs({"Tw", "Emitters", "Kit", "ImpactFrames", "ScreenFx", "SpeedLines", "CameraRig", "Poser", "Clips", "Locomotion", "SummonVfx", "Moves", "TimeStop", "RoadRoller"}) do
	make(root.Modules, "ModuleScript", n)
end
make(game.ServerScriptService, "Script", "StandServer")
make(game.ServerScriptService, "Script", "MovesServer")
make(StarterPlayer.StarterPlayerScripts, "LocalScript", "StandClient")
HttpService.HttpEnabled = false
note("modules and scripts written")

-- 6. the test dummy and the bake rig (the road roller is inserted by insert_asset 121007269169300 into
-- ServerStorage first, then scaled 16/50 and moved: see the DIO memory)
local old = workspace:FindFirstChild("TestDummy")
if old then old:Destroy() end
local dummy = game.Players:CreateHumanoidModelFromDescription(Instance.new("HumanoidDescription"), Enum.HumanoidRigType.R6)
dummy.Name = "TestDummy"
dummy:PivotTo(CFrame.new(16, 3.5, -5) * CFrame.Angles(0, math.pi, 0))
dummy.Parent = workspace
dummy:FindFirstChildOfClass("Humanoid").MaxHealth = 500
dummy:FindFirstChildOfClass("Humanoid").Health = 500
local oldRig = ServerStorage:FindFirstChild("StandAnimRig")
if oldRig then oldRig:Destroy() end
local rig = StarterPlayer.StarterCharacter:Clone()
rig.Name = "StandAnimRig"
for _, d in ipairs(rig:GetDescendants()) do
	if d:IsA("LuaSourceContainer") then d:Destroy() end
end
local stand = root.Assets.TheWorld:Clone()
stand.Name = "Stand"
stand:PivotTo(rig.HumanoidRootPart.CFrame * CFrame.new(2.6, 1.8, 1.6))
local motor = Instance.new("Motor6D")
motor.Name = "StandRoot"
motor.Part0 = rig.HumanoidRootPart
motor.Part1 = stand.StandHumanoidRootPart
motor.Parent = rig.HumanoidRootPart
stand.Parent = rig
rig.Parent = ServerStorage
local saves = Instance.new("Model")
saves.Name = "AnimSaves"
saves.Parent = rig
note("dummy and bake rig made; bake with Bake.lua in batches of five, never a held clip without a length")
return table.concat(out, "\n")
