public class UserEntryData {
    public static final String STATUS_ASSIGN = 'Assign';
    public static final String STATUS_REMOVE = 'Remove';
    public static final String STATUS_ASSIGN_REQUESTED = 'Assign Requested';
    public static final String STATUS_REMOVE_REQUESTED = 'Remove Requested';
    public static final String STATUS_ASSIGNED = 'Assigned';
    public static final String STATUS_REMOVED = 'Removed';
    public static final String STATUS_ERROR = 'Error';

    @AuraEnabled public Id userEntryId { get; set; }
    @AuraEnabled public Boolean isLocked { get; set; }
    @AuraEnabled public Boolean isStaffStatusCurrent { get; set; }
    @AuraEnabled public Boolean isStaffStatusLeft { get; set; }
    @AuraEnabled public Boolean isStaffStatusLongTermLeave { get; set; }
    @AuraEnabled public String primaryJobRole { get; set; }
    @AuraEnabled public String primaryJobRoleId { get; set; }
    @AuraEnabled public String MAPVDepartment { get; set; }
    @AuraEnabled public String MAPVDepartmentName { get; set; }
    @AuraEnabled public String MAPVGroup { get; set; }
    @AuraEnabled public String MAPVGroupName { get; set; }
    @AuraEnabled public String company { get; set; }
    @AuraEnabled public String companyName { get; set; }
    @AuraEnabled public String approvalStatus { get; set; }
    @AuraEnabled public String locations { get; set; }
    @AuraEnabled public String timeTrackingRequired { get; set; }
    
    @AuraEnabled public List<Job_Role__c> jobRoles { get; set; }
    @AuraEnabled public List<UserEntryItem> myLearningPrograms { get; set; }
    @AuraEnabled public List<UserEntryItem> primaRoles { get; set; }
    @AuraEnabled public List<UserEntryItem> primaSecurityGroups { get; set; }
    
    public UserEntryData() {
        jobRoles = new List<Job_Role__c>();
        myLearningPrograms = new List<UserEntryItem>();
        primaRoles = new List<UserEntryItem>();
        primaSecurityGroups = new List<UserEntryItem>();
    }

    public Map<Id, UserEntryItem> getMyLearningProgramsMap(){
        return getUserEntryItemsMap(myLearningPrograms);
    }

    public Map<Id, UserEntryItem> getPrimaRolesMap(){
        return getUserEntryItemsMap(primaRoles);
    }

    public Map<Id, UserEntryItem> getPrimaSecurityGroupsMap(){
        return getUserEntryItemsMap(primaSecurityGroups);
    }

    public void setJobRoles(List<User_Additional_Role__c> userAdditionalRoles){
        for(User_Additional_Role__c userAdditionalRole : userAdditionalRoles){
            jobRoles.add(
                new Job_Role__c(
                    Id = userAdditionalRole.Job_Role__c,
                    Name = userAdditionalRole.Job_Role__r.Name
                )
            );
        }
    }

    public void setMyLearningPrograms(List<User_MyLearning_Program__c> userMyLearningPrograms){
        String status;
        for(User_MyLearning_Program__c userMyLearningProgram : userMyLearningPrograms){
            status = isStaffStatusLeft && userMyLearningProgram.Status__c == STATUS_ASSIGNED ? STATUS_REMOVE : userMyLearningProgram.Status__c;
            if(!isStaffStatusLeft || (isStaffStatusLeft && status == STATUS_REMOVE)){
                myLearningPrograms.add(
                    new UserEntryItem(
                        userMyLearningProgram.MyLearning_Program__c,
                        userMyLearningProgram.MyLearning_Program__r.Name,
                        status
                    )
                );
            }
        }
    }

    public void setPrimaRoles(List<User_Prima_Role__c> userPrimaRoles){
        String status;
        for(User_Prima_Role__c userPrimaRole : userPrimaRoles){
            status = isStaffStatusLeft && userPrimaRole.Status__c == STATUS_ASSIGNED ? STATUS_REMOVE : userPrimaRole.Status__c;
            if(!isStaffStatusLeft || (isStaffStatusLeft && status == STATUS_REMOVE)){
                primaRoles.add(
                    new UserEntryItem(
                        userPrimaRole.Prima_Role__c,
                        userPrimaRole.Prima_Role__r.Name,
                        status
                    )
                );
            }
        }
    }

    public void setPrimaSecurityGroups(List<User_Prima_Security_Group__c> userPrimaSecurityGroups){
        String status;
        for(User_Prima_Security_Group__c userPrimaSecurityGroup : userPrimaSecurityGroups){
            status = (isStaffStatusLeft || isStaffStatusLongTermLeave) && userPrimaSecurityGroup.Status__c == STATUS_ASSIGNED ? STATUS_REMOVE : userPrimaSecurityGroup.Status__c;
            status = isStaffStatusLeft && userPrimaSecurityGroup.Status__c == STATUS_ASSIGNED ? STATUS_REMOVE : userPrimaSecurityGroup.Status__c;
            if(!isStaffStatusLeft || (isStaffStatusLeft && status == STATUS_REMOVE)){
                primaSecurityGroups.add(
                    new UserEntryItem(
                        userPrimaSecurityGroup.Prima_Security_Group__c,
                        userPrimaSecurityGroup.Prima_Security_Group__r.Name,
                        status
                    )
                );
            }
        }
    }

    public void addNewMyLearningProgram(Id myLearningProgramId, String myLearningProgramName){
        myLearningPrograms.add(
            new UserEntryItem(myLearningProgramId, myLearningProgramName, STATUS_ASSIGN)
        );
    }

    public void addNewPrimaRole(Id primaRoleId, String primaRoleName){
        primaRoles.add(
            new UserEntryItem(primaRoleId, primaRoleName, STATUS_ASSIGN)
        );
    }

    public void addNewPrimaSecurityGroup(Id primaSecurityGroupId, String primaSecurityGroupName){
        primaSecurityGroups.add(
            new UserEntryItem(primaSecurityGroupId, primaSecurityGroupName, STATUS_ASSIGN)
        );
    }

    public void removeMyLearningPrograms(Set<Id> myLearningProgramIdsToRemove){
        myLearningPrograms = removeUserEntryItems(myLearningPrograms, myLearningProgramIdsToRemove);
    }

    public void removePrimaRoles(Set<Id> primaRoleIdsToRemove){
        primaRoles = removeUserEntryItems(primaRoles, primaRoleIdsToRemove);
    }

    public void removePrimaSecurityGroups(Set<Id> primaSecurityGroupIdsToRemove){
        primaSecurityGroups = removeUserEntryItems(primaSecurityGroups, primaSecurityGroupIdsToRemove);
    }

    private Map<Id, UserEntryItem> getUserEntryItemsMap(List<UserEntryItem> userEntryItems){
        Map<Id, UserEntryItem> userEntryItemsMap = new Map<Id, UserEntryItem>();
        for(UserEntryItem userEntryItem : userEntryItems){
            userEntryItemsMap.put(userEntryItem.id, userEntryItem);
        }
        return userEntryItemsMap;
    }

    private List<UserEntryItem> removeUserEntryItems(List<UserEntryItem> userEntryItems, Set<Id> userEntryItemIdsToRemove){
        List<UserEntryItem> newUserEntryItems = new List<UserEntryItem>();
        for(UserEntryItem userEntryItem : userEntryItems){
            if(!userEntryItemIdsToRemove.contains(userEntryItem.id)){
                newUserEntryItems.add(userEntryItem);
            }
        }
        return newUserEntryItems;
    }

    public class UserEntryItem {
        @AuraEnabled public Id id { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String status { get; set; }
        @AuraEnabled public String iconName { get; set; }
        @AuraEnabled public String iconTitle { get; set; }
        @AuraEnabled public String iconVariant { get; set; }

        public UserEntryItem(){}

        public UserEntryItem(Id id, String name, String status){
            this.id = id;
            this.name = name;
            this.status = status;
            setStatus(status);
        }

        public void setStatus(String status){
            this.status = status;
            if(status == STATUS_ASSIGN){
                this.iconName = 'utility:reassign';
                this.iconTitle = Label.ToBeAssigned;
            } else if(status == STATUS_ASSIGNED){
                this.iconName = 'utility:success';
                this.iconTitle = status;
                this.iconVariant = 'success';
            } else if(status == STATUS_REMOVE){
                this.iconName = 'utility:ban';
                this.iconTitle = Label.ToBeRemoved;
                this.iconVariant = 'error';
            }
        }
    }

}