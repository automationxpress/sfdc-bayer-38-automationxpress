public with sharing class AzureActiveDirectoryService {

    public class AzureADException extends Exception {}

    public class UserSearchResult {
        public List<UserDetails> value;
    }

    public class UserDetails {
        @AuraEnabled public String displayName;
        @AuraEnabled public String givenName;
        @AuraEnabled public String surname;
        @AuraEnabled public String mail;
        @AuraEnabled public String onPremisesSamAccountName;
        @AuraEnabled public String userPrincipalName;
    }

    @AuraEnabled
    public static List<UserDetails> searchUsers(String displayName){
        String body = getUserSearchResult(displayName);

        Map<String, Object> result = (Map<String, Object>) System.JSON.deserializeUntyped(body);
        handleErrors(result);

        UserSearchResult searchResult = (UserSearchResult) System.JSON.deserialize(body, UserSearchResult.class);
        return searchResult.value;
    }

    @AuraEnabled
    public static Id getResourceManager(String userPrincipalName){
        String body = getUserManager(userPrincipalName);

        Map<String, Object> result = (Map<String, Object>) System.JSON.deserializeUntyped(body);
        handleErrors(result);

        UserDetails managerDetails = (UserDetails) System.JSON.deserialize(body, UserDetails.class);
        User manager = UserUtils.getUserByCwid(managerDetails.onPremisesSamAccountName);
        if(manager == null){
            String message = Label.ManagerIsMissingAccessToUMAApp + managerDetails.displayName;
            AuraHandledException ex = new AuraHandledException(message);
            ex.setMessage(message);
            throw ex;
        }
        return manager.Id;
    }

    private static String getUserSearchResult(String displayName){
        String endpoint = 'callout:Microsoft_Graph/users';
        Map<String, String> params = new Map<String, String>{
            '$select' => 'id,displayName,givenName,surname,mail,onPremisesSamAccountName,userPrincipalName',
            '$search' => '"displayName:' + displayName + '"',
            '$filter' => 'userType eq \'Member\' and mail ne null',
            '$orderBy' => 'displayName'
        };
        Map<String, String> header = new Map<String, String>{
            'Accept' => 'application/json',
            'ConsistencyLevel' => 'eventual'
        };

        HttpResponse response = RESTCallout.makeGetRequest(endpoint, params, header);
        return response.getBody();
    }

    private static String getUserManager(String userPrincipalName){
        String endpoint = 'callout:Microsoft_Graph/users/' + userPrincipalName + '/manager';
        Map<String, String> params = new Map<String, String>{
            '$select' => 'id,displayName,givenName,surname,mail,onPremisesSamAccountName'
        };
        Map<String, String> header = new Map<String, String>{
            'Accept' => 'application/json'
        };

        HttpResponse response = RESTCallout.makeGetRequest(endpoint, params, header);
        return response.getBody();
    }

    private static void handleErrors(Map<String, Object> result){
        if(result.containsKey('error')){
            Map<String, Object> error = (Map<String, Object>) result.get('error');
            String message = error.containsKey('message') ? (String) error.get('message') : 'Azure AD Error';
            throw new AzureADException(message);
        }
    }
}