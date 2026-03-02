package dao;

import model.*;
import util.DBUtil;

import java.sql.*;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;
import jakarta.servlet.http.HttpServletResponse;

public class InvoiceDAO {

    private static final String RES_ROOM_SQL =
            "SELECT r.reservation_id, r.room_id, r.room_number, r.guest_name, r.guest_phone, r.guest_email, r.guest_nic_passport, " +
            "r.check_in_date, r.check_out_date, r.number_of_guests, r.reservation_status, " +
            "rm.nightly_rate " +
            "FROM reservations r JOIN rooms rm ON r.room_id = rm.room_id " +
            "WHERE r.reservation_id = ?";

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

               
                try (PreparedStatement ps = con.prepareStatement(
                        "UPDATE reservations SET reservation_status='CHECKED_OUT' WHERE reservation_id=?")) {
                    ps.setInt(1, reservationId);
                    ps.executeUpdate();
                }

              
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
        return new java.math.BigDecimal(v).setScale(2, java.math.RoundingMode.HALF_UP);
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

    public void writeInvoicePdf(jakarta.servlet.http.HttpServletResponse response, InvoiceBundle bundle) throws Exception {
        throw new UnsupportedOperationException("Add OpenPDF/iText jar and implement PDF rendering.");
    }
}