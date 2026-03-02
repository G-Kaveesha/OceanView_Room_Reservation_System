package controller;

import dao.InvoiceDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/FinalizeCheckoutServlet")
public class FinalizeCheckoutServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String role = (session == null) ? null : (String) session.getAttribute("userRole");
        if (role == null || !"RECEPTIONIST".equalsIgnoreCase(role)) {
            response.sendRedirect(request.getContextPath() + "/Views/login.jsp");
            return;
        }

        int rid = Integer.parseInt(request.getParameter("reservationId"));
        String method = request.getParameter("paymentMethod"); 
        double paid = Double.parseDouble(request.getParameter("amountPaid"));

        Integer receivedBy = (Integer) session.getAttribute("userId"); 

        try {
            InvoiceDAO idao = new InvoiceDAO();
            int invoiceId = idao.finalizeCheckoutTransaction(rid, method, paid, receivedBy);

            session.setAttribute("flashMsg", "Check-out completed. Invoice generated.");
            session.setAttribute("flashType", "success");

            response.sendRedirect(request.getContextPath()
                    + "/InvoicePrintServlet?invoiceId=" + invoiceId);

        } catch (Exception ex) {
            ex.printStackTrace();
            session.setAttribute("flashMsg", "Finalize failed: " + ex.getMessage());
            session.setAttribute("flashType", "danger");
            response.sendRedirect(request.getContextPath() + "/CheckoutServlet?rid=" + rid);
        }
    }
}