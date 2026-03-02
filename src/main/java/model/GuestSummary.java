package model;

import java.sql.Date;

public class GuestSummary {
    private String guestName;
    private String guestPhone;
    private String guestEmail;
    private String guestNicPassport;

    private int totalReservations;
    private Date lastReservationDate; 
    private String latestStatus;
    private String lastRoomNumber;

    public String getGuestName() { return guestName; }
    public void setGuestName(String guestName) { this.guestName = guestName; }

    public String getGuestPhone() { return guestPhone; }
    public void setGuestPhone(String guestPhone) { this.guestPhone = guestPhone; }

    public String getGuestEmail() { return guestEmail; }
    public void setGuestEmail(String guestEmail) { this.guestEmail = guestEmail; }

    public String getGuestNicPassport() { return guestNicPassport; }
    public void setGuestNicPassport(String guestNicPassport) { this.guestNicPassport = guestNicPassport; }

    public int getTotalReservations() { return totalReservations; }
    public void setTotalReservations(int totalReservations) { this.totalReservations = totalReservations; }

    public Date getLastReservationDate() { return lastReservationDate; }
    public void setLastReservationDate(Date lastReservationDate) { this.lastReservationDate = lastReservationDate; }

    public String getLatestStatus() { return latestStatus; }
    public void setLatestStatus(String latestStatus) { this.latestStatus = latestStatus; }

    public String getLastRoomNumber() { return lastRoomNumber; }
    public void setLastRoomNumber(String lastRoomNumber) { this.lastRoomNumber = lastRoomNumber; }
}