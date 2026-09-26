local ids = {9119747138, 9116690684, 9116384485}
local points = 200

local function measure(id)
	local player = Instance.new("AudioPlayer")
	player.Asset = "rbxassetid://" .. id
	player.Volume = 0.5
	player.Parent = workspace

	local analyzer = Instance.new("AudioAnalyzer")
	analyzer.Parent = player
	local speaker = Instance.new("AudioDeviceOutput")
	speaker.Parent = player

	local toAnalyzer = Instance.new("Wire")
	toAnalyzer.SourceInstance = player
	toAnalyzer.TargetInstance = analyzer
	toAnalyzer.Parent = player
	local toSpeaker = Instance.new("Wire")
	toSpeaker.SourceInstance = player
	toSpeaker.TargetInstance = speaker
	toSpeaker.Parent = player

	local waited = 0
	while not player.IsReady and waited < 10 do
		waited += task.wait(0.1)
	end
	local len = player.TimeLength
	local wave = player:GetWaveformAsync(NumberRange.new(0, len), points)

	local top, at = 0, 1
	for i, v in wave do
		if v > top then
			top, at = v, i
		end
	end
	local last = at
	for i = at, #wave do
		if wave[i] > top * 0.01 then
			last = i
		end
	end

	local peak, sum, count = 0, 0, 0
	player:Play()
	local start = os.clock()
	while os.clock() - start < len do
		peak = math.max(peak, analyzer.PeakLevel)
		sum += analyzer.RmsLevel
		count += 1
		task.wait(0.05)
	end
	player:Destroy()

	return string.format("%d len=%.2f peak_at=%.2f tail_to=%.2f peak=%.3f rms=%.3f", id, len, (at - 1) / points * len, (last - 1) / points * len, peak, sum / math.max(count, 1))
end

for _, id in ids do
	print(measure(id))
	task.wait(0.3)
end
