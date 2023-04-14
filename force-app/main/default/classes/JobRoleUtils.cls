public class JobRoleUtils {
    public static final String ROLE_MAIN = 'Main';
    public static final String ROLE_ADD_ON = 'Add-on';

    public static Job_Role__c getJobRole(String jobRoleId){
        Set<Id> jobRoleIds = new Set<Id>{jobRoleId};
        List<Job_Role__c> jobRoles = getJobRoles(jobRoleIds);

        if(!jobRoles.isEmpty()){
            return jobRoles[0];
        }
        return null;
    }

    public static List<Job_Role__c> getJobRoles(Set<Id> jobRoleIds){
        return [SELECT Id, Main_Role_Add_on__c 
                FROM Job_Role__c WHERE Id IN :jobRoleIds];
    }
}