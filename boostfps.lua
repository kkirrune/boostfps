--========================================================--
-- BOOST FPS HUB V1 – VOLCANO UI (Dark Theme Tabbed)
--========================================================--

--// SERVICES
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

--========================================================--
--  SETTINGS & DEFAULTS
--========================================================--

local SaveFile = "BoostFPSHub_Settings.json"
local Settings = {
    Language = "VN", BoostFPS = false, UltraBoost = false, MobileBoost = false, AutoLowPoly = false,
    DisableLOD = false, NoSky = false, NoSkillFX = false, NoDecals = false, NoTextures = false,
    NoWater = false, AntiBan = false, NoScreenGUI = false, NoLightingFX = false, FPSUnlock = false,
}

local DefaultSettings = {
    QualityLevel = settings().Rendering.QualityLevel,
    GlobalShadows = Lighting.GlobalShadows,
    FogEnd = Lighting.FogEnd,
    Ambient = Lighting.Ambient,
}

local function LoadSettings()
    if isfile and isfile(SaveFile) then
        local ok, data = pcall(function() return HttpService:JSONDecode(readfile(SaveFile)) end)
        if ok and type(data) == "table" then
            for k,v in pairs(data) do 
                if Settings[k] ~= nil then Settings[k] = v end
            end
        end
    end
end

local function SaveSettings()
    if writefile then writefile(SaveFile, HttpService:JSONEncode(Settings)) end
end

LoadSettings()

--========================================================--
--  LANGUAGE
--========================================================--

local Lang = {
    ["VN"] = {
        title = "FPS BOOST HUB V12", 
        tab1 = "HIEU NANG", tab2 = "DO HOA", tab3 = "CAI DAT",
        boost = "Tang FPS Co Ban", ultra = "Sieu Tang Toc (Vat lieu)", mobile = "Chong Lag Di Dong", 
        lowpoly = "Tu dong Da giac Thap", disable_lod = "Tat LOD", 
        no_sky = "Xoa Bau Troi", no_skill = "Giam Hieu ung Ky nang",
        no_decals = "Xoa Decals/Logos", no_textures = "Xoa Textures", no_water = "Xoa Nuoc",
        antiban = "Anti-Banwave", noscreengui = "Xoa GUI Game", nolightingfx = "Xoa Hieu ung Anh sang", 
        fpsunlock = "Mo khoa FPS", 
    },
}

local T = Lang[Settings.Language]

--========================================================--
--  CORE BOOST FUNCTION
--========================================================--

local function ApplyBoost()
    -- BOOST FPS
    if Settings.BoostFPS then
        pcall(sethiddenproperty, workspace, "InterpolationThrottling", Enum.InterpolationThrottlingMode.Disabled)
        workspace.StreamingEnabled = true
    else
        workspace.StreamingEnabled = false
    end
    
    -- ULTRA BOOST
    if Settings.UltraBoost then 
        for _,part in pairs(workspace:GetDescendants()) do 
            if part:IsA("MeshPart") then 
                pcall(function() part.RenderFidelity = Enum.RenderFidelity.Performance end) 
            end 
            if part:IsA("BasePart") then 
                part.Material = Enum.Material.SmoothPlastic 
            end 
        end 
    end
    
    -- MOBILE BOOST
    if Settings.MobileBoost then 
        settings().Rendering.QualityLevel = 1
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 200
    else
        settings().Rendering.QualityLevel = DefaultSettings.QualityLevel
        Lighting.GlobalShadows = DefaultSettings.GlobalShadows
        Lighting.FogEnd = DefaultSettings.FogEnd
    end
    
    -- LOW POLY & LOD
    if Settings.AutoLowPoly then 
        for _,a in pairs(workspace:GetDescendants()) do
            if a:IsA("UnionOperation") then a.CollisionFidelity = Enum.CollisionFidelity.Box end
        end
    end
    
    if Settings.DisableLOD then
        pcall(sethiddenproperty, settings().Rendering, "EnableLevelOfDetail", false)
    else
        pcall(sethiddenproperty, settings().Rendering, "EnableLevelOfDetail", true)
    end
    
    -- NO SKY
    local sky = Lighting:FindFirstChildOfClass("Sky")
    if Settings.NoSky then
        if sky then sky.Parent = nil end
        Lighting.OutdoorAmbient = Color3.new(0.5,0.5,0.5)
        Lighting.Ambient = Color3.new(0.5,0.5,0.5)
    else
        Lighting.OutdoorAmbient = DefaultSettings.Ambient
        Lighting.Ambient = DefaultSettings.Ambient
    end
    
    -- NO DECALS
    for _, obj in ipairs(workspace:GetDescendants()) do 
        if obj:IsA("Decal") then obj.Transparency = Settings.NoDecals and 1 or 0 end
        if obj:IsA("Texture") then obj.Transparency = Settings.NoTextures and 1 or 0 end
    end
    
    -- NO WATER
    local Water = workspace:FindFirstChildOfClass("Terrain")
    if Water then
        Water.WaterWaveSize = Settings.NoWater and 0 or 1
        Water.WaterWaveSpeed = Settings.NoWater and 0 or 1
        Water.WaterTransparency = Settings.NoWater and 1 or 0.5
        Water.WaterReflectance = Settings.NoWater and 1 or 0.5
    end

    -- ANTI-BAN & GUI & LIGHTING FX
    if Settings.AntiBan then 
        pcall(sethiddenproperty, game:GetService("ScriptContext"), "ScriptsDisabled", true)
        pcall(sethiddenproperty, game:GetService("ScriptContext"), "ScriptsHidden", true)
    else
        pcall(sethiddenproperty, game:GetService("ScriptContext"), "ScriptsDisabled", false)
        pcall(sethiddenproperty, game:GetService("ScriptContext"), "ScriptsHidden", false)
    end

    local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Name ~= "BoostFPSHub_Main" then
            gui.Enabled = not Settings.NoScreenGUI
        end
    end
    
    for _, fx in ipairs(Lighting:GetChildren()) do
        if fx:IsA("BloomEffect") or fx:IsA("ColorCorrectionEffect") or fx:IsA("DepthOfFieldEffect") or fx:IsA("SunRaysEffect") then
            fx.Enabled = not Settings.NoLightingFX
        end
    end

    -- FPS UNLOCK
    if Settings.FPSUnlock then
        if setfpscap then setfpscap(999) end
        pcall(function() RunService.PreferredClientFPS = 999 end)
        pcall(function() RunService:SetFpsCap(999) end)
    else
        if setfpscap then setfpscap(60) end
        pcall(function() RunService.PreferredClientFPS = 60 end)
        pcall(function() RunService:SetFpsCap(60) end)
    end
end

-- Particle/Skill FX handler
local function SetFX(obj)
    if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
        obj.Enabled = not Settings.NoSkillFX
        if Settings.NoSkillFX then 
            obj.Transparency = NumberSequence.new(0.8)
            obj.Lifetime = NumberRange.new(0.1)
        else
            obj.Transparency = NumberSequence.new(0)
            obj.Lifetime = NumberRange.new(5)
        end
    end
end

workspace.DescendantAdded:Connect(SetFX)
ApplyBoost()

--========================================================--
--  UI CREATION (DRAGGABLE, TABBED)
--========================================================--

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BoostFPSHub_Main"
ScreenGui.Parent = CoreGui

local MainPanel = Instance.new("ImageLabel")
MainPanel.Size = UDim2.new(0, 450, 0, 400)
MainPanel.Position = UDim2.new(0.5, -225, 0.5, -200)
MainPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainPanel.BorderSizePixel = 0
MainPanel.Image = ""
MainPanel.Parent = ScreenGui
pcall(function() MainPanel.Draggable = true end)

local TitleBar = Instance.new("TextLabel")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.Text = T.title
TitleBar.Font = Enum.Font.SourceSansBold
TitleBar.TextSize = 20
TitleBar.TextColor3 = Color3.fromRGB(220, 220, 220)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
TitleBar.Parent = MainPanel

-- Tab containers
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(0, 100, 1, -40)
TabContainer.Position = UDim2.new(0, 0, 0, 40)
TabContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TabContainer.Parent = MainPanel

local PageContainer = Instance.new("Frame")
PageContainer.Size = UDim2.new(1, -100, 1, -40)
PageContainer.Position = UDim2.new(0, 100, 0, 40)
PageContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
PageContainer.Parent = MainPanel

local CurrentTab
local TabButtons, TabPages = {}, {}

-- Create Tab Button
local function CreateTabButton(tabName, pageContainer)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -10, 0, 35)
    Button.Position = UDim2.new(0, 5, 0, 0)
    Button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Button.Text = tabName
    Button.TextColor3 = Color3.fromRGB(180, 180, 180)
    Button.Font = Enum.Font.SourceSansBold
    Button.TextSize = 14
    Button.Parent = TabContainer

    table.insert(TabButtons, {Name = tabName, Button = Button, Page = pageContainer})

    Button.MouseButton1Click:Connect(function()
        for _, t in ipairs(TabButtons) do
            t.Page.Visible = false
            t.Button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            t.Button.TextColor3 = Color3.fromRGB(180, 180, 180)
        end
        pageContainer.Visible = true
        Button.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        CurrentTab = tabName
    end)

    return Button
end

-- Create Tab Page
local function CreateTabPage(name)
    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.Position = UDim2.new(0, 0, 0, 0)
    Page.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Page.ScrollBarThickness = 6
    Page.Visible = false
    Page.Parent = PageContainer

    local UIList = Instance.new("UIListLayout")
    UIList.Padding = UDim.new(0,10)
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.Parent = Page

    TabPages[name] = {Page = Page, UIList = UIList}
    return Page
end

-- Create toggle button
local function CreateToggleContent(parentPage, text, settingKey)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -10, 0, 40)
    Container.BackgroundColor3 = Color3.fromRGB(40,40,40)
    Container.BorderSizePixel = 0
    Container.Parent = parentPage

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -80, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220,220,220)
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 15
    Label.BackgroundTransparency = 1
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container

    local Toggle = Instance.new("TextButton")
    Toggle.Size = UDim2.new(0, 60, 0, 30)
    Toggle.Position = UDim2.new(1, -70, 0.5, -15)
    Toggle.BorderSizePixel = 0
    Toggle.Parent = Container

    local function UpdateButton()
        if Settings[settingKey] then
            Toggle.Text = "ON"
            Toggle.BackgroundColor3 = Color3.fromRGB(0,150,0)
        else
            Toggle.Text = "OFF"
            Toggle.BackgroundColor3 = Color3.fromRGB(150,0,0)
        end
    end

    Toggle.MouseButton1Click:Connect(function()
        Settings[settingKey] = not Settings[settingKey]
        SaveSettings()
        ApplyBoost()
        UpdateButton()
    end)

    UpdateButton()
    return Container
end

--========================================================--
-- CREATE TABS AND CONTENT
--========================================================--

-- 1. Performance Tab
local Tab1Page = CreateTabPage(T.tab1)
CreateToggleContent(Tab1Page, T.boost, "BoostFPS")
CreateToggleContent(Tab1Page, T.ultra, "UltraBoost")
CreateToggleContent(Tab1Page, T.mobile, "MobileBoost")
CreateToggleContent(Tab1Page, T.lowpoly, "AutoLowPoly")
CreateToggleContent(Tab1Page, T.fpsunlock, "FPSUnlock")
CreateToggleContent(Tab1Page, T.antiban, "AntiBan")

-- 2. Graphics Tab
local Tab2Page = CreateTabPage(T.tab2)
CreateToggleContent(Tab2Page, T.disable_lod, "DisableLOD")
CreateToggleContent(Tab2Page, T.no_sky, "NoSky")
CreateToggleContent(Tab2Page, T.no_skill, "NoSkillFX")
CreateToggleContent(Tab2Page, T.no_decals, "NoDecals")
CreateToggleContent(Tab2Page, T.no_textures, "NoTextures")
CreateToggleContent(Tab2Page, T.no_water, "NoWater")
CreateToggleContent(Tab2Page, T.nolightingfx, "NoLightingFX")
CreateToggleContent(Tab2Page, T.noscreengui, "NoScreenGUI")

-- Create tab buttons
CreateTabButton(T.tab1, Tab1Page)
CreateTabButton(T.tab2, Tab2Page)

-- Auto-select first tab
if #TabButtons > 0 then
    TabButtons[1].Button:CaptureFocus()
    TabButtons[1].Button.MouseButton1Click:Wait()
end

-- HIDE UI WITH RIGHTSHIFT
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
        MainPanel.Visible = not MainPanel.Visible
    end
end)

print("[BoostFPS Hub V12] Loaded successfully. Press RightShift to hide/show.")
