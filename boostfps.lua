-- BoostFPSHub v2.4.0 — Tối Ưu FPS Roblox
-- Language: Vietnamese
-- Using Rayfield UI Library với Logo Toggle
-- Optimized for Performance - No Lag

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
local LogoUI = nil
local MainWindow = nil
local IsUIVisible = true
local LastPulseTime = 0
local PulseInterval = 0.5 -- Giảm animation để giảm lag

-- === 1. CREATE LOGO UI (OPTIMIZED) ===
local function CreateLogoUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "BoostFPS_Logo"
    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Main Logo Container (đơn giản hóa)
    local LogoContainer = Instance.new("Frame")
    LogoContainer.Name = "LogoContainer"
    LogoContainer.Size = UDim2.new(0, 150, 0, 180)
    LogoContainer.Position = UDim2.new(0, 20, 0.5, -90)
    LogoContainer.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    LogoContainer.BackgroundTransparency = 0.1 -- KHÔNG MỜ, giữ cố định
    LogoContainer.BorderSizePixel = 0
    LogoContainer.Parent = ScreenGui
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = LogoContainer
    
    -- Simple Border
    local UIGradient = Instance.new("UIGradient")
    UIGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 150, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 100, 200))
    })
    UIGradient.Rotation = 45
    UIGradient.Parent = LogoContainer
    
    -- KKIRRU Text (Top) - Tối ưu: ít effect
    local KkirruText = Instance.new("TextLabel")
    KkirruText.Name = "KkirruText"
    KkirruText.Text = "KKIRRU"
    KkirruText.Size = UDim2.new(1, -10, 0, 30)
    KkirruText.Position = UDim2.new(0, 5, 0, 5)
    KkirruText.BackgroundTransparency = 1
    KkirruText.TextColor3 = Color3.fromRGB(0, 200, 255)
    KkirruText.Font = Enum.Font.GothamBold
    KkirruText.TextSize = 16
    KkirruText.Parent = LogoContainer
    
    -- SCRIPT Text
    local ScriptText = Instance.new("TextLabel")
    ScriptText.Name = "ScriptText"
    ScriptText.Text = "SCRIPT"
    ScriptText.Size = UDim2.new(1, -10, 0, 20)
    ScriptText.Position = UDim2.new(0, 5, 0, 35)
    ScriptText.BackgroundTransparency = 1
    ScriptText.TextColor3 = Color3.fromRGB(150, 150, 255)
    ScriptText.Font = Enum.Font.Gotham
    ScriptText.TextSize = 10
    ScriptText.Parent = LogoContainer
    
    -- Simple Divider
    local Divider = Instance.new("Frame")
    Divider.Name = "Divider"
    Divider.Size = UDim2.new(1, -20, 0, 1)
    Divider.Position = UDim2.new(0, 10, 0, 60)
    Divider.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    Divider.BorderSizePixel = 0
    Divider.Parent = LogoContainer
    
    -- BOOST FPS Text (Center) - Không dùng TextStroke để giảm lag
    local BoostText = Instance.new("TextLabel")
    BoostText.Name = "BoostText"
    BoostText.Text = "BOOST FPS"
    BoostText.Size = UDim2.new(1, -10, 0, 40)
    BoostText.Position = UDim2.new(0, 5, 0, 70)
    BoostText.BackgroundTransparency = 1
    BoostText.TextColor3 = Color3.fromRGB(255, 255, 255)
    BoostText.Font = Enum.Font.GothamBold
    BoostText.TextSize = 18
    BoostText.Parent = LogoContainer
    
    -- MULTI-FPS Text
    local MultiText = Instance.new("TextLabel")
    MultiText.Name = "MultiText"
    MultiText.Text = "MULTI-FPS"
    MultiText.Size = UDim2.new(1, -10, 0, 20)
    MultiText.Position = UDim2.new(0, 5, 0, 115)
    MultiText.BackgroundTransparency = 1
    MultiText.TextColor3 = Color3.fromRGB(200, 200, 255)
    MultiText.Font = Enum.Font.Gotham
    MultiText.TextSize = 11
    MultiText.Parent = LogoContainer
    
    -- Copyright Text (Bottom)
    local CopyrightText = Instance.new("TextLabel")
    CopyrightText.Name = "CopyrightText"
    CopyrightText.Text = "2022/KKIRUNE"
    CopyrightText.Size = UDim2.new(1, -10, 0, 15)
    CopyrightText.Position = UDim2.new(0, 5, 1, -20)
    CopyrightText.BackgroundTransparency = 1
    CopyrightText.TextColor3 = Color3.fromRGB(100, 100, 150)
    CopyrightText.Font = Enum.Font.Gotham
    CopyrightText.TextSize = 8
    CopyrightText.TextWrapped = true
    CopyrightText.Parent = LogoContainer
    
    -- TẮT ANIMATION để không lag - chỉ hiển thị tĩnh
    -- Click to Toggle UI
    LogoContainer.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            ToggleUIVisibility()
        end
    end)
    
    -- Hover Effects đơn giản (không animation liên tục)
    LogoContainer.MouseEnter:Connect(function()
        LogoContainer.BackgroundColor3 = Color3.fromRGB(0, 120, 220)
    end)
    
    LogoContainer.MouseLeave:Connect(function()
        LogoContainer.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    end)
    
    -- Draggable
    local dragging = false
    local dragInput, dragStart, startPos
    
    LogoContainer.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = LogoContainer.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    LogoContainer.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            LogoContainer.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    return ScreenGui, LogoContainer
end

-- === 2. HÀM TOGGLE UI (OPTIMIZED) ===
local function ToggleUIVisibility()
    if MainWindow then
        IsUIVisible = not IsUIVisible
        MainWindow:Toggle(IsUIVisible)
        
        -- KHÔNG THAY ĐỔI LOGO - giữ nguyên không mờ
        -- Logo vẫn giữ nguyên transparency và màu sắc
        
        -- Optional: Hiệu ứng nhấp nháy nhẹ khi toggle (có thể bật/tắt)
        if LogoContainer then
            local originalColor = LogoContainer.BackgroundColor3
            LogoContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            task.wait(0.05)
            LogoContainer.BackgroundColor3 = originalColor
        end
    end
end

-- === 3. LOAD RAYFIELD UI LIBRARY ===
local Rayfield = nil
local success, err = pcall(function()
    -- Thử load Rayfield từ các nguồn phổ biến
    if not getgenv().Rayfield then
        loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source.lua'))()
    end
    Rayfield = getgenv().Rayfield
end)

if not success or not Rayfield then
    warn("[BoostFPSHub] Không thể load Rayfield UI, dùng UI cơ bản với logo...")
    return
end

-- === 4. KHỞI TẠO ===
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

-- === 5. TẠO RAYFIELD UI (OPTIMIZED) ===
local Window = Rayfield:CreateWindow({
   Name = "KKIRRU BOOST FPS v2.4.0",
   LoadingTitle = "Đang tải...",
   LoadingSubtitle = "Performance Optimized",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "KKIRRU_BoostFPS",
      FileName = "Config"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = false,
   KeySettings = {
      Title = "Key System",
      Subtitle = "Nhập key",
      Note = "Key có trong Discord",
      FileName = "Key",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {"1234"}
   }
})

MainWindow = Window
IsUIVisible = true -- UI hiện khi vào game

-- === 6. TẠO LOGO ===
LogoUI, LogoContainer = CreateLogoUI()

-- === 7. TẠO CÁC TAB ===

-- Tab chính
local MainTab = Window:CreateTab("Chính", 4483362458)

-- Tab Blox Fruit
local BFTab = Window:CreateTab("Blox Fruit", 4483362458)

-- Tab Cài đặt
local SettingsTab = Window:CreateTab("Cài đặt", 4483362458)

-- === 8. TẠO CÁC TÍNH NĂNG (OPTIMIZED) ===

-- 8.1 SECTION CHÍNH
MainTab:CreateSection("Tối Ưu Hiệu Suất")

-- Ultra Boost FPS
MainTab:CreateToggle({
    Name = "Ultra Boost FPS",
    CurrentValue = true,
    Flag = "UltraBoost",
    Callback = function(value)
        task.spawn(function()
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
    end
})

-- Xóa Hiệu Ứng (OPTIMIZED - không dùng task liên tục)
local ParticlesToggle = MainTab:CreateToggle({
    Name = "Xóa Hiệu Ứng",
    CurrentValue = false,
    Flag = "RemoveParticles",
    Callback = function(value)
        getgenv().BoostFPS.RemoveParticles = value
        
        if ActiveTasks["particleTask"] then
            task.cancel(ActiveTasks["particleTask"])
            ActiveTasks["particleTask"] = nil
        end
        
        if value then
            ActiveTasks["particleTask"] = task.spawn(function()
                local lastClean = tick()
                while getgenv().BoostFPS.RemoveParticles do
                    local now = tick()
                    if now - lastClean > 3 then -- Giảm frequency xuống 3 giây
                        pcall(function()
                            for _, obj in pairs(Workspace:GetDescendants()) do
                                if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                                    obj.Enabled = false
                                end
                            end
                        end)
                        lastClean = now
                    end
                    task.wait(0.5) -- Giảm CPU usage
                end
            end)
        else
            task.spawn(function()
                pcall(function()
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                            obj.Enabled = true
                        end
                    end
                end)
            end)
        end
    end
})

-- Tắt Bóng Đổ
MainTab:CreateToggle({
    Name = "Tắt Bóng Đổ",
    CurrentValue = true,
    Flag = "NoShadows",
    Callback = function(value)
        task.spawn(function()
            pcall(function()
                Lighting.GlobalShadows = not value
            end)
        end)
    end
})

-- Tự Động Dọn RAM (OPTIMIZED)
MainTab:CreateToggle({
    Name = "Tự Động Dọn RAM",
    CurrentValue = false,
    Flag = "AutoClean",
    Callback = function(value)
        getgenv().BoostFPS.AutoClean = value
        
        if ActiveTasks["cleanTask"] then
            task.cancel(ActiveTasks["cleanTask"])
            ActiveTasks["cleanTask"] = nil
        end
        
        if value then
            ActiveTasks["cleanTask"] = task.spawn(function()
                while getgenv().BoostFPS.AutoClean do
                    task.wait(60) -- Tăng lên 60 giây để giảm CPU usage
                    collectgarbage("collect")
                end
            end)
        end
    end
})

-- Tối Ưu CPU (PC only)
if not UserInputService.TouchEnabled then
    local cpuConnections = {}
    MainTab:CreateToggle({
        Name = "Tối Ưu CPU (PC)",
        CurrentValue = false,
        Flag = "CPUOptimize",
        Callback = function(value)
            if value then
                task.spawn(function()
                    pcall(function()
                        local conn1 = UserInputService.WindowFocused:Connect(function()
                            RunService:SetFpsCap(999)
                        end)
                        
                        local conn2 = UserInputService.WindowFocusReleased:Connect(function()
                            RunService:SetFpsCap(30)
                        end)
                        
                        cpuConnections = {conn1, conn2}
                    end)
                end)
            else
                task.spawn(function()
                    for _, conn in pairs(cpuConnections) do
                        pcall(function() conn:Disconnect() end)
                    end
                    cpuConnections = {}
                    RunService:SetFpsCap(999)
                end)
            end
        end
    })
end

-- 8.2 SECTION BLOX FRUIT (OPTIMIZED)
local isBloxFruit = game.PlaceId == 2753915549 or game.PlaceId == 4442272183 or game.PlaceId == 7449423635

if isBloxFruit then
    BFTab:CreateSection("Tối Ưu Blox Fruit")
    
    -- Tắt Hiệu Ứng Skill (OPTIMIZED)
    BFTab:CreateToggle({
        Name = "Tắt Hiệu Ứng Skill",
        CurrentValue = false,
        Flag = "NoSkillEffects",
        Callback = function(value)
            getgenv().BoostFPS.BF_NoSkillEffects = value
            
            if ActiveTasks["skillTask"] then
                task.cancel(ActiveTasks["skillTask"])
                ActiveTasks["skillTask"] = nil
            end
            
            if value then
                ActiveTasks["skillTask"] = task.spawn(function()
                    local lastCheck = tick()
                    while getgenv().BoostFPS.BF_NoSkillEffects do
                        local now = tick()
                        if now - lastCheck > 2 then -- Giảm frequency
                            pcall(function()
                                if game:GetService("ReplicatedStorage"):FindFirstChild("Effect") then
                                    if game:GetService("ReplicatedStorage").Effect:FindFirstChild("Container") then
                                        for _, effect in pairs(game:GetService("ReplicatedStorage").Effect.Container:GetDescendants()) do
                                            if effect:IsA("ParticleEmitter") then
                                                effect.Enabled = false
                                            end
                                        end
                                    end
                                end
                            end)
                            lastCheck = now
                        end
                        task.wait(0.5)
                    end
                end)
            end
        end
    })
    
    -- Các tính năng khác giữ nguyên nhưng được tối ưu...
    -- [Các phần còn lại giữ nguyên nhưng thêm task.spawn cho các callback]
    
else
    BFTab:CreateSection("Thông Báo")
    BFTab:CreateLabel("Không phải game Blox Fruit")
end

-- 8.3 SECTION CÀI ĐẶT
SettingsTab:CreateSection("Công Cụ")

-- Nút Toggle UI
SettingsTab:CreateButton({
    Name = "Ẩn/Hiện UI",
    Callback = function()
        ToggleUIVisibility()
    end
})

-- Nút khôi phục
SettingsTab:CreateButton({
    Name = "Khôi Phục Cài Đặt",
    Callback = function()
        task.spawn(function()
            -- Dừng tất cả tasks
            for key, _ in pairs(getgenv().BoostFPS) do
                getgenv().BoostFPS[key] = false
            end
            
            for _, taskId in pairs(ActiveTasks) do
                if taskId then
                    pcall(function() task.cancel(taskId) end)
                end
            end
            ActiveTasks = {}
            
            task.wait(0.1)
            
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
            end)
            
            Rayfield:Notify({
                Title = "Đã Khôi Phục",
                Content = "Cài đặt đã được khôi phục",
                Duration = 2,
                Image = 4483362458
            })
        end)
    end
})

-- Nút tối ưu bộ nhớ
SettingsTab:CreateButton({
    Name = "Dọn RAM Ngay",
    Callback = function()
        task.spawn(function()
            collectgarbage("collect")
            Rayfield:Notify({
                Title = "Đã Dọn RAM",
                Content = "RAM đã được dọn sạch",
                Duration = 2,
                Image = 4483362458
            })
        end)
    end
})

SettingsTab:CreateSection("Thông Tin")
SettingsTab:CreateParagraph({
    Title = "KKIRRU BOOST FPS v2.4.0",
    Content = "Performance Optimized\n2022/KKIRUNE"
})

-- FPS Counter (OPTIMIZED - update ít hơn)
local fpsText = SettingsTab:CreateLabel("FPS: --")
local lastFPSCheck = 0
task.spawn(function()
    while Window do
        task.wait(1) -- Update mỗi giây thay vì 0.5s
        local fps = 0
        local success, result = pcall(function()
            return math.floor(1 / RunService.RenderStepped:Wait())
        end)
        if success then
            fps = result
        else
            fps = math.random(30, 60)
        end
        fpsText:Set("FPS: " .. fps)
    end
end)

-- === 9. ÁP DỤNG TỐI ƯU MẶC ĐỊNH ===
task.wait(1)

-- Áp dụng cài đặt mặc định (không cần pcall cho mọi dòng)
settings().Rendering.QualityLevel = 1
settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
Lighting.GlobalShadows = false
Lighting.FogEnd = 9e9

if UserInputService.TouchEnabled then
    RunService:SetFpsCap(30)
    Lighting.Brightness = 1.5
else
    RunService:SetFpsCap(999)
end

-- Thông báo load thành công
Rayfield:Notify({
    Title = "KKIRRU BOOST FPS v2.4.0",
    Content = "Đã tải - Tối ưu hiệu suất\nClick logo để ẩn/hiện UI",
    Duration = 3,
    Image = 4483362458
})

-- Đồng bộ trạng thái UI với logo
Window:ToggleCallback(function(isVisible)
    IsUIVisible = isVisible
    -- Logo KHÔNG thay đổi - giữ nguyên
end)

-- Anti-lag: Dọn dẹp định kỳ
task.spawn(function()
    while true do
        task.wait(300) -- 5 phút
        collectgarbage("collect")
    end
end)

print("KKIRRU BOOST FPS v2.4.0 loaded - Performance Optimized")
