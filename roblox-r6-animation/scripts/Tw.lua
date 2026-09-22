local TweenService = game:GetService("TweenService")

local root = script.Parent.Parent

local Tw = {}

-- the timescale attribute on the ultimate folder stretches every duration so slow mo captures still line up
function Tw.S()
	return root:GetAttribute("TimeScale") or 1
end

-- a tween made with a delaytime cancels the running tween on that property right away so the delay is waited out and the tween made only when due
function Tw.play(inst, props, dur, style, dir, delayTime)
	local info = TweenInfo.new(dur * Tw.S(), style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
	if not delayTime or delayTime <= 0 then
		local t = TweenService:Create(inst, info, props)
		t:Play()
		return t
	end
	local done = Instance.new("BindableEvent")
	task.delay(delayTime * Tw.S(), function()
		if not inst.Parent and not inst:IsA("SoundGroup") and not inst:IsA("ValueBase") then
			done:Fire(Enum.PlaybackState.Cancelled)
			return
		end
		local t = TweenService:Create(inst, info, props)
		t:Play()
		t.Completed:Once(function(state)
			done:Fire(state)
		end)
	end)
	return {Completed = done.Event}
end

function Tw.wait(dur)
	task.wait(dur * Tw.S())
end

function Tw.seq(points)
	local kps = {}
	for _, p in ipairs(points) do
		table.insert(kps, NumberSequenceKeypoint.new(p[1], p[2], p[3] or 0))
	end
	return NumberSequence.new(kps)
end

function Tw.cseq(points)
	local kps = {}
	for _, p in ipairs(points) do
		table.insert(kps, ColorSequenceKeypoint.new(p[1], p[2]))
	end
	return ColorSequence.new(kps)
end

return Tw
