--[[
  BoostFPSHub v8.0 - Delta Fixed Edition
  Simple & Working Version for Delta Executor
]]

-- ========== BASIC SETUP ==========
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Wait for game
if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(1)

-- ========== SIMPLE UI CREATION ==========
local function CreateSimpleUI()
    -- Create ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "FPSBoosterUI"
    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.ResetOnSpawn = false
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 300, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    -- Corner
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = MainFrame
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Text = "🚀 FPS Booster v8.0"
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    Title.TextColor3 = Color3.fromRGB(0, 200, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.Parent = MainFrame
    
    -- Title Corner
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 10)
    TitleCorner.Parent = Title
    
    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Text = "X"
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -35, 0, 5)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = 16
    CloseButton.Parent = Title
    
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- FPS Counter
    local FPSLabel = Instance.new("TextLabel")
    FPSLabel.Text = "FPS: --"
    FPSLabel.Size = UDim2.new(1, -20, 0, 30)
    FPSLabel.Position = UDim2.new(0, 10, 0, 50)
    FPSLabel.BackgroundTransparency = 1
    FPSLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    FPSLabel.Font = Enum.Font.Gotham
    FPSLabel.TextSize = 16
    FPSLabel.TextXAlignment = Enum.TextXAlignment.Left
    FPSLabel.Parent = MainFrame
    
    -- Update FPS
    task.spawn(function()
        while ScreenGui and ScreenGui.Parent do
            local fps = math.floor(1 / RunService.RenderStepped:Wait())
            FPSLabel.Text = "FPS: " .. fps
            task.wait(0.5)
        end
    end)
    
    -- Options Frame
    local OptionsFrame = Instance.new("ScrollingFrame")
    OptionsFrame.Size = UDim2.new(1, -20, 1, -100)
    OptionsFrame.Position = UDim2.new(0, 10, 0, 90)
    OptionsFrame.BackgroundTransparency = 1
    OptionsFrame.BorderSizePixel = 0
    OptionsFrame.ScrollBarThickness = 4
    OptionsFrame.Parent = MainFrame
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 10)
    UIListLayout.Parent = OptionsFrame
    
    -- Store toggles state
    local Toggles = {}
    
    -- Function to create toggle
    local function CreateToggle(text, default, callback)
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Size = UDim2.new(1, 0, 0, 30)
        ToggleFrame.BackgroundTransparency = 1
        ToggleFrame.Parent = OptionsFrame
        
        local ToggleButton = Instance.new("TextButton")
        ToggleButton.Size = UDim2.new(0, 50, 0, 25)
        ToggleButton.Position = UDim2.new(1, -55, 0, 0)
        ToggleButton.BackgroundColor3 = default and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(100, 100, 100)
        ToggleButton.Text = default and "ON" or "OFF"
        ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleButton.Font = Enum.Font.Gotham
        ToggleButton.TextSize = 12
        ToggleButton.Parent = ToggleFrame
        
        local ToggleLabel = Instance.new("TextLabel")
        ToggleLabel.Text = text
        ToggleLabel.Size = UDim2.new(1, -60, 1, 0)
        ToggleLabel.Position = UDim2.new(0, 0, 0, 0)
        ToggleLabel.BackgroundTransparency = 1
        ToggleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        ToggleLabel.Font = Enum.Font.Gotham
        ToggleLabel.TextSize = 14
        ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        ToggleLabel.Parent = ToggleFrame
        
        ToggleButton.MouseButton1Click:Connect(function()
            local newState = ToggleButton.Text == "OFF"
            ToggleButton.Text = newState and "ON" or "OFF"
            ToggleButton.BackgroundColor3 = newState and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(100, 100, 100)
            
            if callback then
                callback(newState)
            end
        end)
        
        Toggles[text] = ToggleButton
        return ToggleButton
    end
    
    -- ========== OPTIMIZATION FUNCTIONS ==========
    
    -- 1. Ultra Boost
    CreateToggle("Ultra Boost FPS", true, function(state)
        if state then
            settings().Rendering.QualityLevel = 1
            settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
        else
            settings().Rendering.QualityLevel = 10
            Lighting.GlobalShadows = true
        end
    end)
    
    -- 2. Remove Particles
    local particleTask
    CreateToggle("Remove Particle Effects", true, function(state)
        if particleTask then
            particleTask = nil
        end
        
        if state then
            particleTask = task.spawn(function()
                while particleTask do
                    task.wait(1)
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                            obj.Enabled = false
                        end
                    end
                end
            end)
        else
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                    obj.Enabled = true
                end
            end
        end
    end)
    
    -- 3. No Shadows
    CreateToggle("Disable Shadows", true, function(state)
        Lighting.GlobalShadows = not state
    end)
    
    -- 4. Auto Clean Memory
    local cleanTask
    CreateToggle("Auto Clean Memory", true, function(state)
        if cleanTask then
            cleanTask = nil
        end
        
        if state then
            cleanTask = task.spawn(function()
                while cleanTask do
                    task.wait(30)
                    collectgarbage("collect")
                end
            end)
        end
    end)
    
    -- 5. Blox Fruits Optimizations
    local isBloxFruit = game.PlaceId == 2753915549 or game.PlaceId == 4442272183 or game.PlaceId == 7449423635
    
    if isBloxFruit then
        -- Skill Effects
        local skillTask
        CreateToggle("BF: No Skill Effects", false, function(state)
            if skillTask then
                skillTask = nil
            end
            
            if state then
                skillTask = task.spawn(function()
                    while skillTask do
                        task.wait(1)
                        pcall(function()
                            if game:GetService("ReplicatedStorage"):FindFirstChild("Effect") then
                                for _, effect in pairs(game:GetService("ReplicatedStorage").Effect.Container:GetDescendants()) do
                                    if effect:IsA("ParticleEmitter") then
                                        effect.Enabled = false
                                    end
                                end
                            end
                        end)
                    end
                end)
            end
        end)
        
        -- Fruit Effects
        local fruitTask
        CreateToggle("BF: No Fruit Effects", false, function(state)
            if fruitTask then
                fruitTask = nil
            end
            
            if state then
                fruitTask = task.spawn(function()
                    while fruitTask do
                        task.wait(2)
                        pcall(function()
                            for _, fruit in pairs(Workspace:GetChildren()) do
                                if fruit:FindFirstChild("Handle") then
                                    for _, effect in pairs(fruit.Handle:GetDescendants()) do
                                        if effect:IsA("ParticleEmitter") then
                                            effect.Enabled = false
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end)
            end
        end)
    end
    
    -- 6. CPU Optimize (PC only)
    if not UserInputService.TouchEnabled then
        local cpuConnections = {}
        CreateToggle("CPU Optimization", true, function(state)
            if state then
                local conn1 = UserInputService.WindowFocused:Connect(function()
                    RunService:SetFpsCap(999)
                end)
                
                local conn2 = UserInputService.WindowFocusReleased:Connect(function()
                    RunService:SetFpsCap(30)
                end)
                
                table.insert(cpuConnections, conn1)
                table.insert(cpuConnections, conn2)
            else
                for _, conn in pairs(cpuConnections) do
                    conn:Disconnect()
                end
                cpuConnections = {}
                RunService:SetFpsCap(999)
            end
        end)
    end
    
    -- 7. Mobile Optimizations
    if UserInputService.TouchEnabled then
        CreateToggle("Mobile: Battery Saver", true, function(state)
            if state then
                RunService:SetFpsCap(30)
                Lighting.Brightness = 1.5
            else
                RunService:SetFpsCap(60)
                Lighting.Brightness = 3
            end
        end)
    end
    
    -- Restore Button
    local RestoreButton = Instance.new("TextButton")
    RestoreButton.Text = "🔄 Restore Default Settings"
    RestoreButton.Size = UDim2.new(1, -20, 0, 40)
    RestoreButton.Position = UDim2.new(0, 10, 1, -50)
    RestoreButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    RestoreButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    RestoreButton.Font = Enum.Font.Gotham
    RestoreButton.TextSize = 14
    RestoreButton.Parent = MainFrame
    
    RestoreButton.MouseButton1Click:Connect(function()
        -- Restore graphics
        settings().Rendering.QualityLevel = 10
        settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level20
        Lighting.GlobalShadows = true
        Lighting.FogEnd = 100000
        Lighting.Brightness = 2
        
        -- Stop all tasks
        particleTask = nil
        cleanTask = nil
        skillTask = nil
        fruitTask = nil
        
        -- Enable all particles
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                obj.Enabled = true
            end
        end
        
        -- Set FPS cap
        RunService:SetFpsCap(60)
        
        -- Reset toggle buttons
        for _, toggle in pairs(Toggles) do
            toggle.Text = "OFF"
            toggle.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        end
    end)
    
    -- Make draggable
    local dragging = false
    local dragInput, dragStart, startPos
    
    Title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    Title.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, 
                                          startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    -- Hide/show with key (Right Control)
    local hidden = false
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Enum.KeyCode.RightControl then
            hidden = not hidden
            MainFrame.Visible = not hidden
        end
    end)
    
    return ScreenGui
end

-- ========== INITIAL OPTIMIZATIONS ==========
-- Apply basic optimizations on start
task.spawn(function()
    settings().Rendering.QualityLevel = 1
    settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    
    -- Mobile specific
    if UserInputService.TouchEnabled then
        RunService:SetFpsCap(30)
        Lighting.Brightness = 1.5
    else
        RunService:SetFpsCap(999)
    end
end)

-- ========== MAIN EXECUTION ==========
-- Try to create UI with error handling
local success, err = pcall(function()
    local ui = CreateSimpleUI()
    
    -- Success notification
    task.wait(1)
    
    -- Create notification
    local Notif = Instance.new("ScreenGui")
    Notif.Name = "Notification"
    Notif.Parent = game:GetService("CoreGui")
    Notif.ResetOnSpawn = false
    
    local NotifFrame = Instance.new("Frame")
    NotifFrame.Size = UDim2.new(0, 250, 0, 60)
    NotifFrame.Position = UDim2.new(0.5, -125, 0, 20)
    NotifFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    NotifFrame.BorderSizePixel = 0
    NotifFrame.Parent = Notif
    
    local NotifCorner = Instance.new("UICorner")
    NotifCorner.CornerRadius = UDim.new(0, 8)
    NotifCorner.Parent = NotifFrame
    
    local NotifText = Instance.new("TextLabel")
    NotifText.Text = "✅ BoostFPSHub v8.0 Loaded!\nPress Right Ctrl to hide/show"
    NotifText.Size = UDim2.new(1, 0, 1, 0)
    NotifText.BackgroundTransparency = 1
    NotifText.TextColor3 = Color3.fromRGB(0, 200, 255)
    NotifText.Font = Enum.Font.Gotham
    NotifText.TextSize = 14
    NotifText.TextWrapped = true
    NotifText.Parent = NotifFrame
    
    -- Auto remove notification
    task.delay(5, function()
        Notif:Destroy()
    end)
end)

if not success then
    -- Simple fallback if UI fails
    warn("[BoostFPSHub] Using fallback optimizations only")
    
    -- Apply optimizations anyway
    settings().Rendering.QualityLevel = 1
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
end

-- Simple FPS counter in console
task.spawn(function()
    while task.wait(2) do
        local fps = math.floor(1 / RunService.RenderStepped:Wait())
        print("[FPS Booster] Current FPS:", fps)
    end
end)

print("🎯 BoostFPSHub v8.0 - Delta Fixed Edition")
print("✅ Script loaded successfully!")
print("📱 Mobile Support:", UserInputService.TouchEnabled and "Yes" or "No")
print("🎮 Press Right Ctrl to toggle UI")
