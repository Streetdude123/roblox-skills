local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local kit = ServerStorage.VfxKit
local log = {}
local function note(s) table.insert(log, s) end

local root = ReplicatedStorage:FindFirstChild("Stand") or Instance.new("Folder")
root.Name = "Stand"
root.Parent = ReplicatedStorage
local function folder(parent, name)
	local f = parent:FindFirstChild(name) or Instance.new("Folder")
	f.Name = name
	f.Parent = parent
	return f
end
local assets = folder(root, "Assets")
local vfx = folder(assets, "Vfx")
local meshes = folder(assets, "Meshes")
local sounds = folder(assets, "Sounds")
folder(root, "Modules")
local remotes = folder(root, "Remotes")
for _, n in ipairs({"SummonRequest", "Summon", "MoveRequest", "Move", "Hit"}) do
	if not remotes:FindFirstChild(n) then
		local r = Instance.new("RemoteEvent")
		r.Name = n
		r.Parent = remotes
	end
end

-- a template part is anchored and invisible with every emitter and beam switched off until code asks
local function prepTemplate(inst, name)
	inst.Name = name
	if inst:IsA("BasePart") then
		inst.Anchored = true
		inst.CanCollide = false
		inst.CanQuery = false
		inst.CanTouch = false
		inst.Transparency = 1
		inst.CastShadow = false
	end
	for _, d in ipairs(inst:GetDescendants()) do
		if d:IsA("ParticleEmitter") then
			d.Enabled = false
		elseif d:IsA("Beam") then
			d.Enabled = false
		elseif d:IsA("LuaSourceContainer") then
			d:Destroy()
		elseif d:IsA("BasePart") then
			d.Anchored = true
			d.CanCollide = false
			d.CanQuery = false
			d.CanTouch = false
		end
	end
	return inst
end

local function cloneTo(src, dest, name)
	if not src then
		note("MISSING " .. name)
		return nil
	end
	local old = dest:FindFirstChild(name)
	if old then old:Destroy() end
	local c = src:Clone()
	prepTemplate(c, name)
	c.Parent = dest
	return c
end

-- effect templates by kit path
cloneTo(kit.Auras["RNG-Aura-01"].HumanoidRootPart, vfx, "ChainRing")
cloneTo(kit.Auras["RNG-Aura-02"].HumanoidRootPart, vfx, "GoldBurst")
cloneTo(kit.Auras["RNG-Aura-03"].HumanoidRootPart, vfx, "GreenAura")
local anime = kit.Anime
for src, name in pairs({["Lighting-03"] = "Lightning", ["Lighting-01"] = "Lightning1", ["Lighting-02"] = "Lightning2", ["Shield-Break-01"] = "ShieldBreak", ["Charge-01"] = "Charge", ["Shiny-01"] = "Shiny", ["Crack-01"] = "Crack", ["Shoot-01"] = "Shock", ["Punch-01"] = "Hit1", ["Punch-02"] = "Hit2", ["Punch-03"] = "Hit3", ["Wind-01"] = "Wind", ["Wind-02"] = "Wind2", ["Stars-01"] = "Stars", ["Slash-Impact-01"] = "SlashImpact", ["Portal-01"] = "Portal", ["Portal-Enter-01"] = "PortalEnter", ["ForceField-Break-01"] = "FieldBreak", ["Slashes-01"] = "Slashes", ["Realistic-Explosion-01"] = "RealExplosion"}) do
	cloneTo(anime:FindFirstChild(src), vfx, name)
end
local smoke = anime:FindFirstChild("Smoke-01")
cloneTo(smoke, vfx, "Smoke")
for src, name in pairs({["Tornado-01"] = "Tornado", ["Lighting-01"] = "BigLightning", ["Big-Crack-01"] = "BigCrack", ["Explosion-01"] = "BigExplosion", ["Ball-01"] = "FireBall"}) do
	cloneTo(kit.Big:FindFirstChild(src), vfx, name)
end
local pack = kit["vfx pack"]
cloneTo(pack:FindFirstChild("Explosion"), vfx, "PackExplosion")
cloneTo(pack:FindFirstChild("Projectile"), vfx, "PackProjectile")
cloneTo(pack:FindFirstChild("f"), vfx, "PackF")
cloneTo(pack:FindFirstChild("Part"), vfx, "PackPart")

-- loose parts are found by the name of an emitter inside them
local looseWanted = {["Purple Expanding"] = "PurpleExpanding", Swirling = "Swirling", Twirl = "Twirl", ["Black Swirl"] = "BlackSwirl", Core = "PurpleCore", Aura = "AuraSheet", Charged = "Charged", Shockwave = "RingShock", Circle = "CircleSheet", Yars = "Rays", MiniSparks = "MiniSparks", ["Last Particle"] = "LastParticle", Black = "BlackSheet", ["Lightning One"] = "LightningSheet", ["Dots 1"] = "Dots", Wave = "WaveBits", Sparkle = "FlareSparkle", Sparkles_Beam = "SparklesBeam", Flash = "FlashSheet", Rays = "RaysFlare"}
local looseDone = {}
for _, p in ipairs(kit.Loose:GetChildren()) do
	for _, e in ipairs(p:GetDescendants()) do
		if e:IsA("ParticleEmitter") and looseWanted[e.Name] and not looseDone[looseWanted[e.Name]] then
			looseDone[looseWanted[e.Name]] = true
			cloneTo(p, vfx, looseWanted[e.Name])
			break
		end
	end
end
for _, name in pairs(looseWanted) do
	if not looseDone[name] then note("loose missing " .. name) end
end

-- meshes by name from the vfx folder and the mesh gallery
local function findMesh(container, name, meshId)
	for _, d in ipairs(container:GetDescendants()) do
		if d:IsA("MeshPart") and d.Name == name and (not meshId or d.MeshId:find(meshId)) then
			return d
		end
	end
	return nil
end
local vfxFolder = kit.VFX
local meshWanted = {
	{"Ring", "1851169338", "Ring"},
	{"CircleShockwave", "1474874211", "CircleFlat"},
	{"Meshes/EyeRing", "4452526014", "EyeRing"},
	{"GravityBallShockwave", "750305703", "GravityShock"},
	{"Shockwave", "2788580235", "ShockDome"},
	{"Sphere", "5747850601", "Sphere"},
	{"Spiral", "6092662636", "Spiral"},
	{"Cylinder", "6063631009", "Cylinder"},
	{"RoughShockwaveElectricity", "903888897", "ElectricShock"},
	{"Meshes/Wave", "2689837482", "Wave"},
	{"LightWind", "4681227436", "LightWind"},
	{"3DStar", "4886514859", "Star3D"},
	{"InvertedSpike", "1826588507", "InvertedSpike"},
	{"Spring", "4631767253", "Spring"},
	{"FancySphere", "5703278366", "FancySphere"},
	{"Meshes/spikeyball", "3375161112", "SpikeBall"},
	{"Circle", "471124075", "CircleRing"},
	{"Meshes/WindMesh1", "4313233873", "WindMesh1"},
	{"Meshes/WindMesh2", "4313235782", "WindMesh2"},
	{"Meshes/new Wind", "4461104675", "WindNew"},
	{"Meshes/shockwave", "92588061", "ShockFlat"},
	{"Spike", "2620058357", "Spike"},
	{"GroundSpikes", "967645205", "GroundSpikes"},
}
for _, w in ipairs(meshWanted) do
	local m = findMesh(vfxFolder, w[1], w[2])
	if m then
		local c = m:Clone()
		for _, d in ipairs(c:GetDescendants()) do
			if not d:IsA("DataModelMesh") then d:Destroy() end
		end
		c.Name = w[3]
		c.Anchored = true
		c.CanCollide = false
		c.CanQuery = false
		c.CanTouch = false
		c.CastShadow = false
		c.Material = Enum.Material.Neon
		c.TextureID = ""
		local old = meshes:FindFirstChild(w[3])
		if old then old:Destroy() end
		c.Parent = meshes
	else
		note("mesh missing " .. w[1])
	end
end
local gallery = kit["Meshes/VFX"]
for _, w in ipairs({{"Lightning (Gold Skin)", "GoldLightning"}, {"ElectricShockwave(Mesh)", "ElectricRing"}, {"Ripple FX", "Ripple"}, {"Lightning", "LightningMesh"}, {"LightningStrikeMesh", "LightningStrike"}}) do
	local m
	for _, d in ipairs(gallery:GetDescendants()) do
		if d:IsA("MeshPart") and d.Name == w[1] then m = d break end
	end
	if m then
		local c = m:Clone()
		for _, d in ipairs(c:GetDescendants()) do
			if not d:IsA("DataModelMesh") then d:Destroy() end
		end
		c.Name = w[2]
		c.Anchored = true
		c.CanCollide = false
		c.CanQuery = false
		c.CanTouch = false
		c.CastShadow = false
		local old = meshes:FindFirstChild(w[2])
		if old then old:Destroy() end
		c.Parent = meshes
	else
		note("gallery mesh missing " .. w[1])
	end
end

-- sounds from the sfx library
local sfx = gallery.SFX
for _, w in ipairs({{"Shadow", "Charge", "ShadowCharge"}, {"Void", "Charge", "VoidCharge"}, {"Void", "Energy", "VoidEnergy"}, {"Void", "Release", "VoidRelease"}, {"Void", "VoidCast", "VoidCast"}, {"Light", "Shining", "Shining"}, {"Light", "LightExplosion", "LightExplosion"}, {"Light", "Beam", "LightBeam"}, {"Lightning", "Shock", "Shock"}, {"Lightning", "Damage", "ShockDamage"}, {"Misc", "Heartbeat", "Heartbeat"}, {"Ash", "Summon", "AshSummon"}, {"Combat", "Impact", "Impact"}, {"Combat", "HitStrong", "HitStrong"}, {"Misc", "ChargeMagicPower", "MagicCharge"}, {"Earth", "Earth", "EarthHit"}, {"Wind", "GaleForce", "Gale"}, {"Wind", "WindCircle", "WindCircle"}, {"Curse", "Magma", "CurseMagma"}, {"Shadow", "ShadowCircle", "ShadowCircle"}, {"Shadow", "ShadowExplosion", "ShadowExplosion"}, {"Weapons", "DramaticSlash", "DramaticSlash"}, {"Misc", "Boost", "Boost"}}) do
	local f = sfx:FindFirstChild(w[1])
	local s = f and f:FindFirstChild(w[2], true)
	if s and s:IsA("Sound") then
		local c = s:Clone()
		c.Name = w[3]
		c.Looped = false
		local old = sounds:FindFirstChild(w[3])
		if old then old:Destroy() end
		c.Parent = sounds
	else
		note("sound missing " .. w[1] .. "/" .. w[2])
	end
end
return table.concat(log, "\n") .. string.format("\nvfx=%d meshes=%d sounds=%d", #vfx:GetChildren(), #meshes:GetChildren(), #sounds:GetChildren())