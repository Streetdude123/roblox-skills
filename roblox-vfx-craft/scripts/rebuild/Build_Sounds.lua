local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local StarterPlayer = game:GetService("StarterPlayer")
local root = ReplicatedStorage.Stand
local assets = root.Assets
local sounds = assets.Sounds
local log = {}
local function note(s) table.insert(log, s) end

local archive = ServerStorage:FindFirstChild("StandArchive") or Instance.new("Folder")
archive.Name = "StandArchive"
archive.Parent = ServerStorage
local animArchive = archive:FindFirstChild("Animations") or Instance.new("Folder")
animArchive.Name = "Animations"
animArchive.Parent = archive
local peArchive = archive:FindFirstChild("OldEmitters") or Instance.new("Folder")
peArchive.Name = "OldEmitters"
peArchive.Parent = archive

local stand = workspace:FindFirstChild("Stand") or assets:FindFirstChild("TheWorld")
if stand.Parent == workspace then
	local hrp = stand.StandHumanoidRootPart
	-- the old animation ids belong to another game and never play so they go to the archive
	for _, a in ipairs(hrp:GetChildren()) do
		if a:IsA("Animation") then
			a.Parent = animArchive
		elseif a:IsA("Sound") then
			local old = sounds:FindFirstChild(a.Name)
			if old then old:Destroy() end
			a.Parent = sounds
		end
	end
	-- one root joint is enough
	local seen = false
	for _, m in ipairs(hrp:GetChildren()) do
		if m:IsA("Motor6D") and m.Name == "RootJoint" then
			if seen then
				m:Destroy()
				note("dropped duplicate RootJoint")
			end
			seen = true
		end
	end
	-- the summon attachments hold old emitters that the new sequence replaces
	for _, d in ipairs(stand:GetDescendants()) do
		if d:IsA("Attachment") and d.Name == "SummonParticle" then
			d.Parent = peArchive
		end
	end
	for _, p in ipairs(stand:GetDescendants()) do
		if p:IsA("BasePart") then
			p.Anchored = false
			p.CanCollide = false
			p.CanQuery = false
			p.CanTouch = false
			p.Massless = true
			p.CastShadow = true
		end
	end
	stand.PrimaryPart = hrp
	stand.Name = "TheWorld"
	stand.Parent = assets
	note("stand moved with " .. #stand:GetDescendants() .. " descendants")
end

-- the grey rig becomes the spawn body
local sc = workspace:FindFirstChild("StarterCharacter")
if sc then
	local old = StarterPlayer:FindFirstChild("StarterCharacter")
	if old then
		old.Name = "StarterCharacter_old"
		old.Parent = archive
	end
	sc.HumanoidRootPart.Anchored = false
	sc.PrimaryPart = sc.HumanoidRootPart
	sc.Parent = StarterPlayer
	note("starter character set")
end

-- a dusk mood with bloom so gold and violet glow read
local world = {ClockTime = Lighting.ClockTime, Brightness = Lighting.Brightness, Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient, ExposureCompensation = Lighting.ExposureCompensation, EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale, EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale}
if not Lighting:GetAttribute("Backup") then
	local s = {}
	for k, v in pairs(world) do table.insert(s, k .. "=" .. tostring(v)) end
	Lighting:SetAttribute("Backup", table.concat(s, ";"))
end
Lighting.ClockTime = 18.35
Lighting.Brightness = 1.8
Lighting.Ambient = Color3.fromRGB(38, 30, 52)
Lighting.OutdoorAmbient = Color3.fromRGB(78, 62, 104)
Lighting.ExposureCompensation = 0.1
Lighting.EnvironmentDiffuseScale = 0.6
Lighting.EnvironmentSpecularScale = 0.6
local atm = Lighting:FindFirstChildOfClass("Atmosphere")
if atm then
	atm:SetAttribute("Backup", string.format("%.2f;%.2f;%.2f;%s", atm.Density, atm.Haze, atm.Glare, tostring(atm.Color)))
	atm.Density = 0.36
	atm.Haze = 1.2
	atm.Glare = 0.3
	atm.Color = Color3.fromRGB(150, 120, 190)
	atm.Decay = Color3.fromRGB(70, 40, 110)
end
local bloom = Lighting:FindFirstChildOfClass("BloomEffect")
if bloom then
	bloom.Enabled = true
	bloom.Intensity = 0.55
	bloom.Size = 30
	bloom.Threshold = 1.0
end
local dof = Lighting:FindFirstChildOfClass("DepthOfFieldEffect")
if dof then dof.Enabled = false end
local sun = Lighting:FindFirstChildOfClass("SunRaysEffect")
if sun then sun.Intensity = 0.08 end
local base = workspace.Baseplate
base:SetAttribute("Backup", tostring(base.Color) .. ";" .. tostring(base.Material))
base.Color = Color3.fromRGB(34, 30, 42)
base.Material = Enum.Material.Slate
note(string.format("sounds now %d", #sounds:GetChildren()))
return table.concat(log, "\n")