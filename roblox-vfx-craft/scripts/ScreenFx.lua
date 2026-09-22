local Players = game:GetService("Players")

local Tw = require(script.Parent.Tw)

local ScreenFx = {}

local gui, black, white, barTop, barBottom, vignette, flareImg, flareLine

local function edge(parent, pos, size, rotation)
	local f = Instance.new("Frame")
	f.BackgroundColor3 = Color3.new(0, 0, 0)
	f.BorderSizePixel = 0
	f.Position = pos
	f.Size = size
	f.BackgroundTransparency = 1
	f.ZIndex = 3
	local g = Instance.new("UIGradient")
	g.Rotation = rotation
	g.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)})
	g.Parent = f
	f.Parent = parent
	return f
end

local function build()
	gui = Instance.new("ScreenGui")
	gui.Name = "UltScreenFx"
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = 60
	gui.ResetOnSpawn = false
	white = Instance.new("Frame")
	white.Name = "Flash"
	white.Size = UDim2.fromScale(1, 1)
	white.BorderSizePixel = 0
	white.BackgroundColor3 = Color3.new(1, 1, 1)
	white.BackgroundTransparency = 1
	white.ZIndex = 1
	white.Parent = gui
	-- a soft frame darkening from four gradient edges since there is no radial gradient
	vignette = {
		edge(gui, UDim2.fromScale(0, 0), UDim2.fromScale(1, 0.3), 90),
		edge(gui, UDim2.fromScale(0, 0.7), UDim2.fromScale(1, 0.3), 270),
		edge(gui, UDim2.fromScale(0, 0), UDim2.fromScale(0.22, 1), 0),
		edge(gui, UDim2.fromScale(0.78, 0), UDim2.fromScale(0.22, 1), 180),
	}
	flareImg = Instance.new("ImageLabel")
	flareImg.Name = "Flare"
	flareImg.BackgroundTransparency = 1
	flareImg.Image = "rbxassetid://867619398"
	flareImg.ImageTransparency = 1
	flareImg.AnchorPoint = Vector2.new(0.5, 0.5)
	flareImg.Size = UDim2.fromScale(2.4, 0.16)
	flareImg.ScaleType = Enum.ScaleType.Stretch
	flareImg.ZIndex = 4
	flareImg.Parent = gui
	flareLine = flareImg:Clone()
	flareLine.Name = "FlareLine"
	flareLine.Size = UDim2.fromScale(3, 0.035)
	flareLine.Parent = gui
	barTop = Instance.new("Frame")
	barTop.Name = "BarTop"
	barTop.BackgroundColor3 = Color3.new(0, 0, 0)
	barTop.BorderSizePixel = 0
	barTop.Size = UDim2.fromScale(1, 0)
	barTop.ZIndex = 5
	barTop.Parent = gui
	barBottom = barTop:Clone()
	barBottom.Name = "BarBottom"
	barBottom.AnchorPoint = Vector2.new(0, 1)
	barBottom.Position = UDim2.fromScale(0, 1)
	barBottom.Parent = gui
	black = Instance.new("Frame")
	black.Name = "Fade"
	black.Size = UDim2.fromScale(1, 1)
	black.BorderSizePixel = 0
	black.BackgroundColor3 = Color3.new(0, 0, 0)
	black.BackgroundTransparency = 1
	black.ZIndex = 9
	black.Parent = gui
	gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
end

local function ready()
	if not gui then
		build()
	end
end

-- to is 0 for clear and 1 for full black
function ScreenFx.fade(to, dur, style)
	ready()
	return Tw.play(black, {BackgroundTransparency = 1 - to}, dur, style or Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
end

function ScreenFx.flash(strength, dur, color)
	ready()
	white.BackgroundColor3 = color or Color3.new(1, 1, 1)
	white.BackgroundTransparency = 1 - strength
	Tw.play(white, {BackgroundTransparency = 1}, dur, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
end

-- letterbox bars slide to a 2.39 frame on a 16 by 9 view
function ScreenFx.bars(on, dur)
	ready()
	local h = on and 0.12 or 0
	Tw.play(barTop, {Size = UDim2.fromScale(1, h)}, dur, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	Tw.play(barBottom, {Size = UDim2.fromScale(1, h)}, dur, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
end

function ScreenFx.vignette(strength, dur)
	ready()
	for _, f in ipairs(vignette) do
		Tw.play(f, {BackgroundTransparency = 1 - strength}, dur)
	end
end

-- an anamorphic streak pinned to where a world point sits on screen
function ScreenFx.flare(worldPos, color, strength, dur)
	ready()
	local cam = workspace.CurrentCamera
	local p, on = cam:WorldToViewportPoint(worldPos)
	if not on or p.Z < 0 then
		return
	end
	local size = cam.ViewportSize
	local pos = UDim2.fromScale(p.X / size.X, p.Y / size.Y)
	for _, img in ipairs({flareImg, flareLine}) do
		img.Position = pos
		img.ImageColor3 = color
		img.ImageTransparency = 1 - strength
		Tw.play(img, {ImageTransparency = 1}, dur, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	end
	Tw.play(flareImg, {Size = UDim2.fromScale(3.2, 0.2)}, dur, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	task.delay(dur * Tw.S(), function()
		flareImg.Size = UDim2.fromScale(2.4, 0.16)
	end)
end

function ScreenFx.reset()
	if not gui then
		return
	end
	barTop.Size = UDim2.fromScale(1, 0)
	barBottom.Size = UDim2.fromScale(1, 0)
	for _, f in ipairs(vignette) do
		f.BackgroundTransparency = 1
	end
	black.BackgroundTransparency = 1
	white.BackgroundTransparency = 1
	flareImg.ImageTransparency = 1
	flareLine.ImageTransparency = 1
end

return ScreenFx
