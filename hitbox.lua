--// COMBAT ADMIN PANEL
--// NEW RESPONSIVE UI
--// LocalScript -> StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--==================================================
-- SETTINGS
--==================================================

local Settings = {
	PlayerAimbot = false,
	NpcAimbot = false,

	PlayerHitbox = 2.5,
	NpcHitbox = 2,

	ShowPlayerHitboxes = false,
	ShowNpcHitboxes = false,

	AimPart = "Head",
	AimSmoothness = 0.25,
	AimRange = 500,
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
	0.25,
	Enum.EasingStyle.Quart,
	Enum.EasingDirection.Out
)

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
-- OPEN BUTTON
--==================================================

local OpenButton = Instance.new("TextButton")
OpenButton.Name = "OpenCombat"
OpenButton.Size = UDim2.fromOffset(46, 46)
OpenButton.Position = UDim2.new(0, 18, 0.5, -23)
OpenButton.BackgroundColor3 = COLORS.Panel
OpenButton.BorderSizePixel = 0
OpenButton.Text = "⚔"
OpenButton.TextColor3 = COLORS.Pink
OpenButton.TextSize = 22
OpenButton.Font = Enum.Font.GothamBold
OpenButton.AutoButtonColor = false
OpenButton.Active = true
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
Main.Size = UDim2.fromOffset(700, 440)
Main.BackgroundColor3 = COLORS.Background
Main.BorderSizePixel = 0
Main.Visible = true
Main.Active = true
Main.ZIndex = 10
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 16)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = COLORS.Pink
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.2
MainStroke.Parent = Main

local MainSizeConstraint = Instance.new("UISizeConstraint")
MainSizeConstraint.MinSize = Vector2.new(300, 330)
MainSizeConstraint.MaxSize = Vector2.new(760, 500)
MainSizeConstraint.Parent = Main

--==================================================
-- RESPONSIVE SIZE
--==================================================

local function updatePanelSize()

	local camera = workspace.CurrentCamera

	if not camera then
		return
	end

	local viewport = camera.ViewportSize

	if viewport.X < 600 then

		-- Mobile
		Main.Size = UDim2.new(
			0.94,
			0,
			0.78,
			0
		)

	else

		-- PC / Tablet
		Main.Size = UDim2.fromOffset(
			700,
			440
		)
	end
end

updatePanelSize()

workspace.CurrentCamera:GetPropertyChangedSignal(
	"ViewportSize"
):Connect(updatePanelSize)

--==================================================
-- HEADER
--==================================================

local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 58)
Header.BackgroundColor3 = COLORS.Panel
Header.BorderSizePixel = 0
Header.Active = true
Header.ZIndex = 11
Header.Parent = Main

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 16)
HeaderCorner.Parent = Header

local Logo = Instance.new("TextLabel")
Logo.BackgroundTransparency = 1
Logo.Position = UDim2.fromOffset(18, 8)
Logo.Size = UDim2.fromOffset(38, 40)
Logo.Text = "⚔"
Logo.TextColor3 = COLORS.Pink
Logo.TextSize = 25
Logo.Font = Enum.Font.GothamBold
Logo.ZIndex = 12
Logo.Parent = Header

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Position = UDim2.fromOffset(58, 7)
Title.Size = UDim2.new(1, -170, 0, 25)
Title.Text = "COMBAT"
Title.TextColor3 = COLORS.White
Title.TextSize = 19
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 12
Title.Parent = Header

local Subtitle = Instance.new("TextLabel")
Subtitle.BackgroundTransparency = 1
Subtitle.Position = UDim2.fromOffset(59, 31)
Subtitle.Size = UDim2.new(1, -170, 0, 17)
Subtitle.Text = "ADMIN DEBUG PANEL"
Subtitle.TextColor3 = COLORS.Pink
Subtitle.TextSize = 9
Subtitle.Font = Enum.Font.GothamBold
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.ZIndex = 12
Subtitle.Parent = Header

--==================================================
-- ADMIN BADGE
--==================================================

local AdminBadge = Instance.new("Frame")
AdminBadge.Size = UDim2.fromOffset(105, 36)
AdminBadge.Position = UDim2.new(1, -150, 0, 11)
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
BadgeText.TextSize = 11
BadgeText.Font = Enum.Font.GothamBold
BadgeText.ZIndex = 13
BadgeText.Parent = AdminBadge

--==================================================
-- CLOSE
--==================================================

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(34, 34)
Close.Position = UDim2.new(1, -42, 0, 12)
Close.BackgroundColor3 = COLORS.Card
Close.BorderSizePixel = 0
Close.Text = "×"
Close.TextColor3 = COLORS.Pink
Close.TextSize = 23
Close.Font = Enum.Font.GothamBold
Close.AutoButtonColor = false
Close.Active = true
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
PageContainer.Position = UDim2.fromOffset(10, 68)
PageContainer.Size = UDim2.new(1, -20, 1, -78)
PageContainer.BackgroundTransparency = 1
PageContainer.ClipsDescendants = true
PageContainer.ZIndex = 10
PageContainer.Parent = Main

--==================================================
-- PAGE SYSTEM
--==================================================

local Pages = {}
local CurrentPage = nil

local function createPage(name)

	local page = Instance.new("Frame")
	page.Name = name
	page.Size = UDim2.fromScale(1, 1)
	page.Position = UDim2.fromScale(0, 0)
	page.BackgroundTransparency = 1
	page.Visible = false
	page.ZIndex = 10
	page.Parent = PageContainer

	Pages[name] = page

	return page
end

local HomePage = createPage("Home")
local AimPage = createPage("Aim")
local HitboxPage = createPage("Hitboxes")
local DebugPage = createPage("Debug")
local MiscPage = createPage("Misc")

--==================================================
-- BUTTON HELPER
--==================================================

local function styleButton(button)

	button.AutoButtonColor = false
	button.Active = true
	button.Selectable = true

	local normal = COLORS.Card
	local hover = COLORS.CardHover

	button.BackgroundColor3 = normal

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
				BackgroundColor3 = hover
			}
		):Play()

		TweenService:Create(
			stroke,
			TweenFast,
			{
				Color = COLORS.Pink,
				Transparency = 0.25
			}
		):Play()
	end)

	button.MouseLeave:Connect(function()

		TweenService:Create(
			button,
			TweenFast,
			{
				BackgroundColor3 = normal
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

	-- IMPORTANT:
	-- Activated works with BOTH mouse and touch.
	button.Activated:Connect(function()

		TweenService:Create(
			button,
			TweenInfo.new(
				0.07,
				Enum.EasingStyle.Quad,
				Enum.EasingDirection.Out
			),
			{
				Size = button.Size
			}
		):Play()
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
	newPage.Position = UDim2.fromScale(0.06, 0)
	newPage.BackgroundTransparency = 1

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
				0.18,
				Enum.EasingStyle.Quad,
				Enum.EasingDirection.In
			),
			{
				Position = UDim2.fromScale(-0.05, 0)
			}
		):Play()

		task.delay(0.18, function()

			if old ~= CurrentPage then
				old.Visible = false
				old.Position = UDim2.fromScale(0, 0)
			end
		end)
	end
end

--==================================================
-- HOME TITLE
--==================================================

local function createHomeHeader(parent, title, subtitle)

	local titleLabel = Instance.new("TextLabel")
	titleLabel.BackgroundTransparency = 1
	titleLabel.Position = UDim2.fromOffset(8, 4)
	titleLabel.Size = UDim2.new(1, -16, 0, 25)
	titleLabel.Text = title
	titleLabel.TextColor3 = COLORS.White
	titleLabel.TextSize = 20
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.ZIndex = 12
	titleLabel.Parent = parent

	local sub = Instance.new("TextLabel")
	sub.BackgroundTransparency = 1
	sub.Position = UDim2.fromOffset(9, 30)
	sub.Size = UDim2.new(1, -18, 0, 20)
	sub.Text = subtitle
	sub.TextColor3 = COLORS.Gray
	sub.TextSize = 10
	sub.Font = Enum.Font.Gotham
	sub.TextXAlignment = Enum.TextXAlignment.Left
	sub.ZIndex = 12
	sub.Parent = parent
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
	button.Size = UDim2.new(1, -16, 0, 67)
	button.Position = position
	button.BackgroundColor3 = COLORS.Card
	button.BorderSizePixel = 0
	button.Text = ""
	button.ZIndex = 12
	button.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = button

	local stroke = Instance.new("UIStroke")
	stroke.Color = COLORS.Stroke
	stroke.Thickness = 1
	stroke.Parent = button

	local iconLabel = Instance.new("TextLabel")
	iconLabel.BackgroundTransparency = 1
	iconLabel.Position = UDim2.fromOffset(13, 13)
	iconLabel.Size = UDim2.fromOffset(40, 40)
	iconLabel.Text = icon
	iconLabel.TextColor3 = COLORS.Pink
	iconLabel.TextSize = 23
	iconLabel.Font = Enum.Font.GothamBold
	iconLabel.ZIndex = 13
	iconLabel.Parent = button

	local titleLabel = Instance.new("TextLabel")
	titleLabel.BackgroundTransparency = 1
	titleLabel.Position = UDim2.fromOffset(62, 12)
	titleLabel.Size = UDim2.new(1, -105, 0, 22)
	titleLabel.Text = title
	titleLabel.TextColor3 = COLORS.White
	titleLabel.TextSize = 13
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.ZIndex = 13
	titleLabel.Parent = button

	local descLabel = Instance.new("TextLabel")
	descLabel.BackgroundTransparency = 1
	descLabel.Position = UDim2.fromOffset(62, 34)
	descLabel.Size = UDim2.new(1, -105, 0, 20)
	descLabel.Text = description
	descLabel.TextColor3 = COLORS.Gray
	descLabel.TextSize = 9
	descLabel.Font = Enum.Font.Gotham
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.ZIndex = 13
	descLabel.Parent = button

	local arrow = Instance.new("TextLabel")
	arrow.BackgroundTransparency = 1
	arrow.AnchorPoint = Vector2.new(1, 0.5)
	arrow.Position = UDim2.new(1, -14, 0.5, 0)
	arrow.Size = UDim2.fromOffset(20, 25)
	arrow.Text = "›"
	arrow.TextColor3 = COLORS.Gray
	arrow.TextSize = 24
	arrow.Font = Enum.Font.GothamBold
	arrow.ZIndex = 13
	arrow.Parent = button

	styleButton(button)

	button.Activated:Connect(function()
		callback()
	end)

	return button
end

--==================================================
-- HOME PAGE
--==================================================

createHomeHeader(
	HomePage,
	"CONTROL CENTER",
	"Choose a category to configure"
)

createCategoryButton(
	HomePage,
	UDim2.fromOffset(8, 58),
	"AIM",
	"Aimbot, target selection and aim settings",
	"◎",
	function()
		showPage("Aim")
	end
)

createCategoryButton(
	HomePage,
	UDim2.fromOffset(8, 133),
	"HITBOXES",
	"Player and NPC hitbox controls",
	"◇",
	function()
		showPage("Hitboxes")
	end
)

createCategoryButton(
	HomePage,
	UDim2.fromOffset(8, 208),
	"DEBUG",
	"Developer diagnostics and debug tools",
	"⚙",
	function()
		showPage("Debug")
	end
)

createCategoryButton(
	HomePage,
	UDim2.fromOffset(8, 283),
	"MISC",
	"Additional admin utilities",
	"◆",
	function()
		showPage("Misc")
	end
)

--==================================================
-- PAGE HEADER
--==================================================

local function createPageHeader(
	parent,
	title,
	subtitle
)

	local back = Instance.new("TextButton")
	back.Size = UDim2.fromOffset(78, 34)
	back.Position = UDim2.new(1, -86, 0, 0)
	back.BackgroundColor3 = COLORS.Card
	back.BorderSizePixel = 0
	back.Text = "‹  BACK"
	back.TextColor3 = COLORS.White
	back.TextSize = 10
	back.Font = Enum.Font.GothamBold
	back.AutoButtonColor = false
	back.Active = true
	back.ZIndex = 15
	back.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 9)
	corner.Parent = back

	local stroke = Instance.new("UIStroke")
	stroke.Color = COLORS.Stroke
	stroke.Parent = back

	styleButton(back)

	back.Activated:Connect(function()
		showPage("Home")
	end)

	local titleLabel = Instance.new("TextLabel")
	titleLabel.BackgroundTransparency = 1
	titleLabel.Position = UDim2.fromOffset(8, 0)
	titleLabel.Size = UDim2.new(1, -100, 0, 25)
	titleLabel.Text = title
	titleLabel.TextColor3 = COLORS.White
	titleLabel.TextSize = 19
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.ZIndex = 14
	titleLabel.Parent = parent

	local sub = Instance.new("TextLabel")
	sub.BackgroundTransparency = 1
	sub.Position = UDim2.fromOffset(9, 25)
	sub.Size = UDim2.new(1, -100, 0, 18)
	sub.Text = subtitle
	sub.TextColor3 = COLORS.Gray
	sub.TextSize = 9
	sub.Font = Enum.Font.Gotham
	sub.TextXAlignment = Enum.TextXAlignment.Left
	sub.ZIndex = 14
	sub.Parent = parent
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
	button.Size = UDim2.new(1, -16, 0, 55)
	button.Position = UDim2.fromOffset(8, y)
	button.BackgroundColor3 = COLORS.Card
	button.BorderSizePixel = 0
	button.Text = ""
	button.Active = true
	button.AutoButtonColor = false
	button.ZIndex = 12
	button.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = button

	local stroke = Instance.new("UIStroke")
	stroke.Color = COLORS.Stroke
	stroke.Parent = button

	local titleLabel = Instance.new("TextLabel")
	titleLabel.BackgroundTransparency = 1
	titleLabel.Position = UDim2.fromOffset(13, 8)
	titleLabel.Size = UDim2.new(1, -95, 0, 20)
	titleLabel.Text = title
	titleLabel.TextColor3 = COLORS.White
	titleLabel.TextSize = 11
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.ZIndex = 13
	titleLabel.Parent = button

	local descLabel = Instance.new("TextLabel")
	descLabel.BackgroundTransparency = 1
	descLabel.Position = UDim2.fromOffset(13, 29)
	descLabel.Size = UDim2.new(1, -95, 0, 16)
	descLabel.Text = description
	descLabel.TextColor3 = COLORS.Gray
	descLabel.TextSize = 8
	descLabel.Font = Enum.Font.Gotham
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.ZIndex = 13
	descLabel.Parent = button

	local toggle = Instance.new("Frame")
	toggle.Size = UDim2.fromOffset(47, 24)
	toggle.Position = UDim2.new(1, -60, 0.5, -12)
	toggle.BackgroundColor3 = COLORS.Gray2
	toggle.BorderSizePixel = 0
	toggle.ZIndex = 13
	toggle.Parent = button

	local toggleCorner = Instance.new("UICorner")
	toggleCorner.CornerRadius = UDim.new(1, 0)
	toggleCorner.Parent = toggle

	local knob = Instance.new("Frame")
	knob.Size = UDim2.fromOffset(18, 18)
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
				BackgroundColor3 =
					enabled
					and COLORS.Pink
					or COLORS.Gray2
			}
		):Play()

		TweenService:Create(
			knob,
			TweenFast,
			{
				Position =
					enabled
					and UDim2.fromOffset(26, 3)
					or UDim2.fromOffset(3, 3)
			}
		):Play()
	end

	button.Activated:Connect(function()

		setValue(not getValue())
		refresh()
	end)

	styleButton(button)

	refresh()

	return button
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
	58,
	"PLAYER AIMBOT",
	"Targets enemy players with valid red ESP",
	function()
		return Settings.PlayerAimbot
	end,
	function(value)
		Settings.PlayerAimbot = value

		-- подключение твоей логики аима здесь
	end
)

createToggle(
	AimPage,
	121,
	"NPC AIMBOT",
	"Targets the nearest valid NPC",
	function()
		return Settings.NpcAimbot
	end,
	function(value)
		Settings.NpcAimbot = value

		-- подключение NPC aim здесь
	end
)

--==================================================
-- AIM INFO CARD
--==================================================

local AimInfo = Instance.new("Frame")
AimInfo.Size = UDim2.new(1, -16, 0, 76)
AimInfo.Position = UDim2.fromOffset(8, 184)
AimInfo.BackgroundColor3 = COLORS.Panel2
AimInfo.BorderSizePixel = 0
AimInfo.ZIndex = 12
AimInfo.Parent = AimPage

local AimInfoCorner = Instance.new("UICorner")
AimInfoCorner.CornerRadius = UDim.new(0, 10)
AimInfoCorner.Parent = AimInfo

local AimInfoStroke = Instance.new("UIStroke")
AimInfoStroke.Color = COLORS.PinkDark
AimInfoStroke.Transparency = 0.3
AimInfoStroke.Parent = AimInfo

local AimInfoTitle = Instance.new("TextLabel")
AimInfoTitle.BackgroundTransparency = 1
AimInfoTitle.Position = UDim2.fromOffset(12, 8)
AimInfoTitle.Size = UDim2.new(1, -24, 0, 18)
AimInfoTitle.Text = "CURRENT TARGET"
AimInfoTitle.TextColor3 = COLORS.Pink
AimInfoTitle.TextSize = 9
AimInfoTitle.Font = Enum.Font.GothamBold
AimInfoTitle.TextXAlignment = Enum.TextXAlignment.Left
AimInfoTitle.ZIndex = 13
AimInfoTitle.Parent = AimInfo

local AimTargetText = Instance.new("TextLabel")
AimTargetText.BackgroundTransparency = 1
AimTargetText.Position = UDim2.fromOffset(12, 30)
AimTargetText.Size = UDim2.new(1, -24, 0, 20)
AimTargetText.Text = "No target"
AimTargetText.TextColor3 = COLORS.White
AimTargetText.TextSize = 12
AimTargetText.Font = Enum.Font.GothamBold
AimTargetText.TextXAlignment = Enum.TextXAlignment.Left
AimTargetText.ZIndex = 13
AimTargetText.Parent = AimInfo

local AimStatus = Instance.new("TextLabel")
AimStatus.BackgroundTransparency = 1
AimStatus.Position = UDim2.fromOffset(12, 51)
AimStatus.Size = UDim2.new(1, -24, 0, 15)
AimStatus.Text = "Player: —     NPC: —"
AimStatus.TextColor3 = COLORS.Gray
AimStatus.TextSize = 8
AimStatus.Font = Enum.Font.Gotham
AimStatus.TextXAlignment = Enum.TextXAlignment.Left
AimStatus.ZIndex = 13
AimStatus.Parent = AimInfo

--==================================================
-- AIM OPTIONS
--==================================================

local AimPartButton = Instance.new("TextButton")
AimPartButton.Size = UDim2.new(1, -16, 0, 43)
AimPartButton.Position = UDim2.fromOffset(8, 270)
AimPartButton.BackgroundColor3 = COLORS.Card
AimPartButton.BorderSizePixel = 0
AimPartButton.Text = "AIM PART:  HEAD"
AimPartButton.TextColor3 = COLORS.White
AimPartButton.TextSize = 10
AimPartButton.Font = Enum.Font.GothamBold
AimPartButton.AutoButtonColor = false
AimPartButton.Active = true
AimPartButton.ZIndex = 12
AimPartButton.Parent = AimPage

local AimPartCorner = Instance.new("UICorner")
AimPartCorner.CornerRadius = UDim.new(0, 9)
AimPartCorner.Parent = AimPartButton

local AimPartStroke = Instance.new("UIStroke")
AimPartStroke.Color = COLORS.Stroke
AimPartStroke.Parent = AimPartButton

styleButton(AimPartButton)

AimPartButton.Activated:Connect(function()

	if Settings.AimPart == "Head" then
		Settings.AimPart = "Torso"

	elseif Settings.AimPart == "Torso" then
		Settings.AimPart = "HumanoidRootPart"

	else
		Settings.AimPart = "Head"
	end

	AimPartButton.Text =
		"AIM PART:  "
		.. string.upper(Settings.AimPart)
end)

--==================================================
-- SMOOTHNESS
--==================================================

local SmoothButton = Instance.new("TextButton")
SmoothButton.Size = UDim2.new(1, -16, 0, 43)
SmoothButton.Position = UDim2.fromOffset(8, 320)
SmoothButton.BackgroundColor3 = COLORS.Card
SmoothButton.BorderSizePixel = 0
SmoothButton.Text =
	"AIM SMOOTHNESS:  "
	.. tostring(Settings.AimSmoothness)

SmoothButton.TextColor3 = COLORS.White
SmoothButton.TextSize = 10
SmoothButton.Font = Enum.Font.GothamBold
SmoothButton.AutoButtonColor = false
SmoothButton.Active = true
SmoothButton.ZIndex = 12
SmoothButton.Parent = AimPage

local SmoothCorner = Instance.new("UICorner")
SmoothCorner.CornerRadius = UDim.new(0, 9)
SmoothCorner.Parent = SmoothButton

local SmoothStroke = Instance.new("UIStroke")
SmoothStroke.Color = COLORS.Stroke
SmoothStroke.Parent = SmoothButton

styleButton(SmoothButton)

SmoothButton.Activated:Connect(function()

	Settings.AimSmoothness += 0.05

	if Settings.AimSmoothness > 0.8 then
		Settings.AimSmoothness = 0.1
	end

	Settings.AimSmoothness =
		math.floor(
			Settings.AimSmoothness * 100
		) / 100

	SmoothButton.Text =
		"AIM SMOOTHNESS:  "
		.. tostring(Settings.AimSmoothness)
end)

--==================================================
-- HITBOX PAGE
--==================================================

createPageHeader(
	HitboxPage,
	"HITBOXES",
	"Player and NPC hitbox configuration"
)

local PlayerHitboxButton = Instance.new("TextButton")
PlayerHitboxButton.Size = UDim2.new(1, -16, 0, 48)
PlayerHitboxButton.Position = UDim2.fromOffset(8, 58)
PlayerHitboxButton.BackgroundColor3 = COLORS.Card
PlayerHitboxButton.BorderSizePixel = 0
PlayerHitboxButton.Text =
	"PLAYER HITBOX   ×"
	.. tostring(Settings.PlayerHitbox)

PlayerHitboxButton.TextColor3 = COLORS.White
PlayerHitboxButton.TextSize = 11
PlayerHitboxButton.Font = Enum.Font.GothamBold
PlayerHitboxButton.AutoButtonColor = false
PlayerHitboxButton.Active = true
PlayerHitboxButton.ZIndex = 12
PlayerHitboxButton.Parent = HitboxPage

local PlayerHitboxCorner = Instance.new("UICorner")
PlayerHitboxCorner.CornerRadius = UDim.new(0, 10)
PlayerHitboxCorner.Parent = PlayerHitboxButton

local PlayerHitboxStroke = Instance.new("UIStroke")
PlayerHitboxStroke.Color = COLORS.Stroke
PlayerHitboxStroke.Parent = PlayerHitboxButton

styleButton(PlayerHitboxButton)

PlayerHitboxButton.Activated:Connect(function()

	Settings.PlayerHitbox += 0.5

	if Settings.PlayerHitbox > 20 then
		Settings.PlayerHitbox = 1
	end

	PlayerHitboxButton.Text =
		"PLAYER HITBOX   ×"
		.. tostring(Settings.PlayerHitbox)

	-- Здесь подключается реальное изменение
	-- hitbox персонажей на серверной стороне.
end)

createToggle(
	HitboxPage,
	116,
	"SHOW PLAYER HITBOXES",
	"Display enlarged player hitboxes",
	function()
		return Settings.ShowPlayerHitboxes
	end,
	function(value)
		Settings.ShowPlayerHitboxes = value

		-- подключение визуализации
	end
)

local NpcHitboxButton = Instance.new("TextButton")
NpcHitboxButton.Size = UDim2.new(1, -16, 0, 48)
NpcHitboxButton.Position = UDim2.fromOffset(8, 179)
NpcHitboxButton.BackgroundColor3 = COLORS.Card
NpcHitboxButton.BorderSizePixel = 0
NpcHitboxButton.Text =
	"NPC HITBOX   ×"
	.. tostring(Settings.NpcHitbox)

NpcHitboxButton.TextColor3 = COLORS.White
NpcHitboxButton.TextSize = 11
NpcHitboxButton.Font = Enum.Font.GothamBold
NpcHitboxButton.AutoButtonColor = false
NpcHitboxButton.Active = true
NpcHitboxButton.ZIndex = 12
NpcHitboxButton.Parent = HitboxPage

local NpcHitboxCorner = Instance.new("UICorner")
NpcHitboxCorner.CornerRadius = UDim.new(0, 10)
NpcHitboxCorner.Parent = NpcHitboxButton

local NpcHitboxStroke = Instance.new("UIStroke")
NpcHitboxStroke.Color = COLORS.Stroke
NpcHitboxStroke.Parent = NpcHitboxButton

styleButton(NpcHitboxButton)

NpcHitboxButton.Activated:Connect(function()

	Settings.NpcHitbox += 0.5

	if Settings.NpcHitbox > 20 then
		Settings.NpcHitbox = 1
	end

	NpcHitboxButton.Text =
		"NPC HITBOX   ×"
		.. tostring(Settings.NpcHitbox)
end)

createToggle(
	HitboxPage,
	237,
	"SHOW NPC HITBOXES",
	"Display enlarged NPC hitboxes",
	function()
		return Settings.ShowNpcHitboxes
	end,
	function(value)
		Settings.ShowNpcHitboxes = value
	end
)

--==================================================
-- DEBUG PAGE
--==================================================

createPageHeader(
	DebugPage,
	"DEBUG",
	"Developer diagnostics"
)

createToggle(
	DebugPage,
	58,
	"DEBUG OVERLAY",
	"Show development information",
	function()
		return false
	end,
	function(value)
		-- debug overlay
	end
)

createToggle(
	DebugPage,
	121,
	"TARGET DEBUG",
	"Display current target diagnostics",
	function()
		return false
	end,
	function(value)
		-- target debug
	end
)

createToggle(
	DebugPage,
	184,
	"PERFORMANCE DEBUG",
	"Monitor client performance",
	function()
		return false
	end,
	function(value)
		-- performance debug
	end
)

local DebugInfo = Instance.new("TextLabel")
DebugInfo.BackgroundTransparency = 1
DebugInfo.Position = UDim2.fromOffset(12, 255)
DebugInfo.Size = UDim2.new(1, -24, 0, 80)
DebugInfo.Text =
	"FPS: --\n"
	.. "Players: --\n"
	.. "NPCs: --\n"
	.. "Current target: --"

DebugInfo.TextColor3 = COLORS.Gray
DebugInfo.TextSize = 10
DebugInfo.Font = Enum.Font.Code
DebugInfo.TextXAlignment = Enum.TextXAlignment.Left
DebugInfo.TextYAlignment = Enum.TextYAlignment.Top
DebugInfo.ZIndex = 12
DebugInfo.Parent = DebugPage

--==================================================
-- MISC PAGE
--==================================================

createPageHeader(
	MiscPage,
	"MISC",
	"Additional administration tools"
)

createToggle(
	MiscPage,
	58,
	"TARGET INFO",
	"Show detailed target information",
	function()
		return false
	end,
	function(value)
		-- target info
	end
)

createToggle(
	MiscPage,
	121,
	"ESP DEBUG",
	"Inspect detected ESP objects",
	function()
		return false
	end,
	function(value)
		-- ESP debug
	end
)

createToggle(
	MiscPage,
	184,
	"NPC SCANNER",
	"Monitor NPC detection",
	function()
		return false
	end,
	function(value)
		-- NPC scanner
	end
)

--==================================================
-- OPEN / CLOSE
--==================================================

local IsOpen = true

local function openPanel()

	if IsOpen then
		return
	end

	IsOpen = true

	Main.Visible = true
	Main.Size = UDim2.fromOffset(650, 0)

	TweenService:Create(
		Main,
		TweenInfo.new(
			0.25,
			Enum.EasingStyle.Back,
			Enum.EasingDirection.Out
		),
		{
			Size = UDim2.fromOffset(700, 440)
		}
	):Play()
end

local function closePanel()

	if not IsOpen then
		return
	end

	IsOpen = false

	local tween = TweenService:Create(
		Main,
		TweenInfo.new(
			0.18,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.In
		),
		{
			Size = UDim2.fromOffset(700, 0)
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

Header.InputEnded:Connect(function(input)

	if input.UserInputType ==
		Enum.UserInputType.MouseButton1
		or input.UserInputType ==
		Enum.UserInputType.Touch then

		dragging = false
	end
end)

UserInputService.InputChanged:Connect(function(input)

	if not dragging then
		return
	end

	if input.UserInputType ~=
		Enum.UserInputType.MouseMovement
		and input.UserInputType ~=
		Enum.UserInputType.Touch then
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
-- INITIAL PAGE
--==================================================

showPage("Home")
