trigger UserPrimaSecurityGroupTrigger on User_Prima_Security_Group__c (before delete, after delete, after update) {
    new UserPrimaSecurityGroupTriggerHandler().run();
}