local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local Settings = {
	Enabled = false,
	Range = 150,
	Smoothness = 0.18,
	TargetPart = "HumanoidRootPart",

	PredictionEnabled = true,
	PredictionTime = 0.12,

	FOVEnabled = true,
	FOV = 75,

	ManualControl = true,
	ManualControlStrength = 0.35
}

local target = nil
local selectedPlayer = nil

local targetHighlight = nil
local targetMarker = nil
local markerText = nil

local opened = false
local animating = false
local dragging = false

local dragStart
local startPosition

local lastCameraLook = nil
local manualCameraMovement = 0
local targetRefreshTimer = 0

local gui = Instance.new("ScreenGui")
gui.Name = "MobileCamlock"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

local function createCorner(object, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = object
	return corner
end

local function createStroke(object, thickness, transparency)
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = thickness
	stroke.Transparency = transparency
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.Parent = object
	return stroke
end

local openButton = Instance.new("TextButton")
openButton.Name = "OpenMenu"
openButton.Size = UDim2.fromOffset(58, 58)
openButton.Position = UDim2.new(1, -130, 0, 18)
openButton.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
openButton.BackgroundTransparency = 0.08
openButton.Text = "≡"
openButton.TextColor3 = Color3.fromRGB(255, 255, 255)
openButton.TextScaled = true
openButton.Font = Enum.Font.GothamBold
openButton.AutoButtonColor = false
openButton.Parent = gui

createCorner(openButton, 20)
createStroke(openButton, 1.5, 0.25)

local openGradient = Instance.new("UIGradient")
openGradient.Rotation = 90
openGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(38, 38, 43)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 8, 10))
})
openGradient.Parent = openButton

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(320, 520)
main.Position = UDim2.new(1, -345, 0, 88)
main.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
main.BackgroundTransparency = 0.02
main.Visible = false
main.ClipsDescendants = true
main.Parent = gui

createCorner(main, 20)
createStroke(main, 1.5, 0.2)

local mainGradient = Instance.new("UIGradient")
mainGradient.Rotation = 90
mainGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(32, 32, 37)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(15, 15, 18)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(7, 7, 9))
})
mainGradient.Parent = main

local topLine = Instance.new("Frame")
topLine.Size = UDim2.new(1, -40, 0, 2)
topLine.Position = UDim2.fromOffset(20, 59)
topLine.BackgroundColor3 = Color3.fromRGB(220, 30, 50)
topLine.BorderSizePixel = 0
topLine.Parent = main

createCorner(topLine, 2)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -80, 0, 45)
title.Position = UDim2.fromOffset(20, 10)
title.BackgroundTransparency = 1
title.Text = "CAMLOCK"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = main

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -40, 0, 20)
subtitle.Position = UDim2.fromOffset(20, 67)
subtitle.BackgroundTransparency = 1
subtitle.Text = "MOBILE CONTROL PANEL"
subtitle.TextColor3 = Color3.fromRGB(255, 255, 255)
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.TextScaled = true
subtitle.Font = Enum.Font.GothamMedium
subtitle.Parent = main

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.fromOffset(40, 40)
closeButton.Position = UDim2.new(1, -50, 0, 10)
closeButton.BackgroundTransparency = 1
closeButton.Text = "×"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextScaled = true
closeButton.Font = Enum.Font.GothamBold
closeButton.AutoButtonColor = false
closeButton.Parent = main

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -30, 1, -105)
scroll.Position = UDim2.fromOffset(15, 95)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 3
scroll.ScrollBarImageColor3 = Color3.fromRGB(220, 30, 50)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.Parent = main

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -8, 0, 0)
content.BackgroundTransparency = 1
content.AutomaticSize = Enum.AutomaticSize.Y
content.Parent = scroll

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = content

local function createLabel(text, order)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 22)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextScaled = true
	label.Font = Enum.Font.GothamMedium
	label.LayoutOrder = order
	label.Parent = content

	return label
end

local function createButton(text, order)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, 0, 0, 46)
	button.BackgroundColor3 = Color3.fromRGB(25, 25, 29)
	button.BackgroundTransparency = 0.03
	button.Text = text
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextScaled = true
	button.Font = Enum.Font.GothamBold
	button.AutoButtonColor = false
	button.LayoutOrder = order
	button.Parent = content

	createCorner(button, 11)

	local stroke = createStroke(button, 1, 0.4)

	local gradient = Instance.new("UIGradient")
	gradient.Rotation = 90
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 45)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(14, 14, 17))
	})
	gradient.Parent = button

	button.Activated:Connect(function()
		local oldSize = button.Size

		TweenService:Create(
			button,
			TweenInfo.new(0.07, Enum.EasingStyle.Quad),
			{
				Size = UDim2.new(1, -6, 0, 43)
			}
		):Play()

		task.delay(0.07, function()
			TweenService:Create(
				button,
				TweenInfo.new(0.13, Enum.EasingStyle.Back),
				{
					Size = oldSize
				}
			):Play()
		end)
	end)

	return button, stroke
end

local toggle, toggleStroke = createButton("CAMLOCK: OFF", 1)

local selectedLabel = createLabel("TARGET: AUTO", 2)
local playerButton = createButton("SELECT PLAYER", 3)

local targetList = Instance.new("ScrollingFrame")
targetList.Size = UDim2.new(1, 0, 0, 100)
targetList.BackgroundColor3 = Color3.fromRGB(9, 9, 12)
targetList.BackgroundTransparency = 0.15
targetList.BorderSizePixel = 0
targetList.ScrollBarThickness = 3
targetList.ScrollBarImageColor3 = Color3.fromRGB(220, 30, 50)
targetList.LayoutOrder = 4
targetList.Parent = content

createCorner(targetList, 10)

local targetListLayout = Instance.new("UIListLayout")
targetListLayout.Padding = UDim.new(0, 4)
targetListLayout.SortOrder = Enum.SortOrder.Name
targetListLayout.Parent = targetList

local rangeLabel = createLabel("DISTANCE: 150", 5)
local rangeButton = createButton("CHANGE DISTANCE", 6)

local smoothLabel = createLabel("SMOOTHNESS: 18%", 7)
local smoothButton = createButton("CHANGE SMOOTHNESS", 8)

local targetPartLabel = createLabel("TARGET PART: BODY", 9)
local targetButton = createButton("CHANGE TARGET PART", 10)

local predictionLabel = createLabel("PREDICTION: ON | 12%", 11)
local predictionButton = createButton("PREDICTION SETTINGS", 12)

local fovLabel = createLabel("FOV ASSIST: 75°", 13)
local fovButton = createButton("CHANGE FOV", 14)

local resetButton = createButton("RESET TARGET", 15)

local function setActive(button, stroke, state)
	if state then
		button.BackgroundColor3 = Color3.fromRGB(65, 12, 20)
		stroke.Color = Color3.fromRGB(235, 35, 55)
		stroke.Transparency = 0.05
	else
		button.BackgroundColor3 = Color3.fromRGB(25, 25, 29)
		stroke.Color = Color3.fromRGB(255, 255, 255)
		stroke.Transparency = 0.4
	end
end

local function removeTargetVisuals()
	if targetHighlight then
		targetHighlight:Destroy()
		targetHighlight = nil
	end

	if targetMarker then
		targetMarker:Destroy()
		targetMarker = nil
	end

	markerText = nil
end

local function createTargetVisuals(part)
	removeTargetVisuals()

	if not part or not part.Parent then
		return
	end

	local character = part.Parent

	targetHighlight = Instance.new("Highlight")
	targetHighlight.Name = "CamlockHighlight"
	targetHighlight.Adornee = character
	targetHighlight.FillColor = Color3.fromRGB(255, 30, 45)
	targetHighlight.FillTransparency = 0.88
	targetHighlight.OutlineColor = Color3.fromRGB(255, 40, 55)
	targetHighlight.OutlineTransparency = 0.1
	targetHighlight.DepthMode = Enum.HighlightDepthMode.Occluded
	targetHighlight.Parent = character

	targetMarker = Instance.new("BillboardGui")
	targetMarker.Name = "CamlockMarker"
	targetMarker.Adornee = part
	targetMarker.Size = UDim2.fromOffset(25, 25)
	targetMarker.StudsOffset = Vector3.new(0, 3.2, 0)
	targetMarker.AlwaysOnTop = true
	targetMarker.MaxDistance = Settings.Range
	targetMarker.Parent = gui

	markerText = Instance.new("TextLabel")
	markerText.Size = UDim2.fromScale(1, 1)
	markerText.BackgroundTransparency = 1
	markerText.Text = "×"
	markerText.TextColor3 = Color3.fromRGB(255, 35, 50)
	markerText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	markerText.TextStrokeTransparency = 0.2
	markerText.TextScaled = true
	markerText.Font = Enum.Font.GothamBold
	markerText.Parent = targetMarker
end

local function isPlayerValid(plr)
	if not plr or plr == player then
		return false
	end

	if not plr.Character then
		return false
	end

	local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")

	return humanoid and humanoid.Health > 0
end

local function getPart(plr)
	if not isPlayerValid(plr) then
		return nil
	end

	return plr.Character:FindFirstChild(Settings.TargetPart)
		or plr.Character:FindFirstChild("HumanoidRootPart")
end

local function isInsideFOV(part)
	if not Settings.FOVEnabled then
		return true
	end

	local screenPoint, visible =
		camera:WorldToViewportPoint(part.Position)

	if not visible or screenPoint.Z <= 0 then
		return false
	end

	local center =
		Vector2.new(
			camera.ViewportSize.X / 2,
			camera.ViewportSize.Y / 2
		)

	local point =
		Vector2.new(
			screenPoint.X,
			screenPoint.Y
		)

	local distance = (point - center).Magnitude

	local radius =
		math.tan(math.rad(Settings.FOV / 2)) *
		camera.ViewportSize.Y / 2

	return distance <= radius
end

local function findAutomaticTarget()
	local character = player.Character

	if not character then
		return nil
	end

	local root = character:FindFirstChild("HumanoidRootPart")

	if not root then
		return nil
	end

	local closest = nil
	local closestDistance = Settings.Range

	for _, other in ipairs(Players:GetPlayers()) do
		if other ~= player and isPlayerValid(other) then
			local part = getPart(other)

			if part then
				local distance =
					(part.Position - root.Position).Magnitude

				if distance <= closestDistance
					and isInsideFOV(part) then

					closestDistance = distance
					closest = other
				end
			end
		end
	end

	return closest
end

local function setTarget(plr)
	if plr and isPlayerValid(plr) then
		selectedPlayer = plr
		target = getPart(plr)

		if target then
			createTargetVisuals(target)
			selectedLabel.Text = "TARGET: " .. plr.Name
		end
	else
		selectedPlayer = nil
		target = nil
		removeTargetVisuals()
		selectedLabel.Text = "TARGET: AUTO"
	end
end

local function refreshAutomaticTarget()
	if selectedPlayer then
		local part = getPart(selectedPlayer)

		if part then
			target = part

			if not targetHighlight then
				createTargetVisuals(part)
			end

			return
		end

		target = nil
		removeTargetVisuals()
		return
	end

	local newTarget = findAutomaticTarget()

	if newTarget then
		setTarget(newTarget)
	else
		target = nil
		removeTargetVisuals()
	end
end

local function rebuildPlayerList()
	for _, object in ipairs(targetList:GetChildren()) do
		if object:IsA("TextButton") then
			object:Destroy()
		end
	end

	for _, other in ipairs(Players:GetPlayers()) do
		if other ~= player then
			local button = Instance.new("TextButton")
			button.Size = UDim2.new(1, -8, 0, 30)
			button.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
			button.BackgroundTransparency = 0.1
			button.Text =
				other.DisplayName .. "  @" .. other.Name
			button.TextColor3 = Color3.fromRGB(255, 255, 255)
			button.TextScaled = true
			button.Font = Enum.Font.GothamMedium
			button.AutoButtonColor = false
			button.Parent = targetList

			createCorner(button, 8)

			button.Activated:Connect(function()
				setTarget(other)
			end)
		end
	end

	local autoButton = Instance.new("TextButton")
	autoButton.Size = UDim2.new(1, -8, 0, 30)
	autoButton.BackgroundColor3 = Color3.fromRGB(55, 12, 19)
	autoButton.BackgroundTransparency = 0.05
	autoButton.Text = "AUTO TARGET"
	autoButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	autoButton.TextScaled = true
	autoButton.Font = Enum.Font.GothamBold
	autoButton.AutoButtonColor = false
	autoButton.Parent = targetList

	createCorner(autoButton, 8)

	autoButton.Activated:Connect(function()
		selectedPlayer = nil
		selectedLabel.Text = "TARGET: AUTO"
		target = nil
		removeTargetVisuals()
		refreshAutomaticTarget()
	end)
end

local function updateToggle()
	if Settings.Enabled then
		toggle.Text = "CAMLOCK: ON"
		setActive(toggle, toggleStroke, true)
	else
		toggle.Text = "CAMLOCK: OFF"
		setActive(toggle, toggleStroke, false)
	end
end

local function updateRange()
	rangeLabel.Text = "DISTANCE: " .. Settings.Range

	if targetMarker then
		targetMarker.MaxDistance = Settings.Range
	end
end

local function updateSmoothness()
	smoothLabel.Text =
		"SMOOTHNESS: " ..
		math.floor(Settings.Smoothness * 100) ..
		"%"
end

local function updateTargetPart()
	if Settings.TargetPart == "Head" then
		targetPartLabel.Text = "TARGET PART: HEAD"
	else
		targetPartLabel.Text = "TARGET PART: BODY"
	end
end

local function updatePrediction()
	local percent =
		math.floor(Settings.PredictionTime * 100)

	if Settings.PredictionEnabled then
		predictionLabel.Text =
			"PREDICTION: ON | " .. percent .. "%"
	else
		predictionLabel.Text =
			"PREDICTION: OFF"
	end
end

local function updateFOV()
	fovLabel.Text = "FOV ASSIST: " .. Settings.FOV .. "°"
end

local function toggleCamlock()
	Settings.Enabled = not Settings.Enabled

	if Settings.Enabled then
		if selectedPlayer then
			setTarget(selectedPlayer)
		else
			refreshAutomaticTarget()
		end
	else
		target = nil
		removeTargetVisuals()
	end

	updateToggle()
end

toggle.Activated:Connect(toggleCamlock)

playerButton.Activated:Connect(function()
	rebuildPlayerList()

	if targetList.Visible then
		targetList.Visible = false
	else
		targetList.Visible = true
	end
end)

rangeButton.Activated:Connect(function()
	if Settings.Range == 75 then
		Settings.Range = 100
	elseif Settings.Range == 100 then
		Settings.Range = 150
	elseif Settings.Range == 150 then
		Settings.Range = 200
	elseif Settings.Range == 200 then
		Settings.Range = 250
	else
		Settings.Range = 75
	end

	updateRange()
end)

smoothButton.Activated:Connect(function()
	if Settings.Smoothness >= 0.30 then
		Settings.Smoothness = 0.08
	else
		Settings.Smoothness =
			math.round((Settings.Smoothness + 0.04) * 100) / 100
	end

	updateSmoothness()
end)

targetButton.Activated:Connect(function()
	if Settings.TargetPart == "HumanoidRootPart" then
		Settings.TargetPart = "Head"
	else
		Settings.TargetPart = "HumanoidRootPart"
	end

	target = nil

	if selectedPlayer then
		target = getPart(selectedPlayer)

		if target then
			createTargetVisuals(target)
		end
	end

	updateTargetPart()
end)

predictionButton.Activated:Connect(function()
	if not Settings.PredictionEnabled then
		Settings.PredictionEnabled = true
		Settings.PredictionTime = 0.12
	elseif Settings.PredictionTime < 0.12 then
		Settings.PredictionTime = 0.12
	elseif Settings.PredictionTime < 0.18 then
		Settings.PredictionTime = 0.18
	elseif Settings.PredictionTime < 0.24 then
		Settings.PredictionTime = 0.24
	else
		Settings.PredictionEnabled = false
		Settings.PredictionTime = 0.12
	end

	updatePrediction()
end)

fovButton.Activated:Connect(function()
	if Settings.FOV == 45 then
		Settings.FOV = 60
	elseif Settings.FOV == 60 then
		Settings.FOV = 75
	elseif Settings.FOV == 75 then
		Settings.FOV = 90
	else
		Settings.FOV = 45
	end

	updateFOV()
end)

resetButton.Activated:Connect(function()
	selectedPlayer = nil
	target = nil

	removeTargetVisuals()

	selectedLabel.Text = "TARGET: AUTO"

	if Settings.Enabled then
		refreshAutomaticTarget()
	end
end)

RunService.RenderStepped:Connect(function(dt)
	if targetMarker and markerText then
		local pulse =
			0.5 + math.sin(os.clock() * 4) * 0.15

		markerText.TextTransparency = pulse
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging then
		local delta = input.Position - dragStart

		main.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end
end)

title.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseButton1 then

		dragging = true
		dragStart = input.Position
		startPosition = main.Position
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseButton1 then

		dragging = false
	end
end)

local function openMenu()
	if opened or animating then
		return
	end

	opened = true
	animating = true

	rebuildPlayerList()
	targetList.Visible = false

	main.Visible = true
	main.Size = UDim2.fromOffset(285, 485)
	main.BackgroundTransparency = 1

	for _, object in ipairs(content:GetChildren()) do
		if object:IsA("TextButton") then
			object.BackgroundTransparency = 1
			object.TextTransparency = 1
		elseif object:IsA("TextLabel") then
			object.TextTransparency = 1
		end
	end

	TweenService:Create(
		main,
		TweenInfo.new(
			0.32,
			Enum.EasingStyle.Back,
			Enum.EasingDirection.Out
		),
		{
			Size = UDim2.fromOffset(320, 520),
			BackgroundTransparency = 0.02
		}
	):Play()

	task.spawn(function()
		for _, object in ipairs(content:GetChildren()) do
			if object:IsA("GuiObject") then
				task.wait(0.025)

				if object:IsA("TextButton") then
					TweenService:Create(
						object,
						TweenInfo.new(
							0.2,
							Enum.EasingStyle.Quad,
							Enum.EasingDirection.Out
						),
						{
							BackgroundTransparency = 0.03,
							TextTransparency = 0
						}
					):Play()
				elseif object:IsA("TextLabel") then
					TweenService:Create(
						object,
						TweenInfo.new(
							0.2,
							Enum.EasingStyle.Quad,
							Enum.EasingDirection.Out
						),
						{
							TextTransparency = 0
						}
					):Play()
				end
			end
		end
	end)

	TweenService:Create(
		openButton,
		TweenInfo.new(
			0.2,
			Enum.EasingStyle.Back,
			Enum.EasingDirection.Out
		),
		{
			Rotation = 90,
			Size = UDim2.fromOffset(62, 62)
		}
	):Play()

	task.wait(0.32)

	animating = false
end

local function closeMenu()
	if not opened or animating then
		return
	end

	opened = false
	animating = true

	TweenService:Create(
		main,
		TweenInfo.new(
			0.2,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.In
		),
		{
			Size = UDim2.fromOffset(285, 485),
			BackgroundTransparency = 1
		}
	):Play()

	TweenService:Create(
		openButton,
		TweenInfo.new(
			0.2,
			Enum.EasingStyle.Back,
			Enum.EasingDirection.Out
		),
		{
			Rotation = 0,
			Size = UDim2.fromOffset(58, 58)
		}
	):Play()

	task.wait(0.2)

	main.Visible = false
	animating = false
end

openButton.Activated:Connect(function()
	if opened then
		closeMenu()
	else
		openMenu()
	end
end)

closeButton.Activated:Connect(closeMenu)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end

	if input.KeyCode == Enum.KeyCode.F then
		toggleCamlock()

	elseif input.KeyCode == Enum.KeyCode.M then
		if opened then
			closeMenu()
		else
			openMenu()
		end

	elseif input.KeyCode == Enum.KeyCode.Q then
		Settings.Range = math.max(
			50,
			Settings.Range - 25
		)

		updateRange()

	elseif input.KeyCode == Enum.KeyCode.E then
		Settings.Range = math.min(
			300,
			Settings.Range + 25
		)

		updateRange()

	elseif input.KeyCode == Enum.KeyCode.Z then
		Settings.Smoothness =
			math.max(
				0.05,
				math.round(
					(Settings.Smoothness - 0.01) * 100
				) / 100
			)

		updateSmoothness()

	elseif input.KeyCode == Enum.KeyCode.X then
		Settings.Smoothness =
			math.min(
				0.50,
				math.round(
					(Settings.Smoothness + 0.01) * 100
				) / 100
			)

		updateSmoothness()

	elseif input.KeyCode == Enum.KeyCode.T then
		if Settings.TargetPart == "HumanoidRootPart" then
			Settings.TargetPart = "Head"
		else
			Settings.TargetPart = "HumanoidRootPart"
		end

		target = nil
		updateTargetPart()

	elseif input.KeyCode == Enum.KeyCode.R then
		selectedPlayer = nil
		target = nil
		removeTargetVisuals()
		selectedLabel.Text = "TARGET: AUTO"

		if Settings.Enabled then
			refreshAutomaticTarget()
		end
	end
end)

RunService:BindToRenderStep(
	"MobileCamlockCamera",
	Enum.RenderPriority.Camera.Value + 1,
	function(dt)
		if not Settings.Enabled then
			lastCameraLook = camera.CFrame.LookVector
			return
		end

		targetRefreshTimer += dt

		if targetRefreshTimer >= 0.15 then
			targetRefreshTimer = 0

			if selectedPlayer then
				local part = getPart(selectedPlayer)

				if part then
					target = part
				else
					target = nil
					removeTargetVisuals()
				end
			else
				if not target or not target.Parent then
					refreshAutomaticTarget()
				end
			end
		end

		if not target or not target.Parent then
			return
		end

		local character = player.Character

		if not character then
			return
		end

		local root =
			character:FindFirstChild("HumanoidRootPart")

		if not root then
			return
		end

		local distance =
			(target.Position - root.Position).Magnitude

		if distance > Settings.Range then
			if selectedPlayer then
				target = nil
				removeTargetVisuals()
			else
				refreshAutomaticTarget()
			end

			return
		end

		local currentLook =
			camera.CFrame.LookVector

		if lastCameraLook then
			local cameraDelta =
				1 - math.clamp(
					currentLook:Dot(lastCameraLook),
					-1,
					1
				)

			manualCameraMovement =
				math.clamp(
					manualCameraMovement * 0.75 +
					cameraDelta * 5,
					0,
					1
				)
		end

		lastCameraLook = currentLook

		local aimPosition = target.Position

		if Settings.PredictionEnabled then
			aimPosition +=
				target.AssemblyLinearVelocity *
				Settings.PredictionTime
		end

		local direction =
			aimPosition - camera.CFrame.Position

		if direction.Magnitude < 0.01 then
			return
		end

		local desired =
			CFrame.lookAt(
				camera.CFrame.Position,
				aimPosition
			)

		local assistStrength =
			Settings.Smoothness

		if Settings.ManualControl then
			local manualFactor =
				1 -
				manualCameraMovement *
				(1 - Settings.ManualControlStrength)

			assistStrength *= manualFactor
		end

		assistStrength =
			math.clamp(
				assistStrength,
				0.01,
				0.5
			)

		camera.CFrame =
			camera.CFrame:Lerp(
				desired,
				assistStrength
			)
	end
)

Players.PlayerAdded:Connect(function()
	task.wait(0.2)
	rebuildPlayerList()
end)

Players.PlayerRemoving:Connect(function(leavingPlayer)
	if selectedPlayer == leavingPlayer then
		selectedPlayer = nil
		target = nil
		removeTargetVisuals()
		selectedLabel.Text = "TARGET: AUTO"
	end

	task.wait()
	rebuildPlayerList()
end)

player.CharacterAdded:Connect(function()
	target = nil
	removeTargetVisuals()

	if Settings.Enabled then
		task.wait(0.5)

		if selectedPlayer then
			setTarget(selectedPlayer)
		else
			refreshAutomaticTarget()
		end
	end
end)

updateToggle()
updateRange()
updateSmoothness()
updateTargetPart()
updatePrediction()
updateFOV()
rebuildPlayerList()
