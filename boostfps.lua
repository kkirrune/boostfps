--========================================================--
-- BOOST FPS HUB V5 – MAX FEATURE UPGRADE (Sửa lỗi Ngôn ngữ)
-- Hỗ trợ 12 Ngôn ngữ • Anti-Ban • Advanced GFX Reduction
--========================================================--

--// Services
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

--========================================================--
--  SETTINGS & DEFAULTS
--========================================================--

local SaveFile = "BoostFPSHub_Settings.json"
local UI_Size = UDim2.new(0, 600, 0, 450) -- Kích thước lớn mặc định
local UI_Size_Small = UDim2.new(0, 300, 0, 40) -- Kích thước nhỏ

local Settings = {
    Language = "VN",
    BoostFPS = false,
    UltraBoost = false,
    MobileBoost = false,
    AutoLowPoly = false,
    DisableLOD = false,
    NoSky = false,
    NoSkillFX = false,
    CustomCursor = false,
    NoDecals = false,
    NoTextures = false,
    NoWater = false,
    AntiBan = false,
    ResizeMode = "Full",
}

local DefaultSettings = {
    QualityLevel = settings().Rendering.QualityLevel,
    GlobalShadows = Lighting.GlobalShadows,
    FogEnd = Lighting.FogEnd,
    Ambient = Lighting.Ambient,
}

local function LoadSettings()
    if isfile(SaveFile) then
        local ok, data = pcall(function()
            return HttpService:JSONDecode(readfile(SaveFile))
        end)
        if ok and type(data) == "table" then
            for k,v in pairs(data) do 
                if Settings[k] ~= nil then Settings[k] = v end
            end
        end
    end
end

local function SaveSettings()
    writefile(SaveFile, HttpService:JSONEncode(Settings))
end

LoadSettings()

--========================================================--
--  LANGUAGES (Hỗ trợ MAX 12 - Hiển thị Tên đầy đủ)
--========================================================--

local Lang = {
    ["VN"] = {
        title = "TĂNG TỐC FPS HUB", group_opt = "Tối Ưu Hiệu Năng", group_gfx = "Giảm Đồ Họa Nâng Cao", group_settings = "Cài Đặt & Điều Khiển",
        boost = "Tăng FPS Cơ Bản", ultra = "Siêu Tăng Tốc (Vật liệu)", mobile = "Chống Lag Di Động (Bóng/Sương mù)", lowpoly = "Tự động Đa giác Thấp",
        disable_lod = "Tắt LOD (Render mọi thứ)", no_sky = "Xóa Bầu Trời & Mặt trời", no_skill = "Giảm Hiệu ứng Kỹ năng/Vệt",
        no_decals = "Xóa Decals & Logos", no_textures = "Xóa Textures/Mô hình", no_water = "Xóa Nước & Sóng",
        antiban = "Anti-Banwave (Experimental)", language = "Ngôn ngữ", cursor = "Đổi Hình Dạng Chuột", mode = "Chế Độ Hiệu Năng Tối Đa",
    },
    ["EN"] = {
        title = "FPS BOOST HUB", group_opt = "Performance Optimization", group_gfx = "Advanced GFX Reduction", group_settings = "Settings & Control",
        boost = "Boost FPS (Basic)", ultra = "Ultra Boost (Materials/Mesh)", mobile = "Mobile Anti-Lag (Shadows/Fog)", lowpoly = "Auto Low Poly (Unions)",
        disable_lod = "Disable LOD (Render All)", no_sky = "Remove Sky & Sun", no_skill = "Reduce Skill VFX/Trails",
        no_decals = "Remove Decals & Logos", no_textures = "Remove Textures/Models", no_water = "Remove Water & Waves",
        antiban = "Anti-Banwave (Experimental)", language = "Language", cursor = "Custom Cursor", mode = "Max Performance Mode",
    },
    ["JP"] = {
        title = "FPS高速化ハブ", group_opt = "パフォーマンス最適化", group_gfx = "高度なグラフィック", group_settings = "設定と制御",
        boost = "基本FPSブースト", ultra = "ウルトラブースト", mobile = "モバイル最適化", lowpoly = "低ポリ自動化",
        disable_lod = "LODを無効化", no_sky = "空と太陽を削除", no_skill = "スキルVFXを削減",
        no_decals = "デカールを削除", no_textures = "テクスチャを削除", no_water = "水を削除",
        antiban = "アンチバンウェーブ", language = "言語", cursor = "カスタムカーソル", mode = "最大パフォーマンスモード",
    },
    ["KR"] = {
        title = "FPS 향상 허브", group_opt = "성능 최적화", group_gfx = "고급 그래픽 감소", group_settings = "설정 및 제어",
        boost = "기본 FPS 향상", ultra = "울트라 부스트", mobile = "모바일 최적화", lowpoly = "저폴리 자동",
        disable_lod = "LOD 비활성화", no_sky = "하늘 및 태양 제거", no_skill = "스킬 VFX 감소",
        no_decals = "데칼 제거", no_textures = "텍스처 제거", no_water = "물 및 파도 제거",
        antiban = "안티밴 웨이브", language = "언어", cursor = "사용자 지정 커서", mode = "최대 성능 모드",
    },
    ["PT"] = {
        title = "HUB DE FPS BOOST", group_opt = "Otimização de Desempenho", group_gfx = "Redução Gráfica Avançada", group_settings = "Configurações e Controle",
        boost = "FPS Básico", ultra = "Ultra Boost", mobile = "Anti-Lag Móvel", lowpoly = "Baixo Polígono Automático",
        disable_lod = "Desativar LOD", no_sky = "Remover Céu e Sol", no_skill = "Reduzir VFX/Trilhas de Habilidade",
        no_decals = "Remover Decais", no_textures = "Remover Texturas", no_water = "Remover Água e Ondas",
        antiban = "Anti-Banwave", language = "Idioma", cursor = "Cursor Personalizado", mode = "Modo de Desempenho Máximo",
    },
    ["ES"] = {
        title = "HUB DE FPS", group_opt = "Optimización de Rendimiento", group_gfx = "Reducción Gráfica", group_settings = "Configuración y Control",
        boost = "FPS Básico", ultra = "Ultra Boost", mobile = "Anti-Lag Móvil", lowpoly = "Bajo Polígono Auto",
        disable_lod = "Desactivar LOD", no_sky = "Eliminar Cielo y Sol", no_skill = "Reducir VFX/Rastros de Habilidad",
        no_decals = "Eliminar Calcomanías", no_textures = "Eliminar Texturas", no_water = "Eliminar Agua y Olas",
        antiban = "Anti-Banwave", language = "Idioma", cursor = "Cursor Personalizado", mode = "Modo de Rendimiento Máximo",
    },
    ["FR"] = {
        title = "HUB FPS", group_opt = "Optimisation", group_gfx = "Réduction Graphique", group_settings = "Paramètres et Contrôle",
        boost = "FPS de Base", ultra = "Ultra Boost", mobile = "Anti-Lag Mobile", lowpoly = "Faible Poly Auto",
        disable_lod = "Désactiver LOD", no_sky = "Supprimer Ciel et Soleil", no_skill = "Réduire VFX/Traces de Compétences",
        no_decals = "Supprimer les Décalcomanies", no_textures = "Supprimer les Textures", no_water = "Supprimer l'Eau et les Vagues",
        antiban = "Anti-Banwave", language = "Langue", cursor = "Curseur Personnalisé", mode = "Mode Performance Max",
    },
    ["DE"] = {
        title = "FPS HUB", group_opt = "Leistungsoptimierung", group_gfx = "Erweiterte Grafikreduzierung", group_settings = "Einstellungen & Steuerung",
        boost = "Basis-FPS", ultra = "Ultra Boost", mobile = "Mobiler Anti-Lag", lowpoly = "Auto Low Poly",
        disable_lod = "LOD deaktivieren", no_sky = "Himmel & Sonne entfernen", no_skill = "Skill VFX reduzieren",
        no_decals = "Decals entfernen", no_textures = "Texturen entfernen", no_water = "Wasser & Wellen entfernen",
        antiban = "Anti-Banwave", language = "Sprache", cursor = "Benutzerdefinierter Cursor", mode = "Maximaler Leistungsmodus",
    },
    ["IT"] = {
        title = "HUB FPS", group_opt = "Ottimizzazione delle Prestazioni", group_gfx = "Riduzione Grafica Avanzata", group_settings = "Impostazioni e Controllo",
        boost = "FPS Base", ultra = "Ultra Boost", mobile = "Anti-Lag Mobile", lowpoly = "Bassa Poligonale Automatica",
        disable_lod = "Disabilita LOD", no_sky = "Rimuovi Cielo e Sole", no_skill = "Riduci VFX Abilità",
        no_decals = "Rimuovi Decalcomanie", no_textures = "Rimuovi Texture", no_water = "Rimuovi Acqua e Onde",
        antiban = "Anti-Banwave", language = "Lingua", cursor = "Cursore Personalizzato", mode = "Modalità Prestazioni Massime",
    },
    ["RU"] = {
        title = "FPS ХАБ", group_opt = "Оптимизация Производительности", group_gfx = "Продвинутое Снижение Графики", group_settings = "Настройки и Управление",
        boost = "Базовый FPS", ultra = "Ультра Ускорение", mobile = "Мобильный Анти-Лаг", lowpoly = "Авто Низкополигональность",
        disable_lod = "Отключить LOD", no_sky = "Удалить Небо и Солнце", no_skill = "Уменьшить Эффекты Навыков",
        no_decals = "Удалить Декали", no_textures = "Удалить Текстуры", no_water = "Удалить Воду и Волны",
        antiban = "Анти-Бан", language = "Язык", cursor = "Пользовательский Курсор", mode = "Максимальная Производительность",
    },
    ["ZH"] = {
        title = "FPS HUB", group_opt = "性能优化", group_gfx = "高级图形减少", group_settings = "设置和控制",
        boost = "基础 FPS", ultra = "超级加速", mobile = "移动防卡顿", lowpoly = "自动低多边形",
        disable_lod = "禁用 LOD", no_sky = "移除天空和太阳", no_skill = "减少技能特效",
        no_decals = "移除贴花", no_textures = "移除纹理", no_water = "移除水和波浪",
        antiban = "防封禁", language = "语言", cursor = "自定义光标", mode = "最大性能模式",
    },
    ["KO"] = {
        title = "FPS 허브", group_opt = "성능 최적화", group_gfx = "고급 그래픽 감소", group_settings = "설정 및 제어",
        boost = "기본 FPS 부스트", ultra = "울트라 부스트", mobile = "모바일 안티-랙", lowpoly = "저폴리 자동",
        disable_lod = "LOD 비활성화", no_sky = "하늘 및 태양 제거", no_skill = "스킬 VFX 감소",
        no_decals = "데칼 제거", no_textures = "텍스처 제거", no_water = "물 및 파도 제거",
        antiban = "안티-밴", language = "언어", cursor = "사용자 지정 커서", mode = "최대 성능 모드",
    },
}

-- Mảng chứa cả Code và Tên đầy đủ để hiển thị trong Dropdown
local LangFullNames = {
    {"VN", "VN Tiếng Việt"},
    {"EN", "EN English"},
    {"JP", "JP 日本語 (Japanese)"},
    {"KR", "KR 한국어 (Korean)"},
    {"PT", "PT Português"},
    {"ES", "ES Español"},
    {"FR", "FR Français"},
    {"DE", "DE Deutsch"},
    {"IT", "IT Italiano"},
    {"RU", "RU Русский (Russian)"},
    {"ZH", "ZH 中文 (Chinese)"},
    {"KO", "KO 한국어 (Korean)"},
}

-- Mảng Values cho Dropdown (Chỉ chứa Code)
local LangCodes = {}
for _, pair in ipairs(LangFullNames) do
    table.insert(LangCodes, pair[1])
end

-- Mảng hiển thị (Sẽ được dùng để thay thế Values mặc định của Linoria)
local LangDisplayNames = {}
for _, pair in ipairs(LangFullNames) do
    table.insert(LangDisplayNames, pair[2])
end

--========================================================--
--  LINORIA UI LIBRARY (FIXED LOAD)
--========================================================--

local function LoadLinoriaComponent(url, name)
    local code = game:HttpGet(url)
    if not code or code:len() < 100 then
        print("Linoria Load Error: Không thể tải " .. name .. " từ URL.")
        return nil
    end

    local component, err = loadstring(code)
    
    if not component or typeof(component) ~= "function" then
        print("Linoria Execution Error: loadstring " .. name .. " thất bại: " .. tostring(err))
        return nil
    end

    return component() 
end

local Library = LoadLinoriaComponent("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua", "Library")

if not Library then
    print("[BoostFPS Hub v5] FATAL ERROR: Linoria Library không thể tải. Script dừng lại.")
    return
end

pcall(Library.SetTheme, Library, "Default")

local UI = Library:CreateWindow({
    Title = Lang[Settings.Language].title .. "  |  V5",
    Center = true,
    AutoShow = true,
    Size = Settings.ResizeMode == "Full" and UI_Size or UI_Size_Small,
})

--========================================================--
--  TOP BAR BUTTONS (CLOSE, RESIZE, MINIMIZE)
--========================================================--

local TopBar = UI.MainFrame.TopBar

-- Nút Đóng (X)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = TopBar
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 30, 1, 0)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextColor3 = Color3.new(1, 1, 1)

CloseBtn.MouseButton1Click:Connect(function()
    UI.MainFrame.Visible = false
end)

-- Nút Resize (Toggle Full/Compact)
local ResizeBtn = Instance.new("TextButton")
ResizeBtn.Parent = TopBar
ResizeBtn.Text = Settings.ResizeMode == "Full" and "S" or "L" 
ResizeBtn.Size = UDim2.new(0, 30, 1, 0)
ResizeBtn.Position = UDim2.new(1, -60, 0, 0)
ResizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ResizeBtn.Font = Enum.Font.SourceSansBold
ResizeBtn.TextColor3 = Color3.new(1, 1, 1)

local function SetResizeMode(mode)
    Settings.ResizeMode = mode
    SaveSettings()
    local targetSize = mode == "Full" and UI_Size or UDim2.new(0, 300, 0, 40)
    
    TweenService:Create(UI.MainFrame, TweenInfo.new(.3), {Size = targetSize}):Play()
    ResizeBtn.Text = mode == "Full" and "S" or "L" 
    
    -- Ẩn/hiện nội dung khi chuyển sang Compact/Full
    for _,child in pairs(UI.MainFrame:GetChildren()) do
        if child:IsA("Frame") and child.Name ~= "TopBar" then
            child.Visible = (mode == "Full")
        end
    end
end

ResizeBtn.MouseButton1Click:Connect(function()
    if Settings.ResizeMode == "Full" then
        SetResizeMode("Compact")
    else
        SetResizeMode("Full")
    end
end)

--========================================================--
--  TABS
--========================================================--

local MainTab = UI:AddTab("⚡ " .. Lang[Settings.Language].group_opt)
local GfxTab = UI:AddTab("🖼️ " .. Lang[Settings.Language].group_gfx)
local SettingsTab = UI:AddTab("⚙️ " .. Lang[Settings.Language].group_settings)

--========================================================--
--  OPTIMIZATION TAB
--========================================================--

local OptSec = MainTab:AddLeftGroupbox(Lang[Settings.Language].group_opt)
local SecuritySec = MainTab:AddRightGroupbox("Security") 

-- Anti-Ban
SecuritySec:AddToggle("AntiBan", {
    Text = Lang[Settings.Language].antiban,
    Default = Settings.AntiBan,
    Callback = function(v)
        Settings.AntiBan = v
        SaveSettings()
        if v then
            pcall(sethiddenproperty, game:GetService("ScriptContext"), "ScriptsDisabled", true)
            pcall(sethiddenproperty, game:GetService("ScriptContext"), "ScriptsHidden", true)
        else
            pcall(sethiddenproperty, game:GetService("ScriptContext"), "ScriptsDisabled", false)
            pcall(sethiddenproperty, game:GetService("ScriptContext"), "ScriptsHidden", false)
        end
    end
})

-- Core Boosts
OptSec:AddToggle("BoostFPS", {
    Text = Lang[Settings.Language].boost,
    Default = Settings.BoostFPS,
    Callback = function(v)
        Settings.BoostFPS = v
        SaveSettings()
        if v then
            pcall(sethiddenproperty, workspace, "InterpolationThrottling", Enum.InterpolationThrottlingMode.Disabled)
            workspace.StreamingEnabled = true
        else
            workspace.StreamingEnabled = false
        end
    end
})

OptSec:AddToggle("UltraBoost", {
    Text = Lang[Settings.Language].ultra,
    Default = Settings.UltraBoost,
    Callback = function(v)
        Settings.UltraBoost = v
        SaveSettings()
        if v then
            for _,part in pairs(workspace:GetDescendants()) do
                if part:IsA("MeshPart") then part.RenderFidelity = Enum.RenderFidelity.Performance end
                if part:IsA("BasePart") then part.Material = Enum.Material.SmoothPlastic end
            end
        end
    end
})

OptSec:AddToggle("MobileBoost", {
    Text = Lang[Settings.Language].mobile,
    Default = Settings.MobileBoost,
    Callback = function(v)
        Settings.MobileBoost = v
        SaveSettings()
        if v then
            settings().Rendering.QualityLevel = 1
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 200
        else
            settings().Rendering.QualityLevel = DefaultSettings.QualityLevel
            Lighting.GlobalShadows = DefaultSettings.GlobalShadows
            Lighting.FogEnd = DefaultSettings.FogEnd
        end
    end
})

OptSec:AddToggle("LowPoly", {
    Text = Lang[Settings.Language].lowpoly,
    Default = Settings.AutoLowPoly,
    Callback = function(v)
        Settings.AutoLowPoly = v
        SaveSettings()
        if v then
            for _,a in pairs(workspace:GetDescendants()) do
                if a:IsA("UnionOperation") then a.CollisionFidelity = Enum.CollisionFidelity.Box end
            end
        end
    end
})

OptSec:AddButton(Lang[Settings.Language].mode, function()
    settings().Rendering.QualityLevel = 1
    Lighting.GlobalShadows = false
    Library:Notify("Applied Max Performance Mode!", 3)
end)

--========================================================--
--  GRAPHICS REDUCTION TAB
--========================================================--

local GfxReductionSec = GfxTab:AddLeftGroupbox(Lang[Settings.Language].group_gfx)
local AntiFXSec = GfxTab:AddRightGroupbox("Anti-FX")

-- Water
GfxReductionSec:AddToggle("NoWater", {
    Text = Lang[Settings.Language].no_water,
    Default = Settings.NoWater,
    Callback = function(v)
        Settings.NoWater = v
        SaveSettings()
        local Water = workspace:FindFirstChildOfClass("Terrain")
        if Water then
            Water.WaterWaveSize = v and 0 or 1
            Water.WaterWaveSpeed = v and 0 or 1
            Water.WaterTransparency = v and 1 or 0.5
            Water.WaterReflectance = v and 1 or 0.5
        end
    end
})

-- Textures
GfxReductionSec:AddToggle("NoTextures", {
    Text = Lang[Settings.Language].no_textures,
    Default = Settings.NoTextures,
    Callback = function(v)
        Settings.NoTextures = v
        SaveSettings()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Texture") or obj:IsA("WeldConstraint") then 
                obj.Transparency = v and 1 or 0
            end
        end
    end
})

-- Decals
GfxReductionSec:AddToggle("NoDecals", {
    Text = Lang[Settings.Language].no_decals,
    Default = Settings.NoDecals,
    Callback = function(v)
        Settings.NoDecals = v
        SaveSettings()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Decal") or obj:IsA("BillboardGui") then
                obj.Transparency = v and 1 or 0
            end
        end
    end
})

-- Sky/Sun
GfxReductionSec:AddToggle("NoSky", {
    Text = Lang[Settings.Language].no_sky,
    Default = Settings.NoSky,
    Callback = function(v)
        Settings.NoSky = v
        SaveSettings()
        if v then
            local Sky = Lighting:FindFirstChildOfClass("Sky")
            if Sky then Sky.Parent = nil end
            Lighting.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
            Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
        else
            Lighting.OutdoorAmbient = DefaultSettings.Ambient
            Lighting.Ambient = DefaultSettings.Ambient
        end
    end
})

-- LOD
GfxReductionSec:AddToggle("DisableLOD", {
    Text = Lang[Settings.Language].disable_lod,
    Default = Settings.DisableLOD,
    Callback = function(v)
        Settings.DisableLOD = v
        SaveSettings()
        if v then
            pcall(sethiddenproperty, settings().Rendering, "EnableLevelOfDetail", false)
        else
            pcall(sethiddenproperty, settings().Rendering, "EnableLevelOfDetail", true)
        end
    end
})

-- Skill FX
AntiFXSec:AddToggle("NoSkillFX", {
    Text = Lang[Settings.Language].no_skill,
    Default = Settings.NoSkillFX,
    Callback = function(v)
        Settings.NoSkillFX = v
        SaveSettings()
        local function SetFX(obj)
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                obj.Enabled = not v
                if v then
                    obj.Transparency = NumberRange.new(0.8) 
                    obj.Lifetime = NumberRange.new(0.1)
                else
                    obj.Transparency = NumberRange.new(0)
                    obj.Lifetime = NumberRange.new(5)
                end
            end
        end
        for _,obj in pairs(workspace:GetDescendants()) do
            SetFX(obj)
        end
        workspace.DescendantAdded:Connect(SetFX)
    end
})

--========================================================--
--  SETTINGS & CONTROL TAB
--========================================================--

local LangBox = SettingsTab:AddLeftGroupbox(Lang[Settings.Language].language)
local ControlBox = SettingsTab:AddRightGroupbox(Lang[Settings.Language].group_settings)

-- Language Dropdown (Đã chỉnh sửa để hiển thị Tên đầy đủ)
local LangDropdown = LangBox:AddDropdown("LangDrop", {
    Values = LangCodes, -- Dùng Code để lưu trong Settings
    Default = Settings.Language,
    Text = Lang[Settings.Language].language,
    Callback = function(v)
        Settings.Language = v
        SaveSettings()
        Library:Notify("Language will update next reopen/re-execute.", 5)
    end
})

local function UpdateDropdownDisplay()
    local codes = LangDropdown.Values 
    local names = LangDisplayNames
    
    local newItems = {}
    for i, code in ipairs(codes) do
        local fullName = names[i] or code
        newItems[i] = fullName 
    end
    
    LangDropdown.Items = newItems
    
    -- Đặt lại giá trị mặc định dựa trên tên đầy đủ
    for i, code in ipairs(LangCodes) do
        if code == Settings.Language then
            LangDropdown:SetValue(LangDisplayNames[i])
            break
        end
    end
end

UpdateDropdownDisplay()


-- Custom Cursor
ControlBox:AddToggle("CustomCursor", {
    Text = Lang[Settings.Language].cursor,
    Default = Settings.CustomCursor,
    Callback = function(v)
        Settings.CustomCursor = v
        SaveSettings()
        local mouse = Players.LocalPlayer:GetMouse()
        if v then
            mouse.Icon = "rbxassetid://632558611"
        else
            mouse.Icon = "" 
        end
    end
})

--========================================================--
--  HOTKEYS & DOCK ICON
--========================================================--

-- HIDE UI WITH RIGHTSHIFT
UserInputService.InputBegan:Connect(function(k,t)
    if not t and k.KeyCode == Enum.KeyCode.RightShift then
        UI.MainFrame.Visible = not UI.MainFrame.Visible
    end
end)

-- DOCK ICON
local Dock = Instance.new("ImageButton")
Dock.Parent = game.CoreGui
Dock.Size = UDim2.new(0,60,0,60)
Dock.Position = UDim2.new(0,20,0.5,-30)
Dock.Image = "rbxassetid://3926305904"
Dock.ImageRectOffset = Vector2.new(4,4)
Dock.ImageRectSize = Vector2.new(36,36)

Dock.MouseButton1Click:Connect(function()
    UI.MainFrame.Visible = not UI.MainFrame.Visible
end)

--========================================================--
--  END
--========================================================--

-- Áp dụng chế độ Compact nếu đã lưu
if Settings.ResizeMode == "Compact" then
    SetResizeMode("Compact")
end

Library:Notify("BOOST FPS HUB V5 LOADED ✔", 5)
print("[BoostFPS Hub v5 - MAX FEATURES] Loaded. Locale:", Settings.Language)
