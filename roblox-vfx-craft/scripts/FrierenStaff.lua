local source = game.ServerStorage.Quarantine.StaffA:Clone()
source:ScaleTo(4.8 / 16.04)

local body, gem
for _, d in source:GetDescendants() do
	if d:IsA("MeshPart") then
		if d.Size.Y > 3 then
			body = d
		else
			gem = d
		end
	end
end

local up = body.CFrame.UpVector
local bottom = body.Position - up * body.Size.Y / 2

local staff = Instance.new("Model")
staff.Name = "Staff"

local grip = Instance.new("Part")
grip.Name = "Grip"
grip.Size = Vector3.new(0.2, 0.2, 0.2)
grip.Transparency = 1
grip.CanCollide = false
grip.CanQuery = false
grip.CanTouch = false
grip.Massless = true
grip.CFrame = CFrame.fromMatrix(bottom + up * body.Size.Y * 0.4, body.CFrame.RightVector, up)
grip.Parent = staff

body.Name = "Body"
gem.Name = "Gem"
for _, p in {body, gem} do
	p.Anchored = false
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Massless = true
	local m = Instance.new("Motor6D")
	m.Name = p.Name
	m.Part0 = grip
	m.Part1 = p
	m.C0 = grip.CFrame:ToObjectSpace(p.CFrame)
	m.Parent = grip
	p.Parent = staff
end

local tip = Instance.new("Attachment")
tip.Name = "Tip"
tip.Parent = grip
tip.WorldPosition = gem.Position

staff.PrimaryPart = grip
local assets = game.ReplicatedStorage.Frieren.Assets
local old = assets:FindFirstChild("Staff")
if old then
	old:Destroy()
end
staff.Parent = assets
source:Destroy()

return string.format("staff tip %.2f %.2f %.2f", tip.Position.X, tip.Position.Y, tip.Position.Z)
