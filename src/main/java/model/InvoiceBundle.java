// File: src/model/InvoiceBundle.java
package model;

import java.util.ArrayList;
import java.util.List;

/**
 * Convenience wrapper for printing:
 * - invoice header totals
 * - reservation guest + stay data
 * - nightly rate (optional convenience)
 * - invoice items list
 */
public class InvoiceBundle {

    public Invoice invoice;
    public ReservationRequest reservation;

    public double nightlyRate; 

    public List<InvoiceItem> items = new ArrayList<>();

    public InvoiceBundle() {}

    public Invoice getInvoice() {
        return invoice;
    }
    public void setInvoice(Invoice invoice) {
        this.invoice = invoice;
    }

    public ReservationRequest getReservation() {
        return reservation;
    }
    public void setReservation(ReservationRequest reservation) {
        this.reservation = reservation;
    }

    public double getNightlyRate() {
        return nightlyRate;
    }
    public void setNightlyRate(double nightlyRate) {
        this.nightlyRate = nightlyRate;
    }

    public List<InvoiceItem> getItems() {
        return items;
    }
    public void setItems(List<InvoiceItem> items) {
        this.items = items;
    }
}