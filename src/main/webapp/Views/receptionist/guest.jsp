<%
    String role = (String) session.getAttribute("userRole");
    if (role == null || !"RECEPTIONIST".equalsIgnoreCase(role)) {
        response.sendRedirect(request.getContextPath() + "/Views/login.jsp");
        return;
    }
%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="model.GuestSummary" %>
<%
    String ctx = request.getContextPath();
    String receptionistName = "Receptionist";

    List<GuestSummary> guestList = (List<GuestSummary>) request.getAttribute("guestList");
    if (guestList == null) guestList = new ArrayList<>();

    String errorMsg = (String) request.getAttribute("errorMsg");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Customers - Receptionist</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
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
        .sb-top { text-align:center; padding:10px 18px 18px; }
        .sb-logo { width:54px; height:54px; object-fit:contain; margin-bottom:12px; }
        .sb-title { font-weight:900; font-size:20px; margin-bottom:4px; }
        .sb-subtitle { opacity:.95; font-weight:600; }
        .sb-divider { height:2px; background:rgba(255,255,255,.15); margin:10px 0 18px; }

        .sb-nav { display:flex; flex-direction:column; gap:14px; padding:0 18px; }
        .sb-link {
            display:flex; align-items:center; gap:14px;
            text-decoration:none; color:#fff;
            font-weight:800; padding:12px 14px;
            border-radius:14px;
            transition: background .15s ease, transform .15s ease, box-shadow .15s ease;
        }
        .sb-link i{ font-size:18px; opacity:.95; width:22px; display:inline-flex; justify-content:center; }
        .sb-link:hover{ background: rgba(255,255,255,0.12); transform: translateY(-1px); box-shadow: 0 14px 26px rgba(0,0,0,0.12); }
        .sb-active{ background: rgba(255,255,255,0.14); box-shadow: inset 0 0 0 1px rgba(255,255,255,0.10); }
        .sb-logout{ margin-top:10px; }

        /* Mobile offcanvas */
        .sidebar-offcanvas { width: 300px; background: transparent; border: 0; }
        .sidebar-mobile { width: 280px !important; min-height: 100%; position: relative; }

        /* Main */
        .main{
            flex: 1;
            padding: 18px;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            gap: 16px;
        }

        /* Topbar */
        .topbar {
            background: rgba(255,255,255,0.95);
            border-radius: 18px;
            padding: 14px 16px;
            display:flex;
            align-items:center;
            justify-content:space-between;
            box-shadow: 0 18px 45px rgba(0,0,0,0.10);
            backdrop-filter: blur(8px);
        }
        .top-title{ font-weight:900; font-size:18px; line-height:1.1; }
        .welcome-name{ color:#0b69a6; }
        .top-sub{ margin-top:4px; font-weight:800; opacity:.70; font-size:13px; }

        .burger{
            width:46px; height:46px;
            border-radius:14px; border:0;
            background: rgba(255,255,255,0.95);
            box-shadow: 0 16px 30px rgba(0,0,0,0.10);
            display:inline-flex; align-items:center; justify-content:center;
            font-size:26px; color:#0b69a6;
        }

        .user{
            display:flex; align-items:center; gap:10px;
            padding:6px 10px;
            border-radius:16px;
            background: rgba(255,255,255,0.65);
            box-shadow: inset 0 0 0 1px rgba(0,0,0,0.05);
        }
        .user-img{ width:44px; height:44px; border-radius:50%; object-fit:cover; border:2px solid rgba(255,255,255,0.8); }
        .user-name{ font-weight:900; }
        .user-role{ font-weight:800; opacity:.70; font-size:12px; }

        /* Content card */
        .card-shell{
            background: rgba(255,255,255,0.92);
            border-radius: 22px;
            box-shadow: 0 22px 60px rgba(0,0,0,0.14);
            overflow: hidden;
        }
        .card-head{
            padding: 16px 18px;
            display:flex;
            align-items:center;
            justify-content:space-between;
            gap:12px;
            border-bottom: 1px solid rgba(0,0,0,0.06);
        }
        .card-title{
            font-weight: 900;
            margin: 0;
            font-size: 18px;
            display:flex;
            align-items:center;
            gap:10px;
        }
        .searchbox{
            max-width: 440px;
            width: 100%;
        }
        .table thead th{
            font-size: 12px;
            font-weight: 900;
            opacity: .8;
            white-space: nowrap;
        }
        .badge-soft{
            border-radius: 999px;
            padding: 6px 10px;
            font-weight: 800;
            font-size: 12px;
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
            <a class="sb-link" href="<%= ctx %>/ReceptionistReservationsServlet"><i class="bi bi-journal-text"></i><span>Reservations</span></a>
            <a class="sb-link sb-active" href="<%= ctx %>/ReceptionistGuestsServlet"><i class="bi bi-people"></i><span>Customers</span></a>
            <a class="sb-link" href="<%= ctx %>/Views/receptionist/room.jsp"><i class="bi bi-door-open"></i><span>Rooms</span></a>
            <a class="sb-link" href="<%= ctx %>/Views/receptionist/help.jsp"><i class="bi bi-question-circle"></i><span>Help & Guide</span></a>
            <a class="sb-link sb-logout" href="<%= ctx %>/LogoutServlet"><i class="bi bi-box-arrow-right"></i><span>Logout</span></a>
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
                    <a class="sb-link sb-active" href="<%= ctx %>/ReceptionistGuestsServlet"><i class="bi bi-people"></i><span>Customers</span></a>
                    <a class="sb-link" href="<%= ctx %>/Views/receptionist/room.jsp"><i class="bi bi-door-open"></i><span>Rooms</span></a>
                    <a class="sb-link" href="<%= ctx %>/Views/receptionist/help.jsp"><i class="bi bi-question-circle"></i><span>Help & Guide</span></a>
                    <a class="sb-link sb-logout" href="<%= ctx %>/LogoutServlet"><i class="bi bi-box-arrow-right"></i><span>Logout</span></a>
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
                        Customers • <span class="welcome-name"><%= receptionistName %></span>
                    </div>
                    <div class="top-sub" id="dateTime">--</div>
                </div>
            </div>

            <div class="user">
                <img src="https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop"
                     class="user-img" alt="Receptionist Photo">
                <div class="d-none d-sm-block">
                    <div class="user-name"><%= receptionistName %></div>
                    <div class="user-role">Front Desk</div>
                </div>
            </div>
        </header>

        <!-- CONTENT -->
        <section class="card-shell">
            <div class="card-head">
                <h3 class="card-title"><i class="bi bi-people"></i>Guest List</h3>

                <div class="searchbox">
                    <div class="input-group">
                        <span class="input-group-text bg-white"><i class="bi bi-search"></i></span>
                        <input id="searchInput" type="text" class="form-control" placeholder="Search by name, email, phone, status...">
                    </div>
                </div>
            </div>

            <div class="p-3">
                <% if (errorMsg != null) { %>
                    <div class="alert alert-danger" style="border-radius:16px; font-weight:700;">
                        <%= errorMsg %>
                    </div>
                <% } %>

                <div class="table-responsive">
                    <table class="table align-middle mb-0" id="guestTable">
                        <thead class="table-light">
                        <tr>
                            <th>Guest Name</th>
                            <th>Phone</th>
                            <th>Email</th>
                            <th>NIC/Passport</th>
                            <th>Total Reservations</th>
                            <th>Last Reservation Date</th>
                            <th>Latest Status</th>
                            <th>Last Room</th>
                            
                        </tr>
                        </thead>
                        <tbody>
                        <% if (guestList.isEmpty()) { %>
                            <tr>
                                <td colspan="9" class="text-center py-4" style="font-weight:800; opacity:.75;">
                                    No guest records found (from reservations).
                                </td>
                            </tr>
                        <% } else { 
                            for (GuestSummary g : guestList) {
                                String st = (g.getLatestStatus()==null) ? "" : g.getLatestStatus().trim().toUpperCase();
                        %>
                            <tr class="guestRow"
                                data-search="<%= ((g.getGuestName()==null?"":g.getGuestName()) + " " +
                                                  (g.getGuestEmail()==null?"":g.getGuestEmail()) + " " +
                                                  (g.getGuestPhone()==null?"":g.getGuestPhone()) + " " + st).toLowerCase() %>">
                                <td style="font-weight:900;"><%= (g.getGuestName()==null?"-":g.getGuestName()) %></td>
                                <td><%= (g.getGuestPhone()==null?"-":g.getGuestPhone()) %></td>
                                <td><%= (g.getGuestEmail()==null?"-":g.getGuestEmail()) %></td>
                                <td><%= (g.getGuestNicPassport()==null?"-":g.getGuestNicPassport()) %></td>
                                <td><span class="badge text-bg-primary"><%= g.getTotalReservations() %></span></td>
                                <td><%= (g.getLastReservationDate()==null?"-":g.getLastReservationDate()) %></td>
                                <td>
                                    <span class="badge badge-soft text-bg-light">
                                        <%= st.isEmpty() ? "-" : st %>
                                    </span>
                                </td>
                                <td><%= (g.getLastRoomNumber()==null?"-":g.getLastRoomNumber()) %></td>
                                
                            </tr>
                        <% } } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </section>

    </main>
</div>

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

    (function(){
        const input = document.getElementById('searchInput');
        const rows = Array.from(document.querySelectorAll('.guestRow'));
        if (!input) return;

        input.addEventListener('input', () => {
            const q = (input.value || '').trim().toLowerCase();
            rows.forEach(r => {
                const s = (r.dataset.search || '');
                r.style.display = (!q || s.includes(q)) ? '' : 'none';
            });
        });
    })();
</script>
</body>
</html>