@isTest
public class UserPrimaRoleTriggerHandlerTest {
    
    @TestSetup
    static void setupTestData() {
        Profile platformEndUserProfile = UserUtils.getPlatformEndUserProfile();
        PermissionSet umaApplicationAdminPermissionSet = UserUtils.getUmaApplicationAdminPermissionSet();
        PermissionSet umaEndUserPermissionSet = UserUtils.getUmaEndUserPermissionSet();

        User applicationAdmin = TestDataService.createUser(new User(
            Username = 'test.application.admin.ext@bayer.com',
            ProfileId = platformEndUserProfile.Id,
            FederationIdentifier = 'ZZBBB'
        ));
        User endUser = TestDataService.createUser(new User(
            Username = 'test.end.user.ext@bayer.com',
            ProfileId = platformEndUserProfile.Id,
            FederationIdentifier = 'MMBBB'
        ));
        User manager = TestDataService.createUser(new User(
            Username = 'test.manager.ext@bayer.com',
            ProfileId = platformEndUserProfile.Id,
            FederationIdentifier = 'AABBB'
        ));
        insert new List<User>{applicationAdmin, endUser, manager};

        List<PermissionSetAssignment> permissionSetAssignments = new List<PermissionSetAssignment>();
        permissionSetAssignments.add(new PermissionSetAssignment(
            PermissionSetId = umaApplicationAdminPermissionSet.Id,
            AssigneeId = applicationAdmin.Id
        ));
        permissionSetAssignments.add(new PermissionSetAssignment(
            PermissionSetId = umaEndUserPermissionSet.Id,
            AssigneeId = endUser.Id
        ));
        insert permissionSetAssignments;

        Account company = TestDataService.getDefaultAccount();
        MAPV_Department__c mapvDepartment = TestDataService.getDefaultMapvDepartment();
        MAPV_Group__c mapvGroup = TestDataService.getDefaultMapvGroup();
        Job_Role__c jobRole = TestDataService.getDefaultJobRole();
        Prima_Security_Group__c primaSecurityGroup = TestDataService.getDefaultPrimaSecurityGroup();

        System.runAs(applicationAdmin){
            insert company;
            insert mapvDepartment;
            insert mapvGroup;
            insert jobRole;
            insert primaSecurityGroup;
        }
        
        System.runAs(applicationAdmin){
            Role_Matrix__c roleMatrix = TestDataService.createRoleMatrix(new Role_Matrix__c(
            Job_Role__c = jobRole.Id,
            MAPV_Department__c = mapvDepartment.Id,
            MAPV_Group__c = mapvGroup.Id,
            Company__c = company.Id
            ));
            insert roleMatrix;
            
            Role_Matrix_Prima_SG__c rmpsg = new Role_Matrix_Prima_SG__c(
            Role_Matrix__c = roleMatrix.Id,
            Prima_Security_Group__c = primaSecurityGroup.Id
            );
            insert rmpsg;
        }
        
        System.runAs(manager){
                User_Entry__c userEntry = TestDataService.createUserEntry(new User_Entry__c(
                Resource_Manager__c = manager.Id,
                Company__c = company.Id, 
                MAPV_Department__c = mapvDepartment.Id, 
                MAPV_Group__c = mapvGroup.Id, 
                Primary_Job_Role__c = jobRole.Id
            ));
            insert userEntry;
        }
    }

    @isTest
    static void testValidateUserPrimaRolesOnDelete() {
        User_Entry__c userEntry = [SELECT Id FROM User_Entry__c LIMIT 1];
        User manager = [SELECT Id FROM User WHERE Username = 'test.manager.ext@bayer.com'];

        Prima_Role__c primaRole = TestDataService.getDefaultPrimaRole();
        insert primaRole;

        User_Prima_Role__c userPrimaRole = new User_Prima_Role__c(
            User_Entry__c = userEntry.Id,
            Prima_Role__c = primaRole.Id,
            Status__c = 'Assigned'
        );
        insert userPrimaRole;

        Test.startTest();

        System.runAs(manager) {
            try {
                delete userPrimaRole;
            } catch (Exception e) {
                System.assertEquals(true, e != null, 'Exception should be thrown.');
                System.assertEquals(true, e.getMessage().contains(Label.UserPrimaRoleCannotBeDeleted), 'Exception should be thrown.');
            }
        }

        Test.stopTest();
    }
}