package controller;

import dao.GuestDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import model.GuestSummary;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/ReceptionistGuestsServlet")
public class ReceptionistGuestsServlet extends HttpServlet {

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
            GuestDAO dao = new GuestDAO();
            List<GuestSummary> guestList = dao.getGuestSummariesFromReservations();
            if (guestList == null) guestList = new ArrayList<>();

            request.setAttribute("guestList", guestList);
            request.getRequestDispatcher("/Views/receptionist/guest.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("guestList", new ArrayList<>());
            request.setAttribute("errorMsg", "Failed to load guest list.");
            request.getRequestDispatcher("/Views/receptionist/guest.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}