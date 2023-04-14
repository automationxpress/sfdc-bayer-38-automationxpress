public class UserPrimaSecurityGroupUtils {
    public static final String STATUS_ASSIGN = 'Assign';
    public static final String STATUS_REMOVE = 'Remove';
    public static final String STATUS_ERROR = 'Error';
    public static final Set<String> UPDATABLE_STATUSES = new Set<String>{
        STATUS_ASSIGN,
        STATUS_REMOVE,
        STATUS_ERROR
    };
    
    public static void validateUserPrimaSecurityGroupsOnDelete(Map<Id, User_Prima_Security_Group__c> oldUserPrimaSecurityGroups) {
        Boolean hasDeleteAllPrimaItems = FeatureManagement.checkPermission('DeleteAllPrimaItems');
        Boolean isUpdatable;
        for(User_Prima_Security_Group__c userPrimaSecurityGroup : oldUserPrimaSecurityGroups.values()){
            isUpdatable = UPDATABLE_STATUSES.contains(userPrimaSecurityGroup.Status__c);
            if(!hasDeleteAllPrimaItems && !isUpdatable){
                userPrimaSecurityGroup.addError(Label.UserPrimaSecurityGroupCannotBeDeleted);
            }
        }
    }
}