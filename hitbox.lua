local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Settings = {
	Aimbot = false,
	ESP = true,
	Markers = true,

	PlayerHitbox = 2,
	NpcHitbox = 2,

	ShowPlayerHitboxes = false,
	ShowNpcHitboxes = false,

	AimPart = "Head",
	AimSmoothness = 0.35,
	AimRange = 500
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CombatAdminPanel"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(330, 430)
Main.Position = UDim2.new(0.5, -165, 0.5, -215)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(255, 55, 100)
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.2
MainStroke.Parent = Main

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 58)
Header.BackgroundColor3 = Color3.fromRGB(18, 18, 21)
Header.BorderSizePixel = 0
Header.Parent = Main

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 14)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -70, 1, 0)
Title.Position = UDim2.fromOffset(18, 0)
Title.BackgroundTransparency = 1
Title.Text = "COMBAT CONTROL"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 17
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Accent = Instance.new("Frame")
Accent.Size = UDim2.fromOffset(4, 32)
Accent.Position = UDim2.fromOffset(8, 13)
Accent.BackgroundColor3 = Color3.fromRGB(255, 55, 100)
Accent.BorderSizePixel = 0
Accent.Parent = Header

local AccentCorner = Instance.new("UICorner")
AccentCorner.CornerRadius = UDim.new(1, 0)
AccentCorner.Parent = Accent

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(36, 36)
Close.Position = UDim2.new(1, -46, 0, 11)
Close.BackgroundColor3 = Color3.fromRGB(30, 30, 34)
Close.Text = "×"
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
Close.TextSize = 22
Close.Font = Enum.Font.GothamBold
Close.BorderSizePixel = 0
Close.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 9)
CloseCorner.Parent = Close

local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -20, 1, -70)
Content.Position = UDim2.fromOffset(10, 65)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 3
Content.ScrollBarImageColor3 = Color3.fromRGB(255, 55, 100)
Content.CanvasSize = UDim2.new()
Content.Parent = Main

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 8)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Layout.Parent = Content

local Padding = Instance.new("UIPadding")
Padding.PaddingBottom = UDim.new(0, 10)
Padding.Parent = Content

Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	Content.CanvasSize = UDim2.fromOffset(0, Layout.AbsoluteContentSize.Y + 15)
end)

local function createButton(text)
	local Button = Instance.new("TextButton")
	Button.Size = UDim2.new(1, -10, 0, 43)
	Button.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
	Button.BorderSizePixel = 0
	Button.TextColor3 = Color3.fromRGB(255, 255, 255)
	Button.TextSize = 13
	Button.Font = Enum.Font.GothamSemibold
	Button.Text = text
	Button.AutoButtonColor = false
	Button.Parent = Content

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 9)
	Corner.Parent = Button

	local Stroke = Instance.new("UIStroke")
	Stroke.Color = Color3.fromRGB(45, 45, 50)
	Stroke.Thickness = 1
	Stroke.Parent = Button

	Button.MouseEnter:Connect(function()
		TweenService:Create(
			Button,
			TweenInfo.new(0.15),
			{BackgroundColor3 = Color3.fromRGB(38, 26, 31)}
		):Play()
	end)

	Button.MouseLeave:Connect(function()
		TweenService:Create(
			Button,
			TweenInfo.new(0.15),
			{BackgroundColor3 = Color3.fromRGB(24, 24, 28)}
		):Play()
	end)

	return Button
end

local function createSection(text)
	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, -10, 0, 28)
	Label.BackgroundTransparency = 1
	Label.Text = text
	Label.TextColor3 = Color3.fromRGB(255, 75, 115)
	Label.TextSize = 11
	Label.Font = Enum.Font.GothamBold
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = Content

	return Label
end

local function setToggle(button, name, state)
	button.Text = name .. ": " .. (state and "ON" or "OFF")

	if state then
		button.BackgroundColor3 = Color3.fromRGB(115, 25, 52)
	else
		button.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
	end
end

local function createValueButton(name, value, callback)
	local Button = createButton(
		name .. ": x" .. string.format("%.1f", value)
	)

	Button.MouseButton1Click:Connect(function()
		value = callback(value)
		Button.Text = name .. ": x" .. string.format("%.1f", value)
	end)

	return Button
end

createSection("TARGETING")

local AimbotButton = createButton("AIMBOT: OFF")

AimbotButton.MouseButton1Click:Connect(function()
	Settings.Aimbot = not Settings.Aimbot
	setToggle(AimbotButton, "AIMBOT", Settings.Aimbot)
end)

local ESPButton = createButton("ENEMY ESP: ON")

ESPButton.MouseButton1Click:Connect(function()
	Settings.ESP = not Settings.ESP

	if not Settings.ESP then
		for _, player in ipairs(Players:GetPlayers()) do
			if player.Character then
				local highlight =
					player.Character:FindFirstChild("AdminEnemyESP")

				if highlight then
					highlight:Destroy()
				end

				local root =
					player.Character:FindFirstChild("HumanoidRootPart")

				if root then
					local marker =
						root:FindFirstChild("AdminEnemyMarker")

					if marker then
						marker:Destroy()
					end
				end
			end
		end
	end

	setToggle(ESPButton, "ENEMY ESP", Settings.ESP)
end)

local MarkerButton = createButton("ENEMY MARKERS: ON")

MarkerButton.MouseButton1Click:Connect(function()
	Settings.Markers = not Settings.Markers

	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character then
			local root =
				player.Character:FindFirstChild("HumanoidRootPart")

			if root then
				local marker =
					root:FindFirstChild("AdminEnemyMarker")

				if marker and not Settings.Markers then
					marker:Destroy()
				end
			end
		end
	end

	setToggle(
		MarkerButton,
		"ENEMY MARKERS",
		Settings.Markers
	)
end)

local AimPartButton = createButton("AIM PART: HEAD")

AimPartButton.MouseButton1Click:Connect(function()
	if Settings.AimPart == "Head" then
		Settings.AimPart = "HumanoidRootPart"
		AimPartButton.Text = "AIM PART: BODY"
	else
		Settings.AimPart = "Head"
		AimPartButton.Text = "AIM PART: HEAD"
	end
end)

local SmoothButton = createButton("AIM SMOOTH: 0.35")

SmoothButton.MouseButton1Click:Connect(function()
	Settings.AimSmoothness += 0.05

	if Settings.AimSmoothness > 1 then
		Settings.AimSmoothness = 0.1
	end

	SmoothButton.Text =
		"AIM SMOOTH: "
		.. string.format("%.2f", Settings.AimSmoothness)
end)

createSection("PLAYER HITBOX")

local PlayerHitboxButton = createValueButton(
	"PLAYER",
	Settings.PlayerHitbox,
	function(value)
		value += 0.25

		if value > 4 then
			value = 1
		end

		Settings.PlayerHitbox = value

		return value
	end
)

local ShowPlayerButton =
	createButton("SHOW PLAYER HITBOXES: OFF")

ShowPlayerButton.MouseButton1Click:Connect(function()
	Settings.ShowPlayerHitboxes =
		not Settings.ShowPlayerHitboxes

	setToggle(
		ShowPlayerButton,
		"SHOW PLAYER HITBOXES",
		Settings.ShowPlayerHitboxes
	)
end)

createSection("NPC HITBOX")

local NpcHitboxButton = createValueButton(
	"NPC",
	Settings.NpcHitbox,
	function(value)
		value += 0.25

		if value > 4 then
			value = 1
		end

		Settings.NpcHitbox = value

		return value
	end
)

local ShowNpcButton =
	createButton("SHOW NPC HITBOXES: OFF")

ShowNpcButton.MouseButton1Click:Connect(function()
	Settings.ShowNpcHitboxes =
		not Settings.ShowNpcHitboxes

	setToggle(
		ShowNpcButton,
		"SHOW NPC HITBOXES",
		Settings.ShowNpcHitboxes
	)
end)

local ResetButton = createButton("RESET HITBOXES")

ResetButton.MouseButton1Click:Connect(function()
	Settings.PlayerHitbox = 1
	Settings.NpcHitbox = 1

	PlayerHitboxButton.Text = "PLAYER: x1.0"
	NpcHitboxButton.Text = "NPC: x1.0"
end)

local function isEnemy(player)
	if player == LocalPlayer then
		return false
	end

	if not player.Character then
		return false
	end

	local humanoid =
		player.Character:FindFirstChildOfClass("Humanoid")

	if not humanoid or humanoid.Health <= 0 then
		return false
	end

	if LocalPlayer.Team and player.Team then
		return LocalPlayer.Team ~= player.Team
	end

	return true
end

local function getAimPart(character)
	return character:FindFirstChild(Settings.AimPart)
		or character:FindFirstChild("HumanoidRootPart")
end

local function createEnemyESP(player)
	if not Settings.ESP then
		return
	end

	if not isEnemy(player) then
		return
	end

	if not player.Character then
		return
	end

	local character = player.Character

	local highlight =
		character:FindFirstChild("AdminEnemyESP")

	if not highlight then
		highlight = Instance.new("Highlight")
		highlight.Name = "AdminEnemyESP"
		highlight.FillColor =
			Color3.fromRGB(255, 35, 65)
		highlight.OutlineColor =
			Color3.fromRGB(255, 100, 130)
		highlight.FillTransparency = 0.78
		highlight.OutlineTransparency = 0
		highlight.DepthMode =
			Enum.HighlightDepthMode.AlwaysOnTop
		highlight.Parent = character
	end

	if Settings.Markers then
		local root =
			character:FindFirstChild("HumanoidRootPart")

		if root then
			local marker =
				root:FindFirstChild("AdminEnemyMarker")

			if not marker then
				marker = Instance.new("BillboardGui")
				marker.Name = "AdminEnemyMarker"
				marker.Size =
					UDim2.fromOffset(70, 70)
				marker.StudsOffset =
					Vector3.new(0, 3.5, 0)
				marker.AlwaysOnTop = true
				marker.Parent = root

				local arrow = Instance.new("TextLabel")
				arrow.Size = UDim2.fromScale(1, 1)
				arrow.BackgroundTransparency = 1
				arrow.Text = "▼"
				arrow.TextColor3 =
					Color3.fromRGB(255, 40, 70)
				arrow.TextStrokeTransparency = 0.25
				arrow.TextScaled = true
				arrow.Font = Enum.Font.GothamBold
				arrow.Parent = marker
			end
		end
	end
end

local function isMarkedEnemy(player)
	if not Settings.ESP then
		return false
	end

	if not isEnemy(player) then
		return false
	end

	if not player.Character then
		return false
	end

	local highlight =
		player.Character:FindFirstChild("AdminEnemyESP")

	if not highlight then
		return false
	end

	if Settings.Markers then
		local root =
			player.Character:FindFirstChild("HumanoidRootPart")

		if not root then
			return false
		end

		local marker =
			root:FindFirstChild("AdminEnemyMarker")

		if not marker then
			return false
		end
	end

	return true
end

local function getAimTarget()
	local closest = nil
	local closestDistance = Settings.AimRange

	for _, player in ipairs(Players:GetPlayers()) do
		if isMarkedEnemy(player) then
			local part = getAimPart(player.Character)

			if part then
				local screenPosition, visible =
					Camera:WorldToViewportPoint(part.Position)

				if visible and screenPosition.Z > 0 then
					local center = Vector2.new(
						Camera.ViewportSize.X / 2,
						Camera.ViewportSize.Y / 2
					)

					local distance = (
						Vector2.new(
							screenPosition.X,
							screenPosition.Y
						) - center
					).Magnitude

					if distance < closestDistance then
						closestDistance = distance
						closest = part
					end
				end
			end
		end
	end

	return closest
end

local function createHitbox(character, multiplier, name)
	local root =
		character:FindFirstChild("HumanoidRootPart")

	if not root then
		return
	end

	local old = root:FindFirstChild(name)

	if old then
		old:Destroy()
	end

	if multiplier <= 1 then
		return
	end

	local box = Instance.new("BoxHandleAdornment")
	box.Name = name
	box.Adornee = root
	box.AlwaysOnTop = true
	box.ZIndex = 5
	box.Transparency = 0.82
	box.Color3 = Color3.fromRGB(255, 55, 100)
	box.Size = root.Size * multiplier
	box.Parent = root
end

local function updatePlayerHitboxes()
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			local root =
				player.Character:FindFirstChild("HumanoidRootPart")

			if root then
				local box =
					root:FindFirstChild("AdminPlayerHitbox")

				if Settings.ShowPlayerHitboxes then
					createHitbox(
						player.Character,
						Settings.PlayerHitbox,
						"AdminPlayerHitbox"
					)
				elseif box then
					box:Destroy()
				end
			end
		end
	end
end

local function updateNpcHitboxes()
	for _, model in ipairs(workspace:GetDescendants()) do
		if model:IsA("Model")
			and not Players:GetPlayerFromCharacter(model)
			and model:FindFirstChildOfClass("Humanoid") then

			local root =
				model:FindFirstChild("HumanoidRootPart")

			if root then
				local box =
					root:FindFirstChild("AdminNpcHitbox")

				if Settings.ShowNpcHitboxes then
					createHitbox(
						model,
						Settings.NpcHitbox,
						"AdminNpcHitbox"
					)
				elseif box then
					box:Destroy()
				end
			end
		end
	end
end

RunService.RenderStepped:Connect(function()
	for _, player in ipairs(Players:GetPlayers()) do
		if isEnemy(player) then
			createEnemyESP(player)
		end
	end

	updatePlayerHitboxes()
	updateNpcHitboxes()

	if Settings.Aimbot then
		local target = getAimTarget()

		if target then
			local cameraPosition =
				Camera.CFrame.Position

			local direction =
				(target.Position - cameraPosition).Unit

			local desired =
				CFrame.lookAt(
					cameraPosition,
					cameraPosition + direction
				)

			Camera.CFrame =
				Camera.CFrame:Lerp(
					desired,
					Settings.AimSmoothness
				)
		end
	end
end)

local dragging = false
local dragStart
local startPosition

Header.InputBegan:Connect(function(input)
	if input.UserInputType ==
		Enum.UserInputType.MouseButton1
		or input.UserInputType ==
		Enum.UserInputType.Touch then

		dragging = true
		dragStart = input.Position
		startPosition = Main.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not dragging then
		return
	end

	if input.UserInputType ==
		Enum.UserInputType.MouseMovement
		or input.UserInputType ==
		Enum.UserInputType.Touch then

		local delta =
			input.Position - dragStart

		Main.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType ==
		Enum.UserInputType.MouseButton1
		or input.UserInputType ==
		Enum.UserInputType.Touch then

		dragging = false
	end
end)

Close.MouseButton1Click:Connect(function()
	TweenService:Create(
		Main,
		TweenInfo.new(
			0.2,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.In
		),
		{
			Size = UDim2.fromOffset(330, 0),
			BackgroundTransparency = 1
		}
	):Play()

	task.wait(0.2)
	Main.Visible = false
end)

local OpenButton = Instance.new("TextButton")
OpenButton.Size = UDim2.fromOffset(48, 48)
OpenButton.Position =
	UDim2.new(1, -65, 0, 20)
OpenButton.BackgroundColor3 =
	Color3.fromRGB(15, 15, 18)
OpenButton.Text = "⚙"
OpenButton.TextColor3 =
	Color3.fromRGB(255, 55, 100)
OpenButton.TextSize = 20
OpenButton.Font = Enum.Font.GothamBold
OpenButton.BorderSizePixel = 0
OpenButton.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(0, 12)
OpenCorner.Parent = OpenButton

OpenButton.MouseButton1Click:Connect(function()
	Main.Visible = true
	Main.Size = UDim2.fromOffset(330, 0)
	Main.BackgroundTransparency = 1

	TweenService:Create(
		Main,
		TweenInfo.new(
			0.28,
			Enum.EasingStyle.Back,
			Enum.EasingDirection.Out
		),
		{
			Size = UDim2.fromOffset(330, 430),
			BackgroundTransparency = 0
		}
	):Play()
end)
