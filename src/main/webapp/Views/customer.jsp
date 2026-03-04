<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="model.Room" %>
<%@ page import="dao.RoomDAO" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="dao.ReservationDAO" %>
<%@ page import="model.ReservationRequest" %>
<%@ page import="dao.InvoiceDAO" %>
<%@ page import="model.Invoice" %>

<%
  String flashMsg = (String) session.getAttribute("flashMsg");
  String flashType = (String) session.getAttribute("flashType");
  if (flashMsg != null) {
      session.removeAttribute("flashMsg");
      session.removeAttribute("flashType");
  }
%>

<%
    if (request.getAttribute("myReservations") == null) {
        response.sendRedirect(request.getContextPath() + "/CustomerRoomsServlet");
        return;
    }
%>

<%
    // Auth guard: only Guests allowed
    String authType = (String) session.getAttribute("authType");
    String guestEmail = (String) session.getAttribute("guestEmail");

    if (authType == null || !"GUEST".equals(authType) || guestEmail == null) {
        response.sendRedirect(request.getContextPath() + "/Views/login.jsp");
        return;
    }

    List<Room> availableRooms = (List<Room>) request.getAttribute("availableRooms");
    String errorMsg = (String) request.getAttribute("errorMsg");

    if (availableRooms == null && errorMsg == null) {
        try {
            RoomDAO dao = new RoomDAO();
            availableRooms = dao.getAvailableRooms();
            request.setAttribute("availableRooms", availableRooms);
        } catch (Exception ex) {
            ex.printStackTrace();
            errorMsg = "Failed to load rooms. Please try again.";
            request.setAttribute("errorMsg", errorMsg);
        }
    }

    Set<String> typeSet = new LinkedHashSet<>();
    if (availableRooms != null) {
        for (Room r : availableRooms) {
            if (r.getTypeName() != null && !r.getTypeName().trim().isEmpty()) {
                typeSet.add(r.getTypeName().trim());
            }
        }
    }
%>

<%
  String selectedCheckIn = (String) request.getAttribute("selectedCheckIn");
  String selectedCheckOut = (String) request.getAttribute("selectedCheckOut");
  if (selectedCheckIn == null) selectedCheckIn = "";
  if (selectedCheckOut == null) selectedCheckOut = "";
%>

<%
    // messages
    List<ReservationRequest> confirmedMsgs = null;
    int newMsgCount = 0;

    try {
        ReservationDAO rdao = new ReservationDAO();

        confirmedMsgs = rdao.getConfirmedReservationsByEmail(guestEmail);

        Timestamp lastSeen = (Timestamp) session.getAttribute("msgLastSeen");
        if (lastSeen == null) {
            lastSeen = new Timestamp(0); // epoch
        }
        newMsgCount = rdao.countConfirmedUpdatedAfter(guestEmail, lastSeen);

    } catch (Exception ex) {
        ex.printStackTrace();
        confirmedMsgs = new ArrayList<>();
        newMsgCount = 0;
    }
%>
<%
    List<Invoice> invoiceMsgs = null;
    int newInvoiceCount = 0;

    try {
        InvoiceDAO idao = new InvoiceDAO();

        invoiceMsgs = idao.getInvoicesByGuestEmail(guestEmail);

        Timestamp lastSeen = (Timestamp) session.getAttribute("msgLastSeen");
        if (lastSeen == null) lastSeen = new Timestamp(0);

        newInvoiceCount = idao.countInvoicesUpdatedAfter(guestEmail, lastSeen);

    } catch (Exception ex) {
        ex.printStackTrace();
        invoiceMsgs = new ArrayList<>();
        newInvoiceCount = 0;
    }

    int totalNewMsgCount = newMsgCount + newInvoiceCount;
%>
<%
    List<ReservationRequest> myReservations =
            (List<ReservationRequest>) request.getAttribute("myReservations");
    if (myReservations == null) myReservations = new ArrayList<>();
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Ocean View Resort - Customer</title>

  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">

  <!-- Bootstrap 5 -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"/>
  <!-- Bootstrap Icons -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet"/>

  
  <script defer src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

  <style>
    :root{
      --ovr-aqua:#0aa7c6;
      --ovr-blue:#0b5aa6;
      --ovr-deep:#064b77;
      --ovr-ink:#0d0f12;
      --ovr-muted: rgba(13,15,18,.68);
      --glass: rgba(255,255,255,.44);
      --glass2: rgba(255,255,255,.58);
      --shadow: 0 18px 48px rgba(0,0,0,.18);
      --radius: 18px;
    }

    body{
      font-family: "Inter", system-ui, -apple-system, Segoe UI, Roboto, Arial, sans-serif;
      font-weight: 400;
      letter-spacing: 0;
      background:
        radial-gradient(1200px 600px at 15% 10%, rgba(10,167,198,.16), transparent 60%),
        radial-gradient(1200px 700px at 85% 15%, rgba(11,90,166,.14), transparent 60%),
        linear-gradient(180deg, rgba(0,95,150,.06), rgba(0,0,0,.02));
      color: var(--ovr-ink);
    }

    h1,h2,h3,h4,h5{ letter-spacing: .1px; }
    .fw-bold{ font-weight: 600 !important; } 
    .fw-semibold{ font-weight: 600 !important; }
    .fw-normal{ font-weight: 400 !important; }

    .ovr-navbar{
      position: sticky;
      top: 0;
      z-index: 1020;
      backdrop-filter: blur(14px);
      background: rgba(255,255,255,.62);
      border-bottom: 1px solid rgba(255,255,255,.75);
      box-shadow: 0 10px 30px rgba(0,0,0,.06);
    }

    .brand-wrap{
      display:flex;
      align-items:center;
      gap:10px;
      font-weight: 700;
      letter-spacing:.1px;
    }
    .brand-wrap img{ width:44px; height:44px; object-fit:contain; }
    .brand-name{ line-height:1.1; font-weight: 700; }
    .brand-name small{
      display:block;
      font-weight: 500;
      opacity:.72;
      letter-spacing:1.2px;
      font-size:.72rem;
      margin-top:2px;
    }

    .nav-link{
      font-weight: 600;
      color: rgba(0,0,0,.72) !important;
    }
    .nav-link.active{
      color: var(--ovr-blue) !important;
    }

    .btn-ovr{
      border:0;
      font-weight: 600;
      color:#fff;
      padding: .70rem 1.05rem;
      border-radius: 14px;
      background: linear-gradient(90deg, rgba(0,220,210,.95), rgba(0,150,255,.95));
      box-shadow: 0 14px 26px rgba(0,0,0,.14);
    }

    .hero{ padding: 22px 0 0; }

    .hero-card{
      border-radius: 28px;
      overflow:hidden;
      box-shadow: var(--shadow);
      border: 1px solid rgba(255,255,255,.72);
      background: rgba(255,255,255,.28);
    }

    .carousel-item{ height: 520px; }

    .hero-img{
      width:100%;
      height:100%;
      object-fit:cover;
      filter: saturate(1.05) contrast(1.03);
    }

    .hero-overlay{
      position:absolute;
      inset:0;
      background: linear-gradient(90deg, rgba(0,0,0,.58), rgba(0,0,0,.10) 55%, rgba(0,0,0,.35));
    }

    .hero-content{
      position:absolute;
      inset:0;
      display:flex;
      align-items:center;
      padding: 48px;
      color:#fff;
    }

    .hero-badge{
      display:inline-flex;
      align-items:center;
      gap:8px;
      padding: 9px 14px;
      border-radius: 999px;
      background: rgba(255,255,255,.18);
      border: 1px solid rgba(255,255,255,.26);
      font-weight: 600;
      letter-spacing:.3px;
      font-size: .88rem;
    }

    .hero-title{
      font-size: clamp(1.8rem, 3.0vw, 3.0rem);
      font-weight: 700;
      margin-top: 14px;
      margin-bottom: 10px;
    }

    .hero-text{
      max-width: 640px;
      opacity:.92;
      font-weight: 400;
      line-height: 1.55;
      font-size: 1rem;
    }

    .carousel-indicators [data-bs-target]{
      width: 10px;
      height: 10px;
      border-radius: 50%;
    }

    .section-title{
      margin-top: 44px;
      font-weight: 700;
      letter-spacing:.1px;
    }

    .section-sub{
      color: var(--ovr-muted);
      font-weight: 400;
      margin-bottom: 14px;
    }

    .filter-bar{
      border-radius: 18px;
      background: var(--glass);
      border: 1px solid rgba(255,255,255,.75);
      box-shadow: 0 14px 35px rgba(0,0,0,.08);
      padding: 14px;
    }

    .filter-input{
      border-radius: 14px;
      border: 1.6px solid rgba(0,0,0,.12);
      background: rgba(255,255,255,.70);
      height: 46px;
      font-weight: 500;
    }
    .filter-input:focus{
      border-color: rgba(10,167,198,.45);
      box-shadow: 0 0 0 .2rem rgba(10,167,198,.14);
    }

    .btn-outline-ovr{
      border: 1.8px solid rgba(0,0,0,.18);
      background: rgba(255,255,255,.22);
      font-weight: 600;
      border-radius: 14px;
      height: 46px;
    }

    /* Cards */
    .rooms-grid{
      display: grid;
      grid-template-columns: repeat(3, minmax(0, 1fr));
      gap: 18px;
      margin-top: 16px;
      margin-bottom: 10px;
    }

    .room-card{
      border-radius: 20px;
      overflow: hidden;
      background: rgba(255,255,255,.70);
      border: 1px solid rgba(255,255,255,.90);
      box-shadow: 0 16px 44px rgba(0,0,0,.10);
      transition: transform .15s ease, box-shadow .15s ease;
    }
    .room-card:hover{
      transform: translateY(-2px);
      box-shadow: 0 22px 52px rgba(0,0,0,.14);
    }

    .room-img-wrap{
      height: 220px;
      background: rgba(0,0,0,.06);
    }
    .room-img{
      width: 100%;
      height: 100%;
      object-fit: cover;
      filter: saturate(1.05) contrast(1.03);
    }

    .room-body{ padding: 16px 16px 18px; }

    .room-top{
      display:flex;
      align-items:flex-start;
      justify-content:space-between;
      gap: 10px;
    }

    .room-name{
      font-weight: 600;
      font-size: 1.02rem;
    }

    .room-price{
      font-weight: 600;
      font-size: 1.05rem;
      color: var(--ovr-deep);
      white-space: nowrap;
    }
    .room-price span{
      font-weight: 500;
      color: rgba(0,0,0,.55);
      font-size: .9rem;
      margin-left: 4px;
    }

    .room-meta{
      margin-top: 10px;
      display:flex;
      flex-wrap:wrap;
      gap: 10px 14px;
      color: rgba(0,0,0,.66);
      font-weight: 500;
      font-size: .92rem;
    }
    .room-meta i{ margin-right: 6px; }

    .room-desc{
      margin-top: 10px;
      color: rgba(0,0,0,.68);
      font-weight: 400;
      line-height: 1.45;
      min-height: 44px;
      font-size: .95rem;
    }

    .room-actions{ margin-top: 14px; }

    .grid-full{ grid-column: 1 / -1; }
    .is-hidden{ display:none !important; }

    @media (max-width: 1200px){
      .rooms-grid{ grid-template-columns: repeat(2, minmax(0, 1fr)); }
    }
    @media (max-width: 768px){
      .rooms-grid{ grid-template-columns: 1fr; }
      .room-img-wrap{ height: 200px; }
    }

    .rooms-shell{
      border-radius: 20px;
      background: rgba(255,255,255,.55);
      border: 1px dashed rgba(0,0,0,.18);
      padding: 22px;
      box-shadow: 0 14px 34px rgba(0,0,0,.08);
    }
    .rooms-shell .hint{
      color: rgba(0,0,0,.64);
      font-weight: 400;
      line-height: 1.55;
    }

    .contact-shell{
      border-radius: 20px;
      background: rgba(255,255,255,.56);
      border: 1px solid rgba(255,255,255,.78);
      box-shadow: 0 16px 42px rgba(0,0,0,.08);
      padding: 26px;
    }

    .contact-side{
      border-radius: 20px;
      background: rgba(255,255,255,.60);
      border: 1px solid rgba(255,255,255,.78);
      box-shadow: 0 16px 42px rgba(0,0,0,.08);
      padding: 26px;
      height: 100%;
    }

    .contact-label{
      font-weight: 600;
      margin-bottom: 8px;
    }

    .contact-input{
      border-radius: 14px;
      border: 1.6px solid rgba(0,0,0,.12);
      background: rgba(255,255,255,.74);
      font-weight: 500;
      padding: .72rem .9rem;
    }
    .contact-input:focus{
      border-color: rgba(10,167,198,.45);
      box-shadow: 0 0 0 .2rem rgba(10,167,198,.14);
    }

    .info-row{
      display:flex;
      gap:14px;
      align-items:flex-start;
      margin-bottom: 16px;
    }
    .info-row i{
      font-size: 18px;
      margin-top: 3px;
      color: rgba(0,0,0,.70);
    }
    .info-title{
      font-weight: 600;
      margin-bottom: 2px;
    }
    .info-value{
      color: rgba(0,0,0,.66);
      font-weight: 400;
    }

    footer{
      margin-top: 60px;
      background: linear-gradient(180deg, rgba(7,101,155,1), rgba(6,75,119,1));
      color: #fff;
      padding: 40px 0 22px;
    }
    .footer-muted{ opacity:.86; font-weight:400; }

    @media (max-width: 992px){
      .carousel-item{ height: 420px; }
      .hero-content{ padding: 26px; }
    }

    .book-card{
      border: 0;
      border-radius: 20px;
      overflow: hidden;
      background: rgba(255,255,255,.72);
      backdrop-filter: blur(14px);
      box-shadow: 0 22px 60px rgba(0,0,0,.20);
    }

    .book-header{
      padding: 16px 18px;
      background: linear-gradient(90deg, rgba(0,220,210,.95), rgba(0,150,255,.95));
      color: #fff;
      display:flex;
      justify-content:space-between;
      align-items:center;
      gap: 10px;
    }

    .book-title{
      font-weight: 700;
      font-size: 1.05rem;
      margin: 0;
    }

    .book-sub{
      font-weight: 400;
      opacity: .92;
      font-size: .9rem;
      margin: 2px 0 0;
    }

    .book-body{ padding: 16px; }

    .book-chip{
      display:inline-flex;
      align-items:center;
      gap:8px;
      padding: 7px 11px;
      border-radius: 999px;
      background: rgba(11,90,166,.10);
      border: 1px solid rgba(11,90,166,.18);
      font-weight: 600;
      color: rgba(6,75,119,.92);
      font-size: .9rem;
    }

    .book-layout{
      display:grid;
      grid-template-columns: 1fr 1fr;
      gap: 14px 14px;
      margin-top: 14px;
    }

    .book-label{
      font-weight: 600;
      font-size: .88rem;
      margin-bottom: 6px;
      color: rgba(0,0,0,.74);
    }

    .book-input{
      border-radius: 14px;
      border: 1.6px solid rgba(0,0,0,.12);
      background: rgba(255,255,255,.76);
      font-weight: 500;
      padding: .70rem .9rem;
    }
    .book-input:focus{
      border-color: rgba(10,167,198,.45);
      box-shadow: 0 0 0 .2rem rgba(10,167,198,.14);
    }

    .book-span-2{ grid-column: 1 / -1; }

    .book-actions{
      display:flex;
      gap: 10px;
      margin-top: 14px;
    }

    .book-cancel{
      border-radius: 14px;
      font-weight: 600;
      border: 1.8px solid rgba(0,0,0,.16);
      background: rgba(255,255,255,.40);
      color: rgba(0,0,0,.78);
      flex: 1;
      height: 46px;
    }

    .book-submit{
      flex: 1;
      height: 46px;
    }

    .book-note{
      display:flex;
      gap:8px;
      align-items:flex-start;
      color: rgba(0,0,0,.60);
      font-weight: 400;
      font-size: .86rem;
      line-height: 1.35;
      margin-top: 12px;
    }
    .book-note i{ margin-top: 2px; }

    @media (max-width: 576px){
      .book-layout{ grid-template-columns: 1fr; }
      .book-actions{ flex-direction: column; }
    }
  </style>
</head>

<body>

<!-- NAVBAR -->
<nav class="navbar navbar-expand-lg ovr-navbar">
  <div class="container">
    <a class="navbar-brand brand-wrap" href="#">
      <img src="<%= request.getContextPath() %>/images/logo_black.png" alt="Ocean View Resort Logo">
      <div class="brand-name">
        Ocean View Resort
        <small>HOTEL RESERVATION</small>
      </div>
    </a>

    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navMain">
      <span class="navbar-toggler-icon"></span>
    </button>

    <div class="collapse navbar-collapse" id="navMain">
      <ul class="navbar-nav ms-auto align-items-lg-center gap-lg-2">
        <li class="nav-item">
          <a class="nav-link active" href="#rooms"><i class="bi bi-door-open me-1"></i>Available Rooms</a>
        </li>
        <li class="nav-item">
          <a class="nav-link" href="#myres"><i class="bi bi-journal-check me-1"></i>My Reservations</a>
        </li>
        <li class="nav-item">
          <a class="nav-link" href="#contact"><i class="bi bi-chat-dots me-1"></i>Contact Us</a>
        </li>

        <li class="nav-item d-none d-lg-block mx-lg-2">
          <span class="badge rounded-pill text-bg-light" style="font-weight:600; border:1px solid rgba(0,0,0,.10);">
            <i class="bi bi-person-circle me-1"></i><%= guestEmail %>
          </span>
        </li>

<li class="nav-item ms-lg-2">
  <button class="btn position-relative"
          type="button"
          data-bs-toggle="offcanvas"
          data-bs-target="#messagesCanvas"
          aria-controls="messagesCanvas"
          style="border:1px solid rgba(0,0,0,.10); border-radius:14px; background:rgba(255,255,255,.55); height:44px; padding:0 14px;">
    <i class="bi bi-envelope"></i>

    <% if (totalNewMsgCount > 0) { %>
      <span id="msgBadge"
            class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger">
        <%= totalNewMsgCount %>
      </span>
    <% } else { %>
      <span id="msgBadge"
            class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger d-none">
        0
      </span>
    <% } %>
  </button>
</li>

        <li class="nav-item ms-lg-2">
          <a class="btn btn-ovr" href="<%= request.getContextPath() %>/LogoutServlet">
            <i class="bi bi-box-arrow-right me-1"></i>Logout
          </a>
        </li>
      </ul>
    </div>
  </div>
</nav>

<% if (flashMsg != null) { %>
  <div class="container mt-3">
    <div class="alert alert-<%= (flashType == null ? "info" : flashType) %> alert-dismissible fade show"
         role="alert" style="border-radius:16px; font-weight:500;">
      <%= flashMsg %>
      <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
  </div>

  <script>
    setTimeout(() => {
      const el = document.querySelector('.alert.alert-dismissible');
      if (!el) return;

      if (window.bootstrap && bootstrap.Alert) {
        bootstrap.Alert.getOrCreateInstance(el).close();
      } else {
        el.classList.remove('show');
        el.remove();
      }
    }, 4000);
  </script>
<% } %>

<!-- HERO -->
<section class="hero">
  <div class="container">
    <div id="heroCarousel" class="carousel slide hero-card" data-bs-ride="carousel" data-bs-interval="4500">
      <div class="carousel-indicators">
        <button type="button" data-bs-target="#heroCarousel" data-bs-slide-to="0" class="active"></button>
        <button type="button" data-bs-target="#heroCarousel" data-bs-slide-to="1"></button>
        <button type="button" data-bs-target="#heroCarousel" data-bs-slide-to="2"></button>
      </div>

      <div class="carousel-inner">
        <div class="carousel-item active position-relative">
          <img class="hero-img" src="https://i.pinimg.com/1200x/09/58/44/095844ab5536d6ed203924e385a76bc2.jpg" alt="Ocean view">
          <div class="hero-overlay"></div>
          <div class="hero-content">
            <div>
              <div class="hero-badge"><i class="bi bi-stars"></i> Welcome Back</div>
              <div class="hero-title">Your peaceful escape by the ocean.</div>
            </div>
          </div>
        </div>

        <div class="carousel-item position-relative">
          <img class="hero-img" src="https://i.pinimg.com/1200x/32/d5/3b/32d53b53f51500c78d01946976d27c13.jpg" alt="Pool side">
          <div class="hero-overlay"></div>
          <div class="hero-content">
            <div>
              <div class="hero-badge"><i class="bi bi-wind"></i> Relax & Recharge</div>
              <div class="hero-title">Comfort that feels effortless.</div>
            </div>
          </div>
        </div>

        <div class="carousel-item position-relative">
          <img class="hero-img" src="https://i.pinimg.com/1200x/81/dd/67/81dd675f8e7830554024bfca88db9369.jpg" alt="Sunset">
          <div class="hero-overlay"></div>
          <div class="hero-content">
            <div>
              <div class="hero-badge"><i class="bi bi-geo-alt"></i> Sri Lanka</div>
              <div class="hero-title">Ocean views. Sunset moments.</div>
            </div>
          </div>
        </div>
      </div>

      <button class="carousel-control-prev" type="button" data-bs-target="#heroCarousel" data-bs-slide="prev">
        <span class="carousel-control-prev-icon"></span>
      </button>
      <button class="carousel-control-next" type="button" data-bs-target="#heroCarousel" data-bs-slide="next">
        <span class="carousel-control-next-icon"></span>
      </button>
    </div>
  </div>
</section>

<!-- ROOMS SECTION -->
<section id="rooms" class="container">
  <h2 class="section-title">Available Rooms</h2>

  <div class="filter-bar mb-4">
    <form method="get" action="<%= request.getContextPath() %>/CustomerRoomsServlet">
      <div class="row g-2 align-items-center">

        <!-- Date range -->
        <div class="col-lg-2">
          <input type="date" class="form-control filter-input" name="check_in_date"
                 id="searchCheckIn" value="<%= selectedCheckIn %>" required>
        </div>

        <div class="col-lg-2">
          <input type="date" class="form-control filter-input" name="check_out_date"
                 id="searchCheckOut" value="<%= selectedCheckOut %>" required>
        </div>

        <div class="col-lg-1 d-grid">
          <button class="btn btn-ovr" type="submit" style="height:46px;">Search</button>
        </div>

        <div class="col-lg-3">
          <div class="input-group">
            <span class="input-group-text bg-transparent border-0"><i class="bi bi-search"></i></span>
            <input id="searchInput" type="text" class="form-control filter-input"
                   placeholder="Search (room number, type, description)">
          </div>
        </div>

        <div class="col-lg-2">
          <select id="capacityFilter" class="form-select filter-input">
            <option value="">Capacity: Any</option>
            <option value="1">1 Guest</option>
            <option value="2">2 Guests</option>
            <option value="3">3 Guests</option>
            <option value="4">4+ Guests</option>
          </select>
        </div>

        <div class="col-lg-1">
          <select id="typeFilter" class="form-select filter-input">
            <option value="">Room Type: Any</option>
            <% for (String t : typeSet) { %>
              <option value="<%= t %>"><%= t %></option>
            <% } %>
          </select>
        </div>

        <div class="col-lg-1 d-grid">
          <button id="resetBtn" class="btn btn-outline-ovr" type="button">Reset</button>
        </div>

      </div>
    </form>

    <div class="mt-2" style="color:rgba(0,0,0,.62); font-weight:500; font-size:.92rem;">
      Showing rooms available from <span style="font-weight:700;"><%= selectedCheckIn %></span>
      to <span style="font-weight:700;"><%= selectedCheckOut %></span>
    </div>
  </div>

  <!-- ROOMS GRID -->
  <div id="roomsGrid" class="rooms-grid">
    <%
      if (errorMsg != null) {
    %>
        <div class="alert alert-danger grid-full" style="border-radius:16px; font-weight:500;">
          <%= errorMsg %>
        </div>
    <%
      } else if (availableRooms == null || availableRooms.isEmpty()) {
    %>
        <div class="rooms-shell grid-full" id="emptyState">
          <div class="d-flex align-items-start gap-3">
            <div class="fs-2">🛏️</div>
            <div>
              <div class="fw-semibold">No available rooms right now</div>
              <div class="hint">Please check again later.</div>
            </div>
          </div>
        </div>
    <%
      } else {
        for (Room r : availableRooms) {

          String img = r.getRoomImage();
          if (img == null || img.trim().isEmpty()) {
            img = request.getContextPath() + "/images/room_placeholder.jpg";
          } else {
            if (!img.startsWith("http")) {
              if (!img.startsWith("/")) img = "/" + img;
              img = request.getContextPath() + img;
            }
          }

          String desc = (r.getDescription() == null || r.getDescription().trim().isEmpty())
                  ? "Comfortable room with a relaxing stay experience."
                  : r.getDescription();

          String typeName = (r.getTypeName() == null) ? "" : r.getTypeName().trim();
    %>

      <div class="room-card roomItem"
           data-roomnumber="<%= r.getRoomNumber() == null ? "" : r.getRoomNumber().toLowerCase() %>"
           data-type="<%= typeName.toLowerCase() %>"
           data-capacity="<%= r.getCapacity() %>"
           data-desc="<%= desc.toLowerCase() %>">

        <div class="room-img-wrap">
          <img class="room-img" src="<%= img %>" alt="Room Image">
        </div>

        <div class="room-body">
          <div class="room-top">
            <div class="room-name">
              Room <%= r.getRoomNumber() %>
            </div>

            <div class="room-price">
              Rs. <%= String.format("%.0f", r.getNightlyRate()) %><span>/night</span>
            </div>
          </div>

          <div class="room-meta">
            <span><i class="bi bi-people"></i> <%= r.getCapacity() %> Guests</span>
            <% if (r.getFloorNo() != null) { %>
              <span><i class="bi bi-building"></i> Floor <%= r.getFloorNo() %></span>
            <% } %>
          </div>

          <div class="room-desc"><%= desc %></div>

          <div class="room-actions">
            <button type="button"
                    class="btn btn-ovr w-100 bookNowBtn"
                    data-roomid="<%= r.getRoomId() %>"
                    data-roomnumber="<%= r.getRoomNumber() %>"
                    data-capacity="<%= r.getCapacity() %>">
              <i class="bi bi-calendar-check me-1"></i>Book Now
            </button>
          </div>
        </div>
      </div>

    <%
        }
      }
    %>

    <div class="rooms-shell grid-full is-hidden" id="noMatchState">
      <div class="d-flex align-items-start gap-3">
        <div class="fs-2">🔎</div>
        <div>
          <div class="fw-semibold">No rooms match your filters</div>
          <div class="hint">Try changing capacity / type or clear the search.</div>
        </div>
      </div>
    </div>

  </div>
</section>

<!-- MY RESERVATIONS -->
<section id="myres" class="container">
  <h2 class="section-title">My Reservations</h2>
  <p class="section-sub">Only your reservations (matched by your email) are shown here.</p>

  <style>
    .myres-card{
      border-radius: 20px;
      background: rgba(255,255,255,.70);
      border: 1px solid rgba(255,255,255,.90);
      box-shadow: 0 16px 44px rgba(0,0,0,.10);
      overflow:hidden;
    }
    .myres-head{
      padding: 14px 16px;
      background: linear-gradient(90deg, rgba(10,167,198,.95), rgba(11,90,166,.92));
      color:#fff;
      display:flex;
      justify-content:space-between;
      align-items:center;
      gap:10px;
    }
    .myres-head .title{
      font-weight: 700;
      margin:0;
      font-size: 1.05rem;
    }
    .myres-head .meta{
      font-weight: 500;
      opacity:.92;
      font-size:.9rem;
    }
    .status-pill{
      display:inline-flex;
      align-items:center;
      gap:8px;
      padding: 7px 12px;
      border-radius: 999px;
      font-weight: 600;
      font-size: .86rem;
      border: 1px solid rgba(0,0,0,.10);
      background: rgba(255,255,255,.70);
      color: rgba(0,0,0,.75);
    }
    .st-PENDING{ background: rgba(255,193,7,.18); border-color: rgba(255,193,7,.25); color: rgba(120,80,0,.95); }
    .st-CONFIRMED{ background: rgba(13,110,253,.16); border-color: rgba(13,110,253,.22); color: rgba(0,70,160,.95); }
    .st-CHECKED_IN{ background: rgba(32,201,151,.16); border-color: rgba(32,201,151,.22); color: rgba(0,110,80,.95); }
    .st-CHECKED_OUT{ background: rgba(108,117,125,.16); border-color: rgba(108,117,125,.22); color: rgba(70,70,70,.95); }
    .st-CANCELLED{ background: rgba(220,53,69,.16); border-color: rgba(220,53,69,.22); color: rgba(150,10,25,.95); }

    .myres-table th{
      font-size: 12px;
      font-weight: 700;
      opacity: .85;
      white-space: nowrap;
    }
    .myres-table td{
      font-size: 14px;
      font-weight: 500;
      color: rgba(0,0,0,.78);
      vertical-align: middle;
    }
    .myres-muted{ color: rgba(0,0,0,.60); font-weight: 500; font-size: .9rem; }
  </style>

  <div class="myres-card">
    <div class="myres-head">
      <div>
        <p class="title mb-1"><i class="bi bi-journal-check me-2"></i>Reservation History</p>
        <div class="meta">Email: <%= guestEmail %></div>
      </div>
      <div class="meta">
        Total: <span style="font-weight:700;"><%= myReservations.size() %></span>
      </div>
    </div>

    <div class="p-3">

      <% if (myReservations.isEmpty()) { %>
        <div class="p-3" style="border-radius:16px; background:rgba(255,255,255,.85); border:1px dashed rgba(0,0,0,.16);">
          <div style="font-weight:600;">No reservations found</div>
          <div class="myres-muted" style="margin-top:6px;">
            Once you submit a booking request, your reservations will appear here.
          </div>
        </div>
      <% } else { %>

        <div class="table-responsive">
          <table class="table table-sm align-middle myres-table mb-0">
            <thead>
              <tr>
                <th>Reservation</th>
                <th>Room</th>
                <th>Check-in</th>
                <th>Check-out</th>
                <th>Nights</th>
                <th>Guests</th>
                <th>Status</th>
              </tr>
            </thead>
            <tbody>
            <%
              for (ReservationRequest rr : myReservations) {
                String st = (rr.getReservationStatus()==null) ? "" : rr.getReservationStatus().trim().toUpperCase();

                int nights = 0;
                try {
                  if (rr.getCheckInDate() != null && rr.getCheckOutDate() != null) {
                    java.time.LocalDate ci = rr.getCheckInDate().toLocalDate();
                    java.time.LocalDate co = rr.getCheckOutDate().toLocalDate();
                    nights = (int) java.time.temporal.ChronoUnit.DAYS.between(ci, co);
                    if (nights < 0) nights = 0;
                  }
                } catch (Exception e) { nights = 0; }
            %>
              <tr>
                <td>
                  <div style="font-weight:700;">RES-<%= rr.getReservationId() %></div>
                  <div class="myres-muted">Created: <%= rr.getCreatedAt() %></div>
                </td>
                <td>
                  <div style="font-weight:700;">Room <%= rr.getRoomNumber() %></div>
                  <div class="myres-muted">ID: <%= rr.getRoomId() %></div>
                </td>
                <td><%= rr.getCheckInDate() %></td>
                <td><%= rr.getCheckOutDate() %></td>
                <td><%= nights %></td>
                <td><%= rr.getNumberOfGuests() %></td>
                <td>
                  <span class="status-pill st-<%= st %>">
                    <i class="bi bi-dot"></i> <%= st %>
                  </span>
                </td>
              </tr>
            <% } %>
            </tbody>
          </table>
        </div>

      <% } %>
    </div>
  </div>
</section>

<!-- CONTACT -->
<section id="contact" class="container">
  <h2 class="section-title">Contact Us</h2>
  <p class="section-sub mb-3">Need help? Send a message — our team will respond quickly.</p>

  <div class="row g-4">
    <div class="col-lg-7">
      <div class="contact-shell">
        <form onsubmit="event.preventDefault(); alert('Message sent (demo).');">
          <div class="row g-3">
            <div class="col-md-6">
              <div class="contact-label">Name</div>
              <input class="form-control contact-input" type="text" placeholder="Enter your name" required>
            </div>

            <div class="col-md-6">
              <div class="contact-label">Email</div>
              <input class="form-control contact-input" type="email" value="<%= guestEmail %>" required>
            </div>

            <div class="col-12">
              <div class="contact-label">Message</div>
              <textarea class="form-control contact-input" rows="6" placeholder="Write your message..." required></textarea>
            </div>

            <div class="col-12 d-grid">
              <button class="btn btn-ovr" type="submit">
                <i class="bi bi-send me-1"></i>Send Message
              </button>
            </div>
          </div>
        </form>
      </div>
    </div>

    <div class="col-lg-5">
      <div class="contact-side">
        <div class="mb-3 fw-semibold" style="font-size:1.05rem;">Resort Details</div>

        <div class="info-row">
          <i class="bi bi-geo-alt-fill"></i>
          <div>
            <div class="info-title">Location</div>
            <div class="info-value">123 Beach Road, Galle, Sri Lanka</div>
          </div>
        </div>

        <div class="info-row">
          <i class="bi bi-telephone-fill"></i>
          <div>
            <div class="info-title">Phone</div>
            <div class="info-value">+94 91 123 4567</div>
          </div>
        </div>

        <div class="info-row">
          <i class="bi bi-envelope-fill"></i>
          <div>
            <div class="info-title">Email</div>
            <div class="info-value">infooceanviewresort@gmail.com</div>
          </div>
        </div>

        <hr style="opacity:.20;">

        <div class="info-row mb-0">
          <i class="bi bi-clock"></i>
          <div>
            <div class="info-title">Support</div>
            <div class="info-value">Available 24/7 for in-house guests</div>
          </div>
        </div>
      </div>
    </div>
  </div>
</section>

<!-- HORIZONTAL BOOK NOW MODAL -->
<div class="modal fade" id="bookModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered modal-lg">
    <div class="modal-content book-card">

      <div class="book-header">
        <div>
          <p class="book-title mb-0">Reservation Request</p>
          <p class="book-sub mb-0">Add your details and submit to reception.</p>
        </div>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>

      <div class="modal-body book-body">
<form id="bookForm" method="post" action="<%= request.getContextPath() %>/BookRoomServlet">
  <input type="hidden" name="room_id" id="book_room_id">
  <input type="hidden" name="room_number" id="book_room_number">

  <div class="d-flex flex-wrap align-items-center justify-content-between gap-2">
    <div class="book-chip">
      <i class="bi bi-door-open"></i>
      <span id="bookRoomLabel">Room -</span>
    </div>
    <div style="color:rgba(0,0,0,.56); font-size:.9rem;">
      <i class="bi bi-shield-check me-1"></i>Your details are private
    </div>
  </div>

  <div class="book-layout">
    <div>
      <div class="book-label">Full Name</div>
      <input type="text" class="form-control book-input" name="guest_name" required>
    </div>

    <div>
      <div class="book-label">Phone Number</div>
      <input type="tel" class="form-control book-input" name="guest_phone" required>
    </div>

    <div>
      <div class="book-label">NIC / Passport</div>
      <input type="text" class="form-control book-input" name="guest_nic_passport">
    </div>

    <div>
      <div class="book-label">Email</div>
      <input type="email" class="form-control book-input" name="guest_email"
             value="<%= guestEmail %>" readonly required>
    </div>

    <div>
      <div class="book-label">Check-in Date</div>
      <input type="date" class="form-control book-input" name="check_in_date" id="checkIn" required>
    </div>

    <div>
      <div class="book-label">Check-out Date</div>
      <input type="date" class="form-control book-input" name="check_out_date" id="checkOut" required>
    </div>

    <div>
      <div class="book-label">Number of Guests</div>
      <input type="number" class="form-control book-input" name="number_of_guests" id="guestCount"
             min="1" max="10" value="1" required>
    </div>

    <div class="book-span-2">
      <div class="book-label">Special Requests (Optional)</div>
      <textarea class="form-control book-input" name="special_requests" rows="3"></textarea>
    </div>
  </div>
  <div id="availabilityMsg" class="mt-2" style="display:none; font-weight:600;"></div>

  <div class="book-actions">
    <button type="button" class="btn book-cancel" data-bs-dismiss="modal">Cancel</button>
    <button type="submit" class="btn btn-ovr book-submit">
      <i class="bi bi-send me-1"></i>Submit Request
    </button>
  </div>

  <div class="book-note">
    <i class="bi bi-info-circle"></i>
    Your request will be reviewed by the receptionist and confirmed soon.
  </div>
</form>
      </div>

    </div>
  </div>
</div>

<!-- MESSAGES OFFCANVAS -->
<div class="offcanvas offcanvas-end" tabindex="-1" id="messagesCanvas"
     aria-labelledby="messagesCanvasLabel" style="width:380px;">

  <div class="offcanvas-header"
       style="background: linear-gradient(90deg, rgba(0,220,210,.95), rgba(0,150,255,.95)); color:#fff;">
    <h5 class="offcanvas-title" id="messagesCanvasLabel" style="font-weight:700;">
      <i class="bi bi-bell me-2"></i>Messages
    </h5>
    <button type="button" class="btn-close btn-close-white"
            data-bs-dismiss="offcanvas"></button>
  </div>

  <div class="offcanvas-body" style="background: rgba(255,255,255,.70);">

    <!-- reservation messages-->

    <% if (confirmedMsgs == null || confirmedMsgs.isEmpty()) { %>
      <div class="p-3"
           style="border-radius:16px; background:rgba(255,255,255,.75);
                  border:1px solid rgba(0,0,0,.08);">
        <div style="font-weight:600;">No reservation messages yet</div>
      </div>
    <% } else { %>

      <div class="d-grid gap-2">
        <% for (ReservationRequest rr : confirmedMsgs) { %>
          <div class="p-3"
               style="border-radius:16px; background:rgba(255,255,255,.85);
                      border:1px solid rgba(0,0,0,.08);
                      box-shadow:0 10px 24px rgba(0,0,0,.06);">

            <div style="display:flex; justify-content:space-between; gap:10px;">
              <div style="font-weight:600;">
                Reservation Confirmed ✅
              </div>
              <div style="color:rgba(0,0,0,.55); font-size:.85rem;">
                #<%= rr.getReservationId() %>
              </div>
            </div>

            <div style="margin-top:8px; color:rgba(0,0,0,.72); line-height:1.45;">
              Hello <span style="font-weight:600;">
              <%= (rr.getGuestName() == null ? "Guest" : rr.getGuestName()) %>
              </span>, welcome to Ocean View Resort 🌊<br/>
              Your reservation for
              <span style="font-weight:600;">Room <%= rr.getRoomNumber() %></span> is confirmed.

              <div style="margin-top:8px;">
                <i class="bi bi-calendar-event me-1"></i>
                Check-in: <span style="font-weight:600;"><%= rr.getCheckInDate() %></span><br/>
                <i class="bi bi-calendar2-check me-1"></i>
                Check-out: <span style="font-weight:600;"><%= rr.getCheckOutDate() %></span>
              </div>
            </div>

            <div style="margin-top:10px; color:rgba(0,0,0,.60); font-size:.9rem;">
              We look forward to hosting you.
            </div>
          </div>
        <% } %>
      </div>

    <% } %>

    <!--invoices -->

    <hr style="opacity:.18;">

    <div class="mb-2"
         style="font-weight:700; color:rgba(0,0,0,.75);">
      <i class="bi bi-receipt-cutoff me-2"></i>Invoices
    </div>

    <% if (invoiceMsgs == null || invoiceMsgs.isEmpty()) { %>

      <div class="p-3"
           style="border-radius:16px; background:rgba(255,255,255,.75);
                  border:1px solid rgba(0,0,0,.08);">
        <div style="font-weight:600;">No invoices yet</div>
        <div style="color:rgba(0,0,0,.65); margin-top:6px;">
          After check-out, your invoice CSV will appear here.
        </div>
      </div>

    <% } else { %>

      <div class="d-grid gap-2">

        <% for (Invoice inv : invoiceMsgs) { %>

          <div class="p-3"
               style="border-radius:16px; background:rgba(255,255,255,.85);
                      border:1px solid rgba(0,0,0,.08);
                      box-shadow:0 10px 24px rgba(0,0,0,.06);">

            <div style="display:flex; justify-content:space-between; gap:10px;">
              <div style="font-weight:600;">Invoice Ready ✅</div>
              <div style="color:rgba(0,0,0,.55); font-size:.85rem;">
                #<%= inv.getInvoiceId() %>
              </div>
            </div>

            <div style="margin-top:8px; color:rgba(0,0,0,.72); line-height:1.45;">
              Your check-out invoice is available.<br/>
              Reservation:
              <span style="font-weight:600;">
                RES-<%= inv.getReservationId() %>
              </span><br/>
              Total:
              <span style="font-weight:600;">
                Rs. <%= String.format("%.2f", inv.getTotalAmount()) %>
              </span>
            </div>

            <div class="mt-2 d-flex gap-2">
              <a class="btn btn-sm btn-ovr"
   href="<%= request.getContextPath() %>/CustomerInvoicePdfServlet?invoiceId=<%= inv.getInvoiceId() %>">
  <i class="bi bi-file-earmark-pdf me-1"></i>Download PDF
</a>
            </div>

            <div style="margin-top:10px; color:rgba(0,0,0,.60); font-size:.9rem;">
              Updated: <%= (inv.getUpdatedAt() == null ? "-" : inv.getUpdatedAt()) %>
            </div>

          </div>

        <% } %>

      </div>

    <% } %>

  </div>
</div>

<!-- FOOTER -->
<footer>
  <div class="container">
    <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-2">
      <div style="font-weight:600;">© 2026 Ocean View Resort</div>
    </div>
  </div>
</footer>

<script>
  (function(){
    const searchInput = document.getElementById('searchInput');
    const capacityFilter = document.getElementById('capacityFilter');
    const typeFilter = document.getElementById('typeFilter');
    const resetBtn = document.getElementById('resetBtn');

    const roomItems = Array.from(document.querySelectorAll('.roomItem'));
    const noMatchState = document.getElementById('noMatchState');

    function normalize(str){
      return (str || '').toString().trim().toLowerCase();
    }

    function capacityMatch(roomCap, selectedCap){
      if (!selectedCap) return true;
      const cap = parseInt(roomCap || "0", 10);
      const sel = parseInt(selectedCap, 10);
      if (sel === 4) return cap >= 4;
      return cap === sel;
    }

    function applyFilters(){
      const q = normalize(searchInput.value);
      const capSel = capacityFilter.value;
      const typeSel = normalize(typeFilter.value);

      let shown = 0;

      roomItems.forEach(card => {
        const roomNo = normalize(card.dataset.roomnumber);
        const type = normalize(card.dataset.type);
        const cap = card.dataset.capacity;
        const desc = normalize(card.dataset.desc);

        const searchOk = !q || roomNo.includes(q) || desc.includes(q) || type.includes(q);
        const capOk = capacityMatch(cap, capSel);
        const typeOk = !typeSel || type === typeSel;

        const show = searchOk && capOk && typeOk;
        card.classList.toggle('is-hidden', !show);
        if (show) shown++;
      });

      if (noMatchState) {
        noMatchState.classList.toggle('is-hidden', shown !== 0);
      }
    }

    function resetFilters(){
      searchInput.value = '';
      capacityFilter.value = '';
      typeFilter.value = '';
      applyFilters();
    }

    if (searchInput) searchInput.addEventListener('input', applyFilters);
    if (capacityFilter) capacityFilter.addEventListener('change', applyFilters);
    if (typeFilter) typeFilter.addEventListener('change', applyFilters);
    if (resetBtn) resetBtn.addEventListener('click', resetFilters);

    applyFilters();
  })();
</script>

<script>
  (function(){
    const ci = document.getElementById('searchCheckIn');
    const co = document.getElementById('searchCheckOut');
    if (!ci || !co) return;

    const today = new Date().toISOString().split('T')[0];
    ci.min = today;
    if (!ci.value) ci.value = today;

    function fixCheckout(){
      if (!ci.value) return;
      co.min = ci.value;
      if (!co.value || co.value <= ci.value){
        const d = new Date(ci.value);
        d.setDate(d.getDate() + 1);
        co.value = d.toISOString().split('T')[0];
      }
    }

    ci.addEventListener('change', fixCheckout);
    fixCheckout();
  })();
</script>

<script>
  (function () {
    const modalEl = document.getElementById('bookModal');
    if (!modalEl) return;

    let bookModal = null;

    const roomIdInput = document.getElementById('book_room_id');
    const roomNoInput = document.getElementById('book_room_number');
    const roomLabel = document.getElementById('bookRoomLabel');

    const checkIn = document.getElementById('checkIn');
    const checkOut = document.getElementById('checkOut');
    const guestCount = document.getElementById('guestCount');

   
    const msg = document.getElementById('availabilityMsg');
    const submitBtn = document.querySelector('#bookForm button[type="submit"]');

    function showMsg(text, ok){
      if (!msg) return;
      msg.style.display = 'block';
      msg.style.color = ok ? 'green' : 'crimson';
      msg.textContent = text;
    }

    async function checkAvailability(){
      if (!roomIdInput || !checkIn || !checkOut || !submitBtn) return;
      if (!roomIdInput.value || !checkIn.value || !checkOut.value) return;

      
      if (checkOut.value <= checkIn.value){
        submitBtn.disabled = true;
        showMsg("Check-out must be after check-in.", false);
        return;
      }

      try {
        const url = '<%= request.getContextPath() %>/CheckAvailabilityServlet'
          + '?room_id=' + encodeURIComponent(roomIdInput.value)
          + '&check_in_date=' + encodeURIComponent(checkIn.value)
          + '&check_out_date=' + encodeURIComponent(checkOut.value);

        const res = await fetch(url);
        const data = await res.json();

        if (data.available){
          submitBtn.disabled = false;
          showMsg("Room is available for these dates.", true);
        } else {
          submitBtn.disabled = true;
          showMsg("This room is already booked for these dates. Please choose different dates.", false);
        }
      } catch (e) {
        submitBtn.disabled = false;
        if (msg) msg.style.display = 'none';
      }
    }

    const today = new Date().toISOString().split('T')[0];
    if (checkIn) checkIn.min = today;
    if (checkOut) checkOut.min = today;

    if (checkIn && checkOut) {
      checkIn.addEventListener('change', () => {
        if (checkIn.value) {
          checkOut.min = checkIn.value;
          if (checkOut.value && checkOut.value < checkIn.value) {
            checkOut.value = checkIn.value;
          }
        }
        checkAvailability();
      });

      checkOut.addEventListener('change', checkAvailability);
    }

    modalEl.addEventListener('shown.bs.modal', checkAvailability);

    document.addEventListener('click', function (e) {
      const btn = e.target.closest('.bookNowBtn');
      if (!btn) return;

      if (!bookModal) {
        if (!window.bootstrap || !bootstrap.Modal) return; 
        bookModal = new bootstrap.Modal(modalEl);
      }

      const roomId = btn.getAttribute('data-roomid');
      const roomNo = btn.getAttribute('data-roomnumber');
      const roomCap = parseInt(btn.getAttribute('data-capacity') || "10", 10);

      const form = document.getElementById('bookForm');
      if (form) form.reset();

      if (roomIdInput) roomIdInput.value = roomId || "";
      if (roomNoInput) roomNoInput.value = roomNo || "";
      if (roomLabel) roomLabel.textContent = "Room " + (roomNo || "-");

      if (guestCount) {
        guestCount.max = isNaN(roomCap) ? 10 : roomCap;
        guestCount.value = "1";
      }

      const globalCI = document.getElementById('searchCheckIn');
      const globalCO = document.getElementById('searchCheckOut');
      if (globalCI && globalCI.value && checkIn) checkIn.value = globalCI.value;
      if (globalCO && globalCO.value && checkOut) checkOut.value = globalCO.value;

      
      if (checkIn && checkIn.value) {
        checkOut.min = checkIn.value;
        if (checkOut.value && checkOut.value < checkIn.value) {
          checkOut.value = checkIn.value;
        }
      }

     
      if (msg) msg.style.display = 'none';
      if (submitBtn) submitBtn.disabled = false;

      bookModal.show();
    });
  })();
</script>

<script>
  
  (function(){
    const canvasEl = document.getElementById('messagesCanvas');
    if (!canvasEl) return;

    canvasEl.addEventListener('shown.bs.offcanvas', function(){
      fetch('<%= request.getContextPath() %>/MessageSeenServlet', { method: 'GET' })
        .then(() => {
          const badge = document.getElementById('msgBadge');
          if (badge) {
            badge.textContent = '0';
            badge.classList.add('d-none');
          }
        })
        .catch(() => {});
    });
  })();
</script>

</body>
</html>