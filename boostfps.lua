-- BoostFPS Hub v2 - Linoria-style Dark UI (Full)
-- Multi-language (default EN), Drag+Drop, Tabs, Scrolling, Mobile friendly
-- Aggressive visual reduction (safe-first heuristics), Smart anti-ban delays
-- Author: generated for kkirru — customize Config below

-- ================= CONFIG =================
local Config = {
    Theme = {
        Background = Color3.fromRGB(18,22,25),
        Panel = Color3.fromRGB(24,30,34),
        Accent = Color3.fromRGB(86,145,255),
        Accent2 = Color3.fromRGB(84,176,160),
        Text = Color3.fromRGB(232,236,240),
        SubText = Color3.fromRGB(150,160,170),
        WindowRadius = 8,
    },
    LanguageDefault = "en", -- DEFAULT LANGUAGE = EN
    AutoDetectLocale = true,
    AntiBan = {
        MinDelay = 0.03,
        MaxDelay = 0.12,
        BatchSize = 100,
        Jitter = 0.025,
    },
    AggressiveDepth = 2, -- 0 = mild, 1 = strong, 2 = extreme-safe
    MobileScale = 1.12,
    IsVIP = false, -- set to true locally to enable VIP aggressive extras
    ToggleKey = Enum.KeyCode.RightControl,
    DefaultRenderDistance = (workspace:FindFirstChild("StreamingTargetRadius") and workspace.StreamingTargetRadius) or 512,
    AntiCrashInterval = 24,
}

-- ================= LOCALES (EN default, VI included) =================
local LANGS = {
    en = {
        Title = "BoostFPS Hub",
        Hint = "Safe visuals optimizer · PC & Mobile",
        BoostAll = "APPLY MAX BOOST (SAFE)",
        Restore = "RESTORE (Revert All)",
        FPS = "FPS: %d",
        RenderValue = "Render Radius: %d",
        ToggleUI = "Toggle UI",
        Particles = "Disable Particles / FX",
        Lights = "Disable Lights",
        Textures = "Hide Decals / Textures",
        Materials = "Reduce Materials -> Plastic",
        Mesh = "Strip Mesh Textures",
        Post = "Disable Post-Processing",
        Fog = "Disable Fog",
        Shadows = "Disable Shadows",
        Foliage = "Hide Foliage",
        Sounds = "Mute Workspace Sounds",
        AntiCrash = "Anti-Crash (Auto Clear + GC)",
        VIP = "Apply VIP Aggressive Mode",
        AggressiveApplied = "[VIP] Aggressive Mode Applied",
        AntiCrashDo = "[AntiCrash] Cleared cache + GC",
    },
    vi = {
        Title = "BoostFPS Hub",
        Hint = "Tối ưu đồ họa an toàn · PC & Mobile",
        BoostAll = "BẬT TĂNG TỐI ĐA (AN TOÀN)",
        Restore = "KHÔI PHỤC (Hoàn tác)",
        FPS = "FPS: %d",
        RenderValue = "Khoảng cách render: %d",
        ToggleUI = "Hiện/Ẩn UI",
        Particles = "Tắt Particles / FX",
        Lights = "Tắt Đèn",
        Textures = "Ẩn Decal / Texture",
        Materials = "Giảm Material -> Plastic",
        Mesh = "Xóa Texture Mesh",
        Post = "Tắt Post-Processing",
        Fog = "Tắt Fog",
        Shadows = "Tắt Shadows",
        Foliage = "Ẩn Cây Cỏ",
        Sounds = "Tắt Âm Workspace",
        AntiCrash = "Anti-Crash (Clear + GC)",
        VIP = "Kích hoạt VIP Aggressive Mode",
        AggressiveApplied = "[VIP] Chế độ Aggressive kích hoạt",
        AntiCrashDo = "[AntiCrash] Đã xóa cache + GC",
    }
}
-- choose locale
local function detectLocale()
    if Config.AutoDetectLocale then
        local success, localeId = pcall(function() return game:GetService("LocalizationService").RobloxLocaleId end)
        if success and localeId then
            local short = tostring(localeId):sub(1,2):lower()
            if LANGS[short] then return short end
        end
    end
    return Config.LanguageDefault
end
local LOCALE = detectLocale()
local L = LANGS[LOCALE] or LANGS[Config.LanguageDefault]

-- ================= SERVICES & STATE =================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local ContentProvider = game:GetService("ContentProvider")
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local TeleportService = game:GetService("TeleportService")

local Original = {}       -- Original properties map {instance -> {prop=val}}
local ModifiedList = {}   -- instances we modified (list)
local Toggles = {}        -- active toggles
local AntiCrashThread = nil
local FPSConn = nil
local UIVisible = true

-- ================= UTILITIES =================
local function randDelay()
    local a,b = Config.AntiBan.MinDelay, Config.AntiBan.MaxDelay
    return a + math.random()*(b-a) + (math.random()-0.5)*Config.AntiBan.Jitter
end

local function batchWorker(list, batchSize, worker)
    if #list == 0 then return end
    task.spawn(function()
        local i = 1
        local bs = math.max(6, batchSize or Config.AntiBan.BatchSize)
        while i <= #list do
            local endI = math.min(#list, i + bs - 1)
            for j=i,endI do
                pcall(worker, list[j])
            end
            i = endI + 1
            task.wait(randDelay())
        end
    end)
end

local function saveOriginal(inst, props)
    if not inst then return end
    if Original[inst] then return end
    Original[inst] = {}
    for _,p in ipairs(props) do
        pcall(function() Original[inst][p] = inst[p] end)
    end
    table.insert(ModifiedList, inst)
end

local function isProtected(inst)
    if not inst then return true end
    if inst:IsDescendantOf(LocalPlayer.Character or {}) then return true end
    if inst:IsDescendantOf(LocalPlayer:FindFirstChild("PlayerGui") or {}) then return true end
    if inst:IsDescendantOf(LocalPlayer:FindFirstChild("Backpack") or {}) then return true end
    if inst:IsDescendantOf(game:GetService("StarterGui")) then return true end
    if CollectionService:HasTag(inst, "Preserve") then return true end
    local nm = tostring(inst.Name):lower()
    if nm:match("hit") or nm:match("hurt") or nm:match("damage") or nm:match("hitbox") or nm:match("projectile") then
        return true
    end
    local ok, attr = pcall(function() return inst:GetAttribute("NoOptimize") end)
    if ok and attr then return true end
    return false
end

-- ================= ACTIONS (SAFE-PRIORITY) =================
local function disableEmitters(root)
    local found = {}
    for _,v in ipairs(root:GetDescendants()) do
        if (v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Sparkles") or v:IsA("Smoke") or v:IsA("Fire")) and not isProtected(v) then
            table.insert(found, v)
        end
    end
    batchWorker(found, Config.AntiBan.BatchSize, function(obj)
        saveOriginal(obj, {"Enabled"})
        pcall(function() obj.Enabled = false end)
    end)
end

local function disableLights(root)
    local found = {}
    for _,v in ipairs(root:GetDescendants()) do
        if v:IsA("Light") and not isProtected(v) then table.insert(found, v) end
    end
    batchWorker(found, Config.AntiBan.BatchSize, function(light)
        saveOriginal(light, {"Enabled"})
        pcall(function() light.Enabled = false end)
    end)
end

local function hideDecalsTextures(root)
    local found = {}
    for _,v in ipairs(root:GetDescendants()) do
        if (v:IsA("Decal") or v:IsA("Texture") or v:IsA("SurfaceAppearance")) and not isProtected(v) then
            table.insert(found, v)
        end
    end
    batchWorker(found, math.max(8, Config.AntiBan.BatchSize//4), function(obj)
        if obj:IsA("SurfaceAppearance") then
            saveOriginal(obj, {"AlbedoColor","Roughness","Metalness"})
            pcall(function()
                obj.AlbedoColor = Color3.new(0.5,0.5,0.5)
                if obj:FindFirstChild("ColorMap") then pcall(function() obj.ColorMap = "" end) end
            end)
        else
            saveOriginal(obj, {"Transparency"})
            pcall(function() obj.Transparency = 1 end)
        end
    end)
end

local function reduceMaterials(root)
    local found = {}
    for _,v in ipairs(root:GetDescendants()) do
        if v:IsA("BasePart") and not isProtected(v) then table.insert(found, v) end
    end
    batchWorker(found, Config.AntiBan.BatchSize, function(part)
        saveOriginal(part, {"Material","Reflectance"})
        pcall(function() part.Material = Enum.Material.SmoothPlastic part.Reflectance = 0 end)
    end)
end

local function optimizeMeshParts(root)
    local found = {}
    for _,v in ipairs(root:GetDescendants()) do
        if v:IsA("MeshPart") and not isProtected(v) then table.insert(found, v) end
    end
    batchWorker(found, math.max(6, Config.AntiBan.BatchSize//6), function(mesh)
        saveOriginal(mesh, {"TextureID","RenderFidelity"})
        pcall(function()
            if mesh.TextureID and mesh.TextureID ~= "" then mesh.TextureID = "" end
            if mesh.RenderFidelity then pcall(function() mesh.RenderFidelity = Enum.RenderFidelity.Performance end) end
        end)
    end)
end

local function disablePostProcessing()
    local effects = {}
    for _,eff in ipairs(Lighting:GetChildren()) do
        local cls = eff.ClassName
        if cls == "BloomEffect" or cls == "SunRaysEffect" or cls == "ColorCorrectionEffect" or cls == "DepthOfFieldEffect" or cls == "BlurEffect" or cls == "AmbientOcclusion" then
            table.insert(effects, eff)
        end
    end
    for _,e in ipairs(effects) do
        saveOriginal(e, {"Enabled"})
        pcall(function() if e.Enabled ~= nil then e.Enabled = false end end)
    end
end

local function disableFog(state)
    pcall(function()
        if Original["_Lighting_FogEnd"] == nil then Original["_Lighting_FogEnd"] = Lighting.FogEnd end
        if Lighting:FindFirstChild("Atmosphere") and Original["_Lighting_AtmosphereDensity"] == nil then Original["_Lighting_AtmosphereDensity"] = Lighting.Atmosphere.Density end
        if state then
            Lighting.FogEnd = 1e6
            if Lighting:FindFirstChild("Atmosphere") then Lighting.Atmosphere.Density = 0 end
        else
            Lighting.FogEnd = Original["_Lighting_FogEnd"] or 1000
            if Lighting:FindFirstChild("Atmosphere") then Lighting.Atmosphere.Density = Original["_Lighting_AtmosphereDensity"] or 0.35 end
        end
    end)
end

local function disableShadows(state)
    pcall(function()
        if Original["_Lighting_GlobalShadows"] == nil then Original["_Lighting_GlobalShadows"] = Lighting.GlobalShadows end
        Lighting.GlobalShadows = not state
    end)
end

local function hideFoliage(root)
    local found = {}
    for _,v in ipairs(root:GetDescendants()) do
        if (v:IsA("MeshPart") or v:IsA("Part")) and not isProtected(v) then
            local nm = tostring(v.Name):lower()
            if nm:find("tree") or nm:find("leaf") or nm:find("grass") or nm:find("bush") or nm:find("foliage") then
                table.insert(found, v)
            end
        end
    end
    batchWorker(found, Config.AntiBan.BatchSize, function(obj)
        saveOriginal(obj, {"Transparency","CanCollide"})
        pcall(function() obj.Transparency = 1 obj.CanCollide = false end)
    end)
end

local function muteWorkspaceSounds()
    local found = {}
    for _,v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Sound") and not isProtected(v) then table.insert(found, v) end
    end
    batchWorker(found, Config.AntiBan.BatchSize, function(s)
        saveOriginal(s, {"Volume","Playing"})
        pcall(function() s.Volume = 0 if s.Playing then s:Stop() end end)
    end)
end

local function setRenderDistance(radius)
    pcall(function()
        if workspace:FindFirstChild("StreamingTargetRadius") then
            if Original["_StreamingTargetRadius"] == nil then Original["_StreamingTargetRadius"] = workspace.StreamingTargetRadius end
            workspace.StreamingTargetRadius = radius
        end
    end)
end

local function restoreRenderDistance()
    pcall(function() if Original["_StreamingTargetRadius"] then workspace.StreamingTargetRadius = Original["_StreamingTargetRadius"] end end)
end

-- Aggressive depth extras (safe rules applied)
local function aggressiveExtras(depth)
    if depth >= 1 then
        -- stronger: remove decal textures, set terrain low LOD
        hideDecalsTextures(workspace)
        optimizeMeshParts(workspace)
        reduceMaterials(workspace)
    end
    if depth >= 2 then
        -- extreme-safe: reduce additional quality, remove more maps, set streaming low
        hideFoliage(workspace)
        muteWorkspaceSounds()
        setRenderDistance(128) -- aggressive but safe for low-end
    end
end

-- ================= AntiCrash =================
local function startAntiCrash()
    if AntiCrashThread then return end
    AntiCrashThread = task.spawn(function()
        while Toggles.antiCrash do
            task.wait(Config.AntiCrashInterval)
            pcall(function() ContentProvider:ClearAllCachedAssets() end)
            collectgarbage("collect")
            pcall(function() print(L.AntiCrashDo or "[AntiCrash] Cleared") end)
        end
        AntiCrashThread = nil
    end)
    print(L.AntiCrashOn or "[AntiCrash] Enabled")
end

local function stopAntiCrash()
    Toggles.antiCrash = false
    AntiCrashThread = nil
end

-- ================= APPLY / REVERT =================
local function applyFullSafeBoost()
    task.spawn(function()
        task.wait(randDelay())
        hideDecalsTextures(workspace); task.wait(randDelay())
        disableEmitters(workspace); task.wait(randDelay())
        optimizeMeshParts(workspace); task.wait(randDelay())
        reduceMaterials(workspace); task.wait(randDelay())
        disablePostProcessing(); task.wait(randDelay())
        disableFog(true); task.wait(randDelay())
        disableShadows(true); task.wait(randDelay())
        hideFoliage(workspace); task.wait(randDelay())
        muteWorkspaceSounds()
        Toggles.antiCrash = true; startAntiCrash()
        if Config.IsVIP then aggressiveExtras(Config.AggressiveDepth) end
    end)
end

local function restoreAll()
    for _,inst in ipairs(ModifiedList) do
        local orig = Original[inst]
        if orig and inst and inst.Parent then
            pcall(function()
                for k,v in pairs(orig) do
                    pcall(function() inst[k] = v end)
                end
            end)
        end
    end
    pcall(function()
        if Original["_Lighting_GlobalShadows"] ~= nil then Lighting.GlobalShadows = Original["_Lighting_GlobalShadows"] end
        if Original["_Lighting_FogEnd"] ~= nil then Lighting.FogEnd = Original["_Lighting_FogEnd"] end
        if Original["_Lighting_AtmosphereDensity"] ~= nil and Lighting:FindFirstChild("Atmosphere") then Lighting.Atmosphere.Density = Original["_Lighting_AtmosphereDensity"] end
    end)
    Original = {}
    ModifiedList = {}
    Toggles = {}
    stopAntiCrash()
    restoreRenderDistance()
    print("[BoostFPS] Restore attempted.")
end

-- ================= UI: Linoria-like Dark =================
-- Remove old
if game.CoreGui:FindFirstChild("BoostFPS_LinoriaUI_v2") then game.CoreGui.BoostFPS_LinoriaUI_v2:Destroy() end
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BoostFPS_LinoriaUI_v2"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

-- scale
local mobile = (UIS.TouchEnabled and not UIS.KeyboardEnabled) or false
local scale = mobile and Config.MobileScale or 1
local W = math.floor(420 * scale)
local H = math.floor(420 * scale)

-- Main window
local Window = Instance.new("Frame", ScreenGui)
Window.Name = "Window"
Window.Size = UDim2.new(0, W, 0, H)
Window.Position = UDim2.new(0.06, 0, 0.18, 0)
Window.AnchorPoint = Vector2.new(0,0)
Window.BackgroundColor3 = Config.Theme.Panel
Window.BorderSizePixel = 0
Window.ClipsDescendants = true
Window.Visible = true
Window.Active = true
Window.Draggable = true
Window.AutomaticSize = Enum.AutomaticSize.None
Window.LayoutOrder = 1

-- Rounded corners (UIGradient not supported, but we can fake)
local UICorner = Instance.new("UICorner", Window)
UICorner.CornerRadius = UDim.new(0, Config.Theme.WindowRadius)

-- Header
local Header = Instance.new("Frame", Window)
Header.Size = UDim2.new(1, 0, 0, 54)
Header.Position = UDim2.new(0, 0, 0, 0)
Header.BackgroundColor3 = Config.Theme.Background
Header.BorderSizePixel = 0

local TitleLabel = Instance.new("TextLabel", Header)
TitleLabel.Size = UDim2.new(0.7, -12, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = L.Title
TitleLabel.TextColor3 = Config.Theme.Accent
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = math.clamp(15 * scale, 12, 20)
TitleLabel.TextScaled = false

local HintLabel = Instance.new("TextLabel", Header)
HintLabel.Size = UDim2.new(0.3, -12, 1, 0)
HintLabel.Position = UDim2.new(0.7, 8, 0, 0)
HintLabel.BackgroundTransparency = 1
HintLabel.Text = L.Hint
HintLabel.TextColor3 = Config.Theme.SubText
HintLabel.TextXAlignment = Enum.TextXAlignment.Right
HintLabel.Font = Enum.Font.Gotham
HintLabel.TextSize = math.clamp(12 * scale, 10, 14)
HintLabel.TextScaled = false

local CloseButton = Instance.new("TextButton", Header)
CloseButton.Size = UDim2.new(0, 36, 0, 28)
CloseButton.Position = UDim2.new(1, -48, 0, 12)
CloseButton.AnchorPoint = Vector2.new(0,0)
CloseButton.Text = "✕"
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = math.clamp(16 * scale, 12, 20)
CloseButton.TextColor3 = Config.Theme.Text
CloseButton.BackgroundColor3 = Color3.fromRGB(38,44,50)
CloseButton.BorderSizePixel = 0
local CloseCorner = Instance.new("UICorner", CloseButton); CloseCorner.CornerRadius = UDim.new(0,6)

-- Left tab column
local TabColumn = Instance.new("Frame", Window)
TabColumn.Size = UDim2.new(0, 140 * scale, 1, -54)
TabColumn.Position = UDim2.new(0, 0, 0, 54)
TabColumn.BackgroundTransparency = 1

local function makeTabBtn(text, y)
    local b = Instance.new("TextButton", TabColumn)
    b.Size = UDim2.new(1, -12, 0, 36)
    b.Position = UDim2.new(0, 6, 0, 12 + (y-1) * (36 + 8))
    b.Text = text
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = math.clamp(13 * scale, 11, 16)
    b.TextColor3 = Config.Theme.Text
    b.BackgroundColor3 = Color3.fromRGB(28,34,38)
    b.BorderSizePixel = 0
    local uc = Instance.new("UICorner", b); uc.CornerRadius = UDim.new(0,6)
    return b
end

local t1 = makeTabBtn("Main", 1)
local t2 = makeTabBtn("Visuals", 2)
local t3 = makeTabBtn("Advanced", 3)
local t4 = makeTabBtn("Settings", 4)

-- Right panel (content)
local Panel = Instance.new("Frame", Window)
Panel.Size = UDim2.new(1, - (140 * scale) - 16, 1, -54)
Panel.Position = UDim2.new(0, (140 * scale) + 8, 0, 54)
Panel.BackgroundTransparency = 1

local Scroll = Instance.new("ScrollingFrame", Panel)
Scroll.Size = UDim2.new(1, -12, 1, -12)
Scroll.Position = UDim2.new(0, 6, 0, 6)
Scroll.CanvasSize = UDim2.new(0,0,0,0)
Scroll.ScrollBarThickness = math.clamp(8 * scale, 6, 12)
Scroll.BackgroundTransparency = 1

local Layout = Instance.new("UIListLayout", Scroll)
Layout.Padding = UDim.new(0, 10)
Layout.SortOrder = Enum.SortOrder.LayoutOrder

-- small factory: button, toggle, slider
local function createButton(text, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, math.clamp(40 * scale, 32, 48))
    b.BackgroundColor3 = color or Config.Theme.Accent
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextColor3 = Color3.fromRGB(12,12,12)
    b.TextScaled = false
    b.TextSize = math.clamp(14 * scale, 12, 16)
    b.BorderSizePixel = 0
    local uc = Instance.new("UICorner", b); uc.CornerRadius = UDim.new(0,6)
    return b
end

local function createToggleRow(text)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, math.clamp(48 * scale,40,56))
    f.BackgroundTransparency = 1
    local lbl = Instance.new("TextLabel", f)
    lbl.Size = UDim2.new(0.68, 0, 1, 0)
    lbl.Position = UDim2.new(0, 0, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = math.clamp(14 * scale, 12, 16)
    lbl.TextColor3 = Config.Theme.Text
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local btn = Instance.new("TextButton", f)
    btn.Size = UDim2.new(0, 90 * scale, 0, math.clamp(32 * scale, 28, 40))
    btn.Position = UDim2.new(1, - (98 * scale), 0.5, - (math.clamp(16 * scale,12,18)))
    btn.Text = "OFF"
    btn.BackgroundColor3 = Config.Theme.Panel
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = math.clamp(12 * scale, 11, 14)
    btn.TextColor3 = Config.Theme.Text
    btn.BorderSizePixel = 0
    local uc2 = Instance.new("UICorner", btn); uc2.CornerRadius = UDim.new(0,6)

    return {frame=f, label=lbl, button=btn}
end

-- Build Main tab content
local btnApply = createButton(L.BoostAll)
btnApply.Parent = Scroll

local btnRestore = createButton(L.Restore, Color3.fromRGB(110,110,110))
btnRestore.Parent = Scroll

local togParticles = createToggleRow(L.Particles); togParticles.frame.Parent = Scroll
local togLights = createToggleRow(L.Lights); togLights.frame.Parent = Scroll
local togTextures = createToggleRow(L.Textures); togTextures.frame.Parent = Scroll
local togMaterials = createToggleRow(L.Materials); togMaterials.frame.Parent = Scroll
local togMesh = createToggleRow(L.Mesh); togMesh.frame.Parent = Scroll
local togPost = createToggleRow(L.Post); togPost.frame.Parent = Scroll
local togFog = createToggleRow(L.Fog); togFog.frame.Parent = Scroll
local togShadows = createToggleRow(L.Shadows); togShadows.frame.Parent = Scroll
local togFoliage = createToggleRow(L.Foliage); togFoliage.frame.Parent = Scroll
local togSounds = createToggleRow(L.Sounds); togSounds.frame.Parent = Scroll
local togAntiCrash = createToggleRow(L.AntiCrash); togAntiCrash.frame.Parent = Scroll

local btnVIP = createButton(L.VIP)
btnVIP.Parent = Scroll

local renderLabel = Instance.new("TextLabel", Scroll)
renderLabel.Size = UDim2.new(1, 0, 0, math.clamp(28 * scale,24,32))
renderLabel.BackgroundTransparency = 1
renderLabel.Text = string.format(L.RenderValue, Config.DefaultRenderDistance)
renderLabel.TextColor3 = Config.Theme.SubText
renderLabel.Font = Enum.Font.Gotham
renderLabel.TextSize = math.clamp(13 * scale,12,14)
renderLabel.Parent = Scroll

-- update canvas size helper
local function updateCanvas()
    local total = Layout.AbsoluteContentSize.Y + 24
    Scroll.CanvasSize = UDim2.new(0,0,total)
end
Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
task.defer(updateCanvas)

-- small helper to set visual toggle
local function setToggleVisual(tog, state)
    pcall(function()
        tog.button.Text = state and "ON" or "OFF"
        tog.button.BackgroundColor3 = state and Config.Theme.Accent2 or Config.Theme.Panel
        tog.label.TextColor3 = state and Config.Theme.Text or Config.Theme.Text
    end)
end

-- Bind toggle button actions (with smart delays)
local function safeToggleAction(toggleName, action)
    Toggles[toggleName] = not Toggles[toggleName]
    setToggleVisual(_G["tog_"..toggleName], Toggles[toggleName])
    task.spawn(function()
        task.wait(randDelay())
        pcall(action)
    end)
end

-- store references for easier mapping
_G.tog_disableParticles = togParticles
_G.tog_disableLights = togLights
_G.tog_hideTextures = togTextures
_G.tog_reduceMaterials = togMaterials
_G.tog_optimizeMesh = togMesh
_G.tog_disablePost = togPost
_G.tog_disableFog = togFog
_G.tog_disableShadows = togShadows
_G.tog_hideFoliage = togFoliage
_G.tog_muteSounds = togSounds
_G.tog_antiCrash = togAntiCrash

-- bind UI interactions
togParticles.button.MouseButton1Click:Connect(function()
    Toggles.disableParticles = not Toggles.disableParticles
    setToggleVisual(togParticles, Toggles.disableParticles)
    if Toggles.disableParticles then disableEmitters(workspace) end
end)

togLights.button.MouseButton1Click:Connect(function()
    Toggles.disableLights = not Toggles.disableLights
    setToggleVisual(togLights, Toggles.disableLights)
    if Toggles.disableLights then disableLights(workspace) end
end)

togTextures.button.MouseButton1Click:Connect(function()
    Toggles.hideTextures = not Toggles.hideTextures
    setToggleVisual(togTextures, Toggles.hideTextures)
    if Toggles.hideTextures then hideDecalsTextures(workspace) end
end)

togMaterials.button.MouseButton1Click:Connect(function()
    Toggles.reduceMaterials = not Toggles.reduceMaterials
    setToggleVisual(togMaterials, Toggles.reduceMaterials)
    if Toggles.reduceMaterials then reduceMaterials(workspace) end
end)

togMesh.button.MouseButton1Click:Connect(function()
    Toggles.optimizeMesh = not Toggles.optimizeMesh
    setToggleVisual(togMesh, Toggles.optimizeMesh)
    if Toggles.optimizeMesh then optimizeMeshParts(workspace) end
end)

togPost.button.MouseButton1Click:Connect(function()
    Toggles.disablePost = not Toggles.disablePost
    setToggleVisual(togPost, Toggles.disablePost)
    if Toggles.disablePost then disablePostProcessing() end
end)

togFog.button.MouseButton1Click:Connect(function()
    Toggles.disableFog = not Toggles.disableFog
    setToggleVisual(togFog, Toggles.disableFog)
    disableFog(Toggles.disableFog)
end)

togShadows.button.MouseButton1Click:Connect(function()
    Toggles.disableShadows = not Toggles.disableShadows
    setToggleVisual(togShadows, Toggles.disableShadows)
    disableShadows(Toggles.disableShadows)
end)

togFoliage.button.MouseButton1Click:Connect(function()
    Toggles.hideFoliage = not Toggles.hideFoliage
    setToggleVisual(togFoliage, Toggles.hideFoliage)
    if Toggles.hideFoliage then hideFoliage(workspace) end
end)

togSounds.button.MouseButton1Click:Connect(function()
    Toggles.mute = not Toggles.mute
    setToggleVisual(togSounds, Toggles.mute)
    if Toggles.mute then muteWorkspaceSounds() end
end)

togAntiCrash.button.MouseButton1Click:Connect(function()
    Toggles.antiCrash = not Toggles.antiCrash
    setToggleVisual(togAntiCrash, Toggles.antiCrash)
    if Toggles.antiCrash then startAntiCrash() else stopAntiCrash() end
end)

btnVIP.MouseButton1Click:Connect(function()
    if not Config.IsVIP then
        warn("VIP mode disabled (set Config.IsVIP = true locally to enable)")
        return
    end
    applyAggressiveSafeMode()
end)

btnApply.MouseButton1Click:Connect(function()
    applyFullSafeBoost()
end)

btnRestore.MouseButton1Click:Connect(function()
    restoreAll()
end)

-- Tabs switching visuals (simple)
local tabs = {t1,t2,t3,t4}
local panels = {} -- could add page content; for now we just highlight selected
local function selectTab(btn)
    for _,b in ipairs(tabs) do b.BackgroundColor3 = Color3.fromRGB(28,34,38) end
    btn.BackgroundColor3 = Config.Theme.Accent
end
t1.MouseButton1Click:Connect(function() selectTab(t1) end)
t2.MouseButton1Click:Connect(function() selectTab(t2) end)
t3.MouseButton1Click:Connect(function() selectTab(t3) end)
t4.MouseButton1Click:Connect(function() selectTab(t4) end)
selectTab(t1)

-- Close button
CloseButton.MouseButton1Click:Connect(function()
    UIVisible = false
    Window.Visible = false
end)

-- Drag improvements (Header)
local dragging = false
local dragStart = nil
local startPos = nil
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Window.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
Header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
RunService.Heartbeat:Connect(function()
    if not dragging or not dragInput or not dragStart or not startPos then return end
    local delta = dragInput.Position - dragStart
    Window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end)

-- Toggle UI by key
UIS.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode == Config.ToggleKey then
        UIVisible = not UIVisible
        Window.Visible = UIVisible
    end
    if inp.KeyCode == Enum.KeyCode.Left then setRenderDistance(math.max(64, (workspace.StreamingTargetRadius or Config.DefaultRenderDistance) - 32)) end
    if inp.KeyCode == Enum.KeyCode.Right then setRenderDistance(math.min(2048, (workspace.StreamingTargetRadius or Config.DefaultRenderDistance) + 32)) end
end)

-- FPS counter
local fpsLabel = Instance.new("TextLabel", ScreenGui)
fpsLabel.Size = UDim2.new(0,140,0,28)
fpsLabel.Position = UDim2.new(1, -160, 0, 8)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.TextColor3 = Config.Theme.Text
fpsLabel.TextSize = math.clamp(13 * scale, 11, 16)
fpsLabel.Text = string.format(L.FPS, 0)

local avg = 60
FPSConn = RunService.Heartbeat:Connect(function(dt)
    if dt and dt > 0 then
        local f = 1/dt
        avg = avg*0.92 + f*0.08
        fpsLabel.Text = string.format(L.FPS, math.floor(avg+0.5))
    end
end)

-- Mobile tweaks
if mobile then
    Window.Position = UDim2.new(0.02, 0, 0.06, 0)
    Window.Size = UDim2.new(0, math.floor(540 * scale), 0, math.floor(560 * scale))
    for _,obj in ipairs(Window:GetDescendants()) do
        if obj:IsA("TextButton") or obj:IsA("TextLabel") then
            pcall(function() obj.TextSize = math.clamp((obj.TextSize or 14) * 1.05, 12, 20) end)
        end
    end
end

-- ensure scroll is snappy
Scroll.MouseWheelForward:Connect(function() Scroll.CanvasPosition = Scroll.CanvasPosition - Vector2.new(0, 120) end)
Scroll.MouseWheelBackward:Connect(function() Scroll.CanvasPosition = Scroll.CanvasPosition + Vector2.new(0, 120) end)

-- final print
print("[BoostFPS Hub v2 - Linoria Dark] Loaded. Locale:", LOCALE, " VIP:", tostring(Config.IsVIP))
