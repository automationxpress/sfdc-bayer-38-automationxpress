public class UserPrimaRoleTriggerHandler extends TriggerHandler {

    public override void beforeDelete(Map<Id, SObject> oldRecords){
        Map<Id, User_Prima_Role__c> oldUserPrimaRoles = (Map<Id, User_Prima_Role__c>) oldRecords;
        UserPrimaRoleUtils.validateUserPrimaRolesOnDelete(oldUserPrimaRoles);
    }
    
    public override void afterDelete(Map<Id, SObject> oldRecords){
        Map<Id, User_Prima_Role__c> oldUserPrimaRoles = (Map<Id, User_Prima_Role__c>) oldRecords;
        Set<Id> userEntryIds = getUserEntryIds(oldUserPrimaRoles.values());
        UserEntryService.updateLockedUserEntries(userEntryIds);
    }
    
    public override void afterUpdate(Map<Id, SObject> newRecords, Map<Id, SObject> oldRecords) {
        Map<Id, User_Prima_Role__c> newUserPrimaRoles = (Map<Id, User_Prima_Role__c>) newRecords;
        Map<Id, User_Prima_Role__c> oldUserPrimaRoles = (Map<Id, User_Prima_Role__c>) oldRecords;
        Set<Id> userEntryIds = getUserEntryIds(newUserPrimaRoles, oldUserPrimaRoles);
        UserEntryService.updateLockedUserEntries(userEntryIds);
    }

    private static Set<Id> getUserEntryIds(List<User_Prima_Role__c> userPrimaRoles){
        Set<Id> userEntryIds = new Set<Id>();
        for(User_Prima_Role__c userPrimaRole : userPrimaRoles){
            userEntryIds.add(userPrimaRole.User_Entry__c);
        }
        return userEntryIds;
    }

    private static Set<Id> getUserEntryIds(Map<Id, User_Prima_Role__c> newUserPrimaRoles, Map<Id, User_Prima_Role__c> oldUserPrimaRoles){
        Set<Id> userEntryIds = new Set<Id>();
        User_Prima_Role__c newUserPrimaRole, oldUserPrimaRole;
        for(Id userMyLearningProgramId : newUserPrimaRoles.keySet()){
            newUserPrimaRole = newUserPrimaRoles.get(userMyLearningProgramId);
            oldUserPrimaRole = oldUserPrimaRoles.get(userMyLearningProgramId);
            if(newUserPrimaRole.Status__c != oldUserPrimaRole.Status__c){
                userEntryIds.add(newUserPrimaRole.User_Entry__c);
            }
        }
        return userEntryIds;
    }
}