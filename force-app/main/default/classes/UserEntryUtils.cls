/**********************************************************
*  UserEntryUtils
* 
*  Last Modified By: -
*  Last Modified Date: - 16/03/2023
* 
*  Description: Utility class for UserEntry
*  //Added error handling and comments
*
* *********************************************************/
public class UserEntryUtils {
    
    public static final String SHARE_CAUSE_RESOURCE_MANAGER = Schema.User_Entry__Share.rowCause.Resource_Manager__c;
    public static final String SHARE_CAUSE_DEPUTY_MANAGER = Schema.User_Entry__Share.rowCause.Deputy_Manager__c;
    
    public static final String STAFF_STATUS_CURRENT = 'Current';
    public static final String STAFF_STATUS_LEFT = 'Left';
    public static final String STAFF_STATUS_LONG_TERM_LEAVE = 'Long-Term Leave';
    
    public static final String TIME_TRACKING_REQUIRED = 'Required';
    public static final String TIME_TRACKING_NOT_REQUIRED = 'Not Required';
    public static final String TIME_TRACKING_UPDATE_EXISTING = 'Update Existing';
    
    
    public static final String CWID_DEACTIVATED_YES = 'Yes';
    public static final String CWID_DEACTIVATED_NO = 'No';
    
    public static final String GRANT_ACCESS_TO_UMA_YES = 'Yes';
    public static final String GRANT_ACCESS_TO_UMA_NO = 'No';
    
    public static final String LOCATION_GERMANY_BERLIN = 'Germany (Berlin)';
    
    public static final String APPROVAL_STATUS_PENDING = 'Pending for Approval';
    public static final String APPROVAL_STATUS_APPROVED = 'Approved';
    
    public static User_Entry__c getUserEntry(String userEntryId){
        Set<Id> userEntryIds = new Set<Id>{userEntryId};
            List<User_Entry__c> userEntries = getUserEntries(userEntryIds);
        
        if(!userEntries.isEmpty()){
            return userEntries[0];
        }
        return null;
    }
    
    //Return User Entry records based on set of Ids
    public static List<User_Entry__c> getUserEntries(Set<Id> userEntryIds){
        List<User_Entry__c> getUserEntryDetails = new List<User_Entry__c>();
        try{
            getUserEntryDetails = [SELECT Id, Name, Is_Locked__c, Approval_Status__c, Staff_Status__c, Primary_Job_Role__c, Primary_Job_Role__r.Name, 
                                   MAPV_Department__c, MAPV_Department__r.Name, MAPV_Group__c, MAPV_Group__r.Name,
                                   Uma_Company__c, Resource_Manager__c, Deputy_Manager__c,Locations__c,Time_Tracking_Required__c,Working_Hours__c,
                                   (SELECT Id, MyLearning_Program__c, MyLearning_Program__r.Name, Status__c FROM User_MyLearning_Programs__r),
                                   (SELECT Id, Prima_Role__c, Prima_Role__r.Name, Status__c FROM User_Prima_Roles__r),
                                   (SELECT Id, Prima_Security_Group__c, Prima_Security_Group__r.Name, Status__c FROM User_Prima_Security_Groups__r),
                                   (SELECT Id, Status__c FROM User_Time_Trackings__r),
                                   (SELECT Id, Job_Role__c, Job_Role__r.Name FROM User_Additional_Roles__r)
                                   FROM User_Entry__c WHERE Id IN :userEntryIds];
        }
        catch (Exception e) {
            System.debug(HandleCustomException.debugException(e));
        }
        return getUserEntryDetails;
    }
    
    //Return Map of CWID and List of corresponding User Entry Records
    public static Map<String, User_Entry__c> getUserEntriesByCwid(Set<String> cwids){
        Map<String, User_Entry__c> userEntriesByCwid = new Map<String, User_Entry__c>();
        for(User_Entry__c userEntry : [SELECT CWID__c, 
                                       (SELECT Id, Prima_Role__r.Name, Status__c FROM User_Prima_Roles__r),
                                       (SELECT Id, Prima_Security_Group__r.Name, Status__c FROM User_Prima_Security_Groups__r)
                                       FROM User_Entry__c WHERE CWID__c IN :cwids]){
                                           userEntriesByCwid.put(userEntry.CWID__c, userEntry);
                                       }
        return userEntriesByCwid;
    }
    
    public static User_Prima_Role__c getUserPrimaRoleByName(User_Entry__c userEntry, String primaRoleName){
        for(User_Prima_Role__c userPrimaRole : userEntry.User_Prima_Roles__r){
            if(userPrimaRole.Prima_Role__r.Name == primaRoleName){
                return userPrimaRole;
            }
        }
        
        return null;
    }
    
    public static User_Prima_Security_Group__c getUserPrimaSecurityGroupByName(User_Entry__c userEntry, String primaSecurityGroupName){
        for(User_Prima_Security_Group__c userPrimaSecurityGroup : userEntry.User_Prima_Security_Groups__r){
            if(userPrimaSecurityGroup.Prima_Security_Group__r.Name == primaSecurityGroupName){
                return userPrimaSecurityGroup;
            }
        }
        
        return null;
    }
    
    public static User_Entry__Share getNewShareWithResourceManager(Id userEntryId, Id userOrGroupId, String accessLevel){
        return new User_Entry__Share(
            ParentId = userEntryId,
            UserOrGroupId = userOrGroupId,
            AccessLevel = accessLevel,
            RowCause = SHARE_CAUSE_RESOURCE_MANAGER
        );
    }
    
    public static User_Entry__Share getNewShareWithDeputyManager(Id userEntryId, Id userOrGroupId, String accessLevel){
        return new User_Entry__Share(
            ParentId = userEntryId,
            UserOrGroupId = userOrGroupId,
            AccessLevel = accessLevel,
            RowCause = SHARE_CAUSE_DEPUTY_MANAGER
        );
    }
    
    public static Map<Id, List<User_Entry__Share>> getSharingsWithResourceManager(Set<Id> userEntryIds){
        Map<Id, List<User_Entry__Share>> userEntrySharingsMap = new Map<Id, List<User_Entry__Share>>();
        for(User_Entry__Share userEntryShare : [SELECT Id, ParentId, UserOrGroupId, AccessLevel FROM User_Entry__Share 
                                                WHERE ParentId IN :userEntryIds AND RowCause = :SHARE_CAUSE_RESOURCE_MANAGER]){
                                                    if(!userEntrySharingsMap.containsKey(userEntryShare.ParentId)){
                                                        userEntrySharingsMap.put(userEntryShare.ParentId, new List<User_Entry__Share>{userEntryShare});
                                                    } else {
                                                        userEntrySharingsMap.get(userEntryShare.ParentId).add(userEntryShare);
                                                    }
                                                }
        
        return userEntrySharingsMap;
    }
    
    public static Map<Id, List<User_Entry__Share>> getSharingsWithDeputyManager(Set<Id> userEntryIds){
        Map<Id, List<User_Entry__Share>> userEntrySharingsMap = new Map<Id, List<User_Entry__Share>>();
        for(User_Entry__Share userEntryShare : [SELECT Id, ParentId, UserOrGroupId, AccessLevel FROM User_Entry__Share 
                                                WHERE ParentId IN :userEntryIds AND RowCause = :SHARE_CAUSE_DEPUTY_MANAGER]){
                                                    if(!userEntrySharingsMap.containsKey(userEntryShare.ParentId)){
                                                        userEntrySharingsMap.put(userEntryShare.ParentId, new List<User_Entry__Share>{userEntryShare});
                                                    } else {
                                                        userEntrySharingsMap.get(userEntryShare.ParentId).add(userEntryShare);
                                                    }
                                                }
        return userEntrySharingsMap;
    }
    
    public static List<User_Entry__c> getUserEntriesForPrimaUpdates(Set<Id> userEntryIds){
        List<User_Entry__c> userEntries = new List<User_Entry__c>();
        for(User_Entry__c userEntry : [SELECT CWID__c,
                                       (SELECT Id, Prima_Role__r.Name, Status__c 
                                        FROM User_Prima_Roles__r WHERE Status__c IN :PrimaData.NEW_STATUSES),
                                       (SELECT Id, Prima_Security_Group__r.Name, Status__c 
                                        FROM User_Prima_Security_Groups__r WHERE Status__c IN :PrimaData.NEW_STATUSES)
                                       FROM User_Entry__c WHERE Id IN :userEntryIds]){
                                           if(!userEntry.User_Prima_Roles__r.isEmpty() || !userEntry.User_Prima_Security_Groups__r.isEmpty()){
                                               userEntries.add(userEntry);
                                           }
                                       }
        
        return userEntries;
    }
    
    public static Set<Id> getUserEntryIdsForMyLearningUpdates(Set<Id> userEntryIds){
        List<User_Entry__c> userEntries = UserEntryUtils.getUserEntries(userEntryIds);
        Set<Id> userEntriesForMyLearningUpdates = new Set<Id>();
        Set<String> statuses = new Set<String>{UserEntryData.STATUS_ASSIGN, UserEntryData.STATUS_REMOVE};
            
            for(User_Entry__c userEntry : userEntries){
                for(User_MyLearning_Program__c userMyLearningProgram : userEntry.User_MyLearning_Programs__r){
                    if(statuses.contains(userMyLearningProgram.Status__c)){
                        userEntriesForMyLearningUpdates.add(userEntry.Id);
                        break;
                    }
                }
            }
        
        return userEntriesForMyLearningUpdates;
    }
}