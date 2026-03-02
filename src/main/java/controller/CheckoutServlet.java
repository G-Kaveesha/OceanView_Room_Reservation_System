package controller;

import dao.InvoiceDAO;
import dao.ReservationDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.Invoice;
import model.InvoiceItem;
import model.ReservationRequest;

import java.io.IOException;
import java.util.List;

@WebServlet("/CheckoutServlet")
public class CheckoutServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String role = (session == null) ? null : (String) session.getAttribute("userRole");
        if (role == null || !"RECEPTIONIST".equalsIgnoreCase(role)) {
            response.sendRedirect(request.getContextPath() + "/Views/login.jsp");
            return;
        }

        String ridStr = request.getParameter("rid");
        int rid;
        try { rid = Integer.parseInt(ridStr); }
        catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/ReceptionistReservationsServlet");
            return;
        }

        try {
            ReservationDAO rdao = new ReservationDAO();
            ReservationRequest r = rdao.getReservationById(rid);
            if (r == null) throw new IllegalArgumentException("Reservation not found.");

            
            String st = (r.getReservationStatus() == null) ? "" : r.getReservationStatus().trim().toUpperCase();
            if (!"CHECKED_IN".equals(st)) {
                session.setAttribute("flashMsg", "Only CHECKED_IN reservations can be checked-out.");
                session.setAttribute("flashType", "warning");
                response.sendRedirect(request.getContextPath() + "/ReservationDetailsServlet?id=" + rid);
                return;
            }

            InvoiceDAO idao = new InvoiceDAO();
            Invoice inv = idao.getOrCreateInvoiceForReservation(rid);

            List<InvoiceItem> items = idao.getInvoiceItems(inv.getInvoiceId());

            request.setAttribute("reservation", r);
            request.setAttribute("invoice", inv);
            request.setAttribute("items", items);

            request.getRequestDispatcher("/Views/receptionist/checkout.jsp").forward(request, response);

        } catch (Exception ex) {
            ex.printStackTrace();
            session.setAttribute("flashMsg", "Checkout load failed: " + ex.getMessage());
            session.setAttribute("flashType", "danger");
            response.sendRedirect(request.getContextPath() + "/ReservationDetailsServlet?id=" + rid);
        }
    }

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
        String removeId = request.getParameter("removeItemId");

        try {
            InvoiceDAO idao = new InvoiceDAO();
            int invoiceId = idao.getOrCreateInvoiceForReservation(rid).getInvoiceId();

            if (removeId != null && !removeId.trim().isEmpty()) {
                idao.removeInvoiceItem(Integer.parseInt(removeId), invoiceId);
            } else {
                String name = request.getParameter("chargeName");
                int qty = Integer.parseInt(request.getParameter("qty"));
                double unit = Double.parseDouble(request.getParameter("unitPrice"));
                String note = request.getParameter("note");

                idao.addInvoiceItem(invoiceId, name, qty, unit, note);
            }

            response.sendRedirect(request.getContextPath() + "/CheckoutServlet?rid=" + rid);

        } catch (Exception ex) {
            ex.printStackTrace();
            session.setAttribute("flashMsg", "Charge update failed: " + ex.getMessage());
            session.setAttribute("flashType", "danger");
            response.sendRedirect(request.getContextPath() + "/CheckoutServlet?rid=" + rid);
        }
    }
}