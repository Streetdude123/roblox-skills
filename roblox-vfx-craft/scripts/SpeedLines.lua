local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Tw = require(script.Parent.Tw)

local SpeedLines = {}

local COUNT = 36
local gui, lines, conn
local strength = Instance.new("NumberValue")
local frame = 0

local function build()
	local pg = Players.LocalPlayer:WaitForChild("PlayerGui")
	gui = Instance.new("ScreenGui")
	gui.Name = "UltSpeedLines"
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = 50
	gui.ResetOnSpawn = false
	lines = {}
	for i = 1, COUNT do
		local f = Instance.new("Frame")
		f.Name = "Ray"
		f.BackgroundColor3 = Color3.new(0, 0, 0)
		f.BorderSizePixel = 0
		f.AnchorPoint = Vector2.new(0.5, 0.5)
		f.BackgroundTransparency = 1
		local g = Instance.new("UIGradient")
		g.Rotation = 90
		g.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.35, 0.3), NumberSequenceKeypoint.new(1, 0)})
		g.Parent = f
		f.Parent = gui
		lines[i] = {frame = f, angle = (i / COUNT) * 360}
	end
	gui.Parent = pg
end

-- each ray is a tall thin frame whose top end sits on an inner radius so it tapers in toward the subject
local function layout(alpha)
	local size = gui.AbsoluteSize
	local cx, cy = size.X / 2, size.Y / 2
	local h = size.Y
	for _, l in ipairs(lines) do
		local f = l.frame
		if math.random() < 0.4 then
			f.BackgroundTransparency = 1
		else
			local a = math.rad(l.angle + (math.random() - 0.5) * 9)
			local r0 = h * (0.2 + math.random() * 0.1)
			local len = h * (0.3 + math.random() * 0.28)
			local dx, dy = -math.sin(a), math.cos(a)
			local d = r0 + len / 2
			f.Size = UDim2.fromOffset(1.5 + math.random() * 3, len)
			f.Position = UDim2.fromOffset(cx + dx * d, cy + dy * d)
			f.Rotation = math.deg(a)
			f.BackgroundTransparency = alpha
		end
	end
end

local function step()
	frame += 1
	local s = strength.Value
	if s <= 0.001 then
		for _, l in ipairs(lines) do
			l.frame.BackgroundTransparency = 1
		end
		return
	end
	if frame % 3 == 0 then
		layout(1 - s * 0.7)
	end
end

function SpeedLines.set(value, dur)
	if not gui then
		build()
	end
	if not conn then
		conn = RunService.RenderStepped:Connect(step)
	end
	TweenService:Create(strength, TweenInfo.new((dur or 0.2) * Tw.S(), Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Value = value}):Play()
end

-- a pulse snaps the lines in for one hit and lets them die off so they never sit on a whole phase
function SpeedLines.pulse(value, dur)
	SpeedLines.set(value, 0.06)
	task.delay(0.12 * Tw.S(), function()
		SpeedLines.stop(dur or 0.4)
	end)
end

function SpeedLines.stop(dur)
	SpeedLines.set(0, dur or 0.4)
	task.delay((dur or 0.4) * Tw.S() + 0.1, function()
		if strength.Value <= 0.001 and conn then
			conn:Disconnect()
			conn = nil
			for _, l in ipairs(lines) do
				l.frame.BackgroundTransparency = 1
			end
		end
	end)
end

return SpeedLines
