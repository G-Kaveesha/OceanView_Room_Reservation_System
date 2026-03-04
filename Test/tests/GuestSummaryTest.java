package tests;

import static org.junit.jupiter.api.Assertions.*;

import java.sql.Date;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import model.GuestSummary;

class GuestSummaryTest {
    private GuestSummary guestSummary;
    @BeforeEach
    void setUp() {
        guestSummary = new GuestSummary();
    }
    @Test
    void defaultValues_shouldBeNullOrZero() {
        assertAll("Default values",
            () -> assertNull(guestSummary.getGuestName()),
            () -> assertNull(guestSummary.getGuestPhone()),
            () -> assertNull(guestSummary.getGuestEmail()),
            () -> assertNull(guestSummary.getGuestNicPassport()),
            () -> assertEquals(0, guestSummary.getTotalReservations()),
            () -> assertNull(guestSummary.getLastReservationDate()),
            () -> assertNull(guestSummary.getLatestStatus()),
            () -> assertNull(guestSummary.getLastRoomNumber())
        );
    }
    @Test
    void settersAndGetters_shouldWorkCorrectly() {
        Date testDate = Date.valueOf("2026-03-01");

        guestSummary.setGuestName("Nimal Perera");
        guestSummary.setGuestPhone("0771234567");
        guestSummary.setGuestEmail("nimal@test.com");
        guestSummary.setGuestNicPassport("901234567V");
        guestSummary.setTotalReservations(5);
        guestSummary.setLastReservationDate(testDate);
        guestSummary.setLatestStatus("CONFIRMED");
        guestSummary.setLastRoomNumber("A-101");

        assertAll("Getter validation",
            () -> assertEquals("Nimal Perera", guestSummary.getGuestName()),
            () -> assertEquals("0771234567", guestSummary.getGuestPhone()),
            () -> assertEquals("nimal@test.com", guestSummary.getGuestEmail()),
            () -> assertEquals("901234567V", guestSummary.getGuestNicPassport()),
            () -> assertEquals(5, guestSummary.getTotalReservations()),
            () -> assertEquals(testDate, guestSummary.getLastReservationDate()),
            () -> assertEquals("CONFIRMED", guestSummary.getLatestStatus()),
            () -> assertEquals("A-101", guestSummary.getLastRoomNumber())
        );
    }
    @Test
    void updatingValues_shouldReplaceOldValues() {

        guestSummary.setGuestName("Old Name");
        guestSummary.setGuestName("New Name");
        assertEquals("New Name", guestSummary.getGuestName());
    }
    @Test
    void totalReservations_shouldAcceptPositiveNumber() {
        guestSummary.setTotalReservations(10);
        assertTrue(guestSummary.getTotalReservations() > 0);
    }
}