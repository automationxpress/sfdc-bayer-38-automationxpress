/**********************************************************
*  UserEntryService
* 
*  Last Modified By: -
*  Last Modified Date: - 16/03/2023
* 
*  Description: Service class for UserEntry
*  //Added error handling and comments
*
* *********************************************************/

public class UserEntryService {
    
    //User Entry record should not be deleted when Staff Status is 'Left' else display error message
    public static void validateUserEntriesOnDelete(Map<Id, User_Entry__c> oldUserEntries) {
        Boolean isStaffStatusLeft;
        for(User_Entry__c userEntry : oldUserEntries.values()){
            isStaffStatusLeft = UserEntryUtils.STAFF_STATUS_LEFT.equals(userEntry.Staff_Status__c);
            if(!isStaffStatusLeft){
                userEntry.addError(Label.UserEntryCannotBeDeleted);
            }
        }
    }
    
    // Set Is_Locked__c field to true when Approval is done and all assignments are done (Status=Assigned)
    public static void setIsLocked(Map<Id, User_Entry__c> newUserEntries){
        Set<Id> userEntryIds = new Set<Id>();
        for(User_Entry__c newUserEntry : newUserEntries.values()){
            if(newUserEntry.Approval_Status__c == UserEntryUtils.APPROVAL_STATUS_APPROVED){
                userEntryIds.add(newUserEntry.Id);
            }
        }
        
        for(User_Entry__c userEntry : UserEntryUtils.getUserEntries(userEntryIds)){
            newUserEntries.get(userEntry.Id).Is_Locked__c = isUserEntryLocked(userEntry);
        }
    }
    
    //Once all assignments done after aproval, uncheck the Is_Locked__c field and set Approval_Status__c to null
    public static void updateLockedUserEntries(Set<Id> userEntryIds){
        List<User_Entry__c> userEntriesToUpdate = new List<User_Entry__c>();
        for(User_Entry__c userEntry : UserEntryUtils.getUserEntries(userEntryIds)){
            if(!isUserEntryLocked(userEntry)){
                userEntriesToUpdate.add(
                    new User_Entry__c(
                        Id = userEntry.Id,
                        Is_Locked__c = false,
                        Approval_Status__c = null
                    )
                );
            }
        }
        try{
            update userEntriesToUpdate;
        }
        catch(Exception e) {
            System.debug(HandleCustomException.debugException(e));
        }
    }
    
    //Share User Entry record to Resource Manager on insert
    public static void shareUserEntryRecordsWithResourceManager(Map<Id, User_Entry__c> newUserEntries) {
        addUserEntrySharingsWithResourceManager(newUserEntries, null);
    }
    
    //Share User Entry record to Resource Manager on update
    public static void shareUserEntryRecordsWithResourceManager(Map<Id, User_Entry__c> newUserEntries, Map<Id, User_Entry__c> oldUserEntries) {
        removeUserEntrySharingsWithResourceManager(newUserEntries, oldUserEntries);
        addUserEntrySharingsWithResourceManager(newUserEntries, oldUserEntries);
    }
    
    //Share User Entry record to Deputy Manager on insert
    public static void shareUserEntryRecordsWithDeputyManager(Map<Id, User_Entry__c> newUserEntries) {
        addUserEntrySharingsWithDeputyManager(newUserEntries, null);
    }
    
    //Share User Entry record to Deputy Manager on update
    public static void shareUserEntryRecordsWithDeputyManager(Map<Id, User_Entry__c> newUserEntries, Map<Id, User_Entry__c> oldUserEntries) {
        removeUserEntrySharingsWithDeputyManager(newUserEntries, oldUserEntries);
        addUserEntrySharingsWithDeputyManager(newUserEntries, oldUserEntries);
    }
    
    // Return True/False based on all assignments status
    public static Boolean isUserEntryLocked(User_Entry__c userEntry){
        Set<String> statuses = new Set<String>{UserEntryData.STATUS_ASSIGNED};
            if(areAllMyLearningProgramsInStatuses(userEntry.User_MyLearning_Programs__r, statuses) 
               && areAllPrimaRolesInStatuses(userEntry.User_Prima_Roles__r, statuses) 
               && areAllPrimaSecurityGroupsInStatuses(userEntry.User_Prima_Security_Groups__r, statuses)
               && areAllUserTimeTrackingsInStatuses(userEntry.User_Time_Trackings__r, statuses)){
                   return false;
               }
        return true;
    }
    
    public static Boolean areAllMyLearningProgramsInStatuses(List<User_MyLearning_Program__c> userMyLearningPrograms, Set<String> statuses){
        for(User_MyLearning_Program__c userMyLearningProgram : userMyLearningPrograms){
            if(!statuses.contains(userMyLearningProgram.Status__c)){
                return false;
            }
        }
        return true;
    }
    
    public static Boolean areAllPrimaRolesInStatuses(List<User_Prima_Role__c> userPrimaRoles, Set<String> statuses){
        for(User_Prima_Role__c userPrimaRole : userPrimaRoles){
            if(!statuses.contains(userPrimaRole.Status__c)){
                return false;
            }
        }
        return true;
    }
    
    public static Boolean areAllPrimaSecurityGroupsInStatuses(List<User_Prima_Security_Group__c> userPrimaSecurityGroups, Set<String> statuses){
        for(User_Prima_Security_Group__c userPrimaSecurityGroup : userPrimaSecurityGroups){
            if(!statuses.contains(userPrimaSecurityGroup.Status__c)){
                return false;
            }
        }
        return true;
    }
    
    public static Boolean areAllUserTimeTrackingsInStatuses(List<User_Time_Tracking__c> userTimeTrackings, Set<String> statuses){
        for(User_Time_Tracking__c userTimeTracking : userTimeTrackings){
            if(!statuses.contains(userTimeTracking.Status__c)){
                return false;
            }
        }
        return true;
    }
    
    //Unshare User Entry record from previous Resource Manager on update
    private static void removeUserEntrySharingsWithResourceManager(Map<Id, User_Entry__c> newUserEntries, Map<Id, User_Entry__c> oldUserEntries){
        User_Entry__c oldUserEntry;
        Set<Id> userEntryIds = new Set<Id>();
        List<User_Entry__Share> userEntrySharingsToRemove = new List<User_Entry__Share>();
        
        for(User_Entry__c newUserEntry : newUserEntries.values()){
            oldUserEntry = oldUserEntries.get(newUserEntry.Id);
            if(newUserEntry.Resource_Manager__c != oldUserEntry.Resource_Manager__c && oldUserEntry.Resource_Manager__c != null){
                userEntryIds.add(oldUserEntry.Id);
            }
        }
        
        Map<Id, List<User_Entry__Share>> userEntrySharings = UserEntryUtils.getSharingsWithResourceManager(userEntryIds);
        for(Id userEntryId : userEntrySharings.keySet()){
            userEntrySharingsToRemove.addAll(userEntrySharings.get(userEntryId));
        }
        try{
            delete userEntrySharingsToRemove;
        }
        catch (Exception e) {
            System.debug(HandleCustomException.debugException(e));
        }
    }
    
    //Unshare User Entry record from previous Deputy Manager on update
    private static void removeUserEntrySharingsWithDeputyManager(Map<Id, User_Entry__c> newUserEntries, Map<Id, User_Entry__c> oldUserEntries){
        User_Entry__c oldUserEntry;
        Set<Id> userEntryIds = new Set<Id>();
        List<User_Entry__Share> userEntrySharingsToRemove = new List<User_Entry__Share>();
        
        for(User_Entry__c newUserEntry : newUserEntries.values()){
            oldUserEntry = oldUserEntries.get(newUserEntry.Id);
            if(newUserEntry.Deputy_Manager__c != oldUserEntry.Deputy_Manager__c && oldUserEntry.Deputy_Manager__c != null){
                userEntryIds.add(oldUserEntry.Id);
                system.debug('@@inside removeUserEntrySharingsWithDeputyManager--userEntryIds=  '+userEntryIds);
            }
        }
        
        Map<Id, List<User_Entry__Share>> userEntrySharings = UserEntryUtils.getSharingsWithDeputyManager(userEntryIds);
        for(Id userEntryId : userEntrySharings.keySet()){
            userEntrySharingsToRemove.addAll(userEntrySharings.get(userEntryId));
        }
        
        
        try{
            delete userEntrySharingsToRemove;
        }
        catch (Exception e) {
            System.debug(HandleCustomException.debugException(e));
        }
    }
    
    private static void addUserEntrySharingsWithResourceManager(Map<Id, User_Entry__c> newUserEntries, Map<Id, User_Entry__c> oldUserEntries){
        User_Entry__c oldUserEntry;
        Boolean isNew, isResourceManagerChanged;
        List<User_Entry__Share> userEntrySharingsToAdd = new List<User_Entry__Share>();
        
        for(User_Entry__c newUserEntry : newUserEntries.values()){
            oldUserEntry = oldUserEntries != null ? oldUserEntries.get(newUserEntry.Id) : null;
            isNew = oldUserEntry == null;
            isResourceManagerChanged = !isNew && newUserEntry.Resource_Manager__c != oldUserEntry.Resource_Manager__c;
            if((isNew || isResourceManagerChanged) && newUserEntry.Resource_Manager__c != null){
                User_Entry__Share newUserEntryShare = UserEntryUtils.getNewShareWithResourceManager(newUserEntry.Id, newUserEntry.Resource_Manager__c, 'Edit');
                userEntrySharingsToAdd.add(newUserEntryShare);
            }
        }
        try{
            insert userEntrySharingsToAdd;
        }
        catch (Exception e) {
            System.debug(HandleCustomException.debugException(e));
        }
    }
    
    private static void addUserEntrySharingsWithDeputyManager(Map<Id, User_Entry__c> newUserEntries, Map<Id, User_Entry__c> oldUserEntries){
        User_Entry__c oldUserEntry;
        Boolean isNew, isDeputyManagerChanged;
        List<User_Entry__Share> userEntrySharingsToAdd = new List<User_Entry__Share>();
        
        for(User_Entry__c newUserEntry : newUserEntries.values()){
            oldUserEntry = oldUserEntries != null ? oldUserEntries.get(newUserEntry.Id) : null;
            isNew = oldUserEntry == null;
            isDeputyManagerChanged = !isNew && newUserEntry.Deputy_Manager__c != oldUserEntry.Deputy_Manager__c;
            if((isNew || isDeputyManagerChanged) && newUserEntry.Deputy_Manager__c != null){
                User_Entry__Share newUserEntryShare = UserEntryUtils.getNewShareWithDeputyManager(newUserEntry.Id, newUserEntry.Deputy_Manager__c, 'Edit');
                userEntrySharingsToAdd.add(newUserEntryShare);
            }
        }
        try{
            insert userEntrySharingsToAdd;
        }
        catch (Exception e) {
            System.debug(HandleCustomException.debugException(e));
        }
    }
    
    public static void sendPrimaAndMyLearningUpdates(Map<Id, User_Entry__c> newUserEntries, Map<Id, User_Entry__c> oldUserEntries){
        Set<Id> userEntryIds = new Set<Id>();
        User_Entry__c newUserEntry;
        User_Entry__c oldUserEntry;
        for(Id userEntryId : newUserEntries.keySet()){
            newUserEntry = newUserEntries.get(userEntryId);
            oldUserEntry = oldUserEntries.get(userEntryId);
            System.debug('oldUserEntry.Is_Locked__c: ' + oldUserEntry.Is_Locked__c);
            System.debug('newUserEntry.Is_Locked__c: ' + newUserEntry.Is_Locked__c);
            if(!oldUserEntry.Is_Locked__c && newUserEntry.Is_Locked__c){
                userEntryIds.add(userEntryId);
            }
        }
        if(!userEntryIds.isEmpty()){
            Set<Id> userEntryIdsForMyLearning = UserEntryUtils.getUserEntryIdsForMyLearningUpdates(userEntryIds);
            List<User_Entry__c> userEntriesForPrima = UserEntryUtils.getUserEntriesForPrimaUpdates(userEntryIds);
            if(!userEntryIdsForMyLearning.isEmpty()){
                sendMyLearningUpdatesNotificationEmails(userEntryIdsForMyLearning);
            }
            if(!userEntriesForPrima.isEmpty()){
                System.enqueueJob(new PrimaUpdatesAsync(userEntriesForPrima));
            }
        }
    }
    
    /* This method should be removed once MyLearning integration will be implemented */
    public static void sendMyLearningUpdatesNotificationEmails(Set<Id> userEntryIds){
        Id templateId = EmailMessageService.getMyLearningUpdatesTemplateId();
        Set<Id> myLearningAdminIds = UserUtils.getMyLearningAdminIds();
        if(!myLearningAdminIds.isEmpty()){
            List<String> toAddresses = UserUtils.getUserEmailAddresses(myLearningAdminIds);
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            for(Id userEntryId : userEntryIds){
                emails.add(EmailMessageService.getSingleEmailMessageFromTemplate(templateId, userEntryId, toAddresses));
            }
            EmailMessageService.sendEmailMessages(emails);
        }
    }
    
    // Method for Hard check in User Entry
    public static void validateUserEntrieseWithRoleMatrix(List<User_Entry__c> newUserEntries) {
        for(User_Entry__c userEntry : newUserEntries){
            searchMatchingRoleMatrix(userEntry);
        }
    }
    
    //Search for matching Role Matrix record with selected Primary Job Role, MAPV Dept, MAPV Group and Company in User Entry
    //if not found, show error msg
    private static void searchMatchingRoleMatrix(User_Entry__c userEntry) {
        Set<Id> jobRoleId = new Set<Id>();
        jobRoleId.add(userEntry.Primary_Job_Role__c);
        List<Role_Matrix__c> roleMatrices = RoleMatrixUtils.getRoleMatrices(
            jobRoleId,
            userEntry.MAPV_Department__c, 
            userEntry.MAPV_Group__c, 
            userEntry.Company__c
        );
        
        if(roleMatrices.size()==0){
            userEntry.addError('Incorrect combination of entries, please contact your UMA Admins');
        }
    }
    
    
    
}