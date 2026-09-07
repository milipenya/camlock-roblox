--// COMBAT ADMIN PANEL
--// LocalScript -> StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

local GodModeEvent =
	ReplicatedStorage:WaitForChild(
		"CombatGodModeEvent"
	)

--==================================================
-- SETTINGS
--==================================================

local Settings = {

	-- Player Aimbot
	Aimbot = false,

	-- NPC Aimbot
	NpcAimbot = false,

	-- God Mode
	GodMode = false,

	-- Hitboxes
	PlayerHitbox = 2.5,
	NpcHitbox = 2,

	ShowPlayerHitboxes = false,
	ShowNpcHitboxes = false,

	-- Aim
	AimPart = "Head",
	AimSmoothness = 0.25,
	AimRange = 500,
}

--==================================================
-- GUI
--==================================================

local ScreenGui =
	Instance.new("ScreenGui")

ScreenGui.Name =
	"CombatAdminPanel"

ScreenGui.ResetOnSpawn =
	false

ScreenGui.ZIndexBehavior =
	Enum.ZIndexBehavior.Sibling

ScreenGui.Parent =
	PlayerGui

--==================================================
-- OPEN BUTTON
--==================================================

local OpenButton =
	Instance.new("TextButton")

OpenButton.Name =
	"OpenCombat"

OpenButton.Size =
	UDim2.fromOffset(48, 48)

OpenButton.Position =
	UDim2.new(
		0,
		20,
		0.5,
		-24
	)

OpenButton.BackgroundColor3 =
	Color3.fromRGB(
		10,
		10,
		12
	)

OpenButton.Text =
	"⚔"

OpenButton.TextColor3 =
	Color3.fromRGB(
		255,
		50,
		110
	)

OpenButton.TextSize =
	24

OpenButton.Font =
	Enum.Font.GothamBold

OpenButton.AutoButtonColor =
	false

OpenButton.Parent =
	ScreenGui

local OpenCorner =
	Instance.new("UICorner")

OpenCorner.CornerRadius =
	UDim.new(0, 12)

OpenCorner.Parent =
	OpenButton

local OpenStroke =
	Instance.new("UIStroke")

OpenStroke.Color =
	Color3.fromRGB(
		255,
		40,
		100
	)

OpenStroke.Thickness =
	1.5

OpenStroke.Parent =
	OpenButton

--==================================================
-- MAIN
--==================================================

local Main =
	Instance.new("Frame")

Main.Name =
	"Main"

Main.Size =
	UDim2.fromOffset(
		310,
		500
	)

Main.Position =
	UDim2.new(
		0,
		80,
		0.5,
		-250
	)

Main.BackgroundColor3 =
	Color3.fromRGB(
		8,
		8,
		10
	)

Main.BorderSizePixel =
	0

Main.Visible =
	true

Main.Parent =
	ScreenGui

local MainCorner =
	Instance.new("UICorner")

MainCorner.CornerRadius =
	UDim.new(0, 14)

MainCorner.Parent =
	Main

local MainStroke =
	Instance.new("UIStroke")

MainStroke.Color =
	Color3.fromRGB(
		255,
		40,
		100
	)

MainStroke.Thickness =
	1.5

MainStroke.Transparency =
	0.2

MainStroke.Parent =
	Main

--==================================================
-- HEADER
--==================================================

local Header =
	Instance.new("Frame")

Header.Size =
	UDim2.new(
		1,
		0,
		0,
		55
	)

Header.BackgroundColor3 =
	Color3.fromRGB(
		15,
		15,
		18
	)

Header.BorderSizePixel =
	0

Header.Parent =
	Main

local HeaderCorner =
	Instance.new("UICorner")

HeaderCorner.CornerRadius =
	UDim.new(0, 14)

HeaderCorner.Parent =
	Header

local Title =
	Instance.new("TextLabel")

Title.BackgroundTransparency =
	1

Title.Position =
	UDim2.fromOffset(
		18,
		7
	)

Title.Size =
	UDim2.new(
		1,
		-70,
		0,
		25
	)

Title.Text =
	"COMBAT"

Title.TextColor3 =
	Color3.fromRGB(
		255,
		255,
		255
	)

Title.TextSize =
	20

Title.Font =
	Enum.Font.GothamBold

Title.TextXAlignment =
	Enum.TextXAlignment.Left

Title.Parent =
	Header

local Subtitle =
	Instance.new("TextLabel")

Subtitle.BackgroundTransparency =
	1

Subtitle.Position =
	UDim2.fromOffset(
		19,
		30
	)

Subtitle.Size =
	UDim2.new(
		1,
		-70,
		0,
		18
	)

Subtitle.Text =
	"ADMIN DEBUG PANEL"

Subtitle.TextColor3 =
	Color3.fromRGB(
		255,
		50,
		110
	)

Subtitle.TextSize =
	10

Subtitle.Font =
	Enum.Font.GothamBold

Subtitle.TextXAlignment =
	Enum.TextXAlignment.Left

Subtitle.Parent =
	Header

local Close =
	Instance.new("TextButton")

Close.Size =
	UDim2.fromOffset(
		35,
		35
	)

Close.Position =
	UDim2.new(
		1,
		-45,
		0,
		10
	)

Close.BackgroundColor3 =
	Color3.fromRGB(
		30,
		30,
		34
	)

Close.Text =
	"×"

Close.TextColor3 =
	Color3.fromRGB(
		255,
		70,
		110
	)

Close.TextSize =
	24

Close.Font =
	Enum.Font.GothamBold

Close.AutoButtonColor =
	false

Close.Parent =
	Header

local CloseCorner =
	Instance.new("UICorner")

CloseCorner.CornerRadius =
	UDim.new(0, 9)

CloseCorner.Parent =
	Close

--==================================================
-- CONTENT
--==================================================

local Content =
	Instance.new("ScrollingFrame")

Content.Position =
	UDim2.fromOffset(
		10,
		65
	)

Content.Size =
	UDim2.new(
		1,
		-20,
		1,
		-75
	)

Content.BackgroundTransparency =
	1

Content.BorderSizePixel =
	0

Content.ScrollBarThickness =
	3

Content.ScrollBarImageColor3 =
	Color3.fromRGB(
		255,
		40,
		100
	)

Content.CanvasSize =
	UDim2.new(
		0,
		0,
		0,
		0
	)

Content.Parent =
	Main

local Layout =
	Instance.new("UIListLayout")

Layout.Padding =
	UDim.new(
		0,
		7
	)

Layout.SortOrder =
	Enum.SortOrder.LayoutOrder

Layout.Parent =
	Content

local Padding =
	Instance.new("UIPadding")

Padding.PaddingLeft =
	UDim.new(
		0,
		3
	)

Padding.PaddingRight =
	UDim.new(
		0,
		3
	)

Padding.PaddingBottom =
	UDim.new(
		0,
		10
	)

Padding.Parent =
	Content

Layout:GetPropertyChangedSignal(
		"AbsoluteContentSize"
):Connect(function()

	Content.CanvasSize =
		UDim2.new(
			0,
			0,
			0,
			Layout.AbsoluteContentSize.Y
				+ 15
		)
end)

--==================================================
-- BUTTON CREATOR
--==================================================

local function createButton(text)

	local Button =
		Instance.new("TextButton")

	Button.Size =
		UDim2.new(
			1,
			-6,
			0,
			42
		)

	Button.BackgroundColor3 =
		Color3.fromRGB(
			18,
			18,
			21
		)

	Button.BorderSizePixel =
		0

	Button.Text =
		text

	Button.TextColor3 =
		Color3.fromRGB(
			255,
			255,
			255
		)

	Button.TextSize =
		13

	Button.Font =
		Enum.Font.GothamBold

	Button.AutoButtonColor =
		false

	Button.Parent =
		Content

	local Corner =
		Instance.new("UICorner")

	Corner.CornerRadius =
		UDim.new(
			0,
			9
		)

	Corner.Parent =
	Button

	local Stroke =
		Instance.new("UIStroke")

	Stroke.Color =
		Color3.fromRGB(
			45,
			45,
			50
		)

	Stroke.Thickness =
		1

	Stroke.Parent =
	Button

	Button.MouseEnter:Connect(
		function()

			TweenService:Create(
				Button,
				TweenInfo.new(0.12),
				{
					BackgroundColor3 =
						Color3.fromRGB(
							35,
							20,
							27
						)
				}
			):Play()
		end
	)

	Button.MouseLeave:Connect(
		function()

			TweenService:Create(
				Button,
				TweenInfo.new(0.12),
				{
					BackgroundColor3 =
						Color3.fromRGB(
							18,
							18,
							21
						)
				}
			):Play()
		end
	)

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

	local humanoid =
		player.Character:FindFirstChildOfClass(
			"Humanoid"
		)

	if not humanoid
		or humanoid.Health <= 0 then

		return false
	end

	if LocalPlayer.Team
		and player.Team then

		return LocalPlayer.Team
			~= player.Team
	end

	return true
end

--==================================================
-- SYSTEM RED ESP DETECTOR
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

	local character =
		player.Character

	if not character then
		return nil
	end

	for _, object in ipairs(
		character:GetDescendants()
	) do

		if object:IsA("Highlight") then

			if not object.Enabled then
				continue
			end

			local redFill =
				isRedColor(
					object.FillColor
				)

			local redOutline =
				isRedColor(
					object.OutlineColor
				)

			if redFill
				or redOutline then

				return object
			end
		end
	end

	return nil
end

--==================================================
-- PLAYER AIM VALIDATION
--==================================================

local function isValidAimTarget(player)

	if not player then
		return false
	end

	if not isEnemy(player) then
		return false
	end

	local highlight =
		getSystemRedHighlight(
			player
		)

	if not highlight then
		return false
	end

	if not highlight.Enabled then
		return false
	end

	return true
end

--==================================================
-- AIM PART
--==================================================

local function getAimPart(character)

	if not character then
		return nil
	end

	if Settings.AimPart == "Head" then

		return character:FindFirstChild(
			"Head"
		)

	elseif Settings.AimPart == "Torso" then

		return character:FindFirstChild(
			"UpperTorso"
		)
			or character:FindFirstChild(
				"Torso"
			)

	elseif Settings.AimPart ==
		"HumanoidRootPart" then

		return character:FindFirstChild(
			"HumanoidRootPart"
		)
	end

	return character:FindFirstChild(
		"Head"
	)
end

--==================================================
-- LOCAL ROOT
--==================================================

local function getLocalRoot()

	local character =
		LocalPlayer.Character

	if not character then
		return nil
	end

	return character:FindFirstChild(
		"HumanoidRootPart"
	)
end

--==================================================
-- CURRENT TARGETS
--==================================================

local CurrentTarget = nil
local CurrentNpcTarget = nil

--==================================================
-- FIND NEAREST PLAYER WITH SYSTEM ESP
--==================================================

local function getAimTarget()

	local localRoot =
		getLocalRoot()

	if not localRoot then

		CurrentTarget = nil

		return nil
	end

	local closestPlayer = nil
	local closestPart = nil
	local closestDistance =
		Settings.AimRange

	for _, player in ipairs(
		Players:GetPlayers()
	) do

		if isValidAimTarget(player) then

			local character =
				player.Character

			local humanoid =
				character:FindFirstChildOfClass(
					"Humanoid"
				)

			local root =
				character:FindFirstChild(
					"HumanoidRootPart"
				)

			if humanoid
				and humanoid.Health > 0
				and root then

				local distance =
					(
						root.Position
						- localRoot.Position
					).Magnitude

				if distance <=
					Settings.AimRange
					and distance <
					closestDistance then

					local part =
						getAimPart(
							character
						)

					if part then

						closestDistance =
							distance

						closestPlayer =
							player

						closestPart =
							part
					end
				end
			end
		end
	end

	CurrentTarget =
		closestPlayer

	return closestPart
end

--==================================================
-- NPC CHECK
--==================================================

local function isNPC(model)

	if not model:IsA("Model") then
		return false
	end

	if Players:GetPlayerFromCharacter(
		model
	) then

		return false
	end

	local humanoid =
		model:FindFirstChildOfClass(
			"Humanoid"
		)

	local root =
		model:FindFirstChild(
			"HumanoidRootPart"
		)

	if not humanoid
		or not root then

		return false
	end

	if humanoid.Health <= 0 then
		return false
	end

	return true
end

--==================================================
-- FIND NEAREST NPC
--==================================================

local function getNpcAimTarget()

	local localRoot =
		getLocalRoot()

	if not localRoot then

		CurrentNpcTarget =
			nil

		return nil
	end

	local closestNpc = nil
	local closestPart = nil
	local closestDistance =
		Settings.AimRange

	for _, object in ipairs(
		workspace:GetDescendants()
	) do

		if isNPC(object) then

			local humanoid =
				object:FindFirstChildOfClass(
					"Humanoid"
				)

			local root =
				object:FindFirstChild(
					"HumanoidRootPart"
				)

			if humanoid
				and humanoid.Health > 0
				and root then

				local distance =
					(
						root.Position
						- localRoot.Position
					).Magnitude

				if distance <=
					Settings.AimRange
					and distance <
					closestDistance then

					local part =
						getAimPart(
							object
						)

					if part then

						closestDistance =
							distance

						closestNpc =
							object

						closestPart =
							part
					end
				end
			end
		end
	end

	CurrentNpcTarget =
		closestNpc

	return closestPart
end

--==================================================
-- PLAYER AIMBOT BUTTON
--==================================================

local AimbotButton =
	createButton(
		"PLAYER AIMBOT: OFF"
	)

AimbotButton.MouseButton1Click:Connect(
	function()

		Settings.Aimbot =
			not Settings.Aimbot

		if Settings.Aimbot then

			AimbotButton.Text =
				"PLAYER AIMBOT: ON"

			AimbotButton.TextColor3 =
				Color3.fromRGB(
					255,
					50,
					110
				)

		else

			AimbotButton.Text =
				"PLAYER AIMBOT: OFF"

			AimbotButton.TextColor3 =
				Color3.fromRGB(
					255,
					255,
					255
				)

			CurrentTarget =
				nil
		end
	end
)

--==================================================
-- NPC AIMBOT BUTTON
--==================================================

local NpcAimbotButton =
	createButton(
		"NPC AIMBOT: OFF"
	)

NpcAimbotButton.MouseButton1Click:Connect(
	function()

		Settings.NpcAimbot =
			not Settings.NpcAimbot

		if Settings.NpcAimbot then

			NpcAimbotButton.Text =
				"NPC AIMBOT: ON"

			NpcAimbotButton.TextColor3 =
				Color3.fromRGB(
					255,
					50,
					110
				)

		else

			NpcAimbotButton.Text =
				"NPC AIMBOT: OFF"

			NpcAimbotButton.TextColor3 =
				Color3.fromRGB(
					255,
					255,
					255
				)

			CurrentNpcTarget =
				nil
		end
	end
)

--==================================================
-- GOD MODE BUTTON
--==================================================

local GodModeButton =
	createButton(
		"GOD MODE: OFF"
	)

GodModeButton.MouseButton1Click:Connect(
	function()

		Settings.GodMode =
			not Settings.GodMode

		GodModeEvent:FireServer(
			Settings.GodMode
		)

		if Settings.GodMode then

			GodModeButton.Text =
				"GOD MODE: ON"

			GodModeButton.TextColor3 =
				Color3.fromRGB(
					255,
					50,
					110
				)

		else

			GodModeButton.Text =
				"GOD MODE: OFF"

			GodModeButton.TextColor3 =
				Color3.fromRGB(
					255,
					255,
					255
				)
		end
	end
)

--==================================================
-- AIM PART BUTTON
--==================================================

local AimPartButton =
	createButton(
		"AIM PART: HEAD"
	)

AimPartButton.MouseButton1Click:Connect(
	function()

		if Settings.AimPart ==
			"Head" then

			Settings.AimPart =
				"Torso"

		elseif Settings.AimPart ==
			"Torso" then

			Settings.AimPart =
				"HumanoidRootPart"

		else

			Settings.AimPart =
				"Head"
		end

		AimPartButton.Text =
			"AIM PART: "
			.. string.upper(
				Settings.AimPart
			)
	end
)

--==================================================
-- SMOOTH BUTTON
--==================================================

local SmoothButton =
	createButton(
		"AIM SMOOTH: "
		.. tostring(
			Settings.AimSmoothness
		)
	)

SmoothButton.MouseButton1Click:Connect(
	function()

		Settings.AimSmoothness +=
			0.05

		if Settings.AimSmoothness > 0.8 then
			Settings.AimSmoothness = 0.1
		end

		Settings.AimSmoothness =
			math.floor(
				Settings.AimSmoothness * 100
			) / 100

		SmoothButton.Text =
			"AIM SMOOTH: "
			.. tostring(
				Settings.AimSmoothness
			)
	end
)

--==================================================
-- PLAYER HITBOXES
--==================================================

local PlayerHitboxObjects = {}

local function createHitbox(player)

	if not player.Character then
		return
	end

	local root =
		player.Character:FindFirstChild(
			"HumanoidRootPart"
		)

	if not root then
		return
	end

	if PlayerHitboxObjects[player] then

		PlayerHitboxObjects[player]:Destroy()

		PlayerHitboxObjects[player] =
			nil
	end

	if not Settings.ShowPlayerHitboxes then
		return
	end

	local box =
		Instance.new(
			"BoxHandleAdornment"
		)

	box.Name =
		"AdminPlayerHitbox"

	box.Adornee =
		root

	box.Size =
		root.Size *
		Settings.PlayerHitbox

	box.Color3 =
		Color3.fromRGB(
			255,
			50,
			100
		)

	box.Transparency =
		0.75

	box.AlwaysOnTop =
		true

	box.ZIndex =
		5

	box.Parent =
		root

	PlayerHitboxObjects[player] =
		box
end

local function updatePlayerHitboxes()

	for _, player in ipairs(
		Players:GetPlayers()
	) do

		if player ~= LocalPlayer then
			createHitbox(player)
		end
	end
end

local PlayerHitboxButton =
	createButton(
		"PLAYER HITBOX: x"
		.. Settings.PlayerHitbox
	)

PlayerHitboxButton.MouseButton1Click:Connect(
	function()

		Settings.PlayerHitbox +=
			0.5

		if Settings.PlayerHitbox > 5 then
			Settings.PlayerHitbox = 1
		end

		PlayerHitboxButton.Text =
			"PLAYER HITBOX: x"
			.. Settings.PlayerHitbox

		updatePlayerHitboxes()
	end
)

local ShowPlayerButton =
	createButton(
		"SHOW PLAYER HITBOXES: OFF"
	)

ShowPlayerButton.MouseButton1Click:Connect(
	function()

		Settings.ShowPlayerHitboxes =
			not Settings.ShowPlayerHitboxes

		if Settings.ShowPlayerHitboxes then

			ShowPlayerButton.Text =
				"SHOW PLAYER HITBOXES: ON"

			ShowPlayerButton.TextColor3 =
				Color3.fromRGB(
					255,
					50,
					110
				)

		else

			ShowPlayerButton.Text =
				"SHOW PLAYER HITBOXES: OFF"

			ShowPlayerButton.TextColor3 =
				Color3.fromRGB(
					255,
					255,
					255
				)
		end

		updatePlayerHitboxes()
	end
)

--==================================================
-- NPC HITBOXES
--==================================================

local NpcHitboxObjects = {}

local function updateNpcHitboxes()

	for model, object in pairs(
		NpcHitboxObjects
	) do

		if object then
			object:Destroy()
		end

		NpcHitboxObjects[model] =
			nil
	end

	if not Settings.ShowNpcHitboxes then
		return
	end

	for _, object in ipairs(
		workspace:GetDescendants()
	) do

		if isNPC(object) then

			local root =
				object:FindFirstChild(
					"HumanoidRootPart"
				)

			if root then

				local box =
					Instance.new(
						"BoxHandleAdornment"
					)

				box.Name =
					"AdminNPCHitbox"

				box.Adornee =
					root

				box.Size =
					root.Size *
					Settings.NpcHitbox

				box.Color3 =
					Color3.fromRGB(
						255,
						50,
						100
					)

				box.Transparency =
					0.75

				box.AlwaysOnTop =
					true

				box.ZIndex =
					5

				box.Parent =
					root

				NpcHitboxObjects[object] =
					box
			end
		end
	end
end

local NpcHitboxButton =
	createButton(
		"NPC HITBOX: x"
		.. Settings.NpcHitbox
	)

NpcHitboxButton.MouseButton1Click:Connect(
	function()

		Settings.NpcHitbox +=
			0.5

		if Settings.NpcHitbox > 5 then
			Settings.NpcHitbox = 1
		end

		NpcHitboxButton.Text =
			"NPC HITBOX: x"
			.. Settings.NpcHitbox

		updateNpcHitboxes()
	end
)

local ShowNpcButton =
	createButton(
		"SHOW NPC HITBOXES: OFF"
	)

ShowNpcButton.MouseButton1Click:Connect(
	function()

		Settings.ShowNpcHitboxes =
			not Settings.ShowNpcHitboxes

		if Settings.ShowNpcHitboxes then

			ShowNpcButton.Text =
				"SHOW NPC HITBOXES: ON"

			ShowNpcButton.TextColor3 =
				Color3.fromRGB(
					255,
					50,
					110
				)

		else

			ShowNpcButton.Text =
				"SHOW NPC HITBOXES: OFF"

			ShowNpcButton.TextColor3 =
				Color3.fromRGB(
					255,
					255,
					255
				)
		end

		updateNpcHitboxes()
	end
)

--==================================================
-- RESET HITBOXES
--==================================================

local ResetButton =
	createButton(
		"RESET HITBOXES"
	)

ResetButton.MouseButton1Click:Connect(
	function()

		Settings.PlayerHitbox = 1
		Settings.NpcHitbox = 1

		PlayerHitboxButton.Text =
			"PLAYER HITBOX: x1"

		NpcHitboxButton.Text =
			"NPC HITBOX: x1"

		updatePlayerHitboxes()
		updateNpcHitboxes()
	end
)

--==================================================
-- PLAYER EVENTS
--==================================================

local function setupPlayer(player)

	if player == LocalPlayer then
		return
	end

	player.CharacterAdded:Connect(
		function()

			if CurrentTarget == player then
				CurrentTarget = nil
			end

			task.wait(0.5)

			createHitbox(player)
		end
	)

	if player.Character then

		task.defer(
			function()
				createHitbox(player)
			end
		)
	end

	player:GetPropertyChangedSignal(
		"Team"
	):Connect(
		function()

			if CurrentTarget == player
				and not isEnemy(player) then

				CurrentTarget = nil
			end
		end
	)
end

for _, player in ipairs(
	Players:GetPlayers()
) do

	setupPlayer(player)
end

Players.PlayerAdded:Connect(
	setupPlayer
)

Players.PlayerRemoving:Connect(
	function(player)

		if CurrentTarget == player then
			CurrentTarget = nil
		end

		if PlayerHitboxObjects[player] then

			PlayerHitboxObjects[player]:Destroy()

			PlayerHitboxObjects[player] =
				nil
		end
	end
)

--==================================================
-- AIMBOT
--==================================================

RunService:BindToRenderStep(
	"CombatAdminAimbot",
	Enum.RenderPriority.Camera.Value + 1,
	function()

		-- BOTH OFF
		if not Settings.Aimbot
			and not Settings.NpcAimbot then

			CurrentTarget = nil
			CurrentNpcTarget = nil

			return
		end

		--==================================================
		-- PLAYER AIMBOT
		--==================================================

		if Settings.Aimbot then

			local playerTarget =
				getAimTarget()

			if playerTarget
				and CurrentTarget
				and isValidAimTarget(
					CurrentTarget
				) then

				local targetCFrame =
					CFrame.lookAt(
						Camera.CFrame.Position,
						playerTarget.Position
					)

				Camera.CFrame =
					Camera.CFrame:Lerp(
						targetCFrame,
						Settings.AimSmoothness
					)

				return
			end

			CurrentTarget = nil

		else

			CurrentTarget = nil
		end

		--==================================================
		-- NPC AIMBOT
		--==================================================

		if Settings.NpcAimbot then

			local npcTarget =
				getNpcAimTarget()

			if npcTarget
				and CurrentNpcTarget then

				local humanoid =
					CurrentNpcTarget:FindFirstChildOfClass(
						"Humanoid"
					)

				local root =
					CurrentNpcTarget:FindFirstChild(
						"HumanoidRootPart"
					)

				if humanoid
					and humanoid.Health > 0
					and root then

					local targetCFrame =
						CFrame.lookAt(
							Camera.CFrame.Position,
							npcTarget.Position
						)

					Camera.CFrame =
						Camera.CFrame:Lerp(
							targetCFrame,
							Settings.AimSmoothness
						)

					return
				end
			end

			CurrentNpcTarget = nil

		else

			CurrentNpcTarget = nil
		end
	end
)

--==================================================
-- DRAGGING
--==================================================

local dragging = false
local dragStart
local startPosition

Header.InputBegan:Connect(
	function(input)

		if input.UserInputType ==
			Enum.UserInputType.MouseButton1
			or input.UserInputType ==
			Enum.UserInputType.Touch then

			dragging = true

			dragStart =
				input.Position

			startPosition =
				Main.Position
		end
	end
)

Header.InputEnded:Connect(
	function(input)

		if input.UserInputType ==
			Enum.UserInputType.MouseButton1
			or input.UserInputType ==
			Enum.UserInputType.Touch then

			dragging = false
		end
	end
)

UserInputService.InputChanged:Connect(
	function(input)

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
			input.Position -
			dragStart

		Main.Position =
			UDim2.new(
				startPosition.X.Scale,
				startPosition.X.Offset
					+ delta.X,

				startPosition.Y.Scale,
				startPosition.Y.Offset
					+ delta.Y
			)
	end
)

--==================================================
-- OPEN / CLOSE ANIMATION
--==================================================

local function openPanel()

	Main.Visible =
		true

	Main.Size =
		UDim2.fromOffset(
			310,
			0
		)

	TweenService:Create(
		Main,
		TweenInfo.new(
			0.25,
			Enum.EasingStyle.Back,
			Enum.EasingDirection.Out
		),
		{
			Size =
				UDim2.fromOffset(
					310,
					500
				)
		}
	):Play()
end

local function closePanel()

	local tween =
		TweenService:Create(
			Main,
			TweenInfo.new(
				0.2,
				Enum.EasingStyle.Quad,
				Enum.EasingDirection.In
			),
			{
				Size =
					UDim2.fromOffset(
						310,
						0
					)
			}
		)

	tween:Play()

	tween.Completed:Connect(
		function()
			Main.Visible =
				false
		end
	)
end

OpenButton.MouseButton1Click:Connect(
	function()

		if Main.Visible then
			closePanel()
		else
			openPanel()
		end
	end
)

Close.MouseButton1Click:Connect(
	function()
		closePanel()
	end
)

--==================================================
-- KEYBOARD
--==================================================

UserInputService.InputBegan:Connect(
	function(input, processed)

		if processed then
			return
		end

		-- RightShift = OPEN / CLOSE

		if input.KeyCode ==
			Enum.KeyCode.RightShift then

			if Main.Visible then
				closePanel()
			else
				openPanel()
			end
		end

		-- ] = INCREASE PLAYER HITBOX

		if input.KeyCode ==
			Enum.KeyCode.RightBracket then

			Settings.PlayerHitbox +=
				0.5

			if Settings.PlayerHitbox > 5 then
				Settings.PlayerHitbox = 1
			end

			PlayerHitboxButton.Text =
				"PLAYER HITBOX: x"
				.. Settings.PlayerHitbox

			updatePlayerHitboxes()
		end

		-- [ = DECREASE PLAYER HITBOX

		if input.KeyCode ==
			Enum.KeyCode.LeftBracket then

			Settings.PlayerHitbox -=
				0.5

			if Settings.PlayerHitbox < 1 then
				Settings.PlayerHitbox = 5
			end

			PlayerHitboxButton.Text =
				"PLAYER HITBOX: x"
				.. Settings.PlayerHitbox

			updatePlayerHitboxes()
		end

		-- H = PLAYER HITBOXES

		if input.KeyCode ==
			Enum.KeyCode.H then

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
	end
)

--==================================================
-- INITIAL
--==================================================

task.wait(1)

updatePlayerHitboxes()
updateNpcHitboxes()
