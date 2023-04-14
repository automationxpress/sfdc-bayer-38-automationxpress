@isTest
private class MyLearningCurriculumsBatchTest {
    
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

        MyLearning_Program__c myLearningProgram  = TestDataService.createMyLearningProgram(new MyLearning_Program__c(
            ID__c = 'ML_DDDD'
        ));
        insert myLearningProgram;
        
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
            CWID__c = 'AABCC',
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
            Status__c = UserEntryData.STATUS_ASSIGN
        );
    }

    @isTest
    public static void testMyLearningCurriculumsBatch() {
        User manager = [SELECT Id FROM User WHERE Username = 'test.manager.ext@bayer.com'];
        Set<Id> userEntryIds = new Set<Id>();
        for(User_Entry__c userEntry : [SELECT Id FROM User_Entry__c]){
            userEntryIds.add(userEntry.Id);
        }

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseAssignSuccess());
        System.runAs(manager){
            Database.executeBatch(new MyLearningCurriculumsBatch(userEntryIds), 10);
        }

        Test.stopTest();

        for(User_MyLearning_Program__c userMyLearningProgram : [SELECT Id, Status__c FROM User_MyLearning_Program__c]){
            System.assertEquals(userMyLearningProgram.Status__c, UserEntryData.STATUS_ASSIGNED);
        }
    }

    public class MockHttpResponseAssignSuccess implements HttpCalloutMock {
        String body = '{'
                        + '"primaryKey": "",'
                        + '"curricula": ['
                            + '{'
                                + '"studentID": "AABCC",'
                                + '"qualificationID": "ML_DDDD",'
                                + '"assignmentDate": 1644192000000,'
                                + '"errorMessage": null'
                            + '}'
                        + ']'
                    + '}';

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(body);
            res.setStatusCode(201);
            return res;
        }
    }
}