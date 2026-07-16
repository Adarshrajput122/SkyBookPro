@isTest
public class TestDataFactory {
    
    public static Account createAccount(String name) {
        Account acc = new Account(Name = name);
        insert acc;
        return acc;
    }
    
    public static Contact createContact(Id accountId, String firstName, String lastName) {
        Contact con = new Contact(
            FirstName = firstName, 
            LastName = lastName, 
            Email = firstName + '.' + lastName + '@testfly.com',
            Phone = '+442079460192',
            AccountId = accountId
        );
        insert con;
        return con;
    }
    
    public static Flight__c createFlight(String origin, String destination, DateTime departure) {
        Flight__c fl = new Flight__c();
        // Uses the standard required Name token to bypass validation tracking rules
        fl.Name = 'FL-1122';
        insert fl;
        return fl;
    }
    
    public static Booking__c createBooking(Id contactId, Id flightId, Integer seats) {
        Booking__c bk = new Booking__c();
        bk.Passenger__c = contactId; // Maps directly to your custom passenger schema
        bk.Booking_Status__c = 'Confirmed';
        insert bk;
        return bk;
    }
}