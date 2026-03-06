<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="true" %>
<%
  String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Help & User Guide - Ocean View Resort</title>

  <!-- Bootstrap 5 -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <!-- Bootstrap Icons -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
</head>

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

  .sidebar{
    width: 300px;
    min-height: 100vh;
    background: linear-gradient(180deg,#0188f7 0%,#5601ff 60%,#4626d6 100%);
    color:#fff;
    padding: 22px 0;
    position: sticky;
    top:0;
    display:flex;
    flex-direction:column;
    box-shadow: 0 18px 55px rgba(0,0,0,0.18);
  }
  .sidebar-mobile{
    width: 300px !important;
    min-height:100%;
    position:relative;
  }
  .sidebar-offcanvas{ width: 320px; border:0; background: transparent; }

  .sb-top{
    text-align:center;
    padding: 10px 18px 18px;
  }
  .sb-logo{ width:56px; height:56px; object-fit:contain; margin-bottom:12px; }
  .sb-title{ font-weight:900; font-size:22px; }
  .sb-subtitle{ font-weight:700; opacity:0.9; }

  .sb-divider{ height:2px; background: rgba(255,255,255,0.15); margin: 12px 0 18px; }

  .sb-nav{ display:flex; flex-direction:column; gap:10px; padding: 0 16px; }
  .sb-link{
    display:flex;
    align-items:center;
    gap:12px;
    padding: 14px 14px;
    border-radius: 16px;
    text-decoration:none;
    color:#fff;
    font-weight:800;
    transition: transform .12s ease, background .12s ease, box-shadow .12s ease;
  }
  .sb-link i{ font-size:18px; }
  .sb-link span{ white-space: nowrap; }

  .sb-link:hover{
    background: rgba(255,255,255,0.14);
    transform: translateY(-1px);
    box-shadow: 0 14px 26px rgba(0,0,0,0.12);
  }
  .sb-active{ background: rgba(255,255,255,0.18); }
  .sb-help{ background: rgba(255,255,255,0.16); }
  .sb-logout{ margin-top: 8px; background: rgba(0,0,0,0.12); }
  .sb-logout:hover{ background: rgba(0,0,0,0.18); }

  .main{ flex:1; padding: 18px 18px 40px 18px; }

  .topbar{
    background:#fff;
    border-radius: 18px;
    padding: 14px 16px;
    display:flex;
    justify-content:space-between;
    align-items:center;
    box-shadow: 0 16px 30px rgba(0,0,0,0.08);
  }

  .top-title{
    font-weight:900;
    font-size:20px;
    color:#141823;
    display:flex;
    align-items:center;
    gap:10px;
  }
  .top-sub{
    font-weight:800;
    opacity:0.72;
    font-size:13px;
    margin-top: 2px;
  }

  .tiny-chip{
    display:inline-flex;
    align-items:center;
    gap:8px;
    padding: 6px 10px;
    border-radius: 999px;
    font-weight: 900;
    font-size: 12px;
    background: rgba(59,130,246,0.12);
    color:#1e40af;
    border: 1px solid rgba(59,130,246,0.18);
  }

  .burger{
    width: 46px; height:46px;
    border-radius: 14px;
    background: #eef3f9;
    border:0;
    box-shadow: 0 12px 24px rgba(0,0,0,0.10);
    font-size: 26px;
    color:#0b69a6;
  }

  .badge-pill{
    display:flex;
    align-items:center;
    gap:10px;
    background:#eef3f9;
    padding: 10px 12px;
    border-radius: 16px;
    font-weight:900;
    box-shadow: 0 12px 24px rgba(0,0,0,0.10);
  }

  .user {
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 6px 10px;
    border-radius: 16px;
    background: rgba(255,255,255,0.65);
    box-shadow: inset 0 0 0 1px rgba(0,0,0,0.05);
    transition: transform .15s ease, box-shadow .15s ease;
  }
  .user:hover {
    transform: translateY(-1px);
    box-shadow: 0 18px 40px rgba(0,0,0,0.10);
  }

  .user-img {
    width: 44px;
    height: 44px;
    border-radius: 50%;
    object-fit: cover;
    box-shadow: 0 12px 26px rgba(0,0,0,0.15);
    border: 2px solid rgba(255,255,255,0.8);
  }
  .user-meta { line-height: 1.1; }
  .user-name { font-weight: 900; }
  .user-role { font-weight: 800; opacity: 0.70; font-size: 12px; }

  /*  CARDS  */
  .cardx{
    background:#fff;
    border-radius: 18px;
    box-shadow: 0 18px 45px rgba(0,0,0,0.10);
    overflow:hidden;
  }
  .cardx-head{
    padding: 14px 16px;
    border-bottom: 1px solid rgba(0,0,0,0.06);
    display:flex;
    align-items:center;
    justify-content:space-between;
    gap:12px;
    flex-wrap: wrap;
  }
  .cardx-title{
    font-weight:900;
    color:#141823;
    display:flex;
    align-items:center;
    gap:10px;
  }
  .cardx-body{ padding: 14px 16px; }

  .count-pill{
    padding: 8px 12px;
    border-radius: 999px;
    font-weight: 900;
    font-size: 12px;
    background: linear-gradient(90deg,#2f77c5,#6a5bd6);
    color:#fff;
  }

  .search-wrap{ position: relative; }
  .search-wrap i{
    position:absolute;
    left: 12px;
    top: 50%;
    transform: translateY(-50%);
    opacity: 0.6;
  }
  .search-input{
    width:100%;
    height: 46px;
    border-radius: 14px;
    border: 2px solid rgba(0,0,0,0.10);
    padding-left: 40px;
    padding-right: 12px;
    font-weight: 800;
    box-shadow: 0 10px 18px rgba(0,0,0,0.06);
  }
  .field-label{ font-weight:900; }
  .field-input{
    border-radius: 14px;
    border: 2px solid rgba(0,0,0,0.10);
    box-shadow: 0 10px 18px rgba(0,0,0,0.06);
  }

  .hint{
    font-weight: 800;
    opacity: 0.65;
    font-size: 12px;
  }
  .no-results{
    display:none;
    margin-top: 12px;
    background: rgba(245,158,11,0.18);
    border: 1px solid rgba(245,158,11,0.25);
    color:#92400e;
    border-radius: 14px;
    padding: 12px 14px;
    font-weight: 800;
  }

  /*  ACCORDION  */
  .help-acc .accordion-item{
    border: 0;
    border-radius: 16px;
    overflow:hidden;
    box-shadow: 0 14px 26px rgba(0,0,0,0.08);
    margin-bottom: 12px;
  }

  .help-acc .accordion-button{
    font-weight: 900;
    color:#141823;
    background: #fff;
    box-shadow:none;
    padding: 16px 16px;
  }
  .help-acc .accordion-button:not(.collapsed){
    background: linear-gradient(90deg, rgba(47,119,197,0.12), rgba(106,91,214,0.12));
    color:#0b69a6;
  }
  .help-acc .accordion-body{
    background: rgba(11,105,166,0.04);
    font-weight: 800;
    color: rgba(0,0,0,0.78);
    border-top: 1px solid rgba(0,0,0,0.06);
  }

  /* SUPPORT CARD  */
  .support-card{
    background: linear-gradient(135deg, rgba(59,130,246,0.12), rgba(168,85,247,0.12));
  }
  .support-title{
    font-weight: 900;
    font-size: 18px;
    color:#141823;
    display:flex;
    align-items:center;
    gap:10px;
  }
  .support-sub{
    font-weight: 800;
    opacity: 0.75;
    margin-top: 4px;
  }

  .support-chip{
    background:#fff;
    border-radius: 16px;
    padding: 12px 14px;
    display:flex;
    align-items:center;
    gap:12px;
    box-shadow: 0 14px 26px rgba(0,0,0,0.10);
  }
  .support-chip i{
    width: 44px; height:44px;
    border-radius: 16px;
    display:flex;
    align-items:center;
    justify-content:center;
    font-size: 18px;
    background: rgba(11,105,166,0.12);
    color:#0b69a6;
  }
  .chip-title{ font-weight: 900; }
  .chip-sub{ font-weight: 800; opacity: 0.75; font-size: 12px; }

  @media (max-width: 576px){
    .main{ padding: 14px; }
    .topbar{ flex-wrap: wrap; gap: 10px; }
  }
</style>

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
        <a class="sb-link" href="<%= ctx %>/ReceptionistGuestsServlet"><i class="bi bi-people"></i><span>Customers</span></a>
        <a class="sb-link" href="<%= ctx %>/Views/receptionist/room.jsp"><i class="bi bi-door-open"></i><span>Rooms</span></a>
        <a class="sb-link sb-active sb-help" href="<%= ctx %>/Views/receptionist/help.jsp"><i class="bi bi-question-circle"></i><span>Help & Guide</span></a>
        <a class="sb-link sb-logout" href="<%= ctx %>/login.jsp"><i class="bi bi-box-arrow-right"></i><span>Logout</span></a>
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
            <a class="sb-link" href="<%= ctx %>/Views/receptionist.js"><i class="bi bi-grid-1x2-fill"></i><span>Dashboard</span></a>
            <a class="sb-link" href="<%= ctx %>/ReceptionistReservationsServlet"><i class="bi bi-journal-text"></i><span>Reservations</span></a>
            <a class="sb-link" href="<%= ctx %>/ReceptionistGuestsServlet"><i class="bi bi-people"></i><span>Customers</span></a>
            <a class="sb-link" href="<%= ctx %>/Views/receptionist/room.jsp"><i class="bi bi-door-open"></i><span>Rooms</span></a>
            <a class="sb-link sb-active sb-help" href="<%= ctx %>/Views/receptionist/help.jsp"><i class="bi bi-question-circle"></i><span>Help & Guide</span></a>
            <a class="sb-link sb-logout" href="<%= ctx %>/login.jsp"><i class="bi bi-box-arrow-right"></i><span>Logout</span></a>
          </nav>
        </aside>
      </div>
    </div>

 
    <main class="main">

      <header class="topbar">
        <div class="d-flex align-items-center gap-3">
          <button class="btn burger d-lg-none" type="button"
                  data-bs-toggle="offcanvas" data-bs-target="#mobileSidebar"
                  aria-controls="mobileSidebar" aria-label="Open menu">
            <i class="bi bi-list"></i>
          </button>

          <div>
            <div class="top-title">
              Help & User Guide
              <span class="tiny-chip"><i class="bi bi-life-preserver"></i> Support</span>
            </div>
            <div class="top-sub">Guidelines for using Ocean View Resort Receptionist System</div>
          </div>
        </div>

        <div class="d-flex align-items-center gap-2 gap-md-3">
          <div class="badge-pill">
            <i class="bi bi-clock"></i>
            <span id="currentDateTime">-</span>
          </div>
          <div class="user">
            <img src="https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop"
                 class="user-img" alt="Receptionist Photo">
            <div class="user-meta d-none d-sm-block">
              <div class="user-name">Receptionist</div>
              <div class="user-role">Front Desk</div>
            </div>
          </div>
        </div>
      </header>

      <!-- FILTERS -->
      <section class="mt-3">
        <div class="cardx">
          <div class="cardx-head">
            <div class="cardx-title"><i class="bi bi-funnel"></i> Find Help Topics</div>
            <span class="count-pill" id="visibleCount">5 Topics</span>
          </div>

          <div class="cardx-body">
            <div class="row g-3 align-items-end">
              <div class="col-12 col-lg-8">
                <label class="form-label field-label">Search</label>
                <div class="search-wrap">
                  <i class="bi bi-search"></i>
                  <input id="helpSearch" class="search-input" type="text"
                         placeholder="Type keywords (reservation, check-in, checkout, bill, reports)..." />
                </div>
                <div class="hint mt-2">
                  Tip: Try “reservation”, “check-out”, “bill”, “reports”.
                </div>
                <div class="no-results" id="noResults">
                  <strong>No matches found.</strong> Try another keyword or change the category.
                </div>
              </div>

              <div class="col-12 col-lg-4">
                <label class="form-label field-label">Category</label>
                <select id="helpCategory" class="form-select field-input">
                  <option value="all" selected>All Topics</option>
                  <option value="reservations">Reservations</option>
                  <option value="checkin">Check-In</option>
                  <option value="checkout">Check-Out & Billing</option>
                  <option value="rooms">Room Availability</option>
                  <option value="reports">Reports</option>
                </select>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- HELP ACCORDION -->
      <section class="mt-3">
        <div class="cardx">
          <div class="cardx-head">
            <div class="cardx-title"><i class="bi bi-book"></i> Help Topics</div>
          </div>

          <div class="cardx-body">
            <div class="accordion help-acc" id="helpAccordion">

              <div class="accordion help-acc" id="helpAccordion">

  <!-- VIEW RESERVATIONS -->
  <div class="accordion-item help-item" data-category="reservations"
       data-keywords="reservation view confirm cancel guest request">
    <h2 class="accordion-header">
      <button class="accordion-button" type="button"
              data-bs-toggle="collapse" data-bs-target="#c1">
        <i class="bi bi-journal-text me-2"></i> How to view reservation requests?
      </button>
    </h2>

    <div id="c1" class="accordion-collapse collapse show"
         data-bs-parent="#helpAccordion">
      <div class="accordion-body">
        <ol class="mb-0">
          <li>Open <b>Reservations</b> from the sidebar.</li>
          <li>The system displays <b>Pending reservation requests</b>.</li>
          <li>Check guest details, dates, and number of guests.</li>
          <li>Click <b>View</b> to see the reservation information.</li>
          <li>You can then confirm or cancel the request.</li>
        </ol>
      </div>
    </div>
  </div>

  <!-- CONFIRM RESERVATION -->
  <div class="accordion-item help-item" data-category="reservations"
       data-keywords="confirm reservation approve booking receptionist">
    <h2 class="accordion-header">
      <button class="accordion-button collapsed" type="button"
              data-bs-toggle="collapse" data-bs-target="#c2">
        <i class="bi bi-check-circle me-2"></i> How to confirm a reservation?
      </button>
    </h2>

    <div id="c2" class="accordion-collapse collapse"
         data-bs-parent="#helpAccordion">
      <div class="accordion-body">
        <ol class="mb-0">
          <li>Go to the <b>Reservations</b> page.</li>
          <li>Select a reservation from the <b>Pending Requests</b> list.</li>
          <li>Verify guest information and dates.</li>
          <li>Click <b>Confirm Reservation</b>.</li>
          <li>The reservation status changes to <b>CONFIRMED</b>.</li>
        </ol>
      </div>
    </div>
  </div>

  <!-- WALK IN CHECK IN -->
  <div class="accordion-item help-item" data-category="checkin"
       data-keywords="walk in check in guest without reservation">
    <h2 class="accordion-header">
      <button class="accordion-button collapsed" type="button"
              data-bs-toggle="collapse" data-bs-target="#c3">
        <i class="bi bi-person-plus me-2"></i> How to check-in a walk-in guest?
      </button>
    </h2>

    <div id="c3" class="accordion-collapse collapse"
         data-bs-parent="#helpAccordion">
      <div class="accordion-body">
        <ol class="mb-0">
          <li>Open the <b>Reservations</b> page.</li>
          <li>Select the option <b>Walk-In Check-In</b>.</li>
          <li>Enter guest details (name, phone, email, NIC/passport).</li>
          <li>Select an <b>available room</b>.</li>
          <li>Enter check-in and check-out dates.</li>
          <li>Click <b>Create Check-In</b>.</li>
        </ol>
      </div>
    </div>
  </div>

  <!-- ROOM STATUS -->
  <div class="accordion-item help-item" data-category="rooms"
       data-keywords="room availability status available occupied cleaning maintenance">
    <h2 class="accordion-header">
      <button class="accordion-button collapsed" type="button"
              data-bs-toggle="collapse" data-bs-target="#c4">
        <i class="bi bi-door-open me-2"></i> How to check room availability?
      </button>
    </h2>

    <div id="c4" class="accordion-collapse collapse"
         data-bs-parent="#helpAccordion">
      <div class="accordion-body">
        <ol class="mb-0">
          <li>Open the <b>Rooms</b> page from the sidebar.</li>
          <li>The system shows all rooms and their status.</li>
          <li>Room statuses include:
            <ul>
              <li><b>AVAILABLE</b></li>
              <li><b>OCCUPIED</b></li>
              <li><b>RESERVED</b></li>
              <li><b>CLEANING</b></li>
              <li><b>MAINTENANCE</b></li>
            </ul>
          </li>
          <li>Only <b>AVAILABLE</b> rooms can be reserved or checked-in.</li>
        </ol>
      </div>
    </div>
  </div>

  <!-- checkout and bill -->
  <div class="accordion-item help-item" data-category="checkout"
       data-keywords="checkout invoice bill payment room stay">
    <h2 class="accordion-header">
      <button class="accordion-button collapsed" type="button"
              data-bs-toggle="collapse" data-bs-target="#c5">
        <i class="bi bi-receipt me-2"></i> How to process guest checkout?
      </button>
    </h2>

    <div id="c5" class="accordion-collapse collapse"
         data-bs-parent="#helpAccordion">
      <div class="accordion-body">
        <ol class="mb-0">
          <li>Open the <b>Checkout</b> page.</li>
          <li>Search the reservation using the <b>reservation ID</b>.</li>
          <li>The system calculates the <b>number of nights</b>.</li>
          <li>An <b>invoice</b> is generated automatically.</li>
          <li>Record payment (Cash, Card, or Online Transfer).</li>
          <li>Complete the checkout process.</li>
        </ol>
      </div>
    </div>
  </div>

</div>
            </div>
          </div>
        </div>
      </section>

      <!-- SUPPORT CONTACT -->
      <section class="mt-3 mb-4">
        <div class="cardx support-card">
          <div class="cardx-body">
            <div class="support-title">
              <i class="bi bi-info-circle"></i> Need additional help?
            </div>
            <div class="support-sub">Contact support if you face system issues or booking conflicts.</div>

            <div class="row g-3 mt-1">
              <div class="col-12 col-md-4">
                <div class="support-chip">
                  <i class="bi bi-headset"></i>
                  <div>
                    <div class="chip-title">IT Support</div>
                    <div class="chip-sub">+94 91 222 3344 (Ext: 101)</div>
                  </div>
                </div>
              </div>

              <div class="col-12 col-md-4">
                <div class="support-chip">
                  <i class="bi bi-envelope"></i>
                  <div>
                    <div class="chip-title">Email</div>
                    <div class="chip-sub">support@oceanviewresort.lk</div>
                  </div>
                </div>
              </div>

              <div class="col-12 col-md-4">
                <div class="support-chip">
                  <i class="bi bi-person-badge"></i>
                  <div>
                    <div class="chip-title">Front Desk Manager</div>
                    <div class="chip-sub">+94 91 123 4567 (Ext: 100)</div>
                  </div>
                </div>
              </div>
            </div>

          </div>
        </div>
      </section>

    </main>
  </div>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

  <script>
   
    function updateDateTime() {
      const now = new Date();
      const options = {
        weekday: 'long', year: 'numeric', month: 'long', day: 'numeric',
        hour: '2-digit', minute: '2-digit'
      };
      document.getElementById('currentDateTime').textContent = now.toLocaleDateString(undefined, options);
    }

    
    const searchEl = document.getElementById('helpSearch');
    const categoryEl = document.getElementById('helpCategory');
    const items = Array.from(document.querySelectorAll('.help-item'));
    const noResults = document.getElementById('noResults');
    const visibleCount = document.getElementById('visibleCount');

    function applyFilters() {
      const q = (searchEl.value || '').trim().toLowerCase();
      const cat = categoryEl.value;

      let shown = 0;

      items.forEach(item => {
        const itemCat = item.dataset.category;
        const keywords = (item.dataset.keywords || '').toLowerCase();
        const text = item.innerText.toLowerCase();

        const catMatch = (cat === 'all') || (itemCat === cat);
        const qMatch = !q || keywords.includes(q) || text.includes(q);

        const shouldShow = catMatch && qMatch;
        item.style.display = shouldShow ? '' : 'none';
        if (shouldShow) shown++;
      });

      visibleCount.textContent = shown + " Topic" + (shown === 1 ? "" : "s");
      noResults.style.display = shown === 0 ? 'block' : 'none';
    }

    document.addEventListener('DOMContentLoaded', () => {
      updateDateTime();
      setInterval(updateDateTime, 1000);
      applyFilters();
    });

    searchEl.addEventListener('input', applyFilters);
    categoryEl.addEventListener('change', applyFilters);

    document.querySelectorAll('#mobileSidebar a.sb-link').forEach(link => {
      link.addEventListener('click', () => {
        const el = document.getElementById('mobileSidebar');
        const offcanvas = bootstrap.Offcanvas.getInstance(el);
        if (offcanvas) offcanvas.hide();
      });
    });
  </script>
</body>
</html>
