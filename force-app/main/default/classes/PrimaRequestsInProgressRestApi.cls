@RestResource(urlMapping='/prima/requestsinprogress/*')
global with sharing class PrimaRequestsInProgressRestApi {
    private static final Set<String> STATUSES_TO_UPDATE = new Set<String>{
        UserEntryData.STATUS_ASSIGNED, 
        UserEntryData.STATUS_ERROR
    };

    global class PrimaRequest {
        public List<PrimaData.UserRequest> users;
    }
    
    @HttpGet
    global static PrimaRequest getPrimaRequestsInProgress() {
        PrimaRequest primaRequest = new PrimaRequest();
        primaRequest.users = new List<PrimaData.UserRequest>();
        List<User_Entry__c> userEntries = getLockedUserEntriesWithRolesAndSecurityGroups();
        for(User_Entry__c userEntry : userEntries){
            primaRequest.users.add(new PrimaData.UserRequest(userEntry));
        }
        
        return primaRequest;
    }

    @HttpPost
    global static void updatePrimaRequestsInProgress(List<PrimaData.UserResponse> users) {
        Set<String> cwids = PrimaData.getUserCwids(users);
        Map<String, User_Entry__c> userEntriesByCwid = UserEntryUtils.getUserEntriesByCwid(cwids);

        try {
            updateUserPrimaRoles(users, userEntriesByCwid);
            updateUserPrimaSecurityGroups(users, userEntriesByCwid);
        } catch(Exception ex){
            HandleCustomException.logException(ex);
            RestContext.response.statusCode = 400;
        }
    }

    private static List<User_Entry__c> getLockedUserEntriesWithRolesAndSecurityGroups(){
        List<User_Entry__c> userEntries = new List<User_Entry__c>();
        for(User_Entry__c userEntry : [SELECT CWID__c,
                                              (SELECT Prima_Role__r.Name, Status__c FROM User_Prima_Roles__r 
                                               WHERE Status__c IN :PrimaData.IN_PROGRESS_STATUSES),
                                              (SELECT Prima_Security_Group__r.Name, Status__c FROM User_Prima_Security_Groups__r 
                                               WHERE Status__c IN :PrimaData.IN_PROGRESS_STATUSES)
                                       FROM User_Entry__c WHERE Is_Locked__c = true]){
            if(!userEntry.User_Prima_Roles__r.isEmpty() || !userEntry.User_Prima_Security_Groups__r.isEmpty()){
                userEntries.add(userEntry);
            }
        }
        
        return userEntries;
    }

    private static void updateUserPrimaRoles(List<PrimaData.UserResponse> users, Map<String, User_Entry__c> userEntriesByCwid){
        List<User_Prima_Role__c> userPrimaRolesToUpdate = new List<User_Prima_Role__c>();
        List<User_Prima_Role__c> userPrimaRolesToDelete = new List<User_Prima_Role__c>();

        User_Entry__c userEntry;
        User_Prima_Role__c userPrimaRole;
        for(PrimaData.UserResponse user : users){
            userEntry = userEntriesByCwid.containsKey(user.cwid) ? userEntriesByCwid.get(user.cwid) : null;
            if(userEntry != null && user.primaRoles != null){
                for(PrimaData.PrimaRoleResponse primaRole : user.primaRoles){
                    userPrimaRole = UserEntryUtils.getUserPrimaRoleByName(userEntry, primaRole.name);
                    if(userPrimaRole != null && STATUSES_TO_UPDATE.contains(primaRole.status)){
                        userPrimaRolesToUpdate.add(PrimaData.getUserPrimaRoleToUpdate(userPrimaRole.Id, primaRole));
                    } else if(userPrimaRole != null && primaRole.status == UserEntryData.STATUS_REMOVED){
                        userPrimaRolesToDelete.add(userPrimaRole);
                    }
                }
            }
        }

        update userPrimaRolesToUpdate;
        delete userPrimaRolesToDelete;
    }

    private static void updateUserPrimaSecurityGroups(List<PrimaData.UserResponse> users, Map<String, User_Entry__c> userEntriesByCwid){
        List<User_Prima_Security_Group__c> userPrimaSecurityGroupsToUpdate = new List<User_Prima_Security_Group__c>();
        List<User_Prima_Security_Group__c> userPrimaSecurityGroupsToDelete = new List<User_Prima_Security_Group__c>();

        User_Entry__c userEntry;
        User_Prima_Security_Group__c userPrimaSecurityGroup;
        for(PrimaData.UserResponse user : users){
            userEntry = userEntriesByCwid.containsKey(user.cwid) ? userEntriesByCwid.get(user.cwid) : null;
            if(userEntry != null && user.primaSecurityGroups != null){
                for(PrimaData.PrimaSecurityGroupResponse primaSecurityGroup : user.primaSecurityGroups){
                    userPrimaSecurityGroup = UserEntryUtils.getUserPrimaSecurityGroupByName(userEntry, primaSecurityGroup.name);
                    if(userPrimaSecurityGroup != null && STATUSES_TO_UPDATE.contains(primaSecurityGroup.status)){
                        userPrimaSecurityGroupsToUpdate.add(PrimaData.getUserPrimaSecurityGroupToUpdate(userPrimaSecurityGroup.Id, primaSecurityGroup));
                    } else if(userPrimaSecurityGroup != null && primaSecurityGroup.status == UserEntryData.STATUS_REMOVED){
                        userPrimaSecurityGroupsToDelete.add(userPrimaSecurityGroup);
                    } 
                }
            }
        }
        
        update userPrimaSecurityGroupsToUpdate;
        delete userPrimaSecurityGroupsToDelete;
    }
}