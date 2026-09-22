-- run in the edit datamodel: bakes every clip at 30 fps into KeyframeSequences on an AnimSaves model of a rig
-- so the Animation Editor or Moon Animator can load and publish them
-- fresh module copies dodge the require cache of the edit session after a Source push
local ServerStorage = game:GetService("ServerStorage")
local root = game.ReplicatedStorage.Stand
local rig = ServerStorage.StandAnimRig
local poserCopy = root.Modules.Poser:Clone()
poserCopy.Name = "PoserBake"
poserCopy.Parent = root.Modules
local configCopy = root.Config:Clone()
configCopy.Name = "ConfigBake"
configCopy.Parent = root
local clipsCopy = root.Modules.Clips:Clone()
clipsCopy.Name = "ClipsBake"
clipsCopy.Source = clipsCopy.Source:gsub("require%(script%.Parent%.Poser%)", "require(script.Parent.PoserBake)"):gsub("require%(root%.Config%)", "require(root.ConfigBake)")
clipsCopy.Parent = root.Modules
local Poser = require(poserCopy)
local Clips = require(clipsCopy)
local saves = rig:FindFirstChild("AnimSaves") or Instance.new("Model")
saves.Name = "AnimSaves"
saves.Parent = rig
saves:ClearAllChildren()
local prig = Poser.attach(rig)
local out = {}
for _, item in ipairs({{"DioSummon", "DioSummon"}, {"DioIdleBake", "DioIdle"}, {"DioWalkBake", "DioWalk"}, {"WorldAppear", "WorldAppear"}, {"WorldIdleBake", "WorldIdle"}, {"WorldVanish", "WorldVanish"}}) do
	local kfs = Poser.bake(Clips[item[1]], prig, 30, item[2])
	kfs.Parent = saves
	table.insert(out, string.format("%s %d keyframes", item[2], #kfs:GetKeyframes()))
end
poserCopy:Destroy()
clipsCopy:Destroy()
configCopy:Destroy()
return table.concat(out, "\n")
