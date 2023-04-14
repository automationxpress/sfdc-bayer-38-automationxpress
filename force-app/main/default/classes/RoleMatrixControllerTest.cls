/*
* Description: Test class for RoleMatrixController class.
*/
@isTest
private class RoleMatrixControllerTest {
    @TestSetup
    private static void createTestData() {
        Job_Role__c jobRole1 = TestDataService.getDefaultJobRole();
        insert jobRole1;
        
        Job_Role__c jobRole2 = TestDataService.getDefaultJobRole();
        jobRole2.Name='Test Job Role1';
        insert jobRole2;
        
        Job_Role__c jobRole3 = TestDataService.getDefaultJobRole();
        jobRole3.Name='Test Global Job Role';
        jobRole3.Main_Role_Add_on__c='Add-on';
        insert jobRole3;
        
        
        MAPV_Department__c department1 = TestDataService.getDefaultMapvDepartment();
        insert department1;
        
        MAPV_Group__c group1 = TestDataService.getDefaultMapvGroup();
        insert group1;
        
        Account acc1= TestDataService.getDefaultAccount();
        insert acc1;
        
        MyLearning_Program__c myLearnings = TestDataService.getDefaultMyLearningProgram();
        insert myLearnings;
        
        Role_Matrix__c roleMatrix1= TestDataService.getDefaultRoleMatrix();
        roleMatrix1.Job_Role__c = [Select Id from Job_Role__c][0].Id;
        roleMatrix1.Role_Matrix_Type__c='4-Criteria Role Matrix';
        roleMatrix1.MAPV_Department__c = [Select Id from MAPV_Department__c][0].Id;
        roleMatrix1.MAPV_Group__c = [Select Id from MAPV_Group__c][0].Id;
        roleMatrix1.Company__c = [Select Id from Account][0].Id;
        insert roleMatrix1;
        
        Role_Matrix_ML__c roleMatrix_MyLearning = new Role_Matrix_ML__c();
        roleMatrix_MyLearning.Role_Matrix__c = roleMatrix1.Id;
        roleMatrix_MyLearning.MyLearning_Program__c = myLearnings.Id;
        insert roleMatrix_MyLearning;
        
        Role_Matrix__c roleMatrix_3_criteria= TestDataService.getDefaultRoleMatrix();
        roleMatrix_3_criteria.Job_Role__c = [Select Id from Job_Role__c where Name=:'Test Job Role1'].Id;
        roleMatrix_3_criteria.Role_Matrix_Type__c='3-Criteria Role Matrix';
        roleMatrix_3_criteria.MAPV_Department__c = [Select Id from MAPV_Department__c][0].Id;
        roleMatrix_3_criteria.Company__c = [Select Id from Account][0].Id;
        insert roleMatrix_3_criteria;
        Role_Matrix_ML__c roleMatrix_MyLearning_3_criteria = new Role_Matrix_ML__c();
        roleMatrix_MyLearning_3_criteria.Role_Matrix__c = roleMatrix_3_criteria.Id;
        roleMatrix_MyLearning_3_criteria.MyLearning_Program__c = myLearnings.Id;
        insert roleMatrix_MyLearning_3_criteria;
        
        Role_Matrix__c roleMatrixGlobalJob= TestDataService.getDefaultRoleMatrix();
        roleMatrixGlobalJob.Job_Role__c = [Select Id from Job_Role__c where Main_Role_Add_on__c='Add-on'][0].Id;
        roleMatrixGlobalJob.Role_Matrix_Type__c='Global Job role/ Add-On role';
        insert roleMatrixGlobalJob;
        Role_Matrix_ML__c roleMatrix_MyLearningGlobalJob = new Role_Matrix_ML__c();
        roleMatrix_MyLearningGlobalJob.Role_Matrix__c = roleMatrixGlobalJob.Id;
        roleMatrix_MyLearningGlobalJob.MyLearning_Program__c = myLearnings.Id;
        insert roleMatrix_MyLearningGlobalJob;
    }
    
    //Test the functionality to display all the Role Matrices Records / filtered records based on search text in Role Matrix Overview tab
    @IsTest
    private static void testName() {
        Test.startTest();
        RoleMatrixListWrapper wrapperList = new RoleMatrixListWrapper();
        wrapperList.roleMatrixRecord = RoleMatrixController.getFilteredRoleMatrixDetails('')[0].roleMatrixRecord;
        wrapperList.myLearningString = RoleMatrixController.getFilteredRoleMatrixDetails('')[0].myLearningString;
        system.assertEquals(wrapperList.roleMatrixRecord.Main_Role_Add_on_Formula__c, JobRoleUtils.ROLE_MAIN);
        system.assertEquals(wrapperList.myLearningString, 'Test ML Program');
        RoleMatrixListWrapper wrapperList1 = new RoleMatrixListWrapper();
        wrapperList1.roleMatrixRecord = RoleMatrixController.getFilteredRoleMatrixDetails('Group')[0].roleMatrixRecord;
        system.assertEquals(wrapperList1.roleMatrixRecord.MAPV_Group__r.Name, 'Test Group');
        Test.stopTest();
        
    }
    
    public class RoleMatrixListWrapper{
        @AuraEnabled
        public Role_Matrix__c roleMatrixRecord{get;set;}
        @AuraEnabled
        public String myLearningString{get;set;}
        @AuraEnabled
        public String primaRoleString{get;set;}
        @AuraEnabled
        public String primaSecurityGroupString{get;set;}
        
    }
    
}