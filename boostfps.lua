-- BOOST FPS HUB V1.1 - LINORIA STYLE 

-- SERVICES
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

-- SAFETY: local player & mouse
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer and LocalPlayer:GetMouse()

-- SETTINGS
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

-- LANGUAGE
local Lang = {
    ["VN"] = {
        title = "FPS BOOST HUB V12",
        tab1 = "HIỆU NĂNG", tab2 = "ĐỒ HỌA", tab3 = "CÀI ĐẶT",
        boost = "Tăng FPS Cơ Bản", ultra = "Siêu Tăng Tốc (Vật liệu)", mobile = "Chống Lag Di Động",
        lowpoly = "Tự động Đa giác Thấp", disable_lod = "Tắt LOD",
        no_sky = "Xóa Bầu Trời", no_skill = "Giảm Hiệu ứng Kỹ năng",
        no_decals = "Xóa Decals/Logos", no_textures = "Xóa Textures", no_water = "Xóa Nước",
        antiban = "Anti-Banwave", noscreengui = "Xóa GUI Game", nolightingfx = "Xóa Hiệu ứng Ánh sáng",
        fpsunlock = "Mở Khóa FPS",
        close = "Đóng", pin = "Khóa",
    }
}
local T = Lang[Settings.Language] or Lang["VN"]

-- CORE BOOST LOGIC
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
        for _,a in pairs(workspace:GetDescendants()) do
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
        if sky then sky.Parent = nil end
        Lighting.OutdoorAmbient = Color3.new(0.5,0.5,0.5)
        Lighting.Ambient = Color3.new(0.5,0.5,0.5)
    else
        Lighting.OutdoorAmbient = DefaultSettings.Ambient
        Lighting.Ambient = DefaultSettings.Ambient
    end

    -- NO DECALS/TEXTURES
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

    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Name ~= "BoostFPSHub_Main" then
            pcall(function() gui.Enabled = not Settings.NoScreenGUI end)
        end
    end

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

-- PARTICLE FX HANDLER
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

-- Apply initial
pcall(ApplyBoost)

-- ---------- UI BUILD (Custom Linoria-like) ----------
-- Parent UI to CoreGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BoostFPSHub_Main"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- MAIN PANEL as ImageLabel (customlooks)
local MainPanel = Instance.new("ImageLabel")
MainPanel.Name = "MainPanel"
MainPanel.Parent = ScreenGui
MainPanel.AnchorPoint = Vector2.new(0.5, 0.5)
MainPanel.Position = UDim2.new(0.5, 0, 0.5, 0)
MainPanel.Size = UDim2.new(0, 640, 0, 420)
MainPanel.BackgroundTransparency = 1
-- You can replace this image id with your own panel background asset (rounded corners + shadow)
MainPanel.Image = "rbxassetid://0" -- empty by default -> will look plain; replace with your asset if available
MainPanel.ScaleType = Enum.ScaleType.Slice
MainPanel.SliceCenter = Rect.new(12, 12, 52, 52)
MainPanel.Active = true

-- UICorner + Border using ImageLabel overlay for nicer look
local UICornerMain = Instance.new("UICorner", MainPanel)
UICornerMain.CornerRadius = UDim.new(0, 8)

-- Titlebar (ImageLabel for custom look)
local TitleBar = Instance.new("ImageLabel")
TitleBar.Name = "TitleBar"
TitleBar.Parent = MainPanel
TitleBar.AnchorPoint = Vector2.new(0, 0)
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.Size = UDim2.new(1, 0, 0, 46)
TitleBar.BackgroundTransparency = 0
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
TitleBar.Image = "" -- could use an image for gradient
TitleBar.ScaleType = Enum.ScaleType.Slice

local TitleText = Instance.new("TextLabel")
TitleText.Parent = TitleBar
TitleText.AnchorPoint = Vector2.new(0, 0.5)
TitleText.Position = UDim2.new(0, 12, 0.5, 0)
TitleText.Size = UDim2.new(0.6, 0, 1, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = T.title
TitleText.TextColor3 = Color3.fromRGB(230,230,230)
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 16
TitleText.TextXAlignment = Enum.TextXAlignment.Left

-- Close & Pin buttons (custom ImageButton)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Parent = TitleBar
CloseBtn.AnchorPoint = Vector2.new(1, 0.5)
CloseBtn.Position = UDim2.new(1, -12, 0.5, 0)
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.BackgroundTransparency = 0
CloseBtn.BackgroundColor3 = Color3.fromRGB(190, 40, 40)
CloseBtn.Text = "✕"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.TextColor3 = Color3.fromRGB(255,255,255)
CloseBtn.AutoButtonColor = false

local PinBtn = Instance.new("TextButton")
PinBtn.Name = "PinBtn"
PinBtn.Parent = TitleBar
PinBtn.AnchorPoint = Vector2.new(1, 0.5)
PinBtn.Position = UDim2.new(1, -48, 0.5, 0)
PinBtn.Size = UDim2.new(0, 28, 0, 28)
PinBtn.BackgroundTransparency = 0
PinBtn.BackgroundColor3 = Color3.fromRGB(80,80,80)
PinBtn.Text = "📌"
PinBtn.Font = Enum.Font.SourceSans
PinBtn.TextSize = 14
PinBtn.TextColor3 = Color3.fromRGB(220,220,220)
PinBtn.AutoButtonColor = false

-- Container for Tab buttons (left side)
local TabContainer = Instance.new("Frame")
TabContainer.Name = "TabContainer"
TabContainer.Parent = MainPanel
TabContainer.AnchorPoint = Vector2.new(0, 0)
TabContainer.Position = UDim2.new(0, 12, 0, 56)
TabContainer.Size = UDim2.new(0, 140, 1, -72)
TabContainer.BackgroundTransparency = 1

-- Right content area
local PageContainer = Instance.new("Frame")
PageContainer.Name = "PageContainer"
PageContainer.Parent = MainPanel
PageContainer.AnchorPoint = Vector2.new(0, 0)
PageContainer.Position = UDim2.new(0, 164, 0, 56)
PageContainer.Size = UDim2.new(1, -176, 1, -72)
PageContainer.BackgroundTransparency = 1

-- Little decorative left accent
local Accent = Instance.new("Frame")
Accent.Name = "Accent"
Accent.Parent = MainPanel
Accent.AnchorPoint = Vector2.new(0,0)
Accent.Position = UDim2.new(0, 0, 0, 46)
Accent.Size = UDim2.new(0, 6, 1, -46)
Accent.BackgroundColor3 = Color3.fromRGB(0,150,200)
Accent.BorderSizePixel = 0

-- Helper functions for creating custom images/buttons
local function makeTabButton(text, parent)
    local btn = Instance.new("TextButton")
    btn.Parent = parent
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundTransparency = 1
    btn.AutoButtonColor = false
    btn.Text = ""
    btn.LayoutOrder = 0

    local bg = Instance.new("ImageLabel")
    bg.Parent = btn
    bg.AnchorPoint = Vector2.new(0,0)
    bg.Position = UDim2.new(0, 0, 0, 0)
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.Image = "" -- keep empty to use color
    bg.BackgroundColor3 = Color3.fromRGB(35,35,35)

    local corner = Instance.new("UICorner", bg)
    corner.CornerRadius = UDim.new(0, 6)

    local label = Instance.new("TextLabel")
    label.Parent = btn
    label.AnchorPoint = Vector2.new(0,0.5)
    label.Position = UDim2.new(0, 12, 0.5, 0)
    label.Size = UDim2.new(1, -24, 1, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamSemibold
    label.Text = text
    label.TextSize = 14
    label.TextColor3 = Color3.fromRGB(200,200,200)
    label.TextXAlignment = Enum.TextXAlignment.Left

    return btn, bg, label
end

-- Tab creation
local TabButtons = {}
local TabPages = {}

local function createPage(name)
    local page = Instance.new("ScrollingFrame")
    page.Parent = PageContainer
    page.Name = name:gsub("%s","_")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.Position = UDim2.new(0, 0, 0, 0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 8
    page.CanvasSize = UDim2.new(0,0,0,0)
    page.Visible = false

    local layout = Instance.new("UIListLayout", page)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0,8)

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y + 12)
    end)

    TabPages[name] = page
    return page
end

-- Toggle control (custom switch)
local function createToggle(parent, labelText, settingKey)
    local container = Instance.new("Frame")
    container.Parent = parent
    container.Size = UDim2.new(1, -12, 0, 44)
    container.BackgroundTransparency = 1

    local bg = Instance.new("ImageLabel")
    bg.Parent = container
    bg.AnchorPoint = Vector2.new(0,0)
    bg.Position = UDim2.new(0, 0, 0, 0)
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(40,40,40)
    bg.Image = ""
    bg.ScaleType = Enum.ScaleType.Slice
    bg.SliceCenter = Rect.new(12,12,52,52)

    local cr = Instance.new("UICorner", bg)
    cr.CornerRadius = UDim.new(0, 6)

    local label = Instance.new("TextLabel")
    label.Parent = bg
    label.AnchorPoint = Vector2.new(0,0.5)
    label.Position = UDim2.new(0, 12, 0.5, 0)
    label.Size = UDim2.new(0.75, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextColor3 = Color3.fromRGB(230,230,230)
    label.TextXAlignment = Enum.TextXAlignment.Left

    -- switch visual (ImageButton)
    local switch = Instance.new("ImageButton")
    switch.Parent = bg
    switch.AnchorPoint = Vector2.new(1, 0.5)
    switch.Position = UDim2.new(1, -12, 0.5, 0)
    switch.Size = UDim2.new(0, 50, 0, 26)
    switch.BackgroundTransparency = 1
    switch.Image = ""
    switch.AutoButtonColor = false

    local sw_bg = Instance.new("Frame", switch)
    sw_bg.Size = UDim2.new(1,0,1,0)
    sw_bg.Position = UDim2.new(0,0,0,0)
    sw_bg.BackgroundColor3 = Settings[settingKey] and Color3.fromRGB(0,150,140) or Color3.fromRGB(80,80,80)
    sw_bg.AnchorPoint = Vector2.new(0.5,0.5)
    sw_bg.BorderSizePixel = 0

    local sw_corner = Instance.new("UICorner", sw_bg)
    sw_corner.CornerRadius = UDim.new(1,0)

    local knob = Instance.new("Frame", sw_bg)
    knob.Size = UDim2.new(0, 22, 0, 22)
    knob.Position = Settings[settingKey] and UDim2.new(1, -26, 0.5, -11) or UDim2.new(0, 4, 0.5, -11)
    knob.BackgroundColor3 = Color3.fromRGB(245,245,245)
    knob.BorderSizePixel = 0
    local knobCorner = Instance.new("UICorner", knob)
    knobCorner.CornerRadius = UDim.new(1,0)

    -- apply logic
    local function updateVisual()
        sw_bg.BackgroundColor3 = Settings[settingKey] and Color3.fromRGB(0,150,140) or Color3.fromRGB(80,80,80)
        knob:TweenPosition(Settings[settingKey] and UDim2.new(1, -26, 0.5, -11) or UDim2.new(0, 4, 0.5, -11), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.12, true)
    end

    switch.MouseButton1Click:Connect(function()
        Settings[settingKey] = not Settings[settingKey]
        SaveSettings()
        pcall(ApplyBoost)
        updateVisual()
    end)

    -- initial
    updateVisual()
    return container
end

-- create tabs and pages
local page1 = createPage(T.tab1)
local page2 = createPage(T.tab2)
local page3 = createPage(T.tab3)

local btn1, bg1, lt1 = makeTabButton(T.tab1, TabContainer)
local btn2, bg2, lt2 = makeTabButton(T.tab2, TabContainer)
local btn3, bg3, lt3 = makeTabButton(T.tab3, TabContainer)

btn1.Parent = TabContainer
btn2.Parent = TabContainer
btn3.Parent = TabContainer

table.insert(TabButtons, {Name=T.tab1, Button=btn1, Page=page1, Bg=bg1})
table.insert(TabButtons, {Name=T.tab2, Button=btn2, Page=page2, Bg=bg2})
table.insert(TabButtons, {Name=T.tab3, Button=btn3, Page=page3, Bg=bg3})

-- populate page1 (performance)
createToggle(page1, T.boost, "BoostFPS")
createToggle(page1, T.ultra, "UltraBoost")
createToggle(page1, T.mobile, "MobileBoost")
createToggle(page1, T.lowpoly, "AutoLowPoly")
createToggle(page1, T.fpsunlock, "FPSUnlock")
createToggle(page1, T.antiban, "AntiBan")

-- populate page2 (graphics)
createToggle(page2, T.disable_lod, "DisableLOD")
createToggle(page2, T.no_sky, "NoSky")
createToggle(page2, T.no_skill, "NoSkillFX")
createToggle(page2, T.no_decals, "NoDecals")
createToggle(page2, T.no_textures, "NoTextures")
createToggle(page2, T.no_water, "NoWater")
createToggle(page2, T.nolightingfx, "NoLightingFX")
createToggle(page2, T.noscreengui, "NoScreenGUI")

-- page3 can have reset/save buttons etc.
local function createButton(parent, text, cb)
    local container = Instance.new("Frame")
    container.Parent = parent
    container.Size = UDim2.new(1, -12, 0, 40)
    container.BackgroundTransparency = 1

    local btn = Instance.new("TextButton")
    btn.Parent = container
    btn.AnchorPoint = Vector2.new(0,0)
    btn.Position = UDim2.new(0,0,0,0)
    btn.Size = UDim2.new(1,0,1,0)
    btn.BackgroundColor3 = Color3.fromRGB(0,150,200)
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.AutoButtonColor = false
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0,6)
    btn.MouseButton1Click:Connect(function()
        if cb then pcall(cb) end
    end)
    return container
end

createButton(page3, "Save Settings", function() SaveSettings() end)
createButton(page3, "Reset to Default", function()
    Settings = {
        Language = "VN", BoostFPS = false, UltraBoost = false, MobileBoost = false, AutoLowPoly = false,
        DisableLOD = false, NoSky = false, NoSkillFX = false, NoDecals = false, NoTextures = false,
        NoWater = false, AntiBan = false, NoScreenGUI = false, NoLightingFX = false, FPSUnlock = false,
    }
    SaveSettings()
    ApplyBoost()
    -- refresh toggles by reloading UI would be simplest; for brevity not implemented here
end)

-- TAB selection handler
local function selectTab(tab)
    for _, t in ipairs(TabButtons) do
        t.Bg.BackgroundColor3 = (t == tab) and Color3.fromRGB(0,120,160) or Color3.fromRGB(35,35,35)
        t.Page.Visible = (t == tab)
    end
end

-- connect tabs
for _,t in ipairs(TabButtons) do
    t.Button.MouseButton1Click:Connect(function()
        selectTab(t)
    end)
end

-- Auto-select first tab
if #TabButtons > 0 then selectTab(TabButtons[1]) end

-- DRAG LOGIC for MainPanel using TitleBar
local dragging, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = Vector2.new(input.Position.X, input.Position.Y)
        startPos = MainPanel.Position
    end
end)
TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStart
        MainPanel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- RESIZE HANDLE (corner, drag to resize)
local ResizeHandle = Instance.new("ImageButton")
ResizeHandle.Parent = MainPanel
ResizeHandle.Name = "Resize"
ResizeHandle.AnchorPoint = Vector2.new(1,1)
ResizeHandle.Position = UDim2.new(1, -8, 1, -8)
ResizeHandle.Size = UDim2.new(0, 18, 0, 18)
ResizeHandle.BackgroundTransparency = 0
ResizeHandle.BackgroundColor3 = Color3.fromRGB(35,35,35)
ResizeHandle.AutoButtonColor = false
ResizeHandle.Image = ""
local rhCorner = Instance.new("UICorner", ResizeHandle)
rhCorner.CornerRadius = UDim.new(0,6)

local resizing = false
local resizeStartPos, resizeStartSize, resizeStartMouse

ResizeHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        resizing = true
        resizeStartMouse = Vector2.new(input.Position.X, input.Position.Y)
        resizeStartSize = Vector2.new(MainPanel.AbsoluteSize.X, MainPanel.AbsoluteSize.Y)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
        local currentMouse = Vector2.new(input.Position.X, input.Position.Y)
        local delta = currentMouse - resizeStartMouse
        local newX = math.max(300, resizeStartSize.X + delta.X)
        local newY = math.max(180, resizeStartSize.Y + delta.Y)
        MainPanel.Size = UDim2.new(0, newX, 0, newY)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        resizing = false
    end
end)

-- CLOSE and PIN behavior
local pinned = false
CloseBtn.MouseButton1Click:Connect(function()
    MainPanel.Visible = false
end)
PinBtn.MouseButton1Click:Connect(function()
    pinned = not pinned
    PinBtn.BackgroundColor3 = pinned and Color3.fromRGB(0,150,200) or Color3.fromRGB(80,80,80)
    PinBtn.TextColor3 = pinned and Color3.fromRGB(255,255,255) or Color3.fromRGB(220,220,220)
    -- when pinned, keep on top (we're parented to CoreGui so it's already top), else nothing special
end)

-- HIDE/SHOW with RIGHTSHIFT
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
        MainPanel.Visible = not MainPanel.Visible
    end
end)

-- final print
print("[BoostFPS Hub V12 - LinoriaStyle] Loaded successfully.")

-- Ensure UI toggles reflect loaded Settings visually (some toggles created earlier already used Settings on init)
-- But to be safe, re-apply boost once more
pcall(ApplyBoost)
