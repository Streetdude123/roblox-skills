local GuiService = game:GetService("GuiService")

local function lin(v)
	return v <= 0.03928 and v / 12.92 or ((v + 0.055) / 1.055) ^ 2.4
end

local function lum(c)
	return 0.2126 * lin(c.R) + 0.7152 * lin(c.G) + 0.0722 * lin(c.B)
end

local function ratio(a, b)
	local x, y = lum(a), lum(b)
	if x < y then
		x, y = y, x
	end
	return (x + 0.05) / (y + 0.05)
end

local skip = {Guard = true, Backdrop = true, Hit = true, Dim = true, Shade = true}

local function rect(o, stop)
	local p, s = o.AbsolutePosition, o.AbsoluteSize
	local x0, y0, x1, y1 = p.X, p.Y, p.X + s.X, p.Y + s.Y
	local a = o.Parent
	while a and a ~= stop do
		if a:IsA("GuiObject") and (a.ClipsDescendants or a:IsA("ScrollingFrame") or a:IsA("CanvasGroup")) then
			local ap, as = a.AbsolutePosition, a.AbsoluteSize
			x0, y0 = math.max(x0, ap.X), math.max(y0, ap.Y)
			x1, y1 = math.min(x1, ap.X + as.X), math.min(y1, ap.Y + as.Y)
		end
		a = a.Parent
	end
	return {x0, y0, x1, y1}
end

local function overlap(a, b)
	return math.min(a[3], b[3]) - math.max(a[1], b[1]), math.min(a[4], b[4]) - math.max(a[2], b[2])
end

local function boxHit(r, x0, y0, x1, y1)
	return r[1] < x1 and r[3] > x0 and r[2] < y1 and r[4] > y0
end

return function(gui, opts)
	opts = opts or {}
	local out, counts = {}, {}
	local cap = opts.cap or 8
	local tv, touch = opts.tv, opts.touch
	local minHit = opts.minHit or (tv and 64 or touch and 44 or 32)
	local minText = opts.minText or (tv and 24 or 11)
	local base = gui:GetFullName()
	local o0, sz = gui.AbsolutePosition, gui.AbsoluteSize
	local inset = GuiService:GetGuiInset()
	local fonts, sizes, radii, strokes, pads = {}, {}, {}, {}, {}
	local hits = {}
	local unnamed = 0

	local function add(kind, msg)
		counts[kind] = (counts[kind] or 0) + 1
		if counts[kind] <= cap then
			table.insert(out, kind .. "  " .. msg)
		end
	end

	local function path(o)
		return o:GetFullName():sub(#base + 2)
	end

	local function shown(o)
		local p = o
		while p and p ~= gui do
			if p:IsA("GuiObject") and not p.Visible then
				return false
			end
			p = p.Parent
		end
		return true
	end

	local function behind(o)
		local p = o
		while p and p ~= gui do
			if p:IsA("GuiObject") then
				if p.BackgroundTransparency < 0.35 then
					return p.BackgroundColor3
				end
				if p ~= o and (p:IsA("ImageLabel") or p:IsA("ImageButton")) and p.Image ~= "" and p.ImageTransparency < 0.35 then
					return nil, true
				end
			end
			p = p.Parent
		end
	end

	local function zoom(o)
		local k = 1
		local a = o
		while a and a ~= gui do
			for _, c in a:GetChildren() do
				if c:IsA("UIScale") then
					k *= c.Scale
				end
			end
			a = a.Parent
		end
		return k
	end

	local function stroked(o)
		if o.TextStrokeTransparency < 0.6 then
			return true
		end
		for _, m in o:GetChildren() do
			if m:IsA("UIStroke") and m.Enabled and m.Transparency < 0.6 and m.ApplyStrokeMode == Enum.ApplyStrokeMode.Contextual then
				return true
			end
		end
		return false
	end

	if gui:IsA("ScreenGui") and gui.ResetOnSpawn then
		add("RESETONSPAWN", gui.Name .. " resets on respawn")
	end

	local short = math.min(sz.X, sz.Y)
	local big = short > 500
	local jx0, jy0, jx1, jy1
	if big then
		jx0, jy0, jx1, jy1 = o0.X + sz.X - 224, o0.Y + sz.Y - 236, o0.X + sz.X - 46, o0.Y + sz.Y - 86
	else
		jx0, jy0, jx1, jy1 = o0.X + sz.X - 140, o0.Y + sz.Y - 140, o0.X + sz.X - 20, o0.Y + sz.Y - 16
	end

	for _, o in gui:GetDescendants() do
		if o:IsA("GuiObject") and shown(o) then
			if o.Name == o.ClassName then
				unnamed += 1
			end
			local s = o.AbsoluteSize
			local r = rect(o, gui)
			local cut = r[3] - r[1] <= 0 or r[4] - r[2] <= 0
			local hit = (o:IsA("GuiButton") or o:IsA("TextBox")) and not skip[o.Name] and not o:GetAttribute("AuditSkip") and not cut
			local text = (o:IsA("TextLabel") or o:IsA("TextButton") or o:IsA("TextBox")) and o.Text ~= "" and o.TextTransparency < 0.9 and not cut
			if (hit or text) and s.X > 0 and s.Y > 0 then
				if r[1] < o0.X - 2 or r[2] < o0.Y - 2 or r[3] > o0.X + sz.X + 2 or r[4] > o0.Y + sz.Y + 2 then
					add("OFFSCREEN", path(o))
				end
				if tv then
					local vx, vy = sz.X + inset.X, sz.Y + inset.Y
					if r[1] < vx * 0.05 or r[2] + inset.Y < vy * 0.05 or r[3] > vx * 0.95 or r[4] + inset.Y > vy * 0.95 then
						add("TV-UNSAFE", path(o))
					end
				end
			end
			if hit and s.X > 0 then
				if math.min(s.X, s.Y) < minHit then
					add("SMALL HIT", string.format("%s %dx%d", path(o), math.floor(s.X), math.floor(s.Y)))
				end
				if o:IsA("GuiButton") then
					if o.AutoButtonColor then
						add("AUTOBUTTONCOLOR", path(o))
					end
					local a = o.Parent
					while a and a ~= gui do
						if a:IsA("GuiButton") and o.Active then
							add("NESTED BUTTON", path(o) .. " inside " .. a.Name)
							break
						end
						a = a.Parent
					end
				end
				if touch and opts.hud then
					if boxHit(r, o0.X, o0.Y + sz.Y / 3, o0.X + sz.X * 0.4, o0.Y + sz.Y) then
						add("STICK ZONE", path(o))
					end
					if boxHit(r, jx0, jy0, jx1, jy1) then
						add("JUMP ZONE", path(o))
					end
				end
				table.insert(hits, {o, r})
			end
			if text then
				local size = (o.TextScaled and not o.TextWrapped and o.TextBounds.Y or o.TextSize) * zoom(o)
				if size > 0 and size < minText then
					add("SMALL TEXT", string.format("%s %d px", path(o), math.floor(size)))
				end
				if not o.TextFits then
					add("OVERFLOW", path(o))
				end
				if o.TextScaled and not o:FindFirstChildOfClass("UITextSizeConstraint") then
					add("TEXTSCALED NO CAP", path(o))
				end
				local back, onImage = behind(o)
				local large = size >= 24 or (size >= 18 and o.FontFace.Weight.Value >= 600)
				if back then
					local r = ratio(o.TextColor3, back)
					if r < (large and 3 or 4.5) then
						add("CONTRAST", string.format("%s %.2f:1", path(o), r))
					end
				elseif not onImage and not stroked(o) then
					add("NO PLATE OR STROKE", path(o))
				end
				local fam = o.FontFace.Family:match("([%w]+)%.json$") or o.FontFace.Family
				fonts[fam .. " " .. o.FontFace.Weight.Name] = true
				sizes[math.floor(size + 0.5)] = true
			end
			for _, m in o:GetChildren() do
				if m:IsA("UICorner") then
					radii[tostring(m.CornerRadius)] = true
				elseif m:IsA("UIStroke") and m.Enabled then
					strokes[m.Thickness] = true
				elseif m:IsA("UIPadding") then
					pads[tostring(m.PaddingLeft)] = true
				end
			end
		end
	end

	for i = 1, #hits do
		for j = i + 1, #hits do
			local a, b = hits[i], hits[j]
			if not a[1]:IsDescendantOf(b[1]) and not b[1]:IsDescendantOf(a[1]) then
				local x, y = overlap(a[2], b[2])
				if x > 4 and y > 4 then
					add("OVERLAP", path(a[1]) .. " / " .. path(b[1]))
				end
			end
		end
	end

	local function keys(t)
		local l = {}
		for k in t do
			table.insert(l, tostring(k))
		end
		table.sort(l, function(x, y)
			local a, b = tonumber(x), tonumber(y)
			if a and b then
				return a < b
			end
			return x < y
		end)
		return table.concat(l, ", ")
	end

	local head = {string.format("AUDIT %s  area %dx%d  min hit %d  min text %d", gui.Name, math.floor(sz.X), math.floor(sz.Y), minHit, minText)}
	for k, n in counts do
		table.insert(head, k .. " x" .. n)
	end
	table.insert(out, 1, table.concat(head, "  |  "))
	table.insert(out, "fonts: " .. keys(fonts))
	table.insert(out, "text sizes: " .. keys(sizes))
	table.insert(out, "corner radii: " .. keys(radii))
	table.insert(out, "strokes: " .. keys(strokes))
	table.insert(out, "paddings: " .. keys(pads))
	table.insert(out, "unnamed GuiObjects: " .. unnamed)
	return table.concat(out, "\n")
end
