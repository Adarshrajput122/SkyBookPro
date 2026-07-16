public with sharing class BookingDataController {
    
    /**
     * Requirement 1: Confirmed Bookings Dashboard Queue
     * Purpose: Extracts the 50 most recent confirmed flights managed by the running agent.
     */
    @AuraEnabled(cacheable=true)
    public static List<Booking__c> getConfirmedBookingsByAgent() {
        return [
            SELECT Id, 
                   Name, 
                   Passenger__r.Name, 
                   Booking_Status__c, 
                   CreatedDate
              FROM Booking__c 
             WHERE Agent__c = :UserInfo.getUserId() 
               AND Booking_Status__c = 'Confirmed'
             ORDER BY CreatedDate DESC 
             LIMIT 50
        ];
    }
    
    /**
     * Requirement 2: Agent Performance Rollups
     * Purpose: Summarizes transaction counts grouped by individual travel agents to drive leaderboard components.
     */
    @AuraEnabled(cacheable=true)
    public static List<AggregateResult> getAgentRevenueMetrics() {
        return [
            SELECT Agent__r.Name agentName, 
                   COUNT(Id) totalBookings
              FROM Booking__c 
             WHERE Booking_Status__c = 'Confirmed'
             GROUP BY Agent__r.Name
        ];
    }
    
    /**
     * Requirement 3: Global Passenger Text Search Engine
     * Purpose: Uses a full-text SOSL search index to locate passengers and bookings matching a partial text match.
     */
    @AuraEnabled(cacheable=true)
    public static List<List<SObject>> searchPassengerDirectory(String searchTerm) {
        // Enforce a safe input threshold validation before executing queries
        if (String.isBlank(searchTerm) || searchTerm.trim().length() < 2) {
            return new List<List<SObject>>();
        }
        
        // Escape characters and append wildcards to mitigate dynamic injection vulnerabilities
        String sanitizedSearch = '*' + String.escapeSingleQuotes(searchTerm.trim()) + '*';
        
        return [
            FIND :sanitizedSearch 
              IN ALL FIELDS 
       RETURNING Contact(Id, Name, Email, Phone), 
                 Booking__c(Id, Name, Booking_Status__c WHERE Booking_Status__c != 'Archived')
        ];
    }
}