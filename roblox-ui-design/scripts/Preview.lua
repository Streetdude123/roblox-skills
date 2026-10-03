local StarterGui = game:GetService("StarterGui")
local svc = game:GetService("StudioDeviceSimulatorService")

local function ring(parent, name, size, pos)
	local r = Instance.new("Frame")
	r.Name = name
	r.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
	r.BackgroundTransparency = 0.55
	r.BorderSizePixel = 0
	r.AnchorPoint = Vector2.new(0.5, 0.5)
	r.Size = UDim2.fromOffset(size, size)
	r.Position = pos
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0.5, 0)
	c.Parent = r
	local s = Instance.new("UIStroke")
	s.Color = Color3.new(1, 1, 1)
	s.Transparency = 0.5
	s.Thickness = 2
	s.Parent = r
	r.Parent = parent
end

local function ghost(inset, touch)
	local old = StarterGui:FindFirstChild("Preview_Topbar")
	if old then
		old:Destroy()
	end
	if not inset or inset <= 0 then
		return
	end
	local g = Instance.new("ScreenGui")
	g.Name = "Preview_Topbar"
	g.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
	g.DisplayOrder = 999
	if touch then
		local vp = workspace.CurrentCamera.ViewportSize
		local small = math.min(vp.X, vp.Y) <= 500
		if small then
			ring(g, "Jump", 72, UDim2.new(1, -100, 1, -100))
			ring(g, "Stick", 74, UDim2.new(0, 66, 1, -56))
		else
			ring(g, "Jump", 120, UDim2.new(1, -160, 1, -172))
			ring(g, "Stick", 148, UDim2.new(0, 132, 1, -112))
		end
	end
	local band = Instance.new("Frame")
	band.Name = "Band"
	band.BackgroundColor3 = Color3.new(0, 0, 0)
	band.BackgroundTransparency = 0.82
	band.BorderSizePixel = 0
	band.Size = UDim2.new(1, 0, 0, inset)
	band.Parent = g
	local gap = inset - 46
	for i, x in {gap, gap * 2 + 44, -(gap + 44)} do
		local b = Instance.new("Frame")
		b.Name = "Button" .. i
		b.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
		b.BackgroundTransparency = 0.25
		b.BorderSizePixel = 0
		b.Size = UDim2.fromOffset(44, 44)
		b.Position = x < 0 and UDim2.new(1, x, 0, gap) or UDim2.fromOffset(x, gap)
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0.5, 0)
		c.Parent = b
		b.Parent = band
	end
	g.Parent = StarterGui
end

local function apply(Fit, gui, inset)
	local root = gui:FindFirstChild("Root")
	local s = root and root:FindFirstChild("Fit")
	if not s then
		return "no Root/Fit"
	end
	local size = workspace.CurrentCamera.ViewportSize
	local area = {AbsoluteSize = Vector2.new(size.X, size.Y - inset)}
	local k, kind = Fit.scale(area, s)
	s.Scale = k
	root.Position = UDim2.fromOffset(0, inset)
	root.Size = UDim2.new(1 / k, 0, 1 / k, -inset / k)
	local lay = gui:FindFirstChild("Layout")
	if lay then
		loadstring(lay.Source)()(gui, kind)
	end
	return kind, k
end

local function reset(gui)
	local root = gui:FindFirstChild("Root")
	if root then
		root.Position = UDim2.new()
		root.Size = UDim2.fromScale(1, 1)
		if root:FindFirstChild("Fit") then
			root.Fit.Scale = 1
		end
	end
	gui.Enabled = false
end

return function(Fit, opts)
	opts = opts or {}
	if opts.reset then
		svc:SetDeviceAsync("default")
		ghost(0)
		for _, g in StarterGui:GetChildren() do
			if g:IsA("ScreenGui") and g:GetAttribute(opts.tag or "Lab") then
				reset(g)
			end
		end
		return "reset"
	end
	if opts.device then
		svc:SetDeviceAsync(opts.device)
		task.wait(1)
	end
	local show = {}
	for _, n in opts.show or {} do
		show[n] = true
	end
	local lines = {}
	for _, g in StarterGui:GetChildren() do
		if g:IsA("ScreenGui") and g:GetAttribute(opts.tag or "Lab") then
			local probe = g:FindFirstChild("Root")
			local vp = workspace.CurrentCamera.ViewportSize
			local short = math.min(vp.X, vp.Y)
			local touch = game:GetService("UserInputService").PreferredInput == Enum.PreferredInput.Touch
			local inset = opts.inset or ((short <= 500 or touch) and 52 or 58)
			local kind, k = apply(Fit, g, inset)
			g.Enabled = show[g.Name] == true
			if g.Enabled then
				table.insert(lines, string.format("%s screen %dx%d inset %d kind %s scale %s", g.Name, math.floor(vp.X), math.floor(vp.Y), inset, tostring(kind), tostring(k)))
				ghost(opts.topbar == false and 0 or inset, opts.controls ~= false and (kind == "Phone" or kind == "Tablet"))
			end
			if not probe then
				table.insert(lines, g.Name .. " has no Root")
			end
		end
	end
	local ok, res = pcall(svc.GetResolutionAsync, svc)
	table.insert(lines, 1, "device " .. tostring(opts.device or "unchanged") .. (ok and string.format(" %dx%d", math.floor(res.X), math.floor(res.Y)) or ""))
	return table.concat(lines, "\n")
end
