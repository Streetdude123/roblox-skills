-- run in the edit datamodel: plays every sound under ROOT once and blanks the ones that never load so a
-- pack's private audio stops spamming "not authorized" on every play start; the old id is kept in a
-- DeadSoundId attribute so nothing is lost
local ROOT = game.ReplicatedStorage:FindFirstChild("Stand") and game.ReplicatedStorage.Stand.Assets.Sounds
if not ROOT then
	return "set ROOT to the sound folder"
end
local ContentProvider = game:GetService("ContentProvider")

local sounds = {}
for _, d in ipairs(ROOT:GetDescendants()) do
	if d:IsA("Sound") and d.SoundId ~= "" then
		table.insert(sounds, d)
	end
end
-- preload reports the failed ids so the blank pass does not depend on playback timing
local failed = {}
ContentProvider:PreloadAsync(sounds, function(id, status)
	if status ~= Enum.AssetFetchStatus.Success then
		failed[id] = true
	end
end)
local dead, alive = {}, 0
for _, s in ipairs(sounds) do
	if failed[s.SoundId] then
		s:SetAttribute("DeadSoundId", s.SoundId)
		s.SoundId = ""
		table.insert(dead, s.Name)
	else
		alive += 1
	end
end
return string.format("%d sounds load, %d blanked: %s", alive, #dead, table.concat(dead, ", "))
