<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kkirune Executor - Quản lý Executor</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --dark: #0a0a0a;
            --darker: #050505;
            --light: #ffffff;
            --gray: #a0a0a0;
            --primary: #6366f1;
            --primary-dark: #4f46e5;
            --success: #10b981;
            --warning: #f59e0b;
            --danger: #ef4444;
            --transparent: rgba(255, 255, 255, 0.1);
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        body {
            background-color: var(--dark);
            color: var(--light);
            min-height: 100vh;
            background-image: 
                linear-gradient(rgba(255, 255, 255, 0.03) 1px, transparent 1px),
                linear-gradient(90deg, rgba(255, 255, 255, 0.03) 1px, transparent 1px);
            background-size: 30px 30px;
            overflow-x: hidden;
        }

        .container {
            max-width: 1600px;
            margin: 0 auto;
            padding: 0 2rem;
        }

        /* Top Navigation */
        .top-nav {
            background: var(--darker);
            border-bottom: 1px solid var(--transparent);
            padding: 0;
            position: sticky;
            top: 0;
            z-index: 100;
            backdrop-filter: blur(10px);
        }

        .nav-container {
            max-width: 1600px;
            margin: 0 auto;
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 0 2rem;
        }

        .logo {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            font-size: 1.8rem;
            font-weight: 700;
            color: var(--light);
            text-decoration: none;
            padding: 1.2rem 0;
        }

        .logo i {
            color: var(--primary);
        }

        .nav-links {
            display: flex;
            gap: 0;
        }

        .nav-link {
            padding: 1.5rem 2rem;
            color: var(--gray);
            text-decoration: none;
            font-weight: 600;
            font-size: 1.1rem;
            transition: all 0.3s ease;
            border-bottom: 3px solid transparent;
            white-space: nowrap;
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }

        .nav-link:hover {
            color: var(--light);
            background: rgba(255, 255, 255, 0.05);
        }

        .nav-link.active {
            color: var(--primary);
            border-bottom-color: var(--primary);
            background: rgba(99, 102, 241, 0.1);
        }

        /* Header Styles */
        .executor-header {
            padding: 80px 2rem 50px;
            background: transparent;
            text-align: center;
            position: relative;
        }

        .executor-header::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 1px;
            background: linear-gradient(90deg, transparent, var(--light), transparent);
        }

        .page-title {
            font-size: 4rem;
            font-weight: 700;
            margin-bottom: 1.5rem;
            color: var(--light);
            text-shadow: 0 0 15px rgba(99, 102, 241, 0.5);
        }

        .page-title i {
            color: var(--primary);
            margin-right: 1.5rem;
        }

        .page-subtitle {
            font-size: 1.4rem;
            color: var(--gray);
            margin-bottom: 2rem;
            max-width: 800px;
            margin-left: auto;
            margin-right: auto;
            line-height: 1.6;
        }

        .template-badge {
            display: inline-block;
            background: rgba(245, 158, 11, 0.2);
            color: var(--warning);
            padding: 0.75rem 1.5rem;
            border-radius: 25px;
            font-size: 1.1rem;
            font-weight: 600;
            border: 1px solid var(--warning);
            margin-bottom: 1.5rem;
        }

        /* Main Content */
        .executor-content {
            padding: 2rem;
        }

        /* Platform Tabs */
        .platform-tabs {
            background: var(--darker);
            border: 1px solid var(--transparent);
            border-radius: 15px;
            overflow: hidden;
            margin-bottom: 3rem;
            backdrop-filter: blur(10px);
        }

        .platform-header {
            display: flex;
            background: rgba(0, 0, 0, 0.3);
            border-bottom: 1px solid var(--transparent);
            overflow-x: auto;
        }

        .platform-btn {
            flex: 1;
            padding: 1.5rem 2rem;
            background: transparent;
            border: none;
            color: var(--gray);
            font-size: 1.2rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            white-space: nowrap;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 1rem;
            min-width: 200px;
            position: relative;
            overflow: hidden;
        }

        .platform-btn::after {
            content: '';
            position: absolute;
            bottom: 0;
            left: 50%;
            width: 0;
            height: 4px;
            background: var(--primary);
            transition: all 0.3s ease;
            transform: translateX(-50%);
        }

        .platform-btn:hover {
            background: rgba(255, 255, 255, 0.05);
            color: var(--light);
        }

        .platform-btn.active {
            background: rgba(99, 102, 241, 0.1);
            color: var(--primary);
        }

        .platform-btn.active::after {
            width: 100%;
        }

        .platform-btn.disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }

        .platform-btn.disabled:hover {
            background: transparent;
            color: var(--gray);
        }

        .platform-badge {
            background: var(--primary);
            color: var(--light);
            padding: 0.4rem 0.8rem;
            border-radius: 15px;
            font-size: 0.9rem;
            font-weight: 600;
        }

        /* Platform Content */
        .platform-content {
            display: none;
            padding: 2.5rem;
            animation: fadeIn 0.5s ease;
        }

        .platform-content.active {
            display: block;
        }

        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }

        /* Platform Content Header */
        .platform-header-content {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 2rem;
            flex-wrap: wrap;
            gap: 1.5rem;
        }

        .platform-title {
            font-size: 2rem;
            font-weight: 600;
            color: var(--light);
            display: flex;
            align-items: center;
            gap: 1rem;
        }

        .platform-title i {
            color: var(--primary);
            font-size: 2.2rem;
        }

        .platform-actions {
            display: flex;
            gap: 1.5rem;
            align-items: center;
        }

        .search-box {
            position: relative;
            display: flex;
            align-items: center;
        }

        .search-box input {
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid var(--transparent);
            border-radius: 10px;
            padding: 1rem 1.5rem 1rem 3rem;
            color: var(--light);
            font-size: 1.1rem;
            width: 400px;
            transition: all 0.3s ease;
        }

        .search-box input:focus {
            outline: none;
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.2);
        }

        .search-box i {
            position: absolute;
            left: 1.2rem;
            color: var(--gray);
            font-size: 1.2rem;
        }

        .filter-btn {
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid var(--transparent);
            border-radius: 10px;
            padding: 1rem 1.5rem;
            color: var(--gray);
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 0.5rem;
            font-size: 1.1rem;
        }

        .filter-btn:hover {
            background: rgba(255, 255, 255, 0.1);
            color: var(--light);
        }

        .sort-select {
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid var(--transparent);
            border-radius: 10px;
            padding: 1rem 1.5rem;
            color: var(--light);
            font-size: 1.1rem;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .sort-select:focus {
            outline: none;
            border-color: var(--primary);
        }

        /* Executor Grid */
        .executor-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(450px, 1fr));
            gap: 2.5rem;
            margin-top: 2rem;
        }

        .executor-card {
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid var(--transparent);
            border-radius: 15px;
            padding: 2.5rem;
            transition: all 0.3s ease;
            display: flex;
            flex-direction: column;
            height: 100%;
            position: relative;
            overflow: hidden;
        }

        .executor-card:hover {
            transform: translateY(-8px);
            box-shadow: 0 15px 30px rgba(0, 0, 0, 0.3);
            border-color: var(--primary);
        }

        .executor-card.featured {
            border: 2px solid var(--warning);
            background: linear-gradient(135deg, rgba(255, 255, 255, 0.05), rgba(245, 158, 11, 0.1));
        }

        .featured-badge {
            position: absolute;
            top: 1rem;
            right: 1rem;
            background: var(--warning);
            color: var(--dark);
            padding: 0.5rem 1rem;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 600;
            z-index: 2;
        }

        .executor-header-card {
            display: flex;
            align-items: center;
            margin-bottom: 1.5rem;
        }

        .executor-icon {
            width: 80px;
            height: 80px;
            border-radius: 15px;
            background: rgba(99, 102, 241, 0.1);
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 1.5rem;
            font-size: 2.5rem;
            color: var(--primary);
        }

        .executor-info {
            flex: 1;
        }

        .executor-name {
            font-weight: 600;
            font-size: 1.8rem;
            color: var(--light);
            margin-bottom: 0.5rem;
        }

        .executor-version {
            font-size: 1.2rem;
            color: var(--gray);
        }

        .executor-description {
            color: var(--gray);
            margin-bottom: 2rem;
            line-height: 1.6;
            flex: 1;
            font-size: 1.2rem;
        }

        .executor-meta {
            display: flex;
            gap: 1rem;
            margin-bottom: 1.5rem;
            flex-wrap: wrap;
        }

        .meta-item {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            color: var(--gray);
            font-size: 1rem;
        }

        .executor-footer-card {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: auto;
        }

        .executor-platform {
            background: rgba(255, 255, 255, 0.1);
            padding: 0.5rem 1rem;
            border-radius: 25px;
            font-size: 1.1rem;
            color: var(--gray);
        }

        .executor-actions {
            display: flex;
            gap: 1rem;
        }

        .download-btn, .web-btn, .info-btn {
            padding: 0.8rem 1.5rem;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 600;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 0.75rem;
            font-size: 1.1rem;
            border: none;
            text-decoration: none;
        }

        .download-btn {
            background: var(--primary);
            color: white;
        }

        .web-btn {
            background: rgba(255, 255, 255, 0.1);
            color: var(--light);
            border: 1px solid var(--transparent);
        }

        .info-btn {
            background: rgba(107, 114, 128, 0.1);
            color: var(--gray);
            border: 1px solid var(--transparent);
        }

        .download-btn:hover {
            background: var(--primary-dark);
            transform: translateY(-3px);
            box-shadow: 0 5px 15px rgba(99, 102, 241, 0.4);
        }

        .web-btn:hover {
            background: rgba(255, 255, 255, 0.2);
            transform: translateY(-3px);
            box-shadow: 0 5px 15px rgba(255, 255, 255, 0.1);
        }

        .info-btn:hover {
            background: rgba(107, 114, 128, 0.2);
            transform: translateY(-3px);
        }

        /* Stats Section */
        .stats-section {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1.5rem;
            margin-bottom: 3rem;
        }

        .stat-card {
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid var(--transparent);
            border-radius: 15px;
            padding: 2rem;
            text-align: center;
            transition: all 0.3s ease;
        }

        .stat-card:hover {
            transform: translateY(-5px);
            border-color: var(--primary);
        }

        .stat-icon {
            font-size: 2.5rem;
            margin-bottom: 1rem;
            color: var(--primary);
        }

        .stat-number {
            font-size: 2.5rem;
            font-weight: bold;
            color: var(--light);
            margin-bottom: 0.5rem;
        }

        .stat-label {
            color: var(--gray);
            font-size: 1.1rem;
        }

        /* Quick Actions */
        .quick-actions {
            display: flex;
            gap: 1rem;
            margin-bottom: 2rem;
            flex-wrap: wrap;
        }

        .action-btn {
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid var(--transparent);
            border-radius: 10px;
            padding: 1rem 1.5rem;
            color: var(--gray);
            text-decoration: none;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 0.5rem;
            font-size: 1rem;
        }

        .action-btn:hover {
            background: rgba(255, 255, 255, 0.1);
            color: var(--light);
            border-color: var(--primary);
        }

        /* Empty State */
        .empty-state {
            text-align: center;
            padding: 5rem 2rem;
            color: var(--gray);
        }

        .empty-state i {
            font-size: 5rem;
            color: var(--transparent);
            margin-bottom: 2rem;
        }

        .empty-state h3 {
            font-size: 2rem;
            color: var(--light);
            margin-bottom: 1.5rem;
        }

        .empty-state p {
            font-size: 1.2rem;
            margin-bottom: 2.5rem;
            max-width: 600px;
            margin-left: auto;
            margin-right: auto;
            line-height: 1.6;
        }

        /* Version Info */
        .version-info {
            background: var(--darker);
            border: 1px solid var(--transparent);
            border-radius: 15px;
            padding: 2rem;
            text-align: center;
            backdrop-filter: blur(10px);
            margin-top: 3rem;
        }

        .version-text {
            color: var(--gray);
            font-size: 1.1rem;
        }

        .version-number {
            color: var(--primary);
            font-weight: 700;
        }

        /* Footer */
        .executor-footer {
            padding: 2.5rem;
            text-align: center;
            border-top: 1px solid var(--transparent);
            margin-top: 3rem;
        }

        .footer-text {
            color: var(--gray);
            font-size: 1.1rem;
        }

        .footer-links {
            display: flex;
            justify-content: center;
            flex-wrap: wrap;
            gap: 2.5rem;
            margin-top: 2rem;
            padding-top: 2rem;
            border-top: 1px solid var(--transparent);
        }

        .footer-link {
            color: var(--gray);
            text-decoration: none;
            transition: color 0.3s ease;
            font-size: 1.1rem;
        }

        .footer-link:hover {
            color: var(--primary);
        }

        /* Responsive Design */
        @media (max-width: 1200px) {
            .executor-grid {
                grid-template-columns: repeat(auto-fill, minmax(400px, 1fr));
            }
        }

        @media (max-width: 1024px) {
            .executor-grid {
                grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
            }
            
            .search-box input {
                width: 300px;
            }
        }

        @media (max-width: 768px) {
            .nav-container {
                flex-direction: column;
                padding: 0 1rem;
            }

            .nav-links {
                width: 100%;
                overflow-x: auto;
            }

            .nav-link {
                padding: 1.2rem 1.5rem;
                font-size: 1rem;
            }

            .platform-header {
                flex-direction: column;
            }

            .platform-btn {
                min-width: auto;
                padding: 1.2rem 1.5rem;
            }

            .page-title {
                font-size: 3rem;
            }

            .platform-header-content {
                flex-direction: column;
                align-items: flex-start;
            }

            .platform-actions {
                width: 100%;
                justify-content: space-between;
            }

            .search-box input {
                width: 100%;
            }
            
            .footer-links {
                flex-direction: column;
                gap: 1.5rem;
                text-align: center;
            }
            
            .executor-grid {
                grid-template-columns: 1fr;
            }

            .executor-actions {
                flex-direction: column;
                width: 100%;
            }

            .download-btn, .web-btn, .info-btn {
                width: 100%;
                justify-content: center;
            }

            .stats-section {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 480px) {
            .executor-header {
                padding: 60px 1rem 30px;
            }

            .executor-content {
                padding: 1rem;
            }

            .page-title {
                font-size: 2.5rem;
            }

            .platform-content {
                padding: 1.5rem;
            }

            .executor-card {
                padding: 1.5rem;
            }

            .executor-header-card {
                flex-direction: column;
                text-align: center;
            }

            .executor-icon {
                margin-right: 0;
                margin-bottom: 1rem;
            }
        }

        /* Animation */
        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .fade-in-up {
            animation: fadeInUp 0.6s ease forwards;
        }

        /* Loading Animation */
        .loading {
            display: inline-block;
            width: 20px;
            height: 20px;
            border: 3px solid rgba(255,255,255,.3);
            border-radius: 50%;
            border-top-color: var(--primary);
            animation: spin 1s ease-in-out infinite;
        }

        @keyframes spin {
            to { transform: rotate(360deg); }
        }
    </style>
</head>
<body>
    <!-- Top Navigation -->
    <nav class="top-nav">
        <div class="nav-container">
            <a href="index.html" class="logo">
                <i class="fas fa-rocket"></i>
                Kkirune
            </a>
            <div class="nav-links">
                <a href="index.html" class="nav-link">
                    <i class="fas fa-home"></i>
                    Trang Chủ
                </a>
                <a href="scripts.html" class="nav-link">
                    <i class="fas fa-code"></i>
                    Scripts
                </a>
                <a href="executor.html" class="nav-link active">
                    <i class="fas fa-terminal"></i>
                    Executor
                </a>
                <a href="fqa.html" class="nav-link">
                    <i class="fas fa-question-circle"></i>
                    FQA
                </a>
                <a href="discord.html" class="nav-link">
                    <i class="fab fa-discord"></i>
                    Discord
                </a>
            </div>
        </div>
    </nav>

    <div class="container">
        <!-- Header Section -->
        <header class="executor-header fade-in-up">
            <div class="template-badge">
                <i class="fas fa-palette"></i>
                EXECUTOR PLATFORM
            </div>
            <h1 class="page-title"><i class="fas fa-rocket"></i>Kkirune Executor</h1>
            <p class="page-subtitle">Kkirune cung cấp các executor và script chất lượng cao cho Roblox với hiệu suất vượt trội, bảo mật tuyệt đối và hỗ trợ 24/7</p>
        </header>

        <!-- Main Content -->
        <div class="executor-content">
            <!-- Stats Section -->
            <div class="stats-section fade-in-up">
                <div class="stat-card">
                    <div class="stat-icon">
                        <i class="fas fa-download"></i>
                    </div>
                    <div class="stat-number" id="total-downloads">0</div>
                    <div class="stat-label">Tổng lượt tải</div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon">
                        <i class="fas fa-box"></i>
                    </div>
                    <div class="stat-number" id="total-executors">0</div>
                    <div class="stat-label">Executor có sẵn</div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon">
                        <i class="fas fa-star"></i>
                    </div>
                    <div class="stat-number" id="average-rating">0.0</div>
                    <div class="stat-label">Đánh giá trung bình</div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon">
                        <i class="fas fa-users"></i>
                    </div>
                    <div class="stat-number" id="active-users">0</div>
                    <div class="stat-label">Người dùng hoạt động</div>
                </div>
            </div>

            <!-- Quick Actions -->
            <div class="quick-actions fade-in-up">
                <a href="#windows" class="action-btn" data-platform="windows">
                    <i class="fab fa-windows"></i>
                    Windows Executors
                </a>
                <a href="#android" class="action-btn" data-platform="android">
                    <i class="fab fa-android"></i>
                    Android Executors
                </a>
                <a href="#web" class="action-btn" data-platform="web">
                    <i class="fas fa-globe"></i>
                    Web Executors
                </a>
                <a href="upload.html" class="action-btn">
                    <i class="fas fa-upload"></i>
                    Upload Executor
                </a>
                <a href="admin.html" class="action-btn">
                    <i class="fas fa-cog"></i>
                    Quản lý Executor
                </a>
            </div>

            <!-- Platform Tabs -->
            <div class="platform-tabs fade-in-up">
                <div class="platform-header">
                    <button class="platform-btn active" data-platform="windows">
                        <i class="fab fa-windows"></i>
                        Windows
                        <span class="platform-badge" id="windows-count">0</span>
                    </button>
                    <button class="platform-btn" data-platform="android">
                        <i class="fab fa-android"></i>
                        Android
                        <span class="platform-badge" id="android-count">0</span>
                    </button>
                    <button class="platform-btn" data-platform="web">
                        <i class="fas fa-globe"></i>
                        Web
                        <span class="platform-badge" id="web-count">0</span>
                    </button>
                    <button class="platform-btn disabled" data-platform="mac">
                        <i class="fab fa-apple"></i>
                        Mac
                        <span class="platform-badge">Soon</span>
                    </button>
                    <button class="platform-btn disabled" data-platform="ios">
                        <i class="fab fa-apple"></i>
                        iOS
                        <span class="platform-badge">Soon</span>
                    </button>
                    <button class="platform-btn disabled" data-platform="linux">
                        <i class="fab fa-linux"></i>
                        Linux
                        <span class="platform-badge">Soon</span>
                    </button>
                </div>

                <!-- Windows Platform Content -->
                <div class="platform-content active" id="windows">
                    <div class="platform-header-content">
                        <h2 class="platform-title">
                            <i class="fab fa-windows"></i>
                            Windows Executors
                        </h2>
                        <div class="platform-actions">
                            <div class="search-box">
                                <i class="fas fa-search"></i>
                                <input type="text" placeholder="Tìm kiếm executor..." id="windows-search">
                            </div>
                            <button class="filter-btn" id="windows-filter">
                                <i class="fas fa-filter"></i>
                                Lọc
                            </button>
                            <select class="sort-select" id="windows-sort">
                                <option value="newest">Mới nhất</option>
                                <option value="popular">Phổ biến</option>
                                <option value="rating">Đánh giá cao</option>
                                <option value="name">Tên A-Z</option>
                            </select>
                        </div>
                    </div>
                    
                    <div class="executor-grid" id="windows-executors">
                        <!-- Windows executors will be loaded here -->
                    </div>
                    
                    <div class="empty-state" id="empty-windows">
                        <i class="fas fa-box-open"></i>
                        <h3>Chưa có executor nào</h3>
                        <p>Chưa có executor Windows nào được thêm vào hệ thống. Admin có thể thêm executor mới thông qua trang quản trị.</p>
                    </div>
                </div>

                <!-- Android Platform Content -->
                <div class="platform-content" id="android">
                    <div class="platform-header-content">
                        <h2 class="platform-title">
                            <i class="fab fa-android"></i>
                            Android Executors
                        </h2>
                        <div class="platform-actions">
                            <div class="search-box">
                                <i class="fas fa-search"></i>
                                <input type="text" placeholder="Tìm kiếm executor..." id="android-search">
                            </div>
                            <button class="filter-btn" id="android-filter">
                                <i class="fas fa-filter"></i>
                                Lọc
                            </button>
                            <select class="sort-select" id="android-sort">
                                <option value="newest">Mới nhất</option>
                                <option value="popular">Phổ biến</option>
                                <option value="rating">Đánh giá cao</option>
                                <option value="name">Tên A-Z</option>
                            </select>
                        </div>
                    </div>
                    
                    <div class="executor-grid" id="android-executors">
                        <!-- Android executors will be loaded here -->
                    </div>
                    
                    <div class="empty-state" id="empty-android">
                        <i class="fas fa-box-open"></i>
                        <h3>Chưa có executor nào</h3>
                        <p>Chưa có executor Android nào được thêm vào hệ thống. Admin có thể thêm executor mới thông qua trang quản trị.</p>
                    </div>
                </div>

                <!-- Web Platform Content -->
                <div class="platform-content" id="web">
                    <div class="platform-header-content">
                        <h2 class="platform-title">
                            <i class="fas fa-globe"></i>
                            Web Executors
                        </h2>
                        <div class="platform-actions">
                            <div class="search-box">
                                <i class="fas fa-search"></i>
                                <input type="text" placeholder="Tìm kiếm executor..." id="web-search">
                            </div>
                            <button class="filter-btn" id="web-filter">
                                <i class="fas fa-filter"></i>
                                Lọc
                            </button>
                            <select class="sort-select" id="web-sort">
                                <option value="newest">Mới nhất</option>
                                <option value="popular">Phổ biến</option>
                                <option value="rating">Đánh giá cao</option>
                                <option value="name">Tên A-Z</option>
                            </select>
                        </div>
                    </div>
                    
                    <div class="executor-grid" id="web-executors">
                        <!-- Web executors will be loaded here -->
                    </div>
                    
                    <div class="empty-state" id="empty-web">
                        <i class="fas fa-box-open"></i>
                        <h3>Chưa có executor nào</h3>
                        <p>Chưa có executor Web nào được thêm vào hệ thống. Admin có thể thêm executor mới thông qua trang quản trị.</p>
                    </div>
                </div>

                <!-- Other Platforms (Disabled) -->
                <div class="platform-content" id="mac">
                    <div class="empty-state">
                        <i class="fas fa-tools"></i>
                        <h3>Đang phát triển</h3>
                        <p>Nền tảng Mac đang được phát triển và sẽ sớm có mặt trong tương lai.</p>
                    </div>
                </div>

                <div class="platform-content" id="ios">
                    <div class="empty-state">
                        <i class="fas fa-tools"></i>
                        <h3>Đang phát triển</h3>
                        <p>Nền tảng iOS đang được phát triển và sẽ sớm có mặt trong tương lai.</p>
                    </div>
                </div>

                <div class="platform-content" id="linux">
                    <div class="empty-state">
                        <i class="fas fa-tools"></i>
                        <h3>Đang phát triển</h3>
                        <p>Nền tảng Linux đang được phát triển và sẽ sớm có mặt trong tương lai.</p>
                    </div>
                </div>
            </div>

            <!-- Version Info -->
            <div class="version-info fade-in-up">
                <p class="version-text">
                    Phiên bản hệ thống: <span class="version-number">v2.1.0</span> | 
                    Template UI: <span class="version-number">v1.0.0</span> | 
                    Cập nhật lần cuối: <span class="version-number" id="last-update">15/12/2023</span>
                </p>
            </div>
        </div>

        <!-- Footer -->
        <footer class="executor-footer">
            <p class="footer-text">© 2024 Kkirune Executor - Nền tảng Executor & Script Roblox hàng đầu</p>
            <div class="footer-links">
                <a href="index.html" class="footer-link">Trang Chủ</a>
                <a href="scripts.html" class="footer-link">Scripts</a>
                <a href="executor.html" class="footer-link">Executors</a>
                <a href="fqa.html" class="footer-link">Câu Hỏi Thường Gặp</a>
                <a href="discord.html" class="footer-link">Discord</a>
                <a href="terms.html" class="footer-link">Điều Khoản Sử Dụng</a>
                <a href="privacy.html" class="footer-link">Chính Sách Bảo Mật</a>
            </div>
        </footer>
    </div>

    <script>
        // Executor Management System
        class ExecutorManager {
            constructor() {
                this.executors = [];
                this.filters = {
                    windows: { search: '', sort: 'newest' },
                    android: { search: '', sort: 'newest' },
                    web: { search: '', sort: 'newest' }
                };
                this.init();
            }

            init() {
                this.loadExecutors();
                this.setupEventListeners();
                this.updateStats();
            }

            loadExecutors() {
                try {
                    const savedExecutors = localStorage.getItem('kkirune_executors');
                    this.executors = savedExecutors ? JSON.parse(savedExecutors) : [];
                    
                    // If no executors, initialize with empty array
                    if (this.executors.length === 0) {
                        this.executors = [];
                        this.saveExecutors();
                    }
                    
                    this.renderAllPlatforms();
                } catch (error) {
                    console.error('Error loading executors:', error);
                    this.executors = [];
                }
            }

            saveExecutors() {
                localStorage.setItem('kkirune_executors', JSON.stringify(this.executors));
                this.updateStats();
            }

            setupEventListeners() {
                // Platform tabs
                document.querySelectorAll('.platform-btn').forEach(btn => {
                    btn.addEventListener('click', (e) => {
                        if (e.target.classList.contains('disabled')) return;
                        
                        const platform = e.target.dataset.platform;
                        this.switchPlatform(platform);
                    });
                });

                // Quick actions
                document.querySelectorAll('.action-btn[data-platform]').forEach(btn => {
                    btn.addEventListener('click', (e) => {
                        e.preventDefault();
                        const platform = e.target.closest('.action-btn').dataset.platform;
                        this.switchPlatform(platform);
                    });
                });

                // Search functionality
                ['windows', 'android', 'web'].forEach(platform => {
                    const searchInput = document.getElementById(`${platform}-search`);
                    const sortSelect = document.getElementById(`${platform}-sort`);
                    
                    searchInput.addEventListener('input', (e) => {
                        this.filters[platform].search = e.target.value.toLowerCase();
                        this.renderPlatform(platform);
                    });

                    sortSelect.addEventListener('change', (e) => {
                        this.filters[platform].sort = e.target.value;
                        this.renderPlatform(platform);
                    });
                });

                // Filter buttons
                document.querySelectorAll('.filter-btn').forEach(btn => {
                    btn.addEventListener('click', (e) => {
                        const platform = e.target.closest('.platform-content').id;
                        this.showFilterModal(platform);
                    });
                });
            }

            switchPlatform(platform) {
                // Update active tab
                document.querySelectorAll('.platform-btn').forEach(btn => {
                    btn.classList.remove('active');
                });
                document.querySelector(`.platform-btn[data-platform="${platform}"]`).classList.add('active');

                // Update active content
                document.querySelectorAll('.platform-content').forEach(content => {
                    content.classList.remove('active');
                });
                document.getElementById(platform).classList.add('active');

                // Render platform
                this.renderPlatform(platform);
            }

            renderAllPlatforms() {
                ['windows', 'android', 'web'].forEach(platform => {
                    this.renderPlatform(platform);
                });
            }

            renderPlatform(platform) {
                const container = document.getElementById(`${platform}-executors`);
                const emptyState = document.getElementById(`empty-${platform}`);
                
                if (!container) return;

                let platformExecutors = this.executors.filter(executor => 
                    executor.os === platform && executor.status === 'active'
                );

                // Apply search filter
                if (this.filters[platform].search) {
                    platformExecutors = platformExecutors.filter(executor =>
                        executor.name.toLowerCase().includes(this.filters[platform].search) ||
                        executor.description.toLowerCase().includes(this.filters[platform].search)
                    );
                }

                // Apply sorting
                platformExecutors = this.sortExecutors(platformExecutors, this.filters[platform].sort);

                // Update platform count
                const countBadge = document.getElementById(`${platform}-count`);
                if (countBadge) {
                    countBadge.textContent = platformExecutors.length;
                }

                if (platformExecutors.length === 0) {
                    container.style.display = 'none';
                    if (emptyState) emptyState.style.display = 'block';
                    return;
                }

                container.style.display = 'grid';
                if (emptyState) emptyState.style.display = 'none';

                // Create HTML for executors
                container.innerHTML = platformExecutors.map(executor => `
                    <div class="executor-card ${executor.featured ? 'featured' : ''}">
                        ${executor.featured ? '<div class="featured-badge"><i class="fas fa-crown"></i> Nổi bật</div>' : ''}
                        <div class="executor-header-card">
                            <div class="executor-icon">
                                <i class="fab fa-${this.getOSIcon(executor.os)}"></i>
                            </div>
                            <div class="executor-info">
                                <div class="executor-name">${this.escapeHtml(executor.name)}</div>
                                <div class="executor-version">Phiên bản ${executor.version}</div>
                            </div>
                        </div>
                        <div class="executor-description">${executor.description || 'Executor chất lượng cao cho hệ thống của bạn.'}</div>
                        <div class="executor-meta">
                            <div class="meta-item">
                                <i class="fas fa-download"></i>
                                <span>${this.formatNumber(executor.downloads || 0)} lượt tải</span>
                            </div>
                            <div class="meta-item">
                                <i class="fas fa-calendar"></i>
                                <span>${executor.date || '15/12/2023'}</span>
                            </div>
                            <div class="meta-item">
                                <i class="fas fa-star"></i>
                                <span>${executor.rating || '5.0'}</span>
                            </div>
                            ${executor.size ? `<div class="meta-item">
                                <i class="fas fa-weight"></i>
                                <span>${executor.size}</span>
                            </div>` : ''}
                        </div>
                        <div class="executor-footer-card">
                            <div class="executor-platform">${this.getOSDisplayName(executor.os)}</div>
                            <div class="executor-actions">
                                ${executor.webUrl ? `<a href="${executor.webUrl}" target="_blank" class="web-btn"><i class="fas fa-external-link-alt"></i> Link Web</a>` : ''}
                                <button class="info-btn" onclick="executorManager.showExecutorInfo('${executor.id}')">
                                    <i class="fas fa-info-circle"></i> Chi tiết
                                </button>
                                <button class="download-btn" onclick="executorManager.downloadExecutor('${executor.id}')">
                                    <i class="fas fa-download"></i> Tải Xuống
                                </button>
                            </div>
                        </div>
                    </div>
                `).join('');
            }

            sortExecutors(executors, sortBy) {
                switch (sortBy) {
                    case 'newest':
                        return executors.sort((a, b) => new Date(b.date) - new Date(a.date));
                    case 'popular':
                        return executors.sort((a, b) => (b.downloads || 0) - (a.downloads || 0));
                    case 'rating':
                        return executors.sort((a, b) => parseFloat(b.rating) - parseFloat(a.rating));
                    case 'name':
                        return executors.sort((a, b) => a.name.localeCompare(b.name));
                    default:
                        return executors;
                }
            }

            updateStats() {
                const totalDownloads = this.executors.reduce((sum, executor) => sum + (executor.downloads || 0), 0);
                const totalExecutors = this.executors.filter(e => e.status === 'active').length;
                const averageRating = this.executors.length > 0 
                    ? (this.executors.reduce((sum, executor) => sum + parseFloat(executor.rating || 0), 0) / this.executors.length).toFixed(1)
                    : '0.0';
                const activeUsers = Math.floor(totalDownloads * 0.8); // Simulated active users

                document.getElementById('total-downloads').textContent = this.formatNumber(totalDownloads);
                document.getElementById('total-executors').textContent = totalExecutors;
                document.getElementById('average-rating').textContent = averageRating;
                document.getElementById('active-users').textContent = this.formatNumber(activeUsers);

                // Update last update time
                document.getElementById('last-update').textContent = new Date().toLocaleDateString('vi-VN');
            }

            downloadExecutor(id) {
                try {
                    const executor = this.executors.find(e => e.id === id);
                    
                    if (executor) {
                        if (executor.downloadUrl && executor.downloadUrl !== '#') {
                            // Show loading state
                            const button = event.target;
                            const originalHTML = button.innerHTML;
                            button.innerHTML = '<div class="loading"></div> Đang tải...';
                            button.disabled = true;

                            // Simulate download process
                            setTimeout(() => {
                                window.open(executor.downloadUrl, '_blank');
                                
                                // Update download count
                                executor.downloads = (executor.downloads || 0) + 1;
                                this.saveExecutors();
                                
                                // Restore button
                                button.innerHTML = originalHTML;
                                button.disabled = false;

                                // Show success message
                                this.showNotification(`Đã bắt đầu tải xuống ${executor.name}!`, 'success');
                            }, 1000);
                        } else {
                            this.showNotification(`Executor ${executor.name} chưa có link tải xuống.`, 'error');
                        }
                    }
                } catch (error) {
                    console.error('Error downloading executor:', error);
                    this.showNotification('Có lỗi xảy ra khi tải xuống!', 'error');
                }
            }

            showExecutorInfo(id) {
                const executor = this.executors.find(e => e.id === id);
                if (executor) {
                    const info = `
Tên: ${executor.name}
Phiên bản: ${executor.version}
Nền tảng: ${this.getOSDisplayName(executor.os)}
Lượt tải: ${this.formatNumber(executor.downloads || 0)}
Đánh giá: ${executor.rating}/5
Ngày cập nhật: ${executor.date}
${executor.description}
                    `.trim();
                    
                    this.showNotification(info, 'info', 5000);
                }
            }

            showFilterModal(platform) {
                // In a real implementation, this would show a filter modal
                this.showNotification(`Tính năng lọc nâng cao cho ${platform} đang được phát triển!`, 'info');
            }

            showNotification(message, type = 'info', duration = 3000) {
                // Create notification element
                const notification = document.createElement('div');
                notification.className = `notification notification-${type}`;
                notification.innerHTML = `
                    <div class="notification-content">
                        <i class="fas fa-${this.getNotificationIcon(type)}"></i>
                        <span>${message}</span>
                    </div>
                `;

                // Add styles
                notification.style.cssText = `
                    position: fixed;
                    top: 100px;
                    right: 20px;
                    background: ${type === 'success' ? 'var(--success)' : type === 'error' ? 'var(--danger)' : 'var(--primary)'};
                    color: white;
                    padding: 1rem 1.5rem;
                    border-radius: 10px;
                    box-shadow: 0 10px 30px rgba(0,0,0,0.3);
                    z-index: 1000;
                    animation: slideInRight 0.3s ease;
                    max-width: 400px;
                `;

                document.body.appendChild(notification);

                // Remove after duration
                setTimeout(() => {
                    notification.style.animation = 'slideOutRight 0.3s ease';
                    setTimeout(() => {
                        if (notification.parentNode) {
                            notification.parentNode.removeChild(notification);
                        }
                    }, 300);
                }, duration);
            }

            getNotificationIcon(type) {
                const icons = {
                    'success': 'check-circle',
                    'error': 'exclamation-circle',
                    'info': 'info-circle',
                    'warning': 'exclamation-triangle'
                };
                return icons[type] || 'info-circle';
            }

            getOSIcon(os) {
                const icons = {
                    'windows': 'windows',
                    'android': 'android',
                    'web': 'chrome',
                    'mac': 'apple',
                    'ios': 'apple',
                    'linux': 'linux'
                };
                return icons[os] || 'desktop';
            }

            getOSDisplayName(os) {
                const osNames = {
                    'windows': 'Windows',
                    'android': 'Android',
                    'web': 'Web',
                    'mac': 'Mac OS',
                    'ios': 'iOS',
                    'linux': 'Linux'
                };
                return osNames[os] || os;
            }

            escapeHtml(unsafe) {
                if (!unsafe) return '';
                return unsafe
                    .replace(/&/g, "&amp;")
                    .replace(/</g, "&lt;")
                    .replace(/>/g, "&gt;")
                    .replace(/"/g, "&quot;")
                    .replace(/'/g, "&#039;");
            }

            formatNumber(num) {
                return new Intl.NumberFormat('vi-VN').format(num);
            }
        }

        // Initialize when page loads
        document.addEventListener('DOMContentLoaded', () => {
            window.executorManager = new ExecutorManager();
        });

        // Add CSS for notifications
        const style = document.createElement('style');
        style.textContent = `
            @keyframes slideInRight {
                from {
                    transform: translateX(100%);
                    opacity: 0;
                }
                to {
                    transform: translateX(0);
                    opacity: 1;
                }
            }
            
            @keyframes slideOutRight {
                from {
                    transform: translateX(0);
                    opacity: 1;
                }
                to {
                    transform: translateX(100%);
                    opacity: 0;
                }
            }
            
            .notification-content {
                display: flex;
                align-items: center;
                gap: 0.5rem;
            }
        `;
        document.head.appendChild(style);
    </script>
</body>
</html>
