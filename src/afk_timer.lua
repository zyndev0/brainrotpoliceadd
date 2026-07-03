-- AFK Timer
-- Put this in ServerScriptService as a Script

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local afkStore = DataStoreService:GetDataStore("AFKTimeStoreV1")
local playerStates = {}
local SAVE_INTERVAL = 15

local function createBillboard(character)
	local existing = character:FindFirstChild("AFKBillboard")
	if existing then
		existing:Destroy()
	end

	local head = character:FindFirstChild("Head")
	if not head then
		return nil
	end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "AFKBillboard"
	billboard.Adornee = head
	billboard.Size = UDim2.new(4, 0, 1.2, 0)
	billboard.StudsOffset = Vector3.new(0, 3.5, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = character

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextStrokeTransparency = 0.4
	label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 24
	label.Text = "AFK: 0s"
	label.Parent = billboard

	return label
end

local function updateBillboard(state)
	if state.label then
		state.label.Text = "AFK: " .. math.floor(state.totalAFKTime) .. "s"
	end
end

local function loadPlayerAFK(player)
	local success, value = pcall(function()
		return afkStore:GetAsync(player.UserId)
	end)

	if success and type(value) == "number" then
		return value
	end

	return 0
end

local function savePlayerAFK(player, state)
	if not player or not player.Parent then
		return
	end

	local success, err = pcall(function()
		afkStore:SetAsync(player.UserId, state.totalAFKTime)
	end)

	if not success then
		warn("Failed to save AFK time for " .. player.Name .. ": " .. tostring(err))
	end
end

Players.PlayerAdded:Connect(function(player)
	local state = {
		totalAFKTime = loadPlayerAFK(player),
		isAFK = false,
		idleTimer = 0,
		lastSave = os.clock(),
		label = nil,
	}
	playerStates[player] = state

	player.CharacterAdded:Connect(function(character)
		character:WaitForChild("Humanoid")
		state.label = createBillboard(character)
		state.isAFK = false
		state.idleTimer = 0
		updateBillboard(state)
	end)

	if player.Character then
		state.label = createBillboard(player.Character)
		updateBillboard(state)
	end
end)

Players.PlayerRemoving:Connect(function(player)
	local state = playerStates[player]
	if state then
		savePlayerAFK(player, state)
		playerStates[player] = nil
	end
end)

game:BindToClose(function()
	for player, state in pairs(playerStates) do
		savePlayerAFK(player, state)
	end
end)

RunService.Heartbeat:Connect(function(dt)
	for player, state in pairs(playerStates) do
		if not player or not player.Parent then
			continue
		end

		local character = player.Character
		if not character then
			continue
		end

		local humanoid = character:FindFirstChildOfClass("Humanoid")
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if not humanoid or not rootPart then
			continue
		end

		local isMoving = (humanoid.MoveDirection.Magnitude > 0.1) or (rootPart.AssemblyLinearVelocity.Magnitude > 1)

		if isMoving then
			state.isAFK = false
			state.idleTimer = 0
		else
			if not state.isAFK then
				state.isAFK = true
				state.idleTimer = 0
			end

			state.idleTimer += dt
			if state.idleTimer >= 1 then
				state.totalAFKTime += 1
				state.idleTimer = 0
				updateBillboard(state)
			end
		end

		if os.clock() - state.lastSave >= SAVE_INTERVAL then
			savePlayerAFK(player, state)
			state.lastSave = os.clock()
		end
	end
end)
