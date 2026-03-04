package tests;

import static org.junit.jupiter.api.Assertions.*;

import java.sql.Date;
import java.sql.Timestamp;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import model.ReservationRequest;

class ReservationRequestTest {

    @Test
    @DisplayName("ReservationRequest: setters and getters should store and return correct values")
    void settersAndGetters_shouldWorkCorrectly() {
        ReservationRequest rr = new ReservationRequest();

        int reservationId = 101;
        int roomId = 12;
        String roomNumber = "A-102";

        String guestName = "Nimal Perera";
        String guestPhone = "0771234567";
        String guestEmail = "nimal@test.com";
        String guestNicPassport = "200012345678";

        Date checkIn = Date.valueOf("2026-03-10");
        Date checkOut = Date.valueOf("2026-03-12");
        int numberOfGuests = 2;

        String reservationStatus = "PENDING";
        Timestamp createdAt = Timestamp.valueOf("2026-03-03 10:15:30");
        Timestamp updatedAt = Timestamp.valueOf("2026-03-03 11:00:00");

        rr.setReservationId(reservationId);
        rr.setRoomId(roomId);
        rr.setRoomNumber(roomNumber);

        rr.setGuestName(guestName);
        rr.setGuestPhone(guestPhone);
        rr.setGuestEmail(guestEmail);
        rr.setGuestNicPassport(guestNicPassport);
        rr.setCheckInDate(checkIn);
        rr.setCheckOutDate(checkOut);
        rr.setNumberOfGuests(numberOfGuests);
        rr.setReservationStatus(reservationStatus);
        rr.setCreatedAt(createdAt);
        rr.setUpdatedAt(updatedAt);

        assertAll("All ReservationRequest fields should match",
                () -> assertEquals(reservationId, rr.getReservationId()),
                () -> assertEquals(roomId, rr.getRoomId()),
                () -> assertEquals(roomNumber, rr.getRoomNumber()),
                () -> assertEquals(guestName, rr.getGuestName()),
                () -> assertEquals(guestPhone, rr.getGuestPhone()),
                () -> assertEquals(guestEmail, rr.getGuestEmail()),
                () -> assertEquals(guestNicPassport, rr.getGuestNicPassport()),
                () -> assertEquals(checkIn, rr.getCheckInDate()),
                () -> assertEquals(checkOut, rr.getCheckOutDate()),
                () -> assertEquals(numberOfGuests, rr.getNumberOfGuests()),
                () -> assertEquals(reservationStatus, rr.getReservationStatus()),
                () -> assertEquals(createdAt, rr.getCreatedAt()),
                () -> assertEquals(updatedAt, rr.getUpdatedAt())
        );
    }

    @Test
    @DisplayName("ReservationRequest: default values should be null/zero before setting")
    void defaultValues_shouldBeNullOrZero() {
        ReservationRequest rr = new ReservationRequest();

        assertAll("Defaults",
                () -> assertEquals(0, rr.getReservationId()),
                () -> assertEquals(0, rr.getRoomId()),
                () -> assertEquals(0, rr.getNumberOfGuests()),

                () -> assertNull(rr.getRoomNumber()),
                () -> assertNull(rr.getGuestName()),
                () -> assertNull(rr.getGuestPhone()),
                () -> assertNull(rr.getGuestEmail()),
                () -> assertNull(rr.getGuestNicPassport()),
                () -> assertNull(rr.getCheckInDate()),
                () -> assertNull(rr.getCheckOutDate()),
                () -> assertNull(rr.getReservationStatus()),
                () -> assertNull(rr.getCreatedAt()),
                () -> assertNull(rr.getUpdatedAt())
        );
    }

    @Test
    @DisplayName("ReservationRequest: should allow updating fields (simulates edit/update flow)")
    void updatingFields_shouldOverwritePreviousValues() {
        ReservationRequest rr = new ReservationRequest();

        rr.setReservationStatus("PENDING");
        rr.setReservationStatus("CONFIRMED");

        rr.setNumberOfGuests(1);
        rr.setNumberOfGuests(3);

        Timestamp t1 = Timestamp.valueOf("2026-03-03 09:00:00");
        Timestamp t2 = Timestamp.valueOf("2026-03-03 12:00:00");

        rr.setUpdatedAt(t1);
        rr.setUpdatedAt(t2);

        assertAll("Updated values should reflect latest assignment",
                () -> assertEquals("CONFIRMED", rr.getReservationStatus()),
                () -> assertEquals(3, rr.getNumberOfGuests()),
                () -> assertEquals(t2, rr.getUpdatedAt())
        );
    }
}