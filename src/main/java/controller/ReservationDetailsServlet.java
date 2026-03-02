package controller;

import dao.ReservationDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.ReservationRequest;

import java.io.IOException;

@WebServlet("/ReservationDetailsServlet")
public class ReservationDetailsServlet extends HttpServlet {

    private static final String LOGIN_PAGE = "/Views/login.jsp";
    private static final String LIST_URL    = "/ReceptionistReservationsServlet";
    private static final String VIEW_JSP    = "/Views/receptionist/reservation_details.jsp";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        // Role guard: only RECEPTIONIST
        String role = (session == null) ? null : (String) session.getAttribute("userRole");
        if (role == null || !"RECEPTIONIST".equalsIgnoreCase(role)) {
            response.sendRedirect(request.getContextPath() + LOGIN_PAGE);
            return;
        }

        // Validate id
        int id = parseIntOrMinusOne(request.getParameter("id"));
        if (id <= 0) {
            session.setAttribute("flashMsg", "Invalid reservation id.");
            session.setAttribute("flashType", "warning");
            response.sendRedirect(request.getContextPath() + LIST_URL);
            return;
        }

        try {
            ReservationDAO dao = new ReservationDAO();
            ReservationRequest res = dao.getReservationById(id);

            if (res == null) {
                session.setAttribute("flashMsg", "Reservation not found.");
                session.setAttribute("flashType", "warning");
                response.sendRedirect(request.getContextPath() + LIST_URL);
                return;
            }

            
            request.setAttribute("reservation", res);

            
            String success = request.getParameter("success");
            if ("checkin".equalsIgnoreCase(success)) {
                request.setAttribute("successMsg", "Guest checked-in successfully.");
            }

            request.getRequestDispatcher(VIEW_JSP).forward(request, response);

        } catch (Exception ex) {
            ex.printStackTrace();
            session.setAttribute("flashMsg", "Failed to load reservation details.");
            session.setAttribute("flashType", "danger");
            response.sendRedirect(request.getContextPath() + LIST_URL);
        }
    }

    private int parseIntOrMinusOne(String s) {
        try {
            return Integer.parseInt(s);
        } catch (Exception e) {
            return -1;
        }
    }
}