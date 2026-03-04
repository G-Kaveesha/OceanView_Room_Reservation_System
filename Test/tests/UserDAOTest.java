package tests;

import static org.junit.jupiter.api.Assertions.*;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.List;

import org.junit.jupiter.api.*;

import dao.UserDAO;
import model.User;
import util.DBUtil;

public class UserDAOTest {

    @BeforeAll
    static void useTestDb() {
        System.setProperty("db.url",
            "jdbc:mysql://localhost:3306/ocean_view_resort_test?useSSL=false&serverTimezone=Asia/Colombo");
        System.setProperty("db.user", "root");
        System.setProperty("db.pass", "Root*234");
    }

    private UserDAO dao;

    private String testEmail;
    private final String testPassword = "pass123";
    private Integer insertedUserId = null;

    @BeforeEach
    void setUp() {
        dao = new UserDAO();
        testEmail = "junit_user_" + System.currentTimeMillis() + "@test.com";
        insertedUserId = null;
    }

    @AfterEach
    void tearDown() throws Exception {
        if (insertedUserId != null) {
            deleteUserById(insertedUserId);
        }
        deleteUserByEmail(testEmail);
    }

    @Test
    @DisplayName("emailExists returns false for a non-existing email")
    void emailExists_nonExisting_returnsFalse() {
        String email = "no_such_user_" + System.currentTimeMillis() + "@test.com";
        assertFalse(dao.emailExists(email));
    }

    @Test
    @DisplayName("addEmployee inserts a user and emailExists becomes true")
    void addEmployee_insertsRow() throws Exception {
        User u = new User();
        u.setEmail(testEmail);
        u.setPassword(testPassword);
        u.setRole("RECEPTIONIST");
        u.setFullName("JUnit Employee");
        u.setPhone("0771111111");
        u.setActive(true);

        assertTrue(dao.addEmployee(u));
        assertTrue(dao.emailExists(testEmail));

        insertedUserId = findUserIdByEmail(testEmail);
        assertNotNull(insertedUserId);
        assertTrue(insertedUserId > 0);
    }

    @Test
    @DisplayName("login returns user when credentials are valid and is_active=1")
    void login_validCredentials_returnsUser() throws Exception {
        
        User u = new User();
        u.setEmail(testEmail);
        u.setPassword(testPassword);
        u.setRole("MANAGER");
        u.setFullName("JUnit Manager");
        u.setPhone(null);      
        u.setActive(true);

        assertTrue(dao.addEmployee(u));
        insertedUserId = findUserIdByEmail(testEmail);

        // Act
        User logged = dao.login(testEmail, testPassword);

        // Assert
        assertNotNull(logged);
        assertEquals(testEmail, logged.getEmail());
        assertEquals("MANAGER", logged.getRole());
        assertEquals("JUnit Manager", logged.getFullName());
        assertTrue(logged.isActive());
    }

    @Test
    @DisplayName("login returns null when is_active=0 even if credentials are correct")
    void login_inactiveUser_returnsNull() throws Exception {
       
        User u = new User();
        u.setEmail(testEmail);
        u.setPassword(testPassword);
        u.setRole("RECEPTIONIST");
        u.setFullName("JUnit Inactive");
        u.setPhone("0700000000");
        u.setActive(false);

        assertTrue(dao.addEmployee(u));
        insertedUserId = findUserIdByEmail(testEmail);

        // Act
        User logged = dao.login(testEmail, testPassword);

        // Assert
        assertNull(logged);
    }

    @Test
    @DisplayName("getAllEmployees returns a list and includes the inserted test user")
    void getAllEmployees_containsInsertedUser() throws Exception {
        // Arrange
        User u = new User();
        u.setEmail(testEmail);
        u.setPassword(testPassword);
        u.setRole("RECEPTIONIST");
        u.setFullName("JUnit List User");
        u.setPhone("0712345678");
        u.setActive(true);

        assertTrue(dao.addEmployee(u));
        insertedUserId = findUserIdByEmail(testEmail);

        // Act
        List<User> all = dao.getAllEmployees();

        // Assert
        assertNotNull(all);
        assertTrue(all.size() > 0);

        boolean found = all.stream().anyMatch(x -> testEmail.equals(x.getEmail()));
        assertTrue(found);
    }

    @Test
    @DisplayName("updateEmployee updates fields correctly")
    void updateEmployee_updatesRow() throws Exception {
       
        User u = new User();
        u.setEmail(testEmail);
        u.setPassword(testPassword);
        u.setRole("RECEPTIONIST");
        u.setFullName("JUnit Before Update");
        u.setPhone("0770000000");
        u.setActive(true);

        assertTrue(dao.addEmployee(u));
        insertedUserId = findUserIdByEmail(testEmail);
        assertNotNull(insertedUserId);

        User updated = new User();
        updated.setUserId(insertedUserId);
        updated.setEmail(testEmail); 
        updated.setPassword("newpass456");
        updated.setRole("MANAGER");
        updated.setFullName("JUnit After Update");
        updated.setPhone("");        
        updated.setActive(false);

        assertTrue(dao.updateEmployee(updated));
        assertNull(dao.login(testEmail, "newpass456"));
        assertTrue(dao.emailExists(testEmail));
    }

    @Test
    @DisplayName("deleteEmployee removes the user record")
    void deleteEmployee_deletesRow() throws Exception {
        
        User u = new User();
        u.setEmail(testEmail);
        u.setPassword(testPassword);
        u.setRole("RECEPTIONIST");
        u.setFullName("JUnit Delete User");
        u.setPhone("0722222222");
        u.setActive(true);

        assertTrue(dao.addEmployee(u));
        insertedUserId = findUserIdByEmail(testEmail);
        assertNotNull(insertedUserId);

        assertTrue(dao.deleteEmployee(insertedUserId));
        assertFalse(dao.emailExists(testEmail));

        insertedUserId = null;
    }


    private Integer findUserIdByEmail(String email) throws Exception {
        String sql = "SELECT user_id FROM user_accounts WHERE email = ? LIMIT 1";
        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("user_id");
            }
        }
        return null;
    }

    private void deleteUserById(Integer id) throws Exception {
        if (id == null) return;
        String sql = "DELETE FROM user_accounts WHERE user_id = ?";
        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }

    private void deleteUserByEmail(String email) throws Exception {
        String sql = "DELETE FROM user_accounts WHERE email = ?";
        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.executeUpdate();
        }
    }
}