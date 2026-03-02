package controller;

import dao.UserDAO;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

@WebServlet("/EmployeeServlet")
public class EmployeeServlet extends HttpServlet {

    private final UserDAO dao = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if ("delete".equalsIgnoreCase(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            dao.deleteEmployee(id);

            
            response.sendRedirect(request.getContextPath() + "/EmployeeServlet");
            return;
        }

        List<User> employees = dao.getAllEmployees();
        request.setAttribute("employees", employees);

        request.getRequestDispatcher("/Views/manager/employee.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if ("add".equalsIgnoreCase(action)) {

            String email = request.getParameter("email");

            if (dao.emailExists(email)) {
                request.setAttribute("err", "Email already exists!");
                request.setAttribute("employees", dao.getAllEmployees());
                request.getRequestDispatcher("/Views/manager/employee.jsp").forward(request, response);
                return;
            }

            User u = new User();
            u.setEmail(email);
            u.setPassword(request.getParameter("password"));
            u.setRole(request.getParameter("role"));
            u.setFullName(request.getParameter("fullName"));
            u.setPhone(request.getParameter("phone"));
            u.setActive("1".equals(request.getParameter("isActive")));

            dao.addEmployee(u);

            response.sendRedirect(request.getContextPath() + "/EmployeeServlet");
        }
    }
}
