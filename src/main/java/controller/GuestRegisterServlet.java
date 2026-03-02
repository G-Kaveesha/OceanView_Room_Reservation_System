package controller;

import dao.GuestDAO;
import model.Guest;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.regex.Pattern;

@WebServlet("/register")
public class GuestRegisterServlet extends HttpServlet {

    private final GuestDAO guestDAO = new GuestDAO();

    private static final Pattern EMAIL_PATTERN =
            Pattern.compile("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$");

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String email = req.getParameter("email");
        String password = req.getParameter("password");
        String confirm = req.getParameter("confirmPassword");

        
        email = (email == null) ? "" : email.trim();
        password = (password == null) ? "" : password.trim();
        confirm = (confirm == null) ? "" : confirm.trim();

        //  validations
        if (email.isEmpty() || password.isEmpty() || confirm.isEmpty()) {
            req.setAttribute("error", "All fields are required.");
            req.getRequestDispatcher("/Views/register.jsp").forward(req, resp);
            return;
        }

        if (email.length() > 120) {
            req.setAttribute("error", "Email is too long (max 120 characters).");
            req.getRequestDispatcher("/Views/register.jsp").forward(req, resp);
            return;
        }

        if (!EMAIL_PATTERN.matcher(email).matches()) {
            req.setAttribute("error", "Please enter a valid email address.");
            req.getRequestDispatcher("/Views/register.jsp").forward(req, resp);
            return;
        }

        if (password.length() < 6) {
            req.setAttribute("error", "Password must be at least 6 characters.");
            req.getRequestDispatcher("/Views/register.jsp").forward(req, resp);
            return;
        }

        if (!password.equals(confirm)) {
            req.setAttribute("error", "Passwords do not match.");
            req.getRequestDispatcher("/Views/register.jsp").forward(req, resp);
            return;
        }

        try {
            if (guestDAO.emailExists(email)) {
                req.setAttribute("error", "This email is already registered. Please login.");
                req.getRequestDispatcher("/Views/register.jsp").forward(req, resp);
                return;
            }

            Guest g = new Guest(email, password);
            boolean ok = guestDAO.registerGuest(g);

            if (ok) {
                req.setAttribute("success", "Registration successful! Please login.");
                req.getRequestDispatcher("/Views/register.jsp").forward(req, resp);
            } else {
                req.setAttribute("error", "Registration failed. Please try again.");
                req.getRequestDispatcher("/Views/register.jsp").forward(req, resp);
            }

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Server error: " + e.getMessage());
            req.getRequestDispatcher("/Views/register.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/Views/register.jsp").forward(req, resp);
    }
}
