-- PenyaHubZ Compact Camlock
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local CamlockEnabled = false
local WallCheckEnabled = true
local HighlightEnabled = true
local TargetPlayer = nil

-- Remove previous GUI/highlight
for _, name in ipairs({"PenyaHubZ_Camlock", "PenyaHubZ_Camlock_Old", "PenyaTargetESP"}) do
    local a = PlayerGui:FindFirstChild(name)
    if a then a:Destroy() end
    local b = game:GetService("CoreGui"):FindFirstChild(name)
    if b then b:Destroy() end
end

local oldHighlight = workspace:FindFirstChild("PenyaTargetHighlight")
if oldHighlight then oldHighlight:Destroy() end

print("=== NEW PENYAHUBZ CAMLOCK LOADED ===")
print("UI VERSION: COMPACT MOBILE")

local Colors = {
    Background = Color3.fromRGB(12,10,16),
    Panel = Color3.fromRGB(20,17,26),
    Purple = Color3.fromRGB(135,65,220),
    PurpleDark = Color3.fromRGB(82,38,140),
    Text = Color3.fromRGB(240,238,245),
    TextDim = Color3.fromRGB(150,145,160),
    Off = Color3.fromRGB(65,61,72)
}

local TargetHighlight = Instance.new("Highlight")
TargetHighlight.Name = "PenyaTargetHighlight"
TargetHighlight.FillColor = Color3.fromRGB(0,100,255)
TargetHighlight.OutlineColor = Color3.fromRGB(255,255,255)
TargetHighlight.FillTransparency = 0.5
TargetHighlight.OutlineTransparency = 0.2
TargetHighlight.Enabled = false
TargetHighlight.Parent = workspace

local function getClosestPlayer()
    local character = LocalPlayer.Character
    local myRoot = character and character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end

    local closest, closestDistance = nil, math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if root and humanoid and humanoid.Health > 0 then
                local distance = (root.Position - myRoot.Position).Magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    closest = player
                end
            end
        end
    end
    return closest
end

local function isBehindWall(targetCharacter)
    if not WallCheckEnabled then return false end
    local myCharacter = LocalPlayer.Character
    local targetRoot = targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart")
    if not myCharacter or not targetRoot then return false end

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {myCharacter, targetCharacter}
    params.IgnoreWater = true

    return workspace:Raycast(
        Camera.CFrame.Position,
        targetRoot.Position - Camera.CFrame.Position,
        params
    ) ~= nil
end

local function clearTarget()
    TargetPlayer = nil
    TargetHighlight.Enabled = false
    TargetHighlight.Adornee = nil
end

local function enableCamlock()
    local target = getClosestPlayer()
    if not target then return false end
    TargetPlayer = target
    return true
end

local function disableCamlock()
    CamlockEnabled = false
    clearTarget()
end

-- GUI: always open, compact, mobile-friendly
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PenyaHubZ_Camlock"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(205,145)
Main.Position = UDim2.new(1,-215,0,65)
Main.BackgroundColor3 = Colors.Background
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0,11)
corner.Parent = Main

local stroke = Instance.new("UIStroke")
stroke.Color = Colors.PurpleDark
stroke.Thickness = 1
stroke.Transparency = 0.15
stroke.Parent = Main

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1,0,0,32)
Header.BackgroundColor3 = Colors.Panel
Header.BorderSizePixel = 0
Header.Parent = Main

local hc = Instance.new("UICorner")
hc.CornerRadius = UDim.new(0,11)
hc.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,-18,1,0)
Title.Position = UDim2.fromOffset(9,0)
Title.BackgroundTransparency = 1
Title.Text = "CAMLOCK"
Title.TextColor3 = Colors.Text
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Status = Instance.new("TextLabel")
Status.Size = UDim2.fromOffset(65,32)
Status.Position = UDim2.new(1,-73,0,0)
Status.BackgroundTransparency = 1
Status.Text = "READY"
Status.TextColor3 = Colors.TextDim
Status.Font = Enum.Font.GothamMedium
Status.TextSize = 9
Status.TextXAlignment = Enum.TextXAlignment.Right
Status.Parent = Header

local TargetLabel = Instance.new("TextLabel")
TargetLabel.Size = UDim2.new(1,-18,0,18)
TargetLabel.Position = UDim2.fromOffset(9,36)
TargetLabel.BackgroundTransparency = 1
TargetLabel.Text = "Target: None"
TargetLabel.TextColor3 = Colors.TextDim
TargetLabel.Font = Enum.Font.Gotham
TargetLabel.TextSize = 10
TargetLabel.TextXAlignment = Enum.TextXAlignment.Left
TargetLabel.TextTruncate = Enum.TextTruncate.AtEnd
TargetLabel.Parent = Main

local function createToggle(name,y,defaultValue,callback)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,-75,0,25)
    label.Position = UDim2.fromOffset(9,y)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Colors.Text
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 10
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = Main

    local toggle = Instance.new("Frame")
    toggle.Size = UDim2.fromOffset(38,19)
    toggle.Position = UDim2.new(1,-47,0,y+3)
    toggle.BackgroundColor3 = defaultValue and Colors.Purple or Colors.Off
    toggle.BorderSizePixel = 0
    toggle.Parent = Main

    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(1,0)
    tc.Parent = toggle

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(15,15)
    knob.Position = defaultValue and UDim2.new(1,-17,0.5,-7) or UDim2.fromOffset(2,2)
    knob.BackgroundColor3 = Colors.Text
    knob.BorderSizePixel = 0
    knob.Parent = toggle

    local kc = Instance.new("UICorner")
    kc.CornerRadius = UDim.new(1,0)
    kc.Parent = knob

    local button = Instance.new("TextButton")
    button.Size = UDim2.fromScale(1,1)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.AutoButtonColor = false
    button.Parent = toggle

    local state = defaultValue
    local function setState(value)
        state = value == true
        toggle.BackgroundColor3 = state and Colors.Purple or Colors.Off
        knob.Position = state and UDim2.new(1,-17,0.5,-7) or UDim2.fromOffset(2,2)
        callback(state)
    end

    button.MouseButton1Click:Connect(function()
        setState(not state)
    end)

    return {Set=setState, Get=function() return state end}
end

local CamlockToggle
CamlockToggle = createToggle("Camlock",55,false,function(state)
    if state then
        if enableCamlock() then
            CamlockEnabled = true
            Status.Text = "LOCKED"
            Status.TextColor3 = Colors.Purple
        else
            CamlockEnabled = false
            Status.Text = "NO TARGET"
            Status.TextColor3 = Colors.TextDim
            CamlockToggle.Set(false)
        end
    else
        disableCamlock()
        Status.Text = "READY"
        Status.TextColor3 = Colors.TextDim
    end
end)

createToggle("Wall Check",81,true,function(state)
    WallCheckEnabled = state
end)

createToggle("Target ESP",107,true,function(state)
    HighlightEnabled = state
    if not state then
        TargetHighlight.Enabled = false
    end
end)

local function updateTargetLabel()
    if TargetPlayer and TargetPlayer.Character then
        TargetLabel.Text = "Target: " .. TargetPlayer.Name
        TargetLabel.TextColor3 = Colors.Text
    else
        TargetLabel.Text = "Target: None"
        TargetLabel.TextColor3 = Colors.TextDim
    end
end

RunService.RenderStepped:Connect(function()
    if not CamlockEnabled then
        updateTargetLabel()
        return
    end

    if not TargetPlayer then
        disableCamlock()
        CamlockToggle.Set(false)
        return
    end

    local character = TargetPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")

    if not character or not root or not humanoid or humanoid.Health <= 0 then
        disableCamlock()
        CamlockToggle.Set(false)
        Status.Text = "READY"
        Status.TextColor3 = Colors.TextDim
        return
    end

    updateTargetLabel()

    if isBehindWall(character) then
        TargetHighlight.Enabled = false
        return
    end

    Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, root.Position)

    if HighlightEnabled then
        TargetHighlight.Adornee = character
        TargetHighlight.Enabled = true
    else
        TargetHighlight.Enabled = false
        TargetHighlight.Adornee = nil
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    clearTarget()
    if CamlockEnabled then
        CamlockEnabled = false
        CamlockToggle.Set(false)
        Status.Text = "READY"
        Status.TextColor3 = Colors.TextDim
    end
end)

print("[PenyaHubZ] Compact Camlock ready.")
