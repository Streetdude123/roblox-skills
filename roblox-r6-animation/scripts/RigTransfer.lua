local RigTransfer = {}

local function motors(model)
	local m = {}
	for _, d in model:GetDescendants() do
		if d:IsA("Motor6D") then
			m[d.Part1.Name] = d
		end
	end
	return m
end

local function order(mots)
	local list = {}
	local function walk(p)
		for name, m in mots do
			if m.Part0.Name == p then
				table.insert(list, name)
				walk(name)
			end
		end
	end
	walk("HumanoidRootPart")
	return list
end

local function fk(mots, ord, poses)
	local rel = {HumanoidRootPart = CFrame.identity}
	for _, name in ord do
		local m = mots[name]
		rel[name] = rel[m.Part0.Name] * m.C0 * (poses[name] or CFrame.identity) * m.C1:Inverse()
	end
	return rel
end

function RigTransfer.new(oldModel, newModel, map)
	local om, nm = motors(oldModel), motors(newModel)
	local oo, no = order(om), order(nm)
	local restO, restN = fk(om, oo, {}), fk(nm, no, {})
	local off = {}
	for n, o in map do
		off[n] = restO[o]:Inverse() * restN[n]
	end
	local t = {}

	function t.convert(src, name, priority)
		local kfs = Instance.new("KeyframeSequence")
		kfs.Name = name
		kfs.Loop = src.Loop
		kfs.Priority = priority or src.Priority
		local frames = {}
		for _, kf in src:GetChildren() do
			if kf:IsA("Keyframe") then
				table.insert(frames, kf)
			end
		end
		table.sort(frames, function(a, b)
			return a.Time < b.Time
		end)
		local worst = 0
		for _, kf in frames do
			local poses, weight = {}, {}
			for _, p in kf:GetDescendants() do
				if p:IsA("Pose") then
					poses[p.Name] = p.Weight > 0 and p.CFrame or CFrame.identity
					weight[p.Name] = p.Weight
				end
			end
			local relO = fk(om, oo, poses)
			local relN = {HumanoidRootPart = CFrame.identity}
			local out = {}
			for _, n in no do
				local m = nm[n]
				local goal = relO[map[n]] * off[n]
				out[n] = m.C0:Inverse() * relN[m.Part0.Name]:Inverse() * goal * m.C1
				relN[n] = relN[m.Part0.Name] * m.C0 * out[n] * m.C1:Inverse()
				worst = math.max(worst, (relN[n].Position - goal.Position).Magnitude)
			end
			local key = Instance.new("Keyframe")
			key.Time = kf.Time
			for _, mk in kf:GetChildren() do
				if mk:IsA("KeyframeMarker") then
					mk:Clone().Parent = key
				end
			end
			local root = Instance.new("Pose")
			root.Name = "HumanoidRootPart"
			root.Weight = 0
			root.Parent = key
			local made = {HumanoidRootPart = root}
			for _, n in no do
				local p = Instance.new("Pose")
				p.Name = n
				p.EasingStyle = Enum.PoseEasingStyle.Linear
				if (weight[map[n]] or 0) > 0 then
					p.CFrame = out[n]
					p.Weight = 1
				else
					p.Weight = 0
				end
				p.Parent = made[nm[n].Part0.Name]
				made[n] = p
			end
			key.Parent = kfs
		end
		return kfs, worst
	end

	return t
end

return RigTransfer
