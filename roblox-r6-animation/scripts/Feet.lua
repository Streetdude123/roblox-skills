-- planted feet for a stock r6 rig (1 x 2 x 1 legs on hips at the torso's bottom corners): a rigid leg is aimed from
-- its hip at a floor target so the torso can twist, lean and lunge while the feet stay where they stand. Use it as a
-- clip's post pass: clip.post = Feet.post({r = {x, z, yaw}, l = {x, z, yaw}}) plants the right and left soles at those
-- root-space points (x right, z forward negative, the floor 3 under the root) with the toe turned yaw degrees
-- (positive turns out to the character's left). A target may be a function of t that returns {x, z, yaw, lift} so a
-- foot can step (lift raises the sole off the floor). The torso must be low enough for both legs to reach; a leg that
-- cannot reach hangs no more than 0.12 below its hip; Feet.gap and the stats table from Feet.post report the need.
local Feet = {}

local V3 = Vector3.new
local LEGV = {[1] = V3(-0.5, -2, 0), [-1] = V3(0.5, -2, 0)}
local HIP_GAP = 0.12

-- lowest of the four sole corners in root space for a leg pose under a torso pose (the hip pivot is the leg's outer
-- top edge, so the sole centre sits half a stud inward of the pivot)
local function lowest(tp, s, pose)
	local centre = tp * CFrame.new(s, -1, 0) * pose * CFrame.new(-0.5 * s, -1, 0)
	local low = math.huge
	for _, x in ipairs({-0.5, 0.5}) do
		for _, z in ipairs({-0.5, 0.5}) do
			low = math.min(low, (centre * V3(x, -1, z)).Y)
		end
	end
	return low
end
Feet.lowest = lowest

-- the pose-space cframe of a leg whose sole centre stands on (fx, floor + lift, fz) with the toe at yaw, and the hip
-- gap it needed (over 0.12 the leg cannot reach: it hangs at 0.12 and the sole lifts)
function Feet.stand(tp, s, fx, fz, yaw, lift)
	local floor = -3 + (lift or 0)
	local hip = tp * V3(s, -1, 0)
	local v = LEGV[s]
	local rise, pose, gap = 0, CFrame.identity, 0
	-- four passes: solve the leg exactly for a sole centre raised by rise, then move rise so the lowest corner (which
	-- the twist and the tilt choose) lands on the floor; the sole centre never leaves (fx, fz)
	for _ = 1, 4 do
		local d = tp.Rotation:VectorToObjectSpace(V3(fx, floor + rise, fz) - hip)
		-- the leg only slides along the torso's own up axis (up hides inside the torso, down opens the hip), so the
		-- rotation alone carries the sole across: py leaves exactly one leg length for the rotation to cover
		local py = d.Y + math.sqrt(math.max(0, v.Magnitude ^ 2 - (d.X * d.X + d.Z * d.Z)))
		local w = d - V3(0, py, 0)
		local axis = v.Unit:Cross(w.Unit)
		local sinA, cosA = axis.Magnitude, v.Unit:Dot(w.Unit)
		local R = sinA < 1e-6 and CFrame.identity or CFrame.fromAxisAngle(axis / sinA, math.atan2(sinA, cosA))
		-- turn the leg about the hip-to-sole line (the sole centre stays put) until the toe points yaw degrees off the
		-- root's forward; two passes because that line leans a little off vertical
		for _ = 1, 2 do
			local fwd = (tp.Rotation * R):VectorToWorldSpace(V3(0, 0, -1))
			local cur = math.deg(math.atan2(-fwd.X, -fwd.Z))
			local delta = ((yaw or 0) - cur + 180) % 360 - 180
			-- the turn axis runs up the leg (sole to hip) so a positive delta turns the toe left the way yaw counts; w points down and turned every toe the wrong way (the left idle foot ended at -88 for a target of 10)
			R = CFrame.fromAxisAngle(-w.Unit, math.rad(delta)) * R
		end
		gap = math.max(0, -py)
		pose = CFrame.new(0, math.max(py, -HIP_GAP), 0) * R
		-- raising the aim is always safe; a leg that cannot reach and already floats stays aimed where it is, because
		-- lowering the aim of a leg that is too short only tips it further and digs its corner under the floor
		local err = lowest(tp, s, pose) - floor
		if gap > HIP_GAP and err > 0 then
			break
		end
		rise -= err
	end
	return pose, gap
end

local function target(spec, t)
	if type(spec) == "function" then
		return spec(t)
	end
	return spec
end

-- a post pass that plants both feet; the worst hip gap seen is kept in the returned table's gap field
function Feet.post(targets)
	local stats = {gap = 0}
	local fn = function(poses, t)
		local tp = poses.Torso
		if not tp then
			return
		end
		for s, key in pairs({[1] = "r", [-1] = "l"}) do
			local spec = targets[key] and target(targets[key], t)
			local name = s == 1 and "Right Leg" or "Left Leg"
			if spec and poses[name] then
				local cf, gap = Feet.stand(tp, s, spec[1], spec[2], spec[3], spec[4])
				poses[name] = cf
				stats.gap = math.max(stats.gap, gap)
			end
		end
	end
	return fn, stats
end

-- the hip gap a leg needs to stand on a floor target under a torso pose (0 when it reaches; drop the torso by the
-- excess over 0.12 or bring the target closer)
function Feet.gap(tp, s, fx, fz, lift)
	local _, gap = Feet.stand(tp, s, fx, fz, 0, lift)
	return gap
end

return Feet
