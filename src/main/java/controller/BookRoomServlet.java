package controller;

import dao.ReservationDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Date;
import java.time.LocalDate;

@WebServlet("/BookRoomServlet")
public class BookRoomServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String authType = (session == null) ? null : (String) session.getAttribute("authType");
        String guestEmailSession = (session == null) ? null : (String) session.getAttribute("guestEmail");

        if (authType == null || !"GUEST".equalsIgnoreCase(authType) || guestEmailSession == null) {
            response.sendRedirect(request.getContextPath() + "/Views/login.jsp");
            return;
        }

        try {
        	
            // Read & validate inputs
           
            int roomId = parseIntRequired(request.getParameter("room_id"), "Room ID");
            String roomNumber = trimToNull(request.getParameter("room_number"));

            String guestName = trimToNull(request.getParameter("guest_name"));
            String guestPhone = trimToNull(request.getParameter("guest_phone"));
            String guestNic = trimToNull(request.getParameter("guest_nic_passport"));
            String special = trimToNull(request.getParameter("special_requests"));

            String guestEmail = guestEmailSession;

            int guests = parseIntRequired(request.getParameter("number_of_guests"), "Number of guests");
            if (guests < 1) throw new IllegalArgumentException("Number of guests must be at least 1.");

            LocalDate ci = LocalDate.parse(request.getParameter("check_in_date"));
            LocalDate co = LocalDate.parse(request.getParameter("check_out_date"));

            if (!co.isAfter(ci)) {
                throw new IllegalArgumentException("Check-out must be after check-in.");
            }

            LocalDate today = LocalDate.now();
            if (ci.isBefore(today)) {
                throw new IllegalArgumentException("Check-in date cannot be in the past.");
            }

            // Create PENDING request 
            ReservationDAO dao = new ReservationDAO();

            int newResId = dao.createPendingReservation(
                    roomId,
                    roomNumber,
                    guestName,
                    guestPhone,
                    guestEmail,
                    guestNic,
                    Date.valueOf(ci),
                    Date.valueOf(co),
                    guests,
                    special,
                    null 
            );

            session.setAttribute("flashMsg", "Reservation request sent to reception. Reservation ID: " + newResId);
            session.setAttribute("flashType", "success");

            response.sendRedirect(request.getContextPath()
                    + "/CustomerRoomsServlet?check_in_date=" + ci + "&check_out_date=" + co);

        } catch (IllegalArgumentException ex) {
            session.setAttribute("flashMsg", ex.getMessage());
            session.setAttribute("flashType", "danger");

            String ci = request.getParameter("check_in_date");
            String co = request.getParameter("check_out_date");
            if (ci == null) ci = "";
            if (co == null) co = "";

            response.sendRedirect(request.getContextPath()
                    + "/CustomerRoomsServlet?check_in_date=" + ci + "&check_out_date=" + co);

        } catch (Exception ex) {
            ex.printStackTrace();
            session.setAttribute("flashMsg", "Booking failed. Please try again.");
            session.setAttribute("flashType", "danger");
            response.sendRedirect(request.getContextPath() + "/CustomerRoomsServlet");
        }
    }

    // Helpers 
    private static String trimToNull(String s) {
        if (s == null) return null;
        String t = s.trim();
        return t.isEmpty() ? null : t;
    }

    private static int parseIntRequired(String s, String fieldName) {
        if (s == null || s.trim().isEmpty()) {
            throw new IllegalArgumentException(fieldName + " is required.");
        }
        try {
            return Integer.parseInt(s.trim());
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException(fieldName + " is invalid.");
        }
    }
}