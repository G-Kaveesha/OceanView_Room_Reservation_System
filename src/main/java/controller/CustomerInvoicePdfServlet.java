package controller;

import dao.InvoiceDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.InvoiceBundle;

import java.io.IOException;

@WebServlet("/CustomerInvoicePdfServlet")
public class CustomerInvoicePdfServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Guest login guard
        HttpSession session = request.getSession(false);
        String authType = (session == null) ? null : (String) session.getAttribute("authType");
        String guestEmail = (session == null) ? null : (String) session.getAttribute("guestEmail");

        if (authType == null || !"GUEST".equalsIgnoreCase(authType) || guestEmail == null) {
            response.sendRedirect(request.getContextPath() + "/Views/login.jsp");
            return;
        }

        try {
            int invoiceId = Integer.parseInt(request.getParameter("invoiceId"));

            InvoiceDAO dao = new InvoiceDAO();

            // ✅ Security: invoice must belong to this logged-in guest
            if (!dao.invoiceBelongsToEmail(invoiceId, guestEmail)) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                response.getWriter().write("Access denied.");
                return;
            }

            InvoiceBundle bundle = dao.getInvoiceBundle(invoiceId);
            if (bundle == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                response.getWriter().write("Invoice not found.");
                return;
            }

            // ✅ Stream PDF
            dao.writeInvoicePdf(response, bundle);

        } catch (NumberFormatException ex) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Invalid invoiceId.");
        } catch (Exception ex) {
            ex.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("Failed to generate PDF.");
        }
    }
}