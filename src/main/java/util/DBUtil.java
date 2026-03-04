package util;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBUtil {

    // Default (Production) DB settings
    private static final String DEFAULT_URL =
            "jdbc:mysql://localhost:3306/ocean_view_resort?useSSL=false&serverTimezone=Asia/Colombo";
    private static final String DEFAULT_USER = "root";
    private static final String DEFAULT_PASS = "Root*234";

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static Connection getConnection() throws Exception {

        String url = System.getProperty("db.url");
        String user = System.getProperty("db.user");
        String pass = System.getProperty("db.pass");

        if (url != null && !url.isBlank()) {
            
            return DriverManager.getConnection(url, user, pass);
        }

        return DriverManager.getConnection(DEFAULT_URL, DEFAULT_USER, DEFAULT_PASS);
    }
}