--[[
    Script: Kuak Hub v1.0
    Author: kuak saudi
    Game: Blox Fruits
    Description: A powerful script for auto-farming and more.
]]

print("Kuak Hub v1.0: Initializing...")

-- =================================================================
--                        GUI Library (Simplified)
-- =================================================================
-- This is a custom GUI library to ensure it works reliably.
local KuakGUI = {}
do
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "KuakHubGui"
    screenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    screenGui.ResetOnSpawn = false

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Parent = screenGui
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BorderColor3 = Color3.fromRGB(80, 80, 80)
    mainFrame.BorderSizePixel = 2
    mainFrame.Position = UDim2.new(0.02, 0, 0.5, -200)
    mainFrame.Size = UDim2.new(0, 400, 0, 400)
    mainFrame.Draggable = true
    mainFrame.Active = true
    mainFrame.Visible = true

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Parent = mainFrame
    titleLabel.Size = UDim2.new(1, 0, 0, 30)
    titleLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Text = "Kuak Hub v1.0 - Blox Fruits"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 18

    local tabsFrame = Instance.new("Frame")
    tabsFrame.Parent = mainFrame
    tabsFrame.Position = UDim2.new(0, 0, 0.075, 0)
    tabsFrame.Size = UDim2.new(1, 0, 0.925, 0)
    tabsFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)

    function KuakGUI:CreateTab(name)
        local page = Instance.new("Frame")
        page.Name = name
        page.Parent = tabsFrame
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        page.Visible = false -- Hide by default
        
        -- Simple tab button system needed here, for now we just show the first tab
        if #tabsFrame:GetChildren() == 1 then page.Visible = true end
        
        return page
    end

    function KuakGUI:CreateToggle(parent, text, callback)
        local toggled = false
        local button = Instance.new("TextButton")
        button.Parent = parent
        button.Size = UDim2.new(0.9, 0, 0, 30)
        button.Position = UDim2.new(0.05, 0, 0.1 + (#parent:GetChildren() * 0.1), 0)
        button.BackgroundColor3 = Color3.fromRGB(190, 40, 40)
        button.Font = Enum.Font.SourceSans
        button.Text = text
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextSize = 16
        
        button.MouseButton1Click:Connect(function()
            toggled = not toggled
            button.BackgroundColor3 = toggled and Color3.fromRGB(40, 190, 40) or Color3.fromRGB(190, 40, 40)
            pcall(callback, toggled)
        end)
        return button
    end
end
print("Kuak Hub: GUI Loaded.")

-- =================================================================
--                        Main Script
-- =================================================================
local Main = {}
Main.Enabled = false
Main.Weapon = "Melee" -- Default weapon

local Player = game:GetService("Players").LocalPlayer
local Workspace = game:GetService("Workspace")

-- Auto Farm Coroutine
coroutine.wrap(function()
    while wait() do
        if Main.Enabled then
            pcall(function()
                local currentQuest = Player.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text
                
                if currentQuest == "No Quest" then
                    -- Find quest giver for current level
                    local level = Player.Data.Level.Value
                    local closestGiver
                    local minDist = math.huge
                    for _, v in pairs(Workspace.Enemies:GetChildren()) do
                        if v.Name:find("Quest") and v:FindFirstChild("Humanoid") then
                            local questLevel = v:GetAttribute("Level")
                            if questLevel and level >= questLevel then
                                local dist = (Player.Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude
                                if dist < minDist then
                                    minDist = dist
                                    closestGiver = v
                                end
                            end
                        end
                    end
                    if closestGiver then
                        Player.Character.Humanoid:MoveTo(closestGiver.HumanoidRootPart.Position)
                        wait(1)
                        fireproximityprompt(closestGiver.HumanoidRootPart, 1)
                        wait(1)
                    end
                else
                    -- Farm mobs for the current quest
                    local questProgress = Player.PlayerGui.Main.Quest.Container.QuestTitle.Progress.Text
                    local needed = tonumber(questProgress:match("/(%d+)"))
                    local current = tonumber(questProgress:match("(%d+)/"))
                    
                    if current < needed then
                        local mobName = currentQuest:match("Defeat %d+ (.+)")
                        local targetMob
                        local minDist = math.huge
                        for _, v in pairs(Workspace.Enemies:GetChildren()) do
                            if v.Name == mobName and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                                local dist = (Player.Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude
                                if dist < minDist then
                                    minDist = dist
                                    targetMob = v
                                end
                            end
                        end
                        
                        if targetMob then
                            -- Teleport and attack
                            while targetMob.Humanoid.Health > 0 and Main.Enabled do
                                Player.Character.HumanoidRootPart.CFrame = targetMob.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
                                game:GetService("VirtualUser"):SetFocus(Enum.UserInputType.Keyboard, 0)
                                game:GetService("VirtualUser"):SendKey("Z", false, 0) -- Example for Melee, can be customized
                                wait(0.5)
                            end
                        end
                    end
                end
            end)
        end
    end
end)()
print("Kuak Hub: Auto Farm thread started.")

-- ESP Coroutine
coroutine.wrap(function()
    local espEnabled = { players = false, fruits = false, chests = false }
    local espElements = {}

    KuakGUI:CreateToggle(KuakGUI:CreateTab("ESP"), "ESP Players", function(state) espEnabled.players = state end)
    KuakGUI:CreateToggle(KuakGUI:CreateTab("ESP"), "ESP Fruits", function(state) espEnabled.fruits = state end)
    KuakGUI:CreateToggle(KuakGUI:CreateTab("ESP"), "ESP Chests", function(state) espEnabled.chests = state end)

    while wait(0.5) do
        -- Clear old ESP
        for item, element in pairs(espElements) do
            if not item or not item.Parent then
                element:Destroy()
                espElements[item] = nil
            end
        end

        -- Player ESP
        if espEnabled.players then
            for _, player in pairs(game:GetService("Players"):GetPlayers()) do
                if player ~= Player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    -- Create or update ESP element
                end
            end
        end

        -- Fruit and Chest ESP
        for _, v in pairs(Workspace:GetChildren()) do
            if espEnabled.fruits and v.Name:find("Fruit") and v:IsA("Model") then
                -- Create or update ESP element
            end
            if espEnabled.chests and v.Name:find("Chest") and v:IsA("Model") then
                -- Create or update ESP element
            end
        end
    end
end)()
print("Kuak Hub: ESP thread started.")

-- =================================================================
--                        GUI Setup
-- =================================================================
local farmTab = KuakGUI:CreateTab("Main")

KuakGUI:CreateToggle(farmTab, "Enable Auto Farm", function(state)
    Main.Enabled = state
    print("Kuak Hub: Auto Farm set to " .. tostring(state))
end)

print("Kuak Hub: Script fully loaded and running.")
