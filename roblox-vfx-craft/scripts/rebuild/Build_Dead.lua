local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local kit = ServerStorage.VfxKit
-- the dead kit sounds keep their id in an attribute and stop spamming the console
local deadIds = {["313945165"] = true, ["315263434"] = true, ["316680451"] = true, ["321321137"] = true, ["321322066"] = true, ["144423255"] = true, ["382888000"] = true, ["382897994"] = true, ["281759824"] = true, ["265536195"] = true, ["265536273"] = true, ["265536326"] = true, ["265536377"] = true, ["265536430"] = true, ["536252731"] = true, ["533181749"] = true, ["651169602"] = true, ["738764881"] = true, ["781142217"] = true, ["174401329"] = true, ["174399344"] = true, ["273564089"] = true, ["340505360"] = true, ["1544280726"] = true, ["154500795"] = true, ["291559199"] = true, ["183763512"] = true, ["996375707"] = true, ["469345336"] = true, ["348676461"] = true, ["439342426"] = true, ["376020049"] = true, ["402347142"] = true, ["179294699"] = true, ["435742675"] = true, ["466493476"] = true, ["167029307"] = true, ["258468873"] = true, ["258468889"] = true, ["258468903"] = true, ["258468916"] = true, ["258468929"] = true, ["604999798"] = true, ["1417056781"] = true, ["1418723483"] = true}
local blanked = 0
for _, s in ipairs(kit:GetDescendants()) do
	if s:IsA("Sound") then
		local id = s.SoundId:match("%d+")
		if id and deadIds[id] then
			s:SetAttribute("DeadSoundId", s.SoundId)
			s.SoundId = ""
			blanked += 1
		end
	end
end

return string.format("blanked %d dead sounds", blanked)
