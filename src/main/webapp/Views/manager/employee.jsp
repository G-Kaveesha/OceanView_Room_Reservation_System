<%@ page import="java.util.List" %>
<%@ page import="model.User" %>

<%
    String role = (String) session.getAttribute("userRole");
    if (role == null || !"MANAGER".equalsIgnoreCase(role)) {
        response.sendRedirect(request.getContextPath() + "/Views/login.jsp");
        return;
    }

    String ctx = request.getContextPath();

    if (request.getAttribute("employees") == null) {
        response.sendRedirect(request.getContextPath() + "/EmployeeServlet");
        return;
    }

    List<User> employees = (List<User>) request.getAttribute("employees");

    String adminName = (String) session.getAttribute("adminName");
    if (adminName == null) adminName = "John Anderson";

    String adminRole = (String) session.getAttribute("adminRole");
    if (adminRole == null) adminRole = "Admin";
%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Employee Management - Ocean View Resort</title>

  <!-- Bootstrap 5 -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <!-- Bootstrap Icons -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
  <!-- Fonts -->
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
      --card-bg: #ffffff;
      --text-primary: #1f2937;
      --text-secondary: #6b7280;
      --border-color: #e5e7eb;
      --shadow-md: 0 4px 12px rgba(0,0,0,0.08);
      --shadow-lg: 0 10px 30px rgba(0,0,0,0.12);
      --shadow-hover: 0 12px 40px rgba(99, 102, 241, 0.15);
    }

    * { margin:0; padding:0; box-sizing:border-box; }

    body {
      font-family: 'Outfit', sans-serif;
      background-image: url("<%= ctx %>/images/bg.png");
      color: var(--text-primary);
      min-height: 100vh;
    }

    /* Sidebar */
    .sidebar {
      position: fixed;
      left: 0; top: 0;
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
    }

    .sidebar-logo {
      width: 50px; height: 50px;
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
    .sidebar-menu { list-style: none; padding: 0 1rem; }
    .sidebar-menu li { margin-bottom: 0.5rem; }

    .sidebar-menu a {
      display:flex;
      align-items:center;
      gap:1rem;
      padding: 0.875rem 1rem;
      color: rgba(255,255,255,0.8);
      text-decoration:none;
      border-radius: 0.5rem;
      transition: all .3s ease;
      font-weight: 500;
    }

    .sidebar-menu a:hover {
      background: rgba(255,255,255,0.1);
      color:#fff;
      transform: translateX(5px);
    }

    .sidebar-menu a.active {
      background: linear-gradient(90deg, var(--primary-color), var(--secondary-color));
      color:#fff;
      box-shadow: 0 4px 12px rgba(99,102,241,0.3);
    }

    .sidebar-menu i { width:20px; text-align:center; }

    /* Mobile toggle */
    .sidebar-toggle {
      display:none;
      position: fixed;
      top: 1rem; left: 1rem;
      z-index: 1001;
      background: var(--primary-color);
      color:#fff;
      border:none;
      padding: 0.75rem 1rem;
      border-radius: 0.5rem;
      cursor:pointer;
      box-shadow: var(--shadow-md);
    }
    .sidebar.open { transform: translateX(0); }

    /* Main */
    .main-content {
      margin-left: 260px;
      padding: 2rem;
      transition: margin-left .3s ease;
    }

    /* Header */
    .top-header {
      background: white;
      padding: 1.5rem 2rem;
      border-radius: 1rem;
      margin-bottom: 1.5rem;
      box-shadow: var(--shadow-md);
      display:flex;
      justify-content:space-between;
      align-items:center;
      flex-wrap:wrap;
      gap:1rem;
    }

    .header-left h1 {
      font-size: 1.875rem;
      font-weight: 700;
      margin-bottom: 0.25rem;
    }

    .login-time {
      color: var(--text-secondary);
      font-size: 0.875rem;
      display:flex;
      align-items:center;
      gap:0.5rem;
    }

    .header-right { display:flex; align-items:center; gap:1.5rem; }

    .header-icon {
      position: relative;
      width:40px; height:40px;
      display:flex;
      align-items:center;
      justify-content:center;
      background: var(--border-color);
      border-radius: 0.5rem;
      cursor:pointer;
      transition: all .3s ease;
    }

    .header-icon:hover {
      background: var(--primary-color);
      color:#fff;
      transform: translateY(-2px);
      box-shadow: var(--shadow-md);
    }

    .badge-notification {
      position:absolute;
      top:-5px; right:-5px;
      background: var(--danger-color);
      color:#fff;
      width:18px; height:18px;
      border-radius: 50%;
      font-size: 0.625rem;
      display:flex;
      align-items:center;
      justify-content:center;
      font-weight:700;
    }

    .user-profile {
      display:flex;
      align-items:center;
      gap:0.75rem;
      padding: 0.5rem 1rem;
      background: var(--border-color);
      border-radius: 2rem;
      cursor:pointer;
      transition: all .3s ease;
    }

    .user-profile:hover {
      background: var(--primary-color);
      color:#fff;
      transform: translateY(-2px);
      box-shadow: var(--shadow-md);
    }

    .user-photo {
      width:40px; height:40px;
      border-radius:50%;
      object-fit: cover;
      border:2px solid #fff;
    }

    .user-name { font-weight:600; font-size:0.875rem; line-height:1.2; }
    .user-role { font-size:0.75rem; opacity:0.8; }

    /* Page cards */
    .page-card {
      background:#fff;
      border-radius: 1rem;
      box-shadow: var(--shadow-md);
      padding: 1.5rem;
      margin-bottom: 1.5rem;
    }
    .page-card h2 {
      font-size: 1.25rem;
      font-weight: 700;
      margin-bottom: 1rem;
      display:flex;
      align-items:center;
      gap:0.5rem;
    }

    /* Inputs */
    .field-label {
      font-weight: 600;
      font-size: 0.85rem;
      color: var(--text-secondary);
      margin-bottom: .4rem;
    }
    .field-input {
      border-radius: 0.75rem;
      border: 1px solid var(--border-color);
      height: 44px;
      font-weight: 600;
    }
    .field-input:focus{
      border-color: rgba(99,102,241,0.7);
      box-shadow: 0 0 0 .2rem rgba(99,102,241,0.15);
    }

    .btn-add {
      height: 46px;
      border-radius: 0.75rem;
      font-weight: 700;
      border: 0;
      background: linear-gradient(90deg, var(--primary-color), var(--secondary-color));
      color:#fff;
    }

    /* Table */
    .table thead th{
      background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
      color:#fff;
      border:0 !important;
      font-size: 0.8rem;
      text-transform: uppercase;
      letter-spacing: .5px;
      padding: 14px 12px !important;
      white-space: nowrap;
    }
    .table tbody td{
      border-color: rgba(15,23,42,0.08) !important;
      padding: 14px 12px !important;
      font-weight: 600;
      color: rgba(15,23,42,0.85);
      vertical-align: middle;
    }
    .table tbody tr:hover{ background: rgba(99,102,241,0.06); }

    .badge-role{
      font-weight: 700;
      border-radius: 999px;
      padding: 6px 10px;
      font-size: 12px;
      border: 1px solid rgba(15,23,42,0.10);
      background: rgba(59,130,246,0.10);
      color:#1e40af;
      white-space: nowrap;
    }
    .badge-active{
      background: rgba(16,185,129,0.12);
      color: #065f46;
      border-color: rgba(16,185,129,0.25);
    }
    .badge-inactive{
      background: rgba(239,68,68,0.12);
      color: #991b1b;
      border-color: rgba(239,68,68,0.25);
    }

    .btn-icon{
      width: 38px; height: 38px;
      border-radius: 0.75rem;
      display:inline-flex;
      align-items:center;
      justify-content:center;
      border: 1px solid rgba(15,23,42,0.10);
      background:#fff;
      color: rgba(15,23,42,0.75);
      transition: transform .12s ease, background .12s ease, color .12s ease;
      text-decoration:none;
    }
    .btn-icon:hover{ transform: translateY(-1px); }
    .btn-del:hover{ background: rgba(239,68,68,0.12); color:#991b1b; }

    .filter-row{
      display:flex;
      gap: 0.75rem;
      flex-wrap: wrap;
      align-items: center;
      justify-content: flex-end;
    }
    .search-wrap{ position: relative; min-width: 260px; flex:1; }
    .search-wrap i{
      position:absolute;
      left: 12px;
      top: 50%;
      transform: translateY(-50%);
      opacity: 0.6;
    }
    .search-input{
      width:100%;
      height: 44px;
      border-radius: 0.75rem;
      border: 1px solid var(--border-color);
      padding-left: 40px;
      padding-right: 12px;
      font-weight: 600;
      box-shadow: none;
    }
    .pill{
      border-radius: 999px;
      padding: 8px 12px;
      border: 1px solid var(--border-color);
      font-weight: 600;
      height: 44px;
      background: #fff;
    }

    @media (max-width: 768px){
      .sidebar { transform: translateX(-100%); }
      .sidebar-toggle { display:block; }
      .main-content { margin-left: 0; padding: 1rem; }
      .top-header { flex-direction: column; align-items: flex-start; }
      .user-info { display:none; }
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
      <li><a href="<%= ctx %>/Views/manager.jsp">
        <i class="bi bi-grid-1x2-fill"></i> Dashboard</a></li>

      <li><a href="<%= ctx %>/RoomServlet">
        <i class="bi bi-door-open-fill"></i> Rooms</a></li>

      <li><a class="active" href="<%= ctx %>/EmployeeServlet">
        <i class="bi bi-person-badge-fill"></i> Employee Management</a></li>

      <li><a href="<%= ctx %>/ManagerReportsServlet">
        <i class="bi bi-bar-chart-fill"></i> Reports</a></li>

      <li><a href="<%= ctx %>/LogoutServlet">
        <i class="bi bi-box-arrow-right"></i> Logout</a></li>
    </ul>
  </aside>

  <!-- Main -->
  <main class="main-content">

    <!-- Top Header-->
    <div class="top-header">
      <div class="header-left">
        <h1>Employee Management</h1>
        <div class="login-time">
          <i class="bi bi-clock-fill"></i>
          <span id="currentDateTime">-</span>
        </div>
      </div>

      <div class="header-right">
        <div class="header-icon" title="Settings">
          <i class="bi bi-gear-fill"></i>
        </div>
        <div class="header-icon" title="Notifications">
          <i class="bi bi-bell-fill"></i>
          <span class="badge-notification">5</span>
        </div>
        <div class="user-profile" title="Profile">
          <img src="https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop" alt="Admin" class="user-photo">
          <div class="user-info">
            <div class="user-name"><%= adminName %></div>
            <div class="user-role"><%= adminRole %></div>
          </div>
        </div>
      </div>
    </div>

    <!-- Add Employee -->
    <div class="page-card">
      <h2><i class="bi bi-person-plus-fill"></i> Add Employee</h2>

      <form id="addEmployeeForm" class="row g-3" novalidate
            action="<%= ctx %>/EmployeeServlet?action=add" method="POST">

        <div class="col-12 col-md-6">
          <label class="field-label">Email (Username)</label>
          <input type="email" class="form-control field-input" name="email"
                 placeholder="employee@oceanview.com" required>
          <div class="invalid-feedback fw-bold">Enter a valid email.</div>
        </div>

        <div class="col-12 col-md-6">
          <label class="field-label">Password</label>
          <input type="text" class="form-control field-input" name="password"
                 placeholder="e.g. emp123" required>
          <div class="invalid-feedback fw-bold">Password is required.</div>
        </div>

        <div class="col-12 col-md-6">
          <label class="field-label">Full Name</label>
          <input type="text" class="form-control field-input" name="fullName"
                 placeholder="e.g. Emily Silva" required>
          <div class="invalid-feedback fw-bold">Full name is required.</div>
        </div>

        <div class="col-12 col-md-3">
          <label class="field-label">Role</label>
          <select class="form-select field-input" name="role" required>
            <option value="" selected disabled>Select role</option>
            <option>RECEPTIONIST</option>
            <option>HOUSEKEEPING</option>
            <option>FRONT_OFFICE</option>
            <option>CONCIERGE</option>
            <option>MAINTENANCE</option>
            <option>SECURITY</option>
            <option>ACCOUNTANT</option>
            <option>CHEF</option>
            <option>WAITER</option>
          </select>
          <div class="invalid-feedback fw-bold">Select a role.</div>
        </div>

        <div class="col-12 col-md-3">
          <label class="field-label">Phone</label>
          <input type="text" class="form-control field-input" name="phone" placeholder="07X XXX XXXX">
        </div>

        <div class="col-12 col-md-3">
          <label class="field-label">Active</label>
          <select class="form-select field-input" name="isActive">
            <option value="1" selected>Yes</option>
            <option value="0">No</option>
          </select>
        </div>

        <div class="col-12 col-md-9 d-flex align-items-end gap-2 justify-content-end">
          <button type="reset" class="btn btn-outline-secondary fw-bold" style="border-radius:0.75rem;height:46px;">
            Clear
          </button>
          <button type="submit" class="btn btn-add px-4">
            <i class="bi bi-plus-lg me-1"></i> Add Employee
          </button>
        </div>
      </form>

      <%
        String err = (String) request.getAttribute("err");
        if (err != null) {
      %>
        <div class="alert alert-danger mt-3 fw-bold"><%= err %></div>
      <%
        }
      %>
    </div>

    <!-- Employee List -->
    <div class="page-card">
      <div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-3">
        <h2 class="mb-0"><i class="bi bi-people-fill"></i> Employee List</h2>

        <div class="filter-row" style="flex:1;">
          <div class="search-wrap">
            <i class="bi bi-search"></i>
            <input id="searchInput" class="search-input" type="text" placeholder="Search name / email / phone..." />
          </div>

          <select id="roleFilter" class="pill">
            <option value="ALL" selected>All Roles</option>
            <option>MANAGER</option>
            <option>RECEPTIONIST</option>
            <option>HOUSEKEEPING</option>
            <option>FRONT_OFFICE</option>
            <option>CONCIERGE</option>
            <option>MAINTENANCE</option>
            <option>SECURITY</option>
            <option>ACCOUNTANT</option>
            <option>CHEF</option>
            <option>WAITER</option>
          </select>

          <select id="activeFilter" class="pill">
            <option value="ALL" selected>All Status</option>
            <option value="ACTIVE">Active</option>
            <option value="INACTIVE">Inactive</option>
          </select>

          <span class="pill" style="display:inline-flex;align-items:center;gap:8px;">
            <i class="bi bi-people"></i> <span id="countTxt">0</span>
          </span>
        </div>
      </div>

      <div class="table-responsive">
        <table class="table align-middle">
          <thead>
            <tr>
              <th>Email</th>
              <th>Password</th>
              <th>Role</th>
              <th>Full Name</th>
              <th>Phone</th>
              <th>Status</th>
              <th>Created</th>
              <th class="text-end">Actions</th>
            </tr>
          </thead>

          <tbody id="empTbody">
          <%
            if (employees == null || employees.isEmpty()) {
          %>
            <tr class="emp-row-empty">
              <td colspan="8" class="text-center py-4 text-secondary fw-bold">No employees found.</td>
            </tr>
          <%
            } else {
              for (User emp : employees) {
                String phone = (emp.getPhone()==null || emp.getPhone().trim().isEmpty()) ? "-" : emp.getPhone();
                String statusTxt = emp.isActive() ? "Active" : "Inactive";
                String statusClass = emp.isActive() ? "badge-active" : "badge-inactive";
                String roleTxt = (emp.getRole()==null) ? "-" : emp.getRole();
          %>
            <tr class="emp-row"
                data-email="<%= emp.getEmail() %>"
                data-name="<%= emp.getFullName() %>"
                data-phone="<%= phone %>"
                data-role="<%= roleTxt %>"
                data-status="<%= emp.isActive() ? "ACTIVE" : "INACTIVE" %>">

              <td class="fw-bold"><%= emp.getEmail() %></td>
              <td><span class="text-muted fw-bold"><%= emp.getPassword() %></span></td>
              <td><span class="badge-role"><%= roleTxt %></span></td>
              <td class="fw-bold"><%= emp.getFullName() %></td>
              <td><%= phone %></td>
              <td><span class="badge-role <%= statusClass %>"><%= statusTxt %></span></td>
              <td><span class="text-muted fw-bold"><%= emp.getCreatedAt() %></span></td>

              <td class="text-end">
                <a class="btn-icon btn-del"
                   href="<%= ctx %>/EmployeeServlet?action=delete&id=<%= emp.getUserId() %>"
                   onclick="return confirm('Delete this employee?');"
                   title="Delete">
                  <i class="bi bi-trash3"></i>
                </a>
              </td>
            </tr>
          <%
              }
            }
          %>
          </tbody>
        </table>

        <div id="emptyState" class="text-center py-4 text-secondary fw-bold d-none">
          No employees match your filters.
        </div>
      </div>
    </div>

  </main>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

  <script>
    function toggleSidebar() {
      const sidebar = document.getElementById('sidebar');
      sidebar.classList.toggle('open');
    }

    document.addEventListener('click', function(event) {
      const sidebar = document.getElementById('sidebar');
      const toggleBtn = document.querySelector('.sidebar-toggle');
      if (window.innerWidth <= 768) {
        if (!sidebar.contains(event.target) && !toggleBtn.contains(event.target)) {
          sidebar.classList.remove('open');
        }
      }
    });

    function updateDateTime() {
      const now = new Date();
      const options = { weekday:'long', year:'numeric', month:'long', day:'numeric', hour:'2-digit', minute:'2-digit' };
      document.getElementById('currentDateTime').textContent = now.toLocaleDateString('en-US', options);
    }
    updateDateTime();
    setInterval(updateDateTime, 60000);

    const searchInput = document.getElementById("searchInput");
    const roleFilter = document.getElementById("roleFilter");
    const activeFilter = document.getElementById("activeFilter");
    const countTxt = document.getElementById("countTxt");
    const emptyState = document.getElementById("emptyState");

    function applyFilters(){
      const q = (searchInput.value || "").trim().toLowerCase();
      const r = roleFilter.value;
      const s = activeFilter.value;

      const rows = Array.from(document.querySelectorAll(".emp-row"));
      let visibleCount = 0;

      rows.forEach(row => {
        const email = (row.dataset.email || "").toLowerCase();
        const name  = (row.dataset.name || "").toLowerCase();
        const phone = (row.dataset.phone || "").toLowerCase();
        const role  = (row.dataset.role || "");
        const status = (row.dataset.status || "");

        const textMatch = !q || (email.includes(q) || name.includes(q) || phone.includes(q));
        const roleMatch = (r === "ALL") || (role === r);
        const statusMatch = (s === "ALL") || (status === s);

        const show = textMatch && roleMatch && statusMatch;
        row.classList.toggle("d-none", !show);
        if (show) visibleCount++;
      });

      countTxt.textContent = visibleCount + " Employees";
      if (rows.length > 0 && visibleCount === 0) emptyState.classList.remove("d-none");
      else emptyState.classList.add("d-none");
    }

    applyFilters();
    searchInput.addEventListener("input", applyFilters);
    roleFilter.addEventListener("change", applyFilters);
    activeFilter.addEventListener("change", applyFilters);

    document.getElementById("addEmployeeForm").addEventListener("submit", (e) => {
      const form = e.target;
      if(!form.checkValidity()){
        e.preventDefault();
        e.stopPropagation();
        form.classList.add("was-validated");
      }
    });
  </script>

</body>
</html>