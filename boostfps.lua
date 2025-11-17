-- BOOST FPS RAYFIELD-LIKE (MULTI-LANGUAGE + SMART ANTI-LAG + ANIMATION)
-- UI kiểu Rayfield-light; safe client-only; supports PC + Mobile touch
-- Languages: EN, VI, ES, PT, FR, TR, RU, KR, CN, JP

-- ====== CONFIG ======
local Config = {
    Theme = {
        Background = Color3.fromRGB(14, 22, 22),
        Panel = Color3.fromRGB(21, 30, 30),
        Accent = Color3.fromRGB(84, 176, 160), -- Xanh ngọc
        Text = Color3.fromRGB(230, 236, 235),
        SubText = Color3.fromRGB(160, 170, 168),
    },
    Language = "EN", -- Mặc định Tiếng Việt
    AntiBan = {
        MinDelay = 0.12,
        MaxDelay = 0.45,
        BatchSize = 40,
        Jitter = 0.08,
    },
    MobileScale = 1.0, -- Will auto adjust
}

-- ====== LANGUAGE STRINGS ======
local LANG = {
    EN = {
        Title = "Boost FPS | UltraSafe", Hint = "Tip: Turn off when spawning bosses", KillAura = "Remove Textures/Decals", AutoUpgrade = "Disable Particles/FX", SpeedBoost = "Lower Materials (Plastic)", Lighting = "Disable Lighting Effects", Mesh = "Strip Mesh Textures (LOD)", BoostAll = "BOOST MAX (Safe)", Restore = "Restore (Teleport)", Language = "Language",
    },
    VI = {
        Title = "Tăng FPS | An Toàn", Hint = "Lưu ý: Tắt khi Boss/Event spawn", KillAura = "Xóa Texture/Decal", AutoUpgrade = "Tắt Particles/Hiệu ứng FX", SpeedBoost = "Giảm Material (Plastic)", Lighting = "Tắt Hiệu Ứng Lighting", Mesh = "Xóa Texture Mesh (LOD)", BoostAll = "TĂNG MAX (An Toàn)", Restore = "Khôi phục (Teleport)", Language = "Ngôn ngữ",
    },
    ES = {
        Title = "Aumentar FPS | Seguro", Hint = "Consejo: Apaga al spawnear jefes", KillAura = "Eliminar Texturas", AutoUpgrade = "Desactivar Partículas", SpeedBoost = "Reducir Materiales", Lighting = "Desactivar Iluminación", Mesh = "Eliminar Texturas Mesh", BoostAll = "BOOST MÁX (Seguro)", Restore = "Restaurar (Teleport)", Language = "Idioma",
    },
    PT = {
        Title = "Aumentar FPS | Seguro", Hint = "Dica: Desligue ao spawnar bosses", KillAura = "Remover Texturas", AutoUpgrade = "Desativar Partículas", SpeedBoost = "Reduzir Materiais", Lighting = "Desativar Iluminação", Mesh = "Remover Texturas Mesh", BoostAll = "BOOST MÁX (Seguro)", Restore = "Restaurar (Teleport)", Language = "Idioma",
    },
    FR = {
        Title = "Boost FPS | Sûr", Hint = "Astuce : Désactivez lors de l'apparition des boss", KillAura = "Supprimer Textures", AutoUpgrade = "Désactiver Particules", SpeedBoost = "Réduire Matériaux", Lighting = "Désactiver Éclairage", Mesh = "Supprimer Textures Mesh", BoostAll = "BOOST MAX (Sûr)", Restore = "Restaurer (Teleport)", Language = "Langue",
    },
    TR = {
        Title = "FPS Arttır | Güvenli", Hint = "İpucu: Boss spawn olurken kapat", KillAura = "Doku Kaldır", AutoUpgrade = "Parçacıkları Kapat", SpeedBoost = "Malzemeleri Azalt", Lighting = "Işık Efektlerini Kapat", Mesh = "Mesh Texture Kaldır", BoostAll = "BOOST MAX (Güvenli)", Restore = "Geri Yükle (Teleport)", Language = "Dil",
    },
    RU = {
        Title = "Ускорить FPS | Безопасно", Hint = "Совет: Отключите при появлении босса", KillAura = "Удалить Текстуры", AutoUpgrade = "Отключить Частицы", SpeedBoost = "Уменьшить Материалы", Lighting = "Отключить Освещение", Mesh = "Удалить Текстуры Mesh", BoostAll = "BOOST MAX (Безопасно)", Restore = "Восстановить (Teleport)", Language = "Язык",
    },
    KR = {
        Title = "FPS 향상 | 안전", Hint = "팁: 보스 소환 시 끄세요", KillAura = "텍스쳐 제거", AutoUpgrade = "파티클 끄기", SpeedBoost = "재질 낮춤", Lighting = "조명 효과 끄기", Mesh = "메시 텍스쳐 제거", BoostAll = "최대 부스트 (안전)", Restore = "복원 (텔레포트)", Language = "언어",
    },
    CN = {
        Title = "提升 FPS | 安全", Hint = "提示：Boss 出现时请关闭", KillAura = "移除贴图", AutoUpgrade = "关闭粒子", SpeedBoost = "降低材质", Lighting = "关闭光照特效", Mesh = "移除 Mesh 贴图", BoostAll = "最大加速 (安全)", Restore = "恢复（传送）", Language = "语言",
    },
    JP = {
        Title = "FPS向上｜安全", Hint = "ヒント：ボス出現時はオフにしてね", KillAura = "テクスチャ削除", AutoUpgrade = "パーティクル無効", SpeedBoost = "マテリアル低減", Lighting = "ライティング無効", Mesh = "メッシュテクスチャ削除", BoostAll = "最大ブースト (安全)", Restore = "復元 (テレポート)", Language = "言語",
    },
}
local AvailableLanguages = {'VI', 'EN', 'ES', 'PT', 'FR', 'TR', 'RU', 'KR', 'CN', 'JP'}

-- ====== SERVICES & HELPERS ======
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

-- Anti-Lag/Jitter Delay
local function randDelay()
    local a = Config.AntiBan.MinDelay
    local b = Config.AntiBan.MaxDelay
    return a + math.random() * (b - a) + (math.random()-0.5) * Config.AntiBan.Jitter
end

-- Process large lists in batches to avoid spikes (action splitting)
local function batchProcess(list, worker)
    local batchSize = Config.AntiBan.BatchSize
    task.spawn(function()
        local i = 1
        while i <= #list do
            local endI = math.min(#list, i + batchSize - 1)
            for j = i, endI do
                -- Sử dụng task.spawn nhỏ để đảm bảo không có pcall nào bị treo
                task.spawn(function()
                    pcall(worker, list[j])
                end)
            end
            i = endI + 1
            task.wait(randDelay()) -- Phân tách hành động
        end
    end)
end

-- Detect mobile and scale UI
local function isMobile()
    return UIS.TouchEnabled and not UIS.KeyboardEnabled and not UIS.MouseEnabled
end

if isMobile() then
    Config.MobileScale = 1.2
else
    Config.MobileScale = 1.0
end

-- ====== SAFE ACTIONS (No destructive changes to gameplay) ======

local function shouldOptimize(instance)
    -- KHÔNG TỐI ƯU HÓA các thành phần quan trọng của người chơi (tránh gián đoạn giao diện/trang bị)
    return not instance:IsDescendantOf(LocalPlayer.Character or {})
        and not instance:IsDescendantOf(LocalPlayer:FindFirstChild("PlayerGui") or {})
        and not instance:IsDescendantOf(LocalPlayer:FindFirstChild("Backpack") or {})
end

-- Safe: Disable particle-type objects (disable, don't destroy)
local function disableEmittersSafe(root)
    local found = {}
    for _, v in ipairs(root:GetDescendants()) do
        if (v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Sparkles") or v:IsA("Fire") or v:IsA("Smoke")) and shouldOptimize(v) then
            table.insert(found, v)
        end
    end
    batchProcess(found, function(obj)
        obj.Enabled = false
    end)
end

-- Safe: Hide decals/textures by setting Transparency = 1 (KillAura)
local function hideDecalsSafe(root)
    local found = {}
    for _, v in ipairs(root:GetDescendants()) do
        if (v:IsA("Decal") or v:IsA("Texture") or v:IsA("SurfaceAppearance")) and shouldOptimize(v) then
            table.insert(found, v)
        end
    end
    batchProcess(found, function(obj)
        if obj:IsA("SurfaceAppearance") then
            -- Tắt SurfaceAppearance để hiển thị vật liệu mặc định
            Debris:AddItem(obj, 0) -- Xóa SurfaceAppearance một cách an toàn
        elseif obj.Transparency ~= nil then
            obj.Transparency = 1
        elseif obj.Texture then
            obj.Texture = "" -- Xóa Texture ID
        end
    end)
end

-- Safe: Set MeshPart textureID blank and set RenderFidelity to Performance (LOD)
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
        if mesh.RenderFidelity then
            mesh.RenderFidelity = Enum.RenderFidelity.Performance
        end
    end)
end

-- Safe: Reduce materials to SmoothPlastic and Reflectance = 0
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

-- Lighting + post-processing safe removal
local function optimizeLightingSafe()
    pcall(function()
        -- Tắt bóng đổ
        Lighting.GlobalShadows = false
        
        -- Cài đặt chất lượng đồ họa thấp nhất (Client Side Setting)
        settings().Rendering.QualityLevel = 1 
        settings().Rendering.AutomaticLevelOfDetail = true

        -- Xóa/Vô hiệu hóa các hiệu ứng nặng trong Lighting
        for _, eff in ipairs(Lighting:GetChildren()) do
            local cls = eff.ClassName
            if (cls == "BloomEffect" or cls == "SunRaysEffect" or cls == "ColorCorrectionEffect" or cls == "DepthOfFieldEffect" or cls == "AmbientOcclusion") then
                if eff.Enabled ~= nil then
                    pcall(function() eff.Enabled = false end)
                end
            end
        end
    end)
end

-- Combined apply sequence with smart anti-ban splitting and jitter
local function applyBoostSafe()
    task.spawn(function()
        -- sequence with small waits to mimic human actions
        task.wait(randDelay())
        hideDecalsSafe(workspace); task.wait(randDelay())
        disableEmittersSafe(workspace); task.wait(randDelay())
        optimizeMeshPartsSafe(workspace); task.wait(randDelay())
        reduceMaterialsSafe(workspace); task.wait(randDelay())
        optimizeLightingSafe()
    end)
end

-- Revert: Teleport is the safest way to revert most client-side graphic changes
local function revertSafe()
    pcall(function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
    end)
end

-- Toggles state table
local TogglesState = {
    texture = false,
    particles = false,
    materials = false,
    lighting = false,
    mesh = false,
}

-- The actual functions to run when toggled
local ToggleActions = {
    texture = function(state) if state then hideDecalsSafe(workspace) end end,
    particles = function(state) if state then disableEmittersSafe(workspace) end end,
    materials = function(state) if state then reduceMaterialsSafe(workspace) end end,
    lighting = function(state) if state then optimizeLightingSafe() end end,
    mesh = function(state) if state then optimizeMeshPartsSafe(workspace) end end,
}

-- ====== UI & ANIMATION LOGIC ======

-- Remove existing GUI if present
if game.CoreGui:FindFirstChild("BoostFPS_RayUI") then
    game.CoreGui:FindFirstChild("BoostFPS_RayUI"):Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BoostFPS_RayUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

-- Main window (Initial position OFF-SCREEN for animation)
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0.3, 0, 0.65, 0) -- Use scale for responsiveness
Main.Position = UDim2.new(-1, 0, 0.5, 0) -- Start off-screen (left)
Main.AnchorPoint = Vector2.new(0, 0.5) -- Anchor center-left
Main.BackgroundColor3 = Config.Theme.Panel
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = ScreenGui
Main.Active = true
Main.Draggable = true
Main.Visible = false -- Start invisible

-- Utility function to handle the opening animation
local function animateIn(uiFrame, duration)
    local targetPosition = UDim2.new(0.02, 0, 0.5, 0) -- End position: 2% from left, vertically centered
    
    if uiFrame then
        uiFrame.Visible = true
        
        -- Start with a small fade in
        uiFrame.Transparency = 1
        
        local info = TweenInfo.new(duration, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
        
        -- Tween position (Slide)
        TweenService:Create(uiFrame, info, {Position = targetPosition}):Play()

        -- Tween transparency (Fade)
        TweenService:Create(uiFrame, TweenInfo.new(duration/2), {BackgroundTransparency = 0.1}):Play()
    end
end

-- Header
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 48 * Config.MobileScale)
Header.BackgroundColor3 = Config.Theme.Background
Header.BorderSizePixel = 0

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(0.8, -12, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = LANG[Config.Language].Title
Title.TextColor3 = Config.Theme.Text
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.TextSize = 18

local LangBtn = Instance.new("TextButton", Header)
LangBtn.Size = UDim2.new(0.18, -12, 0.7, 0)
LangBtn.Position = UDim2.new(0.82, 6, 0.15, 0)
LangBtn.Text = LANG[Config.Language].Language
LangBtn.Font = Enum.Font.GothamSemibold
LangBtn.TextScaled = true
LangBtn.TextColor3 = Config.Theme.SubText
LangBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
LangBtn.BorderSizePixel = 0
LangBtn.TextSize = 14

-- Content area
local ContentPanel = Instance.new("Frame", Main)
ContentPanel.Size = UDim2.new(1, 0, 1, -48 * Config.MobileScale)
ContentPanel.Position = UDim2.new(0, 0, 0, 48 * Config.MobileScale)
ContentPanel.BackgroundTransparency = 1
ContentPanel.ClipsDescendants = true

local ScrollFrame = Instance.new("ScrollingFrame", ContentPanel)
ScrollFrame.Size = UDim2.new(1, 0, 1, -110 * Config.MobileScale)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 400) -- Will be updated dynamically
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.ScrollBarImageColor3 = Config.Theme.Accent
ScrollFrame.BorderSizePixel = 0

-- create content entry factory (label + toggle)
local function createEntry(parent, key, text, y)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -24, 0, 54 * Config.MobileScale)
    frame.Position = UDim2.new(0, 12, 0, 12 + (y-1) * (54 * Config.MobileScale + 6))
    frame.BackgroundTransparency = 1
    frame.Name = key

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.78, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Config.Theme.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextScaled = true

    local toggle = Instance.new("TextButton", frame)
    toggle.Size = UDim2.new(0.2, 0, 0.7, 0)
    toggle.Position = UDim2.new(0.78, 4, 0.15, 0)
    toggle.Text = ""
    toggle.BackgroundColor3 = Color3.fromRGB(40,40,40)
    toggle.BorderSizePixel = 0
    
    local padding = Instance.new("UIPadding", toggle)
    padding.PaddingTop = UDim.new(0.1, 0)
    padding.PaddingBottom = UDim.new(0.1, 0)
    padding.PaddingLeft = UDim.new(0.1, 0)
    padding.PaddingRight = UDim.new(0.1, 0)

    local indicator = Instance.new("Frame", toggle)
    indicator.Size = UDim2.new(0.45, 0, 0.7, 0)
    indicator.Position = UDim2.new(0.05, 0, 0.15, 0)
    indicator.BackgroundColor3 = Color3.fromRGB(180,180,180)
    indicator.Name = "ind"
    indicator.BorderSizePixel = 0
    indicator.AnchorPoint = Vector2.new(0, 0)
    
    return {frame=frame, label=label, toggle=toggle, indicator=indicator}
end

-- Entries in ScrollFrame
local entries = {}
entries.texture = createEntry(ScrollFrame, "texture", LANG[Config.Language].KillAura, 1)
entries.particles = createEntry(ScrollFrame, "particles", LANG[Config.Language].AutoUpgrade, 2)
entries.materials = createEntry(ScrollFrame, "materials", LANG[Config.Language].SpeedBoost, 3)
entries.lighting = createEntry(ScrollFrame, "lighting", LANG[Config.Language].Lighting, 4)
entries.mesh = createEntry(ScrollFrame, "mesh", LANG[Config.Language].Mesh, 5)

-- Update CanvasSize
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, (5 * (54 * Config.MobileScale + 6) + 12))

-- Buttons bottom
local btnBoost = Instance.new("TextButton", ContentPanel)
btnBoost.Size = UDim2.new(1, -24, 0, 48 * Config.MobileScale)
btnBoost.Position = UDim2.new(0, 12, 1, -50 * Config.MobileScale)
btnBoost.Text = LANG[Config.Language].BoostAll
btnBoost.BackgroundColor3 = Config.Theme.Accent
btnBoost.Font = Enum.Font.GothamBold
btnBoost.TextScaled = true
btnBoost.TextColor3 = Color3.fromRGB(12,12,12)
btnBoost.BorderSizePixel = 0

local btnRestore = Instance.new("TextButton", ContentPanel)
btnRestore.Size = UDim2.new(1, -24, 0, 36 * Config.MobileScale)
btnRestore.Position = UDim2.new(0, 12, 1, -94 * Config.MobileScale - 48 * Config.MobileScale)
btnRestore.Text = LANG[Config.Language].Restore
btnRestore.BackgroundColor3 = Color3.fromRGB(40,40,40)
btnRestore.Font = Enum.Font.Gotham
btnRestore.TextScaled = true
btnRestore.TextColor3 = Config.Theme.Text
btnRestore.BorderSizePixel = 0

-- Helper to toggle indicators visually with animation
local function setIndicator(ind, on)
    pcall(function()
        local targetX = on and 0.5 or 0.05
        local color = on and Config.Theme.Accent or Color3.fromRGB(180,180,180)
        
        TweenService:Create(ind, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(targetX, 0, 0.15, 0),
            BackgroundColor3 = color
        }):Play()
    end)
end

-- Initial indicators off
for key, entry in pairs(entries) do
    setIndicator(entry.indicator, false)
end

-- ====== INTERACTIONS & SMART DELAY BINDING ======
local debounce = {}

local function safeToggle(key, entry)
    if debounce[key] then return end
    debounce[key] = true
    
    TogglesState[key] = not TogglesState[key]
    local state = TogglesState[key]
    
    -- Small randomized delay before performing to mimic human click
    local d = randDelay()
    task.spawn(function()
        task.wait(d)
        
        -- Run the graphics action safely
        ToggleActions[key](state)
        
        -- Update UI
        setIndicator(entry.indicator, state)
        
        task.wait(0.08)
        debounce[key] = false
    end)
end

-- Bind entry toggles to safe actions
entries.texture.toggle.MouseButton1Click:Connect(function()
    safeToggle("texture", entries.texture)
end)
entries.particles.toggle.MouseButton1Click:Connect(function()
    safeToggle("particles", entries.particles)
end)
entries.materials.toggle.MouseButton1Click:Connect(function()
    safeToggle("materials", entries.materials)
end)
entries.lighting.toggle.MouseButton1Click:Connect(function()
    safeToggle("lighting", entries.lighting)
end)
entries.mesh.toggle.MouseButton1Click:Connect(function()
    safeToggle("mesh", entries.mesh)
end)

-- Boost All button: performs sequence with splitting and jitter
btnBoost.MouseButton1Click:Connect(function()
    if debounce["boost"] then return end
    debounce["boost"] = true
    applyBoostSafe()
    -- Update all toggles visually after boost is applied
    for key, entry in pairs(entries) do
        TogglesState[key] = true
        setIndicator(entry.indicator, true)
    end
    task.wait(0.6)
    debounce["boost"] = false
end)

btnRestore.MouseButton1Click:Connect(function()
    if debounce["restore"] then return end
    debounce["restore"] = true
    task.spawn(function()
        task.wait(randDelay())
        revertSafe()
        task.wait(0.6)
        debounce["restore"] = false
    end)
end)

-- Language selection popup (simple)
LangBtn.MouseButton1Click:Connect(function()
    if ScreenGui:FindFirstChild("LangMenu") then
        ScreenGui.LangMenu:Destroy()
        return
    end
    
    local menu = Instance.new("Frame", ScreenGui)
    menu.Name = "LangMenu"
    -- Kích thước tương đối dựa trên LangBtn
    menu.Size = UDim2.new(0, 160, 0, 34 * #AvailableLanguages) 
    menu.Position = UDim2.fromOffset(LangBtn.AbsolutePosition.X, LangBtn.AbsolutePosition.Y + LangBtn.AbsoluteSize.Y)
    menu.BackgroundColor3 = Config.Theme.Panel
    menu.BorderSizePixel = 0
    
    local idx = 0
    for _, code in ipairs(AvailableLanguages) do
        idx = idx + 1
        local b = Instance.new("TextButton", menu)
        b.Size = UDim2.new(1, -8, 0, 30)
        b.Position = UDim2.new(0, 4, 0, 2 + (idx-1) * 34)
        b.Text = code
        b.BackgroundColor3 = Color3.fromRGB(35,35,35)
        b.TextColor3 = Config.Theme.Text
        b.Font = Enum.Font.Gotham
        b.TextScaled = true
        b.MouseButton1Click:Connect(function()
            Config.Language = code
            
            -- Update all texts
            Title.Text = LANG[code].Title
            LangBtn.Text = LANG[code].Language
            btnBoost.Text = LANG[code].BoostAll
            btnRestore.Text = LANG[code].Restore
            
            entries.texture.label.Text = LANG[code].KillAura
            entries.particles.label.Text = LANG[code].AutoUpgrade
            entries.materials.label.Text = LANG[code].SpeedBoost
            entries.lighting.label.Text = LANG[code].Lighting
            entries.mesh.label.Text = LANG[code].Mesh
            
            menu:Destroy()
        end)
    end

    -- dismiss on outside click
    local conn
    conn = UIS.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            task.wait(0.1) -- wait for button to register
            if menu and menu.Parent then
                local mpos = UIS:GetMouseLocation()
                local rect = Rect.new(menu.AbsolutePosition, menu.AbsolutePosition + Vector2.new(menu.AbsoluteSize.X, menu.AbsoluteSize.Y))
                if not (mpos.X >= rect.Min.X and mpos.X <= rect.Max.X and mpos.Y >= rect.Min.Y and mpos.Y <= rect.Max.Y) then
                    menu:Destroy()
                    conn:Disconnect()
                end
            end
        end
    end)
end)

-- Execute the opening animation once the UI is ready
animateIn(Main, 0.4) -- 0.4 seconds animation time

-- print ready
print("[BoostFPS] Rayfield-like UI loaded with Animation. Language:", Config.Language)
