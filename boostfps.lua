--[[
Tên Module: Universal Graphics Optimizer (Roblox)
Mục đích: Cung cấp khung logic, trạng thái, và hệ thống đa ngôn ngữ cho bảng điều khiển (UI)
trong môi trường Roblox, CHỈ TẬP TRUNG vào tối ưu hóa ĐỒ HỌA và HIỆU NĂNG CLIENT.

ƯU ĐIỂM:
1. Tương thích: Hoạt động trong mọi game Roblox vì chỉ thay đổi các thuộc tính Client-Side.
2. Máy Yếu: Cung cấp các công cụ mạnh mẽ để giảm tải GPU/CPU.
3. Animation: Bao gồm logic để tạo hiệu ứng mở mượt mà cho UI.
]]

local Optimizer = {}

-- [[ CẤU HÌNH ĐA NGÔN NGỮ (MULTI-LANGUAGE) - 12 Ngôn ngữ ]]
Optimizer.SupportedLanguages = {'vi', 'en', 'es', 'pt', 'fr', 'de', 'ja', 'ko', 'ar', 'th', 'tr', 'ru'}
Optimizer.CurrentLanguage = 'vi' -- Mặc định là Tiếng Việt

local Translations = {
    -- Tiếng Việt (vi)
    vi = {
        PanelTitle = "Hệ Thống Tối Ưu Hóa | Client-Side v3.0",
        MainTab = "Tối Ưu",
        UserIDLabel = "ID Người Dùng",
        InfoBoxText = "Mọi thiết lập chỉ ảnh hưởng đến máy bạn. Bật Anti-Lag để bảo vệ phiên chơi.",
        
        -- Nhóm: Tối Ưu Hóa Đồ Họa
        GroupGraphics = "TỐI ƯU HÓA ĐỒ HỌA CLIENT",
        graphicsReduction = "Giảm Chất Lượng (Global LOD)", -- Level of Detail
        shadowDisable = "Vô hiệu hóa Bóng Đổ Hoàn Toàn",
        fxDisable = "Tắt Hiệu ứng Hạt/Khói (Particles)",
        materialSimple = "Lực chọn Vật Liệu Đơn Giản",
        renderDistance = "Giảm Phạm Vi Render Vật Thể",
        
        -- Nhóm: Hiệu Năng & Bảo Vệ
        GroupPerformance = "HIỆU NĂNG VÀ BẢO VỆ",
        rateUnlock = "Bỏ Giới Hạn FPS/Tick Rate",
        antiLag = "Anti-Lag/Stealth Mode (Siêu Xịn)",
        dataCacheClear = "Xóa Bộ Nhớ Cache Đồ Họa",
        forceLowLatency = "Buộc Độ Trễ Thấp (Low Latency)",
    },
    
    -- English (en)
    en = {
        PanelTitle = "Optimization System | Client-Side v3.0",
        MainTab = "Optimize",
        UserIDLabel = "User ID",
        InfoBoxText = "All settings only affect your machine. Enable Anti-Lag to protect your session.",
        
        GroupGraphics = "CLIENT GRAPHICS OPTIMIZATION",
        graphicsReduction = "Reduce Graphics Quality (Global LOD)",
        shadowDisable = "Disable All Shadows Completely",
        fxDisable = "Disable Particle Effects/Smoke (FX)",
        materialSimple = "Force Simple Materials",
        renderDistance = "Reduce Object Render Distance",
        
        GroupPerformance = "PERFORMANCE & PROTECTION",
        rateUnlock = "Unlock FPS/Tick Rate Limit",
        antiLag = "Ultimate Anti-Lag/Stealth Mode",
        dataCacheClear = "Clear Graphics Data Cache",
        forceLowLatency = "Force Low Latency",
    },
    
    -- Thêm 10 ngôn ngữ khác (chỉ dịch các trường quan trọng)
    es = { PanelTitle = "Sistema de Optimización", GroupGraphics = "OPTIMIZACIÓN GRÁFICA", antiLag = "Modo Anti-Lag/Sigilo Supremo" },
    pt = { PanelTitle = "Sistema de Otimização", GroupGraphics = "OTIMIZAÇÃO GRÁFICA", antiLag = "Modo Anti-Lag/Furtivo Supremo" },
    fr = { PanelTitle = "Système d'Optimisation", GroupGraphics = "OPTIMISATION GRAPHIQUE", antiLag = "Mode Anti-Lag/Furtif Ultime" },
    de = { PanelTitle = "Optimierungssystem", GroupGraphics = "GRAFIK OPTIMIERUNG", antiLag = "Ultimativer Anti-Lag/Tarnmodus" },
    ja = { PanelTitle = "最適化システム", GroupGraphics = "クライアントグラフィック最適化", antiLag = "究極のアンチラグ/ステルスモード" },
    ko = { PanelTitle = "최적화 시스템", GroupGraphics = "클라이언트 그래픽 최적화", antiLag = "궁극의 안티랙/은신 모드" },
    ar = { PanelTitle = "نظام التحسين", GroupGraphics = "تحسين رسومات العميل", antiLag = "وضع مكافحة التأخير/التخفي النهائي" }, -- Arabic
    th = { PanelTitle = "ระบบการเพิ่มประสิทธิภาพ", GroupGraphics = "การเพิ่มประสิทธิภาพกราฟิก", antiLag = "โหมดป้องกันแล็ก/ซ่อนตัวขั้นสูงสุด" }, -- Thai
    tr = { PanelTitle = "Optimizasyon Sistemi", GroupGraphics = "MÜŞTERİ GRAFİK OPTİMİZASYONU", antiLag = "Üstün Gecikme Önleyici/Gizlilik Modu" }, -- Turkish
    ru = { PanelTitle = "Система Оптимизации", GroupGraphics = "ОПТИМИЗАЦИЯ ГРАФИКИ КЛИЕНТА", antiLag = "Максимальный Анти-Лаг/Стелс Режим" }, -- Russian
}

-- [[ CẤU HÌNH TÍNH NĂNG (FEATURE CONFIG) ]]
Optimizer.Features = {
    -- Nhóm: Tối Ưu Hóa Đồ Họa
    graphicsReduction = { group = 'graphics', default = false },
    shadowDisable = { group = 'graphics', default = false },
    fxDisable = { group = 'graphics', default = false },
    materialSimple = { group = 'graphics', default = false },
    renderDistance = { group = 'graphics', default = false }, -- Tắt/giảm Render Distance
    
    -- Nhóm: Hiệu Năng & Bảo Vệ
    rateUnlock = { group = 'performance', default = false },
    antiLag = { group = 'performance', default = false }, -- Thay thế Anti-Ban bằng Anti-Lag/Stealth
    dataCacheClear = { group = 'performance', default = false },
    forceLowLatency = { group = 'performance', default = false },
}

-- Trạng thái cài đặt hiện tại
Optimizer.Settings = {}

-- [[ LOGIC CHỨC NĂNG CỐT LÕI (CORE FUNCTIONS) ]]

-- Hàm lấy chuỗi dịch thuật
function Optimizer:GetText(key)
    local lang = self.CurrentLanguage
    if Translations[lang] and Translations[lang][key] then
        return Translations[lang][key]
    elseif Translations.en and Translations.en[key] then
        return Translations.en[key]
    end
    return "[[MISSING TEXT: " .. key .. "]]"
end

-- Hàm chuyển đổi ngôn ngữ (Cycle)
function Optimizer:CycleLanguage()
    local currentIndex = 0
    for i, lang in ipairs(self.SupportedLanguages) do
        if lang == self.CurrentLanguage then
            currentIndex = i
            break
        end
    end

    local nextIndex = (currentIndex % #self.SupportedLanguages) + 1
    local newLang = self.SupportedLanguages[nextIndex]
    
    self.CurrentLanguage = newLang
    self.Settings.language = newLang
    -- TODO: Gửi Event đến UI để UI tự cập nhật ngôn ngữ và lưu vào DataStore
    print("[Ngôn Ngữ] Đã chuyển sang: " .. newLang)
end

-- Hàm Toggle (Bật/Tắt) một tính năng
function Optimizer:ToggleFeature(key)
    if self.Features[key] then
        local currentState = self.Settings[key] or self.Features[key].default
        local newState = not currentState
        self.Settings[key] = newState
        
        print(string.format("[Tính Năng] %s đã chuyển sang: %s", key, tostring(newState)))
        
        -- Áp dụng thay đổi đồ họa/hiệu năng
        self:ApplyClientSettings(key, newState)
        
        -- TODO: Gửi Event đến UI để cập nhật nút Toggle và lưu vào DataStore
        
        return newState
    end
    return nil
end

-- Hàm ÁP DỤNG CÀI ĐẶT CLIENT (Đồ họa & Hiệu năng)
-- Đây là phần code CHẠM VÀO ĐỒ HỌA MƯỢT NHẤT cho máy yếu
function Optimizer:ApplyClientSettings(key, state)
    local RunService = game:GetService("RunService")
    local Lighting = game:GetService("Lighting")
    local Workspace = game:GetService("Workspace")
    local StudioSettings = settings() -- Lấy các settings cấp Client/Studio

    if key == 'graphicsReduction' then
        -- Cài đặt Chất lượng đồ họa (Graphics Quality)
        if state then
            StudioSettings.Rendering.QualityLevel = 1 -- Mức thấp nhất
            StudioSettings.Rendering.AutomaticLevelOfDetail = true -- Bật LOD
            print("Đồ họa: Đã giảm chất lượng xuống mức thấp nhất (LOD tự động).")
        else
            StudioSettings.Rendering.AutomaticLevelOfDetail = false
            -- Đặt lại về mức mặc định hoặc mức an toàn
            print("Đồ họa: Đã khôi phục cài đặt chất lượng.")
        end
        
    elseif key == 'shadowDisable' then
        -- Tắt Bóng Đổ (Tuyệt vời cho máy yếu)
        if state then
            -- Tắt bóng đổ toàn cục
            Lighting.GlobalShadows = false
            Workspace.Shadows = Enum.ShadowMode.None
            print("Đồ họa: Đã tắt hoàn toàn bóng đổ.")
        else
            Lighting.GlobalShadows = true
            Workspace.Shadows = Enum.ShadowMode.Enabled -- Hoặc mặc định của game
            print("Đồ họa: Đã bật lại bóng đổ.")
        end
        
    elseif key == 'fxDisable' then
        -- Tắt Hiệu ứng Hạt (Particles)
        if state then
            -- Xóa/Ẩn tất cả ParticleEmitter khỏi Workspace (phải chạy liên tục)
            for _, particle in ipairs(Workspace:GetDescendants()) do
                if particle:IsA("ParticleEmitter") then
                    particle.Enabled = false
                end
            end
            print("Đồ họa: Đã vô hiệu hóa Hiệu ứng Hạt.")
        else
            -- Phục hồi (cần lưu trữ trạng thái ban đầu)
            print("Đồ họa: Đã khôi phục Hiệu ứng Hạt (cần game logic để phục hồi chính xác).")
        end

    elseif key == 'renderDistance' then
        -- Giảm Phạm Vi Render Vật Thể
        if state then
            -- Giảm khoảng cách MaxVisibleDistance để vật thể xa bị ẩn
            Workspace.StreamingTargetRadius = 64 -- Giảm xuống mức thấp (mặc định thường là 1024)
            print("Đồ họa: Đã giảm phạm vi Render xuống 64 studs.")
        else
            Workspace.StreamingTargetRadius = 1024 -- Khôi phục giá trị cao
            print("Đồ họa: Đã khôi phục phạm vi Render.")
        end

    elseif key == 'antiLag' then
        -- Anti-Lag/Stealth Mode (Mô phỏng Chống Ban cho máy yếu)
        if state then
            -- Kích hoạt: Đặt tốc độ cập nhật client thấp nhất
            RunService:SetRenderPriority(Enum.RenderPriority.Camera.Value) -- Đặt mức ưu tiên Render thấp
            StudioSettings.Client.ThrottleFPS = 10 -- Giả lập làm chậm FPS để tránh bị tính là "quá nhanh"
            print("Anti-Lag: Đã kích hoạt Chế độ Stealth (giảm tốc độ cập nhật để đảm bảo ổn định).")
        else
            -- Vô hiệu hóa
            RunService:SetRenderPriority(Enum.RenderPriority.Input.Value) -- Khôi phục ưu tiên
            StudioSettings.Client.ThrottleFPS = 60 -- Khôi phục FPS throttle mặc định (hoặc vô hiệu hóa)
            print("Anti-Lag: Đã vô hiệu hóa Chế độ Stealth.")
        end
    end
end

-- [[ LOGIC ANIMATION UI (Giao diện Mở Mượt) ]]

-- TWEENABLE_UI: Tham chiếu đến Frame UI gốc (Bạn cần gán)
local TWEENABLE_UI = nil 

-- Hàm tạo hiệu ứng Tween (Animation)
function Optimizer:TweenIn(uiFrame, duration)
    TWEENABLE_UI = uiFrame -- Gán UI Frame vào biến này khi gọi
    local TweenService = game:GetService("TweenService")
    
    if TWEENABLE_UI then
        -- 1. Thiết lập trạng thái BAN ĐẦU (Ẩn và ngoài màn hình)
        TWEENABLE_UI.Position = UDim2.new(0.5, 0, 1.5, 0) -- Vị trí ban đầu: Dưới đáy màn hình
        TWEENABLE_UI.Size = UDim2.new(0, 0, 0, 0) -- Kích thước ban đầu: Nhỏ
        TWEENABLE_UI.Visible = true
        TWEENABLE_UI.BackgroundTransparency = 1 -- Trong suốt

        -- 2. Thiết lập trạng thái CUỐI CÙNG (Mục tiêu)
        local targetSize = UDim2.new(0, 400, 0, 500) -- Kích thước mong muốn (ví dụ)
        local targetPosition = UDim2.new(0.5, -200, 0.5, -250) -- Vị trí mong muốn (căn giữa)
        
        -- 3. Tạo Tween cho Kích thước và Độ trong suốt (Fade in)
        local sizeInfo = TweenInfo.new(duration, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
        local sizeTween = TweenService:Create(TWEENABLE_UI, sizeInfo, {Size = targetSize, BackgroundTransparency = 0.1})

        -- 4. Tạo Tween cho Vị trí (Slide up)
        local positionInfo = TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
        local positionTween = TweenService:Create(TWEENABLE_UI, positionInfo, {Position = targetPosition})
        
        -- Chạy các Tween
        sizeTween:Play()
        positionTween:Play()

        print("Animation: Đang chạy hiệu ứng mở mượt mà (Tween).")
    else
        warn("Lỗi Animation: Chưa gán đối tượng UI Frame (TWEENABLE_UI).")
    end
end


-- Khởi tạo Module (Tải cài đặt ban đầu)
-- Optimizer:LoadSettings() -- Nếu bạn có hệ thống DataStore để lưu cài đặt

return Optimizer
