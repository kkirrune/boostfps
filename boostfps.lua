-- BoostFPS Hub — Full Multilingual + VIP Safe Anti-Crash
-- LƯU Ý QUAN TRỌNG: Script này KHÔNG hỗ trợ né ban/anti-cheat. "Anti-Ban" theo nghĩa né ban sẽ bị từ chối.
-- Thay vào đó cung cấp "VIP Safe Mode" = Aggressive visual reduction + Auto GC/ClearCache + Adaptive throttling (KHÔNG phá gameplay).

-- ========== Cấu hình chính ==========
local Config = {
    Theme = {
        Background = Color3.fromRGB(20,20,20),
        Panel = Color3.fromRGB(36,36,36),
        Accent = Color3.fromRGB(80,200,255),
        ToggleON = Color3.fromRGB(76,175,80),
        ToggleOFF = Color3.fromRGB(75,85,99),
        Text = Color3.fromRGB(235,235,235),
    },
    AntiBan = { -- (chỉ là tên) delays/jitter để tránh spam thao tác lớn
        MinDelay = 0.02,
        MaxDelay = 0.08,
        BatchSize = 120,
        Jitter = 0.02,
    },
    DefaultRenderDistance = workspace:FindFirstChild("StreamingTargetRadius") and workspace.StreamingTargetRadius or 512,
    AntiCrashInterval = 30, -- giây
    IsVIP = false, -- đặt true nếu bạn là VIP (chỉ mở thêm tùy chọn "aggressive safe reduction")
}

-- ========== HỖ TRỢ NGÔN NGỮ (locales) ==========
-- Mẫu: hỗ trợ nhiều locale. Thêm locale mới bằng cách thêm table LANGS["<locale>"] = { ... }
-- Mình đưa sẵn một tập ngôn ngữ phổ biến. Bạn có thể mở rộng.
local LANGS = {
    ["en"] = {
        Title="BoostFPS Hub (Safe)",
        Hint="Safe optimizations. PC & Mobile.",
        BoostAll="APPLY MAX BOOST (SAFE)",
        Restore="RESTORE",
        FPS="FPS: %d",
        RenderValue="Render Radius: %d",
        AntiCrashOn="[AntiCrash] Enabled",
        AntiCrashDo="[AntiCrash] Cleared cache + GC",
        AggressiveOn="[VIP] Aggressive Safe Mode ON",
    },
    ["vi"] = {
        Title="BoostFPS Hub (An toàn)",
        Hint="Tối ưu an toàn. Chạy trên PC & Mobile.",
        BoostAll="BẬT TĂNG TỐI ĐA (AN TOÀN)",
        Restore="KHÔI PHỤC",
        FPS="FPS: %d",
        RenderValue="Khoảng cách render: %d",
        AntiCrashOn="[AntiCrash] Bật",
        AntiCrashDo="[AntiCrash] Clear cache + GC",
        AggressiveOn="[VIP] Chế độ giảm mạnh (AN TOÀN) BẬT",
    },
    ["es"] = { Title="BoostFPS Hub (Seguro)", Hint="Optimizaciones seguras.", BoostAll="APLICAR MÁXIMO", Restore="RESTABLECER", FPS="FPS: %d", RenderValue="Radio Render: %d", AntiCrashOn="[AntiCrash] Activado", AntiCrashDo="[AntiCrash] Caché limpiada", AggressiveOn="[VIP] Modo agresivo ON" },
    ["fr"] = { Title="BoostFPS Hub (Sûr)", Hint="Optimisations sûres.", BoostAll="APPLIQUER MAX", Restore="RÉTABLIR", FPS="FPS: %d", RenderValue="Distance rendu: %d", AntiCrashOn="[AntiCrash] Activé", AntiCrashDo="[AntiCrash] Cache nettoyée", AggressiveOn="[VIP] Mode agressif ON" },
    ["de"] = { Title="BoostFPS Hub (Sicher)", Hint="Sichere Optimierungen.", BoostAll="MAX ANWENDEN", Restore="WIEDERHERSTELLEN", FPS="FPS: %d", RenderValue="Render Radius: %d", AntiCrashOn="[AntiCrash] Aktiv", AntiCrashDo="[AntiCrash] Cache geleert", AggressiveOn="[VIP] Aggressivmodus ON" },
    ["pt"] = { Title="BoostFPS Hub (Seguro)", Hint="Otimizações seguras.", BoostAll="APLICAR MÁXIMO", Restore="RESTAURAR", FPS="FPS: %d", RenderValue="Raio Render: %d", AntiCrashOn="[AntiCrash] Ativado", AntiCrashDo="[AntiCrash] Cache limpa", AggressiveOn="[VIP] Modo agressivo ON" },
    ["ru"] = { Title="BoostFPS Hub (Безопасно)", Hint="Безопасная оптимизация.", BoostAll="ПРИМЕНИТЬ МАКСИМАЛЬНО", Restore="ВОССТАНОВИТЬ", FPS="FPS: %d", RenderValue="Радиус рендера: %d", AntiCrashOn="[AntiCrash] Включено", AntiCrashDo="[AntiCrash] Кэш очищен", AggressiveOn="[VIP] Агрессивный режим ON" },
    ["zh"] = { Title="BoostFPS Hub（安全）", Hint="安全优化。支持移动与PC。", BoostAll="应用最大优化", Restore="恢复", FPS="FPS: %d", RenderValue="渲染半径: %d", AntiCrashOn="[AntiCrash] 已启用", AntiCrashDo="[AntiCrash] 已清除缓存", AggressiveOn="[VIP] 激进模式 ON" },
    ["ja"] = { Title="BoostFPS Hub (安全)", Hint="安全な最適化。", BoostAll="最大ブースト適用", Restore="復元", FPS="FPS: %d", RenderValue="レンダ距離: %d", AntiCrashOn="[AntiCrash] 有効", AntiCrashDo="[AntiCrash] キャッシュクリア", AggressiveOn="[VIP] アグレッシブON" },
    ["ko"] = { Title="BoostFPS Hub (안전)", Hint="안전한 최적화.", BoostAll="최대 부스트 적용", Restore="복구", FPS="FPS: %d", RenderValue="렌더 반경: %d", AntiCrashOn="[AntiCrash] 활성화", AntiCrashDo="[AntiCrash] 캐시 삭제", AggressiveOn="[VIP] 공격적 모드 ON" },
    ["ar"] = { Title="BoostFPS Hub (آمن)", Hint="تحسينات آمنة.", BoostAll="تطبيق أقصى تحسين", Restore="استعادة", FPS="FPS: %d", RenderValue="نطاق العرض: %d", AntiCrashOn="[AntiCrash] مفعل", AntiCrashDo="[AntiCrash] تم تنظيف الكاش", AggressiveOn="[VIP] الوضع العدواني ON" },
    -- Add more locales if needed...
}

-- Helper: lấy ngôn ngữ hiện tại (dựa trên UserLocale của client nếu có)
local function getLocaleKey()
    local success, locale = pcall(function() return game:GetService("LocalizationService"):GetCountryRegionForPlayerAsync(game.Players.LocalPlayer) end)
    if success and locale then
        locale = tostring(locale):lower()
        if LANGS[locale] then return locale end
    end
    -- fallback: dùng UserLocaleId (en, vi, etc)
    local ok, userLocale = pcall(function() return game:GetService("LocalizationService").RobloxLocaleId end)
    if ok and userLocale then
        local simple = tostring(userLocale):sub(1,2)
        if LANGS[simple] then return simple end
    end
    return "en"
end

local LOCALE = getLocaleKey()
local L = LANGS[LOCALE] or LANGS["en"]

-- ========== Services & State ==========
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local ContentProvider = game:GetService("ContentProvider")
local Debris = game:GetService("Debris")
local CollectionService = game:GetService("CollectionService")

local Toggles = {}
local Entries = {}
local originalStates = {} -- lưu trạng thái gốc
local modifiedList = {}
local antiCrashThread = nil
local fpsConnection = nil

-- ========== Utility ==========
local function randDelay()
    local a,b = Config.AntiBan.MinDelay, Config.AntiBan.MaxDelay
    return a + math.random()*(b-a) + (math.random()-0.5)*Config.AntiBan.Jitter
end

local function batchProcess(list, worker)
    task.spawn(function()
        local i = 1
        local bs = Config.AntiBan.BatchSize
        while i <= #list do
            local endI = math.min(#list, i + bs - 1)
            for j = i, endI do
                pcall(worker, list[j])
            end
            i = endI + 1
            task.wait(randDelay())
        end
    end)
end

-- Kiểm tra bảo vệ (KHÔNG tối ưu) — tránh phá hitbox/damage
local function isProtected(inst)
    if not inst then return false end
    if inst:IsDescendantOf(LocalPlayer.Character or {}) then return true end -- skip local player's own
    if CollectionService:HasTag(inst, "Preserve") then return true end
    local nm = tostring(inst.Name):lower()
    if nm:find("hit") or nm:find("hurt") or nm:find("damage") or nm:find("hitbox") or nm:find("hurtbox") or nm:find("projectile") then
        return true
    end
    local ok, attr = pcall(function() return inst:GetAttribute("NoOptimize") end)
    if ok and attr then return true end
    return false
end

local function saveOriginal(inst, props)
    if not inst then return end
    if originalStates[inst] then return end
    originalStates[inst] = {}
    for _,p in ipairs(props) do
        pcall(function() originalStates[inst][p] = inst[p] end)
    end
    table.insert(modifiedList, inst)
end

local function restoreAll()
    for _, inst in ipairs(modifiedList) do
        local orig = originalStates[inst]
        if orig and inst and inst.Parent then
            pcall(function()
                for k,v in pairs(orig) do
                    inst[k] = v
                end
            end)
        end
    end
    -- restore lighting special props
    pcall(function()
        if originalStates["_Lighting_GlobalShadows"] ~= nil then Lighting.GlobalShadows = originalStates["_Lighting_GlobalShadows"] end
        if originalStates["_Lighting_FogEnd"] ~= nil then Lighting.FogEnd = originalStates["_Lighting_FogEnd"] end
        if originalStates["_Lighting_AtmosphereDensity"] ~= nil and Lighting:FindFirstChild("Atmosphere") then Lighting.Atmosphere.Density = originalStates["_Lighting_AtmosphereDensity"] end
    end)
    originalStates = {}
    modifiedList = {}
    print("[BoostFPS] Restore attempted. Một số thay đổi (clear cache) có thể cần rejoin.")
end

-- ========== Tính năng giảm đồ họa mở rộng (safe) ==========
local function disableParticles(root)
    local found = {}
    for _,v in ipairs(root:GetDescendants()) do
        if (v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Sparkles") or v:IsA("Smoke") or v:IsA("Fire")) and not isProtected(v) then
            table.insert(found, v)
        end
    end
    batchProcess(found, function(obj)
        saveOriginal(obj, {"Enabled"})
        pcall(function() obj.Enabled = false end)
    end)
end

local function disableLights(root)
    local found = {}
    for _,v in ipairs(root:GetDescendants()) do
        if v:IsA("Light") and not isProtected(v) then table.insert(found, v) end
    end
    batchProcess(found, function(light)
        saveOriginal(light, {"Enabled"})
        pcall(function() light.Enabled = false end)
    end)
end

local function hideDecalsTextures(root)
    local found = {}
    for _,v in ipairs(root:GetDescendants()) do
        if (v:IsA("Decal") or v:IsA("Texture") or v:IsA("SurfaceAppearance")) and not isProtected(v) then table.insert(found, v) end
    end
    batchProcess(found, function(obj)
        if obj:IsA("SurfaceAppearance") then
            saveOriginal(obj, {"AlbedoColor", "Roughness", "Metalness"})
            pcall(function() obj.AlbedoColor = Color3.new(0.5,0.5,0.5); if obj:FindFirstChild("ColorMap") then obj.ColorMap = "" end end)
        else
            saveOriginal(obj, {"Transparency"})
            pcall(function() obj.Transparency = 1 end)
        end
    end)
end

local function reduceMaterials(root)
    local found = {}
    for _,v in ipairs(root:GetDescendants()) do
        if v:IsA("BasePart") and not isProtected(v) then table.insert(found, v) end
    end
    batchProcess(found, function(part)
        saveOriginal(part, {"Material", "Reflectance"})
        pcall(function() part.Material = Enum.Material.SmoothPlastic; part.Reflectance = 0 end)
    end)
end

local function optimizeMeshParts(root)
    local found = {}
    for _,v in ipairs(root:GetDescendants()) do
        if v:IsA("MeshPart") and not isProtected(v) then table.insert(found, v) end
    end
    batchProcess(found, function(mesh)
        saveOriginal(mesh, {"TextureID", "RenderFidelity"})
        pcall(function() mesh.TextureID = ""; mesh.RenderFidelity = Enum.RenderFidelity.Performance end)
    end)
end

local function disablePostProcessing()
    local effects = {}
    for _,eff in ipairs(Lighting:GetChildren()) do
        local cls = eff.ClassName
        if (cls == "BloomEffect" or cls == "SunRaysEffect" or cls == "ColorCorrectionEffect" or cls == "DepthOfFieldEffect" or cls == "BlurEffect" or cls == "AmbientOcclusion") then
            table.insert(effects, eff)
        end
    end
    for _,e in ipairs(effects) do
        saveOriginal(e, {"Enabled"})
        pcall(function() e.Enabled = false end)
    end
end

local function disableFog(state)
    pcall(function()
        if originalStates["_Lighting_FogEnd"] == nil then originalStates["_Lighting_FogEnd"] = Lighting.FogEnd end
        if Lighting:FindFirstChild("Atmosphere") and originalStates["_Lighting_AtmosphereDensity"] == nil then originalStates["_Lighting_AtmosphereDensity"] = Lighting.Atmosphere.Density end
        if state then
            Lighting.FogEnd = 1e6
            if Lighting:FindFirstChild("Atmosphere") then Lighting.Atmosphere.Density = 0 end
        else
            Lighting.FogEnd = originalStates["_Lighting_FogEnd"] or 1000
            if Lighting:FindFirstChild("Atmosphere") then Lighting.Atmosphere.Density = originalStates["_Lighting_AtmosphereDensity"] or 0.35 end
        end
    end)
end

local function disableShadows(state)
    pcall(function()
        if originalStates["_Lighting_GlobalShadows"] == nil then originalStates["_Lighting_GlobalShadows"] = Lighting.GlobalShadows end
        Lighting.GlobalShadows = not state
    end)
end

local function reduceWater()
    pcall(function()
        if Lighting:FindFirstChild("WaterReflection") then
            saveOriginal(Lighting, {"WaterReflectance","WaterWaveSize","WaterWaveSpeed"})
            Lighting.WaterReflectance = 0
            Lighting.WaterWaveSize = 0
            Lighting.WaterWaveSpeed = 0
        else
            -- try safe properties
            pcall(function() Lighting.WaterReflectance = 0 end)
        end
    end)
end

local function hideFoliage(root)
    local found = {}
    for _,v in ipairs(root:GetDescendants()) do
        if (v:IsA("MeshPart") or v:IsA("Part")) and not isProtected(v) then
            local nm = tostring(v.Name):lower()
            if nm:find("tree") or nm:find("leaf") or nm:find("grass") or nm:find("bush") or nm:find("foliage") then
                table.insert(found, v)
            end
        end
    end
    batchProcess(found, function(obj)
        saveOriginal(obj, {"Transparency","CanCollide"})
        pcall(function() obj.Transparency = 1; obj.CanCollide = false end)
    end)
end

local function muteWorkspaceSounds()
    local found = {}
    for _,v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Sound") and not isProtected(v) then table.insert(found, v) end
    end
    batchProcess(found, function(s)
        saveOriginal(s, {"Volume","Playing"})
        pcall(function() s.Volume = 0; if s.Playing then s:Stop() end end)
    end)
end

-- ========== Render distance safe ==========
local function setRenderDistance(radius)
    pcall(function()
        if workspace:FindFirstChild("StreamingTargetRadius") then
            if originalStates["_StreamingTargetRadius"] == nil then originalStates["_StreamingTargetRadius"] = workspace.StreamingTargetRadius end
            workspace.StreamingTargetRadius = radius
            print(string.format(L.RenderValue, radius))
        end
    end)
end
local function restoreRenderDistance()
    pcall(function()
        if originalStates["_StreamingTargetRadius"] then workspace.StreamingTargetRadius = originalStates["_StreamingTargetRadius"] end
    end)
end

-- ========== AntiCrash VIP safe ==========
local function startAntiCrash()
    if antiCrashThread then return end
    antiCrashThread = task.spawn(function()
        while Toggles.anticrash do
            task.wait(Config.AntiCrashInterval)
            pcall(function() ContentProvider:ClearAllCachedAssets() end)
            collectgarbage("collect")
            print(L.AntiCrashDo or "[AntiCrash] Cleared")
        end
        antiCrashThread = nil
    end)
    print(L.AntiCrashOn or "[AntiCrash] On")
end
local function stopAntiCrash()
    Toggles.anticrash = false
    antiCrashThread = nil
    print("[AntiCrash] Stopped")
end

-- ========== Lock FPS ==========
local function lockFPS(enable, fps)
    if fpsConnection then fpsConnection:Disconnect(); fpsConnection = nil end
    if enable and fps and fps > 0 then
        local target = 1/fps
        fpsConnection = RunService.Heartbeat:Connect(function(dt)
            if dt < target then task.wait(target - dt) end
        end)
        print(string.format(L.FPS or "FPS: %d", fps))
    end
end

-- ========== VIP Aggressive Safe Mode ==========
local function applyAggressiveSafeMode()
    -- chỉ chạy khi Config.IsVIP == true
    if not Config.IsVIP then
        warn("Aggressive Safe Mode requires VIP flag. Set Config.IsVIP = true to enable (local setting).")
        return
    end
    -- làm nhiều bước giảm mạnh (tất cả safe checks)
    disableParticles(workspace)
    disableLights(workspace)
    hideDecalsTextures(workspace)
    reduceMaterials(workspace)
    optimizeMeshParts(workspace)
    disablePostProcessing()
    disableFog(true)
    disableShadows(true)
    reduceWater()
    hideFoliage(workspace)
    muteWorkspaceSounds()
    print(L.AggressiveOn or "[VIP] Aggressive Safe Mode applied")
end

-- ========== UI (rút gọn) ==========
-- Tạo UI đơn giản responsive. (Bạn có thể thay UI factory / skin sau)
if game.CoreGui:FindFirstChild("BoostFPS_Hub_UI") then game.CoreGui.BoostFPS_Hub_UI:Destroy() end
local screenGui = Instance.new("ScreenGui", game.CoreGui); screenGui.Name = "BoostFPS_Hub_UI"

local main = Instance.new("Frame", screenGui); main.Size = UDim2.new(0.8,0,0.7,0); main.Position = UDim2.new(0.5,0,0.5,0); main.AnchorPoint = Vector2.new(0.5,0.5); main.BackgroundColor3 = Config.Theme.Background; main.Visible = false
local title = Instance.new("TextLabel", main); title.Size = UDim2.new(1,-20,0,36); title.Position = UDim2.new(0,10,0,6); title.BackgroundTransparency = 1; title.Text = L.Title; title.TextColor3 = Config.Theme.Accent; title.Font = Enum.Font.GothamBold; title.TextSize = 18
local closeBtn = Instance.new("TextButton", main); closeBtn.Size = UDim2.new(0,36,0,28); closeBtn.Position = UDim2.new(1,-48,0,6); closeBtn.Text="X"; closeBtn.Parent = main

local content = Instance.new("ScrollingFrame", main); content.Size = UDim2.new(1,-20,1,-56); content.Position = UDim2.new(0,10,0,46); content.BackgroundColor3 = Config.Theme.Panel; content.CanvasSize = UDim2.new(0,0,0,0)
local layout = Instance.new("UIListLayout", content); layout.Padding = UDim.new(0,8)

-- Factory nhỏ: button
local function mkBtn(parent, text)
    local b = Instance.new("TextButton", parent); b.Size = UDim2.new(1,-12,0,36); b.Text = text; b.Font = Enum.Font.GothamBold; b.TextColor3 = Config.Theme.Text; b.BackgroundColor3 = Config.Theme.Accent
    return b
end

-- Factory: toggle button (text toggle)
local function mkToggleBtn(parent, text)
    local f = Instance.new("Frame", parent); f.Size = UDim2.new(1,-12,0,36); f.BackgroundColor3 = Config.Theme.Panel
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(0.7,0,1,0); l.Text = text; l.BackgroundTransparency = 1; l.TextColor3 = Config.Theme.Text; l.Font = Enum.Font.Gotham
    local b = Instance.new("TextButton", f); b.Size = UDim2.new(0,80,0,28); b.Position = UDim2.new(1,-88,0.5,-14); b.Text="OFF"; b.BackgroundColor3 = Config.Theme.ToggleOFF; b.Font = Enum.Font.GothamBold
    return {frame=f, label=l, button=b}
end

-- Add UI controls (core)
local btnBoost = mkBtn(content, L.BoostAll)
local btnRestore = mkBtn(content, L.Restore); btnRestore.BackgroundColor3 = Color3.fromRGB(110,110,110)
local tParticles = mkToggleBtn(content, "Tắt Particles/FX")
local tLights = mkToggleBtn(content, "Tắt Lights")
local tTextures = mkToggleBtn(content, "Ẩn Decals/Textures")
local tMaterials = mkToggleBtn(content, "Giảm Materials -> Plastic")
local tMesh = mkToggleBtn(content, "Tối ưu MeshParts (Performance)")
local tPost = mkToggleBtn(content, "Tắt Post-Processing")
local tFog = mkToggleBtn(content, "Disable Fog")
local tShadows = mkToggleBtn(content, "Tắt Shadows")
local tFoliage = mkToggleBtn(content, "Ẩn cây cỏ")
local tMute = mkToggleBtn(content, "Tắt âm workspace")
local tAntiCrash = mkToggleBtn(content, "Anti-Crash (Clear+GC)")
local btnVIP = mkBtn(content, "Apply VIP Aggressive Safe Mode") -- chỉ khi IsVIP true, mới thực hiện
local sliderRender = Instance.new("TextLabel", content); sliderRender.Size = UDim2.new(1,-12,0,20); sliderRender.Text = string.format(L.RenderValue, Config.DefaultRenderDistance); sliderRender.BackgroundTransparency = 1; sliderRender.TextColor3 = Config.Theme.Text

-- Simple interactions
local function toggleVisual(tog, state)
    tog.button.Text = state and "ON" or "OFF"
    tog.button.BackgroundColor3 = state and Config.Theme.ToggleON or Config.Theme.ToggleOFF
end

tParticles.button.MouseButton1Click:Connect(function() Toggles.disableParticles = not Toggles.disableParticles; toggleVisual(tParticles, Toggles.disableParticles); if Toggles.disableParticles then disableParticles(workspace) end end)
tLights.button.MouseButton1Click:Connect(function() Toggles.disableLights = not Toggles.disableLights; toggleVisual(tLights, Toggles.disableLights); if Toggles.disableLights then disableLights(workspace) end end)
tTextures.button.MouseButton1Click:Connect(function() Toggles.hideTextures = not Toggles.hideTextures; toggleVisual(tTextures, Toggles.hideTextures); if Toggles.hideTextures then hideDecalsTextures(workspace) end end)
tMaterials.button.MouseButton1Click:Connect(function() Toggles.reduceMaterials = not Toggles.reduceMaterials; toggleVisual(tMaterials, Toggles.reduceMaterials); if Toggles.reduceMaterials then reduceMaterials(workspace) end end)
tMesh.button.MouseButton1Click:Connect(function() Toggles.optimizeMesh = not Toggles.optimizeMesh; toggleVisual(tMesh, Toggles.optimizeMesh); if Toggles.optimizeMesh then optimizeMeshParts(workspace) end end)
tPost.button.MouseButton1Click:Connect(function() Toggles.disablePost = not Toggles.disablePost; toggleVisual(tPost, Toggles.disablePost); if Toggles.disablePost then disablePostProcessing() end end)
tFog.button.MouseButton1Click:Connect(function() Toggles.disableFog = not Toggles.disableFog; toggleVisual(tFog, Toggles.disableFog); disableFog(Toggles.disableFog) end)
tShadows.button.MouseButton1Click:Connect(function() Toggles.disableShadows = not Toggles.disableShadows; toggleVisual(tShadows, Toggles.disableShadows); disableShadows(Toggles.disableShadows) end)
tFoliage.button.MouseButton1Click:Connect(function() Toggles.hideFoliage = not Toggles.hideFoliage; toggleVisual(tFoliage, Toggles.hideFoliage); if Toggles.hideFoliage then hideFoliage(workspace) end end)
tMute.button.MouseButton1Click:Connect(function() Toggles.mute = not Toggles.mute; toggleVisual(tMute, Toggles.mute); if Toggles.mute then muteWorkspaceSounds() end end)
tAntiCrash.button.MouseButton1Click:Connect(function() Toggles.antiCrash = not Toggles.antiCrash; toggleVisual(tAntiCrash, Toggles.antiCrash); if Toggles.antiCrash then startAntiCrash() else stopAntiCrash() end end)

btnVIP.MouseButton1Click:Connect(function()
    if not Config.IsVIP then
        warn("VIP features require Config.IsVIP = true (local setting) and are SAFE mode only.")
        return
    end
    applyAggressiveSafeMode()
end)

btnBoost.MouseButton1Click:Connect(function()
    -- bật một loạt các tùy chọn an toàn
    disableParticles(workspace)
    disableLights(workspace)
    hideDecalsTextures(workspace)
    reduceMaterials(workspace)
    optimizeMeshParts(workspace)
    disablePostProcessing()
    disableFog(true)
    disableShadows(true)
    hideFoliage(workspace)
    muteWorkspaceSounds()
    -- optionally start anti crash
    Toggles.antiCrash = true
    startAntiCrash()
end)

btnRestore.MouseButton1Click:Connect(function()
    restoreAll()
    stopAntiCrash()
    lockFPS(false)
    restoreRenderDistance()
    -- reset UI visuals
    local toggles = {tParticles,tLights,tTextures,tMaterials,tMesh,tPost,tFog,tShadows,tFoliage,tMute,tAntiCrash}
    for _,t in ipairs(toggles) do toggleVisual(t, false) end
end)

-- Render slider quick: ràng buộc bằng keyboard cho demo (Left/Right arrows tăng giảm)
local currentRender = Config.DefaultRenderDistance or 256
local function setRender(v)
    currentRender = math.clamp(v, 64, 1024)
    sliderRender.Text = string.format(L.RenderValue, currentRender)
    setRenderDistance(currentRender)
end

UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.Left then setRender(currentRender - 16) end
    if input.KeyCode == Enum.KeyCode.Right then setRender(currentRender + 16) end
    if input.KeyCode == Enum.KeyCode.RightControl then main.Visible = not main.Visible end
end)

-- FPS counter
local fpsLabel = Instance.new("TextLabel", screenGui); fpsLabel.Size = UDim2.new(0,120,0,28); fpsLabel.Position = UDim2.new(1,-130,0,8); fpsLabel.BackgroundTransparency = 1; fpsLabel.Font = Enum.Font.GothamBold; fpsLabel.TextColor3 = Config.Theme.Text
local avgFPS = 60
RunService.Heartbeat:Connect(function(dt)
    if dt and dt > 0 then
        local fps = 1/dt
        avgFPS = avgFPS*0.9 + fps*0.1
        fpsLabel.Text = string.format(L.FPS or "FPS: %d", math.floor(avgFPS+0.5))
    end
end)

-- Show UI initially small
task.delay(0.1, function() main.Visible = true end)

print("[BoostFPS Hub] Loaded (" .. (LOCALE or "en") .. "). VIP Mode: " .. tostring(Config.IsVIP) .. ".")
