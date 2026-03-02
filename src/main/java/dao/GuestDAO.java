package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import model.GuestSummary;
import util.DBUtil;
import java.util.ArrayList;
import java.util.List;
import model.Guest;


public class GuestDAO {

    public boolean emailExists(String email) throws Exception {
        String sql = "SELECT 1 FROM guest_reg WHERE guest_email = ? LIMIT 1";
        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public boolean registerGuest(Guest guest) throws Exception {
        String sql = "INSERT INTO guest_reg (guest_email, guest_password) VALUES (?, ?)";
        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, guest.getGuestEmail());
            ps.setString(2, guest.getGuestPassword());
            return ps.executeUpdate() > 0;
        }
    }
    public Guest loginGuest(String email, String password) throws Exception {
        String sql = "SELECT guest_id, guest_email, guest_password FROM guest_reg WHERE guest_email = ? AND guest_password = ? LIMIT 1";

        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, email);
            ps.setString(2, password);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Guest g = new Guest();
                    g.setGuestId(rs.getInt("guest_id"));
                    g.setGuestEmail(rs.getString("guest_email"));
                    g.setGuestPassword(rs.getString("guest_password"));
                    return g;
                }
                return null;
            }
        }
    }
    
        public List<GuestSummary> getGuestSummariesFromReservations() throws Exception {

            String sql =
                    "SELECT x.guest_email, x.guest_name, x.guest_phone, x.guest_nic_passport, " +
                    "       x.room_number, x.reservation_status, x.last_date, x.total_res " +
                    "FROM ( " +
                    "   SELECT r.guest_email, r.guest_name, r.guest_phone, r.guest_nic_passport, " +
                    "          r.room_number, r.reservation_status, " +
                    "          DATE(r.created_at) AS last_date, " +
                    "          COUNT(*) OVER (PARTITION BY r.guest_email) AS total_res, " +
                    "          ROW_NUMBER() OVER (PARTITION BY r.guest_email ORDER BY r.created_at DESC, r.reservation_id DESC) AS rn " +
                    "   FROM reservations r " +
                    "   WHERE r.guest_email IS NOT NULL AND r.guest_email <> '' " +
                    ") x " +
                    "WHERE x.rn = 1 " +
                    "ORDER BY x.last_date DESC, x.guest_email ASC";

            List<GuestSummary> list = new ArrayList<>();

            try (Connection con = DBUtil.getConnection();
                 PreparedStatement ps = con.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {
                    GuestSummary g = new GuestSummary();
                    g.setGuestEmail(rs.getString("guest_email"));
                    g.setGuestName(rs.getString("guest_name"));
                    g.setGuestPhone(rs.getString("guest_phone"));
                    g.setGuestNicPassport(rs.getString("guest_nic_passport"));

                    g.setLastRoomNumber(rs.getString("room_number"));
                    g.setLatestStatus(rs.getString("reservation_status"));
                    g.setLastReservationDate(rs.getDate("last_date"));
                    g.setTotalReservations(rs.getInt("total_res"));

                    list.add(g);
                }
            }

            return list;
        }
    }

