local http = game:GetService("HttpService")
local lighting = game:GetService("Lighting")
local matService = game:GetService("MaterialService")

local root = ...
root = root or workspace

local count = { parts = 0, meshes = 0, unions = 0, surface = 0, textured = 0, doubleSided = 0, transparent = 0, neon = 0, decals = 0 }
local mats, cols, fid, coll = {}, {}, {}, {}
local meshIds, texIds = {}, {}
local sizes, meshSizes = {}, {}
local big = {}

local function area(s)
	return 2 * (s.X * s.Y + s.Y * s.Z + s.X * s.Z)
end

for _, d in root:GetDescendants() do
	if d:IsA("BasePart") and d ~= workspace.Terrain then
		count.parts += 1
		local a = area(d.Size)
		mats[d.Material.Name] = (mats[d.Material.Name] or 0) + a
		local c = d.Color
		local key = string.format("%02X%02X%02X", math.floor(c.R * 15 + 0.5) * 17, math.floor(c.G * 15 + 0.5) * 17, math.floor(c.B * 15 + 0.5) * 17)
		cols[key] = (cols[key] or 0) + a
		table.insert(sizes, d.Size.Magnitude)
		if d.Transparency > 0.05 and d.Transparency < 1 then
			count.transparent += 1
		end
		if d.Material == Enum.Material.Neon then
			count.neon += 1
		end
		coll[d.CollisionFidelity and d.CollisionFidelity.Name or "Part"] = (coll[d.CollisionFidelity and d.CollisionFidelity.Name or "Part"] or 0) + 1
		if d:IsA("MeshPart") then
			count.meshes += 1
			table.insert(meshSizes, d.Size.Magnitude)
			local ok, id = pcall(function()
				return d.MeshId
			end)
			if ok and id ~= "" then
				meshIds[id] = (meshIds[id] or 0) + 1
			end
			if d.TextureID ~= "" then
				count.textured += 1
				texIds[d.TextureID] = true
			end
			if d.DoubleSided then
				count.doubleSided += 1
			end
			local okf, f = pcall(function()
				return d.RenderFidelity.Name
			end)
			if okf then
				fid[f] = (fid[f] or 0) + 1
			end
			if d:FindFirstChildOfClass("SurfaceAppearance") then
				count.surface += 1
			end
			table.insert(big, { d:GetFullName(), d.Size.Magnitude, d.TextureID ~= "", d:FindFirstChildOfClass("SurfaceAppearance") ~= nil, d.Material.Name })
		elseif d:IsA("UnionOperation") then
			count.unions += 1
		end
	elseif d:IsA("Decal") or d:IsA("Texture") then
		count.decals += 1
	end
end

local function top(t, n)
	local arr, tot = {}, 0
	for k, v in t do
		table.insert(arr, { k, v })
		tot += v
	end
	table.sort(arr, function(a, b)
		return a[2] > b[2]
	end)
	local res = {}
	for i = 1, math.min(n, #arr) do
		table.insert(res, { arr[i][1], math.floor(arr[i][2] / math.max(tot, 1e-6) * 1000 + 0.5) / 10 })
	end
	return res
end

local function pct(arr, p)
	if #arr == 0 then
		return 0
	end
	table.sort(arr)
	return math.floor(arr[math.max(1, math.floor(#arr * p))] * 100 + 0.5) / 100
end

table.sort(big, function(a, b)
	return a[2] > b[2]
end)
local bigList = {}
for i = 1, math.min(12, #big) do
	table.insert(bigList, { big[i][1], math.floor(big[i][2] * 10) / 10, big[i][3], big[i][4], big[i][5] })
end

local uniqMesh, uniqTex = 0, 0
for _ in meshIds do
	uniqMesh += 1
end
for _ in texIds do
	uniqTex += 1
end

local fx = {}
for _, e in lighting:GetChildren() do
	local row = { e.ClassName, e.Name }
	if e:IsA("Atmosphere") then
		table.insert(row, string.format("density %.2f haze %.2f glare %.2f", e.Density, e.Haze, e.Glare))
	elseif e:IsA("BloomEffect") then
		table.insert(row, string.format("intensity %.2f size %d threshold %.2f", e.Intensity, e.Size, e.Threshold))
	elseif e:IsA("ColorCorrectionEffect") then
		table.insert(row, string.format("brightness %.2f contrast %.2f saturation %.2f tint %s", e.Brightness, e.Contrast, e.Saturation, tostring(e.TintColor)))
	end
	table.insert(fx, row)
end

local variants = {}
for _, v in matService:GetDescendants() do
	if v:IsA("MaterialVariant") then
		table.insert(variants, { v.Name, v.BaseMaterial.Name, v.StudsPerTile })
	end
end

local tech = pcall(function()
	return lighting.Technology.Name
end) and lighting.Technology.Name or "?"

return http:JSONEncode({
	root = root:GetFullName(),
	count = count,
	uniqueMeshes = uniqMesh,
	uniqueTextures = uniqTex,
	materialsByArea = top(mats, 10),
	paletteByArea = top(cols, 14),
	renderFidelity = fid,
	collision = coll,
	partSize = { p50 = pct(sizes, 0.5), p90 = pct(sizes, 0.9) },
	meshSize = { p50 = pct(meshSizes, 0.5), p90 = pct(meshSizes, 0.9) },
	largestMeshes = bigList,
	lighting = {
		technology = tech,
		brightness = lighting.Brightness,
		clock = lighting.ClockTime,
		ambient = tostring(lighting.Ambient),
		outdoor = tostring(lighting.OutdoorAmbient),
		shadows = lighting.GlobalShadows,
		diffuseScale = lighting.EnvironmentDiffuseScale,
		specularScale = lighting.EnvironmentSpecularScale,
		exposure = lighting.ExposureCompensation,
	},
	effects = fx,
	materialVariants = variants,
})
