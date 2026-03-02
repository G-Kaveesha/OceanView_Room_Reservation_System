<%
    String role = (String) session.getAttribute("userRole");
    if (role == null || !"MANAGER".equalsIgnoreCase(role)) {
        response.sendRedirect(request.getContextPath() + "/Views/login.jsp");
        return;
    }
%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="model.report.*" %>

<%
  String ctx = request.getContextPath();

  String adminName = (String) session.getAttribute("adminName");
  if (adminName == null) adminName = "Manager";

  String adminRole = (String) session.getAttribute("adminRole");
  if (adminRole == null) adminRole = "Admin";

  String from = (String) request.getAttribute("from");
  String to   = (String) request.getAttribute("to");

  Integer totalReservations = (Integer) request.getAttribute("totalReservations");
  BigDecimal totalRevenue   = (BigDecimal) request.getAttribute("totalRevenue");
  BigDecimal totalPayments  = (BigDecimal) request.getAttribute("totalPayments");
  BigDecimal occupancyRate  = (BigDecimal) request.getAttribute("occupancyRate");
  BigDecimal adr            = (BigDecimal) request.getAttribute("adr");
  BigDecimal alos           = (BigDecimal) request.getAttribute("alos");
  Integer cancelledCount    = (Integer) request.getAttribute("cancelledCount");
  Integer pendingCount      = (Integer) request.getAttribute("pendingCount");

  List<ReservationReportRow> reservations = (List<ReservationReportRow>) request.getAttribute("reservations");
  List<InvoiceReportRow> invoices = (List<InvoiceReportRow>) request.getAttribute("invoices");
  List<PaymentReportRow> payments = (List<PaymentReportRow>) request.getAttribute("payments");
  List<RoomUtilizationRow> roomUtilization = (List<RoomUtilizationRow>) request.getAttribute("roomUtilization");

  List<ChartPoint> revenueByDay = (List<ChartPoint>) request.getAttribute("revenueByDay");
  List<StatusCount> statusBreakdown = (List<StatusCount>) request.getAttribute("statusBreakdown");
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Reports - Ocean View Resort</title>

  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
  <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&family=Space+Mono:wght@400;700&display=swap" rel="stylesheet">

  <!-- Chart.js -->
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

  <style>

    body {
      font-family: 'Outfit', sans-serif;
      background-image: url("<%= ctx %>/images/bg.png");
      min-height: 100vh;
    }

    .main-content { margin-left: 260px; padding: 2rem; }
    .top-header {
      background: #fff; padding: 1.5rem 2rem; border-radius: 1rem;
      margin-bottom: 1.25rem; box-shadow: 0 4px 12px rgba(0,0,0,0.08);
      display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:1rem;
    }

    .kpi-grid{
      display:grid;
      grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
      gap: 1rem;
      margin: 1rem 0 1.25rem;
    }
    .kpi{
      background:#fff; border-radius:1rem; padding: 1.25rem;
      box-shadow: 0 4px 12px rgba(0,0,0,0.08);
      position: relative; overflow:hidden;
    }
    .kpi .label{ opacity:.7; font-weight:600; font-size:.85rem; text-transform:uppercase; letter-spacing:.5px; }
    .kpi .value{ font-family:'Space Mono', monospace; font-size:1.65rem; font-weight:700; margin-top:.35rem; }

    .card-box{
      background:#fff; border-radius:1rem; padding: 1.25rem;
      box-shadow: 0 4px 12px rgba(0,0,0,0.08);
      margin-bottom: 1.25rem;
    }
    .card-title{
      font-weight:700; font-size:1.1rem;
      display:flex; align-items:center; gap:.5rem;
      margin-bottom: .9rem;
    }

    .table thead th{
      background: linear-gradient(135deg, #6366f1, #8b5cf6);
      color:#fff;
      border:0;
    }
    .badge-status{
      padding:.35rem .7rem; border-radius:999px; font-size:.75rem; font-weight:700;
      text-transform:uppercase;
      display:inline-block;
    }
    .s-PENDING{ background:#fef3c7; color:#92400e; }
    .s-CONFIRMED{ background:#d1fae5; color:#065f46; }
    .s-CHECKED_IN{ background:#dbeafe; color:#1e40af; }
    .s-CHECKED_OUT{ background:#e5e7eb; color:#111827; }
    .s-CANCELLED{ background:#fee2e2; color:#991b1b; }

    @media (max-width: 768px){
      .main-content { margin-left: 0; padding: 1rem; }
    }
  </style>
</head>

<body>

  <aside class="sidebar" id="sidebar" style="position:fixed;left:0;top:0;width:260px;height:100vh;background:linear-gradient(180deg,#312e81 0%,#1e1b4b 100%);padding:1.5rem 0;z-index:1000;box-shadow:0 10px 30px rgba(0,0,0,0.12);">
    <div class="sidebar-brand" style="padding:0 1.5rem 2rem;border-bottom:1px solid rgba(255,255,255,.1);margin-bottom:1.5rem;display:flex;align-items:center;gap:1rem;">
      <img src="<%= ctx %>/images/logo.png" style="width:50px;height:50px;object-fit:contain;border-radius:.5rem;padding:.5rem;" alt="Logo">
      <h3 style="color:#fff;font-weight:700;font-size:1.25rem;margin:0;">Ocean View Resort</h3>
    </div>
    <ul class="sidebar-menu" style="list-style:none;padding:0 1rem;margin:0;">
      <li style="margin-bottom:.5rem;"><a href="<%= ctx %>/Views/manager.jsp" style="display:flex;gap:1rem;align-items:center;padding:.875rem 1rem;color:rgba(255,255,255,.85);text-decoration:none;border-radius:.5rem;">
        <i class="bi bi-grid-1x2-fill"></i> Dashboard</a></li>

      <li style="margin-bottom:.5rem;"><a href="<%= ctx %>/RoomServlet" style="display:flex;gap:1rem;align-items:center;padding:.875rem 1rem;color:rgba(255,255,255,.85);text-decoration:none;border-radius:.5rem;">
        <i class="bi bi-door-open-fill"></i> Rooms</a></li>

      <li style="margin-bottom:.5rem;"><a href="<%= ctx %>/EmployeeServlet" style="display:flex;gap:1rem;align-items:center;padding:.875rem 1rem;color:rgba(255,255,255,.85);text-decoration:none;border-radius:.5rem;">
        <i class="bi bi-person-badge-fill"></i> Employee Management</a></li>

      <li style="margin-bottom:.5rem;"><a href="<%= ctx %>/ManagerReportsServlet" style="display:flex;gap:1rem;align-items:center;padding:.875rem 1rem;color:#fff;text-decoration:none;border-radius:.5rem;background:linear-gradient(90deg,#6366f1,#8b5cf6);box-shadow:0 4px 12px rgba(99,102,241,.3);">
        <i class="bi bi-bar-chart-fill"></i> Reports</a></li>

      <li style="margin-bottom:.5rem;"><a href="<%= ctx %>/LogoutServlet" style="display:flex;gap:1rem;align-items:center;padding:.875rem 1rem;color:rgba(255,255,255,.85);text-decoration:none;border-radius:.5rem;">
        <i class="bi bi-box-arrow-right"></i> Logout</a></li>
    </ul>
  </aside>

  <main class="main-content">
    <div class="top-header">
      <div>
        <h1 style="margin:0;font-weight:800;">Reports</h1>
        <div style="opacity:.75;font-weight:600;font-size:.9rem;margin-top:.35rem;">
          <i class="bi bi-calendar3"></i>
          <span>From <b><%= from %></b> to <b><%= to %></b></span>
        </div>
      </div>

      <div style="display:flex;align-items:center;gap:1rem;">
        <div style="display:flex;align-items:center;gap:.75rem;padding:.5rem 1rem;background:#e5e7eb;border-radius:2rem;">
          <img src="https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop" style="width:40px;height:40px;border-radius:50%;object-fit:cover;border:2px solid #fff;" alt="Admin">
          <div>
            <div style="font-weight:700;font-size:.9rem;line-height:1.2;"><%= adminName %></div>
            <div style="font-size:.75rem;opacity:.8;"><%= adminRole %></div>
          </div>
        </div>
      </div>
    </div>

    <!-- Date Range Filter -->
    <div class="card-box">
      <div class="card-title"><i class="bi bi-funnel"></i> Date Range Filter</div>
      <form class="row g-3 align-items-end" method="get" action="<%= ctx %>/ManagerReportsServlet">
        <div class="col-md-4">
          <label class="form-label">From</label>
          <input type="date" name="from" class="form-control" value="<%= from %>" required>
        </div>
        <div class="col-md-4">
          <label class="form-label">To</label>
          <input type="date" name="to" class="form-control" value="<%= to %>" required>
        </div>
        <div class="col-md-4 d-flex gap-2">
          <button class="btn btn-primary px-4" type="submit"><i class="bi bi-arrow-repeat"></i> Generate</button>
          <a class="btn btn-outline-secondary px-4" href="<%= ctx %>/ManagerReportsServlet"><i class="bi bi-x-circle"></i> Reset</a>
        </div>
      </form>
    </div>

    <!-- KPI Cards -->
    <div class="kpi-grid">
      <div class="kpi"><div class="label">Total Reservations</div><div class="value"><%= totalReservations %></div></div>
      <div class="kpi"><div class="label">Total Revenue</div><div class="value">LKR <%= totalRevenue %></div></div>
      <div class="kpi"><div class="label">Payments Received</div><div class="value">LKR <%= totalPayments %></div></div>
      <div class="kpi"><div class="label">Occupancy Rate</div><div class="value"><%= occupancyRate %>%</div></div>
      <div class="kpi"><div class="label">ADR</div><div class="value">LKR <%= adr %></div></div>
      <div class="kpi"><div class="label">ALOS</div><div class="value"><%= alos %> nights</div></div>
      <div class="kpi"><div class="label">Cancelled</div><div class="value"><%= cancelledCount %></div></div>
      <div class="kpi"><div class="label">Pending</div><div class="value"><%= pendingCount %></div></div>
    </div>

    <!-- Charts -->
    <div class="card-box">
      <div class="card-title"><i class="bi bi-graph-up"></i> Charts</div>
      <div class="row g-3">
        <div class="col-lg-8">
          <canvas id="revenueChart" height="120"></canvas>
        </div>
        <div class="col-lg-4">
          <canvas id="statusChart" height="120"></canvas>
        </div>
      </div>
      <div class="mt-2" style="opacity:.7;font-weight:600;font-size:.85rem;">
        If a chart is empty, it means no data in the selected range.
      </div>
    </div>

    <!-- Reservations Report -->
    <div class="card-box">
      <div class="card-title"><i class="bi bi-journal-text"></i> Reservations Report</div>
      <div class="table-responsive">
        <table class="table table-hover align-middle">
          <thead>
          <tr>
            <th>Reservation ID</th>
            <th>Guest</th>
            <th>Room No</th>
            <th>Check-in</th>
            <th>Check-out</th>
            <th>Guests</th>
            <th>Status</th>
            <th>Created</th>
          </tr>
          </thead>
          <tbody>
          <%
            if (reservations == null || reservations.isEmpty()) {
          %>
            <tr><td colspan="8" class="text-center py-4 text-secondary">No reservations in this period.</td></tr>
          <%
            } else {
              for (ReservationReportRow r : reservations) {
          %>
            <tr>
              <td>RES-<%= r.getReservationId() %></td>
              <td><%= r.getGuestName() %></td>
              <td><%= r.getRoomNumber() %></td>
              <td><%= r.getCheckIn() %></td>
              <td><%= r.getCheckOut() %></td>
              <td><%= r.getGuests() %></td>
              <td><span class="badge-status s-<%= r.getStatus() %>"><%= r.getStatus() %></span></td>
              <td><%= r.getCreatedAt() %></td>
            </tr>
          <%
              }
            }
          %>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Invoices Report -->
    <div class="card-box">
      <div class="card-title"><i class="bi bi-receipt"></i> Revenue / Billing Report</div>
      <div class="table-responsive">
        <table class="table table-hover align-middle">
          <thead>
          <tr>
            <th>Invoice ID</th>
            <th>Reservation ID</th>
            <th>Guest Email</th>
            <th>Total Amount</th>
            <th>Status</th>
            <th>Issued Date</th>
          </tr>
          </thead>
          <tbody>
          <%
            if (invoices == null || invoices.isEmpty()) {
          %>
            <tr><td colspan="6" class="text-center py-4 text-secondary">No invoices in this period.</td></tr>
          <%
            } else {
              for (InvoiceReportRow i : invoices) {
          %>
            <tr>
              <td>INV-<%= i.getInvoiceId() %></td>
              <td>RES-<%= i.getReservationId() %></td>
              <td><%= i.getGuestEmail() %></td>
              <td>LKR <%= i.getTotalAmount() %></td>
              <td><span class="badge-status"><%= i.getInvoiceStatus() %></span></td>
              <td><%= i.getIssuedAt() %></td>
            </tr>
          <%
              }
            }
          %>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Payments Report -->
    <div class="card-box">
      <div class="card-title"><i class="bi bi-credit-card"></i> Payments Report</div>
      <div class="table-responsive">
        <table class="table table-hover align-middle">
          <thead>
          <tr>
            <th>Payment ID</th>
            <th>Invoice ID</th>
            <th>Method</th>
            <th>Amount Paid</th>
            <th>Status</th>
            <th>Date</th>
            <th>Received By</th>
          </tr>
          </thead>
          <tbody>
          <%
            if (payments == null || payments.isEmpty()) {
          %>
            <tr><td colspan="7" class="text-center py-4 text-secondary">No payments in this period.</td></tr>
          <%
            } else {
              for (PaymentReportRow p : payments) {
          %>
            <tr>
              <td>PAY-<%= p.getPaymentId() %></td>
              <td>INV-<%= p.getInvoiceId() %></td>
              <td><%= p.getMethod() %></td>
              <td>LKR <%= p.getAmountPaid() %></td>
              <td><span class="badge-status"><%= p.getPaymentStatus() %></span></td>
              <td><%= p.getPaymentDate() %></td>
              <td><%= p.getReceivedBy() %></td>
            </tr>
          <%
              }
            }
          %>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Room Utilization -->
    <div class="card-box">
      <div class="card-title"><i class="bi bi-door-open"></i> Room Utilization / Occupancy</div>
      <div class="table-responsive">
        <table class="table table-hover align-middle">
          <thead>
          <tr>
            <th>Room No</th>
            <th>Type</th>
            <th>Nights Booked</th>
            <th>Times Reserved</th>
            <th>Current Status</th>
          </tr>
          </thead>
          <tbody>
          <%
            if (roomUtilization == null || roomUtilization.isEmpty()) {
          %>
            <tr><td colspan="5" class="text-center py-4 text-secondary">No room utilization data in this period.</td></tr>
          <%
            } else {
              for (RoomUtilizationRow ru : roomUtilization) {
          %>
            <tr>
              <td><%= ru.getRoomNumber() %></td>
              <td><%= ru.getTypeName() %></td>
              <td><%= ru.getNightsBooked() %></td>
              <td><%= ru.getTimesReserved() %></td>
              <td><span class="badge-status"><%= ru.getCurrentStatus() %></span></td>
            </tr>
          <%
              }
            }
          %>
          </tbody>
        </table>
      </div>
    </div>

  </main>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

  <script>
    const revenueLabels = [
      <% if (revenueByDay != null) { for (int x=0; x<revenueByDay.size(); x++){ %>
        "<%= revenueByDay.get(x).getLabel() %>"<%= (x < revenueByDay.size()-1) ? "," : "" %>
      <% }} %>
    ];
    const revenueValues = [
      <% if (revenueByDay != null) { for (int x=0; x<revenueByDay.size(); x++){ %>
        <%= revenueByDay.get(x).getValue() %><%= (x < revenueByDay.size()-1) ? "," : "" %>
      <% }} %>
    ];

    const statusLabels = [
      <% if (statusBreakdown != null) { for (int x=0; x<statusBreakdown.size(); x++){ %>
        "<%= statusBreakdown.get(x).getStatus() %>"<%= (x < statusBreakdown.size()-1) ? "," : "" %>
      <% }} %>
    ];
    const statusValues = [
      <% if (statusBreakdown != null) { for (int x=0; x<statusBreakdown.size(); x++){ %>
        <%= statusBreakdown.get(x).getCount() %><%= (x < statusBreakdown.size()-1) ? "," : "" %>
      <% }} %>
    ];

    const revenueCtx = document.getElementById('revenueChart');
    new Chart(revenueCtx, {
      type: 'line',
      data: { labels: revenueLabels, datasets: [{ label: 'Revenue', data: revenueValues, tension: 0.35 }] },
      options: { responsive: true, plugins: { legend: { display: true } } }
    });

    const statusCtx = document.getElementById('statusChart');
    new Chart(statusCtx, {
      type: 'bar',
      data: { labels: statusLabels, datasets: [{ label: 'Reservations', data: statusValues }] },
      options: { responsive: true, plugins: { legend: { display: true } } }
    });
  </script>

</body>
</html>