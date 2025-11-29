-- BoostFPSHub v2.3 — Tối Ưu FPS Roblox
-- Language: Vietnamese
-- Features: Ẩn UI, thu nhỏ, tối ưu đa game, BF local load

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
        getgenv().RemoveParticles = value
        task.spawn(function()
            while getgenv().RemoveParticles do
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
        getgenv().AutoClean = value
        task.spawn(function()
            while getgenv().AutoClean do
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
        end
    end
})

-- === 5. TAB BLOX FRUIT NÂNG CAO ===
local BFLeft = Tabs.BloxFruit:AddLeftGroupbox("Tối Ưu Blox Fruit")
local BFRight = Tabs.BloxFruit:AddRightGroupbox("Tối Ưu Map")

-- Tắt hiệu ứng skill
BFLeft:AddToggle("BF_NoSkillEffects", {
    Text = "Tắt Hiệu Ứng Skill",
    Default = false,
    Callback = function(value)
        getgenv().BF_NoSkillEffects = value
        task.spawn(function()
            while getgenv().BF_NoSkillEffects do
                for _, effect in pairs(game:GetService("ReplicatedStorage").Effect.Container:GetDescendants()) do
                    if effect:IsA("ParticleEmitter") then
                        effect.Enabled = false
                    end
                end
                task.wait(1)
            end
        end)
    end
})

-- Giảm nước
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

-- Tối ưu đảo (cơ bản)
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

-- Tắt hiệu ứng trái cây
BFRight:AddToggle("BF_NoFruitEffects", {
    Text = "Tắt Hiệu Ứng Trái",
    Default = false,
    Callback = function(value)
        getgenv().BF_NoFruitEffects = value
        task.spawn(function()
            while getgenv().BF_NoFruitEffects do
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

-- Giảm hiệu ứng người chơi
BFRight:AddToggle("BF_ReducePlayers", {
    Text = "Giảm Hiệu Ứng Người Chơi",
    Default = false,
    Callback = function(value)
        getgenv().BF_ReducePlayers = value
        task.spawn(function()
            while getgenv().BF_ReducePlayers do
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

-- BF Local Loading / Culling nâng cao
BFRight:AddToggle("BF_LocalLoad", {
    Text = "Load Xung Quanh Người Chơi",
    Default = false,
    Callback = function(value)
        getgenv().BF_LocalLoad = value
        if value then
            task.spawn(function()
                local player = Players.LocalPlayer
                local radius = 300 -- bán kính load đảo
                while getgenv().BF_LocalLoad do
                    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local hrp = player.Character.HumanoidRootPart.Position
                        for _, island in pairs(Workspace:GetChildren()) do
                            if island:IsA("Model") and island:FindFirstChild("Terrain") then
                                local distance = (island:GetModelCFrame().p - hrp).Magnitude
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

-- === 6. TAB STEAL A BRAINROT ===
local BRLeft = Tabs.Brainrot:AddLeftGroupbox("Tối Ưu Nhân Vật")
local BRRight = Tabs.Brainrot:AddRightGroupbox("Tối Ưu Môi Trường")

BRLeft:AddToggle("BR_NoGlow", {
    Text = "Tắt Hiệu Ứng Phát Sáng",
    Default = false,
    Callback = function(value)
        getgenv().BR_NoGlow = value
        task.spawn(function()
            while getgenv().BR_NoGlow do
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("ParticleEmitter") and (obj.Name == "Glow" or obj.Name == "Aura") then
                        obj.Enabled = false
                    end
                end
                task.wait(1)
            end
        end)
    end
})

BRLeft:AddToggle("BR_ReduceCharacters", {
    Text = "Giảm Hiệu Ứng Nhân Vật",
    Default = false,
    Callback = function(value)
        getgenv().BR_ReduceCharacters = value
        task.spawn(function()
            while getgenv().BR_ReduceCharacters do
                for _, char in pairs(Workspace:GetChildren()) do
                    if char:FindFirstChild("Humanoid") then
                        for _, part in pairs(char:GetDescendants()) do
                            if part:IsA("ParticleEmitter") or part:IsA("Trail") then
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

BRLeft:AddToggle("BR_NoWeaponEffects", {
    Text = "Tắt Hiệu Ứng Vũ Khí",
    Default = false,
    Callback = function(value)
        if value then
            for _, tool in pairs(Workspace:GetDescendants()) do
                if tool:IsA("Tool") then
                    for _, effect in pairs(tool:GetDescendants()) do
                        if effect:IsA("ParticleEmitter") then
                            effect.Enabled = false
                        end
                    end
                end
            end
        end
    end
})

BRRight:AddToggle("BR_OptimizeMap", {
    Text = "Tối Ưu Bản Đồ",
    Default = false,
    Callback = function(value)
        if value then
            for _, part in pairs(Workspace:GetDescendants()) do
                if part:IsA("Part") and part.Material == Enum.Material.Neon then
                    part.Material = Enum.Material.Plastic
                end
            end
        end
    end
})

BRRight:AddToggle("BR_ReduceLighting", {
    Text = "Giảm Ánh Sáng",
    Default = false,
    Callback = function(value)
        if value then
            Lighting.Brightness = 1
            Lighting.Ambient = Color3.new(0.3, 0.3, 0.3)
        else
            Lighting.Brightness = OriginalState.Lighting.Brightness
            Lighting.Ambient = Color3.new(1, 1, 1)
        end
    end
})

BRRight:AddToggle("BR_NoAmbientSound", {
    Text = "Tắt Âm Thanh Môi Trường",
    Default = false,
    Callback = function(value)
        if value then
            for _, sound in pairs(Workspace:GetDescendants()) do
                if sound:IsA("Sound") and sound.Name == "Ambience" then
                    sound.Volume = 0
                end
            end
        end
    end
})

-- === 7. TAB TSB ===
local TSBLeft = Tabs.TSB:AddLeftGroupbox("Tối Ưu Nhân Vật")
local TSBRight = Tabs.TSB:AddRightGroupbox("Tối Ưu Môi Trường")

TSBLeft:AddToggle("TSB_NoSkillEffects", {
    Text = "Tắt Hiệu Ứng Skill",
    Default = false,
    Callback = function(value)
        getgenv().TSB_NoSkillEffects = value
        task.spawn(function()
            while getgenv().TSB_NoSkillEffects do
                for _, effect in pairs(Workspace:GetDescendants()) do
                    if effect:IsA("ParticleEmitter") and effect.Name == "SkillEffect" then
                        effect.Enabled = false
                    end
                end
                task.wait(1)
            end
        end)
    end
})

TSBLeft:AddToggle("TSB_ReduceAura", {
    Text = "Giảm Hiệu Ứng Aura",
    Default = false,
    Callback = function(value)
        getgenv().TSB_ReduceAura = value
        task.spawn(function()
            while getgenv().TSB_ReduceAura do
                for _, char in pairs(Workspace:GetChildren()) do
                    if char:FindFirstChild("Humanoid") then
                        for _, part in pairs(char:GetDescendants()) do
                            if part:IsA("ParticleEmitter") and part.Name == "Aura" then
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

TSBLeft:AddToggle("TSB_NoTrails", {
    Text = "Tắt Vệt Di Chuyển",
    Default = false,
    Callback = function(value)
        getgenv().TSB_NoTrails = value
        task.spawn(function()
            while getgenv().TSB_NoTrails do
                for _, trail in pairs(Workspace:GetDescendants()) do
                    if trail:IsA("Trail") then
                        trail.Enabled = false
                    end
                end
                task.wait(1)
            end
        end)
    end
})

TSBRight:AddToggle("TSB_OptimizeMap", {
    Text = "Tối Ưu Bản Đồ",
    Default = false,
    Callback = function(value)
        if value then
            for _, part in pairs(Workspace:GetDescendants()) do
                if part:IsA("Part") and part.BrickColor == BrickColor.new("Bright blue") then
                    part.Transparency = 0.5
                end
            end
        end
    end
})

TSBRight:AddToggle("TSB_ReducePlayers", {
    Text = "Giảm Hiệu Ứng Người Chơi",
    Default = false,
    Callback = function(value)
        getgenv().TSB_ReducePlayers = value
        task.spawn(function()
            while getgenv().TSB_ReducePlayers do
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

TSBRight:AddToggle("TSB_NoBattleEffects", {
    Text = "Tắt Hiệu Ứng Chiến Đấu",
    Default = false,
    Callback = function(value)
        if value then
            for _, effect in pairs(Workspace:GetDescendants()) do
                if effect:IsA("Explosion") or effect:IsA("Fire") then
                    effect:Destroy()
                end
            end
        end
    end
})

-- === 8. TAB SETTINGS ===
local SetLeft = Tabs.Settings:AddLeftGroupbox("Điều Khiển")
SetLeft:AddButton("Ẩn/Hiện UI (Ctrl+Phải)", function()
    Library:Unload()
end)
SetLeft:AddButton("Thu Nhỏ", function()
    Library.Minimize = not Library.Minimize
end)

local SetRight = Tabs.Settings:AddRightGroupbox("Hệ Thống")
SetRight:AddButton("Khôi Phục Gốc", function()
    for property, value in pairs(OriginalState.Lighting) do
        Lighting[property] = value
    end
    settings().Rendering.QualityLevel = OriginalState.Global.QualityLevel
    settings().Rendering.MeshPartDetailLevel = OriginalState.Global.MeshDetail
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
            obj.Enabled = true
        end
    end
    Library:Notify("Đã khôi phục cài đặt gốc!", 3)
end)

-- === 9. PHÍM TẮT ===
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        Library:Unload()
    end
end)

-- === 10. HOÀN THIỆN ===
Library:Notify(BoostFPSHub v2.3 loaded successfully!", 5)
SaveManager:SetLibrary(Library)
SaveManager:SetFolder("BoostFPSHub_v2.3")
SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("BoostFPSHub_v2.3")
ThemeManager:ApplyToTab(Tabs.Settings)

warn("BoostFPSHub v2.3 loaded successfully!")
