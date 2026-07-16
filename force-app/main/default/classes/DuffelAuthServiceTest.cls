@isTest
private class DuffelAuthServiceTest {
    @isTest static void testAuthorizationHeaderRetrieval() {
        Test.startTest();
        String header = DuffelAuthService.getAuthorizationHeader();
        Test.stopTest();
        System.assert(header.contains('Bearer'), 'Header must format as a standard Bearer authentication string.');
    }
}