public with sharing class UserEntryController {
     
    //Calling from UserEntryAlerts, to display banner msg to User to submit the User Entry record for approval
    @AuraEnabled
    public static Boolean doesUserEntryNeedApproval(Id userEntryId){
        Set<String> statuses = new Set<String>{UserEntryData.STATUS_ASSIGN, UserEntryData.STATUS_REMOVE};
        User_Entry__c userEntry = UserEntryUtils.getUserEntry(userEntryId);
        if(userEntry != null && !userEntry.Is_Locked__c && userEntry.Approval_Status__c != UserEntryUtils.APPROVAL_STATUS_PENDING){
            for(User_MyLearning_Program__c userMyLearningProgram : userEntry.User_MyLearning_Programs__r){
                if(statuses.contains(userMyLearningProgram.Status__c)){
                    return true;
                }
            }
            for(User_Prima_Role__c userPrimaRole : userEntry.User_Prima_Roles__r){
                if(statuses.contains(userPrimaRole.Status__c)){
                    return true;
                }
            }
            for(User_Prima_Security_Group__c userPrimaSecurityGroup : userEntry.User_Prima_Security_Groups__r){
                if(statuses.contains(userPrimaSecurityGroup.Status__c)){
                    return true;
                }
            }
        }

        return false;
    }
}