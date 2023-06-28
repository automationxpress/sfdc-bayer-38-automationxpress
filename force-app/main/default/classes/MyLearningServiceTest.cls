@isTest
private class MyLearningServiceTest {

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

        MyLearning_Program__c myLearningProgram = TestDataService.createMyLearningProgram(new MyLearning_Program__c(
            ID__c = 'ML_DDDD'
        ));
        insert myLearningProgram;
        
        Role_Matrix__c roleMatrix = TestDataService.createRoleMatrix(new Role_Matrix__c(
            Job_Role__c = jobRole.Id,
            MAPV_Department__c = mapvDepartment.Id,
            MAPV_Group__c = mapvGroup.Id
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
    public static void testGetCurriculumStatus() {
        User manager = [SELECT Id FROM User WHERE Username = 'test.manager.ext@bayer.com'];
        User_Entry__c userEntry = [SELECT Id, CWID__c FROM User_Entry__c LIMIT 1];
        MyLearning_Program__c myLearningProgram = [SELECT Id, ID__c FROM MyLearning_Program__c LIMIT 1];

        String status;

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGetStatus());
        System.runAs(manager){
            status = MyLearningService.getCurriculumStatus(userEntry.CWID__c, myLearningProgram.ID__c);
        }

        Test.stopTest();

        System.assertEquals(MyLearningService.CURRICULUM_STATUS_INCOMPLETE, status);
    }

    @isTest
    public static void testAssignCurriculumsSuccess() {
        User manager = [SELECT Id FROM User WHERE Username = 'test.manager.ext@bayer.com'];
        User_Entry__c userEntry = [SELECT Id, CWID__c FROM User_Entry__c LIMIT 1];
        MyLearning_Program__c myLearningProgram = [SELECT Id, ID__c FROM MyLearning_Program__c LIMIT 1];
        List<User_MyLearning_Program__c> userMyLearningPrograms = [SELECT Id, User_Entry__r.CWID__c, MyLearning_Program__r.ID__c FROM User_MyLearning_Program__c];

        Map<String, Map<String, MyLearningService.CurriculumResponse>> response;

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseAssignSuccess());
        System.runAs(manager){
            response = MyLearningService.assignCurriculums(userMyLearningPrograms);
        }

        Test.stopTest();

        System.debug(response);
        MyLearningService.CurriculumResponse curriculum = response.get(userEntry.CWID__c).get(myLearningProgram.ID__c);
        System.assertEquals(userEntry.CWID__c, curriculum.studentID);
        System.assertEquals(myLearningProgram.ID__c, curriculum.qualificationID);
    }

    public class MockHttpResponseGetStatus implements HttpCalloutMock {
        String body = '{'
                        + '"@odata.context": "$metadata#CurriculumStatuses",'
                        + '"value": ['
                            + '{'
                                + '"curriculumStatus": "' + MyLearningService.CURRICULUM_STATUS_INCOMPLETE + '",'
                                + '"expirationDate": null'
                            + '}'
                        + ']'
                    + '}';

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(body);
            res.setStatusCode(200);
            return res;
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