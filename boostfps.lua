-- BoostFPSHub v3 Universal Safe
-- Linoria UI, Safe for almost all Roblox games

if not game:IsLoaded() then game.Loaded:Wait() end

-- Load Linoria UI
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua"))()
local SaveManager  = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua"))()

local Window = Library:CreateWindow({Title = "Boost FPS Hub v3 — Universal Safe", Center = true, AutoShow = true})
local Tabs = {
    Main = Window:AddTab("Boost"),
    GFX = Window:AddTab("Graphics"),
    Misc = Window:AddTab("Settings"),
}

-- Services
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Settings
local Settings = {
    BoostFPS = true,       -- Safe, ON
    MobileBoost = true,    -- Safe, ON
    FPSUnlock = true,      -- Safe, ON
    UltraBoost = false,    -- Heavy, OFF
    AutoLowPoly = false,   -- Heavy, OFF
    DisableLOD = false,    -- Heavy, OFF
    NoSky = false,         -- Heavy, OFF
    NoDecals = false,      -- Heavy, OFF
    NoTextures = false,    -- Heavy, OFF
    NoWater = false,       -- Heavy, OFF
    AntiBan = false,       -- Heavy, OFF
    NoScreenGUI = false,   -- Heavy, OFF
    NoLightingFX = false,  -- Heavy, OFF
    NoParticles = false,   -- Heavy, OFF
}

local DefaultSettings = {
    QualityLevel = settings().Rendering.QualityLevel,
    GlobalShadows = Lighting.GlobalShadows,
    FogEnd = Lighting.FogEnd,
    Ambient = Lighting.Ambient,
}

local function safeCall(fn)
    local ok, err = pcall(fn)
    if not ok then warn("[BoostFPSHub v3 Error]:", err) end
end

-- Apply Boost Logic
local function applyBoost()
    safeCall(function()
        -- BoostFPS
        if Settings.BoostFPS then
            pcall(sethiddenproperty, workspace, "InterpolationThrottling", Enum.InterpolationThrottlingMode.Disabled)
            workspace.StreamingEnabled = true
        else
            workspace.StreamingEnabled = false
        end

        -- MobileBoost
        if Settings.MobileBoost then
            settings().Rendering.QualityLevel = 1
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 200
        else
            settings().Rendering.QualityLevel = DefaultSettings.QualityLevel
            Lighting.GlobalShadows = DefaultSettings.GlobalShadows
            Lighting.FogEnd = DefaultSettings.FogEnd
        end

        -- UltraBoost (heavy toggle)
        if Settings.UltraBoost then
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic v.Reflectance = 0 end
                if v:IsA("MeshPart") then v.RenderFidelity = Enum.RenderFidelity.Performance end
                if v:IsA("UnionOperation") then v.CollisionFidelity = Enum.CollisionFidelity.Box end
            end
        end

        -- AutoLowPoly
        if Settings.AutoLowPoly then
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("UnionOperation") then v.CollisionFidelity = Enum.CollisionFidelity.Box end
            end
        end

        -- DisableLOD
        pcall(sethiddenproperty, settings().Rendering, "EnableLevelOfDetail", not Settings.DisableLOD)

        -- NoSky
        if Settings.NoSky then
            local sky = Lighting:FindFirstChildOfClass("Sky")
            if sky then sky:Destroy() end
            Lighting.OutdoorAmbient = Color3.new(0.5,0.5,0.5)
            Lighting.Ambient = Color3.new(0.5,0.5,0.5)
        else
            Lighting.OutdoorAmbient = DefaultSettings.Ambient
            Lighting.Ambient = DefaultSettings.Ambient
        end

        -- NoDecals / NoTextures
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("Decal") then v.Transparency = Settings.NoDecals and 1 or 0 end
            if v:IsA("Texture") then v.Transparency = Settings.NoTextures and 1 or 0 end
        end

        -- NoWater
        local terrain = Workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            terrain.WaterWaveSize = Settings.NoWater and 0 or 1
            terrain.WaterWaveSpeed = Settings.NoWater and 0 or 1
            terrain.WaterTransparency = Settings.NoWater and 1 or 0.5
            terrain.WaterReflectance = Settings.NoWater and 1 or 0.5
        end

        -- AntiBan
        safeCall(function()
            if Settings.AntiBan then
                sethiddenproperty(game:GetService("ScriptContext"), "ScriptsDisabled", true)
                sethiddenproperty(game:GetService("ScriptContext"), "ScriptsHidden", true)
            else
                sethiddenproperty(game:GetService("ScriptContext"), "ScriptsDisabled", false)
                sethiddenproperty(game:GetService("ScriptContext"), "ScriptsHidden", false)
            end
        end)

        -- NoScreenGUI
        if LocalPlayer then
            local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
            if PlayerGui then
                for _, gui in pairs(PlayerGui:GetChildren()) do
                    if gui:IsA("ScreenGui") and gui.Name ~= "BoostFPSHub_Main" then
                        gui.Enabled = not Settings.NoScreenGUI
                    end
                end
            end
        end

        -- NoLightingFX
        for _, fx in pairs(Lighting:GetChildren()) do
            if fx:IsA("BloomEffect") or fx:IsA("ColorCorrectionEffect") or fx:IsA("DepthOfFieldEffect") or fx:IsA("SunRaysEffect") then
                fx.Enabled = not Settings.NoLightingFX
            end
        end

        -- Particle FX Safe
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
                obj.Enabled = not Settings.NoParticles
            end
        end

        -- FPS Unlock
        if Settings.FPSUnlock then
            if setfpscap then pcall(setfpscap, 999) end
            pcall(function() RunService.PreferredClientFPS = 999 end)
            pcall(function() RunService:SetFpsCap(999) end)
        else
            if setfpscap then pcall(setfpscap, 60) end
            pcall(function() RunService.PreferredClientFPS = 60 end)
            pcall(function() RunService:SetFpsCap(60) end)
        end
    end)
end

-- Auto restore after respawn
Players.LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    applyBoost()
end)

-- Build Linoria UI
local mainGroup = Tabs.Main:AddLeftGroupbox("Boost Options")
mainGroup:AddToggle("BoostFPS", {Text = "Boost FPS", Default = true, Callback = function(v) applyBoost() end})
mainGroup:AddToggle("MobileBoost", {Text = "Mobile Boost", Default = true, Callback = function(v) applyBoost() end})
mainGroup:AddToggle("FPSUnlock", {Text = "FPS Unlock", Default = true, Callback = function(v) applyBoost() end})
mainGroup:AddToggle("UltraBoost", {Text = "Ultra Boost (Heavy)", Default = false, Callback = function(v) applyBoost() end})

local gfxGroup = Tabs.GFX:AddLeftGroupbox("Graphics Options")
gfxGroup:AddToggle("AutoLowPoly", {Text = "Auto LowPoly (Heavy)", Default = false, Callback = function(v) applyBoost() end})
gfxGroup:AddToggle("DisableLOD", {Text = "Disable LOD (Heavy)", Default = false, Callback = function(v) applyBoost() end})
gfxGroup:AddToggle("NoSky", {Text = "Remove Sky (Heavy)", Default = false, Callback = function(v) applyBoost() end})
gfxGroup:AddToggle("NoDecals", {Text = "Remove Decals (Heavy)", Default = false, Callback = function(v) applyBoost() end})
gfxGroup:AddToggle("NoTextures", {Text = "Remove Textures (Heavy)", Default = false, Callback = function(v) applyBoost() end})
gfxGroup:AddToggle("NoWater", {Text = "Remove Water (Heavy)", Default = false, Callback = function(v) applyBoost() end})
gfxGroup:AddToggle("NoLightingFX", {Text = "Disable Lighting FX", Default = false, Callback = function(v) applyBoost() end})
gfxGroup:AddToggle("NoParticles", {Text = "Disable Particles (Heavy)", Default = false, Callback = function(v) applyBoost() end})
gfxGroup:AddToggle("NoScreenGUI", {Text = "Disable Player GUI (Heavy)", Default = false, Callback = function(v) applyBoost() end})
gfxGroup:AddToggle("AntiBan", {Text = "AntiBan Safe (Heavy)", Default = false, Callback = function(v) applyBoost() end})

-- Save & Theme
SaveManager:SetLibrary(Library)
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("BoostFPSHub_v3")
SaveManager:SetFolder("BoostFPSHub_v3")
SaveManager:BuildConfigSection(Tabs.Misc)

-- Apply initial boost
applyBoost()
Library:Notify("BoostFPSHub v3 Loaded! Safe for most games.", 5)
