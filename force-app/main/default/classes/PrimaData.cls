global class PrimaData {
     //Prima data class
     //comments added to test githuh-enhancement-destructive-v2
     //comments added to new branch
    public static final Set<String> NEW_STATUSES = new Set<String>{
        UserEntryData.STATUS_ASSIGN, 
        UserEntryData.STATUS_REMOVE
    };
    public static final Set<String> IN_PROGRESS_STATUSES = new Set<String>{
        UserEntryData.STATUS_ASSIGN_REQUESTED, 
        UserEntryData.STATUS_REMOVE_REQUESTED
    };

    public static Set<String> getUserCwids(List<UserResponse> users){
        Set<String> cwids = new Set<String>();
        for(UserResponse user : users){
            if(String.isNotBlank(user.cwid)){
                cwids.add(user.cwid);
            }
        }

        return cwids;
    }

    public static User_Prima_Role__c getUserPrimaRoleToUpdate(Id userPrimaRoleId, PrimaRoleResponse primaRole){
        User_Prima_Role__c userPrimaRole = new User_Prima_Role__c(
            Id = userPrimaRoleId, 
            Status__c = primaRole.status
        );
        userPrimaRole.Error_Message__c = primaRole.status == UserEntryData.STATUS_ERROR ? primaRole.error : null;
        userPrimaRole.Initial_Sending_Failed__c = false;
        return userPrimaRole;
    }

    public static User_Prima_Security_Group__c getUserPrimaSecurityGroupToUpdate(Id userPrimaSecurityGroupId, PrimaSecurityGroupResponse primaSecurityGroup){
        User_Prima_Security_Group__c userPrimaSecurityGroup = new User_Prima_Security_Group__c(
            Id = userPrimaSecurityGroupId, 
            Status__c = primaSecurityGroup.status
        );
        userPrimaSecurityGroup.Error_Message__c = primaSecurityGroup.status == UserEntryData.STATUS_ERROR ? primaSecurityGroup.error : null;
        userPrimaSecurityGroup.Initial_Sending_Failed__c = false;
        return userPrimaSecurityGroup;
    }

    global class UserRequest {
        public String cwid;
        public List<PrimaRoleRequest> primaRoles;
        public List<PrimaSecurityGroupRequest> primaSecurityGroups;

        public UserRequest(User_Entry__c userEntry){
            cwid = userEntry.CWID__c;
            primaRoles = new List<PrimaRoleRequest>();
            for(User_Prima_Role__c userRole : userEntry.User_Prima_Roles__r){
                primaRoles.add(new PrimaRoleRequest(userRole.Prima_Role__r.Name, userRole.Status__c));
            }
            primaSecurityGroups = new List<PrimaSecurityGroupRequest>();
            for(User_Prima_Security_Group__c userSecurityGroup : userEntry.User_Prima_Security_Groups__r){
                primaSecurityGroups.add(new PrimaSecurityGroupRequest(userSecurityGroup.Prima_Security_Group__r.Name, userSecurityGroup.Status__c));
            }
        }
    }

    global class UserResponse {
        public String cwid;
        public List<PrimaRoleResponse> primaRoles;
        public List<PrimaSecurityGroupResponse> primaSecurityGroups;
    }

    public class PrimaRoleRequest {
        public String name;
        public String status;

        public PrimaRoleRequest(String name, String status){
            this.name = name;
            this.status = status;
        }
    }

    public class PrimaRoleResponse {
        public String name;
        public String status;
        public String error;
    }

    public class PrimaSecurityGroupRequest {
        public String name;
        public String status;

        public PrimaSecurityGroupRequest(String name, String status){
            this.name = name;
            this.status = status;
        }
    }

    public class PrimaSecurityGroupResponse {
        public String name;
        public String status;
        public String error;
    }
}