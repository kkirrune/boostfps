--[[ 
    BoostFPSHub v6 — International Edition
    Features: Loading Screen, Multi-Language, Auto Game Detect, Deep Boost
]]

-- === 1. LOADING SCREEN SYSTEM (Hệ thống màn hình chờ) ===
local function ShowLoadingScreen()
    local Players = game:GetService("Players")
    local TweenService = game:GetService("TweenService")
    local CoreGui = game:GetService("CoreGui")
    local LocalPlayer = Players.LocalPlayer
    
    -- Tạo ScreenGui an toàn
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "BoostFPS_Loading"
    -- Nếu dùng Executor xịn thì nhét vào CoreGui, không thì PlayerGui
    pcall(function() ScreenGui.Parent = CoreGui end) 
    if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
    
    -- Background đen
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(1, 0, 1, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    -- Logo/Title Text
    local Title = Instance.new("TextLabel")
    Title.Text = "BOOST FPS HUB v6"
    Title.Size = UDim2.new(1, 0, 0.2, 0)
    Title.Position = UDim2.new(0, 0, 0.3, 0)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.fromRGB(0, 255, 127) -- Màu xanh ngọc
    Title.Font = Enum.Font.FredokaOne
    Title.TextSize = 40
    Title.Parent = MainFrame

    -- Thanh Loading Bar (Background)
    local BarBg = Instance.new("Frame")
    BarBg.Size = UDim2.new(0.6, 0, 0.05, 0)
    BarBg.Position = UDim2.new(0.2, 0, 0.5, 0)
    BarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    BarBg.BorderSizePixel = 0
    BarBg.Parent = MainFrame
    
    -- Corner cho đẹp
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = BarBg

    -- Thanh Fill (Màu chạy)
    local BarFill = Instance.new("Frame")
    BarFill.Size = UDim2.new(0, 0, 1, 0) -- Bắt đầu từ 0
    BarFill.BackgroundColor3 = Color3.fromRGB(0, 255, 127)
    BarFill.BorderSizePixel = 0
    BarFill.Parent = BarBg
    local UICorner2 = Instance.new("UICorner")
    UICorner2.CornerRadius = UDim.new(0, 8)
    UICorner2.Parent = BarFill

    -- Text %
    local PercentTxt = Instance.new("TextLabel")
    PercentTxt.Text = "Loading... 0%"
    PercentTxt.Size = UDim2.new(1, 0, 2, 0)
    PercentTxt.Position = UDim2.new(0, 0, 1.2, 0)
    PercentTxt.BackgroundTransparency = 1
    PercentTxt.TextColor3 = Color3.fromRGB(200, 200, 200)
    PercentTxt.Font = Enum.Font.GothamBold
    PercentTxt.TextSize = 18
    PercentTxt.Parent = BarBg

    -- Logic chạy %
    for i = 1, 100 do
        BarFill.Size = UDim2.new(i/100, 0, 1, 0)
        PercentTxt.Text = "Loading Assets... " .. i .. "%"
        
        -- Chạy nhanh ở đoạn đầu, chậm ở đoạn cuối cho giống thật
        if i < 70 then
            task.wait(0.01)
        else
            task.wait(0.03)
        end
    end
    
    task.wait(0.5) -- Đợi 1 chút khi 100%
    ScreenGui:Destroy() -- Xóa UI Loading
end

-- CHẠY MÀN HÌNH LOADING
ShowLoadingScreen()


-- === 2. LANGUAGE SYSTEM (Hệ thống Ngôn Ngữ) ===
-- Chọn ngôn ngữ: "English", "Vietnamese", "Spanish", "Portuguese", "Thai"
local SelectLanguage = "English" -- MẶC ĐỊNH LÀ TIẾNG ANH (Default)

local Translations = {
    ["English"] = {
        Title = "Boost FPS Hub v6 - Ultimate",
        Tab_Main = "Main Boost",
        Tab_Game = "Game Boost",
        Tab_GFX = "Deep Graphics",
        Tab_Settings = "Settings",
        
        -- Main
        Grp_System = "System Boost",
        Btn_BoostFPS = "Boost FPS (Basic)",
        Btn_Mobile = "Mobile Mode (Low GFX)",
        Btn_AntiLag = "Anti-Lag (Auto Clear RAM)",
        Btn_CleanRAM = "Clean RAM Now",
        
        -- Game
        Grp_Universal = "Universal Game",
        Lbl_NoGame = "No specific game detected.",
        
        -- GFX
        Grp_Deep = "Deep Reduction",
        Btn_NoSky = "Remove Sky",
        Btn_FullBright = "Fullbright (Max Light)",
        Btn_SmoothWalls = "Smooth Walls (Plastic)",
        Btn_Invisible = "Invisible Objects (Wallhack-like)",
        
        -- Settings
        Grp_Config = "Config Manager",
        Lbl_Lang = "Language: English",
        Btn_Unload = "Unload Script"
    },
    ["Vietnamese"] = {
        Title = "Boost FPS Hub v6 - Siêu Cấp",
        Tab_Main = "Tăng Tốc Chính",
        Tab_Game = "Game Cụ Thể",
        Tab_GFX = "Đồ Họa Sâu",
        Tab_Settings = "Cài Đặt",
        
        Grp_System = "Hệ Thống",
        Btn_BoostFPS = "Tăng FPS (Cơ bản)",
        Btn_Mobile = "Chế độ Mobile (Siêu nhẹ)",
        Btn_AntiLag = "Anti-Lag (Tự dọn RAM)",
        Btn_CleanRAM = "Dọn RAM Ngay",
        
        Grp_Universal = "Game Phổ Quát",
        Lbl_NoGame = "Không tìm thấy cấu hình game riêng.",
        
        Grp_Deep = "Giảm Đồ Họa Sâu",
        Btn_NoSky = "Xóa Bầu Trời",
        Btn_FullBright = "Sáng Tối Đa",
        Btn_SmoothWalls = "Tường Mịn (Nhựa)",
        Btn_Invisible = "Tàng Hình Vật Thể",
        
        Grp_Config = "Quản Lý Cấu Hình",
        Lbl_Lang = "Ngôn ngữ: Tiếng Việt",
        Btn_Unload = "Tắt Script"
    },
    ["Spanish"] = {
        Title = "Boost FPS Hub v6 - Ultimo",
        Tab_Main = "Impulso Principal",
        Tab_Game = "Juego Específico",
        Tab_GFX = "Gráficos Profundos",
        Tab_Settings = "Ajustes",
        Grp_System = "Sistema",
        Btn_BoostFPS = "Aumentar FPS",
        Btn_Mobile = "Modo Móvil",
        Btn_AntiLag = "Anti-Lag (RAM)",
        Btn_CleanRAM = "Limpiar RAM",
        Grp_Universal = "Juego Universal",
        Lbl_NoGame = "Juego no detectado.",
        Grp_Deep = "Reducción Profunda",
        Btn_NoSky = "Eliminar Cielo",
        Btn_FullBright = "Brillo Máximo",
        Btn_SmoothWalls = "Paredes Lisas",
        Btn_Invisible = "Objetos Invisibles",
        Grp_Config = "Configuración",
        Lbl_Lang = "Idioma: Español",
        Btn_Unload = "Descargar Script"
    },
    -- Thêm các ngôn ngữ khác nếu cần
}

-- Hàm lấy text theo ngôn ngữ
local function T(key)
    if Translations[SelectLanguage] and Translations[SelectLanguage][key] then
        return Translations[SelectLanguage][key]
    end
    return Translations["English"][key] or key -- Fallback về tiếng Anh
end

-- === 3. CORE SCRIPT (Giữ nguyên tính năng cũ nhưng thay Text) ===
if not game:IsLoaded() then game.Loaded:Wait() end

-- Linoria Lib
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua"))()

local Window = Library:CreateWindow({
    Title = T("Title"),
    Center = true,
    AutoShow = true,
    TabPadding = 8
})

local Tabs = {
    Main = Window:AddTab(T("Tab_Main")),
    Game = Window:AddTab(T("Tab_Game")),
    Graphics = Window:AddTab(T("Tab_GFX")),
    Settings = Window:AddTab(T("Tab_Settings"))
}

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Detect Game
local PlaceID = game.PlaceId
local GameName = "Universal"
local GameIDs = {
    BloxFruit = {2753915549, 4442272183, 7449423635},
    TSB = {10449761463},
    Doors = {6516141723, 6839171747},
    Evade = {9872472334},
    Fisch = {16732694052},
    Rivals = {17625359962},
    PixelBlade = {6445980753},
    Brainrot = {15561560423}
}

local function checkGame()
    for name, ids in pairs(GameIDs) do
        for _, id in pairs(ids) do
            if PlaceID == id then GameName = name return end
        end
    end
    local lowerName = game.Name:lower()
    if lowerName:find("blox fruit") then GameName = "BloxFruit"
    elseif lowerName:find("battlegrounds") then GameName = "TSB"
    elseif lowerName:find("doors") then GameName = "Doors"
    elseif lowerName:find("evade") then GameName = "Evade"
    elseif lowerName:find("fisch") then GameName = "Fisch"
    elseif lowerName:find("rivals") then GameName = "Rivals"
    elseif lowerName:find("pixel") then GameName = "PixelBlade"
    end
end
checkGame()

-- Safe Call
local function safeCall(func)
    local ok, err = pcall(func)
end

local function runAntiCrash()
    if setfpscap then setfpscap(60) end
    for _, v in pairs(Workspace:GetDescendants()) do
        if v.Name == "Debris" or v.Name == "Bullet" then v:Destroy() end
    end
    if checkcaller then for i=1,3 do collectgarbage("collect") end end
end

-- === UI BUILD ===

-- 1. Main Tab
local MainGroup = Tabs.Main:AddLeftGroupbox(T("Grp_System"))
MainGroup:AddToggle("BoostFPS", {Text = T("Btn_BoostFPS"), Default = true, Callback = function(v)
    if v then 
        settings().Rendering.QualityLevel = 1 
        workspace.StreamingEnabled = true
    end
end})
MainGroup:AddToggle("MobileMode", {Text = T("Btn_Mobile"), Default = false, Callback = function(v)
    Lighting.GlobalShadows = not v
    if v then Lighting.FogEnd = 9e9 end
end})
MainGroup:AddToggle("AntiLag", {Text = T("Btn_AntiLag"), Default = false, Callback = function(v)
    if v then
        task.spawn(function()
            while v do runAntiCrash() task.wait(10) end
        end)
    end
end})
MainGroup:AddButton(T("Btn_CleanRAM"), {Func = runAntiCrash})

-- 2. Game Tab
local GameGroup = Tabs.Game:AddLeftGroupbox("Game: " .. GameName)
if GameName == "BloxFruit" then
    GameGroup:AddToggle("BF1", {Text = "No Skill Effects", Default = false, Callback = function(v) end}) -- Add logic
    GameGroup:AddToggle("BF2", {Text = "Fast Mode (No Sea)", Default = false, Callback = function(v) 
        local s = Workspace:FindFirstChild("Sea") if s then s.Transparency = v and 1 or 0 end
    end})
elseif GameName == "Doors" then
    GameGroup:AddToggle("D1", {Text = "No Lights", Default = false, Callback = function(v) end})
    GameGroup:AddToggle("D2", {Text = "Remove Decor", Default = false, Callback = function(v) end})
else
    GameGroup:AddLabel(T("Lbl_NoGame"))
    GameGroup:AddLabel("Mode: " .. GameName)
end

-- 3. Graphics Tab
local GFXGroup = Tabs.Graphics:AddLeftGroupbox(T("Grp_Deep"))
GFXGroup:AddToggle("NoSky", {Text = T("Btn_NoSky"), Default = false, Callback = function(v)
    if v then for _,o in pairs(Lighting:GetChildren()) do if o:IsA("Sky") then o.Parent=nil end end end
end})
GFXGroup:AddToggle("FullBright", {Text = T("Btn_FullBright"), Default = false, Callback = function(v)
    if v then Lighting.Brightness=2 Lighting.ClockTime=14 Lighting.GlobalShadows=false else Lighting.Brightness=1 end
end})
GFXGroup:AddToggle("SmoothWalls", {Text = T("Btn_SmoothWalls"), Default = false, Callback = function(v)
    for _,p in pairs(Workspace:GetDescendants()) do if p:IsA("BasePart") then p.Material = v and Enum.Material.SmoothPlastic or Enum.Material.Plastic end end
end})

-- 4. Settings Tab
local SetGroup = Tabs.Settings:AddLeftGroupbox(T("Grp_Config"))
SetGroup:AddLabel(T("Lbl_Lang"))
SetGroup:AddDropdown("LangSelect", {
    Values = {"English", "Vietnamese", "Spanish"},
    Default = 1,
    Multi = false,
    Text = "Select Language (Restart Script)",
    Tooltip = "Select language and re-execute script",
    Callback = function(v)
        -- Chức năng này chỉ mang tính chất lưu config, cần re-execute để đổi ngôn ngữ hoàn toàn
        SelectLanguage = v
    end
})
SetGroup:AddButton(T("Btn_Unload"), {Func = function() Window:Unload() end})

SaveManager:SetLibrary(Library)
SaveManager:SetFolder("BoostFPSHub_v6")
SaveManager:BuildConfigSection(SetGroup)

Library:Notify("BoostFPSHub v6 Loaded!", 5)
