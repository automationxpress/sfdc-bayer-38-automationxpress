/**********************************************************
*  UserEntryEditController
* 
*  Last Modified By: -
*  Last Modified Date: - 16/03/2023
* 
*  Description: controller class for Lightning Web Component - 'UserEntryEdit'.
*  //Added error handling and comments
*
* *********************************************************/

// Controller class for UserEntryEdit LWC component
public with sharing class UserEntryEditController {
    
    // Return User Entry details (in UserEntryData) based on id
    @AuraEnabled
    public static UserEntryData getUserEntryData(String userEntryId){
        UserEntryData userEntryData = new UserEntryData();
        if(String.isBlank(userEntryId)){
            return userEntryData;
        }
        
        try {
            User_Entry__c userEntry = UserEntryUtils.getUserEntry(userEntryId);
            userEntryData.userEntryId = userEntry.Id;
            userEntryData.isLocked = userEntry.Is_Locked__c;
            userEntryData.isStaffStatusCurrent = userEntry.Staff_Status__c == UserEntryUtils.STAFF_STATUS_CURRENT;
            if(userEntry.Staff_Status__c==UserEntryUtils.STAFF_STATUS_LEFT || userEntry.Staff_Status__c==UserEntryUtils.STAFF_STATUS_LONG_TERM_LEAVE){
                userEntryData.isStaffStatusLeft=true;
            }
            else{
                userEntryData.isStaffStatusLeft=false;
            }
            
            userEntryData.isStaffStatusLongTermLeave = userEntry.Staff_Status__c == UserEntryUtils.STAFF_STATUS_LONG_TERM_LEAVE;
            userEntryData.primaryJobRole = userEntry.Primary_Job_Role__r.Name;
            userEntryData.primaryJobRoleId = userEntry.Primary_Job_Role__c;
            userEntryData.MAPVDepartment = userEntry.MAPV_Department__c;
            userEntryData.MAPVDepartmentName = userEntry.MAPV_Department__r.Name;
            userEntryData.MAPVGroup = userEntry.MAPV_Group__c;
            userEntryData.MAPVGroupName = userEntry.MAPV_Group__r.Name;
            userEntryData.umaCompany = userEntry.Uma_Company__c;
            userEntryData.approvalStatus = userEntry.Approval_Status__c;
            userEntryData.locations = userEntry.Locations__c;
            userEntryData.timeTrackingRequired = userEntry.Time_Tracking_Required__c;
            userEntryData.setJobRoles(userEntry.User_Additional_Roles__r);
            userEntryData.setMyLearningPrograms(userEntry.User_MyLearning_Programs__r);
            userEntryData.setPrimaRoles(userEntry.User_Prima_Roles__r);
            userEntryData.setPrimaSecurityGroups(userEntry.User_Prima_Security_Groups__r);
            
            if(!userEntryData.isStaffStatusLeft && !userEntryData.isStaffStatusLongTermLeave){
                applyRoleMatricesData(userEntryData);
            } 
            
        } catch (Exception e) {
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        system.debug('@@getUserEntryData -userEntryData = '+userEntryData);
        return userEntryData;
    }
    
    //calling from lwc, to set junctions objects - User_MyLearning_Programs, User_Prima_Roles and User_Prima_Security_Groups
    @AuraEnabled (cacheable=true)
    public static UserEntryData refreshRoleMatricesData(UserEntryData userEntryDetails){
        system.debug('@@refreshRoleMatricesData= '+userEntryDetails);
        User_Entry__c userEntry = UserEntryUtils.getUserEntry(userEntryDetails.userEntryId);
        if(userEntry != null){
            userEntryDetails.setMyLearningPrograms(userEntry.User_MyLearning_Programs__r);
            userEntryDetails.setPrimaRoles(userEntry.User_Prima_Roles__r);
            userEntryDetails.setPrimaSecurityGroups(userEntry.User_Prima_Security_Groups__r);
        }
        
        if(!userEntryDetails.isStaffStatusLeft && !userEntryDetails.isStaffStatusLongTermLeave){
            applyRoleMatricesData(userEntryDetails);
        }
        return userEntryDetails;
    }
    
    //based on userEntryDetails, get the matcing Role Matrix record and returns the corresponding MyLearnings,Prima Roles and Prima SGs
    //and based on this populate MyLearnings, Prima Roles and Prima SGs in User Entry
    private static void applyRoleMatricesData(UserEntryData userEntryDetails){
        Set<Id> jobRoleIds = SObjectUtils.getRecordIds(userEntryDetails.jobRoles);
        jobRoleIds.add(userEntryDetails.primaryJobRoleId);
        
        List<Role_Matrix__c> roleMatrices = RoleMatrixUtils.getRoleMatrices(
            jobRoleIds, 
            userEntryDetails.MAPVDepartment, 
            userEntryDetails.MAPVGroup, 
            userEntryDetails.umaCompany
        );
        System.debug('roleMatrices: '+roleMatrices);
        
        setMyLearningPrograms(userEntryDetails, roleMatrices);
        setPrimaRoles(userEntryDetails, roleMatrices);
        setPrimaSecurityGroups(userEntryDetails, roleMatrices);
        
        System.debug('primaRoles: '+userEntryDetails.primaRoles);
        System.debug('primaSecurityGroups: '+userEntryDetails.primaSecurityGroups);
    }
    
    private static void setMyLearningPrograms(UserEntryData userEntryDetails, List<Role_Matrix__c> roleMatrices){
        Map<Id, UserEntryData.UserEntryItem> userMyLearningPrograms = userEntryDetails.getMyLearningProgramsMap();
        Map<Id, MyLearning_Program__c> newMyLearningPrograms = RoleMatrixService.getMyLearningProgramsMap(roleMatrices);
        
        Set<Id> myLearningProgramIds = new Set<Id>();
        myLearningProgramIds.addAll(userMyLearningPrograms.keySet());
        myLearningProgramIds.addAll(newMyLearningPrograms.keySet());
        
        Set<Id> myLearningProgramIdsToRemove = new Set<Id>();
        for(Id myLearningProgramId : myLearningProgramIds){
            if(!userMyLearningPrograms.containsKey(myLearningProgramId) && newMyLearningPrograms.containsKey(myLearningProgramId)){
                userEntryDetails.addNewMyLearningProgram(myLearningProgramId, newMyLearningPrograms.get(myLearningProgramId).Name);
            } else if(userMyLearningPrograms.containsKey(myLearningProgramId) && !newMyLearningPrograms.containsKey(myLearningProgramId)
                      && userMyLearningPrograms.get(myLearningProgramId).status == UserEntryData.STATUS_ASSIGN){
                          myLearningProgramIdsToRemove.add(myLearningProgramId);
                      } else if(userMyLearningPrograms.containsKey(myLearningProgramId) && !newMyLearningPrograms.containsKey(myLearningProgramId)
                                && userMyLearningPrograms.get(myLearningProgramId).status == UserEntryData.STATUS_ASSIGNED){
                                    userMyLearningPrograms.get(myLearningProgramId).setStatus(UserEntryData.STATUS_REMOVE);
                                } else if(userMyLearningPrograms.containsKey(myLearningProgramId) && newMyLearningPrograms.containsKey(myLearningProgramId)
                                          && userMyLearningPrograms.get(myLearningProgramId).status == UserEntryData.STATUS_REMOVE){
                                              userMyLearningPrograms.get(myLearningProgramId).setStatus(UserEntryData.STATUS_ASSIGNED);
                                          }
        }
        userEntryDetails.removeMyLearningPrograms(myLearningProgramIdsToRemove);
    }
    
    private static void setPrimaRoles(UserEntryData userEntryDetails, List<Role_Matrix__c> roleMatrices){
        Map<Id, UserEntryData.UserEntryItem> userPrimaRoles = userEntryDetails.getPrimaRolesMap();
        Map<Id, Prima_Role__c> newPrimaRoles = RoleMatrixService.getPrimaRolesMap(roleMatrices);
        
        Set<Id> primaRoleIds = new Set<Id>();
        primaRoleIds.addAll(userPrimaRoles.keySet());
        primaRoleIds.addAll(newPrimaRoles.keySet());
        
        Set<Id> primaRoleIdsToRemove = new Set<Id>();
        for(Id primaRoleId : primaRoleIds){
            if(!userPrimaRoles.containsKey(primaRoleId) && newPrimaRoles.containsKey(primaRoleId)){
                userEntryDetails.addNewPrimaRole(primaRoleId, newPrimaRoles.get(primaRoleId).Name);
            } else if(userPrimaRoles.containsKey(primaRoleId) && !newPrimaRoles.containsKey(primaRoleId)
                      && userPrimaRoles.get(primaRoleId).status == UserEntryData.STATUS_ASSIGN){
                          primaRoleIdsToRemove.add(primaRoleId);
                      } else if(userPrimaRoles.containsKey(primaRoleId) && !newPrimaRoles.containsKey(primaRoleId)
                                && userPrimaRoles.get(primaRoleId).status == UserEntryData.STATUS_ASSIGNED){
                                    userPrimaRoles.get(primaRoleId).setStatus(UserEntryData.STATUS_REMOVE);
                                } else if(userPrimaRoles.containsKey(primaRoleId) && newPrimaRoles.containsKey(primaRoleId)
                                          && userPrimaRoles.get(primaRoleId).status == UserEntryData.STATUS_REMOVE){
                                              userPrimaRoles.get(primaRoleId).setStatus(UserEntryData.STATUS_ASSIGNED);
                                          }
        }
        userEntryDetails.removePrimaRoles(primaRoleIdsToRemove);
    }
    
    private static void setPrimaSecurityGroups(UserEntryData userEntryDetails, List<Role_Matrix__c> roleMatrices){
        Map<Id, UserEntryData.UserEntryItem> userPrimaSecurityGroups = userEntryDetails.getPrimaSecurityGroupsMap();
        Map<Id, Prima_Security_Group__c> newPrimaSecurityGroups = RoleMatrixService.getPrimaSecurityGroupsMap(roleMatrices);
        
        Set<Id> primaSecurityGroupIds = new Set<Id>();
        primaSecurityGroupIds.addAll(userPrimaSecurityGroups.keySet());
        primaSecurityGroupIds.addAll(newPrimaSecurityGroups.keySet());
        
        Set<Id> primaSecurityGroupIdsToRemove = new Set<Id>();
        for(Id primaSecurityGroupId : primaSecurityGroupIds){
            if(!userPrimaSecurityGroups.containsKey(primaSecurityGroupId) && newPrimaSecurityGroups.containsKey(primaSecurityGroupId)){
                userEntryDetails.addNewPrimaSecurityGroup(primaSecurityGroupId, newPrimaSecurityGroups.get(primaSecurityGroupId).Name);
            } else if(userPrimaSecurityGroups.containsKey(primaSecurityGroupId) && !newPrimaSecurityGroups.containsKey(primaSecurityGroupId)
                      && userPrimaSecurityGroups.get(primaSecurityGroupId).status == UserEntryData.STATUS_ASSIGN){
                          primaSecurityGroupIdsToRemove.add(primaSecurityGroupId);
                      } else if(userPrimaSecurityGroups.containsKey(primaSecurityGroupId) && !newPrimaSecurityGroups.containsKey(primaSecurityGroupId)
                                && userPrimaSecurityGroups.get(primaSecurityGroupId).status == UserEntryData.STATUS_ASSIGNED){
                                    userPrimaSecurityGroups.get(primaSecurityGroupId).setStatus(UserEntryData.STATUS_REMOVE);
                                } else if(userPrimaSecurityGroups.containsKey(primaSecurityGroupId) && newPrimaSecurityGroups.containsKey(primaSecurityGroupId)
                                          && userPrimaSecurityGroups.get(primaSecurityGroupId).status == UserEntryData.STATUS_REMOVE){
                                              userPrimaSecurityGroups.get(primaSecurityGroupId).setStatus(UserEntryData.STATUS_ASSIGNED);
                                          }
        }
        userEntryDetails.removePrimaSecurityGroups(primaSecurityGroupIdsToRemove);
    }
    
    // calling this method when User clicks Save button in UserEntryEdit lwc component
    // Save User Entry record, insert/delete the Additional Job Roles,updating junction object records
    @AuraEnabled
    public static void saveUserEntryData(UserEntryData userEntryData){
        try{
            User_Entry__c userEntry = UserEntryUtils.getUserEntry(userEntryData.userEntryId);
            userEntry.Primary_Job_Role__c = userEntryData.primaryJobRole;
            userEntry.Locations__c = userEntryData.locations;
            update userEntry;
            
            List<User_Additional_Role__c> additionalJobRolesToAdd = getAdditionalJobRolesToAdd(userEntryData, userEntry);
            List<User_Additional_Role__c> additionalJobRolesToRemove = getAdditionalJobRolesToRemove(userEntryData, userEntry);
            insert additionalJobRolesToAdd;
            delete additionalJobRolesToRemove;
            
            updateUserMyLearningPrograms(userEntryData, userEntry);
            updateUserPrimaRoles(userEntryData, userEntry);
            updateUserPrimaSecurityGroups(userEntryData, userEntry);
        
        } catch (Exception e) {
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    private static List<User_Additional_Role__c> getAdditionalJobRolesToAdd(UserEntryData userEntryData, User_Entry__c userEntry){
        Set<Id> additionalJobRoleIds = new Set<Id>();
        for(User_Additional_Role__c userEntryJobRole : userEntry.User_Additional_Roles__r){
            additionalJobRoleIds.add(userEntryJobRole.Job_Role__c);
        }
        List<User_Additional_Role__c> additionalJobRolesToAdd = new List<User_Additional_Role__c>();
        for(Job_Role__c jobRole : userEntryData.jobRoles){
            if(!additionalJobRoleIds.contains(jobRole.Id)){
                system.debug('@@inside getAdditionalJobRolesToAdd - jobRole.Id ' + jobRole.Id);
                additionalJobRolesToAdd.add(new User_Additional_Role__c(
                    User_Entry__c = userEntryData.userEntryId,
                    Job_Role__c = jobRole.Id
                ));
            }
        }
        
        return additionalJobRolesToAdd;
    }
    
    private static List<User_Additional_Role__c> getAdditionalJobRolesToRemove(UserEntryData userEntryData, User_Entry__c userEntry){
        Set<Id> additionalJobRoleIds = SObjectUtils.getRecordIds(userEntryData.jobRoles);
        
        List<User_Additional_Role__c> jobRolesToRemove = new List<User_Additional_Role__c>();
        for(User_Additional_Role__c userEntryJobRole : userEntry.User_Additional_Roles__r){
            if(!additionalJobRoleIds.contains(userEntryJobRole.Job_Role__c)){
                jobRolesToRemove.add(userEntryJobRole);
            }
        }
        return jobRolesToRemove;
    }
    
    private static void updateUserMyLearningPrograms(UserEntryData newUserEntryData, User_Entry__c userEntry){
        Map<Id, UserEntryData.UserEntryItem> newMyLearningPrograms = newUserEntryData.getMyLearningProgramsMap();
        Map<Id, User_MyLearning_Program__c> oldUserMyLearningPrograms = getUserMyLearningProgramsMap(userEntry.User_MyLearning_Programs__r);
        
        List<User_MyLearning_Program__c> myLearningProgramsToAdd = new List<User_MyLearning_Program__c>();
        List<User_MyLearning_Program__c> myLearningProgramsToUpdate = new List<User_MyLearning_Program__c>();
        List<User_MyLearning_Program__c> myLearningProgramsToRemove = new List<User_MyLearning_Program__c>();
        
        for(Id myLearningProgramId : newMyLearningPrograms.keySet()){
            if(!oldUserMyLearningPrograms.containsKey(myLearningProgramId)){
                myLearningProgramsToAdd.add(new User_MyLearning_Program__c(
                    User_Entry__c = userEntry.Id,
                    MyLearning_Program__c = myLearningProgramId,
                    Status__c = UserEntryData.STATUS_ASSIGN
                ));
            }
        }
        
        for(Id myLearningProgramId : oldUserMyLearningPrograms.keySet()){
            if(newMyLearningPrograms.containsKey(myLearningProgramId)){
                myLearningProgramsToUpdate.add(
                    new User_MyLearning_Program__c(
                        Id = oldUserMyLearningPrograms.get(myLearningProgramId).Id,
                        Status__c = newMyLearningPrograms.get(myLearningProgramId).status
                    )
                );
            } else {
                myLearningProgramsToRemove.add(oldUserMyLearningPrograms.get(myLearningProgramId));
            }
        }
        try{
            insert myLearningProgramsToAdd;
            update myLearningProgramsToUpdate;
            delete myLearningProgramsToRemove;
        }
        catch(Exception e) {
            System.debug(HandleCustomException.debugException(e));
        }
    }
    
    private static void updateUserPrimaRoles(UserEntryData newUserEntryData, User_Entry__c userEntry){
        Map<Id, UserEntryData.UserEntryItem> newPrimaRoles = newUserEntryData.getPrimaRolesMap();
        Map<Id, User_Prima_Role__c> oldUserPrimaRoles = getUserPrimaRolesMap(userEntry.User_Prima_Roles__r);
        
        List<User_Prima_Role__c> primaRolesToAdd = new List<User_Prima_Role__c>();
        List<User_Prima_Role__c> primaRolesToUpdate = new List<User_Prima_Role__c>();
        List<User_Prima_Role__c> primaRolesToRemove = new List<User_Prima_Role__c>();
        
        for(Id primaRoleId : newPrimaRoles.keySet()){
            if(!oldUserPrimaRoles.containsKey(primaRoleId)){
                primaRolesToAdd.add(new User_Prima_Role__c(
                    User_Entry__c = userEntry.Id,
                    Prima_Role__c = primaRoleId,
                    Status__c = UserEntryData.STATUS_ASSIGN
                ));
            }
        }
        
        for(Id primaRoleId : oldUserPrimaRoles.keySet()){
            if(newPrimaRoles.containsKey(primaRoleId)){
                primaRolesToUpdate.add(
                    new User_Prima_Role__c(
                        Id = oldUserPrimaRoles.get(primaRoleId).Id,
                        Status__c = newPrimaRoles.get(primaRoleId).status
                    )
                );
            } else {
                primaRolesToRemove.add(oldUserPrimaRoles.get(primaRoleId));
            }
        }
        
        try{
            insert primaRolesToAdd;
            update primaRolesToUpdate;
            delete primaRolesToRemove;
        }
        catch(Exception e){
            System.debug(HandleCustomException.debugException(e));
        }
    }
    
    private static void updateUserPrimaSecurityGroups(UserEntryData newUserEntryData, User_Entry__c userEntry){
        Map<Id, UserEntryData.UserEntryItem> newPrimaSecurityGroups = newUserEntryData.getPrimaSecurityGroupsMap();
        Map<Id, User_Prima_Security_Group__c> oldUserPrimaSecurityGroups = getUserPrimaSecurityGroupsMap(userEntry.User_Prima_Security_Groups__r);
        
        List<User_Prima_Security_Group__c> primaSecurityGroupsToAdd = new List<User_Prima_Security_Group__c>();
        List<User_Prima_Security_Group__c> primaSecurityGroupsToUpdate = new List<User_Prima_Security_Group__c>();
        List<User_Prima_Security_Group__c> primaSecurityGroupsToRemove = new List<User_Prima_Security_Group__c>();
        
        for(Id primaSecurityGroupId : newPrimaSecurityGroups.keySet()){
            if(!oldUserPrimaSecurityGroups.containsKey(primaSecurityGroupId)){
                primaSecurityGroupsToAdd.add(new User_Prima_Security_Group__c(
                    User_Entry__c = userEntry.Id,
                    Prima_Security_Group__c = primaSecurityGroupId,
                    Status__c = UserEntryData.STATUS_ASSIGN
                ));
            }
        }
        
        for(Id primaSecurityGroupId : oldUserPrimaSecurityGroups.keySet()){
            if(newPrimaSecurityGroups.containsKey(primaSecurityGroupId)){
                primaSecurityGroupsToUpdate.add(
                    new User_Prima_Security_Group__c(
                        Id = oldUserPrimaSecurityGroups.get(primaSecurityGroupId).Id,
                        Status__c = newPrimaSecurityGroups.get(primaSecurityGroupId).status
                    )
                );
            } else {
                primaSecurityGroupsToRemove.add(oldUserPrimaSecurityGroups.get(primaSecurityGroupId));
            }
        }
        
        try{
            insert primaSecurityGroupsToAdd;
            update primaSecurityGroupsToUpdate;
            delete primaSecurityGroupsToRemove;
        }
        catch(Exception e){
            System.debug(HandleCustomException.debugException(e));
        }
    }
    
    private static Map<Id, User_MyLearning_Program__c> getUserMyLearningProgramsMap(List<User_MyLearning_Program__c> userMyLearningPrograms){
        Map<Id, User_MyLearning_Program__c> userMyLearningProgramsMap = new Map <Id, User_MyLearning_Program__c>();
        for(User_MyLearning_Program__c userMyLearningProgram : userMyLearningPrograms){
            userMyLearningProgramsMap.put(userMyLearningProgram.MyLearning_Program__c, userMyLearningProgram);
        }
        
        return userMyLearningProgramsMap;
    }
    
    private static Map<Id, User_Prima_Role__c> getUserPrimaRolesMap(List<User_Prima_Role__c> userPrimaRoles){
        Map<Id, User_Prima_Role__c> userPrimaRolesMap = new Map <Id, User_Prima_Role__c>();
        for(User_Prima_Role__c userPrimaRole : userPrimaRoles){
            userPrimaRolesMap.put(userPrimaRole.Prima_Role__c, userPrimaRole);
        }
        
        return userPrimaRolesMap;
    }
    
    private static Map<Id, User_Prima_Security_Group__c> getUserPrimaSecurityGroupsMap(List<User_Prima_Security_Group__c> userPrimaSecurityGroups){
        Map<Id, User_Prima_Security_Group__c> userPrimaSecurityGroupsMap = new Map <Id, User_Prima_Security_Group__c>();
        for(User_Prima_Security_Group__c userPrimaSecurityGroup : userPrimaSecurityGroups){
            userPrimaSecurityGroupsMap.put(userPrimaSecurityGroup.Prima_Security_Group__c, userPrimaSecurityGroup);
        }
        
        return userPrimaSecurityGroupsMap;
    }
    
    
    @AuraEnabled (cacheable=true)
    public static List<JobRoleWrapper> getJobRoleRecords(String filter, String searchKey){
        String key = '%'+searchKey+'%';
        String query = 'SELECT Id, Name, Job_Role__c FROM Role_Matrix__c';
        if(filter!= ''){
            query += ' WHERE Main_Role_Add_on_Formula__c =: filter';
        }
        List<Role_Matrix__c> roleMatrixMainList = Database.query(query);
        List<Id> jobRoleIdList = new List<Id>();
        
        for(Role_Matrix__c roleMatrix : roleMatrixMainList){
            jobRoleIdList.add(roleMatrix.Job_Role__c);
        }
        
        String jobRolequery = 'Select Id, Name From Job_Role__c WHERE ID IN : jobRoleIdList';
        if(searchKey!= ''){
            jobRolequery += ' AND Name LIKE: key';
        }
        
        List<Job_Role__c> jobRoleList = Database.query(jobRolequery);
        List<JobRoleWrapper> lstReturnResult = new List<JobRoleWrapper>();
        
        for(Job_Role__c jobRole : jobRoleList){
            JobRoleWrapper result = new JobRoleWrapper();
            result.recordId = jobRole.Id;
            result.recordName = jobRole.Name;
            lstReturnResult.add(result);
        }
        return lstReturnResult;
    }
    
    //Submit the User Entry Record for approval when user clicks 'Save and Submit for Approval' button in UserEntryEdit component
    @AuraEnabled
    public static void submitForApproval(String recordId){
        String comments = 'Submitting User Entry request for approval.';
        try{
            ApprovalProcessService.submitForApproval(recordId, comments);
        }catch (Exception e) {
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    } 
    
    public class JobRoleWrapper {
        @AuraEnabled public String recordId;
        @AuraEnabled public String recordName;
    }
    
    // Returns Location options in lwc- UserEntryEdit component 
    // based on passed search key. if search kex is blank return all Location options
    @AuraEnabled
    public static List<String> getLocationOptions(String searchKey){
        List<String> allLocationValues = new List<String>();
        List<String> filterLocationValues = new List<String>();
        List<String> locationValues = new List<String>();
        try{
            Schema.SObjectType objType = Schema.getGlobalDescribe().get('User_Entry__c');
            Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
            Schema.DescribeFieldResult objFieldInfo = objDescribe.fields.getMap().get('Locations__c').getDescribe();
            List<Schema.PicklistEntry> picklistValues = objFieldInfo.getPicklistValues();
            
            //Add the picklist values to list
            for(Schema.PicklistEntry plv: picklistValues) {
                allLocationValues.add(plv.getValue());
            }
            allLocationValues.sort();
            if(searchKey==''){
                locationValues.addAll(allLocationValues);
            }
            else{
                for(String str : allLocationValues){
                    if(str.containsIgnoreCase(searchKey)){
                        filterLocationValues.add(str);
                    }
                }
                locationValues.addAll(filterLocationValues);
            }
        }catch (Exception e) {
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        return locationValues;
    }
    
    @AuraEnabled
    public static List<SObject> getAllRecords(String objectApiName) {
        try {
            String queryString = 'SELECT Id, Name FROM ' + objectApiName;
            
            if (objectApiName == 'MAPV_Department__c' || objectApiName == 'MAPV_Group__c') {
                queryString = 'SELECT Id, Name, Abbreviation__c FROM ' + objectApiName;
            }
            return Database.query(String.escapeSingleQuotes(queryString));
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}