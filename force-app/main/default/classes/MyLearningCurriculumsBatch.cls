public class MyLearningCurriculumsBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    public final Set<Id> userEntryIds;
    
    public MyLearningCurriculumsBatch(Set<Id> ids){
        userEntryIds = ids;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT User_Entry__r.CWID__c, MyLearning_Program__r.ID__c, Status__c';
        query += ' FROM User_MyLearning_Program__c';
        query += ' WHERE User_Entry__c IN :userEntryIds AND Status__c = \'' + UserEntryData.STATUS_ASSIGN + '\'';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<User_MyLearning_Program__c> scope){
        List<User_MyLearning_Program__c> userMLProgramsToAssign = new List<User_MyLearning_Program__c>();
        List<User_MyLearning_Program__c> userMLProgramsToUpdate = new List<User_MyLearning_Program__c>();
        
        String curriculumStatus;
        for(User_MyLearning_Program__c userMLProgram : scope){
            curriculumStatus = MyLearningService.getCurriculumStatus(
                userMLProgram.User_Entry__r.CWID__c, 
                userMLProgram.MyLearning_Program__r.ID__c
            );
            if(MyLearningService.isCurriculumAssigned(curriculumStatus)){
                userMLProgram.Status__c = UserEntryData.STATUS_ASSIGNED;
                userMLProgramsToUpdate.add(userMLProgram);
            } else {
                userMLProgramsToAssign.add(userMLProgram);
            }
        }
        
        if(!userMLProgramsToAssign.isEmpty()){
            Map<String, Map<String, MyLearningService.CurriculumResponse>> curriculumResponseMap = MyLearningService.assignCurriculums(userMLProgramsToAssign);
            
            MyLearningService.CurriculumResponse response;
            for(User_MyLearning_Program__c userMLProgram : userMLProgramsToAssign){
                response = MyLearningService.getCurriculumResponse(
                    curriculumResponseMap, 
                    userMLProgram.User_Entry__r.CWID__c, 
                    userMLProgram.MyLearning_Program__r.ID__c
                );
                if(response != null && response.errorMessage == null){
                    userMLProgram.Status__c = UserEntryData.STATUS_ASSIGNED;
                    userMLProgramsToUpdate.add(userMLProgram);
                } else if(response != null){
                    userMLProgram.Status__c = UserEntryData.STATUS_ERROR;
                    userMLProgram.Error_Message__c = response.errorMessage;
                    userMLProgramsToUpdate.add(userMLProgram);
                }
            }
        }
        
        update userMLProgramsToUpdate;
    }

    public void finish(Database.BatchableContext BC){}
}