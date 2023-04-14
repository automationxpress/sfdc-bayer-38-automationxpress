//Test the functionality of RoleMatrixService class
@isTest
private class RoleMatrixServiceTest {
	@TestSetup
    private static void setupTestData(){
        Profile platformEndUserProfile = UserUtils.getPlatformEndUserProfile();
        PermissionSet umaApplicationAdminPermissionSet = UserUtils.getUmaApplicationAdminPermissionSet();

        User applicationAdmin = TestDataService.createUser(new User(
            Username = 'test.application.admin.ext@bayer.com',
            ProfileId = platformEndUserProfile.Id,
            FederationIdentifier = 'ZZBBB'
        ));
        insert applicationAdmin;

        PermissionSetAssignment permissionSetAssignment = new PermissionSetAssignment(
            PermissionSetId = umaApplicationAdminPermissionSet.Id,
            AssigneeId = applicationAdmin.Id
        );
        insert permissionSetAssignment;

        System.runAs(applicationAdmin){
            Account company = TestDataService.getDefaultAccount();
            insert company;

            Job_Role__c jobRole = TestDataService.getDefaultJobRole();
            insert jobRole;

            MAPV_Department__c mapvDepartment = TestDataService.getDefaultMapvDepartment();
            insert mapvDepartment;

            MAPV_Group__c mapvGroup = TestDataService.getDefaultMapvGroup();
            insert mapvGroup;

            Role_Matrix__c roleMatrix = TestDataService.createRoleMatrix(new Role_Matrix__c(
                Job_Role__c = jobRole.Id,
                MAPV_Department__c = mapvDepartment.Id,
                MAPV_Group__c = mapvGroup.Id,
                Company__c = company.Id
            ));
            insert roleMatrix;
        
            MyLearning_Program__c myLearningProgram = TestDataService.getDefaultMyLearningProgram();
            insert myLearningProgram;
            insert new Role_Matrix_ML__c(
                Role_Matrix__c = roleMatrix.Id,
                MyLearning_Program__c = myLearningProgram.Id
            );

            Prima_Role__c primaRole = TestDataService.getDefaultPrimaRole();
            insert primaRole;
            insert new Role_Matrix_Prima_Role__c(
                Role_Matrix__c = roleMatrix.Id,
                Prima_Role__c = primaRole.Id
            );

            Prima_Security_Group__c primaSecurityGroup = TestDataService.getDefaultPrimaSecurityGroup();
            insert primaSecurityGroup;
            insert new Role_Matrix_Prima_SG__c(
                Role_Matrix__c = roleMatrix.Id,
                Prima_Security_Group__c = primaSecurityGroup.Id
            );
        
            Job_Role__c jobRole1 = new Job_Role__c(
                Name = 'Test Job Role1',
                Main_Role_Add_on__c = JobRoleUtils.ROLE_ADD_ON
            );
            insert jobRole1;
        
            Role_Matrix__c roleMatrix1 = TestDataService.createRoleMatrix(new Role_Matrix__c(
                Job_Role__c = jobRole1.Id,
                Role_Matrix_Type__c  ='Global Job role/ Add-On role',
                MAPV_Department__c = mapvDepartment.Id,
                MAPV_Group__c = mapvGroup.Id,
                Company__c = company.Id
            ));
            insert roleMatrix1;
        }
    }
    
    //function to test the Service class methods which returns RoleMatrixData along with 
    //MyLearnings, Prima Roles and Prima SG as a UMA admin
    @isTest
    private static void getRoleMatricesDataTest(){
        User applicationAdmin = [SELECT Id FROM User WHERE Username = 'test.application.admin.ext@bayer.com'];

        List<Role_Matrix__c> roleMatrix = [SELECT Id FROM Role_Matrix__c LIMIT 2];
        Set<String> roleMatrixIds = new Set<String>{roleMatrix[0].Id, roleMatrix[1].Id};

        List<RoleMatrixData> roleMatricesData;
        List<Role_Matrix__c> roleMatrices;
        Map<Id, MyLearning_Program__c> newMyLearningPrograms;
        Map<Id, Prima_Role__c> newPrimaRoles;
        Map<Id, Prima_Security_Group__c> newPrimaSecurityGroups;
        RoleMatrixData roleMatrix2;
        RoleMatrixData roleMatrix3;

        Test.startTest();
        
        System.runAs(applicationAdmin){
            roleMatricesData = RoleMatrixService.getRoleMatricesData(roleMatrixIds);
            roleMatrices = RoleMatrixUtils.getRoleMatrices(roleMatrixIds);
            newMyLearningPrograms = RoleMatrixService.getMyLearningProgramsMap(roleMatrices);
            newPrimaRoles = RoleMatrixService.getPrimaRolesMap(roleMatrices);
            newPrimaSecurityGroups = RoleMatrixService.getPrimaSecurityGroupsMap(roleMatrices);
            roleMatrix2 = RoleMatrixService.getRoleMatrixData('');
            roleMatrix3 = RoleMatrixService.getRoleMatrixData(roleMatrix[0].Id);
        }
        
        Test.stopTest();
        
        System.assertEquals(2, roleMatricesData.size());
        System.assertEquals(2, roleMatrices.size());
        System.assertEquals(1, newMyLearningPrograms.size());
        System.assertEquals(1, newPrimaRoles.size());
        System.assertEquals(1, newPrimaSecurityGroups.size());
        System.assertEquals(null, roleMatrix2);
        System.assertEquals(1, roleMatrix3.myLearningPrograms.size());
    }
}