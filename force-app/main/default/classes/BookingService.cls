public with sharing class BookingService {
    
    @AuraEnabled(cacheable=false)
    public static Booking__c createBooking(Id contactId, String offerId, Decimal expectedPrice) {
        // Pre-verify ticket costs to catch mid-checkout price shifts
        FlightOfferWrapper liveOffer = DuffelFlightPricingService.confirmPriceAndConditions(offerId);
        if (liveOffer.price > expectedPrice) {
            throw new AuraHandledException('Price has changed from £' + expectedPrice + ' to £' + liveOffer.price + '. Please refresh flight offers.');
        }
        
        // Book flight instantly via Duffel Orders Endpoint
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Duffel_API/air/orders');
        req.setMethod('POST');
        req.setHeader('Authorization', DuffelAuthService.getAuthorizationHeader());
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Duffel-Version', 'v2');
        
        Map<String, Object> requestBody = new Map<String, Object>();
        Map<String, Object> dataMap = new Map<String, Object>();
        
        dataMap.put('selected_offers', new List<String>{offerId});
        dataMap.put('type', 'instant');
        
        // Retrieve passenger contact details
        Contact passenger = [SELECT FirstName, LastName, Email, Phone FROM Contact WHERE Id = :contactId LIMIT 1];
        
        List<Map<String, Object>> passengersList = new List<Map<String, Object>>();
        Map<String, Object> passengerMap = new Map<String, Object>();
        passengerMap.put('id', 'pas_000001'); 
        passengerMap.put('given_name', passenger.FirstName);
        passengerMap.put('family_name', passenger.LastName);
        passengerMap.put('email', passenger.Email);
        passengerMap.put('phone_number', passenger.Phone);
        passengersList.add(passengerMap);
        
        dataMap.put('passengers', passengersList);
        requestBody.put('data', dataMap);
        
        req.setBody(JSON.serialize(requestBody));
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        if (res.getStatusCode() != 201) {
            throw new AuraHandledException('Airline booking engine failed: ' + res.getStatusCode() + ' - ' + res.getBody());
        }
        
        // Salesforce DB Commit with Rollback Protection
                // Salesforce DB Commit with Rollback Protection
        Savepoint sp = Database.setSavepoint();
        try {
            Booking__c newBk = new Booking__c();
            
            // FIX: Changed Contact__c to Passenger__c to match your BRD Page 5 schema
            newBk.Passenger__c = contactId; 
            newBk.Booking_Status__c = 'Confirmed'; 
            
            insert newBk;
            
            // This now compiles cleanly since newBk is recognized and returned safely
            return newBk;
            
        } catch (Exception e) {
            Database.rollback(sp);
            throw new AuraHandledException('Database transaction failed. Record was rolled back: ' + e.getMessage());
        }
    }
}