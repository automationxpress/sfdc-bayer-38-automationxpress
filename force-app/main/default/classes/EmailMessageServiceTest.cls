/**********************************************************
*  To test the fucntionality of EmailMessageService
* 
*   Last Modified Date: - 21/06/2023
*    modified to handle the replacement of Account lookup field by new Company picklist field in Role Matrix and User Entry
*
* *********************************************************/

@isTest
public class EmailMessageServiceTest {
    @TestSetup
    static void setupTestData() {
        
        Job_Role__c jobRole = TestDataService.getDefaultJobRole();
        insert jobRole;

        MAPV_Department__c mapvDepartment = TestDataService.getDefaultMapvDepartment();
        insert mapvDepartment;

        MAPV_Group__c mapvGroup = TestDataService.getDefaultMapvGroup();
        insert mapvGroup;

        Role_Matrix__c roleMatrix = TestDataService.createRoleMatrix(new Role_Matrix__c(
            Job_Role__c = jobRole.Id,
            MAPV_Department__c = mapvDepartment.Id,
            MAPV_Group__c = mapvGroup.Id
        ));
        insert roleMatrix;
        
        MyLearning_Program__c mlp = TestDataService.getDefaultMyLearningProgram();
        mlp.ID__c = 'PH_RD_160';
        mlp.Name = 'Test ML Program2';
        insert mlp;
    }

    @isTest
    static void testGetMyLearningUpdatesTemplateId() {
        Id testTmplId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'User_Entry_MyLearning_Updates_Notification' LIMIT 1].Id;

        Test.startTest();
        Id templateId = EmailMessageService.getMyLearningUpdatesTemplateId();
        Test.stopTest();

        System.assertEquals(testTmplId, templateId, 'Template Id should be returned.');
    }

    @isTest
    static void testGetAndSendSingleEmailMessageFromTemplate() {
        Id templateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'User_Entry_MyLearning_Updates_Notification' LIMIT 1].Id;
        Role_Matrix__c roleMatrix = [SELECT Id, Job_Role__c, MAPV_Department__c, MAPV_Group__c, Uma_Company__c FROM Role_Matrix__c LIMIT 1];
		MyLearning_Program__c mlp = [SELECT Id, Name, ID__c FROM MyLearning_Program__c LIMIT 1];
        Role_Matrix_ML__c rmmlp = new Role_Matrix_ML__c(
            							MyLearning_Program__c = mlp.Id,
            							Role_Matrix__c = roleMatrix.Id
        						  );
        insert rmmlp;
            
        User_Entry__c ue = (User_Entry__c) TestDataService.createUserEntry(new User_Entry__c(
            Primary_Job_Role__c = roleMatrix.Job_Role__c,
            MAPV_Department__c = roleMatrix.MAPV_Department__c,
            MAPV_Group__c = roleMatrix.MAPV_Group__c,
            Uma_Company__c = roleMatrix.Uma_Company__c
        ));
        insert ue;
        
        
        

        List<String> addresses = new List<String>{ 'test@test.com' };

        Test.startTest();

        Messaging.SingleEmailMessage email = EmailMessageService.getSingleEmailMessageFromTemplate(templateId, ue.Id, addresses);
        System.assertEquals(false, email == null, 'Email should be created.');

        EmailMessageService.sendEmailMessages(new List<Messaging.SingleEmailMessage>{ email });

        Test.stopTest();
    }
}