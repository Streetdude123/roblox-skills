local svc = game:GetService("StudioDeviceSimulatorService")

return function(id, mode, portrait)
	if not id or id == "default" then
		svc:SetDeviceAsync("default")
		return "default"
	end
	svc:SetDeviceAsync(id)
	if mode then
		svc:SetScalingModeAsync(Enum.DeviceSimulatorScalingMode[mode])
	end
	if portrait ~= nil then
		svc:SetOrientationAsync(portrait and Enum.ScreenOrientation.Portrait or Enum.ScreenOrientation.LandscapeRight)
	end
	local res = svc:GetResolutionAsync()
	return string.format("%s %dx%d %d dpi %s", id, res.X, res.Y, svc:GetPixelDensityAsync(), tostring(svc:GetScalingModeAsync()))
end
