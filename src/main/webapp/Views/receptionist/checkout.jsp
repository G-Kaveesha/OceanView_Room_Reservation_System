<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="model.ReservationRequest" %>
<%@ page import="model.InvoiceItem" %>
<%@ page import="model.Invoice" %>
<%!
  private String esc(String s){
    if(s==null) return "";
    return s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
            .replace("\"","&quot;").replace("'","&#x27;");
  }
  private String money(BigDecimal v){
    if(v==null) return "0.00";
    return String.format("%,.2f", v.doubleValue());
  }
%>

<%
  String role = (String) session.getAttribute("userRole");
  if (role == null || !"RECEPTIONIST".equalsIgnoreCase(role)) {
    response.sendRedirect(request.getContextPath() + "/Views/login.jsp");
    return;
  }

  String ctx = request.getContextPath();

  ReservationRequest r = (ReservationRequest) request.getAttribute("reservation");
  Invoice inv = (Invoice) request.getAttribute("invoice");
  List<InvoiceItem> items = (List<InvoiceItem>) request.getAttribute("items");
  if (items == null) items = new ArrayList<>();

  if (r == null || inv == null) {
    response.sendRedirect(ctx + "/ReceptionistReservationsServlet");
    return;
  }

  String flashMsg = (String) session.getAttribute("flashMsg");
  String flashType = (String) session.getAttribute("flashType");
  if (flashMsg != null) { session.removeAttribute("flashMsg"); session.removeAttribute("flashType"); }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Checkout & Billing</title>

  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">

  <style>
    body{ 
    background:#f4f7fb; 
    font-family:system-ui,-apple-system,Segoe UI,Roboto,Arial,sans-serif; 
    color:#141823; 
    }
    .wrap{ 
    max-width:1180px; 
    margin:26px auto; 
    padding:0 14px; 
    }
    .hero{ 
    border:0; 
    border-radius:18px; 
    box-shadow:0 18px 45px rgba(0,0,0,.10); 
    overflow:hidden; 
    }
    .hero-h{ 
    padding:16px 18px; 
    background:linear-gradient(90deg,#2f77c5,#6a5bd6); 
    color:#fff; 
    }
    .pill{ 
    padding:6px 12px; 
    border-radius:999px; 
    background:rgba(255,255,255,.20); 
    display:inline-flex; gap:8px; 
    align-items:center; 
    }
    .panel{ 
    background:#fff; 
    border-radius:18px; 
    box-shadow:0 18px 45px rgba(0,0,0,.08); 
    border:1px solid rgba(0,0,0,.06); 
    }
    .panel-h{ 
    padding:14px 16px; 
    border-bottom:1px solid rgba(0,0,0,.06); 
    font-weight:700; 
    }
    .panel-b{ 
    padding:16px; 
    }
    .kv{ 
    font-size:12px; 
    opacity:.7; 
    font-weight:600; 
    }
    .vv{ 
    font-size:14px; 
    font-weight:600; 
    }
    .inp{ 
    border-radius:14px; 
    height:46px; 
    font-weight:600; 
    }
    .btn-soft{ 
    border-radius:14px; 
    height:44px; 
    padding:0 14px; 
    font-weight:600; 
    }
    .sumrow{ 
    display:flex; 
    justify-content:space-between; 
    gap:10px; 
    margin:8px 0; 
    font-weight:600; 
    }
    .sumrow span{ 
    opacity:.78; 
    font-weight:600; 
    }
    .sumtotal{ 
    font-size:18px; 
    }
    .table thead th{ 
    font-size:12px; 
    font-weight:700; 
    opacity:.85; 
    }
  </style>
</head>

<body>
<div class="wrap">

  <div class="card hero mb-3">
    <div class="hero-h d-flex justify-content-between align-items-center flex-wrap gap-2">
      <div>
        <div class="h5 mb-1">Check-out & Billing • Invoice INV-<%= inv.getInvoiceId() %></div>
        <div class="pill"><i class="bi bi-receipt"></i> RES-<%= r.getReservationId() %> • Room <%= esc(r.getRoomNumber()) %></div>
      </div>
      <div class="d-flex gap-2">
        <a class="btn btn-light btn-soft" href="<%= ctx %>/ReservationDetailsServlet?id=<%= r.getReservationId() %>">
          <i class="bi bi-arrow-left"></i> Back
        </a>
        <a class="btn btn-light btn-soft" href="<%= ctx %>/InvoicePrintServlet?invoiceId=<%= inv.getInvoiceId() %>">
          <i class="bi bi-printer"></i> Print View
        </a>
        <a class="btn btn-outline-light btn-soft" href="<%= ctx %>/InvoicePrintServlet?invoiceId=<%= inv.getInvoiceId() %>&download=pdf">
          <i class="bi bi-download"></i> Download PDF
        </a>
      </div>
    </div>
  </div>

  <% if (flashMsg != null) { %>
    <div class="alert alert-<%= (flashType==null?"info":flashType) %>" style="border-radius:14px;">
      <%= esc(flashMsg) %>
    </div>
  <% } %>

  <div class="row g-3">
    <!-- LEFT -->
    <div class="col-lg-7">
      <div class="panel mb-3">
        <div class="panel-h">Guest Details (Auto)</div>
        <div class="panel-b">
          <div class="row g-3">
            <div class="col-md-6"><div class="kv">Full Name</div><div class="vv"><%= esc(r.getGuestName()) %></div></div>
            <div class="col-md-6"><div class="kv">NIC / Passport</div><div class="vv"><%= esc(r.getGuestNicPassport()) %></div></div>
            <div class="col-md-6"><div class="kv">Phone</div><div class="vv"><%= esc(r.getGuestPhone()) %></div></div>
            <div class="col-md-6"><div class="kv">Email</div><div class="vv"><%= esc(r.getGuestEmail()) %></div></div>
          </div>
        </div>
      </div>

      <div class="panel">
        <div class="panel-h">Add Extra Charges</div>
        <div class="panel-b">
          <form method="post" action="<%= ctx %>/CheckoutServlet" class="row g-2">
            <input type="hidden" name="reservationId" value="<%= r.getReservationId() %>">

            <div class="col-md-6">
              <label class="kv mb-1">Charge Type</label>
              <select class="form-select inp" name="chargeName" required>
                <option value="">Select charge</option>
                <optgroup label="Food & Beverage">
                  <option>Restaurant bill</option>
                  <option>Room service</option>
                  <option>Mini bar</option>
                  <option>Soft drinks / water</option>
                </optgroup>
                <optgroup label="Services">
                  <option>Laundry / ironing</option>
                  <option>Airport pickup / drop</option>
                  <option>Taxi / transport</option>
                  <option>Extra bed / baby cot</option>
                  <option>Late checkout fee</option>
                  <option>Early check-in fee</option>
                </optgroup>
                <optgroup label="Facilities">
                  <option>Spa / massage</option>
                  <option>Activity / excursion fee</option>
                </optgroup>
                <optgroup label="Penalties">
                  <option>Lost key card fee</option>
                  <option>Damage fee</option>
                  <option>Smoking penalty</option>
                </optgroup>
                <option>Other</option>
              </select>
            </div>

            <div class="col-md-2">
              <label class="kv mb-1">Qty</label>
              <input class="form-control inp" type="number" name="qty" min="1" value="1" required>
            </div>

            <div class="col-md-4">
              <label class="kv mb-1">Unit Price (LKR)</label>
              <input class="form-control inp" type="number" step="0.01" name="unitPrice" min="0" required>
            </div>

            <div class="col-12">
              <label class="kv mb-1">Note (optional)</label>
              <input class="form-control inp" style="height:auto;" name="note" placeholder="Example: 2 coffees, towel fine, etc.">
            </div>

            <div class="col-12 d-grid">
              <button class="btn btn-primary btn-soft" type="submit">
                <i class="bi bi-plus-circle"></i> Add Charge
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>

    <!-- RIGHT -->
    <div class="col-lg-5">
      <div class="panel">
        <div class="panel-h">Bill Summary</div>
        <div class="panel-b">

          <div class="row g-2 mb-2">
            <div class="col-6"><div class="kv">Check-in</div><div class="vv"><%= r.getCheckInDate() %></div></div>
            <div class="col-6"><div class="kv">Check-out</div><div class="vv"><%= r.getCheckOutDate() %></div></div>
            <div class="col-6"><div class="kv">Nights</div><div class="vv"><%= inv.getNights() %></div></div>
            <div class="col-6"><div class="kv">Guests</div><div class="vv"><%= r.getNumberOfGuests() %></div></div>
          </div>

          <hr>

          <div class="table-responsive">
            <table class="table table-sm align-middle mb-2">
              <thead>
              <tr>
                <th>Item</th>
                <th class="text-end">Amount</th>
                <th class="text-end">Remove</th>
              </tr>
              </thead>
              <tbody>
              <tr>
                <td>
                  Room cost
                  <div class="kv"><%= money(inv.getRoomRate()) %> × <%= inv.getNights() %></div>
                </td>
                <td class="text-end">LKR <%= money(inv.getRoomCost()) %></td>
                <td class="text-end">—</td>
              </tr>

              <% if(items.isEmpty()){ %>
                <tr><td colspan="3" class="text-muted" style="font-weight:600;">No extra charges added.</td></tr>
              <% } else { for(InvoiceItem it: items){ %>
                <tr>
                  <td>
                    <%= esc(it.getItemName()) %>
                    <% if(it.getNote()!=null && !it.getNote().trim().isEmpty()){ %>
                      <div class="kv"><%= esc(it.getNote()) %></div>
                    <% } %>
                    <div class="kv"><%= it.getQty() %> × <%= money(it.getUnitPrice()) %></div>
                  </td>
                  <td class="text-end">LKR <%= money(it.getAmount()) %></td>
                  <td class="text-end">
                    <form method="post" action="<%= ctx %>/CheckoutServlet" class="d-inline">
                      <input type="hidden" name="reservationId" value="<%= r.getReservationId() %>">
                      <input type="hidden" name="removeItemId" value="<%= it.getItemId() %>">
                      <button class="btn btn-outline-danger btn-sm" type="submit" title="Remove">
                        <i class="bi bi-trash"></i>
                      </button>
                    </form>
                  </td>
                </tr>
              <% } } %>
              </tbody>
            </table>
          </div>

          <hr>

          <div class="sumrow"><span>Extras Total</span><div>LKR <%= money(inv.getExtrasTotal()) %></div></div>
          <div class="sumrow"><span>Service Charge</span><div>LKR <%= money(inv.getServiceCharge()) %></div></div>
          <div class="sumrow"><span>Tax</span><div>LKR <%= money(inv.getTaxAmount()) %></div></div>
          <div class="sumrow sumtotal"><span>Grand Total</span><div>LKR <%= money(inv.getTotalAmount()) %></div></div>

          <hr>

          <form method="post" action="<%= ctx %>/FinalizeCheckoutServlet" class="row g-2">
            <input type="hidden" name="reservationId" value="<%= r.getReservationId() %>">

            <div class="col-12">
              <label class="kv mb-1">Payment Method</label>
              <select class="form-select inp" name="paymentMethod" required>
                <option value="CASH">CASH</option>
                <option value="CARD">CARD</option>
              </select>
            </div>

            <div class="col-12">
              <label class="kv mb-1">Amount Paid (LKR)</label>
              <input class="form-control inp" type="number" step="0.01" min="0"
                     name="amountPaid" value="<%= inv.getTotalAmount() %>" required>
            </div>

            <div class="col-12 d-grid">
              <button class="btn btn-success btn-soft" type="submit"
                      onclick="return confirm('Confirm check-out?');">
                <i class="bi bi-check2-circle"></i> Confirm Check-out
              </button>
            </div>
          </form>

        </div>
      </div>
    </div>

  </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>