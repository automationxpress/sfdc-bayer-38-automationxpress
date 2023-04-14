public class UserUtils {
    /* Profiles */
    public static final String SYSTEM_ADMINISTRATOR = 'System Administrator';
    public static final String PLATFORM_END_USER = 'Platform End User';
    public static final String CONSENT_FORM_PROFILE = 'Consent Form Profile';
    /* Permission Sets */
    public static final String UMA_END_USER = 'UMA_End_User';
    public static final String UMA_MANAGER_USER = 'UMA_Manager_User';
    public static final String UMA_APPLICATION_ADMIN = 'UMA_Application_Admin';
    public static final String UMA_MYLEARNING_ADMIN = 'UMA_MyLearning_Admin';

    public static Profile getSystemAdministratorProfile(){
        return getProfile(SYSTEM_ADMINISTRATOR);
    }

    public static Profile getPlatformEndUserProfile(){
        return getProfile(PLATFORM_END_USER);
    }

    public static Profile getConsentFormProfile(){
        return getProfile(CONSENT_FORM_PROFILE);
    }

    public static Profile getProfile(String profileName){
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = :profileName];
        if(!profiles.isEmpty()){
            return profiles[0];
        }
        return null;
    }

    public static PermissionSet getUmaEndUserPermissionSet(){
        return getPermissionSet(UMA_END_USER);
    }

    public static PermissionSet getUmaManagerUserPermissionSet(){
        return getPermissionSet(UMA_MANAGER_USER);
    }

    public static PermissionSet getUmaApplicationAdminPermissionSet(){
        return getPermissionSet(UMA_APPLICATION_ADMIN);
    }

    public static PermissionSet getPermissionSet(String permissionSetName){
        List<PermissionSet> permissionSets = [SELECT Id FROM PermissionSet WHERE Name = :permissionSetName];
        if(!permissionSets.isEmpty()){
            return permissionSets[0];
        }
        return null;
    }

    public static User getUserByCwid(String cwid){
        Set<String> cwids = new Set<String>{cwid};
        List<User> users = getUsersByCwid(cwids);

        if(!users.isEmpty()){
            return users[0];
        }
        return null;
    }

    public static List<User> getUsersByCwid(Set<String> cwids){
        return [SELECT Id, Username, FederationIdentifier 
                FROM User 
                WHERE FederationIdentifier IN :cwids];
    }

    public static List<String> getUserEmailAddresses(Set<Id> userIds){
        List<String> userEmailAddresses = new List<String>();
        for(User u : [SELECT Email FROM User WHERE Id IN :userIds]){
            userEmailAddresses.add(u.Email);
        }
        return userEmailAddresses;
    }

    public static Set<Id> getMyLearningAdminIds(){
        return getPermissionSetAssigneeIds(UMA_MYLEARNING_ADMIN);
    }

    public static Set<Id> getPermissionSetAssigneeIds(String permissionSetName){
        Set<Id> assigneeIds = new Set<Id>();
        for(PermissionSetAssignment psa : [SELECT AssigneeId FROM PermissionSetAssignment 
                                           WHERE PermissionSet.Name = :permissionSetName AND Assignee.IsActive = true]){
            assigneeIds.add(psa.AssigneeId);
        }
        return assigneeIds;
    }

}