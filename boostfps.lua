--[[ 
  BOOST FPS HUB - FULL (Linoria UI if available; fallback otherwise)
  Features:
    - Multi-language (auto detect + manual)
    - Full Linoria UI integration (if raw reachable)
    - Fallback instance UI if Linoria unavailable
    - Many toggles: Boost, Ultra, Mobile, LowPoly, LOD, Sky, Decals, Textures, Water, Particles, Lighting FX
    - Presets: Performance, Balanced, Visual
    - Hotkeys: RightShift toggle UI, Ctrl+1..3 apply presets
    - Save/Load settings (writefile/readfile when available)
    - Throttled workspace changes to avoid freezing large maps
    - SaveManager & ThemeManager support when Linoria addons present
    - Notifications
--]]

-- ============================
-- SERVICES & SAFETY
-- ============================
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Localization = game:GetService("LocalizationService")

-- Ensure LocalPlayer
local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    Players.PlayerAdded:Wait()
    LocalPlayer = Players.LocalPlayer
end

-- ============================
-- SETTINGS & IO
-- ============================
local SaveFile = "BoostFPSHub_Settings.json"
local Settings = {
    Language = "auto", -- "auto" or "vi","en","th","id","cn","jp","kr","ru"
    -- toggles
    BoostFPS = false,
    UltraBoost = false,
    MobileBoost = false,
    AutoLowPoly = false,
    DisableLOD = false,
    NoSky = false,
    NoSkillFX = false,
    NoDecals = false,
    NoTextures = false,
    NoWater = false,
    AntiBan = false,
    NoScreenGUI = false,
    NoLightingFX = false,
    FPSUnlock = false,
    -- others
    Preset = "Custom",
    MaxFPS = 60,
}

local DefaultSettings = {
    QualityLevel = (pcall(function() return settings().Rendering.QualityLevel end) and settings().Rendering.QualityLevel) or 13,
    GlobalShadows = Lighting.GlobalShadows,
    FogEnd = Lighting.FogEnd,
    Ambient = Lighting.Ambient,
}

local function safeReadFile(name)
    if type(isfile) == "function" and isfile(name) then
        local ok, raw = pcall(function() return readfile(name) end)
        if ok and type(raw) == "string" then
            local ok2, data = pcall(function() return HttpService:JSONDecode(raw) end)
            if ok2 and type(data) == "table" then return data end
        end
    end
    return nil
end
local function safeWriteFile(name, tbl)
    if type(writefile) == "function" then
        local ok, err = pcall(function()
            writefile(name, HttpService:JSONEncode(tbl))
        end)
        return ok, err
    end
    return false, "no writefile"
end

local function LoadSettings()
    local data = safeReadFile(SaveFile)
    if data then
        for k,v in pairs(data) do
            if Settings[k] ~= nil then Settings[k] = v end
        end
    end
end
local function SaveSettings()
    local ok, err = safeWriteFile(SaveFile, Settings)
    if not ok then
        -- fallback: try to store in _G (volatile)
        _G.BoostFPSHub_Settings = Settings
    end
end

LoadSettings()

-- ============================
-- MULTI-LANGUAGE
-- ============================
local function detectLang()
    local chosen = Settings.Language or "auto"
    if chosen ~= "auto" then return chosen end
    local sys = tostring(Localization.SystemLocaleId or ""):lower()
    if sys:find("vi") then return "vi"
    if sys:find("th") then return "th"
    if sys:find("id") then return "id"
    if sys:find("zh") then return "cn"
    if sys:find("ja") then return "jp"
    if sys:find("ko") then return "kr"
    if sys:find("ru") then return "ru"
    return "en"
end

local LANG_TABLE = {
    vi = {
        title = "FPS BOOST HUB",
        tab1 = "HIỆU NĂNG", tab2 = "ĐỒ HỌA", tab3 = "CÀI ĐẶT", tab4 = "THÊM",
        boost = "Tăng FPS cơ bản", ultra = "Siêu tăng vật liệu", mobile = "Chống lag di động",
        lowpoly = "Tự động đa giác thấp", disable_lod = "Tắt LOD", no_sky = "Xóa bầu trời",
        no_skill = "Giảm hiệu ứng kỹ năng", no_decals = "Xóa Decals/Logo", no_textures = "Xóa Textures",
        no_water = "Xóa nước", antiban = "Anti-Ban", noscreengui = "Ẩn GUI game", nolightingfx = "Tắt FX ánh sáng",
        fpsunlock = "Mở khóa FPS", presets = "Cài đặt sẵn", save = "Lưu cài đặt", reset = "Khôi phục mặc định",
        perf = "Chế độ hiệu năng", balanced = "Cân bằng", visual = "Đồ họa",
        notify_saved = "Đã lưu cài đặt", notify_reset = "Đã khôi phục mặc định",
        desc = "Tối ưu đồ họa để tăng FPS",
    },
    en = {
        title = "FPS BOOST HUB",
        tab1 = "PERFORMANCE", tab2 = "GRAPHICS", tab3 = "SETTINGS", tab4 = "EXTRA",
        boost = "Enable Boost", ultra = "Ultra (materials)", mobile = "Mobile Mode",
        lowpoly = "Auto Low-Poly", disable_lod = "Disable LOD", no_sky = "Remove Sky",
        no_skill = "Reduce Skill FX", no_decals = "Remove Decals/Logos", no_textures = "Remove Textures",
        no_water = "Remove Water", antiban = "Anti-Ban", noscreengui = "Hide Game GUI", nolightingfx = "Disable Lighting FX",
        fpsunlock = "Unlock FPS", presets = "Presets", save = "Save Settings", reset = "Reset Defaults",
        perf = "Performance Mode", balanced = "Balanced", visual = "Visuals",
        notify_saved = "Settings saved", notify_reset = "Defaults restored",
        desc = "Optimize graphics to increase FPS",
    },
    th = {
        title = "BOOST FPS",
        tab1 = "ประสิทธิภาพ", tab2 = "กราฟิก", tab3 = "การตั้งค่า", tab4 = "เพิ่มเติม",
        boost = "เปิด Boost", ultra = "Ultra (วัสดุ)", mobile = "โหมดมือถือ",
        lowpoly = "Low-Poly อัตโนมัติ", disable_lod = "ปิด LOD", no_sky = "ลบท้องฟ้า",
        no_skill = "ลดเอฟเฟกต์สกิล", no_decals = "ลบ Decals/โลโก้", no_textures = "ลบ Texture",
        no_water = "ปิดน้ำ", antiban = "Anti-Ban", noscreengui = "ซ่อน GUI เกม", nolightingfx = "ปิด FX แสง",
        fpsunlock = "ปลดล็อก FPS", presets = "ค่าที่ตั้งไว้", save = "บันทึก", reset = "คืนค่าเริ่มต้น",
        perf = "โหมดประสิทธิภาพ", balanced = "สมดุล", visual = "โหมดสวย",
        notify_saved = "บันทึกเรียบร้อย", notify_reset = "คืนค่าเริ่มต้นแล้ว",
        desc = "ปรับกราฟิกเพื่อเพิ่ม FPS",
    },
    id = {
        title = "BOOST FPS",
        tab1 = "PERFORMA", tab2 = "GRAFIK", tab3 = "PENGATURAN", tab4 = "LAINNYA",
        boost = "Aktifkan Boost", ultra = "Ultra (material)", mobile = "Mode Mobile",
        lowpoly = "Auto Low-Poly", disable_lod = "Matikan LOD", no_sky = "Hapus Langit",
        no_skill = "Kurangi Efek Skill", no_decals = "Hapus Decals/Logo", no_textures = "Hapus Texture",
        no_water = "Hapus Air", antiban = "Anti-Ban", noscreengui = "Sembunyikan GUI", nolightingfx = "Matikan FX Pencahayaan",
        fpsunlock = "Buka FPS", presets = "Preset", save = "Simpan", reset = "Reset Default",
        perf = "Mode Performa", balanced = "Seimbang", visual = "Visual",
        notify_saved = "Tersimpan", notify_reset = "Reset selesai",
        desc = "Optimalkan grafik untuk FPS lebih tinggi",
    },
    cn = {
        title = "提升FPS",
        tab1 = "性能", tab2 = "画面", tab3 = "设置", tab4 = "更多",
        boost = "启用加速", ultra = "超强(材质)", mobile = "手机模式",
        lowpoly = "自动低多边形", disable_lod = "禁用LOD", no_sky = "移除天空",
        no_skill = "降低技能特效", no_decals = "移除贴纸/标志", no_textures = "移除贴图",
        no_water = "移除水面", antiban = "防封", noscreengui = "隐藏GUI", nolightingfx = "禁用光效",
        fpsunlock = "解锁FPS", presets = "预设", save = "保存设置", reset = "重置默认",
        perf = "性能模式", balanced = "平衡", visual = "视觉模式",
        notify_saved = "已保存设置", notify_reset = "已恢复默认",
        desc = "优化画面以提升帧率",
    },
    jp = {
        title = "FPSブースト",
        tab1 = "パフォーマンス", tab2 = "グラフィック", tab3 = "設定", tab4 = "その他",
        boost = "ブーストON", ultra = "ウルトラ(素材)", mobile = "モバイルモード",
        lowpoly = "自動低ポリ", disable_lod = "LOD 無効", no_sky = "空を削除",
        no_skill = "スキル演出削減", no_decals = "デカール削除", no_textures = "テクスチャ削除",
        no_water = "水削除", antiban = "アンチバン", noscreengui = "GUI非表示", nolightingfx = "光効果無効",
        fpsunlock = "FPS解放", presets = "プリセット", save = "保存", reset = "デフォルトに戻す",
        perf = "パフォーマンス", balanced = "バランス", visual = "ビジュアル",
        notify_saved = "設定を保存しました", notify_reset = "デフォルトに戻しました",
        desc = "グラフィックを最適化してFPSを上げます",
    },
    kr = {
        title = "FPS 부스트",
        tab1 = "성능", tab2 = "그래픽", tab3 = "설정", tab4 = "추가",
        boost = "부스트 켜기", ultra = "울트라(재질)", mobile = "모바일 모드",
        lowpoly = "자동 로우폴리", disable_lod = "LOD 비활성화", no_sky = "하늘 제거",
        no_skill = "스킬 이펙트 감소", no_decals = "데칼 제거", no_textures = "텍스처 제거",
        no_water = "물 제거", antiban = "안티밴", noscreengui = "GUI 숨기기", nolightingfx = "조명 FX 끄기",
        fpsunlock = "FPS 해제", presets = "프리셋", save = "저장", reset = "초기화",
        perf = "퍼포먼스", balanced = "균형", visual = "시각",
        notify_saved = "설정 저장됨", notify_reset = "초기화 완료",
        desc = "그래픽 최적화로 FPS 향상",
    },
    ru = {
        title = "Ускоритель FPS",
        tab1 = "ПРОИЗВОДИТ.", tab2 = "ГРАФИКА", tab3 = "НАСТРОЙКИ", tab4 = "ДОП.",
        boost = "Включить ускорение", ultra = "Ультра (материалы)", mobile = "Мобильный режим",
        lowpoly = "Авто низкополигон", disable_lod = "Отключить LOD", no_sky = "Убрать небо",
        no_skill = "Уменьшить эффекты", no_decals = "Убрать стикеры", no_textures = "Убрать текстуры",
        no_water = "Убрать воду", antiban = "Анти-бан", noscreengui = "Скрыть GUI", nolightingfx = "Откл. свет. эффекты",
        fpsunlock = "Разблокировать FPS", presets = "Пресеты", save = "Сохранить", reset = "Сбросить",
        perf = "Режим производительности", balanced = "Баланс", visual = "Визуал",
        notify_saved = "Настройки сохранены", notify_reset = "Сброшено по-умолчанию",
        desc = "Оптимизация графики для повышения FPS",
    },
}

local LANG = LANG_TABLE[detectLang()] or LANG_TABLE["en"]

-- ============================
-- CORE BOOST LOGIC (with throttling)
-- ============================
local function applyToWorkspace(action, batchSize)
    -- action(obj) - called for each desc, batchSize controls yield frequency
    batchSize = batchSize or 200
    local count = 0
    local descendants = workspace:GetDescendants()
    for _, obj in ipairs(descendants) do
        pcall(function() action(obj) end)
        count = count + 1
        if count % batchSize == 0 then
            -- yield a frame to avoid freezing
            RunService.Heartbeat:Wait()
        end
    end
end

local function ApplyBoost()
    -- BOOST FPS: interpolation throttling & streaming
    if Settings.BoostFPS then
        pcall(sethiddenproperty, workspace, "InterpolationThrottling", Enum.InterpolationThrottlingMode.Disabled)
        workspace.StreamingEnabled = true
    else
        workspace.StreamingEnabled = false
    end

    -- ULTRA BOOST: materials and render fidelity
    if Settings.UltraBoost then
        applyToWorkspace(function(part)
            if part:IsA("MeshPart") then
                pcall(function() part.RenderFidelity = Enum.RenderFidelity.Performance end)
            end
            if part:IsA("BasePart") then
                pcall(function() part.Material = Enum.Material.SmoothPlastic end)
            end
        end, 250)
    end

    -- MOBILE BOOST
    if Settings.MobileBoost then
        pcall(function() settings().Rendering.QualityLevel = 1 end)
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 200
    else
        pcall(function() settings().Rendering.QualityLevel = DefaultSettings.QualityLevel end)
        Lighting.GlobalShadows = DefaultSettings.GlobalShadows
        Lighting.FogEnd = DefaultSettings.FogEnd
    end

    -- LOW POLY
    if Settings.AutoLowPoly then
        applyToWorkspace(function(a)
            if a:IsA("UnionOperation") then
                pcall(function() a.CollisionFidelity = Enum.CollisionFidelity.Box end)
            end
        end, 300)
    end

    -- LOD
    pcall(sethiddenproperty, settings().Rendering, "EnableLevelOfDetail", not Settings.DisableLOD)

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

    -- DECALS / TEXTURES
    applyToWorkspace(function(obj)
        if obj:IsA("Decal") then obj.Transparency = Settings.NoDecals and 1 or 0 end
        if obj:IsA("Texture") then obj.Transparency = Settings.NoTextures and 1 or 0 end
    end, 400)

    -- WATER (Terrain)
    local terr = workspace:FindFirstChildOfClass("Terrain")
    if terr then
        terr.WaterWaveSize = Settings.NoWater and 0 or 1
        terr.WaterWaveSpeed = Settings.NoWater and 0 or 1
        terr.WaterTransparency = Settings.NoWater and 1 or 0.5
        terr.WaterReflectance = Settings.NoWater and 1 or 0.5
    end

    -- SCRIPT HIDING (anti-ban toggle; use caution)
    pcall(function()
        local sc = game:GetService("ScriptContext")
        pcall(sethiddenproperty, sc, "ScriptsDisabled", Settings.AntiBan)
        pcall(sethiddenproperty, sc, "ScriptsHidden", Settings.AntiBan)
    end)

    -- PLAYER GUI hide
    if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") then
        local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
        for _, gui in ipairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Name ~= "BoostFPSHub_Main" then
                pcall(function() gui.Enabled = not Settings.NoScreenGUI end)
            end
        end
    end

    -- Lighting FX
    for _, fx in ipairs(Lighting:GetChildren()) do
        if fx:IsA("BloomEffect") or fx:IsA("ColorCorrectionEffect") or fx:IsA("DepthOfFieldEffect") or fx:IsA("SunRaysEffect") then
            fx.Enabled = not Settings.NoLightingFX
        end
    end

    -- PARTICLE/Trail handler (descendant)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
            obj.Enabled = not Settings.NoSkillFX
            if Settings.NoSkillFX then
                pcall(function()
                    obj.Transparency = NumberSequence.new(0.8)
                    obj.Lifetime = NumberRange.new(0.1)
                end)
            end
        end
    end

    -- FPS unlock
    if Settings.FPSUnlock then
        if type(setfpscap) == "function" then pcall(setfpscap, 999) end
        pcall(function() RunService.PreferredClientFPS = 999 end)
        pcall(function() RunService:SetFpsCap(999) end)
    else
        if type(setfpscap) == "function" then pcall(setfpscap, Settings.MaxFPS or 60) end
        pcall(function() RunService.PreferredClientFPS = Settings.MaxFPS or 60 end)
        pcall(function() RunService:SetFpsCap(Settings.MaxFPS or 60) end)
    end
end

-- Descendant added handler for FX
workspace.DescendantAdded:Connect(function(obj)
    pcall(function()
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
            obj.Enabled = not Settings.NoSkillFX
        end
    end)
end)

-- Initial apply
pcall(ApplyBoost)

-- ============================
-- PRESETS
-- ============================
local function ApplyPreset(name)
    if name == "Performance" then
        Settings.BoostFPS = true
        Settings.UltraBoost = true
        Settings.MobileBoost = true
        Settings.AutoLowPoly = true
        Settings.DisableLOD = true
        Settings.NoSky = true
        Settings.NoSkillFX = true
        Settings.NoDecals = true
        Settings.NoTextures = true
        Settings.NoWater = true
        Settings.NoLightingFX = true
        Settings.FPSUnlock = true
        Settings.MaxFPS = 999
    elseif name == "Balanced" then
        Settings.BoostFPS = true
        Settings.UltraBoost = false
        Settings.MobileBoost = true
        Settings.AutoLowPoly = false
        Settings.DisableLOD = false
        Settings.NoSky = false
        Settings.NoSkillFX = false
        Settings.NoDecals = false
        Settings.NoTextures = false
        Settings.NoWater = false
        Settings.NoLightingFX = false
        Settings.FPSUnlock = false
        Settings.MaxFPS = 120
    elseif name == "Visual" then
        Settings.BoostFPS = false
        Settings.UltraBoost = false
        Settings.MobileBoost = false
        Settings.AutoLowPoly = false
        Settings.DisableLOD = false
        Settings.NoSky = false
        Settings.NoSkillFX = false
        Settings.NoDecals = false
        Settings.NoTextures = false
        Settings.NoWater = false
        Settings.NoLightingFX = false
        Settings.FPSUnlock = false
        Settings.MaxFPS = 60
    end
    Settings.Preset = name
    SaveSettings()
    ApplyBoost()
end

-- ============================
-- TRY LOAD LINORIA (multiple known repos)
-- ============================
local function TryLoad(url)
    local ok, res = pcall(function() return game:HttpGet(url) end)
    if ok and type(res) == "string" and #res > 50 then
        local ok2, lib = pcall(function() return loadstring(res)() end)
        if ok2 and type(lib) == "table" then
            return lib
        end
    end
    return nil
end

local linoriaCandidates = {
    "https://raw.githubusercontent.com/17kShots/linoria-lib/main/Library.lua",
    "https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua",
    "https://raw.githubusercontent.com/ObiWanDuck/Linoria/main/Library.lua",
    "https://raw.githubusercontent.com/Desudo/DesudoHub/main/Source/Libs/Linoria/Library.lua",
    -- Add more known raw URLs if you have a preferred mirror
}
local LinoriaLib, ThemeManager, SaveManager = nil, nil, nil
for _, url in ipairs(linoriaCandidates) do
    local lib = TryLoad(url)
    if lib then
        LinoriaLib = lib
        -- try to load addons from the same upstream if possible (best-effort)
        local base = url:gsub("Library.lua","")
        ThemeManager = TryLoad(base .. "addons/ThemeManager.lua") or ThemeManager
        SaveManager = TryLoad(base .. "addons/SaveManager.lua") or SaveManager
        break
    end
end

-- ============================
-- UI BUILD (Linoria if available, else fallback minimal)
-- ============================
local UI = {}
local function Notify(txt, t)
    t = t or 3
    if LinoriaLib and LinoriaLib:Notify then
        pcall(function() LinoriaLib:Notify({Title = "BoostFPS", Description = tostring(txt), Duration = t}) end)
    else
        -- simple print fallback
        warn("[BoostFPS] "..tostring(txt))
    end
end

if LinoriaLib then
    local Library = LinoriaLib
    local Window = Library:CreateWindow({
        Title = LANG.title.." - "..(LANG.desc or ""),
        Center = true,
        AutoShow = true,
    })

    -- create tabs
    local TabPerf = Window:AddTab(LANG.tab1)
    local TabGfx = Window:AddTab(LANG.tab2)
    local TabSet = Window:AddTab(LANG.tab3)
    local TabExtra = Window:AddTab(LANG.tab4)

    -- Performance tab
    do
        local left = TabPerf:AddLeftGroupbox(LANG.perf)
        left:AddToggle("BoostFPS", { Text = LANG.boost, Default = Settings.BoostFPS, Tooltip = "Main boost toggle", Callback = function(v) Settings.BoostFPS = v SaveSettings() ApplyBoost() end })
        left:AddToggle("UltraBoost", { Text = LANG.ultra, Default = Settings.UltraBoost, Callback = function(v) Settings.UltraBoost = v SaveSettings() ApplyBoost() end })
        left:AddToggle("MobileBoost", { Text = LANG.mobile, Default = Settings.MobileBoost, Callback = function(v) Settings.MobileBoost = v SaveSettings() ApplyBoost() end })
        left:AddToggle("AutoLowPoly", { Text = LANG.lowpoly, Default = Settings.AutoLowPoly, Callback = function(v) Settings.AutoLowPoly = v SaveSettings() ApplyBoost() end })
        left:AddToggle("FPSUnlock", { Text = LANG.fpsunlock, Default = Settings.FPSUnlock, Callback = function(v) Settings.FPSUnlock = v SaveSettings() ApplyBoost() end })
        left:AddSlider("MaxFPS", { Text = "Max FPS", Default = Settings.MaxFPS or 60, Min = 30, Max = 999, Float = 0, Callback = function(v) Settings.MaxFPS = math.floor(v) SaveSettings() ApplyBoost() end })
        left:AddDropdown("Presets", { Text = LANG.presets, Default = Settings.Preset or "Custom", Options = {"Performance","Balanced","Visual","Custom"}, Callback = function(v) if v ~= "Custom" then ApplyPreset(v) end end })
    end

    -- Graphics tab
    do
        local left = TabGfx:AddLeftGroupbox(LANG.tab2)
        left:AddToggle("DisableLOD", { Text = LANG.disable_lod, Default = Settings.DisableLOD, Callback = function(v) Settings.DisableLOD = v SaveSettings() ApplyBoost() end })
        left:AddToggle("NoSky", { Text = LANG.no_sky, Default = Settings.NoSky, Callback = function(v) Settings.NoSky = v SaveSettings() ApplyBoost() end })
        left:AddToggle("NoSkillFX", { Text = LANG.no_skill, Default = Settings.NoSkillFX, Callback = function(v) Settings.NoSkillFX = v SaveSettings() ApplyBoost() end })
        left:AddToggle("NoDecals", { Text = LANG.no_decals, Default = Settings.NoDecals, Callback = function(v) Settings.NoDecals = v SaveSettings() ApplyBoost() end })
        left:AddToggle("NoTextures", { Text = LANG.no_textures, Default = Settings.NoTextures, Callback = function(v) Settings.NoTextures = v SaveSettings() ApplyBoost() end })
        left:AddToggle("NoWater", { Text = LANG.no_water, Default = Settings.NoWater, Callback = function(v) Settings.NoWater = v SaveSettings() ApplyBoost() end })
        left:AddToggle("NoLightingFX", { Text = LANG.nolightingfx, Default = Settings.NoLightingFX, Callback = function(v) Settings.NoLightingFX = v SaveSettings() ApplyBoost() end })
        left:AddToggle("NoScreenGUI", { Text = LANG.noscreengui, Default = Settings.NoScreenGUI, Callback = function(v) Settings.NoScreenGUI = v SaveSettings() ApplyBoost() end })
    end

    -- Settings tab
    do
        local left = TabSet:AddLeftGroupbox(LANG.tab3)
        left:AddButton(LANG.save, function() SaveSettings() Notify(LANG.notify_saved) end)
        left:AddButton(LANG.reset, function()
            for k,_ in pairs(Settings) do
                if k ~= "Language" then Settings[k] = false end
            end
            Settings.MaxFPS = 60
            Settings.Preset = "Custom"
            Settings.Language = "auto"
            SaveSettings()
            ApplyBoost()
            Notify(LANG.notify_reset)
        end)
        if SaveManager then
            SaveManager:SetLibrary(Library)
            SaveManager:IgnoreThemeSettings()
            SaveManager:SetIgnoreIndexes({})
            SaveManager:BuildConfigSection(TabSet)
        end
        if ThemeManager then
            ThemeManager:SetLibrary(Library)
            ThemeManager:ApplyToTab(TabSet)
        end
    end

    -- Extra tab
    do
        local left = TabExtra:AddLeftGroupbox(LANG.tab4)
        left:AddLabel("Hotkeys: RightShift to toggle UI. Ctrl + 1/2/3 apply presets.")
        left:AddButton("Apply Performance Preset (Ctrl+1)", function() ApplyPreset("Performance") Notify("Applied Performance") end)
        left:AddButton("Apply Balanced Preset (Ctrl+2)", function() ApplyPreset("Balanced") Notify("Applied Balanced") end)
        left:AddButton("Apply Visual Preset (Ctrl+3)", function() ApplyPreset("Visual") Notify("Applied Visual") end)
    end

    -- Save current state to UI (helpful)
    if SaveManager then
        SaveManager:BuildConfigSection(TabSet)
    end

    -- store UI reference for hotkeys toggle
    UI.Window = Window

    print("[BoostFPSHub] Linoria UI loaded.")
else
    -- FALLBACK BUILD (simple, robust)
    local function BuildFallbackUI()
        -- create ScreenGui + Panel with essential toggles (kept compact)
        local sg = Instance.new("ScreenGui")
        sg.Name = "BoostFPSHub_Main"
        sg.Parent = CoreGui
        sg.ResetOnSpawn = false

        local frame = Instance.new("Frame", sg)
        frame.Name = "Main"
        frame.AnchorPoint = Vector2.new(0.5,0.5)
        frame.Position = UDim2.new(0.5,0.5,0.5,0)
        frame.Size = UDim2.new(0,420,0,380)
        frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
        frame.BorderSizePixel = 0

        local title = Instance.new("TextLabel", frame)
        title.Size = UDim2.new(1,0,0,30)
        title.Position = UDim2.new(0,0,0,0)
        title.BackgroundTransparency = 1
        title.Text = LANG.title
        title.Font = Enum.Font.GothamBold
        title.TextSize = 16
        title.TextColor3 = Color3.fromRGB(230,230,230)
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.TextYAlignment = Enum.TextYAlignment.Center
        title.Padding = nil

        local y = 36
        local function addToggle(labelText, key)
            local lbl = Instance.new("TextLabel", frame)
            lbl.Size = UDim2.new(0.68,0,0,24)
            lbl.Position = UDim2.new(0,12,0,y)
            lbl.BackgroundTransparency = 1
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 14
            lbl.TextColor3 = Color3.fromRGB(220,220,220)
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Text = labelText

            local btn = Instance.new("TextButton", frame)
            btn.Size = UDim2.new(0.28, -12, 0, 22)
            btn.Position = UDim2.new(0.72, 0, 0, y+1)
            btn.AutoButtonColor = true
            btn.Text = Settings[key] and "ON" or "OFF"
            btn.BackgroundColor3 = Settings[key] and Color3.fromRGB(0,150,140) or Color3.fromRGB(80,80,80)
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 14
            btn.TextColor3 = Color3.fromRGB(255,255,255)

            btn.MouseButton1Click:Connect(function()
                Settings[key] = not Settings[key]
                btn.Text = Settings[key] and "ON" or "OFF"
                btn.BackgroundColor3 = Settings[key] and Color3.fromRGB(0,150,140) or Color3.fromRGB(80,80,80)
                SaveSettings()
                ApplyBoost()
            end)
            y = y + 30
            return btn
        end

        addToggle(LANG.boost, "BoostFPS")
        addToggle(LANG.ultra, "UltraBoost")
        addToggle(LANG.mobile, "MobileBoost")
        addToggle(LANG.lowpoly, "AutoLowPoly")
        addToggle(LANG.disable_lod, "DisableLOD")
        addToggle(LANG.no_sky, "NoSky")
        addToggle(LANG.no_skill, "NoSkillFX")
        addToggle(LANG.no_decals, "NoDecals")
        addToggle(LANG.no_textures, "NoTextures")
        addToggle(LANG.no_water, "NoWater")

        -- Save & Reset buttons
        local saveBtn = Instance.new("TextButton", frame)
        saveBtn.Size = UDim2.new(0.46, -8, 0, 28)
        saveBtn.Position = UDim2.new(0.05, 0, 1, -36)
        saveBtn.Text = LANG.save
        saveBtn.BackgroundColor3 = Color3.fromRGB(0,150,200)
        saveBtn.Font = Enum.Font.GothamBold
        saveBtn.TextColor3 = Color3.fromRGB(255,255,255)
        saveBtn.MouseButton1Click:Connect(function() SaveSettings() Notify(LANG.notify_saved) end)

        local resetBtn = Instance.new("TextButton", frame)
        resetBtn.Size = UDim2.new(0.46, -8, 0, 28)
        resetBtn.Position = UDim2.new(0.5, 0, 1, -36)
        resetBtn.Text = LANG.reset
        resetBtn.BackgroundColor3 = Color3.fromRGB(200,60,60)
        resetBtn.Font = Enum.Font.GothamBold
        resetBtn.TextColor3 = Color3.fromRGB(255,255,255)
        resetBtn.MouseButton1Click:Connect(function()
            for k,_ in pairs(Settings) do
                if k ~= "Language" then Settings[k] = false end
            end
            Settings.MaxFPS = 60
            SaveSettings()
            ApplyBoost()
            Notify(LANG.notify_reset)
        end)
    end

    BuildFallbackUI()
    print("[BoostFPSHub] Linoria not found; fallback UI created.")
end

-- ============================
-- HOTKEYS
-- ============================
-- RightShift toggles Linoria Window (or fallback: toggles ScreenGui)
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        if LinoriaLib and UI and UI.Window then
            pcall(function() UI.Window:Toggle() end)
        else
            -- try to toggle fallback ScreenGui
            local sg = CoreGui:FindFirstChild("BoostFPSHub_Main")
            if sg then sg.Enabled = not sg.Enabled end
        end
    end
    -- Ctrl + 1/2/3 shortcuts
    if input.KeyCode == Enum.KeyCode.One and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or input.KeyCode == Enum.KeyCode.One and UserInputService:IsKeyDown(Enum.KeyCode.RightControl) then
        ApplyPreset("Performance")
        Notify("Preset: Performance")
    end
    if input.KeyCode == Enum.KeyCode.Two and (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)) then
        ApplyPreset("Balanced")
        Notify("Preset: Balanced")
    end
    if input.KeyCode == Enum.KeyCode.Three and (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)) then
        ApplyPreset("Visual")
        Notify("Preset: Visual")
    end
end)

-- ============================
-- AUTO APPLY ON JOIN (if saved)
-- ============================
-- Re-apply when respawn/character load to keep player GUI changes
Players.PlayerAdded:Connect(function(pl)
    if pl == LocalPlayer then
        pcall(ApplyBoost)
    end
end)
-- Also re-apply periodically to catch new objects (gentle)
spawn(function()
    while true do
        wait(30)
        pcall(ApplyBoost)
    end
end)

-- Final
print("[BoostFPSHub] Loaded. Language:", detectLang())
Notify("BoostFPS Hub loaded ("..(LANG.desc or "")..")", 3)

-- End of script
