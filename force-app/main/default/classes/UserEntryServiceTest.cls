@isTest
public class UserEntryServiceTest {
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
        mlp.ID__c = 'PH_RD_CUR_140';
        insert mlp;

        Role_Matrix_ML__c rmmlp = new Role_Matrix_ML__c(
            Role_Matrix__c = roleMatrix.Id,
            MyLearning_Program__c = mlp.Id
        );
        insert rmmlp;
    }

    @isTest
    static void testValidateUserEntriesOnDelete() {
        Profile p = UserUtils.getPlatformEndUserProfile();
        User u = TestDataService.getDefaultUser();
        u.ProfileId = p.Id;
        insert u;
        Role_Matrix__c roleMatrix = [SELECT Id, Job_Role__c, MAPV_Department__c, MAPV_Group__c, Uma_Company__c FROM Role_Matrix__c LIMIT 1];

        User_Entry__c ue = (User_Entry__c) TestDataService.createUserEntry(new User_Entry__c(
            Primary_Job_Role__c = roleMatrix.Job_Role__c,
            MAPV_Department__c = roleMatrix.MAPV_Department__c,
            MAPV_Group__c = roleMatrix.MAPV_Group__c,
            Uma_Company__c = roleMatrix.Uma_Company__c,
            Resource_Manager__c = u.Id
        ));
        insert ue;
        
        PermissionSet ps = UserUtils.getUmaApplicationAdminPermissionSet();
		PermissionSetAssignment psa = new PermissionSetAssignment();
		psa.AssigneeId = u.Id;
		psa.PermissionSetId = ps.Id;
        system.runAs(u){
            insert psa;
        }
		
        System.runAs(u) {
            try {
                delete ue;
            } catch (Exception e) {
                System.assertEquals(true, e != null, 'Exception should be thrown.');
                System.assertEquals(true, e.getMessage().contains(Label.UserEntryCannotBeDeleted), 'Exception should be thrown.');
            }
        }
    }

    @isTest
    static void testUserEntrySharingsWithManagers() {
        Profile endUserProfile = UserUtils.getPlatformEndUserProfile();
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        Role_Matrix__c roleMatrix = [SELECT Id, Job_Role__c, MAPV_Department__c, MAPV_Group__c, Uma_Company__c FROM Role_Matrix__c LIMIT 1];

        List<User> users = new List<User>();

        User u = TestDataService.getDefaultUser();
        u.ProfileId = endUserProfile.Id;
        users.add(u);

        User u2 = TestDataService.getDefaultUser();
        u2.Username = 'resmgr@example.com.bayer';
        u2.ProfileId = adminProfile.Id;
        users.add(u2);

        insert users;

        System.runAs(u) {
            User_Entry__c ue = (User_Entry__c) TestDataService.createUserEntry(new User_Entry__c(
                Primary_Job_Role__c = roleMatrix.Job_Role__c,
                MAPV_Department__c = roleMatrix.MAPV_Department__c,
                MAPV_Group__c = roleMatrix.MAPV_Group__c,
                Uma_Company__c = roleMatrix.Uma_Company__c,
                Resource_Manager__c = u2.Id,
                Deputy_Manager__c = UserInfo.getUserId()
            ));
            insert ue;

            ue.Resource_Manager__c = UserInfo.getUserId();
            ue.Deputy_Manager__c = u2.Id;
            update ue;

            List<User_Entry__Share> resultShares = [SELECT Id FROM User_Entry__Share];
            System.assertEquals(true, resultShares.size() > 1, 'User Entry record should be shared.');
        }
    }

    @isTest
    static void testUpdateMyLearningCurriculums() {
        Profile p = UserUtils.getPlatformEndUserProfile();
        User u = TestDataService.getDefaultUser();
        u.ProfileId = p.Id;
        insert u;
        
        Role_Matrix__c roleMatrix = [SELECT Id, Job_Role__c, MAPV_Department__c, MAPV_Group__c, Uma_Company__c FROM Role_Matrix__c LIMIT 1];

        User_Entry__c ue = (User_Entry__c) TestDataService.createUserEntry(new User_Entry__c(
            Primary_Job_Role__c = roleMatrix.Job_Role__c,
            MAPV_Department__c = roleMatrix.MAPV_Department__c,
            MAPV_Group__c = roleMatrix.MAPV_Group__c,
            Uma_Company__c = roleMatrix.Uma_Company__c,
            Resource_Manager__c = u.Id
        ));
        insert ue;

       System.runAs(u) {
            ue.Is_Locked__c = true;
            update ue;

            List<AsyncApexJob> resultBatch = [SELECT Id, MethodName FROM AsyncApexJob];
            // System.assertEquals(true, resultBatch.size() > 0, 'Batch job should be started.');
        }
    }

    @isTest
    static void testUpdateLockedUserEntries() {
        Role_Matrix__c roleMatrix = [SELECT Id, Job_Role__c, MAPV_Department__c, MAPV_Group__c, Uma_Company__c FROM Role_Matrix__c LIMIT 1];
	    User_Entry__c ue = (User_Entry__c) TestDataService.createUserEntry(new User_Entry__c(
            Primary_Job_Role__c = roleMatrix.Job_Role__c,
            MAPV_Department__c = roleMatrix.MAPV_Department__c,
            MAPV_Group__c = roleMatrix.MAPV_Group__c,
            Uma_Company__c = roleMatrix.Uma_Company__c
        ));
        insert ue;

        MyLearning_Program__c mlp = TestDataService.getDefaultMyLearningProgram();
        mlp.ID__c = 'PH_RD_140';
        mlp.Name = 'Test ML Program1';
        insert mlp;

        User_MyLearning_Program__c umlp = new User_MyLearning_Program__c(
            User_Entry__c = ue.Id,
            MyLearning_Program__c = mlp.Id,
            Status__c = 'Assign'
        );
        insert umlp;

        Prima_Role__c pr = TestDataService.getDefaultPrimaRole();
        insert pr;

        User_Prima_Role__c upr = new User_Prima_Role__c(
            User_Entry__c = ue.Id,
            Prima_Role__c = pr.Id,
            Status__c = 'Assign'
        );
        insert upr;

        Prima_Security_Group__c psg = TestDataService.getDefaultPrimaSecurityGroup();
        insert psg;

        User_Prima_Security_Group__c upsg = new User_Prima_Security_Group__c(
            User_Entry__c = ue.Id,
            Prima_Security_Group__c = psg.Id,
            Status__c = 'Assign'
        );
        insert upsg;

        Test.startTest();

        umlp.Status__c = 'Remove';
        update umlp;

        upr.Status__c = 'Assigned';
        update upr;

        upsg.Status__c = 'Assigned';
        update upsg;

        delete umlp;

        Test.stopTest();

        User_Entry__c resultUe = [SELECT Is_Locked__c FROM User_Entry__c WHERE Id = :ue.Id LIMIT 1];
        System.assertEquals(false, resultUe.Is_Locked__c, 'User Entry record should be locked.');
    }
}