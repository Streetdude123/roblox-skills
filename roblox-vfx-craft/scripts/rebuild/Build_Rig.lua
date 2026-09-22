local RS, SS = game.ReplicatedStorage, game.ServerStorage
local root = RS.Stand
local archive = SS.StandArchive
local free = workspace["The World"]
local out = {}
local function line(s) table.insert(out, s) end

-- 1. archive the untouched free model and the old dead-mesh template
local keep = free:Clone()
keep.Name = "TheWorldFreeModel"
keep.Parent = archive
local old = root.Assets.TheWorld
old.Name = "TheWorldDeadMeshes"
old.Parent = archive
line("archived old template and free model copy")

-- 2. the clips go to a replicated folder without the moon animator metadata
local anims = Instance.new("Folder")
anims.Name = "Anims"
for _, k in ipairs(free.AnimSaves:GetChildren()) do
	if k:IsA("KeyframeSequence") then
		local c = k:Clone()
		local removed = 0
		for _, d in ipairs(c:GetDescendants()) do
			if not (d:IsA("Keyframe") or d:IsA("Pose") or d:IsA("KeyframeMarker")) then
				d:Destroy()
				removed += 1
			end
		end
		c.Name = k.Name:gsub("^TW ", ""):gsub("^TW", "")
		c.Parent = anims
		line(("clip %s -> %s (%d meta removed, %d desc)"):format(k.Name, c.Name, removed, #c:GetDescendants()))
	end
end
anims.Parent = root.Assets

-- 3. the free model becomes the new template
local stand = free
stand.Name = "TheWorld"
stand.AnimSaves:Destroy()
local hum = stand:FindFirstChildOfClass("Humanoid")
if hum then hum:Destroy() end
local rename = {
	Head = "Stand Head", Torso = "Stand Torso", HumanoidRootPart = "StandHumanoidRootPart",
	["Right Arm"] = "Stand Right Arm", ["Left Arm"] = "Stand Left Arm",
	["Right Leg"] = "Stand Right Leg", ["Left Leg"] = "Stand Left Leg",
}
for _, c in ipairs(stand:GetChildren()) do
	if rename[c.Name] then
		c.Name = rename[c.Name]
	end
end
stand.PrimaryPart = stand.StandHumanoidRootPart
local dead, fx = 0, 0
for _, d in ipairs(stand:GetDescendants()) do
	if (d:IsA("Weld") or d:IsA("Snap") or d:IsA("Motor6D")) and (d.Part0 == nil or d.Part1 == nil) then
		d:Destroy()
		dead += 1
	elseif d:IsA("ParticleEmitter") or d:IsA("Trail") then
		d:Destroy()
		fx += 1
	end
end
line(("removed %d dead joints and %d free model emitters"):format(dead, fx))
local n, hidden = 0, 0
for _, d in ipairs(stand:GetDescendants()) do
	if d:IsA("BasePart") then
		n += 1
		d.Anchored = false
		d.CanCollide = false
		d.CanQuery = false
		d.CanTouch = false
		d.Massless = true
		d.CastShadow = true
		-- parts the artist left invisible stay invisible through every summon tween
		if d.Transparency >= 1 then
			d:SetAttribute("Tr", 1)
			hidden += 1
		else
			d:SetAttribute("Tr", d.Transparency)
		end
	end
end
line(("%d parts, %d hidden base parts"):format(n, hidden))
stand:PivotTo(CFrame.new(0, 0, 0))
stand.Parent = root.Assets
-- joints after the rename
for _, m in ipairs(stand:GetDescendants()) do
	if m:IsA("Motor6D") then
		line(("  joint %s: %s -> %s"):format(m.Name, m.Part0.Name, m.Part1.Name))
	end
end
return table.concat(out, "\n")