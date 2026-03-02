<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String error = (String) request.getAttribute("error");
    String success = (String) request.getAttribute("success");
    String emailValue = request.getParameter("email") != null ? request.getParameter("email") : "";
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Ocean View Resort - Register</title>

  <!-- Bootstrap 5 -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

  <style>
    :root{
      --ovr-blue-1:#0aa7c6;
      --ovr-blue-2:#0b5aa6;
      --ovr-ink:#111;
    }

    *{ box-sizing:border-box; }

    html, body{
      height:100%;
      margin:0;
      overflow:hidden;
    }

    body{
      font-family: "Segoe UI", system-ui, -apple-system, Arial, sans-serif;
      color: var(--ovr-ink);
    }

    .auth-hero{
      height:100vh;
      width:100vw;
      display:flex;
      align-items:center;
      justify-content:center;
      position:relative;
      background:
        linear-gradient(180deg, rgba(0,90,160,.55), rgba(0,0,0,.55)),
        url("<%= request.getContextPath() %>/images/bg.png") center/cover no-repeat;
    }

    .auth-hero-overlay{
      position:absolute;
      inset:0;
      background: linear-gradient(180deg, rgba(0, 120, 180, .35), rgba(0,0,0,.45));
      pointer-events:none;
    }

    .auth-wrap{
      position:relative;
      width:100%;
      height:100%;
      padding: 24px;
      display:flex;
      align-items:center;
      justify-content:center;
    }

    .auth-card{
      width: min(1400px, calc(100vw - 48px));
      height: min(720px, calc(100vh - 48px));
      display:flex;
      border-radius: 28px;
      overflow:hidden;
      box-shadow: 0 22px 60px rgba(0,0,0,.35);
      background: rgba(255,255,255,.08);
    }

    .auth-left{
      width: 55%;
      height:100%;
      position:relative;
    }

    .auth-left-img{
      width:100%;
      height:100%;
      object-fit:cover;
      display:block;
      filter: saturate(1.05) contrast(1.05);
    }

    .auth-right{
      width:45%;
      height:100%;
      background: rgba(255,255,255,.08);
    }

    .glass{
      height:100%;
      padding: 48px 46px;
      background: rgba(255,255,255,.35);
      backdrop-filter: blur(10px);
      border-left: 1px solid rgba(255,255,255,.45);
      border-top: 1px solid rgba(255,255,255,.35);
      overflow:hidden;
      display:flex;
      flex-direction:column;
      justify-content:center;
    }

    .brand-title{
      font-family: "Georgia", "Times New Roman", serif;
      text-align:center;
      font-size: 34px;
      margin:0;
      font-weight: 700;
      color:#111;
    }

    .brand-subtitle{
      text-align:center;
      margin-top: 10px;
      letter-spacing: 2.5px;
      font-size: 12px;
      color: rgba(0,0,0,.65);
    }

    .form-label-ovr{
      font-weight: 600;
      letter-spacing: .4px;
      color: rgba(0,0,0,.75);
      margin-bottom: 8px;
    }

    .ovr-input{
      height: 44px;
      border-radius: 12px;
      border: 2px solid rgba(0,0,0,.45);
      background: rgba(255,255,255,.18);
      backdrop-filter: blur(6px);
      box-shadow: inset 0 1px 0 rgba(255,255,255,.4);
    }

    .ovr-input:focus{
      border-color: rgba(0,0,0,.70);
      box-shadow: 0 0 0 .2rem rgba(10,167,198,.18);
      background: rgba(255,255,255,.22);
    }

    .btn-ovr{
      height: 52px;
      border-radius: 14px;
      font-weight: 700;
      font-size: 18px;
      color: #fff;
      border: 0;
      background: linear-gradient(180deg, #17d7c6, #0aa7c6 45%, #0a7fd0);
      box-shadow: 0 10px 22px rgba(0, 140, 200, .35),
                  inset 0 1px 0 rgba(255,255,255,.35);
    }

    .btn-ovr:hover{ filter: brightness(1.03); transform: translateY(-1px); }
    .btn-ovr:active{ transform: translateY(0px); }

    .terms-text{ font-size: 14px; color: rgba(0,0,0,.72); }
    .have-account{ font-weight: 600; color: rgba(0,0,0,.65); }

    .link-ovr{
      font-weight: 800;
      color: #0a7fd0;
      text-decoration: none;
    }
    .link-ovr:hover{ text-decoration: underline; }

    @media (max-width: 992px){
      html, body{ overflow:auto; }
      .auth-card{ flex-direction: column; height: auto; max-height: none; }
      .auth-left, .auth-right{ width:100%; }
      .auth-left{ height: 320px; }
      .glass{ padding: 34px 22px; }
      .auth-wrap{ padding:16px; }
    }
  </style>
</head>

<body>
  <section class="auth-hero">
    <div class="auth-hero-overlay"></div>

    <div class="auth-wrap">
      <div class="auth-card">

        <!-- LEFT IMAGE -->
        <div class="auth-left">
          <img
            src="https://i.pinimg.com/736x/5d/43/e0/5d43e0ff7cb8bae7920c5d0ec4a9c5f3.jpg"
            alt="Relax"
            class="auth-left-img"
          />
        </div>

        <div class="auth-right">
          <div class="glass">
            <div>
              <h1 class="brand-title">Ocean View Resort</h1>
              <p class="brand-subtitle">HOTEL RESERVATION SYSTEM</p>
            </div>

            <!-- alerts -->
            <% if (error != null) { %>
              <div class="alert alert-danger mt-3 mb-0"><%= error %></div>
            <% } %>
            <% if (success != null) { %>
              <div class="alert alert-success mt-3 mb-0"><%= success %></div>
            <% } %>

            <form class="mt-4" action="<%= request.getContextPath() %>/register" method="post">
              <div class="mb-3">
                <label class="form-label form-label-ovr" for="email">Email</label>
                <input type="email" id="email" name="email" class="form-control ovr-input"
                       value="<%= emailValue %>" required>
              </div>

              <div class="mb-3">
                <label class="form-label form-label-ovr" for="password">Password</label>
                <input type="password" id="password" name="password" class="form-control ovr-input" required>
              </div>

              <div class="mb-3">
                <label class="form-label form-label-ovr" for="confirmPassword">Confirm Password</label>
                <input type="password" id="confirmPassword" name="confirmPassword" class="form-control ovr-input" required>
              </div>

              <button type="submit" class="btn btn-ovr w-100 mt-2">Sign Up</button>

              <div class="d-flex align-items-start gap-2 mt-3">
                <input class="form-check-input mt-1" type="checkbox" id="terms" required>
                <label class="form-check-label terms-text" for="terms">
                  I agree to the terms &amp; Conditions
                </label>
              </div>

              <div class="mt-3 text-center have-account">
                Already Have an Account?
                <a href="<%= request.getContextPath() %>/Views/login.jsp" class="link-ovr ms-2">Login</a>
              </div>
            </form>

          </div>
        </div>

      </div>
    </div>
  </section>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
