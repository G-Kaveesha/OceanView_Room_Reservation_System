package controller;

import dao.ReservationDAO;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.Date;
import java.time.LocalDate;

@WebServlet("/CheckAvailabilityServlet")
public class CheckAvailabilityServlet extends HttpServlet {

  @Override
  protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
    response.setContentType("application/json");

    try {
      int roomId = Integer.parseInt(request.getParameter("room_id"));
      LocalDate ci = LocalDate.parse(request.getParameter("check_in_date"));
      LocalDate co = LocalDate.parse(request.getParameter("check_out_date"));

      ReservationDAO dao = new ReservationDAO();
      boolean ok = dao.isRoomAvailable(roomId, Date.valueOf(ci), Date.valueOf(co));

      response.getWriter().write("{\"available\":" + ok + "}");
    } catch (Exception e) {
      response.getWriter().write("{\"available\":false}");
    }
  }
}