local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ToggleBtn = Instance.new("TextButton")
local StatusLabel = Instance.new("TextLabel")

ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.Name = "PenyaCamlockHub"

MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 20, 30)
MainFrame.BorderSizePixel = 1
MainFrame.BorderColor3 = Color3.fromRGB(255, 0, 100) -- Ярко-розовый неоновый контур
MainFrame.Position = UDim2.new(0.1, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 220, 0, 130)
MainFrame.Active = true
MainFrame.Draggable = true

Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0.3, 0)
Title.BackgroundColor3 = Color3.fromRGB(40, 30, 45)
Title.Text = "🔒 Penya Camlock (Hard)"
Title.TextColor3 = Color3.fromRGB(255, 0, 100)
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

-- Функция поиска ближайшего живого игрока к твоему прицелу
local function GetClosestPlayer()
    local closest = nil
    local shortestDistance = math.huge
    local camera = Workspace.CurrentCamera
    
    if not camera then return nil end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                -- Считаем дистанцию на экране от центра до персонажа
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
    
    if CamlockActive then
        TargetPlayer = GetClosestPlayer()
        
        if TargetPlayer and TargetPlayer.Character then
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
            ToggleBtn.Text = "CAMLOCK: ON"
            StatusLabel.Text = "Locked on: " .. TargetPlayer.Name
            
            local camera = Workspace.CurrentCamera
            
            -- НАМЕРТВЫЙ ЦИКЛ ПРИВЯЗКИ КАМЕРЫ (Без Lerp и сглаживания)
            CamLoop = RunService.RenderStepped:Connect(function()
                if not CamlockActive or not camera then return end
                
                -- Проверяем, жив ли противник и существует ли его хитбокс
                if TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local targetHRP = TargetPlayer.Character.HumanoidRootPart
                    local targetHum = TargetPlayer.Character:FindFirstChildOfClass("Humanoid")
                    
                    if targetHum and targetHum.Health > 0 then
                        -- Жестко перезаписываем CFrame камеры, направляя её из текущей позиции глаза в хитбокс цели
                        -- Смещение Vector3.new(0, 1.5, 0) направляет камеру ровно в голову/шею, а не в пояс
                        camera.CFrame = CFrame.new(camera.CFrame.Position, targetHRP.Position + Vector3.new(0, 1.5, 0))
                    else
                        -- Если цель погибла, ищем новую автоматически
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
        -- ПОЛНОЕ ОТКЛЮЧЕНИЕ И ОСВОБОЖДЕНИЕ КАМЕРЫ
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        ToggleBtn.Text = "CAMLOCK: OFF"
        StatusLabel.Text = "Target: None"
        
        if CamLoop then
            CamLoop:Disconnect()
            CamLoop = nil
        end
        TargetPlayer = nil
    end
end)
