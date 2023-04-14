public class UserMyLearningProgramTriggerHandler extends TriggerHandler {

    public override void beforeDelete(Map<Id, SObject> oldRecords){
        Map<Id, User_MyLearning_Program__c> oldUserMyLearningPrograms = (Map<Id, User_MyLearning_Program__c>) oldRecords;
        UserMyLearningProgramUtils.validateUserMyLearningProgramsOnDelete(oldUserMyLearningPrograms);
    }
    
    public override void afterDelete(Map<Id, SObject> oldRecords){
        Map<Id, User_MyLearning_Program__c> oldUserMyLearningPrograms = (Map<Id, User_MyLearning_Program__c>) oldRecords;
        Set<Id> userEntryIds = getUserEntryIds(oldUserMyLearningPrograms.values());
        UserEntryService.updateLockedUserEntries(userEntryIds);
    }
    
    public override void afterUpdate(Map<Id, SObject> newRecords, Map<Id, SObject> oldRecords) {
        Map<Id, User_MyLearning_Program__c> newUserMyLearningPrograms = (Map<Id, User_MyLearning_Program__c>) newRecords;
        Map<Id, User_MyLearning_Program__c> oldUserMyLearningPrograms = (Map<Id, User_MyLearning_Program__c>) oldRecords;
        Set<Id> userEntryIds = getUserEntryIds(newUserMyLearningPrograms, oldUserMyLearningPrograms);
        UserEntryService.updateLockedUserEntries(userEntryIds);
    }

    private static Set<Id> getUserEntryIds(List<User_MyLearning_Program__c> userMyLearningPrograms){
        Set<Id> userEntryIds = new Set<Id>();
        for(User_MyLearning_Program__c userMyLearningProgram : userMyLearningPrograms){
            userEntryIds.add(userMyLearningProgram.User_Entry__c);
        }
        return userEntryIds;
    }

    private static Set<Id> getUserEntryIds(Map<Id, User_MyLearning_Program__c> newUserMyLearningPrograms, Map<Id, User_MyLearning_Program__c> oldUserMyLearningPrograms){
        Set<Id> userEntryIds = new Set<Id>();
        User_MyLearning_Program__c newUserMyLearningProgram, oldUserMyLearningProgram;
        for(Id userMyLearningProgramId : newUserMyLearningPrograms.keySet()){
            newUserMyLearningProgram = newUserMyLearningPrograms.get(userMyLearningProgramId);
            oldUserMyLearningProgram = oldUserMyLearningPrograms.get(userMyLearningProgramId);
            if(newUserMyLearningProgram.Status__c != oldUserMyLearningProgram.Status__c){
                userEntryIds.add(newUserMyLearningProgram.User_Entry__c);
            }
        }
        return userEntryIds;
    }
}