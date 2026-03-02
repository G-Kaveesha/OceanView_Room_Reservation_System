package model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class InvoiceItem {

    private int itemId;
    private int invoiceId;

    private String itemName;
    private int qty;

    private BigDecimal unitPrice;
    private BigDecimal amount;    

    private String note;
    private Timestamp addedAt;

    public InvoiceItem() {}


    public int getItemId() {
        return itemId;
    }
    public void setItemId(int itemId) {
        this.itemId = itemId;
    }

    public int getInvoiceId() {
        return invoiceId;
    }
    public void setInvoiceId(int invoiceId) {
        this.invoiceId = invoiceId;
    }

    public String getItemName() {
        return itemName;
    }
    public void setItemName(String itemName) {
        this.itemName = itemName;
    }

    public int getQty() {
        return qty;
    }
    public void setQty(int qty) {
        this.qty = qty;
    }

    public BigDecimal getUnitPrice() {
        return unitPrice;
    }
    public void setUnitPrice(BigDecimal unitPrice) {
        this.unitPrice = unitPrice;
    }

    public BigDecimal getAmount() {
        return amount;
    }
    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }

    public String getNote() {
        return note;
    }
    public void setNote(String note) {
        this.note = note;
    }

    public Timestamp getAddedAt() {
        return addedAt;
    }
    public void setAddedAt(Timestamp addedAt) {
        this.addedAt = addedAt;
    }
}