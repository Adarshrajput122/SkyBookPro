@isTest
public class DuffelMockHttpResponses implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        
        // Comprehensive nested JSON matching real Duffel flight tracking APIs
        String jsonBody = '{' +
            '"data": {' +
                '"id": "off_test99",' +
                '"total_amount": "450.00",' +
                '"total_currency": "GBP",' +
                '"offers": [{' +
                    '"id": "off_test99",' +
                    '"total_amount": "450.00",' +
                    '"total_currency": "GBP",' +
                    '"slices": [{' +
                        '"segments": [{' +
                            '"origin": {"iata_code": "LHR"},' +
                            '"destination": {"iata_code": "JFK"},' +
                            '"departing_at": "2026-12-25T10:00:00Z",' +
                            '"arriving_at": "2026-12-25T14:00:00Z",' +
                            '"marketing_carrier": {"name": "British Airways"},' +
                            '"marketing_carrier_flight_number": "BA112"' +
                        '}]' +
                    '}],' +
                    '"passengers": [{"id": "pas_1", "type": "adult"}]' +
                '}]' +
            '}' +
        '}';
        
        if (req.getEndpoint().contains('orders')) {
            res.setStatusCode(201);
            res.setBody('{"data": {"id": "ord_test88", "status": "confirmed"}}');
        } else {
            res.setStatusCode(200);
            res.setBody(jsonBody);
        }
        return res;
    }
}