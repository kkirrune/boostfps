--[[
BOOST FPS HUB UNIVERSAL V1.0
- Linoria-style UI
- Safe: anti-crash, universal, no game-specific
- No animation, no weapons, no localChar references
]]--

-- SERVICES
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- LOCAL PLAYER
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer and LocalPlayer:GetMouse()

-- SETTINGS
local SaveFile = "BoostFPSHub_Universal.json"
local Settings = {
    BoostFPS = false,
    UltraBoost = false,
    MobileBoost = false,
    AutoLowPoly = false,
    DisableLOD = false,
    NoSky = false,
    NoDecals = false,
    NoTextures = false,
    NoWater = false,
    AntiBan = false,
    NoScreenGUI = false,
    NoLightingFX = false,
    FPSUnlock = false,
}

-- DEFAULTS (to restore)
local DefaultSettings = {
    QualityLevel = settings().Rendering.QualityLevel,
    GlobalShadows = Lighting.GlobalShadows,
    FogEnd = Lighting.FogEnd,
    Ambient = Lighting.Ambient,
}

-- LOAD/SAVE SETTINGS
local function LoadSettings()
    if isfile and isfile(SaveFile) then
        local ok, data = pcall(function() return HttpService:JSONDecode(readfile(SaveFile)) end)
        if ok and type(data) == "table" then
            for k,v in pairs(data) do
                if Settings[k] ~= nil then
                    Settings[k] = v
                end
            end
        end
    end
end

local function SaveSettings()
    if writefile then
        writefile(SaveFile, HttpService:JSONEncode(Settings))
    end
end

LoadSettings()

-- BOOST LOGIC (safe)
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
        for _, part in pairs(workspace:GetDescendants()) do
            if part:IsA("MeshPart") then
                pcall(function() part.RenderFidelity = Enum.RenderFidelity.Performance end)
            end
            if part:IsA("BasePart") then
                pcall(function() part.Material = Enum.Material.SmoothPlastic end)
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
        for _, a in pairs(workspace:GetDescendants()) do
            if a:IsA("UnionOperation") then
                pcall(function() a.CollisionFidelity = Enum.CollisionFidelity.Box end)
            end
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
        if sky then sky:Destroy() end
        Lighting.OutdoorAmbient = Color3.new(0.5,0.5,0.5)
        Lighting.Ambient = Color3.new(0.5,0.5,0.5)
    else
        Lighting.OutdoorAmbient = DefaultSettings.Ambient
        Lighting.Ambient = DefaultSettings.Ambient
    end

    -- NO DECALS / TEXTURES
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

    -- PlayerGui safe toggle
    if LocalPlayer then
        local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if PlayerGui then
            for _, gui in ipairs(PlayerGui:GetChildren()) do
                if gui:IsA("ScreenGui") and gui.Name ~= "BoostFPSHub_Main" then
                    pcall(function() gui.Enabled = not Settings.NoScreenGUI end)
                end
            end
        end
    end

    -- Lighting FX safe toggle
    for _, fx in ipairs(Lighting:GetChildren()) do
        if fx:IsA("BloomEffect") or fx:IsA("ColorCorrectionEffect") or fx:IsA("DepthOfFieldEffect") or fx:IsA("SunRaysEffect") then
            fx.Enabled = not Settings.NoLightingFX
        end
    end

    -- FPS UNLOCK
    if Settings.FPSUnlock then
        if setfpscap then pcall(setfpscap, 999) end
        pcall(function() RunService.PreferredClientFPS = 999 end)
        pcall(function() RunService:SetFpsCap(999) end)
    else
        if setfpscap then pcall(setfpscap, 60) end
        pcall(function() RunService.PreferredClientFPS = 60 end)
        pcall(function() RunService:SetFpsCap(60) end)
    end
end

-- PARTICLE FX HANDLER (safe)
local function SetFX(obj)
    if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
        obj.Enabled = true -- keep default
    end
end
workspace.DescendantAdded:Connect(SetFX)

-- APPLY INITIAL BOOST
pcall(ApplyBoost)

--[[ =========================
UI SECTION (Linoria Style)
========================= ]]--

local function BuildUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "BoostFPSHub_Main"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = CoreGui

    -- Main Panel
    local MainPanel = Instance.new("Frame")
    MainPanel.Name = "MainPanel"
    MainPanel.Size = UDim2.new(0,640,0,420)
    MainPanel.Position = UDim2.new(0.5,0,0.5,0)
    MainPanel.AnchorPoint = Vector2.new(0.5,0.5)
    MainPanel.BackgroundColor3 = Color3.fromRGB(25,25,25)
    MainPanel.BorderSizePixel = 0
    MainPanel.Parent = ScreenGui
    local UIC = Instance.new("UICorner", MainPanel)
    UIC.CornerRadius = UDim.new(0,8)

    -- TitleBar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1,0,0,46)
    TitleBar.Position = UDim2.new(0,0,0,0)
    TitleBar.BackgroundColor3 = Color3.fromRGB(20,20,20)
    TitleBar.Parent = MainPanel
    local TitleText = Instance.new("TextLabel")
    TitleText.Parent = TitleBar
    TitleText.Size = UDim2.new(1,-60,1,0)
    TitleText.Position = UDim2.new(0,12,0,0)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = "Boost FPS Hub Universal"
    TitleText.TextColor3 = Color3.fromRGB(230,230,230)
    TitleText.Font = Enum.Font.GothamBold
    TitleText.TextSize = 16
    TitleText.TextXAlignment = Enum.TextXAlignment.Left

    -- Close Button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Parent = TitleBar
    CloseBtn.Size = UDim2.new(0,28,0,28)
    CloseBtn.Position = UDim2.new(1,-12,0.5,-14)
    CloseBtn.Text = "✕"
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 16
    CloseBtn.TextColor3 = Color3.fromRGB(255,255,255)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(190,40,40)
    CloseBtn.AutoButtonColor = false
    CloseBtn.MouseButton1Click:Connect(function() MainPanel.Visible = false end)

    -- Tab Container
    local TabContainer = Instance.new("Frame")
    TabContainer.Size = UDim2.new(0,140,1,-72)
    TabContainer.Position = UDim2.new(0,12,0,56)
    TabContainer.BackgroundTransparency = 1
    TabContainer.Parent = MainPanel

    -- Page Container
    local PageContainer = Instance.new("Frame")
    PageContainer.Size = UDim2.new(1,-176,1,-72)
    PageContainer.Position = UDim2.new(0,164,0,56)
    PageContainer.BackgroundTransparency = 1
    PageContainer.Parent = MainPanel

    -- Create Toggle Helper
    local function createToggle(parent, text, key)
        local frame = Instance.new("Frame", parent)
        frame.Size = UDim2.new(1,0,0,36)
        frame.BackgroundTransparency = 1
        local lbl = Instance.new("TextLabel", frame)
        lbl.Size = UDim2.new(1, -60, 1, 0)
        lbl.Position = UDim2.new(0,12,0,0)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = Color3.fromRGB(230,230,230)
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 14
        lbl.TextXAlignment = Enum.TextXAlignment.Left

        local btn = Instance.new("TextButton", frame)
        btn.Size = UDim2.new(0,50,0,24)
        btn.Position = UDim2.new(1,-60,0.5,-12)
        btn.Text = Settings[key] and "ON" or "OFF"
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 14
        btn.TextColor3 = Settings[key] and Color3.fromRGB(0,200,140) or Color3.fromRGB(180,180,180)
        btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
        btn.AutoButtonColor = false
        btn.MouseButton1Click:Connect(function()
            Settings[key] = not Settings[key]
            btn.Text = Settings[key] and "ON" or "OFF"
            btn.TextColor3 = Settings[key] and Color3.fromRGB(0,200,140) or Color3.fromRGB(180,180,180)
            SaveSettings()
            pcall(ApplyBoost)
        end)
    end

    -- Pages and toggles
    local Pages = {}
    local function createPage(name)
        local page = Instance.new("ScrollingFrame", PageContainer)
        page.Size = UDim2.new(1,0,1,0)
        page.Position = UDim2.new(0,0,0,0)
        page.BackgroundTransparency = 1
        page.Visible = false
        local layout = Instance.new("UIListLayout", page)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0,8)
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            page.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 12)
        end)
        Pages[name] = page
        return page
    end

    local page1 = createPage("Performance")
    local page2 = createPage("Graphics")
    local page3 = createPage("Settings")

    createToggle(page1,"Boost FPS","BoostFPS")
    createToggle(page1,"Ultra Boost","UltraBoost")
    createToggle(page1,"Mobile Boost","MobileBoost")
    createToggle(page1,"Auto LowPoly","AutoLowPoly")
    createToggle(page1,"FPS Unlock","FPSUnlock")
    createToggle(page1,"AntiBan","AntiBan")

    createToggle(page2,"Disable LOD","DisableLOD")
    createToggle(page2,"No Sky","NoSky")
    createToggle(page2,"No Decals","NoDecals")
    createToggle(page2,"No Textures","NoTextures")
    createToggle(page2,"No Water","NoWater")
    createToggle(page2,"No Lighting FX","NoLightingFX")
    createToggle(page2,"No Screen GUI","NoScreenGUI")

    -- Settings Page
    local btnSave = Instance.new("TextButton", page3)
    btnSave.Size = UDim2.new(1,0,0,36)
    btnSave.BackgroundColor3 = Color3.fromRGB(0,150,200)
    btnSave.Text = "Save Settings"
    btnSave.Font = Enum.Font.GothamBold
    btnSave.TextSize = 14
    btnSave.TextColor3 = Color3.fromRGB(255,255,255)
    btnSave.AutoButtonColor = false
    btnSave.MouseButton1Click:Connect(function()
        SaveSettings()
    end)

    local btnReset = Instance.new("TextButton", page3)
    btnReset.Size = UDim2.new(1,0,0,36)
    btnReset.Position = UDim2.new(0,0,0,44)
    btnReset.BackgroundColor3 = Color3.fromRGB(200,50,50)
    btnReset.Text = "Reset Settings"
    btnReset.Font = Enum.Font.GothamBold
    btnReset.TextSize = 14
    btnReset.TextColor3 = Color3.fromRGB(255,255,255)
    btnReset.AutoButtonColor = false
    btnReset.MouseButton1Click:Connect(function()
        for k,_ in pairs(Settings) do
            Settings[k] = false
        end
        SaveSettings()
        pcall(ApplyBoost)
    end)

    -- Drag Logic
    local dragging, startPos, startMouse
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            startMouse = input.Position
            startPos = MainPanel.Position
        end
    end)
    TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - startMouse
            MainPanel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- Build UI
pcall(BuildUI)

print("[BoostFPS Hub Universal] Loaded successfully.")
