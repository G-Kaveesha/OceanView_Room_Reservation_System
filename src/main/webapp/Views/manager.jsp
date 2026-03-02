<%
    String role = (String) session.getAttribute("userRole");
    if (role == null || !"MANAGER".equalsIgnoreCase(role)) {
        response.sendRedirect(request.getContextPath() + "/Views/login.jsp");
        return;
    }
%>
<%
  String ctx = request.getContextPath();
%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hotel Admin Dashboard</title>

    <!-- Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">

    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&family=Space+Mono:wght@400;700&display=swap" rel="stylesheet">

   <style>
    :root {
            --primary-color: #6366f1;
            --primary-dark: #4f46e5;
            --secondary-color: #8b5cf6;
            --accent-color: #ec4899;
            --success-color: #10b981;
            --warning-color: #f59e0b;
            --danger-color: #ef4444;
            --info-color: #3b82f6;
            --dark-bg: #1e1b4b;
            --sidebar-bg: #312e81;
            --card-bg: #ffffff;
            --text-primary: #1f2937;
            --text-secondary: #6b7280;
            --border-color: #e5e7eb;
            --shadow-sm: 0 2px 4px rgba(0,0,0,0.04);
            --shadow-md: 0 4px 12px rgba(0,0,0,0.08);
            --shadow-lg: 0 10px 30px rgba(0,0,0,0.12);
            --shadow-hover: 0 12px 40px rgba(99, 102, 241, 0.15);
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Outfit', sans-serif;
            background-image: url("${pageContext.request.contextPath}/images/bg.png");
            color: var(--text-primary);
            min-height: 100vh;
        }

        /* Sidebar Styles */
        .sidebar {
            position: fixed;
            left: 0;
            top: 0;
            width: 260px;
            height: 100vh;
            background: linear-gradient(180deg, var(--sidebar-bg) 0%, var(--dark-bg) 100%);
            padding: 1.5rem 0;
            z-index: 1000;
            box-shadow: var(--shadow-lg);
            transition: transform 0.3s ease;
        }

        .sidebar-brand {
            padding: 0 1.5rem 2rem;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            margin-bottom: 1.5rem;
            display: flex;
            font-family: 'Lucida Sans', 'Lucida Sans Regular', 'Lucida Grande', 'Lucida Sans Unicode', Geneva, Verdana, sans-serif;
            align-items: center;
            gap: 1rem;
        }

        .sidebar-logo {
            width: 50px;
            height: 50px;
            object-fit: contain;
            border-radius: 0.5rem;
            padding: 0.5rem;
        }

        .sidebar-brand h3 {
            color: white;
            font-weight: 700;
            font-size: 1.25rem;
            margin: 0;
        }

        .sidebar-menu {
            list-style: none;
            padding: 0 1rem;
        }

        .sidebar-menu li {
            margin-bottom: 0.5rem;
        }

        .sidebar-menu a {
            display: flex;
            align-items: center;
            gap: 1rem;
            padding: 0.875rem 1rem;
            color: rgba(255, 255, 255, 0.8);
            text-decoration: none;
            border-radius: 0.5rem;
            transition: all 0.3s ease;
            font-weight: 500;
        }

        .sidebar-menu a:hover {
            background: rgba(255, 255, 255, 0.1);
            color: white;
            transform: translateX(5px);
        }

        .sidebar-menu a.active {
            background: linear-gradient(90deg, var(--primary-color), var(--secondary-color));
            color: white;
            box-shadow: 0 4px 12px rgba(99, 102, 241, 0.3);
        }

        .sidebar-menu i {
            width: 20px;
            text-align: center;
        }

        /* Mobile Sidebar Toggle */
        .sidebar-toggle {
            display: none;
            position: fixed;
            top: 1rem;
            left: 1rem;
            z-index: 1001;
            background: var(--primary-color);
            color: white;
            border: none;
            padding: 0.75rem 1rem;
            border-radius: 0.5rem;
            cursor: pointer;
            box-shadow: var(--shadow-md);
        }

        .sidebar.closed {
            transform: translateX(-100%);
        }

        /* Main Content */
        .main-content {
            margin-left: 260px;
            padding: 2rem;
            transition: margin-left 0.3s ease;
        }

        /* Top Header */
        .top-header {
            background: white;
            padding: 1.5rem 2rem;
            border-radius: 1rem;
            margin-bottom: 2rem;
            box-shadow: var(--shadow-md);
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 1rem;
        }

        .header-left h1 {
            font-size: 1.875rem;
            font-weight: 700;
            color: var(--text-primary);
            margin-bottom: 0.25rem;
        }

        .login-time {
            color: var(--text-secondary);
            font-size: 0.875rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .header-right {
            display: flex;
            align-items: center;
            gap: 1.5rem;
        }

        .header-icon {
            position: relative;
            width: 40px;
            height: 40px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: var(--border-color);
            border-radius: 0.5rem;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .header-icon:hover {
            background: var(--primary-color);
            color: white;
            transform: translateY(-2px);
            box-shadow: var(--shadow-md);
        }

        .badge-notification {
            position: absolute;
            top: -5px;
            right: -5px;
            background: var(--danger-color);
            color: white;
            width: 18px;
            height: 18px;
            border-radius: 50%;
            font-size: 0.625rem;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
        }

        .user-profile {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            padding: 0.5rem 1rem;
            background: var(--border-color);
            border-radius: 2rem;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .user-profile:hover {
            background: var(--primary-color);
            color: white;
            transform: translateY(-2px);
            box-shadow: var(--shadow-md);
        }

        .user-photo {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            object-fit: cover;
            border: 2px solid white;
        }

        .user-info {
            text-align: left;
        }

        .user-name {
            font-weight: 600;
            font-size: 0.875rem;
            line-height: 1.2;
        }

        .user-role {
            font-size: 0.75rem;
            opacity: 0.8;
        }

        /* Stats Cards */
        .stats-row {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2rem;
        }

        .stat-card {
            background: white;
            padding: 1.75rem;
            border-radius: 1rem;
            box-shadow: var(--shadow-md);
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }

        .stat-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 4px;
            height: 100%;
            background: linear-gradient(180deg, var(--primary-color), var(--secondary-color));
        }

        .stat-card:hover {
            transform: translateY(-5px);
            box-shadow: var(--shadow-hover);
        }

        .stat-card-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 1rem;
        }

        .stat-info h3 {
            font-size: 0.875rem;
            color: var(--text-secondary);
            font-weight: 500;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .stat-info .count {
            font-size: 2.25rem;
            font-weight: 700;
            color: var(--text-primary);
            margin-top: 0.5rem;
            font-family: 'Space Mono', monospace;
        }

        .stat-icon {
            width: 60px;
            height: 60px;
            border-radius: 1rem;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
        }

        .stat-card.bookings .stat-icon {
            background: linear-gradient(135deg, #3b82f6, #2563eb);
            color: white;
        }

        .stat-card.checkin .stat-icon {
            background: linear-gradient(135deg, #10b981, #059669);
            color: white;
        }

        .stat-card.checkout .stat-icon {
            background: linear-gradient(135deg, #f59e0b, #d97706);
            color: white;
        }

        .stat-card.revenue .stat-icon {
            background: linear-gradient(135deg, #ec4899, #db2777);
            color: white;
        }

        .stat-trend {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            font-size: 0.875rem;
            margin-top: 0.5rem;
        }

        .stat-trend.up { color: var(--success-color); }
        .stat-trend.down { color: var(--danger-color); }

        /* Grid Layout */
        .dashboard-grid {
            display: grid;
            grid-template-columns: 1fr;
            gap: 1.5rem;
            margin-bottom: 2rem;
        }

        .bottom-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1.5rem;
            margin-bottom: 2rem;
        }

        /* Room Availability Card */
        .room-availability {
            background: white;
            padding: 2rem;
            border-radius: 1rem;
            box-shadow: var(--shadow-md);
            transition: all 0.3s ease;
        }

        .room-availability:hover { box-shadow: var(--shadow-hover); }

        .card-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1.5rem;
            padding-bottom: 1rem;
            border-bottom: 2px solid var(--border-color);
        }

        .card-header h2 {
            font-size: 1.25rem;
            font-weight: 700;
            color: var(--text-primary);
        }

        .card-menu {
            color: var(--text-secondary);
            cursor: pointer;
            font-size: 1.25rem;
            transition: color 0.3s ease;
        }

        .card-menu:hover { color: var(--primary-color); }

        .room-visual {
            display: grid;
            grid-template-columns: 3fr 1fr 1fr;
            gap: 0.5rem;
            height: 80px;
            margin-bottom: 2rem;
            border-radius: 0.75rem;
            overflow: hidden;
        }

        .room-segment {
            border-radius: 0.5rem;
            transition: all 0.3s ease;
            cursor: pointer;
        }

        .room-segment:hover {
            transform: scale(1.05);
            box-shadow: var(--shadow-md);
        }

        .room-segment.occupied { background: linear-gradient(135deg, #86efac, #4ade80); }
        .room-segment.reserved { background: linear-gradient(135deg, #fef08a, #fde047); }
        .room-segment.available { background: linear-gradient(135deg, #d9f99d, #bef264); }
        .room-segment.not-ready { background: linear-gradient(135deg, #fca5a5, #f87171); }

        .room-stats {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 1rem;
        }

        .room-stat-item {
            padding: 1rem;
            border-radius: 0.75rem;
            background: var(--border-color);
            transition: all 0.3s ease;
        }

        .room-stat-item:hover {
            background: var(--primary-color);
            color: white;
            transform: translateY(-3px);
            box-shadow: var(--shadow-md);
        }

        .room-stat-label {
            font-size: 0.875rem;
            opacity: 0.8;
            margin-bottom: 0.25rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .room-stat-label::before {
            content: '';
            width: 12px;
            height: 12px;
            border-radius: 3px;
        }

        .room-stat-item:nth-child(1) .room-stat-label::before { background: #4ade80; }
        .room-stat-item:nth-child(2) .room-stat-label::before { background: #fde047; }
        .room-stat-item:nth-child(3) .room-stat-label::before { background: #bef264; }
        .room-stat-item:nth-child(4) .room-stat-label::before { background: #f87171; }

        .room-stat-value {
            font-size: 1.875rem;
            font-weight: 700;
            font-family: 'Space Mono', monospace;
        }

        /* Overall Rating Card */
        .rating-card {
            background: white;
            padding: 2rem;
            border-radius: 1rem;
            box-shadow: var(--shadow-md);
            transition: all 0.3s ease;
        }

        .rating-card:hover { box-shadow: var(--shadow-hover); }

        .rating-score {
            text-align: center;
            padding: 1.5rem;
            background: linear-gradient(135deg, #d1fae5, #a7f3d0);
            border-radius: 1rem;
            margin-bottom: 1.5rem;
        }

        .rating-number {
            font-size: 3.5rem;
            font-weight: 700;
            color: var(--success-color);
            font-family: 'Space Mono', monospace;
        }

        .rating-number span {
            font-size: 2rem;
            color: var(--text-secondary);
        }

        .rating-label {
            font-size: 1.125rem;
            font-weight: 600;
            color: var(--success-color);
            margin-top: 0.5rem;
        }

        .rating-reviews {
            font-size: 0.875rem;
            color: var(--text-secondary);
            margin-top: 0.25rem;
        }

        .rating-breakdown {
            display: flex;
            flex-direction: column;
            gap: 1rem;
        }

        .rating-item {
            display: flex;
            align-items: center;
            gap: 1rem;
        }

        .rating-name {
            width: 100px;
            font-size: 0.875rem;
            color: var(--text-secondary);
            font-weight: 500;
        }

        .rating-bar {
            flex: 1;
            height: 8px;
            background: var(--border-color);
            border-radius: 1rem;
            overflow: hidden;
        }

        .rating-fill {
            height: 100%;
            background: linear-gradient(90deg, #fde047, #facc15);
            border-radius: 1rem;
            transition: width 0.6s ease;
        }

        .rating-value {
            width: 40px;
            text-align: right;
            font-weight: 700;
            color: var(--text-primary);
            font-family: 'Space Mono', monospace;
        }

        /* Tasks Card */
        .tasks-card {
            background: white;
            padding: 2rem;
            border-radius: 1rem;
            box-shadow: var(--shadow-md);
        }

        .tasks-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1.5rem;
            padding-bottom: 1rem;
            border-bottom: 2px solid var(--border-color);
        }

        .add-task-btn {
            width: 40px;
            height: 40px;
            border-radius: 0.5rem;
            background: linear-gradient(135deg, #fde047, #facc15);
            border: none;
            color: var(--text-primary);
            font-size: 1.25rem;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .add-task-btn:hover {
            transform: rotate(90deg) scale(1.1);
            box-shadow: var(--shadow-md);
        }

        .task-list {
            display: flex;
            flex-direction: column;
            gap: 1rem;
        }

        .task-item {
            padding: 1.25rem;
            border-radius: 0.75rem;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 1rem;
        }

        .task-item.task-green { background: linear-gradient(135deg, #d1fae5, #a7f3d0); }
        .task-item.task-yellow { background: linear-gradient(135deg, #fef3c7, #fde68a); }

        .task-item:hover {
            transform: translateX(5px);
            box-shadow: var(--shadow-md);
        }

        .task-checkbox {
            width: 20px;
            height: 20px;
            border: 2px solid var(--text-secondary);
            border-radius: 0.25rem;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .task-content { flex: 1; }

        .task-date {
            font-size: 0.75rem;
            color: var(--text-secondary);
            margin-bottom: 0.25rem;
        }

        .task-text { font-weight: 500; color: var(--text-primary); }

        .task-menu {
            color: var(--text-secondary);
            cursor: pointer;
            transition: color 0.3s ease;
        }

        .task-menu:hover { color: var(--primary-color); }

        
        /* Responsive Design */
        @media (max-width: 1200px) {
            .bottom-grid { grid-template-columns: 1fr; }
        }

        @media (max-width: 768px) {
            .sidebar { transform: translateX(-100%); }
            .sidebar.open { transform: translateX(0); }
            .sidebar-toggle { display: block; }
            .main-content { margin-left: 0; padding: 1rem; }
            .top-header { flex-direction: column; align-items: flex-start; }
            .stats-row { grid-template-columns: 1fr; }
            .reservations-table { font-size: 0.875rem; }
            .reservations-table th, .reservations-table td { padding: 0.75rem 0.5rem; }
        }

        @media (max-width: 480px) {
            .user-info { display: none; }
            .header-right { gap: 1rem; }
        }

        
        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(30px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .stat-card { animation: fadeInUp 0.6s ease backwards; }
        .stat-card:nth-child(1) { animation-delay: 0.1s; }
        .stat-card:nth-child(2) { animation-delay: 0.2s; }
        .stat-card:nth-child(3) { animation-delay: 0.3s; }
        .stat-card:nth-child(4) { animation-delay: 0.4s; }

        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.5; }
        }

        .badge-notification { animation: pulse 2s ease-in-out infinite; }
   </style>
</head>

<body>
<%
    String adminName = (String) session.getAttribute("adminName");
    if (adminName == null) adminName = "John Anderson";

    String adminRole = (String) session.getAttribute("adminRole");
    if (adminRole == null) adminRole = "Admin";

    String totalRevenue = "LKR 45,280,000";
%>

    <!-- Sidebar Toggle Button -->
    <button class="sidebar-toggle" onclick="toggleSidebar()" aria-label="Toggle sidebar">
        <i class="bi bi-list"></i>
    </button>

    <!-- Sidebar -->
    <aside class="sidebar" id="sidebar">
        <div class="sidebar-brand">
            <img src="${pageContext.request.contextPath}/images/logo.png" alt="Hotel Logo" class="sidebar-logo">
            <h3>Ocean View Resort</h3>
        </div>
        <ul class="sidebar-menu">
    <li><a href="<%= ctx %>/Views/manager.jsp" class="active"><i class="bi bi-grid-1x2-fill"></i> Dashboard</a></li>
    <li><a href="<%= ctx %>/RoomServlet"><i class="bi bi-door-open-fill"></i> Rooms</a></li>
    <li><a href="<%= ctx %>/EmployeeServlet"><i class="bi bi-person-badge-fill"></i> Employee Management</a></li>
    <li><a href="<%= ctx %>/ManagerReportsServlet"><i class="bi bi-bar-chart-fill"></i> Reports</a></li>
    <li><a href="<%= ctx %>/LogoutServlet"><i class="bi bi-box-arrow-right"></i> Logout</a></li>
</ul>
    </aside>

    <!-- Main Content -->
    <main class="main-content">
        <!-- Top Header -->
        <div class="top-header">
            <div class="header-left">
                <h1>Dashboard</h1>
                <div class="login-time">
                    <i class="bi bi-clock-fill"></i>
                    <span id="currentDateTime">-</span>
                </div>
            </div>
            <div class="header-right">
                <div class="header-icon" title="Settings">
                    <i class="bi bi-gear-fill"></i>
                </div>
                <div class="header-icon" title="Notifications">
                    <i class="bi bi-bell-fill"></i>
                    <span class="badge-notification">5</span>
                </div>
                <div class="user-profile" title="Profile">
                    <img src="https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop" alt="Admin" class="user-photo">
                    <div class="user-info">
                        <div class="user-name"><%= adminName %></div>
                        <div class="user-role"><%= adminRole %></div>
                    </div>
                </div>
            </div>
        </div>



        <!-- Dashboard Grid -->
        <div class="dashboard-grid">
            <!-- Room Availability - Full Width -->
            <div class="room-availability">
                <div class="card-header">
                    <h2>Room Availability</h2>
                    <div class="card-menu" title="More">
                        <i class="bi bi-three-dots-vertical"></i>
                    </div>
                </div>
                <div class="room-visual">
                    <div class="room-segment occupied"></div>
                    <div class="room-segment reserved"></div>
                    <div class="room-segment available"></div>
                    <div class="room-segment not-ready"></div>
                </div>
                <div class="room-stats">
                    <div class="room-stat-item">
                        <div class="room-stat-label">Total</div>
                        <div class="room-stat-value">30</div>
                    </div>
                    <div class="room-stat-item">
                        <div class="room-stat-label">Reserved</div>
                        <div class="room-stat-value">15</div>
                    </div>
                    <div class="room-stat-item">
                        <div class="room-stat-label">Available</div>
                        <div class="room-stat-value">12</div>
                    </div>
                    <div class="room-stat-item">
                        <div class="room-stat-label">Not Ready</div>
                        <div class="room-stat-value">03</div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Bottom Grid -->
        <div class="bottom-grid">
            <!-- Overall Rating -->
            <div class="rating-card">
                <div class="card-header">
                    <h2>Overall Rating</h2>
                    <div class="card-menu" title="More">
                        <i class="bi bi-three-dots-vertical"></i>
                    </div>
                </div>
                <div class="rating-score">
                    <div class="rating-number">4.6<span>/5</span></div>
                    <div class="rating-label">Impressive</div>
                    <div class="rating-reviews">from 2546 reviews</div>
                </div>
                <div class="rating-breakdown">
                    <div class="rating-item">
                        <div class="rating-name">Facilities</div>
                        <div class="rating-bar"><div class="rating-fill" style="width: 88%"></div></div>
                        <div class="rating-value">4.4</div>
                    </div>
                    <div class="rating-item">
                        <div class="rating-name">Cleanliness</div>
                        <div class="rating-bar"><div class="rating-fill" style="width: 94%"></div></div>
                        <div class="rating-value">4.7</div>
                    </div>
                    <div class="rating-item">
                        <div class="rating-name">Services</div>
                        <div class="rating-bar"><div class="rating-fill" style="width: 92%"></div></div>
                        <div class="rating-value">4.6</div>
                    </div>
                    <div class="rating-item">
                        <div class="rating-name">Comfort</div>
                        <div class="rating-bar"><div class="rating-fill" style="width: 96%"></div></div>
                        <div class="rating-value">4.8</div>
                    </div>
                    <div class="rating-item">
                        <div class="rating-name">Location</div>
                        <div class="rating-bar"><div class="rating-fill" style="width: 90%"></div></div>
                        <div class="rating-value">4.5</div>
                    </div>
                </div>
            </div>

            <!-- Tasks -->
            <div class="tasks-card">
                <div class="tasks-header">
                    <h2>Tasks</h2>
                    <button class="add-task-btn" type="button" aria-label="Add task">
                        <i class="bi bi-plus-lg"></i>
                    </button>
                </div>
                <div class="task-list">
                    <div class="task-item task-green">
                        <div class="task-checkbox"></div>
                        <div class="task-content">
                            <div class="task-date">June 19, 2028</div>
                            <div class="task-text">Set Up Conference Room B for 10 AM Meeting</div>
                        </div>
                        <div class="task-menu" title="More">
                            <i class="bi bi-three-dots-vertical"></i>
                        </div>
                    </div>
                    <div class="task-item task-yellow">
                        <div class="task-checkbox"></div>
                        <div class="task-content">
                            <div class="task-date">June 19, 2028</div>
                            <div class="task-text">Restock Housekeeping Supplies on 3rd Floor</div>
                        </div>
                        <div class="task-menu" title="More">
                            <i class="bi bi-three-dots-vertical"></i>
                        </div>
                    </div>
                    <div class="task-item task-green">
                        <div class="task-checkbox"></div>
                        <div class="task-content">
                            <div class="task-date">June 20, 2028</div>
                            <div class="task-text">Inspect and Clean the Pool Area</div>
                        </div>
                        <div class="task-menu" title="More">
                            <i class="bi bi-three-dots-vertical"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>

    </main>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
       
        function toggleSidebar() {
            const sidebar = document.getElementById('sidebar');
            sidebar.classList.toggle('open');
        }

        
        document.addEventListener('click', function(event) {
            const sidebar = document.getElementById('sidebar');
            const toggleBtn = document.querySelector('.sidebar-toggle');

            if (window.innerWidth <= 768) {
                if (!sidebar.contains(event.target) && !toggleBtn.contains(event.target)) {
                    sidebar.classList.remove('open');
                }
            }
        });

        function updateDateTime() {
            const now = new Date();
            const options = {
                weekday: 'long',
                year: 'numeric',
                month: 'long',
                day: 'numeric',
                hour: '2-digit',
                minute: '2-digit'
            };
            document.getElementById('currentDateTime').textContent =
                now.toLocaleDateString('en-US', options);
        }

        updateDateTime();
        setInterval(updateDateTime, 60000);

        window.addEventListener('load', function() {
            const ratingFills = document.querySelectorAll('.rating-fill');
            ratingFills.forEach((fill, index) => {
                const width = fill.style.width;
                fill.style.width = '0';
                setTimeout(() => {
                    fill.style.width = width;
                }, 500 + (index * 100));
            });
        });
        document.querySelectorAll('.task-checkbox').forEach(checkbox => {
            checkbox.addEventListener('click', function() {
                const hasIcon = this.querySelector('i');
                if (hasIcon) {
                    this.style.background = '';
                    this.innerHTML = '';
                } else {
                    this.style.background = 'linear-gradient(135deg, #10b981, #059669)';
                    this.innerHTML = '<i class="bi bi-check" style="color:white;font-size:0.75rem;"></i>';
                }
            });
        });
    </script>
</body>
</html>
