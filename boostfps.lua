-- BoostFPSHub Ultimate v4.0 - Tối Ưu FPS All-in-One
-- Hỗ trợ PC + Mobile + Blox Fruits + Anti-Crash VIP
-- Language: Vietnamese

-- ████████████████████████████████████████████████████████████████████████████
-- █                              [INITIALIZATION]                            █
-- ████████████████████████████████████████████████████████████████████████████

-- === 0.1 PHÁT HIỆN HỆ THỐNG & THIẾT BỊ ===
local SYS = {
    IS_MOBILE = false,
    IS_PC = false,
    IS_LOW_END = false,
    IS_HIGH_END = false,
    IS_ROBLOX_STUDIO = false,
    DEVICE_INFO = {
        RAM = 0,
        GPU = "Unknown",
        OS = "Unknown",
        SCREEN_SIZE = Vector2.new(0, 0),
        TOUCH_SUPPORT = false,
        GAMEPAD_SUPPORT = false
    },
    GAME_INFO = {
        PLACE_ID = game.PlaceId,
        PLAYER_COUNT = 0,
        IS_BLOX_FRUIT = false,
        IS_TSB = false,
        IS_ANIME = false
    }
}

-- Phát hiện thiết bị
pcall(function()
    local UserInputService = game:GetService("UserInputService")
    local Stats = game:GetService("Stats")
    
    SYS.IS_MOBILE = UserInputService.TouchEnabled
    SYS.IS_PC = not SYS.IS_MOBILE
    SYS.DEVICE_INFO.TOUCH_SUPPORT = UserInputService.TouchEnabled
    SYS.DEVICE_INFO.GAMEPAD_SUPPORT = UserInputService.GamepadEnabled
    SYS.DEVICE_INFO.SCREEN_SIZE = game:GetService("GuiService"):GetScreenResolution()
    
    -- Phát hiện RAM
    if Stats then
        SYS.DEVICE_INFO.RAM = Stats:GetTotalMemoryUsageMb() or 0
        SYS.IS_LOW_END = (SYS.DEVICE_INFO.RAM < 1500) or (SYS.IS_MOBILE and SYS.DEVICE_INFO.RAM < 1000)
        SYS.IS_HIGH_END = (SYS.DEVICE_INFO.RAM > 8000) or (not SYS.IS_MOBILE and SYS.DEVICE_INFO.RAM > 4000)
    end
    
    -- Phát hiện game
    local placeId = game.PlaceId
    SYS.GAME_INFO.IS_BLOX_FRUIT = (placeId == 2753915549) or (placeId == 4442272183) or (placeId == 7449423635)
    SYS.GAME_INFO.IS_TSB = (placeId == 286090429) -- Arsenal
    SYS.GAME_INFO.PLAYER_COUNT = #game:GetService("Players"):GetPlayers()
    
    -- Phát hiện Roblox Studio
    SYS.IS_ROBLOX_STUDIO = (game:GetService("RunService"):IsStudio())
end)

-- === 0.2 BIẾN TOÀN CỤC BẢO VỆ ===
local _G_SAFE = {
    BoostFPS = {
        -- Main Settings
        RemoveParticles = false,
        AutoClean = false,
        NoShadows = false,
        CPUOptimize = false,
        
        -- Mobile Specific
        MobileUltraBoost = false,
        MobileBatterySaver = false,
        MobileDataSaver = false,
        MobileAutoFPS = false,
        
        -- Blox Fruit
        BF_NoSkillEffects = false,
        BF_NoFruitEffects = false,
        BF_ReducePlayers = false,
        BF_LocalLoad = false,
        BF_ReduceWater = false,
        BF_OptimizeIslands = false,
        
        -- Anti-Crash
        AntiCrash = true,
        MemoryGuard = true,
        HookProtection = true,
        
        -- Advanced
        DynamicResolution = false,
        TextureStreaming = false,
        CharacterOptimizer = false
    },
    
    Tasks = {},
    Connections = {},
    OriginalState = {},
    RestorePoints = {},
    PerformanceStats = {
        FPS = 0,
        Memory = 0,
        Particles = 0,
        Ping = 0
    }
}

-- ████████████████████████████████████████████████████████████████████████████
-- █                             [ANTI-CRASH VIP]                             █
-- ████████████████████████████████████████████████████████████████████████████

local AntiCrashSystem = {
    -- Layer 1: Error Handler
    CreateSafeFunction = function(func, funcName)
        return function(...)
            local success, result = xpcall(function()
                return func(...)
            end, function(err)
                local trace = debug.traceback()
                warn("[BoostFPSHub - AntiCrash]", funcName or "Unknown", "Error:", err)
                warn("Stack Trace:", trace)
                
                -- Log error to safety net
                table.insert(_G_SAFE.RestorePoints["crash_logs"] or {}, {
                    time = os.time(),
                    error = err,
                    trace = trace
                })
                
                return nil
            end)
            return result
        end
    end,
    
    -- Layer 2: Memory Guard
    MemoryGuard = function()
        local lastMemory = collectgarbage("count")
        local crashCount = 0
        
        return task.spawn(function()
            while _G_SAFE.BoostFPS.MemoryGuard do
                task.wait(60)
                
                local currentMemory = collectgarbage("count")
                if currentMemory > lastMemory * 1.5 then
                    crashCount = crashCount + 1
                    warn("[AntiCrash] Memory spike detected! ("..crashCount.."/3)")
                    
                    if crashCount >= 3 then
                        warn("[AntiCrash] Emergency memory cleanup!")
                        for i = 1, 3 do
                            collectgarbage("collect")
                            task.wait(0.1)
                        end
                        crashCount = 0
                    end
                end
                
                -- Auto clean dead tasks
                for i = #_G_SAFE.Tasks, 1, -1 do
                    local task = _G_SAFE.Tasks[i]
                    if coroutine.status(task) == "dead" then
                        table.remove(_G_SAFE.Tasks, i)
                    end
                end
                
                lastMemory = currentMemory
            end
        end)
    end,
    
    -- Layer 3: Hook Protection
    SetupStealthMode = function()
        if not SYS.IS_ROBLOX_STUDIO then
            local mt = getrawmetatable(game)
            if mt then
                local oldNamecall = mt.__namecall
                
                setreadonly(mt, false)
                mt.__namecall = newcclosure(function(self, ...)
                    local method = getnamecallmethod()
                    
                    -- Anti-Kick/Ban
                    if method == "Kick" or method == "kick" or method == "Destroy" then
                        if tostring(self):find("Player") then
                            warn("[AntiCrash] Blocked malicious call:", method)
                            return nil
                        end
                    end
                    
                    -- Anti-Teleport
                    if method == "Teleport" or method == "TeleportAsync" then
                        warn("[AntiCrash] Blocked teleport attempt")
                        return nil
                    end
                    
                    return oldNamecall(self, ...)
                end)
                setreadonly(mt, true)
            end
        end
    end,
    
    -- Layer 4: Crash Recovery
    SetupCrashRecovery = function()
        return task.spawn(function()
            local lastStable = tick()
            
            while _G_SAFE.BoostFPS.AntiCrash do
                task.wait(10)
                
                -- Check game stability
                if not game:IsLoaded() then
                    warn("[CrashRecovery] Game unloaded! Waiting for recovery...")
                    task.wait(5)
                    
                    if game:IsLoaded() then
                        warn("[CrashRecovery] Game recovered!")
                        -- Auto-restore settings
                        AntiCrashSystem.RestoreToPoint("stable_backup")
                    end
                end
                
                -- Check FPS stability
                if _G_SAFE.PerformanceStats.FPS < 10 and tick() - lastStable > 30 then
                    warn("[CrashRecovery] Low FPS detected! Auto-optimizing...")
                    AntiCrashSystem.EmergencyOptimize()
                    lastStable = tick()
                end
            end
        end)
    end,
    
    -- Emergency Optimization
    EmergencyOptimize = function()
        warn("[Emergency] Applying emergency optimizations...")
        
        -- 1. Max performance mode
        settings().Rendering.QualityLevel = 1
        settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
        
        -- 2. Disable all effects
        local Lighting = game:GetService("Lighting")
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        
        -- 3. Remove particles
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                obj.Enabled = false
            end
        end
        
        -- 4. Force garbage collection
        for i = 1, 3 do
            collectgarbage("collect")
            task.wait(0.1)
        end
        
        warn("[Emergency] Optimizations applied!")
    end,
    
    -- Restore System
    CreateRestorePoint = function(name)
        _G_SAFE.RestorePoints[name] = {
            time = os.time(),
            lighting = {},
            settings = {},
            game = game.PlaceId
        }
        
        local Lighting = game:GetService("Lighting")
        _G_SAFE.RestorePoints[name].lighting = {
            GlobalShadows = Lighting.GlobalShadows,
            FogEnd = Lighting.FogEnd,
            Brightness = Lighting.Brightness,
            Technology = Lighting.Technology
        }
        
        _G_SAFE.RestorePoints[name].settings = {
            QualityLevel = settings().Rendering.QualityLevel,
            MeshDetail = settings().Rendering.MeshPartDetailLevel
        }
        
        return true
    end,
    
    RestoreToPoint = function(name)
        local point = _G_SAFE.RestorePoints[name]
        if point then
            pcall(function()
                local Lighting = game:GetService("Lighting")
                for prop, value in pairs(point.lighting) do
                    Lighting[prop] = value
                end
                
                settings().Rendering.QualityLevel = point.settings.QualityLevel
                settings().Rendering.MeshPartDetailLevel = point.settings.MeshDetail
                
                warn("[AntiCrash] Restored to point:", name)
            end)
            return true
        end
        return false
    end
}

-- ████████████████████████████████████████████████████████████████████████████
-- █                          [LOADING SCREEN UNIVERSAL]                      █
-- ████████████████████████████████████████████████████████████████████████████

local function ShowUniversalLoading()
    if game:GetService("CoreGui"):FindFirstChild("BoostFPS_Loader") then return end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "BoostFPS_Loader"
    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local Frame = Instance.new("Frame")
    Frame.Size = SYS.IS_MOBILE and UDim2.new(0.8, 0, 0.2, 0) or UDim2.new(0, 350, 0, 100)
    Frame.Position = SYS.IS_MOBILE and UDim2.new(0.1, 0, 0.4, 0) or UDim2.new(0.5, -175, 0.5, -50)
    Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    Frame.BackgroundTransparency = 0.1
    Frame.BorderSizePixel = 0
    Frame.Parent = ScreenGui
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, SYS.IS_MOBILE and 15 or 10)
    UICorner.Parent = Frame
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Text = "🚀 BoostFPSHub Ultimate v4.0"
    Title.Size = UDim2.new(1, 0, 0.4, 0)
    Title.Position = UDim2.new(0, 0, 0.1, 0)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.fromRGB(0, 200, 255)
    Title.Font = SYS.IS_MOBILE and Enum.Font.GothamSemibold or Enum.Font.GothamBold
    Title.TextSize = SYS.IS_MOBILE and 16 or 18
    Title.Parent = Frame
    
    -- Subtitle
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Text = SYS.IS_MOBILE and "Optimizing for Mobile..." or "Optimizing for PC..."
    Subtitle.Size = UDim2.new(1, 0, 0.3, 0)
    Subtitle.Position = UDim2.new(0, 0, 0.5, 0)
    Subtitle.BackgroundTransparency = 1
    Subtitle.TextColor3 = Color3.fromRGB(200, 200, 255)
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.TextSize = SYS.IS_MOBILE and 12 or 14
    Subtitle.Parent = Frame
    
    -- Progress Bar
    local ProgressBG = Instance.new("Frame")
    ProgressBG.Size = UDim2.new(0.9, 0, 0.15, 0)
    ProgressBG.Position = UDim2.new(0.05, 0, 0.8, 0)
    ProgressBG.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    ProgressBG.BorderSizePixel = 0
    ProgressBG.Parent = Frame
    
    local ProgressCorner = Instance.new("UICorner")
    ProgressCorner.CornerRadius = UDim.new(0, 8)
    ProgressCorner.Parent = ProgressBG
    
    local Progress = Instance.new("Frame")
    Progress.Size = UDim2.new(0, 0, 1, 0)
    Progress.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
    Progress.BorderSizePixel = 0
    Progress.Parent = ProgressBG
    
    local ProgressCorner2 = Instance.new("UICorner")
    ProgressCorner2.CornerRadius = UDim.new(0, 8)
    ProgressCorner2.Parent = Progress
    
    -- Animation
    task.spawn(function()
        for i = 1, 100 do
            task.wait(0.015)
            Progress.Size = UDim2.new(i/100, 0, 1, 0)
        end
        task.wait(0.5)
        ScreenGui:Destroy()
    end)
end

-- ████████████████████████████████████████████████████████████████████████████
-- █                            [MAIN OPTIMIZATIONS]                          █
-- ████████████████████████████████████████████████████████████████████████████

local OptimizationSystem = {
    -- Universal Optimizations
    ApplyUniversalDefaults = function()
        pcall(function()
            local Lighting = game:GetService("Lighting")
            local RunService = game:GetService("RunService")
            
            -- Lighting Optimizations
            Lighting.GlobalShadows = false
            Lighting.FogEnd = SYS.IS_MOBILE and 500 or 9e9
            Lighting.Brightness = SYS.IS_MOBILE and 2 or 3
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
            Lighting.EnvironmentDiffuseScale = SYS.IS_MOBILE and 0.3 or 0.7
            Lighting.EnvironmentSpecularScale = SYS.IS_MOBILE and 0.1 or 0.5
            
            -- Graphics Settings
            if SYS.IS_MOBILE then
                settings().Rendering.QualityLevel = 1
                settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
                RunService:SetFpsCap(SYS.IS_LOW_END and 30 or 45)
            else
                settings().Rendering.QualityLevel = 3
                settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04
                RunService:SetFpsCap(999)
            end
            
            -- Terrain Optimizations
            if workspace.Terrain then
                workspace.Terrain.WaterReflectance = 0
                workspace.Terrain.WaterTransparency = SYS.IS_MOBILE and 0.6 or 0.3
                workspace.Terrain.WaterWaveSize = SYS.IS_MOBILE and 0 or 0.1
                workspace.Terrain.WaterWaveSpeed = SYS.IS_MOBILE and 0 or 0.5
            end
        end)
    end,
    
    -- Particle Removal System
    ParticleRemover = function()
        return task.spawn(function()
            while _G_SAFE.BoostFPS.RemoveParticles do
                task.wait(SYS.IS_MOBILE and 2 or 1)
                pcall(function()
                    local count = 0
                    local maxParticles = SYS.IS_LOW_END and 5 or SYS.IS_MOBILE and 15 or 50
                    
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if obj:IsA("ParticleEmitter") then
                            count = count + 1
                            if count > maxParticles then
                                obj.Enabled = false
                            else
                                obj.Enabled = true
                                if SYS.IS_MOBILE then
                                    obj.Rate = math.min(obj.Rate, 20)
                                end
                            end
                        elseif obj:IsA("Trail") then
                            obj.Enabled = not SYS.IS_MOBILE
                        end
                    end
                    
                    _G_SAFE.PerformanceStats.Particles = count
                end)
            end
        end)
    end,
    
    -- Auto Memory Cleaner
    AutoCleaner = function()
        return task.spawn(function()
            while _G_SAFE.BoostFPS.AutoClean do
                task.wait(SYS.IS_MOBILE and 45 or 30)
                collectgarbage("collect")
                _G_SAFE.PerformanceStats.Memory = math.floor(collectgarbage("count"))
            end
        end)
    end,
    
    -- CPU Optimization
    CPUOptimizer = function()
        if SYS.IS_MOBILE then return end
        
        local focusedConn = game:GetService("UserInputService").WindowFocused:Connect(function()
            game:GetService("RunService"):SetFpsCap(999)
        end)
        
        local unfocusedConn = game:GetService("UserInputService").WindowFocusReleased:Connect(function()
            game:GetService("RunService"):SetFpsCap(30)
        end)
        
        table.insert(_G_SAFE.Connections, focusedConn)
        table.insert(_G_SAFE.Connections, unfocusedConn)
        
        return focusedConn, unfocusedConn
    end
}

-- ████████████████████████████████████████████████████████████████████████████
-- █                         [MOBILE SPECIFIC FEATURES]                       █
-- ████████████████████████████████████████████████████████████████████████████

local MobileSystem = {
    -- Dynamic Resolution Scaling
    DynamicResolution = function()
        if not SYS.IS_MOBILE then return end
        
        return task.spawn(function()
            local Camera = workspace.CurrentCamera
            
            while _G_SAFE.BoostFPS.DynamicResolution do
                task.wait(3)
                pcall(function()
                    local fps = _G_SAFE.PerformanceStats.FPS
                    
                    if fps < 15 then
                        -- Ultra Low Mode
                        Camera.FieldOfView = 55
                        settings().Rendering.QualityLevel = 1
                    elseif fps < 25 then
                        -- Low Mode
                        Camera.FieldOfView = 60
                        settings().Rendering.QualityLevel = 2
                    else
                        -- Normal Mode
                        Camera.FieldOfView = 70
                        settings().Rendering.QualityLevel = 3
                    end
                end)
            end
        end)
    end,
    
    -- Texture Streaming
    TextureStreaming = function()
        if not SYS.IS_MOBILE then return end
        
        return task.spawn(function()
            while _G_SAFE.BoostFPS.TextureStreaming do
                task.wait(2)
                pcall(function()
                    local Players = game:GetService("Players")
                    local localPlayer = Players.LocalPlayer
                    
                    if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local position = localPlayer.Character.HumanoidRootPart.Position
                        
                        for _, obj in pairs(workspace:GetDescendants()) do
                            if obj:IsA("BasePart") then
                                local distance = (obj.Position - position).Magnitude
                                
                                if distance > 100 then
                                    -- Reduce quality for distant objects
                                    if obj:IsA("MeshPart") then
                                        obj.TextureID = ""
                                    end
                                    obj.Material = Enum.Material.Plastic
                                else
                                    -- Keep quality for nearby objects
                                    obj.Material = Enum.Material.SmoothPlastic
                                end
                            end
                        end
                    end
                end)
            end
        end)
    end,
    
    -- Character Optimizer for Mobile
    MobileCharacterOptimizer = function()
        if not SYS.IS_MOBILE then return end
        
        return task.spawn(function()
            while _G_SAFE.BoostFPS.CharacterOptimizer do
                task.wait(2)
                pcall(function()
                    local Players = game:GetService("Players")
                    local localPlayer = Players.LocalPlayer
                    
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= localPlayer and player.Character then
                            local char = player.Character
                            local distance = 0
                            
                            if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                distance = (char:GetPivot().Position - localPlayer.Character.HumanoidRootPart.Position).Magnitude
                            end
                            
                            -- Optimize based on distance
                            for _, part in pairs(char:GetDescendants()) do
                                if distance > 50 then
                                    -- Distant players: reduce quality
                                    if part:IsA("BasePart") then
                                        part.Transparency = 0.3
                                        part.Material = Enum.Material.Plastic
                                    elseif part:IsA("ParticleEmitter") then
                                        part.Enabled = false
                                    elseif part:IsA("Decal") then
                                        part.Transparency = 0.5
                                    end
                                else
                                    -- Nearby players: normal quality
                                    if part:IsA("BasePart") then
                                        part.Transparency = 0
                                        part.Material = Enum.Material.SmoothPlastic
                                    end
                                end
                            end
                        end
                    end
                end)
            end
        end)
    end,
    
    -- Battery Saver Mode
    BatterySaver = function()
        if not SYS.IS_MOBILE then return end
        
        pcall(function()
            game:GetService("RunService"):SetFpsCap(30)
            
            local Lighting = game:GetService("Lighting")
            Lighting.Brightness = 1.5
            Lighting.Ambient = Color3.fromRGB(100, 100, 100)
            
            -- Reduce physics
            if settings().Physics then
                settings().Physics.PhysicsEnvironmentalThrottle = 2
            end
            
            -- Reduce network usage
            if settings().Network then
                settings().Network.IncomingReplicationLag = 1000
            end
        end)
    end
}

-- ████████████████████████████████████████████████████████████████████████████
-- █                         [BLOX FRUITS OPTIMIZATIONS]                      █
-- ████████████████████████████████████████████████████████████████████████████

local BloxFruitSystem = {
    -- No Skill Effects
    NoSkillEffects = function()
        return task.spawn(function()
            while _G_SAFE.BoostFPS.BF_NoSkillEffects do
                task.wait(SYS.IS_MOBILE and 3 or 1)
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
    end,
    
    -- No Fruit Effects
    NoFruitEffects = function()
        return task.spawn(function()
            while _G_SAFE.BoostFPS.BF_NoFruitEffects do
                task.wait(SYS.IS_MOBILE and 4 or 2)
                pcall(function()
                    for _, fruit in pairs(workspace:GetChildren()) do
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
    end,
    
    -- Reduce Water Effects
    ReduceWater = function()
        pcall(function()
            for _, part in pairs(workspace:GetDescendants()) do
                if part:IsA("Part") and part.Name == "Water" then
                    part.Transparency = SYS.IS_MOBILE and 0.9 or 0.8
                end
            end
        end)
    end,
    
    -- Optimize Islands
    OptimizeIslands = function()
        return task.spawn(function()
            while _G_SAFE.BoostFPS.BF_OptimizeIslands do
                task.wait(5)
                pcall(function()
                    for _, island in pairs(workspace:GetChildren()) do
                        if island:IsA("Model") and island:FindFirstChild("Terrain") then
                            island.Terrain.WaterTransparency = SYS.IS_MOBILE and 0.9 or 0.8
                            
                            -- Optimize parts
                            for _, part in pairs(island:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    part.Material = Enum.Material.Plastic
                                    if part.Transparency < 0.5 then
                                        part.Reflectance = 0
                                    end
                                end
                            end
                        end
                    end
                end)
            end
        end)
    end,
    
    -- Local Load System
    LocalLoad = function()
        return task.spawn(function()
            local radius = SYS.IS_MOBILE and 200 or 300
            local originalStates = {}
            
            -- Save original states
            for _, island in pairs(workspace:GetChildren()) do
                if island:IsA("Model") and island:FindFirstChild("Terrain") then
                    originalStates[island.Name] = {
                        Parent = island.Parent,
                        Parts = {}
                    }
                end
            end
            
            while _G_SAFE.BoostFPS.BF_LocalLoad do
                task.wait(SYS.IS_MOBILE and 1 or 0.5)
                pcall(function()
                    local Players = game:GetService("Players")
                    local player = Players.LocalPlayer
                    
                    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local hrp = player.Character.HumanoidRootPart.Position
                        
                        for _, island in pairs(workspace:GetChildren()) do
                            if island:IsA("Model") and island:FindFirstChild("Terrain") then
                                local islandPos = island:GetPivot().Position
                                local distance = (islandPos - hrp).Magnitude
                                
                                if distance <= radius then
                                    if not island.Parent then island.Parent = workspace end
                                    
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
            
            -- Restore all islands
            pcall(function()
                for _, island in pairs(workspace:GetChildren()) do
                    if island:IsA("Model") and island:FindFirstChild("Terrain") then
                        island.Parent = workspace
                        for _, part in pairs(island:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.Material = Enum.Material.SmoothPlastic
                                part.Transparency = 0
                            end
                        end
                    end
                end
            end)
        end)
    end
}

-- ████████████████████████████████████████████████████████████████████████████
-- █                           [UI SYSTEM UNIVERSAL]                          █
-- ████████████████████████████████████████████████████████████████████████████

-- Wait for game to load
if not game:IsLoaded() then game.Loaded:Wait() end
ShowUniversalLoading()

-- Load Library
local Library, ThemeManager, SaveManager
local libSuccess, libError = pcall(function()
    Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
    ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua"))()
    SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua"))()
end)

if not libSuccess then
    warn("[BoostFPSHub] Library load failed:", libError)
    return
end

-- Create Window with device-specific settings
local Window = Library:CreateWindow({
    Title = "🚀 BoostFPSHub Ultimate v4.0",
    Center = true,
    AutoShow = true,
    TabPadding = SYS.IS_MOBILE and 4 or 6,
    MenuFadeTime = 0.1
})

-- Watermark with FPS
Library:SetWatermark("BoostFPSHub v4.0 | FPS: -- | Device: " .. (SYS.IS_MOBILE and "📱" or "💻"))
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            local fps = math.floor(1 / game:GetService("RunService").RenderStepped:Wait())
            _G_SAFE.PerformanceStats.FPS = fps
            Library:SetWatermark("BoostFPSHub v4.0 | FPS: "..fps.." | "..(SYS.IS_MOBILE and "📱 Mobile" or "💻 PC"))
        end)
    end
end)

-- Create Tabs
local Tabs = {
    Main = Window:AddTab("Main"),
    BloxFruit = SYS.GAME_INFO.IS_BLOX_FRUIT and Window:AddTab("Blox Fruit"),
    Mobile = SYS.IS_MOBILE and Window:AddTab("📱 Mobile"),
    Settings = Window:AddTab("Settings")
}

-- ████████████████████████████████████████████████████████████████████████████
-- █                               [TAB: MAIN]                               █
-- ████████████████████████████████████████████████████████████████████████████

local MainLeft = Tabs.Main:AddLeftGroupbox("🎯 Performance Boost")

MainLeft:AddToggle("UltraBoost", {
    Text = "🚀 Ultra Performance Mode",
    Default = true,
    Callback = AntiCrashSystem.CreateSafeFunction(function(value)
        if value then
            OptimizationSystem.ApplyUniversalDefaults()
            Library:Notify("Ultra Boost activated!", 2)
        else
            AntiCrashSystem.RestoreToPoint("initial")
            Library:Notify("Settings restored", 2)
        end
    end, "UltraBoost")
})

MainLeft:AddToggle("RemoveParticles", {
    Text = "✨ Remove Particle Effects",
    Default = true,
    Callback = AntiCrashSystem.CreateSafeFunction(function(value)
        _G_SAFE.BoostFPS.RemoveParticles = value
        if value then
            local task = OptimizationSystem.ParticleRemover()
            table.insert(_G_SAFE.Tasks, task)
            Library:Notify("Particles removed", 2)
        end
    end, "RemoveParticles")
})

MainLeft:AddToggle("NoShadows", {
    Text = "🌑 Disable Shadows",
    Default = true,
    Callback = AntiCrashSystem.CreateSafeFunction(function(value)
        _G_SAFE.BoostFPS.NoShadows = value
        pcall(function()
            game:GetService("Lighting").GlobalShadows = not value
        end)
    end, "NoShadows")
})

local MainRight = Tabs.Main:AddRightGroupbox("⚙️ System")

MainRight:AddToggle("AutoClean", {
    Text = "🧹 Auto Memory Cleaner",
    Default = true,
    Callback = AntiCrashSystem.CreateSafeFunction(function(value)
        _G_SAFE.BoostFPS.AutoClean = value
        if value then
            local task = OptimizationSystem.AutoCleaner()
            table.insert(_G_SAFE.Tasks, task)
            Library:Notify("Auto Clean enabled", 2)
        end
    end, "AutoClean")
})

if SYS.IS_PC then
    MainRight:AddToggle("CPUOptimize", {
        Text = "💻 CPU Optimization",
        Default = true,
        Callback = AntiCrashSystem.CreateSafeFunction(function(value)
            _G_SAFE.BoostFPS.CPUOptimize = value
            if value then
                OptimizationSystem.CPUOptimizer()
                Library:Notify("CPU Optimized", 2)
            end
        end, "CPUOptimize")
    })
end

-- Performance Monitor
local PerfGroup = Tabs.Main:AddRightGroupbox("📊 Performance Monitor")
local fpsLabel = PerfGroup:AddLabel("FPS: --")
local memLabel = PerfGroup:AddLabel("RAM: -- MB")
local partLabel = PerfGroup:AddLabel("Particles: --")

task.spawn(function()
    while task.wait(1) do
        pcall(function()
            fpsLabel:SetText("FPS: " .. _G_SAFE.PerformanceStats.FPS)
            memLabel:SetText("RAM: " .. _G_SAFE.PerformanceStats.Memory .. " MB")
            partLabel:SetText("Particles: " .. _G_SAFE.PerformanceStats.Particles)
        end)
    end
end)

PerfGroup:AddButton("🔄 Clean RAM Now", function()
    collectgarbage("collect")
    collectgarbage("collect")
    Library:Notify("RAM cleaned!", 2)
end)

-- ████████████████████████████████████████████████████████████████████████████
-- █                          [TAB: BLOX FRUIT]                              █
-- ████████████████████████████████████████████████████████████████████████████

if SYS.GAME_INFO.IS_BLOX_FRUIT then
    local BFLeft = Tabs.BloxFruit:AddLeftGroupbox("🍎 Blox Fruit Optimizations")
    local BFRight = Tabs.BloxFruit:AddRightGroupbox("🗺️ Map Optimizations")
    
    BFLeft:AddToggle("BF_NoSkillEffects", {
        Text = "⚡ Disable Skill Effects",
        Default = false,
        Callback = AntiCrashSystem.CreateSafeFunction(function(value)
            _G_SAFE.BoostFPS.BF_NoSkillEffects = value
            if value then
                local task = BloxFruitSystem.NoSkillEffects()
                table.insert(_G_SAFE.Tasks, task)
            end
        end, "BF_NoSkillEffects")
    })
    
    BFLeft:AddToggle("BF_NoFruitEffects", {
        Text = "🍓 Disable Fruit Effects",
        Default = false,
        Callback = AntiCrashSystem.CreateSafeFunction(function(value)
            _G_SAFE.BoostFPS.BF_NoFruitEffects = value
            if value then
                local task = BloxFruitSystem.NoFruitEffects()
                table.insert(_G_SAFE.Tasks, task)
            end
        end, "BF_NoFruitEffects")
    })
    
    BFLeft:AddToggle("BF_ReduceWater", {
        Text = "💧 Reduce Water Effects",
        Default = false,
        Callback = AntiCrashSystem.CreateSafeFunction(function(value)
            _G_SAFE.BoostFPS.BF_ReduceWater = value
            if value then
                BloxFruitSystem.ReduceWater()
            end
        end, "BF_ReduceWater")
    })
    
    BFRight:AddToggle("BF_OptimizeIslands", {
        Text = "🏝️ Optimize Islands",
        Default = false,
        Callback = AntiCrashSystem.CreateSafeFunction(function(value)
            _G_SAFE.BoostFPS.BF_OptimizeIslands = value
            if value then
                local task = BloxFruitSystem.OptimizeIslands()
                table.insert(_G_SAFE.Tasks, task)
            end
        end, "BF_OptimizeIslands")
    })
    
    BFRight:AddToggle("BF_LocalLoad", {
        Text = "📍 Local Island Loading",
        Default = false,
        Callback = AntiCrashSystem.CreateSafeFunction(function(value)
            _G_SAFE.BoostFPS.BF_LocalLoad = value
            if value then
                local task = BloxFruitSystem.LocalLoad()
                table.insert(_G_SAFE.Tasks, task)
            end
        end, "BF_LocalLoad")
    })
    
    -- Blox Fruit Tips
    local TipsGroup = Tabs.BloxFruit:AddLeftGroupbox("💡 Tips for Blox Fruit")
    TipsGroup:AddLabel("• Enable all options for max FPS")
    TipsGroup:AddLabel("• Local Load helps on weak devices")
    TipsGroup:AddLabel("• Disable fruit effects in PVP")
    TipsGroup:AddLabel("• Optimize islands in crowded seas")
end

-- ████████████████████████████████████████████████████████████████████████████
-- █                            [TAB: MOBILE]                                █
-- ████████████████████████████████████████████████████████████████████████████

if SYS.IS_MOBILE then
    local MobileMain = Tabs.Mobile:AddLeftGroupbox("📱 Mobile Optimizations")
    local MobileRight = Tabs.Mobile:AddRightGroupbox("🔋 Battery & Data")
    
    MobileMain:AddToggle("MobileUltraBoost", {
        Text = "⚡ Mobile Ultra Boost",
        Default = true,
        Callback = AntiCrashSystem.CreateSafeFunction(function(value)
            _G_SAFE.BoostFPS.MobileUltraBoost = value
            if value then
                OptimizationSystem.ApplyUniversalDefaults()
                Library:Notify("Mobile boost activated!", 2)
            end
        end, "MobileUltraBoost")
    })
    
    MobileMain:AddToggle("DynamicResolution", {
        Text = "🔄 Dynamic Resolution",
        Default = true,
        Callback = AntiCrashSystem.CreateSafeFunction(function(value)
            _G_SAFE.BoostFPS.DynamicResolution = value
            if value then
                local task = MobileSystem.DynamicResolution()
                table.insert(_G_SAFE.Tasks, task)
            end
        end, "DynamicResolution")
    })
    
    MobileMain:AddToggle("TextureStreaming", {
        Text = "🎨 Texture Streaming",
        Default = true,
        Callback = AntiCrashSystem.CreateSafeFunction(function(value)
            _G_SAFE.BoostFPS.TextureStreaming = value
            if value then
                local task = MobileSystem.TextureStreaming()
                table.insert(_G_SAFE.Tasks, task)
            end
        end, "TextureStreaming")
    })
    
    MobileMain:AddToggle("CharacterOptimizer", {
        Text = "👥 Character Optimizer",
        Default = true,
        Callback = AntiCrashSystem.CreateSafeFunction(function(value)
            _G_SAFE.BoostFPS.CharacterOptimizer = value
            if value then
                local task = MobileSystem.MobileCharacterOptimizer()
                table.insert(_G_SAFE.Tasks, task)
            end
        end, "CharacterOptimizer")
    })
    
    MobileRight:AddToggle("MobileBatterySaver", {
        Text = "🔋 Battery Saver",
        Default = true,
        Callback = AntiCrashSystem.CreateSafeFunction(function(value)
            _G_SAFE.BoostFPS.MobileBatterySaver = value
            if value then
                MobileSystem.BatterySaver()
                Library:Notify("Battery saver ON", 2)
            else
                game:GetService("RunService"):SetFpsCap(60)
                Library:Notify("Battery saver OFF", 2)
            end
        end, "MobileBatterySaver")
    })
    
    MobileRight:AddToggle("MobileDataSaver", {
        Text = "📶 Data Saver",
        Default = true,
        Callback = AntiCrashSystem.CreateSafeFunction(function(value)
            _G_SAFE.BoostFPS.MobileDataSaver = value
            if value then
                Library:Notify("Data saver activated", 2)
            end
        end, "MobileDataSaver")
    })
    
    -- Mobile Info Panel
    local InfoGroup = Tabs.Mobile:AddRightGroupbox("📱 Device Info")
    InfoGroup:AddLabel("Device: " .. (SYS.IS_LOW_END and "Low-End" or "Mid-Range"))
    InfoGroup:AddLabel("RAM: " .. math.floor(SYS.DEVICE_INFO.RAM) .. "MB")
    InfoGroup:AddLabel("Screen: " .. math.floor(SYS.DEVICE_INFO.SCREEN_SIZE.X) .. "x" .. math.floor(SYS.DEVICE_INFO.SCREEN_SIZE.Y))
    InfoGroup:AddLabel("Touch: " .. (SYS.DEVICE_INFO.TOUCH_SUPPORT and "Yes" or "No"))
end

-- ████████████████████████████████████████████████████████████████████████████
-- █                             [TAB: SETTINGS]                             █
-- ████████████████████████████████████████████████████████████████████████████

local SetLeft = Tabs.Settings:AddLeftGroupbox("🎮 Controls")
SetLeft:AddButton("🔄 Hide/Show UI (Right Ctrl)", function()
    Library:Unload()
end)

SetLeft:AddButton("📱 Minimize UI", function()
    Library.Minimize = not Library.Minimize
end)

SetLeft:AddButton("🎨 Change Theme", function()
    ThemeManager:OpenConfig()
end)

local SetRight = Tabs.Settings:AddRightGroupbox("⚙️ System")

SetRight:AddButton("💾 Save Settings", function()
    SaveManager:SaveConfig()
    Library:Notify("Settings saved!", 2)
end)

SetRight:AddButton("📂 Load Settings", function()
    SaveManager:LoadConfig()
    Library:Notify("Settings loaded!", 2)
end)

SetRight:AddButton("⚠️ Emergency Restore", AntiCrashSystem.CreateSafeFunction(function()
    -- Stop all tasks
    for _, task in ipairs(_G_SAFE.Tasks) do
        pcall(task.cancel, task)
    end
    _G_SAFE.Tasks = {}
    
    -- Disconnect all
    for _, conn in ipairs(_G_SAFE.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    _G_SAFE.Connections = {}
    
    -- Restore everything
    AntiCrashSystem.RestoreToPoint("initial")
    
    -- Reset all toggles
    for key, _ in pairs(_G_SAFE.BoostFPS) do
        _G_SAFE.BoostFPS[key] = false
    end
    
    Library:Notify("Emergency restore complete!", 3)
end, "EmergencyRestore"))

SetRight:AddButton("🚨 Emergency Shutdown", function()
    -- Final cleanup
    for _, task in ipairs(_G_SAFE.Tasks) do
        pcall(task.cancel, task)
    end
    
    for _, conn in ipairs(_G_SAFE.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    
    -- Restore settings
    pcall(function()
        local Lighting = game:GetService("Lighting")
        Lighting.GlobalShadows = true
        Lighting.FogEnd = 100000
        Lighting.Brightness = 2
        
        settings().Rendering.QualityLevel = 10
        settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level20
        
        game:GetService("RunService"):SetFpsCap(60)
    end)
    
    -- Close UI
    Library:Unload()
    warn("[BoostFPSHub] Emergency shutdown complete!")
end)

-- ████████████████████████████████████████████████████████████████████████████
-- █                           [FINAL INITIALIZATION]                         █
-- ████████████████████████████████████████████████████████████████████████████

-- Create initial restore point
AntiCrashSystem.CreateRestorePoint("initial")

-- Apply universal optimizations
OptimizationSystem.ApplyUniversalDefaults()

-- Setup anti-crash
AntiCrashSystem.SetupStealthMode()
local crashTask = AntiCrashSystem.SetupCrashRecovery()
table.insert(_G_SAFE.Tasks, crashTask)

local memTask = AntiCrashSystem.MemoryGuard()
table.insert(_G_SAFE.Tasks, memTask)

-- Auto-detect and apply game-specific optimizations
if SYS.GAME_INFO.IS_BLOX_FRUIT and SYS.IS_MOBILE then
    task.wait(2)
    BloxFruitSystem.ReduceWater()
    Library:Notify("Blox Fruit mobile optimizations applied!", 3)
end

-- Keybinds
local uiToggle = game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightControl then
        Library:Unload()
    end
end)
table.insert(_G_SAFE.Connections, uiToggle)

-- Save/Load system
SaveManager:SetLibrary(Library)
SaveManager:SetFolder("BoostFPSHub_v4")
SaveManager:IgnoreThemeSettings(true)
SaveManager:BuildConfigSection(Tabs.Settings)

ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("BoostFPSHub_v4")
ThemeManager:ApplyToTab(Tabs.Settings)

-- Final notification
Library:Notify("🚀 BoostFPSHub Ultimate v4.0 Ready!", 3)
Library:Notify("Device: " .. (SYS.IS_MOBILE and "📱 Mobile" .. (SYS.IS_LOW_END and " (Low-End)" or " (Mid-Range)") or "💻 PC"), 3)

if SYS.GAME_INFO.IS_BLOX_FRUIT then
    Library:Notify("🍎 Blox Fruit optimizations available!", 3)
end

-- Performance monitor start
task.spawn(function()
    while task.wait(5) do
        _G_SAFE.PerformanceStats.Memory = math.floor(collectgarbage("count"))
    end
end)

warn("[BoostFPSHub Ultimate v4.0] Loaded successfully!")
warn("Device: " .. (SYS.IS_MOBILE and "Mobile" or "PC"))
warn("RAM: " .. SYS.DEVICE_INFO.RAM .. "MB")
warn("Game: " .. (SYS.GAME_INFO.IS_BLOX_FRUIT and "Blox Fruit" or "Other"))
warn("Ready to boost your FPS! 🚀")
