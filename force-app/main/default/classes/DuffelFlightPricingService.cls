public with sharing class DuffelFlightPricingService {
    
    public static FlightOfferWrapper confirmPriceAndConditions(String offerId) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Duffel_API/air/offers/' + offerId);
        req.setMethod('GET');
        req.setHeader('Authorization', DuffelAuthService.getAuthorizationHeader());
        req.setHeader('Duffel-Version', 'v2');
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        FlightOfferWrapper wrap = new FlightOfferWrapper();
        
        if (res.getStatusCode() == 200) {
            Map<String, Object> root = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            Map<String, Object> data = (Map<String, Object>) root.get('data');
            
            wrap.offerId = (String) data.get('id');
            wrap.price = Decimal.valueOf((String) data.get('total_amount'));
            wrap.currencyCode = (String) data.get('total_currency');
            
            // Extract fare modification conditions if listed by the carrier
            Map<String, Object> passengerConditions = (Map<String, Object>) data.get('passenger_identity_documents_required');
            // Condition parameters can be further processed here if required by frontend UI
        } else {
            throw new AuraHandledException('Pricing verification failed: Status ' + res.getStatusCode());
        }
        
        return wrap;
    }
}