package model;

public class Guest {
    private int guestId;
    private String guestEmail;
    private String guestPassword;

    public Guest() {}

    public Guest(String guestEmail, String guestPassword) {
        this.guestEmail = guestEmail;
        this.guestPassword = guestPassword;
    }

    public int getGuestId() { return guestId; }
    public void setGuestId(int guestId) { this.guestId = guestId; }

    public String getGuestEmail() { return guestEmail; }
    public void setGuestEmail(String guestEmail) { this.guestEmail = guestEmail; }

    public String getGuestPassword() { return guestPassword; }
    public void setGuestPassword(String guestPassword) { this.guestPassword = guestPassword; }
    
 
}
