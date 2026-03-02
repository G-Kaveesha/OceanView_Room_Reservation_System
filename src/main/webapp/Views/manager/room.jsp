<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="model.Room" %>

<%
    // Guard: only MANAGER
    String role = (String) session.getAttribute("userRole");
    if (role == null || !"MANAGER".equalsIgnoreCase(role)) {
        response.sendRedirect(request.getContextPath() + "/Views/login.jsp");
        return;
    }

    String ctx = request.getContextPath();

    List<Room> rooms = (List<Room>) request.getAttribute("rooms");
    if (rooms == null) {
        response.sendRedirect(ctx + "/RoomServlet");
        return;
    }

    String flashMsg = (String) request.getAttribute("flashMsg");
    String flashType = (String) request.getAttribute("flashType");

    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

    String adminName = (String) session.getAttribute("adminName");
    if (adminName == null) adminName = "Manager";

    String adminRole = (String) session.getAttribute("adminRole");
    if (adminRole == null) adminRole = "MANAGER";
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Room Management - Ocean View Resort</title>

<!-- prevent browser caching HTML -->
<meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
<meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Expires" content="0" />

<!-- Bootstrap 5 -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<!-- Bootstrap Icons -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
<!-- Google Fonts (same feel as manager.jsp) -->
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

        --card-bg: rgba(255, 255, 255, 0.92);
        --text-primary: #1f2937;
        --text-secondary: #6b7280;
        --border-color: rgba(15, 23, 42, 0.10);
        --shadow-sm: 0 2px 4px rgba(0,0,0,0.04);
        --shadow-md: 0 6px 18px rgba(0,0,0,0.10);
        --shadow-lg: 0 10px 30px rgba(0,0,0,0.14);
        --shadow-hover: 0 12px 40px rgba(99, 102, 241, 0.15);
    }

    * { margin: 0; padding: 0; box-sizing: border-box; }

    body {
        font-family: 'Outfit', sans-serif;
        background-image: url("<%= ctx %>/images/bg.png");
        background-size: cover;
        background-position: center;
        background-attachment: fixed;
        color: var(--text-primary);
        min-height: 100vh;
    }

    /* subtle overlay for readability */
    body::before{
        content:"";
        position: fixed;
        inset: 0;
        background: rgba(2, 6, 23, 0.35);
        backdrop-filter: blur(8px);
        -webkit-backdrop-filter: blur(8px);
        z-index: -1;
    }

    /* Sidebar (same as manager.jsp) */
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
        align-items: center;
        gap: 1rem;
        font-family: 'Lucida Sans', 'Lucida Sans Regular', 'Lucida Grande', 'Lucida Sans Unicode', Geneva, Verdana, sans-serif;
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
        margin: 0;
    }

    .sidebar-menu li { margin-bottom: 0.5rem; }

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

    .sidebar-menu i { width: 20px; text-align: center; }

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

    /* Main content */
    .main-content {
        margin-left: 260px;
        padding: 2rem;
        transition: margin-left 0.3s ease;
    }

    /* Top header */
    .top-header {
        background: rgba(255,255,255,0.95);
        padding: 1.25rem 1.5rem;
        border-radius: 1rem;
        margin-bottom: 1.5rem;
        box-shadow: var(--shadow-md);
        display: flex;
        justify-content: space-between;
        align-items: center;
        flex-wrap: wrap;
        gap: 1rem;
        border: 1px solid rgba(255,255,255,0.60);
    }

    .header-left h1 {
        font-size: 1.65rem;
        font-weight: 700;
        color: var(--text-primary);
        margin: 0 0 0.25rem 0;
    }

    .login-time {
        color: var(--text-secondary);
        font-size: 0.9rem;
        display: flex;
        align-items: center;
        gap: 0.5rem;
    }

    .header-right {
        display: flex;
        align-items: center;
        gap: 1rem;
        flex-wrap: wrap;
    }

    .header-icon {
        position: relative;
        width: 40px;
        height: 40px;
        display: flex;
        align-items: center;
        justify-content: center;
        background: rgba(229, 231, 235, 0.9);
        border-radius: 0.65rem;
        cursor: pointer;
        transition: all 0.3s ease;
        border: 1px solid rgba(15,23,42,0.08);
    }

    .header-icon:hover {
        background: var(--primary-color);
        color: white;
        transform: translateY(-2px);
        box-shadow: var(--shadow-md);
    }

    .user-profile {
        display: flex;
        align-items: center;
        gap: 0.75rem;
        padding: 0.5rem 0.9rem;
        background: rgba(229, 231, 235, 0.9);
        border-radius: 2rem;
        cursor: pointer;
        transition: all 0.3s ease;
        border: 1px solid rgba(15,23,42,0.08);
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
        background: #fff;
    }

    .user-info { text-align: left; }
    .user-name { font-weight: 600; font-size: 0.9rem; line-height: 1.2; }
    .user-role { font-size: 0.75rem; opacity: 0.85; }

    /* Content wrapper card */
    .content-card {
        background: var(--card-bg);
        border: 1px solid rgba(255,255,255,0.55);
        border-radius: 1.15rem;
        box-shadow: var(--shadow-lg);
        overflow: hidden;
    }

    .content-card-head {
        padding: 1rem 1.25rem;
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 0.75rem;
        flex-wrap: wrap;
        border-bottom: 1px solid rgba(15,23,42,0.08);
        background: linear-gradient(90deg, rgba(99,102,241,0.12), rgba(139,92,246,0.10));
    }

    .content-title {
        display: flex;
        align-items: center;
        gap: 0.6rem;
        font-weight: 700;
        font-size: 1.05rem;
        margin: 0;
    }

    .content-title i { color: var(--primary-dark); }

    .content-card-body { padding: 1.25rem; }

    /* Form + table cards */
    .panel {
        background: #fff;
        border: 1px solid rgba(15,23,42,0.10);
        border-radius: 1rem;
        box-shadow: 0 14px 26px rgba(0,0,0,0.08);
        overflow: hidden;
    }

    .panel-head {
        padding: 0.95rem 1rem;
        display: flex;
        justify-content: space-between;
        align-items: center;
        border-bottom: 1px solid rgba(15,23,42,0.08);
        background: linear-gradient(90deg, rgba(16,185,129,0.10), rgba(59,130,246,0.08));
    }

    .panel-head .title {
        display: flex;
        align-items: center;
        gap: 0.6rem;
        font-weight: 700;
        margin: 0;
        font-size: 1rem;
    }
    .panel-head .title i { color: var(--success-color); }

    .field-label {
        font-weight: 600;
        font-size: 0.85rem;
        color: rgba(31,41,55,0.80);
        margin-bottom: 0.45rem;
    }

    .field-input {
        border-radius: 0.9rem;
        border: 2px solid rgba(15, 23, 42, 0.12);
        box-shadow: 0 10px 18px rgba(0,0,0,0.05);
        font-weight: 500;
        min-height: 44px;
    }

    textarea.field-input {
        min-height: 110px;
        padding-top: 10px;
        padding-bottom: 10px;
    }

    .field-input:focus {
        border-color: rgba(99,102,241,0.65);
        box-shadow: 0 0 0 0.2rem rgba(99,102,241,0.18);
    }

    .btn-primary-grad {
        min-height: 46px;
        border-radius: 0.9rem;
        font-weight: 700;
        border: 0;
        background: linear-gradient(90deg, var(--primary-color), var(--secondary-color));
        color: #fff;
        box-shadow: 0 14px 26px rgba(0,0,0,0.18);
        padding: 0.6rem 1rem;
    }
    .btn-primary-grad:hover { filter: brightness(0.98); transform: translateY(-1px); }

    .chip {
        display: inline-flex;
        align-items: center;
        gap: 0.5rem;
        padding: 0.55rem 0.8rem;
        border-radius: 999px;
        font-weight: 600;
        font-size: 0.85rem;
        background: rgba(99,102,241,0.12);
        color: #1e40af;
        border: 1px solid rgba(99,102,241,0.22);
        text-decoration: none;
        white-space: nowrap;
    }

    /* Table */
    .table-panel { margin-top: 1rem; }
    .table-panel .panel-head{
        background: linear-gradient(90deg, rgba(99,102,241,0.10), rgba(236,72,153,0.08));
    }
    .table-panel .panel-head .title i { color: var(--primary-dark); }

    table { margin: 0; }
    thead th {
        font-size: 0.78rem;
        letter-spacing: .5px;
        text-transform: uppercase;
        font-weight: 700;
        color: #fff;
        background: linear-gradient(90deg, var(--primary-color), var(--secondary-color));
        border: 0 !important;
        padding: 0.95rem 0.8rem !important;
        vertical-align: middle;
        white-space: nowrap;
    }
    tbody td {
        font-weight: 500;
        color: rgba(15,23,42,0.86);
        border-color: rgba(15,23,42,0.08) !important;
        padding: 0.95rem 0.8rem !important;
        vertical-align: middle;
    }
    tbody tr:hover { background: rgba(99,102,241,0.06); }

    .badge-pill {
        font-weight: 700;
        border-radius: 999px;
        padding: 0.35rem 0.65rem;
        font-size: 0.78rem;
        border: 1px solid rgba(15,23,42,0.10);
        background: rgba(59,130,246,0.10);
        color: #1e40af;
        white-space: nowrap;
    }
    .badge-active {
        background: rgba(16,185,129,0.14);
        color: #065f46;
        border-color: rgba(16,185,129,0.25);
    }
    .badge-inactive {
        background: rgba(245,158,11,0.14);
        color: #92400e;
        border-color: rgba(245,158,11,0.25);
    }
    .badge-status {
        background: rgba(99,102,241,0.12);
        color: #3730a3;
        border-color: rgba(99,102,241,0.22);
    }

    .btn-icon {
        width: 38px;
        height: 38px;
        border-radius: 0.85rem;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        border: 1px solid rgba(15,23,42,0.10);
        background: #fff;
        color: rgba(15,23,42,0.75);
        box-shadow: 0 10px 18px rgba(0,0,0,0.05);
        transition: transform .12s ease, background .12s ease, color .12s ease;
    }
    .btn-icon:hover { transform: translateY(-1px); }
    .btn-edit:hover { background: rgba(59,130,246,0.12); color: #1e40af; }
    .btn-del:hover { background: rgba(239,68,68,0.12); color: #991b1b; }

    .thumb {
        width: 56px;
        height: 42px;
        border-radius: 0.75rem;
        object-fit: cover;
        border: 1px solid rgba(15,23,42,0.10);
        box-shadow: 0 10px 18px rgba(0,0,0,0.05);
        background: #f1f5f9;
    }

    /* Responsive */
    @media (max-width: 768px) {
        .sidebar { transform: translateX(-100%); }
        .sidebar.open { transform: translateX(0); }
        .sidebar-toggle { display: block; }
        .main-content { margin-left: 0; padding: 1rem; }
        .top-header { padding: 1rem; }
    }
    @media (max-width: 480px) {
        .user-info { display: none; }
    }
</style>
</head>

<body>

<!-- Sidebar Toggle Button -->
<button class="sidebar-toggle" onclick="toggleSidebar()" aria-label="Toggle sidebar">
    <i class="bi bi-list"></i>
</button>

<!-- Sidebar -->
<aside class="sidebar" id="sidebar">
    <div class="sidebar-brand">
        <img src="<%= ctx %>/images/logo.png" alt="Hotel Logo" class="sidebar-logo">
        <h3>Ocean View Resort</h3>
    </div>
<ul class="sidebar-menu">
    <li><a href="<%= ctx %>/Views/manager.jsp"><i class="bi bi-grid-1x2-fill"></i> Dashboard</a></li>
    <li><a href="<%= ctx %>/RoomServlet" class="active"><i class="bi bi-door-open-fill"></i> Rooms</a></li>
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
            <h1>Rooms</h1>
            <div class="login-time">
                <i class="bi bi-clock-fill"></i>
                <span id="currentDateTime">-</span>
            </div>
        </div>

        <div class="header-right">
            <div class="header-icon" title="Refresh" onclick="window.location.href='<%= ctx %>/RoomServlet'">
                <i class="bi bi-arrow-repeat"></i>
            </div>
            <div class="user-profile" title="Profile">
                <img src="<%= ctx %>/images/logo_black.png" alt="Admin" class="user-photo">
                <div class="user-info">
                    <div class="user-name"><%= adminName %></div>
                    <div class="user-role"><%= adminRole %></div>
                </div>
            </div>
        </div>
    </div>

    <div class="content-card">
        <div class="content-card-head">
            <h2 class="content-title"><i class="bi bi-door-open-fill"></i> Room Management</h2>
            <a class="chip" href="<%= ctx %>/RoomServlet"><i class="bi bi-arrow-repeat"></i> Refresh</a>
        </div>

        <div class="content-card-body">

            <!-- Flash -->
            <%
                if (flashMsg != null) {
            %>
            <div class="alert alert-<%= (flashType == null ? "info" : flashType) %> alert-dismissible fade show" role="alert" style="border-radius:0.9rem;">
                <span><%= flashMsg %></span>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <%
                }
            %>

            <!-- Create Room -->
            <div class="panel">
                <div class="panel-head">
                    <h3 class="title"><i class="bi bi-plus-circle-fill"></i> Create Room</h3>
                </div>

                <div class="p-3 p-md-4">
                    <form action="<%= ctx %>/RoomServlet?action=add" method="POST" enctype="multipart/form-data" class="row g-3">
                        <div class="col-12 col-md-4">
                            <label class="field-label">Room Number</label>
                            <input class="form-control field-input" name="roomNumber" required>
                        </div>

                        <div class="col-12 col-md-4">
                            <label class="field-label">Floor No</label>
                            <input type="number" class="form-control field-input" name="floorNo">
                        </div>

                        <div class="col-12 col-md-4">
                            <label class="field-label">Room Type</label>
                            <select class="form-select field-input" name="typeName" required>
                                <option value="" disabled selected>Select Room Type</option>
                                <option>Standard</option>
                                <option>Deluxe</option>
                                <option>Deluxe Sea View</option>
                                <option>Suite</option>
                                <option>Family</option>
                                <option>Single</option>
                            </select>
                        </div>

                        <div class="col-12 col-md-4">
                            <label class="field-label">Capacity</label>
                            <input type="number" class="form-control field-input" name="capacity" min="1" value="1" required>
                        </div>

                        <div class="col-12 col-md-4">
                            <label class="field-label">Nightly Rate (LKR)</label>
                            <input type="number" step="0.01" class="form-control field-input" name="nightlyRate" required>
                        </div>

                        <div class="col-12 col-md-4">
                            <label class="field-label">Active</label>
                            <select class="form-select field-input" name="isActive">
                                <option value="1" selected>Yes</option>
                                <option value="0">No</option>
                            </select>
                        </div>

                        <div class="col-12">
                            <label class="field-label">Description</label>
                            <textarea class="form-control field-input" name="description"></textarea>
                        </div>

                        <div class="col-12 col-md-6">
                            <label class="field-label">Room Image</label>
                            <input type="file" class="form-control field-input" name="roomImage" accept="image/*">
                        </div>

                        <div class="col-12 col-md-6">
                            <label class="field-label">Notes</label>
                            <input class="form-control field-input" name="notes">
                        </div>

                        <div class="col-12 text-end">
                            <button type="submit" class="btn btn-primary-grad">
                                <i class="bi bi-plus-lg me-1"></i> Create Room
                            </button>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Rooms Table -->
            <div class="panel table-panel">
                <div class="panel-head">
                    <h3 class="title"><i class="bi bi-table"></i> All Rooms</h3>
                    <a class="chip" href="<%= ctx %>/RoomServlet"><i class="bi bi-arrow-repeat"></i> Refresh</a>
                </div>

                <div class="table-responsive">
                    <table class="table align-middle">
                        <thead>
                        <tr>
                            <th>Image</th>
                            <th>Room No.</th>
                            <th>Floor</th>
                            <th>Type</th>
                            <th>Capacity</th>
                            <th>Rate</th>
                            <th>Active</th>
                            <th>Status</th>
                            <th>Updated</th>
                            <th class="text-end">Actions</th>
                        </tr>
                        </thead>

                        <tbody id="roomsTbody">
                        <%
                            if (rooms.isEmpty()) {
                        %>
                        <tr>
                            <td colspan="10" class="text-center text-muted py-4">No rooms found.</td>
                        </tr>
                        <%
                            } else {
                                for (Room r : rooms) {
                                    String img = r.getRoomImage();
                                    if (img == null || img.trim().isEmpty()) img = "images/room_demo.jpg";

                                    String activeClass = (r.getIsActive() == 1) ? "badge-active" : "badge-inactive";
                                    String activeText  = (r.getIsActive() == 1) ? "Yes" : "No";
                        %>
                        <tr>
                            <td><img class="thumb" src="<%= ctx + "/" + img %>" alt="Room"></td>
                            <td><%= r.getRoomNumber() %></td>
                            <td><%= (r.getFloorNo() == null ? "-" : r.getFloorNo()) %></td>
                            <td><%= r.getTypeName() %></td>
                            <td><%= r.getCapacity() %></td>
                            <td>LKR <%= String.format("%.2f", r.getNightlyRate()) %></td>
                            <td>
                                <span class="badge-pill <%= activeClass %>"><%= activeText %></span>
                            </td>
                            <td>
                                <span class="badge-pill badge-status"><%= (r.getStatus() == null ? "-" : r.getStatus()) %></span>
                            </td>
                            <td><%= (r.getUpdatedAt() == null ? "-" : sdf.format(r.getUpdatedAt())) %></td>

                            <td class="text-end">
                                <!-- EDIT -->
                                <button
                                        class="btn-icon btn-edit"
                                        type="button"
                                        title="Edit"
                                        data-bs-toggle="modal"
                                        data-bs-target="#editRoomModal"

                                        data-room-id="<%= r.getRoomId() %>"
                                        data-room-number="<%= r.getRoomNumber() %>"
                                        data-floor-no="<%= (r.getFloorNo()==null ? "" : r.getFloorNo()) %>"
                                        data-type-name="<%= r.getTypeName() %>"
                                        data-capacity="<%= r.getCapacity() %>"
                                        data-nightly-rate="<%= r.getNightlyRate() %>"
                                        data-is-active="<%= r.getIsActive() %>"
                                        data-description="<%= (r.getDescription()==null ? "" : r.getDescription().replace("\"","&quot;")) %>"
                                        data-notes="<%= (r.getNotes()==null ? "" : r.getNotes().replace("\"","&quot;")) %>"
                                        data-status="<%= (r.getStatus()==null ? "" : r.getStatus()) %>"
                                >
                                    <i class="bi bi-pencil-square"></i>
                                </button>

                                <!-- DELETE -->
                                <form action="<%= ctx %>/RoomServlet?action=delete" method="POST"
                                      style="display:inline" onsubmit="return confirm('Delete this room permanently?');">
                                    <input type="hidden" name="roomId" value="<%= r.getRoomId() %>">
                                    <button class="btn-icon btn-del" type="submit" title="Delete">
                                        <i class="bi bi-trash3"></i>
                                    </button>
                                </form>
                            </td>
                        </tr>
                        <%
                                }
                            }
                        %>
                        </tbody>
                    </table>
                </div>
            </div>

        </div>
    </div>
</main>

<!-- EDIT MODAL -->
<div class="modal fade" id="editRoomModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-xl modal-dialog-centered">
        <div class="modal-content" style="border-radius:18px; overflow:hidden;">
            <div class="modal-header" style="background:#eef2ff;">
                <h5 class="modal-title" style="font-weight:700;">
                    <i class="bi bi-pencil-square me-2"></i> Edit Room (Status Locked)
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>

            <form action="<%= ctx %>/RoomServlet?action=update" method="POST" enctype="multipart/form-data">
                <div class="modal-body p-4">
                    <input type="hidden" name="roomId" id="edit_roomId">

                    <div class="row g-3">
                        <div class="col-md-4">
                            <label class="field-label">Room Number</label>
                            <input class="form-control field-input" name="roomNumber" id="edit_roomNumber" required>
                        </div>

                        <div class="col-md-4">
                            <label class="field-label">Floor No</label>
                            <input type="number" class="form-control field-input" name="floorNo" id="edit_floorNo">
                        </div>

                        <div class="col-md-4">
                            <label class="field-label">Room Type</label>
                            <select class="form-select field-input" name="typeName" id="edit_typeName" required>
                                <option value="" disabled>Select Room Type</option>
                                <option>Standard</option>
                                <option>Deluxe</option>
                                <option>Deluxe Sea View</option>
                                <option>Suite</option>
                            </select>
                        </div>

                        <div class="col-md-4">
                            <label class="field-label">Capacity</label>
                            <input type="number" class="form-control field-input" name="capacity" id="edit_capacity" min="1" required>
                        </div>

                        <div class="col-md-4">
                            <label class="field-label">Nightly Rate (LKR)</label>
                            <input type="number" step="0.01" class="form-control field-input" name="nightlyRate" id="edit_nightlyRate" required>
                        </div>

                        <div class="col-md-4">
                            <label class="field-label">Active</label>
                            <select class="form-select field-input" name="isActive" id="edit_isActive">
                                <option value="1">Yes</option>
                                <option value="0">No</option>
                            </select>
                        </div>

                        <div class="col-12">
                            <label class="field-label">Description</label>
                            <textarea class="form-control field-input" name="description" id="edit_description"></textarea>
                        </div>

                        <div class="col-md-6">
                            <label class="field-label">Replace Room Image</label>
                            <input type="file" class="form-control field-input" name="roomImageEdit" accept="image/*">
                        </div>

                        <div class="col-md-6">
                            <label class="field-label">Notes</label>
                            <input class="form-control field-input" name="notes" id="edit_notes">
                        </div>

                        <div class="col-12">
                            <label class="field-label">Status (Receptionist/System)</label>
                            <input class="form-control field-input" id="edit_status" disabled>
                        </div>
                    </div>
                </div>

                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal" style="border-radius:0.9rem;">Cancel</button>
                    <button type="submit" class="btn btn-primary-grad">
                        <i class="bi bi-check2-circle me-1"></i> Save Changes
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<script>
    // Toggle Sidebar for Mobile
    function toggleSidebar() {
        const sidebar = document.getElementById('sidebar');
        sidebar.classList.toggle('open');
    }

    // Close sidebar when clicking outside on mobile
    document.addEventListener('click', function(event) {
        const sidebar = document.getElementById('sidebar');
        const toggleBtn = document.querySelector('.sidebar-toggle');

        if (window.innerWidth <= 768) {
            if (!sidebar.contains(event.target) && !toggleBtn.contains(event.target)) {
                sidebar.classList.remove('open');
            }
        }
    });

    // Update Date and Time (top header)
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

    // Fill edit modal
    const editModal = document.getElementById('editRoomModal');
    editModal.addEventListener('show.bs.modal', function (event) {
        const btn = event.relatedTarget;

        document.getElementById('edit_roomId').value = btn.getAttribute('data-room-id');
        document.getElementById('edit_roomNumber').value = btn.getAttribute('data-room-number') || '';
        document.getElementById('edit_floorNo').value = btn.getAttribute('data-floor-no') || '';
        document.getElementById('edit_typeName').value = btn.getAttribute('data-type-name') || '';
        document.getElementById('edit_capacity').value = btn.getAttribute('data-capacity') || '';
        document.getElementById('edit_nightlyRate').value = btn.getAttribute('data-nightly-rate') || '';
        document.getElementById('edit_isActive').value = btn.getAttribute('data-is-active') || '1';
        document.getElementById('edit_description').value = btn.getAttribute('data-description') || '';
        document.getElementById('edit_notes').value = btn.getAttribute('data-notes') || '';
        document.getElementById('edit_status').value = btn.getAttribute('data-status') || '';
    });
</script>

</body>
</html>