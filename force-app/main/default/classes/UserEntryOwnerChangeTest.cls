@isTest
private class UserEntryOwnerChangeTest {

    @TestSetup
    private static void setupTestData(){
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

        MAPV_Department__c mapvDepartment = TestDataService.getDefaultMapvDepartment();
        MAPV_Group__c mapvGroup = TestDataService.getDefaultMapvGroup();
        Job_Role__c jobRole = TestDataService.getDefaultJobRole();
        Prima_Role__c primaRole = TestDataService.getDefaultPrimaRole();
        Prima_Security_Group__c primaSecurityGroup = TestDataService.getDefaultPrimaSecurityGroup();
        
        System.runAs(applicationAdmin){
            insert mapvDepartment;
            insert mapvGroup;
            insert jobRole;
            insert primaRole;
            insert primaSecurityGroup;
        }
        

        System.runAs(applicationAdmin){
            Role_Matrix__c roleMatrix = TestDataService.createRoleMatrix(new Role_Matrix__c(
            Job_Role__c = jobRole.Id,
            MAPV_Department__c = mapvDepartment.Id,
            MAPV_Group__c = mapvGroup.Id
            ));
            insert roleMatrix;
            
            Role_Matrix_Prima_Role__c rmpr = new Role_Matrix_Prima_Role__c(
            Role_Matrix__c = roleMatrix.Id,
            Prima_Role__c = primaRole.Id
            );
            insert rmpr;
        }
        System.runAs(manager){    
            User_Entry__c userEntry = TestDataService.createUserEntry(new User_Entry__c(
                Resource_Manager__c = manager.Id, 
                MAPV_Department__c = mapvDepartment.Id, 
                MAPV_Group__c = mapvGroup.Id, 
                Primary_Job_Role__c = jobRole.Id,
                CWID__c = 'MMBBB'
            ));
            insert userEntry;
        }
    }

    @isTest
    public static void testChangeOwners() {
        User manager = [SELECT Id FROM User WHERE Username = 'test.manager.ext@bayer.com'];
        User endUser = [SELECT Id FROM User WHERE Username = 'test.end.user.ext@bayer.com'];
        List<UserEntryOwnerChange.OwnerChangeRequest> requests = new List<UserEntryOwnerChange.OwnerChangeRequest>();
        for(User_Entry__c userEntry : [SELECT Id FROM User_Entry__c]){
            UserEntryOwnerChange.OwnerChangeRequest request = new UserEntryOwnerChange.OwnerChangeRequest();
            request.userEntryId = userEntry.Id;
            request.ownerId = endUser.Id;
            requests.add(request);
        }

        Test.startTest();

        System.runAs(manager){
            UserEntryOwnerChange.changeOwners(requests);
        }

        Test.stopTest();

        for(User_Entry__c userEntry : [SELECT Id, OwnerId FROM User_Entry__c]){
            System.assertEquals(endUser.Id, userEntry.OwnerId);
        }
    }
}