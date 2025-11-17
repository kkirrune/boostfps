--========================================================--
-- BOOST FPS HUB V12 – VOLCANO UI (Dark Theme Tabbed) - FINAL FIX
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
    QualityLevel = settings().Rendering.QualityLevel, GlobalShadows = Lighting.GlobalShadows,
    FogEnd = Lighting.FogEnd, Ambient = Lighting.Ambient,
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

-- CORE FUNCTIONS (Đã Sửa Lỗi)
local function ApplyBoost()
    -- BOOST FPS
    if Settings.BoostFPS then pcall(sethiddenproperty, workspace, "InterpolationThrottling", Enum.InterpolationThrottlingMode.Disabled); workspace.StreamingEnabled = true
    else workspace.StreamingEnabled = false end
    
    -- ULTRA BOOST (Fixed RenderFidelity/SolidModel issue with pcall)
    if Settings.UltraBoost then 
        for _,part in pairs(workspace:GetDescendants()) do 
            if part:IsA("MeshPart") then 
                pcall(function() part.RenderFidelity = Enum.RenderFidelity.Performance end) -- Bọc trong pcall 
            end 
            if part:IsA("BasePart") then 
                part.Material = Enum.Material.SmoothPlastic 
            end 
        end 
    end
    
    -- MOBILE BOOST
    if Settings.MobileBoost then settings().Rendering.QualityLevel = 1; Lighting.GlobalShadows = false; Lighting.FogEnd = 200
    else settings().Rendering.QualityLevel = DefaultSettings.QualityLevel; Lighting.GlobalShadows = DefaultSettings.GlobalShadows; Lighting.FogEnd = DefaultSettings.FogEnd end
    
    -- LOW POLY & LOD
    if Settings.AutoLowPoly then for _,a in pairs(workspace:GetDescendants()) do if a:IsA("UnionOperation") then a.CollisionFidelity = Enum.CollisionFidelity.Box end end end
    if Settings.DisableLOD then pcall(sethiddenproperty, settings().Rendering, "EnableLevelOfDetail", false)
    else pcall(sethiddenproperty, settings().Rendering, "EnableLevelOfDetail", true) end
    
    -- NO SKY
    local sky = Lighting:FindFirstChildOfClass("Sky")
    if Settings.NoSky then if sky then sky.Parent = nil end; Lighting.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5); Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
    else Lighting.OutdoorAmbient = DefaultSettings.Ambient; Lighting.Ambient = DefaultSettings.Ambient end
    
    -- NO DECALS (Fixed BillboardGui Transparency issue)
    for _, obj in ipairs(workspace:GetDescendants()) do 
        if obj:IsA("Decal") then 
            obj.Transparency = Settings.NoDecals and 1 or 0 -- Chỉ thay đổi Decal
        end
        -- Không thay đổi Transparency của BillboardGui để tránh lỗi
    end
    
    -- NO TEXTURES
    for _, obj in ipairs(workspace:GetDescendants()) do if obj:IsA("Texture") then obj.Transparency = Settings.NoTextures and 1 or 0 end end
    
    -- NO WATER
    local Water = workspace:FindFirstChildOfClass("Terrain")
    if Water then
        Water.WaterWaveSize = Settings.NoWater and 0 or 1; Water.WaterWaveSpeed = Settings.NoWater and 0 or 1
        Water.WaterTransparency = Settings.NoWater and 1 or 0.5; Water.WaterReflectance = Settings.NoWater and 1 or 0.5
    end

    -- ANTI-BAN & GUI & LIGHTING FX
    if Settings.AntiBan then pcall(sethiddenproperty, game:GetService("ScriptContext"), "ScriptsDisabled", true); pcall(sethiddenproperty, game:GetService("ScriptContext"), "ScriptsHidden", true)
    else pcall(sethiddenproperty, game:GetService("ScriptContext"), "ScriptsDisabled", false); pcall(sethiddenproperty, game:GetService("ScriptContext"), "ScriptsHidden", false) end

    local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
    for _, gui in ipairs(PlayerGui:GetChildren()) do if gui:IsA("ScreenGui") and gui.Name ~= "BoostFPSHub_Main" then gui.Enabled = not Settings.NoScreenGUI end end
    
    for _, fx in ipairs(Lighting:GetChildren()) do if fx:IsA("BloomEffect") or fx:IsA("ColorCorrectionEffect") or fx:IsA("DepthOfFieldEffect") or fx:IsA("SunRaysEffect") then fx.Enabled = not Settings.NoLightingFX end end

    -- FPS UNLOCK
    if Settings.FPSUnlock then
        if setfpscap then setfpscap(999) end
        pcall(function() game:GetService("RunService").PreferredClientFPS = 999 end)
        pcall(function() game:GetService("RunService"):SetFpsCap(999) end)
    else
        if setfpscap then setfpscap(60) end
        pcall(function() game:GetService("RunService").PreferredClientFPS = 60 end)
        pcall(function() game:GetService("RunService"):SetFpsCap(60) end)
    end
end

local function SetFX(obj)
    if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
        obj.Enabled = not Settings.NoSkillFX
        if Settings.NoSkillFX then obj.Transparency = NumberRange.new(0.8); obj.Lifetime = NumberRange.new(0.1)
        else obj.Transparency = NumberRange.new(0); obj.Lifetime = NumberRange.new(5) end
    end
end
workspace.DescendantAdded:Connect(SetFX)

ApplyBoost()

--========================================================--
--  V12 DARK THEME UI (Mô phỏng Tab)
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
pcall(function() MainPanel.Draggable = true end)
MainPanel.Parent = ScreenGui

local TitleBar = Instance.new("TextBox") 
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.Text = T.title
TitleBar.Font = Enum.Font.SourceSansBold
TitleBar.TextSize = 20
TitleBar.TextColor3 = Color3.fromRGB(220, 220, 220)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20) 
TitleBar.TextEditable = false 
TitleBar.Parent = MainPanel

local TabContainer = Instance.new("ImageLabel")
TabContainer.Size = UDim2.new(0, 100, 1, -40) 
TabContainer.Position = UDim2.new(0, 0, 0, 40)
TabContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TabContainer.Image = ""
TabContainer.Parent = MainPanel

local PageContainer = Instance.new("ImageLabel")
PageContainer.Size = UDim2.new(1, -100, 1, -40)
PageContainer.Position = UDim2.new(0, 100, 0, 40)
PageContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
PageContainer.Image = ""
PageContainer.Parent = MainPanel

local CurrentTab = nil
local TabButtons = {}
local TabPages = {}

local function CreateTabButton(tabName, pageContainer)
    local Button = Instance.new("ImageButton")
    Button.Size = UDim2.new(1, 0, 0, 35)
    Button.BackgroundColor3 = Color3.fromRGB(45, 45, 45) 
    Button.Image = ""
    Button.Parent = TabContainer

    local ButtonText = Instance.new("TextBox")
    ButtonText.Size = UDim2.new(1, 0, 1, 0)
    ButtonText.Text = tabName
    ButtonText.Font = Enum.Font.SourceSansBold
    ButtonText.TextSize = 14
    ButtonText.TextColor3 = Color3.fromRGB(180, 180, 180)
    ButtonText.BackgroundColor3 = Color3.new(0,0,0)
    ButtonText.TextTransparency = 1
    ButtonText.TextEditable = false
    ButtonText.Parent = Button
    
    table.insert(TabButtons, {Name = tabName, Button = Button, Page = pageContainer})
    
    Button.MouseButton1Click:Connect(function()
        for _, t in ipairs(TabButtons) do
            t.Page.Visible = false
            t.Button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            t.Button:FindFirstChildOfClass("TextBox").TextColor3 = Color3.fromRGB(180, 180, 180)
        end
        pageContainer.Visible = true
        Button.BackgroundColor3 = Color3.fromRGB(0, 150, 200) 
        Button:FindFirstChildOfClass("TextBox").TextColor3 = Color3.fromRGB(255, 255, 255)
        CurrentTab = tabName
    end)
    return Button
end

local function CreateTabPage(name)
    local Page = Instance.new("ImageLabel")
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.Position = UDim2.new(0, 0, 0, 0)
    Page.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Page.Image = ""
    Page.Visible = false
    Page.Parent = PageContainer
    
    local Scroll = Instance.new("ScrollingGui")
    Scroll.Size = UDim2.new(1, -10, 1, -10)
    Scroll.Position = UDim2.new(0, 5, 0, 5)
    Scroll.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Scroll.ScrollBarThickness = 6
    Scroll.Parent = Page
    
    local UILayout = Instance.new("UIGridLayout") 
    UILayout.CellSize = UDim2.new(1, 0, 0, 45) 
    UILayout.CellPadding = UDim2.new(0, 0, 0, 10)
    UILayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UILayout.Parent = Scroll

    TabPages[name] = {Page = Page, Scroll = Scroll, UILayout = UILayout}
    return Scroll
end

local function CreateToggleContent(parentScroll, text, settingKey)
    local Container = Instance.new("ImageLabel") 
    Container.Size = UDim2.new(1, 0, 0, 45)
    Container.BackgroundColor3 = Color3.fromRGB(40, 40, 40) 
    Container.BorderSizePixel = 0
    Container.Image = ""
    Container.Parent = parentScroll
    
    local LabelText = Instance.new("TextBox") 
    LabelText.Size = UDim2.new(1, -90, 1, 0)
    LabelText.Position = UDim2.new(0, 10, 0, 0)
    LabelText.Text = text
    LabelText.Font = Enum.Font.SourceSans
    LabelText.TextSize = 15
    LabelText.TextColor3 = Color3.fromRGB(220, 220, 220)
    LabelText.BackgroundColor3 = Container.BackgroundColor3
    LabelText.TextXAlignment = Enum.TextXAlignment.Left
    LabelText.TextEditable = false
    LabelText.Parent = Container

    local ToggleButton = Instance.new("ImageButton") 
    ToggleButton.Size = UDim2.new(0, 60, 0, 30)
    ToggleButton.Position = UDim2.new(1, -70, 0.5, -15)
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Parent = Container
    ToggleButton.Image = "" 
    
    local ButtonText = Instance.new("TextBox") 
    ButtonText.Size = UDim2.new(1, 0, 1, 0)
    ButtonText.Font = Enum.Font.SourceSansBold
    ButtonText.TextSize = 14
    ButtonText.TextColor3 = Color3.fromRGB(255, 255, 255)
    ButtonText.BackgroundColor3 = Color3.new(0,0,0)
    ButtonText.TextTransparency = 1
    ButtonText.Parent = ToggleButton
    
    local function UpdateButtonColor(state)
        if state then
            ButtonText.Text = "ON"
            ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0) 
        else
            ButtonText.Text = "OFF"
            ToggleButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0) 
        end
    end

    ToggleButton.MouseButton1Click:Connect(function()
        Settings[settingKey] = not Settings[settingKey]
        SaveSettings()
        ApplyBoost()
        UpdateButtonColor(Settings[settingKey])
    end)
    
    UpdateButtonColor(Settings[settingKey])
    return Container
end

--========================================================--
--  CREATE LAYOUTS
--========================================================--

-- 1. Tab Performance
local Tab1Scroll = CreateTabPage(T.tab1)
CreateToggleContent(Tab1Scroll, T.boost, "BoostFPS")
CreateToggleContent(Tab1Scroll, T.ultra, "UltraBoost")
CreateToggleContent(Tab1Scroll, T.mobile, "MobileBoost")
CreateToggleContent(Tab1Scroll, T.lowpoly, "AutoLowPoly")
CreateToggleContent(Tab1Scroll, T.fpsunlock, "FPSUnlock")
CreateToggleContent(Tab1Scroll, T.antiban, "AntiBan")
Tab1Scroll.CanvasSize = UDim2.new(0, 0, 0, (45 + 10) * 6 + 10)

-- 2. Tab Graphics
local Tab2Scroll = CreateTabPage(T.tab2)
CreateToggleContent(Tab2Scroll, T.disable_lod, "DisableLOD")
CreateToggleContent(Tab2Scroll, T.no_sky, "NoSky")
CreateToggleContent(Tab2Scroll, T.no_skill, "NoSkillFX")
CreateToggleContent(Tab2Scroll, T.no_decals, "NoDecals")
CreateToggleContent(Tab2Scroll, T.no_textures, "NoTextures")
CreateToggleContent(Tab2Scroll, T.no_water, "NoWater")
CreateToggleContent(Tab2Scroll, T.nolightingfx, "NoLightingFX")
CreateToggleContent(Tab2Scroll, T.noscreengui, "NoScreenGUI")
Tab2Scroll.CanvasSize = UDim2.new(0, 0, 0, (45 + 10) * 8 + 10)


-- Create Tab Buttons
local Tab1Button = CreateTabButton(T.tab1, TabPages[T.tab1].Page)
local Tab2Button = CreateTabButton(T.tab2, TabPages[T.tab2].Page)

-- Auto select first tab
pcall(function() Tab1Button:FireServer("MouseButton1Click") end) 

-- Align buttons using UIListLayout
local TabListLayout = Instance.new("UIListLayout")
TabListLayout.Padding = UDim.new(0, 5)
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Parent = TabContainer

-- HIDE UI WITH RIGHTSHIFT
UserInputService.InputBegan:Connect(function(k,t)
    if not t and k.KeyCode == Enum.KeyCode.RightShift then
        MainPanel.Visible = not MainPanel.Visible
    end
end)

print("[BoostFPS Hub V12] Loaded successfully on Volcano/limited Executors. Press RightShift to hide/show.")
