<%
    String role = (String) session.getAttribute("userRole");
    if (role == null || !"RECEPTIONIST".equalsIgnoreCase(role)) {
        response.sendRedirect(request.getContextPath() + "/Views/login.jsp");
        return;
    }
%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="model.Room" %>
<%@ page import="dao.RoomDAO" %>

<%
    String ctx = request.getContextPath();
    String receptionistName = "Receptionist";

    String success = request.getParameter("success");
    String error = request.getParameter("error");

    List<Room> rooms = (List<Room>) request.getAttribute("rooms");

    if (rooms == null) {
        try {
            RoomDAO dao = new RoomDAO();
            rooms = dao.getAllRooms();
        } catch (Exception e) {
            rooms = new ArrayList<>();
        }
    }

    Set<String> roomTypes = new LinkedHashSet<>();
    for (Room r : rooms) {
        if (r != null && r.getTypeName() != null && !r.getTypeName().trim().isEmpty()) {
            roomTypes.add(r.getTypeName().trim());
        }
    }
%>

<%!
    private String safe(String s){ return (s == null) ? "" : s; }

    private String statusClass(String status){
        if(status == null) return "st-available";
        switch(status.toUpperCase()){
            case "AVAILABLE": return "st-available";
            case "OCCUPIED": return "st-occupied";
            case "RESERVED": return "st-reserved";
            case "CLEANING": return "st-cleaning";
            case "MAINTENANCE": return "st-maint";
            default: return "st-available";
        }
    }

    private String statusIcon(String status){
        if(status == null) return "bi-check-circle";
        switch(status.toUpperCase()){
            case "AVAILABLE": return "bi-check-circle";
            case "OCCUPIED": return "bi-x-circle";
            case "RESERVED": return "bi-bookmark-check";
            case "CLEANING": return "bi-bucket";
            case "MAINTENANCE": return "bi-tools";
            default: return "bi-check-circle";
        }
    }

    private String escAttr(String s){
        if (s == null) return "";
        return s.replace("&","&amp;")
                .replace("\"","&quot;")
                .replace("<","&lt;")
                .replace(">","&gt;");
    }

    private boolean isAvailable(String status){
        return status != null && "AVAILABLE".equalsIgnoreCase(status.trim());
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Rooms - Receptionist | Ocean View Resort</title>

  <!-- Bootstrap 5 -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <!-- Bootstrap Icons -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">

  <style>
    html, body { height: 100%; margin: 0; }

    body{
      background: #f4f7fb;
      background-image: url("<%= ctx %>/images/bg.png");
      background-size: cover;
      background-position: center;
      background-repeat: no-repeat;
      background-attachment: fixed;
      font-family: system-ui, -apple-system, Segoe UI, Roboto, Arial, sans-serif;
    }
    .app-shell{ display:flex; min-height:100vh; }

    .flash-wrap{
      position: fixed;
      top: 12px;
      left: 12px;
      right: 12px;
      z-index: 2000;
      pointer-events: none;
    }
    .flash-wrap .alert{
      pointer-events: auto;
      border-radius:14px;
      box-shadow: 0 18px 45px rgba(0,0,0,0.10);
      margin-bottom: 0;
    }

    /* Sidebar */
    .sidebar {
      width: 280px;
      min-height: 100vh;
      background: linear-gradient(180deg, #0b4f7c 0%, #0b69a6 60%, #2687d6 100%);
      color: #fff;
      padding: 22px 0;
      position: sticky;
      top: 0;
      display: flex;
      flex-direction: column;
      box-shadow: 0 18px 55px rgba(0,0,0,0.18);
    }
    .sb-top { text-align:center; padding: 10px 18px 18px 18px; }
    .sb-logo { width: 54px; height:54px; object-fit:contain; margin-bottom: 12px; }
    .sb-title { font-weight: 800; font-size: 20px; margin-bottom: 4px; }
    .sb-subtitle { opacity: 0.95; font-weight: 600; }
    .sb-divider { height: 2px; background: rgba(255,255,255,0.15); margin: 10px 0 18px 0; }

    .sb-nav { display:flex; flex-direction:column; gap: 14px; padding: 0 18px; }
    .sb-link{
      display:flex; align-items:center; gap:14px;
      text-decoration:none; color:#fff;
      font-weight: 700;
      padding: 12px 14px;
      border-radius: 14px;
      transition: background .15s ease, transform .15s ease, box-shadow .15s ease;
    }
    .sb-link i { font-size: 18px; opacity: 0.95; width: 22px; display:inline-flex; align-items:center; justify-content:center; }
    .sb-link:hover{ background: rgba(255,255,255,0.12); transform: translateY(-1px); box-shadow: 0 14px 26px rgba(0,0,0,0.12); }
    .sb-active{ background: rgba(255,255,255,0.14); box-shadow: inset 0 0 0 1px rgba(255,255,255,0.10); }
    .sb-help{ background: transparent; border: 0; box-shadow: none !important; }
    .sb-help:hover{ background: rgba(255,255,255,0.12); box-shadow: 0 14px 26px rgba(0,0,0,0.12); }

    /* Offcanvas */
    .sidebar-offcanvas { width: 300px; background: transparent; border: 0; }
    .sidebar-mobile { width: 280px !important; min-height: 100%; position: relative; }

    /* Main */
    .main{ flex:1; padding: 18px 18px 40px 18px; }

    /* Topbar */
    .topbar{
      background: rgba(255,255,255,0.95);
      border-radius: 18px;
      padding: 14px 16px;
      display:flex; align-items:center; justify-content:space-between;
      box-shadow: 0 18px 45px rgba(0,0,0,0.10);
      backdrop-filter: blur(8px);
      -webkit-backdrop-filter: blur(8px);
    }
    .top-title{ font-weight: 800; font-size: 18px; line-height: 1.1; }
    .welcome-name{ color: #0b69a6; }
    .top-sub{ margin-top: 4px; font-weight: 600; opacity: 0.70; font-size: 13px; }

    .burger{
      width: 46px; height: 46px;
      border-radius: 14px;
      border: 0;
      background: rgba(255,255,255,0.95);
      box-shadow: 0 16px 30px rgba(0,0,0,0.10);
      display:inline-flex; align-items:center; justify-content:center;
      font-size: 26px; color: #0b69a6;
      transition: transform .15s ease, box-shadow .15s ease;
    }
    .burger:hover{ transform: translateY(-1px); box-shadow: 0 20px 40px rgba(0,0,0,0.14); }

    .icon-btn{
      width: 44px; height: 44px;
      border-radius: 14px;
      border: 0;
      background: rgba(11,105,166,0.10);
      color: #0b69a6;
      display:inline-flex; align-items:center; justify-content:center;
      font-size: 18px;
      position: relative;
      transition: transform .15s ease, box-shadow .15s ease, background .15s ease;
    }
    .icon-btn:hover{
      background: rgba(11,105,166,0.16);
      transform: translateY(-1px);
      box-shadow: 0 16px 30px rgba(0,0,0,0.10);
    }
    .notify-dot{
      width: 10px; height: 10px;
      border-radius: 50%;
      background: #ff3b30;
      position:absolute; top: 10px; right: 10px;
      box-shadow: 0 8px 18px rgba(255,59,48,0.35);
    }

    .user{
      display:flex; align-items:center; gap:10px;
      padding: 6px 10px;
      border-radius: 16px;
      background: rgba(255,255,255,0.65);
      box-shadow: inset 0 0 0 1px rgba(0,0,0,0.05);
      transition: transform .15s ease, box-shadow .15s ease;
    }
    .user:hover{ transform: translateY(-1px); box-shadow: 0 18px 40px rgba(0,0,0,0.10); }
    .user-img{
      width: 44px; height: 44px; border-radius: 50%;
      object-fit: cover;
      box-shadow: 0 12px 26px rgba(0,0,0,0.15);
      border: 2px solid rgba(255,255,255,0.8);
    }
    .user-name{ font-weight: 800; }
    .user-role{ font-weight: 600; opacity: 0.70; font-size: 12px; }

    /* Page header area */
    .page-head{
      margin-top: 14px;
      display:flex; align-items:flex-end; justify-content:space-between;
      gap: 12px; flex-wrap: wrap;
    }
    .page-title{ font-weight: 800; font-size: 18px; color: rgba(0,0,0,.80); margin: 0; }

    /* Filter bar */
    .filter-bar{
      margin-top: 12px;
      background: rgba(255,255,255,0.95);
      border-radius: 18px;
      padding: 12px;
      box-shadow: 0 18px 45px rgba(0,0,0,0.10);
      backdrop-filter: blur(8px);
    }
    .filter-input{
      height: 44px;
      border-radius: 14px;
      border: 2px solid rgba(0,0,0,0.10);
      font-weight: 600;
      box-shadow: 0 10px 18px rgba(0,0,0,0.06);
    }

    .room-card{
      background:#fff;
      border-radius: 18px;
      box-shadow: 0 18px 45px rgba(0,0,0,0.10);
      overflow:hidden;
      transition: transform .14s ease, box-shadow .14s ease;
      border: 1px solid rgba(0,0,0,0.06);
    }
    .room-card:hover{ transform: translateY(-2px); box-shadow: 0 24px 55px rgba(0,0,0,0.14); }

    .room-row{
      display:flex;
      gap: 14px;
      padding: 14px;
    }

    .room-img{
      width: 180px;
      min-width: 180px;
      height: 120px;
      border-radius: 16px;
      object-fit: cover;
      background: rgba(0,0,0,0.06);
      box-shadow: 0 14px 28px rgba(0,0,0,0.10);
    }

    .room-mid{ flex:1; min-width: 0; }
    .room-topline{
      display:flex;
      align-items:flex-start;
      justify-content:space-between;
      gap: 10px;
      flex-wrap: wrap;
    }
    .room-name{
      font-weight: 800;
      font-size: 16px;
      color:#141823;
      margin: 0;
    }
    .room-type{
      font-weight: 600;
      opacity: .72;
      font-size: 12px;
      margin-top: 3px;
    }
    .room-meta{
      margin-top: 10px;
      display:flex;
      flex-wrap:wrap;
      gap: 10px 14px;
      font-weight: 600;
      opacity: .86;
      font-size: 12px;
    }
    .room-meta i{ opacity: .85; margin-right: 6px; }

    .room-desc{
      margin-top: 10px;
      font-weight: 600;
      opacity: .70;
      font-size: 12px;
      line-height: 1.45;
      max-width: 820px;
    }

    .room-actions{
      display:flex;
      flex-direction:column;
      gap: 10px;
      min-width: 170px;
      justify-content: space-between;
    }
    .btn-soft{
      border: 0;
      border-radius: 14px;
      height: 44px;
      font-weight: 700;
      box-shadow: 0 14px 26px rgba(0,0,0,0.12);
      transition: transform .14s ease, box-shadow .14s ease;
    }
    .btn-soft:hover{ transform: translateY(-1px); box-shadow: 0 18px 34px rgba(0,0,0,0.14); }
    .btn-primary-soft{
      background: linear-gradient(90deg,#2f77c5,#6a5bd6);
      color:#fff;
    }

    .btn-disabled{
      opacity: .65;
      cursor: not-allowed;
      box-shadow: none !important;
    }

    .pill{
      padding: 8px 12px;
      border-radius: 999px;
      font-weight: 700;
      font-size: 12px;
      display:inline-flex;
      align-items:center;
      gap: 6px;
      white-space: nowrap;
    }
    .pill i{ font-size: 12px; }
    .st-available{ background: rgba(34,197,94,0.15); color:#166534; }
    .st-occupied{ background: rgba(220,53,69,0.14); color:#b02a37; }
    .st-reserved{ background: rgba(59,130,246,0.16); color:#1e40af; }
    .st-cleaning{ background: rgba(245,158,11,0.18); color:#92400e; }
    .st-maint{ background: rgba(31,41,55,0.12); color:#111827; }

    @media (max-width: 768px){
      .room-row{ flex-direction: column; }
      .room-img{ width: 100%; min-width: 0; height: 180px; }
      .room-actions{ flex-direction: row; min-width: 0; }
      .room-actions .btn-soft{ flex: 1; }
    }
    @media (max-width: 576px){
      .main{ padding: 14px; }
      .room-actions{ flex-direction: column; }
    }

    .modal-skin{
      border-radius: 18px;
      overflow:hidden;
      box-shadow: 0 22px 55px rgba(0,0,0,0.20);
    }
    .field-label{ font-weight:700; }
    .field-input{
      border-radius: 14px;
      border: 2px solid rgba(0,0,0,0.10);
      box-shadow: 0 10px 18px rgba(0,0,0,0.06);
      font-weight: 600;
      height: 44px;
    }
  </style>
</head>

<body>

  <div class="flash-wrap">
    <% if (success != null) { %>
      <div class="alert alert-success" id="flashMsg">
        <i class="bi bi-check-circle me-2"></i> Walk-in check-in saved successfully.
      </div>
    <% } else if (error != null) { %>
      <div class="alert alert-danger" id="flashMsg">
        <i class="bi bi-exclamation-triangle me-2"></i> <%= error %>
      </div>
    <% } %>
  </div>

  <div class="app-shell">

    <!-- DESKTOP SIDEBAR -->
    <aside class="sidebar d-none d-lg-flex">
      <div class="sb-top">
        <img src="<%= ctx %>/images/logo.png" class="sb-logo" alt="Logo">
        <div class="sb-title">Ocean View Resort</div>
        <div class="sb-subtitle">Receptionist Portal</div>
      </div>

      <div class="sb-divider"></div>

      <nav class="sb-nav">
        <a class="sb-link" href="<%= ctx %>/Views/receptionist.jsp"><i class="bi bi-grid-1x2-fill"></i><span>Dashboard</span></a>
        <a class="sb-link" href="<%= ctx %>/ReceptionistReservationsServlet"><i class="bi bi-journal-text"></i><span>Reservations</span></a>
        <a class="sb-link" href="<%= ctx %>/ReceptionistGuestsServlet"><i class="bi bi-people"></i><span>Customers</span></a>
        <a class="sb-link sb-active" href="<%= ctx %>/ReceptionistRoomServlet"><i class="bi bi-door-open"></i><span>Rooms</span></a>
        <a class="sb-link sb-help" href="<%= ctx %>/Views/receptionist/help.jsp"><i class="bi bi-question-circle"></i><span>Help & Guide</span></a>
        <a class="sb-link" href="<%= ctx %>/Views/login.jsp"><i class="bi bi-box-arrow-right"></i><span>Logout</span></a>
      </nav>
    </aside>

    <!-- MOBILE OFFCANVAS SIDEBAR -->
    <div class="offcanvas offcanvas-start sidebar-offcanvas d-lg-none" tabindex="-1" id="mobileSidebar">
      <div class="offcanvas-body p-0">
        <aside class="sidebar sidebar-mobile">
          <div class="sb-top">
            <img src="<%= ctx %>/images/logo.png" class="sb-logo" alt="Logo">
            <div class="sb-title">Ocean View Resort</div>
            <div class="sb-subtitle">Receptionist Portal</div>
          </div>

          <div class="sb-divider"></div>

          <nav class="sb-nav">
            <a class="sb-link" href="<%= ctx %>/Views/receptionist.jsp"><i class="bi bi-grid-1x2-fill"></i><span>Dashboard</span></a>
            <a class="sb-link" href="<%= ctx %>/ReceptionistReservationsServlet"><i class="bi bi-journal-text"></i><span>Reservations</span></a>
            <a class="sb-link" href="<%= ctx %>/ReceptionistGuestsServlet"><i class="bi bi-people"></i><span>Customers</span></a>
            <a class="sb-link sb-active" href="<%= ctx %>/ReceptionistRoomServlet"><i class="bi bi-door-open"></i><span>Rooms</span></a>
            <a class="sb-link sb-help" href="<%= ctx %>/Views/receptionist/help.jsp"><i class="bi bi-question-circle"></i><span>Help & Guide</span></a>
            <a class="sb-link" href="<%= ctx %>/Views/login.jsp"><i class="bi bi-box-arrow-right"></i><span>Logout</span></a>
          </nav>
        </aside>
      </div>
    </div>

    
    <main class="main">

      <!-- TOP HEADER -->
      <header class="topbar">
        <div class="d-flex align-items-center gap-3">
          <button class="btn burger d-lg-none" type="button"
                  data-bs-toggle="offcanvas" data-bs-target="#mobileSidebar"
                  aria-controls="mobileSidebar" aria-label="Open menu">
            <i class="bi bi-list"></i>
          </button>

          <div>
            <div class="top-title">
              Rooms • <span class="welcome-name"><%= receptionistName %></span>
            </div>
            <div class="top-sub" id="dateTime">--</div>
          </div>
        </div>

        <div class="d-flex align-items-center gap-2 gap-md-3">
          <button class="icon-btn" type="button" aria-label="Notifications">
            <i class="bi bi-bell"></i>
            <span class="notify-dot"></span>
          </button>

          <div class="user">
            <img src="https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop"
                 class="user-img" alt="Receptionist Photo">
            <div class="d-none d-sm-block">
              <div class="user-name"><%= receptionistName %></div>
              <div class="user-role">Front Desk</div>
            </div>
          </div>
        </div>
      </header>

    
      <div class="page-head">
        <div>
          <h2 class="page-title mb-0">Room List</h2>
        </div>
      </div>

      <!-- FILTER BAR -->
      <div class="filter-bar">
        <div class="row g-2 align-items-center">
          <div class="col-lg-5">
            <div class="position-relative">
              <i class="bi bi-search" style="position:absolute; left:12px; top:50%; transform:translateY(-50%); opacity:.6;"></i>
              <input id="searchInput" class="form-control filter-input ps-5" type="text"
                     placeholder="Search by room number, type, status...">
            </div>
          </div>

          <div class="col-lg-3">
            <select id="typeFilter" class="form-select filter-input">
              <option value="">Room Type: All</option>
              <% for(String t : roomTypes){ %>
                <option value="<%= escAttr(t) %>"><%= t %></option>
              <% } %>
            </select>
          </div>

          <div class="col-lg-3">
            <select id="statusFilter" class="form-select filter-input">
              <option value="">Status: All</option>
              <option value="AVAILABLE">AVAILABLE</option>
              <option value="OCCUPIED">OCCUPIED</option>
              <option value="RESERVED">RESERVED</option>
              <option value="CLEANING">CLEANING</option>
              <option value="MAINTENANCE">MAINTENANCE</option>
            </select>
          </div>

          <div class="col-lg-1 d-grid">
            <button id="resetBtn" class="btn btn-outline-dark filter-input" type="button" style="border-radius:14px;">
              Reset
            </button>
          </div>
        </div>
      </div>

      <!-- ROOMS LIST -->
      <section class="mt-3">
        <div class="row g-3" id="roomsGrid">

          <% if (rooms == null || rooms.isEmpty()) { %>
            <div class="col-12">
              <div class="alert alert-warning" style="border-radius:14px;">
                No rooms found.
              </div>
            </div>
          <% } else { %>

            <% for (Room r : rooms) {
                 String img = r.getRoomImage();
                 if (img == null || img.trim().isEmpty()) img = "images/room_placeholder.jpg";

                 String roomNumber = safe(r.getRoomNumber()).trim();
                 String typeName   = safe(r.getTypeName()).trim();
                 String status     = safe(r.getStatus()).trim();

                 String floorNo    = (r.getFloorNo() == null) ? "" : String.valueOf(r.getFloorNo());
                 String capacity   = String.valueOf(r.getCapacity());
                 String rate       = String.valueOf(r.getNightlyRate());
                 String desc       = safe(r.getDescription()).trim();
                 String notes      = safe(r.getNotes()).trim();

                 boolean available = isAvailable(status);

                 String searchBlob = (roomNumber + " " + typeName + " " + status + " " + floorNo + " " +
                                      capacity + " " + rate + " " + desc + " " + notes).toLowerCase();
            %>

            <div class="col-12 room-item"
                 data-type="<%= escAttr(typeName) %>"
                 data-status="<%= escAttr(status.toUpperCase()) %>"
                 data-search="<%= escAttr(searchBlob) %>">

              <div class="room-card">
                <div class="room-row">
                  <img class="room-img" src="<%= ctx %>/<%= img %>" alt="Room">

                  <div class="room-mid">
                    <div class="room-topline">
                      <div>
                        <p class="room-name mb-0">Room <%= roomNumber %></p>
                        <div class="room-type"><i class="bi bi-tag me-1"></i><%= typeName %></div>
                      </div>

                      <div class="d-flex align-items-center gap-2">
                        <span class="pill <%= statusClass(status) %>">
                          <i class="bi <%= statusIcon(status) %>"></i> <%= status %>
                        </span>
                      </div>
                    </div>

                    <div class="room-meta">
                      <span><i class="bi bi-people"></i> Capacity: <%= r.getCapacity() %></span>
                      <span><i class="bi bi-cash-coin"></i> Rate: LKR <%= String.format("%,.2f", r.getNightlyRate()) %> / night</span>
                      <span><i class="bi bi-building"></i> Floor: <%= (r.getFloorNo() == null ? "-" : r.getFloorNo()) %></span>
                      <span><i class="bi bi-hash"></i> Room ID: <%= r.getRoomId() %></span>
                    </div>

                    <div class="room-desc"><%= desc %></div>

                    <% if (notes != null && !notes.trim().isEmpty()) { %>
                      <div class="room-desc" style="margin-top:6px;">
                        <strong>Notes:</strong> <%= notes %>
                      </div>
                    <% } %>
                  </div>

                  <div class="room-actions">
                    <% if (available) { %>
                      <button type="button"
                              class="btn btn-soft btn-primary-soft"
                              data-bs-toggle="modal"
                              data-bs-target="#bookRoomModal"
                              data-roomnumber="<%= escAttr(roomNumber) %>"
                              data-roomtype="<%= escAttr(typeName) %>"
                              data-roomid="<%= r.getRoomId() %>">
                        <i class="bi bi-calendar-check me-2"></i>Booking
                      </button>
                    <% } else { %>
                      <button type="button" class="btn btn-soft btn-secondary btn-disabled" disabled>
                        <i class="bi bi-lock me-2"></i>Unavailable
                      </button>
                    <% } %>
                  </div>

                </div>
              </div>
            </div>

            <% } %>
          <% } %>

        </div>

        <div id="noResults" class="alert alert-info mt-3" style="border-radius:14px; display:none;">
          No rooms match your search/filters.
        </div>
      </section>

    </main>
  </div>

  <!-- BOOK ROOM MODAL -->
  <div class="modal fade" id="bookRoomModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
      <div class="modal-content modal-skin">
        <div class="modal-header">
          <h5 class="modal-title" style="font-weight:800;">
            <i class="bi bi-calendar-check me-2"></i>Room Booking
          </h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
        </div>

        <div class="modal-body">
          <form action="<%= ctx %>/WalkInCheckInServlet" method="post" id="walkinForm">
            <div class="row g-3">

              <div class="col-md-6">
                <label class="form-label field-label">Room Number</label>
                <input type="text" id="bkRoomNumber" name="roomNumber" class="form-control field-input" readonly>
              </div>

              <div class="col-md-6">
                <label class="form-label field-label">Room Type</label>
                <input type="text" id="bkRoomType" class="form-control field-input" readonly>
              </div>

              <input type="hidden" id="bkRoomId" name="roomId">

              <div class="col-md-6">
                <label class="form-label field-label">Full Name</label>
                <input type="text" name="guestName" class="form-control field-input" required>
              </div>

              <div class="col-md-6">
                <label class="form-label field-label">Phone Number</label>
                <input type="text" name="guestPhone" class="form-control field-input" required>
              </div>

              <div class="col-md-6">
                <label class="form-label field-label">NIC / Passport</label>
                <input type="text" name="guestNicPassport" class="form-control field-input">
              </div>

              <div class="col-md-6">
                <label class="form-label field-label">E-mail</label>
                <input type="email" name="guestEmail" class="form-control field-input">
              </div>

              <div class="col-md-6">
                <label class="form-label field-label">Check-in Date</label>
                <input type="date" name="checkInDate" class="form-control field-input" required>
              </div>

              <div class="col-md-6">
                <label class="form-label field-label">Check-out Date</label>
                <input type="date" name="checkOutDate" class="form-control field-input" required>
              </div>

              <div class="col-md-6">
                <label class="form-label field-label">Number of Guests</label>
                <input type="number" name="numberOfGuests" class="form-control field-input" min="1" max="10" value="1" required>
              </div>

              <div class="col-md-12">
                <label class="form-label field-label">Special Requests (Optional)</label>
                <textarea name="specialRequests" class="form-control field-input" style="height:90px;"></textarea>
              </div>

            </div>

            <div class="d-flex justify-content-end gap-2 mt-3">
              <button type="button" class="btn btn-outline-dark" data-bs-dismiss="modal" style="border-radius:14px;">
                Cancel
              </button>
              <button type="submit" class="btn btn-primary" style="border-radius:14px;">
                Check-in
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>

  <!-- Bootstrap JS -->
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

  <script>
    const dtEl = document.getElementById("dateTime");
    function updateDateTime() {
      const now = new Date();
      const date = now.toLocaleDateString(undefined, { weekday: "long", year: "numeric", month: "long", day: "numeric" });
      const time = now.toLocaleTimeString(undefined, { hour: "2-digit", minute: "2-digit", second: "2-digit" });
      dtEl.textContent = date + " • " + time;
    }
    updateDateTime();
    setInterval(updateDateTime, 1000);

    const bookModal = document.getElementById("bookRoomModal");
    if (bookModal){
      bookModal.addEventListener("show.bs.modal", function (event) {
        const btn = event.relatedTarget;
        if (!btn) return;

        document.getElementById("bkRoomNumber").value = btn.getAttribute("data-roomnumber") || "";
        document.getElementById("bkRoomType").value   = btn.getAttribute("data-roomtype") || "";
        document.getElementById("bkRoomId").value     = btn.getAttribute("data-roomid") || "";
      });
    }

   
    (function(){
      const flash = document.getElementById("flashMsg");
      if (!flash) return;

      setTimeout(() => {
        flash.style.transition = "opacity 0.5s ease";
        flash.style.opacity = "0";
        setTimeout(() => {
          flash.remove();
        }, 600);
      }, 2500);

    
      const url = new URL(window.location.href);
      if (url.searchParams.has("success") || url.searchParams.has("error") || url.searchParams.has("rid")) {
        url.searchParams.delete("success");
        url.searchParams.delete("error");
        url.searchParams.delete("rid");
        window.history.replaceState({}, document.title, url.pathname + (url.searchParams.toString() ? ("?" + url.searchParams.toString()) : ""));
      }
    })();

    const searchInput  = document.getElementById("searchInput");
    const typeFilter   = document.getElementById("typeFilter");
    const statusFilter = document.getElementById("statusFilter");
    const resetBtn     = document.getElementById("resetBtn");
    const items        = Array.from(document.querySelectorAll(".room-item"));
    const noResults    = document.getElementById("noResults");

    function applyFilters() {
      const q = (searchInput.value || "").trim().toLowerCase();
      const typeVal = (typeFilter.value || "").trim();
      const statusVal = (statusFilter.value || "").trim();

      let visibleCount = 0;

      items.forEach(el => {
        const elType = (el.getAttribute("data-type") || "").trim();
        const elStatus = (el.getAttribute("data-status") || "").trim();
        const blob = (el.getAttribute("data-search") || "").toLowerCase();

        const matchSearch = !q || blob.includes(q);
        const matchType = !typeVal || elType === typeVal;
        const matchStatus = !statusVal || elStatus === statusVal;

        const show = matchSearch && matchType && matchStatus;
        el.style.display = show ? "" : "none";
        if (show) visibleCount++;
      });

      noResults.style.display = (items.length > 0 && visibleCount === 0) ? "" : "none";
    }

    if (searchInput)  searchInput.addEventListener("input", applyFilters);
    if (typeFilter)   typeFilter.addEventListener("change", applyFilters);
    if (statusFilter) statusFilter.addEventListener("change", applyFilters);

    if (resetBtn){
      resetBtn.addEventListener("click", () => {
        searchInput.value = "";
        typeFilter.value = "";
        statusFilter.value = "";
        applyFilters();
        searchInput.focus();
      });
    }

    applyFilters();
  </script>
</body>
</html>