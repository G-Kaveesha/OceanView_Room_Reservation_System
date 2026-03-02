package controller;

import dao.ReservationDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.Date;

@WebServlet("/WalkInCheckInServlet")
public class WalkInCheckInServlet extends HttpServlet {

    private final ReservationDAO reservationDAO = new ReservationDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Role guard
        HttpSession session = request.getSession(false);
        String role = (session == null) ? null : (String) session.getAttribute("userRole");
        if (role == null || !"RECEPTIONIST".equalsIgnoreCase(role)) {
            response.sendRedirect(request.getContextPath() + "/Views/login.jsp");
            return;
        }

        
        Integer createdBy = null;
        Object uid = session.getAttribute("userId");
        if (uid instanceof Integer) createdBy = (Integer) uid;

        try {
            int roomId = Integer.parseInt(request.getParameter("roomId"));
            String roomNumber = trim(request.getParameter("roomNumber"));

            String guestName = trim(request.getParameter("guestName"));
            String guestPhone = trim(request.getParameter("guestPhone"));
            String guestEmail = trim(request.getParameter("guestEmail"));
            String guestNicPassport = trim(request.getParameter("guestNicPassport"));

            Date checkInDate = Date.valueOf(request.getParameter("checkInDate"));
            Date checkOutDate = Date.valueOf(request.getParameter("checkOutDate"));

            int numberOfGuests = Integer.parseInt(request.getParameter("numberOfGuests"));
            String specialRequests = trim(request.getParameter("specialRequests"));

            // Basic validations
            if (guestName.isEmpty() || guestPhone.isEmpty()) {
                throw new IllegalArgumentException("Guest name and phone are required.");
            }
            if (!checkOutDate.after(checkInDate)) {
                throw new IllegalArgumentException("Check-out date must be after check-in date.");
            }
            if (numberOfGuests < 1) {
                throw new IllegalArgumentException("Number of guests must be at least 1.");
            }

            int newReservationId = reservationDAO.createWalkInAndCheckIn(
                    roomId,
                    roomNumber,
                    guestName,
                    guestPhone,
                    guestEmail,
                    guestNicPassport,
                    checkInDate,
                    checkOutDate,
                    numberOfGuests,
                    specialRequests,
                    createdBy
            );

            response.sendRedirect(request.getContextPath() + "/ReceptionistRoomServlet?success=1&rid=" + newReservationId);

        } catch (IllegalArgumentException ex) {
            
            response.sendRedirect(request.getContextPath() + "/ReceptionistRoomServlet?error=" + urlEnc(ex.getMessage()));
        } catch (Exception ex) {
            throw new ServletException(ex);
        }
    }

    private String trim(String s) {
        return (s == null) ? "" : s.trim();
    }

    private String urlEnc(String s) {
        try {
            return java.net.URLEncoder.encode(s, java.nio.charset.StandardCharsets.UTF_8);
        } catch (Exception e) {
            return "error";
        }
    }
}