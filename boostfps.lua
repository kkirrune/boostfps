--[[ 
    BoostFPSHub v2.1 — Ultra Enhanced
    Language: Vietnamese
    Features: Advanced Optimization, Smooth Animations, Enhanced Security
]]

-- === 1. ENHANCED LOADING SCREEN WITH SMOOTH ANIMATIONS ===
local function ShowLoadingScreen()
    if game:GetService("CoreGui"):FindFirstChild("BoostFPS_Loading") then return end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "BoostFPS_Loading"
    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.IgnoreGuiInset = true

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1,0,1,0)
    Frame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    Frame.BackgroundTransparency = 1
    Frame.Parent = ScreenGui

    -- Background Gradient
    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 10, 15)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 30))
    })
    Gradient.Rotation = 45
    Gradient.Parent = Frame

    -- Animated Background Particles
    local ParticlesFolder = Instance.new("Folder")
    ParticlesFolder.Parent = Frame

    -- Create floating particles
    for i = 1, 15 do
        local Particle = Instance.new("Frame")
        Particle.Size = UDim2.new(0, math.random(2, 4), 0, math.random(2, 4))
        Particle.Position = UDim2.new(math.random(), 0, math.random(), 0)
        Particle.BackgroundColor3 = Color3.fromRGB(0, 255, 128)
        Particle.BorderSizePixel = 0
        Particle.BackgroundTransparency = 0.7
        Particle.Parent = ParticlesFolder
        
        -- Animate particle
        local TweenService = game:GetService("TweenService")
        local targetPos = UDim2.new(math.random(), 0, math.random(), 0)
        local tween = TweenService:Create(Particle, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
            Position = targetPos,
            BackgroundTransparency = math.random(0.3, 0.8)
        })
        tween:Play()
    end

    -- Loading Container
    local LoadingContainer = Instance.new("Frame")
    LoadingContainer.Size = UDim2.new(0, 400, 0, 200)
    LoadingContainer.Position = UDim2.new(0.5, -200, 0.5, -100)
    LoadingContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    LoadingContainer.BackgroundTransparency = 1
    LoadingContainer.Parent = Frame

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = LoadingContainer

    local ContainerStroke = Instance.new("UIStroke")
    ContainerStroke.Color = Color3.fromRGB(50, 50, 60)
    ContainerStroke.Thickness = 2
    ContainerStroke.Parent = LoadingContainer

    -- Spinning Loader
    local LoaderCircle = Instance.new("Frame")
    LoaderCircle.Size = UDim2.new(0, 60, 0, 60)
    LoaderCircle.Position = UDim2.new(0.5, -30, 0.3, -30)
    LoaderCircle.BackgroundTransparency = 1
    LoaderCircle.Parent = LoadingContainer

    local LoaderStroke = Instance.new("UIStroke")
    LoaderStroke.Color = Color3.fromRGB(0, 255, 128)
    LoaderStroke.Thickness = 3
    LoaderStroke.Parent = LoaderCircle

    -- Animated dots
    local DotsContainer = Instance.new("Frame")
    DotsContainer.Size = UDim2.new(0, 60, 0, 20)
    DotsContainer.Position = UDim2.new(0.5, -30, 0.7, -10)
    DotsContainer.BackgroundTransparency = 1
    DotsContainer.Parent = LoadingContainer

    local dots = {}
    for i = 1, 3 do
        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 8, 0, 8)
        dot.Position = UDim2.new(0.2 * i, -4, 0.5, -4)
        dot.BackgroundColor3 = Color3.fromRGB(0, 255, 128)
        dot.BorderSizePixel = 0
        dot.BackgroundTransparency = 1
        dot.Parent = DotsContainer
        
        local dotCorner = Instance.new("UICorner")
        dotCorner.CornerRadius = UDim.new(1, 0)
        dotCorner.Parent = dot
        
        table.insert(dots, dot)
    end

    local Title = Instance.new("TextLabel")
    Title.Text = "BoostFPSHub v2.1"
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Position = UDim2.new(0, 0, 0.1, 0)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 24
    Title.TextTransparency = 1
    Title.Parent = LoadingContainer
    
    local SubTitle = Instance.new("TextLabel")
    SubTitle.Text = "Đang tối ưu hệ thống..."
    SubTitle.Size = UDim2.new(1, 0, 0, 20)
    SubTitle.Position = UDim2.new(0, 0, 0.8, 0)
    SubTitle.BackgroundTransparency = 1
    SubTitle.TextColor3 = Color3.fromRGB(150, 150, 150)
    SubTitle.Font = Enum.Font.Gotham
    SubTitle.TextSize = 14
    SubTitle.TextTransparency = 1
    SubTitle.Parent = LoadingContainer

    -- Progress bar
    local BarBase = Instance.new("Frame")
    BarBase.Size = UDim2.new(0.8, 0, 0, 4)
    BarBase.Position = UDim2.new(0.1, 0, 0.9, 0)
    BarBase.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    BarBase.BorderSizePixel = 0
    BarBase.BackgroundTransparency = 1
    BarBase.Parent = LoadingContainer
    
    local BarProgress = Instance.new("Frame")
    BarProgress.Size = UDim2.new(0, 0, 1, 0)
    BarProgress.BackgroundColor3 = Color3.fromRGB(0, 255, 128)
    BarProgress.BorderSizePixel = 0
    BarProgress.Parent = BarBase

    local BarCorner = Instance.new("UICorner")
    BarCorner.CornerRadius = UDim.new(1, 0)
    BarCorner.Parent = BarBase

    -- Smooth Animations
    local TweenService = game:GetService("TweenService")
    
    -- Fade in background and container
    TweenService:Create(Frame, TweenInfo.new(0.8, Enum.EasingStyle.Quad), {BackgroundTransparency = 0}):Play()
    task.wait(0.3)
    TweenService:Create(LoadingContainer, TweenInfo.new(0.6, Enum.EasingStyle.Quad), {BackgroundTransparency = 0}):Play()

    -- Fade in text
    task.wait(0.2)
    TweenService:Create(Title, TweenInfo.new(0.8, Enum.EasingStyle.Quad), {TextTransparency = 0}):Play()
    TweenService:Create(SubTitle, TweenInfo.new(0.8, Enum.EasingStyle.Quad), {TextTransparency = 0}):Play()
    TweenService:Create(BarBase, TweenInfo.new(0.8, Enum.EasingStyle.Quad), {BackgroundTransparency = 0}):Play()

    -- Spinning loader animation
    local spinConnection
    spinConnection = game:GetService("RunService").RenderStepped:Connect(function(delta)
        LoaderCircle.Rotation = LoaderCircle.Rotation + (delta * 180)
    end)

    -- Animated dots sequence
    local dotAnimations = {}
    for i, dot in ipairs(dots) do
        local tween = TweenService:Create(dot, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, -1, true, (i-1)*0.2), {
            BackgroundTransparency = 0
        })
        tween:Play()
        table.insert(dotAnimations, tween)
    end

    -- Progress bar animation
    task.wait(0.5)
    local progressTween = TweenService:Create(BarProgress, TweenInfo.new(2, Enum.EasingStyle.Quint), {Size = UDim2.new(1, 0, 1, 0)})
    progressTween:Play()

    -- Update loading text
    local loadingTexts = {
        "Đang tải thư viện...",
        "Đang khởi tạo hệ thống...",
        "Đang tối ưu hóa...",
        "Sắp hoàn tất..."
    }
    
    for i, text in ipairs(loadingTexts) do
        task.wait(0.4)
        SubTitle.Text = text
    end

    task.wait(0.5)
    
    -- Smooth fade out
    TweenService:Create(Frame, TweenInfo.new(0.8, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()
    TweenService:Create(LoadingContainer, TweenInfo.new(0.6, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()
    TweenService:Create(Title, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {TextTransparency = 1}):Play()
    TweenService:Create(SubTitle, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {TextTransparency = 1}):Play()
    
    -- Stop animations
    if spinConnection then
        spinConnection:Disconnect()
    end
    for _, tween in ipairs(dotAnimations) do
        pcall(function() tween:Cancel() end)
    end
    progressTween:Cancel()
    
    task.wait(0.8)
    ScreenGui:Destroy()
end

ShowLoadingScreen()

-- === 2. ENHANCED INITIALIZATION & SECURITY ===
if not game:IsLoaded() then game.Loaded:Wait() end

-- Safe Library Loading
local function SafeLoad(url)
    local success, result = pcall(function()
        return game:HttpGet(url, true)
    end)
    if success then
        return loadstring(result)()
    else
        warn("[Security] Failed to load: " .. url)
        return nil
    end
end

local Library = SafeLoad("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua")
local ThemeManager = SafeLoad("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua")
local SaveManager = SafeLoad("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua")

if not Library then
    warn("Failed to load required libraries!")
    return
end

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- === 3. ENHANCED STATE MANAGEMENT ===
local OriginalState = {
    Lighting = {
        GlobalShadows = Lighting.GlobalShadows,
        FogEnd = Lighting.FogEnd,
        Brightness = Lighting.Brightness,
        Ambient = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        Technology = Lighting.Technology
    },
    Global = {
        QualityLevel = settings().Rendering.QualityLevel,
        MeshDetail = settings().Rendering.MeshPartDetailLevel
    }
}

local ActiveTweens = {}
local PerformanceStats = {
    FPS = 0,
    Ping = 0,
    MemoryUsage = 0
}

local function SafeCall(func, errorMsg)
    local success, result = pcall(func)
    if not success then 
        warn("[BoostFPSHub Error]: " .. (errorMsg or tostring(result)))
        return false
    end
    return true
end

local function RestoreDefaults()
    SafeCall(function()
        -- Restore Lighting
        for property, value in pairs(OriginalState.Lighting) do
            Lighting[property] = value
        end
        
        -- Restore Settings
        settings().Rendering.QualityLevel = OriginalState.Global.QualityLevel
        settings().Rendering.MeshPartDetailLevel = OriginalState.Global.MeshDetail
        
        -- Restore Objects
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") then 
                v.Material = Enum.Material.Plastic 
                v.Transparency = 0 
            end
            if v:IsA("Decal") or v:IsA("Texture") then 
                v.Transparency = 0 
            end
            if v:IsA("ParticleEmitter") then
                v.Enabled = true
            end
            if v:IsA("Light") then
                v.Enabled = true
            end
        end
        
        -- Enable 3D rendering
        RunService:Set3dRenderingEnabled(true)
        
        -- Stop all active tweens
        for _, tween in pairs(ActiveTweens) do
            pcall(function() tween:Cancel() end)
        end
        ActiveTweens = {}
        
        Library:Notify("Đã khôi phục cài đặt gốc!", 5)
    end, "RestoreDefaults failed")
end

-- === 4. ENHANCED UI WITH SMOOTH ANIMATIONS ===
local Window = Library:CreateWindow({
    Title = "BoostFPSHub v2.1 | Ultra Enhanced",
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.3
})

-- Enhanced Watermark with smooth updates
Library:SetWatermark("BoostFPSHub v2.1 | Initializing...")
Library:SetWatermarkVisibility(true)

-- Performance monitoring
task.spawn(function()
    while true do
        task.wait(0.5)
        SafeCall(function()
            local fps = math.floor(1 / RunService.RenderStepped:Wait())
            local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            PerformanceStats.FPS = fps
            PerformanceStats.Ping = ping
            
            Library:SetWatermark(string.format("BoostFPSHub v2.1 | FPS: %d | Ping: %dms", fps, ping))
        end, "Performance update failed")
    end
end)

local Tabs = {
    Main = Window:AddTab("Chính (Main)"),
    Game = Window:AddTab("Game Boost"), 
    Extreme = Window:AddTab("Siêu Cấp"),
    Visuals = Window:AddTab("Hiệu Ứng"),
    Misc = Window:AddTab("Tiện Ích"),
    Settings = Window:AddTab("Cài Đặt"),
}

-- === 5. ENHANCED FEATURES ===

-- >> TAB 1: MAIN BOOST (ENHANCED)
local MainGroup = Tabs.Main:AddLeftGroupbox("Tối Ưu Cơ Bản")

MainGroup:AddToggle("BoostFPS", {
    Text = "Boost FPS (Khuyên Dùng)", 
    Default = true, 
    Callback = function(v)
        SafeCall(function()
            if v then
                settings().Rendering.QualityLevel = 1
                settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04
                workspace.StreamingEnabled = true
                Library:Notify("Đã kích hoạt Boost FPS!", 3)
            else
                settings().Rendering.QualityLevel = OriginalState.Global.QualityLevel
                settings().Rendering.MeshPartDetailLevel = OriginalState.Global.MeshDetail
            end
        end, "BoostFPS toggle failed")
    end
})

MainGroup:AddToggle("MobileMode", {
    Text = "Chế Độ Mobile", 
    Default = false, 
    Callback = function(v)
        Lighting.GlobalShadows = not v
        if v then 
            Lighting.FogEnd = 9e9 
            Library:Notify("Đã bật chế độ Mobile!", 3)
        else 
            Lighting.FogEnd = OriginalState.Lighting.FogEnd 
        end
    end
})

MainGroup:AddToggle("FullBright", {
    Text = "Sáng Tối Đa", 
    Default = false, 
    Callback = function(v)
        if v then
            Lighting.Ambient = Color3.new(1,1,1)
            Lighting.OutdoorAmbient = Color3.new(1,1,1)
            Lighting.ClockTime = 14
            Library:Notify("Đã bật FullBright!", 3)
        else
            Lighting.Ambient = OriginalState.Lighting.Ambient
            Lighting.OutdoorAmbient = OriginalState.Lighting.OutdoorAmbient
            Lighting.ClockTime = 12
        end
    end
})

local OptGroup = Tabs.Main:AddRightGroupbox("Tối Ưu Hệ Thống")

OptGroup:AddToggle("CPUThrottle", {
    Text = "Tiết Kiệm CPU", 
    Default = true, 
    Callback = function(v)
        local focused = true
        UserInputService.WindowFocused:Connect(function() 
            focused = true 
            if v then RunService:SetFpsCap(999) end 
        end)
        UserInputService.WindowFocusReleased:Connect(function() 
            focused = false 
            if v then RunService:SetFpsCap(30) end 
        end)
    end
})

OptGroup:AddToggle("AutoClearRAM", {
    Text = "Dọn RAM Tự Động", 
    Default = true, 
    Callback = function(v)
        if v then
            task.spawn(function()
                while getgenv().AutoClearRAM do
                    task.wait(20)
                    SafeCall(function()
                        -- Clean up debris and effects
                        for _, obj in pairs(Workspace:GetDescendants()) do
                            if obj:IsA("Part") and (obj.Name == "Debris" or obj.Name == "Effect" or obj.Name == "Bullet") then
                                if not obj:FindFirstAncestorOfClass("Model") then
                                    obj:Destroy()
                                end
                            end
                        end
                        -- Garbage collection
                        for i = 1, 2 do 
                            task.wait()
                            collectgarbage("collect")
                        end
                    end, "AutoClearRAM failed")
                end
            end)
        end
    end
})

-- >> NEW TAB: VISUAL EFFECTS
local VisualGroup = Tabs.Visuals:AddLeftGroupbox("Hiệu Ứng Hình Ảnh")

VisualGroup:AddToggle("SmoothCamera", {
    Text = "Camera Mượt Mà", 
    Default = false, 
    Callback = function(v)
        if v then
            local camera = Workspace.CurrentCamera
            if camera then
                camera.CameraType = Enum.CameraType.Scriptable
                Library:Notify("Đã bật Camera mượt mà!", 3)
            end
        else
            local camera = Workspace.CurrentCamera
            if camera then
                camera.CameraType = Enum.CameraType.Custom
            end
        end
    end
})

VisualGroup:AddSlider("FOV", {
    Text = "Góc nhìn (FOV)",
    Default = 70,
    Min = 50,
    Max = 120,
    Rounding = 0,
    Callback = function(v)
        local camera = Workspace.CurrentCamera
        if camera then
            camera.FieldOfView = v
        end
    end
})

VisualGroup:AddToggle("DepthOfField", {
    Text = "Hiệu Ứng Xóa Phông", 
    Default = false, 
    Callback = function(v)
        if v then
            local depth = Instance.new("DepthOfFieldEffect")
            depth.Parent = Lighting
            depth.FarIntensity = 0
            depth.FocusDistance = 50
            depth.InFocusRadius = 50
            depth.NearIntensity = 1
            Library:Notify("Đã bật hiệu ứng xóa phông!", 3)
        else
            for _, effect in pairs(Lighting:GetChildren()) do
                if effect:IsA("DepthOfFieldEffect") then
                    effect:Destroy()
                end
            end
        end
    end
})

-- >> TAB 2: GAME BOOST (ENHANCED)
local GameGroup = Tabs.Game:AddLeftGroupbox("Game Hiện Tại")

local function DetectGame()
    local id = game.PlaceId
    if id == 2753915549 or id == 4442272183 or id == 7449423635 then 
        return "BloxFruit"
    elseif id == 10449761463 then 
        return "TSB"
    elseif id == 6516141723 then 
        return "Doors"
    else 
        return "Universal" 
    end
end

local CurrentGame = DetectGame()
GameGroup:AddLabel("Đang chơi: " .. CurrentGame)

if CurrentGame == "BloxFruit" then
    GameGroup:AddToggle("BF_NoSkill", {
        Text = "Tắt Hiệu Ứng Skill", 
        Default = false, 
        Callback = function(v)
            task.spawn(function()
                while getgenv().BF_NoSkill do
                    SafeCall(function()
                        for _, p in pairs(game.ReplicatedStorage:GetDescendants()) do
                            if p:IsA("ParticleEmitter") then 
                                p.Enabled = not v 
                            end
                        end
                    end, "BF_NoSkill failed")
                    task.wait(1)
                end
            end)
        end
    })
    
elseif CurrentGame == "Doors" then
    GameGroup:AddToggle("Doors_NoLight", {
        Text = "Giảm Ánh Sáng", 
        Default = false, 
        Callback = function(v)
            SafeCall(function()
                for _, l in pairs(Workspace:GetDescendants()) do 
                    if l:IsA("Light") then 
                        l.Enabled = not v 
                    end 
                end
            end, "Doors_NoLight failed")
        end
    })
end

-- >> TAB 3: EXTREME (ENHANCED)
local ExtremeGroup = Tabs.Extreme:AddLeftGroupbox("Cảnh Báo: Ảnh hưởng đồ họa")

ExtremeGroup:AddToggle("Wireframe", {
    Text = "Chế Độ Khung Dây", 
    Default = false, 
    Callback = function(v)
        SafeCall(function()
            for _, p in pairs(Workspace:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.Material = v and Enum.Material.ForceField or Enum.Material.Plastic
                    if v then 
                        p.Transparency = 0.3 
                    else 
                        p.Transparency = 0 
                    end
                end
            end
        end, "Wireframe toggle failed")
    end
})

-- >> TAB 4: MISC (ENHANCED)
local MiscGroup = Tabs.Misc:AddLeftGroupbox("Hệ Thống & Server")

MiscGroup:AddToggle("AntiAFK", {
    Text = "Chống AFK", 
    Default = true, 
    Callback = function(v)
        if v then
            local vu = game:GetService("VirtualUser")
            LocalPlayer.Idled:Connect(function()
                vu:CaptureController()
                vu:ClickButton2(Vector2.new())
            end)
            Library:Notify("Đã bật Anti-AFK!", 3)
        end
    end
})

MiscGroup:AddButton("Rejoin Server", {
    Func = function()
        Library:Notify("Đang kết nối lại...", 3)
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end
})

MiscGroup:AddButton("Server Hop", {
    Func = function()
        Library:Notify("Đang tìm server mới...", 3)
        SafeCall(function()
            local Http = game:GetService("HttpService")
            local TPS = game:GetService("TeleportService")
            local Api = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
            
            local function ListServers(cursor)
                local Raw = game:HttpGet(Api .. ((cursor and "&cursor="..cursor) or ""))
                return Http:JSONDecode(Raw)
            end
            
            local Server, Next
            repeat
                local Servers = ListServers(Next)
                Server = Servers.data[math.random(1, #Servers.data)]
                Next = Servers.nextPageCursor
            until Server and Server.playing < Server.maxPlayers and Server.id ~= game.JobId
            
            if Server then
                TPS:TeleportToPlaceInstance(game.PlaceId, Server.id, LocalPlayer)
            end
        end, "Server Hop failed")
    end
})

-- >> TAB 5: SETTINGS (ENHANCED)
local SetGroup = Tabs.Settings:AddLeftGroupbox("Hệ Thống")

SetGroup:AddButton("KHÔI PHỤC MẶC ĐỊNH", {
    Func = RestoreDefaults
})

SetGroup:AddButton("Tắt Script", {
    Func = function() 
        Library:Notify("Tắt BoostFPSHub...", 3)
        RestoreDefaults()
        task.wait(1)
        Window:Unload() 
    end
})

-- Enhanced Theme Manager
local ThemeGroup = Tabs.Settings:AddRightGroupbox("Giao Diện")
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("BoostFPSHub_v2.1")
ThemeManager:ApplyToTab(ThemeGroup)

-- Enhanced Save Manager
local ConfigGroup = Tabs.Settings:AddRightGroupbox("Cấu Hình")
SaveManager:SetLibrary(Library)
SaveManager:SetFolder("BoostFPSHub_v2.1")
SaveManager:BuildConfigSection(ConfigGroup)

-- === 6. FINAL INITIALIZATION ===
Library:Notify("BoostFPSHub v2.1 Đã Sẵn Sàng! FPS Boosted!", 5)

-- Auto-save configuration
task.spawn(function()
    task.wait(5)
    SafeCall(function()
        SaveManager:Save(game.PlaceId .. "_config")
    end, "Auto-save failed")
end)

-- Clean up on script termination
game:GetService("UserInputService").WindowFocused:Connect(function()
    if getgenv().CPUThrottle then
        RunService:SetFpsCap(999)
    end
end)

game:GetService("UserInputService").WindowFocusReleased:Connect(function()
    if getgenv().CPUThrottle then
        RunService:SetFpsCap(30)
    end
end)

warn("BoostFPSHub v2.1 - Enhanced Edition Loaded Successfully!")
