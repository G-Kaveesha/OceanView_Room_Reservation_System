package controller;

import dao.ReservationDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/ReservationActionServlet")
public class ReservationActionServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String role = (session == null) ? null : (String) session.getAttribute("userRole");

        if (role == null || !"RECEPTIONIST".equalsIgnoreCase(role)) {
            response.sendRedirect(request.getContextPath() + "/Views/login.jsp");
            return;
        }

        String idStr = request.getParameter("id");
        String action = request.getParameter("action");
        if (action == null) action = "";

        int id;
        try {
            id = Integer.parseInt(idStr);
        } catch (Exception e) {
            session.setAttribute("flashMsg", "Invalid reservation id.");
            session.setAttribute("flashType", "warning");
            response.sendRedirect(request.getContextPath() + "/ReceptionistReservationsServlet");
            return;
        }

        try {
            ReservationDAO dao = new ReservationDAO();

            if ("confirm".equalsIgnoreCase(action)) {
                dao.confirmReservation(id);
                session.setAttribute("flashMsg", "Reservation confirmed successfully.");
                session.setAttribute("flashType", "success");
                response.sendRedirect(request.getContextPath() + "/ReceptionistReservationsServlet");
                return;

            } else if ("cancel".equalsIgnoreCase(action)) {
                dao.cancelPendingReservation(id);
                session.setAttribute("flashMsg", "Reservation cancelled and room released.");
                session.setAttribute("flashType", "success");
                response.sendRedirect(request.getContextPath() + "/ReceptionistReservationsServlet");
                return;

            } else if ("checkin".equalsIgnoreCase(action)) {
                dao.checkInConfirmedReservation(id);

                session.setAttribute("flashMsg", "Guest checked-in successfully.");
                session.setAttribute("flashType", "success");

                response.sendRedirect(request.getContextPath()
                        + "/ReservationDetailsServlet?id=" + id + "&success=checkin");
                return;

            } else {
                session.setAttribute("flashMsg", "Unknown action.");
                session.setAttribute("flashType", "warning");
                response.sendRedirect(request.getContextPath() + "/ReceptionistReservationsServlet");
                return;
            }

        } catch (Exception ex) {
            ex.printStackTrace();
            session.setAttribute("flashMsg", "Action failed: " + ex.getMessage());
            session.setAttribute("flashType", "danger");

            if ("checkin".equalsIgnoreCase(action)) {
                response.sendRedirect(request.getContextPath()
                        + "/ReservationDetailsServlet?id=" + id + "&error=1");
            } else {
                response.sendRedirect(request.getContextPath()
                        + "/ReceptionistReservationsServlet");
            }
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.sendRedirect(request.getContextPath() + "/ReceptionistReservationsServlet");
    }
}