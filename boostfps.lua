--[[
    SCRIPT NÂNG CẤP "VIP" - GIAO DIỆN PIXELBLADE
    Tối ưu hóa mạnh mẽ cho máy yếu (Volcano Compatible)
    Bao gồm Animation "Pop-up" và 10+ chức năng "VIP"
]]

-- ====== CONFIG (ĐÃ CẬP NHẬT GIAO DIỆN) ======
local Config = {
    Theme = {
        Background = Color3.fromRGB(23, 28, 33), -- Nền chính (Hub-BG)
        Panel = Color3.fromRGB(33, 41, 51), -- Nền của item (Card-BG)
        Accent = Color3.fromRGB(128, 203, 196), -- Xanh ngọc (Accent)
        TabActive = Color3.fromRGB(44, 54, 65), -- Nền Tab
        Text = Color3.fromRGB(220, 220, 220),
        SubText = Color3.fromRGB(150, 150, 150),
        ToggleON = Color3.fromRGB(76, 175, 80), -- Xanh lá
        ToggleOFF = Color3.fromRGB(75, 85, 99), -- Xám
    },
    Language = "EN", -- Mặc định Tiếng Anh
    AntiBan = {
        MinDelay = 0.1,
        MaxDelay = 0.3,
        BatchSize = 50,
        Jitter = 0.05,
    },
    MobileScale = 1.0, 
}

-- ====== LANGUAGE STRINGS (THÊM CHỨC NĂNG VIP) ======
local LANG = {
    EN = {
        Title = "Pixel Blade | PolleserHub (VIP)",
        MainTab = "Main",
        Hint = "Tip: Use 'Boost Max' on weak devices. Disable before boss spawns!",
        
        -- Chức năng VIP mới
        GroupGraphics = "GRAPHICS (FOR WEAK PC)",
        RemoveTextures = "Remove Textures/Decals",
        DisableParticles = "Disable Particles/FX",
        LowerMaterials = "Lower Materials (Plastic)",
        DisableLighting = "Disable Lighting Effects",
        OptimizeMesh = "Optimize Mesh (LOD)",
        DisableShadows = "DISABLE SHADOWS (VIP)",
        RemoveFoliage = "Remove Grass/Foliage (VIP)",
        DisableFog = "Disable Fog/Atmosphere",
        
        GroupUtility = "UTILITY (ANTI-LAG)",
        AntiLagMode = "Anti-Lag/Stealth Mode",
        BoostAll = "BOOST MAX (Safe)",
        Restore = "Restore (Teleport)",
        Language = "Language",
    },
    VI = {
        Title = "Pixel Blade | PolleserHub (VIP)",
        MainTab = "Chính",
        Hint = "Mẹo: Dùng 'Boost Max' cho máy yếu. Tắt đi khi boss spawn!",
        
        GroupGraphics = "ĐỒ HỌA (CHO MÁY YẾU)",
        RemoveTextures = "Xóa Texture/Decal",
        DisableParticles = "Tắt Particles/Hiệu ứng FX",
        LowerMaterials = "Giảm Material (Plastic)",
        DisableLighting = "Tắt Hiệu Ứng Lighting",
        OptimizeMesh = "Tối ưu Mesh (LOD)",
        DisableShadows = "TẮT BÓNG ĐỔ (VIP)",
        RemoveFoliage = "Xóa Cỏ/Tán Lá (VIP)",
        DisableFog = "Tắt Sương Mù/Khí quyển",
        
        GroupUtility = "TIỆN ÍCH (CHỐNG LAG)",
        AntiLagMode = "Chế độ Anti-Lag/Stealth",
        BoostAll = "TĂNG MAX (An Toàn)",
        Restore = "Khôi phục (Teleport)",
        Language = "Ngôn ngữ",
    },
    -- ... (Thêm các ngôn ngữ khác nếu muốn, cấu trúc tương tự)
}
-- Chỉ giữ 2 ngôn ngữ chính để giảm độ dài, bạn có thể thêm lại các ngôn ngữ kia
local AvailableLanguages = {'EN', 'VI'}

-- ====== SERVICES & HELPERS ======
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local function randDelay()
    local a = Config.AntiBan.MinDelay
    local b = Config.AntiBan.MaxDelay
    return a + math.random() * (b - a) + (math.random()-0.5) * Config.AntiBan.Jitter
end

local function batchProcess(list, worker)
    local batchSize = Config.AntiBan.BatchSize
    task.spawn(function()
        local i = 1
        while i <= #list do
            local endI = math.min(#list, i + batchSize - 1)
            for j = i, endI do
                pcall(worker, list[j])
            end
            i = endI + 1
            task.wait(randDelay()) 
        end
    end)
end

local function shouldOptimize(instance)
    return not instance:IsDescendantOf(LocalPlayer.Character or {})
        and not instance:IsDescendantOf(LocalPlayer:FindFirstChild("PlayerGui") or {})
        and not instance:IsDescendantOf(LocalPlayer:FindFirstChild("Backpack") or {})
end

-- ===== CHỨC NĂNG VIP (MẠNH MẼ HƠN) =====

-- 1. Tắt Particles/FX (Vẫn như cũ, hiệu quả)
local function disableEmittersSafe(root)
    local found = {}
    for _, v in ipairs(root:GetDescendants()) do
        if (v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Sparkles") or v:IsA("Fire") or v:IsA("Smoke")) and shouldOptimize(v) then
            table.insert(found, v)
        end
    end
    batchProcess(found, function(obj) obj.Enabled = false end)
end

-- 2. Xóa Textures/Decals (VIP: Giờ xóa cả SurfaceAppearance - Gây lag nhất)
local function hideDecalsSafe(root)
    local found = {}
    for _, v in ipairs(root:GetDescendants()) do
        if (v:IsA("Decal") or v:IsA("Texture") or v:IsA("SurfaceAppearance")) and shouldOptimize(v) then
            table.insert(found, v)
        end
    end
    batchProcess(found, function(obj)
        if obj:IsA("SurfaceAppearance") then
            Debris:AddItem(obj, 0) -- Xóa ngay lập tức
        elseif obj.Transparency ~= nil then
            obj.Transparency = 1
        elseif obj.Texture then
            obj.Texture = "" 
        end
    end)
end

-- 3. Giảm Materials (Vẫn như cũ)
local function reduceMaterialsSafe(root)
    local found = {}
    for _, v in ipairs(root:GetDescendants()) do
        if v:IsA("BasePart") and shouldOptimize(v) then
            table.insert(found, v)
        end
    end
    batchProcess(found, function(part)
        part.Material = Enum.Material.SmoothPlastic 
        part.Reflectance = 0
    end)
end

-- 4. Tối ưu Mesh (Vẫn như cũ)
local function optimizeMeshPartsSafe(root)
    local found = {}
    for _, v in ipairs(root:GetDescendants()) do
        if v:IsA("MeshPart") and shouldOptimize(v) then
            table.insert(found, v)
        end
    end
    batchProcess(found, function(mesh)
        if mesh.TextureID and mesh.TextureID ~= "" then
            mesh.TextureID = ""
        end
        pcall(function() mesh.RenderFidelity = Enum.RenderFidelity.Performance end)
    end)
end

-- 5. Tắt Lighting (VIP: Tắt PostEffects, chỉ giữ bóng đổ nếu có)
local function optimizeLightingSafe()
    pcall(function()
        -- Tắt các hiệu ứng hậu kỳ (PostEffects)
        for _, eff in ipairs(Lighting:GetChildren()) do
            local cls = eff.ClassName
            if (cls == "BloomEffect" or cls == "SunRaysEffect" or cls == "ColorCorrectionEffect" or cls == "DepthOfFieldEffect" or cls == "AmbientOcclusion" or cls == "BlurEffect") then
                pcall(function() eff.Enabled = false end)
            end
        end
    end)
end

-- 6. TẮT BÓNG ĐỔ (VIP MỚI)
local function disableShadowsSafe(state)
    pcall(function()
        if state then
            Lighting.GlobalShadows = false
        else
            Lighting.GlobalShadows = true -- Bật lại
        end
    end)
end

-- 7. XÓA CỎ (VIP MỚI)
local function removeFoliageSafe(root)
    pcall(function()
        -- Tắt cỏ
        if workspace:IsA("Terrain") then
            workspace.Decoration = false 
        end
        -- Xóa các vật thể cây cỏ (mesh)
        local found = {}
        for _, v in ipairs(root:GetDescendants()) do
            if (v:IsA("MeshPart") or v:IsA("Part")) and (v.Name:lower():find("grass") or v.Name:lower():find("foliage") or v.Name:lower():find("bush")) and shouldOptimize(v) then
                table.insert(found, v)
            end
        end
        batchProcess(found, function(obj) Debris:AddItem(obj, 0) end)
    end)
end

-- 8. TẮT SƯƠNG MÙ (VIP MỚI)
local function disableFogSafe(state)
    pcall(function()
        if state then
            Lighting.FogEnd = 1000000 -- Đẩy sương mù ra rất xa
            Lighting.Atmosphere.Density = 0 -- Tắt Atmosphere
        else
            Lighting.FogEnd = 1000 -- Khôi phục (cần giá trị mặc định của game)
            Lighting.Atmosphere.Density = 0.3 -- Khôi phục
        end
  _   end)
end

-- 9. ANTI-LAG MODE (VIP MỚI)
local function setAntiLagMode(state)
    pcall(function()
        if state then
            -- Cố gắng đặt chất lượng đồ họa thấp nhất (Volcano có thể chặn)
  t         pcall(function() settings().Rendering.QualityLevel = 1 end)
        else
            pcall(function() settings().Rendering.QualityLevel = 10 end) -- Tắt
        end
    end)
end

-- Combined apply sequence
local function applyBoostSafe()
    task.spawn(function()
        task.wait(randDelay())
        hideDecalsSafe(workspace); task.wait(randDelay())
        disableEmittersSafe(workspace); task.wait(randDelay())
        optimizeMeshPartsSafe(workspace); task.wait(randDelay())
        reduceMaterialsSafe(workspace); task.wait(randDelay())
        optimizeLightingSafe(); task.wait(randDelay())
        disableShadowsSafe(true); task.wait(randDelay())
        removeFoliageSafe(workspace); task.wait(randDelay())
        disableFogSafe(true);
    end)
end

-- Revert: Teleport
local function revertSafe()
    pcall(function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
    end)
end

-- Bảng trạng thái Toggles
local TogglesState = {}
local ToggleActions = {}

-- ====== UI SETUP (GIAO DIỆN PIXELBLADE MỚI) ======

if game.CoreGui:FindFirstChild("PixelBladeHub_UI") then
    game.CoreGui:PixelBladeHub_UI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PixelBladeHub_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

-- Main Panel
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 500, 0, 350) -- Kích thước cố định giống trong hình
Main.Position = UDim2.new(0.5, 0, 0.5, 0) -- Bắt đầu ở giữa
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = Config.Theme.Background
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Active = true
Main.Draggable = true
Main.Visible = true

-- Thêm UICorner cho bo tròn VIP
local Corner = Instance.new("UICorner", Main)
Corner.CornerRadius = UDim.new(0, 8)

-- Animation "Pop-up" VIP khi mở
local function animateIn(uiFrame, duration)
    if uiFrame then
        uiFrame.Visible = true
        uiFrame.Transparency = 1 
        uiFrame.Size = UDim2.new(0, 400, 0, 280) -- Bắt đầu nhỏ
        
        local info = TweenInfo.new(duration, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
        
        -- Tween kích thước (Pop-up)
        TweenService:Create(uiFrame, info, {
            Size = UDim2.new(0, 500, 0, 350)
        }):Play()
        
        -- Tween mờ dần (Fade-in)
        TweenService:Create(uiFrame, TweenInfo.new(duration/1.5), {
            Transparency = 0,
            BackgroundTransparency = 0
        }):Play()
    end
end

-- Header (Thanh tiêu đề giống mẫu)
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Config.Theme.Background
Header.BorderSizePixel = 0
Header.BorderColor3 = Config.Theme.Panel
Header.BorderSizePixel = 1 -- Viền dưới

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(0.5, 0, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = LANG[Config.Language].Title
Title.TextColor3 = Config.Theme.Text
Title.Font = Enum.Font.GothamSemibold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.TextSize = 16

-- Nút điều khiển (Giống mẫu)
local Controls = Instance.new("Frame", Header)
Controls.Size = UDim2.new(0.3, 0, 1, 0)
Controls.Position = UDim2.new(1, -120, 0, 0)
Controls.BackgroundTransparency = 1

local IconLayout = Instance.new("UIListLayout", Controls)
IconLayout.FillDirection = Enum.FillDirection.Horizontal
IconLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
IconLayout.VerticalAlignment = Enum.VerticalAlignment.Center
IconLayout.Padding = UDim.new(0, 10)

-- (Bạn có thể thêm Icon Search, Settings, Minimize, Close ở đây nếu muốn)

-- Body (Nội dung chính)
local Body = Instance.new("Frame", Main)
Body.Size = UDim2.new(1, 0, 1, -40)
Body.Position = UDim2.new(0, 0, 0, 40)
Body.BackgroundTransparency = 1

-- Sidebar (Thanh bên)
local Sidebar = Instance.new("Frame", Body)
Sidebar.Size = UDim2.new(0, 100, 1, 0)
Sidebar.BackgroundColor3 = Config.Theme.Background
Sidebar.BorderColor3 = Config.Theme.Panel
Sidebar.BorderSizePixel = 1 -- Viền phải

-- Tab "Main"
local MainTab = Instance.new("TextButton", Sidebar)
MainTab.Size = UDim2.new(1, -12, 0, 36)
MainTab.Position = UDim2.new(0, 6, 0, 10)
MainTab.BackgroundColor3 = Config.Theme.TabActive
MainTab.Text = " "
MainTab.AutoButtonColor = false
local tabCorner = Instance.new("UICorner", MainTab)
tabCorner.CornerRadius = UDim.new(0, 6)

local tabIcon = Instance.new("ImageLabel", MainTab)
tabIcon.Size = UDim2.new(0, 16, 0, 16)
tabIcon.Position = UDim2.new(0, 10, 0.5, -8)
tabIcon.Image = "rbxassetid://3921711107" -- Star Icon
tabIcon.BackgroundTransparency = 1

local tabLabel = Instance.new("TextLabel", MainTab)
tabLabel.Size = UDim2.new(1, -30, 1, 0)
tabLabel.Position = UDim2.new(0, 30, 0, 0)
tabLabel.BackgroundTransparency = 1
tabLabel.Text = LANG[Config.Language].MainTab
tabLabel.TextColor3 = Config.Theme.Accent
tabLabel.Font = Enum.Font.GothamSemibold
tabLabel.TextXAlignment = Enum.TextXAlignment.Left
tabLabel.TextSize = 14

-- Content Area (Khu vực nội dung)
local ContentArea = Instance.new("ScrollingFrame", Body)
ContentArea.Size = UDim2.new(1, -100, 1, 0)
ContentArea.Position = UDim2.new(0, 100, 0, 0)
ContentArea.BackgroundColor3 = Config.Theme.Panel
ContentArea.BorderSizePixel = 0
ContentArea.ScrollBarThickness = 6
ContentArea.ScrollBarImageColor3 = Config.Theme.Accent

local ContentLayout = Instance.new("UIListLayout", ContentArea)
ContentLayout.Padding = UDim.new(0, 6)
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- ===== TẠO CÁC CHỨC NĂNG (GIAO DIỆN VIP) =====

local function createToggle(parent, key, text, y)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -20, 0, 40)
    frame.Position = UDim2.new(0, 10, 0, y)
    frame.BackgroundColor3 = Config.Theme.Panel
    frame.LayoutOrder = y
    local frameCorner = Instance.new("UICorner", frame)
    frameCorner.CornerRadius = UDim.new(0, 6)

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Config.Theme.Text
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextSize = 14

    -- Nút Toggle Trượt (Slider Toggle)
    local toggleBtn = Instance.new("ImageButton", frame)
    toggleBtn.Name = key
    toggleBtn.Size = UDim2.new(0, 38, 0, 20)
    toggleBtn.Position = UDim2.new(1, -48, 0.5, -10)
    toggleBtn.BackgroundColor3 = Config.Theme.ToggleOFF
    local toggleCorner = Instance.new("UICorner", toggleBtn)
    toggleCorner.CornerRadius = UDim.new(0.5, 0)

    local slider = Instance.new("Frame", toggleBtn)
    slider.Size = UDim2.new(0, 16, 0, 16)
    slider.Position = UDim2.new(0, 2, 0.5, -8)
    slider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    local sliderCorner = Instance.new("UICorner", slider)
    sliderCorner.CornerRadius = UDim.new(0.5, 0)

    return {frame=frame, label=label, toggle=toggleBtn, slider=slider}
end

local function createButton(parent, key, text, y, color)
    local btn = Instance.new("TextButton", parent)
    btn.Name = key
    btn.Size = UDim2.new(1, -20, 0, 36)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.BackgroundColor3 = color or Config.Theme.Panel
    btn.Text = text
    btn.TextColor3 = Config.Theme.Text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.LayoutOrder = y
    local btnCorner = Instance.new("UICorner", btn)
    btnCorner.CornerRadius = UDim.new(0, 6)
    return btn
end

local function createLabel(parent, text, y)
    local label = Instance.new("TextLabel", parent)
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0, 10, 0, y)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Config.Theme.SubText
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextSize = 12
    label.LayoutOrder = y
    return label
end

-- ===== TẠO CÁC MỤC TRONG UI =====
local entries = {}
local yPos = 10

-- Hint Box
local hintBox = createLabel(ContentArea, LANG[Config.Language].Hint, yPos)
hintBox.Size = UDim2.new(1, -20, 0, 40)
hintBox.BackgroundColor3 = Config.Theme.Background
hintBox.TextColor3 = Config.Theme.Accent
hintBox.TextWrapped = true
local hintCorner = Instance.new("UICorner", hintBox)
hintCorner.CornerRadius = UDim.new(0, 6)
yPos = yPos + 46

-- Group Graphics
yPos = yPos + 10
createLabel(ContentArea, LANG[Config.Language].GroupGraphics, yPos)
yPos = yPos + 26

-- Add features
entries.texture = createToggle(ContentArea, "texture", LANG[Config.Language].RemoveTextures, yPos); yPos = yPos + 46
entries.particles = createToggle(ContentArea, "particles", LANG[Config.Language].DisableParticles, yPos); yPos = yPos + 46
entries.materials = createToggle(ContentArea, "materials", LANG[Config.Language].LowerMaterials, yPos); yPos = yPos + 46
entries.lighting = createToggle(ContentArea, "lighting", LANG[Config.Language].DisableLighting, yPos); yPos = yPos + 46
entries.mesh = createToggle(ContentArea, "mesh", LANG[Config.Language].OptimizeMesh, yPos); yPos = yPos + 46
entries.shadows = createToggle(ContentArea, "shadows", LANG[Config.Language].DisableShadows, yPos); yPos = yPos + 46
entries.foliage = createToggle(ContentArea, "foliage", LANG[Config.Language].RemoveFoliage, yPos); yPos = yPos + 46
entries.fog = createToggle(ContentArea, "fog", LANG[Config.Language].DisableFog, yPos); yPos = yPos + 46

-- Group Utility
yPos = yPos + 10
createLabel(ContentArea, LANG[Config.Language].GroupUtility, yPos)
yPos = yPos + 26

entries.antilag = createToggle(ContentArea, "antilag", LANG[Config.Language].AntiLagMode, yPos); yPos = yPos + 46

local btnBoost = createButton(ContentArea, "boost", LANG[Config.Language].BoostAll, yPos, Config.Theme.Accent)
btnBoost.TextColor3 = Config.Theme.Background
yPos = yPos + 42

local btnRestore = createButton(ContentArea, "restore", LANG[Config.Language].Restore, yPos, Config.Theme.Panel)
yPos = yPos + 42

-- Cập nhật CanvasSize
ContentArea.CanvasSize = UDim2.new(0, 0, 0, yPos + 20)

-- ====== LOGIC TOGGLE (VIP) ======

ToggleActions = {
    texture = function(state) if state then hideDecalsSafe(workspace) end end,
    particles = function(state) if state then disableEmittersSafe(workspace) end end,
    materials = function(state) if state then reduceMaterialsSafe(workspace) end end,
    lighting = function(state) if state then optimizeLightingSafe() end end,
    mesh = function(state) if state then optimizeMeshPartsSafe(workspace) end end,
    shadows = function(state) disableShadowsSafe(state) end, -- Cần trạng thái
    foliage = function(state) if state then removeFoliageSafe(workspace) end end,
    fog = function(state) disableFogSafe(state) end, -- Cần trạng thái
    antilag = function(state) setAntiLagMode(state) end, -- Cần trạng thái
}

-- Hàm điều khiển UI cho Toggle
local function setToggleUI(key, state)
    local entry = entries[key]
    if not entry then return end
    
    TogglesState[key] = state
    
    local targetPos = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    local targetColor = state and Config.Theme.ToggleON or Config.Theme.ToggleOFF
    
    local info = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    -- Tween slider
    TweenService:Create(entry.slider, info, {Position = targetPos}):Play()
    -- Tween background
    TweenService:Create(entry.toggle, info, {BackgroundColor3 = targetColor}):Play()
end

-- Gán sự kiện Click cho tất cả Toggles
for key, entry in pairs(entries) do
    entry.toggle.MouseButton1Click:Connect(function()
        local newState = not TogglesState[key]
        setToggleUI(key, newState)
        
        -- Chạy hành động với Anti-Lag delay
        task.spawn(function()
            task.wait(randDelay())
            if ToggleActions[key] then
                ToggleActions[key](newState)
            end
        end)
    end)
end

-- Gán sự kiện cho Nút
btnBoost.MouseButton1Click:Connect(function()
    applyBoostSafe()
    -- Cập nhật UI
    for key, entry in pairs(entries) do
        setToggleUI(key, true)
    end
end)

btnRestore.MouseButton1Click:Connect(function()
    task.spawn(function()
        task.wait(randDelay())
        revertSafe()
    end)
end)

-- (Phần Ngôn ngữ chưa được thêm vào UI, nhưng logic đã sẵn sàng)

-- Chạy Animation
animateIn(Main, 0.3) 

print("[PixelBlade VIP] Hệ thống đã tải. Ngôn ngữ:", Config.Language)
