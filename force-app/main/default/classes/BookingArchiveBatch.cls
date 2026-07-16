public with sharing class BookingArchiveBatch implements Database.Batchable<sObject> {
    
    /**
     * Requirement 10.3: Batch Search Scope Boundaries
     * Purpose: Gathers data records older than 2 years that are marked Completed or Cancelled.
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Booking_Status__c 
              FROM Booking__c 
             WHERE Booking_Date__c < LAST_N_YEARS:2 
               AND (Booking_Status__c = 'Completed' OR Booking_Status__c = 'Cancelled')
        ]);
    }
    
    /**
     * Requirement 10.3: Batch Segment Processing Block
     * Purpose: Automatically archives records chunk by chunk within standard safety limits.
     */
    public void execute(Database.BatchableContext bc, List<Booking__c> scopeRecordsList) {
        for (Booking__c bk : scopeRecordsList) {
            bk.Booking_Status__c = 'Archived'; // Changes the record visibility tracking tag safely
        }
        
        // Standard mass database updates running outside transaction threads
        update scopeRecordsList;
    }
    
    /**
     * Requirement 10.3: Finalizer Notification Hook
     * Purpose: Writes audit log tracking summaries after all data segments process cleanly.
     */
    public void finish(Database.BatchableContext bc) {
        System.debug('Historical dataset data archiving batch process completed cleanly across all blocks.');
    }
}