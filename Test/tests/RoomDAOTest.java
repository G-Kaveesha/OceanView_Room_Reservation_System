package tests;

import static org.junit.jupiter.api.Assertions.*;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.Timestamp;
import java.sql.Types;
import java.time.Instant;
import java.util.List;

import org.junit.jupiter.api.*;

import dao.RoomDAO;
import model.Room;
import util.DBUtil;

public class RoomDAOTest {

    @BeforeAll
    static void useTestDb() {
        System.setProperty("db.url",
            "jdbc:mysql://localhost:3306/ocean_view_resort_test?useSSL=false&serverTimezone=Asia/Colombo");
        System.setProperty("db.user", "root");
        System.setProperty("db.pass", "Root*234");
    }

    private RoomDAO dao;

    private Integer roomId1 = null;
    private Integer roomId2 = null;

    private Integer reservationId = null;

    @BeforeEach
    void setUp() {
        dao = new RoomDAO();
    }

    @AfterEach
    void tearDown() throws Exception {
        deleteReservationById(reservationId);
        deleteRoomById(roomId1);
        deleteRoomById(roomId2);
    }

    @Test
    @DisplayName("addRoom should insert a new room (status defaults to AVAILABLE)")
    void addRoom_insertsRow() throws Exception {
        Room r = buildRoom("J-" + System.currentTimeMillis(), 2, "Standard", 2, 15000);

        boolean ok = dao.addRoom(r);
        assertTrue(ok);

        roomId1 = getRoomIdByNumber(r.getRoomNumber());
        assertNotNull(roomId1);

        Room fromDb = dao.getRoomById(roomId1);
        assertNotNull(fromDb);
        assertEquals(r.getRoomNumber(), fromDb.getRoomNumber());
        assertEquals("AVAILABLE", fromDb.getStatus()); 
        assertEquals(1, fromDb.getIsActive());
    }

    @Test
    @DisplayName("getAllRooms should return list containing inserted room")
    void getAllRooms_containsInsertedRoom() throws Exception {
        Room r = buildRoom("J-" + System.currentTimeMillis(), 1, "Deluxe", 3, 22000);
        assertTrue(dao.addRoom(r));
        roomId1 = getRoomIdByNumber(r.getRoomNumber());

        List<Room> list = dao.getAllRooms();
        assertNotNull(list);
        assertTrue(list.stream().anyMatch(x -> x.getRoomId() == roomId1));
    }

    @Test
    @DisplayName("updateRoomManager should update fields without changing image when newImagePathOrNull is null")
    void updateRoomManager_updatesWithoutImage() throws Exception {
        Room r = buildRoom("J-" + System.currentTimeMillis(), 2, "Standard", 2, 15000);
        assertTrue(dao.addRoom(r));
        roomId1 = getRoomIdByNumber(r.getRoomNumber());

        Room toUpdate = dao.getRoomById(roomId1);
        assertNotNull(toUpdate);

        toUpdate.setTypeName("Suite");
        toUpdate.setCapacity(4);
        toUpdate.setNightlyRate(35000);
        toUpdate.setDescription("Updated by JUnit");
        toUpdate.setNotes("Note updated");
        toUpdate.setIsActive(1);

        boolean ok = dao.updateRoomManager(toUpdate, null);
        assertTrue(ok);

        Room updated = dao.getRoomById(roomId1);
        assertEquals("Suite", updated.getTypeName());
        assertEquals(4, updated.getCapacity());
        assertEquals(35000.0, updated.getNightlyRate());
        assertEquals("Updated by JUnit", updated.getDescription());
    }

    @Test
    @DisplayName("roomNumberExists and roomNumberExistsOtherThan should work correctly")
    void roomNumberExists_checks() throws Exception {
        String rn1 = "J-" + System.currentTimeMillis();
        String rn2 = "J-" + (System.currentTimeMillis() + 1);

        Room r1 = buildRoom(rn1, 1, "Standard", 2, 15000);
        Room r2 = buildRoom(rn2, 1, "Deluxe", 3, 22000);

        assertTrue(dao.addRoom(r1));
        assertTrue(dao.addRoom(r2));

        roomId1 = getRoomIdByNumber(rn1);
        roomId2 = getRoomIdByNumber(rn2);

        assertTrue(dao.roomNumberExists(rn1));
        assertTrue(dao.roomNumberExists(rn2));

        assertFalse(dao.roomNumberExistsOtherThan(rn1, roomId1));

        assertTrue(dao.roomNumberExistsOtherThan(rn2, roomId1));
    }

    @Test
    @DisplayName("getAvailableRooms should return only AVAILABLE and active rooms")
    void getAvailableRooms_filtersCorrectly() throws Exception {
        String rn1 = "J-" + System.currentTimeMillis();
        String rn2 = "J-" + (System.currentTimeMillis() + 1);

        Room available = buildRoom(rn1, 1, "Standard", 2, 15000);
        Room inactive = buildRoom(rn2, 1, "Standard", 2, 15000);
        inactive.setIsActive(0);

        assertTrue(dao.addRoom(available));
        assertTrue(dao.addRoom(inactive));

        roomId1 = getRoomIdByNumber(rn1);
        roomId2 = getRoomIdByNumber(rn2);

        List<Room> avail = dao.getAvailableRooms();

        assertTrue(avail.stream().anyMatch(x -> x.getRoomId() == roomId1));
        assertFalse(avail.stream().anyMatch(x -> x.getRoomId() == roomId2));
    }

    @Test
    @DisplayName("getAvailableRoomsForDates should exclude rooms with overlapping PENDING/CONFIRMED/CHECKED_IN reservations")
    void getAvailableRoomsForDates_excludesOverlappingReservation() throws Exception {
  
        String rn1 = "J-" + System.currentTimeMillis();
        String rn2 = "J-" + (System.currentTimeMillis() + 1);

        Room r1 = buildRoom(rn1, 1, "Standard", 2, 15000);
        Room r2 = buildRoom(rn2, 1, "Standard", 2, 15000);

        assertTrue(dao.addRoom(r1));
        assertTrue(dao.addRoom(r2));

        roomId1 = getRoomIdByNumber(rn1);
        roomId2 = getRoomIdByNumber(rn2);

        reservationId = insertReservationForRoom(
                roomId1, rn1,
                Date.valueOf("2026-03-10"),
                Date.valueOf("2026-03-12"),
                "CONFIRMED"
        );

        List<Room> available = dao.getAvailableRoomsForDates(
                Date.valueOf("2026-03-11"), 
                Date.valueOf("2026-03-13")
        );
        assertFalse(available.stream().anyMatch(x -> x.getRoomId() == roomId1));
        assertTrue(available.stream().anyMatch(x -> x.getRoomId() == roomId2));
    }

    @Test
    @DisplayName("deleteRoom should remove the room")
    void deleteRoom_removesRow() throws Exception {
        Room r = buildRoom("J-" + System.currentTimeMillis(), 2, "Standard", 2, 15000);
        assertTrue(dao.addRoom(r));
        roomId1 = getRoomIdByNumber(r.getRoomNumber());

        assertTrue(dao.deleteRoom(roomId1));
        Room fromDb = dao.getRoomById(roomId1);
        assertNull(fromDb);

        roomId1 = null;
    }

    // Helper builders 
    

    private Room buildRoom(String roomNumber, Integer floorNo, String type, int capacity, double rate) {
        Room r = new Room();
        r.setRoomNumber(roomNumber);
        r.setFloorNo(floorNo);
        r.setTypeName(type);
        r.setCapacity(capacity);
        r.setNightlyRate(rate);
        r.setDescription("JUnit room");
        r.setIsActive(1);
        r.setRoomImage(null);
        r.setNotes("JUnit note");
        return r;
    }

    private Integer getRoomIdByNumber(String roomNumber) throws Exception {
        String sql = "SELECT room_id FROM rooms WHERE room_number = ? LIMIT 1";
        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, roomNumber);
            try (ResultSet rs = ps.executeQuery()) {
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

    private Integer insertReservationForRoom(int roomId, String roomNumber, Date in, Date out, String status) throws Exception {
        
        String sql =
            "INSERT INTO reservations (room_id, room_number, guest_name, guest_phone, guest_email, guest_nic_passport, " +
            "check_in_date, check_out_date, number_of_guests, reservation_status, created_by, created_at) " +
            "VALUES (?,?,?,?,?,?,?,?,?,?,?,?)";

        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, roomId);
            ps.setString(2, roomNumber);
            ps.setString(3, "JUnit Guest");
            ps.setString(4, "0770000000");
            ps.setString(5, "junit_guest_" + System.currentTimeMillis() + "@test.com");
            ps.setString(6, "NIC123");
            ps.setDate(7, in);
            ps.setDate(8, out);
            ps.setInt(9, 2);
            ps.setString(10, status);
            ps.setNull(11, Types.INTEGER);
            ps.setTimestamp(12, Timestamp.from(Instant.now()));

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