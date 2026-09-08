--// COMBAT ADMIN PANEL V2
--// LocalScript -> StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
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

	Animations = true,
	UIScale = 1,
}

--==================================================
-- COLORS
--==================================================

local COLORS = {
	Background = Color3.fromRGB(7, 8, 12),
	Panel = Color3.fromRGB(12, 13, 19),
	Panel2 = Color3.fromRGB(17, 18, 25),

	White = Color3.fromRGB(245, 245, 250),
	Gray = Color3.fromRGB(145, 148, 160),
	DarkGray = Color3.fromRGB(45, 47, 58),

	Pink = Color3.fromRGB(255, 35, 115),
	Red = Color3.fromRGB(255, 45, 80),
	PinkDark = Color3.fromRGB(85, 15, 45),

	Green = Color3.fromRGB(70, 230, 145),
}

--==================================================
-- HELPERS
--==================================================

local function tween(object, duration, properties, style, direction)
	if not Settings.Animations then
		for property, value in pairs(properties) do
			object[property] = value
		end
		return
	end

	local info = TweenInfo.new(
		duration or 0.2,
		style or Enum.EasingStyle.Quad,
		direction or Enum.EasingDirection.Out
	)

	TweenService:Create(object, info, properties):Play()
end

local function corner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 10)
	c.Parent = parent
	return c
end

local function stroke(parent, color, thickness, transparency)
	local s = Instance.new("UIStroke")
	s.Color = color or COLORS.DarkGray
	s.Thickness = thickness or 1
	s.Transparency = transparency or 0
	s.Parent = parent
	return s
end

local function label(parent, text, size, color, font)
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = color or COLORS.White
	l.TextSize = size or 14
	l.Font = font or Enum.Font.GothamMedium
	l.Parent = parent
	return l
end

--==================================================
-- GUI
--==================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CombatAdminPanelV2"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

--==================================================
-- OPEN BUTTON
--==================================================

local OpenButton = Instance.new("TextButton")
OpenButton.Name = "OpenCombat"
OpenButton.Size = UDim2.fromOffset(52, 52)
OpenButton.Position = UDim2.new(0, 18, 0.5, -26)
OpenButton.BackgroundColor3 = COLORS.Panel
OpenButton.Text = "⚔"
OpenButton.TextColor3 = COLORS.Pink
OpenButton.TextSize = 25
OpenButton.Font = Enum.Font.GothamBold
OpenButton.AutoButtonColor = false
OpenButton.Parent = ScreenGui

corner(OpenButton, 14)
stroke(OpenButton, COLORS.Pink, 1.5, 0.15)

OpenButton.MouseEnter:Connect(function()
	tween(OpenButton, 0.12, {
		BackgroundColor3 = COLORS.PinkDark
	})
end)

OpenButton.MouseLeave:Connect(function()
	tween(OpenButton, 0.12, {
		BackgroundColor3 = COLORS.Panel
	})
end)

--==================================================
-- MAIN WINDOW
--==================================================

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(950, 570)
Main.Position = UDim2.new(0.5, -475, 0.5, -285)
Main.BackgroundColor3 = COLORS.Background
Main.BorderSizePixel = 0
Main.Visible = false
Main.ClipsDescendants = true
Main.Parent = ScreenGui

corner(Main, 18)
stroke(Main, COLORS.Pink, 1.5, 0.15)

--==================================================
-- HEADER
--==================================================

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 78)
Header.BackgroundColor3 = COLORS.Panel
Header.BorderSizePixel = 0
Header.Parent = Main

corner(Header, 18)

local HeaderLine = Instance.new("Frame")
HeaderLine.Size = UDim2.new(1, -40, 0, 1)
HeaderLine.Position = UDim2.new(0, 20, 1, -1)
HeaderLine.BackgroundColor3 = COLORS.Pink
HeaderLine.BackgroundTransparency = 0.45
HeaderLine.BorderSizePixel = 0
HeaderLine.Parent = Header

local Logo = label(
	Header,
	"⚔",
	34,
	COLORS.Pink,
	Enum.Font.GothamBold
)

Logo.Position = UDim2.fromOffset(22, 18)
Logo.Size = UDim2.fromOffset(42, 42)
Logo.TextXAlignment = Enum.TextXAlignment.Center

local Title = label(
	Header,
	"COMBAT",
	22,
	COLORS.White,
	Enum.Font.GothamBold
)

Title.Position = UDim2.fromOffset(72, 14)
Title.Size = UDim2.fromOffset(250, 28)
Title.TextXAlignment = Enum.TextXAlignment.Left

local Subtitle = label(
	Header,
	"ADMIN DEBUG PANEL",
	10,
	COLORS.Pink,
	Enum.Font.GothamBold
)

Subtitle.Position = UDim2.fromOffset(73, 42)
Subtitle.Size = UDim2.fromOffset(250, 18)
Subtitle.TextXAlignment = Enum.TextXAlignment.Left

local AdminBadge = Instance.new("Frame")
AdminBadge.Size = UDim2.fromOffset(150, 42)
AdminBadge.Position = UDim2.new(1, -205, 0, 18)
AdminBadge.BackgroundColor3 = COLORS.Panel2
AdminBadge.Parent = Header

corner(AdminBadge, 11)
stroke(AdminBadge, COLORS.DarkGray, 1)

local AdminText = label(
	AdminBadge,
	"♛  ADMIN",
	13,
	COLORS.White,
	Enum.Font.GothamBold
)

AdminText.Size = UDim2.fromScale(1, 1)
AdminText.TextXAlignment = Enum.TextXAlignment.Center

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(42, 42)
Close.Position = UDim2.new(1, -55, 0, 18)
Close.BackgroundColor3 = COLORS.Panel2
Close.Text = "×"
Close.TextColor3 = COLORS.Pink
Close.TextSize = 27
Close.Font = Enum.Font.GothamBold
Close.AutoButtonColor = false
Close.Parent = Header

corner(Close, 11)
stroke(Close, COLORS.Pink, 1, 0.25)

--==================================================
-- BODY
--==================================================

local Body = Instance.new("Frame")
Body.Position = UDim2.fromOffset(12, 90)
Body.Size = UDim2.new(1, -24, 1, -102)
Body.BackgroundTransparency = 1
Body.Parent = Main

--==================================================
-- SIDEBAR
--==================================================

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.fromOffset(190, 1)
Sidebar.Size = UDim2.new(0, 190, 1, 0)
Sidebar.BackgroundColor3 = COLORS.Panel
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Body

corner(Sidebar, 14)
stroke(Sidebar, COLORS.DarkGray, 1)

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.Padding = UDim.new(0, 9)
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
SidebarLayout.Parent = Sidebar

local SidebarPadding = Instance.new("UIPadding")
SidebarPadding.PaddingTop = UDim.new(0, 15)
SidebarPadding.PaddingLeft = UDim.new(0, 12)
SidebarPadding.PaddingRight = UDim.new(0, 12)
SidebarPadding.Parent = Sidebar

--==================================================
-- PAGE AREA
--==================================================

local PageArea = Instance.new("Frame")
PageArea.Position = UDim2.fromOffset(202, 0)
PageArea.Size = UDim2.new(1, -202, 1, 0)
PageArea.BackgroundTransparency = 1
PageArea.ClipsDescendants = true
PageArea.Parent = Body

--==================================================
-- SIDEBAR BUTTON
--==================================================

local Pages = {}
local CurrentPage = nil

local function createNavButton(icon, text)
	local Button = Instance.new("TextButton")
	Button.Size = UDim2.new(1, 0, 0, 58)
	Button.BackgroundColor3 = COLORS.Panel2
	Button.Text = ""
	Button.AutoButtonColor = false
	Button.Parent = Sidebar

	corner(Button, 11)
	local ButtonStroke = stroke(Button, COLORS.DarkGray, 1)

	local Icon = label(
		Button,
		icon,
		21,
		COLORS.Gray,
		Enum.Font.GothamBold
	)

	Icon.Position = UDim2.fromOffset(14, 0)
	Icon.Size = UDim2.fromOffset(30, 58)
	Icon.TextXAlignment = Enum.TextXAlignment.Center

	local Text = label(
		Button,
		text,
		13,
		COLORS.White,
		Enum.Font.GothamBold
	)

	Text.Position = UDim2.fromOffset(52, 0)
	Text.Size = UDim2.new(1, -82, 1, 0)
	Text.TextXAlignment = Enum.TextXAlignment.Left

	local Arrow = label(
		Button,
		"›",
		22,
		COLORS.Gray,
		Enum.Font.GothamBold
	)

	Arrow.Position = UDim2.new(1, -35, 0, 0)
	Arrow.Size = UDim2.fromOffset(25, 58)
	Arrow.TextXAlignment = Enum.TextXAlignment.Center

	Button.MouseEnter:Connect(function()
		if CurrentPage ~= text then
			tween(Button, 0.12, {
				BackgroundColor3 = Color3.fromRGB(28, 20, 28)
			})
			tween(Arrow, 0.12, {
				TextColor3 = COLORS.Pink
			})
		end
	end)

	Button.MouseLeave:Connect(function()
		if CurrentPage ~= text then
			tween(Button, 0.12, {
				BackgroundColor3 = COLORS.Panel2
			})
			tween(Arrow, 0.12, {
				TextColor3 = COLORS.Gray
			})
		end
	end)

	return Button, Icon, Text, Arrow, ButtonStroke
end

--==================================================
-- PAGE CREATOR
--==================================================

local function createPage(name, titleText, subtitleText)
	local Page = Instance.new("Frame")
	Page.Name = name
	Page.Size = UDim2.fromScale(1, 1)
	Page.Position = UDim2.fromScale(1, 0)
	Page.BackgroundColor3 = COLORS.Panel
	Page.BorderSizePixel = 0
	Page.Visible = false
	Page.Parent = PageArea

	corner(Page, 14)
	stroke(Page, COLORS.DarkGray, 1)

	local Top = Instance.new("Frame")
	Top.Size = UDim2.new(1, 0, 0, 68)
	Top.BackgroundTransparency = 1
	Top.Parent = Page

	local PageTitle = label(
		Top,
		titleText,
		21,
		COLORS.White,
		Enum.Font.GothamBold
	)

	PageTitle.Position = UDim2.fromOffset(20, 12)
	PageTitle.Size = UDim2.new(1, -40, 0, 27)
	PageTitle.TextXAlignment = Enum.TextXAlignment.Left

	local PageSubtitle = label(
		Top,
		subtitleText,
		11,
		COLORS.Gray,
		Enum.Font.GothamMedium
	)

	PageSubtitle.Position = UDim2.fromOffset(21, 39)
	PageSubtitle.Size = UDim2.new(1, -40, 0, 18)
	PageSubtitle.TextXAlignment = Enum.TextXAlignment.Left

	local Content = Instance.new("ScrollingFrame")
	Content.Position = UDim2.fromOffset(15, 75)
	Content.Size = UDim2.new(1, -30, 1, -90)
	Content.BackgroundTransparency = 1
	Content.BorderSizePixel = 0
	Content.ScrollBarThickness = 3
	Content.ScrollBarImageColor3 = COLORS.Pink
	Content.CanvasSize = UDim2.new(0, 0, 0, 0)
	Content.Parent = Page

	local Layout = Instance.new("UIListLayout")
	Layout.Padding = UDim.new(0, 9)
	Layout.SortOrder = Enum.SortOrder.LayoutOrder
	Layout.Parent = Content

	local Pad = Instance.new("UIPadding")
	Pad.PaddingBottom = UDim.new(0, 15)
	Pad.Parent = Content

	Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		Content.CanvasSize = UDim2.fromOffset(
			0,
			Layout.AbsoluteContentSize.Y + 20
		)
	end)

	Pages[name] = {
		Frame = Page,
		Content = Content,
	}

	return Page, Content
end

--==================================================
-- BACK BUTTON
--==================================================

local function createBackButton(parent)
	local Button = Instance.new("TextButton")
	Button.Size = UDim2.fromOffset(110, 38)
	Button.Position = UDim2.new(1, -130, 0, 14)
	Button.BackgroundColor3 = COLORS.Panel2
	Button.Text = "←  BACK"
	Button.TextColor3 = COLORS.White
	Button.TextSize = 12
	Button.Font = Enum.Font.GothamBold
	Button.AutoButtonColor = false
	Button.Parent = parent

	corner(Button, 9)
	stroke(Button, COLORS.DarkGray, 1)

	Button.MouseButton1Click:Connect(function()
		showPage("HOME")
	end)

	return Button
end

--==================================================
-- HOME
--==================================================

local Home, HomeContent = createPage(
	"HOME",
	"COMBAT",
	"Administrative combat controls and diagnostics"
)

--==================================================
-- HOME CARDS
--==================================================

local function createSectionCard(parent, icon, titleText, descText)
	local Button = Instance.new("TextButton")
	Button.Size = UDim2.new(1, -4, 0, 78)
	Button.BackgroundColor3 = COLORS.Panel2
	Button.Text = ""
	Button.AutoButtonColor = false
	Button.Parent = parent

	corner(Button, 12)
	local s = stroke(Button, COLORS.DarkGray, 1)

	local Icon = label(
		Button,
		icon,
		25,
		COLORS.Pink,
		Enum.Font.GothamBold
	)

	Icon.Position = UDim2.fromOffset(17, 0)
	Icon.Size = UDim2.fromOffset(45, 78)
	Icon.TextXAlignment = Enum.TextXAlignment.Center

	local Title = label(
		Button,
		titleText,
		14,
		COLORS.White,
		Enum.Font.GothamBold
	)

	Title.Position = UDim2.fromOffset(70, 14)
	Title.Size = UDim2.new(1, -120, 0, 23)
	Title.TextXAlignment = Enum.TextXAlignment.Left

	local Desc = label(
		Button,
		descText,
		10,
		COLORS.Gray,
		Enum.Font.GothamMedium
	)

	Desc.Position = UDim2.fromOffset(70, 38)
	Desc.Size = UDim2.new(1, -120, 0, 25)
	Desc.TextXAlignment = Enum.TextXAlignment.Left
	Desc.TextWrapped = true

	local Arrow = label(
		Button,
		"›",
		25,
		COLORS.Gray,
		Enum.Font.GothamBold
	)

	Arrow.Position = UDim2.new(1, -45, 0, 0)
	Arrow.Size = UDim2.fromOffset(30, 78)

	Button.MouseEnter:Connect(function()
		tween(Button, 0.14, {
			BackgroundColor3 = Color3.fromRGB(28, 18, 27)
		})
		tween(s, 0.14, {
			Color = COLORS.Pink,
			Transparency = 0.35
		})
		tween(Arrow, 0.14, {
			TextColor3 = COLORS.Pink
		})
	end)

	Button.MouseLeave:Connect(function()
		tween(Button, 0.14, {
			BackgroundColor3 = COLORS.Panel2
		})
		tween(s, 0.14, {
			Color = COLORS.DarkGray,
			Transparency = 0
		})
		tween(Arrow, 0.14, {
			TextColor3 = COLORS.Gray
		})
	end)

	Button.MouseButton1Click:Connect(function()
		showPage(titleText)
	end)

	return Button
end

createSectionCard(
	HomeContent,
	"◎",
	"AIM",
	"Aimbot, target selection, aim part, range and smoothness"
)

createSectionCard(
	HomeContent,
	"◇",
	"HITBOXES",
	"Player and NPC hitbox debugging and visualization"
)

createSectionCard(
	HomeContent,
	"⚙",
	"DEBUG",
	"Performance, target and NPC scanner diagnostics"
)

createSectionCard(
	HomeContent,
	"✦",
	"MISC",
	"Interface, animations and general settings"
)

--==================================================
-- AIM PAGE
--==================================================

local AimPage, AimContent = createPage(
	"AIM",
	"AIM",
	"Targeting and camera assistance controls"
)

createBackButton(AimPage)

local function createToggle(parent, titleText, descText, initial, callback)
	local Frame = Instance.new("Frame")
	Frame.Size = UDim2.new(1, -4, 0, 64)
	Frame.BackgroundColor3 = COLORS.Panel2
	Frame.Parent = parent

	corner(Frame, 10)
	stroke(Frame, COLORS.DarkGray, 1)

	local Title = label(
		Frame,
		titleText,
		13,
		COLORS.White,
		Enum.Font.GothamBold
	)

	Title.Position = UDim2.fromOffset(16, 10)
	Title.Size = UDim2.new(1, -100, 0, 20)
	Title.TextXAlignment = Enum.TextXAlignment.Left

	local Desc = label(
		Frame,
		descText,
		9,
		COLORS.Gray,
		Enum.Font.GothamMedium
	)

	Desc.Position = UDim2.fromOffset(16, 32)
	Desc.Size = UDim2.new(1, -100, 0, 18)
	Desc.TextXAlignment = Enum.TextXAlignment.Left

	local Toggle = Instance.new("TextButton")
	Toggle.Size = UDim2.fromOffset(58, 30)
	Toggle.Position = UDim2.new(1, -74, 0.5, -15)
	Toggle.BackgroundColor3 = COLORS.DarkGray
	Toggle.Text = ""
	Toggle.AutoButtonColor = false
	Toggle.Parent = Frame

	corner(Toggle, 15)

	local Knob = Instance.new("Frame")
	Knob.Size = UDim2.fromOffset(24, 24)
	Knob.Position = UDim2.fromOffset(3, 3)
	Knob.BackgroundColor3 = COLORS.White
	Knob.Parent = Toggle

	corner(Knob, 12)

	local enabled = initial

	local function refresh()
		if enabled then
			tween(Toggle, 0.15, {
				BackgroundColor3 = COLORS.Pink
			})
			tween(Knob, 0.15, {
				Position = UDim2.new(1, -27, 0, 3)
			})
		else
			tween(Toggle, 0.15, {
				BackgroundColor3 = COLORS.DarkGray
			})
			tween(Knob, 0.15, {
				Position = UDim2.fromOffset(3, 3)
			})
		end
	end

	Toggle.MouseButton1Click:Connect(function()
		enabled = not enabled
		refresh()
		callback(enabled)
	end)

	refresh()

	return Frame
end

createToggle(
	AimContent,
	"PLAYER AIMBOT",
	"Targets only enemy players with active red Highlight ESP",
	false,
	function(value)
		Settings.PlayerAimbot = value
		if not value then
			CurrentTarget = nil
		end
	end
)

createToggle(
	AimContent,
	"NPC AIMBOT",
	"Targets the nearest valid NPC using the cached NPC list",
	false,
	function(value)
		Settings.NpcAimbot = value
		if not value then
			CurrentNpcTarget = nil
		end
	end
)

--==================================================
-- SELECTOR
--==================================================

local function createSelector(parent, titleText, values, currentValue, callback)
	local Frame = Instance.new("Frame")
	Frame.Size = UDim2.new(1, -4, 0, 58)
	Frame.BackgroundColor3 = COLORS.Panel2
	Frame.Parent = parent

	corner(Frame, 10)
	stroke(Frame, COLORS.DarkGray, 1)

	local Title = label(
		Frame,
		titleText,
		12,
		COLORS.White,
		Enum.Font.GothamBold
	)

	Title.Position = UDim2.fromOffset(16, 0)
	Title.Size = UDim2.new(0.5, 0, 1, 0)
	Title.TextXAlignment = Enum.TextXAlignment.Left

	local Button = Instance.new("TextButton")
	Button.Size = UDim2.fromOffset(170, 38)
	Button.Position = UDim2.new(1, -185, 0.5, -19)
	Button.BackgroundColor3 = COLORS.Panel
	Button.TextColor3 = COLORS.White
	Button.TextSize = 11
	Button.Font = Enum.Font.GothamBold
	Button.AutoButtonColor = false
	Button.Text = string.upper(currentValue)
	Button.Parent = Frame

	corner(Button, 9)
	stroke(Button, COLORS.DarkGray, 1)

	local index = table.find(values, currentValue) or 1

	Button.MouseButton1Click:Connect(function()
		index += 1

		if index > #values then
			index = 1
		end

		local value = values[index]
		Button.Text = string.upper(value)

		callback(value)

		tween(Button, 0.08, {
			Size = UDim2.fromOffset(162, 36)
		})

		task.delay(0.08, function()
			tween(Button, 0.08, {
				Size = UDim2.fromOffset(170, 38)
			})
		end)
	end)

	return Frame
end

createSelector(
	AimContent,
	"AIM PART",
	{"Head", "Torso", "HumanoidRootPart"},
	Settings.AimPart,
	function(value)
		Settings.AimPart = value
	end
)

--==================================================
-- SLIDER
--==================================================

local function createSlider(parent, titleText, min, max, current, callback)
	local Frame = Instance.new("Frame")
	Frame.Size = UDim2.new(1, -4, 0, 70)
	Frame.BackgroundColor3 = COLORS.Panel2
	Frame.Parent = parent

	corner(Frame, 10)
	stroke(Frame, COLORS.DarkGray, 1)

	local Title = label(
		Frame,
		titleText,
		12,
		COLORS.White,
		Enum.Font.GothamBold
	)

	Title.Position = UDim2.fromOffset(16, 9)
	Title.Size = UDim2.fromOffset(180, 20)
	Title.TextXAlignment = Enum.TextXAlignment.Left

	local ValueLabel = label(
		Frame,
		string.format("%.2f", current),
		12,
		COLORS.Pink,
		Enum.Font.GothamBold
	)

	ValueLabel.Position = UDim2.new(1, -70, 0, 9)
	ValueLabel.Size = UDim2.fromOffset(55, 20)
	ValueLabel.TextXAlignment = Enum.TextXAlignment.Right

	local Bar = Instance.new("Frame")
	Bar.Size = UDim2.new(1, -32, 0, 6)
	Bar.Position = UDim2.fromOffset(16, 44)
	Bar.BackgroundColor3 = COLORS.DarkGray
	Bar.Parent = Frame

	corner(Bar, 3)

	local Fill = Instance.new("Frame")
	Fill.Size = UDim2.new(
		(current - min) / (max - min),
		0,
		1,
		0
	)
	Fill.BackgroundColor3 = COLORS.Pink
	Fill.Parent = Bar

	corner(Fill, 3)

	local draggingSlider = false

	local function setValue(inputX)
		local relative = math.clamp(
			(inputX - Bar.AbsolutePosition.X) /
			Bar.AbsoluteSize.X,
			0,
			1
		)

		local value = min + (max - min) * relative

		value = math.floor(value * 100) / 100

		Fill.Size = UDim2.new(relative, 0, 1, 0)
		ValueLabel.Text = string.format("%.2f", value)

		callback(value)
	end

	Bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			draggingSlider = true
			setValue(input.Position.X)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not draggingSlider then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then

			setValue(input.Position.X)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			draggingSlider = false
		end
	end)

	return Frame
end

createSlider(
	AimContent,
	"AIM SMOOTHNESS",
	0.05,
	1,
	Settings.AimSmoothness,
	function(value)
		Settings.AimSmoothness = value
	end
)

createSlider(
	AimContent,
	"AIM RANGE",
	50,
	1500,
	Settings.AimRange,
	function(value)
		Settings.AimRange = math.floor(value)
	end
)

--==================================================
-- TARGET INFO
--==================================================

local TargetInfo = Instance.new("Frame")
TargetInfo.Size = UDim2.new(1, -4, 0, 100)
TargetInfo.BackgroundColor3 = COLORS.Panel2
TargetInfo.Parent = AimContent

corner(TargetInfo, 10)
stroke(TargetInfo, COLORS.Pink, 1, 0.45)

local TargetTitle = label(
	TargetInfo,
	"◎  CURRENT TARGET",
	12,
	COLORS.Pink,
	Enum.Font.GothamBold
)

TargetTitle.Position = UDim2.fromOffset(16, 10)
TargetTitle.Size = UDim2.new(1, -32, 0, 20)
TargetTitle.TextXAlignment = Enum.TextXAlignment.Left

local TargetLabel = label(
	TargetInfo,
	"No target",
	13,
	COLORS.White,
	Enum.Font.GothamBold
)

TargetLabel.Position = UDim2.fromOffset(16, 38)
TargetLabel.Size = UDim2.new(0.5, -20, 0, 22)
TargetLabel.TextXAlignment = Enum.TextXAlignment.Left

local TargetStats = label(
	TargetInfo,
	"Distance: —     HP: —     ESP: —",
	10,
	COLORS.Gray,
	Enum.Font.GothamMedium
)

TargetStats.Position = UDim2.fromOffset(16, 64)
TargetStats.Size = UDim2.new(1, -32, 0, 18)
TargetStats.TextXAlignment = Enum.TextXAlignment.Left

--==================================================
-- HITBOX PAGE
--==================================================

local HitboxPage, HitboxContent = createPage(
	"HITBOXES",
	"HITBOXES",
	"Combat hitbox debugging and visualization"
)

createBackButton(HitboxPage)

local function createValueControl(parent, titleText, value, minValue, maxValue, step, callback)
	local Frame = Instance.new("Frame")
	Frame.Size = UDim2.new(1, -4, 0, 64)
	Frame.BackgroundColor3 = COLORS.Panel2
	Frame.Parent = parent

	corner(Frame, 10)
	stroke(Frame, COLORS.DarkGray, 1)

	local Title = label(
		Frame,
		titleText,
		12,
		COLORS.White,
		Enum.Font.GothamBold
	)

	Title.Position = UDim2.fromOffset(16, 0)
	Title.Size = UDim2.fromOffset(180, 64)
	Title.TextXAlignment = Enum.TextXAlignment.Left

	local Minus = Instance.new("TextButton")
	Minus.Size = UDim2.fromOffset(38, 38)
	Minus.Position = UDim2.new(1, -150, 0.5, -19)
	Minus.BackgroundColor3 = COLORS.Panel
	Minus.Text = "−"
	Minus.TextColor3 = COLORS.White
	Minus.TextSize = 20
	Minus.Font = Enum.Font.GothamBold
	Minus.AutoButtonColor = false
	Minus.Parent = Frame

	corner(Minus, 8)

	local Value = label(
		Frame,
		"x" .. tostring(value),
		13,
		COLORS.Pink,
		Enum.Font.GothamBold
	)

	Value.Position = UDim2.new(1, -105, 0, 0)
	Value.Size = UDim2.fromOffset(65, 64)
	Value.TextXAlignment = Enum.TextXAlignment.Center

	local Plus = Instance.new("TextButton")
	Plus.Size = UDim2.fromOffset(38, 38)
	Plus.Position = UDim2.new(1, -55, 0.5, -19)
	Plus.BackgroundColor3 = COLORS.Panel
	Plus.Text = "+"
	Plus.TextColor3 = COLORS.White
	Plus.TextSize = 19
	Plus.Font = Enum.Font.GothamBold
	Plus.AutoButtonColor = false
	Plus.Parent = Frame

	corner(Plus, 8)

	local function update(newValue)
		value = math.clamp(
			math.floor(newValue / step + 0.5) * step,
			minValue,
			maxValue
		)

		Value.Text = "x" .. tostring(value)
		callback(value)
	end

	Minus.MouseButton1Click:Connect(function()
		update(value - step)
	end)

	Plus.MouseButton1Click:Connect(function()
		update(value + step)
	end)

	return Frame
end

createValueControl(
	HitboxContent,
	"PLAYER HITBOX",
	Settings.PlayerHitbox,
	1,
	25,
	0.5,
	function(value)
		Settings.PlayerHitbox = value
		updatePlayerHitboxes()
	end
)

createToggle(
	HitboxContent,
	"SHOW PLAYER HITBOXES",
	"Display player hitbox debug volumes",
	false,
	function(value)
		Settings.ShowPlayerHitboxes = value
		updatePlayerHitboxes()
	end
)

createValueControl(
	HitboxContent,
	"NPC HITBOX",
	Settings.NpcHitbox,
	1,
	25,
	0.5,
	function(value)
		Settings.NpcHitbox = value
		updateNpcHitboxes()
	end
)

createToggle(
	HitboxContent,
	"SHOW NPC HITBOXES",
	"Display NPC hitbox debug volumes",
	false,
	function(value)
		Settings.ShowNpcHitboxes = value
		updateNpcHitboxes()
	end
)

local ResetHitbox = Instance.new("TextButton")
ResetHitbox.Size = UDim2.new(1, -4, 0, 48)
ResetHitbox.BackgroundColor3 = COLORS.Panel2
ResetHitbox.Text = "RESET HITBOX SETTINGS"
ResetHitbox.TextColor3 = COLORS.White
ResetHitbox.TextSize = 12
ResetHitbox.Font = Enum.Font.GothamBold
ResetHitbox.AutoButtonColor = false
ResetHitbox.Parent = HitboxContent

corner(ResetHitbox, 10)
stroke(ResetHitbox, COLORS.Pink, 1, 0.5)

ResetHitbox.MouseButton1Click:Connect(function()
	Settings.PlayerHitbox = 1
	Settings.NpcHitbox = 1

	updatePlayerHitboxes()
	updateNpcHitboxes()
end)

--==================================================
-- DEBUG PAGE
--==================================================

local DebugPage, DebugContent = createPage(
	"DEBUG",
	"DEBUG",
	"Performance and targeting diagnostics"
)

createBackButton(DebugPage)

local DebugCard = Instance.new("Frame")
DebugCard.Size = UDim2.new(1, -4, 0, 180)
DebugCard.BackgroundColor3 = COLORS.Panel2
DebugCard.Parent = DebugContent

corner(DebugCard, 11)
stroke(DebugCard, COLORS.DarkGray, 1)

local DebugText = label(
	DebugCard,
	"",
	12,
	COLORS.White,
	Enum.Font.Code
)

DebugText.Position = UDim2.fromOffset(16, 14)
DebugText.Size = UDim2.new(1, -32, 1, -28)
DebugText.TextXAlignment = Enum.TextXAlignment.Left
DebugText.TextYAlignment = Enum.TextYAlignment.Top

local DebugRefresh = Instance.new("TextButton")
DebugRefresh.Size = UDim2.new(1, -4, 0, 48)
DebugRefresh.BackgroundColor3 = COLORS.Panel2
DebugRefresh.Text = "REFRESH DEBUG"
DebugRefresh.TextColor3 = COLORS.White
DebugRefresh.TextSize = 12
DebugRefresh.Font = Enum.Font.GothamBold
DebugRefresh.AutoButtonColor = false
DebugRefresh.Parent = DebugContent

corner(DebugRefresh, 10)
stroke(DebugRefresh, COLORS.Pink, 1, 0.45)

--==================================================
-- MISC PAGE
--==================================================

local MiscPage, MiscContent = createPage(
	"MISC",
	"MISC",
	"General interface and utility settings"
)

createBackButton(MiscPage)

createToggle(
	MiscContent,
	"UI ANIMATIONS",
	"Enable transitions and interaction animations",
	true,
	function(value)
		Settings.Animations = value
	end
)

createToggle(
	MiscContent,
	"UI SOUND",
	"Reserved for interface sound effects",
	true,
	function(value)
		-- reserved
	end
)

local ResetUI = Instance.new("TextButton")
ResetUI.Size = UDim2.new(1, -4, 0, 48)
ResetUI.BackgroundColor3 = COLORS.Panel2
ResetUI.Text = "RESET UI POSITION"
ResetUI.TextColor3 = COLORS.White
ResetUI.TextSize = 12
ResetUI.Font = Enum.Font.GothamBold
ResetUI.AutoButtonColor = false
ResetUI.Parent = MiscContent

corner(ResetUI, 10)
stroke(ResetUI, COLORS.DarkGray, 1)

--==================================================
-- NAVIGATION
--==================================================

local NavButtons = {}

local function registerNav(name, icon)
	local button, iconObj, textObj, arrowObj, strokeObj =
		createNavButton(icon, name)

	NavButtons[name] = {
		Button = button,
		Icon = iconObj,
		Text = textObj,
		Arrow = arrowObj,
		Stroke = strokeObj,
	}

	button.MouseButton1Click:Connect(function()
		showPage(name)
	end)
end

registerNav("AIM", "◎")
registerNav("HITBOXES", "◇")
registerNav("DEBUG", "⚙")
registerNav("MISC", "✦")

--==================================================
-- SHOW PAGE
--==================================================

function showPage(name)
	local pageData = Pages[name]

	if not pageData then
		return
	end

	local newPage = pageData.Frame

	if CurrentPage == name then
		return
	end

	local oldPage = CurrentPage and Pages[CurrentPage]

	CurrentPage = name

	for navName, data in pairs(NavButtons) do
		local active = navName == name

		if active then
			tween(data.Button, 0.15, {
				BackgroundColor3 = Color3.fromRGB(70, 15, 40)
			})

			tween(data.Icon, 0.15, {
				TextColor3 = COLORS.Pink
			})

			tween(data.Arrow, 0.15, {
				TextColor3 = COLORS.Pink
			})

			tween(data.Stroke, 0.15, {
				Color = COLORS.Pink,
				Transparency = 0.25
			})
		else
			tween(data.Button, 0.15, {
				BackgroundColor3 = COLORS.Panel2
			})

			tween(data.Icon, 0.15, {
				TextColor3 = COLORS.Gray
			})

			tween(data.Arrow, 0.15, {
				TextColor3 = COLORS.Gray
			})

			tween(data.Stroke, 0.15, {
				Color = COLORS.DarkGray,
				Transparency = 0
			})
		end
	end

	newPage.Visible = true

	if not oldPage then
		newPage.Position = UDim2.fromScale(0, 0)
		return
	end

	if not Settings.Animations then
		oldPage.Visible = false
		newPage.Position = UDim2.fromScale(0, 0)
		return
	end

	newPage.Position = UDim2.fromScale(1, 0)

	tween(
		oldPage,
		0.22,
		{
			Position = UDim2.fromScale(-1, 0)
		},
		Enum.EasingStyle.Quart,
		Enum.EasingDirection.In
	)

	tween(
		newPage,
		0.28,
		{
			Position = UDim2.fromScale(0, 0)
		},
		Enum.EasingStyle.Quart,
		Enum.EasingDirection.Out
	)

	task.delay(0.3, function()
		if oldPage then
			oldPage.Visible = false
		end
	end)
end

--==================================================
-- HOME NAVIGATION
--==================================================

function showPage(name)
	local pageData = Pages[name]

	if not pageData then
		return
	end

	local newPage = pageData.Frame

	if CurrentPage == name then
		return
	end

	local oldPage = CurrentPage and Pages[CurrentPage]
	CurrentPage = name

	if name == "HOME" then
		for _, data in pairs(NavButtons) do
			tween(data.Button, 0.12, {
				BackgroundColor3 = COLORS.Panel2
			})
		end
	end

	if oldPage == nil then
		newPage.Visible = true
		newPage.Position = UDim2.fromScale(0, 0)
		return
	end

	newPage.Visible = true
	newPage.Position = UDim2.fromScale(1, 0)

	if Settings.Animations then
		tween(
			oldPage,
			0.2,
			{
				Position = UDim2.fromScale(-1, 0)
			},
			Enum.EasingStyle.Quart,
			Enum.EasingDirection.In
		)

		tween(
			newPage,
			0.25,
			{
				Position = UDim2.fromScale(0, 0)
			},
			Enum.EasingStyle.Quart,
			Enum.EasingDirection.Out
		)

		task.delay(0.27, function()
			if oldPage then
				oldPage.Visible = false
			end
		end)
	else
		oldPage.Visible = false
		newPage.Position = UDim2.fromScale(0, 0)
	end
end

--==================================================
-- AIM SYSTEM
--==================================================

local CurrentTarget = nil
local CurrentNpcTarget = nil

--==================================================
-- ENEMY
--==================================================

local function isEnemy(player)
	if player == LocalPlayer then
		return false
	end

	local character = player.Character
	if not character then
		return false
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if not humanoid or humanoid.Health <= 0 then
		return false
	end

	if LocalPlayer.Team and player.Team then
		return LocalPlayer.Team ~= player.Team
	end

	return true
end

--==================================================
-- RED ESP
--==================================================

local function isRedColor(color)
	if not color then
		return false
	end

	return color.R > 0.65
		and color.R > color.G * 1.8
		and color.R > color.B * 1.8
end

local function getSystemRedHighlight(player)
	local character = player.Character

	if not character then
		return nil
	end

	for _, object in ipairs(character:GetDescendants()) do
		if object:IsA("Highlight")
			and object.Enabled then

			if isRedColor(object.FillColor)
				or isRedColor(object.OutlineColor) then

				return object
			end
		end
	end

	return nil
end

local function isValidAimTarget(player)
	if not player then
		return false
	end

	if not isEnemy(player) then
		return false
	end

	return getSystemRedHighlight(player) ~= nil
end

--==================================================
-- AIM PART
--==================================================

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

--==================================================
-- LOCAL ROOT
--==================================================

local function getLocalRoot()
	local character = LocalPlayer.Character

	if not character then
		return nil
	end

	return character:FindFirstChild("HumanoidRootPart")
end

--==================================================
-- PLAYER TARGET
--==================================================

local function getAimTarget()
	local localRoot = getLocalRoot()

	if not localRoot then
		CurrentTarget = nil
		return nil
	end

	local closestPlayer = nil
	local closestPart = nil
	local closestDistance = Settings.AimRange

	for _, player in ipairs(Players:GetPlayers()) do
		if isValidAimTarget(player) then

			local character = player.Character
			local root = character
				and character:FindFirstChild("HumanoidRootPart")

			local humanoid = character
				and character:FindFirstChildOfClass("Humanoid")

			if root
				and humanoid
				and humanoid.Health > 0 then

				local distance =
					(root.Position - localRoot.Position).Magnitude

				if distance <= Settings.AimRange
					and distance < closestDistance then

					local part = getAimPart(character)

					if part then
						closestDistance = distance
						closestPlayer = player
						closestPart = part
					end
				end
			end
		end
	end

	CurrentTarget = closestPlayer

	return closestPart
end

--==================================================
-- NPC CACHE
--==================================================

local NpcCache = {}

local function isNPC(model)
	if not model:IsA("Model") then
		return false
	end

	if Players:GetPlayerFromCharacter(model) then
		return false
	end

	local humanoid = model:FindFirstChildOfClass("Humanoid")
	local root = model:FindFirstChild("HumanoidRootPart")

	if not humanoid or not root then
		return false
	end

	return humanoid.Health > 0
end

local function rebuildNpcCache()
	table.clear(NpcCache)

	for _, object in ipairs(workspace:GetDescendants()) do
		if isNPC(object) then
			table.insert(NpcCache, object)
		end
	end
end

workspace.DescendantAdded:Connect(function(object)
	if object:IsA("Model") and isNPC(object) then
		if not table.find(NpcCache, object) then
			table.insert(NpcCache, object)
		end
	end
end)

workspace.DescendantRemoving:Connect(function(object)
	local index = table.find(NpcCache, object)

	if index then
		table.remove(NpcCache, index)
	end
end)

--==================================================
-- NPC TARGET
--==================================================

local function getNpcAimTarget()
	local localRoot = getLocalRoot()

	if not localRoot then
		CurrentNpcTarget = nil
		return nil
	end

	local closestNpc = nil
	local closestPart = nil
	local closestDistance = Settings.AimRange

	for i = #NpcCache, 1, -1 do
		local npc = NpcCache[i]

		if not npc or not npc.Parent then
			table.remove(NpcCache, i)
			continue
		end

		local humanoid =
			npc:FindFirstChildOfClass("Humanoid")

		local root =
			npc:FindFirstChild("HumanoidRootPart")

		if humanoid
			and humanoid.Health > 0
			and root then

			local distance =
				(root.Position - localRoot.Position).Magnitude

			if distance <= Settings.AimRange
				and distance < closestDistance then

				local part = getAimPart(npc)

				if part then
					closestDistance = distance
					closestNpc = npc
					closestPart = part
				end
			end
		end
	end

	CurrentNpcTarget = closestNpc

	return closestPart
end

--==================================================
-- HITBOX VISUALIZATION
--==================================================

local PlayerHitboxObjects = {}
local NpcHitboxObjects = {}

function createHitbox(player)
	if not player.Character then
		return
	end

	local root =
		player.Character:FindFirstChild("HumanoidRootPart")

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

	local box = Instance.new("BoxHandleAdornment")
	box.Name = "AdminPlayerHitbox"
	box.Adornee = root
	box.Size = root.Size * Settings.PlayerHitbox
	box.Color3 = COLORS.Pink
	box.Transparency = 0.78
	box.AlwaysOnTop = true
	box.ZIndex = 5
	box.Parent = root

	PlayerHitboxObjects[player] = box
end

function updatePlayerHitboxes()
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			createHitbox(player)
		end
	end
end

function updateNpcHitboxes()
	for model, object in pairs(NpcHitboxObjects) do
		if object then
			object:Destroy()
		end

		NpcHitboxObjects[model] = nil
	end

	if not Settings.ShowNpcHitboxes then
		return
	end

	for _, npc in ipairs(NpcCache) do
		if npc and npc.Parent then
			local root = npc:FindFirstChild("HumanoidRootPart")

			if root then
				local box = Instance.new("BoxHandleAdornment")
				box.Name = "AdminNPCHitbox"
				box.Adornee = root
				box.Size = root.Size * Settings.NpcHitbox
				box.Color3 = COLORS.Pink
				box.Transparency = 0.78
				box.AlwaysOnTop = true
				box.ZIndex = 5
				box.Parent = root

				NpcHitboxObjects[npc] = box
			end
		end
	end
end

--==================================================
-- DEBUG UPDATE
--==================================================

local function updateDebug()
	local fps = math.floor(1 / math.max(RunService.RenderStepped:Wait(), 0.001))

	local playerTargetText = "None"
	local npcTargetText = "None"

	if CurrentTarget then
		playerTargetText = CurrentTarget.Name
	end

	if CurrentNpcTarget then
		npcTargetText = CurrentNpcTarget.Name
	end

	DebugText.Text =
		"COMBAT DEBUG\n\n" ..
		"Player Aimbot    : " .. tostring(Settings.PlayerAimbot) .. "\n" ..
		"NPC Aimbot       : " .. tostring(Settings.NpcAimbot) .. "\n\n" ..
		"NPC Cache        : " .. tostring(#NpcCache) .. "\n" ..
		"Player Target    : " .. playerTargetText .. "\n" ..
		"NPC Target       : " .. npcTargetText .. "\n\n" ..
		"Player Hitbox    : x" .. tostring(Settings.PlayerHitbox) .. "\n" ..
		"NPC Hitbox       : x" .. tostring(Settings.NpcHitbox)
end

DebugRefresh.MouseButton1Click:Connect(updateDebug)

--==================================================
-- TARGET INFO UPDATE
--==================================================

local function updateTargetInfo()
	if CurrentTarget then
		local character = CurrentTarget.Character
		local humanoid = character
			and character:FindFirstChildOfClass("Humanoid")
		local root = character
			and character:FindFirstChild("HumanoidRootPart")

		local localRoot = getLocalRoot()

		local distance = 0

		if root and localRoot then
			distance =
				(root.Position - localRoot.Position).Magnitude
		end

		TargetLabel.Text =
			CurrentTarget.Name

		TargetStats.Text =
			"Distance: "
			.. math.floor(distance)
			.. "     HP: "
			.. (humanoid and math.floor(humanoid.Health) or 0)
			.. "     ESP: ACTIVE"

	elseif CurrentNpcTarget then

		local humanoid =
			CurrentNpcTarget:FindFirstChildOfClass("Humanoid")

		local root =
			CurrentNpcTarget:FindFirstChild("HumanoidRootPart")

		local localRoot = getLocalRoot()

		local distance = 0

		if root and localRoot then
			distance =
				(root.Position - localRoot.Position).Magnitude
		end

		TargetLabel.Text =
			"NPC: " .. CurrentNpcTarget.Name

		TargetStats.Text =
			"Distance: "
			.. math.floor(distance)
			.. "     HP: "
			.. (humanoid and math.floor(humanoid.Health) or 0)
			.. "     ESP: —"

	else

		TargetLabel.Text = "No target"
		TargetStats.Text = "Distance: —     HP: —     ESP: —"
	end
end

--==================================================
-- AIM LOOP
--==================================================

RunService:BindToRenderStep(
	"CombatAdminAimbotV2",
	Enum.RenderPriority.Camera.Value + 1,
	function()
		local Camera = workspace.CurrentCamera

		if not Camera then
			return
		end

		-- PLAYER AIM

		if Settings.PlayerAimbot then
			local target = getAimTarget()

			if target
				and CurrentTarget
				and isValidAimTarget(CurrentTarget) then

				local targetCFrame =
					CFrame.lookAt(
						Camera.CFrame.Position,
						target.Position
					)

				Camera.CFrame =
					Camera.CFrame:Lerp(
						targetCFrame,
						Settings.AimSmoothness
					)

				updateTargetInfo()
				return
			end
		else
			CurrentTarget = nil
		end

		-- NPC AIM

		if Settings.NpcAimbot then
			local target = getNpcAimTarget()

			if target
				and CurrentNpcTarget then

				local humanoid =
					CurrentNpcTarget:FindFirstChildOfClass("Humanoid")

				if humanoid and humanoid.Health > 0 then
					local targetCFrame =
						CFrame.lookAt(
							Camera.CFrame.Position,
							target.Position
						)

					Camera.CFrame =
						Camera.CFrame:Lerp(
							targetCFrame,
							Settings.AimSmoothness
						)

					updateTargetInfo()
					return
				end
			end
		else
			CurrentNpcTarget = nil
		end

		updateTargetInfo()
	end
)

--==================================================
-- PLAYER EVENTS
--==================================================

local function setupPlayer(player)
	if player == LocalPlayer then
		return
	end

	player.CharacterAdded:Connect(function()
		if CurrentTarget == player then
			CurrentTarget = nil
		end

		task.wait(0.4)

		createHitbox(player)
	end)

	player:GetPropertyChangedSignal("Team"):Connect(function()
		if CurrentTarget == player
			and not isEnemy(player) then

			CurrentTarget = nil
		end
	end)

	if player.Character then
		task.defer(function()
			createHitbox(player)
		end)
	end
end

for _, player in ipairs(Players:GetPlayers()) do
	setupPlayer(player)
end

Players.PlayerAdded:Connect(setupPlayer)

Players.PlayerRemoving:Connect(function(player)
	if CurrentTarget == player then
		CurrentTarget = nil
	end

	if PlayerHitboxObjects[player] then
		PlayerHitboxObjects[player]:Destroy()
		PlayerHitboxObjects[player] = nil
	end
end)

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

	local delta =
		input.Position - dragStart

	Main.Position =
		UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
end)

--==================================================
-- OPEN / CLOSE
--==================================================

local function openPanel()
	Main.Visible = true

	if Settings.Animations then
		Main.Size = UDim2.fromOffset(850, 0)

		tween(
			Main,
			0.3,
			{
				Size = UDim2.fromOffset(950, 570)
			},
			Enum.EasingStyle.Back,
			Enum.EasingDirection.Out
		)
	else
		Main.Size = UDim2.fromOffset(950, 570)
	end

	showPage("HOME")
end

local function closePanel()
	if not Main.Visible then
		return
	end

	if Settings.Animations then
		local t = TweenService:Create(
			Main,
			TweenInfo.new(
				0.2,
				Enum.EasingStyle.Quad,
				Enum.EasingDirection.In
			),
			{
				Size = UDim2.fromOffset(950, 0)
			}
		)

		t:Play()

		t.Completed:Connect(function()
			Main.Visible = false
		end)
	else
		Main.Visible = false
	end
end

OpenButton.MouseButton1Click:Connect(function()
	if Main.Visible then
		closePanel()
	else
		openPanel()
	end
end)

Close.MouseButton1Click:Connect(closePanel)

--==================================================
-- KEYBOARD
--==================================================

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end

	-- RightShift
	if input.KeyCode == Enum.KeyCode.RightShift then
		if Main.Visible then
			closePanel()
		else
			openPanel()
		end
	end

	-- H
	if input.KeyCode == Enum.KeyCode.H then
		Settings.ShowPlayerHitboxes =
			not Settings.ShowPlayerHitboxes

		updatePlayerHitboxes()
	end

	-- [ ]
	if input.KeyCode == Enum.KeyCode.RightBracket then
		Settings.PlayerHitbox =
			math.min(
				Settings.PlayerHitbox + 0.5,
				25
			)

		updatePlayerHitboxes()
	end

	if input.KeyCode == Enum.KeyCode.LeftBracket then
		Settings.PlayerHitbox =
			math.max(
				Settings.PlayerHitbox - 0.5,
				1
			)

		updatePlayerHitboxes()
	end
end)

--==================================================
-- RESET UI
--==================================================

ResetUI.MouseButton1Click:Connect(function()
	Main.Position =
		UDim2.new(
			0.5,
			-475,
			0.5,
			-285
		)

	Main.Size =
		UDim2.fromOffset(950, 570)
end)

--==================================================
-- INITIALIZE
--==================================================

rebuildNpcCache()

task.wait(0.5)

updatePlayerHitboxes()
updateNpcHitboxes()

-- Начальная страница
showPage("HOME")

print("[Combat Admin Panel V2] Loaded")
