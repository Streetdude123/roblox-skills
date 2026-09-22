local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local root = ReplicatedStorage:WaitForChild("Stand")
local Config = require(root.Config)
local Remotes = root.Remotes
local B = Config.Barrage
local TS = Config.TimeStop

local cool = {}
local barrages = {}
local stop = nil

local function now()
	return os.clock()
end

local function ready(player, name, cooldown)
	local c = cool[player]
	if not c then
		c = {}
		cool[player] = c
	end
	if c[name] and now() - c[name] < cooldown then
		return false
	end
	c[name] = now()
	return true
end

local function alive(player)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local hrp = character and character:FindFirstChild("HumanoidRootPart")
	if not humanoid or humanoid.Health <= 0 or not hrp or not character:FindFirstChild("Stand") then
		return nil
	end
	if character:GetAttribute("StandOut") ~= true then
		return nil
	end
	return character, humanoid, hrp
end

-- a body is frozen when someone else's time stop holds the world
local function frozen(character)
	return stop ~= nil and stop.character ~= character and stop.frozenNow
end

local function humanoidsIn(cf, size, exclude)
	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {exclude}
	local seen = {}
	local list = {}
	for _, part in ipairs(workspace:GetPartBoundsInBox(cf, size, params)) do
		local model = part:FindFirstAncestorOfClass("Model")
		while model and not model:FindFirstChildOfClass("Humanoid") do
			model = model:FindFirstAncestorOfClass("Model")
		end
		if model and not seen[model] then
			local hum = model:FindFirstChildOfClass("Humanoid")
			if hum and hum.Health > 0 then
				seen[model] = true
				table.insert(list, {model = model, humanoid = hum, part = part})
			end
		end
	end
	return list
end

-- a humanoid's ground friction eats a plain velocity in a frame so a knockback is a quarter second of driven velocity
local function launch(model, fling)
	local hrp = model:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return
	end
	local a = Instance.new("Attachment")
	a.Name = "FlingAttachment"
	a.Parent = hrp
	local lv = Instance.new("LinearVelocity")
	lv.Attachment0 = a
	lv.MaxForce = 1e6
	lv.VectorVelocity = fling
	lv.RelativeTo = Enum.ActuatorRelativeTo.World
	lv.Parent = hrp
	game:GetService("Debris"):AddItem(lv, 0.22)
	game:GetService("Debris"):AddItem(a, 0.3)
end

-- damage lands now, or waits in the queue when the target is frozen in stopped time
local function damage(attacker, hit, amount, kind, fling)
	local pos = hit.part.Position
	if frozen(hit.model) then
		local q = stop.queue[hit.model]
		if not q then
			q = {damage = 0, fling = Vector3.zero, humanoid = hit.humanoid}
			stop.queue[hit.model] = q
		end
		q.damage += amount
		if fling then
			q.fling = fling
		end
		Remotes.Hit:FireAllClients(hit.model, "Frozen", pos)
		return
	end
	hit.humanoid:TakeDamage(amount)
	if fling then
		launch(hit.model, fling)
	end
	Remotes.Hit:FireAllClients(hit.model, kind, pos)
end

local function endBarrage(player, character, humanoid, hrp)
	local state = barrages[player]
	if not state then
		return
	end
	barrages[player] = nil
	state.running = false
	Remotes.Move:FireAllClients(player, "Barrage", false)
	-- the finisher hit lands on the heavy clip's strike frame
	task.delay(0.32, function()
		if humanoid.Parent and humanoid.Health > 0 then
			local box = hrp.CFrame * CFrame.new(0, 0.5, -B.Reach / 2 - 1)
			for _, hit in ipairs(humanoidsIn(box, Vector3.new(B.Width, 7, B.Reach + 2), character)) do
				damage(player, hit, B.FinishDamage, "Heavy", hrp.CFrame.LookVector * B.Knockback + Vector3.new(0, 14, 0))
			end
		end
	end)
	task.delay(0.6, function()
		if humanoid.Parent and state.speed0 then
			humanoid.WalkSpeed = state.speed0
		end
	end)
end

local function startBarrage(player)
	local character, humanoid, hrp = alive(player)
	if not character or barrages[player] or frozen(character) then
		return
	end
	if not ready(player, "Barrage", B.Cooldown) then
		return
	end
	local state = {running = true, speed0 = humanoid.WalkSpeed, t0 = now()}
	barrages[player] = state
	humanoid.WalkSpeed = B.WalkSpeed
	Remotes.Move:FireAllClients(player, "Barrage", true)
	task.spawn(function()
		while state.running and humanoid.Parent and humanoid.Health > 0 do
			local box = hrp.CFrame * CFrame.new(0, 0.5, -B.Reach / 2 - 1)
			for _, hit in ipairs(humanoidsIn(box, Vector3.new(B.Width, 6, B.Reach), character)) do
				damage(player, hit, B.TickDamage, "Barrage", nil)
			end
			task.wait(B.TickRate)
			if now() - state.t0 >= B.MaxHold then
				break
			end
		end
		if barrages[player] == state then
			endBarrage(player, character, humanoid, hrp)
		end
	end)
end

-- the m1 chain: one request per hit, accepted once most of the current hit has played, index reset after
-- the window; the hit box lands on the clip's strike frame and the fifth hit flings
local M1 = Config.M1
local combos = {}

local function m1(player)
	local character, humanoid, hrp = alive(player)
	if not character or barrages[player] or frozen(character) then
		return
	end
	if stop and stop.character == character and not stop.frozenNow then
		return
	end
	local c = combos[player]
	if not c then
		c = {index = 0, last = 0, busyUntil = 0, speed0 = nil}
		combos[player] = c
	end
	local t = now()
	if t < c.busyUntil then
		-- one early click waits for the busy window so a masher never drops a hit
		if not c.queued then
			c.queued = true
			task.delay(c.busyUntil - t + 0.01, function()
				if c.queued then
					c.queued = false
					m1(player)
				end
			end)
		end
		return
	end
	c.queued = false
	if t - c.last > M1.Window then
		c.index = 0
	end
	if c.index >= #M1.Lengths then
		if t - c.last < M1.Cooldown then
			return
		end
		c.index = 0
	end
	c.index += 1
	c.last = t
	local i = c.index
	local len = M1.Lengths[i]
	c.busyUntil = t + len * 0.8
	if not c.speed0 then
		c.speed0 = humanoid.WalkSpeed
	end
	humanoid.WalkSpeed = 0
	Remotes.Move:FireAllClients(player, "M1", i)
	task.delay(M1.Strike[i], function()
		if humanoid.Parent and humanoid.Health > 0 and c.index == i then
			local box = hrp.CFrame * CFrame.new(0, 0.5, -M1.Reach / 2 - 1)
			local fling = i == #M1.Lengths and (hrp.CFrame.LookVector * M1.Fling + Vector3.new(0, 12, 0)) or nil
			for _, hit in ipairs(humanoidsIn(box, Vector3.new(M1.Width, 6, M1.Reach), character)) do
				damage(player, hit, M1.Damage[i], i == #M1.Lengths and "Heavy" or "M1", fling)
			end
		end
	end)
	task.delay(len + 0.25, function()
		if c.index == i and now() - c.last >= len + 0.2 and humanoid.Parent and c.speed0 then
			humanoid.WalkSpeed = c.speed0
			c.speed0 = nil
		end
	end)
end

-- freezes every other body: anchored roots, walk speeds parked in an attribute, loose parts held with
-- their velocity saved so they fly on when time moves again
local function freezeWorld(caster)
	stop.frozenNow = true
	for _, other in ipairs(Players:GetPlayers()) do
		local c = other.Character
		if c and c ~= caster then
			local hum = c:FindFirstChildOfClass("Humanoid")
			local hrp = c:FindFirstChild("HumanoidRootPart")
			if hum and hrp then
				c:SetAttribute("FrozenSpeed", hum.WalkSpeed)
				c:SetAttribute("FrozenJump", hum.JumpPower)
				hum.WalkSpeed = 0
				hum.JumpPower = 0
				hrp.Anchored = true
				c:SetAttribute("Frozen", true)
				table.insert(stop.frozen, c)
			end
		end
	end
	for _, d in ipairs(workspace:GetDescendants()) do
		if d:IsA("Model") and d:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(d) and d ~= caster then
			local hum = d:FindFirstChildOfClass("Humanoid")
			local hrp = d:FindFirstChild("HumanoidRootPart")
			if hrp and not d:GetAttribute("Frozen") then
				d:SetAttribute("FrozenSpeed", hum.WalkSpeed)
				d:SetAttribute("FrozenJump", hum.JumpPower)
				hum.WalkSpeed = 0
				hum.JumpPower = 0
				hrp.Anchored = true
				d:SetAttribute("Frozen", true)
				table.insert(stop.frozen, d)
			end
		elseif d:IsA("BasePart") and not d.Anchored and not d:FindFirstAncestorOfClass("Model") then
			d:SetAttribute("FrozenVel", d.AssemblyLinearVelocity)
			d:SetAttribute("FrozenAng", d.AssemblyAngularVelocity)
			d.Anchored = true
			table.insert(stop.parts, d)
		end
	end
end

local function resumeWorld()
	if not stop then
		return
	end
	local s = stop
	stop = nil
	workspace:SetAttribute("TimeStop", nil)
	for _, c in ipairs(s.frozen) do
		if c.Parent then
			local hum = c:FindFirstChildOfClass("Humanoid")
			local hrp = c:FindFirstChild("HumanoidRootPart")
			if hum then
				hum.WalkSpeed = c:GetAttribute("FrozenSpeed") or 16
				hum.JumpPower = c:GetAttribute("FrozenJump") or 50
			end
			if hrp then
				hrp.Anchored = false
			end
			c:SetAttribute("Frozen", nil)
			c:SetAttribute("FrozenSpeed", nil)
			c:SetAttribute("FrozenJump", nil)
		end
	end
	for _, p in ipairs(s.parts) do
		if p.Parent then
			p.Anchored = false
			p.AssemblyLinearVelocity = p:GetAttribute("FrozenVel") or Vector3.zero
			p.AssemblyAngularVelocity = p:GetAttribute("FrozenAng") or Vector3.zero
			p:SetAttribute("FrozenVel", nil)
			p:SetAttribute("FrozenAng", nil)
		end
	end
	-- every hit taken in stopped time lands at once
	for model, q in pairs(s.queue) do
		if model.Parent and q.humanoid.Parent and q.humanoid.Health > 0 then
			q.humanoid:TakeDamage(q.damage)
			if q.fling.Magnitude > 0 then
				launch(model, q.fling)
			end
			local hrp = model:FindFirstChild("HumanoidRootPart")
			local torso = model:FindFirstChild("Torso") or hrp
			Remotes.Hit:FireAllClients(model, "Release", torso and torso.Position or model:GetPivot().Position)
		end
	end
end

local function startTimeStop(player)
	local character, humanoid, hrp = alive(player)
	if not character or stop or frozen(character) or barrages[player] then
		return
	end
	if not ready(player, "TimeStop", TS.Cooldown) then
		return
	end
	stop = {player = player, character = character, frozen = {}, parts = {}, queue = {}, frozenNow = false}
	workspace:SetAttribute("TimeStop", player.UserId)
	Remotes.Move:FireAllClients(player, "TimeStop", true)
	local mine = stop
	task.delay(TS.Beats.snap, function()
		if stop == mine and humanoid.Parent and humanoid.Health > 0 then
			freezeWorld(character)
		elseif stop == mine then
			resumeWorld()
		end
	end)
	local hold = TS.Beats.done + TS.Duration
	task.delay(hold - 1.6, function()
		if stop == mine then
			Remotes.Move:FireAllClients(player, "TimeStop", false)
		end
	end)
	task.delay(hold, function()
		if stop == mine then
			resumeWorld()
		end
	end)
	humanoid.Died:Once(function()
		if stop == mine then
			Remotes.Move:FireAllClients(player, "TimeStop", false)
			task.delay(1.6, function()
				if stop == mine then
					resumeWorld()
				end
			end)
		end
	end)
end

Remotes.MoveRequest.OnServerEvent:Connect(function(player, name, on)
	if name == "Barrage" then
		if on then
			startBarrage(player)
		else
			local character, humanoid, hrp = alive(player)
			if character and barrages[player] and now() - barrages[player].t0 > 0.35 then
				endBarrage(player, character, humanoid, hrp)
			end
		end
	elseif name == "TimeStop" and on then
		startTimeStop(player)
	elseif name == "M1" then
		m1(player)
	end
end)

Players.PlayerRemoving:Connect(function(player)
	cool[player] = nil
	barrages[player] = nil
	combos[player] = nil
	if stop and stop.player == player then
		Remotes.Move:FireAllClients(player, "TimeStop", false)
		resumeWorld()
	end
end)
