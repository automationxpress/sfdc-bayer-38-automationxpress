public with sharing class PrimaService {

    private static final Boolean IS_SANDBOX = OrgUtils.isSandbox();
    private static final String PRIMA_WEBHOOK_URL = '/connector/UMA/UMA_Endpoint/webhook.rsb';

    public class PrimaRequest {
        public List<PrimaData.UserRequest> users;
    }

    public class PrimaException extends Exception {}

    public static void sendPrimaUpdates(List<User_Entry__c> userEntries, Integer nrOfAttempts){
        PrimaRequest request = new PrimaRequest();
        request.users =  new List<PrimaData.UserRequest>();
        List<User_Prima_Role__c> userPrimaRoles = new List<User_Prima_Role__c>();
        List<User_Prima_Security_Group__c> userPrimaSecurityGroups = new List<User_Prima_Security_Group__c>();
        for(User_Entry__c userEntry : userEntries){ 
            PrimaData.UserRequest userRequest = new PrimaData.UserRequest(userEntry);       
            request.users.add(userRequest);
            if(!userEntry.User_Prima_Roles__r.isEmpty()){
                userPrimaRoles.addAll(userEntry.User_Prima_Roles__r);
            }
            if(!userEntry.User_Prima_Security_Groups__r.isEmpty()){
                userPrimaSecurityGroups.addAll(userEntry.User_Prima_Security_Groups__r);
            }
        }

        try {
            sendPrimaRolesAndSecurityGroups(request);
            updatePrimaRoleStatuses(userPrimaRoles);
            updatePrimaSecurityGroupStatuses(userPrimaSecurityGroups);
        } catch(Exception ex){
            UMA_Settings__mdt umaSettings = OrgUtils.getUmaSettings();
            if(umaSettings != null && nrOfAttempts < umaSettings.Max_nr_of_Prima_POST_request_attempts__c){
                System.enqueueJob(new PrimaUpdatesAsync(userEntries, nrOfAttempts + 1));
            } else {
                updatePrimaRoleSendingFailed(userPrimaRoles);
                updatePrimaSecurityGroupSendingFailed(userPrimaSecurityGroups);
                HandleCustomException.logException(ex);
            }
        }
    }

    private static void sendPrimaRolesAndSecurityGroups(PrimaRequest primaRequest){
        Integration_Config__mdt integrationConfig = OrgUtils.getIntegrationConfig();
        
        String endpoint = IS_SANDBOX ? 'callout:Prima_DEV' : 'callout:Prima';
        endpoint += PRIMA_WEBHOOK_URL;
        
        Map<String, String> header = new Map<String, String>{
            'Content-Type' => 'application/json',
            'x-arcesb-authtoken' => integrationConfig.Prima_Authtoken__c
        };

        String body = JSON.serialize(primaRequest);

        HttpResponse response = RESTCallout.makePostRequest(endpoint, header, body);
        System.debug('RESPONSE: '+response.getBody());
        if(response.getStatusCode() != 200){
            throw new PrimaException(response.getStatus());
        }
    }

    private static void updatePrimaRoleStatuses(List<User_Prima_Role__c> userPrimaRoles){
        for(User_Prima_Role__c userPrimaRole : userPrimaRoles){
            userPrimaRole.Status__c = getNewPrimaStatus(userPrimaRole.Status__c);
        }
        update userPrimaRoles;
    }

    private static void updatePrimaRoleSendingFailed(List<User_Prima_Role__c> userPrimaRoles){
        for(User_Prima_Role__c userPrimaRole : userPrimaRoles){
            userPrimaRole.Initial_Sending_Failed__c = true;
        }
        update userPrimaRoles;
    }
    
    private static void updatePrimaSecurityGroupStatuses(List<User_Prima_Security_Group__c> userPrimaSecurityGroups){
        for(User_Prima_Security_Group__c userPrimaSecurityGroup : userPrimaSecurityGroups){
            userPrimaSecurityGroup.Status__c = getNewPrimaStatus(userPrimaSecurityGroup.Status__c);
        }
        update userPrimaSecurityGroups;
    }

    private static void updatePrimaSecurityGroupSendingFailed(List<User_Prima_Security_Group__c> userPrimaSecurityGroups){
        for(User_Prima_Security_Group__c userPrimaSecurityGroup : userPrimaSecurityGroups){
            userPrimaSecurityGroup.Initial_Sending_Failed__c = true;
        }
        update userPrimaSecurityGroups;
    }

    private static String getNewPrimaStatus(String currentStatus){
        if(currentStatus == UserEntryData.STATUS_ASSIGN){
            return UserEntryData.STATUS_ASSIGN_REQUESTED;
        } else if(currentStatus == UserEntryData.STATUS_REMOVE){
            return UserEntryData.STATUS_REMOVE_REQUESTED;
        } else {
            return currentStatus;
        }
    }
}