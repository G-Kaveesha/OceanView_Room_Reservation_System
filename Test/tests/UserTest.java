package tests;

import static org.junit.jupiter.api.Assertions.*;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import model.User;

public class UserTest {

    @Test
    @DisplayName("User setters and getters should store and return correct values")
    void settersAndGetters_shouldWorkCorrectly() {

        // Arrange
        User user = new User();

        // Act
        user.setUserId(101);
        user.setEmail("admin@oceanview.com");
        user.setPassword("securePass123");
        user.setRole("MANAGER");
        user.setFullName("Ocean View Manager");
        user.setPhone("0771234567");
        user.setActive(true);
        user.setCreatedAt("2026-03-03");

        // Assert
        assertAll("Verify all user properties",
                () -> assertEquals(101, user.getUserId()),
                () -> assertEquals("admin@oceanview.com", user.getEmail()),
                () -> assertEquals("securePass123", user.getPassword()),
                () -> assertEquals("MANAGER", user.getRole()),
                () -> assertEquals("Ocean View Manager", user.getFullName()),
                () -> assertEquals("0771234567", user.getPhone()),
                () -> assertTrue(user.isActive()),
                () -> assertEquals("2026-03-03", user.getCreatedAt())
        );
    }

    @Test
    @DisplayName("New User object should have default values")
    void defaultValues_shouldBeCorrect() {

        // Arrange
        User user = new User();

        // Assert
        assertAll("Verify default state",
                () -> assertEquals(0, user.getUserId()),
                () -> assertNull(user.getEmail()),
                () -> assertNull(user.getPassword()),
                () -> assertNull(user.getRole()),
                () -> assertNull(user.getFullName()),
                () -> assertNull(user.getPhone()),
                () -> assertFalse(user.isActive()), 
                () -> assertNull(user.getCreatedAt())
        );
    }

    @Test
    @DisplayName("User active flag should toggle correctly")
    void activeFlag_shouldChangeCorrectly() {

        User user = new User();

        user.setActive(false);
        assertFalse(user.isActive());

        user.setActive(true);
        assertTrue(user.isActive());
    }
}