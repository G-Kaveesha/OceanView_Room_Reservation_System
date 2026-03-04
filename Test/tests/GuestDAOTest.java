package tests;

import static org.junit.jupiter.api.Assertions.*;

import java.math.BigDecimal;
import java.sql.*;
import java.time.Instant;
import java.util.List;

import org.junit.jupiter.api.*;

import dao.GuestDAO;
import model.Guest;
import model.GuestSummary;
import util.DBUtil;

public class GuestDAOTest {

    @BeforeAll
    static void useTestDb() {
        System.setProperty("db.url",
            "jdbc:mysql://localhost:3306/ocean_view_resort_test?useSSL=false&serverTimezone=Asia/Colombo");
        System.setProperty("db.user", "root");
        System.setProperty("db.pass", "Root*234");
    }

    private GuestDAO dao;

    private String testEmail;
    private final String testPassword = "test123";

    private Integer insertedReservationId1 = null;
    private Integer insertedReservationId2 = null;

    private Integer insertedRoomId = null;

    @BeforeEach
    void setUp() throws Exception {
        dao = new GuestDAO();
        testEmail = "junit_" + System.currentTimeMillis() + "@test.com";

        insertedRoomId = insertRoomRow("J-" + System.currentTimeMillis());
        assertNotNull(insertedRoomId);
        assertTrue(insertedRoomId > 0);
    }

    @AfterEach
    void tearDown() throws Exception {
        deleteReservationById(insertedReservationId1);
        deleteReservationById(insertedReservationId2);
        deleteGuestByEmail(testEmail);
        deleteRoomById(insertedRoomId);
    }

    @Test
    @DisplayName("emailExists should return false for non-existing email")
    void emailExists_nonExisting_returnsFalse() throws Exception {
        assertFalse(dao.emailExists("no_such_user_" + System.currentTimeMillis() + "@test.com"));
    }

    @Test
    @DisplayName("registerGuest should insert a new guest and emailExists becomes true")
    void registerGuest_insertsRow() throws Exception {
        Guest g = new Guest();
        g.setGuestEmail(testEmail);
        g.setGuestPassword(testPassword);

        boolean inserted = dao.registerGuest(g);

        assertTrue(inserted);
        assertTrue(dao.emailExists(testEmail));
    }

    @Test
    @DisplayName("loginGuest returns Guest for valid credentials")
    void loginGuest_validCredentials_returnsGuest() throws Exception {
        Guest g = new Guest();
        g.setGuestEmail(testEmail);
        g.setGuestPassword(testPassword);
        assertTrue(dao.registerGuest(g));

        Guest logged = dao.loginGuest(testEmail, testPassword);

        assertNotNull(logged);
        assertTrue(logged.getGuestId() > 0);
        assertEquals(testEmail, logged.getGuestEmail());
        assertEquals(testPassword, logged.getGuestPassword());
    }

    @Test
    @DisplayName("loginGuest returns null for invalid credentials")
    void loginGuest_invalidCredentials_returnsNull() throws Exception {
        Guest logged = dao.loginGuest("wrong@test.com", "wrong");
        assertNull(logged);
    }

    @Test
    @DisplayName("getGuestSummariesFromReservations returns latest reservation and total count per guest")
    void guestSummariesFromReservations_returnsLatestAndCount() throws Exception {

        insertedReservationId1 = insertReservationRow(
                insertedRoomId,
                testEmail, "JUnit Guest", "0770000000", "NIC123",
                "A-101", "PENDING",
                Timestamp.from(Instant.now().minusSeconds(3600))
        );

        insertedReservationId2 = insertReservationRow(
                insertedRoomId,
                testEmail, "JUnit Guest", "0770000000", "NIC123",
                "A-102", "CONFIRMED",
                Timestamp.from(Instant.now())
        );

        List<GuestSummary> list = dao.getGuestSummariesFromReservations();

        GuestSummary gs = list.stream()
                .filter(x -> testEmail.equals(x.getGuestEmail()))
                .findFirst()
                .orElse(null);

        assertNotNull(gs);
        assertEquals("JUnit Guest", gs.getGuestName());
        assertEquals("0770000000", gs.getGuestPhone());
        assertEquals("NIC123", gs.getGuestNicPassport());
        assertEquals("A-102", gs.getLastRoomNumber());
        assertEquals("CONFIRMED", gs.getLatestStatus());
        assertEquals(2, gs.getTotalReservations());
        assertNotNull(gs.getLastReservationDate());
    }

    // ----------------------- Helpers -----------------------

    private void deleteGuestByEmail(String email) throws Exception {
        String sql = "DELETE FROM guest_reg WHERE guest_email = ?";
        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.executeUpdate();
        }
    }

    private Integer insertRoomRow(String roomNumber) throws Exception {
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
            ps.setString(6, "JUnit test room");
            ps.setInt(7, 1); 
            ps.setString(8, "AVAILABLE");
            ps.setString(9, "Created for JUnit");
            ps.setTimestamp(10, Timestamp.from(Instant.now()));

            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return null;
    }

    private void deleteRoomById(Integer roomId) throws Exception {
        if (roomId == null) return;
        String sql = "DELETE FROM rooms WHERE room_id = ?";
        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, roomId);
            ps.executeUpdate();
        }
    }

    private Integer insertReservationRow(
            int roomId,
            String email, String name, String phone, String nic,
            String roomNumber, String status, Timestamp createdAt
    ) throws Exception {

        String sql =
                "INSERT INTO reservations (" +
                "room_id, room_number, guest_name, guest_phone, guest_email, guest_nic_passport, " +
                "check_in_date, check_out_date, number_of_guests, reservation_status, created_by, created_at" +
                ") VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, roomId);
            ps.setString(2, roomNumber);
            ps.setString(3, name);
            ps.setString(4, phone);
            ps.setString(5, email);
            ps.setString(6, nic);

            ps.setDate(7, Date.valueOf("2026-03-10"));
            ps.setDate(8, Date.valueOf("2026-03-12"));
            ps.setInt(9, 2);

            ps.setString(10, status);
            ps.setNull(11, Types.INTEGER);

            ps.setTimestamp(12, createdAt);

            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getInt(1);
            }
        }

        return null;
    }

    private void deleteReservationById(Integer id) throws Exception {
        if (id == null) return;

        String sql = "DELETE FROM reservations WHERE reservation_id = ?";
        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }
}