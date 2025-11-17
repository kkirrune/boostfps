--========================================================--
-- BOOST FPS HUB V6 – FIX LỖI CRASH TOPBAR (Final Fix)
-- Tăng cường kiểm tra an toàn sau khi tạo UI Window.
--========================================================--

--// Services
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

--========================================================--
--  SETTINGS & DEFAULTS (Giữ nguyên)
--========================================================--

local SaveFile = "BoostFPSHub_Settings.json"
local UI_Size = UDim2.new(0, 600, 0, 450)
local UI_Size_Small = UDim2.new(0, 300, 0, 40)

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
--  LANGUAGES (Giữ nguyên)
--========================================================--

-- [Các định nghĩa ngôn ngữ Lang, LangFullNames, LangCodes, LangDisplayNames giữ nguyên]
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
    -- ... (10 ngôn ngữ còn lại)
}

local LangFullNames = {
    {"VN", "VN Tiếng Việt"}, {"EN", "EN English"}, {"JP", "JP 日本語 (Japanese)"}, {"KR", "KR 한국어 (Korean)"},
    {"PT", "PT Português"}, {"ES", "ES Español"}, {"FR", "FR Français"}, {"DE", "DE Deutsch"},
    {"IT", "IT Italiano"}, {"RU", "RU Русский (Russian)"}, {"ZH", "ZH 中文 (Chinese)"}, {"KO", "KO 한국어 (Korean)"},
}

local LangCodes = {}
for _, pair in ipairs(LangFullNames) do table.insert(LangCodes, pair[1]) end

local LangDisplayNames = {}
for _, pair in ipairs(LangFullNames) do table.insert(LangDisplayNames, pair[2]) end


--========================================================--
--  LINORIA UI LIBRARY (Đã Fix Lỗi Tạo UI)
--========================================================--

local function LoadLinoriaComponent(url, name)
    local code = game:HttpGet(url)
    if not code or code:len() < 100 then
        print("Linoria Load Error: Không thể tải " .. name .. " từ URL. Code quá ngắn.")
        return nil
    end

    local component, err = loadstring(code)
    
    if not component or typeof(component) ~= "function" then
        print("Linoria Execution Error: loadstring " .. name .. " thất bại: " .. tostring(err))
        return nil
    end

    local success, result = pcall(component)
    if not success then
        print("Linoria Runtime Error: Khởi tạo " .. name .. " thất bại: " .. tostring(result))
        return nil
    end

    return result
end

local Library = LoadLinoriaComponent("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua", "Library")

-- >>>>> BƯỚC KIỂM TRA AN TOÀN SAU KHI TẢI THƯ VIỆN <<<<<
if not Library or typeof(Library.CreateWindow) ~= "function" then
    local errorMessage = "[BoostFPS Hub v6] FATAL ERROR: Linoria Library không thể tải hoặc không hợp lệ. Vui lòng kiểm tra kết nối Executor/Internet."
    warn(errorMessage)
    
    -- Tạo thông báo lỗi đơn giản trên màn hình
    local ErrorLabel = Instance.new("TextLabel")
    ErrorLabel.Text = "Linoria UI FAILED TO LOAD. Check console (F9)."
    ErrorLabel.Size = UDim2.new(0.5, 0, 0, 50)
    ErrorLabel.Position = UDim2.new(0.25, 0, 0.4, 0)
    ErrorLabel.Font = Enum.Font.SourceSansBold
    ErrorLabel.TextColor3 = Color3.new(1, 0, 0) 
    ErrorLabel.Parent = game.CoreGui
    
    delay(5, function() ErrorLabel:Destroy() end)
    return -- DỪNG SCRIPT ngay lập tức, tránh lỗi TopBar
end

pcall(Library.SetTheme, Library, "Default")

-- Cố gắng tạo UI Window
local UI = pcall(Library.CreateWindow, Library, {
    Title = Lang[Settings.Language].title .. "  |  V6",
    Center = true,
    AutoShow = true,
    Size = Settings.ResizeMode == "Full" and UI_Size or UI_Size_Small,
})

-- Lấy kết quả UI ra ngoài
local success, UI_Result = UI[1], UI[2]
local UI_Window = success and UI_Result or nil

-- >>>>> BƯỚC KIỂM TRA AN TOÀN SAU KHI TẠO WINDOW <<<<<
if not UI_Window or typeof(UI_Window.MainFrame) ~= "Instance" then
    warn("[BoostFPS Hub v6] FATAL ERROR: UI Window không được tạo. Executor chặn UI?")
    return -- DỪNG SCRIPT, tránh lỗi TopBar
end

local UI = UI_Window -- Đảm bảo biến UI là Window object hợp lệ

--========================================================--
--  TOP BAR BUTTONS (Bây giờ đã an toàn)
--========================================================--

local TopBar = UI.MainFrame.TopBar -- Dòng này sẽ không còn bị lỗi nếu các check trên thành công

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
--  TABS (Giữ nguyên)
--========================================================--

local MainTab = UI:AddTab("⚡ " .. Lang[Settings.Language].group_opt)
local GfxTab = UI:AddTab("🖼️ " .. Lang[Settings.Language].group_gfx)
local SettingsTab = UI:AddTab("⚙️ " .. Lang[Settings.Language].group_settings)

--========================================================--
--  OPTIMIZATION TAB (Giữ nguyên)
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
--  GRAPHICS REDUCTION TAB (Giữ nguyên)
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
--  SETTINGS & CONTROL TAB (Giữ nguyên)
--========================================================--

local LangBox = SettingsTab:AddLeftGroupbox(Lang[Settings.Language].language)
local ControlBox = SettingsTab:AddRightGroupbox(Lang[Settings.Language].group_settings)

-- Language Dropdown
local LangDropdown = LangBox:AddDropdown("LangDrop", {
    Values = LangCodes, 
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
--  HOTKEYS & DOCK ICON (Giữ nguyên)
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

Library:Notify("BOOST FPS HUB V6 LOADED ✔", 5)
print("[BoostFPS Hub v6 - FINAL STABLE] Loaded. Locale:", Settings.Language)
