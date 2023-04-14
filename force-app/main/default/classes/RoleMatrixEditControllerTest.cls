//Test class for RoleMatrixEditController
@isTest
private class RoleMatrixEditControllerTest {
    
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
        }
    }
    
    //Test the functionality which return the Role Matrix data as a UMA admin user
    @IsTest
    static void getRoleMatrixDataTest() {
        User applicationAdmin = [SELECT Id FROM User WHERE Username = 'test.application.admin.ext@bayer.com'];
        
        Role_Matrix__c roleMatrix = [SELECT Id FROM Role_Matrix__c LIMIT 1];
        RoleMatrixData roleMatrixData;

        Test.startTest();
        
        System.runAs(applicationAdmin){
            roleMatrixData = RoleMatrixEditController.getRoleMatrixData(roleMatrix.Id);
        }

        Test.stopTest();
        
        System.assertEquals(1, roleMatrixData.myLearningPrograms.size());
        System.assertEquals(1, roleMatrixData.primaRoles.size());
        System.assertEquals(1, roleMatrixData.primaSecurityGroups.size());
    }

    //Test the functionality to save the Role Matrix Record as a UMA admin
    @IsTest
    static void saveRoleMatrixDataTest() {
        User applicationAdmin = [SELECT Id FROM User WHERE Username = 'test.application.admin.ext@bayer.com'];

        Role_Matrix__c roleMatrix = [SELECT Id FROM Role_Matrix__c LIMIT 1];

        MyLearning_Program__c myLearningProgram = new MyLearning_Program__c(
            Name = 'MyLearning Program 22',
            ID__c = 'ML Program 22'
        );
        insert myLearningProgram;

        Prima_Role__c primaRole = new Prima_Role__c(Name = 'Prima Role 22');
        insert primaRole;

        Prima_Security_Group__c primaSecurityGroup = new Prima_Security_Group__c(Name = 'Prima Security Group 22');
        insert primaSecurityGroup;
        
        RoleMatrixData roleMatrixData = RoleMatrixEditController.getRoleMatrixData(roleMatrix.Id);
        roleMatrixData.myLearningPrograms = new List<MyLearning_Program__c>{myLearningProgram};
        roleMatrixData.primaRoles = new List<Prima_Role__c>{primaRole};
        roleMatrixData.primaSecurityGroups = new List<Prima_Security_Group__c>{primaSecurityGroup};

        Test.startTest();
        
        System.runAs(applicationAdmin){
            RoleMatrixEditController.saveRoleMatrixData(roleMatrixData);
        }

        Test.stopTest();
        
        System.assertEquals(1, roleMatrixData.myLearningPrograms.size());
        System.assertEquals(1, roleMatrixData.primaRoles.size());
        System.assertEquals(1, roleMatrixData.primaSecurityGroups.size());
    }
}