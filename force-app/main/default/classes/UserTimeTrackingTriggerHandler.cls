public class UserTimeTrackingTriggerHandler extends TriggerHandler{
    
	public override void afterDelete(Map<Id, SObject> oldRecords){
        Map<Id, User_Time_Tracking__c> oldUserTimeTrackings = (Map<Id, User_Time_Tracking__c>) oldRecords;
        Set<Id> userEntryIds = getUserEntryIds(oldUserTimeTrackings.values());
        UserEntryService.updateLockedUserEntries(userEntryIds);
    }
    
    public override void afterUpdate(Map<Id, SObject> newRecords, Map<Id, SObject> oldRecords) {
        Map<Id, User_Time_Tracking__c> newUserTimeTrackings = (Map<Id, User_Time_Tracking__c>) newRecords;
        Map<Id, User_Time_Tracking__c> oldUserTimeTrackings = (Map<Id, User_Time_Tracking__c>) oldRecords;
        Set<Id> userEntryIds = getUserEntryIds(newUserTimeTrackings, oldUserTimeTrackings);
        UserEntryService.updateLockedUserEntries(userEntryIds);
    }
    
    private static Set<Id> getUserEntryIds(List<User_Time_Tracking__c> userTimeTrackings){
        Set<Id> userEntryIds = new Set<Id>();
        for(User_Time_Tracking__c userTimeTracking : userTimeTrackings){
            userEntryIds.add(userTimeTracking.User_Entry__c);
        }
        return userEntryIds;
    }
    
    private static Set<Id> getUserEntryIds(Map<Id, User_Time_Tracking__c> newUserTimeTrackings, Map<Id, User_Time_Tracking__c> oldUserTimeTrackings){
        Set<Id> userEntryIds = new Set<Id>();
        User_Time_Tracking__c newUserTimeTracking, oldUserTimeTracking;
        for(Id userTimeTrackingId : newUserTimeTrackings.keySet()){
            newUserTimeTracking = newUserTimeTrackings.get(userTimeTrackingId);
            oldUserTimeTracking = oldUserTimeTrackings.get(userTimeTrackingId);
            if(newUserTimeTracking.Status__c != oldUserTimeTracking.Status__c){
                userEntryIds.add(newUserTimeTracking.User_Entry__c);
            }
        }
        return userEntryIds;
    }
}