public class FlightOfferWrapper {
    @AuraEnabled public String offerId {get;set;}
    @AuraEnabled public String airline {get;set;}
    @AuraEnabled public String flightNumber {get;set;}
    @AuraEnabled public String origin {get;set;}
    @AuraEnabled public String destination {get;set;}
    @AuraEnabled public DateTime departureTime {get;set;}
    @AuraEnabled public DateTime arrivalTime {get;set;}
    @AuraEnabled public Decimal price {get;set;}
    @AuraEnabled public String currencyCode {get;set;}
    @AuraEnabled public Integer seatsAvailable {get;set;}
    @AuraEnabled public String cabinClass {get;set;}
}