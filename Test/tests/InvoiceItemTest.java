package tests;

import static org.junit.jupiter.api.Assertions.*;

import java.math.BigDecimal;
import java.sql.Timestamp;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import model.InvoiceItem;

public class InvoiceItemTest {

    private InvoiceItem item;

    @BeforeEach
    void setUp() {
        item = new InvoiceItem();
    }

    @Test
    @DisplayName("Test default constructor creates non-null object")
    void testDefaultConstructor() {
        assertNotNull(item);
    }

    @Test
    @DisplayName("Test setters and getters store and return correct values")
    void testSettersAndGetters() {

        BigDecimal unitPrice = new BigDecimal("2500.50");
        BigDecimal amount = new BigDecimal("5001.00");
        Timestamp now = new Timestamp(System.currentTimeMillis());

        item.setItemId(1);
        item.setInvoiceId(10);
        item.setItemName("Room Service");
        item.setQty(2);
        item.setUnitPrice(unitPrice);
        item.setAmount(amount);
        item.setNote("Extra pillows requested");
        item.setAddedAt(now);

        assertAll("Verify all field values",
                () -> assertEquals(1, item.getItemId()),
                () -> assertEquals(10, item.getInvoiceId()),
                () -> assertEquals("Room Service", item.getItemName()),
                () -> assertEquals(2, item.getQty()),
                () -> assertEquals(unitPrice, item.getUnitPrice()),
                () -> assertEquals(amount, item.getAmount()),
                () -> assertEquals("Extra pillows requested", item.getNote()),
                () -> assertEquals(now, item.getAddedAt())
        );
    }

    @Test
    @DisplayName("Test BigDecimal precision is preserved")
    void testBigDecimalPrecision() {

        BigDecimal price = new BigDecimal("1234.5678");
        item.setUnitPrice(price);

        assertEquals(0, price.compareTo(item.getUnitPrice()));
    }

    @Test
    @DisplayName("Test null values are handled correctly")
    void testNullValues() {

        item.setItemName(null);
        item.setNote(null);
        item.setUnitPrice(null);
        item.setAmount(null);
        item.setAddedAt(null);

        assertNull(item.getItemName());
        assertNull(item.getNote());
        assertNull(item.getUnitPrice());
        assertNull(item.getAmount());
        assertNull(item.getAddedAt());
    }

    @Test
    @DisplayName("Test quantity accepts integer values")
    void testQuantityAssignment() {

        item.setQty(5);
        assertTrue(item.getQty() > 0);
        assertEquals(5, item.getQty());
    }
}