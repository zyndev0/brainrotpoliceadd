-- LocalScript in StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local function createWarningGui()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "AFKMovementWarning"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui

	local frame = Instance.new("Frame")
	frame.Name = "WarningFrame"
	frame.Size = UDim2.new(0, 420, 0, 54)
	frame.Position = UDim2.new(0.5, -210, 0, 20)
	frame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	frame.BackgroundTransparency = 0.15
	frame.BorderSizePixel = 0
	frame.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = frame

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = "WARNING: YOU MUST BE COMPLETELY STILL TO GAIN AFK TIME!"
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 18
	label.TextWrapped = true
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.Parent = frame

	return screenGui, frame, label
end

local screenGui, frame = createWarningGui()
local warningVisible = false
local fadeTween

local function showWarning()
	if warningVisible then
		return
	end

	warningVisible = true
	frame.Visible = true
	frame.Transparency = 0

	if fadeTween then
		fadeTween:Cancel()
	end

	fadeTween = game:GetService("TweenService"):Create(
		frame,
		TweenInfo.new(0.25, Enum.EasingStyle.Linear),
		{ BackgroundTransparency = 0.15 }
	)
	fadeTween:Play()
end

local function hideWarning()
	warningVisible = false
	frame.Visible = false
end

local function checkMovement()
	local character = player.Character
	if not character then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not rootPart then
		return
	end

	local isMoving = (humanoid.MoveDirection.Magnitude > 0.1) or (rootPart.AssemblyLinearVelocity.Magnitude > 1)
	if isMoving then
		showWarning()
	else
		hideWarning()
	end
end

player.CharacterAdded:Connect(function()
	task.wait(0.2)
	checkMovement()
end)

RunService.Heartbeat:Connect(function()
	checkMovement()
end)
