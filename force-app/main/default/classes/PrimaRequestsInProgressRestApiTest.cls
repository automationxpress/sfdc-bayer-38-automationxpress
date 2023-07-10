@isTest
public class PrimaRequestsInProgressRestApiTest {
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
    }

    @isTest
    static void testGetPrimaRequestsInProgress() {
        Role_Matrix__c roleMatrix = [SELECT Id, Job_Role__c, MAPV_Department__c, MAPV_Group__c, Uma_Company__c FROM Role_Matrix__c LIMIT 1];

        User_Entry__c ue = (User_Entry__c) TestDataService.createUserEntry(new User_Entry__c(
            Primary_Job_Role__c = roleMatrix.Job_Role__c,
            MAPV_Department__c = roleMatrix.MAPV_Department__c,
            MAPV_Group__c = roleMatrix.MAPV_Group__c,
            Uma_Company__c = roleMatrix.Uma_Company__c
        ));
        insert ue;

        Test.startTest();
        PrimaRequestsInProgressRestApi.PrimaRequest req = PrimaRequestsInProgressRestApi.getPrimaRequestsInProgress();
        Test.stopTest();

        System.assertEquals(true, req != null, 'Request should exist.');
    }

    @isTest
    static void testUpdatePrimaRequestsInProgress() {
        Role_Matrix__c roleMatrix = [SELECT Id, Job_Role__c, MAPV_Department__c, MAPV_Group__c, Uma_Company__c FROM Role_Matrix__c LIMIT 1];

        User_Entry__c ue = (User_Entry__c) TestDataService.createUserEntry(new User_Entry__c(
            Primary_Job_Role__c = roleMatrix.Job_Role__c,
            MAPV_Department__c = roleMatrix.MAPV_Department__c,
            MAPV_Group__c = roleMatrix.MAPV_Group__c,
            Uma_Company__c = roleMatrix.Uma_Company__c
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
        prrSuccess.status = 'Assigned';
        prrSuccess.error = '';

        PrimaData.PrimaSecurityGroupResponse psgrSuccess = new PrimaData.PrimaSecurityGroupResponse();
        psgrSuccess.name = 'Test Prima Security Group';
        psgrSuccess.status = 'Assigned';
        psgrSuccess.error = '';

        PrimaData.PrimaRoleResponse prrError = new PrimaData.PrimaRoleResponse();
        prrError.name = 'Test Prima Role';
        prrError.status = 'Error';
        prrError.error = 'Error';

        PrimaData.PrimaSecurityGroupResponse psgrError = new PrimaData.PrimaSecurityGroupResponse();
        psgrError.name = 'Test Prima Security Group';
        psgrError.status = 'Error';
        psgrError.error = 'Error';

        PrimaData.PrimaRoleResponse prrRemoved = new PrimaData.PrimaRoleResponse();
        prrRemoved.name = 'Test Prima Role';
        prrRemoved.status = 'Removed';
        prrRemoved.error = '';

        PrimaData.PrimaSecurityGroupResponse psgrRemoved = new PrimaData.PrimaSecurityGroupResponse();
        psgrRemoved.name = 'Test Prima Security Group';
        psgrRemoved.status = 'Removed';
        psgrRemoved.error = '';

        PrimaData.UserResponse urSuccess = new PrimaData.UserResponse();
        urSuccess.cwid = 'BYXXF';
        urSuccess.primaRoles = new List<PrimaData.PrimaRoleResponse>{ prrSuccess };
        urSuccess.primaSecurityGroups = new List<PrimaData.PrimaSecurityGroupResponse>{ psgrSuccess };

        PrimaData.UserResponse urError = new PrimaData.UserResponse();
        urError.cwid = 'BYXXF';
        urError.primaRoles = new List<PrimaData.PrimaRoleResponse>{ prrError };
        urError.primaSecurityGroups = new List<PrimaData.PrimaSecurityGroupResponse>{ psgrError };

        PrimaData.UserResponse urRemoved = new PrimaData.UserResponse();
        urRemoved.cwid = 'BYXXF';
        urRemoved.primaRoles = new List<PrimaData.PrimaRoleResponse>{ prrRemoved };
        urRemoved.primaSecurityGroups = new List<PrimaData.PrimaSecurityGroupResponse>{ psgrRemoved };

        Test.startTest();

        PrimaRequestsInProgressRestApi.updatePrimaRequestsInProgress(new List<PrimaData.UserResponse>{ urSuccess });
        PrimaRequestsInProgressRestApi.updatePrimaRequestsInProgress(new List<PrimaData.UserResponse>{ urError });
        PrimaRequestsInProgressRestApi.updatePrimaRequestsInProgress(new List<PrimaData.UserResponse>{ urRemoved });

        Test.stopTest();

        List<User_Prima_Role__c> resultUprs = [SELECT Id FROM User_Prima_Role__c];
        List<User_Prima_Security_Group__c> resultUpsgs = [SELECT Id FROM User_Prima_Security_Group__c];

        System.assertEquals(0, resultUprs.size(), 'User Prima Roles should be deleted.');
        System.assertEquals(0, resultUpsgs.size(), 'User Prima Security Groups should be deleted.');
    }
}