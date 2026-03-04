package dao;

import model.*;
import util.DBUtil;

import jakarta.servlet.http.HttpServletResponse;

import java.io.PrintWriter;
import java.math.RoundingMode;
import java.sql.*;
import java.text.DecimalFormat;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;
import com.lowagie.text.*;
import com.lowagie.text.pdf.*;

public class InvoiceDAO {

    private static final String RES_ROOM_SQL =
            "SELECT r.reservation_id, r.room_id, r.room_number, r.guest_name, r.guest_phone, r.guest_email, r.guest_nic_passport, " +
            "r.check_in_date, r.check_out_date, r.number_of_guests, r.reservation_status, " +
            "rm.nightly_rate " +
            "FROM reservations r JOIN rooms rm ON r.room_id = rm.room_id " +
            "WHERE r.reservation_id = ?";

    // Currency formatter 
    private static final DecimalFormat LKR_FMT = new DecimalFormat("#,##0.00");

    private static String money(Object v) {
        if (v == null) return "LKR 0.00";
        try {
            if (v instanceof java.math.BigDecimal) {
                return "LKR " + LKR_FMT.format(((java.math.BigDecimal) v).doubleValue());
            }
            if (v instanceof Number) {
                return "LKR " + LKR_FMT.format(((Number) v).doubleValue());
            }
            return "LKR " + LKR_FMT.format(Double.parseDouble(String.valueOf(v)));
        } catch (Exception e) {
            return "LKR " + String.valueOf(v);
        }
    }

    private static String moneyCsv(Object v) {
        
        return money(v);
    }
    
    // CUSTOMER NOTIFICATIONS

    public List<Invoice> getInvoicesByGuestEmail(String email) throws Exception {

        String sql =
                "SELECT i.invoice_id, i.reservation_id, i.total_amount, i.issued_at " +
                "FROM invoices i " +
                "JOIN reservations r ON r.reservation_id = i.reservation_id " +
                "WHERE r.guest_email = ? " +
                "ORDER BY i.issued_at DESC, i.invoice_id DESC";

        List<Invoice> list = new ArrayList<>();

        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, email);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Invoice inv = new Invoice();
                    inv.setInvoiceId(rs.getInt("invoice_id"));
                    inv.setReservationId(rs.getInt("reservation_id"));
                    inv.setTotalAmount(rs.getBigDecimal("total_amount"));
                    inv.setIssuedAt(rs.getTimestamp("issued_at"));
                    list.add(inv);
                }
            }
        }
        return list;
    }

    public int countInvoicesUpdatedAfter(String email, Timestamp lastSeen) throws Exception {

        String sql =
                "SELECT COUNT(*) " +
                "FROM invoices i " +
                "JOIN reservations r ON r.reservation_id = i.reservation_id " +
                "WHERE r.guest_email = ? " +
                "AND COALESCE(i.issued_at, NOW()) > ?";

        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, email);
            ps.setTimestamp(2, lastSeen);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    public boolean invoiceBelongsToEmail(int invoiceId, String guestEmail) throws Exception {

        final String sql =
                "SELECT COUNT(*) " +
                "FROM invoices i " +
                "JOIN reservations r ON r.reservation_id = i.reservation_id " +
                "WHERE i.invoice_id = ? AND r.guest_email = ?";

        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, invoiceId);
            ps.setString(2, guestEmail);

            try (ResultSet rs = ps.executeQuery()) {
                int count = rs.next() ? rs.getInt(1) : 0;
                return count > 0;
            }
        }
    }

    // CSV DOWNLOAD

    public void writeInvoiceCsv(HttpServletResponse response, int invoiceId) throws Exception {

        response.setContentType("text/csv; charset=UTF-8");
        response.setHeader("Content-Disposition", "attachment; filename=invoice_" + invoiceId + ".csv");

        final String sqlInv =
                "SELECT i.invoice_id, i.reservation_id, i.nights, i.room_rate, i.room_cost, " +
                "i.extras_total, i.service_charge, i.tax_amount, i.discount, i.total_amount, " +
                "i.invoice_status, i.issued_at " +
                "FROM invoices i WHERE i.invoice_id = ?";

        final String sqlRes =
                "SELECT reservation_id, room_number, guest_name, guest_phone, guest_email, " +
                "check_in_date, check_out_date, number_of_guests " +
                "FROM reservations WHERE reservation_id = ?";

        final String sqlPay =
                "SELECT payment_method, amount_paid, payment_status, received_by, created_at " +
                "FROM payments WHERE invoice_id = ? " +
                "ORDER BY payment_id DESC LIMIT 1";

        final String sqlItems =
                "SELECT item_name, qty, unit_price, amount, note " +
                "FROM invoice_items WHERE invoice_id = ? " +
                "ORDER BY item_id DESC";

        try (Connection con = DBUtil.getConnection();
             PrintWriter out = response.getWriter()) {

            int reservationId;

            // invoice row
            try (PreparedStatement ps = con.prepareStatement(sqlInv)) {
                ps.setInt(1, invoiceId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        out.println("Invoice not found");
                        return;
                    }

                    reservationId = rs.getInt("reservation_id");

                    out.println("Invoice Summary");
                    out.println("Invoice ID,Reservation ID,Nights,Room Rate,Room Cost,Extras Total,Service Charge,Tax Amount,Discount,Total Amount,Status,Issued At");

                    out.printf("%d,%d,%d,%s,%s,%s,%s,%s,%s,%s,%s,%s%n",
                            rs.getInt("invoice_id"),
                            reservationId,
                            rs.getInt("nights"),
                            moneyCsv(rs.getBigDecimal("room_rate")),
                            moneyCsv(rs.getBigDecimal("room_cost")),
                            moneyCsv(rs.getBigDecimal("extras_total")),
                            moneyCsv(rs.getBigDecimal("service_charge")),
                            moneyCsv(rs.getBigDecimal("tax_amount")),
                            moneyCsv(rs.getBigDecimal("discount")),
                            moneyCsv(rs.getBigDecimal("total_amount")),
                            safe(rs.getString("invoice_status")),
                            String.valueOf(rs.getTimestamp("issued_at"))
                    );
                }
            }

            out.println();

            // reservation/guest info
            out.println("Reservation Details");
            out.println("Room Number,Guest Name,Guest Phone,Guest Email,Check In,Check Out,Guests");

            try (PreparedStatement ps = con.prepareStatement(sqlRes)) {
                ps.setInt(1, reservationId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        out.printf("%s,%s,%s,%s,%s,%s,%d%n",
                                csv(rs.getString("room_number")),
                                csv(rs.getString("guest_name")),
                                csv(rs.getString("guest_phone")),
                                csv(rs.getString("guest_email")),
                                String.valueOf(rs.getDate("check_in_date")),
                                String.valueOf(rs.getDate("check_out_date")),
                                rs.getInt("number_of_guests")
                        );
                    }
                }
            }

            out.println();

            // payment info
            out.println("Payment Details");
            out.println("Method,Amount Paid,Status,Received By,Created At");

            try (PreparedStatement ps = con.prepareStatement(sqlPay)) {
                ps.setInt(1, invoiceId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        out.printf("%s,%s,%s,%s,%s%n",
                                csv(rs.getString("payment_method")),
                                moneyCsv(rs.getBigDecimal("amount_paid")),
                                csv(rs.getString("payment_status")),
                                String.valueOf(rs.getObject("received_by")),
                                String.valueOf(rs.getTimestamp("created_at"))
                        );
                    } else {
                        out.println("N/A,N/A,N/A,N/A,N/A");
                    }
                }
            }

            out.println();

            // items
            out.println("Invoice Items");
            out.println("Item Name,Qty,Unit Price,Amount,Note");

            try (PreparedStatement ps = con.prepareStatement(sqlItems)) {
                ps.setInt(1, invoiceId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        out.printf("%s,%d,%s,%s,%s%n",
                                csv(rs.getString("item_name")),
                                rs.getInt("qty"),
                                moneyCsv(rs.getBigDecimal("unit_price")),
                                moneyCsv(rs.getBigDecimal("amount")),
                                csv(rs.getString("note"))
                        );
                    }
                }
            }

            out.flush();
        }
    }

    private String safe(String s) { return (s == null) ? "" : s; }

    private String csv(String s) {
        if (s == null) return "";
        String t = s.replace("\"", "\"\"");
        if (t.contains(",") || t.contains("\n") || t.contains("\r")) {
            return "\"" + t + "\"";
        }
        return t;
    }

    // receptionist checkout

    public Invoice getOrCreateInvoiceForReservation(int reservationId) throws Exception {
        try (Connection con = DBUtil.getConnection()) {

            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT * FROM invoices WHERE reservation_id = ?")) {
                ps.setInt(1, reservationId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) return mapInvoice(rs);
                }
            }

            ReservationRate rr = getReservationRate(con, reservationId);

            int nights = calcNights(rr.checkIn, rr.checkOut);
            double roomCost = rr.nightlyRate * nights;

            double total = roomCost;

            try (PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO invoices(reservation_id, nights, room_rate, room_cost, extras_total, total_amount, invoice_status) " +
                    "VALUES(?,?,?,?,0.00,?, 'DRAFT')",
                    Statement.RETURN_GENERATED_KEYS)) {

                ps.setInt(1, reservationId);
                ps.setInt(2, nights);
                ps.setBigDecimal(3, new java.math.BigDecimal(rr.nightlyRate).setScale(2));
                ps.setBigDecimal(4, new java.math.BigDecimal(roomCost).setScale(2));
                ps.setBigDecimal(5, new java.math.BigDecimal(total).setScale(2));

                ps.executeUpdate();
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    keys.next();
                    int invoiceId = keys.getInt(1);
                    return getInvoiceById(invoiceId);
                }
            }
        }
    }

    public Invoice getInvoiceById(int invoiceId) throws Exception {
        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement("SELECT * FROM invoices WHERE invoice_id=?")) {
            ps.setInt(1, invoiceId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                return mapInvoice(rs);
            }
        }
    }

    public List<InvoiceItem> getInvoiceItems(int invoiceId) throws Exception {
        List<InvoiceItem> list = new ArrayList<>();
        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(
                     "SELECT * FROM invoice_items WHERE invoice_id=? ORDER BY item_id DESC")) {
            ps.setInt(1, invoiceId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapItem(rs));
            }
        }
        return list;
    }

    public void addInvoiceItem(int invoiceId, String name, int qty, double unitPrice, String note) throws Exception {
        double amount = qty * unitPrice;

        try (Connection con = DBUtil.getConnection()) {
            con.setAutoCommit(false);
            try {
                try (PreparedStatement ps = con.prepareStatement(
                        "INSERT INTO invoice_items(invoice_id,item_name,qty,unit_price,amount,note) VALUES(?,?,?,?,?,?)")) {
                    ps.setInt(1, invoiceId);
                    ps.setString(2, name);
                    ps.setInt(3, qty);
                    ps.setBigDecimal(4, bd(unitPrice));
                    ps.setBigDecimal(5, bd(amount));
                    ps.setString(6, (note == null || note.trim().isEmpty()) ? null : note.trim());
                    ps.executeUpdate();
                }

                recalcInvoiceTotals(con, invoiceId);
                con.commit();
            } catch (Exception ex) {
                con.rollback();
                throw ex;
            } finally {
                con.setAutoCommit(true);
            }
        }
    }

    public void removeInvoiceItem(int itemId, int invoiceId) throws Exception {
        try (Connection con = DBUtil.getConnection()) {
            con.setAutoCommit(false);
            try {
                try (PreparedStatement ps = con.prepareStatement(
                        "DELETE FROM invoice_items WHERE item_id=? AND invoice_id=?")) {
                    ps.setInt(1, itemId);
                    ps.setInt(2, invoiceId);
                    ps.executeUpdate();
                }
                recalcInvoiceTotals(con, invoiceId);
                con.commit();
            } catch (Exception ex) {
                con.rollback();
                throw ex;
            } finally {
                con.setAutoCommit(true);
            }
        }
    }

    public int finalizeCheckoutTransaction(int reservationId, String method, double amountPaid, Integer receivedBy) throws Exception {

        try (Connection con = DBUtil.getConnection()) {
            con.setAutoCommit(false);
            try {

                int roomId;
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT room_id, reservation_status FROM reservations WHERE reservation_id=? FOR UPDATE")) {
                    ps.setInt(1, reservationId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) throw new IllegalArgumentException("Reservation not found.");
                        String st = rs.getString("reservation_status");
                        if (st == null || !"CHECKED_IN".equalsIgnoreCase(st))
                            throw new IllegalArgumentException("Reservation must be CHECKED_IN to checkout.");
                        roomId = rs.getInt("room_id");
                    }
                }

                Invoice inv = getOrCreateInvoiceForReservation(reservationId);
                int invoiceId = inv.getInvoiceId();

                recalcInvoiceTotals(con, invoiceId);

                // insert payment
                try (PreparedStatement ps = con.prepareStatement(
                        "INSERT INTO payments(invoice_id, payment_method, amount_paid, payment_status, received_by) " +
                        "VALUES(?, ?, ?, 'SUCCESS', ?)")) {
                    ps.setInt(1, invoiceId);
                    ps.setString(2, method);
                    ps.setBigDecimal(3, bd(amountPaid));
                    if (receivedBy == null) ps.setNull(4, Types.INTEGER);
                    else ps.setInt(4, receivedBy);
                    ps.executeUpdate();
                }

                // invoice
                try (PreparedStatement ps = con.prepareStatement(
                        "UPDATE invoices SET invoice_status='PAID' WHERE invoice_id=?")) {
                    ps.setInt(1, invoiceId);
                    ps.executeUpdate();
                }

                // reservation
                try (PreparedStatement ps = con.prepareStatement(
                        "UPDATE reservations SET reservation_status='CHECKED_OUT' WHERE reservation_id=?")) {
                    ps.setInt(1, reservationId);
                    ps.executeUpdate();
                }

                // room
                try (PreparedStatement ps = con.prepareStatement(
                        "UPDATE rooms SET status='AVAILABLE' WHERE room_id=?")) {
                    ps.setInt(1, roomId);
                    ps.executeUpdate();
                }

                con.commit();
                return invoiceId;

            } catch (Exception ex) {
                con.rollback();
                throw ex;
            } finally {
                con.setAutoCommit(true);
            }
        }
    }

    public InvoiceBundle getInvoiceBundle(int invoiceId) throws Exception {
        Invoice inv = getInvoiceById(invoiceId);
        if (inv == null) return null;

        ReservationRequest r;
        double rate;

        try (Connection con = DBUtil.getConnection()) {
            ReservationRate rr = getReservationRateByInvoice(con, invoiceId);
            r = rr.reservation;
            rate = rr.nightlyRate;
        }

        List<InvoiceItem> items = getInvoiceItems(invoiceId);

        InvoiceBundle b = new InvoiceBundle();
        b.invoice = inv;
        b.reservation = r;
        b.nightlyRate = rate;
        b.items = items;
        return b;
    }

    // ---------------- helpers ----------------

    private void recalcInvoiceTotals(Connection con, int invoiceId) throws Exception {
        double extras = 0.0;
        try (PreparedStatement ps = con.prepareStatement(
                "SELECT COALESCE(SUM(amount),0) FROM invoice_items WHERE invoice_id=?")) {
            ps.setInt(1, invoiceId);
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                extras = rs.getDouble(1);
            }
        }

        double roomCost;
        double service = 0.0;
        double tax = 0.0;
        double discount = 0.0;

        try (PreparedStatement ps = con.prepareStatement(
                "SELECT room_cost FROM invoices WHERE invoice_id=?")) {
            ps.setInt(1, invoiceId);
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                roomCost = rs.getDouble(1);
            }
        }

        double total = (roomCost + extras + service + tax) - discount;

        try (PreparedStatement ps = con.prepareStatement(
                "UPDATE invoices SET extras_total=?, service_charge=?, tax_amount=?, discount=?, total_amount=?, invoice_status='ISSUED' " +
                "WHERE invoice_id=? AND invoice_status='DRAFT'")) {
            ps.setBigDecimal(1, bd(extras));
            ps.setBigDecimal(2, bd(service));
            ps.setBigDecimal(3, bd(tax));
            ps.setBigDecimal(4, bd(discount));
            ps.setBigDecimal(5, bd(total));
            ps.setInt(6, invoiceId);
            ps.executeUpdate();
        }

        try (PreparedStatement ps = con.prepareStatement(
                "UPDATE invoices SET extras_total=?, service_charge=?, tax_amount=?, discount=?, total_amount=? " +
                "WHERE invoice_id=? AND invoice_status<>'DRAFT'")) {
            ps.setBigDecimal(1, bd(extras));
            ps.setBigDecimal(2, bd(service));
            ps.setBigDecimal(3, bd(tax));
            ps.setBigDecimal(4, bd(discount));
            ps.setBigDecimal(5, bd(total));
            ps.setInt(6, invoiceId);
            ps.executeUpdate();
        }
    }

    private ReservationRate getReservationRate(Connection con, int reservationId) throws Exception {
        try (PreparedStatement ps = con.prepareStatement(RES_ROOM_SQL)) {
            ps.setInt(1, reservationId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) throw new IllegalArgumentException("Reservation not found.");
                return mapReservationRate(rs);
            }
        }
    }

    private ReservationRate getReservationRateByInvoice(Connection con, int invoiceId) throws Exception {
        try (PreparedStatement ps = con.prepareStatement(
                "SELECT r.*, rm.nightly_rate " +
                "FROM invoices i JOIN reservations r ON i.reservation_id=r.reservation_id " +
                "JOIN rooms rm ON r.room_id=rm.room_id " +
                "WHERE i.invoice_id=?")) {
            ps.setInt(1, invoiceId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) throw new IllegalArgumentException("Invoice not found.");
                return mapReservationRate(rs);
            }
        }
    }

    private int calcNights(Date checkIn, Date checkOut) {
        LocalDate ci = checkIn.toLocalDate();
        LocalDate co = checkOut.toLocalDate();
        long n = ChronoUnit.DAYS.between(ci, co);
        return (int) Math.max(1, n);
    }

    private java.math.BigDecimal bd(double v) {
        return new java.math.BigDecimal(v).setScale(2, RoundingMode.HALF_UP);
    }

    private Invoice mapInvoice(ResultSet rs) throws SQLException {
        Invoice i = new Invoice();
        i.setInvoiceId(rs.getInt("invoice_id"));
        i.setReservationId(rs.getInt("reservation_id"));
        i.setNights(rs.getInt("nights"));
        i.setRoomRate(rs.getBigDecimal("room_rate"));
        i.setRoomCost(rs.getBigDecimal("room_cost"));
        i.setExtrasTotal(rs.getBigDecimal("extras_total"));
        i.setServiceCharge(rs.getBigDecimal("service_charge"));
        i.setTaxAmount(rs.getBigDecimal("tax_amount"));
        i.setDiscount(rs.getBigDecimal("discount"));
        i.setTotalAmount(rs.getBigDecimal("total_amount"));
        i.setInvoiceStatus(rs.getString("invoice_status"));
        i.setIssuedAt(rs.getTimestamp("issued_at"));
        return i;
    }

    private InvoiceItem mapItem(ResultSet rs) throws SQLException {
        InvoiceItem it = new InvoiceItem();
        it.setItemId(rs.getInt("item_id"));
        it.setInvoiceId(rs.getInt("invoice_id"));
        it.setItemName(rs.getString("item_name"));
        it.setQty(rs.getInt("qty"));
        it.setUnitPrice(rs.getBigDecimal("unit_price"));
        it.setAmount(rs.getBigDecimal("amount"));
        it.setNote(rs.getString("note"));
        return it;
    }

    private ReservationRate mapReservationRate(ResultSet rs) throws SQLException {
        ReservationRequest r = new ReservationRequest();
        r.setReservationId(rs.getInt("reservation_id"));
        r.setRoomId(rs.getInt("room_id"));
        r.setRoomNumber(rs.getString("room_number"));
        r.setGuestName(rs.getString("guest_name"));
        r.setGuestPhone(rs.getString("guest_phone"));
        r.setGuestEmail(rs.getString("guest_email"));
        r.setGuestNicPassport(rs.getString("guest_nic_passport"));
        r.setCheckInDate(rs.getDate("check_in_date"));
        r.setCheckOutDate(rs.getDate("check_out_date"));
        r.setNumberOfGuests(rs.getInt("number_of_guests"));
        r.setReservationStatus(rs.getString("reservation_status"));

        ReservationRate rr = new ReservationRate();
        rr.reservation = r;
        rr.checkIn = rs.getDate("check_in_date");
        rr.checkOut = rs.getDate("check_out_date");
        rr.nightlyRate = rs.getDouble("nightly_rate");
        return rr;
    }

    private static class ReservationRate {
        ReservationRequest reservation;
        Date checkIn;
        Date checkOut;
        double nightlyRate;
    }

    // PDF DOWNLOAD 
    public void writeInvoicePdf(HttpServletResponse response, InvoiceBundle bundle) throws Exception {

        int invoiceId = bundle.invoice.getInvoiceId();
        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "attachment; filename=invoice_" + invoiceId + ".pdf");

        Document document = new Document(PageSize.A4, 36, 36, 36, 36);
        PdfWriter.getInstance(document, response.getOutputStream());

        document.open();

        Font title = new Font(Font.HELVETICA, 18, Font.BOLD);
        Font h = new Font(Font.HELVETICA, 12, Font.BOLD);
        Font normal = new Font(Font.HELVETICA, 11, Font.NORMAL);

        Paragraph pTitle = new Paragraph("Ocean View Resort - Invoice", title);
        pTitle.setAlignment(Element.ALIGN_CENTER);
        document.add(pTitle);
        document.add(new Paragraph(" ", normal));

        PdfPTable summary = new PdfPTable(2);
        summary.setWidthPercentage(100);
        summary.setSpacingBefore(5f);
        summary.setSpacingAfter(12f);
        summary.setWidths(new float[]{35f, 65f});

        addRowPdf(summary, "Invoice ID", String.valueOf(bundle.invoice.getInvoiceId()), h, normal);
        addRowPdf(summary, "Reservation ID", "RES-" + bundle.invoice.getReservationId(), h, normal);
        addRowPdf(summary, "Issued At", String.valueOf(bundle.invoice.getIssuedAt()), h, normal);
        addRowPdf(summary, "Status", String.valueOf(bundle.invoice.getInvoiceStatus()), h, normal);
        document.add(summary);

        document.add(new Paragraph("Guest Details", h));
        document.add(new Paragraph("Name: " + safePdf(bundle.reservation.getGuestName()), normal));
        document.add(new Paragraph("Email: " + safePdf(bundle.reservation.getGuestEmail()), normal));
        document.add(new Paragraph("Phone: " + safePdf(bundle.reservation.getGuestPhone()), normal));
        document.add(new Paragraph("Room: " + safePdf(bundle.reservation.getRoomNumber()), normal));
        document.add(new Paragraph("Check-in: " + String.valueOf(bundle.reservation.getCheckInDate()), normal));
        document.add(new Paragraph("Check-out: " + String.valueOf(bundle.reservation.getCheckOutDate()), normal));
        document.add(new Paragraph("Guests: " + bundle.reservation.getNumberOfGuests(), normal));
        document.add(new Paragraph(" ", normal));

        document.add(new Paragraph("Charges", h));
        PdfPTable items = new PdfPTable(4);
        items.setWidthPercentage(100);
        items.setSpacingBefore(8f);
        items.setWidths(new float[]{50f, 15f, 15f, 20f});

        addHeader(items, "Item", h);
        addHeader(items, "Qty", h);
        addHeader(items, "Unit Price", h);
        addHeader(items, "Amount", h);

        addCell(items, "Room Charge (" + bundle.invoice.getNights() + " night(s))", normal);
        addCell(items, String.valueOf(bundle.invoice.getNights()), normal);
        addCell(items, money(bundle.invoice.getRoomRate()), normal);
        addCell(items, money(bundle.invoice.getRoomCost()), normal);

        if (bundle.items != null) {
            for (InvoiceItem it : bundle.items) {
                addCell(items, safePdf(it.getItemName()), normal);
                addCell(items, String.valueOf(it.getQty()), normal);
                addCell(items, money(it.getUnitPrice()), normal);
                addCell(items, money(it.getAmount()), normal);
            }
        }

        document.add(items);
        document.add(new Paragraph(" ", normal));

        PdfPTable totals = new PdfPTable(2);
        totals.setWidthPercentage(60);
        totals.setHorizontalAlignment(Element.ALIGN_RIGHT);
        totals.setWidths(new float[]{50f, 50f});

        addRowPdf(totals, "Extras Total", money(bundle.invoice.getExtrasTotal()), h, normal);
        addRowPdf(totals, "Service Charge", money(bundle.invoice.getServiceCharge()), h, normal);
        addRowPdf(totals, "Tax", money(bundle.invoice.getTaxAmount()), h, normal);
        addRowPdf(totals, "Discount", money(bundle.invoice.getDiscount()), h, normal);
        addRowPdf(totals, "TOTAL", money(bundle.invoice.getTotalAmount()), h, normal);

        document.add(totals);

        document.add(new Paragraph(" ", normal));
        Paragraph thanks = new Paragraph("Thank you for staying with Ocean View Resort!", normal);
        thanks.setAlignment(Element.ALIGN_CENTER);
        document.add(thanks);

        document.close();
    }

    // PDF helpers
    private static String safePdf(String s) {
        return (s == null) ? "" : s;
    }

    private static void addHeader(PdfPTable t, String text, Font f) {
        PdfPCell c = new PdfPCell(new Phrase(text, f));
        c.setBackgroundColor(new java.awt.Color(235, 245, 255));
        c.setPadding(8f);
        t.addCell(c);
    }

    private static void addCell(PdfPTable t, String text, Font f) {
        PdfPCell c = new PdfPCell(new Phrase(text == null ? "" : text, f));
        c.setPadding(8f);
        t.addCell(c);
    }

    private static void addRowPdf(PdfPTable t, String k, String v, Font kf, Font vf) {
        PdfPCell c1 = new PdfPCell(new Phrase(k, kf));
        c1.setPadding(8f);
        PdfPCell c2 = new PdfPCell(new Phrase(v == null ? "" : v, vf));
        c2.setPadding(8f);
        t.addCell(c1);
        t.addCell(c2);
    }
}