package controller;

import dao.ReservationDAO;
import model.ReservationRequest;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

@WebServlet("/ReceptionistReservationsServlet")
public class ReceptionistReservationsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String role = (session == null) ? null : (String) session.getAttribute("userRole");

        if (role == null || !"RECEPTIONIST".equalsIgnoreCase(role)) {
            response.sendRedirect(request.getContextPath() + "/Views/login.jsp");
            return;
        }

        try {
            ReservationDAO dao = new ReservationDAO();

            // Notifications 
            List<ReservationRequest> pending = dao.getReservationsByStatus("PENDING");
            request.setAttribute("pendingRequests", pending);
            request.setAttribute("pendingCount", pending == null ? 0 : pending.size());

            // Reservation List table 
            List<ReservationRequest> notPending = dao.getReservationsNotPending();
            request.setAttribute("reservationList", notPending);

            // KPI 
            int confirmedCount = dao.countByStatus("CONFIRMED");
            int checkedInCount = dao.countByStatus("CHECKED_IN");

            request.setAttribute("confirmedCount", confirmedCount);
            request.setAttribute("checkedInCount", checkedInCount);

          
            request.setAttribute("todayCount", 0);

        } catch (Exception ex) {
            ex.printStackTrace();

            request.setAttribute("pendingRequests", null);
            request.setAttribute("pendingCount", 0);

            request.setAttribute("reservationList", null);

            request.setAttribute("confirmedCount", 0);
            request.setAttribute("checkedInCount", 0);
            request.setAttribute("todayCount", 0);

            request.setAttribute("errorMsg", "Failed to load reservations.");
        }

        request.getRequestDispatcher("/Views/receptionist/reservations.jsp").forward(request, response);
    }
}