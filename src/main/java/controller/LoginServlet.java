package controller;

import dao.UserDAO;
import dao.GuestDAO;
import model.User;
import model.Guest;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.regex.Pattern;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private UserDAO userDAO;
    private GuestDAO guestDAO;

    // email validation
    private static final Pattern EMAIL_PATTERN =
            Pattern.compile("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$");

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
        guestDAO = new GuestDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("username");  // email for all users
        String password = request.getParameter("password");

        email = (email == null) ? "" : email.trim();
        password = (password == null) ? "" : password.trim();

        // basic validation
        if (email.isEmpty() || password.isEmpty()) {
            request.setAttribute("error", "Please enter email and password.");
            request.getRequestDispatcher("/Views/login.jsp").forward(request, response);
            return;
        }

        if (!EMAIL_PATTERN.matcher(email).matches()) {
            request.setAttribute("error", "Please enter a valid email address.");
            request.getRequestDispatcher("/Views/login.jsp").forward(request, response);
            return;
        }

        try {
            User user = userDAO.login(email, password);

            if (user != null) {
                HttpSession session = request.getSession(true);
                session.setAttribute("authType", "STAFF");
                session.setAttribute("userId", user.getUserId());
                session.setAttribute("userEmail", user.getEmail());
                session.setAttribute("userRole", user.getRole());
                session.setAttribute("fullName", user.getFullName());

                if ("MANAGER".equalsIgnoreCase(user.getRole())) {
                    response.sendRedirect(request.getContextPath() + "/Views/manager.jsp");
                    return;
                } else if ("RECEPTIONIST".equalsIgnoreCase(user.getRole())) {
                    response.sendRedirect(request.getContextPath() + "/Views/receptionist.jsp");
                    return;
                } else {
                    session.invalidate();
                    request.setAttribute("error", "Unauthorized staff role.");
                    request.getRequestDispatcher("/Views/login.jsp").forward(request, response);
                    return;
                }
            }

            Guest guest = guestDAO.loginGuest(email, password);

            if (guest != null) {
                HttpSession session = request.getSession(true);
                session.setAttribute("authType", "GUEST");
                session.setAttribute("guestId", guest.getGuestId());
                session.setAttribute("guestEmail", guest.getGuestEmail());

                response.sendRedirect(request.getContextPath() + "/CustomerRoomsServlet");
                return;
            }

            request.setAttribute("error", "Invalid email or password.");
            request.getRequestDispatcher("/Views/login.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Server error: " + e.getMessage());
            request.getRequestDispatcher("/Views/login.jsp").forward(request, response);
        }
    }
}
