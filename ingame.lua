local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local AIMBOT_ENABLED = true
local ESP_ENABLED = true

local AIM_KEY = Enum.KeyCode.Q
local MAX_DISTANCE = 500
local FOV_RADIUS = 250

local ESP_COLOR = Color3.fromRGB(255, 0, 0)

local function getCostumeName(player)
    local character = player.Character
    if not character then
        return ""
    end

    local costume = character:GetAttribute("CostumeName")

    if costume then
        return tostring(costume)
    end

    costume = player:GetAttribute("CostumeName")

    if costume then
        return tostring(costume)
    end

    local value = character:FindFirstChild("CostumeName")

    if value and value:IsA("StringValue") then
        return value.Value
    end

    return ""
end

local function isGuard(player)
    local costumeName = string.lower(getCostumeName(player))

    return string.find(costumeName, "guard", 1, true) ~= nil
end

local function getMyRole()
    if isGuard(LocalPlayer) then
        return "Guard"
    end

    return "Player"
end

local function isValidTarget(player)
    if player == LocalPlayer then
        return false
    end

    local character = player.Character
    if not character then
        return false
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")

    if not humanoid or humanoid.Health <= 0 or not root then
        return false
    end

    local myRole = getMyRole()
    local targetIsGuard = isGuard(player)

    if myRole == "Guard" and targetIsGuard then
        return false
    end

    if myRole == "Player" and not targetIsGuard then
        return false
    end

    local distance = (root.Position - Camera.CFrame.Position).Magnitude

    if distance > MAX_DISTANCE then
        return false
    end

    return true
end

local function createESP(player)
    if player == LocalPlayer then
        return
    end

    local function update()
        local character = player.Character
        if not character then
            return
        end

        local highlight = character:FindFirstChild("AimbotESP")

        if not isValidTarget(player) or not ESP_ENABLED then
            if highlight then
                highlight:Destroy()
            end

            return
        end

        if not highlight then
            highlight = Instance.new("Highlight")
            highlight.Name = "AimbotESP"
            highlight.FillColor = ESP_COLOR
            highlight.OutlineColor = ESP_COLOR
            highlight.FillTransparency = 0.55
            highlight.OutlineTransparency = 0
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Parent = character
        end
    end

    player.CharacterAdded:Connect(function()
        task.wait(0.2)
        update()
    end)

    update()
end

for _, player in ipairs(Players:GetPlayers()) do
    createESP(player)
end

Players.PlayerAdded:Connect(createESP)

local function getClosestTarget()
    local closestPlayer = nil
    local closestDistance = FOV_RADIUS

    local screenCenter = Vector2.new(
        Camera.ViewportSize.X / 2,
        Camera.ViewportSize.Y / 2
    )

    for _, player in ipairs(Players:GetPlayers()) do
        if isValidTarget(player) then
            local character = player.Character
            local head = character:FindFirstChild("Head")
            local root = character:FindFirstChild("HumanoidRootPart")
            local targetPart = head or root

            if targetPart then
                local screenPosition, visible =
                    Camera:WorldToViewportPoint(targetPart.Position)

                if visible and screenPosition.Z > 0 then
                    local targetPosition = Vector2.new(
                        screenPosition.X,
                        screenPosition.Y
                    )

                    local distanceFromCenter =
                        (targetPosition - screenCenter).Magnitude

                    if distanceFromCenter < closestDistance then
                        closestDistance = distanceFromCenter
                        closestPlayer = player
                    end
                end
            end
        end
    end

    return closestPlayer
end

local aiming = false

local function aimAt(player)
    if not player or not isValidTarget(player) then
        return
    end

    local character = player.Character
    local head = character and character:FindFirstChild("Head")

    if not head then
        return
    end

    Camera.CFrame = CFrame.lookAt(
        Camera.CFrame.Position,
        head.Position
    )
end

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then
        return
    end

    if input.KeyCode == AIM_KEY then
        aiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == AIM_KEY then
        aiming = false
    end
end)

RunService.RenderStepped:Connect(function()
    if not AIMBOT_ENABLED or not aiming then
        return
    end

    local target = getClosestTarget()

    if target then
        aimAt(target)
    end
end)
