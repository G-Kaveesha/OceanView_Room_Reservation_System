package dao;

import model.ReservationRequest;
import util.DBUtil;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;


public class ReservationDAO {

    //  Walk-in check-in 
    public int createWalkInAndCheckIn(
            int roomId,
            String roomNumber,
            String guestName,
            String guestPhone,
            String guestEmail,
            String guestNicPassport,
            Date checkInDate,
            Date checkOutDate,
            int numberOfGuests,
            String specialRequests,
            Integer createdBy
    ) throws Exception {

        final String insertSql =
                "INSERT INTO reservations " +
                        "(room_id, room_number, guest_name, guest_phone, guest_email, guest_nic_passport, " +
                        " check_in_date, check_out_date, number_of_guests, reservation_status, created_by, special_requests) " +
                        "VALUES (?,?,?,?,?,?,?,?,?, 'CHECKED_IN', ?, ?)";

        final String updateRoomSql =
                "UPDATE rooms SET status = 'OCCUPIED' WHERE room_id = ?";

        try (Connection con = DBUtil.getConnection()) {
            con.setAutoCommit(false);
            try {
                validateRoomOperationallyAvailable(con, roomId);

                validateNoOverlap(con, roomId, checkInDate, checkOutDate);

                int reservationId = insertReservation(
                        con,
                        insertSql,
                        roomId,
                        roomNumber,
                        guestName,
                        guestPhone,
                        guestEmail,
                        guestNicPassport,
                        checkInDate,
                        checkOutDate,
                        numberOfGuests,
                        "CHECKED_IN",
                        createdBy,
                        specialRequests
                );

                updateRoomStatus(con, updateRoomSql, roomId, "OCCUPIED");

                con.commit();
                return reservationId;
            } catch (Exception ex) {
                con.rollback();
                throw ex;
            } finally {
                con.setAutoCommit(true);
            }
        }
    }

    // Customer booking request 
    public int createPendingReservation(
            int roomId,
            String roomNumber,
            String guestName,
            String guestPhone,
            String guestEmail,
            String guestNicPassport,
            Date checkInDate,
            Date checkOutDate,
            int numberOfGuests,
            String specialRequests,
            Integer createdBy
    ) throws Exception {

        final String insertSql =
                "INSERT INTO reservations " +
                        "(room_id, room_number, guest_name, guest_phone, guest_email, guest_nic_passport, " +
                        " check_in_date, check_out_date, number_of_guests, reservation_status, created_by, special_requests) " +
                        "VALUES (?,?,?,?,?,?,?,?,?, 'PENDING', ?, ?)";

        try (Connection con = DBUtil.getConnection()) {
            con.setAutoCommit(false);
            try {
                
                validateRoomOperationallyAvailable(con, roomId);

                
                validateNoOverlap(con, roomId, checkInDate, checkOutDate);

                int reservationId = insertReservation(
                        con,
                        insertSql,
                        roomId,
                        roomNumber,
                        guestName,
                        guestPhone,
                        guestEmail,
                        guestNicPassport,
                        checkInDate,
                        checkOutDate,
                        numberOfGuests,
                        "PENDING",
                        createdBy,
                        specialRequests
                );

                con.commit();
                return reservationId;
            } catch (Exception ex) {
                con.rollback();
                throw ex;
            } finally {
                con.setAutoCommit(true);
            }
        }
    }
    public boolean isRoomAvailable(int roomId, Date checkIn, Date checkOut) throws Exception {
        final String sql =
            "SELECT COUNT(*) FROM reservations " +
            "WHERE room_id = ? " +
            "AND reservation_status IN ('PENDING','CONFIRMED','CHECKED_IN') " +
            "AND check_in_date < ? " +
            "AND check_out_date > ?";

        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, roomId);
            ps.setDate(2, checkOut);
            ps.setDate(3, checkIn);

            try (ResultSet rs = ps.executeQuery()) {
                int count = rs.next() ? rs.getInt(1) : 0;
                return count == 0;
            }
        }
    }
    //  Pending requests 
    public List<ReservationRequest> getPendingRequests() throws Exception {
        return getReservationsByStatus("PENDING");
    }

    
    public List<ReservationRequest> getReservationsByStatus(String status) throws Exception {

        String sql =
                "SELECT reservation_id, room_id, room_number, guest_name, guest_phone, guest_email, guest_nic_passport, " +
                        "check_in_date, check_out_date, number_of_guests, reservation_status, created_at, updated_at " +
                        "FROM reservations " +
                        "WHERE reservation_status = ? " +
                        "ORDER BY created_at DESC, reservation_id DESC";

        List<ReservationRequest> list = new ArrayList<>();

        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, status);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapReservationRequest(rs));
                }
            }
        }
        return list;
    }

    
    public ReservationRequest getReservationById(int reservationId) throws Exception {

        String sql =
                "SELECT reservation_id, room_id, room_number, guest_name, guest_phone, guest_email, guest_nic_passport, " +
                        "check_in_date, check_out_date, number_of_guests, reservation_status, created_at, updated_at " +
                        "FROM reservations WHERE reservation_id = ?";

        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, reservationId);

            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                return mapReservationRequest(rs);
            }
        }
    }

    // Confirm PENDING 
    public void confirmReservation(int reservationId) throws Exception {

        final String lockSql =
                "SELECT reservation_id, room_id, reservation_status " +
                        "FROM reservations WHERE reservation_id = ? FOR UPDATE";

        final String updateResSql =
                "UPDATE reservations SET reservation_status = 'CONFIRMED' " +
                        "WHERE reservation_id = ? AND reservation_status = 'PENDING'";

        try (Connection con = DBUtil.getConnection()) {
            con.setAutoCommit(false);
            try {
                lockReservationAndGetRoomId(con, lockSql, reservationId, "PENDING");

                try (PreparedStatement ps = con.prepareStatement(updateResSql)) {
                    ps.setInt(1, reservationId);
                    int rows = ps.executeUpdate();
                    if (rows != 1) throw new SQLException("Failed to confirm reservation.");
                }

              

                con.commit();
            } catch (Exception ex) {
                con.rollback();
                throw ex;
            } finally {
                con.setAutoCommit(true);
            }
        }
    }

    // Cancel PENDING 
    public void cancelPendingReservation(int reservationId) throws Exception {

        final String lockSql =
                "SELECT reservation_id, room_id, reservation_status " +
                        "FROM reservations WHERE reservation_id = ? FOR UPDATE";

        final String cancelResSql =
                "UPDATE reservations SET reservation_status = 'CANCELLED' " +
                        "WHERE reservation_id = ? AND reservation_status = 'PENDING'";

        try (Connection con = DBUtil.getConnection()) {
            con.setAutoCommit(false);
            try {
                lockReservationAndGetRoomId(con, lockSql, reservationId, "PENDING");

                try (PreparedStatement ps = con.prepareStatement(cancelResSql)) {
                    ps.setInt(1, reservationId);
                    int rows = ps.executeUpdate();
                    if (rows != 1) throw new SQLException("Failed to cancel reservation.");
                }

                

                con.commit();
            } catch (Exception ex) {
                con.rollback();
                throw ex;
            } finally {
                con.setAutoCommit(true);
            }
        }
    }

   
    public List<ReservationRequest> getReservationsNotPending() throws Exception {

        String sql =
                "SELECT reservation_id, room_id, room_number, guest_name, guest_phone, guest_email, guest_nic_passport, " +
                        "check_in_date, check_out_date, number_of_guests, reservation_status, created_at, updated_at " +
                        "FROM reservations " +
                        "WHERE reservation_status <> ? " +
                        "ORDER BY created_at DESC, reservation_id DESC";

        List<ReservationRequest> list = new ArrayList<>();

        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, "PENDING");

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapReservationRequest(rs));
                }
            }
        }
        return list;
    }

    
    public int countByStatus(String status) throws Exception {

        String sql = "SELECT COUNT(*) FROM reservations WHERE reservation_status = ?";

        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, status);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    
    public List<ReservationRequest> getConfirmedReservationsByEmail(String email) throws Exception {

        String sql =
                "SELECT reservation_id, room_id, room_number, guest_name, guest_phone, guest_email, guest_nic_passport, " +
                        "check_in_date, check_out_date, number_of_guests, reservation_status, created_at, updated_at " +
                        "FROM reservations " +
                        "WHERE guest_email = ? AND reservation_status = 'CONFIRMED' " +
                        "ORDER BY updated_at DESC, reservation_id DESC";

        List<ReservationRequest> list = new ArrayList<>();

        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, email);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapReservationRequest(rs));
                }
            }
        }

        return list;
    }

    public int countConfirmedUpdatedAfter(String email, Timestamp lastSeen) throws Exception {

        String sql =
                "SELECT COUNT(*) FROM reservations " +
                        "WHERE guest_email = ? " +
                        "AND reservation_status = 'CONFIRMED' " +
                        "AND updated_at > ?";

        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, email);
            ps.setTimestamp(2, lastSeen);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    public List<ReservationRequest> getReservationsByGuestEmail(String email) throws Exception {

        String sql =
                "SELECT reservation_id, room_id, room_number, guest_name, guest_phone, guest_email, guest_nic_passport, " +
                        "check_in_date, check_out_date, number_of_guests, reservation_status, created_at, updated_at " +
                        "FROM reservations " +
                        "WHERE guest_email = ? " +
                        "ORDER BY created_at DESC, reservation_id DESC";

        List<ReservationRequest> list = new ArrayList<>();

        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, email);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapReservationRequest(rs));
                }
            }
        }

        return list;
    }

    public List<ReservationRequest> getActiveReservationsByGuestEmail(String email) throws Exception {

        String sql =
                "SELECT reservation_id, room_id, room_number, guest_name, guest_phone, guest_email, guest_nic_passport, " +
                        "check_in_date, check_out_date, number_of_guests, reservation_status, created_at, updated_at " +
                        "FROM reservations " +
                        "WHERE guest_email = ? AND reservation_status <> 'CANCELLED' " +
                        "ORDER BY created_at DESC, reservation_id DESC";

        List<ReservationRequest> list = new ArrayList<>();

        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, email);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapReservationRequest(rs));
                }
            }
        }

        return list;
    }

   
    public void checkInConfirmedReservation(int reservationId) throws Exception {

        final String lockSql =
                "SELECT reservation_id, room_id, reservation_status, check_in_date " +
                        "FROM reservations WHERE reservation_id = ? FOR UPDATE";

        final String updateReservationSql =
                "UPDATE reservations SET reservation_status = 'CHECKED_IN' " +
                        "WHERE reservation_id = ? AND reservation_status = 'CONFIRMED'";

        final String updateRoomSql =
                "UPDATE rooms SET status = 'OCCUPIED' WHERE room_id = ?";

        try (Connection con = DBUtil.getConnection()) {
            con.setAutoCommit(false);
            try {
                int roomId;
                Date checkInDate;

                
                try (PreparedStatement ps = con.prepareStatement(lockSql)) {
                    ps.setInt(1, reservationId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) throw new IllegalArgumentException("Reservation not found.");

                        String st = rs.getString("reservation_status");
                        if (st == null || !"CONFIRMED".equalsIgnoreCase(st)) {
                            throw new IllegalArgumentException("Only CONFIRMED reservations can be checked-in. Current: " + st);
                        }

                        roomId = rs.getInt("room_id");
                        checkInDate = rs.getDate("check_in_date");
                        if (checkInDate == null) throw new IllegalArgumentException("Check-in date is missing.");
                    }
                }

                
                java.time.LocalDate today = java.time.LocalDate.now();
                java.time.LocalDate ci = checkInDate.toLocalDate();

                if (!today.equals(ci)) {
                    throw new IllegalArgumentException("Check-in is allowed only on the check-in date: " + checkInDate);
                }

                try (PreparedStatement ps = con.prepareStatement(updateReservationSql)) {
                    ps.setInt(1, reservationId);
                    int rows = ps.executeUpdate();
                    if (rows != 1) throw new SQLException("Failed to check-in reservation.");
                }

                try (PreparedStatement ps = con.prepareStatement(updateRoomSql)) {
                    ps.setInt(1, roomId);
                    int rows = ps.executeUpdate();
                    if (rows != 1) throw new SQLException("Failed to update room status.");
                }

                con.commit();
            } catch (Exception ex) {
                con.rollback();
                throw ex;
            } finally {
                con.setAutoCommit(true);
            }
        }
    }

    // Helpers
    
    private void validateRoomOperationallyAvailable(Connection con, int roomId) throws Exception {

        final String checkRoomSql =
                "SELECT status, is_active FROM rooms WHERE room_id = ? FOR UPDATE";

        try (PreparedStatement ps = con.prepareStatement(checkRoomSql)) {
            ps.setInt(1, roomId);

            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) throw new IllegalArgumentException("Room not found.");

                String status = rs.getString("status");
                int isActive = rs.getInt("is_active");

                if (isActive != 1) {
                    throw new IllegalArgumentException("Room is not active.");
                }

                if (status == null) status = "AVAILABLE";

                if ("OCCUPIED".equalsIgnoreCase(status)
                        || "MAINTENANCE".equalsIgnoreCase(status)
                        || "CLEANING".equalsIgnoreCase(status)) {
                    throw new IllegalArgumentException("Room is not available now. Current status: " + status);
                }
            }
        }
    }

    
    private void validateNoOverlap(Connection con, int roomId, Date checkIn, Date checkOut) throws Exception {

        if (checkIn == null || checkOut == null) {
            throw new IllegalArgumentException("Check-in and check-out dates are required.");
        }
        if (!checkOut.toLocalDate().isAfter(checkIn.toLocalDate())) {
            throw new IllegalArgumentException("Check-out must be after check-in.");
        }

        final String sql =
                "SELECT COUNT(*) " +
                        "FROM reservations " +
                        "WHERE room_id = ? " +
                        "AND reservation_status IN ('PENDING','CONFIRMED','CHECKED_IN') " +
                        "AND check_in_date < ? " +
                        "AND check_out_date > ?";

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, roomId);
            ps.setDate(2, checkOut);
            ps.setDate(3, checkIn);

            try (ResultSet rs = ps.executeQuery()) {
                int count = (rs.next() ? rs.getInt(1) : 0);
                if (count > 0) {
                    throw new IllegalArgumentException("Room is already booked for selected dates.");
                }
            }
        }
    }

    private int insertReservation(
            Connection con,
            String insertSql,
            int roomId,
            String roomNumber,
            String guestName,
            String guestPhone,
            String guestEmail,
            String guestNicPassport,
            Date checkInDate,
            Date checkOutDate,
            int numberOfGuests,
            String reservationStatusLabel, 
            Integer createdBy,
            String specialRequests
    ) throws Exception {

        try (PreparedStatement ps = con.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, roomId);
            ps.setString(2, roomNumber);

            ps.setString(3, guestName);
            ps.setString(4, guestPhone);
            ps.setString(5, emptyToNull(guestEmail));
            ps.setString(6, emptyToNull(guestNicPassport));

            ps.setDate(7, checkInDate);
            ps.setDate(8, checkOutDate);
            ps.setInt(9, numberOfGuests);

            if (createdBy == null) ps.setNull(10, Types.INTEGER);
            else ps.setInt(10, createdBy);

            ps.setString(11, emptyToNull(specialRequests));

            int rows = ps.executeUpdate();
            if (rows != 1) {
                throw new SQLException("Failed to insert reservation (" + reservationStatusLabel + ").");
            }

            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (!keys.next()) throw new SQLException("No generated reservation_id returned.");
                return keys.getInt(1);
            }
        }
    }

    private void updateRoomStatus(Connection con, String updateSql, int roomId, String statusLabel) throws Exception {

        try (PreparedStatement ps = con.prepareStatement(updateSql)) {
            ps.setInt(1, roomId);
            int rows = ps.executeUpdate();
            if (rows != 1) {
                throw new SQLException("Failed to update room status to " + statusLabel + ".");
            }
        }
    }

    private int lockReservationAndGetRoomId(Connection con, String lockSql, int reservationId, String requiredStatus)
            throws Exception {

        try (PreparedStatement ps = con.prepareStatement(lockSql)) {
            ps.setInt(1, reservationId);

            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) throw new IllegalArgumentException("Reservation not found.");

                String status = rs.getString("reservation_status");
                if (status == null || !requiredStatus.equalsIgnoreCase(status)) {
                    throw new IllegalArgumentException("Reservation is not " + requiredStatus + ". Current: " + status);
                }

                return rs.getInt("room_id");
            }
        }
    }

    private ReservationRequest mapReservationRequest(ResultSet rs) throws SQLException {

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
        r.setCreatedAt(rs.getTimestamp("created_at"));
        r.setUpdatedAt(rs.getTimestamp("updated_at"));

        return r;
    }

    private String emptyToNull(String s) {
        if (s == null) return null;
        String t = s.trim();
        return t.isEmpty() ? null : t;
    }

}