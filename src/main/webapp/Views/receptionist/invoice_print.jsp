<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<%@ page import="model.InvoiceBundle"%>
<%@ page import="model.InvoiceItem"%>
<%!
  private String esc(String s){
    if(s==null) return "";
    return s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
            .replace("\"","&quot;").replace("'","&#x27;");
  }
  private String money(java.math.BigDecimal v){
    if(v==null) return "0.00";
    return String.format("%,.2f", v.doubleValue());
  }
%>

<%
  String ctx = request.getContextPath();
  InvoiceBundle b = (InvoiceBundle) request.getAttribute("bundle");
  if(b == null){
    response.sendRedirect(ctx + "/ReceptionistReservationsServlet");
    return;
  }
%>

<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Invoice INV-<%= b.invoice.getInvoiceId() %></title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <style>
    body{ 
    background:#fff; 
    font-family:system-ui,-apple-system,Segoe UI,Roboto,Arial,sans-serif; 
    color:#111; 
    }
    .paper{ 
    max-width:820px; 
    margin:22px auto; 
    padding:18px; 
    border:1px solid #e6e6e6; 
    border-radius:14px; }
    .muted{ color:#666; font-size:12px; font-weight:600; }
    .hline{ border-top:1px solid #e6e6e6; margin:12px 0; }
    @media print{ .no-print{ display:none !important; } .paper{ border:0; } }
  </style>
</head>
<body>
<div class="paper">
  <div class="d-flex justify-content-between align-items-start">
    <div>
      <h4 class="mb-1">Ocean View Resort</h4>
      <div class="muted">Official Invoice / Bill</div>
    </div>
    <div class="text-end">
      <div><b>INV-<%= b.invoice.getInvoiceId() %></b></div>
      <div class="muted">Status: <%= esc(b.invoice.getInvoiceStatus()) %></div>
    </div>
  </div>

  <div class="hline"></div>

  <div class="row g-2">
    <div class="col-md-6">
      <div class="muted">Guest</div>
      <div><b><%= esc(b.reservation.getGuestName()) %></b></div>
      <div class="muted">NIC/Passport: <%= esc(b.reservation.getGuestNicPassport()) %></div>
      <div class="muted">Phone: <%= esc(b.reservation.getGuestPhone()) %></div>
      <div class="muted">Email: <%= esc(b.reservation.getGuestEmail()) %></div>
    </div>
    <div class="col-md-6 text-md-end">
      <div class="muted">Reservation</div>
      <div><b>RES-<%= b.reservation.getReservationId() %></b></div>
      <div class="muted">Room: <%= esc(b.reservation.getRoomNumber()) %></div>
      <div class="muted">Check-in: <%= b.reservation.getCheckInDate() %></div>
      <div class="muted">Check-out: <%= b.reservation.getCheckOutDate() %></div>
      <div class="muted">Nights: <%= b.invoice.getNights() %></div>
    </div>
  </div>

  <div class="hline"></div>

  <table class="table table-sm">
    <thead>
    <tr>
      <th>Description</th>
      <th class="text-end">Amount (LKR)</th>
    </tr>
    </thead>
    <tbody>
    <tr>
      <td>Room cost (<%= money(b.invoice.getRoomRate()) %> × <%= b.invoice.getNights() %>)</td>
      <td class="text-end"><%= money(b.invoice.getRoomCost()) %></td>
    </tr>

    <% for(InvoiceItem it : b.items){ %>
      <tr>
        <td>
          <%= esc(it.getItemName()) %>
          <% if(it.getNote()!=null && !it.getNote().trim().isEmpty()){ %>
            <div class="muted"><%= esc(it.getNote()) %></div>
          <% } %>
        </td>
        <td class="text-end"><%= money(it.getAmount()) %></td>
      </tr>
    <% } %>
    </tbody>
  </table>

  <div class="hline"></div>

  <div class="d-flex justify-content-end">
    <div style="min-width:320px;">
      <div class="d-flex justify-content-between"><span class="muted">Extras</span><b><%= money(b.invoice.getExtrasTotal()) %></b></div>
      <div class="d-flex justify-content-between"><span class="muted">Service charge</span><b><%= money(b.invoice.getServiceCharge()) %></b></div>
      <div class="d-flex justify-content-between"><span class="muted">Tax</span><b><%= money(b.invoice.getTaxAmount()) %></b></div>
      <div class="d-flex justify-content-between fs-5 mt-2"><span><b>Total</b></span><span><b><%= money(b.invoice.getTotalAmount()) %></b></span></div>
    </div>
  </div>

  <div class="hline"></div>

  <div class="no-print d-flex gap-2">
    <button class="btn btn-primary" onclick="window.print()"><i class="bi bi-printer"></i> Print</button>
    <a class="btn btn-outline-secondary" href="<%= ctx %>/CheckoutServlet?rid=<%= b.reservation.getReservationId() %>">Back</a>
  </div>
</div>
</body>
</html>