--// COMBAT ADMIN PANEL
--// FULL REWORK
--// LocalScript -> StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Stats = game:GetService("Stats")
local CollectionService = game:GetService("CollectionService")
local LogService = game:GetService("LogService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Camera = workspace.CurrentCamera

--==================================================
-- SETTINGS
--==================================================

local Settings = {
	PlayerAimbot = false,
	NpcAimbot = false,

	AimPart = "Head",
	AimSmoothness = 0.25,
	AimRange = 500,
	AimFOV = 150,

	InstantAim = false,

	DebugOverlay = false,
	TargetDebug = false,
	PerformanceDebug = false,

	TargetInfo = false,
	EspDebug = false,
	NpcScanner = false,

	UIAnimations = true,
	CompactUI = false,
}

--==================================================
-- DEFAULT SETTINGS
--==================================================

local DEFAULT_SETTINGS = {
	PlayerAimbot = false,
	NpcAimbot = false,

	AimPart = "Head",
	AimSmoothness = 0.25,
	AimRange = 500,
	AimFOV = 150,

	InstantAim = false,

	DebugOverlay = false,
	TargetDebug = false,
	PerformanceDebug = false,

	TargetInfo = false,
	EspDebug = false,
	NpcScanner = false,

	UIAnimations = true,
	CompactUI = false,
}

--==================================================
-- COLORS
--==================================================

local COLORS = {
	Background = Color3.fromRGB(7, 8, 12),
	Panel = Color3.fromRGB(11, 12, 18),
	Panel2 = Color3.fromRGB(16, 17, 25),

	Card = Color3.fromRGB(18, 20, 29),
	CardHover = Color3.fromRGB(27, 22, 34),

	Stroke = Color3.fromRGB(45, 48, 62),

	Pink = Color3.fromRGB(255, 35, 115),
	PinkDark = Color3.fromRGB(170, 20, 75),

	White = Color3.fromRGB(245, 245, 250),
	Gray = Color3.fromRGB(150, 153, 165),
	Gray2 = Color3.fromRGB(95, 99, 112),

	Green = Color3.fromRGB(70, 220, 140),
	Red = Color3.fromRGB(255, 70, 90),
	Yellow = Color3.fromRGB(255, 210, 80),
}

--==================================================
-- TWEEN
--==================================================

local TweenFast = TweenInfo.new(
	0.12,
	Enum.EasingStyle.Quad,
	Enum.EasingDirection.Out
)

local TweenNormal = TweenInfo.new(
	0.2,
	Enum.EasingStyle.Quart,
	Enum.EasingDirection.Out
)

local TweenPage = TweenInfo.new(
	0.22,
	Enum.EasingStyle.Quart,
	Enum.EasingDirection.Out
)

--==================================================
-- STATE
--==================================================

local IsOpen = true
local CurrentPage = nil

local CurrentTarget = nil
local CurrentNpcTarget = nil

local LastAimScan = 0
local AimScanInterval = 0.06

local LastNpcScan = 0
local NpcScanInterval = 0.08

local LastPerformanceUpdate = 0
local LastDebugUpdate = 0

local LastFPS = 0
local FPSAccumulator = 0
local FPSFrames = 0

local NPCs = {}

local Connections = {}

local DebugToolWindow = nil
local DebugToolContent = nil
local DebugToolTitle = nil
local DebugToolSubtitle = nil

local DebugConsoleMessages = {}
local DebugConsoleConnection = nil

local SelectedDebugPlayer = LocalPlayer
local SelectedDebugObject = nil

local RemoteList = {}
local SelectedRemoteIndex = 1

--==================================================
-- SCREEN GUI
--==================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CombatAdminPanel"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 100
ScreenGui.Parent = PlayerGui

--==================================================
-- AIM FOV CIRCLE
--==================================================

local AimFOVCircle = Instance.new("Frame")
AimFOVCircle.Name = "AimFOVCircle"
AimFOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
AimFOVCircle.Position = UDim2.fromScale(0.5, 0.5)
AimFOVCircle.Size = UDim2.fromOffset(
	Settings.AimFOV * 2,
	Settings.AimFOV * 2
)
AimFOVCircle.BackgroundTransparency = 1
AimFOVCircle.BorderSizePixel = 0
AimFOVCircle.Visible = false
AimFOVCircle.ZIndex = 5
AimFOVCircle.Parent = ScreenGui

local AimFOVCorner = Instance.new("UICorner")
AimFOVCorner.CornerRadius = UDim.new(1, 0)
AimFOVCorner.Parent = AimFOVCircle

local AimFOVStroke = Instance.new("UIStroke")
AimFOVStroke.Color = COLORS.Pink
AimFOVStroke.Thickness = 1.5
AimFOVStroke.Transparency = 0.15
AimFOVStroke.Parent = AimFOVCircle

--==================================================
-- OPEN BUTTON
--==================================================

local OpenButton = Instance.new("TextButton")
OpenButton.Name = "OpenCombat"
OpenButton.Size = UDim2.fromOffset(44, 44)
OpenButton.Position = UDim2.new(0, 16, 0.5, -22)
OpenButton.BackgroundColor3 = COLORS.Panel
OpenButton.BorderSizePixel = 0
OpenButton.Text = "⚔"
OpenButton.TextColor3 = COLORS.Pink
OpenButton.TextSize = 21
OpenButton.Font = Enum.Font.GothamBold
OpenButton.AutoButtonColor = false
OpenButton.Active = true
OpenButton.Selectable = true
OpenButton.ZIndex = 100
OpenButton.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(0, 12)
OpenCorner.Parent = OpenButton

local OpenStroke = Instance.new("UIStroke")
OpenStroke.Color = COLORS.Pink
OpenStroke.Thickness = 1.5
OpenStroke.Transparency = 0.15
OpenStroke.Parent = OpenButton

--==================================================
-- MAIN PANEL
--==================================================

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Position = UDim2.fromScale(0.5, 0.5)
Main.Size = UDim2.fromOffset(590, 390)
Main.BackgroundColor3 = COLORS.Background
Main.BorderSizePixel = 0
Main.Visible = true
Main.Active = true
Main.ZIndex = 10
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 15)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = COLORS.Pink
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.2
MainStroke.Parent = Main

local MainSizeConstraint = Instance.new("UISizeConstraint")
MainSizeConstraint.MinSize = Vector2.new(300, 320)
MainSizeConstraint.MaxSize = Vector2.new(650, 450)
MainSizeConstraint.Parent = Main

--==================================================
-- RESPONSIVE SIZE
--==================================================

local function getNormalPanelSize()
	local viewport = Camera and Camera.ViewportSize

	if viewport and viewport.X < 600 then
		return UDim2.new(0.92, 0, 0.78, 0)
	end

	return UDim2.fromOffset(
		Settings.CompactUI and 540 or 590,
		Settings.CompactUI and 360 or 390
	)
end

local function updatePanelSize()
	if not Main.Visible then
		return
	end

	local viewport = Camera and Camera.ViewportSize

	if viewport and viewport.X < 600 then
		Main.Size = UDim2.new(0.92, 0, 0.78, 0)
	else
		Main.Size = getNormalPanelSize()
	end
end

updatePanelSize()

if Camera then
	table.insert(
		Connections,
		Camera:GetPropertyChangedSignal("ViewportSize"):Connect(updatePanelSize)
	)
end

--==================================================
-- HEADER
--==================================================

local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 55)
Header.BackgroundColor3 = COLORS.Panel
Header.BorderSizePixel = 0
Header.Active = true
Header.ZIndex = 11
Header.Parent = Main

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 15)
HeaderCorner.Parent = Header

local Logo = Instance.new("TextLabel")
Logo.BackgroundTransparency = 1
Logo.Position = UDim2.fromOffset(16, 7)
Logo.Size = UDim2.fromOffset(36, 38)
Logo.Text = "⚔"
Logo.TextColor3 = COLORS.Pink
Logo.TextSize = 23
Logo.Font = Enum.Font.GothamBold
Logo.ZIndex = 12
Logo.Parent = Header

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Position = UDim2.fromOffset(54, 6)
Title.Size = UDim2.new(1, -170, 0, 23)
Title.Text = "COMBAT"
Title.TextColor3 = COLORS.White
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 12
Title.Parent = Header

local Subtitle = Instance.new("TextLabel")
Subtitle.BackgroundTransparency = 1
Subtitle.Position = UDim2.fromOffset(55, 29)
Subtitle.Size = UDim2.new(1, -170, 0, 16)
Subtitle.Text = "ADMIN DEBUG PANEL"
Subtitle.TextColor3 = COLORS.Pink
Subtitle.TextSize = 8
Subtitle.Font = Enum.Font.GothamBold
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.ZIndex = 12
Subtitle.Parent = Header

--==================================================
-- ADMIN BADGE
--==================================================

local AdminBadge = Instance.new("Frame")
AdminBadge.Size = UDim2.fromOffset(88, 32)
AdminBadge.Position = UDim2.new(1, -132, 0, 11)
AdminBadge.BackgroundColor3 = COLORS.Card
AdminBadge.BorderSizePixel = 0
AdminBadge.ZIndex = 12
AdminBadge.Parent = Header

local BadgeCorner = Instance.new("UICorner")
BadgeCorner.CornerRadius = UDim.new(0, 9)
BadgeCorner.Parent = AdminBadge

local BadgeStroke = Instance.new("UIStroke")
BadgeStroke.Color = COLORS.Stroke
BadgeStroke.Parent = AdminBadge

local BadgeText = Instance.new("TextLabel")
BadgeText.BackgroundTransparency = 1
BadgeText.Size = UDim2.new(1, 0, 1, 0)
BadgeText.Text = "♛  ADMIN"
BadgeText.TextColor3 = COLORS.White
BadgeText.TextSize = 10
BadgeText.Font = Enum.Font.GothamBold
BadgeText.ZIndex = 13
BadgeText.Parent = AdminBadge

--==================================================
-- CLOSE
--==================================================

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(31, 31)
Close.Position = UDim2.new(1, -38, 0, 11)
Close.BackgroundColor3 = COLORS.Card
Close.BorderSizePixel = 0
Close.Text = "×"
Close.TextColor3 = COLORS.Pink
Close.TextSize = 21
Close.Font = Enum.Font.GothamBold
Close.AutoButtonColor = false
Close.Active = true
Close.Selectable = true
Close.ZIndex = 13
Close.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 9)
CloseCorner.Parent = Close

--==================================================
-- PAGE CONTAINER
--==================================================

local PageContainer = Instance.new("Frame")
PageContainer.Name = "Pages"
PageContainer.Position = UDim2.fromOffset(9, 64)
PageContainer.Size = UDim2.new(1, -18, 1, -73)
PageContainer.BackgroundTransparency = 1
PageContainer.ClipsDescendants = true
PageContainer.ZIndex = 10
PageContainer.Parent = Main

--==================================================
-- PAGE SYSTEM
--==================================================

local Pages = {}

local function createPage(name)
	local page = Instance.new("ScrollingFrame")
	page.Name = name
	page.Size = UDim2.fromScale(1, 1)
	page.Position = UDim2.fromScale(0, 0)
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.Visible = false
	page.ZIndex = 10

	page.Active = true
	page.Selectable = false

	page.ScrollingEnabled = true
	page.ScrollingDirection = Enum.ScrollingDirection.Y

	page.ScrollBarThickness = 3
	page.ScrollBarImageColor3 = COLORS.Pink
	page.ScrollBarImageTransparency = 0.25

	page.CanvasSize = UDim2.new(0, 0, 0, 0)
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y

	page.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable

	page.Parent = PageContainer

	Pages[name] = page

	return page
end

local HomePage = createPage("Home")
local AimPage = createPage("Aim")
local DebugPage = createPage("Debug")
local MiscPage = createPage("Misc")
local SettingsPage = createPage("Settings")

--==================================================
-- BUTTON STYLE
--==================================================

local function styleButton(button)
	button.AutoButtonColor = false
	button.Active = true
	button.Selectable = true

	local stroke = button:FindFirstChildOfClass("UIStroke")

	if not stroke then
		stroke = Instance.new("UIStroke")
		stroke.Color = COLORS.Stroke
		stroke.Thickness = 1
		stroke.Parent = button
	end

	button.MouseEnter:Connect(function()
		TweenService:Create(
			button,
			TweenFast,
			{
				BackgroundColor3 = COLORS.CardHover
			}
		):Play()

		TweenService:Create(
			stroke,
			TweenFast,
			{
				Color = COLORS.Pink,
				Transparency = 0.2
			}
		):Play()
	end)

	button.MouseLeave:Connect(function()
		TweenService:Create(
			button,
			TweenFast,
			{
				BackgroundColor3 = COLORS.Card
			}
		):Play()

		TweenService:Create(
			stroke,
			TweenFast,
			{
				Color = COLORS.Stroke,
				Transparency = 0
			}
		):Play()
	end)

	button.Activated:Connect(function()
		TweenService:Create(
			button,
			TweenInfo.new(
				0.06,
				Enum.EasingStyle.Quad,
				Enum.EasingDirection.Out
			),
			{
				BackgroundColor3 = COLORS.PinkDark
			}
		):Play()

		task.delay(0.07, function()
			if button and button.Parent then
				TweenService:Create(
					button,
					TweenFast,
					{
						BackgroundColor3 = COLORS.Card
					}
				):Play()
			end
		end)
	end)

	return button
end

--==================================================
-- PAGE TRANSITION
--==================================================

local function showPage(pageName)
	local newPage = Pages[pageName]

	if not newPage then
		return
	end

	if CurrentPage == newPage then
		return
	end

	local oldPage = CurrentPage

	CurrentPage = newPage
	newPage.Visible = true

	newPage.CanvasPosition = Vector2.new(0, 0)

	if not Settings.UIAnimations then
		newPage.Position = UDim2.fromScale(0, 0)

		if oldPage then
			oldPage.Visible = false
			oldPage.Position = UDim2.fromScale(0, 0)
		end

		return
	end

	newPage.Position = UDim2.fromScale(0.06, 0)

	TweenService:Create(
		newPage,
		TweenPage,
		{
			Position = UDim2.fromScale(0, 0)
		}
	):Play()

	if oldPage then
		local old = oldPage

		TweenService:Create(
			old,
			TweenInfo.new(
				0.16,
				Enum.EasingStyle.Quad,
				Enum.EasingDirection.In
			),
			{
				Position = UDim2.fromScale(-0.05, 0)
			}
		):Play()

		task.delay(0.16, function()
			if old ~= CurrentPage then
				old.Visible = false
				old.Position = UDim2.fromScale(0, 0)
			end
		end)
	end
end

--==================================================
-- HELPERS
--==================================================

local function createPageHeader(parent, title, subtitle)
	local titleLabel = Instance.new("TextLabel")
	titleLabel.BackgroundTransparency = 1
	titleLabel.Position = UDim2.fromOffset(7, 0)
	titleLabel.Size = UDim2.new(1, -100, 0, 23)
	titleLabel.Text = title
	titleLabel.TextColor3 = COLORS.White
	titleLabel.TextSize = 18
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.ZIndex = 14
	titleLabel.Parent = parent

	local sub = Instance.new("TextLabel")
	sub.BackgroundTransparency = 1
	sub.Position = UDim2.fromOffset(8, 23)
	sub.Size = UDim2.new(1, -100, 0, 17)
	sub.Text = subtitle
	sub.TextColor3 = COLORS.Gray
	sub.TextSize = 8
	sub.Font = Enum.Font.Gotham
	sub.TextXAlignment = Enum.TextXAlignment.Left
	sub.ZIndex = 14
	sub.Parent = parent

	local back = Instance.new("TextButton")
	back.Size = UDim2.fromOffset(72, 32)
	back.Position = UDim2.new(1, -78, 0, 0)
	back.BackgroundColor3 = COLORS.Card
	back.BorderSizePixel = 0
	back.Text = "‹  BACK"
	back.TextColor3 = COLORS.White
	back.TextSize = 9
	back.Font = Enum.Font.GothamBold
	back.AutoButtonColor = false
	back.Active = true
	back.Selectable = true
	back.ZIndex = 15
	back.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 9)
	corner.Parent = back

	styleButton(back)

	back.Activated:Connect(function()
		showPage("Home")
	end)

	return back
end

--==================================================
-- TOGGLE
--==================================================

local function createToggle(
	parent,
	y,
	title,
	description,
	getValue,
	setValue
)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -16, 0, 53)
	button.Position = UDim2.fromOffset(8, y)
	button.BackgroundColor3 = COLORS.Card
	button.BorderSizePixel = 0
	button.Text = ""
	button.Active = true
	button.Selectable = true
	button.AutoButtonColor = false
	button.ZIndex = 12
	button.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = button

	local titleLabel = Instance.new("TextLabel")
	titleLabel.BackgroundTransparency = 1
	titleLabel.Position = UDim2.fromOffset(12, 7)
	titleLabel.Size = UDim2.new(1, -90, 0, 19)
	titleLabel.Text = title
	titleLabel.TextColor3 = COLORS.White
	titleLabel.TextSize = 10
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.ZIndex = 13
	titleLabel.Parent = button

	local descLabel = Instance.new("TextLabel")
	descLabel.BackgroundTransparency = 1
	descLabel.Position = UDim2.fromOffset(12, 27)
	descLabel.Size = UDim2.new(1, -90, 0, 15)
	descLabel.Text = description
	descLabel.TextColor3 = COLORS.Gray
	descLabel.TextSize = 7.5
	descLabel.Font = Enum.Font.Gotham
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.ZIndex = 13
	descLabel.Parent = button

	local toggle = Instance.new("Frame")
	toggle.Size = UDim2.fromOffset(44, 22)
	toggle.Position = UDim2.new(1, -57, 0.5, -11)
	toggle.BackgroundColor3 = COLORS.Gray2
	toggle.BorderSizePixel = 0
	toggle.ZIndex = 13
	toggle.Parent = button

	local toggleCorner = Instance.new("UICorner")
	toggleCorner.CornerRadius = UDim.new(1, 0)
	toggleCorner.Parent = toggle

	local knob = Instance.new("Frame")
	knob.Size = UDim2.fromOffset(16, 16)
	knob.Position = UDim2.fromOffset(3, 3)
	knob.BackgroundColor3 = COLORS.White
	knob.BorderSizePixel = 0
	knob.ZIndex = 14
	knob.Parent = toggle

	local knobCorner = Instance.new("UICorner")
	knobCorner.CornerRadius = UDim.new(1, 0)
	knobCorner.Parent = knob

	local function refresh()
		local enabled = getValue()

		TweenService:Create(
			toggle,
			TweenFast,
			{
				BackgroundColor3 = enabled and COLORS.Pink or COLORS.Gray2
			}
		):Play()

		TweenService:Create(
			knob,
			TweenFast,
			{
				Position = enabled
					and UDim2.fromOffset(25, 3)
					or UDim2.fromOffset(3, 3)
			}
		):Play()
	end

	button.Activated:Connect(function()
		local newValue = not getValue()

		setValue(newValue)
		refresh()
	end)

	styleButton(button)
	refresh()

	return {
		Button = button,
		Refresh = refresh,
	}
end

--==================================================
-- CATEGORY BUTTON
--==================================================

local function createCategoryButton(
	parent,
	position,
	title,
	description,
	icon,
	callback
)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -16, 0, 61)
	button.Position = position
	button.BackgroundColor3 = COLORS.Card
	button.BorderSizePixel = 0
	button.Text = ""
	button.ZIndex = 12
	button.Active = true
	button.Selectable = true
	button.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 11)
	corner.Parent = button

	local iconLabel = Instance.new("TextLabel")
	iconLabel.BackgroundTransparency = 1
	iconLabel.Position = UDim2.fromOffset(12, 10)
	iconLabel.Size = UDim2.fromOffset(38, 38)
	iconLabel.Text = icon
	iconLabel.TextColor3 = COLORS.Pink
	iconLabel.TextSize = 21
	iconLabel.Font = Enum.Font.GothamBold
	iconLabel.ZIndex = 13
	iconLabel.Parent = button

	local titleLabel = Instance.new("TextLabel")
	titleLabel.BackgroundTransparency = 1
	titleLabel.Position = UDim2.fromOffset(58, 10)
	titleLabel.Size = UDim2.new(1, -100, 0, 20)
	titleLabel.Text = title
	titleLabel.TextColor3 = COLORS.White
	titleLabel.TextSize = 11
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.ZIndex = 13
	titleLabel.Parent = button

	local descLabel = Instance.new("TextLabel")
	descLabel.BackgroundTransparency = 1
	descLabel.Position = UDim2.fromOffset(58, 30)
	descLabel.Size = UDim2.new(1, -100, 0, 17)
	descLabel.Text = description
	descLabel.TextColor3 = COLORS.Gray
	descLabel.TextSize = 7.5
	descLabel.Font = Enum.Font.Gotham
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.ZIndex = 13
	descLabel.Parent = button

	local arrow = Instance.new("TextLabel")
	arrow.BackgroundTransparency = 1
	arrow.AnchorPoint = Vector2.new(1, 0.5)
	arrow.Position = UDim2.new(1, -13, 0.5, 0)
	arrow.Size = UDim2.fromOffset(18, 23)
	arrow.Text = "›"
	arrow.TextColor3 = COLORS.Gray
	arrow.TextSize = 22
	arrow.Font = Enum.Font.GothamBold
	arrow.ZIndex = 13
	arrow.Parent = button

	styleButton(button)

	button.Activated:Connect(callback)

	return button
end

--==================================================
-- HOME
--==================================================

do
	local titleLabel = Instance.new("TextLabel")
	titleLabel.BackgroundTransparency = 1
	titleLabel.Position = UDim2.fromOffset(8, 2)
	titleLabel.Size = UDim2.new(1, -16, 0, 23)
	titleLabel.Text = "CONTROL CENTER"
	titleLabel.TextColor3 = COLORS.White
	titleLabel.TextSize = 18
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.ZIndex = 12
	titleLabel.Parent = HomePage

	local subtitle = Instance.new("TextLabel")
	subtitle.BackgroundTransparency = 1
	subtitle.Position = UDim2.fromOffset(9, 25)
	subtitle.Size = UDim2.new(1, -18, 0, 17)
	subtitle.Text = "Choose a category"
	subtitle.TextColor3 = COLORS.Gray
	subtitle.TextSize = 8
	subtitle.Font = Enum.Font.Gotham
	subtitle.TextXAlignment = Enum.TextXAlignment.Left
	subtitle.ZIndex = 12
	subtitle.Parent = HomePage

	createCategoryButton(
		HomePage,
		UDim2.fromOffset(8, 51),
		"AIM",
		"Player, NPC and aim configuration",
		"◎",
		function()
			showPage("Aim")
		end
	)

	createCategoryButton(
		HomePage,
		UDim2.fromOffset(8, 120),
		"DEBUG",
		"Diagnostics and development information",
		"⚙",
		function()
			showPage("Debug")
		end
	)

	createCategoryButton(
		HomePage,
		UDim2.fromOffset(8, 189),
		"MISC",
		"Target, ESP and NPC utilities",
		"◆",
		function()
			showPage("Misc")
		end
	)

	createCategoryButton(
		HomePage,
		UDim2.fromOffset(8, 258),
		"SETTINGS",
		"Panel and interface configuration",
		"☷",
		function()
			showPage("Settings")
		end
	)
end

--==================================================
-- AIM HELPERS
--==================================================

local function getLocalCharacter()
	return LocalPlayer.Character
end

local function getLocalRoot()
	local character = getLocalCharacter()

	if not character then
		return nil
	end

	return character:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid(model)
	if not model then
		return nil
	end

	return model:FindFirstChildOfClass("Humanoid")
end

local function getRoot(model)
	if not model then
		return nil
	end

	return model:FindFirstChild("HumanoidRootPart")
		or model:FindFirstChild("UpperTorso")
		or model:FindFirstChild("Torso")
end

local function isAlive(model)
	local humanoid = getHumanoid(model)

	return humanoid
		and humanoid.Health > 0
end

local function isEnemy(player)
	if not player or player == LocalPlayer then
		return false
	end

	if LocalPlayer.Team ~= nil and player.Team ~= nil then
		if LocalPlayer.Team == player.Team then
			return false
		end
	end

	return true
end

local function isRedColor(color)
	if not color then
		return false
	end

	return color.R > 0.65
		and color.G < 0.35
		and color.B < 0.45
end

local function getSystemRedHighlight(character)
	if not character then
		return nil
	end

	for _, object in ipairs(character:GetDescendants()) do
		if object:IsA("Highlight") then
			if object.Enabled and isRedColor(object.FillColor) then
				return object
			end
		end
	end

	return nil
end

local function isValidPlayerTarget(player)
	if not player then
		return false
	end

	if not isEnemy(player) then
		return false
	end

	local character = player.Character

	if not character then
		return false
	end

	if not isAlive(character) then
		return false
	end

	local highlight = getSystemRedHighlight(character)

	if not highlight then
		return false
	end

	return true
end

local function getAimPart(model)
	if not model then
		return nil
	end

	if Settings.AimPart == "Head" then
		return model:FindFirstChild("Head")
			or model:FindFirstChild("UpperTorso")
			or getRoot(model)
	end

	if Settings.AimPart == "Torso" then
		return model:FindFirstChild("UpperTorso")
			or model:FindFirstChild("Torso")
			or getRoot(model)
	end

	return model:FindFirstChild("HumanoidRootPart")
		or getRoot(model)
end

--==================================================
-- FOV CHECK
--==================================================

local function isPartInsideAimFOV(part)
	if not part then
		return false
	end

	Camera = workspace.CurrentCamera

	if not Camera then
		return false
	end

	local viewport = Camera.ViewportSize

	if not viewport then
		return false
	end

	local screenPosition, onScreen =
		Camera:WorldToViewportPoint(part.Position)

	if not onScreen or screenPosition.Z <= 0 then
		return false
	end

	local screenCenter =
		Vector2.new(
			viewport.X / 2,
			viewport.Y / 2
		)

	local screenDistance =
		(
			Vector2.new(
				screenPosition.X,
				screenPosition.Y
			) - screenCenter
		).Magnitude

	return screenDistance <= Settings.AimFOV
end

--==================================================
-- PLAYER TARGET
--==================================================

local function getPlayerAimTarget()
	local localRoot = getLocalRoot()

	if not localRoot then
		return nil
	end

	Camera = workspace.CurrentCamera

	if not Camera then
		return nil
	end

	local viewport = Camera.ViewportSize

	if not viewport then
		return nil
	end

	local screenCenter =
		Vector2.new(
			viewport.X / 2,
			viewport.Y / 2
		)

	local bestPlayer = nil
	local bestDistance = math.huge

	for _, player in ipairs(Players:GetPlayers()) do
		if isValidPlayerTarget(player) then
			local character = player.Character
			local root = getRoot(character)
			local aimPart = getAimPart(character)

			if root and aimPart then
				local screenPosition, onScreen =
					Camera:WorldToViewportPoint(
						aimPart.Position
					)

				if onScreen and screenPosition.Z > 0 then
					local screenDistance =
						(
							Vector2.new(
								screenPosition.X,
								screenPosition.Y
							) - screenCenter
						).Magnitude

					if screenDistance <= Settings.AimFOV then
						local distance =
							(root.Position - localRoot.Position).Magnitude

						if distance <= Settings.AimRange
							and distance < bestDistance then

							bestDistance = distance
							bestPlayer = player
						end
					end
				end
			end
		end
	end

	return bestPlayer
end

--==================================================
-- NPC DETECTION
--==================================================

local function isNPC(model)
	if not model or not model:IsA("Model") then
		return false
	end

	if Players:GetPlayerFromCharacter(model) then
		return false
	end

	local humanoid = getHumanoid(model)

	if not humanoid then
		return false
	end

	if humanoid.Health <= 0 then
		return false
	end

	local root = getRoot(model)

	if not root then
		return false
	end

	return true
end

local function registerNPC(model)
	if isNPC(model) then
		NPCs[model] = true
	end
end

local function unregisterNPC(model)
	NPCs[model] = nil
end

local function rebuildNPCList()
	table.clear(NPCs)

	for _, object in ipairs(workspace:GetDescendants()) do
		if object:IsA("Model") then
			registerNPC(object)
		end
	end

	LastNpcScan = os.clock()
end

local function getNPCFromInstance(instance)
	if not instance then
		return nil
	end

	if instance:IsA("Model") then
		return instance
	end

	return instance:FindFirstAncestorOfClass("Model")
end

workspace.DescendantAdded:Connect(function(instance)
	local model = getNPCFromInstance(instance)

	if model then
		task.defer(function()
			registerNPC(model)
		end)
	end
end)

workspace.DescendantRemoving:Connect(function(instance)
	if instance:IsA("Model") then
		unregisterNPC(instance)
	end
end)

rebuildNPCList()

--==================================================
-- NPC TARGET
--==================================================

local function getNpcAimTarget()
	local localRoot = getLocalRoot()

	if not localRoot then
		return nil
	end

	Camera = workspace.CurrentCamera

	if not Camera then
		return nil
	end

	local viewport = Camera.ViewportSize

	if not viewport then
		return nil
	end

	local screenCenter =
		Vector2.new(
			viewport.X / 2,
			viewport.Y / 2
		)

	local bestNPC = nil
	local bestDistance = math.huge

	for npc in pairs(NPCs) do
		if npc.Parent and isNPC(npc) then
			local root = getRoot(npc)
			local aimPart = getAimPart(npc)

			if root and aimPart then
				local screenPosition, onScreen =
					Camera:WorldToViewportPoint(
						aimPart.Position
					)

				if onScreen and screenPosition.Z > 0 then
					local screenDistance =
						(
							Vector2.new(
								screenPosition.X,
								screenPosition.Y
							) - screenCenter
						).Magnitude

					if screenDistance <= Settings.AimFOV then
						local distance =
							(root.Position - localRoot.Position).Magnitude

						if distance <= Settings.AimRange
							and distance < bestDistance then

							bestDistance = distance
							bestNPC = npc
						end
					end
				end
			end
		end
	end

	return bestNPC
end

--==================================================
-- TARGET VALIDATION
--==================================================

local function isCurrentPlayerTargetValid()
	if not CurrentTarget then
		return false
	end

	if not isValidPlayerTarget(CurrentTarget) then
		return false
	end

	local character = CurrentTarget.Character

	if not character then
		return false
	end

	local aimPart = getAimPart(character)

	if not aimPart then
		return false
	end

	return isPartInsideAimFOV(aimPart)
end

local function isCurrentNpcTargetValid()
	if not CurrentNpcTarget then
		return false
	end

	if not CurrentNpcTarget.Parent then
		return false
	end

	if not isNPC(CurrentNpcTarget) then
		return false
	end

	local aimPart = getAimPart(CurrentNpcTarget)

	if not aimPart then
		return false
	end

	return isPartInsideAimFOV(aimPart)
end

--==================================================
-- TARGET TEXT
--==================================================

local function getTargetName()
	if CurrentTarget and isCurrentPlayerTargetValid() then
		return CurrentTarget.Name
	end

	if CurrentNpcTarget and isCurrentNpcTargetValid() then
		return CurrentNpcTarget.Name
	end

	return "No target"
end

--==================================================
-- AIM PAGE
--==================================================

createPageHeader(
	AimPage,
	"AIM",
	"Aimbot and target configuration"
)

createToggle(
	AimPage,
	52,
	"PLAYER AIMBOT",
	"Targets enemies with active red system ESP",
	function()
		return Settings.PlayerAimbot
	end,
	function(value)
		Settings.PlayerAimbot = value

		if not value then
			CurrentTarget = nil
		end
	end
)

createToggle(
	AimPage,
	111,
	"NPC AIMBOT",
	"Targets the nearest cached NPC",
	function()
		return Settings.NpcAimbot
	end,
	function(value)
		Settings.NpcAimbot = value

		if not value then
			CurrentNpcTarget = nil
		end
	end
)

createToggle(
	AimPage,
	170,
	"INSTANT AIM",
	"Locks camera directly onto the target",
	function()
		return Settings.InstantAim
	end,
	function(value)
		Settings.InstantAim = value
	end
)

--==================================================
-- AIM TARGET INFO
--==================================================

local AimInfo = Instance.new("Frame")
AimInfo.Size = UDim2.new(1, -16, 0, 66)
AimInfo.Position = UDim2.fromOffset(8, 229)
AimInfo.BackgroundColor3 = COLORS.Panel2
AimInfo.BorderSizePixel = 0
AimInfo.ZIndex = 12
AimInfo.Parent = AimPage

local AimInfoCorner = Instance.new("UICorner")
AimInfoCorner.CornerRadius = UDim.new(0, 10)
AimInfoCorner.Parent = AimInfo

local AimInfoStroke = Instance.new("UIStroke")
AimInfoStroke.Color = COLORS.PinkDark
AimInfoStroke.Transparency = 0.25
AimInfoStroke.Parent = AimInfo

local AimInfoTitle = Instance.new("TextLabel")
AimInfoTitle.BackgroundTransparency = 1
AimInfoTitle.Position = UDim2.fromOffset(11, 7)
AimInfoTitle.Size = UDim2.new(1, -22, 0, 15)
AimInfoTitle.Text = "CURRENT TARGET"
AimInfoTitle.TextColor3 = COLORS.Pink
AimInfoTitle.TextSize = 8
AimInfoTitle.Font = Enum.Font.GothamBold
AimInfoTitle.TextXAlignment = Enum.TextXAlignment.Left
AimInfoTitle.ZIndex = 13
AimInfoTitle.Parent = AimInfo

local AimTargetText = Instance.new("TextLabel")
AimTargetText.BackgroundTransparency = 1
AimTargetText.Position = UDim2.fromOffset(11, 25)
AimTargetText.Size = UDim2.new(1, -22, 0, 18)
AimTargetText.Text = "No target"
AimTargetText.TextColor3 = COLORS.White
AimTargetText.TextSize = 11
AimTargetText.Font = Enum.Font.GothamBold
AimTargetText.TextXAlignment = Enum.TextXAlignment.Left
AimTargetText.ZIndex = 13
AimTargetText.Parent = AimInfo

local AimStatus = Instance.new("TextLabel")
AimStatus.BackgroundTransparency = 1
AimStatus.Position = UDim2.fromOffset(11, 44)
AimStatus.Size = UDim2.new(1, -22, 0, 14)
AimStatus.Text = "Player: OFF     NPC: OFF"
AimStatus.TextColor3 = COLORS.Gray
AimStatus.TextSize = 7
AimStatus.Font = Enum.Font.Gotham
AimStatus.TextXAlignment = Enum.TextXAlignment.Left
AimStatus.ZIndex = 13
AimStatus.Parent = AimInfo

--==================================================
-- AIM PART
--==================================================

local AimPartButton = Instance.new("TextButton")
AimPartButton.Size = UDim2.new(1, -16, 0, 40)
AimPartButton.Position = UDim2.fromOffset(8, 303)
AimPartButton.BackgroundColor3 = COLORS.Card
AimPartButton.BorderSizePixel = 0
AimPartButton.TextColor3 = COLORS.White
AimPartButton.TextSize = 9
AimPartButton.Font = Enum.Font.GothamBold
AimPartButton.AutoButtonColor = false
AimPartButton.Active = true
AimPartButton.Selectable = true
AimPartButton.ZIndex = 12
AimPartButton.Parent = AimPage

local AimPartCorner = Instance.new("UICorner")
AimPartCorner.CornerRadius = UDim.new(0, 9)
AimPartCorner.Parent = AimPartButton

styleButton(AimPartButton)

local function refreshAimPart()
	AimPartButton.Text =
		"AIM PART:  "
		.. string.upper(Settings.AimPart)
end

AimPartButton.Activated:Connect(function()
	if Settings.AimPart == "Head" then
		Settings.AimPart = "Torso"
	elseif Settings.AimPart == "Torso" then
		Settings.AimPart = "HumanoidRootPart"
	else
		Settings.AimPart = "Head"
	end

	refreshAimPart()
end)

refreshAimPart()

--==================================================
-- RANGE
--==================================================

local RangeButton = Instance.new("TextButton")
RangeButton.Size = UDim2.new(1, -16, 0, 40)
RangeButton.Position = UDim2.fromOffset(8, 348)
RangeButton.BackgroundColor3 = COLORS.Card
RangeButton.BorderSizePixel = 0
RangeButton.TextColor3 = COLORS.White
RangeButton.TextSize = 9
RangeButton.Font = Enum.Font.GothamBold
RangeButton.AutoButtonColor = false
RangeButton.Active = true
RangeButton.Selectable = true
RangeButton.ZIndex = 12
RangeButton.Parent = AimPage

local RangeCorner = Instance.new("UICorner")
RangeCorner.CornerRadius = UDim.new(0, 9)
RangeCorner.Parent = RangeButton

styleButton(RangeButton)

local function refreshRange()
	RangeButton.Text =
		"AIM RANGE:  "
		.. tostring(Settings.AimRange)
		.. " STUDS"
end

RangeButton.Activated:Connect(function()
	Settings.AimRange += 50

	if Settings.AimRange > 1000 then
		Settings.AimRange = 50
	end

	refreshRange()
end)

refreshRange()

--==================================================
-- AIM FOV
--==================================================

local FOVButton = Instance.new("TextButton")
FOVButton.Size = UDim2.new(1, -16, 0, 40)
FOVButton.Position = UDim2.fromOffset(8, 393)
FOVButton.BackgroundColor3 = COLORS.Card
FOVButton.BorderSizePixel = 0
FOVButton.TextColor3 = COLORS.White
FOVButton.TextSize = 9
FOVButton.Font = Enum.Font.GothamBold
FOVButton.AutoButtonColor = false
FOVButton.Active = true
FOVButton.Selectable = true
FOVButton.ZIndex = 12
FOVButton.Parent = AimPage

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(0, 9)
FOVCorner.Parent = FOVButton

styleButton(FOVButton)

local function refreshFOV()
	FOVButton.Text =
		"AIM FOV:  "
		.. tostring(Settings.AimFOV)
		.. " PX"

	AimFOVCircle.Size =
		UDim2.fromOffset(
			Settings.AimFOV * 2,
			Settings.AimFOV * 2
		)
end

FOVButton.Activated:Connect(function()
	Settings.AimFOV += 25

	if Settings.AimFOV > 300 then
		Settings.AimFOV = 50
	end

	refreshFOV()
end)

refreshFOV()

--==================================================
-- SMOOTHNESS
--==================================================

local SmoothButton = Instance.new("TextButton")
SmoothButton.Size = UDim2.new(1, -16, 0, 40)
SmoothButton.Position = UDim2.fromOffset(8, 438)
SmoothButton.BackgroundColor3 = COLORS.Card
SmoothButton.BorderSizePixel = 0
SmoothButton.TextColor3 = COLORS.White
SmoothButton.TextSize = 9
SmoothButton.Font = Enum.Font.GothamBold
SmoothButton.AutoButtonColor = false
SmoothButton.Active = true
SmoothButton.Selectable = true
SmoothButton.ZIndex = 12
SmoothButton.Parent = AimPage

local SmoothCorner = Instance.new("UICorner")
SmoothCorner.CornerRadius = UDim.new(0, 9)
SmoothCorner.Parent = SmoothButton

styleButton(SmoothButton)

local function refreshSmooth()
	if Settings.InstantAim then
		SmoothButton.Text = "AIM SMOOTHNESS:  INSTANT"
	else
		SmoothButton.Text =
			"AIM SMOOTHNESS:  "
			.. string.format("%.2f", Settings.AimSmoothness)
	end
end

SmoothButton.Activated:Connect(function()
	Settings.AimSmoothness += 0.05

	if Settings.AimSmoothness > 0.8 then
		Settings.AimSmoothness = 0.1
	end

	Settings.AimSmoothness =
		math.floor(Settings.AimSmoothness * 100 + 0.5) / 100

	refreshSmooth()
end)

refreshSmooth()

--==================================================
-- DEBUG PAGE
--==================================================

createPageHeader(
	DebugPage,
	"DEBUG",
	"Live development diagnostics"
)

local DebugOverlayToggle = createToggle(
	DebugPage,
	52,
	"DEBUG OVERLAY",
	"Show live development information",
	function()
		return Settings.DebugOverlay
	end,
	function(value)
		Settings.DebugOverlay = value
	end
)

local TargetDebugToggle = createToggle(
	DebugPage,
	111,
	"TARGET DEBUG",
	"Display active target information",
	function()
		return Settings.TargetDebug
	end,
	function(value)
		Settings.TargetDebug = value
	end
)

local PerformanceDebugToggle = createToggle(
	DebugPage,
	170,
	"PERFORMANCE DEBUG",
	"Monitor client FPS and performance",
	function()
		return Settings.PerformanceDebug
	end,
	function(value)
		Settings.PerformanceDebug = value
	end
)

local DebugInfo = Instance.new("TextLabel")
DebugInfo.BackgroundColor3 = COLORS.Panel2
DebugInfo.BorderSizePixel = 0
DebugInfo.Position = UDim2.fromOffset(8, 230)
DebugInfo.Size = UDim2.new(1, -16, 0, 105)
DebugInfo.Text = ""
DebugInfo.TextColor3 = COLORS.Gray
DebugInfo.TextSize = 9
DebugInfo.Font = Enum.Font.Code
DebugInfo.TextXAlignment = Enum.TextXAlignment.Left
DebugInfo.TextYAlignment = Enum.TextYAlignment.Top
DebugInfo.ZIndex = 12
DebugInfo.Parent = DebugPage

local DebugInfoCorner = Instance.new("UICorner")
DebugInfoCorner.CornerRadius = UDim.new(0, 10)
DebugInfoCorner.Parent = DebugInfo

local DebugInfoPadding = Instance.new("UIPadding")
DebugInfoPadding.PaddingLeft = UDim.new(0, 11)
DebugInfoPadding.PaddingTop = UDim.new(0, 9)
DebugInfoPadding.Parent = DebugInfo

--==================================================
-- DEBUG TOOLS WINDOW
--==================================================

local function createDebugToolButton(
	parent,
	y,
	title,
	description,
	callback
)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -16, 0, 50)
	button.Position = UDim2.fromOffset(8, y)
	button.BackgroundColor3 = COLORS.Card
	button.BorderSizePixel = 0
	button.Text = ""
	button.AutoButtonColor = false
	button.Active = true
	button.Selectable = true
	button.ZIndex = 42
	button.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 9)
	corner.Parent = button

	local titleLabel = Instance.new("TextLabel")
	titleLabel.BackgroundTransparency = 1
	titleLabel.Position = UDim2.fromOffset(11, 6)
	titleLabel.Size = UDim2.new(1, -25, 0, 18)
	titleLabel.Text = title
	titleLabel.TextColor3 = COLORS.White
	titleLabel.TextSize = 9
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.ZIndex = 43
	titleLabel.Parent = button

	local descLabel = Instance.new("TextLabel")
	descLabel.BackgroundTransparency = 1
	descLabel.Position = UDim2.fromOffset(11, 25)
	descLabel.Size = UDim2.new(1, -25, 0, 16)
	descLabel.Text = description
	descLabel.TextColor3 = COLORS.Gray
	descLabel.TextSize = 7
	descLabel.Font = Enum.Font.Gotham
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.ZIndex = 43
	descLabel.Parent = button

	styleButton(button)

	button.Activated:Connect(callback)

	return button
end

local function createDebugToolWindow()
	if DebugToolWindow and DebugToolWindow.Parent then
		return
	end

	DebugToolWindow = Instance.new("Frame")
	DebugToolWindow.Name = "DebugToolWindow"
	DebugToolWindow.AnchorPoint = Vector2.new(0.5, 0.5)
	DebugToolWindow.Position = UDim2.fromScale(0.5, 0.5)
	DebugToolWindow.Size = UDim2.new(0.88, 0, 0.78, 0)
	DebugToolWindow.BackgroundColor3 = COLORS.Background
	DebugToolWindow.BorderSizePixel = 0
	DebugToolWindow.ZIndex = 40
	DebugToolWindow.Visible = false
	DebugToolWindow.Parent = ScreenGui

	local sizeConstraint = Instance.new("UISizeConstraint")
	sizeConstraint.MinSize = Vector2.new(290, 300)
	sizeConstraint.MaxSize = Vector2.new(560, 430)
	sizeConstraint.Parent = DebugToolWindow

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 14)
	corner.Parent = DebugToolWindow

	local stroke = Instance.new("UIStroke")
	stroke.Color = COLORS.Pink
	stroke.Thickness = 1.5
	stroke.Transparency = 0.15
	stroke.Parent = DebugToolWindow

	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, 0, 0, 54)
	header.BackgroundColor3 = COLORS.Panel
	header.BorderSizePixel = 0
	header.Active = true
	header.ZIndex = 41
	header.Parent = DebugToolWindow

	local headerCorner = Instance.new("UICorner")
	headerCorner.CornerRadius = UDim.new(0, 14)
	headerCorner.Parent = header

	DebugToolTitle = Instance.new("TextLabel")
	DebugToolTitle.BackgroundTransparency = 1
	DebugToolTitle.Position = UDim2.fromOffset(14, 7)
	DebugToolTitle.Size = UDim2.new(1, -105, 0, 21)
	DebugToolTitle.Text = "DEBUG TOOL"
	DebugToolTitle.TextColor3 = COLORS.White
	DebugToolTitle.TextSize = 14
	DebugToolTitle.Font = Enum.Font.GothamBold
	DebugToolTitle.TextXAlignment = Enum.TextXAlignment.Left
	DebugToolTitle.ZIndex = 43
	DebugToolTitle.Parent = header

	DebugToolSubtitle = Instance.new("TextLabel")
	DebugToolSubtitle.BackgroundTransparency = 1
	DebugToolSubtitle.Position = UDim2.fromOffset(15, 29)
	DebugToolSubtitle.Size = UDim2.new(1, -105, 0, 15)
	DebugToolSubtitle.Text = "Inspector"
	DebugToolSubtitle.TextColor3 = COLORS.Pink
	DebugToolSubtitle.TextSize = 7
	DebugToolSubtitle.Font = Enum.Font.GothamBold
	DebugToolSubtitle.TextXAlignment = Enum.TextXAlignment.Left
	DebugToolSubtitle.ZIndex = 43
	DebugToolSubtitle.Parent = header

	local close = Instance.new("TextButton")
	close.Size = UDim2.fromOffset(31, 31)
	close.Position = UDim2.new(1, -40, 0, 11)
	close.BackgroundColor3 = COLORS.Card
	close.BorderSizePixel = 0
	close.Text = "×"
	close.TextColor3 = COLORS.Pink
	close.TextSize = 20
	close.Font = Enum.Font.GothamBold
	close.AutoButtonColor = false
	close.Active = true
	close.Selectable = true
	close.ZIndex = 44
	close.Parent = header

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 9)
	closeCorner.Parent = close

	close.Activated:Connect(function()
		DebugToolWindow.Visible = false
	end)

	DebugToolContent = Instance.new("ScrollingFrame")
	DebugToolContent.Name = "Content"
	DebugToolContent.Position = UDim2.fromOffset(8, 63)
	DebugToolContent.Size = UDim2.new(1, -16, 1, -71)
	DebugToolContent.BackgroundTransparency = 1
	DebugToolContent.BorderSizePixel = 0
	DebugToolContent.ScrollBarThickness = 3
	DebugToolContent.ScrollBarImageColor3 = COLORS.Pink
	DebugToolContent.ScrollBarImageTransparency = 0.25
	DebugToolContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
	DebugToolContent.CanvasSize = UDim2.new(0, 0, 0, 0)
	DebugToolContent.ScrollingDirection = Enum.ScrollingDirection.Y
	DebugToolContent.Active = true
	DebugToolContent.ZIndex = 41
	DebugToolContent.Parent = DebugToolWindow
end

createDebugToolWindow()

local function clearDebugToolContent()
	for _, child in ipairs(DebugToolContent:GetChildren()) do
		child:Destroy()
	end

	DebugToolContent.CanvasPosition = Vector2.new(0, 0)
end

local function openDebugTool(title, subtitle)
	createDebugToolWindow()

	DebugToolTitle.Text = title
	DebugToolSubtitle.Text = subtitle

	clearDebugToolContent()

	DebugToolWindow.Visible = true
	DebugToolWindow.Position = UDim2.fromScale(0.5, 0.52)

	if Settings.UIAnimations then
		TweenService:Create(
			DebugToolWindow,
			TweenInfo.new(
				0.18,
				Enum.EasingStyle.Quart,
				Enum.EasingDirection.Out
			),
			{
				Position = UDim2.fromScale(0.5, 0.5)
			}
		):Play()
	else
		DebugToolWindow.Position = UDim2.fromScale(0.5, 0.5)
	end
end

local function createToolSection(parent, y, title)
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Position = UDim2.fromOffset(11, y)
	label.Size = UDim2.new(1, -22, 0, 18)
	label.Text = title
	label.TextColor3 = COLORS.Pink
	label.TextSize = 8
	label.Font = Enum.Font.GothamBold
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.ZIndex = 43
	label.Parent = parent

	return label
end

local function createToolValue(parent, y, title, value, height)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -16, 0, height or 36)
	frame.Position = UDim2.fromOffset(8, y)
	frame.BackgroundColor3 = COLORS.Panel2
	frame.BorderSizePixel = 0
	frame.ZIndex = 42
	frame.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = frame

	local titleLabel = Instance.new("TextLabel")
	titleLabel.BackgroundTransparency = 1
	titleLabel.Position = UDim2.fromOffset(10, 5)
	titleLabel.Size = UDim2.new(0.32, 0, 1, -10)
	titleLabel.Text = title
	titleLabel.TextColor3 = COLORS.Gray
	titleLabel.TextSize = 7
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.ZIndex = 43
	titleLabel.Parent = frame

	local valueLabel = Instance.new("TextLabel")
	valueLabel.BackgroundTransparency = 1
	valueLabel.Position = UDim2.new(0.32, 6, 0, 5)
	valueLabel.Size = UDim2.new(0.68, -16, 1, -10)
	valueLabel.Text = tostring(value)
	valueLabel.TextColor3 = COLORS.White
	valueLabel.TextSize = 7.5
	valueLabel.Font = Enum.Font.Code
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.TextYAlignment = Enum.TextYAlignment.Center
	valueLabel.TextWrapped = true
	valueLabel.ZIndex = 43
	valueLabel.Parent = frame

	return frame
end

local function createToolText(parent, y, text, height)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -16, 0, height or 45)
	label.Position = UDim2.fromOffset(8, y)
	label.BackgroundColor3 = COLORS.Panel2
	label.BorderSizePixel = 0
	label.Text = text
	label.TextColor3 = COLORS.Gray
	label.TextSize = 7.5
	label.Font = Enum.Font.Code
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Top
	label.TextWrapped = true
	label.ZIndex = 42
	label.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = label

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 10)
	padding.PaddingRight = UDim.new(0, 10)
	padding.PaddingTop = UDim.new(0, 8)
	padding.PaddingBottom = UDim.new(0, 8)
	padding.Parent = label

	return label
end

local function createToolAction(parent, y, text, callback)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -16, 0, 38)
	button.Position = UDim2.fromOffset(8, y)
	button.BackgroundColor3 = COLORS.Card
	button.BorderSizePixel = 0
	button.Text = text
	button.TextColor3 = COLORS.White
	button.TextSize = 8
	button.Font = Enum.Font.GothamBold
	button.AutoButtonColor = false
	button.Active = true
	button.Selectable = true
	button.ZIndex = 42
	button.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = button

	styleButton(button)

	button.Activated:Connect(callback)

	return button
end

--==================================================
-- DEBUG TARGET HELPERS
--==================================================

local function getDebugPlayerList()
	local list = {}

	table.insert(list, LocalPlayer)

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			table.insert(list, player)
		end
	end

	return list
end

local function getDebugPlayer()
	if SelectedDebugPlayer and SelectedDebugPlayer.Parent then
		return SelectedDebugPlayer
	end

	return LocalPlayer
end

local function cycleDebugPlayer()
	local list = getDebugPlayerList()

	if #list == 0 then
		SelectedDebugPlayer = LocalPlayer
		return
	end

	local currentIndex = 1

	for index, player in ipairs(list) do
		if player == SelectedDebugPlayer then
			currentIndex = index
			break
		end
	end

	currentIndex += 1

	if currentIndex > #list then
		currentIndex = 1
	end

	SelectedDebugPlayer = list[currentIndex]
end

local function selectAimbotTarget()
	if CurrentTarget and CurrentTarget.Parent then
		SelectedDebugPlayer = CurrentTarget
		return
	end

	SelectedDebugPlayer = LocalPlayer
end

local function getPlayerCharacter(player)
	if not player then
		return nil
	end

	return player.Character
end

local function getCharacterDescription(character)
	if not character then
		return "No character"
	end

	local humanoid = getHumanoid(character)
	local root = getRoot(character)

	local lines = {}

	table.insert(lines, "MODEL: " .. character.Name)
	table.insert(lines, "CLASS: " .. character.ClassName)
	table.insert(lines, "ARCHIVABLE: " .. tostring(character.Archivable))
	table.insert(lines, "CHILDREN: " .. tostring(#character:GetChildren()))

	if humanoid then
		table.insert(lines, "HEALTH: " .. string.format("%.1f", humanoid.Health))
		table.insert(lines, "MAX HEALTH: " .. string.format("%.1f", humanoid.MaxHealth))
		table.insert(lines, "WALKSPEED: " .. string.format("%.1f", humanoid.WalkSpeed))
		table.insert(lines, "JUMP POWER: " .. string.format("%.1f", humanoid.JumpPower))
		table.insert(lines, "STATE: " .. tostring(humanoid:GetState()))
	end

	if root then
		table.insert(lines, "POSITION: " .. tostring(root.Position))
		table.insert(lines, "VELOCITY: " .. tostring(root.AssemblyLinearVelocity))
	end

	local parts = 0
	local accessories = 0
	local tools = 0

	for _, object in ipairs(character:GetDescendants()) do
		if object:IsA("BasePart") then
			parts += 1
		elseif object:IsA("Accessory") then
			accessories += 1
		elseif object:IsA("Tool") then
			tools += 1
		end
	end

	table.insert(lines, "BASEPARTS: " .. tostring(parts))
	table.insert(lines, "ACCESSORIES: " .. tostring(accessories))
	table.insert(lines, "TOOLS: " .. tostring(tools))

	return table.concat(lines, "\n")
end

--==================================================
-- CHARACTER INSPECTOR
--==================================================

local function showCharacterInspector()
	openDebugTool(
		"CHARACTER INSPECTOR",
		"Character and humanoid diagnostics"
	)

	local content = DebugToolContent
	local player = getDebugPlayer()
	local character = getPlayerCharacter(player)

	createToolSection(content, 8, "SELECTED PLAYER")

	createToolValue(
		content,
		29,
		"PLAYER",
		player and player.Name or "None",
		36
	)

	createToolAction(
		content,
		73,
		"NEXT PLAYER",
		function()
			cycleDebugPlayer()
			showCharacterInspector()
		end
	)

	createToolAction(
		content,
		117,
		"USE CURRENT AIM TARGET",
		function()
			selectAimbotTarget()
			showCharacterInspector()
		end
	)

	createToolSection(content, 167, "CHARACTER DATA")

	createToolText(
		content,
		188,
		getCharacterDescription(character),
		190
	)
end

--==================================================
-- OBJECT INSPECTOR
--==================================================

local function getMouseRayObject()
	Camera = workspace.CurrentCamera

	if not Camera then
		return nil
	end

	local mousePosition = UserInputService:GetMouseLocation()

	local ray = Camera:ViewportPointToRay(
		mousePosition.X,
		mousePosition.Y
	)

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {
		LocalPlayer.Character
	}

	local result = workspace:Raycast(
		ray.Origin,
		ray.Direction * 2000,
		params
	)

	if result then
		return result.Instance
	end

	return nil
end

local function getObjectPath(object)
	if not object then
		return "None"
	end

	local parts = {}
	local current = object

	while current and current ~= game do
		table.insert(parts, 1, current.Name)
		current = current.Parent
	end

	return table.concat(parts, ".")
end

local function getObjectInspectorText(object)
	if not object then
		return "No object selected."
	end

	local lines = {}

	table.insert(lines, "NAME: " .. object.Name)
	table.insert(lines, "CLASS: " .. object.ClassName)
	table.insert(lines, "PATH: " .. getObjectPath(object))
	table.insert(lines, "PARENT: " .. (object.Parent and object.Parent.Name or "None"))
	table.insert(lines, "ARCHIVABLE: " .. tostring(object.Archivable))
	table.insert(lines, "CHILDREN: " .. tostring(#object:GetChildren()))

	if object:IsA("BasePart") then
		table.insert(lines, "POSITION: " .. tostring(object.Position))
		table.insert(lines, "SIZE: " .. tostring(object.Size))
		table.insert(lines, "ANCHOR: " .. tostring(object.Anchored))
		table.insert(lines, "CAN COLLIDE: " .. tostring(object.CanCollide))
		table.insert(lines, "TRANSPARENCY: " .. tostring(object.Transparency))
		table.insert(lines, "MATERIAL: " .. tostring(object.Material))
	elseif object:IsA("ValueBase") then
		table.insert(lines, "VALUE: " .. tostring(object.Value))
	elseif object:IsA("Humanoid") then
		table.insert(lines, "HEALTH: " .. tostring(object.Health))
		table.insert(lines, "MAX HEALTH: " .. tostring(object.MaxHealth))
	elseif object:IsA("Tool") then
		table.insert(lines, "EQUIPPED: " .. tostring(object.Parent == LocalPlayer.Character))
	elseif object:IsA("RemoteEvent") then
		table.insert(lines, "REMOTE TYPE: RemoteEvent")
	elseif object:IsA("RemoteFunction") then
		table.insert(lines, "REMOTE TYPE: RemoteFunction")
	end

	local attributes = object:GetAttributes()
	local attributeCount = 0

	for _ in pairs(attributes) do
		attributeCount += 1
	end

	table.insert(lines, "ATTRIBUTES: " .. tostring(attributeCount))

	return table.concat(lines, "\n")
end

local function showObjectInspector()
	openDebugTool(
		"OBJECT INSPECTOR",
		"Inspect object under cursor"
	)

	local content = DebugToolContent

	createToolAction(
		content,
		8,
		"INSPECT OBJECT UNDER CURSOR",
		function()
			SelectedDebugObject = getMouseRayObject()
			showObjectInspector()
		end
	)

	if not SelectedDebugObject or not SelectedDebugObject.Parent then
		SelectedDebugObject = nil
	end

	createToolSection(content, 57, "OBJECT DATA")

	createToolText(
		content,
		78,
		getObjectInspectorText(SelectedDebugObject),
		230
	)
end

--==================================================
-- ATTRIBUTE VIEWER
--==================================================

local function getAttributesText(instance)
	if not instance then
		return "No instance selected."
	end

	local attributes = instance:GetAttributes()
	local keys = {}

	for key in pairs(attributes) do
		table.insert(keys, key)
	end

	table.sort(keys)

	if #keys == 0 then
		return "No attributes found."
	end

	local lines = {}

	for _, key in ipairs(keys) do
		table.insert(
			lines,
			key .. " = " .. tostring(attributes[key])
		)
	end

	return table.concat(lines, "\n")
end

local function showAttributeViewer()
	openDebugTool(
		"ATTRIBUTE VIEWER",
		"Inspect instance attributes"
	)

	local content = DebugToolContent
	local player = getDebugPlayer()
	local character = getPlayerCharacter(player)

	createToolSection(content, 8, "SOURCE")

	createToolValue(
		content,
		29,
		"PLAYER",
		player and player.Name or "None",
		36
	)

	createToolAction(
		content,
		73,
		"NEXT PLAYER",
		function()
			cycleDebugPlayer()
			showAttributeViewer()
		end
	)

	createToolAction(
		content,
		117,
		"USE CURRENT AIM TARGET",
		function()
			selectAimbotTarget()
			showAttributeViewer()
		end
	)

	createToolSection(content, 167, "CHARACTER ATTRIBUTES")

	createToolText(
		content,
		188,
		getAttributesText(character),
		180
	)
end

--==================================================
-- TAG VIEWER
--==================================================

local function getTagsText(instance)
	if not instance then
		return "No instance selected."
	end

	local tags = CollectionService:GetTags(instance)

	if #tags == 0 then
		return "No CollectionService tags."
	end

	table.sort(tags)

	local lines = {}

	for _, tag in ipairs(tags) do
		table.insert(lines, "• " .. tag)
	end

	return table.concat(lines, "\n")
end

local function showTagViewer()
	openDebugTool(
		"TAG VIEWER",
		"Inspect CollectionService tags"
	)

	local content = DebugToolContent
	local player = getDebugPlayer()
	local character = getPlayerCharacter(player)

	createToolSection(content, 8, "SOURCE")

	createToolValue(
		content,
		29,
		"PLAYER",
		player and player.Name or "None",
		36
	)

	createToolAction(
		content,
		73,
		"NEXT PLAYER",
		function()
			cycleDebugPlayer()
			showTagViewer()
		end
	)

	createToolAction(
		content,
		117,
		"USE CURRENT AIM TARGET",
		function()
			selectAimbotTarget()
			showTagViewer()
		end
	)

	createToolSection(content, 167, "TAGS")

	createToolText(
		content,
		188,
		getTagsText(character),
		150
	)
end

--==================================================
-- TOOL INSPECTOR
--==================================================

local function getToolText(player)
	if not player then
		return "No player selected."
	end

	local lines = {}

	local backpack = player:FindFirstChildOfClass("Backpack")
	local character = player.Character

	table.insert(lines, "PLAYER: " .. player.Name)
	table.insert(lines, "")

	local found = {}

	if character then
		for _, object in ipairs(character:GetChildren()) do
			if object:IsA("Tool") then
				table.insert(found, object.Name .. " [EQUIPPED]")
			end
		end
	end

	if backpack then
		for _, object in ipairs(backpack:GetChildren()) do
			if object:IsA("Tool") then
				table.insert(found, object.Name .. " [BACKPACK]")
			end
		end
	end

	if #found == 0 then
		table.insert(lines, "No tools found.")
	else
		for _, name in ipairs(found) do
			table.insert(lines, "• " .. name)
		end
	end

	return table.concat(lines, "\n")
end

local function showToolInspector()
	openDebugTool(
		"TOOL INSPECTOR",
		"Inspect player tools"
	)

	local content = DebugToolContent
	local player = getDebugPlayer()

	createToolSection(content, 8, "SELECTED PLAYER")

	createToolValue(
		content,
		29,
		"PLAYER",
		player and player.Name or "None",
		36
	)

	createToolAction(
		content,
		73,
		"NEXT PLAYER",
		function()
			cycleDebugPlayer()
			showToolInspector()
		end
	)

	createToolAction(
		content,
		117,
		"USE CURRENT AIM TARGET",
		function()
			selectAimbotTarget()
			showToolInspector()
		end
	)

	createToolSection(content, 167, "TOOLS")

	createToolText(
		content,
		188,
		getToolText(player),
		160
	)
end

--==================================================
-- REMOTE TEST PANEL
--==================================================

local function rebuildRemoteList()
	table.clear(RemoteList)

	for _, object in ipairs(ReplicatedStorage:GetDescendants()) do
		if object:IsA("RemoteEvent")
			or object:IsA("RemoteFunction") then

			table.insert(RemoteList, object)
		end
	end

	table.sort(
		RemoteList,
		function(a, b)
			return getObjectPath(a) < getObjectPath(b)
		end
	)

	if #RemoteList == 0 then
		SelectedRemoteIndex = 1
	elseif SelectedRemoteIndex > #RemoteList then
		SelectedRemoteIndex = #RemoteList
	end
end

local function getSelectedRemote()
	return RemoteList[SelectedRemoteIndex]
end

local function showRemoteTestPanel()
	rebuildRemoteList()

	openDebugTool(
		"REMOTE TEST PANEL",
		"Inspect ReplicatedStorage remotes"
	)

	local content = DebugToolContent
	local remote = getSelectedRemote()

	createToolAction(
		content,
		8,
		"REFRESH REMOTE LIST",
		function()
			rebuildRemoteList()
			showRemoteTestPanel()
		end
	)

	createToolSection(content, 57, "SELECTED REMOTE")

	createToolValue(
		content,
		78,
		"COUNT",
		#RemoteList,
		36
	)

	createToolValue(
		content,
		122,
		"REMOTE",
		remote and remote.Name or "None",
		36
	)

	createToolValue(
		content,
		166,
		"TYPE",
		remote and remote.ClassName or "None",
		36
	)

	createToolText(
		content,
		210,
		remote and getObjectPath(remote) or "No RemoteEvent or RemoteFunction found in ReplicatedStorage.",
		55
	)

	createToolAction(
		content,
		275,
		"NEXT REMOTE",
		function()
			if #RemoteList > 0 then
				SelectedRemoteIndex += 1

				if SelectedRemoteIndex > #RemoteList then
					SelectedRemoteIndex = 1
				end
			end

			showRemoteTestPanel()
		end
	)

	if remote and remote:IsA("RemoteEvent") then
		createToolAction(
			content,
			319,
			"FIRE EVENT — NO ARGS",
			function()
				local success, errorMessage = pcall(function()
					remote:FireServer()
				end)

				table.insert(
					DebugConsoleMessages,
					1,
					"[REMOTE EVENT] "
						.. remote.Name
						.. " -> "
						.. (success and "FIRED" or tostring(errorMessage))
				)

				while #DebugConsoleMessages > 80 do
					table.remove(DebugConsoleMessages)
				end
			end
		)
	elseif remote and remote:IsA("RemoteFunction") then
		createToolAction(
			content,
			319,
			"INVOKE FUNCTION — NO ARGS",
			function()
				task.spawn(function()
					local success, result = pcall(function()
						return remote:InvokeServer()
					end)

					local resultText = success
						and tostring(result)
						or tostring(result)

					table.insert(
						DebugConsoleMessages,
						1,
						"[REMOTE FUNCTION] "
							.. remote.Name
							.. " -> "
							.. resultText
					)

					while #DebugConsoleMessages > 80 do
						table.remove(DebugConsoleMessages)
					end
				end)
			end
		)
	end
end

--==================================================
-- PERFORMANCE MONITOR
--==================================================

local function getPing()
	local success, value = pcall(function()
		local network = Stats:FindFirstChild("Network")

		if not network then
			return 0
		end

		local serverStats = network:FindFirstChild("ServerStatsItem")

		if not serverStats then
			return 0
		end

		local ping = serverStats:FindFirstChild("Data Ping")

		if ping then
			return ping:GetValue()
		end

		return 0
	end)

	if success and value then
		return value
	end

	return 0
end

local function getInstanceCount()
	local count = 0

	for _, object in ipairs(game:GetDescendants()) do
		count += 1
	end

	return count
end

local function showPerformanceMonitor()
	openDebugTool(
		"PERFORMANCE MONITOR",
		"Live client performance"
	)

	local content = DebugToolContent

	createToolSection(content, 8, "LIVE METRICS")

	local fpsValue = createToolValue(
		content,
		29,
		"FPS",
		math.floor(LastFPS),
		38
	)

	local memoryValue = createToolValue(
		content,
		73,
		"MEMORY",
		string.format("%.0f MB", getMemoryUsage()),
		38
	)

	local pingValue = createToolValue(
		content,
		117,
		"PING",
		string.format("%.0f ms", getPing()),
		38
	)

	local playerValue = createToolValue(
		content,
		161,
		"PLAYERS",
		#Players:GetPlayers(),
		38
	)

	local npcValue = createToolValue(
		content,
		205,
		"NPC CACHE",
		(function()
			local count = 0

			for npc in pairs(NPCs) do
				if npc.Parent and isNPC(npc) then
					count += 1
				end
			end

			return count
		end)(),
		38
	)

	local instanceValue = createToolValue(
		content,
		249,
		"INSTANCES",
		getInstanceCount(),
		38
	)

	createToolAction(
		content,
		295,
		"REFRESH",
		function()
			showPerformanceMonitor()
		end
	)

	task.spawn(function()
		while DebugToolWindow
			and DebugToolWindow.Visible
			and DebugToolTitle
			and DebugToolTitle.Text == "PERFORMANCE MONITOR" do

			task.wait(0.5)

			if not DebugToolWindow.Visible then
				break
			end

			if fpsValue and fpsValue.Parent then
				local valueLabel = fpsValue:FindFirstChildWhichIsA("TextLabel")

				if valueLabel then
					valueLabel.Text = tostring(math.floor(LastFPS))
				end
			end

			if memoryValue and memoryValue.Parent then
				local labels = memoryValue:GetChildren()

				for _, object in ipairs(labels) do
					if object:IsA("TextLabel")
						and object.Text ~= "MEMORY" then

						object.Text =
							string.format(
								"%.0f MB",
								getMemoryUsage()
							)
					end
				end
			end

			if pingValue and pingValue.Parent then
				for _, object in ipairs(pingValue:GetChildren()) do
					if object:IsA("TextLabel")
						and object.Text ~= "PING" then

						object.Text =
							string.format(
								"%.0f ms",
								getPing()
							)
					end
				end
			end

			if playerValue and playerValue.Parent then
				for _, object in ipairs(playerValue:GetChildren()) do
					if object:IsA("TextLabel")
						and object.Text ~= "PLAYERS" then

						object.Text =
							tostring(#Players:GetPlayers())
					end
				end
			end
		end
	end)
end

--==================================================
-- DEBUG CONSOLE
--==================================================

local function addConsoleMessage(message)
	table.insert(
		DebugConsoleMessages,
		1,
		message
	)

	while #DebugConsoleMessages > 100 do
		table.remove(DebugConsoleMessages)
	end
end

DebugConsoleConnection = LogService.MessageOut:Connect(
	function(message, messageType)
		local typeName = tostring(messageType)

		addConsoleMessage(
			"["
				.. typeName
				.. "] "
				.. message
		)
	end
)

table.insert(
	Connections,
	DebugConsoleConnection
)

local function getConsoleText()
	if #DebugConsoleMessages == 0 then
		return "Debug console is empty."
	end

	return table.concat(
		DebugConsoleMessages,
		"\n"
	)
end

local function showDebugConsole()
	openDebugTool(
		"DEBUG CONSOLE",
		"Client output and runtime messages"
	)

	local content = DebugToolContent

	createToolAction(
		content,
		8,
		"CLEAR CONSOLE",
		function()
			table.clear(DebugConsoleMessages)
			showDebugConsole()
		end
	)

	createToolSection(content, 57, "OUTPUT")

	createToolText(
		content,
		78,
		getConsoleText(),
		270
	)
end

--==================================================
-- PLAYER CLOTHING DEBUG
--==================================================

local function getClothingText(player)
	if not player then
		return "No player selected."
	end

	local character = player.Character

	if not character then
		return "Character is not loaded."
	end

	local lines = {}

	table.insert(lines, "PLAYER: " .. player.Name)
	table.insert(lines, "")

	local shirt = character:FindFirstChildOfClass("Shirt")
	local pants = character:FindFirstChildOfClass("Pants")
	local graphic = character:FindFirstChildOfClass("ShirtGraphic")

	table.insert(
		lines,
		"SHIRT: "
			.. (
				shirt
				and tostring(shirt.ShirtTemplate)
				or "None"
			)
	)

	table.insert(
		lines,
		"PANTS: "
			.. (
				pants
				and tostring(pants.PantsTemplate)
				or "None"
			)
	)

	table.insert(
		lines,
		"SHIRT GRAPHIC: "
			.. (
				graphic
				and tostring(graphic.Graphic)
				or "None"
			)
	)

	table.insert(lines, "")
	table.insert(lines, "ACCESSORIES:")

	local accessories = {}

	for _, object in ipairs(character:GetChildren()) do
		if object:IsA("Accessory") then
			local handle = object:FindFirstChild("Handle")

			local accessoryType = "Unknown"

			if handle then
				local attachment = handle:FindFirstChildWhichIsA("Attachment")

				if attachment then
					accessoryType = attachment.Name
				end
			end

			table.insert(
				accessories,
				object.Name
					.. " ["
					.. accessoryType
					.. "]"
			)
		end
	end

	if #accessories == 0 then
		table.insert(lines, "None")
	else
		for _, accessory in ipairs(accessories) do
			table.insert(
				lines,
				"• " .. accessory
			)
		end
	end

	return table.concat(lines, "\n")
end

local function showPlayerClothingDebug()
	openDebugTool(
		"PLAYER CLOTHING DEBUG",
		"Inspect player's current clothing"
	)

	local content = DebugToolContent
	local player = getDebugPlayer()

	createToolSection(content, 8, "SELECTED PLAYER")

	createToolValue(
		content,
		29,
		"PLAYER",
		player and player.Name or "None",
		36
	)

	createToolAction(
		content,
		73,
		"NEXT PLAYER",
		function()
			cycleDebugPlayer()
			showPlayerClothingDebug()
		end
	)

	createToolAction(
		content,
		117,
		"USE CURRENT AIM TARGET",
		function()
			selectAimbotTarget()
			showPlayerClothingDebug()
		end
	)

	createToolSection(content, 167, "CLOTHING")

	createToolText(
		content,
		188,
		getClothingText(player),
		230
	)
end

--==================================================
-- DEBUG TOOLS MENU
--==================================================

createToolSection(DebugPage, 355, "DEBUG TOOLS")

createDebugToolButton(
	DebugPage,
	377,
	"CHARACTER INSPECTOR",
	"Inspect humanoid, character parts and movement state",
	showCharacterInspector
)

createDebugToolButton(
	DebugPage,
	433,
	"OBJECT INSPECTOR",
	"Inspect the object under the mouse or touch position",
	showObjectInspector
)

createDebugToolButton(
	DebugPage,
	489,
	"ATTRIBUTE VIEWER",
	"View attributes attached to the selected character",
	showAttributeViewer
)

createDebugToolButton(
	DebugPage,
	545,
	"TAG VIEWER",
	"View CollectionService tags on the selected character",
	showTagViewer
)

createDebugToolButton(
	DebugPage,
	601,
	"TOOL INSPECTOR",
	"Inspect equipped and backpack tools",
	showToolInspector
)

createDebugToolButton(
	DebugPage,
	657,
	"REMOTE TEST PANEL",
	"Inspect and test ReplicatedStorage remotes",
	showRemoteTestPanel
)

createDebugToolButton(
	DebugPage,
	713,
	"PERFORMANCE MONITOR",
	"Live FPS, memory, ping and instance statistics",
	showPerformanceMonitor
)

createDebugToolButton(
	DebugPage,
	769,
	"DEBUG CONSOLE",
	"View client runtime output and messages",
	showDebugConsole
)

createDebugToolButton(
	DebugPage,
	825,
	"PLAYER CLOTHING DEBUG",
	"Inspect shirt, pants and accessories",
	showPlayerClothingDebug
)

--==================================================
-- MISC PAGE
--==================================================

createPageHeader(
	MiscPage,
	"MISC",
	"Additional administration utilities"
)

createToggle(
	MiscPage,
	52,
	"TARGET INFO",
	"Show detailed information about current target",
	function()
		return Settings.TargetInfo
	end,
	function(value)
		Settings.TargetInfo = value
	end
)

createToggle(
	MiscPage,
	111,
	"ESP DEBUG",
	"Inspect red Highlight objects",
	function()
		return Settings.EspDebug
	end,
	function(value)
		Settings.EspDebug = value
	end
)

createToggle(
	MiscPage,
	170,
	"NPC SCANNER",
	"Display cached NPC scanner information",
	function()
		return Settings.NpcScanner
	end,
	function(value)
		Settings.NpcScanner = value
	end
)

local RefreshNPCButton = Instance.new("TextButton")
RefreshNPCButton.Size = UDim2.new(1, -16, 0, 42)
RefreshNPCButton.Position = UDim2.fromOffset(8, 229)
RefreshNPCButton.BackgroundColor3 = COLORS.Card
RefreshNPCButton.BorderSizePixel = 0
RefreshNPCButton.Text = "REFRESH NPC CACHE"
RefreshNPCButton.TextColor3 = COLORS.White
RefreshNPCButton.TextSize = 9
RefreshNPCButton.Font = Enum.Font.GothamBold
RefreshNPCButton.AutoButtonColor = false
RefreshNPCButton.Active = true
RefreshNPCButton.Selectable = true
RefreshNPCButton.ZIndex = 12
RefreshNPCButton.Parent = MiscPage

local RefreshNPCCorner = Instance.new("UICorner")
RefreshNPCCorner.CornerRadius = UDim.new(0, 9)
RefreshNPCCorner.Parent = RefreshNPCButton

styleButton(RefreshNPCButton)

RefreshNPCButton.Activated:Connect(function()
	CurrentNpcTarget = nil
	rebuildNPCList()
end)

local MiscInfo = Instance.new("TextLabel")
MiscInfo.BackgroundColor3 = COLORS.Panel2
MiscInfo.BorderSizePixel = 0
MiscInfo.Position = UDim2.fromOffset(8, 280)
MiscInfo.Size = UDim2.new(1, -16, 0, 55)
MiscInfo.Text = ""
MiscInfo.TextColor3 = COLORS.Gray
MiscInfo.TextSize = 8
MiscInfo.Font = Enum.Font.Code
MiscInfo.TextXAlignment = Enum.TextXAlignment.Left
MiscInfo.TextYAlignment = Enum.TextYAlignment.Center
MiscInfo.ZIndex = 12
MiscInfo.Parent = MiscPage

local MiscInfoCorner = Instance.new("UICorner")
MiscInfoCorner.CornerRadius = UDim.new(0, 9)
MiscInfoCorner.Parent = MiscInfo

--==================================================
-- SETTINGS PAGE
--==================================================

createPageHeader(
	SettingsPage,
	"SETTINGS",
	"Panel and interface configuration"
)

createToggle(
	SettingsPage,
	52,
	"UI ANIMATIONS",
	"Enable page and button animations",
	function()
		return Settings.UIAnimations
	end,
	function(value)
		Settings.UIAnimations = value
	end
)

local CompactToggle = createToggle(
	SettingsPage,
	111,
	"COMPACT UI",
	"Use a smaller panel on PC",
	function()
		return Settings.CompactUI
	end,
	function(value)
		Settings.CompactUI = value
		updatePanelSize()
	end
)

local ResetPositionButton = Instance.new("TextButton")
ResetPositionButton.Size = UDim2.new(1, -16, 0, 42)
ResetPositionButton.Position = UDim2.fromOffset(8, 170)
ResetPositionButton.BackgroundColor3 = COLORS.Card
ResetPositionButton.BorderSizePixel = 0
ResetPositionButton.Text = "RESET UI POSITION"
ResetPositionButton.TextColor3 = COLORS.White
ResetPositionButton.TextSize = 9
ResetPositionButton.Font = Enum.Font.GothamBold
ResetPositionButton.AutoButtonColor = false
ResetPositionButton.Active = true
ResetPositionButton.Selectable = true
ResetPositionButton.ZIndex = 12
ResetPositionButton.Parent = SettingsPage

local ResetPositionCorner = Instance.new("UICorner")
ResetPositionCorner.CornerRadius = UDim.new(0, 9)
ResetPositionCorner.Parent = ResetPositionButton

styleButton(ResetPositionButton)

ResetPositionButton.Activated:Connect(function()
	Main.AnchorPoint = Vector2.new(0.5, 0.5)
	Main.Position = UDim2.fromScale(0.5, 0.5)
end)

local ResetSettingsButton = Instance.new("TextButton")
ResetSettingsButton.Size = UDim2.new(1, -16, 0, 42)
ResetSettingsButton.Position = UDim2.fromOffset(8, 221)
ResetSettingsButton.BackgroundColor3 = COLORS.Card
ResetSettingsButton.BorderSizePixel = 0
ResetSettingsButton.Text = "RESET ALL SETTINGS"
ResetSettingsButton.TextColor3 = COLORS.White
ResetSettingsButton.TextSize = 9
ResetSettingsButton.Font = Enum.Font.GothamBold
ResetSettingsButton.AutoButtonColor = false
ResetSettingsButton.Active = true
ResetSettingsButton.Selectable = true
ResetSettingsButton.ZIndex = 12
ResetSettingsButton.Parent = SettingsPage

local ResetSettingsCorner = Instance.new("UICorner")
ResetSettingsCorner.CornerRadius = UDim.new(0, 9)
ResetSettingsCorner.Parent = ResetSettingsButton

styleButton(ResetSettingsButton)

ResetSettingsButton.Activated:Connect(function()
	for key, value in pairs(DEFAULT_SETTINGS) do
		Settings[key] = value
	end

	CurrentTarget = nil
	CurrentNpcTarget = nil

	updatePanelSize()
	refreshAimPart()
	refreshRange()
	refreshFOV()
	refreshSmooth()

	if DebugOverlayToggle then
		DebugOverlayToggle.Refresh()
	end

	if TargetDebugToggle then
		TargetDebugToggle.Refresh()
	end

	if PerformanceDebugToggle then
		PerformanceDebugToggle.Refresh()
	end

	CompactToggle.Refresh()
end)

local SettingsInfo = Instance.new("TextLabel")
SettingsInfo.BackgroundTransparency = 1
SettingsInfo.Position = UDim2.fromOffset(10, 280)
SettingsInfo.Size = UDim2.new(1, -20, 0, 60)
SettingsInfo.Text =
	"Interface settings are local to this panel.\n"
	.. "Combat settings are reset with RESET ALL SETTINGS."

SettingsInfo.TextColor3 = COLORS.Gray
SettingsInfo.TextSize = 8
SettingsInfo.Font = Enum.Font.Gotham
SettingsInfo.TextXAlignment = Enum.TextXAlignment.Left
SettingsInfo.TextYAlignment = Enum.TextYAlignment.Top
SettingsInfo.ZIndex = 12
SettingsInfo.Parent = SettingsPage

--==================================================
-- DEBUG OVERLAY
--==================================================

local DebugOverlay = Instance.new("Frame")
DebugOverlay.Name = "DebugOverlay"
DebugOverlay.Size = UDim2.fromOffset(225, 112)
DebugOverlay.Position = UDim2.new(1, -235, 0, 70)
DebugOverlay.BackgroundColor3 = COLORS.Panel
DebugOverlay.BackgroundTransparency = 0.05
DebugOverlay.BorderSizePixel = 0
DebugOverlay.Visible = false
DebugOverlay.ZIndex = 200
DebugOverlay.Parent = ScreenGui

local DebugOverlayCorner = Instance.new("UICorner")
DebugOverlayCorner.CornerRadius = UDim.new(0, 10)
DebugOverlayCorner.Parent = DebugOverlay

local DebugOverlayStroke = Instance.new("UIStroke")
DebugOverlayStroke.Color = COLORS.Pink
DebugOverlayStroke.Transparency = 0.35
DebugOverlayStroke.Parent = DebugOverlay

local DebugOverlayText = Instance.new("TextLabel")
DebugOverlayText.BackgroundTransparency = 1
DebugOverlayText.Position = UDim2.fromOffset(10, 8)
DebugOverlayText.Size = UDim2.new(1, -20, 1, -16)
DebugOverlayText.TextColor3 = COLORS.White
DebugOverlayText.TextSize = 8
DebugOverlayText.Font = Enum.Font.Code
DebugOverlayText.TextXAlignment = Enum.TextXAlignment.Left
DebugOverlayText.TextYAlignment = Enum.TextYAlignment.Top
DebugOverlayText.ZIndex = 201
DebugOverlayText.Parent = DebugOverlay

--==================================================
-- TARGET INFO OVERLAY
--==================================================

local TargetOverlay = Instance.new("Frame")
TargetOverlay.Name = "TargetOverlay"
TargetOverlay.Size = UDim2.fromOffset(225, 95)
TargetOverlay.Position = UDim2.new(1, -235, 0, 190)
TargetOverlay.BackgroundColor3 = COLORS.Panel
TargetOverlay.BackgroundTransparency = 0.05
TargetOverlay.BorderSizePixel = 0
TargetOverlay.Visible = false
TargetOverlay.ZIndex = 200
TargetOverlay.Parent = ScreenGui

local TargetOverlayCorner = Instance.new("UICorner")
TargetOverlayCorner.CornerRadius = UDim.new(0, 10)
TargetOverlayCorner.Parent = TargetOverlay

local TargetOverlayStroke = Instance.new("UIStroke")
TargetOverlayStroke.Color = COLORS.Pink
TargetOverlayStroke.Transparency = 0.35
TargetOverlayStroke.Parent = TargetOverlay

local TargetOverlayText = Instance.new("TextLabel")
TargetOverlayText.BackgroundTransparency = 1
TargetOverlayText.Position = UDim2.fromOffset(10, 8)
TargetOverlayText.Size = UDim2.new(1, -20, 1, -16)
TargetOverlayText.TextColor3 = COLORS.White
TargetOverlayText.TextSize = 8
TargetOverlayText.Font = Enum.Font.Code
TargetOverlayText.TextXAlignment = Enum.TextXAlignment.Left
TargetOverlayText.TextYAlignment = Enum.TextYAlignment.Top
TargetOverlayText.ZIndex = 201
TargetOverlayText.Parent = TargetOverlay

--==================================================
-- ESP DEBUG OVERLAY
--==================================================

local EspOverlay = Instance.new("Frame")
EspOverlay.Name = "EspOverlay"
EspOverlay.Size = UDim2.fromOffset(225, 95)
EspOverlay.Position = UDim2.new(1, -235, 0, 295)
EspOverlay.BackgroundColor3 = COLORS.Panel
EspOverlay.BackgroundTransparency = 0.05
EspOverlay.BorderSizePixel = 0
EspOverlay.Visible = false
EspOverlay.ZIndex = 200
EspOverlay.Parent = ScreenGui

local EspOverlayCorner = Instance.new("UICorner")
EspOverlayCorner.CornerRadius = UDim.new(0, 10)
EspOverlayCorner.Parent = EspOverlay

local EspOverlayStroke = Instance.new("UIStroke")
EspOverlayStroke.Color = COLORS.Pink
EspOverlayStroke.Transparency = 0.35
EspOverlayStroke.Parent = EspOverlay

local EspOverlayText = Instance.new("TextLabel")
EspOverlayText.BackgroundTransparency = 1
EspOverlayText.Position = UDim2.fromOffset(10, 8)
EspOverlayText.Size = UDim2.new(1, -20, 1, -16)
EspOverlayText.TextColor3 = COLORS.White
EspOverlayText.TextSize = 8
EspOverlayText.Font = Enum.Font.Code
EspOverlayText.TextXAlignment = Enum.TextXAlignment.Left
EspOverlayText.TextYAlignment = Enum.TextYAlignment.Top
EspOverlayText.ZIndex = 201
EspOverlayText.Parent = EspOverlay

--==================================================
-- VISIBILITY UPDATE
--==================================================

local function updateDebugVisibility()
	DebugOverlay.Visible =
		Settings.DebugOverlay
		or Settings.PerformanceDebug

	TargetOverlay.Visible =
		Settings.TargetDebug
		or Settings.TargetInfo

	EspOverlay.Visible =
		Settings.EspDebug
		or Settings.NpcScanner

	AimFOVCircle.Visible =
		Settings.PlayerAimbot
		or Settings.NpcAimbot
end

--==================================================
-- DEBUG DATA
--==================================================

local function countRedHighlights()
	local count = 0

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			local character = player.Character

			if character and getSystemRedHighlight(character) then
				count += 1
			end
		end
	end

	return count
end

local function getMemoryUsage()
	local success, value = pcall(function()
		return Stats:GetTotalMemoryUsageMb()
	end)

	if success and value then
		return value
	end

	return 0
end

local function updateDebugInfo()
	local playerCount = #Players:GetPlayers()

	local npcCount = 0

	for npc in pairs(NPCs) do
		if npc.Parent and isNPC(npc) then
			npcCount += 1
		end
	end

	local targetName = getTargetName()

	DebugInfo.Text =
		"FPS: "
		.. tostring(math.floor(LastFPS))
		.. "\nPlayers: "
		.. tostring(playerCount)
		.. "\nNPC cache: "
		.. tostring(npcCount)
		.. "\nRed ESP: "
		.. tostring(countRedHighlights())
		.. "\nCurrent target: "
		.. targetName

	DebugOverlayText.Text =
		"COMBAT DEBUG\n"
		.. "FPS: "
		.. tostring(math.floor(LastFPS))
		.. "\nPlayers: "
		.. tostring(playerCount)
		.. "\nNPC CACHE: "
		.. tostring(npcCount)
		.. "\nRED ESP: "
		.. tostring(countRedHighlights())
		.. "\nMEMORY: "
		.. string.format("%.0f MB", getMemoryUsage())
		.. "\nAIM RANGE: "
		.. tostring(Settings.AimRange)
		.. "\nAIM FOV: "
		.. tostring(Settings.AimFOV)

	TargetOverlayText.Text =
		"TARGET DEBUG\n"
		.. "Player: "
		.. (
			CurrentTarget
			and CurrentTarget.Name
			or "None"
		)
		.. "\nNPC: "
		.. (
			CurrentNpcTarget
			and CurrentNpcTarget.Name
			or "None"
		)
		.. "\nActive: "
		.. targetName
		.. "\nPart: "
		.. Settings.AimPart
		.. "\nRange: "
		.. tostring(Settings.AimRange)
		.. "\nFOV: "
		.. tostring(Settings.AimFOV)

	MiscInfo.Text =
		"Red ESP detected: "
		.. tostring(countRedHighlights())
		.. "\nNPC cache: "
		.. tostring(npcCount)
		.. "\nCurrent: "
		.. targetName

	EspOverlayText.Text =
		"ESP / NPC DEBUG\n"
		.. "RED PLAYER ESP: "
		.. tostring(countRedHighlights())
		.. "\nNPC CACHE: "
		.. tostring(npcCount)
		.. "\nNPC SCANNER: "
		.. (Settings.NpcScanner and "ON" or "OFF")
end

--==================================================
-- AIM LOOP
--==================================================

local function getActiveAimTarget()
	if Settings.PlayerAimbot then
		if not isCurrentPlayerTargetValid() then
			CurrentTarget = getPlayerAimTarget()
		end

		if CurrentTarget and isCurrentPlayerTargetValid() then
			return getAimPart(CurrentTarget.Character)
		end
	end

	if Settings.NpcAimbot then
		if not isCurrentNpcTargetValid() then
			CurrentNpcTarget = getNpcAimTarget()
		end

		if CurrentNpcTarget and isCurrentNpcTargetValid() then
			return getAimPart(CurrentNpcTarget)
		end
	end

	return nil
end

local function updateTargets()
	local now = os.clock()

	if now - LastAimScan < AimScanInterval then
		return
	end

	LastAimScan = now

	if Settings.PlayerAimbot then
		if not isCurrentPlayerTargetValid() then
			CurrentTarget = getPlayerAimTarget()
		end
	else
		CurrentTarget = nil
	end

	if Settings.NpcAimbot then
		if not isCurrentNpcTargetValid() then
			CurrentNpcTarget = getNpcAimTarget()
		end
	else
		CurrentNpcTarget = nil
	end
end

local function aimAt(part)
	if not part then
		return
	end

	Camera = workspace.CurrentCamera

	if not Camera then
		return
	end

	local cameraPosition = Camera.CFrame.Position

	local targetPosition = part.Position

	local direction = targetPosition - cameraPosition

	if direction.Magnitude <= 0.001 then
		return
	end

	local targetCFrame =
		CFrame.lookAt(
			cameraPosition,
			targetPosition
		)

	if Settings.InstantAim then
		Camera.CFrame = targetCFrame
	else
		Camera.CFrame =
			Camera.CFrame:Lerp(
				targetCFrame,
				math.clamp(Settings.AimSmoothness, 0.01, 1)
			)
	end
end

--==================================================
-- RENDER LOOP
--==================================================

RunService:BindToRenderStep(
	"CombatAdminAim",
	Enum.RenderPriority.Camera.Value + 1,
	function(deltaTime)

		FPSAccumulator += deltaTime
		FPSFrames += 1

		if FPSAccumulator >= 0.5 then
			LastFPS = FPSFrames / FPSAccumulator
			FPSAccumulator = 0
			FPSFrames = 0
		end

		updateTargets()

		local aimPart = getActiveAimTarget()

		if aimPart then
			aimAt(aimPart)
		end

		if os.clock() - LastDebugUpdate >= 0.2 then
			LastDebugUpdate = os.clock()

			updateDebugVisibility()
			updateDebugInfo()

			AimTargetText.Text = getTargetName()

			AimStatus.Text =
				"Player: "
				.. (Settings.PlayerAimbot and "ON" or "OFF")
				.. "     NPC: "
				.. (Settings.NpcAimbot and "ON" or "OFF")
		end
	end
)

--==================================================
-- NPC CACHE MAINTENANCE
--==================================================

task.spawn(function()
	while ScreenGui.Parent do
		task.wait(1)

		local now = os.clock()

		if now - LastNpcScan >= NpcScanInterval then
			for npc in pairs(NPCs) do
				if not npc.Parent or not isNPC(npc) then
					NPCs[npc] = nil
				end
			end

			LastNpcScan = now
		end
	end
end)

--==================================================
-- PLAYER EVENTS
--==================================================

Players.PlayerRemoving:Connect(function(player)
	if CurrentTarget == player then
		CurrentTarget = nil
	end

	if SelectedDebugPlayer == player then
		SelectedDebugPlayer = LocalPlayer
	end
end)

LocalPlayer.CharacterAdded:Connect(function()
	CurrentTarget = nil
	CurrentNpcTarget = nil
end)

--==================================================
-- OPEN / CLOSE
--==================================================

local NormalPanelSize = getNormalPanelSize()

local function openPanel()
	if IsOpen then
		return
	end

	IsOpen = true
	Main.Visible = true

	NormalPanelSize = getNormalPanelSize()

	if not Settings.UIAnimations then
		Main.Size = NormalPanelSize
		return
	end

	local openSize

	if Camera and Camera.ViewportSize.X < 600 then
		openSize = UDim2.new(0.92, 0, 0, 0)
	else
		openSize = UDim2.new(
			NormalPanelSize.X.Scale,
			NormalPanelSize.X.Offset,
			0,
			0
		)
	end

	Main.Size = openSize

	TweenService:Create(
		Main,
		TweenInfo.new(
			0.24,
			Enum.EasingStyle.Back,
			Enum.EasingDirection.Out
		),
		{
			Size = NormalPanelSize
		}
	):Play()
end

local function closePanel()
	if not IsOpen then
		return
	end

	IsOpen = false

	if DebugToolWindow then
		DebugToolWindow.Visible = false
	end

	if not Settings.UIAnimations then
		Main.Visible = false
		return
	end

	local closeSize

	if Camera and Camera.ViewportSize.X < 600 then
		closeSize = UDim2.new(0.92, 0, 0, 0)
	else
		closeSize = UDim2.new(
			NormalPanelSize.X.Scale,
			NormalPanelSize.X.Offset,
			0,
			0
		)
	end

	local tween = TweenService:Create(
		Main,
		TweenInfo.new(
			0.17,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.In
		),
		{
			Size = closeSize
		}
	)

	tween:Play()

	tween.Completed:Once(function()
		if not IsOpen then
			Main.Visible = false
		end
	end)
end

--==================================================
-- OPEN BUTTON
--==================================================

OpenButton.Activated:Connect(function()
	if IsOpen then
		closePanel()
	else
		openPanel()
	end
end)

--==================================================
-- CLOSE BUTTON
--==================================================

Close.Activated:Connect(function()
	closePanel()
end)

--==================================================
-- RIGHT SHIFT
--==================================================

UserInputService.InputBegan:Connect(
	function(input, processed)
		if processed then
			return
		end

		if input.KeyCode == Enum.KeyCode.RightShift then
			if IsOpen then
				closePanel()
			else
				openPanel()
			end
		end
	end
)

--==================================================
-- DRAGGING
--==================================================

local dragging = false
local dragStart
local startPosition
local dragInput

Header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		dragging = true
		dragStart = input.Position
		startPosition = Main.Position

		dragInput = input
	end
end)

Header.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		dragging = false

		if dragInput == input then
			dragInput = nil
		end
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

	local delta =
		input.Position - dragStart

	Main.Position = UDim2.new(
		startPosition.X.Scale,
		startPosition.X.Offset + delta.X,
		startPosition.Y.Scale,
		startPosition.Y.Offset + delta.Y
	)
end)

--==================================================
-- INITIALIZATION
--==================================================

updateDebugVisibility()
updateDebugInfo()

showPage("Home")

--==================================================
-- CLEANUP
--==================================================

ScreenGui.Destroying:Connect(function()
	RunService:UnbindFromRenderStep("CombatAdminAim")

	if DebugConsoleConnection then
		DebugConsoleConnection:Disconnect()
	end

	for _, connection in ipairs(Connections) do
		if connection then
			connection:Disconnect()
		end
	end
end)
