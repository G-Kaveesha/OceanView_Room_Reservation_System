package tests;

import static org.junit.jupiter.api.Assertions.*;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.time.Instant;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import model.Invoice;

class InvoiceTest {

    @Test
    @DisplayName("Default constructor should create empty Invoice object")
    void defaultConstructor_shouldCreateEmptyObject() {
        Invoice invoice = new Invoice();

        assertNotNull(invoice);
        assertEquals(0, invoice.getInvoiceId());
        assertEquals(0, invoice.getReservationId());
        assertEquals(0, invoice.getNights());
        assertNull(invoice.getRoomRate());
        assertNull(invoice.getRoomCost());
        assertNull(invoice.getExtrasTotal());
        assertNull(invoice.getServiceCharge());
        assertNull(invoice.getTaxAmount());
        assertNull(invoice.getDiscount());
        assertNull(invoice.getTotalAmount());
        assertNull(invoice.getInvoiceStatus());
        assertNull(invoice.getIssuedAt());
        assertNull(invoice.getUpdatedAt());
    }

    @Test
    @DisplayName("Setters and Getters should correctly store and return values")
    void settersAndGetters_shouldWorkCorrectly() {

        Invoice invoice = new Invoice();

        Timestamp now = Timestamp.from(Instant.now());

        invoice.setInvoiceId(101);
        invoice.setReservationId(2001);
        invoice.setNights(3);

        invoice.setRoomRate(new BigDecimal("15000.00"));
        invoice.setRoomCost(new BigDecimal("45000.00"));
        invoice.setExtrasTotal(new BigDecimal("5000.00"));
        invoice.setServiceCharge(new BigDecimal("2000.00"));
        invoice.setTaxAmount(new BigDecimal("3000.00"));
        invoice.setDiscount(new BigDecimal("1000.00"));
        invoice.setTotalAmount(new BigDecimal("54000.00"));

        invoice.setInvoiceStatus("PAID");
        invoice.setIssuedAt(now);
        invoice.setUpdatedAt(now);

        assertAll("Invoice field validation",
                () -> assertEquals(101, invoice.getInvoiceId()),
                () -> assertEquals(2001, invoice.getReservationId()),
                () -> assertEquals(3, invoice.getNights()),
                () -> assertEquals(new BigDecimal("15000.00"), invoice.getRoomRate()),
                () -> assertEquals(new BigDecimal("45000.00"), invoice.getRoomCost()),
                () -> assertEquals(new BigDecimal("5000.00"), invoice.getExtrasTotal()),
                () -> assertEquals(new BigDecimal("2000.00"), invoice.getServiceCharge()),
                () -> assertEquals(new BigDecimal("3000.00"), invoice.getTaxAmount()),
                () -> assertEquals(new BigDecimal("1000.00"), invoice.getDiscount()),
                () -> assertEquals(new BigDecimal("54000.00"), invoice.getTotalAmount()),
                () -> assertEquals("PAID", invoice.getInvoiceStatus()),
                () -> assertEquals(now, invoice.getIssuedAt()),
                () -> assertEquals(now, invoice.getUpdatedAt())
        );
    }

    @Test
    @DisplayName("BigDecimal values should maintain precision")
    void bigDecimalPrecision_shouldBeMaintained() {

        Invoice invoice = new Invoice();

        BigDecimal rate = new BigDecimal("12345.67");
        invoice.setRoomRate(rate);

        assertEquals(rate, invoice.getRoomRate());
    }
}