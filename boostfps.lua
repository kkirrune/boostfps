-- BoostFPSHub v1.2.4 — Tối Ưu FPS Roblox
-- Language: Vietnamese

-- === 0. KHỞI TẠO BIẾN TOÀN CỤC ===
getgenv().BoostFPS = {
    RemoveParticles = false,
    AutoClean = false,
    BF_NoSkillEffects = false,
    BF_NoFruitEffects = false,
    BF_ReducePlayers = false,
    BF_LocalLoad = false,
    BR_NoGlow = false,
    BR_ReduceCharacters = false,
    TSB_NoSkillEffects = false,
    TSB_ReduceAura = false,
    TSB_NoTrails = false,
    TSB_ReducePlayers = false
}

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
    TextLabel.Text = "BoostFPSHub v2.3 - Đang tải..."
    TextLabel.Size = UDim2.new(1, 0, 1, 0)
    TextLabel.BackgroundTransparency = 1
    TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.Font = Enum.Font.Gotham
    TextLabel.TextSize = 16
    TextLabel.Parent = Frame

    task.wait(1.5)
    ScreenGui:Destroy()
end

ShowLoadingScreen()

-- === 2. KHỞI TẠO ===
if not game:IsLoaded() then game.Loaded:Wait() end

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua"))()

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

-- === 3. TẠO GIAO DIỆN ===
local Window = Library:CreateWindow({
    Title = "BoostFPSHub v2.3",
    Center = true,
    AutoShow = true,
    TabPadding = 6,
    MenuFadeTime = 0.1
})

-- Watermark FPS
Library:SetWatermark("BoostFPSHub v2.3 | FPS: --")
task.spawn(function()
    while true do
        task.wait(0.5)
        local fps = math.floor(1 / RunService.RenderStepped:Wait())
        Library:SetWatermark("BoostFPSHub v2.3 | FPS: "..fps)
    end
end)

-- Tabs
local Tabs = {
    Main = Window:AddTab("Main"),
    BloxFruit = Window:AddTab("Blox Fruit"),
    Brainrot = Window:AddTab("Steal a Brainrot"),
    TSB = Window:AddTab("TSB"),
    Settings = Window:AddTab("Settings"),
}

-- === 4. TAB MAIN ===
local MainLeft = Tabs.Main:AddLeftGroupbox("Tối Ưu FPS")

MainLeft:AddToggle("UltraBoost", {
    Text = "Ultra Boost FPS",
    Default = true,
    Callback = function(value)
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
    end
})

MainLeft:AddToggle("RemoveParticles", {
    Text = "Xóa Hiệu Ứng",
    Default = true,
    Callback = function(value)
        getgenv().BoostFPS.RemoveParticles = value
        task.spawn(function()
            while getgenv().BoostFPS.RemoveParticles do
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                        obj.Enabled = false
                    end
                end
                task.wait(1)
            end
        end)
    end
})

MainLeft:AddToggle("NoShadows", {
    Text = "Tắt Bóng Đổ",
    Default = true,
    Callback = function(value)
        Lighting.GlobalShadows = not value
    end
})

local MainRight = Tabs.Main:AddRightGroupbox("Hệ Thống")

MainRight:AddToggle("AutoClean", {
    Text = "Tự Động Dọn RAM",
    Default = true,
    Callback = function(value)
        getgenv().BoostFPS.AutoClean = value
        task.spawn(function()
            while getgenv().BoostFPS.AutoClean do
                task.wait(30)
                collectgarbage("collect")
            end
        end)
    end
})

MainRight:AddToggle("CPUOptimize", {
    Text = "Tối Ưu CPU",
    Default = true,
    Callback = function(value)
        if value then
            UserInputService.WindowFocused:Connect(function()
                RunService:SetFpsCap(999)
            end)
            UserInputService.WindowFocusReleased:Connect(function()
                RunService:SetFpsCap(30)
            end)
        else
            RunService:SetFpsCap(999)
        end
    end
})

-- === 5. TAB BLOX FRUIT ===
local BFLeft = Tabs.BloxFruit:AddLeftGroupbox("Tối Ưu Blox Fruit")
local BFRight = Tabs.BloxFruit:AddRightGroupbox("Tối Ưu Map")

BFLeft:AddToggle("BF_NoSkillEffects", {
    Text = "Tắt Hiệu Ứng Skill",
    Default = false,
    Callback = function(value)
        getgenv().BoostFPS.BF_NoSkillEffects = value
        task.spawn(function()
            while getgenv().BoostFPS.BF_NoSkillEffects do
                local success = pcall(function()
                    for _, effect in pairs(game:GetService("ReplicatedStorage").Effect.Container:GetDescendants()) do
                        if effect:IsA("ParticleEmitter") then
                            effect.Enabled = false
                        end
                    end
                end)
                task.wait(1)
            end
        end)
    end
})

BFLeft:AddToggle("BF_ReduceWater", {
    Text = "Giảm Hiệu Ứng Nước",
    Default = false,
    Callback = function(value)
        if value then
            for _, part in pairs(Workspace:GetDescendants()) do
                if part:IsA("Part") and part.Name == "Water" then
                    part.Transparency = 0.8
                end
            end
        end
    end
})

BFRight:AddToggle("BF_OptimizeIslands", {
    Text = "Tối Ưu Đảo",
    Default = false,
    Callback = function(value)
        if value then
            for _, island in pairs(Workspace:GetChildren()) do
                if island:IsA("Model") and island:FindFirstChild("Terrain") then
                    island.Terrain.WaterTransparency = 0.9
                end
            end
        end
    end
})

BFRight:AddToggle("BF_NoFruitEffects", {
    Text = "Tắt Hiệu Ứng Trái",
    Default = false,
    Callback = function(value)
        getgenv().BoostFPS.BF_NoFruitEffects = value
        task.spawn(function()
            while getgenv().BoostFPS.BF_NoFruitEffects do
                for _, fruit in pairs(Workspace:GetChildren()) do
                    if fruit:FindFirstChild("Handle") then
                        for _, effect in pairs(fruit.Handle:GetDescendants()) do
                            if effect:IsA("ParticleEmitter") then
                                effect.Enabled = false
                            end
                        end
                    end
                end
                task.wait(2)
            end
        end)
    end
})

BFRight:AddToggle("BF_ReducePlayers", {
    Text = "Giảm Hiệu Ứng Người Chơi",
    Default = false,
    Callback = function(value)
        getgenv().BoostFPS.BF_ReducePlayers = value
        task.spawn(function()
            while getgenv().BoostFPS.BF_ReducePlayers do
                for _, player in pairs(Players:GetPlayers()) do
                    if player.Character then
                        for _, part in pairs(player.Character:GetDescendants()) do
                            if part:IsA("ParticleEmitter") then
                                part.Enabled = false
                            end
                        end
                    end
                end
                task.wait(2)
            end
        end)
    end
})

BFRight:AddToggle("BF_LocalLoad", {
    Text = "Load Xung Quanh Người Chơi",
    Default = false,
    Callback = function(value)
        getgenv().BoostFPS.BF_LocalLoad = value
        if value then
            task.spawn(function()
                local player = Players.LocalPlayer
                local radius = 300
                while getgenv().BoostFPS.BF_LocalLoad do
                    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local hrp = player.Character.HumanoidRootPart.Position
                        for _, island in pairs(Workspace:GetChildren()) do
                            if island:IsA("Model") and island:FindFirstChild("Terrain") then
                                -- SỬA LỖI: GetModelCFrame() -> GetPivot()
                                local islandPos = island:GetPivot().Position
                                local distance = (islandPos - hrp).Magnitude
                                if distance <= radius then
                                    if not island.Parent then island.Parent = Workspace end
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
                    task.wait(0.5)
                end
            end)
        else
            -- Khôi phục tất cả đảo
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
        end
    end
})

-- === 6. TAB SETTINGS ===
local SetLeft = Tabs.Settings:AddLeftGroupbox("Điều Khiển")
SetLeft:AddButton("Ẩn/Hiện UI (Ctrl+Phải)", function()
    Library:Unload()
end)
SetLeft:AddButton("Thu Nhỏ", function()
    Library.Minimize = not Library.Minimize
end)

local SetRight = Tabs.Settings:AddRightGroupbox("Hệ Thống")
SetRight:AddButton("Khôi Phục Gốc", function()
    -- Dừng tất cả các task đang chạy
    for key, value in pairs(getgenv().BoostFPS) do
        getgenv().BoostFPS[key] = false
    end
    
    -- Khôi phục lighting
    for property, value in pairs(OriginalState.Lighting) do
        Lighting[property] = value
    end
    
    -- Khôi phục settings
    settings().Rendering.QualityLevel = OriginalState.Global.QualityLevel
    settings().Rendering.MeshPartDetailLevel = OriginalState.Global.MeshDetail
    
    -- Bật lại tất cả hiệu ứng
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
            obj.Enabled = true
        end
    end
    
    -- Khôi phục tất cả đảo trong Blox Fruit
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
    
    Library:Notify("Đã khôi phục cài đặt gốc!", 3)
end)

-- === 7. PHÍM TẮT ===
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        Library:Unload()
    end
end)

-- === 8. HOÀN THIỆN ===
Library:Notify("BoostFPSHub v2.3 đã sẵn sàng!", 5)

SaveManager:SetLibrary(Library)
SaveManager:SetFolder("BoostFPSHub_v2.3")
SaveManager:BuildConfigSection(Tabs.Settings)

ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("BoostFPSHub_v2.3")
ThemeManager:ApplyToTab(Tabs.Settings)

warn("BoostFPSHub v2.3 loaded successfully!")
