--[[
    PenyaHubZ - Compact Camlock
    Roblox Studio / собственный проект

    Возможности:
    • Компактное постоянно открытое меню
    • Camlock ON/OFF
    • Цель = ближайший живой игрок
    • Wall Check
    • Target Highlight
    • Автоматический сброс цели при смерти/исчезновении
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--==================================================
-- CONFIG
--==================================================

local CamlockEnabled = false
local WallCheckEnabled = true
local HighlightEnabled = true

local TargetPlayer = nil

--==================================================
-- THEME
--==================================================

local Colors = {
    Background = Color3.fromRGB(12, 10, 16),
    Panel = Color3.fromRGB(20, 17, 26),
    PanelLight = Color3.fromRGB(30, 25, 38),

    Purple = Color3.fromRGB(135, 65, 220),
    PurpleDark = Color3.fromRGB(82, 38, 140),

    Text = Color3.fromRGB(240, 238, 245),
    TextDim = Color3.fromRGB(150, 145, 160),

    Off = Color3.fromRGB(65, 61, 72)
}

--==================================================
-- TARGET HIGHLIGHT
--==================================================

local oldHighlight = workspace:FindFirstChild("PenyaTargetHighlight")

if oldHighlight then
    oldHighlight:Destroy()
end

local TargetHighlight = Instance.new("Highlight")
TargetHighlight.Name = "PenyaTargetHighlight"
TargetHighlight.FillColor = Color3.fromRGB(0, 100, 255)
TargetHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
TargetHighlight.FillTransparency = 0.5
TargetHighlight.OutlineTransparency = 0.2
TargetHighlight.Enabled = false
TargetHighlight.Parent = workspace

--==================================================
-- TARGET SELECTION
--==================================================

local function getClosestPlayer()
    local character = LocalPlayer.Character

    if not character then
        return nil
    end

    local myRoot = character:FindFirstChild("HumanoidRootPart")

    if not myRoot then
        return nil
    end

    local closestPlayer = nil
    local closestDistance = math.huge

    for _, player in ipairs(Players:GetPlayers()) do

        if player ~= LocalPlayer and player.Character then

            local root = player.Character:FindFirstChild("HumanoidRootPart")
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")

            if root and humanoid and humanoid.Health > 0 then

                local distance =
                    (root.Position - myRoot.Position).Magnitude

                if distance < closestDistance then
                    closestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end

    return closestPlayer
end

--==================================================
-- WALL CHECK
--==================================================

local function isBehindWall(targetCharacter)

    if not WallCheckEnabled then
        return false
    end

    local myCharacter = LocalPlayer.Character

    if not myCharacter or not targetCharacter then
        return false
    end

    local myRoot = myCharacter:FindFirstChild("HumanoidRootPart")
    local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")

    if not myRoot or not targetRoot then
        return false
    end

    local origin = Camera.CFrame.Position
    local direction = targetRoot.Position - origin

    local rayParams = RaycastParams.new()

    rayParams.FilterType = Enum.RaycastFilterType.Exclude

    rayParams.FilterDescendantsInstances = {
        myCharacter,
        targetCharacter
    }

    rayParams.IgnoreWater = true

    local result = workspace:Raycast(
        origin,
        direction,
        rayParams
    )

    if result and result.Instance then
        return true
    end

    return false
end

--==================================================
-- TARGET CLEANUP
--==================================================

local function clearTarget()

    TargetPlayer = nil

    TargetHighlight.Enabled = false
    TargetHighlight.Adornee = nil
end

--==================================================
-- CAMLOCK
--==================================================

local function enableCamlock()

    local target = getClosestPlayer()

    if not target then
        return false
    end

    TargetPlayer = target

    return true
end

local function disableCamlock()

    CamlockEnabled = false

    clearTarget()
end

local function toggleCamlock()

    if CamlockEnabled then
        disableCamlock()
        return
    end

    if enableCamlock() then
        CamlockEnabled = true
    end
end

--==================================================
-- UI
--==================================================

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local oldGui = PlayerGui:FindFirstChild("PenyaHubZ_Camlock")

if oldGui then
    oldGui:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")

ScreenGui.Name = "PenyaHubZ_Camlock"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

ScreenGui.Parent = PlayerGui

--==================================================
-- MAIN PANEL
--==================================================

local Main = Instance.new("Frame")

Main.Name = "Main"
Main.Size = UDim2.fromOffset(220, 150)

Main.Position = UDim2.new(
    1,
    -235,
    0,
    70
)

Main.BackgroundColor3 = Colors.Background
Main.BorderSizePixel = 0

Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")

MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")

MainStroke.Color = Colors.PurpleDark
MainStroke.Thickness = 1

MainStroke.Transparency = 0.25
MainStroke.Parent = Main

--==================================================
-- HEADER
--==================================================

local Header = Instance.new("Frame")

Header.Size = UDim2.new(1, 0, 0, 35)

Header.BackgroundColor3 = Colors.Panel
Header.BorderSizePixel = 0

Header.Parent = Main

local HeaderCorner = Instance.new("UICorner")

HeaderCorner.CornerRadius = UDim.new(0, 12)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")

Title.Size = UDim2.new(1, -20, 1, 0)

Title.Position = UDim2.fromOffset(10, 0)

Title.BackgroundTransparency = 1

Title.Text = "CAMLOCK"

Title.TextColor3 = Colors.Text

Title.Font = Enum.Font.GothamBold
Title.TextSize = 14

Title.TextXAlignment = Enum.TextXAlignment.Left

Title.Parent = Header

--==================================================
-- TARGET LABEL
--==================================================

local TargetLabel = Instance.new("TextLabel")

TargetLabel.Size = UDim2.new(1, -20, 0, 22)

TargetLabel.Position = UDim2.fromOffset(10, 38)

TargetLabel.BackgroundTransparency = 1

TargetLabel.Text = "Target: None"

TargetLabel.TextColor3 = Colors.TextDim

TargetLabel.Font = Enum.Font.Gotham

TargetLabel.TextSize = 11

TargetLabel.TextXAlignment = Enum.TextXAlignment.Left

TargetLabel.Parent = Main

--==================================================
-- TOGGLE CREATOR
--==================================================

local function createToggle(name, y, defaultValue, callback)

    local Label = Instance.new("TextLabel")

    Label.Size = UDim2.new(1, -75, 0, 28)

    Label.Position = UDim2.fromOffset(10, y)

    Label.BackgroundTransparency = 1

    Label.Text = name

    Label.TextColor3 = Colors.Text

    Label.Font = Enum.Font.GothamMedium

    Label.TextSize = 11

    Label.TextXAlignment = Enum.TextXAlignment.Left

    Label.Parent = Main


    local Toggle = Instance.new("Frame")

    Toggle.Size = UDim2.fromOffset(42, 21)

    Toggle.Position = UDim2.new(
        1,
        -52,
        0,
        y + 3
    )

    Toggle.BackgroundColor3 =
        defaultValue and Colors.Purple or Colors.Off

    Toggle.BorderSizePixel = 0

    Toggle.Parent = Main


    local Corner = Instance.new("UICorner")

    Corner.CornerRadius = UDim.new(1, 0)

    Corner.Parent = Toggle


    local Knob = Instance.new("Frame")

    Knob.Size = UDim2.fromOffset(17, 17)

    Knob.Position =
        defaultValue
        and UDim2.new(1, -19, 0.5, -8)
        or UDim2.fromOffset(2, 2)

    Knob.BackgroundColor3 = Colors.Text

    Knob.BorderSizePixel = 0

    Knob.Parent = Toggle


    local KnobCorner = Instance.new("UICorner")

    KnobCorner.CornerRadius = UDim.new(1, 0)

    KnobCorner.Parent = Knob


    local Button = Instance.new("TextButton")

    Button.Size = UDim2.fromScale(1, 1)

    Button.BackgroundTransparency = 1

    Button.Text = ""

    Button.AutoButtonColor = false

    Button.Parent = Toggle


    local state = defaultValue


    local function setState(value)

        state = value

        Toggle.BackgroundColor3 =
            state and Colors.Purple or Colors.Off

        Knob.Position =
            state
            and UDim2.new(1, -19, 0.5, -8)
            or UDim2.fromOffset(2, 2)

        callback(state)

    end


    Button.MouseButton1Click:Connect(function()

        setState(not state)

    end)


    return {
        Set = setState,

        Get = function()
            return state
        end
    }

end

--==================================================
-- TOGGLES
--==================================================

local CamlockToggle

CamlockToggle = createToggle(
    "Camlock",
    62,
    false,
    function(state)

        if state then

            if not enableCamlock() then

                CamlockToggle.Set(false)

                return
            end

            CamlockEnabled = true

        else

            disableCamlock()

        end
    end
)


createToggle(
    "Wall Check",
    92,
    true,
    function(state)

        WallCheckEnabled = state

    end
)


createToggle(
    "Target ESP",
    122,
    true,
    function(state)

        HighlightEnabled = state

        if not state then
            TargetHighlight.Enabled = false
        end

    end
)

--==================================================
-- TARGET UPDATE
--==================================================

local function updateTargetLabel()

    if TargetPlayer and TargetPlayer.Character then

        TargetLabel.Text =
            "Target: " .. TargetPlayer.Name

        TargetLabel.TextColor3 = Colors.Text

    else

        TargetLabel.Text = "Target: None"

        TargetLabel.TextColor3 = Colors.TextDim

    end
end

--==================================================
-- MAIN LOOP
--==================================================

RunService.RenderStepped:Connect(function()

    if not CamlockEnabled then
        return
    end

    if not TargetPlayer then

        disableCamlock()

        CamlockToggle.Set(false)

        return
    end

    local character = TargetPlayer.Character

    if not character then

        disableCamlock()

        CamlockToggle.Set(false)

        return
    end

    local root =
        character:FindFirstChild("HumanoidRootPart")

    local humanoid =
        character:FindFirstChildOfClass("Humanoid")

    if not root or not humanoid or humanoid.Health <= 0 then

        disableCamlock()

        CamlockToggle.Set(false)

        return
    end

    -- Проверяем препятствие

    if isBehindWall(character) then

        TargetHighlight.Enabled = false

        return
    end

    -- Камера следует за выбранной целью

    Camera.CFrame =
        CFrame.lookAt(
            Camera.CFrame.Position,
            root.Position
        )

    -- Highlight

    if HighlightEnabled then

        TargetHighlight.Adornee = character
        TargetHighlight.Enabled = true

    else

        TargetHighlight.Enabled = false
        TargetHighlight.Adornee = nil

    end

    updateTargetLabel()

end)

--==================================================
-- RESPAWN HANDLING
--==================================================

LocalPlayer.CharacterAdded:Connect(function()

    clearTarget()

    if CamlockEnabled then

        CamlockEnabled = false

        if CamlockToggle then
            CamlockToggle.Set(false)
        end

    end

end)

print("[PenyaHubZ] Compact Camlock loaded.")
