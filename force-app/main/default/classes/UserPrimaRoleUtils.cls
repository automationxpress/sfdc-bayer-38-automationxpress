public class UserPrimaRoleUtils {
    public static final String STATUS_ASSIGN = 'Assign';
    public static final String STATUS_REMOVE = 'Remove';
    public static final String STATUS_ERROR = 'Error';
    public static final Set<String> UPDATABLE_STATUSES = new Set<String>{
        STATUS_ASSIGN,
        STATUS_REMOVE,
        STATUS_ERROR
    };
    
    public static void validateUserPrimaRolesOnDelete(Map<Id, User_Prima_Role__c> oldUserPrimaRoles) {
        Boolean hasDeleteAllPrimaItems = FeatureManagement.checkPermission('DeleteAllPrimaItems');
        Boolean isUpdatable;
        for(User_Prima_Role__c userPrimaRole : oldUserPrimaRoles.values()){
            isUpdatable = UPDATABLE_STATUSES.contains(userPrimaRole.Status__c);
            if(!hasDeleteAllPrimaItems && !isUpdatable){
                userPrimaRole.addError(Label.UserPrimaRoleCannotBeDeleted);
            }
        }
    }
}