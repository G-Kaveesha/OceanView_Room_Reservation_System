package tests;

import org.junit.platform.suite.api.SelectClasses;
import org.junit.platform.suite.api.Suite;

@Suite
@SelectClasses({ GuestDAOTest.class, GuestSummaryTest.class, GuestTest.class, InvoiceBundleTest.class,
		InvoiceDAOTest.class, InvoiceItemTest.class, InvoiceTest.class, ReportDAOTest.class, ReservationDAOTest.class,
		ReservationRequestTest.class, RoomDAOTest.class, RoomTest.class, UserDAOTest.class, UserTest.class })
public class AllTests {

}
