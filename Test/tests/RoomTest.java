package tests;

import static org.junit.jupiter.api.Assertions.*;

import java.sql.Timestamp;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import model.Room;

class RoomTest {

    private Room room;

    @BeforeEach
    void setUp() {
        room = new Room();
    }

    @Test
    @DisplayName("Default Room object should be created successfully")
    void testRoomObjectCreation() {
        assertNotNull(room);
    }

    @Test
    @DisplayName("Setters and Getters should store and return correct values")
    void testSettersAndGetters() {

        Timestamp now = new Timestamp(System.currentTimeMillis());

        room.setRoomId(101);
        room.setRoomNumber("A-101");
        room.setFloorNo(1);
        room.setTypeName("Deluxe Sea View");
        room.setCapacity(3);
        room.setNightlyRate(25000.50);
        room.setDescription("Spacious room with ocean view");
        room.setIsActive(1);
        room.setRoomImage("room101.jpg");
        room.setStatus("AVAILABLE");
        room.setNotes("Recently renovated");
        room.setCreatedAt(now);
        room.setUpdatedAt(now);

        assertAll("Verify all room fields",
                () -> assertEquals(101, room.getRoomId()),
                () -> assertEquals("A-101", room.getRoomNumber()),
                () -> assertEquals(1, room.getFloorNo()),
                () -> assertEquals("Deluxe Sea View", room.getTypeName()),
                () -> assertEquals(3, room.getCapacity()),
                () -> assertEquals(25000.50, room.getNightlyRate(), 0.001),
                () -> assertEquals("Spacious room with ocean view", room.getDescription()),
                () -> assertEquals(1, room.getIsActive()),
                () -> assertEquals("room101.jpg", room.getRoomImage()),
                () -> assertEquals("AVAILABLE", room.getStatus()),
                () -> assertEquals("Recently renovated", room.getNotes()),
                () -> assertEquals(now, room.getCreatedAt()),
                () -> assertEquals(now, room.getUpdatedAt())
        );
    }

    @Test
    @DisplayName("Room should allow nullable fields (Integer and Timestamp)")
    void testNullableFields() {

        room.setFloorNo(null);
        room.setCreatedAt(null);
        room.setUpdatedAt(null);

        assertNull(room.getFloorNo());
        assertNull(room.getCreatedAt());
        assertNull(room.getUpdatedAt());
    }

    @Test
    @DisplayName("Nightly rate should store decimal values correctly")
    void testNightlyRatePrecision() {

        room.setNightlyRate(19999.999);

        assertEquals(19999.999, room.getNightlyRate(), 0.001);
    }

    @Test
    @DisplayName("Room status should update correctly")
    void testStatusUpdate() {

        room.setStatus("AVAILABLE");
        assertEquals("AVAILABLE", room.getStatus());

        room.setStatus("MAINTENANCE");
        assertEquals("MAINTENANCE", room.getStatus());
    }
}