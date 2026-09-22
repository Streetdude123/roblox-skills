local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Tw = require(script.Parent.Tw)

local CameraRig = {}

local cam = workspace.CurrentCamera
local vals
local origin
local trauma = 0
local seed = math.random() * 100
local rumbling = false
local smoothCF, smoothFov
local frozenUntil = 0
local floorTrauma = 0
local running = {}

local function noise(t, o)
	return math.noise(t, o, seed)
end

local function make(name, v)
	local nv = Instance.new("NumberValue")
	nv.Name = name
	nv.Value = v
	return nv
end

local function decay(dt)
	trauma = math.max(0, trauma - dt * 1.5 / Tw.S())
end

-- low frequency noise reads as a heavy rumble instead of a jitter
local function shakeCF()
	local t = os.clock() * 13
	local s = math.max(trauma, floorTrauma) ^ 2
	local off = Vector3.new(noise(t, 1), noise(t, 2), noise(t, 3)) * s * 2.6
	local rot = CFrame.Angles(noise(t, 4) * s * 0.05, noise(t, 5) * s * 0.05, noise(t, 6) * s * 0.06)
	return CFrame.new(off) * rot
end

local function target()
	local a = math.rad(vals.angle.Value)
	local pos = (origin * CFrame.Angles(0, a, 0)):PointToWorldSpace(Vector3.new(0, vals.height.Value, vals.dist.Value))
	local look = origin.Position + Vector3.new(0, vals.lookY.Value, 0)
	return CFrame.lookAt(pos, look) * CFrame.Angles(0, 0, math.rad(vals.roll.Value))
end

-- angle 0 sits behind the origin's facing and every shot is a tween on number values that a follow lerp then smooths
function CameraRig.take(originCF, params)
	CameraRig.stopRumble()
	origin = originCF
	vals = {
		angle = make("angle", params.angle or 30),
		dist = make("dist", params.dist or 18),
		height = make("height", params.height or 6),
		lookY = make("lookY", params.lookY or 3),
		fov = make("fov", params.fov or 70),
		roll = make("roll", params.roll or 0),
	}
	cam.CameraType = Enum.CameraType.Scriptable
	trauma = 0
	floorTrauma = 0.16
	running = {}
	smoothCF = target()
	smoothFov = vals.fov.Value
	RunService:BindToRenderStep("UltCamera", Enum.RenderPriority.Camera.Value + 1, function(dt)
		decay(dt)
		if os.clock() < frozenUntil then
			return
		end
		local k = 1 - math.exp(-dt * 9 / Tw.S())
		smoothCF = smoothCF:Lerp(target(), k)
		smoothFov += (vals.fov.Value - smoothFov) * (1 - math.exp(-dt * 12 / Tw.S()))
		cam.CFrame = smoothCF * shakeCF()
		cam.FieldOfView = smoothFov
	end)
end

-- a delayed shot waits before it is created so it does not cancel the shot already running
function CameraRig.shot(params, dur, style, dir, delayTime)
	if not vals then
		return
	end
	local mine = vals
	local function go()
		if vals ~= mine then
			return
		end
		local info = TweenInfo.new(dur * Tw.S(), style or Enum.EasingStyle.Sine, dir or Enum.EasingDirection.InOut)
		for k, v in pairs(params) do
			local t = TweenService:Create(vals[k], info, {Value = v})
			running[k] = t
			t:Play()
		end
	end
	if delayTime and delayTime > 0 then
		task.delay(delayTime * Tw.S(), go)
	else
		go()
	end
end

-- a cut snaps every value and the follow lerp so the next frame is already the new shot
function CameraRig.cutTo(params)
	if not vals then
		return
	end
	for k, v in pairs(params) do
		if running[k] then
			running[k]:Cancel()
			running[k] = nil
		end
		vals[k].Value = v
	end
	smoothCF = target()
	smoothFov = vals.fov.Value
	cam.CFrame = smoothCF
	cam.FieldOfView = smoothFov
end

-- a low constant motion so the camera breathes between hits
function CameraRig.floor(v)
	floorTrauma = v
end

-- cutout frames want a dead still camera so the rig skips its updates for the length of the frames
function CameraRig.freeze(dur)
	frozenUntil = os.clock() + dur * Tw.S()
end

function CameraRig.kick(amount)
	trauma = math.min(1, trauma + amount)
end

-- an instant hand back for when the screen is already black so the default camera wakes behind the body
function CameraRig.cut(character)
	if not vals then
		return
	end
	RunService:UnbindFromRenderStep("UltCamera")
	vals = nil
	cam.CameraType = Enum.CameraType.Custom
	cam.FieldOfView = 70
	local hrp = character and character:FindFirstChild("HumanoidRootPart")
	if hrp then
		local pos = hrp.Position - hrp.CFrame.LookVector * 12 + Vector3.new(0, 5, 0)
		cam.CFrame = CFrame.lookAt(pos, hrp.Position + Vector3.new(0, 1.5, 0))
	end
end

-- spectators only get the shake with distance falloff on top of whatever camera they already run
function CameraRig.rumble(pos)
	if vals or rumbling then
		return
	end
	rumbling = true
	RunService:BindToRenderStep("UltRumble", Enum.RenderPriority.Camera.Value + 1, function(dt)
		decay(dt)
		local d = (cam.CFrame.Position - pos).Magnitude
		local fall = math.clamp(1 - (d - 40) / 220, 0, 1)
		if fall > 0 and trauma > 0 then
			cam.CFrame = cam.CFrame * CFrame.new():Lerp(shakeCF(), fall)
		end
	end)
end

function CameraRig.stopRumble()
	if rumbling then
		RunService:UnbindFromRenderStep("UltRumble")
		rumbling = false
	end
end

return CameraRig
