local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local Settings = {
	Multiplier = 2,
	MinMultiplier = 1,
	MaxMultiplier = 5,
	Step = 0.1,
	ShowHitboxes = true
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HitboxTester"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(300, 190)
Main.Position = UDim2.new(0.5, -150, 0.5, -95)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = Main

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(255, 45, 45)
Stroke.Thickness = 1.5
Stroke.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 38)
Title.Position = UDim2.fromOffset(10, 5)
Title.BackgroundTransparency = 1
Title.Text = "HITBOX TESTER"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.Parent = Main

local Value = Instance.new("TextLabel")
Value.Size = UDim2.new(1, 0, 0, 40)
Value.Position = UDim2.fromOffset(0, 45)
Value.BackgroundTransparency = 1
Value.TextColor3 = Color3.new(1, 1, 1)
Value.TextSize = 26
Value.Font = Enum.Font.GothamBold
Value.Parent = Main

local Minus = Instance.new("TextButton")
Minus.Size = UDim2.fromOffset(55, 45)
Minus.Position = UDim2.fromOffset(45, 92)
Minus.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Minus.Text = "-"
Minus.TextColor3 = Color3.new(1, 1, 1)
Minus.TextSize = 25
Minus.Font = Enum.Font.GothamBold
Minus.Parent = Main

local Plus = Instance.new("TextButton")
Plus.Size = UDim2.fromOffset(55, 45)
Plus.Position = UDim2.fromOffset(200, 92)
Plus.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Plus.Text = "+"
Plus.TextColor3 = Color3.new(1, 1, 1)
Plus.TextSize = 25
Plus.Font = Enum.Font.GothamBold
Plus.Parent = Main

local Toggle = Instance.new("TextButton")
Toggle.Size = UDim2.fromOffset(90, 45)
Toggle.Position = UDim2.fromOffset(105, 92)
Toggle.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
Toggle.TextColor3 = Color3.new(1, 1, 1)
Toggle.TextSize = 13
Toggle.Font = Enum.Font.GothamBold
Toggle.Parent = Main

local Reset = Instance.new("TextButton")
Reset.Size = UDim2.new(1, -90, 0, 32)
Reset.Position = UDim2.fromOffset(45, 148)
Reset.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Reset.Text = "RESET"
Reset.TextColor3 = Color3.new(1, 1, 1)
Reset.TextSize = 13
Reset.Font = Enum.Font.GothamBold
Reset.Parent = Main

for _, button in ipairs({Minus, Plus, Toggle, Reset}) do
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 8)
	c.Parent = button
end

local function updateText()
	Value.Text = string.format("x%.1f", Settings.Multiplier)
	Toggle.Text = Settings.ShowHitboxes and "HITBOX: ON" or "HITBOX: OFF"
end

local boxes = {}

local function clearBoxes()
	for character, parts in pairs(boxes) do
		for _, part in ipairs(parts) do
			if part and part.Parent then
				part:Destroy()
			end
		end
		boxes[character] = nil
	end
end

local function createBox(character, original)
	local box = Instance.new("BoxHandleAdornment")
	box.Name = "DebugHitbox"
	box.Adornee = original
	box.AlwaysOnTop = true
	box.ZIndex = 5
	box.Transparency = 0.75
	box.Color3 = Color3.fromRGB(255, 40, 40)
	box.Size = original.Size * Settings.Multiplier
	box.Parent = original

	boxes[character] = boxes[character] or {}
	table.insert(boxes[character], box)
end

local function refreshBoxes()
	clearBoxes()

	if not Settings.ShowHitboxes then
		return
	end

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			local character = player.Character

			local root = character:FindFirstChild("HumanoidRootPart")
			local torso = character:FindFirstChild("UpperTorso")
				or character:FindFirstChild("Torso")

			if root then
				createBox(character, root)
			end

			if torso then
				createBox(character, torso)
			end
		end
	end
end

local function setMultiplier(value)
	Settings.Multiplier = math.clamp(
		math.round(value * 10) / 10,
		Settings.MinMultiplier,
		Settings.MaxMultiplier
	)

	refreshBoxes()
	updateText()
end

Minus.MouseButton1Click:Connect(function()
	setMultiplier(Settings.Multiplier - Settings.Step)
end)

Plus.MouseButton1Click:Connect(function()
	setMultiplier(Settings.Multiplier + Settings.Step)
end)

Toggle.MouseButton1Click:Connect(function()
	Settings.ShowHitboxes = not Settings.ShowHitboxes
	refreshBoxes()
	updateText()
end)

Reset.MouseButton1Click:Connect(function()
	setMultiplier(2)
	Settings.ShowHitboxes = true
	refreshBoxes()
	updateText()
end)

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		task.wait(1)
		refreshBoxes()
	end)
end)

Players.PlayerRemoving:Connect(function()
	refreshBoxes()
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end

	if input.KeyCode == Enum.KeyCode.RightBracket then
		setMultiplier(Settings.Multiplier + Settings.Step)
	elseif input.KeyCode == Enum.KeyCode.LeftBracket then
		setMultiplier(Settings.Multiplier - Settings.Step)
	elseif input.KeyCode == Enum.KeyCode.H then
		Settings.ShowHitboxes = not Settings.ShowHitboxes
		refreshBoxes()
		updateText()
	end
end)

local dragging = false
local dragStart
local startPosition

Title.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		dragging = true
		dragStart = input.Position
		startPosition = Main.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not dragging then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch then

		local delta = input.Position - dragStart

		Main.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

RunService.RenderStepped:Connect(function()
	if not Settings.ShowHitboxes then
		return
	end

	for character, parts in pairs(boxes) do
		if character and character.Parent then
			for _, box in ipairs(parts) do
				if box and box.Parent and box.Adornee then
					box.Size = box.Adornee.Size * Settings.Multiplier
				end
			end
		end
	end
end)

updateText()
refreshBoxes()
