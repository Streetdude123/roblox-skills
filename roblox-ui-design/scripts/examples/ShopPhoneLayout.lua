local GuiService = game:GetService("GuiService")

local saved = {}

local function hold(o, keys)
	local s = saved[o] or {}
	for _, k in keys do
		if s[k] == nil then
			s[k] = o[k]
		end
	end
	saved[o] = s
end

local function put(o, x, y, w, h)
	hold(o, { "AnchorPoint", "Position", "Size" })
	o.AnchorPoint = Vector2.zero
	o.Position = UDim2.fromOffset(x, y)
	o.Size = UDim2.fromOffset(w, h)
	local ratio = o:FindFirstChildOfClass("UIAspectRatioConstraint")
	if ratio then
		hold(ratio, { "AspectRatio" })
		ratio.AspectRatio = w / h
	end
end

return function(gui, kind, inset)
	for o, s in saved do
		for k, v in s do
			o[k] = v
		end
	end
	table.clear(saved)
	if kind ~= "Phone" then
		return
	end

	local main = gui.Main
	local shop = main.ShopBackground
	local stats = main.TowerStats
	local top = (inset or GuiService:GetGuiInset().Y) + 6
	local w = gui.AbsoluteSize.X - 12
	local h = gui.AbsoluteSize.Y - top - 6
	local sw = math.clamp(math.floor(w * 0.44), 280, 360)
	local lw = w - sw - 6

	put(main, 6, top, w, h)
	put(shop, 0, 0, lw, h)
	put(stats, lw + 6, 0, sw, h)

	put(shop["Unit Shop"], 10, 6, math.floor(lw * 0.6), 34)
	put(shop.Exit, lw - 58, 4, 52, 44)
	put(shop.HeaderRule, 10, 52, lw - 20, 2)
	put(shop.ScrollingFrame, 8, 58, lw - 16, h - 66)

	local bottom = h - 56
	local side = 120
	put(stats.TowerName, 6, 4, sw - 12, 24)
	put(stats.Divider, 12, 30, sw - 24, 2)
	put(stats.ViewportFrame, 6, 36, side, bottom - 36)
	put(stats.Stripes, 6, 36, side, bottom - 36)

	local x = side + 12
	local iw = sw - x - 6
	put(stats.InformationBackground, x, 36, iw, bottom - 36)
	put(stats.TowerStats, x + 4, 40, iw - 8, 18)
	local r = math.min(iw - 8, bottom - 36 - 28)
	put(stats.RadarContainer, x + (iw - r) // 2, 62, r, r)

	for _, name in { "Second Square", "Second Square 2", "Second Square 3" } do
		put(stats[name], 3, h - 53, sw - 6, 50)
	end
	for _, name in { "Purchase", "Equip", "Unequip" } do
		put(stats[name], 6, h - 50, sw - 12, 44)
	end
	local b = math.min(48, (sw - 12 - 24) // 5)
	for i = 1, 5 do
		put(stats["Box" .. i], 6 + (i - 1) * (b + 6), h - 50 + (44 - b) // 2, b, b)
	end
end
