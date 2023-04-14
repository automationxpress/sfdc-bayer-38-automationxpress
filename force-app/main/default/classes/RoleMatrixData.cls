//class to create a data structure used in other classes and lwc component
public class RoleMatrixData {
    
    @AuraEnabled public Id roleMatrixId { get; set; }
    @AuraEnabled public Id jobRoleId { get; set; }
    @AuraEnabled public String roleMatrixType { get; set; }
    @AuraEnabled public List<MyLearning_Program__c> myLearningPrograms { get; set; }
    @AuraEnabled public List<Prima_Role__c> primaRoles { get; set; }
    @AuraEnabled public List<Prima_Security_Group__c> primaSecurityGroups { get; set; }

    public RoleMatrixData() {
        myLearningPrograms = new List<MyLearning_Program__c>();
        primaRoles = new List<Prima_Role__c>();
        primaSecurityGroups = new List<Prima_Security_Group__c>();
    }

    public RoleMatrixData(Role_Matrix__c roleMatrix){
        roleMatrixId = roleMatrix.Id;
        roleMatrixType=roleMatrix.Role_Matrix_Type__c;
        jobRoleId = roleMatrix.Job_Role__c;
        setMyLearningPrograms(roleMatrix.Role_Matrix_MyLearning_Programs__r);
        setPrimaRoles(roleMatrix.Role_Matrix_Prima_Roles__r);
        setPrimaSecurityGroups(roleMatrix.Role_Matrix_Prima_Security_Groups__r);
    }
    
    //Set MyLearning details in Role_Matrix_ML junction object
    private void setMyLearningPrograms(List<Role_Matrix_ML__c> roleMatrixMyLearningPrograms){
        myLearningPrograms = new List<MyLearning_Program__c>();
        for(Role_Matrix_ML__c roleMatrixMyLearningProgram : roleMatrixMyLearningPrograms){
            myLearningPrograms.add(
                new MyLearning_Program__c(
                    Id = roleMatrixMyLearningProgram.MyLearning_Program__c,
                    Name = roleMatrixMyLearningProgram.MyLearning_Program__r.Name
                )
            );
        }
    }
    
    //Set Prima Role details in Role_Matrix_Prima_Role junction object
    private void setPrimaRoles(List<Role_Matrix_Prima_Role__c> roleMatrixPrimaRoles){
        primaRoles = new List<Prima_Role__c>();
        for(Role_Matrix_Prima_Role__c roleMatrixPrimaRole : roleMatrixPrimaRoles){
            primaRoles.add(
                new Prima_Role__c(
                    Id = roleMatrixPrimaRole.Prima_Role__c,
                    Name = roleMatrixPrimaRole.Prima_Role__r.Name
                )
            );
        }
    }
    
    //Set PrimaSecurityGroup details in Role_Matrix_Prima_SG junction object
    private void setPrimaSecurityGroups(List<Role_Matrix_Prima_SG__c> roleMatrixPrimaSecurityGroups){
        primaSecurityGroups = new List<Prima_Security_Group__c>();
        for(Role_Matrix_Prima_SG__c roleMatrixPrimaSecurityGroup : roleMatrixPrimaSecurityGroups){
            primaSecurityGroups.add(
                new Prima_Security_Group__c(
                    Id = roleMatrixPrimaSecurityGroup.Prima_Security_Group__c,
                    Name = roleMatrixPrimaSecurityGroup.Prima_Security_Group__r.Name
                )
            );
        }
    }
}