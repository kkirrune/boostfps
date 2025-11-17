--========================================================--
-- BOOST FPS HUB V3 – Premium Linoria UI (FINAL FIX: ROBUST LOAD)
--========================================================--

--// Services
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

--========================================================--
--  SETTINGS FILE (AUTO SAVE)
--========================================================--

local SaveFile = "BoostFPSHub_Settings.json"

local Settings = {
    Language = "EN",
    Theme = "Blue",
    BoostFPS = false,
    AutoLowPoly = false,
    MobileBoost = false,
    UltraBoost = false,
}

-- Lưu trữ các giá trị mặc định để hoàn tác (Revert) an toàn
local DefaultSettings = {
    QualityLevel = settings().Rendering.QualityLevel,
    GlobalShadows = Lighting.GlobalShadows,
    FogEnd = Lighting.FogEnd,
}

local function LoadSettings()
    if isfile(SaveFile) then
        local ok, data = pcall(function()
            return HttpService:JSONDecode(readfile(SaveFile))
        end)
        if ok and type(data) == "table" then
            for k,v in pairs(data) do Settings[k] = v end
        end
    end
end

local function SaveSettings()
    writefile(SaveFile, HttpService:JSONEncode(Settings))
end

LoadSettings()

-- Hàm phụ trợ để áp dụng Theme đã lưu (cần được định nghĩa sau khi Library được tải)
local ApplyTheme
local ThemingEnabled = false -- Biến kiểm soát xem Theming có hoạt động không

--========================================================--
--  LANGUAGES
--========================================================--

local Lang = {
    ["EN"] = {
        title = "BOOST FPS HUB",
        boost = "Boost FPS",
        ultra = "Ultra Boost",
        mobile = "Mobile Anti-Lag",
        lowpoly = "Auto Low Poly",
        theme = "UI Theme",
        language = "Language",
        fpstitle = "FPS Monitor",
        mode = "FPS Turbo Mode",
        minimize = "Minimize UI",
    },
    ["JP"] = {
        title = "FPS高速化ハブ",
        boost = "FPSブースト",
        ultra = "ウルトラブースト",
        mobile = "モバイル最適化",
        lowpoly = "低ポリ自動化",
        theme = "UIテーマ",
        language = "言語",
        fpstitle = "FPSモニター",
        mode = "ターボFPS",
        minimize = "UIを縮小",
    },
    ["KR"] = {
        title = "FPS 향상 허브",
        boost = "FPS 향상",
        ultra = "울트라 부ースト",
        mobile = "모바일 최적화",
        lowpoly = "저폴리 자동",
        theme = "UI 테마",
        language = "언어",
        fpstitle = "FPS 모니터",
        mode = "터보 FPS",
        minimize = "UI 최소화",
    },
}

--========================================================--
--  LINORIA UI LIBRARY (BUILT-IN) - SỬA LỖI TẢI
--========================================================--

-- Hàm tải an toàn
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

-- 1. Tải thư viện chính (BẮT BUỘC)
local Library = LoadLinoriaComponent("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua", "Library")

-- Kiểm tra nếu thư viện chính tải thất bại và dừng script
if not Library then
    print("[BoostFPS Hub v3] FATAL ERROR: Linoria Library không thể tải. Script dừng lại.")
    return
end

-- 2. Tải ThemeManager (TÙY CHỌN)
local ThemeManager = LoadLinoriaComponent("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Addons/ThemeManager.lua", "ThemeManager")

if ThemeManager then
    ThemingEnabled = true -- Nếu tải thành công, bật Theming
else
    print("[BoostFPS Hub v3] Warning: ThemeManager failed to load. Tính năng đổi Theme sẽ bị tắt.")
end

-- (Đã xóa SaveManager vì không cần thiết)

-- Hàm ApplyTheme giờ đã được BẢO VỆ
ApplyTheme = function(themeName)
    if not ThemingEnabled then return end -- KHÔNG LÀM GÌ CẢ NẾU THEME BỊ TẮT

    -- pcall để an toàn tuyệt đối
    pcall(function()
        if themeName == "Blue" then Library:SetTheme("Default") end
        if themeName == "Red" then Library:SetTheme("Discord") end
        if themeName == "Pink" then Library:SetTheme("Fatality") end
    end)
end

-- Áp dụng theme đã lưu (An toàn)
ApplyTheme(Settings.Theme) -- Dòng 135 cũ, giờ đã an toàn

local UI = Library:CreateWindow({
    Title = Lang[Settings.Language].title .. "  |  V3",
    Center = true,
    AutoShow = true,
})

--========================================================--
--  TABS
--========================================================--

local MainTab = UI:AddTab("⚡ Boost")
local SettingsTab = UI:AddTab("⚙ Settings")
local FPSTab = UI:AddTab("📊 FPS")

--========================================================--
--  BOOST TAB
--========================================================--

local BoostSec = MainTab:AddLeftGroupbox("Optimization")

BoostSec:AddToggle("BoostFPS", {
    Text = Lang[Settings.Language].boost,
    Default = Settings.BoostFPS,
    Callback = function(v)
        Settings.BoostFPS = v
        SaveSettings()

        if v then
            pcall(sethiddenproperty, workspace, "InterpolationThrottling", Enum.InterpolationThrottlingMode.Disabled)
            workspace.StreamingEnabled = true

            for _,obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                    obj.Lifetime = NumberRange.new(0)
                end
            end
        else
            workspace.StreamingEnabled = false
        end
    end
})

BoostSec:AddToggle("UltraBoost", {
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

BoostSec:AddToggle("MobileBoost", {
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

BoostSec:AddToggle("LowPoly", {
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

--========================================================--
--  FPS TAB
--========================================================--

local FPSBox = FPSTab:AddLeftGroupbox("FPS Monitor")

local fps = 0
local lastTick = tick()
local lastUpdate = tick()

local fpsLabel = FPSBox:AddLabel("FPS: 0")

RunService.Heartbeat:Connect(function()
    local now = tick()
    fps = 1 / (now - lastTick)
    lastTick = now
    if now - lastUpdate > 0.2 then
        fpsLabel:SetText("FPS: ".. math.floor(fps))
        lastUpdate = now
    end
end)

FPSBox:AddButton(Lang[Settings.Language].mode, function()
    settings().Rendering.QualityLevel = "Level01"
    Lighting.GlobalShadows = false
end)

--========================================================--
--  SETTINGS TAB
--========================================================--

local LangBox = SettingsTab:AddLeftGroupbox(Lang[Settings.Language].language)

LangBox:AddDropdown("LangDrop", {
    Values = {"EN","JP","KR"},
    Default = Settings.Language,
    Text = Lang[Settings.Language].language,
    Callback = function(v)
        Settings.Language = v
        SaveSettings()
        Library:Notify("Language will update next reopen.", 5)
    end
})

local ThemeBox = SettingsTab:AddRightGroupbox(Lang[Settings.Language].theme)

local ThemeDropdown = ThemeBox:AddDropdown("ColorTheme", {
    Values = {"Blue", "Red", "Pink"},
    Default = Settings.Theme,
    Text = Lang[Settings.Language].theme,
    Callback = function(v)
        Settings.Theme = v
        SaveSettings()
        ApplyTheme(v) -- Gọi hàm ApplyTheme đã được bảo vệ
    end
})

-- Tự động vô hiệu hóa Dropdown nếu Theming thất bại
if not ThemingEnabled then
    ThemeDropdown:SetEnabled(false) -- Vô hiệu hóa dropdown
    ThemeBox:AddLabel("Theme disabled (Load Fail)"); -- Thêm nhãn báo lỗi
end

--========================================================--
--  MINIMIZE UI
--========================================================--

local Minimized = false
local MinBtn = Instance.new("TextButton")
MinBtn.Parent = UI.MainFrame.TopBar
MinBtn.Text = "-"
MinBtn.Size = UDim2.new(0,30,1,0)
MinBtn.Position = UDim2.new(1,-30,0,0)
MinBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)

MinBtn.MouseButton1Click:Connect(function()
    Minimized = not Minimized
    if Minimized then
        TweenService:Create(UI.MainFrame, TweenInfo.new(.3), {
            Size = UDim2.new(0,250,0,40)
        }):Play()
        for _,v in pairs(UI.MainFrame:GetChildren()) do
            if v ~= MinBtn and v.Name ~= "TopBar" and v.Name ~= "TabsContainer" then
                v.Visible = false
            end
        end
    else
        TweenService:Create(UI.MainFrame, TweenInfo.new(.3), {
            Size = UDim2.new(0,600,0,450)
        }):Play()
        for _,v in pairs(UI.MainFrame:GetChildren()) do
            v.Visible = true
        end
    end
end)

--========================================================--
--  HIDE UI WITH RIGHTSHIFT
--========================================================--

UserInputService.InputBegan:Connect(function(k,t)
    if not t and k.KeyCode == Enum.KeyCode.RightShift then
        UI.MainFrame.Visible = not UI.MainFrame.Visible
    end
end)

--========================================================--
--  DOCK ICON
--========================================================--

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

Library:Notify("BOOST FPS HUB LOADED ✔", 5)
print("[BoostFPS Hub v3 - Linoria Dark] Loaded. Locale:", Settings.Language)
