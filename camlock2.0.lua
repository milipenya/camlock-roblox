local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ToggleBtn = Instance.new("TextButton")
local StatusLabel = Instance.new("TextLabel")

ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.Name = "PenyaScriptableLock"

MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 1
MainFrame.BorderColor3 = Color3.fromRGB(0, 180, 255)
MainFrame.Position = UDim2.new(0.1, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 220, 0, 130)
MainFrame.Active = true
MainFrame.Draggable = true

Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0.3, 0)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Title.Text = "🔒 Penya Camlock v3"
Title.TextColor3 = Color3.fromRGB(0, 180, 255)
Title.TextSize = 15
Title.Font = Enum.Font.SourceSansBold

ToggleBtn.Parent = MainFrame
ToggleBtn.Position = UDim2.new(0.1, 0, 0.4, 0)
ToggleBtn.Size = UDim2.new(0.8, 0, 0.35, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ToggleBtn.Text = "CAMLOCK: OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 14

StatusLabel.Parent = MainFrame
StatusLabel.Position = UDim2.new(0, 0, 0.8, 0)
StatusLabel.Size = UDim2.new(1, 0, 0.2, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Target: None"
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
StatusLabel.TextSize = 12

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local CamlockActive = false
local TargetPlayer = nil
local CamLoop = nil

-- Расстояние камеры от твоего персонажа (высота и отдаление сзади)
local CameraOffset = Vector3.new(0, 2.5, 8) 

local function GetClosestPlayer()
    local closest = nil
    local shortestDistance = math.huge
    local camera = Workspace.CurrentCamera
    if not camera then return nil end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local pos, onScreen = camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
                if onScreen then
                    local mousePos = camera.ViewportSize / 2
                    local distance = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                    if distance < shortestDistance then
                        closest = player
                        shortestDistance = distance
                    end
                end
            end
        end
    end
    return closest
end

ToggleBtn.MouseButton1Click:Connect(function()
    CamlockActive = not CamlockActive
    local camera = Workspace.CurrentCamera
    
    if CamlockActive then
        TargetPlayer = GetClosestPlayer()
        
        if TargetPlayer and TargetPlayer.Character then
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
            ToggleBtn.Text = "CAMLOCK: ON"
            StatusLabel.Text = "Locked on: " .. TargetPlayer.Name
            
            -- Врубаем ручной режим управления камерой, отключая стандартную физику Roblox
            camera.CameraType = Enum.CameraType.Scriptable
            
            CamLoop = RunService.RenderStepped:Connect(function()
                if not CamlockActive or not camera then return end
                
                local myChar = LocalPlayer.Character
                local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
                
                if myHRP and TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local targetHRP = TargetPlayer.Character.HumanoidRootPart
                    local targetHum = TargetPlayer.Character:FindFirstChildOfClass("Humanoid")
                    
                    if targetHum and targetHum.Health > 0 then
                        -- 1. Считаем направление от тебя к противнику (только по горизонтали, чтобы камеру не кренило)
                        local lookVector = (targetHRP.Position - myHRP.Position).Unit
                        
                        -- 2. Жестко позиционируем камеру строго за спиной твоего персонажа относительно врага
                        -- Твой персонаж гарантированно останется в самом центре экрана
                        local camPosition = myHRP.Position - (lookVector * CameraOffset.Z) + Vector3.new(0, CameraOffset.Y, 0)
                        
                        -- 3. Мгновенно перезаписываем CFrame камеры, направляя её из рассчитанной точки прямо в шею цели
                        camera.CFrame = CFrame.new(camPosition, targetHRP.Position + Vector3.new(0, 1.5, 0))
                        
                        -- 4. Принудительно разворачиваем твоего персонажа лицом к цели, чтобы деши шли в правильном направлении
                        myHRP.CFrame = CFrame.new(myHRP.Position, Vector3.new(targetHRP.Position.X, myHRP.Position.Y, targetHRP.Position.Z))
                    else
                        TargetPlayer = GetClosestPlayer()
                    end
                else
                    TargetPlayer = GetClosestPlayer()
                end
            end)
        else
            CamlockActive = false
            StatusLabel.Text = "No players on screen!"
        end
    else
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        ToggleBtn.Text = "CAMLOCK: OFF"
        StatusLabel.Text = "Target: None"
        
        if CamLoop then
            CamLoop:Disconnect()
            CamLoop = nil
        end
        TargetPlayer = nil
        
        -- Возвращаем управление камере обратно игроку
        if camera then
            camera.CameraType = Enum.CameraType.Custom
        end
    end
end)
