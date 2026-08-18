local Rayfield = loadstring(game:HttpGet('https://sirius.menu'))()

local Window = Rayfield:CreateWindow({
   Name = "Camlock Control Menu",
   LoadingTitle = "Loading Camlock...",
   LoadingSubtitle = "by AI",
   Theme = "Default"
})

local TargetPlayer = nil
local LockEnabled = false
local TargetPart = "Head"
local Smoothness = 0.15

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local function getPlayerNames()
    local names = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(names, player.Name)
        end
    end
    return names
end

local MainTab = Window:CreateTab("Camlock", 4483362458)

local Toggle = MainTab:CreateToggle({
   Name = "Enable Camlock",
   CurrentValue = false,
   Flag = "CamlockToggle",
   Callback = function(Value)
      LockEnabled = Value
   end,
})

local PlayerDropdown = MainTab:CreateDropdown({
   Name = "Select Target Player",
   Options = getPlayerNames(),
   CurrentOption = {""},
   MultipleOptions = false,
   Flag = "PlayerDropdown",
   Callback = function(Option)
      local selectedName = Option[1]
      TargetPlayer = Players:FindFirstChild(selectedName)
   end,
})

local PlayerInput = MainTab:CreateInput({
   Name = "Enter Username Manually",
   CurrentValue = "",
   PlaceholderText = "Username...",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      if Text == "" then return end
      
      for _, player in pairs(Players:GetPlayers()) do
          if string.sub(string.lower(player.Name), 1, string.len(Text)) == string.lower(Text) then
              TargetPlayer = player
              PlayerDropdown:Set({player.Name})
              break
          end
      end
   end,
})

local RefreshButton = MainTab:CreateButton({
   Name = "Refresh Player List",
   Callback = function()
       PlayerDropdown:Refresh(getPlayerNames(), true)
   end,
})

Players.PlayerAdded:Connect(function()
    PlayerDropdown:Refresh(getPlayerNames(), true)
end)
Players.PlayerRemoving:Connect(function()
    PlayerDropdown:Refresh(getPlayerNames(), true)
end)

RunService.RenderStepped:Connect(function()
    if not LockEnabled or not TargetPlayer then return end
    
    local character = TargetPlayer.Character
    if character and character:FindFirstChild(TargetPart) then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        
        if humanoid and humanoid.Health > 0 then
            local targetPosition = character[TargetPart].Position
            local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPosition)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Smoothness)
        end
    end
end)
 
