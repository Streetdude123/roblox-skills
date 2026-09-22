-- run in the edit datamodel: bakes the listed clips into KeyframeSequences on an AnimSaves model of a rig so the
-- Animation Editor or Moon Animator can load and publish them
-- moves bake at 60 fps (30 turns a 3 frame strike into 1.5 keyframes); loops bake at 30
-- fresh module copies dodge the require cache of the edit session after a Source push
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- edit these three lines per place: the feature folder, the rig, and {clipKey, savedName, fps}
local root = ReplicatedStorage:FindFirstChild("Anim") or ReplicatedStorage.Stand
local rig = ServerStorage:FindFirstChild("AnimRig") or ServerStorage.StandAnimRig
local LIST = {
	{"DioSummon", "DioSummon", 60},
	{"DioIdleBake", "DioIdle", 30},
	{"DioWalkBake", "DioWalk", 30},
	{"DioRunBake", "DioRun", 30},
	{"WorldAppear", "WorldAppear", 60},
	{"WorldIdleBake", "WorldIdle", 30},
	{"WorldVanish", "WorldVanish", 60},
}

for _, n in ipairs({"PoserBake", "ClipsBake"}) do
	local o = root.Modules:FindFirstChild(n)
	if o then
		o:Destroy()
	end
end
local oc = root:FindFirstChild("ConfigBake")
if oc then
	oc:Destroy()
end
local poserCopy = root.Modules.Poser:Clone()
poserCopy.Name = "PoserBake"
poserCopy.Parent = root.Modules
local clipsCopy = root.Modules.Clips:Clone()
clipsCopy.Name = "ClipsBake"
clipsCopy.Source = clipsCopy.Source:gsub("require%(script%.Parent%.Poser%)", "require(script.Parent.PoserBake)")
local config = root:FindFirstChild("Config")
local configCopy
if config then
	configCopy = config:Clone()
	configCopy.Name = "ConfigBake"
	configCopy.Parent = root
	clipsCopy.Source = clipsCopy.Source:gsub("require%(root%.Config%)", "require(root.ConfigBake)")
end
clipsCopy.Parent = root.Modules
local Poser = require(poserCopy)
local Clips = require(clipsCopy)
local saves = rig:FindFirstChild("AnimSaves") or Instance.new("Model")
saves.Name = "AnimSaves"
saves.Parent = rig
local prig = Poser.attach(rig)
local out = {}
for _, item in ipairs(LIST) do
	local clip = Clips[item[1]]
	if clip then
		local old = saves:FindFirstChild(item[2])
		if old then
			old:Destroy()
		end
		local kfs = Poser.bake(clip, prig, item[3] or 30, item[2])
		kfs.Parent = saves
		table.insert(out, string.format("%s %d kf at %d fps", item[2], #kfs:GetKeyframes(), item[3] or 30))
	else
		table.insert(out, item[1] .. " missing")
	end
end
poserCopy:Destroy()
clipsCopy:Destroy()
if configCopy then
	configCopy:Destroy()
end
return table.concat(out, "\n")
