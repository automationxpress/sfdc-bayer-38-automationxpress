@isTest
private class AzureActiveDirectoryServiceTest {

    @TestSetup
    private static void setupTestData(){
        Profile platformEndUserProfile = UserUtils.getPlatformEndUserProfile();
        User manager = TestDataService.createUser(new User(
            Username = 'test.manager.ext@bayer.com',
            ProfileId = platformEndUserProfile.Id,
            FederationIdentifier = 'AABBB'
        ));
        insert manager;
    }

    @isTest
    public static void testSearchUsersSuccess() {
        User manager = [SELECT Id FROM User WHERE Username = 'test.manager.ext@bayer.com'];
        String displayName = 'Test User';

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseSearchSuccess());
        System.runAs(manager){
            List<AzureActiveDirectoryService.UserDetails> response = AzureActiveDirectoryService.searchUsers(displayName);
            System.assertEquals(1, response.size());
            AzureActiveDirectoryService.UserDetails userDetails = response[0];
            System.assertEquals('Test', userDetails.givenName);
            System.assertEquals('User', userDetails.surname);
            System.assertEquals('test.user.ext@bayer.com', userDetails.mail);
            System.assertEquals('ZZZTT', userDetails.onPremisesSamAccountName);
            System.assertEquals('test.user.ext@bayer.com', userDetails.userPrincipalName);
        }
        
        Test.stopTest();
    }

    @isTest
    public static void testSearchUsersError() {
        User manager = [SELECT Id FROM User WHERE Username = 'test.manager.ext@bayer.com'];
        String displayName = 'Test User';

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseSearchError());
        System.runAs(manager){
            try {
                List<AzureActiveDirectoryService.UserDetails> response = AzureActiveDirectoryService.searchUsers(displayName);
            } catch(AzureActiveDirectoryService.AzureADException ex){
                System.assertEquals('Invalid Authentication Token', ex.getMessage());
            }
        }
        
        Test.stopTest();
    }

    @isTest
    public static void testGetResourceManagerExisting() {
        User manager = [SELECT Id FROM User WHERE Username = 'test.manager.ext@bayer.com'];
        String userPrincipalName = 'test.user.ext@bayer.com';

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseManagerSuccess('AABBB'));
        System.runAs(manager){
            Id resourceManagerId = AzureActiveDirectoryService.getResourceManager(userPrincipalName);
            System.assertEquals(manager.Id, resourceManagerId);
        }

        Test.stopTest();
    }

    @isTest
    public static void testGetResourceManagerNotExisting() {
        User manager = [SELECT Id FROM User WHERE Username = 'test.manager.ext@bayer.com'];
        String userPrincipalName = 'test.user.ext@bayer.com';

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseManagerSuccess('WWRRR'));
        System.runAs(manager){
            try {
                Id resourceManagerId = AzureActiveDirectoryService.getResourceManager(userPrincipalName);
            } catch(AuraHandledException ex){
                System.assertEquals(Label.ManagerIsMissingAccessToUMAApp + 'Test Manager', ex.getMessage());
            }
        }

        Test.stopTest();
    }

    public class MockHttpResponseSearchSuccess implements HttpCalloutMock {
        String body = '{'
                        + '"@odata.context": "https://graph.microsoft.com/v1.0/$metadata#users",'
                        + '"value": ['
                            + '{'
                                + '"id": "31f15609-cf5d-41a4-9d5b-7436bb42ea9e",'
                                + '"displayName": "Test User",'
                                + '"givenName": "Test",'
                                + '"surname": "User",'
                                + '"mail": "test.user.ext@bayer.com",'
                                + '"onPremisesSamAccountName": "ZZZTT",'
                                + '"userPrincipalName": "test.user.ext@bayer.com"'
                            + '}'
                        + ']'
                    + '}';

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        }
    }

    public class MockHttpResponseSearchError implements HttpCalloutMock {
        String body = '{'
                        + '"error": {'
                            + '"code": "InvalidAuthenticationToken",'
                            + '"message": "Invalid Authentication Token"'
                        + '}'
                    + '}';

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(body);
            res.setStatusCode(401);
            return res;
        }
    }

    public class MockHttpResponseManagerSuccess implements HttpCalloutMock {
        String body;

        public MockHttpResponseManagerSuccess(String cwid) {
            body = '{'
                    + '"@odata.context": "https://graph.microsoft.com/v1.0/$metadata#directoryObjects",'
                    + '"id": "31f15609-cf5d-41a4-9d5b-7436bb42ea9e",'
                    + '"displayName": "Test Manager",'
                    + '"givenName": "Test",'
                    + '"surname": "Manager",'
                    + '"mail": "test.manager.ext@bayer.com",'
                    + '"onPremisesSamAccountName": "' + cwid + '",'
                    + '"userPrincipalName": "test.manager.ext@bayer.com"'
                + '}';
        }

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        }
    }
}