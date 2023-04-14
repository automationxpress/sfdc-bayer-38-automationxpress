trigger UserPrimaRoleTrigger on User_Prima_Role__c (before delete, after delete, after update) {
    new UserPrimaRoleTriggerHandler().run();
}