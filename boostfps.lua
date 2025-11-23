--[[ 
    BoostFPSHub v1.4 — Final Stable
    Author: Gemini AI Optimized
    Language: Vietnamese
    Features: Resizable UI, Watermark, Deep Boost, Game Support, Restore System
]]

-- === 1. LOADING SCREEN (MÀN HÌNH CHỜ) ===
local function ShowLoadingScreen()
    if game:GetService("CoreGui"):FindFirstChild("BoostFPS_Loading") then return end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "BoostFPS_Loading"
    -- Cố gắng đưa vào CoreGui để hiển thị trên mọi layer
    local parent = pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
    if not ScreenGui.Parent then ScreenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") end
    ScreenGui.IgnoreGuiInset = true

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1,0,1,0)
    Frame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    Frame.Parent = ScreenGui

    local BarBase = Instance.new("Frame")
    BarBase.Size = UDim2.new(0.4, 0, 0.02, 0)
    BarBase.Position = UDim2.new(0.3, 0, 0.7, 0)
    BarBase.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    BarBase.BorderSizePixel = 0
    BarBase.Parent = Frame
    
    local BarProgress = Instance.new("Frame")
    BarProgress.Size = UDim2.new(0,0,1,0)
    BarProgress.BackgroundColor3 = Color3.fromRGB(0, 255, 128) -- Màu xanh ngọc
    BarProgress.BorderSizePixel = 0
    BarProgress.Parent = BarBase

    local Title = Instance.new("TextLabel")
    Title.Text = "BoostFPSHub v1.4"
    Title.Size = UDim2.new(1,0,0.1,0)
    Title.Position = UDim2.new(0,0,0.4,0)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.fromRGB(255,255,255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 30
    Title.Parent = Frame
    
    local SubTitle = Instance.new("TextLabel")
    SubTitle.Text = "Loading Assets & Optimizing..."
    SubTitle.Size = UDim2.new(1,0,0.05,0)
    SubTitle.Position = UDim2.new(0,0,0.5,0)
    SubTitle.BackgroundTransparency = 1
    SubTitle.TextColor3 = Color3.fromRGB(150,150,150)
    SubTitle.Font = Enum.Font.Gotham
    SubTitle.TextSize = 14
    SubTitle.Parent = Frame

    local TweenService = game:GetService("TweenService")
    TweenService:Create(BarProgress, TweenInfo.new(1.5, Enum.EasingStyle.Quad), {Size = UDim2.new(1,0,1,0)}):Play()
    
    task.wait(1.8)
    ScreenGui:Destroy()
end
ShowLoadingScreen()

-- === 2. KHỞI TẠO & DỊCH VỤ ===
if not game:IsLoaded() then game.Loaded:Wait() end

-- Load Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua"))()

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- === 3. QUẢN LÝ TRẠNG THÁI (RESTORE SYSTEM) ===
local OriginalState = {
    Lighting = {
        GlobalShadows = Lighting.GlobalShadows,
        FogEnd = Lighting.FogEnd,
        Brightness = Lighting.Brightness,
        Ambient = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        Technology = Lighting.Technology
    },
    Global = {
        QualityLevel = settings().Rendering.QualityLevel
    }
}

local function SafeCall(func)
    local success, result = pcall(func)
    if not success then warn("[BoostFPSHub Error]: " .. tostring(result)) end
end

local function RestoreDefaults()
    SafeCall(function()
        Lighting.GlobalShadows = OriginalState.Lighting.GlobalShadows
        Lighting.FogEnd = OriginalState.Lighting.FogEnd
        Lighting.Brightness = OriginalState.Lighting.Brightness
        Lighting.Ambient = OriginalState.Lighting.Ambient
        Lighting.OutdoorAmbient = OriginalState.Lighting.OutdoorAmbient
        settings().Rendering.QualityLevel = OriginalState.Global.QualityLevel
        
        -- Khôi phục vật thể
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") then v.Material = Enum.Material.Plastic v.Transparency = 0 end
            if v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 0 end
        end
        
        Library:Notify("Đã khôi phục cài đặt gốc!", 5)
    end)
end

-- === 4. GIAO DIỆN CHÍNH ===

local Window = Library:CreateWindow({
    Title = "BoostFPSHub v1.4 | Final Stable",
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

-- Cài đặt Watermark (Góc màn hình)
Library:SetWatermark("BoostFPSHub v1.4 | Running")
Library:SetWatermarkVisibility(true)

-- Cập nhật FPS cho Watermark
task.spawn(function()
    while true do
        task.wait(1)
        local fps = math.floor(1 / RunService.RenderStepped:Wait())
        Library:SetWatermark("BoostFPSHub v1.4 | FPS: " .. fps .. " | Ping: " .. math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) .. "ms")
    end
end)

local Tabs = {
    Main = Window:AddTab("Chính (Main)"),
    Game = Window:AddTab("Game Boost"),
    Extreme = Window:AddTab("Siêu Cấp (Extreme)"),
    Misc = Window:AddTab("Tiện Ích"),
    Settings = Window:AddTab("Cài Đặt"),
}

-- >> TAB 1: MAIN BOOST
local MainGroup = Tabs.Main:AddLeftGroupbox("Tối Ưu Cơ Bản")

MainGroup:AddToggle("BoostFPS", {Text = "Boost FPS (Khuyên Dùng)", Default = true, Callback = function(v)
    if v then
        SafeCall(function()
            settings().Rendering.QualityLevel = 1
            settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04
            workspace.StreamingEnabled = true
        end)
    else
        settings().Rendering.QualityLevel = OriginalState.Global.QualityLevel
    end
end})

MainGroup:AddToggle("MobileMode", {Text = "Chế Độ Mobile (Giảm Bóng)", Default = false, Callback = function(v)
    Lighting.GlobalShadows = not v
    if v then Lighting.FogEnd = 9e9 else Lighting.FogEnd = OriginalState.Lighting.FogEnd end
end})

MainGroup:AddToggle("FullBright", {Text = "Sáng Tối Đa (FullBright)", Default = false, Callback = function(v)
    if v then
        Lighting.Ambient = Color3.new(1,1,1)
        Lighting.ClockTime = 14
    else
        Lighting.Ambient = OriginalState.Lighting.Ambient
        Lighting.ClockTime = 12
    end
end})

local OptGroup = Tabs.Main:AddRightGroupbox("Tối Ưu CPU & RAM")

OptGroup:AddToggle("CPUThrottle", {Text = "Tiết Kiệm CPU (Khi ẩn tab)", Default = true, Callback = function(v)
    -- Logic giảm FPS khi tab ra ngoài
    local focused = true
    UserInputService.WindowFocused:Connect(function() 
        focused = true 
        if v then RunService:SetFpsCap(999) end 
    end)
    UserInputService.WindowFocusReleased:Connect(function() 
        focused = false 
        if v then RunService:SetFpsCap(5) end 
    end)
end})

OptGroup:AddToggle("AutoClearRAM", {Text = "Dọn RAM Tự Động (15s)", Default = true, Callback = function(v)
    if v then
        task.spawn(function()
            while v do
                task.wait(15)
                SafeCall(function()
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj.Name == "Debris" or obj.Name == "Bullet" or obj.Name == "Effect" then obj:Destroy() end
                    end
                    if checkcaller then for i=1,3 do collectgarbage("collect") end end
                end)
            end
        end)
    end
end})

-- >> TAB 2: GAME BOOST
local GameGroup = Tabs.Game:AddLeftGroupbox("Game Hiện Tại")

local function DetectGame()
    local id = game.PlaceId
    if id == 2753915549 or id == 4442272183 or id == 7449423635 then return "BloxFruit"
    elseif id == 10449761463 then return "TSB"
    elseif id == 6516141723 then return "Doors"
    else return "Universal" end
end
local CurrentGame = DetectGame()

GameGroup:AddLabel("Đang chơi: " .. CurrentGame)

if CurrentGame == "BloxFruit" then
    GameGroup:AddToggle("BF_NoSkill", {Text = "Tắt Skill Effects", Default = false, Callback = function(v)
        task.spawn(function()
             for _, p in pairs(game.ReplicatedStorage:GetDescendants()) do
                 if p:IsA("ParticleEmitter") then p.Enabled = not v end
             end
        end)
    end})
    GameGroup:AddToggle("BF_FastMode", {Text = "Xóa Biển & Đảo Xa", Default = false, Callback = function(v)
        local sea = Workspace:FindFirstChild("Sea")
        if sea then sea.Transparency = v and 1 or 0 end
    end})
elseif CurrentGame == "Doors" then
    GameGroup:AddToggle("Doors_NoLight", {Text = "Xóa Ánh Sáng & Bóng", Default = false, Callback = function(v)
        for _, l in pairs(Workspace:GetDescendants()) do if l:IsA("Light") then l.Enabled = not v end end
    end})
elseif CurrentGame == "TSB" then
    GameGroup:AddToggle("TSB_Map", {Text = "Low Poly Map", Default = false, Callback = function(v)
         for _, p in pairs(Workspace.Map:GetDescendants()) do
             if p:IsA("BasePart") then p.Material = v and Enum.Material.SmoothPlastic or Enum.Material.Plastic end
         end
    end})
else
    GameGroup:AddLabel("Không có chức năng riêng cho game này.")
    GameGroup:AddLabel("Vui lòng dùng Tab 'Chính' hoặc 'Siêu Cấp'.")
end

-- >> TAB 3: EXTREME (ĐỒ HỌA SÂU)
local ExtremeGroup = Tabs.Extreme:AddLeftGroupbox("Cảnh Báo: Làm Xấu Game")

ExtremeGroup:AddToggle("Wireframe", {Text = "Chế Độ Khung Dây (Wireframe)", Default = false, Callback = function(v)
    for _, p in pairs(Workspace:GetDescendants()) do
        if p:IsA("BasePart") then
            p.Material = v and Enum.Material.ForceField or Enum.Material.Plastic
            if v then p.Transparency = 0.5 else p.Transparency = 0 end
        end
    end
end})

ExtremeGroup:AddToggle("NoRender", {Text = "Tắt Render 3D (Treo máy)", Default = false, Callback = function(v)
    RunService:Set3dRenderingEnabled(not v)
end})

ExtremeGroup:AddToggle("Invisible", {Text = "Tàng Hình Vật Thể (Xuyên Tường)", Default = false, Callback = function(v)
    for _, p in pairs(Workspace:GetDescendants()) do
        if p:IsA("BasePart") and not p.Parent:IsA("Model") then
            p.Transparency = v and 1 or 0
        end
    end
end})

ExtremeGroup:AddButton("Xóa Texture Vĩnh Viễn", {Func = function()
    for _, t in pairs(Workspace:GetDescendants()) do
        if t:IsA("Texture") or t:IsA("Decal") then t:Destroy() end
    end
    Library:Notify("Đã xóa sạch Texture!", 3)
end})

-- >> TAB 4: TIỆN ÍCH (MISC)
local MiscGroup = Tabs.Misc:AddLeftGroupbox("Server & AFK")

MiscGroup:AddToggle("AntiAFK", {Text = "Anti-AFK (Chống kick)", Default = true, Callback = function(v)
    if v then
        local vu = game:GetService("VirtualUser")
        LocalPlayer.Idled:Connect(function()
            vu:CaptureController()
            vu:ClickButton2(Vector2.new())
        end)
    end
end})

MiscGroup:AddButton("Rejoin Server (Vào lại)", {Func = function()
    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end})

MiscGroup:AddButton("Server Hop (Đổi Server)", {Func = function()
    Library:Notify("Đang tìm server khác...", 3)
    local Http = game:GetService("HttpService")
    local TPS = game:GetService("TeleportService")
    local Api = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
    local function ListServers(cursor)
        local Raw = game:HttpGet(Api .. ((cursor and "&cursor="..cursor) or ""))
        return Http:JSONDecode(Raw)
    end
    local Server, Next; repeat
        local Servers = ListServers(Next)
        Server = Servers.data[math.random(1, #Servers.data)]
        Next = Servers.nextPageCursor
    until Server.playing < Server.maxPlayers and Server.id ~= game.JobId
    TPS:TeleportToPlaceInstance(game.PlaceId, Server.id, LocalPlayer)
end})

-- >> TAB 5: SETTINGS (CÀI ĐẶT)
local SetGroup = Tabs.Settings:AddLeftGroupbox("Hệ Thống")

SetGroup:AddButton("KHÔI PHỤC MẶC ĐỊNH (Restore)", {Func = RestoreDefaults})
SetGroup:AddButton("Tắt Script (Unload)", {Func = function() Window:Unload() end})

-- Theme Manager
local ThemeGroup = Tabs.Settings:AddRightGroupbox("Giao Diện (Themes)")
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("BoostFPSHub_v1.4")
ThemeManager:ApplyToTab(ThemeGroup)

-- Save Manager
local ConfigGroup = Tabs.Settings:AddRightGroupbox("Cấu Hình (Config)")
SaveManager:SetLibrary(Library)
SaveManager:SetFolder("BoostFPSHub_v1.4")
SaveManager:BuildConfigSection(ConfigGroup)

-- Init
Library:Notify("BoostFPSHub v1.4 Loaded!", 5)
