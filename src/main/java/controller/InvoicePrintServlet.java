package controller;

import dao.InvoiceDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.InvoiceBundle;

import java.io.IOException;

@WebServlet("/InvoicePrintServlet")
public class InvoicePrintServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String role = (session == null) ? null : (String) session.getAttribute("userRole");
        if (role == null || !"RECEPTIONIST".equalsIgnoreCase(role)) {
            response.sendRedirect(request.getContextPath() + "/Views/login.jsp");
            return;
        }

        int invoiceId = Integer.parseInt(request.getParameter("invoiceId"));
        String download = request.getParameter("download"); 

        try {
            InvoiceDAO dao = new InvoiceDAO();
            InvoiceBundle bundle = dao.getInvoiceBundle(invoiceId);

            request.setAttribute("bundle", bundle);

            if ("pdf".equalsIgnoreCase(download)) {
                dao.writeInvoicePdf(response, bundle); 
                return;
            }

            request.getRequestDispatcher("/Views/receptionist/invoice_print.jsp")
                    .forward(request, response);

        } catch (Exception ex) {
            ex.printStackTrace();
            session.setAttribute("flashMsg", "Invoice load failed: " + ex.getMessage());
            session.setAttribute("flashType", "danger");
            response.sendRedirect(request.getContextPath() + "/ReceptionistReservationsServlet");
        }
    }
}