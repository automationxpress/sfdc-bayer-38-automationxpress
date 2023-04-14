//Test class to cover UserEntryController & UMAHomePageController
@isTest
private class UserEntryControllerTest {
    
    @TestSetup
    private static void setupTestData(){
        Profile platformEndUserProfile = UserUtils.getPlatformEndUserProfile();
        User manager = TestDataService.createUser(new User(
            Username = 'test.manager.ext@bayer.com',
            ProfileId = platformEndUserProfile.Id,
            FederationIdentifier = 'AABBB'
        ));
        insert manager;

        Account company = TestDataService.getDefaultAccount();
        insert company;

        MAPV_Department__c mapvDepartment = TestDataService.getDefaultMapvDepartment();
        insert mapvDepartment;

        MAPV_Group__c mapvGroup = TestDataService.getDefaultMapvGroup();
        insert mapvGroup;

        Job_Role__c jobRole = TestDataService.getDefaultJobRole();
        insert jobRole;

        MyLearning_Program__c myLearningProgram = TestDataService.getDefaultMyLearningProgram();
        insert myLearningProgram;

        Prima_Role__c primaRole = TestDataService.getDefaultPrimaRole();
        insert primaRole;

        Prima_Security_Group__c primaSecurityGroup = TestDataService.getDefaultPrimaSecurityGroup();
        insert primaSecurityGroup;
        
        Role_Matrix__c roleMatrix = TestDataService.createRoleMatrix(new Role_Matrix__c(
            Job_Role__c = jobRole.Id,
            MAPV_Department__c = mapvDepartment.Id,
            MAPV_Group__c = mapvGroup.Id,
            Company__c = company.Id
        ));
        insert roleMatrix;
        
        Role_Matrix_ML__c rmmlp = new Role_Matrix_ML__c(
            Role_Matrix__c = roleMatrix.Id,
            MyLearning_Program__c = myLearningProgram.Id
        );
        insert rmmlp;

        User_Entry__c userEntry = TestDataService.createUserEntry(new User_Entry__c(
            Resource_Manager__c = manager.Id,
            Company__c = company.Id, 
            MAPV_Department__c = mapvDepartment.Id, 
            MAPV_Group__c = mapvGroup.Id, 
            Primary_Job_Role__c = jobRole.Id
        ));
        insert userEntry;
    
        insert new User_MyLearning_Program__c(
            User_Entry__c = userEntry.Id,
            MyLearning_Program__c = myLearningProgram.Id,
            Status__c = UserEntryData.STATUS_ASSIGNED
        );
        insert new User_Prima_Role__c(
            User_Entry__c = userEntry.Id,
            Prima_Role__c = primaRole.Id,
            Status__c = UserEntryData.STATUS_ASSIGNED
        );
        insert new User_Prima_Security_Group__c(
            User_Entry__c = userEntry.Id,
            Prima_Security_Group__c = primaSecurityGroup.Id,
            Status__c = UserEntryData.STATUS_ASSIGNED
        );
    }

    @isTest
    public static void testUserEntryNeedApproval() {
        User manager = [SELECT Id FROM User WHERE Username = 'test.manager.ext@bayer.com'];
        User_Entry__c userEntry = [SELECT Id FROM User_Entry__c LIMIT 1];

        Test.startTest();
		List<User_Entry__c> userEntries = UMAHomePageController.getUserEntryDetails();
        List<User_Entry__c> filteredUserEntries = UMAHomePageController.getFilteredUserEntryDetails('test', '', '');
        System.assertEquals(true, userEntries.size()>0);
        System.assertEquals(true, filteredUserEntries.size()>0);
        System.runAs(manager){
            Boolean result = UserEntryController.doesUserEntryNeedApproval(userEntry.Id);
            System.assertEquals(false, result);
        }

        Test.stopTest();
    }
}