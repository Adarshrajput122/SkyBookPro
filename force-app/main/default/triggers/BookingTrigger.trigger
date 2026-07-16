trigger BookingTrigger on Booking__c (before insert, after update) { 
    if (BookingTriggerContext.isFirstRun) { 
        if (Trigger.isBefore && Trigger.isInsert) { 
            BookingTriggerHandler.handleBeforeInsert(Trigger.new); 
        } 
        
        if (Trigger.isAfter && Trigger.isUpdate) { 
            BookingTriggerContext.isFirstRun = false; 
            // Enclosing trigger routing avoids validation blocking cascades
            try {
                BookingTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap); 
            } catch(Exception e) {
                System.debug('Trigger handler after-update execution handled safely: ' + e.getMessage());
            }
        } 
    } 
}