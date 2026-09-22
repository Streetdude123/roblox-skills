-- run in the edit datamodel with execute_luau: decodes every KeyframeSequence under a container into
-- parent axis poses (lift twist side plus offset) and posts one text file per clip to a local node server
-- start the server first (scripts/serve.js style: POST /put?name=x writes the body to disk)
local HttpService = game:GetService("HttpService")
local CONTAINERS = {workspace.BestWalkAnimR6.R6.AnimSaves}
local URL = "http://127.0.0.1:8766/put?name="
local wasEnabled = HttpService.HttpEnabled
HttpService.HttpEnabled = true
local R6 = {
	["Right Arm"] = CFrame.Angles(0, math.pi / 2, 0),
	["Left Arm"] = CFrame.Angles(0, -math.pi / 2, 0),
	["Right Leg"] = CFrame.Angles(0, math.pi / 2, 0),
	["Left Leg"] = CFrame.Angles(0, -math.pi / 2, 0),
	["Head"] = CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0),
	["Torso"] = CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0),
}
-- pose = Rz(side) * Rx(lift) * Ry(twist) so lift = asin(r21), twist = atan2(-r20, r22), side = atan2(-r01, r11)
local function angles(P)
	local _, _, _, r00, r01, r02, r10, r11, r12, r20, r21, r22 = P:GetComponents()
	return math.deg(math.asin(math.clamp(r21, -1, 1))), math.deg(math.atan2(-r20, r22)), math.deg(math.atan2(-r01, r11))
end
local function describe(name, tr)
	local r = R6[name]
	local P = r and (r * tr * r:Inverse()) or tr
	local lift, twist, side = angles(P)
	return string.format("%.1f|%.1f|%.1f|%.2f|%.2f|%.2f", lift, twist, side, P.X, P.Y, P.Z)
end
local function dump(kfs, label)
	local out = {}
	local frames = kfs:GetKeyframes()
	table.sort(frames, function(a, b) return a.Time < b.Time end)
	table.insert(out, string.format("#%s len=%.3f loop=%s frames=%d prio=%s", label, frames[#frames].Time, tostring(kfs.Loop), #frames, tostring(kfs.Priority):gsub("Enum.AnimationPriority.", "")))
	for _, kf in ipairs(frames) do
		for _, m in ipairs(kf:GetMarkers()) do
			table.insert(out, string.format("%s|MARKER|%.3f|%s=%s", label, kf.Time, m.Name, m.Value))
		end
		for _, p in ipairs(kf:GetDescendants()) do
			if p:IsA("Pose") and p.Weight > 0 and p.Name ~= "HumanoidRootPart" then
				table.insert(out, string.format("%s|%s|%.3f|%s|%s|%s", label, p.Name, kf.Time, describe(p.Name, p.CFrame), tostring(p.EasingStyle):gsub("Enum.PoseEasingStyle.", ""), tostring(p.EasingDirection):gsub("Enum.PoseEasingDirection.", "")))
			end
		end
	end
	return table.concat(out, "\n")
end
local sent = {}
for _, container in ipairs(CONTAINERS) do
	for _, k in ipairs(container:GetChildren()) do
		if k:IsA("KeyframeSequence") then
			local name = k.Name:gsub("[^%w]", "_")
			local r = HttpService:PostAsync(URL .. name .. ".txt", dump(k, name), Enum.HttpContentType.TextPlain)
			table.insert(sent, name .. " " .. r)
		end
	end
end
HttpService.HttpEnabled = wasEnabled
return table.concat(sent, "\n")
