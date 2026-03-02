package model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class Invoice {

    private int invoiceId;
    private int reservationId;

    private int nights;
    private BigDecimal roomRate;     
    private BigDecimal roomCost;     

    private BigDecimal extrasTotal;  
    private BigDecimal serviceCharge;
    private BigDecimal taxAmount;
    private BigDecimal discount;

    private BigDecimal totalAmount;  
    private String invoiceStatus;    

    private Timestamp issuedAt;
    private Timestamp updatedAt;

    public Invoice() {}
    

    public int getInvoiceId() {
        return invoiceId;
    }
    public void setInvoiceId(int invoiceId) {
        this.invoiceId = invoiceId;
    }

    public int getReservationId() {
        return reservationId;
    }
    public void setReservationId(int reservationId) {
        this.reservationId = reservationId;
    }

    public int getNights() {
        return nights;
    }
    public void setNights(int nights) {
        this.nights = nights;
    }

    public BigDecimal getRoomRate() {
        return roomRate;
    }
    public void setRoomRate(BigDecimal roomRate) {
        this.roomRate = roomRate;
    }

    public BigDecimal getRoomCost() {
        return roomCost;
    }
    public void setRoomCost(BigDecimal roomCost) {
        this.roomCost = roomCost;
    }

    public BigDecimal getExtrasTotal() {
        return extrasTotal;
    }
    public void setExtrasTotal(BigDecimal extrasTotal) {
        this.extrasTotal = extrasTotal;
    }

    public BigDecimal getServiceCharge() {
        return serviceCharge;
    }
    public void setServiceCharge(BigDecimal serviceCharge) {
        this.serviceCharge = serviceCharge;
    }

    public BigDecimal getTaxAmount() {
        return taxAmount;
    }
    public void setTaxAmount(BigDecimal taxAmount) {
        this.taxAmount = taxAmount;
    }

    public BigDecimal getDiscount() {
        return discount;
    }
    public void setDiscount(BigDecimal discount) {
        this.discount = discount;
    }

    public BigDecimal getTotalAmount() {
        return totalAmount;
    }
    public void setTotalAmount(BigDecimal totalAmount) {
        this.totalAmount = totalAmount;
    }

    public String getInvoiceStatus() {
        return invoiceStatus;
    }
    public void setInvoiceStatus(String invoiceStatus) {
        this.invoiceStatus = invoiceStatus;
    }

    public Timestamp getIssuedAt() {
        return issuedAt;
    }
    public void setIssuedAt(Timestamp issuedAt) {
        this.issuedAt = issuedAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }
    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }
}