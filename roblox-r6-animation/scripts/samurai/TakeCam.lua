local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local cam = workspace.CurrentCamera
local START = CFrame.new(0, 3, 4)

local SHOTS = {
	player = nil,
	side = {eye = {Vector3.new(27, 4, -11), Vector3.new(26, 4.5, -14)}, look = {Vector3.new(1, 2.4, -13), Vector3.new(1, 2.2, -16)}, fov = 58},
	impact = {eye = {Vector3.new(15, 2.6, -37), Vector3.new(14, 2.9, -38)}, look = {Vector3.new(3, 3, -17), Vector3.new(3, 3.2, -15)}, fov = 60},
	front = {eye = {Vector3.new(-8, 1.6, -9), Vector3.new(-7, 1.4, -10.5)}, look = {Vector3.new(0, 3.2, 0), Vector3.new(0, 3, -1)}, fov = 55},
	high = {eye = {Vector3.new(-6, 10, 13), Vector3.new(-5, 10.5, 11)}, look = {Vector3.new(3, 0.5, -16), Vector3.new(3, 0.5, -18)}, fov = 62},
}

local function reset()
	local char = player.Character
	char:PivotTo(START)
	cam.CameraType = Enum.CameraType.Custom
	cam.CFrame = CFrame.lookAt(START.Position + Vector3.new(0, 5, 12), START.Position + Vector3.new(0, 1.5, -14))
end

local function waitCast()
	local j = player.Character.HumanoidRootPart:WaitForChild("Root Hip")
	local t0 = os.clock()
	while os.clock() - t0 < 30 do
		RunService.PreRender:Wait()
		local _, ang = j.Transform:ToAxisAngle()
		if math.abs(ang) > 0.02 then
			return true
		end
	end
	return false
end

local function roll(shot)
	local hum = player.Character.Humanoid
	local hrp = player.Character.HumanoidRootPart
	cam.CameraType = Enum.CameraType.Scriptable
	cam.FieldOfView = shot.fov
	local t0 = os.clock()
	local dur = 2.8
	RunService:BindToRenderStep("TakeCam", Enum.RenderPriority.Camera.Value + 1, function()
		local u = math.clamp((os.clock() - t0) / dur, 0, 1)
		u = u * u * (3 - 2 * u)
		local eye = START * shot.eye[1]:Lerp(shot.eye[2], u)
		local look = START * shot.look[1]:Lerp(shot.look[2], u)
		local kick = hrp.CFrame:VectorToWorldSpace(hum.CameraOffset)
		cam.CFrame = CFrame.lookAt(eye + kick, look + kick)
	end)
	task.wait(dur)
	RunService:UnbindFromRenderStep("TakeCam")
	cam.FieldOfView = 70
	reset()
end

workspace:GetAttributeChangedSignal("TakeShot"):Connect(function()
	local spec = workspace:GetAttribute("TakeShot")
	if not spec or spec == "" then
		return
	end
	local name = spec:match("^(%a+)")
	reset()
	local shot = SHOTS[name]
	if shot and waitCast() then
		roll(shot)
	end
end)
