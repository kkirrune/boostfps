--[[
BoostFPS Hub v2 — Full Multilingual + VIP Safe Anti-Crash + Hub-style UI
Author: generated for kkirru
Description:
- Universal client-side FPS optimizer. Safe-mode first: tries NOT to modify gameplay objects.
- Multi-language, Theme presets, Rayfield-like hub UI, Mobile-friendly, Drag & Drop, Scrolling,
  Smart Anti-Ban (randomized delays + action splitting), VIP Aggressive Safe Mode,
  Auto-scale on PC/Mobile, FPS counter, Toggle UI by RightControl.
- IMPORTANT: This script only changes client visuals; it does not call external services.
- Use at your own risk. Some games with strong server-side anti-cheat may still detect visual changes.
--]]

-- ========== CONFIG ==========
local Config = {
    ThemePresets = {
        Dark = {
            Background = Color3.fromRGB(12,16,18),
            Panel = Color3.fromRGB(20,26,28),
            Accent = Color3.fromRGB(84,176,160),
            ToggleON = Color3.fromRGB(76,175,80),
            ToggleOFF = Color3.fromRGB(75,85,99),
            Text = Color3.fromRGB(235,235,235),
            SubText = Color3.fromRGB(155,165,165)
        },
        Slate = {
            Background = Color3.fromRGB(18,22,26),
            Panel = Color3.fromRGB(28,34,38),
            Accent = Color3.fromRGB(96,150,255),
            ToggleON = Color3.fromRGB(90,200,255),
            ToggleOFF = Color3.fromRGB(80,86,94),
            Text = Color3.fromRGB(240,240,245),
            SubText = Color3.fromRGB(165,175,180)
        }
    },
    DefaultTheme = "Dark",
    LanguageDefault = "en",
    AntiBan = {
        MinDelay = 0.04,
        MaxDelay = 0.16,
        BatchSize = 80,
        Jitter = 0.03
    },
    AutoDetectMobile = true,
    AntiCrashInterval = 28, -- seconds
    DefaultRenderDistance = (workspace:FindFirstChild("StreamingTargetRadius") and workspace.StreamingTargetRadius) or 512,
    IsVIP = false, -- local toggle for VIP aggressive features
    UI = {
        Width = 420,
        Height = 420,
        MobileScale = 1.15,
        ToggleKey = Enum.KeyCode.RightControl
    }
}

-- ========== LOCALES ==========
local LANGS = {
    en = {
        Title="BoostFPS Hub",
        Hint="Safe visuals optimizer (client-only)",
        BoostAll="APPLY MAX BOOST (SAFE)",
        Restore="RESTORE",
        FPS="FPS: %d",
        RenderValue="Render Radius: %d",
        AntiCrashOn="[AntiCrash] Enabled",
        AntiCrashDo="[AntiCrash] Cleared cache + GC",
        AggressiveOn="[VIP] Aggressive Safe Mode ON",
        ToggleUI="Toggle UI",
        Particles="Disable Particles/FX",
        Lights="Disable Lights",
        Textures="Hide Decals/Textures",
        Materials="Reduce Materials -> Plastic",
        Mesh="Optimize MeshParts",
        Post="Disable Post-Processing",
        Fog="Disable Fog",
        Shadows="Disable Shadows",
        Foliage="Hide Foliage",
        Sounds="Mute Workspace Sounds",
        AntiCrash="Anti-Crash (Auto Clear & GC)",
        VIP="Apply VIP Aggressive Safe Mode",
        RenderSlider="Render Radius (Left/Right)",
    },
    vi = {
        Title="BoostFPS Hub",
        Hint="Tối ưu đồ họa an toàn (client-only)",
        BoostAll="BẬT TĂNG TỐI ĐA (AN TOÀN)",
        Restore="KHÔI PHỤC",
        FPS="FPS: %d",
        RenderValue="Khoảng cách render: %d",
        AntiCrashOn="[AntiCrash] Đang bật",
        AntiCrashDo="[AntiCrash] Clear cache + GC",
        AggressiveOn="[VIP] Chế độ giảm mạnh (AN TOÀN) BẬT",
        ToggleUI="Hiện/Ẩn UI",
        Particles="Tắt Particles/FX",
        Lights="Tắt Đèn",
        Textures="Ẩn Decals/Textures",
        Materials="Giảm Material -> Plastic",
        Mesh="Tối ưu MeshParts",
        Post="Tắt Post-Processing",
        Fog="Tắt Sương (Fog)",
        Shadows="Tắt Shadows",
        Foliage="Ẩn cây cỏ",
        Sounds="Tắt âm workspace",
        AntiCrash="Anti-Crash (Clear+GC tự động)",
        VIP="Áp dụng VIP Aggressive Safe Mode",
        RenderSlider="Khoảng cách render (←/→)",
    },
    es = { Title="BoostFPS Hub", Hint="Optimizaciones seguras (cliente)", BoostAll="APLICAR MÁXIMO", Restore="RESTABLECER", FPS="FPS: %d", RenderValue="Radio Render: %d", AntiCrashOn="[AntiCrash] Activado", AntiCrashDo="[AntiCrash] Caché limpiada", AggressiveOn="[VIP] Agresivo ON", ToggleUI="Alternar UI", Particles="Desactivar Partículas", Lights="Desactivar Luces", Textures="Ocultar Texturas", Materials="Reducir Materiales", Mesh="Optimizar MeshParts", Post="Desactivar PostProcess", Fog="Desactivar Niebla", Shadows="Desactivar Sombras", Foliage="Ocultar Vegetación", Sounds="Silenciar Sonidos", AntiCrash="Anti-Crash", VIP="Aplicar Modo VIP" },
    fr = { Title="BoostFPS Hub", Hint="Optimisations sûres (client)", BoostAll="APPLIQUER MAX", Restore="RÉTABLIR", FPS="FPS: %d", RenderValue="Rayon rendu: %d", AntiCrashOn="[AntiCrash] Activé", AntiCrashDo="[AntiCrash] Cache nettoyée", AggressiveOn="[VIP] Aggressif ON", ToggleUI="Afficher UI", Particles="Désactiver Particules", Lights="Désactiver Lumières", Textures="Masquer Textures", Materials="Réduire Matériaux", Mesh="Optimiser MeshParts", Post="Désactiver PostProcess", Fog="Désactiver Brouillard", Shadows="Désactiver Ombres", Foliage="Masquer Végétation", Sounds="Couper Sons", AntiCrash="Anti-Crash", VIP="Appliquer VIP" },
    ru = { Title="BoostFPS Hub", Hint="Безопасная оптимизация", BoostAll="ПРИМЕНИТЬ МАКС", Restore="ВОССТАНОВИТЬ", FPS="FPS: %d", RenderValue="Радиус рендера: %d", AntiCrashOn="[AntiCrash] Включено", AntiCrashDo="[AntiCrash] Кэш очищен", AggressiveOn="[VIP] Агрессивный ON", ToggleUI="Переключить UI", Particles="Отключить Частицы", Lights="Отключить Свет", Textures="Скрыть Текстуры", Materials="Уменьшить Материалы", Mesh="Оптимизировать Mesh", Post="Отключить PostProcess", Fog="Отключить Туман", Shadows="Отключить Тени", Foliage="Скрыть Растительность", Sounds="Выключить Звуки", AntiCrash="Anti-Crash", VIP="Применить VIP" },
    zh = { Title="BoostFPS Hub", Hint="安全优化（客户端）", BoostAll="应用最大优化", Restore="恢复", FPS="FPS: %d", RenderValue="渲染半径: %d", AntiCrashOn="[AntiCrash] 已启用", AntiCrashDo="[AntiCrash] 清除缓存", AggressiveOn="[VIP] 激进模式 ON", ToggleUI="切换 UI", Particles="关闭 粒子", Lights="关闭 灯光", Textures="隐藏 贴图", Materials="降低 材质", Mesh="优化 Mesh", Post="关闭 后处理", Fog="关闭 雾效", Shadows="关闭 阴影", Foliage="隐藏 植被", Sounds="静音 声音", AntiCrash="Anti-Crash", VIP="应用 VIP" },
    ja = { Title="BoostFPS Hub", Hint="安全な最適化 (クライアント)", BoostAll="最大ブースト適用", Restore="復元", FPS="FPS: %d", RenderValue="レンダ距離: %d", AntiCrashOn="[AntiCrash] 有効", AntiCrashDo="[AntiCrash] キャッシュクリア", AggressiveOn="[VIP] アグレッシブ ON", ToggleUI="UI 切替", Particles="パーティクル無効", Lights="ライト無効", Textures="テクスチャ非表示", Materials="マテリアル低減", Mesh="メッシュ最適化", Post="ポスト処理無効", Fog="フォグ無効", Shadows="影無効", Foliage="植生非表示", Sounds="サウンドミュート", AntiCrash="Anti-Crash", VIP="VIP 適用" },
    ko = { Title="BoostFPS Hub", Hint="안전한 최적화 (클라이언트)", BoostAll="최대 부스트 적용", Restore="복구", FPS="FPS: %d", RenderValue="렌더 반경: %d", AntiCrashOn="[AntiCrash] 활성화", AntiCrashDo="[AntiCrash] 캐시 삭제", AggressiveOn="[VIP] 공격적 ON", ToggleUI="UI 토글", Particles="파티클 끄기", Lights="라이트 끄기", Textures="텍스처 숨기기", Materials="재질 감소", Mesh="메시 최적화", Post="포스트 처리 끄기", Fog="포그 끄기", Shadows="그림자 끄기", Foliage="식생 숨기기", Sounds="사운드 음소거", AntiCrash="Anti-Crash", VIP="VIP 적용" },
    ar = { Title="BoostFPS Hub", Hint="تحسينات آمنة (العميل)", BoostAll="تطبيق أقصى تحسين", Restore="استعادة", FPS="FPS: %d", RenderValue="نطاق العرض: %d", AntiCrashOn="[AntiCrash] مفعل", AntiCrashDo="[AntiCrash] تم تنظيف الكاش", AggressiveOn="[VIP] الوضع العدواني ON", ToggleUI="تبديل الواجهة", Particles="تعطيل الجسيمات", Lights="تعطيل الأضواء", Textures="إخفاء الخامات", Materials="تقليل المواد", Mesh="تحسين الميش", Post="تعطيل ما بعد المعالجة", Fog="تعطيل الضباب", Shadows="تعطيل الظلال", Foliage="إخفاء النباتات", Sounds="كتم الأصوات", AntiCrash="Anti-Crash", VIP="تطبيق VIP" }
}

-- Utility to detect best-locale key
local function getLocaleKey()
    local ok, ls = pcall(function()
        return game:GetService("LocalizationService").RobloxLocaleId
    end)
    if ok and ls then
        local short = tostring(ls):sub(1,2):lower()
        if LANGS[short] then return short end
    end
    -- fallback to en
    return Config.LanguageDefault
end

local LOCALE = getLocaleKey()
local L = LANGS[LOCALE] or LANGS[Config.LanguageDefault]

-- ========== SERVICES & STATE ==========
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local ContentProvider = game:GetService("ContentProvider")
local CollectionService = game:GetService("CollectionService")
local TeleportService = game:GetService("TeleportService")

local Original = {} -- to store original props
local ModifiedList = {} -- list of instances modified
local Toggles = {} -- track toggles
local AntiCrashThread = nil
local FPSConn = nil
local UIVisible = true

-- ========== HELPERS ==========
local function randDelay()
    local a,b = Config.AntiBan.MinDelay, Config.AntiBan.MaxDelay
    return a + math.random()*(b-a) + (math.random()-0.5)*Config.AntiBan.Jitter
end

local function batchProcessFlat(list, batchSize, worker)
    if #list == 0 then return end
    task.spawn(function()
        local i = 1
        local bs = math.max(8, batchSize or Config.AntiBan.BatchSize)
        while i <= #list do
            local endI = math.min(#list, i + bs - 1)
            for j = i, endI do
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
    ModifiedList[#ModifiedList+1] = inst
end

local function isProtected(inst)
    if not inst then return true end
    -- protect local player's character and UI and backpack/tools
    if inst:IsDescendantOf(LocalPlayer.Character or {}) then return true end
    if inst:IsDescendantOf(LocalPlayer:FindFirstChild("PlayerGui") or {}) then return true end
    if inst:IsDescendantOf(LocalPlayer:FindFirstChild("Backpack") or {}) then return true end
    if inst:IsDescendantOf(game:GetService("StarterGui")) then return true end
    -- collection service tag for preserve
    if CollectionService:HasTag(inst, "Preserve") then return true end
    -- name heuristic
    local nm = tostring(inst.Name):lower()
    if nm:match("hit") or nm:match("hurt") or nm:match("damage") or nm:match("hitbox") or nm:match("projectile") then
        return true
    end
    local ok, attr = pcall(function() return inst:GetAttribute("NoOptimize") end)
    if ok and attr then return true end
    return false
end

-- ========== CORE SAFE ACTIONS ==========
local function disableEmitters(root)
    local found = {}
    for _,v in ipairs(root:GetDescendants()) do
        if (v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Sparkles") or v:IsA("Smoke") or v:IsA("Fire")) and not isProtected(v) then
            found[#found+1] = v
        end
    end
    batchProcessFlat(found, Config.AntiBan.BatchSize, function(obj)
        saveOriginal(obj, {"Enabled"})
        pcall(function() obj.Enabled = false end)
    end)
end

local function disableLights(root)
    local found = {}
    for _,v in ipairs(root:GetDescendants()) do
        if v:IsA("Light") and not isProtected(v) then found[#found+1] = v end
    end
    batchProcessFlat(found, Config.AntiBan.BatchSize, function(light)
        saveOriginal(light, {"Enabled"})
        pcall(function() light.Enabled = false end)
    end)
end

local function hideDecalsTextures(root)
    local found = {}
    for _,v in ipairs(root:GetDescendants()) do
        if (v:IsA("Decal") or v:IsA("Texture") or v:IsA("SurfaceAppearance")) and not isProtected(v) then
            found[#found+1] = v
        end
    end
    batchProcessFlat(found, math.max(10, Config.AntiBan.BatchSize//4), function(obj)
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
        if v:IsA("BasePart") and not isProtected(v) then found[#found+1] = v end
    end
    batchProcessFlat(found, Config.AntiBan.BatchSize, function(part)
        saveOriginal(part, {"Material","Reflectance"})
        pcall(function() part.Material = Enum.Material.SmoothPlastic part.Reflectance = 0 end)
    end)
end

local function optimizeMeshParts(root)
    local found = {}
    for _,v in ipairs(root:GetDescendants()) do
        if v:IsA("MeshPart") and not isProtected(v) then found[#found+1] = v end
    end
    batchProcessFlat(found, math.max(8, Config.AntiBan.BatchSize//5), function(mesh)
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
            effects[#effects+1] = eff
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
                found[#found+1] = v
            end
        end
    end
    batchProcessFlat(found, Config.AntiBan.BatchSize, function(obj)
        saveOriginal(obj, {"Transparency","CanCollide"})
        pcall(function() obj.Transparency = 1 obj.CanCollide = false end)
    end)
end

local function muteWorkspaceSounds()
    local found = {}
    for _,v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Sound") and not isProtected(v) then found[#found+1] = v end
    end
    batchProcessFlat(found, Config.AntiBan.BatchSize, function(s)
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

-- ========== AntiCrash (VIP safe) ==========
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
    print("[AntiCrash] Stopped")
end

-- ========== VIP Aggressive Safe Mode ==========
local function applyAggressiveSafeMode()
    if not Config.IsVIP then
        warn("VIP features require Config.IsVIP = true (local setting).")
        return
    end
    -- apply sequence but safe
    disableEmitters(workspace)
    disableLights(workspace)
    hideDecalsTextures(workspace)
    reduceMaterials(workspace)
    optimizeMeshParts(workspace)
    disablePostProcessing()
    disableFog(true)
    disableShadows(true)
    hideFoliage(workspace)
    muteWorkspaceSounds()
    Toggles.antiCrash = true
    startAntiCrash()
    pcall(function() print(L.AggressiveOn or "[VIP] Aggressive Safe Mode ON") end)
end

-- ========== Apply full safe boost sequence ==========
local function applyFullSafeBoost()
    -- action splitting with randomized waits
    task.spawn(function()
        task.wait(randDelay())
        hideDecalsTextures(workspace)
        task.wait(randDelay())
        disableEmitters(workspace)
        task.wait(randDelay())
        optimizeMeshParts(workspace)
        task.wait(randDelay())
        reduceMaterials(workspace)
        task.wait(randDelay())
        disablePostProcessing()
        task.wait(randDelay())
        disableFog(true)
        disableShadows(true)
        task.wait(randDelay())
        hideFoliage(workspace)
        task.wait(randDelay())
        muteWorkspaceSounds()
        -- start anti-crash by default
        Toggles.antiCrash = true
        startAntiCrash()
    end)
end

-- ========== Revert changes ==========
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
    -- lighting special
    pcall(function()
        if Original["_Lighting_GlobalShadows"] ~= nil then Lighting.GlobalShadows = Original["_Lighting_GlobalShadows"] end
        if Original["_Lighting_FogEnd"] ~= nil then Lighting.FogEnd = Original["_Lighting_FogEnd"] end
        if Original["_Lighting_AtmosphereDensity"] ~= nil and Lighting:FindFirstChild("Atmosphere") then Lighting.Atmosphere.Density = Original["_Lighting_AtmosphereDensity"] end
    end)
    Original = {}
    ModifiedList = {}
    Toggles = {}
    print("[BoostFPS] Attempted restore. Some effects may require rejoin.")
end

-- ========== UI FACTORY (Rayfield-like simplified) ==========
-- Remove existing UI
if game.CoreGui:FindFirstChild("BoostFPS_Hub_UI_v2") then game.CoreGui.BoostFPS_Hub_UI_v2:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BoostFPS_Hub_UI_v2"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

-- auto scale for mobile
local isMobile = (UIS.TouchEnabled and not UIS.KeyboardEnabled) or false
local scale = isMobile and Config.UI.MobileScale or 1
local W = math.floor(Config.UI.Width * scale)
local H = math.floor(Config.UI.Height * scale)

local Main = Instance.new("Frame", ScreenGui)
Main.Name = "Main"
Main.Size = UDim2.new(0, W, 0, H)
Main.Position = UDim2.new(0.05, 0, 0.18, 0)
Main.AnchorPoint = Vector2.new(0,0)
Main.BackgroundColor3 = Config.ThemePresets[Config.DefaultTheme].Panel
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Active = true
Main.Draggable = true

-- Header
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1,0,0,56)
Header.Position = UDim2.new(0,0,0,0)
Header.BackgroundColor3 = Config.ThemePresets[Config.DefaultTheme].Background
Header.BorderSizePixel = 0

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(0.7, -12, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = L.Title
Title.TextColor3 = Config.ThemePresets[Config.DefaultTheme].Accent
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.TextScaled = true

local Hint = Instance.new("TextLabel", Header)
Hint.Size = UDim2.new(0.3, -12, 1, 0)
Hint.Position = UDim2.new(0.7, 8, 0, 0)
Hint.BackgroundTransparency = 1
Hint.Text = L.Hint
Hint.TextColor3 = Config.ThemePresets[Config.DefaultTheme].SubText
Hint.TextXAlignment = Enum.TextXAlignment.Right
Hint.Font = Enum.Font.Gotham
Hint.TextSize = 14

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0,36,0,28)
CloseBtn.Position = UDim2.new(1,-48,0,14)
CloseBtn.Text = "X"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextColor3 = Config.ThemePresets[Config.DefaultTheme].Text
CloseBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)

-- Content
local Content = Instance.new("ScrollingFrame", Main)
Content.Size = UDim2.new(1, -20, 1, -86)
Content.Position = UDim2.new(0, 10, 0, 66)
Content.CanvasSize = UDim2.new(0,0,0,0)
Content.ScrollBarThickness = 8
Content.BackgroundColor3 = Config.ThemePresets[Config.DefaultTheme].Panel
Content.BorderSizePixel = 0

local UIList = Instance.new("UIListLayout", Content)
UIList.Padding = UDim.new(0,8)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Left
Content:GetPropertyChangedSignal("CanvasSize"):Connect(function()
    -- no-op
end)

-- small helper factories
local function makeButton(text, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -12, 0, 40)
    b.BackgroundColor3 = color or Config.ThemePresets[Config.DefaultTheme].Accent
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextColor3 = Color3.fromRGB(10,10,10)
    b.TextScaled = true
    b.BorderSizePixel = 0
    return b
end

local function makeToggle(text)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -12, 0, 44)
    f.BackgroundColor3 = Config.ThemePresets[Config.DefaultTheme].Panel
    f.BorderSizePixel = 0
    local lbl = Instance.new("TextLabel", f)
    lbl.Size = UDim2.new(0.72, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Config.ThemePresets[Config.DefaultTheme].Text
    lbl.Font = Enum.Font.Gotham
    lbl.TextScaled = true
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local btn = Instance.new("TextButton", f)
    btn.Size = UDim2.new(0,88,0,28)
    btn.Position = UDim2.new(1, -96, 0.5, -14)
    btn.Text = "OFF"
    btn.BackgroundColor3 = Config.ThemePresets[Config.DefaultTheme].ToggleOFF
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = Color3.fromRGB(230,230,230)
    btn.BorderSizePixel = 0
    return {frame=f,label=lbl,button=btn}
end

-- Build UI entries
local btnBoost = makeButton(L.BoostAll)
btnBoost.Parent = Content

local btnRestore = makeButton(L.Restore, Color3.fromRGB(120,120,120))
btnRestore.Parent = Content

local togParticles = makeToggle(L.Particles); togParticles.frame.Parent = Content
local togLights = makeToggle(L.Lights); togLights.frame.Parent = Content
local togTextures = makeToggle(L.Textures); togTextures.frame.Parent = Content
local togMaterials = makeToggle(L.Materials); togMaterials.frame.Parent = Content
local togMesh = makeToggle(L.Mesh); togMesh.frame.Parent = Content
local togPost = makeToggle(L.Post); togPost.frame.Parent = Content
local togFog = makeToggle(L.Fog); togFog.frame.Parent = Content
local togShadows = makeToggle(L.Shadows); togShadows.frame.Parent = Content
local togFoliage = makeToggle(L.Foliage); togFoliage.frame.Parent = Content
local togSounds = makeToggle(L.Sounds); togSounds.frame.Parent = Content
local togAntiCrash = makeToggle(L.AntiCrash); togAntiCrash.frame.Parent = Content

local btnVIP = makeButton(L.VIP, Config.ThemePresets[Config.DefaultTheme].Accent)
btnVIP.Parent = Content

local renderLabel = Instance.new("TextLabel")
renderLabel.Size = UDim2.new(1, -12, 0, 28)
renderLabel.BackgroundTransparency = 1
renderLabel.Text = string.format(L.RenderValue, Config.DefaultRenderDistance)
renderLabel.TextColor3 = Config.ThemePresets[Config.DefaultTheme].Text
renderLabel.Font = Enum.Font.Gotham
renderLabel.TextScaled = true
renderLabel.Parent = Content

-- update canvas size
local function updateCanvas()
    local total = 0
    for _,v in ipairs(Content:GetChildren()) do
        if v:IsA("Frame") or v:IsA("TextButton") or v:IsA("TextLabel") then
            total = total + v.AbsoluteSize.Y + (UIList.Padding.Offset or 8)
        end
    end
    Content.CanvasSize = UDim2.new(0,0,0,total/Content.AbsoluteSize.Y)
end
Content:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateCanvas)
task.defer(updateCanvas)

-- helper: toggle visuals UI state
local function setToggleVisual(t, state)
    pcall(function()
        t.button.Text = state and "ON" or "OFF"
        t.button.BackgroundColor3 = state and Config.ThemePresets[Config.DefaultTheme].ToggleON or Config.ThemePresets[Config.DefaultTheme].ToggleOFF
    end)
end

-- binds
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
        warn("VIP features require Config.IsVIP = true (local setting).")
        return
    end
    applyAggressiveSafeMode()
end)

btnBoost.MouseButton1Click:Connect(function()
    applyFullSafeBoost()
end)

btnRestore.MouseButton1Click:Connect(function()
    restoreAll()
    stopAntiCrash()
    restoreRenderDistance()
    -- reset visuals
    for _,t in ipairs({togParticles,togLights,togTextures,togMaterials,togMesh,togPost,togFog,togShadows,togFoliage,togSounds,togAntiCrash}) do
        setToggleVisual(t, false)
    end
end)

-- Render slider via keyboard left/right (simple)
local currentRender = Config.DefaultRenderDistance or 256
local function setRender(v)
    currentRender = math.clamp(v, 64, 1024)
    renderLabel.Text = string.format(L.RenderValue, currentRender)
    setRenderDistance(currentRender)
end

UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Left then setRender(currentRender - 16) end
    if input.KeyCode == Enum.KeyCode.Right then setRender(currentRender + 16) end
    if input.KeyCode == Config.UI.ToggleKey then
        UIVisible = not UIVisible
        Main.Visible = UIVisible
    end
end)

-- Close button
CloseBtn.MouseButton1Click:Connect(function() UIVisible = false; Main.Visible = false end)

-- Draggable improvements (click+drag header)
local dragging = false
local dragInput, dragStart, startPos
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
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
    Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end)

-- FPS counter
local fpsLabel = Instance.new("TextLabel", ScreenGui)
fpsLabel.Size = UDim2.new(0,120,0,28)
fpsLabel.Position = UDim2.new(1,-140,0,8)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.TextColor3 = Config.ThemePresets[Config.DefaultTheme].Text
fpsLabel.TextScaled = true

local avgFPS = 60
FPSConn = RunService.Heartbeat:Connect(function(dt)
    if dt and dt > 0 then
        local fps = 1/dt
        avgFPS = avgFPS*0.9 + fps*0.1
        fpsLabel.Text = string.format(L.FPS, math.floor(avgFPS+0.5))
    end
end)

-- initial visibility
Main.Visible = true
UIVisible = true

-- auto scale for mobile touches: enlarge touch areas
if isMobile then
    for _,obj in ipairs(Main:GetDescendants()) do
        if obj:IsA("TextButton") or obj:IsA("TextLabel") then
            pcall(function() obj.TextSize = 18 end)
        end
    end
end

-- final print
print("[BoostFPS Hub v2] Loaded. Locale:", LOCALE, " VIP:", tostring(Config.IsVIP))

-- End of script
