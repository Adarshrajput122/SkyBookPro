public class BookingEmailService {
    
    /**
     * Requirement 10.1: Asynchronous Future Mail Processor
     * Purpose: Routes text confirmation letters to passengers without tracking up UI checkout speeds.
     */
    @future(callout=false)
    public static void sendBookingConfirmationEmail(Set<Id> bookingIds) {
        // Query passenger contact email routing profiles based on valid active references
        List<Booking__c> targetBookings = [
            SELECT Id, Name, Passenger__r.Name, Passenger__r.Email 
              FROM Booking__c 
             WHERE Id IN :bookingIds 
               AND Passenger__r.Email != NULL
        ];
        
        List<Messaging.SingleEmailMessage> emailQueueList = new List<Messaging.SingleEmailMessage>();
        
        for (Booking__c bk : targetBookings) {
            Messaging.SingleEmailMessage confirmationMail = new Messaging.SingleEmailMessage();
            
            // Map distribution destination profiles
            confirmationMail.setToAddresses(new List<String>{ bk.Passenger__r.Email });
            confirmationMail.setSubject('SkyBook Pro Flight Confirmation - Ticket Code ' + bk.Name);
            
            // Build informational payload alerts
            String contentMessage = 'Dear ' + bk.Passenger__r.Name + ',\n\n' +
                                    'Your automated airline flight reservation arrangement (ID: ' + bk.Name + ') ' +
                                    'has been confirmed via the Duffel Integration Service Engine.\n\n' +
                                    'Thank you for selecting SkyBook Pro.\n' +
                                    'Safe travels!';
            
            confirmationMail.setPlainTextBody(contentMessage);
            emailQueueList.add(confirmationMail);
        }
        
        // Execute bulk distribution tracking safely outside looping iterations
        if (!emailQueueList.isEmpty()) {
            Messaging.sendEmail(emailQueueList);
        }
    }
}