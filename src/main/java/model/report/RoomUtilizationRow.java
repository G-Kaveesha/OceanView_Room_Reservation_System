package model.report;

public class RoomUtilizationRow {
    private String roomNumber;
    private String typeName;
    private int nightsBooked;
    private int timesReserved;
    private String currentStatus;

    public String getRoomNumber() { return roomNumber; }
    public void setRoomNumber(String roomNumber) { this.roomNumber = roomNumber; }
    public String getTypeName() { return typeName; }
    public void setTypeName(String typeName) { this.typeName = typeName; }
    public int getNightsBooked() { return nightsBooked; }
    public void setNightsBooked(int nightsBooked) { this.nightsBooked = nightsBooked; }
    public int getTimesReserved() { return timesReserved; }
    public void setTimesReserved(int timesReserved) { this.timesReserved = timesReserved; }
    public String getCurrentStatus() { return currentStatus; }
    public void setCurrentStatus(String currentStatus) { this.currentStatus = currentStatus; }
}