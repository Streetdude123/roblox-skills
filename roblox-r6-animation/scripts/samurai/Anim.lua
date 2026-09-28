local RunService = game:GetService("RunService")

local Modules = script.Parent
local Poser = require(Modules.Poser)
local Clips = require(Modules.Clips)

local Anim = {}
local rigs = {}

function Anim.start(character)
	local rig = rigs[character]
	if rig then
		return rig
	end
	rig = Poser.attach(character)
	rigs[character] = rig
	rig:play(Clips.Stance, {fadeIn = 0.3})
	character.AncestryChanged:Connect(function(_, parent)
		if not parent then
			rigs[character] = nil
		end
	end)
	return rig
end

local function drive(character, rig, act, clip, dir, dist)
	local hrp = character.HumanoidRootPart
	local start = hrp.Position
	local facing = CFrame.lookAt(start, start + dir).Rotation
	local conn
	conn = RunService.PreRender:Connect(function()
		if rig.active ~= act or not character.Parent then
			conn:Disconnect()
			return
		end
		local t = act.time
		if clip.root then
			local up, fwd, yaw = clip.root(t)
			hrp.CFrame = CFrame.new(start + dir * math.min(fwd, dist) + Vector3.new(0, up, 0)) * facing * CFrame.Angles(0, math.rad(yaw), 0)
			hrp.AssemblyLinearVelocity = Vector3.zero
			hrp.AssemblyAngularVelocity = Vector3.zero
			if t >= clip.rootEnd then
				conn:Disconnect()
			end
		elseif clip.spin then
			hrp.CFrame = CFrame.new(hrp.Position) * facing * CFrame.Angles(0, math.rad(clip.spin(t)), 0)
			hrp.AssemblyAngularVelocity = Vector3.zero
			if t > clip.events.burst + 0.02 then
				conn:Disconnect()
			end
		elseif clip.dash then
			local a, b = clip.dash[1], clip.dash[2]
			local u = math.clamp((t - a) / (b - a), 0, 1)
			u = 1 - (1 - u) ^ 2
			hrp.CFrame = CFrame.new(start + dir * dist * u) * facing
			hrp.AssemblyLinearVelocity = Vector3.zero
			if t >= b then
				conn:Disconnect()
			end
		end
	end)
end

function Anim.cast(character, name, dir, mine, dist)
	local rig = Anim.start(character)
	local clip = Clips[name]
	local act
	act = rig:play(clip, {fadeIn = 0.08, onDone = function()
		if rig.active == act then
			rig:play(Clips.Stance, {fadeIn = 0.12})
		end
	end})
	if mine and (clip.spin or clip.dash or clip.root) then
		drive(character, rig, act, clip, dir, dist)
	end
	return act
end

function Anim.busy(character)
	local rig = rigs[character]
	local a = rig and rig.active
	return a and a.clip ~= Clips.Stance
end

return Anim
