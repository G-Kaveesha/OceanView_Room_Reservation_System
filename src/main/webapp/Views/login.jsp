<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Ocean View Resort - Login</title>

  <!-- Bootstrap 5 -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <!-- Bootstrap Icons -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">

  <style>
    html, body{
      height: 100%;
      margin: 0;
    }

    /* HERO BACKGROUND */
    .login-hero{
      position: relative;
      width: 100%;
      height: 760px;
      background-image: url("<%= request.getContextPath() %>/images/bg.png");
      background-size: cover;
      background-position: center;
      overflow: hidden;
    }

    /* Overlay */
    .login-hero-overlay{
      position: absolute;
      inset: 0;
      background: linear-gradient(
        to bottom,
        #005f96f2 0%,
        #005f968c 25%,
        #00000026 70%,
        #0000000d 100%
      );
      z-index: 1;
    }
    .top-left-logo{
      position: absolute;
      top: 20px;
      left: 26px;
      z-index: 10; /* IMPORTANT FIX */
    }
    .logo-img{
      height: 80px;
      width: 80px;
      object-fit: contain;
      cursor: pointer;
    }

    .login-card-wrap{
      position: absolute;
      inset: 0;
      display: flex;
      align-items: center;
      justify-content: center;
      z-index: 3;
      pointer-events: none;  /* IMPORTANT FIX */
    }

    .login-card-glass{
      width: 520px;
      height: 540px;
      border-radius: 44px;
      background: rgba(255, 255, 255, 0.45);
      backdrop-filter: blur(10px);
      box-shadow: 0 18px 45px rgba(0,0,0,0.30);
      padding: 52px 64px 38px 64px;
      pointer-events: auto; /* IMPORTANT FIX: card still clickable */
    }

    /* Header */
    .login-card-header{
      text-align: center;
      margin-bottom: 34px;
    }

    .login-title{
      font-size: 24px;
      font-weight: 800;
    }

    .login-subtitle{
      margin-top: 6px;
      font-size: 10px;
      font-weight: 700;
      letter-spacing: 2px;
      opacity: 0.65;
    }

    /* Form */
    .field-label{
      font-weight: 800;
      margin-top: 18px;
      margin-bottom: 8px;
    }

    .field-input{
      height: 42px;
      border-radius: 10px;
      border: 2px solid rgba(0,0,0,0.35);
      background: rgba(255,255,255,0.20);
      box-shadow: 0 10px 18px rgba(0,0,0,0.10);
    }

    /* Login Button */
    .btn-login{
      width: 320px;
      height: 44px;
      margin: 34px auto 0;
      display: block;
      border-radius: 12px;
      font-weight: 800;
      font-size: 18px;
      color: #fff;
      background: linear-gradient(90deg, rgba(0,220,210,0.95), rgba(0,150,255,0.95));
      box-shadow: 0 14px 26px rgba(0,0,0,0.25);
      border: none;
    }

    /* Forgot Password */
    .forgot-wrap{
      text-align: right;
      margin-top: 18px;
    }

    .forgot-link{
      font-weight: 800;
      color: rgba(0,0,0,0.75);
      text-decoration: none;
    }

    /* Footer */
    .site-footer{
      background: rgb(7, 101, 155);
      color: white;
      padding: 52px 0 26px;
    }

    .footer-logo{
      height: 34px;
      margin-bottom: 20px;
    }

    .footer-social{
      display: flex;
      gap: 12px;
    }

    .social-link{
      width: 38px;
      height: 38px;
      background: rgba(255,255,255,0.12);
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      color: white;
      text-decoration: none;
    }

    .footer-divider{
      height: 2px;
      background: rgba(255,255,255,0.35);
      margin: 38px 0 18px;
    }

    .footer-bottom{
      text-align: center;
      font-weight: 700;
    }

     
    .footer-info .info-item{
      display:flex;
      gap:12px;
      margin-bottom:16px;
      align-items:flex-start;
    }
    .footer-info .info-icon{
      font-size:18px;
      line-height:1;
      margin-top:2px;
    }
    .footer-info .info-title{
      font-weight:800;
      opacity:0.9;
    }
    .footer-info .info-value{
      opacity:0.9;
      font-weight:600;
    }
  </style>
</head>

<body>

<!-- HERO / BACKGROUND -->
<section class="login-hero">
  <div class="login-hero-overlay"></div>

  <!-- Logo (Redirects to Home) -->
  <div class="top-left-logo">
    <a href="<%= request.getContextPath() %>/index.jsp">
      <img src="<%= request.getContextPath() %>/images/logo.png"
           alt="Ocean View Resort Logo"
           class="logo-img">
    </a>
  </div>

  <!-- Login Card -->
  <div class="login-card-wrap">
    <div class="login-card-glass">

      <div class="login-card-header">
        <div class="login-title">Ocean View Resort</div>
      </div>

      <form class="login-form" autocomplete="off"
            action="<%= request.getContextPath() %>/LoginServlet" method="POST">

        <label class="field-label">Username</label>
        <input type="text" name="username" class="form-control field-input" required>

        <label class="field-label">Password</label>
        <input type="password" name="password" class="form-control field-input" required>

        <button type="submit" class="btn btn-login">Login</button>

        <div class="forgot-wrap">
        Don't have an account?  <a href="<%= request.getContextPath() %>/Views/register.jsp" class="forgot-link">Sign up</a>
        </div>


        <%
          String error = (String) request.getAttribute("error");
          if (error != null) {
        %>
          <div class="alert alert-danger mt-3" role="alert" style="font-weight:700;">
            <%= error %>
          </div>
        <%
          }
        %>

      </form>

    </div>
  </div>
</section>

<!-- FOOTER -->
<footer class="site-footer">
  <div class="container footer-container">
    <div class="row align-items-start">

      <!-- Left -->
      <div class="col-lg-6 footer-left">
        <img src="<%= request.getContextPath() %>/images/logo.png" class="footer-logo" alt="Ocean View Resort Logo">
        <div class="footer-tagline">Relax. Recharge. Reconnect.</div>

        <div class="footer-social mt-3">
          <a href="#" class="social-link" aria-label="Facebook"><i class="bi bi-facebook"></i></a>
          <a href="#" class="social-link" aria-label="Instagram"><i class="bi bi-instagram"></i></a>
        </div>
      </div>

      <!-- Right -->
      <div class="col-lg-6 footer-right">
        <div class="footer-info">

          <div class="info-item">
            <div class="info-icon"><i class="bi bi-geo-alt-fill"></i></div>
            <div class="info-text">
              <div class="info-title">Location</div>
              <div class="info-value">123 Beach Road, Galle, Sri Lanka</div>
            </div>
          </div>

          <div class="info-item">
            <div class="info-icon"><i class="bi bi-telephone-fill"></i></div>
            <div class="info-text">
              <div class="info-title">Contact Details</div>
              <div class="info-value">+94 91 123 4567</div>
            </div>
          </div>

          <div class="info-item">
            <div class="info-icon"><i class="bi bi-envelope-fill"></i></div>
            <div class="info-text">
              <div class="info-title">Email</div>
              <div class="info-value">infooceanviewresort@gmail.com</div>
            </div>
          </div>

        </div>
      </div>

    </div>

    <div class="footer-divider"></div>

    <div class="footer-bottom">
      © 2026 Ocean View Resort. All Rights Reserved.
    </div>
  </div>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
