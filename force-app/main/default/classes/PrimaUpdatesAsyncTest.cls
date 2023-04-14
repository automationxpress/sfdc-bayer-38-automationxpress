@isTest
private class PrimaUpdatesAsyncTest {

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
        
        MyLearning_Program__c mlp = TestDataService.getDefaultMyLearningProgram();
        mlp.ID__c = 'PH_RD_CUR_150';
        insert mlp;
        
        Role_Matrix_ML__c rmmlp = new Role_Matrix_ML__c(
            Role_Matrix__c = roleMatrix.Id,
            MyLearning_Program__c = mlp.Id
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
    
        insert new User_Prima_Role__c(
            User_Entry__c = userEntry.Id,
            Prima_Role__c = primaRole.Id,
            Status__c = UserEntryData.STATUS_ASSIGN
        );
        insert new User_Prima_Security_Group__c(
            User_Entry__c = userEntry.Id,
            Prima_Security_Group__c = primaSecurityGroup.Id,
            Status__c = UserEntryData.STATUS_REMOVE
        );
    }

    @isTest
    public static void testPrimaUpdatesAsync() {
        User manager = [SELECT Id FROM User WHERE Username = 'test.manager.ext@bayer.com'];
        Set<Id> userEntryIds = new Set<Id>();
        for(User_Entry__c userEntry : [SELECT Id FROM User_Entry__c]){
            userEntryIds.add(userEntry.Id);
        }
        List<User_Entry__c> userEntries = UserEntryUtils.getUserEntriesForPrimaUpdates(userEntryIds);

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseSendSuccess());
        System.runAs(manager){
            System.enqueueJob(new PrimaUpdatesAsync(userEntries));
        }

        Test.stopTest();

        for(User_Prima_Role__c userPrimaRole : [SELECT Id, Status__c FROM User_Prima_Role__c]){
            System.assertEquals(UserEntryData.STATUS_ASSIGN_REQUESTED, userPrimaRole.Status__c);
        }
        for(User_Prima_Security_Group__c userPrimaSecurityGroup : [SELECT Id, Status__c FROM User_Prima_Security_Group__c]){
            System.assertEquals(UserEntryData.STATUS_REMOVE_REQUESTED, userPrimaSecurityGroup.Status__c);
        }
    }

    public class MockHttpResponseSendSuccess implements HttpCalloutMock {
        String body = '';

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        }
    }
}