package tests;

import static org.junit.jupiter.api.Assertions.*;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import model.Guest;

public class GuestTest {

    @Test
    @DisplayName("Test default constructor and setters")
    void defaultConstructorAndSetters_shouldSetValuesCorrectly() {

        Guest guest = new Guest();

        guest.setGuestId(1);
        guest.setGuestEmail("test@oceanview.com");
        guest.setGuestPassword("12345");

        assertAll("Guest properties",
                () -> assertEquals(1, guest.getGuestId()),
                () -> assertEquals("test@oceanview.com", guest.getGuestEmail()),
                () -> assertEquals("12345", guest.getGuestPassword())
        );
    }

    @Test
    @DisplayName("Test parameterized constructor")
    void parameterizedConstructor_shouldInitializeFields() {

        Guest guest = new Guest("guest@hotel.com", "securePass");
        
        assertAll("Guest constructor values",
                () -> assertEquals("guest@hotel.com", guest.getGuestEmail()),
                () -> assertEquals("securePass", guest.getGuestPassword())
        );
    }

    @Test
    @DisplayName("Guest object should not be null")
    void guestObject_shouldNotBeNull() {

        Guest guest = new Guest();

        assertNotNull(guest);
    }

    @Test
    @DisplayName("Email and password can be updated")
    void setters_shouldUpdateValuesCorrectly() {

        Guest guest = new Guest("old@mail.com", "oldPass");

        guest.setGuestEmail("new@mail.com");
        guest.setGuestPassword("newPass");

        assertEquals("new@mail.com", guest.getGuestEmail());
        assertEquals("newPass", guest.getGuestPassword());
    }
}