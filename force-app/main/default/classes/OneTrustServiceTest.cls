@isTest
private class OneTrustServiceTest {
    @TestSetup
    private static void setupTestData(){
        Profile consentFormUserProfile = UserUtils.getConsentFormProfile();
        User consentFormUser = TestDataService.createUser(new User(
            Username = 'test.consent.form.ext@example.com',
            ProfileId = consentFormUserProfile.Id
        ));
        insert consentFormUser;
    }

    @isTest
    public static void testsendConsentSuccess() {
        String email = 'hcp123.test@example.com';
        User consentFormUser = [SELECT Id FROM User WHERE Username = 'test.consent.form.ext@example.com'];
		String emailBody = System.Label.EmailBody_ConsentForm;
        String emailSubject = System.Label.EmailSubject_ConsentForm;
        Test.startTest();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseSendSuccess());
        String response;
        System.runAs(consentFormUser){
            response = OneTrustService.sendConsent(email, true, true, true);
        }
        OneTrustService.sendEmailToHCP(emailBody, email, emailSubject);
        Test.stopTest();

        System.assertEquals(OneTrustService.RESPONSE_SUCCESS, response);
    }

    @isTest
    public static void testsendConsentError() {
        String email = 'hcp123.test@example.com';
        User consentFormUser = [SELECT Id FROM User WHERE Username = 'test.consent.form.ext@example.com'];
        String emailBody = System.Label.EmailBody_ConsentForm;
        String emailSubject = System.Label.EmailSubject_ConsentForm;
        Test.startTest();
		
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseSendError());
        String response;
        System.runAs(consentFormUser){
            response = OneTrustService.sendConsent(email, true, true, true);
        }
        OneTrustService.sendEmailToHCP(emailBody, email, emailSubject);
        Test.stopTest();

        System.assert(response.contains(email));
    }

    public class MockHttpResponseSendSuccess implements HttpCalloutMock {
        String body = '';

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        }
    }

    public class MockHttpResponseSendError implements HttpCalloutMock {
        String body = '';

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(body);
            res.setStatusCode(404);
            return res;
        }
    }
}