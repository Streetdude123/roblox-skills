local old = game.ServerStorage:FindFirstChild("SamTmp")
if old then
	old:Destroy()
end
local tmp = game.ReplicatedStorage.Samurai:Clone()
tmp.Name = "SamTmp"
tmp.Parent = game.ServerStorage
local mods = tmp.Modules
local Poser = require(mods.Poser)
_G.samClips = require(mods.Clips)
local RIG = game.ServerStorage.SamuraiSource.Preview

local function joints(model)
	local list = {}
	for _, j in ipairs(model:GetDescendants()) do
		if (j:IsA("JointInstance") or j:IsA("WeldConstraint")) and j.Part0 and j.Part1 and j.Part0:IsDescendantOf(model) and j.Part1:IsDescendantOf(model) then
			table.insert(list, j)
		end
	end
	return list
end

local function solve(model, rootCF, poses)
	local world = {[model.HumanoidRootPart] = rootCF}
	local list = joints(model)
	local grew = true
	while grew do
		grew = false
		for _, j in ipairs(list) do
			local a, b = j.Part0, j.Part1
			local c0 = j:IsA("WeldConstraint") and a.CFrame:ToObjectSpace(b.CFrame) or j.C0
			local c1 = j:IsA("WeldConstraint") and CFrame.identity or j.C1
			local mid = CFrame.identity
			if j:IsA("Motor6D") then
				local p = poses[b.Name]
				if p then
					local r = j.C0.Rotation
					mid = r:Inverse() * p * r
				end
			end
			if world[a] and not world[b] then
				world[b] = world[a] * c0 * mid * c1:Inverse()
				grew = true
			elseif world[b] and not world[a] then
				world[a] = world[b] * c1 * mid:Inverse() * c0:Inverse()
				grew = true
			end
		end
	end
	return world
end

local function ghost(parent, name)
	local g = RIG:Clone()
	g.Name = name
	for _, d in ipairs(g:GetDescendants()) do
		if d:IsA("BasePart") then
			d.Anchored = true
			d.CanCollide = false
		elseif d:IsA("LuaSourceContainer") then
			d:Destroy()
		end
	end
	g.Parent = parent
	return g
end

local function place(g, rootCF, poses)
	local world = solve(g, rootCF, poses)
	for part, cf in pairs(world) do
		part.CFrame = cf
	end
end

local FACE = {front = 0, side = -math.pi / 2, rear = math.pi, rear34 = math.pi * 0.75, front34 = -math.pi / 4, side34 = -math.pi * 0.3, left = math.pi / 2}

function _G.clearStrip(all)
	local f = workspace:FindFirstChild("SamStrip")
	if f then
		f:Destroy()
	end
	if all and tmp.Parent then
		tmp:Destroy()
	end
end

function _G.samStrip(clip, times, opts)
	opts = opts or {}
	_G.clearStrip()
	local f = Instance.new("Folder")
	f.Name = "SamStrip"
	f.Parent = workspace
	local gap = opts.gap or 7
	local base = opts.base or Vector3.new(0, 3, 60)
	local n = #times
	for i, t in ipairs(times) do
		local g = ghost(f, ("T%.3f"):format(t))
		local pos = base + Vector3.new((i - (n + 1) / 2) * gap, 0, 0)
		local cf = CFrame.new(pos) * CFrame.Angles(0, opts.yaw or 0, 0)
		if clip.root and not opts.flat then
			local up, fwd, yaw = clip.root(t)
			cf *= CFrame.new(0, up, -fwd * (opts.fwd or 0)) * CFrame.Angles(0, math.rad(yaw), 0)
		end
		place(g, cf, Poser.posesAt(clip, t, opts.ctx))
	end
	local face = FACE[opts.facing or "front"] or 0
	local mid = base + Vector3.new(0, 0.5, 0)
	local width = n * gap
	local dist = opts.dist or math.max(14, width * 0.95)
	local cam = mid + Vector3.new(math.sin(face) * -dist, opts.height or 3, math.cos(face) * -dist)
	return {cam.X, cam.Y, cam.Z}, {mid.X, mid.Y, mid.Z}
end

function _G.samOnion(clip, t0, t1, opts)
	opts = opts or {}
	_G.clearStrip()
	local f = Instance.new("Folder")
	f.Name = "SamStrip"
	f.Parent = workspace
	local base = opts.base or Vector3.new(0, 3, 60)
	local rootCF = CFrame.new(base) * CFrame.Angles(0, opts.yaw or 0, 0)
	local body = ghost(f, "Body")
	place(body, rootCF, Poser.posesAt(clip, opts.bodyAt or t1, opts.ctx))
	local steps = opts.steps or 14
	local keep = {RightKatana = true, LeftKatana = true, MouthKatana = true}
	for i = 0, steps do
		local t = t0 + (t1 - t0) * i / steps
		local g = ghost(f, ("O%.3f"):format(t))
		place(g, rootCF, Poser.posesAt(clip, t, opts.ctx))
		for _, d in ipairs(g:GetDescendants()) do
			if d:IsA("BasePart") then
				local m = d:FindFirstAncestorOfClass("Model")
				if m == g or not keep[m.Name] then
					d:Destroy()
				else
					d.Transparency = 0.2 + 0.6 * (1 - i / steps)
					d.Color = Color3.fromHSV(0.45, 0.8, 0.4 + 0.6 * i / steps)
					d.Material = Enum.Material.Neon
				end
			elseif d:IsA("Decal") or d:IsA("SurfaceAppearance") then
				d:Destroy()
			end
		end
	end
	return rootCF
end

function _G.samTips(clip, fps)
	local out = {}
	local g = ghost(workspace, "TipProbe")
	local low, lowAt, fast, fastAt = math.huge, 0, 0, 0
	local prev = {}
	local len = clip.length
	for i = 0, math.floor(len * (fps or 60)) do
		local t = i / (fps or 60)
		place(g, CFrame.new(0, 3, 0), Poser.posesAt(clip, t))
		for _, n in ipairs({"RightKatana", "LeftKatana", "MouthKatana"}) do
			local h = g[n][n]
			local tip = (h.CFrame * Vector3.new(0, -4.5, 0)).Y
			if tip < low then
				low, lowAt = tip, t
			end
			local up = h.CFrame.UpVector
			if prev[n] then
				local a = math.deg(math.acos(math.clamp(prev[n]:Dot(up), -1, 1)))
				if a > fast then
					fast, fastAt = a, t
				end
			end
			prev[n] = up
		end
	end
	g:Destroy()
	return ("lowest tip %.2f above floor at %.3f, fastest blade %.1f deg per frame at %.3f"):format(low, lowAt, fast, fastAt)
end
