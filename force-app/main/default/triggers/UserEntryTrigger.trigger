trigger UserEntryTrigger on User_Entry__c (before insert, before update, before delete, after insert, after update) {
    new UserEntryTriggerHandler().run();
}