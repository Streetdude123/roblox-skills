local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Poser = require(script.Parent.Poser)
local Clips = require(script.Parent.Clips)

local Locomotion = {}

-- studs of ground covered by one full walk cycle so the feet plant at any speed
local STRIDE = 13
local controllers = {}

local function approach(current, target, rate, dt)
	return current + (target - current) * (1 - math.exp(-rate * dt))
end

local function update(ctrl, dt)
	local ctx = ctrl.ctx
	if ctrl.frozen then
		return
	end
	local humanoid, hrp = ctrl.humanoid, ctrl.hrp
	if not hrp.Parent or not humanoid.Parent then
		return
	end
	ctx.t += dt
	local v = hrp.AssemblyLinearVelocity
	local ground = math.sqrt(v.X * v.X + v.Z * v.Z)
	ctx.speed = approach(ctx.speed, ground, 12, dt)
	local state = humanoid:GetState()
	local airborne = state == Enum.HumanoidStateType.Freefall or state == Enum.HumanoidStateType.Jumping or state == Enum.HumanoidStateType.Flying
	ctx.air = approach(ctx.air, airborne and 1 or 0, 14, dt)
	-- the first part of a jump lifts the knee higher than the fall that follows
	ctx.jump = approach(ctx.jump, (state == Enum.HumanoidStateType.Jumping or v.Y > 8) and 1 or 0, 10, dt)
	local walkTarget = math.clamp((ctx.speed - 0.6) / 3.5, 0, 1) * (1 - ctx.air)
	ctx.walk = approach(ctx.walk, walkTarget, 7, dt)
	if ctx.walk > 0.01 then
		ctx.phase = (ctx.phase + math.pi * 2 * ctx.speed / STRIDE * dt) % (math.pi * 2)
	else
		-- a stopped walk settles the phase to the nearest passing pose so the legs come together
		local rest = ctx.phase < math.pi and 0 or math.pi * 2
		if math.abs(ctx.phase - math.pi) < 0.5 then
			rest = math.pi
		end
		ctx.phase = approach(ctx.phase, rest, 8, dt)
	end
	-- the landing absorbs in 0.12 s holds the bottom 0.12 s and recovers over 0.28 s the way the pro clip does
	ctx.landT += dt
	local lt = ctx.landT
	if lt < 0.12 then
		ctx.land = math.sin(lt / 0.12 * math.pi / 2)
	elseif lt < 0.24 then
		ctx.land = 1
	elseif lt < 0.52 then
		local u = (lt - 0.24) / 0.28
		ctx.land = 1 - (1 - (1 - u) * (1 - u))
	else
		ctx.land = 0
	end
	ctx.run = approach(ctx.run, math.clamp((ctx.speed - 18) / 8, 0, 1) * (1 - ctx.air), 6, dt)
	ctx.stand = ctrl.character:FindFirstChild("Stand") ~= nil
end

-- the roblox animate script only runs on the owner so stopping it there stops the replicated tracks too
local function silenceAnimate(character, humanoid)
	local animate = character:FindFirstChild("Animate")
	if animate and animate:IsA("LocalScript") then
		animate.Disabled = true
	end
	local animator = humanoid:FindFirstChildOfClass("Animator")
	if animator then
		for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
			track:Stop(0)
		end
	end
end

function Locomotion.start(character)
	if controllers[character] then
		return controllers[character]
	end
	local humanoid = character:WaitForChild("Humanoid", 10)
	local hrp = character:WaitForChild("HumanoidRootPart", 10)
	if not humanoid or not hrp then
		return nil
	end
	local ctx = {t = math.random() * 10, phase = 0, speed = 0, walk = 0, run = 0, air = 0, jump = 0, land = 0, landT = 10, stand = false}
	local rig = Poser.attach(character, ctx)
	local ctrl = {character = character, humanoid = humanoid, hrp = hrp, ctx = ctx, rig = rig}
	controllers[character] = ctrl
	if Players.LocalPlayer and Players.LocalPlayer.Character == character then
		task.spawn(function()
			local animate = character:WaitForChild("Animate", 5)
			if animate then
				silenceAnimate(character, humanoid)
			end
		end)
	end
	silenceAnimate(character, humanoid)
	rig:play(Clips.DioMove, {fadeIn = 0.25})
	ctrl.landConn = humanoid.StateChanged:Connect(function(_, new)
		if new == Enum.HumanoidStateType.Landed then
			ctx.landT = 0
		end
	end)
	ctrl.conn = RunService.Heartbeat:Connect(function(dt)
		update(ctrl, dt)
	end)
	ctrl.ancestry = character.AncestryChanged:Connect(function(_, parent)
		if not parent then
			Locomotion.stop(character)
		end
	end)
	return ctrl
end

function Locomotion.stop(character)
	local ctrl = controllers[character]
	if not ctrl then
		return
	end
	controllers[character] = nil
	ctrl.conn:Disconnect()
	ctrl.landConn:Disconnect()
	ctrl.ancestry:Disconnect()
	ctrl.rig:stop(0)
end

function Locomotion.get(character)
	return controllers[character]
end

-- a move clip takes the body over and hands it back to the walk when it ends
function Locomotion.override(character, clip, opts)
	local ctrl = controllers[character] or Locomotion.start(character)
	if not ctrl then
		return nil
	end
	opts = opts or {}
	local after = opts.onDone
	opts.onDone = function()
		ctrl.rig:play(Clips.DioMove, {fadeIn = opts.fadeOut or 0.3})
		if after then
			after()
		end
	end
	return ctrl.rig:play(clip, opts)
end

function Locomotion.release(character, fade)
	local ctrl = controllers[character]
	if ctrl and not ctrl.rig:playing(Clips.DioMove) then
		ctrl.rig:play(Clips.DioMove, {fadeIn = fade or 0.3})
	end
end

return Locomotion
