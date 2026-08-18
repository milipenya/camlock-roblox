-- LocalScript в StarterPlayerScripts
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local Settings = {
    MaxDistance = 50,
    FOVAngle = 60,
    ToggleKey = Enum.KeyCode.Q,
    SmoothSpeed = 10,
    TargetTag = "Enemy",

    -- Оптимизация
    SearchInterval = 0.25,   -- как часто пересчитываем цель (сек), не каждый кадр
    MobileSmoothSpeed = 6,   -- камера плавнее/дешевле на телефонах
}

local locked = false
local currentTarget = nil
local lastSearchTime = 0

-- Косинус половины угла обзора — считаем один раз, не на каждый кадр
local fovCos = math.cos(math.rad(Settings.FOVAngle / 2))

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local smoothSpeed = isMobile and Settings.MobileSmoothSpeed or Settings.SmoothSpeed

-- Кэшируем список игроков, обновляем только по событиям, а не каждый поиск
local cachedPlayers = {}
local function refreshPlayerCache()
    cachedPlayers = Players:GetPlayers()
end
refreshPlayerCache()
Players.PlayerAdded:Connect(refreshPlayerCache)
Players.PlayerRemoving:Connect(refreshPlayerCache)

local function findClosestTarget()
    local charRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not charRoot then return nil end

    local camPos = camera.CFrame.Position
    local lookVector = camera.CFrame.LookVector
    local charPos = charRoot.Position

    local closest, closestDist = nil, Settings.MaxDistance
    for _, plr in ipairs(cachedPlayers) do
        if plr ~= player and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local root = plr.Character:FindFirstChild("HumanoidRootPart")
            if hum and root and hum.Health > 0 then
                local dist = (root.Position - charPos).Magnitude
                if dist <= closestDist then
                    -- дешёвая проверка угла через dot вместо acos/deg
                    local dir = (root.Position - camPos).Unit
                    if lookVector:Dot(dir) >= fovCos then
                        closest = root
                        closestDist = dist
                    end
                end
            end
        end
    end
    return closest
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Settings.ToggleKey then
        locked = not locked
        if locked then
            currentTarget = findClosestTarget()
            lastSearchTime = os.clock()
        else
            currentTarget = nil
        end
    end
end)

RunService.RenderStepped:Connect(function(dt)
    if not locked then return end

    local now = os.clock()

    -- Пересчитываем цель не каждый кадр, а по интервалу — главная экономия на мобилках
    if not currentTarget or not currentTarget.Parent or (now - lastSearchTime) >= Settings.SearchInterval then
        currentTarget = findClosestTarget()
        lastSearchTime = now
        if not currentTarget then
            locked = false
            return
        end
    end

    local goalCFrame = CFrame.lookAt(camera.CFrame.Position, currentTarget.Position)
    camera.CFrame = camera.CFrame:Lerp(goalCFrame, math.clamp(dt * smoothSpeed, 0, 1))
end)
