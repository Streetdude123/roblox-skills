local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")

local Fit = {}

Fit.top = {Phone = 1, Tablet = 1.25, Desktop = 1.25, Tv = 2}

function Fit.kind(short)
	if GuiService.ViewportDisplaySize == Enum.DisplaySize.Large or GuiService:IsTenFootInterface() then
		return "Tv"
	end
	if short <= 500 then
		return "Phone"
	end
	if UserInputService.PreferredInput == Enum.PreferredInput.Touch then
		return "Tablet"
	end
	return "Desktop"
end

function Fit.scale(gui, s)
	local size = gui.AbsoluteSize
	local short = math.min(size.X, size.Y)
	local kind = Fit.kind(short)
	local top = s:GetAttribute(kind) or Fit.top[kind]
	local k
	if kind == "Tv" then
		k = math.clamp(short / 540, 1, top)
	else
		k = math.clamp(short / (s:GetAttribute("Ref") or 288), s:GetAttribute("Min") or 0.75, top)
	end
	local step = s:GetAttribute("Step")
	if step then
		k = math.max(step, math.floor(k / step + 0.5) * step)
	end
	return k, kind
end

function Fit.watch(gui)
	local root = gui:FindFirstChild("Root")
	local s = root and root:FindFirstChild("Fit")
	if not s then
		return
	end
	local function apply()
		local k, kind = Fit.scale(gui, s)
		s.Scale = k
		root.Size = UDim2.fromScale(1 / k, 1 / k)
		gui:SetAttribute("Device", kind)
	end
	apply()
	gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(apply)
	GuiService:GetPropertyChangedSignal("ViewportDisplaySize"):Connect(apply)
	UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(apply)
	return apply
end

function Fit.all(pg)
	for _, g in pg:GetChildren() do
		if g:IsA("ScreenGui") then
			Fit.watch(g)
		end
	end
	pg.ChildAdded:Connect(function(g)
		if g:IsA("ScreenGui") then
			Fit.watch(g)
		end
	end)
end

return Fit
