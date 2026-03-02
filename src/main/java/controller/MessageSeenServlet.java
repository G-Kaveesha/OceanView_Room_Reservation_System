package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.Timestamp;

@WebServlet("/MessageSeenServlet")
public class MessageSeenServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session != null) {
            session.setAttribute("msgLastSeen", new Timestamp(System.currentTimeMillis()));
        }

        response.setStatus(HttpServletResponse.SC_NO_CONTENT);
    }
}