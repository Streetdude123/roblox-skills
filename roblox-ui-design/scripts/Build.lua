local B = {}

B.t = {
	font = "BuilderSans",
	sizes = {caption = 12, body = 14, label = 16, title = 20, heading = 28, display = 40},
	space = {xxs = 2, xs = 4, sm = 8, md = 12, lg = 16, xl = 24, xxl = 32},
	radius = {button = 8, card = 12, panel = 16, chip = 8},
	color = {
		bg = Color3.fromHex("020617"),
		surface = Color3.fromHex("0F172A"),
		raised = Color3.fromHex("1E293B"),
		sunken = Color3.fromHex("020617"),
		line = Color3.fromHex("334155"),
		text = Color3.fromHex("F8FAFC"),
		text2 = Color3.fromHex("CBD5E1"),
		text3 = Color3.fromHex("64748B"),
		primary = Color3.fromHex("38BDF8"),
		onPrimary = Color3.fromHex("020617"),
		success = Color3.fromHex("22C55E"),
		warning = Color3.fromHex("FBBF24"),
		danger = Color3.fromHex("EF4444"),
		info = Color3.fromHex("38BDF8"),
	},
	tiers = {
		Common = Color3.fromHex("A1A1AA"),
		Uncommon = Color3.fromHex("4ADE80"),
		Rare = Color3.fromHex("38BDF8"),
		Epic = Color3.fromHex("A855F7"),
		Legendary = Color3.fromHex("F59E0B"),
		Mythic = Color3.fromHex("F43F5E"),
	},
}

function B.theme(t)
	for k, v in t do
		if type(v) == "table" and type(B.t[k]) == "table" then
			for a, b in v do
				B.t[k][a] = b
			end
		else
			B.t[k] = v
		end
	end
	return B.t
end

function B.make(class, props, kids)
	local o = Instance.new(class)
	local parent
	for k, v in props or {} do
		if k == "Parent" then
			parent = v
		else
			o[k] = v
		end
	end
	for _, c in kids or {} do
		c.Parent = o
	end
	if parent then
		o.Parent = parent
	end
	return o
end

local weights = {
	thin = Enum.FontWeight.Thin,
	light = Enum.FontWeight.Light,
	regular = Enum.FontWeight.Regular,
	medium = Enum.FontWeight.Medium,
	semibold = Enum.FontWeight.SemiBold,
	bold = Enum.FontWeight.Bold,
	extrabold = Enum.FontWeight.ExtraBold,
	heavy = Enum.FontWeight.Heavy,
}

function B.font(w, family)
	return Font.new("rbxasset://fonts/families/" .. (family or B.t.font) .. ".json", weights[w or "regular"] or Enum.FontWeight.Regular)
end

local function udim(v)
	if typeof(v) == "UDim" then
		return v
	end
	return UDim.new(0, v)
end

function B.corner(r)
	return B.make("UICorner", {CornerRadius = udim(r or B.t.radius.button)})
end

function B.border(th, col, tr, pos)
	return B.make("UIStroke", {
		Thickness = th or 1,
		Color = col or B.t.color.line,
		Transparency = tr or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		BorderStrokePosition = pos or Enum.BorderStrokePosition.Inner,
		LineJoinMode = Enum.LineJoinMode.Round,
	})
end

function B.outline(th, col, tr)
	return B.make("UIStroke", {
		Thickness = th or 1,
		Color = col or Color3.new(0, 0, 0),
		Transparency = tr or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
		LineJoinMode = Enum.LineJoinMode.Round,
	})
end

function B.pad(t, r, b, l)
	t = t or B.t.space.lg
	r = r or t
	return B.make("UIPadding", {
		PaddingTop = udim(t),
		PaddingRight = udim(r),
		PaddingBottom = udim(b or t),
		PaddingLeft = udim(l or r),
	})
end

function B.list(dir, gap, h, v)
	return B.make("UIListLayout", {
		FillDirection = dir == "x" and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical,
		Padding = udim(gap or B.t.space.sm),
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = h or Enum.HorizontalAlignment.Left,
		VerticalAlignment = v or Enum.VerticalAlignment.Top,
	})
end

function B.grid(cell, gap, aspect)
	local g = B.make("UIGridLayout", {
		CellSize = cell,
		CellPadding = gap or UDim2.fromOffset(B.t.space.sm, B.t.space.sm),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	if aspect then
		B.make("UIAspectRatioConstraint", {AspectRatio = aspect, Parent = g})
	end
	return g
end

function B.flex(mode)
	return B.make("UIFlexItem", {FlexMode = mode or Enum.UIFlexMode.Fill})
end

function B.cap(maxW, maxH, minW, minH)
	return B.make("UISizeConstraint", {
		MaxSize = Vector2.new(maxW or math.huge, maxH or math.huge),
		MinSize = Vector2.new(minW or 0, minH or 0),
	})
end

function B.scale(n, name)
	return B.make("UIScale", {Scale = n or 1, Name = name or "UIScale"})
end

local depth = {{2, 4, 0.7}, {4, 10, 0.75}, {8, 18, 0.7}, {16, 32, 0.6}}

function B.shadow(n, col)
	local v = depth[n or 2]
	return B.make("UIShadow", {
		Offset = UDim2.fromOffset(0, v[1]),
		BlurRadius = UDim.new(0, v[2]),
		Transparency = v[3],
		Color = col or Color3.new(0, 0, 0),
		ZIndex = -1,
	})
end

function B.gradient(c0, c1, rot, t0, t1)
	return B.make("UIGradient", {
		Color = ColorSequence.new(c0, c1 or c0),
		Transparency = NumberSequence.new(t0 or 0, t1 or t0 or 0),
		Rotation = rot or 90,
	})
end

function B.frame(name, props, kids)
	local p = {Name = name, BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1)}
	for k, v in props or {} do
		p[k] = v
	end
	return B.make("Frame", p, kids)
end

function B.box(name, col, props, kids)
	local p = {Name = name, BackgroundColor3 = col or B.t.color.surface, BorderSizePixel = 0}
	for k, v in props or {} do
		p[k] = v
	end
	return B.make("Frame", p, kids)
end

function B.text(name, str, size, w, col, props, kids)
	local p = {
		Name = name,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = str or "",
		FontFace = B.font(w or "medium"),
		TextSize = B.t.sizes[size] or size or B.t.sizes.body,
		TextColor3 = col or B.t.color.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		AutomaticSize = Enum.AutomaticSize.XY,
		Size = UDim2.new(),
	}
	for k, v in props or {} do
		p[k] = v
	end
	return B.make("TextLabel", p, kids)
end

function B.icon(name, img, px, col, props)
	local p = {
		Name = name,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Image = img or "",
		ImageColor3 = col or Color3.new(1, 1, 1),
		ScaleType = Enum.ScaleType.Fit,
		Size = UDim2.fromOffset(px or 24, px or 24),
	}
	for k, v in props or {} do
		p[k] = v
	end
	return B.make("ImageLabel", p)
end

function B.button(name, label, kind, props, kids)
	local c = B.t.color
	kind = kind or "secondary"
	local fill = kind == "primary" and c.primary or kind == "danger" and c.danger or c.raised
	local ink = (kind == "primary" or kind == "danger") and B.on(fill) or (kind == "ghost" and c.text2 or c.text)
	local b = B.make("TextButton", {
		Name = name,
		Text = "",
		AutoButtonColor = false,
		BorderSizePixel = 0,
		BackgroundColor3 = fill,
		BackgroundTransparency = kind == "ghost" and 1 or 0,
		Size = UDim2.fromOffset(0, 48),
		AutomaticSize = Enum.AutomaticSize.X,
	}, {
		B.corner(B.t.radius.button),
		B.pad(0, B.t.space.lg, 0, B.t.space.lg),
		B.list("x", B.t.space.sm, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Center),
		B.scale(1, "Press"),
	})
	if label then
		B.text("Label", label, "label", "bold", ink, {LayoutOrder = 2}).Parent = b
	end
	if kind == "secondary" then
		B.border(1, c.line).Parent = b
	end
	b:SetAttribute("Kind", kind)
	b:SetAttribute("Fill", fill)
	b:SetAttribute("Hover", B.lift(fill, 0.1))
	b:SetAttribute("Down", B.lift(fill, -0.12))
	for k, v in props or {} do
		b[k] = v
	end
	for _, k in kids or {} do
		k.Parent = b
	end
	return b
end

function B.bar(name, w, h, col, props)
	local bar = B.frame(name, {Size = UDim2.fromOffset(w, h)}, {
		B.box("Trail", B.lift(col, 0.45), {Size = UDim2.fromScale(1, 1)}),
		B.box("Fill", col, {Size = UDim2.fromScale(1, 1), ZIndex = 2}),
	})
	for k, v in props or {} do
		bar[k] = v
	end
	return bar
end

function B.hsl(h, s, l)
	local c = (1 - math.abs(2 * l - 1)) * s
	local x = c * (1 - math.abs((h / 60) % 2 - 1))
	local m = l - c / 2
	local r, g, b
	if h < 60 then
		r, g, b = c, x, 0
	elseif h < 120 then
		r, g, b = x, c, 0
	elseif h < 180 then
		r, g, b = 0, c, x
	elseif h < 240 then
		r, g, b = 0, x, c
	elseif h < 300 then
		r, g, b = x, 0, c
	else
		r, g, b = c, 0, x
	end
	return Color3.new(r + m, g + m, b + m)
end

local function toward(h, hues, amt)
	local best = 999
	for _, t in hues do
		local d = (t - h + 540) % 360 - 180
		if math.abs(d) < math.abs(best) then
			best = d
		end
	end
	return (h + math.clamp(best, -amt, amt)) % 360
end

function B.ramp(h, s, l)
	local out = {[500] = B.hsl(h, s, l)}
	for k, t in {[50] = 0.95, [100] = 0.86, [200] = 0.7, [300] = 0.52, [400] = 0.28} do
		out[k] = B.hsl(toward(h, {60, 180, 300}, 14 * t), math.min(1, s + (1 - s) * 0.25 * t), l + (0.97 - l) * t)
	end
	for k, t in {[600] = 0.2, [700] = 0.4, [800] = 0.58, [900] = 0.74, [950] = 0.86} do
		out[k] = B.hsl(toward(h, {0, 120, 240}, 14 * t), math.min(1, s + (1 - s) * 0.3 * t), l * (1 - t) + 0.05 * t)
	end
	return out
end

function B.lift(c, amt)
	if amt >= 0 then
		return c:Lerp(Color3.new(1, 1, 1), amt)
	end
	return c:Lerp(Color3.new(0, 0, 0), -amt)
end

local function lin(v)
	return v <= 0.03928 and v / 12.92 or ((v + 0.055) / 1.055) ^ 2.4
end

function B.lum(c)
	return 0.2126 * lin(c.R) + 0.7152 * lin(c.G) + 0.0722 * lin(c.B)
end

function B.contrast(a, b)
	local x, y = B.lum(a), B.lum(b)
	if x < y then
		x, y = y, x
	end
	return (x + 0.05) / (y + 0.05)
end

function B.on(c)
	local dark = Color3.fromHex("0B0F19")
	return B.contrast(c, Color3.new(1, 1, 1)) >= B.contrast(c, dark) and Color3.new(1, 1, 1) or dark
end

return B
