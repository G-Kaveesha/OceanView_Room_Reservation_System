<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Ocean View Resort</title>

  <!-- Bootstrap 5 -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <!-- Bootstrap Icons -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">

  <!-- Playfair for the main title (as you used) -->
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@500;700;800;900&display=swap" rel="stylesheet">

<style>
  html, body { height: 100%; margin: 0; }
  body{
    font-family: system-ui, -apple-system, Segoe UI, Roboto, Arial, sans-serif;
    background: #f4f7fb;
  }

  
  html{ scroll-behavior: smooth; }

  
  .hero{
  position: relative;
  width: 100%;
  height: 620px;   /* reduced from 740px */
  overflow: hidden;
  background: #0b5aa6;
}

  .hero-overlay{
    position: absolute;
    inset: 0;
    background: linear-gradient(
      to bottom,
      rgba(0, 95, 150, 0.95) 0%,
      rgba(0, 95, 150, 0.55) 22%,
      rgba(0, 0, 0, 0.05) 55%,
      rgba(0, 0, 0, 0.00) 100%
    );
    z-index: 2;
    pointer-events: none;
  }

  .hero .carousel,
  .hero .carousel-inner,
  .hero .carousel-item{
    height: 100%;
  }

  .hero-slide-img{
    width: 100%;
    height: 100%;
    object-fit: cover;
    filter: saturate(1.05) contrast(1.03);
  }

  .nav-glass{
    position: fixed;
    top: 0; left: 0; right: 0;
    z-index: 99;
    padding: 12px 0;
    transition: box-shadow .2s ease, background .2s ease, padding .2s ease;
    background: rgba(255,255,255,0.14);
    backdrop-filter: blur(14px);
    border-bottom: 1px solid rgba(255,255,255,0.18);
  }
  .nav-glass.scrolled{
    background: rgba(255,255,255,0.85);
    box-shadow: 0 18px 40px rgba(0,0,0,0.10);
    padding: 10px 0;
  }
  .brand-logo { height: 54px; width: 54px; object-fit: contain; }
  .nav-link{
    font-weight: 800;
    color: rgba(255,255,255,0.92) !important;
  }
  .nav-glass.scrolled .nav-link{ color: #0f172a !important; }
  .nav-link.active{ text-decoration: underline; text-underline-offset: 6px; }

  .nav-cta{
    border-radius: 999px;
    font-weight: 900;
    padding: 10px 16px;
  }

  
  .hero-center {
    position:absolute;
    top: 140px;
    left:0; right:0;
    z-index: 3;
    text-align:center;
    padding: 0 16px;
  }
  .hero-welcome { color: rgba(255,255,255,0.90); letter-spacing: 3px; font-weight: 800; font-size: 12px; }
  .hero-title {
    margin-top: 6px;
    color: #fff;
    font-size: 60px;
    font-weight: 900;
    font-family: 'Playfair Display', serif;
    text-shadow: 0 3px 10px rgba(0,0,0,0.25);
  }
  .hero-subtitle{
    margin-top: 14px;
    color: rgba(255,255,255,0.92);
    font-weight: 700;
    max-width: 860px;
    margin-left: auto;
    margin-right: auto;
    line-height: 1.6;
  }

  .hero-left {
    position:absolute;
    left: 80px;
    top: 320px;
    z-index: 3;
    color:#fff;
  }
  .hero-left-text{
    font-family: Georgia, "Times New Roman", Times, serif;
    font-size: 42px;
    font-weight: 650;
    line-height: 1.18;
    text-shadow: 0 3px 10px rgba(0,0,0,0.35);
  }

  .section{
    padding: 88px 0;
    background: #fff;
  }
  .section.alt{ background: #f4f7fb; }
  .section-title{
    font-weight: 950;
    color:#0f172a;
    font-size: 34px;
  }
  .section-sub{
    font-weight: 750;
    color: rgba(15,23,42,0.72);
    max-width: 820px;
  }

  .cardx{
    background:#fff;
    border-radius: 22px;
    box-shadow: 0 18px 45px rgba(0,0,0,0.10);
    border: 1px solid rgba(0,0,0,0.05);
    overflow:hidden;
    transition: transform .15s ease, box-shadow .15s ease;
  }
  .cardx:hover{
    transform: translateY(-3px);
    box-shadow: 0 28px 70px rgba(0,0,0,0.14);
  }
  .pill{
    display:inline-flex;
    gap:8px;
    align-items:center;
    padding: 8px 12px;
    border-radius: 999px;
    font-weight: 900;
    font-size: 12px;
    background: rgba(2,132,199,0.12);
    color: #075985;
    border: 1px solid rgba(2,132,199,0.18);
  }

  .feature-icon{
    width: 52px; height:52px;
    border-radius: 18px;
    display:flex; align-items:center; justify-content:center;
    font-size: 22px;
    background: rgba(99,102,241,0.12);
    color:#3730a3;
  }
  .feature-title{ font-weight: 950; color:#0f172a; }
  .feature-sub{ font-weight: 750; color: rgba(15,23,42,0.70); }

  /* Rooms */
  .room-img{ width:100%; height: 320px; object-fit: cover; border-radius: 18px; }

  /* Gallery */
  .gallery-img{
    width:100%;
    height: 180px;
    object-fit: cover;
    border-radius: 18px;
    cursor: pointer;
    box-shadow: 0 18px 45px rgba(0,0,0,0.12);
    transition: transform .15s ease;
  }
  .gallery-img:hover{ transform: scale(1.01); }

  /* CTA Banner */
  .cta{
    background: linear-gradient(135deg, rgba(2,132,199,0.18), rgba(168,85,247,0.16));
    border-radius: 26px;
    padding: 26px;
    border: 1px solid rgba(0,0,0,0.06);
    box-shadow: 0 22px 55px rgba(0,0,0,0.10);
  }
  .cta-title{ font-weight: 950; color:#0f172a; font-size: 26px; }
  .cta-sub{ font-weight: 800; color: rgba(15,23,42,0.74); }
  .cta-btn{ border-radius: 16px; font-weight: 950; }

  /* Review cards */
  .review-card {
    background: linear-gradient(135deg, #e0f2fe, #d1fae5);
    border-radius: 22px;
    padding: 2.5rem;
    box-shadow: 0 18px 45px rgba(0,0,0,0.08);
  }

  /* Footer */
  .site-footer {
    background: rgb(7, 101, 155);
    color: #ffffff;
    padding-top: 52px;
    padding-bottom: 26px;
  }
  .footer-container { max-width: 1120px; }
  .footer-logo { height: 34px; width: 34px; object-fit: contain; margin-bottom: 20px; }
  .footer-tagline { font-family: Georgia, "Times New Roman", Times, serif; font-weight: 700; margin-bottom: 18px; }
  .footer-social { display:flex; gap: 12px; }
  .social-link{
    width: 38px; height: 38px;
    display:inline-flex; align-items:center; justify-content:center;
    border-radius: 50%;
    background: rgba(255,255,255,0.12);
    color:#fff; text-decoration:none; font-size: 18px;
  }
  .footer-right { display:flex; justify-content:center; }
  .footer-info { width: 360px; }
  .info-item { display:flex; gap: 14px; align-items:center; margin-bottom: 20px; }
  .info-icon{
    width:44px; height:44px; border-radius: 50%;
    background: rgba(255,255,255,0.15);
    display:flex; align-items:center; justify-content:center;
    font-size: 18px;
  }
  .info-title { font-weight: 800; font-size: 13px; margin-bottom: 2px; }
  .info-value { font-size: 13px; opacity: 0.95; }
  .footer-divider { height:2px; background: rgba(255,255,255,0.35); margin-top: 38px; margin-bottom: 18px; }
  .footer-bottom { text-align:center; font-weight: 700; font-size: 14px; }

  .hero .carousel-control-prev,
  .hero .carousel-control-next{
    z-index: 4;
  }

@media (max-width: 991px) {
  .hero { height: 520px; }
    .hero-left { left: 20px; top: 430px; }
    .hero-left-text { font-size: 34px; }
    .hero-title{ font-size: 44px; }
  }
</style>
</head>

<body>

  <!-- Navbar -->
  <nav class="nav-glass">
    <div class="container d-flex align-items-center justify-content-between">
      <a class="d-flex align-items-center gap-2 text-decoration-none" href="<%= request.getContextPath() %>/index.jsp">
        <img src="<%= request.getContextPath() %>/images/logo.png" class="brand-logo" alt="Logo">
        <span class="fw-black" style="font-weight: 950; color: #fff;">Ocean View Resort</span>
      </a>

      <button class="btn btn-light d-lg-none" type="button" data-bs-toggle="offcanvas" data-bs-target="#menuCanvas">
        <i class="bi bi-list"></i>
      </button>

      <div class="d-none d-lg-flex align-items-center gap-3">
        <a class="nav-link" href="#about">About</a>
        <a class="nav-link" href="#rooms">Rooms</a>
        <a class="nav-link" href="#amenities">Amenities</a>
        <a class="nav-link" href="#gallery">Gallery</a>
        <a class="nav-link" href="#reviews">Reviews</a>
        <a class="nav-link" href="#faq">FAQ</a>
        <a href="<%= request.getContextPath() %>/Views/login.jsp" class="btn btn-primary nav-cta">Login</a>
      </div>
    </div>
  </nav>

  <!-- Mobile Offcanvas Menu -->
  <div class="offcanvas offcanvas-end" tabindex="-1" id="menuCanvas">
    <div class="offcanvas-header">
      <h5 class="offcanvas-title fw-bold">Menu</h5>
      <button type="button" class="btn-close" data-bs-dismiss="offcanvas"></button>
    </div>
    <div class="offcanvas-body d-grid gap-2">
      <a class="btn btn-outline-primary" href="#about" data-bs-dismiss="offcanvas">About</a>
      <a class="btn btn-outline-primary" href="#rooms" data-bs-dismiss="offcanvas">Rooms</a>
      <a class="btn btn-outline-primary" href="#amenities" data-bs-dismiss="offcanvas">Amenities</a>
      <a class="btn btn-outline-primary" href="#gallery" data-bs-dismiss="offcanvas">Gallery</a>
      <a class="btn btn-outline-primary" href="#reviews" data-bs-dismiss="offcanvas">Reviews</a>
      <a class="btn btn-outline-primary" href="#faq" data-bs-dismiss="offcanvas">FAQ</a>
      <a class="btn btn-primary" href="<%= request.getContextPath() %>/Views/login.jsp">Login</a>
    </div>
  </div>

  <!-- HERO -->
  <header class="hero">
    <!-- Carousel -->
    <div id="heroCarousel" class="carousel slide carousel-fade" data-bs-ride="carousel" data-bs-interval="4000" data-bs-pause="false" data-bs-touch="true" data-bs-wrap="true">

      <div class="carousel-indicators">
        <button type="button" data-bs-target="#heroCarousel" data-bs-slide-to="0" class="active"></button>
        <button type="button" data-bs-target="#heroCarousel" data-bs-slide-to="1"></button>
        <button type="button" data-bs-target="#heroCarousel" data-bs-slide-to="2"></button>
      </div>

      <div class="carousel-inner">
        <div class="carousel-item active">
          <img class="hero-slide-img" src="<%= request.getContextPath() %>/images/hero.jpg" alt="Ocean View Slide 1">
        </div>
        <div class="carousel-item">
          <img class="hero-slide-img" src="https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=1173&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D" alt="Ocean View Slide 2">
        </div>
        <div class="carousel-item">
          <img class="hero-slide-img" src="https://png.pngtree.com/thumb_back/fh260/background/20240730/pngtree-beach-chairs-with-tropical-maldives-resort-hotel-island-and-sea-background-image_15936080.jpg" alt="Ocean View Slide 3">
        </div>
      </div>

      <button class="carousel-control-prev" type="button" data-bs-target="#heroCarousel" data-bs-slide="prev">
        <span class="carousel-control-prev-icon"></span>
        <span class="visually-hidden">Previous</span>
      </button>
      <button class="carousel-control-next" type="button" data-bs-target="#heroCarousel" data-bs-slide="next">
        <span class="carousel-control-next-icon"></span>
        <span class="visually-hidden">Next</span>
      </button>
    </div>

    <!-- Overlay -->
    <div class="hero-overlay"></div>

    <!-- Text content -->
    <div class="hero-center">
      <div class="hero-welcome">WELCOME TO</div>
      <div class="hero-title">Ocean View Resort</div>
      <div class="hero-subtitle">
        Beachfront comfort in Galle — modern rooms, warm hospitality, and the perfect ocean view for your getaway.
      </div>
    </div>

    
  </header>

  <!-- About -->
  <section id="about" class="section">
    <div class="container">
      <div class="row align-items-center g-5">
        <div class="col-lg-6">
          <div class="pill mb-3"><i class="bi bi-compass"></i> About the Resort</div>
          <div class="section-title mb-2">A peaceful stay by the ocean</div>
          <div class="section-sub mb-4">
            Ocean View Resort is a charming beachside hotel in Galle offering a calm, comfortable, and memorable experience.
          </div>

          <p class="fw-semibold" style="color: rgba(15,23,42,0.80); line-height: 1.9;">
            Ocean View Resort is a charming beachside hotel located in the historic city of Galle.
            Designed for comfort and relaxation, our resort offers beautifully furnished rooms,
            stunning ocean views, and warm Sri Lankan hospitality.
          </p>
          <p class="fw-semibold" style="color: rgba(15,23,42,0.80); line-height: 1.9;">
            We are committed to making every guest’s stay memorable with personalized service,
            modern facilities, and a relaxing coastal atmosphere.
          </p>

          <div class="d-flex gap-2 flex-wrap mt-3">
            <div class="pill"><i class="bi bi-wifi"></i> Free Wi-Fi</div>
            <div class="pill"><i class="bi bi-cup-hot"></i> Breakfast</div>
            <div class="pill"><i class="bi bi-water"></i> Ocean View</div>
          </div>
        </div>

        <div class="col-lg-6 d-flex justify-content-lg-end">
          <div class="cardx" style="width: 380px;">
            <img src="<%= request.getContextPath() %>/images/about.jpg" alt="Resort View" class="w-100" style="height:420px; object-fit:cover;">
          </div>
        </div>
      </div>
    </div>
  </section>

  <!-- Features -->
  <section class="section alt">
    <div class="container">
      <div class="text-center mb-5">
        <div class="pill mb-3"><i class="bi bi-stars"></i> Why Guests Love Us</div>
        <div class="section-title">Modern comfort, local hospitality</div>
        <div class="section-sub mx-auto">Everything you need for a smooth and relaxing stay — thoughtfully designed.</div>
      </div>

      <div class="row g-4">
        <div class="col-md-6 col-lg-3">
          <div class="cardx p-4 h-100">
            <div class="feature-icon mb-3"><i class="bi bi-shield-check"></i></div>
            <div class="feature-title mb-1">Safe & Secure</div>
            <div class="feature-sub">Reception support, secure access, and guest-first service.</div>
          </div>
        </div>
        <div class="col-md-6 col-lg-3">
          <div class="cardx p-4 h-100">
            <div class="feature-icon mb-3"><i class="bi bi-wind"></i></div>
            <div class="feature-title mb-1">AC Rooms</div>
            <div class="feature-sub">Cool, clean, and comfortable rooms with modern essentials.</div>
          </div>
        </div>
        <div class="col-md-6 col-lg-3">
          <div class="cardx p-4 h-100">
            <div class="feature-icon mb-3"><i class="bi bi-geo-alt"></i></div>
            <div class="feature-title mb-1">Prime Location</div>
            <div class="feature-sub">Close to beach, Galle Fort, restaurants, and attractions.</div>
          </div>
        </div>
        <div class="col-md-6 col-lg-3">
          <div class="cardx p-4 h-100">
            <div class="feature-icon mb-3"><i class="bi bi-emoji-smile"></i></div>
            <div class="feature-title mb-1">Friendly Service</div>
            <div class="feature-sub">Warm Sri Lankan hospitality from check-in to check-out.</div>
          </div>
        </div>
      </div>
    </div>
  </section>

  <!-- Rooms -->
  <section id="rooms" class="section">
    <div class="container">
      <div class="text-center mb-5">
        <div class="pill mb-2"><i class="bi bi-door-open"></i> Rooms</div>
        <div class="section-title">Our Rooms</div>
        <div class="section-sub">Stunning ocean-view accommodations</div>
      </div>

      <div class="row g-4">
        <div class="col-md-6 col-lg-4">
          <img class="room-img" src="https://image-tc.galaxy.tf/wijpeg-31fcmteb1c4oowwa1q6wglnl7/15-atelierphotography-20240624-0326-oots-modifier.jpg?width=1920" alt="Deluxe Ocean View Room">
        </div>

        <div class="col-md-6 col-lg-4">
          <img class="room-img" src="https://assets.hyatt.com/content/dam/hyatt/hyattdam/images/2021/06/07/1736/SANJO-P0030-Dreamscape-Living-Room.jpg/SANJO-P0030-Dreamscape-Living-Room.16x9.jpg" alt="Premium Suite">
        </div>

        <div class="col-md-6 col-lg-4">
          <img class="room-img" src="https://lordosbeach.com.cy/wp-content/uploads/2021/04/01-Family-Room-1-1920x1280.jpg" alt="Family Room">
        </div>
      </div>
    </div>
  </section>

  <!-- Amenities -->
  <section id="amenities" class="section alt">
    <div class="container">
      <div class="text-center mb-5">
        <div class="pill mb-3"><i class="bi bi-gem"></i> Amenities</div>
        <div class="section-title">Everything you need, included</div>
        <div class="section-sub mx-auto">Convenient facilities designed for comfort and ease.</div>
      </div>

      <div class="row g-4">
        <div class="col-6 col-md-4 col-lg-3">
          <div class="cardx p-4 text-center h-100">
            <div class="feature-icon mx-auto mb-3"><i class="bi bi-wifi"></i></div>
            <div class="feature-title">Free Wi-Fi</div>
            <div class="feature-sub">Fast connection for work and travel.</div>
          </div>
        </div>
        <div class="col-6 col-md-4 col-lg-3">
          <div class="cardx p-4 text-center h-100">
            <div class="feature-icon mx-auto mb-3"><i class="bi bi-cup-hot"></i></div>
            <div class="feature-title">Breakfast</div>
            <div class="feature-sub">Fresh local and continental options.</div>
          </div>
        </div>
        <div class="col-6 col-md-4 col-lg-3">
          <div class="cardx p-4 text-center h-100">
            <div class="feature-icon mx-auto mb-3"><i class="bi bi-car-front"></i></div>
            <div class="feature-title">Parking</div>
            <div class="feature-sub">Safe and convenient on-site parking.</div>
          </div>
        </div>
        <div class="col-6 col-md-4 col-lg-3">
          <div class="cardx p-4 text-center h-100">
            <div class="feature-icon mx-auto mb-3"><i class="bi bi-water"></i></div>
            <div class="feature-title">Ocean View</div>
            <div class="feature-sub">Relax with breathtaking views.</div>
          </div>
        </div>
      </div>
    </div>
  </section>

  <!-- Reviews -->
  <section id="reviews" class="section">
    <div class="container">
      <div class="text-center mb-5">
        <div class="pill mb-3"><i class="bi bi-chat-quote"></i> Reviews</div>
        <div class="section-title">What our guests say</div>
        <div class="section-sub mx-auto">Real experiences from visitors who stayed with us.</div>
      </div>

      <div id="reviewCarousel" class="carousel slide" data-bs-ride="carousel">
        <div class="carousel-inner">

          <div class="carousel-item active">
            <div class="review-card text-center">
              <div class="fw-bold fs-5" style="color:#0f172a;">“Amazing view and friendly staff!”</div>
              <div class="mt-3 fw-semibold" style="color: rgba(15,23,42,0.80); line-height: 1.8;">
                The rooms were clean, the ocean view was beautiful, and check-in was super smooth. Highly recommended.
              </div>
              <div class="mt-4 d-flex justify-content-center align-items-center gap-2">
                <i class="bi bi-star-fill text-warning"></i><i class="bi bi-star-fill text-warning"></i><i class="bi bi-star-fill text-warning"></i><i class="bi bi-star-fill text-warning"></i><i class="bi bi-star-fill text-warning"></i>
                <span class="ms-2 fw-bold">— Nimal, Sri Lanka</span>
              </div>
            </div>
          </div>

          <div class="carousel-item">
            <div class="review-card text-center">
              <div class="fw-bold fs-5" style="color:#0f172a;">“Perfect family vacation”</div>
              <div class="mt-3 fw-semibold" style="color: rgba(15,23,42,0.80); line-height: 1.8;">
                Great location near Galle Fort and the beach. The family room was spacious and comfortable.
              </div>
              <div class="mt-4 d-flex justify-content-center align-items-center gap-2">
                <i class="bi bi-star-fill text-warning"></i><i class="bi bi-star-fill text-warning"></i><i class="bi bi-star-fill text-warning"></i><i class="bi bi-star-fill text-warning"></i><i class="bi bi-star-half text-warning"></i>
                <span class="ms-2 fw-bold">— Sarah, UK</span>
              </div>
            </div>
          </div>

          <div class="carousel-item">
            <div class="review-card text-center">
              <div class="fw-bold fs-5" style="color:#0f172a;">“Loved the breakfast and calm vibes”</div>
              <div class="mt-3 fw-semibold" style="color: rgba(15,23,42,0.80); line-height: 1.8;">
                Quiet, relaxing, and the staff were always helpful. Great place to recharge.
              </div>
              <div class="mt-4 d-flex justify-content-center align-items-center gap-2">
                <i class="bi bi-star-fill text-warning"></i><i class="bi bi-star-fill text-warning"></i><i class="bi bi-star-fill text-warning"></i><i class="bi bi-star-fill text-warning"></i><i class="bi bi-star-fill text-warning"></i>
                <span class="ms-2 fw-bold">— Akila, Sri Lanka</span>
              </div>
            </div>
          </div>

        </div>

        <button class="carousel-control-prev" type="button" data-bs-target="#reviewCarousel" data-bs-slide="prev">
          <span class="carousel-control-prev-icon"></span>
        </button>
        <button class="carousel-control-next" type="button" data-bs-target="#reviewCarousel" data-bs-slide="next">
          <span class="carousel-control-next-icon"></span>
        </button>
      </div>
    </div>
  </section>

  <!-- Gallery -->
  <section id="gallery" class="section alt">
    <div class="container">
      <div class="d-flex align-items-end justify-content-between flex-wrap gap-2 mb-4">
        <div>
          <div class="pill mb-2"><i class="bi bi-images"></i> Gallery</div>
          <div class="section-title">A glimpse of your stay</div>
          <div class="section-sub">Tap any photo to preview.</div>
        </div>
      </div>

      <div class="row g-4">
        <div class="col-6 col-lg-3">
          <img class="gallery-img"
               src="https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?auto=format&fit=crop&w=1200&q=80"
               alt="Gallery 1">
        </div>

        <div class="col-6 col-lg-3">
          <img class="gallery-img"
               src="https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?auto=format&fit=crop&w=1200&q=80"
               alt="Gallery 2">
        </div>

        <div class="col-6 col-lg-3">
          <img class="gallery-img"
               src="https://images.pexels.com/photos/34777916/pexels-photo-34777916.jpeg"
               alt="Gallery 3">
        </div>

        <div class="col-6 col-lg-3">
          <img class="gallery-img"
               src="https://images.pexels.com/photos/9254154/pexels-photo-9254154.jpeg"
               alt="Gallery 4">
        </div>
      </div>
    </div>
  </section>

  <!-- FAQ -->
  <section id="faq" class="section">
    <div class="container">
      <div class="text-center mb-5">
        <div class="pill mb-3"><i class="bi bi-question-circle"></i> FAQ</div>
        <div class="section-title">Frequently asked questions</div>
        <div class="section-sub mx-auto">Quick answers for common guest questions.</div>
      </div>

      <div class="accordion" id="faqAcc">
        <div class="accordion-item">
          <h2 class="accordion-header">
            <button class="accordion-button fw-bold" type="button" data-bs-toggle="collapse" data-bs-target="#f1">
              What time is check-in and check-out?
            </button>
          </h2>
          <div id="f1" class="accordion-collapse collapse show" data-bs-parent="#faqAcc">
            <div class="accordion-body fw-semibold">
              Check-in starts at <b>2:00 PM</b> and check-out is before <b>12:00 PM</b>. Early check-in depends on availability.
            </div>
          </div>
        </div>

        <div class="accordion-item">
          <h2 class="accordion-header">
            <button class="accordion-button collapsed fw-bold" type="button" data-bs-toggle="collapse" data-bs-target="#f2">
              Do you offer airport pickup?
            </button>
          </h2>
          <div id="f2" class="accordion-collapse collapse" data-bs-parent="#faqAcc">
            <div class="accordion-body fw-semibold">
              Yes, airport pickup can be arranged on request. Please contact reception after booking.
            </div>
          </div>
        </div>

        <div class="accordion-item">
          <h2 class="accordion-header">
            <button class="accordion-button collapsed fw-bold" type="button" data-bs-toggle="collapse" data-bs-target="#f3">
              Is breakfast included?
            </button>
          </h2>
          <div id="f3" class="accordion-collapse collapse" data-bs-parent="#faqAcc">
            <div class="accordion-body fw-semibold">
              Breakfast availability depends on the room package. Some rooms include breakfast by default.
            </div>
          </div>
        </div>
      </div>

      <div class="mt-5">
        <div class="cta d-flex align-items-center justify-content-between flex-wrap gap-3">
          <div>
            <div class="cta-title">Ready for your ocean getaway?</div>
            <div class="cta-sub">Check availability and plan your stay in minutes.</div>
          </div>
          <a href="<%= request.getContextPath() %>/Views/login.jsp" class="btn btn-primary cta-btn">
            <i class="bi bi-door-open"></i> Login to Book
          </a>
        </div>
      </div>
    </div>
  </section>

  <!-- Gallery Modal -->
  <div class="modal fade" id="galleryModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg">
      <div class="modal-content" style="border-radius: 22px; overflow:hidden;">
        <div class="modal-header">
          <h5 class="modal-title fw-bold">Preview</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
        </div>
        <div class="modal-body p-0">
          <img id="galleryModalImg" src="" alt="Preview" style="width:100%; height:auto;">
        </div>
      </div>
    </div>
  </div>

  <!-- FOOTER -->
  <footer class="site-footer">
    <div class="container footer-container">
      <div class="row align-items-start">
        <div class="col-lg-6">
          <img src="<%= request.getContextPath() %>/images/logo.png" alt="Ocean View Resort Logo" class="footer-logo">
          <div class="footer-tagline">Relax. Recharge. Reconnect.</div>

          <div class="footer-social">
            <a href="#" class="social-link" aria-label="Facebook"><i class="bi bi-facebook"></i></a>
            <a href="#" class="social-link" aria-label="Instagram"><i class="bi bi-instagram"></i></a>
          </div>
        </div>

        <div class="col-lg-6 footer-right">
          <div class="footer-info">
            <div class="info-item">
              <div class="info-icon"><i class="bi bi-geo-alt-fill"></i></div>
              <div>
                <div class="info-title">Location</div>
                <div class="info-value">123 Beach Road, Galle, Sri Lanka</div>
              </div>
            </div>

            <div class="info-item">
              <div class="info-icon"><i class="bi bi-telephone-fill"></i></div>
              <div>
                <div class="info-title">Contact Details</div>
                <div class="info-value">+94 91 123 4567</div>
              </div>
            </div>

            <div class="info-item">
              <div class="info-icon"><i class="bi bi-envelope-fill"></i></div>
              <div>
                <div class="info-title">Email</div>
                <div class="info-value">infooceanviewresort@gmail.com</div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="footer-divider"></div>
      <div class="footer-bottom">© 2026 Ocean View Resort. All Rights Reserved.</div>
    </div>
  </footer>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

  <script>
    
    const nav = document.querySelector('.nav-glass');
    const brandText = nav.querySelector('span.fw-black');

    window.addEventListener('scroll', () => {
      const scrolled = window.scrollY > 20;
      nav.classList.toggle('scrolled', scrolled);
      if (brandText) brandText.style.color = scrolled ? '#0f172a' : '#fff';
    });

   
    const sections = ['about','rooms','amenities','gallery','reviews','faq'].map(id => document.getElementById(id));
    const links = Array.from(document.querySelectorAll('.nav-link'));

    function setActiveLink(){
      let current = null;
      sections.forEach(sec => {
        if(!sec) return;
        const top = sec.getBoundingClientRect().top;
        if (top <= 120) current = sec.id;
      });
      links.forEach(a => {
        const href = a.getAttribute('href');
        a.classList.toggle('active', href === ('#' + current));
      });
    }
    window.addEventListener('scroll', setActiveLink);
    setActiveLink();

    const galleryModalEl = document.getElementById('galleryModal');
    const galleryModal = new bootstrap.Modal(galleryModalEl);
    const modalImg = document.getElementById('galleryModalImg');

    document.querySelectorAll('.gallery-img').forEach(img => {
      img.addEventListener('click', () => {
        modalImg.src = img.src;
        galleryModal.show();
      });
    });
  </script>
</body>
</html>
