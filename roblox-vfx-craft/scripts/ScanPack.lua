-- run in the edit datamodel on a freshly inserted pack: lists every script with the dangerous calls it
-- contains and any long numeric array (a byte array payload), then counts what the pack is made of
-- usage: set PACK to the pack root before running; nothing is changed by this script
local PACK = workspace:FindFirstChild("VfxKit") or game:GetService("ServerStorage"):FindFirstChild("VfxKit")
if not PACK then
	return "set PACK to the pack root"
end

local BAD = {"require%s*%(", "getfenv", "setfenv", "loadstring", "GetObjects", "InsertService", "HttpService", "MarketplaceService", "TeleportService", "string%.char", "string%.reverse", "%.Source%s*="}

local lines = {}
local scripts = 0
for _, d in ipairs(PACK:GetDescendants()) do
	if d:IsA("LuaSourceContainer") then
		scripts += 1
		local src = ""
		pcall(function()
			src = d.Source
		end)
		local flags = {}
		for _, pat in ipairs(BAD) do
			if src:find(pat) then
				table.insert(flags, (pat:gsub("%%", "")))
			end
		end
		-- a numeric array over twenty entries is how a payload hides from keyword scans
		local longest = 0
		for arr in src:gmatch("{([%d%s,]+)}") do
			local n = select(2, arr:gsub("%d+", ""))
			if n > longest then
				longest = n
			end
		end
		if longest > 20 then
			table.insert(flags, "bytearray(" .. longest .. ")")
		end
		table.insert(lines, string.format("%s | %s | %d chars | %s | %s", d.ClassName, d:GetFullName(), #src, d.Enabled == false and "disabled" or "ENABLED", #flags > 0 and table.concat(flags, ",") or "clean"))
	end
end

local classes = {}
local textures = {}
local meshes = {}
for _, d in ipairs(PACK:GetDescendants()) do
	classes[d.ClassName] = (classes[d.ClassName] or 0) + 1
	if d:IsA("ParticleEmitter") or d:IsA("Beam") or d:IsA("Trail") then
		local t = d.Texture
		if t and t ~= "" then
			textures[t] = (textures[t] or 0) + 1
		end
	elseif d:IsA("MeshPart") then
		meshes[d.MeshId] = (meshes[d.MeshId] or 0) + 1
	elseif d:IsA("SpecialMesh") then
		meshes[d.MeshId] = (meshes[d.MeshId] or 0) + 1
	end
end
local summary = {}
for k, v in pairs(classes) do
	table.insert(summary, k .. "=" .. v)
end
table.sort(summary)
local nTex, nMesh = 0, 0
for _ in pairs(textures) do nTex += 1 end
for _ in pairs(meshes) do nMesh += 1 end

local out = {string.format("%s: %d scripts, %d unique textures, %d unique meshes", PACK:GetFullName(), scripts, nTex, nMesh)}
for _, l in ipairs(lines) do
	table.insert(out, l)
end
table.insert(out, table.concat(summary, " "))
return table.concat(out, "\n")
