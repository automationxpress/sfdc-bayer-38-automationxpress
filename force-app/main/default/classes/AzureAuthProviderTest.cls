@isTest
public class AzureAuthProviderTest {
    @isTest
    public static void testGetCustomMetadataType() {
        AzureAuthProvider authProvider = new AzureAuthProvider();
        String customMetadataType = authProvider.getCustomMetadataType();
        System.assertEquals(AzureAuthProvider.CUSTOM_METADATA_TYPE, customMetadataType);
    }

    @isTest
    public static void testInitiate() {
        AzureAuthProvider authProvider = new AzureAuthProvider();
        Map<String, String> config = new Map<String, String>();
        config.put('Callback_URL__c', 'foo');
        String state = 'randomState';

        PageReference ref = authProvider.initiate(config, state);
        System.assertEquals(URL.getSalesforceBaseUrl().toExternalForm() + 'foo?state=randomState', ref.getUrl());
    }

    @isTest
    public static void testHandleCallbackSuccess() {
        Map<String, String> config = new Map<String, String>();
        config.put('Tenant_ID__c', 'tenantId');
        config.put('Client_ID__c', 'clientId');
        config.put('Client_Secret__c', 'clientSecret');
        config.put('Scope__c', 'scope');

        Map<String, String> queryArgs = new Map<String, String>();
        queryArgs.put('state', 'randomState');
        Auth.AuthProviderCallbackState callbackState = new Auth.AuthProviderCallbackState(
            new Map<String, String>(),
            '',
            queryArgs
        );

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseSuccess());
        AzureAuthProvider authProvider = new AzureAuthProvider();
        Auth.AuthProviderTokenResponse response = authProvider.handleCallback(config, callbackState);

        System.assertEquals(AzureAuthProvider.AUTH_PROVIDER_NAME, response.provider);
        System.assertEquals('dummy_access_token', response.oauthToken);
        System.assertEquals('randomState', response.state);
    }

    @isTest
    public static void testHandleCallbackError() {
        Map<String, String> config = new Map<String, String>();
        config.put('Tenant_ID__c', 'tenantId');
        config.put('Client_ID__c', 'clientId');
        config.put('Client_Secret__c', 'clientSecret');
        config.put('Scope__c', 'scope');

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseError());
        AzureAuthProvider authProvider = new AzureAuthProvider();

        try{
            Auth.AuthProviderTokenResponse response = authProvider.handleCallback(config, null);
        } catch(AzureAuthProvider.AzureClientCredentialsException ex){
            System.assertEquals('error_code', ex.errorCode);
            System.assertEquals('description', ex.getMessage());
            System.assertEquals('trace_id', ex.traceId);
            System.assertEquals('correlation_id', ex.correlationId);
        }
    }

    @isTest
    public static void testRefresh() {
        Map<String, String> config = new Map<String, String>();
        config.put('Tenant_ID__c', 'tenantId');
        config.put('Client_ID__c', 'clientId');
        config.put('Client_Secret__c', 'clientSecret');
        config.put('Scope__c', 'scope');

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseSuccess());
        AzureAuthProvider authProvider = new AzureAuthProvider();
        Auth.OAuthRefreshResult response = authProvider.refresh(config, null);

        System.assertEquals('dummy_access_token', response.accessToken);
    }

    @isTest
    public static void testGetUserInfo() {
        AzureAuthProvider authProvider = new AzureAuthProvider();
        Auth.UserData userData = authProvider.getUserInfo(null, null);
        System.assertEquals(AzureAuthProvider.USERNAME, userData.username);
        System.assertEquals(AzureAuthProvider.AUTH_PROVIDER_NAME, userData.provider);
    }

    public class MockHttpResponseSuccess implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"access_token": "dummy_access_token"}');
            res.setStatusCode(200);
            return res;
        }
    }

    public class MockHttpResponseError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"error": "error_code", "error_description": "description", "trace_id": "trace_id", "correlation_id": "correlation_id"}');
            res.setStatusCode(400);
            return res;
        }
    }
}