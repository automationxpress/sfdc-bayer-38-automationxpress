@isTest
public class PrimaNewRequestsRestApiTest {
    @TestSetup
    static void setupTestData() {
        Account company = TestDataService.getDefaultAccount();
        insert company;

        Job_Role__c jobRole = TestDataService.getDefaultJobRole();
        insert jobRole;

        MAPV_Department__c mapvDepartment = TestDataService.getDefaultMapvDepartment();
        insert mapvDepartment;

        MAPV_Group__c mapvGroup = TestDataService.getDefaultMapvGroup();
        insert mapvGroup;
        
        MyLearning_Program__c mlp = TestDataService.getDefaultMyLearningProgram();
        mlp.ID__c = 'PH_RD_170';
        mlp.Name = 'Test ML Program3';
        insert mlp;

        Role_Matrix__c roleMatrix = TestDataService.createRoleMatrix(new Role_Matrix__c(
            Job_Role__c = jobRole.Id,
            MAPV_Department__c = mapvDepartment.Id,
            MAPV_Group__c = mapvGroup.Id,
            Company__c = company.Id
        ));
        insert roleMatrix;
        
       Role_Matrix_ML__c rmmlp = new Role_Matrix_ML__c(
            							MyLearning_Program__c = mlp.Id,
            							Role_Matrix__c = roleMatrix.Id
        						  );
       insert rmmlp;
        
    }

    @isTest
    static void testGetPrimaNewRequests() {
        Role_Matrix__c roleMatrix = [SELECT Id, Job_Role__c, MAPV_Department__c, MAPV_Group__c, Company__c FROM Role_Matrix__c LIMIT 1];
        User_Entry__c ue = (User_Entry__c) TestDataService.createUserEntry(new User_Entry__c(
            Primary_Job_Role__c = roleMatrix.Job_Role__c,
            MAPV_Department__c = roleMatrix.MAPV_Department__c,
            MAPV_Group__c = roleMatrix.MAPV_Group__c,
            Company__c = roleMatrix.Company__c
        ));
        insert ue;

        Test.startTest();
        PrimaNewRequestsRestApi.PrimaRequest req = PrimaNewRequestsRestApi.getPrimaNewRequests();
        Test.stopTest();

        System.assertEquals(true, req != null, 'Request should exist.');
    }

    @isTest
    static void testUpdatePrimaNewRequests() {
        Role_Matrix__c roleMatrix = [SELECT Id, Job_Role__c, MAPV_Department__c, MAPV_Group__c, Company__c FROM Role_Matrix__c LIMIT 1];

        User_Entry__c ue = (User_Entry__c) TestDataService.createUserEntry(new User_Entry__c(
            Primary_Job_Role__c = roleMatrix.Job_Role__c,
            MAPV_Department__c = roleMatrix.MAPV_Department__c,
            MAPV_Group__c = roleMatrix.MAPV_Group__c,
            Company__c = roleMatrix.Company__c
        ));
        insert ue;

        Prima_Role__c pr = TestDataService.getDefaultPrimaRole();
        insert pr;

        User_Prima_Role__c upr = new User_Prima_Role__c(
            User_Entry__c = ue.Id,
            Prima_Role__c = pr.Id,
            Status__c = 'Assign Requested'
        );
        insert upr;

        Prima_Security_Group__c psg = TestDataService.getDefaultPrimaSecurityGroup();
        insert psg;

        User_Prima_Security_Group__c upsg = new User_Prima_Security_Group__c(
            User_Entry__c = ue.Id,
            Prima_Security_Group__c = psg.Id,
            Status__c = 'Assign Requested'
        );
        insert upsg;

        PrimaData.PrimaRoleResponse prrSuccess = new PrimaData.PrimaRoleResponse();
        prrSuccess.name = 'Test Prima Role';
        prrSuccess.status = 'Assign Requested';
        prrSuccess.error = '';

        PrimaData.PrimaSecurityGroupResponse psgrSuccess = new PrimaData.PrimaSecurityGroupResponse();
        psgrSuccess.name = 'Test Prima Security Group';
        psgrSuccess.status = 'Assign Requested';
        psgrSuccess.error = '';

        PrimaData.PrimaRoleResponse prrError = new PrimaData.PrimaRoleResponse();
        prrError.name = 'Test Prima Role';
        prrError.status = 'Error';
        prrError.error = 'Error';

        PrimaData.PrimaSecurityGroupResponse psgrError = new PrimaData.PrimaSecurityGroupResponse();
        psgrError.name = 'Test Prima Security Group';
        psgrError.status = 'Error';
        psgrError.error = 'Error';

        PrimaData.UserResponse urSuccess = new PrimaData.UserResponse();
        urSuccess.cwid = 'BYXXF';
        urSuccess.primaRoles = new List<PrimaData.PrimaRoleResponse>{ prrSuccess };
        urSuccess.primaSecurityGroups = new List<PrimaData.PrimaSecurityGroupResponse>{ psgrSuccess };

        PrimaData.UserResponse urError = new PrimaData.UserResponse();
        urError.cwid = 'BYXXF';
        urError.primaRoles = new List<PrimaData.PrimaRoleResponse>{ prrError };
        urError.primaSecurityGroups = new List<PrimaData.PrimaSecurityGroupResponse>{ psgrError };

        Test.startTest();

        PrimaData.UserRequest ur = new PrimaData.UserRequest(ue);
        PrimaData.PrimaRoleRequest prr = new PrimaData.PrimaRoleRequest(prrSuccess.name, prrSuccess.status);
        PrimaData.PrimaSecurityGroupRequest psgr = new PrimaData.PrimaSecurityGroupRequest(psgrSuccess.name, psgrSuccess.status);

        PrimaNewRequestsRestApi.updatePrimaNewRequests(new List<PrimaData.UserResponse>{ urSuccess });
        PrimaNewRequestsRestApi.updatePrimaNewRequests(new List<PrimaData.UserResponse>{ urError });

        Test.stopTest();

        List<User_Prima_Role__c> resultUprs = [SELECT Id FROM User_Prima_Role__c];
        List<User_Prima_Security_Group__c> resultUpsgs = [SELECT Id FROM User_Prima_Security_Group__c];

        System.assertEquals(1, resultUprs.size(), 'User Prima Roles should be updated.');
        System.assertEquals(1, resultUpsgs.size(), 'User Prima Security Groups should be updated.');
    }
}