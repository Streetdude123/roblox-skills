local Poser = require(script.Parent.Poser)

local View = {}

local function bonesOf(model)
	local bones = {}
	for _, b in ipairs(model:GetDescendants()) do
		if b:IsA("Bone") then
			bones[(b.Name:gsub("%.%d+$", ""))] = b
		end
	end
	return bones
end

function View.new(template, cf, color)
	local model = template:Clone()
	model.Name = template.Name .. "View"
	for _, p in ipairs(model:GetDescendants()) do
		if p:IsA("BasePart") then
			p.Anchored = true
			if color then
				p.Color = color
			end
		end
	end
	model:PivotTo(cf)
	model.Parent = workspace
	return {model = model, bones = bonesOf(model)}
end

function View.write(view, poses)
	for name, b in pairs(view.bones) do
		b.Transform = poses[name] or CFrame.identity
	end
end

function View.clip(view, clip, t)
	View.write(view, Poser.posesAt(clip, t))
end

function View.pose(view, expanded)
	local poses = {}
	for name, r in pairs(expanded) do
		poses[name] = Poser.poseCF({r = r})
	end
	View.write(view, poses)
end

function View.point(view, name)
	return view.model:GetPivot():PointToObjectSpace(view.bones[name].TransformedWorldCFrame.Position)
end

function View.fit(view, start, make, score, steps)
	local v = table.clone(start)
	local function cost(w)
		View.pose(view, make(w))
		return score(function(name)
			return View.point(view, name)
		end)
	end
	local best = cost(v)
	for _, step in ipairs(steps or {20, 10, 5, 2.5, 1}) do
		local better, rounds = true, 0
		while better and rounds < 15 do
			better, rounds = false, rounds + 1
			for i = 1, #v do
				for _, dir in ipairs({1, -1}) do
					local w = table.clone(v)
					w[i] += dir * step
					local s = cost(w)
					if s < best then
						best, v, better = s, w, true
					end
				end
			end
		end
	end
	View.pose(view, make(v))
	return v, best
end

return View
