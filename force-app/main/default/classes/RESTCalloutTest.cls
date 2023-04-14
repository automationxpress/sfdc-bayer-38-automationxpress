@isTest
private class RESTCalloutTest {
    @TestSetup
    private static void setupTestData(){
        Profile adminProfile = UserUtils.getSystemAdministratorProfile();
        User admin = TestDataService.createUser(new User(
            Username = 'test.admin.ext@bayer.com',
            ProfileId = adminProfile.Id
        ));
        insert admin;
    }

    @isTest
    public static void testMakeGetRequest() {
        User admin = [SELECT Id FROM User WHERE Username = 'test.admin.ext@bayer.com'];
        String endpoint = 'https://trailhead.salesforce.com/';
        Map<String, String> params = new Map<String, String>{
            'param1' => 'aaa'
        };
        Map<String, String> header = new Map<String, String>{
            'Accept' => 'application/json'
        };

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        System.runAs(admin){
            HttpResponse response = RESTCallout.makeGetRequest(endpoint, params, header);
            System.assertEquals(200, response.getStatusCode());
        }
        
        Test.stopTest();
    }

    @isTest
    public static void testMakePostRequest() {
        User admin = [SELECT Id FROM User WHERE Username = 'test.admin.ext@bayer.com'];
        String endpoint = 'https://trailhead.salesforce.com/';
        Map<String, String> header = new Map<String, String>{
            'Accept' => 'application/json'
        };
        String body = '{"value": "test"}';

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        System.runAs(admin){
            HttpResponse response = RESTCallout.makePostRequest(endpoint, header, body);
            System.assertEquals(200, response.getStatusCode());
        }
        
        Test.stopTest();
    }

    public class MockHttpResponse implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status": "success"}');
            res.setStatusCode(200);
            return res;
        }
    }
}