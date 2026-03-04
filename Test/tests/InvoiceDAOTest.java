package tests;

import static org.junit.jupiter.api.Assertions.*;

import java.math.BigDecimal;
import java.sql.*;
import java.time.Instant;
import java.util.List;

import org.junit.jupiter.api.*;

import dao.InvoiceDAO;
import model.Invoice;
import model.InvoiceItem;
import util.DBUtil;

public class InvoiceDAOTest {

    @BeforeAll
    static void useTestDb() {
        System.setProperty("db.url",
            "jdbc:mysql://localhost:3306/ocean_view_resort_test?useSSL=false&serverTimezone=Asia/Colombo");
        System.setProperty("db.user", "root");
        System.setProperty("db.pass", "Root*234");
    }

    private InvoiceDAO dao;

    private Integer roomId = null;
    private Integer reservationId = null;
    private Integer invoiceId = null;
    private Integer itemId1 = null;

    // Test guest
    private String guestEmail;

    @BeforeEach
    void setUp() throws Exception {
        dao = new InvoiceDAO();
        guestEmail = "junit_" + System.currentTimeMillis() + "@test.com";

        // 1) Room
        roomId = insertRoomRow("INV-" + System.currentTimeMillis(), new BigDecimal("20000.00"));

        // 2) Reservation 
        reservationId = insertReservationRow(roomId, "INV-101", guestEmail);

        assertNotNull(roomId);
        assertNotNull(reservationId);
    }

    @AfterEach
    void tearDown() throws Exception {
        
        deletePaymentByInvoiceId(invoiceId);
        deleteInvoiceItemsByInvoiceId(invoiceId);
        deleteInvoiceById(invoiceId);
        deleteReservationById(reservationId);
        deleteRoomById(roomId);
    }

    @Test
    @DisplayName("getOrCreateInvoiceForReservation creates invoice once and returns same invoice on second call")
    void getOrCreateInvoice_createsOnce() throws Exception {

        Invoice inv1 = dao.getOrCreateInvoiceForReservation(reservationId);
        assertNotNull(inv1);
        assertTrue(inv1.getInvoiceId() > 0);

        invoiceId = inv1.getInvoiceId();

        Invoice inv2 = dao.getOrCreateInvoiceForReservation(reservationId);
        assertNotNull(inv2);
        assertEquals(invoiceId.intValue(), inv2.getInvoiceId());
        assertEquals(reservationId.intValue(), inv1.getReservationId());
        assertTrue(inv1.getNights() >= 1);
        assertNotNull(inv1.getRoomRate());
        assertNotNull(inv1.getRoomCost());
        assertNotNull(inv1.getTotalAmount());
    }

    @Test
    @DisplayName("getInvoiceById returns invoice after creation")
    void getInvoiceById_returnsInvoice() throws Exception {

        Invoice created = dao.getOrCreateInvoiceForReservation(reservationId);
        invoiceId = created.getInvoiceId();

        Invoice fetched = dao.getInvoiceById(invoiceId);
        assertNotNull(fetched);
        assertEquals(invoiceId.intValue(), fetched.getInvoiceId());
        assertEquals(reservationId.intValue(), fetched.getReservationId());
    }

    @Test
    @DisplayName("addInvoiceItem inserts item and updates invoice totals + status ISSUED")
    void addInvoiceItem_insertsAndRecalculates() throws Exception {

        Invoice inv = dao.getOrCreateInvoiceForReservation(reservationId);
        invoiceId = inv.getInvoiceId();

        // Act
        dao.addInvoiceItem(invoiceId, "Extra Bed", 2, 3000.00, "JUnit note");

        // Assert items
        List<InvoiceItem> items = dao.getInvoiceItems(invoiceId);
        assertNotNull(items);
        assertTrue(items.size() >= 1);

        InvoiceItem found = items.stream()
                .filter(it -> "Extra Bed".equals(it.getItemName()))
                .findFirst()
                .orElse(null);

        assertNotNull(found);
        itemId1 = found.getItemId();

        assertEquals(2, found.getQty());
        assertEquals(new BigDecimal("3000.00"), found.getUnitPrice().setScale(2));
        assertEquals(new BigDecimal("6000.00"), found.getAmount().setScale(2));

        Invoice updated = dao.getInvoiceById(invoiceId);
        assertNotNull(updated);
        assertEquals("ISSUED", updated.getInvoiceStatus()); 
        assertTrue(updated.getExtrasTotal().doubleValue() >= 6000.00);
        assertTrue(updated.getTotalAmount().doubleValue() >= updated.getRoomCost().doubleValue());
    }

    @Test
    @DisplayName("removeInvoiceItem deletes item and totals reduce")
    void removeInvoiceItem_deletesAndRecalculates() throws Exception {

        Invoice inv = dao.getOrCreateInvoiceForReservation(reservationId);
        invoiceId = inv.getInvoiceId();

        dao.addInvoiceItem(invoiceId, "Laundry", 1, 1500.00, null);

        Invoice before = dao.getInvoiceById(invoiceId);
        assertNotNull(before);
        double beforeExtras = before.getExtrasTotal().doubleValue();

        
        List<InvoiceItem> items = dao.getInvoiceItems(invoiceId);
        InvoiceItem laundry = items.stream()
                .filter(it -> "Laundry".equals(it.getItemName()))
                .findFirst()
                .orElse(null);

        assertNotNull(laundry);
        int itemId = laundry.getItemId();

        dao.removeInvoiceItem(itemId, invoiceId);

        List<InvoiceItem> afterItems = dao.getInvoiceItems(invoiceId);
        boolean stillThere = afterItems.stream().anyMatch(it -> it.getItemId() == itemId);
        assertFalse(stillThere);

        Invoice after = dao.getInvoiceById(invoiceId);
        assertNotNull(after);
        assertTrue(after.getExtrasTotal().doubleValue() <= beforeExtras);
    }

    @Test
    @DisplayName("invoiceBelongsToEmail returns true for correct guest email and false for wrong email")
    void invoiceBelongsToEmail_checksOwnership() throws Exception {

        Invoice inv = dao.getOrCreateInvoiceForReservation(reservationId);
        invoiceId = inv.getInvoiceId();

        assertTrue(dao.invoiceBelongsToEmail(invoiceId, guestEmail));
        assertFalse(dao.invoiceBelongsToEmail(invoiceId, "wrong_" + guestEmail));
    }

    @Test
    @DisplayName("countInvoicesUpdatedAfter counts invoices after a lastSeen timestamp")
    void countInvoicesUpdatedAfter_countsCorrectly() throws Exception {

        Timestamp lastSeen = Timestamp.from(Instant.now().minusSeconds(3600));

        Invoice inv = dao.getOrCreateInvoiceForReservation(reservationId);
        invoiceId = inv.getInvoiceId();

        int count = dao.countInvoicesUpdatedAfter(guestEmail, lastSeen);
        assertTrue(count >= 1);
    }

    // --------------------------- Helpers: inserts & cleanup ---------------------------

    private Integer insertRoomRow(String roomNumber, BigDecimal nightlyRate) throws Exception {
        String sql =
                "INSERT INTO rooms (room_number, floor_no, type_name, capacity, nightly_rate, description, is_active, status, notes, created_at) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, roomNumber);
            ps.setInt(2, 1);
            ps.setString(3, "Standard");
            ps.setInt(4, 2);
            ps.setBigDecimal(5, nightlyRate);
            ps.setString(6, "JUnit invoice test room");
            ps.setInt(7, 1);
            ps.setString(8, "AVAILABLE");
            ps.setString(9, "Created by JUnit");
            ps.setTimestamp(10, Timestamp.from(Instant.now()));

            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return null;
    }

    private Integer insertReservationRow(int roomId, String roomNumber, String email) throws Exception {
        String sql =
                "INSERT INTO reservations (" +
                "room_id, room_number, guest_name, guest_phone, guest_email, guest_nic_passport, " +
                "check_in_date, check_out_date, number_of_guests, reservation_status, created_by, created_at" +
                ") VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, roomId);
            ps.setString(2, roomNumber);
            ps.setString(3, "JUnit Guest");
            ps.setString(4, "0770000000");
            ps.setString(5, email);
            ps.setString(6, "NIC123");

            // nights >= 1
            ps.setDate(7, Date.valueOf("2026-03-10"));
            ps.setDate(8, Date.valueOf("2026-03-12"));
            ps.setInt(9, 2);
            ps.setString(10, "CHECKED_IN");

            ps.setNull(11, Types.INTEGER);

            ps.setTimestamp(12, Timestamp.from(Instant.now()));

            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return null;
    }

    private void deletePaymentByInvoiceId(Integer invId) throws Exception {
        if (invId == null) return;
        String sql = "DELETE FROM payments WHERE invoice_id = ?";
        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, invId);
            ps.executeUpdate();
        }
    }

    private void deleteInvoiceItemsByInvoiceId(Integer invId) throws Exception {
        if (invId == null) return;
        String sql = "DELETE FROM invoice_items WHERE invoice_id = ?";
        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, invId);
            ps.executeUpdate();
        }
    }

    private void deleteInvoiceById(Integer invId) throws Exception {
        if (invId == null) return;
        String sql = "DELETE FROM invoices WHERE invoice_id = ?";
        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, invId);
            ps.executeUpdate();
        }
    }

    private void deleteReservationById(Integer resId) throws Exception {
        if (resId == null) return;
        String sql = "DELETE FROM reservations WHERE reservation_id = ?";
        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, resId);
            ps.executeUpdate();
        }
    }

    private void deleteRoomById(Integer rId) throws Exception {
        if (rId == null) return;
        String sql = "DELETE FROM rooms WHERE room_id = ?";
        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, rId);
            ps.executeUpdate();
        }
    }
}