local http = game:GetService("HttpService")
local assets = game:GetService("AssetService")

local base, name, at, flip, size = ...
size = size or 512

local abc = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local dec = {}
for i = 1, 64 do
	dec[string.byte(abc, i)] = i - 1
end
dec[string.byte("=")] = 0

local function fetch(file)
	local n = tonumber(http:GetAsync(base .. "/n/" .. file))
	local bits = table.create(n)
	for k = 0, n - 1 do
		bits[k + 1] = http:GetAsync(base .. "/f/" .. file .. "?part=" .. k)
	end
	return table.concat(bits)
end

local function unb64(s)
	local pad = (string.sub(s, -2) == "==" and 2) or (string.sub(s, -1) == "=" and 1) or 0
	local n = #s // 4 * 3 - pad
	local out = buffer.create(n)
	local o = 0
	for i = 1, #s, 4 do
		local a, b, c, d = string.byte(s, i, i + 3)
		local v = dec[a] * 262144 + dec[b] * 4096 + dec[c] * 64 + dec[d]
		buffer.writeu8(out, o, bit32.rshift(v, 16))
		if o + 1 < n then
			buffer.writeu8(out, o + 1, bit32.band(bit32.rshift(v, 8), 255))
		end
		if o + 2 < n then
			buffer.writeu8(out, o + 2, bit32.band(v, 255))
		end
		o += 3
	end
	return out
end

local function image(file)
	local ok, raw = pcall(fetch, file)
	if not ok then
		return nil
	end
	local buf = unb64(raw)
	local img = assets:CreateEditableImage({ Size = Vector2.new(size, size) })
	img:WritePixelsBuffer(Vector2.zero, Vector2.new(size, size), buf)
	return img
end

local d = http:JSONDecode(fetch(name .. ".json"))
local em = assets:CreateEditableMesh({})
local vid = table.create(#d.v)
for i, p in d.v do
	vid[i] = em:AddVertex(Vector3.new(p[1], p[2], p[3]))
end
local hasUv = #d.uv > 0
for k, t in d.t do
	local i0, i1, i2 = t[1] + 1, t[2] + 1, t[3] + 1
	local c0, c1, c2 = 1, 2, 3
	if flip then
		i1, i2 = i2, i1
		c1, c2 = 3, 2
	end
	local f = em:AddTriangle(vid[i0], vid[i1], vid[i2])
	local n = d.n[k]
	em:SetFaceNormals(f, {
		em:AddNormal(Vector3.new(n[c0][1], n[c0][2], n[c0][3])),
		em:AddNormal(Vector3.new(n[c1][1], n[c1][2], n[c1][3])),
		em:AddNormal(Vector3.new(n[c2][1], n[c2][2], n[c2][3])),
	})
	if hasUv then
		local u = d.uv[k]
		em:SetFaceUVs(f, {
			em:AddUV(Vector2.new(u[c0][1], u[c0][2])),
			em:AddUV(Vector2.new(u[c1][1], u[c1][2])),
			em:AddUV(Vector2.new(u[c2][1], u[c2][2])),
		})
	end
end

local part = assets:CreateMeshPartAsync(Content.fromObject(em))
part.Name = name
part.Anchored = true
part.Color = Color3.new(1, 1, 1)
local folder = workspace.CurrentCamera:FindFirstChild("ModelPreview") or Instance.new("Folder")
folder.Name = "ModelPreview"
folder.Parent = workspace.CurrentCamera
part.CFrame = CFrame.new(at + Vector3.new(0, part.Size.Y / 2, 0))
local sa = Instance.new("SurfaceAppearance")
local set = {}
for _, pair in { { "color", "ColorMapContent" }, { "normal", "NormalMapContent" }, { "rough", "RoughnessMapContent" }, { "metal", "MetalnessMapContent" } } do
	local img = image(name .. "_" .. pair[1] .. ".rgba")
	if img then
		local ok = pcall(function()
			sa[pair[2]] = Content.fromObject(img)
		end)
		set[pair[1]] = ok
		if not ok and pair[1] == "color" then
			part.TextureContent = Content.fromObject(img)
		end
	end
end
sa.Parent = part
part.Parent = folder
return http:JSONEncode({ name = name, size = { part.Size.X, part.Size.Y, part.Size.Z }, tris = #d.t, maps = set })
