public class RoleMatrixService {

    public static RoleMatrixData getRoleMatrixData(String roleMatrixId){
        if(String.isBlank(roleMatrixId)){
            return null;
        }

        Role_Matrix__c roleMatrix = RoleMatrixUtils.getRoleMatrix(roleMatrixId);
        RoleMatrixData roleMatrixData = roleMatrix != null ? new RoleMatrixData(roleMatrix) : new RoleMatrixData();

        return roleMatrixData;
    }
    
    public static List<RoleMatrixData> getRoleMatricesData(Set<String> roleMatrixIds){
        List<RoleMatrixData> roleMatricesData = new List<RoleMatrixData>();
        if(roleMatrixIds == null){
            return roleMatricesData;
        }

        List<Role_Matrix__c> roleMatrices = RoleMatrixUtils.getRoleMatrices(roleMatrixIds);
        for(Role_Matrix__c roleMatrix : roleMatrices){
            RoleMatrixData roleMatrixData = roleMatrix != null ? new RoleMatrixData(roleMatrix) : new RoleMatrixData();
            roleMatricesData.add(roleMatrixData);
        }

        return roleMatricesData;
    }

    public static Map<Id, MyLearning_Program__c> getMyLearningProgramsMap(List<Role_Matrix__c> roleMatrices){
        Map<Id, MyLearning_Program__c> newMyLearningPrograms = new Map<Id, MyLearning_Program__c>();
        for(Role_Matrix__c roleMatrix : roleMatrices){
            for(Role_Matrix_ML__c roleMatrixMyLearningProgram : roleMatrix.Role_Matrix_MyLearning_Programs__r){
                if(!newMyLearningPrograms.containsKey(roleMatrixMyLearningProgram.MyLearning_Program__c)){
                    newMyLearningPrograms.put(
                        roleMatrixMyLearningProgram.MyLearning_Program__c, 
                        new MyLearning_Program__c(
                            Id = roleMatrixMyLearningProgram.MyLearning_Program__c,
                            Name = roleMatrixMyLearningProgram.MyLearning_Program__r.Name
                        )
                    );
                }
            }
        }
        return newMyLearningPrograms;
    }

    public static Map<Id, Prima_Role__c> getPrimaRolesMap(List<Role_Matrix__c> roleMatrices){
        Map<Id, Prima_Role__c> newPrimaRoles = new Map<Id, Prima_Role__c>();
        for(Role_Matrix__c roleMatrix : roleMatrices){
            for(Role_Matrix_Prima_Role__c roleMatrixPrimaRole : roleMatrix.Role_Matrix_Prima_Roles__r){
                if(!newPrimaRoles.containsKey(roleMatrixPrimaRole.Prima_Role__c)){
                    newPrimaRoles.put(
                        roleMatrixPrimaRole.Prima_Role__c, 
                        new Prima_Role__c(
                            Id = roleMatrixPrimaRole.Prima_Role__c,
                            Name = roleMatrixPrimaRole.Prima_Role__r.Name
                        )
                    );
                }
            }
        }
        return newPrimaRoles;
    }

    public static Map<Id, Prima_Security_Group__c> getPrimaSecurityGroupsMap(List<Role_Matrix__c> roleMatrices){
        Map<Id, Prima_Security_Group__c> newPrimaSecurityGroups = new Map<Id, Prima_Security_Group__c>();
        for(Role_Matrix__c roleMatrix : roleMatrices){
            for(Role_Matrix_Prima_SG__c roleMatrixPrimaSecurityGroup : roleMatrix.Role_Matrix_Prima_Security_Groups__r){
                if(!newPrimaSecurityGroups.containsKey(roleMatrixPrimaSecurityGroup.Prima_Security_Group__c)){
                    newPrimaSecurityGroups.put(
                        roleMatrixPrimaSecurityGroup.Prima_Security_Group__c, 
                        new Prima_Security_Group__c(
                            Id = roleMatrixPrimaSecurityGroup.Prima_Security_Group__c,
                            Name = roleMatrixPrimaSecurityGroup.Prima_Security_Group__r.Name
                        )
                    );
                }
            }
        }
        return newPrimaSecurityGroups;
    }
}