public with sharing class DuffelFlightSearchService {
    
    @AuraEnabled(cacheable=true)
    public static List<FlightOfferWrapper> searchFlights(String origin, String destination, String departureDate, Integer adults, String cabinClass) {
        List<FlightOfferWrapper> results = new List<FlightOfferWrapper>();
        
        // 1. Initialize our standard HTTP Request
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Duffel_API/air/offer_requests');
        req.setMethod('POST');
        req.setHeader('Authorization', DuffelAuthService.getAuthorizationHeader());
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Duffel-Version', 'v2'); // Enforce strict API versioning rules
        
        // 2. Build the nested payload map matching Duffel structural guidelines
        Map<String, Object> requestBody = new Map<String, Object>();
        Map<String, Object> dataMap = new Map<String, Object>();
        
        // Map the route slice data (Origin, Destination, Date)
        List<Map<String, String>> slices = new List<Map<String, String>>();
        slices.add(new Map<String, String>{
            'origin' => origin,
            'destination' => destination,
            'departure_date' => departureDate
        });
        
        // Map passenger profile rules
        List<Map<String, String>> passengers = new List<Map<String, String>>();
        for (Integer i = 0; i < adults; i++) {
            passengers.add(new Map<String, String>{'type' => 'adult'});
        }
        
        dataMap.put('slices', slices);
        dataMap.put('passengers', passengers);
        dataMap.put('cabin_class', cabinClass.toLowerCase());
        requestBody.put('data', dataMap);
        
        req.setBody(JSON.serialize(requestBody));
        
        // 3. Dispatch the network callout
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        // 4. Handle response verification and extract nested elements
        if (res.getStatusCode() == 201) {
            results = parseDuffelSearchResponse(res.getBody(), cabinClass);
        } else {
            throw new AuraHandledException('Duffel Search Error: ' + res.getStatusCode() + ' - ' + res.getBody());
        }
        
        return results;
    }
    
    private static List<FlightOfferWrapper> parseDuffelSearchResponse(String responseBody, String cabinClass) {
        List<FlightOfferWrapper> offersList = new List<FlightOfferWrapper>();
        
        // Deserialize without complex rigid classes to parse out deeply nested JSON branches
        Map<String, Object> root = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        Map<String, Object> data = (Map<String, Object>) root.get('data');
        List<Object> offers = (List<Object>) data.get('offers');
        
        for (Object obj : offers) {
            Map<String, Object> offer = (Map<String, Object>) obj;
            FlightOfferWrapper wrap = new FlightOfferWrapper();
            
            // Extract baseline parameters
            wrap.offerId = (String) offer.get('id');
            wrap.price = Decimal.valueOf((String) offer.get('total_amount'));
            wrap.currencyCode = (String) offer.get('total_currency');
            wrap.cabinClass = cabinClass;
            
            // Extract route segments to capture flight operational flags
            List<Object> slicesList = (List<Object>) offer.get('slices');
            if (slicesList != null && !slicesList.isEmpty()) {
                Map<String, Object> firstSlice = (Map<String, Object>) slicesList[0];
                List<Object> segmentsList = (List<Object>) firstSlice.get('segments');
                
                if (segmentsList != null && !segmentsList.isEmpty()) {
                    Map<String, Object> firstSegment = (Map<String, Object>) segmentsList[0];
                    
                    // Route endpoints
                    Map<String, Object> segmentOrigin = (Map<String, Object>) firstSegment.get('origin');
                    Map<String, Object> segmentDest = (Map<String, Object>) firstSegment.get('destination');
                    wrap.origin = (String) segmentOrigin.get('iata_code');
                    wrap.destination = (String) segmentDest.get('iata_code');
                    
                    // Timing variables
                    String depTimeStr = (String) firstSegment.get('departing_at');
                    String arrTimeStr = (String) firstSegment.get('arriving_at');
                    wrap.departureTime = (DateTime) JSON.deserialize('"' + depTimeStr + '"', DateTime.class);
                    wrap.arrivalTime = (DateTime) JSON.deserialize('"' + arrTimeStr + '"', DateTime.class);
                    
                    // Operating airline metadata
                    Map<String, Object> marketingCarrier = (Map<String, Object>) firstSegment.get('marketing_carrier');
                    wrap.airline = (String) marketingCarrier.get('name');
                    wrap.flightNumber = (String) firstSegment.get('marketing_carrier_flight_number');
                }
            }
            
            // Handle secondary safety metrics
            Object passengerElements = offer.get('passengers');
            if (passengerElements instanceof List<Object>) {
                List<Object> passList = (List<Object>) passengerElements;
                wrap.seatsAvailable = passList.size(); 
            } else {
                wrap.seatsAvailable = 9; // Default availability placeholder flag if unlisted
            }
            
            offersList.add(wrap);
        }
        
        return offersList;
    }
}