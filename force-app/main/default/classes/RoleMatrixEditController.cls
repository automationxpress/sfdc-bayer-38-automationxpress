//Controller class of LWC-RoleMatrixEdit
public with sharing class RoleMatrixEditController {
    
    //returns the Role Matrix data of corresponding Role Matrix Id
    @AuraEnabled
    public static RoleMatrixData getRoleMatrixData(String roleMatrixId){
        RoleMatrixData roleMatrixData = new RoleMatrixData();
        if(String.isBlank(roleMatrixId)){
            return roleMatrixData;
        }

        try {
            roleMatrixData = RoleMatrixService.getRoleMatrixData(roleMatrixId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
        return roleMatrixData;
    }
    
    // DML operation of Role_Matrix_ML__c, Role_Matrix_Prima_Role__c, Role_Matrix_Prima_SG__c
    @AuraEnabled
    public static void saveRoleMatrixData(RoleMatrixData roleMatrixData){
        Role_Matrix__c roleMatrix = RoleMatrixUtils.getRoleMatrix(roleMatrixData.roleMatrixId);
        List<Role_Matrix_ML__c> myLearningProgramsToAdd = getMyLearningProgramsToAdd(roleMatrixData, roleMatrix);
        List<Role_Matrix_Prima_Role__c> primaRolesToAdd = getPrimaRolesToAdd(roleMatrixData, roleMatrix);
        List<Role_Matrix_Prima_SG__c> primaSecurityGroupsToAdd = getPrimaSecurityGroupsToAdd(roleMatrixData, roleMatrix);
        List<Role_Matrix_ML__c> myLearningProgramsToRemove = getMyLearningProgramsToRemove(roleMatrixData, roleMatrix);
        List<Role_Matrix_Prima_Role__c> primaRolesToRemove = getPrimaRolesToRemove(roleMatrixData, roleMatrix);
        List<Role_Matrix_Prima_SG__c> primaSecurityGroupsToRemove = getPrimaSecurityGroupsToRemove(roleMatrixData, roleMatrix);
        
        try{
            insert myLearningProgramsToAdd;
        	insert primaRolesToAdd;
        	insert primaSecurityGroupsToAdd;
        	delete myLearningProgramsToRemove;
        	delete primaRolesToRemove;
        	delete primaSecurityGroupsToRemove;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    //Returns the list of Role_Matrix_ML__c by adding corresponding MyLearnings 
    private static List<Role_Matrix_ML__c> getMyLearningProgramsToAdd(RoleMatrixData roleMatrixData, Role_Matrix__c roleMatrix){
        Set<Id> myLearningProgramIds = new Set<Id>();
        for(Role_Matrix_ML__c roleMatrixML : roleMatrix.Role_Matrix_MyLearning_Programs__r){
            myLearningProgramIds.add(roleMatrixML.MyLearning_Program__c);
        }

        List<Role_Matrix_ML__c> myLearningProgramsToAdd = new List<Role_Matrix_ML__c>();
        for(MyLearning_Program__c myLearningProgram : roleMatrixData.myLearningPrograms){
            if(!myLearningProgramIds.contains(myLearningProgram.Id)){
                myLearningProgramsToAdd.add(new Role_Matrix_ML__c(
                    Role_Matrix__c = roleMatrixData.roleMatrixId,
                    MyLearning_Program__c = myLearningProgram.Id
                ));
            }
        }

        return myLearningProgramsToAdd;
    }
    
    //Returns the list of Role_Matrix_Prima_Role__c by adding corresponding Prima Roles
    private static List<Role_Matrix_Prima_Role__c> getPrimaRolesToAdd(RoleMatrixData roleMatrixData, Role_Matrix__c roleMatrix){
        Set<Id> primaRoleIds = new Set<Id>();
        for(Role_Matrix_Prima_Role__c roleMatrixPrimaRole : roleMatrix.Role_Matrix_Prima_Roles__r){
            primaRoleIds.add(roleMatrixPrimaRole.Prima_Role__c);
        }

        List<Role_Matrix_Prima_Role__c> primaRolesToAdd = new List<Role_Matrix_Prima_Role__c>();
        for(Prima_Role__c primaRole : roleMatrixData.primaRoles){
            if(!primaRoleIds.contains(primaRole.Id)){
                primaRolesToAdd.add(new Role_Matrix_Prima_Role__c(
                    Role_Matrix__c = roleMatrixData.roleMatrixId,
                    Prima_Role__c = primaRole.Id
                ));
            }
        }

        return primaRolesToAdd;
    }
    
    //Returns the list of Role_Matrix_Prima_SG__c by adding corresponding Prima Security Groups
    private static List<Role_Matrix_Prima_SG__c> getPrimaSecurityGroupsToAdd(RoleMatrixData roleMatrixData, Role_Matrix__c roleMatrix){
        Set<Id> primaSecurityGroupIds = new Set<Id>();
        for(Role_Matrix_Prima_SG__c roleMatrixPrimaSG : roleMatrix.Role_Matrix_Prima_Security_Groups__r){
            primaSecurityGroupIds.add(roleMatrixPrimaSG.Prima_Security_Group__c);
        }

        List<Role_Matrix_Prima_SG__c> primaSecurityGroupsToAdd = new List<Role_Matrix_Prima_SG__c>();
        for(Prima_Security_Group__c primaSecurityGroup : roleMatrixData.primaSecurityGroups){
            if(!primaSecurityGroupIds.contains(primaSecurityGroup.Id)){
                primaSecurityGroupsToAdd.add(new Role_Matrix_Prima_SG__c(
                    Role_Matrix__c = roleMatrixData.roleMatrixId,
                    Prima_Security_Group__c = primaSecurityGroup.Id
                ));
            }
        }

        return primaSecurityGroupsToAdd;
    }
    
    //Returns the list of Role_Matrix_ML__c to be removed from parent Role Matrix record
    private static List<Role_Matrix_ML__c> getMyLearningProgramsToRemove(RoleMatrixData roleMatrixData, Role_Matrix__c roleMatrix){
        Set<Id> myLearningProgramIds = SObjectUtils.getRecordIds(roleMatrixData.myLearningPrograms);

        List<Role_Matrix_ML__c> myLearningProgramsToRemove = new List<Role_Matrix_ML__c>();
        for(Role_Matrix_ML__c roleMatrixML : roleMatrix.Role_Matrix_MyLearning_Programs__r){
            if(!myLearningProgramIds.contains(roleMatrixML.MyLearning_Program__c)){
                myLearningProgramsToRemove.add(roleMatrixML);
            }
        }

        return myLearningProgramsToRemove;
    }
    
    //Returns the list of Role_Matrix_Prima_Role__c to be removed from parent Role Matrix record
    private static List<Role_Matrix_Prima_Role__c> getPrimaRolesToRemove(RoleMatrixData roleMatrixData, Role_Matrix__c roleMatrix){
        Set<Id> primaRoleIds = SObjectUtils.getRecordIds(roleMatrixData.primaRoles);

        List<Role_Matrix_Prima_Role__c> primaRolesToRemove = new List<Role_Matrix_Prima_Role__c>();
        for(Role_Matrix_Prima_Role__c roleMatrixPrimaRole : roleMatrix.Role_Matrix_Prima_Roles__r){
            if(!primaRoleIds.contains(roleMatrixPrimaRole.Prima_Role__c)){
                primaRolesToRemove.add(roleMatrixPrimaRole);
            }
        }

        return primaRolesToRemove;
    }
    
    //Returns the list of Role_Matrix_Prima_SG__c to be removed from parent Role Matrix record
    private static List<Role_Matrix_Prima_SG__c> getPrimaSecurityGroupsToRemove(RoleMatrixData roleMatrixData, Role_Matrix__c roleMatrix){
        Set<Id> primaSecurityGroupIds = SObjectUtils.getRecordIds(roleMatrixData.primaSecurityGroups);

        List<Role_Matrix_Prima_SG__c> primaSecurityGroupsToRemove = new List<Role_Matrix_Prima_SG__c>();
        for(Role_Matrix_Prima_SG__c roleMatrixPrimaSG : roleMatrix.Role_Matrix_Prima_Security_Groups__r){
            if(!primaSecurityGroupIds.contains(roleMatrixPrimaSG.Prima_Security_Group__c)){
                primaSecurityGroupsToRemove.add(roleMatrixPrimaSG);
            }
        }

        return primaSecurityGroupsToRemove;
    }

        
}