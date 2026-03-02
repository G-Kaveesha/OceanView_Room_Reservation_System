<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="model.ReservationRequest" %>

<%
    // Guard: only RECEPTIONIST
    String role = (String) session.getAttribute("userRole");
    if (role == null || !"RECEPTIONIST".equalsIgnoreCase(role)) {
        response.sendRedirect(request.getContextPath() + "/Views/login.jsp");
        return;
    }

    String ctx = request.getContextPath();
    String receptionistName = "Receptionist"; 

    List<ReservationRequest> reservationList =
            (List<ReservationRequest>) request.getAttribute("reservationList");

    List<ReservationRequest> pendingRequests =
            (List<ReservationRequest>) request.getAttribute("pendingRequests");

    Integer pendingCountObj   = (Integer) request.getAttribute("pendingCount");
    Integer confirmedCountObj = (Integer) request.getAttribute("confirmedCount");
    Integer checkedInCountObj = (Integer) request.getAttribute("checkedInCount");
    Integer todayCountObj     = (Integer) request.getAttribute("todayCount");

    int pendingCount   = (pendingCountObj == null) ? 0 : pendingCountObj;
    int confirmedCount = (confirmedCountObj == null) ? 0 : confirmedCountObj;
    int checkedInCount = (checkedInCountObj == null) ? 0 : checkedInCountObj;
    int todayCount     = (todayCountObj == null) ? 0 : todayCountObj;
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Reservations - Receptionist | Ocean View Resort</title>

  <!-- Bootstrap 5 -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <!-- Bootstrap Icons -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">

  <style>
    :root{
      --brand1:#2f77c5;
      --brand2:#6a5bd6;
      --brandDark:#0b4f7c;
      --ink:#141823;
      --card:#ffffff;
      --glass:rgba(255,255,255,.92);
      --line:rgba(0,0,0,.06);
      --shadow:0 18px 45px rgba(0,0,0,.10);
      --radius:18px;
      --radius-sm:14px;
    }

    html, body { height: 100%; margin: 0; }
    body{
      background:#f4f7fb url("<%= ctx %>/images/bg.png") center/cover no-repeat fixed;
      font-family: system-ui, -apple-system, Segoe UI, Roboto, Arial, sans-serif;
      color: var(--ink);
    }
    .app-shell{ display:flex; min-height:100vh; }

    /* Sidebar */
    .sidebar{
      width:280px;
      min-height:100vh;
      background: linear-gradient(180deg, var(--brandDark) 0%, #0b69a6 60%, #2687d6 100%);
      color:#fff;
      padding:22px 0;
      position: sticky;
      top: 0;
      display:flex;
      flex-direction:column;
      box-shadow: 0 18px 55px rgba(0,0,0,.18);
    }
    .sb-top{ text-align:center; padding: 10px 18px 18px 18px; }
    .sb-logo{ width:54px; height:54px; object-fit:contain; margin-bottom:12px; }
    .sb-title{ font-size:20px; margin-bottom:4px; font-weight:600; }
    .sb-subtitle{ opacity:.95; font-weight:500; }
    .sb-divider{ height:2px; background: rgba(255,255,255,.15); margin: 10px 0 18px 0; }

    .sb-nav{ display:flex; flex-direction:column; gap: 14px; padding:0 18px; }
    .sb-link{
      display:flex; align-items:center; gap:14px;
      text-decoration:none; color:#fff;
      font-weight:500;
      padding: 12px 14px;
      border-radius: var(--radius-sm);
      transition: background .15s ease, transform .15s ease, box-shadow .15s ease;
    }
    .sb-link i{ font-size:18px; opacity:.95; width:22px; display:inline-flex; align-items:center; justify-content:center; }
    .sb-link:hover{ background: rgba(255,255,255,.12); transform: translateY(-1px); box-shadow: 0 14px 26px rgba(0,0,0,.12); }
    .sb-active{ background: rgba(255,255,255,.14); box-shadow: inset 0 0 0 1px rgba(255,255,255,.10); }
    .sb-help{ background: transparent; border:0; box-shadow:none !important; }
    .sb-help:hover{ background: rgba(255,255,255,.12); box-shadow: 0 14px 26px rgba(0,0,0,.12); }

    /* Mobile sidebar */
    .sidebar-offcanvas{ width:300px; background:transparent; border:0; }
    .sidebar-mobile{ width:280px !important; min-height:100%; position:relative; }

    /* Main */
    .main{ flex:1; padding: 18px 18px 40px 18px; }

    /* Topbar */
    .topbar{
      background: rgba(255,255,255,.95);
      border-radius: var(--radius);
      padding: 14px 16px;
      display:flex; align-items:center; justify-content:space-between;
      box-shadow: var(--shadow);
      backdrop-filter: blur(8px);
      -webkit-backdrop-filter: blur(8px);
      border: 1px solid var(--line);
    }
    .top-title{ font-size:18px; line-height:1.1; font-weight:600; }
    .welcome-name{ color:#0b69a6; }
    .top-sub{ margin-top:4px; font-weight:500; opacity:.70; font-size:13px; }

    .burger{
      width:46px; height:46px;
      border-radius: var(--radius-sm);
      border:0;
      background: rgba(255,255,255,.95);
      box-shadow: 0 16px 30px rgba(0,0,0,.10);
      display:inline-flex; align-items:center; justify-content:center;
      font-size:26px; color:#0b69a6;
      transition: transform .15s ease, box-shadow .15s ease;
    }
    .burger:hover{ transform: translateY(-1px); box-shadow: 0 20px 40px rgba(0,0,0,.14); }

    .icon-btn{
      width:44px; height:44px;
      border-radius: var(--radius-sm);
      border:0;
      background: rgba(11,105,166,.10);
      color:#0b69a6;
      display:inline-flex; align-items:center; justify-content:center;
      font-size:18px;
      position:relative;
      transition: transform .15s ease, box-shadow .15s ease, background .15s ease;
    }
    .icon-btn:hover{
      background: rgba(11,105,166,.16);
      transform: translateY(-1px);
      box-shadow: 0 16px 30px rgba(0,0,0,.10);
    }
    .notify-dot{
      width:10px; height:10px;
      border-radius:50%;
      background:#ff3b30;
      position:absolute; top:10px; right:10px;
      box-shadow: 0 8px 18px rgba(255,59,48,.35);
      display:none;
    }
    .user{
      display:flex; align-items:center; gap:10px;
      padding: 6px 10px;
      border-radius: 16px;
      background: rgba(255,255,255,.65);
      box-shadow: inset 0 0 0 1px rgba(0,0,0,.05);
      transition: transform .15s ease, box-shadow .15s ease;
    }
    .user:hover{ transform: translateY(-1px); box-shadow: 0 18px 40px rgba(0,0,0,.10); }
    .user-img{
      width:44px; height:44px; border-radius:50%;
      object-fit:cover;
      box-shadow: 0 12px 26px rgba(0,0,0,.15);
      border: 2px solid rgba(255,255,255,.8);
    }
    .user-name{ font-weight:600; }
    .user-role{ font-weight:500; opacity:.70; font-size:12px; }

    /* Page head */
    .page-head{
      margin-top:14px;
      display:flex; align-items:flex-end; justify-content:space-between;
      gap:12px; flex-wrap:wrap;
    }
    .page-title{ font-weight:600; font-size:18px; color: rgba(0,0,0,.80); margin:0; }
    .page-sub{ font-weight:500; opacity:.70; margin: 4px 0 0; font-size:13px; }

    /* KPI cards */
    .kpi-card{
      background: var(--card);
      border-radius: var(--radius);
      padding: 14px;
      display:flex; align-items:center; gap:12px;
      box-shadow: var(--shadow);
      border: 1px solid var(--line);
      transition: transform .14s ease, box-shadow .14s ease;
    }
    .kpi-card:hover{ transform: translateY(-2px); box-shadow: 0 24px 55px rgba(0,0,0,.14); }
    .kpi-icon{
      width:52px; height:52px;
      border-radius: var(--radius);
      display:flex; align-items:center; justify-content:center;
      font-size:20px;
      flex:0 0 auto;
    }
    .bg-soft-blue{ background: rgba(59,130,246,.14); color:#1d4ed8; }
    .bg-soft-green{ background: rgba(34,197,94,.14); color:#166534; }
    .bg-soft-amber{ background: rgba(245,158,11,.18); color:#92400e; }
    .bg-soft-purple{ background: rgba(168,85,247,.14); color:#6b21a8; }
    .kpi-label{ font-weight:500; opacity:.70; font-size:12px; }
    .kpi-value{ font-weight:600; font-size:20px; color: var(--ink); }

    /* Table card */
    .cardx{
      background: var(--card);
      border-radius: var(--radius);
      box-shadow: var(--shadow);
      overflow:hidden;
      border: 1px solid var(--line);
    }
    .cardx-head{
      padding: 14px 16px;
      border-bottom: 1px solid var(--line);
      display:flex; align-items:center; justify-content:space-between;
      gap:10px; flex-wrap:wrap;
    }
    .cardx-title{ font-weight:600; }

    .res-table thead th{
      background: linear-gradient(90deg,var(--brand1),var(--brand2));
      color:#fff;
      font-weight:500;
      font-size:12px;
      padding: 14px 14px;
      white-space: nowrap;
    }
    .res-table tbody td{
      padding: 14px 14px;
      font-weight:500;
      opacity:.92;
      border-top: 1px solid var(--line);
      vertical-align: middle;
    }

    .muted{ font-size:12px; opacity:.75; }

    .pill{
      padding: 8px 12px;
      border-radius: 999px;
      font-weight:500;
      font-size:12px;
      display:inline-flex; align-items:center; gap:6px;
      white-space: nowrap;
    }
    .p-pending{ background: rgba(245,158,11,.18); color:#92400e; }
    .p-confirmed{ background: rgba(59,130,246,.16); color:#1e40af; }
    .p-in{ background: rgba(34,197,94,.14); color:#166534; }
    .p-out{ background: rgba(31,41,55,.12); color:#111827; }
    .p-cancel{ background: rgba(220,53,69,.14); color:#b02a37; }

    .notif-offcanvas{
      width:380px;
      border:0;
      background: rgba(255,255,255,.92);
      backdrop-filter: blur(10px);
    }
    .notif-head{ background: linear-gradient(90deg,var(--brand1),var(--brand2)); color:#fff; }
    .notif-item{
      background:#fff;
      border-radius: 16px;
      padding: 12px;
      border: 1px solid var(--line);
      box-shadow: 0 14px 26px rgba(0,0,0,.08);
    }
    .notif-title{ margin:0; font-weight:600; }
    .notif-sub{ font-weight:500; opacity:.75; font-size:12px; margin-top:4px; }
    .notif-meta{ margin-top:10px; display:flex; gap:10px; flex-wrap:wrap; font-weight:500; font-size:12px; opacity:.85; }
    .notif-actions{ margin-top:10px; display:flex; gap:8px; flex-wrap:wrap; }

    .btn-soft{
      border:0;
      border-radius: var(--radius-sm);
      height:44px;
      font-weight:500;
      box-shadow: 0 14px 26px rgba(0,0,0,.10);
      transition: transform .14s ease, box-shadow .14s ease;
      display:inline-flex; align-items:center; justify-content:center; gap:8px;
      padding: 0 14px;
      text-decoration:none;
    }
    .btn-soft:hover{ transform: translateY(-1px); box-shadow: 0 18px 34px rgba(0,0,0,.12); }
    .btn-primary-soft{ background: linear-gradient(90deg,var(--brand1),var(--brand2)); color:#fff; }
    .btn-outline-soft{ background: rgba(11,105,166,.10); color:#0b69a6; border: 1px solid rgba(11,105,166,.20); box-shadow:none; }
    .btn-outline-soft:hover{ box-shadow: 0 14px 26px rgba(0,0,0,.10); }
    .btn-danger-soft{ background: rgba(220,53,69,.14); color:#b02a37; border:1px solid rgba(220,53,69,.22); box-shadow:none; }
    .btn-success-soft{ background: rgba(34,197,94,.14); color:#166534; border:1px solid rgba(34,197,94,.22); box-shadow:none; }

    @media (max-width: 576px){
      .main{ padding: 14px; }
      .notif-offcanvas{ width:100%; }
    }
  </style>
</head>

<body>
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
        <a class="sb-link sb-active" href="<%= ctx %>/ReceptionistReservationsServlet"><i class="bi bi-journal-text"></i><span>Reservations</span></a>
        <a class="sb-link" href="<%= ctx %>/ReceptionistGuestsServlet""><i class="bi bi-people"></i><span>Customers</span></a>
        <a class="sb-link" href="<%= ctx %>/Views/receptionist/room.jsp"><i class="bi bi-door-open"></i><span>Rooms</span></a>
        <a class="sb-link sb-help" href="<%= ctx %>/Views/receptionist/help.jsp"><i class="bi bi-question-circle"></i><span>Help & Guide</span></a>
        <a class="sb-link" href="<%= ctx %>/LogoutServlet"><i class="bi bi-box-arrow-right"></i><span>Logout</span></a>
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
            <a class="sb-link sb-active" href="<%= ctx %>/ReceptionistReservationsServlet"><i class="bi bi-journal-text"></i><span>Reservations</span></a>
            <a class="sb-link" href="<%= ctx %>/ReceptionistGuestsServlet""><i class="bi bi-people"></i><span>Customers</span></a>
            <a class="sb-link" href="<%= ctx %>/Views/receptionist/room.jsp"><i class="bi bi-door-open"></i><span>Rooms</span></a>
            <a class="sb-link sb-help" href="<%= ctx %>/Views/receptionist/help.jsp"><i class="bi bi-question-circle"></i><span>Help & Guide</span></a>
            <a class="sb-link" href="<%= ctx %>/LogoutServlet"><i class="bi bi-box-arrow-right"></i><span>Logout</span></a>
          </nav>
        </aside>
      </div>
    </div>

    <!-- MAIN -->
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
              Reservations • <span class="welcome-name"><%= receptionistName %></span>
            </div>
            <div class="top-sub" id="dateTime">--</div>
          </div>
        </div>

        <div class="d-flex align-items-center gap-2 gap-md-3">
          <!-- Notifications -> opens offcanvas -->
          <button class="icon-btn" type="button" aria-label="Reservation Requests"
                  data-bs-toggle="offcanvas" data-bs-target="#notifPanel">
            <i class="bi bi-bell"></i>
            <span class="notify-dot" id="notifDot"></span>
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

      <!-- PAGE HEADER -->
      <div class="page-head">
        <div>
          <h2 class="page-title">Reservations</h2>
          <div class="page-sub">View and manage reservations.</div>
        </div>

        <div class="d-flex gap-2 flex-wrap">
          <button class="btn-soft btn-outline-soft" type="button" data-bs-toggle="offcanvas" data-bs-target="#notifPanel">
            <i class="bi bi-bell"></i> View Requests
          </button>
        </div>
      </div>

      <!-- KPI -->
      <section class="mt-3">
        <div class="row g-3">
          <div class="col-12 col-md-6 col-xl-3">
            <div class="kpi-card">
              <div class="kpi-icon bg-soft-amber"><i class="bi bi-hourglass-split"></i></div>
              <div>
                <div class="kpi-label">Pending</div>
                <div class="kpi-value" id="kpiPending">—</div>
              </div>
            </div>
          </div>

          <div class="col-12 col-md-6 col-xl-3">
            <div class="kpi-card">
              <div class="kpi-icon bg-soft-blue"><i class="bi bi-bookmark-check"></i></div>
              <div>
                <div class="kpi-label">Confirmed</div>
                <div class="kpi-value" id="kpiConfirmed">—</div>
              </div>
            </div>
          </div>

          <div class="col-12 col-md-6 col-xl-3">
            <div class="kpi-card">
              <div class="kpi-icon bg-soft-green"><i class="bi bi-door-open"></i></div>
              <div>
                <div class="kpi-label">Checked-In</div>
                <div class="kpi-value" id="kpiCheckedIn">—</div>
              </div>
            </div>
          </div>

          <div class="col-12 col-md-6 col-xl-3">
            <div class="kpi-card">
              <div class="kpi-icon bg-soft-purple"><i class="bi bi-calendar-event"></i></div>
              <div>
                <div class="kpi-label">Today Arrivals / Departures</div>
                <div class="kpi-value" id="kpiToday">—</div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- RESERVATION LIST TABLE  -->
      <section class="mt-3">
        <div class="cardx">
          <div class="cardx-head">
            <div class="cardx-title">Reservation List</div>
          </div>

          <div class="table-responsive">
            <table class="table table-borderless align-middle res-table mb-0">
              <thead>
                <tr>
                  <th>Reservation ID</th>
                  <th>Room No</th>
                  <th>Guest details</th>
                  <th>Check-in</th>
                  <th>Check-out</th>
                  <th>Guests</th>
                  <th>Status</th>
                  <th class="text-end">View</th>
                </tr>
              </thead>

              <tbody>
                <%
                  if (reservationList == null || reservationList.isEmpty()) {
                %>
                  <tr>
                    <td colspan="8" class="text-center muted py-4">No reservations found.</td>
                  </tr>
                <%
                  } else {
                    for (ReservationRequest r : reservationList) {

                      String st = (r.getReservationStatus() == null) ? "" : r.getReservationStatus().trim().toUpperCase();
                      if ("REJECTED".equals(st)) st = "CANCELLED";

                      String pillClass = "p-out";
                      String pillIcon = "bi-info-circle";

                      if ("CONFIRMED".equals(st))      { pillClass = "p-confirmed"; pillIcon = "bi-bookmark-check"; }
                      else if ("CHECKED_IN".equals(st)){ pillClass = "p-in";        pillIcon = "bi-door-open"; }
                      else if ("CHECKED_OUT".equals(st)){pillClass = "p-out";       pillIcon = "bi-box-arrow-right"; }
                      else if ("CANCELLED".equals(st)) { pillClass = "p-cancel";    pillIcon = "bi-x-circle"; }
                %>
                  <tr>
                    <td>RES-<%= r.getReservationId() %></td>
                    <td><%= r.getRoomNumber() %></td>

                    <td>
                      <div><%= r.getGuestName() %></div>
                      <div class="muted">
                        <%= (r.getGuestNicPassport() == null ? "" : r.getGuestNicPassport()) %>
                        <%= (r.getGuestPhone() == null ? "" : " • " + r.getGuestPhone()) %>
                        <%= (r.getGuestEmail() == null ? "" : " • " + r.getGuestEmail()) %>
                      </div>
                    </td>

                    <td><%= r.getCheckInDate() %></td>
                    <td><%= r.getCheckOutDate() %></td>
                    <td><%= r.getNumberOfGuests() %></td>

                    <td>
                      <span class="pill <%= pillClass %>"><i class="bi <%= pillIcon %>"></i> <%= st %></span>
                    </td>

                    <td class="text-end">
                      <a class="btn-soft btn-outline-soft" style="height:40px;"
                         href="<%= ctx %>/ReservationDetailsServlet?id=<%= r.getReservationId() %>">
                        <i class="bi bi-eye"></i>
                      </a>
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
      </section>

    </main>
  </div>

 
  <div class="offcanvas offcanvas-end notif-offcanvas" tabindex="-1" id="notifPanel" aria-labelledby="notifPanelLabel">
    <div class="offcanvas-header notif-head">
      <div class="d-flex align-items-center gap-2">
        <i class="bi bi-bell"></i>
        <h5 class="offcanvas-title mb-0" id="notifPanelLabel">Reservation Requests</h5>
      </div>

      <div class="d-flex align-items-center gap-2">
        <button class="btn-soft btn-outline-soft" id="markAllReadBtn" type="button" style="height:40px;">
          <i class="bi bi-check2"></i> Mark all read
        </button>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="offcanvas" aria-label="Close"></button>
      </div>
    </div>

    <div class="offcanvas-body">
      <div class="d-grid gap-3" id="notifList">
        <%
          if (pendingRequests == null || pendingRequests.isEmpty()) {
        %>
            <div class="text-center muted py-4">No new requests.</div>
        <%
          } else {
            for (ReservationRequest r : pendingRequests) {
        %>
          <div class="notif-item">
            <p class="notif-title">New booking request • RES-<%= r.getReservationId() %></p>

            <div class="notif-sub">
              <%= r.getGuestName() %> • Room <%= r.getRoomNumber() %> •
              <%= r.getCheckInDate() %> — <%= r.getCheckOutDate() %>
            </div>

            <div class="notif-meta">
              <span><i class="bi bi-telephone"></i> <%= r.getGuestPhone() %></span>
              <span><i class="bi bi-people"></i> <%= r.getNumberOfGuests() %> guests</span>
            </div>

            <div class="notif-actions">
              <a class="btn-soft btn-outline-soft" style="height:40px;"
                 href="<%= ctx %>/ReservationDetailsServlet?id=<%= r.getReservationId() %>">
                <i class="bi bi-eye"></i> View
              </a>

<!-- CONFIRM -->
<form method="post" action="<%= ctx %>/ReservationActionServlet" class="d-inline">
  <input type="hidden" name="id" value="<%= r.getReservationId() %>">
  <input type="hidden" name="action" value="confirm">
  <button class="btn-soft btn-success-soft" style="height:40px;" type="submit">
    <i class="bi bi-check2-circle"></i> Confirm
  </button>
</form>

<!-- CANCEL  -->
<form method="post" action="<%= ctx %>/ReservationActionServlet" class="d-inline">
  <input type="hidden" name="id" value="<%= r.getReservationId() %>">
  <input type="hidden" name="action" value="cancel">
  <button class="btn-soft btn-danger-soft" style="height:40px;" type="submit"
          onclick="return confirm('Cancel this booking request?');">
    <i class="bi bi-x-circle"></i> Reject
  </button>
</form>
            </div>
          </div>
        <%
            }
          }
        %>
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

    const markAllReadBtn = document.getElementById('markAllReadBtn');
    if (markAllReadBtn){
      markAllReadBtn.addEventListener('click', function(){
        const list = document.getElementById('notifList');
        if (list) list.style.opacity = "0.55";
        const dot = document.getElementById('notifDot');
        if (dot) dot.style.display = "none";
      });
    }
  </script>

  <script>
    (function(){
      const pendingCount   = <%= pendingCount %>;
      const confirmedCount = <%= confirmedCount %>;
      const checkedInCount = <%= checkedInCount %>;
      const todayCount     = <%= todayCount %>;

      const dot = document.getElementById('notifDot');
      if (dot) dot.style.display = pendingCount > 0 ? "block" : "none";

      const kpiPending = document.getElementById('kpiPending');
      if (kpiPending) kpiPending.textContent = pendingCount;

      const kpiConfirmed = document.getElementById('kpiConfirmed');
      if (kpiConfirmed) kpiConfirmed.textContent = confirmedCount;

      const kpiCheckedIn = document.getElementById('kpiCheckedIn');
      if (kpiCheckedIn) kpiCheckedIn.textContent = checkedInCount;

      const kpiToday = document.getElementById('kpiToday');
      if (kpiToday) kpiToday.textContent = todayCount;
    })();
  </script>
</body>
</html>