--// COMBAT ADMIN PANEL
--// Put this LocalScript into StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--==================================================
-- SETTINGS
--==================================================

local Settings = {
	Aimbot = false,

	ESP = true,
	Markers = true,

	PlayerHitbox = 2.5,
	NpcHitbox = 2,

	ShowPlayerHitboxes = false,
	ShowNpcHitboxes = false,

	AimPart = "Head",
	AimSmoothness = 0.25,
	AimRange = 500,
}

--==================================================
-- GUI
--==================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CombatAdminPanel"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(310, 500)
Main.Position = UDim2.new(0, 30, 0.5, -250)
Main.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 14)
Corner.Parent = Main

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(255, 40, 100)
Stroke.Thickness = 1.5
Stroke.Transparency = 0.25
Stroke.Parent = Main

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 55)
Header.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
Header.BorderSizePixel = 0
Header.Parent = Main

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 14)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Position = UDim2.fromOffset(18, 7)
Title.Size = UDim2.new(1, -70, 0, 25)
Title.Text = "COMBAT"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Subtitle = Instance.new("TextLabel")
Subtitle.BackgroundTransparency = 1
Subtitle.Position = UDim2.fromOffset(19, 30)
Subtitle.Size = UDim2.new(1, -70, 0, 18)
Subtitle.Text = "ADMIN DEBUG PANEL"
Subtitle.TextColor3 = Color3.fromRGB(255, 50, 110)
Subtitle.TextSize = 10
Subtitle.Font = Enum.Font.GothamBold
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = Header

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(35, 35)
Close.Position = UDim2.new(1, -45, 0, 10)
Close.BackgroundColor3 = Color3.fromRGB(30, 30, 34)
Close.Text = "×"
Close.TextColor3 = Color3.fromRGB(255, 70, 110)
Close.TextSize = 24
Close.Font = Enum.Font.GothamBold
Close.AutoButtonColor = false
Close.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 9)
CloseCorner.Parent = Close

local Content = Instance.new("ScrollingFrame")
Content.Position = UDim2.fromOffset(10, 65)
Content.Size = UDim2.new(1, -20, 1, -75)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 3
Content.ScrollBarImageColor3 = Color3.fromRGB(255, 40, 100)
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.Parent = Main

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 7)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = Content

local Padding = Instance.new("UIPadding")
Padding.PaddingLeft = UDim.new(0, 3)
Padding.PaddingRight = UDim.new(0, 3)
Padding.PaddingBottom = UDim.new(0, 10)
Padding.Parent = Content

--==================================================
-- BUTTON CREATOR
--==================================================

local function createButton(text)
	local Button = Instance.new("TextButton")

	Button.Size = UDim2.new(1, -6, 0, 42)
	Button.BackgroundColor3 = Color3.fromRGB(18, 18, 21)
	Button.BorderSizePixel = 0
	Button.Text = text
	Button.TextColor3 = Color3.fromRGB(255, 255, 255)
	Button.TextSize = 13
	Button.Font = Enum.Font.GothamBold
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
			{
				BackgroundColor3 = Color3.fromRGB(35, 20, 27)
			}
		):Play()
	end)

	Button.MouseLeave:Connect(function()
		TweenService:Create(
			Button,
			TweenInfo.new(0.15),
			{
				BackgroundColor3 = Color3.fromRGB(18, 18, 21)
			}
		):Play()
	end)

	return Button
end

--==================================================
-- ENEMY CHECK
--==================================================

local function isEnemy(player)
	if player == LocalPlayer then
		return false
	end

	if not player.Character then
		return false
	end

	local humanoid = player.Character:FindFirstChildOfClass("Humanoid")

	if not humanoid or humanoid.Health <= 0 then
		return false
	end

	-- Team check
	if LocalPlayer.Team ~= nil and player.Team ~= nil then
		return LocalPlayer.Team ~= player.Team
	end

	return true
end

--==================================================
-- ESP
--==================================================

local function removeEnemyESP(player)
	if not player.Character then
		return
	end

	local character = player.Character
	local root = character:FindFirstChild("HumanoidRootPart")

	local highlight = character:FindFirstChild("AdminEnemyESP")

	if highlight then
		highlight:Destroy()
	end

	if root then
		local marker = root:FindFirstChild("AdminEnemyMarker")

		if marker then
			marker:Destroy()
		end
	end

	-- VERY IMPORTANT:
	-- no ESP = no aimbot target
	character:SetAttribute("AdminAimTarget", false)
end

local function createEnemyESP(player)
	if not player.Character then
		return
	end

	local character = player.Character
	local root = character:FindFirstChild("HumanoidRootPart")

	if not root then
		return
	end

	-- Clean old ESP
	removeEnemyESP(player)

	-- If ESP is disabled, don't mark the player
	if not Settings.ESP then
		return
	end

	if not isEnemy(player) then
		return
	end

	--==================================================
	-- RED HIGHLIGHT
	--==================================================

	local highlight = Instance.new("Highlight")
	highlight.Name = "AdminEnemyESP"
	highlight.Adornee = character

	highlight.FillColor = Color3.fromRGB(255, 0, 0)
	highlight.OutlineColor = Color3.fromRGB(255, 0, 0)

	highlight.FillTransparency = 0.78
	highlight.OutlineTransparency = 0

	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

	highlight.Parent = character

	--==================================================
	-- RED ARROW
	--==================================================

	if Settings.Markers then
		local marker = Instance.new("BillboardGui")

		marker.Name = "AdminEnemyMarker"
		marker.Adornee = root
		marker.Size = UDim2.fromOffset(65, 65)
		marker.StudsOffset = Vector3.new(0, 4.5, 0)
		marker.AlwaysOnTop = true

		marker.Parent = root

		local arrow = Instance.new("TextLabel")

		arrow.BackgroundTransparency = 1
		arrow.Size = UDim2.fromScale(1, 1)

		arrow.Text = "▼"
		arrow.TextColor3 = Color3.fromRGB(255, 0, 0)
		arrow.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		arrow.TextStrokeTransparency = 0

		arrow.TextScaled = true
		arrow.Font = Enum.Font.GothamBold

		arrow.Parent = marker
	end

	--==================================================
	-- AIM PERMISSION
	--==================================================

	-- THIS IS THE IMPORTANT PART.
	-- Only players currently marked by our ESP
	-- can be selected by the aimbot.

	character:SetAttribute("AdminAimTarget", true)
end

local function updateAllESP()
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			createEnemyESP(player)
		end
	end
end

--==================================================
-- AIM TARGET
--==================================================

local function isMarkedEnemy(player)
	if not player.Character then
		return false
	end

	if not isEnemy(player) then
		return false
	end

	-- Aimbot ONLY accepts players marked by our ESP.
	if player.Character:GetAttribute("AdminAimTarget") ~= true then
		return false
	end

	-- Extra safety check:
	-- the actual red Highlight must exist.
	local highlight = player.Character:FindFirstChild("AdminEnemyESP")

	if not highlight then
		return false
	end

	return true
end

local function getAimPart(character)
	if not character then
		return nil
	end

	if Settings.AimPart == "Head" then
		return character:FindFirstChild("Head")
	elseif Settings.AimPart == "Torso" then
		return character:FindFirstChild("UpperTorso")
			or character:FindFirstChild("Torso")
	elseif Settings.AimPart == "HumanoidRootPart" then
		return character:FindFirstChild("HumanoidRootPart")
	end

	return character:FindFirstChild("Head")
end

local function getAimTarget()
	local closest = nil
	local closestDistance = Settings.AimRange

	local viewport = Camera.ViewportSize

	local center = Vector2.new(
		viewport.X / 2,
		viewport.Y / 2
	)

	for _, player in ipairs(Players:GetPlayers()) do

		-- THIS FILTER IS THE KEY.
		-- Non-red-ESP players are completely ignored.
		if isMarkedEnemy(player) then

			local character = player.Character
			local humanoid = character:FindFirstChildOfClass("Humanoid")

			if humanoid and humanoid.Health > 0 then

				local part = getAimPart(character)

				if part then

					local screenPosition, visible =
						Camera:WorldToViewportPoint(part.Position)

					if visible and screenPosition.Z > 0 then

						local screenPoint = Vector2.new(
							screenPosition.X,
							screenPosition.Y
						)

						local distance =
							(screenPoint - center).Magnitude

						if distance < closestDistance then
							closestDistance = distance
							closest = part
						end
					end
				end
			end
		end
	end

	return closest
end

--==================================================
-- PLAYER HITBOXES
--==================================================

local PlayerHitboxObjects = {}

local function createHitbox(player)
	if not player.Character then
		return
	end

	local character = player.Character
	local root = character:FindFirstChild("HumanoidRootPart")

	if not root then
		return
	end

	if PlayerHitboxObjects[player] then
		PlayerHitboxObjects[player]:Destroy()
		PlayerHitboxObjects[player] = nil
	end

	if not Settings.ShowPlayerHitboxes then
		return
	end

	local adornment = Instance.new("BoxHandleAdornment")

	adornment.Name = "AdminPlayerHitbox"
	adornment.Adornee = root

	adornment.Size = root.Size * Settings.PlayerHitbox

	adornment.Color3 = Color3.fromRGB(255, 50, 100)
	adornment.Transparency = 0.75

	adornment.AlwaysOnTop = true
	adornment.ZIndex = 5

	adornment.Parent = root

	PlayerHitboxObjects[player] = adornment
end

local function updatePlayerHitboxes()
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			createHitbox(player)
		end
	end
end

--==================================================
-- NPC HITBOXES
--==================================================

local NpcHitboxObjects = {}

local function isNPC(model)
	if not model:IsA("Model") then
		return false
	end

	if Players:GetPlayerFromCharacter(model) then
		return false
	end

	local humanoid = model:FindFirstChildOfClass("Humanoid")
	local root = model:FindFirstChild("HumanoidRootPart")

	return humanoid ~= nil and root ~= nil
end

local function updateNpcHitboxes()
	-- Remove old
	for model, object in pairs(NpcHitboxObjects) do
		if object and object.Parent then
			object:Destroy()
		end

		NpcHitboxObjects[model] = nil
	end

	if not Settings.ShowNpcHitboxes then
		return
	end

	for _, object in ipairs(workspace:GetDescendants()) do

		if isNPC(object) then

			local root = object:FindFirstChild("HumanoidRootPart")

			if root then

				local adornment = Instance.new("BoxHandleAdornment")

				adornment.Name = "AdminNPCHitbox"
				adornment.Adornee = root

				adornment.Size =
					root.Size * Settings.NpcHitbox

				adornment.Color3 =
					Color3.fromRGB(255, 50, 100)

				adornment.Transparency = 0.75

				adornment.AlwaysOnTop = true
				adornment.ZIndex = 5

				adornment.Parent = root

				NpcHitboxObjects[object] = adornment
			end
		end
	end
end

--==================================================
-- BUTTONS
--==================================================

local AimbotButton = createButton("AIMBOT: OFF")

AimbotButton.MouseButton1Click:Connect(function()

	Settings.Aimbot = not Settings.Aimbot

	if Settings.Aimbot then
		AimbotButton.Text = "AIMBOT: ON"
		AimbotButton.TextColor3 = Color3.fromRGB(255, 50, 110)
	else
		AimbotButton.Text = "AIMBOT: OFF"
		AimbotButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	end
end)

local ESPButton = createButton("ENEMY ESP: ON")

ESPButton.MouseButton1Click:Connect(function()

	Settings.ESP = not Settings.ESP

	if Settings.ESP then
		ESPButton.Text = "ENEMY ESP: ON"
		ESPButton.TextColor3 = Color3.fromRGB(255, 50, 110)

		updateAllESP()
	else
		ESPButton.Text = "ENEMY ESP: OFF"
		ESPButton.TextColor3 = Color3.fromRGB(255, 255, 255)

		-- Removing ESP also removes aim permission
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer then
				removeEnemyESP(player)
			end
		end
	end
end)

local MarkerButton = createButton("ENEMY MARKERS: ON")

MarkerButton.MouseButton1Click:Connect(function()

	Settings.Markers = not Settings.Markers

	if Settings.Markers then
		MarkerButton.Text = "ENEMY MARKERS: ON"
		MarkerButton.TextColor3 = Color3.fromRGB(255, 50, 110)
	else
		MarkerButton.Text = "ENEMY MARKERS: OFF"
		MarkerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	end

	updateAllESP()
end)

local AimPartButton = createButton("AIM PART: HEAD")

AimPartButton.MouseButton1Click:Connect(function()

	if Settings.AimPart == "Head" then
		Settings.AimPart = "Torso"
	elseif Settings.AimPart == "Torso" then
		Settings.AimPart = "HumanoidRootPart"
	else
		Settings.AimPart = "Head"
	end

	AimPartButton.Text =
		"AIM PART: " .. string.upper(Settings.AimPart)
end)

local SmoothButton =
	createButton("AIM SMOOTH: " .. tostring(Settings.AimSmoothness))

SmoothButton.MouseButton1Click:Connect(function()

	Settings.AimSmoothness += 0.05

	if Settings.AimSmoothness > 0.8 then
		Settings.AimSmoothness = 0.1
	end

	Settings.AimSmoothness =
		math.floor(Settings.AimSmoothness * 100) / 100

	SmoothButton.Text =
		"AIM SMOOTH: " .. tostring(Settings.AimSmoothness)
end)

local PlayerHitboxButton =
	createButton("PLAYER HITBOX: x" .. Settings.PlayerHitbox)

PlayerHitboxButton.MouseButton1Click:Connect(function()

	Settings.PlayerHitbox += 0.5

	if Settings.PlayerHitbox > 5 then
		Settings.PlayerHitbox = 1
	end

	PlayerHitboxButton.Text =
		"PLAYER HITBOX: x" .. Settings.PlayerHitbox

	updatePlayerHitboxes()
end)

local ShowPlayerButton =
	createButton("SHOW PLAYER HITBOXES: OFF")

ShowPlayerButton.MouseButton1Click:Connect(function()

	Settings.ShowPlayerHitboxes =
		not Settings.ShowPlayerHitboxes

	if Settings.ShowPlayerHitboxes then
		ShowPlayerButton.Text =
			"SHOW PLAYER HITBOXES: ON"

		ShowPlayerButton.TextColor3 =
			Color3.fromRGB(255, 50, 110)
	else
		ShowPlayerButton.Text =
			"SHOW PLAYER HITBOXES: OFF"

		ShowPlayerButton.TextColor3 =
			Color3.fromRGB(255, 255, 255)
	end

	updatePlayerHitboxes()
end)

local NpcHitboxButton =
	createButton("NPC HITBOX: x" .. Settings.NpcHitbox)

NpcHitboxButton.MouseButton1Click:Connect(function()

	Settings.NpcHitbox += 0.5

	if Settings.NpcHitbox > 5 then
		Settings.NpcHitbox = 1
	end

	NpcHitboxButton.Text =
		"NPC HITBOX: x" .. Settings.NpcHitbox

	updateNpcHitboxes()
end)

local ShowNpcButton =
	createButton("SHOW NPC HITBOXES: OFF")

ShowNpcButton.MouseButton1Click:Connect(function()

	Settings.ShowNpcHitboxes =
		not Settings.ShowNpcHitboxes

	if Settings.ShowNpcHitboxes then
		ShowNpcButton.Text =
			"SHOW NPC HITBOXES: ON"

		ShowNpcButton.TextColor3 =
			Color3.fromRGB(255, 50, 110)
	else
		ShowNpcButton.Text =
			"SHOW NPC HITBOXES: OFF"

		ShowNpcButton.TextColor3 =
			Color3.fromRGB(255, 255, 255)
	end

	updateNpcHitboxes()
end)

local ResetButton = createButton("RESET HITBOXES")

ResetButton.MouseButton1Click:Connect(function()

	Settings.PlayerHitbox = 1
	Settings.NpcHitbox = 1

	PlayerHitboxButton.Text = "PLAYER HITBOX: x1"
	NpcHitboxButton.Text = "NPC HITBOX: x1"

	updatePlayerHitboxes()
	updateNpcHitboxes()
end)

--==================================================
-- PLAYER EVENTS
--==================================================

local function setupPlayer(player)

	if player == LocalPlayer then
		return
	end

	player.CharacterAdded:Connect(function()
		task.wait(0.5)

		createEnemyESP(player)
		createHitbox(player)
	end)

	if player.Character then
		task.defer(function()
			createEnemyESP(player)
			createHitbox(player)
		end)
	end

	player:GetPropertyChangedSignal("Team"):Connect(function()
		createEnemyESP(player)
	end)
end

for _, player in ipairs(Players:GetPlayers()) do
	setupPlayer(player)
end

Players.PlayerAdded:Connect(setupPlayer)

Players.PlayerRemoving:Connect(function(player)

	if PlayerHitboxObjects[player] then
		PlayerHitboxObjects[player]:Destroy()
		PlayerHitboxObjects[player] = nil
	end
end)

--==================================================
-- AIMBOT
--==================================================

RunService:BindToRenderStep(
	"CombatAdminAimbot",
	Enum.RenderPriority.Camera.Value + 1,
	function()

		if not Settings.Aimbot then
			return
		end

		local target = getAimTarget()

		if not target then
			return
		end

		local cameraPosition = Camera.CFrame.Position

		local targetCFrame =
			CFrame.lookAt(
				cameraPosition,
				target.Position
			)

		Camera.CFrame =
			Camera.CFrame:Lerp(
				targetCFrame,
				Settings.AimSmoothness
			)
	end
)

--==================================================
-- DRAGGING
--==================================================

local dragging = false
local dragStart
local startPosition

Header.InputBegan:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		dragging = true
		dragStart = input.Position
		startPosition = Main.Position
	end
end)

Header.InputEnded:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		dragging = false
	end
end)

UserInputService.InputChanged:Connect(function(input)

	if not dragging then
		return
	end

	if input.UserInputType ~= Enum.UserInputType.MouseMovement
		and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end

	local delta = input.Position - dragStart

	Main.Position = UDim2.new(
		startPosition.X.Scale,
		startPosition.X.Offset + delta.X,
		startPosition.Y.Scale,
		startPosition.Y.Offset + delta.Y
	)
end)

--==================================================
-- OPEN / CLOSE
--==================================================

local isOpen = true

Close.MouseButton1Click:Connect(function()

	isOpen = false

	TweenService:Create(
		Main,
		TweenInfo.new(
			0.25,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.In
		),
		{
			Size = UDim2.fromOffset(310, 0)
		}
	):Play()

	task.wait(0.25)

	Main.Visible = false
end)

--==================================================
-- KEYBOARD
--==================================================

UserInputService.InputBegan:Connect(function(input, processed)

	if processed then
		return
	end

	if input.KeyCode == Enum.KeyCode.RightBracket then

		Settings.PlayerHitbox += 0.5

		if Settings.PlayerHitbox > 5 then
			Settings.PlayerHitbox = 1
		end

		PlayerHitboxButton.Text =
			"PLAYER HITBOX: x" .. Settings.PlayerHitbox

		updatePlayerHitboxes()
	end

	if input.KeyCode == Enum.KeyCode.LeftBracket then

		Settings.PlayerHitbox -= 0.5

		if Settings.PlayerHitbox < 1 then
			Settings.PlayerHitbox = 5
		end

		PlayerHitboxButton.Text =
			"PLAYER HITBOX: x" .. Settings.PlayerHitbox

		updatePlayerHitboxes()
	end

	if input.KeyCode == Enum.KeyCode.H then

		Settings.ShowPlayerHitboxes =
			not Settings.ShowPlayerHitboxes

		if Settings.ShowPlayerHitboxes then
			ShowPlayerButton.Text =
				"SHOW PLAYER HITBOXES: ON"
		else
			ShowPlayerButton.Text =
				"SHOW PLAYER HITBOXES: OFF"
		end

		updatePlayerHitboxes()
	end
end)

--==================================================
-- INITIAL
--==================================================

task.wait(1)

updateAllESP()
updatePlayerHitboxes()
updateNpcHitboxes()
