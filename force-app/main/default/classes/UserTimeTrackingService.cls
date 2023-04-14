public with sharing class UserTimeTrackingService {
    
    public static final String TO_BE_ASSIGNED = 'Assign';
    public static final String ASSIGNED = 'Assigned';
    public static final String TO_BE_REMOVED = 'Remove';
    public static final String USER_TT_NAME = 'User Time Tracking';
    
    //Create User Time Tracking Record on User Entry Create
    public static void populateUserTimeTrackingsOnUserEntryCreate(Map<Id, User_Entry__c> newUserEntries){
        List<User_Time_Tracking__c> userTTToCreate = new List<User_Time_Tracking__c>();
        
        for(User_Entry__c newUserEntry : newUserEntries.values()){
            if(newUserEntry.Staff_Status__c ==UserEntryUtils.STAFF_STATUS_CURRENT && 
               (newUserEntry.Time_Tracking_Required__c == UserEntryUtils.TIME_TRACKING_REQUIRED || newUserEntry.Time_Tracking_Required__c == UserEntryUtils.TIME_TRACKING_UPDATE_EXISTING)){
                   User_Time_Tracking__c userTTRecord = new User_Time_Tracking__c();
                   userTTRecord.User_Entry__c = newUserEntry.Id;
                   userTTRecord.Name__c = USER_TT_NAME;
                   userTTRecord.Status__c = TO_BE_ASSIGNED;
                   userTTToCreate.add(userTTRecord);
               }
        }
        
        if(userTTToCreate.size()>0){
            insert userTTToCreate;
        }
            
    }
    
    //Create/Update/Delete User Time Tracking Record on User Entry Update
    public static void populateUserTimeTrackingsOnUserEntryUpdate(Map<Id, User_Entry__c> newUserEntries, Map<Id, User_Entry__c> oldUserEntries){
        List<User_Time_Tracking__c> userTTToCreate = new List<User_Time_Tracking__c>();
        List<User_Time_Tracking__c> userTTToUpdate = new List<User_Time_Tracking__c>();
        List<User_Time_Tracking__c> userTTToDelete = new List<User_Time_Tracking__c>();
        List<User_Time_Tracking__c> userTT = new List<User_Time_Tracking__c>();
        Set<Id> userTTID = new Set<Id>();
        Set<Id> userEntryID = new Set<Id>();
        Boolean isStaffStatusChanged, isTimeTrackingChanged, isStaffStatusCurrent;
        User_Entry__c oldUserEntry;
        String newUserTTStatus = '';
        String updateUserTTStatus = '';
        String oldUserTTStatus;
        
        
        for(User_Entry__c newUserEntry : newUserEntries.values()){
            userEntryID.add(newUserEntry.Id);
        }
        userTT = [SELECT Id, Status__c 
                                 FROM User_Time_Tracking__c 
                                 WHERE User_Entry__c IN :userEntryID];
        
        for(User_Entry__c newUserEntry : newUserEntries.values()){
            oldUserEntry = oldUserEntries != null ? oldUserEntries.get(newUserEntry.Id) : null;
            isStaffStatusChanged = newUserEntry.Staff_Status__c != oldUserEntry.Staff_Status__c;
            isTimeTrackingChanged = newUserEntry.Time_Tracking_Required__c != oldUserEntry.Time_Tracking_Required__c;
            isStaffStatusCurrent = newUserEntry.Staff_Status__c == UserEntryUtils.STAFF_STATUS_CURRENT;
            User_Time_Tracking__c userTTRecord = new User_Time_Tracking__c();
            userTTRecord.User_Entry__c = newUserEntry.Id;
            userTTRecord.Name__c = USER_TT_NAME;
            
            if(userTT.size()>0){
                oldUserTTStatus= userTT[0].Status__c;
                userTTRecord.Id = userTT[0].Id;
            }
            
            //when staff status changes to Left/Long Term Leave
            if(isStaffStatusChanged && (!isStaffStatusCurrent)){
                if(!(oldUserEntry!= null && oldUserEntry.Time_Tracking_Required__c== UserEntryUtils.TIME_TRACKING_UPDATE_EXISTING
                     && newUserEntry.Time_Tracking_Required__c == UserEntryUtils.TIME_TRACKING_REQUIRED && oldUserTTStatus==TO_BE_ASSIGNED)){
                       if(oldUserTTStatus== ASSIGNED)
                          updateUserTTStatus= TO_BE_REMOVED;
                       else if(oldUserTTStatus== TO_BE_ASSIGNED)
                       userTTID.add(userTT[0].Id);
                }
            }
            
            //when only staff status changes to Current
            if(isStaffStatusChanged && isStaffStatusCurrent && (!isTimeTrackingChanged)){
                if(newUserEntry.Time_Tracking_Required__c == UserEntryUtils.TIME_TRACKING_REQUIRED || newUserEntry.Time_Tracking_Required__c == UserEntryUtils.TIME_TRACKING_UPDATE_EXISTING){
                    if(oldUserTTStatus==TO_BE_REMOVED)
                        updateUserTTStatus= ASSIGNED;
                    else if(userTT.size()==0)
                        newUserTTStatus= TO_BE_ASSIGNED;
                }
            }
            
            //when only TT Required changed and staff status = Current
            if(!isStaffStatusChanged && isStaffStatusCurrent && isTimeTrackingChanged){
                if(oldUserEntry.Time_Tracking_Required__c== UserEntryUtils.TIME_TRACKING_REQUIRED && newUserEntry.Time_Tracking_Required__c == UserEntryUtils.TIME_TRACKING_NOT_REQUIRED){
                    if(oldUserTTStatus==ASSIGNED){
                       updateUserTTStatus= TO_BE_REMOVED;
                    }
                    else if(oldUserTTStatus== TO_BE_ASSIGNED){
                       userTTID.add(userTT[0].Id);
                    }
                } 
                else if(oldUserEntry.Time_Tracking_Required__c== UserEntryUtils.TIME_TRACKING_REQUIRED && newUserEntry.Time_Tracking_Required__c == UserEntryUtils.TIME_TRACKING_UPDATE_EXISTING && oldUserTTStatus==ASSIGNED){
                	updateUserTTStatus= TO_BE_ASSIGNED;
                }
                else if(oldUserEntry.Time_Tracking_Required__c== UserEntryUtils.TIME_TRACKING_NOT_REQUIRED && newUserEntry.Time_Tracking_Required__c == UserEntryUtils.TIME_TRACKING_REQUIRED){
                    if(oldUserTTStatus== TO_BE_REMOVED){
                        updateUserTTStatus= ASSIGNED;
                    }
                    else if(userTT.size()==0){
                        newUserTTStatus= TO_BE_ASSIGNED;
                    }
                    
                    
                }
            }
            
            //when staff status changed to Current and TT Required also changed
            if(isStaffStatusChanged && isStaffStatusCurrent && isTimeTrackingChanged){
                if(oldUserEntry.Time_Tracking_Required__c== UserEntryUtils.TIME_TRACKING_REQUIRED){
                    if(newUserEntry.Time_Tracking_Required__c == UserEntryUtils.TIME_TRACKING_NOT_REQUIRED && oldUserTTStatus== TO_BE_ASSIGNED){
                       userTTID.add(userTT[0].Id);
                    } 
                    else if(newUserEntry.Time_Tracking_Required__c == UserEntryUtils.TIME_TRACKING_UPDATE_EXISTING && oldUserTTStatus== TO_BE_REMOVED){
                        updateUserTTStatus= ASSIGNED;
                    }
                    else if(newUserEntry.Time_Tracking_Required__c == UserEntryUtils.TIME_TRACKING_UPDATE_EXISTING && userTT.size()==0){
                        newUserTTStatus= TO_BE_ASSIGNED;
                    }
                    
                }
                if(oldUserEntry.Time_Tracking_Required__c== UserEntryUtils.TIME_TRACKING_NOT_REQUIRED && newUserEntry.Time_Tracking_Required__c == UserEntryUtils.TIME_TRACKING_REQUIRED){
                	if(userTT.size()==0)
                        newUserTTStatus= TO_BE_ASSIGNED;
                    else if(oldUserTTStatus== TO_BE_REMOVED)
                        updateUserTTStatus= ASSIGNED;
                }
                
                if(oldUserEntry.Time_Tracking_Required__c== UserEntryUtils.TIME_TRACKING_UPDATE_EXISTING && newUserEntry.Time_Tracking_Required__c == UserEntryUtils.TIME_TRACKING_REQUIRED){
                	if(oldUserTTStatus== ASSIGNED)
                        updateUserTTStatus= TO_BE_ASSIGNED;
                    //else if(oldUserTTStatus== TO_BE_ASSIGNED)
                      //  updateUserTTStatus= ASSIGNED;
                    else if(oldUserTTStatus== TO_BE_REMOVED)
                         updateUserTTStatus= ASSIGNED;
                    else if(userTT.size()==0)
                        newUserTTStatus= TO_BE_ASSIGNED;
                }
                    
                
             }
             
            
            if(updateUserTTStatus!=''){
                userTTRecord.Status__c = updateUserTTStatus;
                userTTToUpdate.add(userTTRecord);
            }
            
            if(newUserTTStatus!=''){
                userTTRecord.Status__c = newUserTTStatus;
                userTTToCreate.add(userTTRecord);
            }
        }
        
        if(userTTToUpdate.size()>0)
            update userTTToUpdate;
        
        if(userTTToCreate.size()>0)
            insert userTTToCreate;
        
        if(userTTID.size()>0){
           userTTToDelete = [SELECT Id 
                                    FROM User_Time_Tracking__c 
                                    WHERE Id IN :userTTID];
        }
        
        if(userTTToDelete.size()>0)
            delete userTTToDelete;
            
    }
    
    
}