package tests;

import static org.junit.jupiter.api.Assertions.*;

import java.math.BigDecimal;
import java.sql.*;
import java.time.Instant;
import java.time.LocalDate;
import java.util.List;

import org.junit.jupiter.api.*;

import dao.ReservationDAO;
import model.ReservationRequest;
import util.DBUtil;

public class ReservationDAOTest {

    @BeforeAll
    static void useTestDb() {
        System.setProperty("db.url",
            "jdbc:mysql://localhost:3306/ocean_view_resort_test?useSSL=false&serverTimezone=Asia/Colombo");
        System.setProperty("db.user", "root");
        System.setProperty("db.pass", "Root*234");
    }

    private ReservationDAO dao;

    private Integer roomId = null;
    private String roomNumber;

    private Integer resPendingId = null;
    private Integer resWalkInId = null;

    @BeforeEach
    void setUp() throws Exception {
        dao = new ReservationDAO();

        long shortTs = System.currentTimeMillis() % 1_000_000_000L;
        roomNumber = "J" + shortTs;

        roomId = insertRoom(roomNumber, "AVAILABLE", 1);
        assertNotNull(roomId);
        assertTrue(roomId > 0);
    }

    @AfterEach
    void tearDown() throws Exception {
        deleteReservation(resPendingId);
        deleteReservation(resWalkInId);
        deleteRoom(roomId);
    }

    // tests

    @Test
    @DisplayName("createPendingReservation inserts PENDING reservation (room status remains AVAILABLE)")
    void createPendingReservation_insertsPending() throws Exception {

        Date ci = Date.valueOf(LocalDate.now().plusDays(10));
        Date co = Date.valueOf(LocalDate.now().plusDays(12));

        resPendingId = dao.createPendingReservation(
                roomId, roomNumber,
                "JUnit Guest", "0770000000", "junit@test.com", "NIC123",
                ci, co, 2,
                "Near window", null
        );

        assertTrue(resPendingId > 0);

        ReservationRequest r = dao.getReservationById(resPendingId);
        assertNotNull(r);
        assertEquals("PENDING", r.getReservationStatus());
        assertEquals(roomId.intValue(), r.getRoomId());
        assertEquals(roomNumber, r.getRoomNumber());
        assertEquals("AVAILABLE", getRoomStatus(roomId));
    }

    @Test
    @DisplayName("createWalkInAndCheckIn inserts CHECKED_IN and updates room status to OCCUPIED")
    void createWalkInAndCheckIn_setsOccupied() throws Exception {

        Date ci = Date.valueOf(LocalDate.now());
        Date co = Date.valueOf(LocalDate.now().plusDays(1));

        resWalkInId = dao.createWalkInAndCheckIn(
                roomId, roomNumber,
                "WalkIn Guest", "0771111111", null, "NIC999",
                ci, co, 1,
                "Late check-in", null
        );

        assertTrue(resWalkInId > 0);

        ReservationRequest r = dao.getReservationById(resWalkInId);
        assertNotNull(r);
        assertEquals("CHECKED_IN", r.getReservationStatus());

        assertEquals("OCCUPIED", getRoomStatus(roomId));
    }

    @Test
    @DisplayName("createPendingReservation rejects overlapping booking")
    void createPendingReservation_overlap_throws() throws Exception {

        Date ci1 = Date.valueOf(LocalDate.now().plusDays(20));
        Date co1 = Date.valueOf(LocalDate.now().plusDays(22));

        resPendingId = dao.createPendingReservation(
                roomId, roomNumber,
                "Guest A", "0700000001", "a@test.com", "NIC-A",
                ci1, co1, 2,
                null, null
        );
        assertTrue(resPendingId > 0);

        Date ci2 = Date.valueOf(LocalDate.now().plusDays(21));
        Date co2 = Date.valueOf(LocalDate.now().plusDays(23));

        IllegalArgumentException ex = assertThrows(IllegalArgumentException.class, () -> {
            dao.createPendingReservation(
                    roomId, roomNumber,
                    "Guest B", "0700000002", "b@test.com", "NIC-B",
                    ci2, co2, 2,
                    null, null
            );
        });

        assertTrue(ex.getMessage().toLowerCase().contains("already booked"));
    }

    @Test
    @DisplayName("isRoomAvailable returns false for overlap and true for non-overlap")
    void isRoomAvailable_checksOverlapCorrectly() throws Exception {

        Date ci1 = Date.valueOf(LocalDate.now().plusDays(30));
        Date co1 = Date.valueOf(LocalDate.now().plusDays(32));

        resPendingId = dao.createPendingReservation(
                roomId, roomNumber,
                "Guest A", "0700000001", "a@test.com", "NIC-A",
                ci1, co1, 2,
                null, null
        );

        boolean availOverlap = dao.isRoomAvailable(
                roomId,
                Date.valueOf(LocalDate.now().plusDays(31)),
                Date.valueOf(LocalDate.now().plusDays(33))
        );
        assertFalse(availOverlap);

        boolean availBefore = dao.isRoomAvailable(
                roomId,
                Date.valueOf(LocalDate.now().plusDays(25)),
                Date.valueOf(LocalDate.now().plusDays(27))
        );
        assertTrue(availBefore);
    }

    @Test
    @DisplayName("confirmReservation updates status from PENDING to CONFIRMED")
    void confirmReservation_updatesStatus() throws Exception {

        Date ci = Date.valueOf(LocalDate.now().plusDays(40));
        Date co = Date.valueOf(LocalDate.now().plusDays(42));

        resPendingId = dao.createPendingReservation(
                roomId, roomNumber,
                "Guest Confirm", "0772222222", "confirm@test.com", "NIC-C",
                ci, co, 2,
                null, null
        );

        dao.confirmReservation(resPendingId);

        ReservationRequest r = dao.getReservationById(resPendingId);
        assertNotNull(r);
        assertEquals("CONFIRMED", r.getReservationStatus());
    }

    @Test
    @DisplayName("cancelPendingReservation updates status from PENDING to CANCELLED")
    void cancelPendingReservation_updatesStatus() throws Exception {

        Date ci = Date.valueOf(LocalDate.now().plusDays(50));
        Date co = Date.valueOf(LocalDate.now().plusDays(52));

        resPendingId = dao.createPendingReservation(
                roomId, roomNumber,
                "Guest Cancel", "0773333333", "cancel@test.com", "NIC-D",
                ci, co, 2,
                null, null
        );

        dao.cancelPendingReservation(resPendingId);

        ReservationRequest r = dao.getReservationById(resPendingId);
        assertNotNull(r);
        assertEquals("CANCELLED", r.getReservationStatus());

        assertEquals("AVAILABLE", getRoomStatus(roomId));
    }

    @Test
    @DisplayName("getReservationsByStatus returns only matching status")
    void getReservationsByStatus_filtersCorrectly() throws Exception {

        Date ci = Date.valueOf(LocalDate.now().plusDays(60));
        Date co = Date.valueOf(LocalDate.now().plusDays(62));

        resPendingId = dao.createPendingReservation(
                roomId, roomNumber,
                "Guest Status", "0774444444", "status@test.com", "NIC-E",
                ci, co, 2,
                null, null
        );

        List<ReservationRequest> pending = dao.getReservationsByStatus("PENDING");
        assertTrue(pending.stream().anyMatch(r -> r.getReservationId() == resPendingId));

        dao.confirmReservation(resPendingId);

        List<ReservationRequest> confirmed = dao.getReservationsByStatus("CONFIRMED");
        assertTrue(confirmed.stream().anyMatch(r -> r.getReservationId() == resPendingId));

        pending = dao.getReservationsByStatus("PENDING");
        assertTrue(pending.stream().noneMatch(r -> r.getReservationId() == resPendingId));
    }

    @Test
    @DisplayName("countByStatus increases after insert")
    void countByStatus_increasesAfterInsert() throws Exception {

        int before = dao.countByStatus("PENDING");

        Date ci = Date.valueOf(LocalDate.now().plusDays(70));
        Date co = Date.valueOf(LocalDate.now().plusDays(71));

        resPendingId = dao.createPendingReservation(
                roomId, roomNumber,
                "Guest Count", "0775555555", "count@test.com", "NIC-F",
                ci, co, 1,
                null, null
        );

        int after = dao.countByStatus("PENDING");
        assertEquals(before + 1, after);
    }

    //helpers

    private Integer insertRoom(String roomNumber, String status, int isActive) throws Exception {
        String sql =
            "INSERT INTO rooms (room_number, floor_no, type_name, capacity, nightly_rate, description, is_active, status, notes, created_at) " +
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, roomNumber);
            ps.setInt(2, 1);
            ps.setString(3, "Standard");
            ps.setInt(4, 2);
            ps.setBigDecimal(5, new BigDecimal("15000.00"));
            ps.setString(6, "JUnit room for ReservationDAO tests");
            ps.setInt(7, isActive);
            ps.setString(8, status);
            ps.setString(9, "JUnit note");
            ps.setTimestamp(10, Timestamp.from(Instant.now()));

            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getInt(1);
            }
            return null;
        }
    }

    private String getRoomStatus(int roomId) throws Exception {
        String sql = "SELECT status FROM rooms WHERE room_id = ?";
        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, roomId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getString("status") : null;
            }
        }
    }

    private void deleteRoom(Integer id) throws Exception {
        if (id == null) return;
        String sql = "DELETE FROM rooms WHERE room_id = ?";
        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }

    private void deleteReservation(Integer id) throws Exception {
        if (id == null) return;
        String sql = "DELETE FROM reservations WHERE reservation_id = ?";
        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }
}