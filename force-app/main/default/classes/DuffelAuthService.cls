public with sharing class DuffelAuthService {
    public static String getAuthorizationHeader() {
        Duffel_Config__mdt config = Duffel_Config__mdt.getInstance('Sandbox');
        String token = (config != null) ? config.Access_Token__c : '';
        return 'Bearer ' + token; // Generates standard format
    }
}