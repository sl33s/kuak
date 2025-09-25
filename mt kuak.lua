--[[
    Script: MyHub v1.2 (Fixed for Steal a Brainrot)
    Author: kuak saudi
    Description: A feature-rich script for Steal a Brainrot.
]]

-- =================================================================
--                        CONFIGURATION
-- =================================================================
local authorName = "kuak saudi"
local discordLink = "https://discord.gg/YprBskZdc9"

-- =================================================================
--                        INITIALIZATION
-- =================================================================
print("MyHub v1.2: Initializing..." )

-- Clean up old GUI
if game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("MyHubGui") then
    game:GetService("Players").LocalPlayer.PlayerGui.MyHubGui:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MyHubGui"
screenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Local Player
local LocalPlayer = Players.LocalPlayer
print("MyHub: LocalPlayer found: " .. LocalPlayer.Name)

-- =================================================================
--                        MAIN HUB GUI
-- =================================================================
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Parent = screenGui
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderColor3 = Color3.fromRGB(80, 80, 80)
mainFrame.BorderSizePixel = 2
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -150)
mainFrame.Size = UDim2.new(0, 350, 0, 250) -- Reduced size slightly
mainFrame.Draggable = true
mainFrame.Active = true
mainFrame.Visible = true

local titleLabel = Instance.new("TextLabel")
titleLabel.Parent = mainFrame
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.Text = "MyHub v1.2 - By " .. authorName
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 18

local function createToggleButton(parent, text, position, callback)
    local toggled = false
    local button = Instance.new("TextButton")
    button.Parent = parent
    button.Position = position
    button.Size = UDim2.new(0.45, 0, 0, 35)
    button.BackgroundColor3 = Color3.fromRGB(190, 40, 40)
    button.Font = Enum.Font.SourceSansBold
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14

    button.MouseButton1Click:Connect(function()
        toggled = not toggled
        button.BackgroundColor3 = toggled and Color3.fromRGB(40, 190, 40) or Color3.fromRGB(190, 40, 40)
        pcall(callback, toggled)
    end)
    return button
end

-- =================================================================
--                        FEATURES
-- =================================================================

-- ESP Features
local espEnabled = { bestPet = false }
local espElements = {}

RunService.RenderStepped:Connect(function()
    -- Clear old elements if the pet is gone
    for item, element in pairs(espElements) do
        if not item or not item.Parent then
            element:Destroy()
            espElements[item] = nil
        end
    end

    if not espEnabled.bestPet then return end

    local housesFolder = Workspace:FindFirstChild("Houses")
    if not housesFolder then return end

    for _, house in pairs(housesFolder:GetChildren()) do
        if house:IsA("Model") and house:FindFirstChild("Head") then
            local bestPet, maxStrength = nil, -1
            local petsFolder = house:FindFirstChild("Pets")
            if petsFolder then
                for _, pet in pairs(petsFolder:GetChildren()) do
                    local strength = pet:GetAttribute("Strength")
                    if strength and strength > maxStrength then
                        maxStrength = strength
                        bestPet = pet
                    end
                end
            end
            
            if bestPet and not espElements[bestPet] then
                local highlight = Instance.new("BoxHandleAdornment")
                highlight.Adornee = bestPet
                highlight.Size = bestPet.Size + Vector3.new(1, 1, 1)
                highlight.Color3 = Color3.fromRGB(255, 255, 0) -- Yellow
                highlight.Transparency = 0.5
                highlight.AlwaysOnTop = true
                highlight.Parent = bestPet
                espElements[bestPet] = highlight
            end
        end
    end
end)

-- Player Hacks
local speedEnabled, jumpEnabled, boostOnStealEnabled = false, false, false
local originalWalkSpeed, originalJumpPower = 16, 50 -- Default values

local function getHumanoid()
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
end

local function applyPlayerHacks()
    local humanoid = getHumanoid()
    if not humanoid then return end
    
    humanoid.WalkSpeed = speedEnabled and 100 or originalWalkSpeed
    humanoid.JumpPower = jumpEnabled and 100 or originalJumpPower
end

LocalPlayer.CharacterAdded:Connect(function(character)
    print("MyHub: New character loaded. Applying hacks.")
    local humanoid = character:WaitForChild("Humanoid")
    originalWalkSpeed = humanoid.WalkSpeed
    originalJumpPower = humanoid.JumpPower
    applyPlayerHacks()
end)

-- Speed boost on steal (FIXED PATH)
local stolePetEvent = ReplicatedStorage:WaitForChild("Default"):WaitForChild("Events"):WaitForChild("StolePet")
if stolePetEvent then
    stolePetEvent.OnClientEvent:Connect(function(player)
        if boostOnStealEnabled and player == LocalPlayer then
            local humanoid = getHumanoid()
            if humanoid then
                print("MyHub: Speed boost activated!")
                humanoid.WalkSpeed = 200
                task.wait(3) -- Use task.wait for better performance
                applyPlayerHacks() -- Re-apply correct speed
            end
        end
    end)
    print("MyHub: 'StolePet' event connected successfully at new path.")
else
    warn("MyHub: Could not find 'StolePet' event.")
end

-- =================================================================
--                        BUTTONS
-- =================================================================

-- Best Pet ESP Button
createToggleButton(mainFrame, "Best Pet ESP", UDim2.new(0.025, 0, 0.15, 0), function(state)
    print("MyHub: Best Pet ESP toggled to " .. tostring(state))
    espEnabled.bestPet = state
    if not state then -- Clear ESP when turned off
        for item, element in pairs(espElements) do
            element:Destroy()
            espElements[item] = nil
        end
    end
end)

-- Player Hack Buttons
createToggleButton(mainFrame, "Speed Hack", UDim2.new(0.525, 0, 0.15, 0), function(state)
    print("MyHub: Speed Hack toggled to " .. tostring(state))
    speedEnabled = state
    applyPlayerHacks()
end)

createToggleButton(mainFrame, "Jump Hack", UDim2.new(0.025, 0, 0.35, 0), function(state)
    print("MyHub: Jump Hack toggled to " .. tostring(state))
    jumpEnabled = state
    applyPlayerHacks()
end)

createToggleButton(mainFrame, "Boost on Steal", UDim2.new(0.525, 0, 0.35, 0), function(state)
    print("MyHub: Boost on Steal toggled to " .. tostring(state))
    boostOnStealEnabled = state
end)

-- Discord Button
local discordButton = Instance.new("TextButton")
discordButton.Parent = mainFrame
discordButton.Position = UDim2.new(0.025, 0, 0.70, 0)
discordButton.Size = UDim2.new(0.95, 0, 0, 40)
discordButton.BackgroundColor3 = Color3.fromRGB(86, 98, 246)
discordButton.Font = Enum.Font.SourceSansBold
discordButton.Text = "Copy Discord Link"
discordButton.TextColor3 = Color3.fromRGB(255, 255, 255)
discordButton.TextSize = 16
discordButton.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(discordLink)
    end
end)

print("MyHub v1.2: Fully loaded and ready.")
