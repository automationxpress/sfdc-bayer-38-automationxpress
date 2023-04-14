public without sharing class OneTrustService {

    private static final String CONSENT_COLLECT_URL = '/latest/services/channel-management/consent/collect';
    @TestVisible private static final String RESPONSE_SUCCESS = 'SUCCESS';

    public class OneTrustException extends Exception {}

    @AuraEnabled
    public static String sendConsent(String email,Boolean isMultiChannelMarketing, Boolean isDpProcessing, Boolean isThirdCountryTransfers){
        if(String.isBlank(email)){
            return System.Label.EmailRrequired_ConsentForm;
        }

        try {
            if(isDpProcessing){
                sendConsentToOneTrust(OneTrustData.getDPProcessingRequest(email, OneTrustData.Action.ACTIVE));
            }
            
            if(isThirdCountryTransfers){
                sendConsentToOneTrust(OneTrustData.getThirdCountryTransfersRequest(email, OneTrustData.Action.ACTIVE));
            }
            
            if(isMultiChannelMarketing && isThirdCountryTransfers){
                sendConsentToOneTrust(OneTrustData.getIMCMBroadConsentRequest(email, OneTrustData.Action.ACTIVE));
            }
            
        } catch(Exception ex){
            HandleCustomException.logException(ex);
            return ex.getMessage();
        }
        
        return RESPONSE_SUCCESS;
    }

    private static void sendConsentToOneTrust(OneTrustData.ConsentCollectRequest request){
        Integration_Config__mdt integrationConfig = OrgUtils.getIntegrationConfig();
        
        String endpoint = OrgUtils.isSandbox() ? 'callout:OneTrust_DEV' : 'callout:OneTrust';
        endpoint += CONSENT_COLLECT_URL;
        
        Map<String, String> header = new Map<String, String>{
            'Content-Type' => 'application/json',
            'x-api-key' => integrationConfig.One_Trust_Api_Key__c
        };

        String body = JSON.serialize(request);

        HttpResponse response = RESTCallout.makePostRequest(endpoint, header, body);
        if(response.getStatusCode() != 200){
            throw new OneTrustException('Email: ' + request.account.identifier + '\n' + response.getStatus() + ':\n' + response.getBody());
        }
    }

    @AuraEnabled
    public static void sendEmailToHCP(String body, String toSend, String subject){
        		
        try{
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {toSend};
            mail.setToAddresses(toAddresses);
            mail.setSubject(subject);
            mail.setHtmlBody('<p>'+ body + '</p>');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
       
    }
    
    @AuraEnabled
    public static String decryptEmail(String algorithmName, String privateKey, String initializationVector, String encrypted){
    	Blob key = Blob.valueOf(privateKey);
        Blob iv = Blob.valueOf(initializationVector);
        Blob data = EncodingUtil.base64Decode(encrypted);
		Blob decrypted = Crypto.decrypt(algorithmName,key,iv,data);
	    String decryptedString = decrypted.toString();
        return decryptedString;
        
    }
}