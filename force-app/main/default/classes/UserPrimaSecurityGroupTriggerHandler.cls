public class UserPrimaSecurityGroupTriggerHandler extends TriggerHandler {

    public override void beforeDelete(Map<Id, SObject> oldRecords){
        Map<Id, User_Prima_Security_Group__c> oldUserPrimaSecurityGroups = (Map<Id, User_Prima_Security_Group__c>) oldRecords;
        UserPrimaSecurityGroupUtils.validateUserPrimaSecurityGroupsOnDelete(oldUserPrimaSecurityGroups);
    }
    
    public override void afterDelete(Map<Id, SObject> oldRecords){
        Map<Id, User_Prima_Security_Group__c> oldUserPrimaSecurityGroups = (Map<Id, User_Prima_Security_Group__c>) oldRecords;
        Set<Id> userEntryIds = getUserEntryIds(oldUserPrimaSecurityGroups.values());
        UserEntryService.updateLockedUserEntries(userEntryIds);
    }
    
    public override void afterUpdate(Map<Id, SObject> newRecords, Map<Id, SObject> oldRecords) {
        Map<Id, User_Prima_Security_Group__c> newUserPrimaSecurityGroups = (Map<Id, User_Prima_Security_Group__c>) newRecords;
        Map<Id, User_Prima_Security_Group__c> oldUserPrimaSecurityGroups = (Map<Id, User_Prima_Security_Group__c>) oldRecords;
        Set<Id> userEntryIds = getUserEntryIds(newUserPrimaSecurityGroups, oldUserPrimaSecurityGroups);
        UserEntryService.updateLockedUserEntries(userEntryIds);
    }

    private static Set<Id> getUserEntryIds(List<User_Prima_Security_Group__c> userPrimaSecurityGroups){
        Set<Id> userEntryIds = new Set<Id>();
        for(User_Prima_Security_Group__c userPrimaSecurityGroup : userPrimaSecurityGroups){
            userEntryIds.add(userPrimaSecurityGroup.User_Entry__c);
        }
        return userEntryIds;
    }

    private static Set<Id> getUserEntryIds(Map<Id, User_Prima_Security_Group__c> newUserPrimaSecurityGroups, Map<Id, User_Prima_Security_Group__c> oldUserPrimaSecurityGroups){
        Set<Id> userEntryIds = new Set<Id>();
        User_Prima_Security_Group__c newUserPrimaSecurityGroup, oldUserPrimaSecurityGroup;
        for(Id userMyLearningProgramId : newUserPrimaSecurityGroups.keySet()){
            newUserPrimaSecurityGroup = newUserPrimaSecurityGroups.get(userMyLearningProgramId);
            oldUserPrimaSecurityGroup = oldUserPrimaSecurityGroups.get(userMyLearningProgramId);
            if(newUserPrimaSecurityGroup.Status__c != oldUserPrimaSecurityGroup.Status__c){
                userEntryIds.add(newUserPrimaSecurityGroup.User_Entry__c);
            }
        }
        return userEntryIds;
    }
}