--========================================================--
--=                 BOOST FPS MULTI-LANGUAGE UI          =--
--========================================================--

-- ▶ Auto language or manual
_G.BoostFPS_Lang = _G.BoostFPS_Lang or "auto"

-- ▶ Load Linoria
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua"))()

---------------------------------------------------------
-- 🔥 1. MULTI LANGUAGE SYSTEM
---------------------------------------------------------
local lang = _G.BoostFPS_Lang
if lang == "auto" then
    local sys = (game:GetService("LocalizationService").SystemLocaleId or ""):lower()
    if sys:find("vi") then lang = "vi"
    elseif sys:find("th") then lang = "th"
    elseif sys:find("id") then lang = "id"
    elseif sys:find("zh") then lang = "cn"
    elseif sys:find("ja") then lang = "jp"
    elseif sys:find("ko") then lang = "kr"
    elseif sys:find("ru") then lang = "ru"
    else lang = "en" end
end

local L = {
    ["vi"] = {
        MainTab = "Trang chính",
        Graphics = "Đồ họa",
        Extra = "Tính năng",
        About = "Thông tin",
        Boost = "Bật tối ưu FPS",
        Undo = "Gỡ tối ưu",
        Shadows = "Tắt bóng",
        Textures = "Tắt texture",
        Mesh = "Tắt mesh",
        Water = "Tắt nước",
        Particles = "Tắt hiệu ứng",
        Fog = "Tắt sương mù",
        LowGFX = "Low Graphics Mode",
        Unlock = "Unlock FPS",
        MaxFPS = "Giới hạn FPS",
        Desc = "Tối ưu game để tăng FPS",
    },

    ["en"] = {
        MainTab = "Main",
        Graphics = "Graphics",
        Extra = "Extras",
        About = "About",
        Boost = "Enable FPS Boost",
        Undo = "Disable Boost",
        Shadows = "Disable Shadows",
        Textures = "Remove Textures",
        Mesh = "Remove Mesh",
        Water = "Remove Water",
        Particles = "Disable Particles",
        Fog = "Remove Fog",
        LowGFX = "Low Graphics Mode",
        Unlock = "Unlock FPS",
        MaxFPS = "FPS Limit",
        Desc = "Optimize graphics to increase FPS",
    },

    ["th"] = {
        MainTab = "หน้าแรก",
        Graphics = "กราฟิก",
        Extra = "เพิ่มเติม",
        About = "เกี่ยวกับ",
        Boost = "เพิ่ม FPS",
        Undo = "ปิด Boost",
        Shadows = "ปิดเงา",
        Textures = "ลบ texture",
        Mesh = "ลบ mesh",
        Water = "ปิดน้ำ",
        Particles = "ปิดเอฟเฟกต์",
        Fog = "ลบหมอก",
        LowGFX = "โหมดกราฟิกต่ำ",
        Unlock = "ปลดล็อก FPS",
        MaxFPS = "จำกัด FPS",
        Desc = "เพิ่ม FPS โดยลดกราฟิก",
    },

    ["id"] = {
        MainTab = "Menu",
        Graphics = "Grafik",
        Extra = "Ekstra",
        About = "Tentang",
        Boost = "Aktifkan Boost FPS",
        Undo = "Matikan Boost",
        Shadows = "Nonaktifkan Shadows",
        Textures = "Hapus Texture",
        Mesh = "Hapus Mesh",
        Water = "Nonaktifkan Air",
        Particles = "Nonaktifkan Partikel",
        Fog = "Hapus Kabut",
        LowGFX = "Mode Grafik Rendah",
        Unlock = "Unlock FPS",
        MaxFPS = "Limit FPS",
        Desc = "Optimalkan grafik untuk FPS lebih tinggi",
    }
}

L = L[lang] or L["en"]

---------------------------------------------------------
-- 🔥 2. UI WINDOW
---------------------------------------------------------
local Window = Library:CreateWindow({
    Title = "Boost FPS | "..L.Desc,
    Center = true,
    AutoShow = true,
})

---------------------------------------------------------
-- 🔥 3. TABS
---------------------------------------------------------
local TabMain = Window:AddTab(L.MainTab)
local TabGraphics = Window:AddTab(L.Graphics)
local TabExtra = Window:AddTab(L.Extra)
local TabAbout = Window:AddTab(L.About)

---------------------------------------------------------
-- 🔥 4. MAIN TAB – BOOST BUTTONS
---------------------------------------------------------
local MainGroup = TabMain:AddLeftGroupbox(L.MainTab)

MainGroup:AddButton(L.Boost, function()
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    game.Lighting.GlobalShadows = false
    game.Lighting.EnvironmentDiffuseScale = 0
    game.Lighting.EnvironmentSpecularScale = 0
end)

MainGroup:AddButton(L.Undo, function()
    settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
    game.Lighting.GlobalShadows = true
    game.Lighting.EnvironmentDiffuseScale = 1
    game.Lighting.EnvironmentSpecularScale = 1
end)

---------------------------------------------------------
-- 🔥 5. GRAPHICS TAB – NHIỀU CHỨC NĂNG
---------------------------------------------------------
local gfx = TabGraphics:AddLeftGroupbox("Graphics Options")

gfx:AddToggle(L.Shadows, { Default = false, Callback = function(v)
    game.Lighting.GlobalShadows = not v
end })

gfx:AddToggle(L.Textures, { Default = false, Callback = function(v)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Texture") or obj:IsA("Decal") then
            obj.Transparency = v and 1 or 0
        end
    end
end })

gfx:AddToggle(L.Mesh, { Default = false, Callback = function(v)
    for _, m in ipairs(workspace:GetDescendants()) do
        if m:IsA("MeshPart") then
            m.TextureID = v and "" or m.TextureID
        end
    end
end })

gfx:AddToggle(L.Water, { Default = false, Callback = function(v)
    game.Lighting.WaterTransparency = v and 1 or 0
end })

gfx:AddToggle(L.Particles, { Default = false, Callback = function(v)
    for _, p in ipairs(workspace:GetDescendants()) do
        if p:IsA("ParticleEmitter") then
            p.Enabled = not v
        end
    end
end })

gfx:AddToggle(L.Fog, { Default = false, Callback = function(v)
    if v then
        game.Lighting.FogEnd = 9e9
    else
        game.Lighting.FogEnd = 200
    end
end })

gfx:AddToggle(L.LowGFX, { Default = false, Callback = function(v)
    if v then
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    else
        settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
    end
end })

---------------------------------------------------------
-- 🔥 6. EXTRA TAB
---------------------------------------------------------
local extra = TabExtra:AddLeftGroupbox(L.Extra)

extra:AddToggle(L.Unlock, { Default = true, Callback = function(v)
    setfpscap(v and 999 or 60)
end })

extra:AddSlider(L.MaxFPS, { Min = 30, Max = 240, Default = 60, Callback = function(v)
    setfpscap(v)
end })

---------------------------------------------------------
-- 🔥 7. ABOUT TAB
---------------------------------------------------------
local about = TabAbout:AddLeftGroupbox(L.About)
about:AddLabel("Made by kkirrune")
about:AddLabel("Multi-language UI")
about:AddLabel("Full optimization functions")

---------------------------------------------------------
-- 🔥 8. FINISH
---------------------------------------------------------
Library:Notify("BoostFPS UI Loaded!", 3)
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
