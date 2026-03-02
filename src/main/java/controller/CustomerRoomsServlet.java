package controller;

import dao.RoomDAO;
import dao.ReservationDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Room;
import model.ReservationRequest;

import java.io.IOException;
import java.sql.Date;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/CustomerRoomsServlet")
public class CustomerRoomsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        
        // Auth guard: only GUEST
        HttpSession session = request.getSession(false);
        String authType = (session == null) ? null : (String) session.getAttribute("authType");
        String guestEmail = (session == null) ? null : (String) session.getAttribute("guestEmail");

        if (authType == null || !"GUEST".equalsIgnoreCase(authType) ||
                guestEmail == null || guestEmail.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/Views/login.jsp");
            return;
        }

       
        // Read date range from query
        
        String ciStr = request.getParameter("check_in_date");
        String coStr = request.getParameter("check_out_date");

        LocalDate today = LocalDate.now();
        LocalDate checkInLd;
        LocalDate checkOutLd;

        try {
            checkInLd = (ciStr == null || ciStr.isBlank()) ? today : LocalDate.parse(ciStr);
        } catch (Exception e) {
            checkInLd = today;
        }

        try {
            checkOutLd = (coStr == null || coStr.isBlank()) ? today.plusDays(1) : LocalDate.parse(coStr);
        } catch (Exception e) {
            checkOutLd = today.plusDays(1);
        }

        // Validation
        if (!checkOutLd.isAfter(checkInLd)) {
            checkOutLd = checkInLd.plusDays(1);
        }

        request.setAttribute("selectedCheckIn", checkInLd.toString());
        request.setAttribute("selectedCheckOut", checkOutLd.toString());

    
        // Load page data
        
        try {
            RoomDAO roomDAO = new RoomDAO();

            
            List<Room> availableRooms = roomDAO.getAvailableRoomsForDates(
                    Date.valueOf(checkInLd),
                    Date.valueOf(checkOutLd)
            );
            request.setAttribute("availableRooms", availableRooms);

            ReservationDAO reservationDAO = new ReservationDAO();
            List<ReservationRequest> myReservations =
                    reservationDAO.getReservationsByGuestEmail(guestEmail.trim());

            if (myReservations == null) myReservations = new ArrayList<>();
            request.setAttribute("myReservations", myReservations);

            request.getRequestDispatcher("/Views/customer.jsp").forward(request, response);

        } catch (Exception ex) {
            ex.printStackTrace();

            request.setAttribute("availableRooms", new ArrayList<Room>());
            request.setAttribute("myReservations", new ArrayList<ReservationRequest>());
            request.setAttribute("errorMsg", "Failed to load customer data. Please try again.");
            request.getRequestDispatcher("/Views/customer.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}