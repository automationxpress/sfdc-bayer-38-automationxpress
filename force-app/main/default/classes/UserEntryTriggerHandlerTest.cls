@isTest
private class UserEntryTriggerHandlerTest {
    
    @TestSetup
    private static void setupTestData(){
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
    }
    
    @IsTest
    static void deleteUserEntriesErrorTest() {
        Role_Matrix__c roleMatrix = [SELECT Id, Job_Role__c, MAPV_Department__c, MAPV_Group__c, Company__c FROM Role_Matrix__c LIMIT 1];
        Profile p = UserUtils.getPlatformEndUserProfile();
        User u = TestDataService.getDefaultUser();
        u.ProfileId = p.Id;
        insert u;
        User_Entry__c userEntryCurrent = (User_Entry__c) TestDataService.createUserEntry(new User_Entry__c(
            CWID__c = 'ABCDE',
            Email__c = 'ABCDE.test@bayer.com',
            Primary_Job_Role__c = roleMatrix.Job_Role__c,
            MAPV_Department__c = roleMatrix.MAPV_Department__c,
            MAPV_Group__c = roleMatrix.MAPV_Group__c,
            Company__c = roleMatrix.Company__c,
            Resource_Manager__c = u.Id
        ));
        User_Entry__c userEntryLeft = (User_Entry__c) TestDataService.createUserEntry(new User_Entry__c(
            CWID__c = 'FGHIJ',
            Email__c = 'FGHIJ.test@bayer.com',
            Primary_Job_Role__c = roleMatrix.Job_Role__c,
            MAPV_Department__c = roleMatrix.MAPV_Department__c,
            MAPV_Group__c = roleMatrix.MAPV_Group__c,
            Company__c = roleMatrix.Company__c,
            Staff_Status__c = UserEntryUtils.STAFF_STATUS_LEFT,
            CWID_Deactivated__c = 'No',
            Resource_Manager__c = u.Id
        ));
        
        List<User_Entry__c> userEntries = new List<User_Entry__c>{ userEntryCurrent, userEntryLeft};
        insert userEntries;
        System.assertEquals(2, userEntries.size());

        Test.startTest();
        
        Database.delete(userEntries, false);

        Test.stopTest();
        
        userEntries = [SELECT Id FROM User_Entry__c];
        System.assertEquals(1, userEntries.size());
    }
}