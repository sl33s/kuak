--[[
    Script: MyHub v1.0
    Author: [Your Name]
    Description: A feature-rich script for Steal a Brainrot.
]]

-- =================================================================
--                        CONFIGURATION
-- =================================================================
local authorName = "[kuak saudi]"
local discordLink = "[https://discord.gg/YprBskZdc9]" -- Example: "https://discord.gg/your-server"

-- =================================================================
--                        INITIALIZATION
-- =================================================================
-- Prevents the script from running twice
if game.Players.LocalPlayer:WaitForChild("PlayerGui" ):FindFirstChild("MyHubGui") then
    game.Players.LocalPlayer.PlayerGui.MyHubGui:Destroy()
end

-- Main GUI container
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MyHubGui"
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- Local Player
local LocalPlayer = Players.LocalPlayer

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
mainFrame.Size = UDim2.new(0, 350, 0, 300)
mainFrame.Draggable = true
mainFrame.Active = true

local titleLabel = Instance.new("TextLabel")
titleLabel.Parent = mainFrame
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.Text = "MyHub v1.0 - By " .. authorName
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 18

-- Function to create a toggle button
local function createToggleButton(parent, text, position, callback)
    local toggled = false
    local button = Instance.new("TextButton")
    button.Parent = parent
    button.Position = position
    button.Size = UDim2.new(0.45, 0, 0, 35)
    button.BackgroundColor3 = Color3.fromRGB(190, 40, 40) -- Red (Off)
    button.Font = Enum.Font.SourceSansBold
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14

    button.MouseButton1Click:Connect(function()
        toggled = not toggled
        button.BackgroundColor3 = toggled and Color3.fromRGB(40, 190, 40) or Color3.fromRGB(190, 40, 40) -- Green (On) / Red (Off)
        callback(toggled)
    end)
    return button
end

-- =================================================================
--                        FEATURES
-- =================================================================

-- ESP Features
local espEnabled = { houseTimer = false, bestPet = false }
local espConnections = {}

function updateEsp(enabled)
    -- Clear previous ESP elements
    for _, conn in pairs(espConnections) do conn:Disconnect() end
    espConnections = {}
    for _, v in pairs(Workspace:GetDescendants()) do
        if v.Name == "ESP_ELEMENT" then v:Destroy() end
    end

    if not enabled then return end

    -- Create new ESP elements
    table.insert(espConnections, RunService.RenderStepped:Connect(function()
        for _, house in pairs(Workspace.Houses:GetChildren()) do
            if house:FindFirstChild("Humanoid") and house:FindFirstChild("Head") then
                local timer = house:FindFirstChild("T")
                if espEnabled.houseTimer and timer and timer:IsA("BillboardGui") then
                    timer.Enabled = true
                elseif not espEnabled.houseTimer and timer and timer:IsA("BillboardGui") then
                    timer.Enabled = false
                end

                if espEnabled.bestPet then
                    local bestPet, maxStrength = nil, -1
                    for _, pet in pairs(house.Pets:GetChildren()) do
                        local strength = pet:GetAttribute("Strength")
                        if strength and strength > maxStrength then
                            maxStrength = strength
                            bestPet = pet
                        end
                    end
                    
                    if bestPet and not bestPet:FindFirstChild("ESP_ELEMENT") then
                        local highlight = Instance.new("BoxHandleAdornment")
                        highlight.Name = "ESP_ELEMENT"
                        highlight.Adornee = bestPet
                        highlight.Size = bestPet.Size + Vector3.new(1, 1, 1)
                        highlight.Color3 = Color3.fromRGB(255, 255, 0) -- Yellow
                        highlight.Transparency = 0.5
                        highlight.AlwaysOnTop = true
                        highlight.Parent = bestPet
                    end
                end
            end
        end
    end))
end

-- Player Hacks
local speedEnabled, jumpEnabled, boostOnStealEnabled = false, false, false
local originalWalkSpeed, originalJumpPower = 16, 50

function applyPlayerHacks()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local humanoid = LocalPlayer.Character.Humanoid
        if not originalWalkSpeed then originalWalkSpeed = humanoid.WalkSpeed end
        if not originalJumpPower then originalJumpPower = humanoid.JumpPower end
        
        humanoid.WalkSpeed = speedEnabled and 100 or originalWalkSpeed
        humanoid.JumpPower = jumpEnabled and 100 or originalJumpPower
    end
end

LocalPlayer.CharacterAdded:Connect(function(character)
    character:WaitForChild("Humanoid").HealthChanged:Connect(function()
        applyPlayerHacks()
    end)
end)

-- Speed boost on steal
if Workspace.Events:FindFirstChild("StolePet") then
    Workspace.Events.StolePet.OnClientEvent:Connect(function(player)
        if boostOnStealEnabled and player == LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            local humanoid = LocalPlayer.Character.Humanoid
            humanoid.WalkSpeed = 200 -- Temporary high speed
            wait(3) -- Boost duration
            humanoid.WalkSpeed = speedEnabled and 100 or originalWalkSpeed -- Return to normal/hacked speed
        end
    end)
end

-- =================================================================
--                        BUTTONS
-- =================================================================

-- ESP Buttons
createToggleButton(mainFrame, "House Timers ESP", UDim2.new(0.025, 0, 0.15, 0), function(state)
    espEnabled.houseTimer = state
    updateEsp(espEnabled.houseTimer or espEnabled.bestPet)
end)

createToggleButton(mainFrame, "Best Pet ESP", UDim2.new(0.525, 0, 0.15, 0), function(state)
    espEnabled.bestPet = state
    updateEsp(espEnabled.houseTimer or espEnabled.bestPet)
end)

-- Player Hack Buttons
createToggleButton(mainFrame, "Speed Hack", UDim2.new(0.025, 0, 0.35, 0), function(state)
    speedEnabled = state
    applyPlayerHacks()
end)

createToggleButton(mainFrame, "Jump Hack", UDim2.new(0.525, 0, 0.35, 0), function(state)
    jumpEnabled = state
    applyPlayerHacks()
end)

createToggleButton(mainFrame, "Boost on Steal", UDim2.new(0.025, 0, 0.55, 0), function(state)
    boostOnStealEnabled = state
end)

-- Discord Button
local discordButton = Instance.new("TextButton")
discordButton.Parent = mainFrame
discordButton.Position = UDim2.new(0.025, 0, 0.75, 0)
discordButton.Size = UDim2.new(0.95, 0, 0, 40)
discordButton.BackgroundColor3 = Color3.fromRGB(86, 98, 246) -- Discord color
discordButton.Font = Enum.Font.SourceSansBold
discordButton.Text = "Copy Discord Link"
discordButton.TextColor3 = Color3.fromRGB(255, 255, 255)
discordButton.TextSize = 16
discordButton.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(discordLink)
    else
        warn("Executor does not support 'setclipboard'.")
    end
end)
