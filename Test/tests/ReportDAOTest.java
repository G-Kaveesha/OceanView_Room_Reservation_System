package tests;

import static org.junit.jupiter.api.Assertions.*;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.*;
import java.time.Instant;
import java.time.LocalDate;
import java.util.List;

import org.junit.jupiter.api.*;

import dao.ReportDAO;
import model.report.ChartPoint;
import model.report.InvoiceReportRow;
import model.report.PaymentReportRow;
import model.report.ReservationReportRow;
import model.report.RoomUtilizationRow;
import model.report.StatusCount;
import util.DBUtil;

public class ReportDAOTest {

    @BeforeAll
    static void useTestDb() {
        System.setProperty("db.url",
            "jdbc:mysql://localhost:3306/ocean_view_resort_test?useSSL=false&serverTimezone=Asia/Colombo");
        System.setProperty("db.user", "root");
        System.setProperty("db.pass", "Root*234");
    }

    private ReportDAO dao;

    // Test
    private final LocalDate from = LocalDate.of(2026, 3, 1);
    private final LocalDate to   = LocalDate.of(2026, 3, 3);

    private Integer roomId1;

    private Integer resConfirmedInRange;
    private Integer resCancelledInRange;
    private Integer resOutsideRange;

    private Integer invoiceIssuedInRange;
    private Integer invoiceDraftInRange;   
    private Integer invoicePaidOutsideRange; 

    private Integer paymentSuccessInRange;
    private Integer paymentFailedInRange;  
    private Integer paymentSuccessOutsideRange; 

    @BeforeEach
    void setUp() throws Exception {
        dao = new ReportDAO();

        // 1) Room (active)
        roomId1 = insertRoom("R-JUNIT-101", 1, "Standard", 2, new BigDecimal("15000.00"), 1, "AVAILABLE");

        // 2) Reservations
        // CONFIRMED inside range: check_in 2026-03-01, check_out 2026-03-03 => nights sold = 2 (DATEDIFF)
        resConfirmedInRange = insertReservation(
                roomId1, "R-JUNIT-101",
                "JUnit Guest A", "0771111111", "a@test.com", "NIC-A",
                LocalDate.of(2026, 3, 1), LocalDate.of(2026, 3, 3),
                2, "CONFIRMED",
                Timestamp.valueOf("2026-03-02 10:00:00")
        );

        // CANCELLED inside range (should be excluded from ALOS)
        resCancelledInRange = insertReservation(
                roomId1, "R-JUNIT-101",
                "JUnit Guest B", "0772222222", "b@test.com", "NIC-B",
                LocalDate.of(2026, 3, 2), LocalDate.of(2026, 3, 3),
                1, "CANCELLED",
                Timestamp.valueOf("2026-03-02 11:00:00")
        );

        // Outside range (created_at before from)
        resOutsideRange = insertReservation(
                roomId1, "R-JUNIT-101",
                "JUnit Guest C", "0773333333", "c@test.com", "NIC-C",
                LocalDate.of(2026, 2, 20), LocalDate.of(2026, 2, 22),
                2, "CONFIRMED",
                Timestamp.valueOf("2026-02-20 09:00:00")
        );

        // 3) Invoices
        // ISSUED in range: should count in revenue and ADR
        // nights=2, room_cost=30000 => ADR = 15000
        invoiceIssuedInRange = insertInvoice(
                resConfirmedInRange,
                2,
                new BigDecimal("15000.00"),
                new BigDecimal("30000.00"),
                new BigDecimal("0.00"),
                new BigDecimal("0.00"),
                new BigDecimal("0.00"),
                new BigDecimal("0.00"),
                new BigDecimal("30000.00"),
                "ISSUED",
                Timestamp.valueOf("2026-03-02 12:00:00")
        );

        // DRAFT in range: should NOT count in revenue
        invoiceDraftInRange = insertInvoice(
                resCancelledInRange,
                1,
                new BigDecimal("15000.00"),
                new BigDecimal("15000.00"),
                new BigDecimal("0.00"),
                new BigDecimal("0.00"),
                new BigDecimal("0.00"),
                new BigDecimal("0.00"),
                new BigDecimal("15000.00"),
                "DRAFT",
                Timestamp.valueOf("2026-03-02 12:30:00")
        );

        // PAID but OUTSIDE range: should NOT count in revenue for the (from,to) window
        invoicePaidOutsideRange = insertInvoice(
                resOutsideRange,
                2,
                new BigDecimal("15000.00"),
                new BigDecimal("30000.00"),
                new BigDecimal("0.00"),
                new BigDecimal("0.00"),
                new BigDecimal("0.00"),
                new BigDecimal("0.00"),
                new BigDecimal("30000.00"),
                "PAID",
                Timestamp.valueOf("2026-02-20 10:00:00")
        );

        // 4) Payments
        // SUCCESS in range: should count
        paymentSuccessInRange = insertPayment(
                invoiceIssuedInRange,
                "CASH",
                new BigDecimal("30000.00"),
                "SUCCESS",
                Timestamp.valueOf("2026-03-02 13:00:00")
        );

        // FAILED in range: should NOT count
        paymentFailedInRange = insertPayment(
                invoiceIssuedInRange,
                "CARD",
                new BigDecimal("5000.00"),
                "FAILED",
                Timestamp.valueOf("2026-03-02 13:10:00")
        );

        // SUCCESS outside range: should NOT count
        paymentSuccessOutsideRange = insertPayment(
                invoicePaidOutsideRange,
                "ONLINE_TRANSFER",
                new BigDecimal("30000.00"),
                "SUCCESS",
                Timestamp.valueOf("2026-02-20 11:00:00")
        );
    }

    @AfterEach
    void tearDown() throws Exception {
        deleteById("payments", "payment_id", paymentSuccessInRange);
        deleteById("payments", "payment_id", paymentFailedInRange);
        deleteById("payments", "payment_id", paymentSuccessOutsideRange);

        deleteById("invoice_items", "invoice_id", invoiceIssuedInRange);
        deleteById("invoice_items", "invoice_id", invoiceDraftInRange);
        deleteById("invoice_items", "invoice_id", invoicePaidOutsideRange);

        deleteById("invoices", "invoice_id", invoiceIssuedInRange);
        deleteById("invoices", "invoice_id", invoiceDraftInRange);
        deleteById("invoices", "invoice_id", invoicePaidOutsideRange);

        deleteById("reservations", "reservation_id", resConfirmedInRange);
        deleteById("reservations", "reservation_id", resCancelledInRange);
        deleteById("reservations", "reservation_id", resOutsideRange);

        deleteById("rooms", "room_id", roomId1);
    }

    // -------------------- Card Tests --------------------

    @Test
    @DisplayName("countReservations counts only rows within date window (created_at)")
    void countReservations_countsInRange() {
        int count = dao.countReservations(from, to);
        assertEquals(2, count); 
    }

    @Test
    @DisplayName("countReservationsByStatus counts only matching status within window")
    void countReservationsByStatus_countsConfirmed() {
        int count = dao.countReservationsByStatus(from, to, "CONFIRMED");
        assertEquals(1, count);
    }

    @Test
    @DisplayName("sumInvoiceRevenue sums ISSUED/PAID only within issued_at window")
    void sumInvoiceRevenue_sumsCorrectStatusesOnly() {
        BigDecimal revenue = dao.sumInvoiceRevenue(from, to);
        assertEquals(new BigDecimal("30000.00"), revenue.setScale(2, RoundingMode.HALF_UP));
    }

    @Test
    @DisplayName("sumPaymentsReceived sums SUCCESS only within payment_date window")
    void sumPaymentsReceived_sumsSuccessOnly() {
        BigDecimal paid = dao.sumPaymentsReceived(from, to);
        assertEquals(new BigDecimal("30000.00"), paid.setScale(2, RoundingMode.HALF_UP));
    }

    @Test
    @DisplayName("getADR = SUM(room_cost)/SUM(nights) for ISSUED/PAID invoices")
    void getADR_returnsExpected() {
        BigDecimal adr = dao.getADR(from, to);
        assertEquals(new BigDecimal("15000.00"), adr.setScale(2, RoundingMode.HALF_UP));
    }

    @Test
    @DisplayName("getALOS excludes CANCELLED reservations")
    void getALOS_excludesCancelled() {
        BigDecimal alos = dao.getALOS(from, to);
        assertEquals(new BigDecimal("2.00"), alos.setScale(2, RoundingMode.HALF_UP));
    }

    @Test
    @DisplayName("getOccupancyRate uses active rooms and overlapping confirmed/checked_in/checked_out nights")
    void getOccupancyRate_returnsExpected() {
        BigDecimal occ = dao.getOccupancyRate(from, to);
        assertEquals(new BigDecimal("66.67"), occ.setScale(2, RoundingMode.HALF_UP));
    }

    // -------------------- Table/Chart Tests --------------------

    @Test
    @DisplayName("getReservationsReport returns recent reservations within window")
    void getReservationsReport_containsInserted() {
        List<ReservationReportRow> rows = dao.getReservationsReport(from, to, 10);
        assertNotNull(rows);
        assertTrue(rows.stream().anyMatch(r -> r.getReservationId() == resConfirmedInRange));
    }

    @Test
    @DisplayName("getInvoicesReport returns invoices within window and maps fields")
    void getInvoicesReport_containsIssued() {
        List<InvoiceReportRow> rows = dao.getInvoicesReport(from, to, 10);
        assertNotNull(rows);
        assertTrue(rows.stream().anyMatch(i -> i.getInvoiceId() == invoiceIssuedInRange));
    }

    @Test
    @DisplayName("getPaymentsReport returns payments within window")
    void getPaymentsReport_containsSuccess() {
        List<PaymentReportRow> rows = dao.getPaymentsReport(from, to, 10);
        assertNotNull(rows);
        assertTrue(rows.stream().anyMatch(p -> p.getPaymentId() == paymentSuccessInRange));
    }

    @Test
    @DisplayName("getRoomUtilization returns utilization rows (at least the inserted room)")
    void getRoomUtilization_containsRoom() {
        List<RoomUtilizationRow> rows = dao.getRoomUtilization(from, to, 10);
        assertNotNull(rows);
        assertTrue(rows.stream().anyMatch(r -> "R-JUNIT-101".equals(r.getRoomNumber())));
    }

    @Test
    @DisplayName("getRevenueByDay returns chart points for days with ISSUED/PAID invoices")
    void getRevenueByDay_containsDay() {
        List<ChartPoint> pts = dao.getRevenueByDay(from, to);
        assertNotNull(pts);
        assertTrue(pts.stream().anyMatch(p -> "2026-03-02".equals(p.getLabel())));
    }

    @Test
    @DisplayName("getReservationStatusBreakdown returns counts grouped by status")
    void getReservationStatusBreakdown_containsConfirmedAndCancelled() {
        List<StatusCount> list = dao.getReservationStatusBreakdown(from, to);
        assertNotNull(list);
        assertTrue(list.stream().anyMatch(s -> "CONFIRMED".equalsIgnoreCase(s.getStatus())));
        assertTrue(list.stream().anyMatch(s -> "CANCELLED".equalsIgnoreCase(s.getStatus())));
    }

    // -------------------- DB Helpers --------------------

    private Integer insertRoom(String roomNumber, int floorNo, String type, int capacity,
                               BigDecimal rate, int isActive, String status) throws Exception {

        String sql =
            "INSERT INTO rooms (room_number, floor_no, type_name, capacity, nightly_rate, description, is_active, status, notes, created_at, updated_at) " +
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            Timestamp now = Timestamp.from(Instant.now());

            ps.setString(1, roomNumber);
            ps.setInt(2, floorNo);
            ps.setString(3, type);
            ps.setInt(4, capacity);
            ps.setBigDecimal(5, rate);
            ps.setString(6, "JUnit room");
            ps.setInt(7, isActive);
            ps.setString(8, status);
            ps.setString(9, "Created for ReportDAO tests");
            ps.setTimestamp(10, now);
            ps.setTimestamp(11, now);

            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                return rs.next() ? rs.getInt(1) : null;
            }
        }
    }

    private Integer insertReservation(int roomId, String roomNumber,
                                      String guestName, String phone, String email, String nic,
                                      LocalDate checkIn, LocalDate checkOut,
                                      int guests, String status,
                                      Timestamp createdAt) throws Exception {

        String sql =
            "INSERT INTO reservations (room_id, room_number, guest_name, guest_phone, guest_email, guest_nic_passport, " +
            "check_in_date, check_out_date, number_of_guests, reservation_status, created_by, special_requests, created_at, updated_at) " +
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, roomId);
            ps.setString(2, roomNumber);
            ps.setString(3, guestName);
            ps.setString(4, phone);
            ps.setString(5, email);
            ps.setString(6, nic);
            ps.setDate(7, Date.valueOf(checkIn));
            ps.setDate(8, Date.valueOf(checkOut));
            ps.setInt(9, guests);
            ps.setString(10, status);
            ps.setNull(11, Types.INTEGER);

            ps.setString(12, "JUnit special request");
            ps.setTimestamp(13, createdAt);
            ps.setTimestamp(14, createdAt);

            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                return rs.next() ? rs.getInt(1) : null;
            }
        }
    }

    private Integer insertInvoice(int reservationId,
                                  int nights,
                                  BigDecimal roomRate,
                                  BigDecimal roomCost,
                                  BigDecimal extrasTotal,
                                  BigDecimal serviceCharge,
                                  BigDecimal taxAmount,
                                  BigDecimal discount,
                                  BigDecimal totalAmount,
                                  String status,
                                  Timestamp issuedAt) throws Exception {

        String sql =
            "INSERT INTO invoices (reservation_id, nights, room_rate, room_cost, extras_total, service_charge, tax_amount, discount, total_amount, invoice_status, issued_at, updated_at) " +
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, reservationId);
            ps.setInt(2, nights);
            ps.setBigDecimal(3, roomRate);
            ps.setBigDecimal(4, roomCost);
            ps.setBigDecimal(5, extrasTotal);
            ps.setBigDecimal(6, serviceCharge);
            ps.setBigDecimal(7, taxAmount);
            ps.setBigDecimal(8, discount);
            ps.setBigDecimal(9, totalAmount);
            ps.setString(10, status);
            ps.setTimestamp(11, issuedAt);
            ps.setTimestamp(12, issuedAt);

            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                return rs.next() ? rs.getInt(1) : null;
            }
        }
    }

    private Integer insertPayment(int invoiceId,
                                  String method,
                                  BigDecimal amountPaid,
                                  String status,
                                  Timestamp paymentDate) throws Exception {

        String sql =
            "INSERT INTO payments (invoice_id, payment_date, payment_method, amount_paid, transaction_ref, payment_status, received_by) " +
            "VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, invoiceId);
            ps.setTimestamp(2, paymentDate);
            ps.setString(3, method);
            ps.setBigDecimal(4, amountPaid);
            ps.setString(5, "TXN-" + System.currentTimeMillis());
            ps.setString(6, status);
            ps.setNull(7, Types.INTEGER);

            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                return rs.next() ? rs.getInt(1) : null;
            }
        }
    }

    private void deleteById(String table, String idCol, Integer id) throws Exception {
        if (id == null) return;
        String sql = "DELETE FROM " + table + " WHERE " + idCol + " = ?";
        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }
}