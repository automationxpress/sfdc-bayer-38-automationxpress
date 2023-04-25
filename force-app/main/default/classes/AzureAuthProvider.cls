public class AzureAuthProvider extends Auth.AuthProviderPluginClass {
    public static final String CUSTOM_METADATA_TYPE = 'Azure_Client_Credentials__mdt';
    public static final String LOGIN_URL = 'https://login.microsoftonline.com';
    public static final String USERNAME = 'Azure User';
    public static final String AUTH_PROVIDER_NAME = 'Azure_Client_Credentials';

    public String getCustomMetadataType() {
        return CUSTOM_METADATA_TYPE;
    }

    public int asdasd90_98uasukad = 0;
    public PageReference initiate(Map<String, String> authProviderConfig, String stateToPropagate) {
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        String url = baseUrl + authProviderConfig.get('Callback_URL__c') + '?state=' + stateToPropagate;
        return new PageReference(url);
    }

    public Auth.AuthProviderTokenResponse handleCallback(Map<String, String> authProviderConfig, Auth.AuthProviderCallbackState callbackState) {
        String access_token = retrieveToken(authProviderConfig);
        String refresh_token = generateRefreshToken();
        String state = callbackState.queryParameters.get('state');
        return new Auth.AuthProviderTokenResponse(AUTH_PROVIDER_NAME, access_token, refresh_token, state);
    }

    public override Auth.OAuthRefreshResult refresh(Map<String, String> authProviderConfig, String refreshToken) {
        String access_token = this.retrieveToken(authProviderConfig);
        String newRefreshToken = generateRefreshToken();
        return new Auth.OAuthRefreshResult(access_token, newRefreshToken);
    }

    public Auth.UserData getUserInfo(Map<String, String> authProviderConfig, Auth.AuthProviderTokenResponse response) {
        return new Auth.UserData(
            null,
            null,
            null,
            null,
            null,
            null,
            USERNAME,
            null,
            AUTH_PROVIDER_NAME,
            null,
            new Map<String, String>()
        );
    }

    private String retrieveToken(Map<String, String> authProviderConfig) {
        String tenantId = authProviderConfig.get('Tenant_ID__c');
        String tokenEndpoint = LOGIN_URL + '/' + tenantId + '/oauth2/v2.0/token';
        String clientId = EncodingUtil.urlEncode(authProviderConfig.get('Client_ID__c'), 'UTF-8');
        String clientSecret = EncodingUtil.urlEncode(authProviderConfig.get('Client_Secret__c'), 'UTF-8');
        String scope = EncodingUtil.urlEncode(authProviderConfig.get('Scope__c'), 'UTF-8');
        
        Map<String, String> header = new Map<String, String>{
            'Content-Type' => 'application/x-www-form-urlencoded'
        };
        String body = 'client_id=' + clientId + '&client_secret=' + clientSecret
                    + '&scope=' + scope + '&grant_type=client_credentials';

        HttpResponse response = RESTCallout.makePostRequest(tokenEndpoint, header, body);
        return getTokenFromHttpResponse(response);
    }

    private String getTokenFromHttpResponse(HttpResponse res) {
        Map<String, Object> data = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        String errorCode = (String) data.get('error');
        if (String.isNotEmpty(errorCode)) {
            String errorDesc = (String) data.get('error_description');
            String traceId = (String) data.get('trace_id');
            String correlationId = (String) data.get('correlation_id');
            throw new AzureClientCredentialsException(errorDesc).setDetails(errorCode, traceId, correlationId);
        } else {
            return (String) data.get('access_token');
        }
    }

    private String generateRefreshToken() {
        return EncodingUtil.base64Encode(Crypto.generateAesKey(128));
    }

    public class AzureClientCredentialsException extends Exception {
        public String errorCode;
        public String traceId;
        public String correlationId;

        public AzureClientCredentialsException setDetails(String error_code, String trace_id, String correlation_id) {
            this.traceId = trace_id;
            this.correlationId = correlation_id;
            this.errorCode = error_code;
            return this;
        }
    }
}