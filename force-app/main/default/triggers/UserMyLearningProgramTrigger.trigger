trigger UserMyLearningProgramTrigger on User_MyLearning_Program__c (before delete, after delete, after update) {
    new UserMyLearningProgramTriggerHandler().run();
}