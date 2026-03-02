package controller;

import dao.ReportDAO;
import model.report.*;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@WebServlet("/ManagerReportsServlet")
public class ManagerReportsServlet extends HttpServlet {

    private String getParam(HttpServletRequest req, String name, String def) {
        String v = req.getParameter(name);
        return (v == null || v.trim().isEmpty()) ? def : v.trim();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Guard: only MANAGER
        HttpSession session = request.getSession(false);
        String role = (session == null) ? null : (String) session.getAttribute("userRole");
        if (role == null || !"MANAGER".equalsIgnoreCase(role)) {
            response.sendRedirect(request.getContextPath() + "/Views/login.jsp");
            return;
        }

        LocalDate today = LocalDate.now();
        LocalDate defaultFrom = today.minusDays(30);

        LocalDate from = LocalDate.parse(getParam(request, "from", defaultFrom.toString()));
        LocalDate to   = LocalDate.parse(getParam(request, "to", today.toString()));

        ReportDAO dao = new ReportDAO();

        // KPIs
        int totalReservations      = dao.countReservations(from, to);
        BigDecimal totalRevenue    = dao.sumInvoiceRevenue(from, to);
        BigDecimal totalPayments   = dao.sumPaymentsReceived(from, to);
        int cancelledCount         = dao.countReservationsByStatus(from, to, "CANCELLED");
        int pendingCount           = dao.countReservationsByStatus(from, to, "PENDING");

        BigDecimal occupancyRate   = dao.getOccupancyRate(from, to); 
        BigDecimal adr             = dao.getADR(from, to);           
        BigDecimal alos            = dao.getALOS(from, to);          

        // Tables
        List<ReservationReportRow> reservations   = dao.getReservationsReport(from, to, 200);
        List<InvoiceReportRow> invoices          = dao.getInvoicesReport(from, to, 200);
        List<PaymentReportRow> payments          = dao.getPaymentsReport(from, to, 200);
        List<RoomUtilizationRow> roomUtilization = dao.getRoomUtilization(from, to, 200);

        // Charts 
        List<ChartPoint> revenueByDay         = dao.getRevenueByDay(from, to);
        List<StatusCount> statusBreakdown     = dao.getReservationStatusBreakdown(from, to);

        
        request.setAttribute("from", from.toString());
        request.setAttribute("to", to.toString());

        request.setAttribute("totalReservations", totalReservations);
        request.setAttribute("totalRevenue", totalRevenue);
        request.setAttribute("totalPayments", totalPayments);
        request.setAttribute("occupancyRate", occupancyRate);
        request.setAttribute("adr", adr);
        request.setAttribute("alos", alos);
        request.setAttribute("cancelledCount", cancelledCount);
        request.setAttribute("pendingCount", pendingCount);

        request.setAttribute("reservations", reservations);
        request.setAttribute("invoices", invoices);
        request.setAttribute("payments", payments);
        request.setAttribute("roomUtilization", roomUtilization);

        request.setAttribute("revenueByDay", revenueByDay);
        request.setAttribute("statusBreakdown", statusBreakdown);
        request.setAttribute("occupancyTrend", java.util.Collections.emptyList());

        request.getRequestDispatcher("/Views/manager/reports.jsp").forward(request, response);
    }
}