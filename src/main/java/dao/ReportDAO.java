package dao;

import model.report.*;

import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import util.DBUtil;

public class ReportDAO {

    private Connection getConn() throws SQLException {
        try {
            return DBUtil.getConnection();
        } catch (Exception e) {
            throw new SQLException("DB Connection failed", e);
        }
    }

    // ---------------- KPIs ----------------

    public int countReservations(LocalDate from, LocalDate to) {
        String sql = "SELECT COUNT(*) FROM reservations " +
                     "WHERE created_at >= ? AND created_at < DATE_ADD(?, INTERVAL 1 DAY)";
        try (Connection con = getConn();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setDate(1, Date.valueOf(from));
            ps.setDate(2, Date.valueOf(to));
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    public int countReservationsByStatus(LocalDate from, LocalDate to, String status) {
        String sql = "SELECT COUNT(*) FROM reservations " +
                     "WHERE reservation_status = ? " +
                     "AND created_at >= ? AND created_at < DATE_ADD(?, INTERVAL 1 DAY)";
        try (Connection con = getConn();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setDate(2, Date.valueOf(from));
            ps.setDate(3, Date.valueOf(to));
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    public BigDecimal sumInvoiceRevenue(LocalDate from, LocalDate to) {
        String sql = "SELECT COALESCE(SUM(total_amount), 0) " +
                     "FROM invoices " +
                     "WHERE issued_at >= ? AND issued_at < DATE_ADD(?, INTERVAL 1 DAY) " +
                     "AND invoice_status IN ('ISSUED','PAID')";
        try (Connection con = getConn();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setDate(1, Date.valueOf(from));
            ps.setDate(2, Date.valueOf(to));
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getBigDecimal(1) : BigDecimal.ZERO;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return BigDecimal.ZERO;
        }
    }

    public BigDecimal sumPaymentsReceived(LocalDate from, LocalDate to) {
        String sql = "SELECT COALESCE(SUM(amount_paid), 0) " +
                     "FROM payments " +
                     "WHERE payment_date >= ? AND payment_date < DATE_ADD(?, INTERVAL 1 DAY) " +
                     "AND payment_status = 'SUCCESS'";
        try (Connection con = getConn();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setDate(1, Date.valueOf(from));
            ps.setDate(2, Date.valueOf(to));
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getBigDecimal(1) : BigDecimal.ZERO;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return BigDecimal.ZERO;
        }
    }

    
    public BigDecimal getADR(LocalDate from, LocalDate to) {
        String sql = "SELECT COALESCE(SUM(room_cost), 0) AS sum_cost, " +
                     "COALESCE(SUM(nights), 0) AS sum_nights " +
                     "FROM invoices " +
                     "WHERE issued_at >= ? AND issued_at < DATE_ADD(?, INTERVAL 1 DAY) " +
                     "AND invoice_status IN ('ISSUED','PAID')";
        try (Connection con = getConn();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setDate(1, Date.valueOf(from));
            ps.setDate(2, Date.valueOf(to));

            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return BigDecimal.ZERO;

                BigDecimal sumCost = rs.getBigDecimal("sum_cost");
                int sumNights = rs.getInt("sum_nights");
                if (sumNights <= 0) return BigDecimal.ZERO;

                return sumCost.divide(BigDecimal.valueOf(sumNights), 2, java.math.RoundingMode.HALF_UP);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return BigDecimal.ZERO;
        }
    }

    
    public BigDecimal getALOS(LocalDate from, LocalDate to) {
        String sql = "SELECT COALESCE(AVG(DATEDIFF(check_out_date, check_in_date)), 0) AS alos " +
                     "FROM reservations " +
                     "WHERE created_at >= ? AND created_at < DATE_ADD(?, INTERVAL 1 DAY) " +
                     "AND reservation_status <> 'CANCELLED'";
        try (Connection con = getConn();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setDate(1, Date.valueOf(from));
            ps.setDate(2, Date.valueOf(to));

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getBigDecimal("alos") : BigDecimal.ZERO;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return BigDecimal.ZERO;
        }
    }

    
    public BigDecimal getOccupancyRate(LocalDate from, LocalDate to) {
        String activeRoomsSql = "SELECT COUNT(*) FROM rooms WHERE is_active = 1";
        String nightsSoldSql =
                "SELECT COALESCE(SUM(" +
                "  GREATEST(0, DATEDIFF(" +
                "    LEAST(check_out_date, DATE_ADD(?, INTERVAL 1 DAY))," +
                "    GREATEST(check_in_date, ?)" +
                "  ))" +
                "), 0) AS nights_sold " +
                "FROM reservations " +
                "WHERE reservation_status IN ('CONFIRMED','CHECKED_IN','CHECKED_OUT') " +
                "AND check_in_date < DATE_ADD(?, INTERVAL 1 DAY) " +
                "AND check_out_date > ?";

        try (Connection con = getConn()) {

            int activeRooms;
            try (PreparedStatement ps = con.prepareStatement(activeRoomsSql);
                 ResultSet rs = ps.executeQuery()) {
                activeRooms = rs.next() ? rs.getInt(1) : 0;
            }

            if (activeRooms <= 0) return BigDecimal.ZERO;

            int nightsSold;
            try (PreparedStatement ps = con.prepareStatement(nightsSoldSql)) {
                ps.setDate(1, Date.valueOf(to));
                ps.setDate(2, Date.valueOf(from));
                ps.setDate(3, Date.valueOf(to));
                ps.setDate(4, Date.valueOf(from));
                try (ResultSet rs = ps.executeQuery()) {
                    nightsSold = rs.next() ? rs.getInt("nights_sold") : 0;
                }
            }

            long days = java.time.temporal.ChronoUnit.DAYS.between(from, to) + 1;
            if (days <= 0) return BigDecimal.ZERO;

            BigDecimal denom = BigDecimal.valueOf(activeRooms).multiply(BigDecimal.valueOf(days));
            return BigDecimal.valueOf(nightsSold)
                    .multiply(BigDecimal.valueOf(100))
                    .divide(denom, 2, java.math.RoundingMode.HALF_UP);

        } catch (SQLException e) {
            e.printStackTrace();
            return BigDecimal.ZERO;
        }
    }

    // ---------------- Tables ----------------

    public List<ReservationReportRow> getReservationsReport(LocalDate from, LocalDate to, int limit) {
        String sql =
            "SELECT reservation_id, guest_name, room_number, check_in_date, check_out_date, " +
            "number_of_guests, reservation_status, created_at " +
            "FROM reservations " +
            "WHERE created_at >= ? AND created_at < DATE_ADD(?, INTERVAL 1 DAY) " +
            "ORDER BY created_at DESC " +
            "LIMIT ?";

        List<ReservationReportRow> list = new ArrayList<>();
        try (Connection con = getConn();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setDate(1, Date.valueOf(from));
            ps.setDate(2, Date.valueOf(to));
            ps.setInt(3, limit);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ReservationReportRow r = new ReservationReportRow();
                    r.setReservationId(rs.getInt("reservation_id"));
                    r.setGuestName(rs.getString("guest_name"));
                    r.setRoomNumber(rs.getString("room_number"));
                    r.setCheckIn(rs.getDate("check_in_date"));
                    r.setCheckOut(rs.getDate("check_out_date"));
                    r.setGuests(rs.getInt("number_of_guests"));
                    r.setStatus(rs.getString("reservation_status"));
                    r.setCreatedAt(rs.getTimestamp("created_at"));
                    list.add(r);
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public List<InvoiceReportRow> getInvoicesReport(LocalDate from, LocalDate to, int limit) {
        String sql =
            "SELECT i.invoice_id, i.reservation_id, r.guest_email, i.total_amount, " +
            "i.invoice_status, i.issued_at " +
            "FROM invoices i " +
            "LEFT JOIN reservations r ON r.reservation_id = i.reservation_id " +
            "WHERE i.issued_at >= ? AND i.issued_at < DATE_ADD(?, INTERVAL 1 DAY) " +
            "ORDER BY i.issued_at DESC " +
            "LIMIT ?";

        List<InvoiceReportRow> list = new ArrayList<>();
        try (Connection con = getConn();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setDate(1, Date.valueOf(from));
            ps.setDate(2, Date.valueOf(to));
            ps.setInt(3, limit);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    InvoiceReportRow row = new InvoiceReportRow();
                    row.setInvoiceId(rs.getInt("invoice_id"));
                    row.setReservationId(rs.getInt("reservation_id"));
                    row.setGuestEmail(rs.getString("guest_email"));
                    row.setTotalAmount(rs.getBigDecimal("total_amount"));
                    row.setInvoiceStatus(rs.getString("invoice_status"));
                    row.setIssuedAt(rs.getTimestamp("issued_at"));
                    list.add(row);
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public List<PaymentReportRow> getPaymentsReport(LocalDate from, LocalDate to, int limit) {
        String sql =
            "SELECT payment_id, invoice_id, payment_method, amount_paid, payment_status, payment_date, received_by " +
            "FROM payments " +
            "WHERE payment_date >= ? AND payment_date < DATE_ADD(?, INTERVAL 1 DAY) " +
            "ORDER BY payment_date DESC " +
            "LIMIT ?";

        List<PaymentReportRow> list = new ArrayList<>();
        try (Connection con = getConn();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setDate(1, Date.valueOf(from));
            ps.setDate(2, Date.valueOf(to));
            ps.setInt(3, limit);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    PaymentReportRow p = new PaymentReportRow();
                    p.setPaymentId(rs.getInt("payment_id"));
                    p.setInvoiceId(rs.getInt("invoice_id"));
                    p.setMethod(rs.getString("payment_method"));
                    p.setAmountPaid(rs.getBigDecimal("amount_paid"));
                    p.setPaymentStatus(rs.getString("payment_status"));
                    p.setPaymentDate(rs.getTimestamp("payment_date"));
                    p.setReceivedBy(rs.getInt("received_by"));
                    list.add(p);
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public List<RoomUtilizationRow> getRoomUtilization(LocalDate from, LocalDate to, int limit) {
        String sql =
            "SELECT rm.room_number, rm.type_name, " +
            "COALESCE(SUM(GREATEST(0, DATEDIFF(" +
            "  LEAST(r.check_out_date, DATE_ADD(?, INTERVAL 1 DAY)), " +
            "  GREATEST(r.check_in_date, ?) " +
            "))), 0) AS nights_booked, " +
            "COUNT(r.reservation_id) AS times_reserved, " +
            "rm.status AS current_status " +
            "FROM rooms rm " +
            "LEFT JOIN reservations r " +
            "  ON r.room_id = rm.room_id " +
            " AND r.reservation_status IN ('CONFIRMED','CHECKED_IN','CHECKED_OUT') " +
            " AND r.check_in_date < DATE_ADD(?, INTERVAL 1 DAY) " +
            " AND r.check_out_date > ? " +
            "GROUP BY rm.room_id, rm.room_number, rm.type_name, rm.status " +
            "ORDER BY nights_booked DESC " +
            "LIMIT ?";

        List<RoomUtilizationRow> list = new ArrayList<>();
        try (Connection con = getConn();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setDate(1, Date.valueOf(to));
            ps.setDate(2, Date.valueOf(from));
            ps.setDate(3, Date.valueOf(to));
            ps.setDate(4, Date.valueOf(from));
            ps.setInt(5, limit);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    RoomUtilizationRow row = new RoomUtilizationRow();
                    row.setRoomNumber(rs.getString("room_number"));
                    row.setTypeName(rs.getString("type_name"));
                    row.setNightsBooked(rs.getInt("nights_booked"));
                    row.setTimesReserved(rs.getInt("times_reserved"));
                    row.setCurrentStatus(rs.getString("current_status"));
                    list.add(row);
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // ---------------- Charts ----------------

    public List<ChartPoint> getRevenueByDay(LocalDate from, LocalDate to) {
        String sql =
            "SELECT DATE(issued_at) AS d, COALESCE(SUM(total_amount),0) AS v " +
            "FROM invoices " +
            "WHERE issued_at >= ? AND issued_at < DATE_ADD(?, INTERVAL 1 DAY) " +
            "AND invoice_status IN ('ISSUED','PAID') " +
            "GROUP BY DATE(issued_at) " +
            "ORDER BY d ASC";
        return chartPoints(sql, from, to);
    }

    public List<StatusCount> getReservationStatusBreakdown(LocalDate from, LocalDate to) {
        String sql =
            "SELECT reservation_status AS s, COUNT(*) AS c " +
            "FROM reservations " +
            "WHERE created_at >= ? AND created_at < DATE_ADD(?, INTERVAL 1 DAY) " +
            "GROUP BY reservation_status " +
            "ORDER BY c DESC";

        List<StatusCount> list = new ArrayList<>();
        try (Connection con = getConn();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setDate(1, Date.valueOf(from));
            ps.setDate(2, Date.valueOf(to));

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    StatusCount sc = new StatusCount();
                    sc.setStatus(rs.getString("s"));
                    sc.setCount(rs.getInt("c"));
                    list.add(sc);
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    private List<ChartPoint> chartPoints(String sql, LocalDate from, LocalDate to) {
        List<ChartPoint> list = new ArrayList<>();
        try (Connection con = getConn();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setDate(1, Date.valueOf(from));
            ps.setDate(2, Date.valueOf(to));

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ChartPoint p = new ChartPoint();
                    p.setLabel(rs.getDate("d").toString());
                    p.setValue(rs.getBigDecimal("v"));
                    list.add(p);
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }
}