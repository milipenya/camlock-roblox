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
	PredictionTime = 0.12
}

local target = nil
local targetHighlight = nil
local targetMarker = nil
local opened = false
local animating = false

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
main.Size = UDim2.fromOffset(300, 385)
main.Position = UDim2.new(1, -325, 0, 88)
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

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -40, 1, -105)
content.Position = UDim2.fromOffset(20, 95)
content.BackgroundTransparency = 1
content.Parent = main

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 9)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = content

local function createLabel(text, order)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 23)
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
	button.Size = UDim2.new(1, 0, 0, 48)
	button.BackgroundColor3 = Color3.fromRGB(25, 25, 29)
	button.BackgroundTransparency = 0.03
	button.Text = text
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextScaled = true
	button.Font = Enum.Font.GothamBold
	button.AutoButtonColor = false
	button.LayoutOrder = order
	button.Parent = content

	createCorner(button, 12)

	local stroke = createStroke(button, 1, 0.4)

	local gradient = Instance.new("UIGradient")
	gradient.Rotation = 90
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 45)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(14, 14, 17))
	})
	gradient.Parent = button

	button.Activated:Connect(function()
		local originalSize = button.Size

		TweenService:Create(
			button,
			TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Size = UDim2.new(1, -6, 0, 45)
			}
		):Play()

		task.delay(0.08, function()
			TweenService:Create(
				button,
				TweenInfo.new(0.14, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
				{
					Size = originalSize
				}
			):Play()
		end)
	end)

	return button, stroke
end

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

local toggle, toggleStroke = createButton("CAMLOCK: OFF", 1)

local rangeLabel = createLabel("DISTANCE: 150", 2)
local rangeButton = createButton("CHANGE DISTANCE", 3)

local smoothLabel = createLabel("SMOOTHNESS: 18%", 4)
local smoothButton = createButton("CHANGE SMOOTHNESS", 5)

local targetLabel = createLabel("TARGET: BODY", 6)
local targetButton = createButton("CHANGE TARGET", 7)

local function removeTargetVisuals()
	if targetHighlight then
		targetHighlight:Destroy()
		targetHighlight = nil
	end

	if targetMarker then
		targetMarker:Destroy()
		targetMarker = nil
	end
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
	targetHighlight.FillTransparency = 0.82
	targetHighlight.OutlineColor = Color3.fromRGB(255, 40, 55)
	targetHighlight.OutlineTransparency = 0.15
	targetHighlight.DepthMode = Enum.HighlightDepthMode.Occluded
	targetHighlight.Parent = character

	targetMarker = Instance.new("BillboardGui")
	targetMarker.Name = "CamlockMarker"
	targetMarker.Adornee = part
	targetMarker.Size = UDim2.fromOffset(28, 28)
	targetMarker.StudsOffset = Vector3.new(0, 3.2, 0)
	targetMarker.AlwaysOnTop = true
	targetMarker.MaxDistance = Settings.Range
	targetMarker.Parent = gui

	local cross = Instance.new("TextLabel")
	cross.Size = UDim2.fromScale(1, 1)
	cross.BackgroundTransparency = 1
	cross.Text = "×"
	cross.TextColor3 = Color3.fromRGB(255, 35, 50)
	cross.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	cross.TextStrokeTransparency = 0.25
	cross.TextScaled = true
	cross.Font = Enum.Font.GothamBold
	cross.Parent = targetMarker
end

local function getTarget()
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
		if other ~= player and other.Character then
			local humanoid =
				other.Character:FindFirstChildOfClass("Humanoid")

			local targetPart =
				other.Character:FindFirstChild(Settings.TargetPart)
				or other.Character:FindFirstChild("HumanoidRootPart")

			if humanoid and humanoid.Health > 0 and targetPart then
				local distance =
					(targetPart.Position - root.Position).Magnitude

				if distance < closestDistance then
					closestDistance = distance
					closest = targetPart
				end
			end
		end
	end

	if closest then
		createTargetVisuals(closest)
	else
		removeTargetVisuals()
	end

	return closest
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

local function updateTarget()
	if Settings.TargetPart == "Head" then
		targetLabel.Text = "TARGET: HEAD"
	else
		targetLabel.Text = "TARGET: BODY"
	end
end

local function toggleCamlock()
	Settings.Enabled = not Settings.Enabled

	if Settings.Enabled then
		target = getTarget()
	else
		target = nil
		removeTargetVisuals()
	end

	updateToggle()
end

toggle.Activated:Connect(toggleCamlock)

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
	if Settings.Smoothness == 0.08 then
		Settings.Smoothness = 0.12
	elseif Settings.Smoothness == 0.12 then
		Settings.Smoothness = 0.18
	elseif Settings.Smoothness == 0.18 then
		Settings.Smoothness = 0.24
	elseif Settings.Smoothness == 0.24 then
		Settings.Smoothness = 0.30
	else
		Settings.Smoothness = 0.08
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
	updateTarget()
end)

RunService.RenderStepped:Connect(function()
	if not Settings.Enabled then
		return
	end

	if not target or not target.Parent then
		target = getTarget()
	end

	if not target then
		return
	end

	local character = player.Character

	if not character then
		return
	end

	local root = character:FindFirstChild("HumanoidRootPart")

	if not root then
		return
	end

	local distance =
		(target.Position - root.Position).Magnitude

	if distance > Settings.Range then
		target = getTarget()

		if not target then
			removeTargetVisuals()
		end

		return
	end

	local aimPosition = target.Position

	if Settings.PredictionEnabled then
		aimPosition =
			aimPosition +
			target.AssemblyLinearVelocity *
			Settings.PredictionTime
	end

	local desired =
		CFrame.lookAt(
			camera.CFrame.Position,
			aimPosition
		)

	camera.CFrame =
		camera.CFrame:Lerp(
			desired,
			Settings.Smoothness
		)
end)

local dragging = false
local dragStart
local startPosition

title.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseButton1 then

		dragging = true
		dragStart = input.Position
		startPosition = main.Position
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

	main.Visible = true
	main.Size = UDim2.fromOffset(270, 345)
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
			Size = UDim2.fromOffset(300, 385),
			BackgroundTransparency = 0.02
		}
	):Play()

	task.spawn(function()
		for _, object in ipairs(content:GetChildren()) do
			if object:IsA("GuiObject") then
				task.wait(0.035)

				if object:IsA("TextButton") then
					TweenService:Create(
						object,
						TweenInfo.new(
							0.22,
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
							0.22,
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
			Size = UDim2.fromOffset(270, 345),
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
		updateTarget()
	end
end)

player.CharacterAdded:Connect(function()
	target = nil
	removeTargetVisuals()

	if Settings.Enabled then
		task.wait(0.5)
		target = getTarget()
	end
end)
