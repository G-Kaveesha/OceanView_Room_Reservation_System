package dao;

import model.Room;
import util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RoomDAO {

    // CREATE
    public boolean addRoom(Room r) throws Exception {

        String sql = "INSERT INTO rooms " +
                "(room_number, floor_no, type_name, capacity, nightly_rate, description, is_active, room_image, status, notes) " +
                "VALUES (?,?,?,?,?,?,?,?,?,?)";

        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, r.getRoomNumber());

            if (r.getFloorNo() == null) ps.setNull(2, Types.INTEGER);
            else ps.setInt(2, r.getFloorNo());

            ps.setString(3, r.getTypeName());
            ps.setInt(4, r.getCapacity());
            ps.setDouble(5, r.getNightlyRate());

            if (isBlank(r.getDescription())) ps.setNull(6, Types.LONGVARCHAR);
            else ps.setString(6, r.getDescription().trim());

            ps.setInt(7, r.getIsActive());

            if (isBlank(r.getRoomImage())) ps.setNull(8, Types.VARCHAR);
            else ps.setString(8, r.getRoomImage().trim());

            ps.setString(9, "AVAILABLE");

            if (isBlank(r.getNotes())) ps.setNull(10, Types.LONGVARCHAR);
            else ps.setString(10, r.getNotes().trim());

            return ps.executeUpdate() > 0;
        }
    }

    //All rooms
    public List<Room> getAllRooms() throws Exception {

        List<Room> list = new ArrayList<>();
        String sql = "SELECT room_id, room_number, floor_no, type_name, capacity, nightly_rate, " +
                "description, is_active, room_image, status, notes, created_at, updated_at " +
                "FROM rooms ORDER BY room_id DESC";

        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapRoomFull(rs));
            }
        }
        return list;
    }

    //  One room by id
    public Room getRoomById(int roomId) throws Exception {

        String sql = "SELECT room_id, room_number, floor_no, type_name, capacity, nightly_rate, " +
                "description, is_active, room_image, status, notes, created_at, updated_at " +
                "FROM rooms WHERE room_id = ?";

        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, roomId);

            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                return mapRoomFull(rs);
            }
        }
    }

    // update details 
    public boolean updateRoomManager(Room r, String newImagePathOrNull) throws Exception {

        String sql;
        if (newImagePathOrNull == null) {
            sql = "UPDATE rooms SET room_number=?, floor_no=?, type_name=?, capacity=?, nightly_rate=?, " +
                    "description=?, is_active=?, notes=?, updated_at=NOW() " +
                    "WHERE room_id=?";
        } else {
            sql = "UPDATE rooms SET room_number=?, floor_no=?, type_name=?, capacity=?, nightly_rate=?, " +
                    "description=?, is_active=?, room_image=?, notes=?, updated_at=NOW() " +
                    "WHERE room_id=?";
        }

        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, r.getRoomNumber());

            if (r.getFloorNo() == null) ps.setNull(2, Types.INTEGER);
            else ps.setInt(2, r.getFloorNo());

            ps.setString(3, r.getTypeName());
            ps.setInt(4, r.getCapacity());
            ps.setDouble(5, r.getNightlyRate());

            if (isBlank(r.getDescription())) ps.setNull(6, Types.LONGVARCHAR);
            else ps.setString(6, r.getDescription().trim());

            ps.setInt(7, r.getIsActive());

            if (newImagePathOrNull == null) {
                if (isBlank(r.getNotes())) ps.setNull(8, Types.LONGVARCHAR);
                else ps.setString(8, r.getNotes().trim());

                ps.setInt(9, r.getRoomId());
            } else {
                ps.setString(8, newImagePathOrNull.trim());

                if (isBlank(r.getNotes())) ps.setNull(9, Types.LONGVARCHAR);
                else ps.setString(9, r.getNotes().trim());

                ps.setInt(10, r.getRoomId());
            }

            return ps.executeUpdate() > 0;
        }
    }

    // DELETE
    public boolean deleteRoom(int roomId) throws Exception {

        String sql = "DELETE FROM rooms WHERE room_id = ?";

        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, roomId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean roomNumberExistsOtherThan(String roomNumber, int excludeRoomId) throws Exception {

        String sql = "SELECT 1 FROM rooms WHERE room_number = ? AND room_id <> ? LIMIT 1";

        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, roomNumber);
            ps.setInt(2, excludeRoomId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public boolean roomNumberExists(String roomNumber) throws Exception {

        String sql = "SELECT 1 FROM rooms WHERE room_number = ? LIMIT 1";

        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, roomNumber);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public List<Room> getAvailableRooms() throws Exception {

        List<Room> list = new ArrayList<>();

        String sql = "SELECT room_id, room_number, floor_no, type_name, capacity, nightly_rate, " +
                "description, is_active, room_image, status, notes, created_at, updated_at " +
                "FROM rooms " +
                "WHERE status = 'AVAILABLE' AND is_active = 1 " +
                "ORDER BY room_id DESC";

        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapRoomFull(rs));
            }
        }
        return list;
    }

    public List<Room> getAvailableRoomsForDates(java.sql.Date checkIn, java.sql.Date checkOut) throws Exception {

        if (checkIn == null || checkOut == null) {
            throw new IllegalArgumentException("checkIn and checkOut dates are required.");
        }

        String sql =
                "SELECT r.room_id, r.room_number, r.floor_no, r.type_name, r.capacity, r.nightly_rate, " +
                "       r.description, r.is_active, r.room_image, r.status, r.notes, r.created_at, r.updated_at " +
                "FROM rooms r " +
                "WHERE r.is_active = 1 " +
                "  AND r.status NOT IN ('OCCUPIED','CLEANING','MAINTENANCE') " +
                "  AND NOT EXISTS ( " +
                "      SELECT 1 FROM reservations res " +
                "      WHERE res.room_id = r.room_id " +
                "        AND res.reservation_status IN ('PENDING','CONFIRMED','CHECKED_IN') " +
                "        AND res.check_in_date < ? " +
                "        AND res.check_out_date > ? " +
                "  ) " +
                "ORDER BY CAST(r.room_number AS UNSIGNED), r.room_number";

        List<Room> list = new ArrayList<>();

        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setDate(1, checkOut);
            ps.setDate(2, checkIn);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRoomFull(rs));
                }
            }
        }

        return list;
    }

    private Room mapRoomFull(ResultSet rs) throws SQLException {

        Room r = new Room();
        r.setRoomId(rs.getInt("room_id"));
        r.setRoomNumber(rs.getString("room_number"));

      
        Object floorObj = rs.getObject("floor_no");
        r.setFloorNo(floorObj == null ? null : (Integer) floorObj);

        r.setTypeName(rs.getString("type_name"));
        r.setCapacity(rs.getInt("capacity"));
        r.setNightlyRate(rs.getDouble("nightly_rate"));

        r.setDescription(rs.getString("description"));
        r.setIsActive(rs.getInt("is_active"));
        r.setRoomImage(rs.getString("room_image"));
        r.setStatus(rs.getString("status"));
        r.setNotes(rs.getString("notes"));

      
        try { r.setCreatedAt(rs.getTimestamp("created_at")); } catch (Exception ignore) {}
        try { r.setUpdatedAt(rs.getTimestamp("updated_at")); } catch (Exception ignore) {}

        return r;
    }

    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }
}