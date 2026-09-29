-- planted feet for any two-legged Motor6D rig whose legs are rigid parts hung from a hip pivot (Feet.lua is the stock
-- r6 version of this). The geometry comes from the rig, so custom r6-style rigs (armoured warriors with longer legs and
-- hips at the leg's top centre) plant as well as stock ones. RigFeet.new(geom) takes:
--   hip   = {[1] = right hip pivot, [-1] = left hip pivot} in the torso's axes (the leg joint's C0 position)
--   leg   = the vector from the hip pivot to the sole centre at rest, in the leg's axes (C1 position down the part)
--   sole  = {x = half width, z = half depth} of the sole
--   floor = the floor height in root space (the rest pose's sole height)
--   names = {[1] = right leg joint, [-1] = left leg joint}, torso = the root joint name
--   gap   = the largest downward hip slide allowed (0.12 hides inside most torsos)
-- The joints' C0 and C1 must have no rotation (pose space = the torso's axes); rotate the geometry first if they do.
-- rf.post({r = {x, z, yaw}, l = {x, z, yaw}}) is a clip post pass like Feet.post: a target may be a function of t
-- that returns {x, z, yaw, lift}; x right, z forward negative, yaw positive turns the toe to the character's left.
local RigFeet = {}

local V3 = Vector3.new

function RigFeet.new(g)
	local rf = {geom = g}
	local L = g.leg.Magnitude
	local down = g.leg.Unit

	local function lowest(tp, s, pose)
		local frame = tp * CFrame.new(g.hip[s]) * pose
		local low = math.huge
		for _, x in ipairs({-g.sole.x, g.sole.x}) do
			for _, z in ipairs({-g.sole.z, g.sole.z}) do
				low = math.min(low, (frame * (g.leg + V3(x, 0, z))).Y)
			end
		end
		return low
	end
	rf.lowest = lowest

	-- the leg pose whose sole centre stands on (fx, floor + lift, fz) with the toe at yaw, and the hip gap it needed
	function rf.stand(tp, s, fx, fz, yaw, lift)
		local floor = g.floor + (lift or 0)
		local hip = tp * g.hip[s]
		local rise, pose, gap = 0, CFrame.identity, 0
		for _ = 1, 4 do
			local d = tp.Rotation:VectorToObjectSpace(V3(fx, floor + rise, fz) - hip)
			local py = d.Y + math.sqrt(math.max(0, L * L - (d.X * d.X + d.Z * d.Z)))
			local w = d - V3(0, py, 0)
			local axis = down:Cross(w.Unit)
			local sinA, cosA = axis.Magnitude, down:Dot(w.Unit)
			local R = sinA < 1e-6 and CFrame.identity or CFrame.fromAxisAngle(axis / sinA, math.atan2(sinA, cosA))
			for _ = 1, 2 do
				local fwd = (tp.Rotation * R):VectorToWorldSpace(V3(0, 0, -1))
				local cur = math.deg(math.atan2(-fwd.X, -fwd.Z))
				local delta = ((yaw or 0) - cur + 180) % 360 - 180
				R = CFrame.fromAxisAngle(-w.Unit, math.rad(delta)) * R
			end
			gap = math.max(0, -py)
			pose = CFrame.new(0, math.max(py, -g.gap), 0) * R
			local err = lowest(tp, s, pose) - floor
			if gap > g.gap and err > 0 then
				break
			end
			rise -= err
		end
		return pose, gap
	end

	function rf.post(targets)
		local stats = {gap = 0}
		local fn = function(poses, t)
			local tp = poses[g.torso]
			if not tp then
				return
			end
			for s, key in pairs({[1] = "r", [-1] = "l"}) do
				local spec = targets[key]
				if type(spec) == "function" then
					spec = spec(t)
				end
				local name = g.names[s]
				if spec and poses[name] then
					local cf, gap = rf.stand(tp, s, spec[1], spec[2], spec[3], spec[4])
					poses[name] = cf
					stats.gap = math.max(stats.gap, gap)
				end
			end
		end
		return fn, stats
	end

	-- the sole corners in root space for a clip at t, for the foot check (lowest corner height and sole centre)
	function rf.sole(poses, s)
		local tp = poses[g.torso]
		local pose = poses[g.names[s]] or CFrame.identity
		local frame = tp * CFrame.new(g.hip[s]) * pose
		return frame * g.leg, lowest(tp, s, pose)
	end

	return rf
end

-- geometry read from a rig: hips from the leg joints' C0, the leg vector from C1 and the part height, the floor from
-- the rest pose (the root joint named torso, legs named by the two names)
function RigFeet.fromRig(rig, torsoName, rightName, leftName, gap)
	local motors = {}
	for _, m in ipairs(rig:GetDescendants()) do
		if m:IsA("Motor6D") and m.Part1 then
			motors[m.Part1.Name] = m
		end
	end
	local r, l = motors[rightName], motors[leftName]
	local leg = V3(0, -(r.C1.Position.Y + r.Part1.Size.Y / 2), 0)
	local root = motors[torsoName].Part0
	local restHip = r.Part0.CFrame * r.C0.Position
	local soleY = (restHip + leg).Y
	return {
		hip = {[1] = r.C0.Position, [-1] = l.C0.Position},
		leg = leg,
		sole = {x = r.Part1.Size.X / 2, z = r.Part1.Size.Z / 2},
		floor = soleY - root.Position.Y,
		names = {[1] = rightName, [-1] = leftName},
		torso = torsoName,
		gap = gap or 0.12,
	}
end

return RigFeet
