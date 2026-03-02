package controller;

import dao.RoomDAO;
import model.Room;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

@WebServlet("/ReceptionistRoomServlet")
public class ReceptionistRoomServlet extends HttpServlet {

    private final RoomDAO roomDAO = new RoomDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // No cache
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        HttpSession session = request.getSession(false);
        String role = (session == null) ? null : (String) session.getAttribute("userRole");

        if (role == null || !"RECEPTIONIST".equalsIgnoreCase(role)) {
            response.sendRedirect(request.getContextPath() + "/Views/login.jsp");
            return;
        }

        try {
            List<Room> rooms = roomDAO.getAllRooms(); 
            request.setAttribute("rooms", rooms);
            request.getRequestDispatcher("/Views/receptionist/room.jsp").forward(request, response);
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}