public class UserEntryTriggerHandler extends TriggerHandler {
    
    public override void beforeInsert(List<SObject> newRecords) {
       List<User_Entry__c> newUserEntries = (List<User_Entry__c>) newRecords; 
       UserEntryService.validateUserEntrieseWithRoleMatrix(newUserEntries);
    }

    public override void beforeUpdate(Map<Id, SObject> newRecords, Map<Id, SObject> oldRecords) {
        System.debug('@@inside UserEntryTriggerHandler.beforeUpdate');
        Map<Id, User_Entry__c> newUserEntries = (Map<Id, User_Entry__c>) newRecords;
        Map<Id, User_Entry__c> oldUserEntries = (Map<Id, User_Entry__c>) oldRecords;
        UserEntryService.setIsLocked(newUserEntries);
        List<User_Entry__c> newUserEntriesList = (List<User_Entry__c>) newRecords.values();
        UserEntryService.validateUserEntrieseWithRoleMatrix(newUserEntriesList);
    }
    
    public override void beforeDelete(Map<Id, SObject> oldRecords){
        System.debug('@@inside UserEntryTriggerHandler.beforeDelete');
        Map<Id, User_Entry__c> oldUserEntries = (Map<Id, User_Entry__c>) oldRecords;
        UserEntryService.validateUserEntriesOnDelete(oldUserEntries);
    }

    public override void afterInsert(Map<Id, SObject> newRecords) {
        System.debug('@@inside UserEntryTriggerHandler.afterInsert');
        Map<Id, User_Entry__c> newUserEntries = (Map<Id, User_Entry__c>) newRecords;
        UserEntryService.shareUserEntryRecordsWithResourceManager(newUserEntries);
        UserEntryService.shareUserEntryRecordsWithDeputyManager(newUserEntries);
        UserTimeTrackingService.populateUserTimeTrackingsOnUserEntryCreate(newUserEntries);
    }
    
    public override void afterUpdate(Map<Id, SObject> newRecords, Map<Id, SObject> oldRecords) {
        System.debug('@@inside UserEntryTriggerHandler.afterUpdate');
        Map<Id, User_Entry__c> newUserEntries = (Map<Id, User_Entry__c>) newRecords;
        Map<Id, User_Entry__c> oldUserEntries = (Map<Id, User_Entry__c>) oldRecords;
        UserEntryService.shareUserEntryRecordsWithResourceManager(newUserEntries, oldUserEntries);
        UserEntryService.shareUserEntryRecordsWithDeputyManager(newUserEntries, oldUserEntries);
        UserEntryService.sendPrimaAndMyLearningUpdates(newUserEntries, oldUserEntries);
        UserTimeTrackingService.populateUserTimeTrackingsOnUserEntryUpdate(newUserEntries, oldUserEntries);
    }
}