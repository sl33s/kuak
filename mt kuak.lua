--[[
    Script: MyHub v1.3 (Final & Stable)
    Author: kuak saudi
    Description: A stable and working script for Steal a Brainrot.
]]

-- =================================================================
--                        CONFIGURATION
-- =================================================================
local authorName = "kuak saudi"
local discordLink = "https://discord.gg/YprBskZdc9"

-- =================================================================
--                        INITIALIZATION
-- =================================================================
print("MyHub v1.3: Initializing..." )

-- Clean up old GUI to prevent stacking
if game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("MyHubGui") then
    game:GetService("Players").LocalPlayer.PlayerGui.MyHubGui:Destroy()
    print("MyHub: Old GUI found and destroyed.")
end

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

-- Local Player
local LocalPlayer = Players.LocalPlayer

-- Main GUI container
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MyHubGui"
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false
print("MyHub: ScreenGui created.")

-- =================================================================
--                        MAIN HUB GUI
-- =================================================================
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Parent = screenGui
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderColor3 = Color3.fromRGB(80, 80, 80)
mainFrame.BorderSizePixel = 2
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -125)
mainFrame.Size = UDim2.new(0, 350, 0, 250)
mainFrame.Draggable = true
mainFrame.Active = true
mainFrame.Visible = true -- CRITICAL FIX: Ensure the frame is visible from the start

local titleLabel = Instance.new("TextLabel")
titleLabel.Parent = mainFrame
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.Text = "MyHub v1.3 - By " .. authorName
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 18

print("MyHub: Main frame and title created successfully.")

-- =================================================================
--                        FEATURES
-- =================================================================

-- Player Hacks
local speedEnabled, jumpEnabled, boostOnStealEnabled = false, false, false
local originalWalkSpeed, originalJumpPower = 16, 50

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
    local humanoid = character:WaitForChild("Humanoid")
    originalWalkSpeed = humanoid.WalkSpeed
    originalJumpPower = humanoid.JumpPower
    applyPlayerHacks()
end)

-- Speed boost on steal (FIXED PATH)
local stolePetEvent = ReplicatedStorage:WaitForChild("Default"):WaitForChild("Events"):WaitForChild("StolePet")
stolePetEvent.OnClientEvent:Connect(function(player)
    if boostOnStealEnabled and player == LocalPlayer then
        local humanoid = getHumanoid()
        if humanoid then
            humanoid.WalkSpeed = 200
            task.wait(3)
            applyPlayerHacks()
        end
    end
end)
print("MyHub: 'StolePet' event connected.")

-- ESP Features
local espEnabled = { bestPet = false }
RunService.RenderStepped:Connect(function()
    if not espEnabled.bestPet then return end
    
    local housesFolder = Workspace:FindFirstChild("Houses")
    if not housesFolder then return end

    for _, house in pairs(housesFolder:GetChildren()) do
        if house:IsA("Model") and house:FindFirstChild("Head") then
            local bestPet, maxStrength = nil, -1
            local petsFolder = house:FindFirstChild("Pets")
            if petsFolder then
                for _, pet in pairs(petsFolder:GetChildren()) do
                    if pet:FindFirstChild("ESP_Highlight") then pet.ESP_Highlight:Destroy() end
                    local strength = pet:GetAttribute("Strength")
                    if strength and strength > maxStrength then
                        maxStrength = strength
                        bestPet = pet
                    end
                end
            end
            
            if bestPet and not bestPet:FindFirstChild("ESP_Highlight") then
                local highlight = Instance.new("BoxHandleAdornment")
                highlight.Name = "ESP_Highlight"
                highlight.Adornee = bestPet
                highlight.Size = bestPet.Size + Vector3.new(1, 1, 1)
                highlight.Color3 = Color3.fromRGB(255, 255, 0)
                highlight.Transparency = 0.5
                highlight.AlwaysOnTop = true
                highlight.Parent = bestPet
            end
        end
    end
end)
print("MyHub: ESP service is running.")

-- =================================================================
--                        BUTTONS
-- =================================================================
-- Function to create a toggle button
local function createToggleButton(text, position, callback)
    local toggled = false
    local button = Instance.new("TextButton")
    button.Parent = mainFrame -- Attach directly to the visible frame
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

-- Create all buttons
createToggleButton("Best Pet ESP", UDim2.new(0.025, 0, 0.15, 0), function(state)
    espEnabled.bestPet = state
    if not state then -- Clear ESP when turned off
        for _, house in pairs(Workspace.Houses:GetChildren()) do
            if house:FindFirstChild("Pets") then
                for _, pet in pairs(house.Pets:GetChildren()) do
                    if pet:FindFirstChild("ESP_Highlight") then pet.ESP_Highlight:Destroy() end
                end
            end
        end
    end
end)

createToggleButton("Speed Hack", UDim2.new(0.525, 0, 0.15, 0), function(state)
    speedEnabled = state
    applyPlayerHacks()
end)

createToggleButton("Jump Hack", UDim2.new(0.025, 0, 0.35, 0), function(state)
    jumpEnabled = state
    applyPlayerHacks()
end)

createToggleButton("Boost on Steal", UDim2.new(0.525, 0, 0.35, 0), function(state)
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
    if setclipboard then setclipboard(discordLink) end
end)

print("MyHub v1.3: All buttons created. Script fully loaded.")
