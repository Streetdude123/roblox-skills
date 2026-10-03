local src, name, base = ...
name = name or "Character"

local function part(n, size, cf, parent)
	local p = Instance.new("Part")
	p.Name = n
	p.Size = size
	p.CFrame = cf
	p.Transparency = 1
	p.CanCollide = n ~= "Head" and n ~= "HumanoidRootPart"
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end

local function motor(n, p0, p1, c0, c1)
	local m = Instance.new("Motor6D")
	m.Name = n
	m.Part0 = p0
	m.Part1 = p1
	m.C0 = c0
	m.C1 = c1
	m.Parent = p0
	return m
end

local model = Instance.new("Model")
model.Name = name
local at = CFrame.new(base)
local hrp = part("HumanoidRootPart", Vector3.new(2, 2, 1), at * CFrame.new(0, 3, 0), model)
local torso = part("Torso", Vector3.new(2, 2, 1), at * CFrame.new(0, 3, 0), model)
local head = part("Head", Vector3.new(2, 1, 1), at * CFrame.new(0, 4.5, 0), model)
local la = part("Left Arm", Vector3.new(1, 2, 1), at * CFrame.new(-1.5, 3, 0), model)
local ra = part("Right Arm", Vector3.new(1, 2, 1), at * CFrame.new(1.5, 3, 0), model)
local ll = part("Left Leg", Vector3.new(1, 2, 1), at * CFrame.new(-0.5, 1, 0), model)
local rl = part("Right Leg", Vector3.new(1, 2, 1), at * CFrame.new(0.5, 1, 0), model)
local hum = Instance.new("Humanoid")
hum.RigType = Enum.HumanoidRigType.R6
hum.Parent = model
model.PrimaryPart = hrp

local pi = math.pi
motor("RootJoint", hrp, torso, CFrame.Angles(-pi / 2, 0, pi), CFrame.Angles(-pi / 2, 0, pi))
motor("Neck", torso, head, CFrame.new(0, 1, 0) * CFrame.Angles(-pi / 2, 0, pi), CFrame.new(0, -0.5, 0) * CFrame.Angles(-pi / 2, 0, pi))
motor("Left Shoulder", torso, la, CFrame.new(-1, 0.5, 0) * CFrame.Angles(0, -pi / 2, 0), CFrame.new(0.5, 0.5, 0) * CFrame.Angles(0, -pi / 2, 0))
motor("Right Shoulder", torso, ra, CFrame.new(1, 0.5, 0) * CFrame.Angles(0, pi / 2, 0), CFrame.new(-0.5, 0.5, 0) * CFrame.Angles(0, pi / 2, 0))
motor("Left Hip", torso, ll, CFrame.new(-1, -1, 0) * CFrame.Angles(0, -pi / 2, 0), CFrame.new(-0.5, 1, 0) * CFrame.Angles(0, -pi / 2, 0))
motor("Right Hip", torso, rl, CFrame.new(1, -1, 0) * CFrame.Angles(0, pi / 2, 0), CFrame.new(0.5, 1, 0) * CFrame.Angles(0, pi / 2, 0))

local map = {
	Head = head, Hat = head, Torso = torso, LeftArm = la, RightArm = ra, LeftLeg = ll, RightLeg = rl,
	Saya = torso, Wakizashi = torso, KatanaSheathed = torso, Katana = ra,
}
local done = {}
for _, mp in src:GetDescendants() do
	if mp:IsA("MeshPart") then
		local key = mp.Name
		local to = map[key]
		if to then
			local cf = mp.CFrame
			mp.Anchored = false
			mp.CanCollide = false
			mp.CanQuery = false
			mp.Massless = true
			mp.Parent = model
			mp.CFrame = cf
			if key == "Katana" then
				motor("KatanaGrip", ra, mp, ra.CFrame:Inverse() * cf, CFrame.new())
			else
				local w = Instance.new("WeldConstraint")
				w.Part0 = to
				w.Part1 = mp
				w.Parent = mp
			end
			if key == "KatanaSheathed" then
				mp.Transparency = 1
			end
			table.insert(done, key)
		end
	end
end
model.Parent = workspace
return table.concat(done, ",")
