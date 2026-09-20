local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- CONFIGURATION
local CAMLOCK_KEY = Enum.KeyCode.E -- Keybind to lock/unlock target
local TARGET_RADIUS = 200 -- Screen radius to search for target

local TargetPlayer = nil
local CamlockEnabled = false
local TargetHighlight = nil

-- Clean existing Highlight if script restarts
if game:GetService("CoreGui"):FindFirstChild("PenyaTargetESP") then
    game:GetService("CoreGui").PenyaTargetESP:Destroy()
end

-- Create persistent Highlight object for Target ESP
TargetHighlight = Instance.new("Highlight")
TargetHighlight.Name = "PenyaTargetESP"
TargetHighlight.FillColor = Color3.fromRGB(0, 100, 255) -- Solid Blue
TargetHighlight.OutlineColor = Color3.fromRGB(255, 255, 255) -- White Outline
TargetHighlight.FillTransparency = 0.5
TargetHighlight.OutlineTransparency = 0.2
TargetHighlight.Enabled = false
TargetHighlight.Parent = game:GetService("CoreGui")

-- Math function to check walls between LocalPlayer and Target
local function isBehindWall(targetCharacter)
    local myChar = LocalPlayer.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local targetHrp = targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart")
    
    if myHrp and targetHrp then
        -- Create a ray from your head/camera position to target's body
        local origin = Camera.CFrame.Position
        local direction = (targetHrp.Position - origin)
        local ray = Ray.new(origin, direction)
        
        -- Ignore list so the ray doesn't hit yourself or the target's own body parts
        local ignoreList = {myChar, targetCharacter, Camera}
        local hitPart, hitPosition = workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
        
        -- If ray hits a map element (Wall, Floor, Block) before reaching target
        if hitPart and not hitPart:IsDescendantOf(targetCharacter) and hitPart.CanCollide then
            return true -- Target is obstructed by wall
        end
    end
    return false -- Path is clear
end

-- Function to acquire the closest valid player near screen center
local function getClosestPlayerToCenter()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local closestEnemy = nil
    local shortestDistance = TARGET_RADIUS

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            
            if hrp and hum and hum.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                
                if onScreen then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if distance < shortestDistance then
                        -- Check walls immediately upon target selection
                        if not isBehindWall(player.Character) then
                            shortestDistance = distance
                            closestEnemy = player
                        end
                    end
                end
            end
        end
    end
    return closestEnemy
end

-- Input handler for activation
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == CAMLOCK_KEY then
        CamlockEnabled = not CamlockEnabled
        
        if CamlockEnabled then
            TargetPlayer = getClosestPlayerToCenter()
            if not TargetPlayer then
                CamlockEnabled = false -- Reset if no clear player found
            end
        else
            TargetPlayer = nil
            TargetHighlight.Enabled = false
            TargetHighlight.Adornee = nil
        end
    end
end)

-- Main tracking loop running at maximum frame rate
RunService.RenderStepped:Connect(function()
    if CamlockEnabled and TargetPlayer and TargetPlayer.Character then
        local targetHrp = TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
        local targetHum = TargetPlayer.Character:FindFirstChildOfClass("Humanoid")
        
        -- Break lock if enemy dies
        if not targetHrp or (targetHum and targetHum.Health <= 0) then
            CamlockEnabled = false
            TargetPlayer = nil
            TargetHighlight.Enabled = false
            TargetHighlight.Adornee = nil
            return
        end
        
        -- Dynamic Wall Check verification during lock state
        if not isBehindWall(TargetPlayer.Character) then
            -- Smooth camera interpolation towards target HumanoidRootPart position
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetHrp.Position)
            
            -- Apply blue ESP highlight to currently locked visible player
            TargetHighlight.Adornee = TargetPlayer.Character
            TargetHighlight.Enabled = true
        else
            -- If target goes behind a wall, pause camera tracking but hold target identity inside script
            TargetHighlight.Enabled = false
            TargetHighlight.Adornee = nil
        end
    end
end)
