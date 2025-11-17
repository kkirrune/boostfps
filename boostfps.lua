-- BOOST FPS RAYFIELD-LIKE (MULTI-LANGUAGE + SMART ANTI-BAN)
-- UI kiểu Rayfield-light; safe client-only; supports PC + Mobile touch
-- Languages: EN, VI, ES, PT, FR, TR, RU, KR, CN, JP

-- ====== CONFIG ======
local Config = {
    Theme = {
        Background = Color3.fromRGB(14, 22, 22),
        Panel = Color3.fromRGB(21, 30, 30),
        Accent = Color3.fromRGB(84, 176, 160),
        Text = Color3.fromRGB(230, 236, 235),
        SubText = Color3.fromRGB(160, 170, 168),
    },
    Language = "EN", -- default language code
    AntiBan = {
        MinDelay = 0.12, -- base random delay seconds
        MaxDelay = 0.45,
        BatchSize = 40, -- how many objects processed per tick in heavy ops
        Jitter = 0.08, -- small random jitter to each button action
    },
    MobileScale = 1.0, -- multiplier for mobile (will auto adjust)
}

-- ====== LANGUAGE STRINGS ======
local LANG = {
    EN = {
        Title = "Boost FPS | UltraSafe",
        Hint = "Tip: Turn off when spawning bosses",
        KillAura = "Remove Textures",
        AutoUpgrade = "Disable Particles",
        SpeedBoost = "Lower Materials",
        Lighting = "Disable Lighting Effects",
        Mesh = "Strip Mesh Textures",
        BoostAll = "BOOST MAX (Safe)",
        Restore = "Restore (Teleport)",
        Language = "Language",
    },
    VI = {
        Title = "Tăng FPS | An Toàn",
        Hint = "Lưu ý: Tắt khi Boss spawn",
        KillAura = "Xóa Texture",
        AutoUpgrade = "Tắt Particles",
        SpeedBoost = "Giảm Material",
        Lighting = "Tắt Hiệu Ứng Lighting",
        Mesh = "Xóa Texture Mesh",
        BoostAll = "TĂNG MAX (An Toàn)",
        Restore = "Khôi phục (Teleport)",
        Language = "Ngôn ngữ",
    },
    ES = {
        Title = "Aumentar FPS | Seguro",
        Hint = "Consejo: Apaga al spawnear jefes",
        KillAura = "Eliminar Texturas",
        AutoUpgrade = "Desactivar Partículas",
        SpeedBoost = "Reducir Materiales",
        Lighting = "Desactivar Iluminación",
        Mesh = "Eliminar Texturas Mesh",
        BoostAll = "BOOST MÁX (Seguro)",
        Restore = "Restaurar (Teleport)",
        Language = "Idioma",
    },
    PT = {
        Title = "Aumentar FPS | Seguro",
        Hint = "Dica: Desligue ao spawnar bosses",
        KillAura = "Remover Texturas",
        AutoUpgrade = "Desativar Partículas",
        SpeedBoost = "Reduzir Materiais",
        Lighting = "Desativar Iluminação",
        Mesh = "Remover Texturas Mesh",
        BoostAll = "BOOST MÁX (Seguro)",
        Restore = "Restaurar (Teleport)",
        Language = "Idioma",
    },
    FR = {
        Title = "Boost FPS | Sûr",
        Hint = "Astuce : Désactivez lors de l'apparition des boss",
        KillAura = "Supprimer Textures",
        AutoUpgrade = "Désactiver Particules",
        SpeedBoost = "Réduire Matériaux",
        Lighting = "Désactiver Éclairage",
        Mesh = "Supprimer Textures Mesh",
        BoostAll = "BOOST MAX (Sûr)",
        Restore = "Restaurer (Teleport)",
        Language = "Langue",
    },
    TR = {
        Title = "FPS Arttır | Güvenli",
        Hint = "İpucu: Boss spawn olurken kapat",
        KillAura = "Doku Kaldır",
        AutoUpgrade = "Parçacıkları Kapat",
        SpeedBoost = "Malzemeleri Azalt",
        Lighting = "Işık Efektlerini Kapat",
        Mesh = "Mesh Texture Kaldır",
        BoostAll = "BOOST MAX (Güvenli)",
        Restore = "Geri Yükle (Teleport)",
        Language = "Dil",
    },
    RU = {
        Title = "Ускорить FPS | Безопасно",
        Hint = "Совет: Отключите при появлении босса",
        KillAura = "Удалить Текстуры",
        AutoUpgrade = "Отключить Частицы",
        SpeedBoost = "Уменьшить Материалы",
        Lighting = "Отключить Освещение",
        Mesh = "Удалить Текстуры Mesh",
        BoostAll = "BOOST MAX (Безопасно)",
        Restore = "Восстановить (Teleport)",
        Language = "Язык",
    },
    KR = {
        Title = "FPS 향상 | 안전",
        Hint = "팁: 보스 소환 시 끄세요",
        KillAura = "텍스쳐 제거",
        AutoUpgrade = "파티클 끄기",
        SpeedBoost = "재질 낮춤",
        Lighting = "조명 효과 끄기",
        Mesh = "메시 텍스쳐 제거",
        BoostAll = "최대 부스트 (안전)",
        Restore = "복원 (텔레포트)",
        Language = "언어",
    },
    CN = {
        Title = "提升 FPS | 安全",
        Hint = "提示：Boss 出现时请关闭",
        KillAura = "移除贴图",
        AutoUpgrade = "关闭粒子",
        SpeedBoost = "降低材质",
        Lighting = "关闭光照特效",
        Mesh = "移除 Mesh 贴图",
        BoostAll = "最大加速 (安全)",
        Restore = "恢复（传送）",
        Language = "语言",
    },
    JP = {
        Title = "FPS向上｜安全",
        Hint = "ヒント：ボス出現時はオフにしてね",
        KillAura = "テクスチャ削除",
        AutoUpgrade = "パーティクル無効",
        SpeedBoost = "マテリアル低減",
        Lighting = "ライティング無効",
        Mesh = "メッシュテクスチャ削除",
        BoostAll = "最大ブースト (安全)",
        Restore = "復元 (テレポート)",
        Language = "言語",
    },
}

-- ====== SERVICES & HELPERS ======
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")

local function randDelay()
    local a = Config.AntiBan.MinDelay
    local b = Config.AntiBan.MaxDelay
    return a + math.random() * (b - a) + (math.random()-0.5) * Config.AntiBan.Jitter
end

local function safePcall(fn, ...)
    local ok, res = pcall(fn, ...)
    return ok, res
end

-- process large lists in batches to avoid spikes (action splitting)
local function batchProcess(list, batchSize, worker)
    batchSize = math.max(1, batchSize or Config.AntiBan.BatchSize)
    spawn(function()
        local i = 1
        while i <= #list do
            local endI = math.min(#list, i + batchSize - 1)
            for j = i, endI do
                pcall(worker, list[j])
            end
            i = endI + 1
            task.wait(randDelay()) -- spaced
        end
    end)
end

-- detect mobile and scale UI
local function isMobile()
    return UIS.TouchEnabled and not UIS.KeyboardEnabled
end

if isMobile() then
    Config.MobileScale = 1.15
else
    Config.MobileScale = 1.0
end

-- ====== SAFE ACTIONS (no destructive for gameplay) ======

-- safe: disable particle-type objects (disable, don't destroy)
local function disableEmittersSafe(root)
    local found = {}
    for _, v in ipairs(root:GetDescendants()) do
        if (v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam")
            or v:IsA("Sparkles") or v:IsA("Fire") or v:IsA("Smoke")) then
            table.insert(found, v)
        end
    end
    batchProcess(found, Config.AntiBan.BatchSize, function(obj)
        pcall(function() obj.Enabled = false end)
    end)
end

-- safe: hide decals/textures by setting Transparency = 1 if not essential (not in PlayerGui/Character)
local function hideDecalsSafe(root)
    local found = {}
    for _, v in ipairs(root:GetDescendants()) do
        if (v:IsA("Decal") or v:IsA("Texture")) and not v:IsDescendantOf(LocalPlayer.Character or {}) and not v:IsDescendantOf(LocalPlayer:FindFirstChild("PlayerGui") or {}) then
            table.insert(found, v)
        end
    end
    batchProcess(found, math.max(10, Config.AntiBan.BatchSize//4), function(obj)
        pcall(function()
            if obj.Transparency ~= nil then
                obj.Transparency = 1
            else
                -- fallback: try to clear texture id for decals (if available)
                pcall(function() if obj.Texture then obj.Texture = "" end end)
            end
        end)
    end)
end

-- safe: set MeshPart textureID blank and set RenderFidelity to Performance if available
local function optimizeMeshPartsSafe(root)
    local found = {}
    for _, v in ipairs(root:GetDescendants()) do
        if v:IsA("MeshPart") and not v:IsDescendantOf(LocalPlayer.Character or {}) then
            table.insert(found, v)
        end
    end
    batchProcess(found, math.max(8, Config.AntiBan.BatchSize//5), function(mesh)
        pcall(function()
            if mesh.TextureID and mesh.TextureID ~= "" then
                mesh.TextureID = ""
            end
            if mesh.RenderFidelity then
                pcall(function() mesh.RenderFidelity = Enum.RenderFidelity.Performance end)
            end
        end)
    end)
end

-- safe: reduce materials to SmoothPlastic for parts not in Character/PlayerGui/Backpack/Tools
local function reduceMaterialsSafe(root)
    local found = {}
    for _, v in ipairs(root:GetDescendants()) do
        if v:IsA("BasePart") and not v:IsDescendantOf(LocalPlayer.Character or {}) and not v:IsDescendantOf(LocalPlayer:FindFirstChild("PlayerGui") or {}) then
            table.insert(found, v)
        end
    end
    batchProcess(found, Config.AntiBan.BatchSize, function(part)
        pcall(function() part.Material = Enum.Material.SmoothPlastic part.Reflectance = 0 end)
    end)
end

-- lighting + postprocessing safe removal
local function optimizeLightingSafe()
    local changes = {}
    pcall(function()
        -- record some lighting states in local table (not exposing outside)
        changes.GlobalShadows = Lighting.GlobalShadows
        changes.Brightness = Lighting.Brightness
        changes.FogEnd = Lighting.FogEnd
        -- apply safe modifications
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 1e8
        Lighting.Brightness = math.clamp((Lighting.Brightness or 2) * 0.6, 0, 10)
        -- remove heavy post effects under Lighting (destroy if safe, but we only disable common ones)
        for _, eff in ipairs(Lighting:GetChildren()) do
            local cls = eff.ClassName
            if (cls == "BloomEffect" or cls == "SunRaysEffect" or cls == "ColorCorrectionEffect" or cls == "DepthOfFieldEffect" or cls == "AmbientOcclusion") then
                pcall(function()
                    if eff.Enabled ~= nil then eff.Enabled = false end
                end)
            end
        end
    end)
end

-- combined apply sequence with smart anti-ban splitting and jitter
local function applyBoostSafe()
    -- sequence with small waits to mimic human actions
    spawn(function()
        task.wait(randDelay())
        hideDecalsSafe(workspace)
        task.wait(randDelay())
        disableEmittersSafe(workspace)
        task.wait(randDelay())
        optimizeMeshPartsSafe(workspace)
        task.wait(randDelay())
        reduceMaterialsSafe(workspace)
        task.wait(randDelay())
        optimizeLightingSafe()
    end)
end

-- revert best-effort: teleport is safest in many games
local function revertSafe()
    pcall(function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
    end)
end

-- ====== UI (Rayfield-like simple) ======
-- Remove existing GUI if present
if game.CoreGui:FindFirstChild("BoostFPS_RayUI") then
    game.CoreGui:FindFirstChild("BoostFPS_RayUI"):Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BoostFPS_RayUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

-- Main window
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 420 * Config.MobileScale, 0, 420 * Config.MobileScale)
Main.Position = UDim2.new(0.05, 0, 0.18, 0)
Main.AnchorPoint = Vector2.new(0, 0)
Main.BackgroundColor3 = Config.Theme.Panel
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = ScreenGui
Main.Active = true
Main.Draggable = true

-- Header
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 58 * Config.MobileScale)
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

local LangBtn = Instance.new("TextButton", Header)
LangBtn.Size = UDim2.new(0.18, -12, 0.6, 0)
LangBtn.Position = UDim2.new(0.82, 6, 0.2, 0)
LangBtn.Text = LANG[Config.Language].Language
LangBtn.Font = Enum.Font.GothamSemibold
LangBtn.TextScaled = true
LangBtn.TextColor3 = Config.Theme.SubText
LangBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
LangBtn.BorderSizePixel = 0
LangBtn.AutoButtonColor = true

-- Content area (left tab + right panel)
local LeftPanel = Instance.new("Frame", Main)
LeftPanel.Size = UDim2.new(0, 140 * Config.MobileScale, 1, -58 * Config.MobileScale)
LeftPanel.Position = UDim2.new(0, 0, 0, 58 * Config.MobileScale)
LeftPanel.BackgroundTransparency = 1

local RightPanel = Instance.new("Frame", Main)
RightPanel.Size = UDim2.new(1, -140 * Config.MobileScale, 1, -58 * Config.MobileScale)
RightPanel.Position = UDim2.new(0, 140 * Config.MobileScale, 0, 58 * Config.MobileScale)
RightPanel.BackgroundTransparency = 1

-- create simple tab button factory
local function tabButton(text, y)
    local b = Instance.new("TextButton", LeftPanel)
    b.Size = UDim2.new(1, -12, 0, 44 * Config.MobileScale)
    b.Position = UDim2.new(0, 6, 0, 10 + (y-1) * (44 * Config.MobileScale + 6))
    b.BackgroundColor3 = Color3.fromRGB(28, 36, 36)
    b.Text = text
    b.TextColor3 = Config.Theme.Text
    b.Font = Enum.Font.GothamSemibold
    b.TextScaled = true
    b.BorderSizePixel = 0
    return b
end

-- create content entry factory (label + toggle)
local function createEntry(parent, text, y)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -24, 0, 54 * Config.MobileScale)
    frame.Position = UDim2.new(0, 12, 0, 12 + (y-1) * (54 * Config.MobileScale + 6))
    frame.BackgroundTransparency = 1

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

    local indicator = Instance.new("Frame", toggle)
    indicator.Size = UDim2.new(0.45, 0, 0.7, 0)
    indicator.Position = UDim2.new(0.05, 0, 0.15, 0)
    indicator.BackgroundColor3 = Color3.fromRGB(180,180,180)
    indicator.Name = "ind"
    indicator.BorderSizePixel = 0
    indicator.AnchorPoint = Vector2.new(0, 0)

    return {frame=frame, label=label, toggle=toggle, indicator=indicator}
end

-- Tab buttons & entries
local tabMain = tabButton(LANG[Config.Language].Title, 1)

-- Entries in right panel
local entries = {}
entries[1] = createEntry(RightPanel, LANG[Config.Language].KillAura, 1)
entries[2] = createEntry(RightPanel, LANG[Config.Language].AutoUpgrade, 2)
entries[3] = createEntry(RightPanel, LANG[Config.Language].SpeedBoost, 3)
entries[4] = createEntry(RightPanel, LANG[Config.Language].Lighting, 4)
entries[5] = createEntry(RightPanel, LANG[Config.Language].Mesh, 5)

-- Buttons bottom
local btnBoost = Instance.new("TextButton", RightPanel)
btnBoost.Size = UDim2.new(1, -24, 0, 48 * Config.MobileScale)
btnBoost.Position = UDim2.new(0, 12, 1, -56 * Config.MobileScale)
btnBoost.Text = LANG[Config.Language].BoostAll
btnBoost.BackgroundColor3 = Config.Theme.Accent
btnBoost.Font = Enum.Font.GothamBold
btnBoost.TextScaled = true
btnBoost.TextColor3 = Color3.fromRGB(12,12,12)
btnBoost.BorderSizePixel = 0

local btnRestore = Instance.new("TextButton", RightPanel)
btnRestore.Size = UDim2.new(1, -24, 0, 36 * Config.MobileScale)
btnRestore.Position = UDim2.new(0, 12, 1, -100 * Config.MobileScale)
btnRestore.Text = LANG[Config.Language].Restore
btnRestore.BackgroundColor3 = Color3.fromRGB(40,40,40)
btnRestore.Font = Enum.Font.Gotham
btnRestore.TextScaled = true
btnRestore.TextColor3 = Config.Theme.Text
btnRestore.BorderSizePixel = 0

-- helper to toggle indicators visually with small animation-like behavior
local function setIndicator(ind, on)
    pcall(function()
        if on then
            ind:TweenPosition(UDim2.new(0.5, 0, 0.15, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.12, true)
            ind.BackgroundColor3 = Config.Theme.Accent
        else
            ind:TweenPosition(UDim2.new(0.05, 0, 0.15, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.12, true)
            ind.BackgroundColor3 = Color3.fromRGB(180,180,180)
        end
    end)
end

-- initial indicators off
for i=1,#entries do
    setIndicator(entries[i].indicator, false)
end

-- ====== INTERACTIONS & SMART DELAY BINDING ======
local toggles = {false, false, false, false, false}
local debounce = {}

local function safeToggle(index, actionFunc)
    if debounce[index] then return end
    debounce[index] = true
    -- small randomized delay before performing to mimic human click
    local d = randDelay()
    task.spawn(function()
        task.wait(d)
        pcall(actionFunc)
        toggles[index] = not toggles[index]
        setIndicator(entries[index].indicator, toggles[index])
        task.wait(0.08)
        debounce[index] = false
    end)
end

-- bind entry toggles to safe actions
entries[1].toggle.MouseButton1Click:Connect(function()
    safeToggle(1, function() hideDecalsSafe(workspace) end)
end)
entries[2].toggle.MouseButton1Click:Connect(function()
    safeToggle(2, function() disableEmittersSafe(workspace) end)
end)
entries[3].toggle.MouseButton1Click:Connect(function()
    safeToggle(3, function() reduceMaterialsSafe(workspace) end)
end)
entries[4].toggle.MouseButton1Click:Connect(function()
    safeToggle(4, function() optimizeLightingSafe() end)
end)
entries[5].toggle.MouseButton1Click:Connect(function()
    safeToggle(5, function() optimizeMeshPartsSafe(workspace) end)
end)

-- Boost All button: perform sequence with splitting and jitter
btnBoost.MouseButton1Click:Connect(function()
    if debounce["boost"] then return end
    debounce["boost"] = true
    spawn(function()
        -- action splitting: call each action with delay to reduce detection
        hideDecalsSafe(workspace); task.wait(randDelay())
        disableEmittersSafe(workspace); task.wait(randDelay())
        optimizeMeshPartsSafe(workspace); task.wait(randDelay())
        reduceMaterialsSafe(workspace); task.wait(randDelay())
        optimizeLightingSafe(); task.wait(randDelay())
        debounce["boost"] = false
    end)
end)

btnRestore.MouseButton1Click:Connect(function()
    if debounce["restore"] then return end
    debounce["restore"] = true
    spawn(function()
        task.wait(randDelay())
        revertSafe()
        task.wait(0.6)
        debounce["restore"] = false
    end)
end)

-- Language selection popup (simple)
LangBtn.MouseButton1Click:Connect(function()
    -- small menu
    if ScreenGui:FindFirstChild("LangMenu") then
        ScreenGui.LangMenu:Destroy()
        return
    end
    local menu = Instance.new("Frame", ScreenGui)
    menu.Name = "LangMenu"
    menu.Size = UDim2.new(0, 160, 0, 240)
    menu.Position = LangBtn.AbsolutePosition + Vector2.new(0, LangBtn.AbsoluteSize.Y)
    menu.BackgroundColor3 = Config.Theme.Panel
    menu.BorderSizePixel = 0

    local idx = 0
    for code, _ in pairs(LANG) do
        idx = idx + 1
        local b = Instance.new("TextButton", menu)
        b.Size = UDim2.new(1, -8, 0, 30)
        b.Position = UDim2.new(0, 4, 0, 6 + (idx-1) * 34)
        b.Text = code
        b.BackgroundColor3 = Color3.fromRGB(35,35,35)
        b.TextColor3 = Config.Theme.Text
        b.Font = Enum.Font.Gotham
        b.TextScaled = true
        b.MouseButton1Click:Connect(function()
            Config.Language = code
            -- update texts
            Title.Text = LANG[code].Title
            entries[1].label.Text = LANG[code].KillAura
            entries[2].label.Text = LANG[code].AutoUpgrade
            entries[3].label.Text = LANG[code].SpeedBoost
            entries[4].label.Text = LANG[code].Lighting
            entries[5].label.Text = LANG[code].Mesh
            btnBoost.Text = LANG[code].BoostAll
            btnRestore.Text = LANG[code].Restore
            LangBtn.Text = LANG[code].Language
            menu:Destroy()
        end)
    end

    -- dismiss on outside click
    local conn
    conn = UIS.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            if menu and not menu:IsDescendantOf(game.CoreGui) then return end
            if not menu then return end
            local mpos = UIS:GetMouseLocation()
            local rect = Rect.new(menu.AbsolutePosition, menu.AbsolutePosition + Vector2.new(menu.AbsoluteSize.X, menu.AbsoluteSize.Y))
            if not (mpos.X >= rect.Min.X and mpos.X <= rect.Max.X and mpos.Y >= rect.Min.Y and mpos.Y <= rect.Max.Y) then
                menu:Destroy()
                conn:Disconnect()
            end
        end
    end)
end)

-- small mobile friendly adjustments (bigger buttons, auto layout)
if isMobile() then
    Main.Position = UDim2.new(0.02, 0, 0.08, 0)
    Main.Size = UDim2.new(0, 360, 0, 480)
    for _, obj in ipairs(Main:GetDescendants()) do
        if obj:IsA("TextButton") or obj:IsA("TextLabel") then
            pcall(function() obj.TextSize = math.max(14, (obj.TextSize or 14) * 1.05) end)
        end
    end
end

-- print ready
print("[BoostFPS] Rayfield-like UI loaded. Language:", Config.Language)
