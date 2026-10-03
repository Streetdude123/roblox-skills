local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")

local Ui = {}

local press = TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local release = TweenInfo.new(0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local hover = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local open = TweenInfo.new(0.26, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local close = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local fade = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local slide = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

Ui.info = {press = press, release = release, hover = hover, open = open, close = close, fade = fade, slide = slide}

local live = setmetatable({}, {__mode = "k"})
local waits = setmetatable({}, {__mode = "k"})

local function play(o, info, props)
	local t = TweenService:Create(o, info, props)
	t:Play()
	return t
end
Ui.play = play

local function stop(o)
	local l = live[o]
	if l then
		for _, t in l do
			t:Cancel()
		end
	end
	l = {}
	live[o] = l
	return l
end

function Ui.calm()
	return GuiService.ReducedMotionEnabled
end

function Ui.touch()
	return UserInputService.PreferredInput == Enum.PreferredInput.Touch
end

function Ui.pad()
	return UserInputService.PreferredInput == Enum.PreferredInput.Gamepad
end

local function isPress(i)
	local t = i.UserInputType
	return t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch or i.KeyCode == Enum.KeyCode.ButtonA
end

function Ui.press(b, fn)
	local s = b:FindFirstChildOfClass("UIScale")
	local ghost = b.BackgroundTransparency >= 1
	b.AutoButtonColor = false
	if b:GetAttribute("Fill") == nil then
		b:SetAttribute("Fill", b.BackgroundColor3)
	end
	local over, down = false, false
	local function paint(scaleInfo)
		local fill = b:GetAttribute("Fill")
		local colorInfo = down and press or hover
		local ink = b:GetAttribute("Ink")
		if ink then
			local c = down and (b:GetAttribute("InkDown") or b:GetAttribute("InkHover") or ink)
				or over and (b:GetAttribute("InkHover") or ink)
				or ink
			for _, d in b:GetDescendants() do
				if d:GetAttribute("Keep") then
					continue
				end
				if d:IsA("UIStroke") and d.ApplyStrokeMode == Enum.ApplyStrokeMode.Border then
					play(d, colorInfo, {Color = c})
				elseif d:IsA("TextLabel") then
					play(d, colorInfo, {TextColor3 = c})
				elseif d:IsA("ImageLabel") and d.Name == "Icon" then
					play(d, colorInfo, {ImageColor3 = c})
				end
			end
			local soul, icon = b:FindFirstChild("Soul", true), b:FindFirstChild("Icon", true)
			if soul and icon then
				soul.Visible = over or down
				icon.Visible = not soul.Visible
			end
		elseif ghost then
			play(b, colorInfo, {BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = down and 0.86 or over and 0.92 or 1})
		else
			local c = down and (b:GetAttribute("Down") or fill:Lerp(Color3.new(0, 0, 0), 0.12))
				or over and (b:GetAttribute("Hover") or fill:Lerp(Color3.new(1, 1, 1), 0.1))
				or fill
			play(b, colorInfo, {BackgroundColor3 = c})
		end
		if s and not Ui.calm() then
			play(s, scaleInfo, {Scale = down and 0.95 or over and 1.03 or 1})
		end
	end
	b.MouseEnter:Connect(function()
		if Ui.touch() then
			return
		end
		over = true
		paint(hover)
	end)
	b.MouseLeave:Connect(function()
		over, down = false, false
		paint(hover)
	end)
	b.SelectionGained:Connect(function()
		over = true
		paint(hover)
	end)
	b.SelectionLost:Connect(function()
		over, down = false, false
		paint(hover)
	end)
	b.InputBegan:Connect(function(i)
		if isPress(i) and b.Interactable then
			down = true
			paint(press)
		end
	end)
	b.InputEnded:Connect(function(i)
		if isPress(i) then
			down = false
			if i.UserInputType == Enum.UserInputType.Touch then
				over = false
			end
			paint(release)
		end
	end)
	if fn then
		b.Activated:Connect(fn)
	end
	return b
end

function Ui.paint(b, fill)
	b:SetAttribute("Fill", fill)
	b:SetAttribute("Hover", fill:Lerp(Color3.new(1, 1, 1), 0.1))
	b:SetAttribute("Down", fill:Lerp(Color3.new(0, 0, 0), 0.12))
	b.BackgroundColor3 = fill
end

function Ui.open(panel, dim)
	local l = stop(panel)
	local s = panel:FindFirstChildOfClass("UIScale")
	local gui = panel:FindFirstAncestorOfClass("ScreenGui")
	if gui then
		gui.Enabled = true
	end
	panel.Visible = true
	if dim then
		dim.Visible = true
		dim.BackgroundTransparency = 1
		table.insert(l, play(dim, fade, {BackgroundTransparency = dim:GetAttribute("Alpha") or 0.45}))
	end
	if panel:IsA("CanvasGroup") then
		panel.GroupTransparency = 1
		table.insert(l, play(panel, fade, {GroupTransparency = 0}))
	end
	if s then
		if Ui.calm() then
			s.Scale = 1
		else
			s.Scale = 0.92
			table.insert(l, play(s, open, {Scale = 1}))
		end
	end
	if Ui.pad() then
		GuiService:Select(panel)
	end
end

function Ui.close(panel, dim, done)
	local l = stop(panel)
	local s = panel:FindFirstChildOfClass("UIScale")
	local last
	if s and not Ui.calm() then
		last = play(s, close, {Scale = 0.95})
		table.insert(l, last)
	end
	if panel:IsA("CanvasGroup") then
		last = play(panel, close, {GroupTransparency = 1})
		table.insert(l, last)
	end
	if dim then
		table.insert(l, play(dim, close, {BackgroundTransparency = 1}))
	end
	if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(panel) then
		GuiService.SelectedObject = nil
	end
	local function hide()
		panel.Visible = false
		if dim then
			dim.Visible = false
		end
		if done then
			done()
		end
	end
	if last then
		last.Completed:Once(function(state)
			if state == Enum.PlaybackState.Completed then
				hide()
			end
		end)
	else
		hide()
	end
end

function Ui.pop(o, amt)
	local s = o:FindFirstChildOfClass("UIScale")
	if not s or Ui.calm() then
		return
	end
	local l = stop(s)
	local t = play(s, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = amt or 1.15})
	table.insert(l, t)
	t.Completed:Once(function(state)
		if state == Enum.PlaybackState.Completed then
			table.insert(l, play(s, release, {Scale = 1}))
		end
	end)
end

function Ui.pulse(o, amt)
	local s = o:FindFirstChildOfClass("UIScale")
	if not s or Ui.calm() then
		return function() end
	end
	local t = play(s, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Scale = amt or 1.06})
	return function()
		t:Cancel()
		s.Scale = 1
	end
end

local units = {"", "K", "M", "B", "T", "Qa", "Qi"}

function Ui.short(n)
	n = math.floor(n + 0.5)
	local a = math.abs(n)
	if a < 1000 then
		return tostring(n)
	end
	local i = math.min(math.floor(math.log10(a) / 3), #units - 1)
	local v = n / 10 ^ (i * 3)
	local s = math.abs(v) < 100 and string.format("%.1f", math.floor(v * 10) / 10) or tostring(math.floor(v))
	return s:gsub("%.0$", "") .. units[i + 1]
end

function Ui.comma(n)
	local s = tostring(math.floor(n + 0.5))
	local k
	repeat
		s, k = s:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
	until k == 0
	return s
end

function Ui.count(label, from, to, fmt, time)
	local f = fmt or Ui.short
	local v = Instance.new("NumberValue")
	v.Value = from
	label.Text = f(from)
	v.Changed:Connect(function(x)
		label.Text = f(x)
	end)
	local t = play(v, TweenInfo.new(Ui.calm() and 0 or (time or 0.6), Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Value = to})
	t.Completed:Once(function()
		label.Text = f(to)
		v:Destroy()
		Ui.pop(label)
	end)
	return t
end

function Ui.bar(fill, trail, a)
	a = math.clamp(a, 0, 1)
	play(fill, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.fromScale(a, 1)})
	if not trail then
		return
	end
	local n = (waits[trail] or 0) + 1
	waits[trail] = n
	if a >= trail.Size.X.Scale then
		stop(trail)
		trail.Size = UDim2.fromScale(a, 1)
		return
	end
	task.delay(0.35, function()
		if waits[trail] == n then
			table.insert(stop(trail), play(trail, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.fromScale(a, 1)}))
		end
	end)
end

function Ui.toast(tpl, parent, text, hold)
	local t = tpl:Clone()
	local body = t:FindFirstChild("Body") or t
	local label = t:FindFirstChild("Label", true)
	if label then
		label.Text = text
	end
	t.Visible = true
	t.Parent = parent
	local calm = Ui.calm()
	if body:IsA("CanvasGroup") then
		body.GroupTransparency = 1
		play(body, slide, {GroupTransparency = 0})
	end
	if body ~= t and not calm then
		body.Position = UDim2.fromOffset(0, -16)
		play(body, slide, {Position = UDim2.new()})
	end
	task.delay(hold or 3, function()
		local last
		if body:IsA("CanvasGroup") then
			last = play(body, close, {GroupTransparency = 1})
		end
		if body ~= t and not calm then
			play(body, close, {Position = UDim2.fromOffset(0, -16)})
		end
		if last then
			last.Completed:Wait()
		end
		t:Destroy()
	end)
	return t
end

function Ui.stagger(items, gap)
	for i, o in items do
		local s = o:FindFirstChildOfClass("UIScale")
		if o:IsA("CanvasGroup") then
			o.GroupTransparency = 1
		end
		if s and not Ui.calm() then
			s.Scale = 0.9
		end
		task.delay((i - 1) * (gap or 0.04), function()
			if o:IsA("CanvasGroup") then
				play(o, fade, {GroupTransparency = 0})
			end
			if s then
				play(s, release, {Scale = 1})
			end
		end)
	end
end

function Ui.shake(o)
	if Ui.calm() then
		return
	end
	local p = o.Position
	task.spawn(function()
		for _, d in {8, -7, 5, -3, 1} do
			o.Position = p + UDim2.fromOffset(d, 0)
			task.wait(0.04)
		end
		o.Position = p
	end)
end

function Ui.hints(root)
	local function apply()
		local mode = UserInputService.PreferredInput
		for _, o in root:GetDescendants() do
			local key = o:GetAttribute("Key")
			if key then
				local pad = o:GetAttribute("Pad")
				local glyph = o:FindFirstChild("Glyph")
				local txt = o:FindFirstChild("Key")
				if mode == Enum.PreferredInput.Touch then
					o.Visible = false
				elseif mode == Enum.PreferredInput.Gamepad and pad and glyph then
					o.Visible = true
					glyph.Image = UserInputService:GetImageForKeyCode(Enum.KeyCode[pad])
					glyph.Visible = true
					if txt then
						txt.Visible = false
					end
				else
					o.Visible = mode ~= Enum.PreferredInput.Gamepad
					if glyph then
						glyph.Visible = false
					end
					if txt then
						local name = UserInputService:GetStringForKeyCode(Enum.KeyCode[key])
						txt.Visible = true
						txt.Text = o:GetAttribute("Label") or (name ~= "" and name or key)
					end
				end
			end
		end
	end
	apply()
	return UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(apply)
end

return Ui
