package tests;

import static org.junit.jupiter.api.Assertions.*;

import java.util.ArrayList;
import java.util.List;

import org.junit.jupiter.api.Test;

import model.Invoice;
import model.InvoiceBundle;
import model.InvoiceItem;
import model.ReservationRequest;

class InvoiceBundleTest {

    @Test
    void defaultConstructor_shouldInitializeItemsList() {
        // Act
        InvoiceBundle bundle = new InvoiceBundle();
        // Assert
        assertNotNull(bundle);
        assertNotNull(bundle.getItems());   
        assertTrue(bundle.getItems().isEmpty());
    }

    @Test
    void settersAndGetters_shouldStoreInvoiceAndReservation() {
        // Arrange
        InvoiceBundle bundle = new InvoiceBundle();
        Invoice invoice = new Invoice();
        ReservationRequest reservation = new ReservationRequest();
        // Act
        bundle.setInvoice(invoice);
        bundle.setReservation(reservation);
        // Assert
        assertEquals(invoice, bundle.getInvoice());
        assertEquals(reservation, bundle.getReservation());
    }

    @Test
    void nightlyRate_shouldStoreCorrectValue() {
        // Arrange
        InvoiceBundle bundle = new InvoiceBundle();
        // Act
        bundle.setNightlyRate(25000.50);
        // Assert
        assertEquals(25000.50, bundle.getNightlyRate());
    }

    @Test
    void setItems_shouldReplaceItemsListCorrectly() {
        // Arrange
        InvoiceBundle bundle = new InvoiceBundle();
        List<InvoiceItem> newItems = new ArrayList<>();

        newItems.add(new InvoiceItem());
        newItems.add(new InvoiceItem());

        // Act
        bundle.setItems(newItems);

        // Assert
        assertEquals(2, bundle.getItems().size());
        assertEquals(newItems, bundle.getItems());
    }

    @Test
    void itemsList_shouldAllowAddingItems() {
        // Arrange
        InvoiceBundle bundle = new InvoiceBundle();
        InvoiceItem item = new InvoiceItem();

        // Act
        bundle.getItems().add(item);

        // Assert
        assertFalse(bundle.getItems().isEmpty());
        assertEquals(1, bundle.getItems().size());
        assertEquals(item, bundle.getItems().get(0));
    }
}