local Debris = game:GetService("Debris")

local root = script.Parent.Parent
local Tw = require(script.Parent.Tw)

local Vfx = root.Assets.Vfx
local Meshes = root.Assets.Meshes

local Kit = {}

-- a template clone lands anchored at a cframe with every emitter and beam still off
function Kit.spawn(name, cf, parent)
	local template = Vfx:FindFirstChild(name)
	if not template then
		warn("no vfx template " .. name)
		return nil
	end
	local c = template:Clone()
	c.CFrame = cf
	for _, e in ipairs(c:GetDescendants()) do
		if e:IsA("ParticleEmitter") then
			e.TimeScale = 1 / Tw.S()
		end
	end
	c.Parent = parent
	return c
end

function Kit.mesh(name, parent, cf, size, color, transparency)
	local template = Meshes:FindFirstChild(name)
	if not template then
		warn("no mesh " .. name)
		return nil
	end
	local m = template:Clone()
	m.CFrame = cf
	m.Size = size
	m.Color = color
	m.Transparency = transparency or 0
	m.Parent = parent
	return m
end

local function match(e, filter)
	if filter == nil then
		return true
	end
	if type(filter) == "string" then
		return e.Name == filter
	end
	return filter[e.Name] ~= nil
end

function Kit.each(inst, fn, filter)
	if not inst then
		return
	end
	for _, e in ipairs(inst:GetDescendants()) do
		if e:IsA("ParticleEmitter") and match(e, filter) then
			fn(e)
		end
	end
end

function Kit.eachBeam(inst, fn)
	if not inst then
		return
	end
	for _, b in ipairs(inst:GetDescendants()) do
		if b:IsA("Beam") then
			fn(b)
		end
	end
end

-- a two colour tint fades from the first to the second over the life else a flat colour
function Kit.tint(inst, color, color2, filter)
	local seq = color2 and ColorSequence.new(color, color2) or ColorSequence.new(color)
	Kit.each(inst, function(e)
		e.Color = seq
	end, filter)
	if not filter then
		Kit.eachBeam(inst, function(b)
			b.Color = seq
		end)
	end
	return inst
end

local function scaleSeq(seq, k)
	local kps = {}
	for _, kp in ipairs(seq.Keypoints) do
		table.insert(kps, NumberSequenceKeypoint.new(kp.Time, kp.Value * k, kp.Envelope * k))
	end
	return NumberSequence.new(kps)
end

-- sizes scale on every emitter and beam so a kit piece tuned for one body fits a bigger scene
function Kit.scale(inst, k, filter)
	Kit.each(inst, function(e)
		e.Size = scaleSeq(e.Size, k)
	end, filter)
	if not filter then
		Kit.eachBeam(inst, function(b)
			b.Width0 *= k
			b.Width1 *= k
		end)
	end
	return inst
end

function Kit.glow(inst, le, filter)
	Kit.each(inst, function(e)
		e.LightEmission = le
		e.LightInfluence = 0
	end, filter)
	return inst
end

function Kit.set(inst, props, filter)
	Kit.each(inst, function(e)
		for k, v in pairs(props) do
			e[k] = v
		end
	end, filter)
	return inst
end

-- counts is a number for every emitter or a table of emitter name to count
function Kit.emit(inst, counts)
	if not inst then
		return
	end
	Kit.each(inst, function(e)
		local n = counts
		if type(counts) == "table" then
			n = counts[e.Name] or counts[e.Texture:match("%d+") or ""]
		end
		if n and n > 0 then
			e:Emit(n)
		end
	end)
	return inst
end

function Kit.enable(inst, on, filter)
	Kit.each(inst, function(e)
		e.Enabled = on
	end, filter)
	return inst
end

-- beams grow in from nothing so a rune ring or a light fan never pops on
function Kit.beams(inst, on, dur, delayTime)
	Kit.eachBeam(inst, function(b)
		local w0, w1 = b:GetAttribute("W0"), b:GetAttribute("W1")
		if not w0 then
			w0, w1 = b.Width0, b.Width1
			b:SetAttribute("W0", w0)
			b:SetAttribute("W1", w1)
		end
		if on then
			b.Width0 = 0
			b.Width1 = 0
			b.Enabled = true
			Tw.play(b, {Width0 = w0, Width1 = w1}, dur or 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out, delayTime)
		else
			local t = Tw.play(b, {Width0 = 0, Width1 = 0}, dur or 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In, delayTime)
			t.Completed:Once(function()
				b.Enabled = false
			end)
		end
	end)
	return inst
end

-- stops the emitters and lets the last particles die before the part goes
function Kit.kill(inst, life)
	if not inst then
		return
	end
	Kit.enable(inst, false)
	Kit.eachBeam(inst, function(b)
		b.Enabled = false
	end)
	Debris:AddItem(inst, (life or 3) * Tw.S())
end

-- a one shot spawns emits and cleans itself
function Kit.burst(name, cf, parent, counts, o)
	local inst = Kit.spawn(name, cf, parent)
	if not inst then
		return nil
	end
	if o then
		if o.color then
			Kit.tint(inst, o.color, o.color2, o.tintFilter)
		end
		if o.scale then
			Kit.scale(inst, o.scale, o.scaleFilter)
		end
		if o.glow then
			Kit.glow(inst, o.glow)
		end
		if o.set then
			Kit.set(inst, o.set, o.setFilter)
		end
	end
	Kit.emit(inst, counts)
	Debris:AddItem(inst, ((o and o.life) or 3) * Tw.S())
	return inst
end

return Kit
