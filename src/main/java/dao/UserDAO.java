package dao;

import model.User;
import util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {

    // LOGIN
    public User login(String email, String password) {
        String sql = "SELECT user_id, email, password, role, full_name, phone, is_active, created_at " +
                     "FROM user_accounts WHERE email=? AND password=? AND is_active=1";

        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, email);
            ps.setString(2, password);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // CHECK DUPLICATE EMAIL
    public boolean emailExists(String email) {
        String sql = "SELECT 1 FROM user_accounts WHERE email=? LIMIT 1";

        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ADD EMPLOYEE
    public boolean addEmployee(User u) {
        String sql = "INSERT INTO user_accounts (email, password, role, full_name, phone, is_active) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, u.getEmail());
            ps.setString(2, u.getPassword());
            ps.setString(3, u.getRole());
            ps.setString(4, u.getFullName());

            if (u.getPhone() == null || u.getPhone().trim().isEmpty()) {
                ps.setNull(5, Types.VARCHAR);
            } else {
                ps.setString(5, u.getPhone());
            }

            ps.setInt(6, u.isActive() ? 1 : 0);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // GET ALL EMPLOYEES
    public List<User> getAllEmployees() {
        List<User> list = new ArrayList<>();

        String sql = "SELECT user_id, email, password, role, full_name, phone, is_active, created_at " +
                     "FROM user_accounts ORDER BY user_id DESC";

        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapRow(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // UPDATE EMPLOYEE
    public boolean updateEmployee(User u) {
        String sql = "UPDATE user_accounts SET email=?, password=?, role=?, full_name=?, phone=?, is_active=? " +
                     "WHERE user_id=?";

        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, u.getEmail());
            ps.setString(2, u.getPassword());
            ps.setString(3, u.getRole());
            ps.setString(4, u.getFullName());

            if (u.getPhone() == null || u.getPhone().trim().isEmpty()) {
                ps.setNull(5, Types.VARCHAR);
            } else {
                ps.setString(5, u.getPhone());
            }

            ps.setInt(6, u.isActive() ? 1 : 0);
            ps.setInt(7, u.getUserId());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // DELETE EMPLOYEE
    public boolean deleteEmployee(int id) {
        String sql = "DELETE FROM user_accounts WHERE user_id=?";

        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // helper mapper
    private User mapRow(ResultSet rs) throws Exception {
        User u = new User();
        u.setUserId(rs.getInt("user_id"));
        u.setEmail(rs.getString("email"));
        u.setPassword(rs.getString("password"));
        u.setRole(rs.getString("role"));
        u.setFullName(rs.getString("full_name"));
        u.setPhone(rs.getString("phone"));
        u.setActive(rs.getInt("is_active") == 1);

        Timestamp ts = rs.getTimestamp("created_at");
        u.setCreatedAt(ts == null ? "" : ts.toString());

        return u;
    }
}
