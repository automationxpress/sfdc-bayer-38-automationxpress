trigger UserTimeTrackingTrigger on User_Time_Tracking__c (after delete, after update) {
    new UserTimeTrackingTriggerHandler().run();
}