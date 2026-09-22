-- run in the edit datamodel: lays candidate meshes in a row at the proportions they will be used at,
-- labels each with its name, and returns a camera position for one screen_capture
-- mesh names lie ("Ring" was a solid cube once) so this is the only honest way to pick a mesh
local SOURCE = game:GetService("ServerStorage"):FindFirstChild("VfxKit")
local NAMES = {"Ring", "ShockDisc", "SlashArc", "Flash", "Spike", "Beam"}
-- the proportions of the real use: a blade is long and thin on y, a ground ring is flat on y
local SIZE = Vector3.new(12, 12 * 0.014, 12 * 0.35)
local SPACING = 16
local AT = Vector3.new(0, 60, -2600)

local old = workspace:FindFirstChild("MeshGallery")
if old then
	old:Destroy()
end
local folder = Instance.new("Folder")
folder.Name = "MeshGallery"
folder.Parent = workspace

local function find(name)
	for _, d in ipairs(SOURCE:GetDescendants()) do
		if d.Name == name and (d:IsA("MeshPart") or (d:IsA("BasePart") and d:FindFirstChildOfClass("SpecialMesh"))) then
			return d
		end
	end
end

local shown = 0
for i, name in ipairs(NAMES) do
	local src = find(name)
	if src then
		local m = src:Clone()
		for _, c in ipairs(m:GetChildren()) do
			if not c:IsA("DataModelMesh") then
				c:Destroy()
			end
		end
		m.Anchored = true
		m.CanCollide = false
		m.Size = SIZE
		m.Material = Enum.Material.Neon
		m.Color = Color3.new(1, 1, 1)
		m.Transparency = 0
		m.CFrame = CFrame.new(AT + Vector3.new((i - (#NAMES + 1) / 2) * SPACING, 0, 0))
		m.Parent = folder
		local bb = Instance.new("BillboardGui")
		bb.Size = UDim2.fromOffset(200, 40)
		bb.StudsOffset = Vector3.new(0, 4, 0)
		bb.AlwaysOnTop = false
		local tl = Instance.new("TextLabel")
		tl.Size = UDim2.fromScale(1, 1)
		tl.BackgroundTransparency = 1
		tl.TextColor3 = Color3.new(1, 1, 1)
		tl.TextScaled = true
		tl.Text = name .. " " .. (m:IsA("MeshPart") and m.MeshId:match("%d+") or "")
		tl.Parent = bb
		bb.Parent = m
		shown += 1
	end
end
local lp = Instance.new("Part")
lp.Anchored = true
lp.Transparency = 1
lp.CanCollide = false
lp.CFrame = CFrame.new(AT + Vector3.new(0, 8, 10))
lp.Parent = folder
local l = Instance.new("PointLight")
l.Brightness = 2
l.Range = 120
l.Parent = lp
-- a three quarter view from above shows the thin axis and the outline at once
local cam = AT + Vector3.new(0, 26, 46)
return string.format("%d meshes; capture camera_position [%d,%d,%d] look_at [%d,%d,%d]", shown, cam.X, cam.Y, cam.Z, AT.X, AT.Y, AT.Z)
