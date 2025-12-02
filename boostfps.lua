-- BoostFPSHub v2.1.1 — Tối Ưu FPS Roblox
-- Language: Vietnamese
-- Fixed for Delta Executor - ĐÃ SỬA LỖI HOÀN CHỈNH

-- === 0. KHỞI TẠO BIẾN TOÀN CỤC ===
getgenv().BoostFPS = {
    RemoveParticles = false,
    AutoClean = false,
    BF_NoSkillEffects = false,
    BF_NoFruitEffects = false,
    BF_ReducePlayers = false,
    BF_LocalLoad = false,
    BF_ReduceWater = false,
    BF_OptimizeIslands = false
}

-- Lưu trữ các task đang chạy
local ActiveTasks = {}

-- === 1. LOADING SCREEN ===
local function ShowLoadingScreen()
    if game:GetService("CoreGui"):FindFirstChild("BoostFPS_Loading") then return end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "BoostFPS_Loading"
    ScreenGui.Parent = game:GetService("CoreGui")

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 300, 0, 80)
    Frame.Position = UDim2.new(0.5, -150, 0.5, -40)
    Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Frame.BorderSizePixel = 0
    Frame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = Frame

    local TextLabel = Instance.new("TextLabel")
    TextLabel.Text = "BoostFPSHub v2.1.1 - Đang tải..."
    TextLabel.Size = UDim2.new(1, 0, 1, 0)
    TextLabel.BackgroundTransparency = 1
    TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.Font = Enum.Font.Gotham
    TextLabel.TextSize = 16
    TextLabel.Parent = Frame

    task.wait(1.5)
    ScreenGui:Destroy()
end

-- === 2. KHỞI TẠO ===
if not game:IsLoaded() then game.Loaded:Wait() end

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Lưu trạng thái gốc
local OriginalState = {
    Lighting = {
        GlobalShadows = Lighting.GlobalShadows,
        FogEnd = Lighting.FogEnd,
        Brightness = Lighting.Brightness,
        Technology = Lighting.Technology
    },
    Global = {
        QualityLevel = settings().Rendering.QualityLevel,
        MeshDetail = settings().Rendering.MeshPartDetailLevel
    }
}

-- === 3. TẠO GIAO DIỆN ĐƠN GIẢN ===
local function CreateSimpleUI()
    -- Tạo ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "BoostFPSHubUI"
    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.ResetOnSpawn = false

    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 350, 0, 450)
    MainFrame.Position = UDim2.new(0.5, -175, 0.5, -225)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame

    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame

    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 8)
    TitleCorner.Parent = TitleBar

    local TitleText = Instance.new("TextLabel")
    TitleText.Text = "BoostFPSHub v2.1.1"
    TitleText.Size = UDim2.new(1, -40, 1, 0)
    TitleText.Position = UDim2.new(0, 10, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.TextColor3 = Color3.fromRGB(0, 200, 255)
    TitleText.Font = Enum.Font.GothamBold
    TitleText.TextSize = 16
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Parent = TitleBar

    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Text = "X"
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -35, 0, 5)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = 14
    CloseButton.Parent = TitleBar

    -- Tabs
    local TabsContainer = Instance.new("Frame")
    TabsContainer.Size = UDim2.new(1, -20, 0, 30)
    TabsContainer.Position = UDim2.new(0, 10, 0, 50)
    TabsContainer.BackgroundTransparency = 1
    TabsContainer.Parent = MainFrame

    local TabsList = Instance.new("UIListLayout")
    TabsList.FillDirection = Enum.FillDirection.Horizontal
    TabsList.Padding = UDim.new(0, 5)
    TabsList.Parent = TabsContainer

    -- Tab Buttons
    local Tabs = {}
    local TabButtons = {}

    local function CreateTab(name)
        local TabButton = Instance.new("TextButton")
        TabButton.Text = name
        TabButton.Size = UDim2.new(0, 80, 1, 0)
        TabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        TabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        TabButton.Font = Enum.Font.Gotham
        TabButton.TextSize = 12
        TabButton.Parent = TabsContainer
        
        local TabFrame = Instance.new("ScrollingFrame")
        TabFrame.Size = UDim2.new(1, -20, 1, -100)
        TabFrame.Position = UDim2.new(0, 10, 0, 90)
        TabFrame.BackgroundTransparency = 1
        TabFrame.BorderSizePixel = 0
        TabFrame.ScrollBarThickness = 4
        TabFrame.Visible = false
        TabFrame.Parent = MainFrame
        
        local TabList = Instance.new("UIListLayout")
        TabList.Padding = UDim.new(0, 10)
        TabList.Parent = TabFrame
        
        Tabs[name] = TabFrame
        TabButtons[name] = TabButton
        
        TabButton.MouseButton1Click:Connect(function()
            for tabName, tabFrame in pairs(Tabs) do
                tabFrame.Visible = false
                TabButtons[tabName].BackgroundColor3 = Color3.fromRGB(50, 50, 60)
            end
            TabFrame.Visible = true
            TabButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        end)
        
        return TabFrame
    end

    -- Create tabs
    local MainTab = CreateTab("Main")
    local BFTab = CreateTab("Blox Fruit")
    local SettingsTab = CreateTab("Settings")
    
    -- Activate first tab
    TabButtons["Main"].BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    Tabs["Main"].Visible = true

    -- FPS Counter
    local FPSLabel = Instance.new("TextLabel")
    FPSLabel.Text = "FPS: --"
    FPSLabel.Size = UDim2.new(0, 100, 0, 20)
    FPSLabel.Position = UDim2.new(1, -110, 0, 50)
    FPSLabel.BackgroundTransparency = 1
    FPSLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
    FPSLabel.Font = Enum.Font.GothamBold
    FPSLabel.TextSize = 12
    FPSLabel.Parent = MainFrame

    -- Update FPS Counter
    local fpsUpdateTask = task.spawn(function()
        while ScreenGui and ScreenGui.Parent do
            task.wait(0.5)
            local success, fps = pcall(function()
                return math.floor(1 / RunService.RenderStepped:Wait())
            end)
            if success then
                FPSLabel.Text = "FPS: " .. fps
            end
        end
    end)
    table.insert(ActiveTasks, fpsUpdateTask)

    -- Function to create toggle
    local function CreateToggle(parent, text, default, callback)
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Size = UDim2.new(1, 0, 0, 30)
        ToggleFrame.BackgroundTransparency = 1
        ToggleFrame.Parent = parent
        
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
        
        return ToggleButton
    end

    -- === MAIN TAB ===
    -- Ultra Boost
    CreateToggle(MainTab, "Ultra Boost FPS", true, function(value)
        pcall(function()
            if value then
                settings().Rendering.QualityLevel = 1
                settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
                Lighting.GlobalShadows = false
                Lighting.FogEnd = 9e9
            else
                settings().Rendering.QualityLevel = OriginalState.Global.QualityLevel
                settings().Rendering.MeshPartDetailLevel = OriginalState.Global.MeshDetail
                Lighting.GlobalShadows = OriginalState.Lighting.GlobalShadows
                Lighting.FogEnd = OriginalState.Lighting.FogEnd
            end
        end)
    end)

    -- Remove Particles
    CreateToggle(MainTab, "Xóa Hiệu Ứng", true, function(value)
        getgenv().BoostFPS.RemoveParticles = value
        
        if ActiveTasks["particleTask"] then
            ActiveTasks["particleTask"] = nil
        end
        
        if value then
            local taskId = "particleTask"
            ActiveTasks[taskId] = task.spawn(function()
                while getgenv().BoostFPS.RemoveParticles do
                    task.wait(1)
                    pcall(function()
                        for _, obj in pairs(Workspace:GetDescendants()) do
                            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                                obj.Enabled = false
                            end
                        end
                    end)
                end
            end)
        else
            pcall(function()
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                        obj.Enabled = true
                    end
                end
            end)
        end
    end)

    -- No Shadows
    CreateToggle(MainTab, "Tắt Bóng Đổ", true, function(value)
        pcall(function()
            Lighting.GlobalShadows = not value
        end)
    end)

    -- Auto Clean
    CreateToggle(MainTab, "Tự Động Dọn RAM", true, function(value)
        getgenv().BoostFPS.AutoClean = value
        
        if ActiveTasks["cleanTask"] then
            ActiveTasks["cleanTask"] = nil
        end
        
        if value then
            local taskId = "cleanTask"
            ActiveTasks[taskId] = task.spawn(function()
                while getgenv().BoostFPS.AutoClean do
                    task.wait(30)
                    collectgarbage("collect")
                end
            end)
        end
    end)

    -- CPU Optimize (PC only)
    if not UserInputService.TouchEnabled then
        local cpuConnections = {}
        CreateToggle(MainTab, "Tối Ưu CPU", true, function(value)
            if value then
                pcall(function()
                    local conn1 = UserInputService.WindowFocused:Connect(function()
                        RunService:SetFpsCap(999)
                    end)
                    
                    local conn2 = UserInputService.WindowFocusReleased:Connect(function()
                        RunService:SetFpsCap(30)
                    end)
                    
                    cpuConnections = {conn1, conn2}
                end)
            else
                for _, conn in pairs(cpuConnections) do
                    pcall(function() conn:Disconnect() end)
                end
                cpuConnections = {}
                RunService:SetFpsCap(999)
            end
        end)
    end

    -- === BLOX FRUIT TAB ===
    local isBloxFruit = game.PlaceId == 2753915549 or game.PlaceId == 4442272183 or game.PlaceId == 7449423635
    
    if isBloxFruit then
        -- No Skill Effects
        CreateToggle(BFTab, "Tắt Hiệu Ứng Skill", false, function(value)
            getgenv().BoostFPS.BF_NoSkillEffects = value
            
            if ActiveTasks["skillTask"] then
                ActiveTasks["skillTask"] = nil
            end
            
            if value then
                local taskId = "skillTask"
                ActiveTasks[taskId] = task.spawn(function()
                    while getgenv().BoostFPS.BF_NoSkillEffects do
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

        -- No Fruit Effects
        CreateToggle(BFTab, "Tắt Hiệu Ứng Trái", false, function(value)
            getgenv().BoostFPS.BF_NoFruitEffects = value
            
            if ActiveTasks["fruitTask"] then
                ActiveTasks["fruitTask"] = nil
            end
            
            if value then
                local taskId = "fruitTask"
                ActiveTasks[taskId] = task.spawn(function()
                    while getgenv().BoostFPS.BF_NoFruitEffects do
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

        -- Reduce Water
        CreateToggle(BFTab, "Giảm Hiệu Ứng Nước", false, function(value)
            getgenv().BoostFPS.BF_ReduceWater = value
            if value then
                pcall(function()
                    for _, part in pairs(Workspace:GetDescendants()) do
                        if part:IsA("Part") and part.Name == "Water" then
                            part.Transparency = 0.8
                        end
                    end
                end)
            else
                pcall(function()
                    for _, part in pairs(Workspace:GetDescendants()) do
                        if part:IsA("Part") and part.Name == "Water" then
                            part.Transparency = 0
                        end
                    end
                end)
            end
        end)

        -- Optimize Islands
        CreateToggle(BFTab, "Tối Ưu Đảo", false, function(value)
            getgenv().BoostFPS.BF_OptimizeIslands = value
            
            if ActiveTasks["islandTask"] then
                ActiveTasks["islandTask"] = nil
            end
            
            if value then
                local taskId = "islandTask"
                ActiveTasks[taskId] = task.spawn(function()
                    while getgenv().BoostFPS.BF_OptimizeIslands do
                        task.wait(5)
                        pcall(function()
                            for _, island in pairs(Workspace:GetChildren()) do
                                if island:IsA("Model") and island:FindFirstChild("Terrain") then
                                    island.Terrain.WaterTransparency = 0.9
                                end
                            end
                        end)
                    end
                end)
            else
                pcall(function()
                    for _, island in pairs(Workspace:GetChildren()) do
                        if island:IsA("Model") and island:FindFirstChild("Terrain") then
                            island.Terrain.WaterTransparency = 0
                        end
                    end
                end)
            end
        end)

        -- Reduce Players
        CreateToggle(BFTab, "Giảm Hiệu Ứng Người Chơi", false, function(value)
            getgenv().BoostFPS.BF_ReducePlayers = value
            
            if ActiveTasks["playerTask"] then
                ActiveTasks["playerTask"] = nil
            end
            
            if value then
                local taskId = "playerTask"
                ActiveTasks[taskId] = task.spawn(function()
                    while getgenv().BoostFPS.BF_ReducePlayers do
                        task.wait(2)
                        pcall(function()
                            for _, player in pairs(Players:GetPlayers()) do
                                if player.Character then
                                    for _, part in pairs(player.Character:GetDescendants()) do
                                        if part:IsA("ParticleEmitter") then
                                            part.Enabled = false
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end)
            end
        end)

        -- LOCAL LOAD SYSTEM (FIXED)
        CreateToggle(BFTab, "Load Xung Quanh Người Chơi", false, function(value)
            getgenv().BoostFPS.BF_LocalLoad = value
            
            if ActiveTasks["localLoadTask"] then
                ActiveTasks["localLoadTask"] = nil
            end
            
            if value then
                local taskId = "localLoadTask"
                ActiveTasks[taskId] = task.spawn(function()
                    local radius = 300
                    local originalStates = {}
                    
                    -- Lưu trạng thái gốc
                    pcall(function()
                        for _, island in pairs(Workspace:GetChildren()) do
                            if island:IsA("Model") and island:FindFirstChild("Terrain") then
                                originalStates[island.Name] = {
                                    Parent = island.Parent,
                                    Transparency = {}
                                }
                                for _, part in pairs(island:GetDescendants()) do
                                    if part:IsA("BasePart") then
                                        originalStates[island.Name].Transparency[part] = part.Transparency
                                    end
                                end
                            end
                        end
                    end)
                    
                    while getgenv().BoostFPS.BF_LocalLoad do
                        task.wait(0.5)
                        pcall(function()
                            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                local hrp = LocalPlayer.Character.HumanoidRootPart.Position
                                
                                for _, island in pairs(Workspace:GetChildren()) do
                                    if island:IsA("Model") and island:FindFirstChild("Terrain") then
                                        local islandPos = island:GetPivot().Position
                                        
                                        local distance = (islandPos - hrp).Magnitude
                                        
                                        if distance <= radius then
                                            if not island.Parent then
                                                island.Parent = Workspace
                                            end
                                            
                                            if distance > 150 then
                                                for _, part in pairs(island:GetDescendants()) do
                                                    if part:IsA("BasePart") then
                                                        part.Material = Enum.Material.Plastic
                                                        part.Transparency = math.clamp((distance-150)/150, 0, 0.8)
                                                    end
                                                end
                                            else
                                                for _, part in pairs(island:GetDescendants()) do
                                                    if part:IsA("BasePart") then
                                                        part.Material = Enum.Material.SmoothPlastic
                                                        part.Transparency = 0
                                                    end
                                                end
                                            end
                                        else
                                            island.Parent = nil
                                        end
                                    end
                                end
                            end
                        end)
                    end
                    
                    -- Khôi phục
                    pcall(function()
                        for islandName, state in pairs(originalStates) do
                            local island = Workspace:FindFirstChild(islandName)
                            if island then
                                island.Parent = Workspace
                                for part, transparency in pairs(state.Transparency) do
                                    if part and part.Parent then
                                        part.Transparency = transparency
                                        part.Material = Enum.Material.SmoothPlastic
                                    end
                                end
                            end
                        end
                    end)
                end)
            else
                -- Khôi phục tất cả đảo
                pcall(function()
                    for _, island in pairs(Workspace:GetChildren()) do
                        if island:IsA("Model") and island:FindFirstChild("Terrain") then
                            island.Parent = Workspace
                            for _, part in pairs(island:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    part.Material = Enum.Material.SmoothPlastic
                                    part.Transparency = 0
                                end
                            end
                        end
                    end
                end)
            end
        end)

    else
        -- Nếu không phải Blox Fruit
        local Label = Instance.new("TextLabel")
        Label.Text = "Không phải game Blox Fruit"
        Label.Size = UDim2.new(1, 0, 0, 30)
        Label.BackgroundTransparency = 1
        Label.TextColor3 = Color3.fromRGB(255, 100, 100)
        Label.Font = Enum.Font.Gotham
        Label.TextSize = 14
        Label.Parent = BFTab
    end

    -- === SETTINGS TAB ===
    -- Restore Button
    local RestoreButton = Instance.new("TextButton")
    RestoreButton.Text = "Khôi Phục Gốc"
    RestoreButton.Size = UDim2.new(1, 0, 0, 40)
    RestoreButton.Position = UDim2.new(0, 0, 0, 10)
    RestoreButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    RestoreButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    RestoreButton.Font = Enum.Font.Gotham
    RestoreButton.TextSize = 14
    RestoreButton.Parent = SettingsTab
    
    RestoreButton.MouseButton1Click:Connect(function()
        -- Dừng tất cả tasks
        for taskId, _ in pairs(ActiveTasks) do
            ActiveTasks[taskId] = nil
        end
        
        -- Khôi phục lighting
        pcall(function()
            Lighting.GlobalShadows = OriginalState.Lighting.GlobalShadows
            Lighting.FogEnd = OriginalState.Lighting.FogEnd
            Lighting.Brightness = OriginalState.Lighting.Brightness
            Lighting.Technology = OriginalState.Lighting.Technology
            
            -- Khôi phục settings
            settings().Rendering.QualityLevel = OriginalState.Global.QualityLevel
            settings().Rendering.MeshPartDetailLevel = OriginalState.Global.MeshDetail
            
            -- Bật lại hiệu ứng
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                    obj.Enabled = true
                end
            end
            
            -- Khôi phục nước
            for _, part in pairs(Workspace:GetDescendants()) do
                if part:IsA("Part") and part.Name == "Water" then
                    part.Transparency = 0
                end
            end
            
            -- Khôi phục đảo
            for _, island in pairs(Workspace:GetChildren()) do
                if island:IsA("Model") and island:FindFirstChild("Terrain") then
                    island.Parent = Workspace
                    island.Terrain.WaterTransparency = 0
                    for _, part in pairs(island:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.Material = Enum.Material.SmoothPlastic
                            part.Transparency = 0
                        end
                    end
                end
            end
        end)
        
        -- Thông báo
        local Notif = Instance.new("ScreenGui")
        Notif.Parent = game:GetService("CoreGui")
        
        local NotifFrame = Instance.new("Frame")
        NotifFrame.Size = UDim2.new(0, 200, 0, 50)
        NotifFrame.Position = UDim2.new(0.5, -100, 0, 20)
        NotifFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        NotifFrame.Parent = Notif
        
        local NotifText = Instance.new("TextLabel")
        NotifText.Text = "Đã khôi phục cài đặt gốc!"
        NotifText.Size = UDim2.new(1, 0, 1, 0)
        NotifText.BackgroundTransparency = 1
        NotifText.TextColor3 = Color3.fromRGB(0, 255, 100)
        NotifText.Font = Enum.Font.Gotham
        NotifText.TextSize = 14
        NotifText.Parent = NotifFrame
        
        task.wait(3)
        Notif:Destroy()
    end)

    -- Close UI Button
    CloseButton.MouseButton1Click:Connect(function()
        -- Dọn dẹp tasks trước khi đóng
        for taskId, _ in pairs(ActiveTasks) do
            ActiveTasks[taskId] = nil
        end
        ScreenGui:Destroy()
    end)

    -- Draggable
    local dragging = false
    local dragInput, dragStart, startPos
    
    TitleBar.InputBegan:Connect(function(input)
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
    
    TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    -- Hide/Show with Right Control
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Enum.KeyCode.RightControl then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)

    return ScreenGui
end

-- === 4. INITIAL OPTIMIZATIONS ===
-- Áp dụng cài đặt mặc định
pcall(function()
    settings().Rendering.QualityLevel = 1
    settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    
    -- Mobile optimizations
    if UserInputService.TouchEnabled then
        RunService:SetFpsCap(30)
        Lighting.Brightness = 1.5
    else
        RunService:SetFpsCap(999)
    end
end)

-- === 5. CREATE UI ===
local function Main()
    ShowLoadingScreen()
    
    local success, err = pcall(function()
        local ui = CreateSimpleUI()
        
        -- Success notification
        task.wait(1)
        print("BoostFPSHub v2.1.1 loaded successfully!")
    
    if not success then
        warn("[BoostFPSHub] UI Creation Error:", err)
        warn("Applying optimizations only...")
    end
end

-- Chạy script với error handling
local mainSuccess, mainError = pcall(Main)
if not mainSuccess then
    warn("[BoostFPSHub] Fatal Error:", mainError)
end
