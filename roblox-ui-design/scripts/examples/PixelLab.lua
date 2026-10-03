return function(B, ids)
	local sg = game:GetService("StarterGui")
	local W = Color3.new(1, 1, 1)
	local K = Color3.new(0, 0, 0)
	local Y = Color3.fromRGB(255, 255, 0)
	local O = Color3.fromRGB(255, 140, 26)
	local R = Color3.fromRGB(255, 0, 0)
	local Gy = Color3.fromRGB(128, 128, 128)
	local Dk = Color3.fromRGB(48, 48, 48)
	local Teal = Color3.fromRGB(31, 181, 200)
	local Wine = Color3.fromRGB(200, 40, 60)
	local Cyan = Color3.fromRGB(66, 252, 255)
	local Center = Enum.VerticalAlignment.Center
	local XY = Enum.AutomaticSize.XY

	B.theme({font = "PressStart2P", sizes = {caption = 12, body = 16, label = 16, title = 24, heading = 32, display = 48}})

	local function px(name, str, size, col, props)
		return B.text(name, str, size, "regular", col or W, props)
	end

	local function pic(name, key, size, col, props)
		local i = B.icon(name, "rbxassetid://" .. ids[key], size, col, props)
		i.ResampleMode = Enum.ResamplerMode.Pixelated
		return i
	end

	local function edge(th, col)
		return B.make("UIStroke", {
			Thickness = th or 4,
			Color = col or W,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			BorderStrokePosition = Enum.BorderStrokePosition.Inner,
			LineJoinMode = Enum.LineJoinMode.Miter,
		})
	end

	local function box(name, props, kids, th, col, class)
		local p = {Name = name, BackgroundColor3 = K, BorderSizePixel = 0}
		for k, v in props or {} do
			p[k] = v
		end
		if class then
			p.Text = ""
			p.AutoButtonColor = false
		end
		local f = B.make(class or "Frame", p, kids)
		edge(th, col).Parent = f
		return f
	end

	local function glow(parent, th)
		local f = B.box("Glow", W, {
			Position = UDim2.fromOffset(th, th),
			Size = UDim2.new(1, -th * 2, 1, -th * 2),
			ZIndex = 0,
		}, {
			B.make("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Teal),
					ColorSequenceKeypoint.new(0.5, K),
					ColorSequenceKeypoint.new(1, Wine),
				}),
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.62),
					NumberSequenceKeypoint.new(0.16, 1),
					NumberSequenceKeypoint.new(0.84, 1),
					NumberSequenceKeypoint.new(1, 0.62),
				}),
			}),
		})
		f.Parent = parent
		return f
	end

	local function keep(o)
		o:SetAttribute("Keep", true)
		for _, d in o:GetDescendants() do
			d:SetAttribute("Keep", true)
		end
		return o
	end

	local function chip(key, pad, inline)
		local c = box("Key", {
			Size = UDim2.fromOffset(24, 24),
			AnchorPoint = inline and Vector2.zero or Vector2.new(0.5, 0.5),
			Position = inline and UDim2.new() or UDim2.fromOffset(2, 2),
			ZIndex = 4,
		}, {
			px("Key", key, "caption", W, {
				AutomaticSize = Enum.AutomaticSize.None,
				Size = UDim2.fromScale(1, 1),
				TextXAlignment = Enum.TextXAlignment.Center,
			}),
			B.icon("Glyph", "", 20, W, {Visible = false, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5)}),
		}, 2)
		c:SetAttribute("Key", key)
		c:SetAttribute("Pad", pad)
		return keep(c)
	end

	local function cmd(name, icon, label, key, pad, order, w)
		local b = B.make("TextButton", {
			Name = name,
			Text = "",
			AutoButtonColor = false,
			BorderSizePixel = 0,
			BackgroundColor3 = K,
			Size = UDim2.fromOffset(w or 128, 44),
			LayoutOrder = order or 0,
		}, {
			edge(3, O),
			B.scale(1, "Press"),
			B.frame("Body", nil, {
				B.pad(0, 12, 0, 12),
				B.list("x", 10, Enum.HorizontalAlignment.Left, Center),
				pic("Icon", icon, 16, O, {LayoutOrder = 1}),
				pic("Soul", "heart", 16, R, {LayoutOrder = 1, Visible = false}),
				px("Label", label, "label", O, {LayoutOrder = 2}),
			}),
			B.box("Cool", K, {
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, -3, 0, 3),
				Size = UDim2.new(0.6, -3, 1, -6),
				BackgroundTransparency = 0.25,
				Visible = false,
				ZIndex = 3,
			}),
			keep(px("Time", "3", "label", W, {AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Visible = false, ZIndex = 4})),
		})
		b:SetAttribute("Ink", O)
		b:SetAttribute("InkHover", Y)
		b:SetAttribute("InkDown", Y)
		if key then
			chip(key, pad).Parent = b
		end
		return b
	end

	local function square(name, icon, order)
		local b = B.make("TextButton", {
			Name = name,
			Text = "",
			AutoButtonColor = false,
			BorderSizePixel = 0,
			BackgroundColor3 = K,
			BackgroundTransparency = 0.1,
			LayoutOrder = order,
		}, {
			edge(3, O),
			B.scale(1, "Press"),
			pic("Icon", icon, 28, O, {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5)}),
			pic("Soul", "heart", 28, R, {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Visible = false}),
			B.box("Cool", K, {
				AnchorPoint = Vector2.new(0, 1),
				Position = UDim2.fromScale(0, 1),
				Size = UDim2.fromScale(1, 0.6),
				BackgroundTransparency = 0.3,
				Visible = false,
				ZIndex = 3,
			}),
			keep(px("Time", "3", "label", W, {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Visible = false, ZIndex = 4})),
		})
		b:SetAttribute("Ink", O)
		b:SetAttribute("InkHover", Y)
		b:SetAttribute("InkDown", Y)
		return b
	end

	local function state(b, s)
		local c = s == "hover" and Y or (s == "cool" or s == "off") and Gy or O
		for _, d in b:GetDescendants() do
			if d:GetAttribute("Keep") then
				continue
			end
			if d:IsA("UIStroke") then
				d.Color = c
			elseif d:IsA("TextLabel") then
				d.TextColor3 = c
			elseif d:IsA("ImageLabel") and d.Name == "Icon" then
				d.ImageColor3 = c
			end
		end
		local soul, icon = b:FindFirstChild("Soul", true), b:FindFirstChild("Icon", true)
		soul.Visible = s == "hover"
		icon.Visible = s ~= "hover"
		b.Cool.Visible = s == "cool"
		b.Time.Visible = s == "cool"
		b.Interactable = s ~= "off"
	end

	local function bar(name, w, h, back, fill, trail, a, t)
		return B.frame(name, {Size = UDim2.fromOffset(w, h)}, {
			B.box("Back", back, {Size = UDim2.fromScale(1, 1)}),
			B.box("Trail", trail or back, {Size = UDim2.fromScale(t or a, 1), ZIndex = 2}),
			B.box("Fill", fill, {Size = UDim2.fromScale(a, 1), ZIndex = 3}),
		})
	end

	local function gui(name, order)
		local old = sg:FindFirstChild(name)
		if old then
			old:Destroy()
		end
		local g = B.make("ScreenGui", {
			Name = name,
			ResetOnSpawn = false,
			Enabled = false,
			DisplayOrder = order,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
			ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets,
		})
		local root = B.frame("Root", {Parent = g})
		local fit = B.make("UIScale", {Name = "Fit", Parent = root})
		fit:SetAttribute("Step", 0.5)
		fit:SetAttribute("Tablet", 1.5)
		fit:SetAttribute("Desktop", 1.5)
		fit:SetAttribute("Tv", 2)
		g:SetAttribute("Lab", true)
		return g, root
	end

	local function backdrop(g, a)
		local d = B.make("TextButton", {
			Name = "Backdrop",
			Text = "",
			AutoButtonColor = false,
			BorderSizePixel = 0,
			BackgroundColor3 = K,
			BackgroundTransparency = a or 0.4,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 0,
			Parent = g,
		})
		d:SetAttribute("Alpha", a or 0.4)
		return d
	end

	local function guard()
		return B.make("TextButton", {
			Name = "Guard",
			Text = "",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 1,
		})
	end

	local hud, hroot = gui("Lab_Hud", 5)

	box("StatsBox", {AutomaticSize = XY, Size = UDim2.new(), AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 16, 1, -16), BackgroundTransparency = 0.15, Parent = hroot}, {
		B.pad(12, 16),
		B.list("y", 8),
		B.frame("Who", {AutomaticSize = XY, Size = UDim2.new(), LayoutOrder = 1}, {
			B.list("x", 24, nil, Center),
			px("Name", "CHARA", "body", W, {LayoutOrder = 1}),
			px("Level", "LV 1", "body", W, {LayoutOrder = 2}),
		}),
		B.frame("Hp", {AutomaticSize = XY, Size = UDim2.new(), LayoutOrder = 2}, {
			B.list("x", 10, nil, Center),
			px("Tag", "HP", "caption", W, {LayoutOrder = 1}),
			bar("Bar", 140, 18, R, Y, Color3.fromRGB(255, 255, 200), 0.7, 0.85),
			px("Value", "14 / 20", "body", W, {LayoutOrder = 3}),
		}),
		B.frame("Sp", {AutomaticSize = XY, Size = UDim2.new(), LayoutOrder = 3}, {
			B.list("x", 10, nil, Center),
			px("Tag", "SP", "caption", W, {LayoutOrder = 1}),
			bar("Bar", 140, 8, Dk, Cyan, nil, 0.55),
		}),
	}, 3)
	hroot.StatsBox.Hp.Bar.LayoutOrder = 2
	hroot.StatsBox.Sp.Bar.LayoutOrder = 2

	local feed = B.frame("Feed", {AutomaticSize = XY, Size = UDim2.new(), AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -16, 0, 16), Parent = hroot}, {
		B.list("y", 8, Enum.HorizontalAlignment.Right),
	})
	box("Alive", {AutomaticSize = XY, Size = UDim2.new(), LayoutOrder = 1, BackgroundTransparency = 0.15, Parent = feed}, {
		B.pad(8, 12),
		B.list("x", 10, nil, Center),
		pic("Icon", "heart", 16, R, {LayoutOrder = 1}),
		px("Line", "4 / 6 ALIVE", "body", W, {LayoutOrder = 2}),
	}, 3)
	box("Note1", {AutomaticSize = XY, Size = UDim2.new(), LayoutOrder = 2, BackgroundTransparency = 0.15, Parent = feed}, {
		B.pad(8, 12),
		px("Line", "* SANS was caught.", "caption", W),
	}, 3)
	box("Note2", {AutomaticSize = XY, Size = UDim2.new(), LayoutOrder = 3, BackgroundTransparency = 0.15, Parent = feed}, {
		B.pad(8, 12),
		px("Line", "* You are filled with DETERMINATION.", "caption", W, {
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.fromOffset(252, 0),
			TextWrapped = true,
			LineHeight = 1.3,
		}),
	}, 3)

	local prompt = box("Prompt", {AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.new(0, 0, 0, 44), AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -76), Parent = hroot}, {
		B.pad(0, 16),
		B.list("x", 12, nil, Center),
		pic("Star", "star", 16, Y, {LayoutOrder = 2}),
		px("Line", "* Check the SAVE point.", "body", W, {LayoutOrder = 3}),
	}, 3, W, "TextButton")
	chip("E", "ButtonX", true).Parent = prompt
	prompt.Key.LayoutOrder = 1
	prompt.Line:SetAttribute("Long", "* Check the SAVE point.")
	prompt.Line:SetAttribute("Short", "SAVE")

	local abil = B.frame("Abilities", {AutomaticSize = XY, Size = UDim2.new(), AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -16, 1, -16), Parent = hroot}, {
		B.list("x", 12, nil, Enum.VerticalAlignment.Bottom),
		cmd("Dash", "bolt", "DASH", "Q", "ButtonX", 1, 120),
		cmd("Block", "shield", "BLOCK", "E", "ButtonY", 2, 136),
		cmd("Heal", "plus", "HEAL", "R", "ButtonB", 3, 120),
		cmd("Trap", "bone", "TRAP", "F", "ButtonR1", 4, 120),
	})
	state(abil.Block, "hover")
	state(abil.Heal, "cool")
	state(abil.Trap, "off")

	local touch = B.frame("TouchAbilities", {Size = UDim2.fromOffset(128, 128), AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -150, 1, -20), Visible = false, Parent = hroot}, {
		B.grid(UDim2.fromOffset(60, 60), UDim2.fromOffset(8, 8)),
		square("Trap", "bone", 1),
		square("Heal", "plus", 2),
		square("Block", "shield", 3),
		square("Dash", "bolt", 4),
	})
	state(touch.Heal, "cool")
	state(touch.Trap, "off")

	local layout = B.make("ModuleScript", {Name = "Layout", Parent = hud})
	layout.Source = table.concat({
		"return function(gui, kind)",
		"\tlocal root = gui.Root",
		"\tlocal touch = kind == \"Phone\" or kind == \"Tablet\"",
		"\tlocal mx, my = 16, 16",
		"\tif kind == \"Tv\" then",
		"\t\tmx, my = 48, 27",
		"\tend",
		"\troot.Abilities.Visible = not touch",
		"\troot.TouchAbilities.Visible = touch",
		"\troot.Abilities.Position = UDim2.new(1, -mx, 1, -my)",
		"\troot.TouchAbilities.Position = UDim2.new(1, -150, 1, -20)",
		"\troot.Feed.Position = UDim2.new(1, -mx, 0, my)",
		"\tlocal stats, prompt = root.StatsBox, root.Prompt",
		"\tprompt.Key.Visible = not touch",
		"\tprompt.Line.Text = prompt.Line:GetAttribute(touch and \"Short\" or \"Long\")",
		"\tif touch then",
		"\t\tstats.AnchorPoint = Vector2.new(0, 0)",
		"\t\tstats.Position = UDim2.fromOffset(mx, my)",
		"\t\tprompt.AnchorPoint = Vector2.new(1, 1)",
		"\t\tprompt.Position = UDim2.new(1, -290, 1, -20)",
		"\telse",
		"\t\tstats.AnchorPoint = Vector2.new(0, 1)",
		"\t\tstats.Position = UDim2.new(0, mx, 1, -my)",
		"\t\tprompt.AnchorPoint = Vector2.new(0.5, 1)",
		"\t\tprompt.Position = UDim2.new(0.5, 0, 1, -(my + 60))",
		"\tend",
		"end",
	}, "\n")

	local shop, sroot = gui("Lab_Shop", 20)
	backdrop(shop, 0.4)
	local panel = box("Panel", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(1, -32, 1, -32), Parent = sroot}, {
		B.cap(800, 450),
		B.scale(1, "Pop"),
		guard(),
	}, 4)
	glow(panel, 4)
	local inner = B.frame("Inner", {ZIndex = 2, Parent = panel}, {
		B.pad(12, 16),
		B.list("y", 8),
	})

	local function tab(name, label, on, order)
		local b = B.make("TextButton", {
			Name = name,
			Text = "",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.new(0, 0, 1, 0),
			LayoutOrder = order,
		}, {
			B.list("x", 8, nil, Center),
			pic("Soul", "heart", 12, R, {LayoutOrder = 1, Visible = on}),
			px("Label", label, "body", on and Y or W, {LayoutOrder = 2, TextTransparency = on and 0 or 0.3}),
		})
		return b
	end

	local closeBtn = box("Close", {Size = UDim2.fromOffset(44, 44), LayoutOrder = 9}, {
		px("X", "X", "body", W, {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5)}),
	}, 2, W, "TextButton")

	B.frame("Header", {Size = UDim2.new(1, 0, 0, 44), LayoutOrder = 1, Parent = inner}, {
		B.list("x", 16, nil, Center),
		px("Title", "SOUL SHOP", "title", W, {LayoutOrder = 1}),
		B.frame("Tabs", {AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.new(0, 0, 1, 0), LayoutOrder = 2}, {
			B.list("x", 20, nil, Center),
			tab("Souls", "SOULS", true, 1),
			tab("Trails", "TRAILS", false, 2),
			tab("Emotes", "EMOTES", false, 3),
		}),
		B.frame("Space", {Size = UDim2.new(0, 0, 1, 0), LayoutOrder = 3}, {B.flex()}),
		B.frame("Gold", {AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.new(0, 0, 1, 0), LayoutOrder = 4}, {
			B.list("x", 8, nil, Center),
			px("Amount", "2450", "body", W, {LayoutOrder = 1}),
			px("G", "G", "body", Y, {LayoutOrder = 2}),
		}),
		closeBtn,
	})

	local body = B.frame("Body", {Size = UDim2.new(1, 0, 0, 0), LayoutOrder = 2, Parent = inner}, {
		B.flex(),
		B.list("x", 16),
	})

	local list = B.make("ScrollingFrame", {
		Name = "List",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(),
		ScrollBarThickness = 6,
		ScrollBarImageColor3 = W,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
		LayoutOrder = 1,
		Parent = body,
	}, {
		B.flex(),
		B.list("y", 4),
	})

	local souls = {
		{"DETERMINATION", Color3.fromRGB(255, 0, 0), 0, "equipped", "* Refuse to fall. Once a round, a fatal hit leaves you at 1 HP.", "1 SAVE / ROUND"},
		{"PATIENCE", Color3.fromRGB(66, 252, 255), 800, nil, "* Stand still to slowly heal.", "+1 HP / 2 SEC"},
		{"BRAVERY", Color3.fromRGB(252, 166, 0), 950, "owned", "* Hits stagger you less.", "STUN -30%"},
		{"INTEGRITY", Color3.fromRGB(0, 60, 255), 1200, "pick", "* Your dash carries you further.", "DASH +25%"},
		{"PERSEVERANCE", Color3.fromRGB(213, 53, 217), 1500, nil, "* Stamina comes back faster.", "SP REGEN +20%"},
		{"KINDNESS", Color3.fromRGB(0, 192, 0), 2000, nil, "* Healing a friend heals you too.", "SHARED HEAL 50%"},
		{"JUSTICE", Color3.fromRGB(255, 255, 0), 3000, nil, "* Your traps last longer.", "TRAP +3 SEC"},
		{"???", Gy, nil, "locked", "* Reach LV 10 to see this SOUL.", ""},
	}
	local gold = 2450
	for i, s in souls do
		local name, col, price, st = s[1], s[2], s[3], s[4]
		local pick = st == "pick"
		local tag, tagCol
		if st == "equipped" then
			tag, tagCol = "EQUIPPED", Y
		elseif st == "owned" then
			tag, tagCol = "OWNED", Gy
		elseif st == "locked" then
			tag, tagCol = "LV 10", Gy
		else
			tag, tagCol = price .. " G", price > gold and R or W
		end
		local row = B.make("TextButton", {
			Name = name == "???" and "Locked" or name:sub(1, 1) .. name:sub(2):lower(),
			Text = "",
			AutoButtonColor = false,
			BorderSizePixel = 0,
			BackgroundColor3 = K,
			BackgroundTransparency = pick and 0 or 1,
			Size = UDim2.new(1, 0, 0, 44),
			LayoutOrder = i,
			Parent = list,
		}, {
			B.pad(0, 12, 0, 12),
			B.list("x", 12, nil, Center),
			pic("Icon", st == "locked" and "lock" or "heart", 20, col, {LayoutOrder = 1}),
			px("Name", name, "body", pick and Y or (st == "locked" and Gy or W), {LayoutOrder = 2}),
			B.frame("Space", {Size = UDim2.new(0, 0, 1, 0), LayoutOrder = 3}, {B.flex()}),
			pic("Check", "check", 14, tagCol, {LayoutOrder = 4, Visible = st == "owned" or st == "equipped"}),
			px("Price", tag, "body", pick and Y or tagCol, {LayoutOrder = 5}),
		})
		if pick then
			edge(2, W).Parent = row
		end
	end

	local pick = souls[4]
	local detail = box("Detail", {Size = UDim2.new(0, 248, 1, 0), LayoutOrder = 2, BackgroundTransparency = 0, Parent = body}, {
		B.pad(12),
		B.list("y", 8),
		B.frame("Top", {AutomaticSize = XY, Size = UDim2.new(), LayoutOrder = 1}, {
			B.list("x", 12, nil, Center),
			pic("Icon", "heart", 28, pick[2], {LayoutOrder = 1}),
			px("Name", pick[1], "body", Y, {LayoutOrder = 2}),
		}),
		px("Desc", pick[5], "caption", W, {
			LayoutOrder = 2,
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.new(1, 0, 0, 0),
			TextWrapped = true,
			LineHeight = 1.35,
			TextYAlignment = Enum.TextYAlignment.Top,
		}),
		px("Stat", pick[6], "caption", Cyan, {LayoutOrder = 3}),
		B.frame("Space", {Size = UDim2.new(1, 0, 0, 0), LayoutOrder = 4}, {
			B.flex(),
			pic("Big", "heart", 0, pick[2], {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.new(1, 0, 1, -16),
			}),
		}),
	}, 2)
	B.cap(112, 112).Parent = detail.Space.Big
	local buy = cmd("Buy", "star", "BUY 1200 G", nil, nil, 5, 220)
	buy.Parent = detail
	buy.Size = UDim2.new(1, 0, 0, 44)
	state(buy, "hover")

	B.make("TextButton", {
		Name = "Shade",
		Text = "",
		AutoButtonColor = false,
		BorderSizePixel = 0,
		BackgroundColor3 = K,
		BackgroundTransparency = 0.4,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 9,
		Visible = false,
		Parent = sroot,
	})
	local confirm = box("Confirm", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(460, 0), AutomaticSize = Enum.AutomaticSize.Y, Visible = false, ZIndex = 10, Parent = sroot}, {
		B.pad(16, 24),
		B.list("y", 20),
		B.scale(1, "Pop"),
		px("Ask", "* Buy INTEGRITY for 1200 G?", "body", W, {
			LayoutOrder = 1,
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.new(1, 0, 0, 0),
			TextWrapped = true,
			LineHeight = 1.3,
		}),
		B.frame("Choices", {Size = UDim2.new(1, 0, 0, 44), LayoutOrder = 2}, {
			B.list("x", 56, Enum.HorizontalAlignment.Center, Center),
			B.make("TextButton", {Name = "Yes", Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.fromOffset(120, 44), LayoutOrder = 1}, {
				B.list("x", 12, Enum.HorizontalAlignment.Center, Center),
				pic("Soul", "heart", 16, R, {LayoutOrder = 1}),
				px("Label", "YES", "body", Y, {LayoutOrder = 2}),
			}),
			B.make("TextButton", {Name = "No", Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.fromOffset(120, 44), LayoutOrder = 2}, {
				B.list("x", 12, Enum.HorizontalAlignment.Center, Center),
				pic("Soul", "heart", 16, R, {LayoutOrder = 1, Visible = false}),
				px("Label", "NO", "body", W, {LayoutOrder = 2}),
			}),
		}),
	}, 4)

	local set, troot = gui("Lab_Settings", 20)
	backdrop(set, 0.4)
	local spanel = box("Panel", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(0, 500, 1, -32), Parent = troot}, {
		B.scale(1, "Pop"),
		B.cap(500, 316),
		guard(),
	}, 4)
	glow(spanel, 4)
	local sin = B.frame("Inner", {ZIndex = 2, Parent = spanel}, {
		B.pad(12, 24),
		B.list("y", 0),
	})
	local rows = B.make("ScrollingFrame", {
		Name = "Rows",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(),
		ScrollBarThickness = 6,
		ScrollBarImageColor3 = W,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
		LayoutOrder = 1,
		Parent = sin,
	}, {
		B.flex(),
		B.list("y", 0),
	})
	local sclose = box("Close", {Size = UDim2.fromOffset(44, 44), LayoutOrder = 3}, {
		px("X", "X", "body", W, {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5)}),
	}, 2, W, "TextButton")
	B.frame("Header", {Size = UDim2.new(1, 0, 0, 44), LayoutOrder = 0, Parent = sin}, {
		B.list("x", 16, nil, Center),
		px("Title", "SETTINGS", "title", W, {LayoutOrder = 1}),
		B.frame("Space", {Size = UDim2.new(0, 0, 1, 0), LayoutOrder = 2}, {B.flex()}),
		sclose,
	})

	local function srow(name, label, order, on, kids)
		local r = B.make("TextButton", {
			Name = name,
			Text = "",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 44),
			LayoutOrder = order,
			Parent = rows,
		}, {
			B.pad(0, 12, 0, 0),
			B.list("x", 12, nil, Center),
			B.frame("Cursor", {Size = UDim2.fromOffset(16, 16), LayoutOrder = 1}, {
				pic("Soul", "heart", 16, R, {Visible = on}),
			}),
			px("Label", label, "body", on and Y or W, {AutomaticSize = Enum.AutomaticSize.None, Size = UDim2.fromOffset(160, 20), LayoutOrder = 2}),
		})
		for _, k in kids do
			k.Parent = r
		end
		return r
	end

	local function slider(a, text)
		return {
			box("Track", {Size = UDim2.fromOffset(164, 20), LayoutOrder = 3}, {
				B.box("Fill", Y, {Position = UDim2.fromOffset(4, 4), Size = UDim2.new(a, -8 * a, 1, -8)}),
			}, 2),
			px("Value", text, "body", W, {AutomaticSize = Enum.AutomaticSize.None, Size = UDim2.fromOffset(64, 20), TextXAlignment = Enum.TextXAlignment.Right, LayoutOrder = 4}),
		}
	end

	srow("Music", "MUSIC", 1, true, slider(0.8, "80"))
	srow("Sound", "SOUND", 2, false, slider(1, "100"))
	srow("Shake", "SHAKE", 3, false, {
		B.frame("Pick", {AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.new(0, 0, 1, 0), LayoutOrder = 3}, {
			B.list("x", 24, nil, Center),
			px("On", "ON", "body", Y, {LayoutOrder = 1}),
			px("Off", "OFF", "body", Gy, {LayoutOrder = 2}),
		}),
	})
	srow("Size", "UI SIZE", 4, false, slider(0.5, "1.5X"))
	srow("Controls", "CONTROLS", 5, false, {
		B.frame("Space", {Size = UDim2.new(0, 0, 1, 0), LayoutOrder = 3}, {B.flex()}),
		px("Go", ">", "body", W, {LayoutOrder = 4}),
	})
	B.frame("Foot", {Size = UDim2.new(1, 0, 0, 28), LayoutOrder = 2, Parent = sin}, {
		B.list("x", 10, Enum.HorizontalAlignment.Right, Center),
		chip("Escape", "ButtonB", true),
		px("Hint", "BACK", "caption", Gy, {LayoutOrder = 2}),
	})
	sin.Foot.Key.Size = UDim2.fromOffset(48, 24)
	sin.Foot.Key.Key.Text = "ESC"
	sin.Foot.Key:SetAttribute("Label", "ESC")
	box("CornerClose", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 22, 0, -16),
		Size = UDim2.fromOffset(44, 44),
		ZIndex = 5,
		Visible = false,
		Parent = spanel,
	}, {
		px("X", "X", "body", W, {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5)}),
	}, 3, W, "TextButton")

	local res, rroot = gui("Lab_Result", 30)
	backdrop(res, 0.5)
	local card = box("Dialog", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 24), Size = UDim2.new(1, -32, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = rroot}, {
		B.cap(640),
		B.pad(16, 24),
		B.scale(1, "Pop"),
		pic("Soul", "heart", 40, R, {AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 0, -32)}),
	}, 4)
	local dlg = B.frame("Body", {AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, 0, 0, 0), Parent = card}, {
		B.list("y", 14),
	})
	local function line(name, str, size, order)
		return px(name, str, size, W, {
			LayoutOrder = order,
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.new(1, 0, 0, 0),
			TextWrapped = true,
			LineHeight = 1.3,
			Parent = dlg,
		})
	end
	line("Title", "* YOU WON!", "title", 1)
	local earn = line("Earn", "* You earned 120 EXP and 45 GOLD.", "body", 2)
	earn.RichText = true
	earn.Text = "* You earned <font color=\"#FFFF00\">120</font> EXP and <font color=\"#FFFF00\">45</font> GOLD."
	line("Love", "* Your LOVE increased.", "body", 3)
	B.frame("Choices", {Size = UDim2.new(1, 0, 0, 44), LayoutOrder = 4, Parent = dlg}, {
		B.list("x", 20, Enum.HorizontalAlignment.Left, Center),
		cmd("Continue", "star", "CONTINUE", nil, nil, 1, 196),
		cmd("Shop", "heart", "SHOP", nil, nil, 2, 116),
	})
	state(dlg.Choices.Continue, "hover")

	B.make("ModuleScript", {Name = "Layout", Parent = shop}).Source = table.concat({
		"return function(gui, kind)",
		"\tgui.Root.Panel.Inner.Header.Title.Visible = kind ~= \"Phone\"",
		"\tgui.Root.Panel.Inner.Body.Detail.Space.Big.Visible = kind ~= \"Phone\"",
		"end",
	}, "\n")
	B.make("ModuleScript", {Name = "Layout", Parent = set}).Source = table.concat({
		"return function(gui, kind)",
		"\tlocal panel = gui.Root.Panel",
		"\tpanel.Inner.Foot.Visible = kind ~= \"Phone\" and kind ~= \"Tablet\"",
		"\tpanel.Inner.Header.Visible = kind ~= \"Phone\"",
		"\tpanel.CornerClose.Visible = kind == \"Phone\"",
		"end",
	}, "\n")

	for _, g in {hud, shop, set, res} do
		g.Parent = sg
	end
	local n = 0
	for _, g in {hud, shop, set, res} do
		n += #g:GetDescendants()
	end
	return "built 4 guis, " .. n .. " instances"
end
