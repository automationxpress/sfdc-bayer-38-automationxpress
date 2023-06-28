@isTest
private class PrimaServiceTest {

    @TestSetup
    private static void setupTestData(){
        Profile platformEndUserProfile = UserUtils.getPlatformEndUserProfile();
        User manager = TestDataService.createUser(new User(
            Username = 'test.manager.ext@bayer.com',
            ProfileId = platformEndUserProfile.Id,
            FederationIdentifier = 'AABBB'
        ));
        insert manager;

        
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
            MAPV_Group__c = mapvGroup.Id
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
    public static void testSendPrimaUpdatesSuccess() {
        User manager = [SELECT Id FROM User WHERE Username = 'test.manager.ext@bayer.com'];
        UMA_Settings__mdt umaSettings = OrgUtils.getUmaSettings();
        Integer nrOfAttempts = (Integer) umaSettings.Max_nr_of_Prima_POST_request_attempts__c - 1;
        Set<Id> userEntryIds = new Set<Id>();
        for(User_Entry__c userEntry : [SELECT Id FROM User_Entry__c]){
            userEntryIds.add(userEntry.Id);
        }
        List<User_Entry__c> userEntries = UserEntryUtils.getUserEntriesForPrimaUpdates(userEntryIds);

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseSendSuccess());
        System.runAs(manager){
            PrimaService.sendPrimaUpdates(userEntries, nrOfAttempts);
        }

        Test.stopTest();

        for(User_Prima_Role__c userPrimaRole : [SELECT Id, Status__c FROM User_Prima_Role__c]){
            System.assertEquals(UserEntryData.STATUS_ASSIGN_REQUESTED, userPrimaRole.Status__c);
        }
        for(User_Prima_Security_Group__c userPrimaSecurityGroup : [SELECT Id, Status__c FROM User_Prima_Security_Group__c]){
            System.assertEquals(UserEntryData.STATUS_REMOVE_REQUESTED, userPrimaSecurityGroup.Status__c);
        }
    }

    @isTest
    public static void testSendPrimaUpdatesError() {
        User manager = [SELECT Id FROM User WHERE Username = 'test.manager.ext@bayer.com'];
        UMA_Settings__mdt umaSettings = OrgUtils.getUmaSettings();
        Integer nrOfAttempts = (Integer) umaSettings.Max_nr_of_Prima_POST_request_attempts__c - 1;
        Set<Id> userEntryIds = new Set<Id>();
        for(User_Entry__c userEntry : [SELECT Id FROM User_Entry__c]){
            userEntryIds.add(userEntry.Id);
        }
        List<User_Entry__c> userEntries = UserEntryUtils.getUserEntriesForPrimaUpdates(userEntryIds);

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseSendError());
        System.runAs(manager){
            PrimaService.sendPrimaUpdates(userEntries, nrOfAttempts);
        }

        Test.stopTest();

        for(User_Prima_Role__c userPrimaRole : [SELECT Id, Status__c, Initial_Sending_Failed__c FROM User_Prima_Role__c]){
            System.assertEquals(UserEntryData.STATUS_ASSIGN, userPrimaRole.Status__c);
            System.assertEquals(true, userPrimaRole.Initial_Sending_Failed__c);
        }
        for(User_Prima_Security_Group__c userPrimaSecurityGroup : [SELECT Id, Status__c, Initial_Sending_Failed__c FROM User_Prima_Security_Group__c]){
            System.assertEquals(UserEntryData.STATUS_REMOVE, userPrimaSecurityGroup.Status__c);
            System.assertEquals(true, userPrimaSecurityGroup.Initial_Sending_Failed__c);
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

    public class MockHttpResponseSendError implements HttpCalloutMock {
        String body = '';

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(body);
            res.setStatusCode(404);
            return res;
        }
    }
}