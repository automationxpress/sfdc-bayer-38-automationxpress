//Test class to cover the UserTimeTrackingTriggerHandler
@isTest
private class UserTimeTrackingTriggerHandlerTest {
	@TestSetup
    private static void setupTestData(){

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
        
        Role_Matrix__c roleMatrix1 = [SELECT Id, Job_Role__c, MAPV_Department__c, MAPV_Group__c, Uma_Company__c FROM Role_Matrix__c LIMIT 1];
        Profile profileRecord = UserUtils.getPlatformEndUserProfile();
        User userRecord = TestDataService.getDefaultUser();
        userRecord.ProfileId = profileRecord.Id;
        insert userRecord;
        User_Entry__c userEntry = (User_Entry__c) TestDataService.createUserEntry(new User_Entry__c(
            CWID__c = 'ABCDE',
            Email__c = 'ABCDE.test@bayer.com',
            Primary_Job_Role__c = roleMatrix1.Job_Role__c,
            MAPV_Department__c = roleMatrix1.MAPV_Department__c,
            MAPV_Group__c = roleMatrix1.MAPV_Group__c,
            Uma_Company__c = roleMatrix1.Uma_Company__c,
            Resource_Manager__c = userRecord.Id
        ));
        insert userEntry;
    
    }
    
    //To test the afterUpdate trigger functionality of UserTT
    @IsTest
    static void updateUserTimeTrackingTest() {
        User_Entry__c userEntry = [SELECT Id, Staff_Status__c, Is_Locked__c FROM User_Entry__c LIMIT 1];
        userEntry.Is_Locked__c = true;
        Update userEntry;
        User_Time_Tracking__c userTTToCreate = (User_Time_Tracking__c) TestDataService.createUserTimeTracking(new User_Time_Tracking__c(
            User_Entry__c = userEntry.Id,
            Status__c = 'Assign',
            Name__c = 'User Time Tracking'
        ));
        
        insert userTTToCreate;
        
        User_Time_Tracking__c userTTToUpdate = [SELECT Id, User_Entry__c, Status__c, Staff_Status__c, Name__c FROM User_Time_Tracking__c LIMIT 1];
        if(userTTToUpdate!=null){
            userTTToUpdate.Status__c = 'Assigned';
        }
        
        Update userTTToUpdate;
        User_Entry__c userEntryRecord = [SELECT Id, Staff_Status__c, Is_Locked__c FROM User_Entry__c LIMIT 1];
        System.assertEquals(false, userEntryRecord.Is_Locked__c);
        
    }
    
    //To test the afterDelete trigger functionality of UserTT
    @IsTest
    static void deleteUserTimeTrackingTest() {
        User_Entry__c userEntry = [SELECT Id, Staff_Status__c, Is_Locked__c FROM User_Entry__c LIMIT 1];
        userEntry.Is_Locked__c = true;
        Update userEntry;
        User_Time_Tracking__c userTTToCreate = (User_Time_Tracking__c) TestDataService.createUserTimeTracking(new User_Time_Tracking__c(
            User_Entry__c = userEntry.Id,
            Status__c = 'Assign',
            Name__c = 'User Time Tracking'
        ));
        
        insert userTTToCreate;
        User_Time_Tracking__c userTTToUpdate = [SELECT Id, User_Entry__c, Status__c, Staff_Status__c, Name__c FROM User_Time_Tracking__c LIMIT 1];
        if(userTTToUpdate!=null){
            userTTToUpdate.Status__c = 'Remove';
        }
        Update userTTToUpdate;
        Delete userTTToUpdate;
        User_Entry__c userEntryRecord = [SELECT Id, Staff_Status__c, Is_Locked__c FROM User_Entry__c LIMIT 1];
        System.assertEquals(false, userEntryRecord.Is_Locked__c);
        
    }
}