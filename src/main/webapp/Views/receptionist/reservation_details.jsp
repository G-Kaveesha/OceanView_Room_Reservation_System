<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.ReservationRequest" %>

<%!
  private String esc(String s){
    if(s == null) return "";
    return s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
            .replace("\"","&quot;").replace("'","&#x27;");
  }
%>

<%
  //only RECEPTIONIST
  String role = (String) session.getAttribute("userRole");
  if (role == null || !"RECEPTIONIST".equalsIgnoreCase(role)) {
    response.sendRedirect(request.getContextPath() + "/Views/login.jsp");
    return;
  }

  String ctx = request.getContextPath();

  ReservationRequest r = (ReservationRequest) request.getAttribute("reservation");
  if (r == null) {
    response.sendRedirect(ctx + "/ReceptionistReservationsServlet");
    return;
  }

  // Flash message 
  String flashMsg  = (String) session.getAttribute("flashMsg");
  String flashType = (String) session.getAttribute("flashType");
  if (flashMsg != null) {
    session.removeAttribute("flashMsg");
    session.removeAttribute("flashType");
  }

  String errorParam = request.getParameter("error");   
  String successParam = request.getParameter("success"); 

  
  String st = (r.getReservationStatus() == null) ? "" : r.getReservationStatus().trim().toUpperCase();

  boolean isPending   = "PENDING".equals(st);
  boolean isConfirmed = "CONFIRMED".equals(st);
  boolean isCheckedIn = "CHECKED_IN".equals(st);
  boolean isCheckedOut = "CHECKED_OUT".equals(st);
  boolean isCancelled = "CANCELLED".equals(st);

  java.time.LocalDate today   = java.time.LocalDate.now();
  java.time.LocalDate checkIn = (r.getCheckInDate() == null) ? null : r.getCheckInDate().toLocalDate();
  boolean isCheckInDay = (checkIn != null && checkIn.equals(today));

  boolean shouldRedirect =
      "checkin".equalsIgnoreCase(successParam) ||
      "confirm".equalsIgnoreCase(successParam) ||
      "cancel".equalsIgnoreCase(successParam);
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Reservation Details</title>

  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">

  <style>
    body{ background:#f4f7fb; font-family:system-ui,-apple-system,Segoe UI,Roboto,Arial,sans-serif; color:#141823; }
    .wrap{ max-width: 920px; margin: 26px auto; padding: 0 14px; }
    .cardx{ border:0; border-radius:18px; box-shadow:0 18px 45px rgba(0,0,0,.10); overflow:hidden; background:#fff; }
    .head{ padding:16px 18px; background:linear-gradient(90deg,#2f77c5,#6a5bd6); color:#fff; }
    .pill{ padding:7px 12px; border-radius:999px; background:rgba(255,255,255,.22); display:inline-flex; gap:8px; align-items:center; font-weight:600; }
    .kv{ font-size:12px; opacity:.72; font-weight:600; }
    .vv{ font-size:14px; font-weight:600; }
    .btn-soft{ border-radius:14px; height:44px; padding:0 14px; font-weight:600; }
    .btn-ok{ background:rgba(34,197,94,.14); color:#166534; border:1px solid rgba(34,197,94,.25); }
    .btn-no{ background:rgba(220,53,69,.14); color:#b02a37; border:1px solid rgba(220,53,69,.22); }
    .btn-back{ background:rgba(255,255,255,.18); color:#fff; border:1px solid rgba(255,255,255,.28); }
    .divider{ border-top:1px solid rgba(0,0,0,.08); margin:18px 0; }
    .meta{ background:rgba(0,0,0,.03); border:1px solid rgba(0,0,0,.05); border-radius:16px; padding:14px; }
    .tag{
      display:inline-flex; align-items:center; gap:8px;
      padding:6px 10px; border-radius:999px; font-size:12px; font-weight:700;
      border:1px solid rgba(0,0,0,.06);
      background:#fff;
    }
    .tag.ok{ background:rgba(34,197,94,.12); color:#166534; border-color:rgba(34,197,94,.22); }
    .tag.warn{ background:rgba(245,158,11,.14); color:#92400e; border-color:rgba(245,158,11,.25); }
    .tag.bad{ background:rgba(220,53,69,.14); color:#b02a37; border-color:rgba(220,53,69,.22); }
    .tag.info{ background:rgba(59,130,246,.14); color:#1e40af; border-color:rgba(59,130,246,.22); }
  </style>

  <% if (shouldRedirect) { %>
    <meta http-equiv="refresh" content="10;url=<%= ctx %>/ReceptionistReservationsServlet">
  <% } %>
</head>

<body>
<div class="wrap">

  <!-- Flash / Error -->
  <% if (flashMsg != null) { %>
    <div class="alert alert-<%= (flashType==null?"info":flashType) %>" role="alert" style="border-radius:14px;">
      <%= esc(flashMsg) %>
    </div>
  <% } else if ("1".equals(errorParam)) { %>
    <div class="alert alert-danger" role="alert" style="border-radius:14px;">
      Action failed. Please check server logs for the exact error.
    </div>
  <% } %>

  <div class="card cardx">
    <div class="head d-flex justify-content-between align-items-center flex-wrap gap-2">
      <div>
        <div class="h5 mb-1">Reservation RES-<%= r.getReservationId() %></div>

        <%
          String tagClass = "info";
          if (isPending) tagClass = "warn";
          else if (isConfirmed) tagClass = "info";
          else if (isCheckedIn) tagClass = "ok";
          else if (isCheckedOut) tagClass = "ok";
          else if (isCancelled) tagClass = "bad";
        %>

        <div class="pill">
          <i class="bi bi-info-circle"></i>
          <span class="tag <%= tagClass %>"><%= esc(st) %></span>
        </div>
      </div>

      <a class="btn btn-soft btn-back" href="<%= ctx %>/ReceptionistReservationsServlet">
        <i class="bi bi-arrow-left"></i> Back
      </a>
    </div>

    <div class="card-body p-4">

      <div class="meta mb-3">
        <div class="row g-3">
          <div class="col-md-4">
            <div class="kv">Room</div>
            <div class="vv"><%= esc(r.getRoomNumber()) %></div>
          </div>
          <div class="col-md-4">
            <div class="kv">Check-in</div>
            <div class="vv"><%= (r.getCheckInDate()==null?"":r.getCheckInDate().toString()) %></div>
          </div>
          <div class="col-md-4">
            <div class="kv">Check-out</div>
            <div class="vv"><%= (r.getCheckOutDate()==null?"":r.getCheckOutDate().toString()) %></div>
          </div>

          <div class="col-md-6">
            <div class="kv">Guest Name</div>
            <div class="vv"><%= esc(r.getGuestName()) %></div>
          </div>
          <div class="col-md-6">
            <div class="kv">NIC / Passport</div>
            <div class="vv"><%= esc(r.getGuestNicPassport()) %></div>
          </div>

          <div class="col-md-6">
            <div class="kv">Phone</div>
            <div class="vv"><%= esc(r.getGuestPhone()) %></div>
          </div>
          <div class="col-md-6">
            <div class="kv">Email</div>
            <div class="vv"><%= esc(r.getGuestEmail()) %></div>
          </div>

          <div class="col-md-4">
            <div class="kv">Guests</div>
            <div class="vv"><%= r.getNumberOfGuests() %></div>
          </div>
          <div class="col-md-8">
            <div class="kv">Created At</div>
            <div class="vv"><%= (r.getCreatedAt()==null?"":r.getCreatedAt().toString()) %></div>
          </div>
        </div>
      </div>

      <!-- ACTIONS -->
      <div class="d-flex flex-wrap gap-2">

        <% if (isPending) { %>
          <form method="post" action="<%= ctx %>/ReservationActionServlet" class="d-inline">
            <input type="hidden" name="id" value="<%= r.getReservationId() %>">
            <input type="hidden" name="action" value="confirm">
            <button class="btn btn-soft btn-ok" type="submit">
              <i class="bi bi-check2-circle"></i> Confirm
            </button>
          </form>

          <form method="post" action="<%= ctx %>/ReservationActionServlet" class="d-inline">
            <input type="hidden" name="id" value="<%= r.getReservationId() %>">
            <input type="hidden" name="action" value="cancel">
            <button class="btn btn-soft btn-no" type="submit"
                    onclick="return confirm('Cancel this booking request?');">
              <i class="bi bi-x-circle"></i> Cancel
            </button>
          </form>
        <% } %>

        <% if (isConfirmed) { %>
          <% if (isCheckInDay) { %>
            <form method="post" action="<%= ctx %>/ReservationActionServlet" class="d-inline">
              <input type="hidden" name="id" value="<%= r.getReservationId() %>">
              <input type="hidden" name="action" value="checkin">
              <button class="btn btn-soft btn-ok" type="submit"
                      onclick="return confirm('Check-in this guest now?');">
                <i class="bi bi-door-open"></i> Check-in
              </button>
            </form>
          <% } else { %>
            <div class="text-muted" style="font-weight:600; padding:10px 4px;">
              Check-in is available only on: <%= (r.getCheckInDate()==null?"":r.getCheckInDate().toString()) %>
            </div>
          <% } %>
        <% } %>

        <% if (isCheckedIn) { %>
          <a class="btn btn-soft btn-ok"
             href="<%= ctx %>/CheckoutServlet?rid=<%= r.getReservationId() %>">
            <i class="bi bi-box-arrow-right"></i> Check-out
          </a>
        <% } %>

        <% if (isCheckedOut) { %>
          <div class="text-muted" style="font-weight:600; padding:10px 4px;">
            Guest already checked out.
          </div>
        <% } %>

        <% if (isCancelled) { %>
          <div class="text-muted" style="font-weight:600; padding:10px 4px;">
            This reservation is cancelled.
          </div>
        <% } %>

      </div>

      <div class="divider"></div>
      <div class="text-muted" style="font-weight:600;">
      </div>

    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>