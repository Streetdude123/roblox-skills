local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local ContentProvider = game:GetService("ContentProvider")

local template = script.Parent.Burst

local RISE = 0.07
local DRIFT = 0.06
local THIN_AT = 0.4
local THIN_TIME = 0.4
local LIFE = 1.6

local Cast = {}

local function outQuart(t)
	return 1 - (1 - t) ^ 4
end

local function faded(seq, k)
	local points = {}
	for _, p in seq.Keypoints do
		table.insert(points, NumberSequenceKeypoint.new(p.Time, 1 - (1 - p.Value) * k))
	end
	return NumberSequence.new(points)
end

function Cast.rig(burst)
	local light = burst.Base.Light
	local rig = {burst = burst, light = light, peak = light:GetAttribute("Peak"), beams = {}, spots = {}}
	for _, v in burst:GetChildren() do
		if v:IsA("Beam") then
			rig.beams[v] = {v.Width0, v.Width1, v.Transparency}
		elseif v:GetAttribute("Lift") then
			rig.spots[v] = v.Position
		end
	end
	return rig
end

function Cast.pose(rig, t)
	local grow = outQuart(math.min(t / RISE, 1))
	local lift = grow + DRIFT * math.min(t / 0.5, 1)
	for a, p in rig.spots do
		a.Position = Vector3.new(p.X, math.max(p.Y * lift, 0.3), p.Z)
	end
	local k = grow * (1 - math.clamp((t - THIN_AT) / THIN_TIME, 0, 1))
	for b, base in rig.beams do
		b.Width0 = base[1] * (0.35 + 0.65 * k)
		b.Width1 = base[2] * (0.35 + 0.65 * k)
		b.Transparency = faded(base[3], k)
		b.Enabled = k > 0
	end
	rig.light.Brightness = rig.peak * grow * math.exp(-t * 3.5)
end

function Cast.fire(rig)
	for _, e in rig.burst:GetDescendants() do
		if e:IsA("ParticleEmitter") then
			e:Emit(e:GetAttribute("Count"))
		end
	end
end

function Cast.warm()
	local burst = template:Clone()
	local textures = {}
	for _, v in burst:GetDescendants() do
		if v:IsA("ParticleEmitter") or v:IsA("Beam") then
			v.Transparency = NumberSequence.new(0.98)
			table.insert(textures, v.Texture)
		end
	end
	ContentProvider:PreloadAsync(textures)
	burst.CFrame = workspace.CurrentCamera.CFrame * CFrame.new(0, -2, -12)
	burst.Parent = workspace
	RunService.RenderStepped:Wait()
	Cast.fire({burst = burst})
	Debris:AddItem(burst, 0.6)
end

function Cast.play(pos)
	local burst = template:Clone()
	burst.CFrame = CFrame.new(pos)
	local rig = Cast.rig(burst)
	Cast.pose(rig, 0)
	burst.Parent = workspace

	local start
	local step
	step = RunService.RenderStepped:Connect(function()
		if not start then
			start = os.clock()
			Cast.fire(rig)
		end
		local t = os.clock() - start
		Cast.pose(rig, t)
		if t > THIN_AT + THIN_TIME then
			step:Disconnect()
			rig.light.Enabled = false
		end
	end)

	Debris:AddItem(burst, LIFE)
end

return Cast
