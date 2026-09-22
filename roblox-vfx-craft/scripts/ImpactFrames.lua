local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Tw = require(script.Parent.Tw)

local ImpactFrames = {}

local STYLES = {
	white = {bg = Color3.new(1, 1, 1), fill = Color3.new(0, 0, 0)},
	black = {bg = Color3.new(0, 0, 0), fill = Color3.new(1, 1, 1)},
	blue = {bg = Color3.fromRGB(0, 225, 255), fill = Color3.fromRGB(8, 10, 70)},
	red = {bg = Color3.fromRGB(255, 30, 60), fill = Color3.new(0, 0, 0)},
	gold = {bg = Color3.fromRGB(255, 200, 40), fill = Color3.fromRGB(45, 10, 60)},
	purple = {bg = Color3.fromRGB(70, 20, 110), fill = Color3.fromRGB(255, 225, 120)},
	green = {bg = Color3.fromRGB(60, 240, 120), fill = Color3.fromRGB(30, 10, 50)},
}

local active = false

-- a flat clone keeps only its mesh so the viewport draws a clean cutout with no textures or sounds
-- even black neon and black plastic render grey in a viewport so a dark fill paints the ambient and the clone stays white plastic
local function flatClone(part, dark)
	local c = part:Clone()
	for _, d in ipairs(c:GetChildren()) do
		if not d:IsA("DataModelMesh") then
			d:Destroy()
		else
			pcall(function()
				d.TextureId = ""
			end)
		end
	end
	c.Material = dark and Enum.Material.SmoothPlastic or Enum.Material.Neon
	c.Transparency = 0
	c.CastShadow = false
	if c:IsA("MeshPart") then
		c.TextureID = ""
	end
	return c
end

local function collect(targets)
	local parts = {}
	for _, t in ipairs(targets) do
		if t and t.Parent then
			if t:IsA("BasePart") and t.Transparency < 1 then
				table.insert(parts, t)
			end
			for _, d in ipairs(t:GetDescendants()) do
				if d:IsA("BasePart") and d.Transparency < 1 then
					table.insert(parts, d)
				end
			end
		end
	end
	return parts
end

-- a plain frame paints the screen since a viewport background renders gamma shifted and neon clones sit on it as flat cutouts
function ImpactFrames.play(targets, pattern)
	if active then
		return
	end
	active = true
	local cam = workspace.CurrentCamera
	local gui = Instance.new("ScreenGui")
	gui.Name = "StandImpactFrame"
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = 40
	gui.ResetOnSpawn = false
	local bg = Instance.new("Frame")
	bg.Size = UDim2.fromScale(1, 1)
	bg.BorderSizePixel = 0
	bg.ZIndex = 1
	bg.Parent = gui
	local vp = Instance.new("ViewportFrame")
	vp.Size = UDim2.fromScale(1, 1)
	vp.BackgroundTransparency = 1
	vp.BorderSizePixel = 0
	vp.ZIndex = 2
	vp.Ambient = Color3.new(1, 1, 1)
	vp.LightColor = Color3.new(0, 0, 0)
	vp.Parent = gui
	local vcam = Instance.new("Camera")
	vcam.Parent = vp
	vp.CurrentCamera = vcam
	local sources = collect(targets)
	local pairs_ = {}
	-- a recoloured clone inside a viewport renders stale so every step gets fresh clones in the new colour
	local function rebuild(fill)
		for _, pr in ipairs(pairs_) do
			pr[1]:Destroy()
		end
		pairs_ = {}
		local dark = (fill.R + fill.G + fill.B) < 1.5
		vp.Ambient = dark and fill or Color3.new(1, 1, 1)
		for _, part in ipairs(sources) do
			local c = flatClone(part, dark)
			c.Color = dark and Color3.new(1, 1, 1) or fill
			c.CFrame = part.CFrame
			c.Parent = vp
			table.insert(pairs_, {c, part})
		end
	end
	local function sync()
		vcam.CFrame = cam.CFrame
		vcam.FieldOfView = cam.FieldOfView
		for _, pr in ipairs(pairs_) do
			if pr[2].Parent then
				pr[1].CFrame = pr[2].CFrame
			end
		end
	end
	local conn = RunService.RenderStepped:Connect(sync)
	gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	for _, step in ipairs(pattern) do
		local style = STYLES[step[1]]
		bg.BackgroundColor3 = style.bg
		rebuild(style.fill)
		sync()
		task.wait(step[2] * Tw.S())
	end
	conn:Disconnect()
	gui:Destroy()
	active = false
end

return ImpactFrames
