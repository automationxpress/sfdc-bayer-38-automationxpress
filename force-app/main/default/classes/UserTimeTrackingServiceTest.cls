//Test class to cover UserTimeTrackingService class
@isTest
public class UserTimeTrackingServiceTest {
    
    @Testsetup
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
        
        MyLearning_Program__c myLearningProgram = TestDataService.getDefaultMyLearningProgram();
        insert myLearningProgram;
        
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
        
        
        Role_Matrix_ML__c rmmlp = new Role_Matrix_ML__c(
            Role_Matrix__c = roleMatrix.Id,
            MyLearning_Program__c = myLearningProgram.Id
        );
        insert rmmlp;
        
        User_Entry__c userEntryCreate = TestDataService.createUserEntry(new User_Entry__c(
            Resource_Manager__c = manager.Id,
            MAPV_Department__c = mapvDepartment.Id, 
            MAPV_Group__c = mapvGroup.Id, 
            Primary_Job_Role__c = jobRole.Id,
            Staff_Status__c='Current',
            Time_Tracking_Required__c='Required'
        ));
        insert userEntryCreate;
        system.debug(userEntryCreate);
        
        insert new User_MyLearning_Program__c(
            User_Entry__c = userEntryCreate.Id,
            MyLearning_Program__c = myLearningProgram.Id,
            Status__c = UserEntryData.STATUS_ASSIGNED
        );
        insert new User_Prima_Role__c(
            User_Entry__c = userEntryCreate.Id,
            Prima_Role__c = primaRole.Id,
            Status__c = UserEntryData.STATUS_ASSIGNED
        );
        insert new User_Prima_Security_Group__c(
            User_Entry__c = userEntryCreate.Id,
            Prima_Security_Group__c = primaSecurityGroup.Id,
            Status__c = UserEntryData.STATUS_ASSIGNED
        );
        
        
    }
    //End
    
    //Test Case for Create User Time Tracking Record on User Entry Create
    @isTest
    private static void testpopulateUserTimeTrackingsOnUserEntryCreate(){
        User_Entry__c ue = [SELECT Id, Name, Is_Locked__c, Approval_Status__c, Staff_Status__c, Primary_Job_Role__c, Primary_Job_Role__r.Name,
                             Time_Tracking_Required__c
                            FROM User_Entry__c LIMIT 1];
        Map<id,User_Entry__c> newUserEntries = new Map<id,User_Entry__c>();
        newUserEntries.put(ue.id,ue);
        UserTimeTrackingService.populateUserTimeTrackingsOnUserEntryCreate(newUserEntries);
        List<User_Time_Tracking__c> test1  = [select id, Name,Status__c from User_Time_Tracking__c where User_Entry__r.id=:ue.Id];
        system.Assert(test1.size()>0);
        system.assertEquals(True, test1.size()>0, 'User Time Tracking Record created Succesfully ');
    }
    
    
    //Test Case-1 for Update User Time Tracking.
    @isTest
    private static void testpopulateUserTimeTrackingsOnUserEntryUpdate(){
        User_Entry__c ue1 = [SELECT Id, Name, Is_Locked__c, Approval_Status__c, Staff_Status__c, Primary_Job_Role__c, Primary_Job_Role__r.Name,
                              Time_Tracking_Required__c
                            FROM User_Entry__c LIMIT 1];
        User_Entry__c ue = TestDataService.createUserEntry(new User_Entry__c(
            Id=ue1.Id,
            Staff_Status__c='Current',
            Time_Tracking_Required__c='Update Existing'
        ));
        Map<id,User_Entry__c> newUserEntries = new Map<id,User_Entry__c>();
        newUserEntries.put(ue.id,ue);
        UserTimeTrackingService.populateUserTimeTrackingsOnUserEntryCreate(newUserEntries);
        
        User_Entry__c userEntry1Update = TestDataService.createUserEntry(new User_Entry__c(
            Id=ue.Id,
            Staff_Status__c='Long-Term Leave',
            Time_Tracking_Required__c='Required'
        ));
        update userEntry1Update;
        
        
        Map<id,User_Entry__c> newUser1Entries = new Map<id,User_Entry__c>();
        newUser1Entries.put(userEntry1Update.id,userEntry1Update);
        UserTimeTrackingService.populateUserTimeTrackingsOnUserEntryUpdate(newUser1Entries,newUserEntries);
        List<User_Time_Tracking__c> test1  = [select id, Name,Status__c from User_Time_Tracking__c where User_Entry__r.id=:ue.Id];
        System.assertEquals('Assign', test1[0].Status__c);
        
        User_Entry__c userEntry2Update = TestDataService.createUserEntry(new User_Entry__c(
            Id=ue.Id,
            Staff_Status__c='Current',
            Time_Tracking_Required__c='Required'
        ));
        update userEntry2Update;
        
        
        Map<id,User_Entry__c> newUser2Entries = new Map<id,User_Entry__c>();
        newUser2Entries.put(userEntry2Update.id,userEntry2Update);
        UserTimeTrackingService.populateUserTimeTrackingsOnUserEntryUpdate(newUser2Entries,newUser1Entries);
        List<User_Time_Tracking__c> test2  = [select id, Name,Status__c from User_Time_Tracking__c where User_Entry__r.id=:ue.Id];
        System.assertEquals('Assign', test2[0].Status__c);
        
        User_Entry__c userEntry3Update = TestDataService.createUserEntry(new User_Entry__c(
            Id=ue.Id,
            Staff_Status__c='Current',
            Time_Tracking_Required__c='Not Required'
        ));
        update userEntry3Update;
        
        Map<id,User_Entry__c> newUser3Entries = new Map<id,User_Entry__c>();
        newUser3Entries.put(userEntry3Update.id,userEntry3Update);
        UserTimeTrackingService.populateUserTimeTrackingsOnUserEntryUpdate(newUser3Entries,newUserEntries);
        List<User_Time_Tracking__c> test3  = [select id, Name,Status__c from User_Time_Tracking__c where User_Entry__r.id=:ue.Id];
        System.assertEquals(True, test3.size()==0);
        
        
        
    }
    //Test Case-2 for Update User Time Tracking.
    @isTest
    private static void test1populateUserTimeTrackingsOnUserEntryUpdate(){
        User_Entry__c ue = [SELECT Id, Name, Is_Locked__c, Approval_Status__c, Staff_Status__c, Primary_Job_Role__c, Primary_Job_Role__r.Name,
                              Time_Tracking_Required__c
                            FROM User_Entry__c LIMIT 1];
        User_Entry__c userEntry1Update = TestDataService.createUserEntry(new User_Entry__c(
            Id=ue.Id,
            Staff_Status__c='Long-Term Leave',
            Time_Tracking_Required__c='Required'
        ));
        update userEntry1Update;
        Map<id,User_Entry__c> newUser1Entries = new Map<id,User_Entry__c>();
        newUser1Entries.put(userEntry1Update.id,userEntry1Update);
        
        User_Entry__c userEntry4Update = TestDataService.createUserEntry(new User_Entry__c(
            Id=ue.Id,
            Staff_Status__c='Current',
            Time_Tracking_Required__c='Update Existing'
        ));
        update userEntry4Update;
        Map<id,User_Entry__c> newUser4Entries = new Map<id,User_Entry__c>();
        newUser4Entries.put(userEntry4Update.id,userEntry4Update);
        UserTimeTrackingService.populateUserTimeTrackingsOnUserEntryUpdate(newUser4Entries,newUser1Entries);
        
        List<User_Time_Tracking__c> test1  = [select id, Name,Status__c from User_Time_Tracking__c where User_Entry__r.id=:ue.Id];
        System.assertEquals('Assign', test1[0].Status__c);
        
        User_Entry__c userEntry5Update = TestDataService.createUserEntry(new User_Entry__c(
            Id=ue.Id,
            Staff_Status__c='Long-Term Leave',
            Time_Tracking_Required__c='Update Existing'
        ));
        update userEntry5Update;
        Map<id,User_Entry__c> newUser5Entries = new Map<id,User_Entry__c>();
        newUser5Entries.put(userEntry5Update.id,userEntry5Update);
        
        User_Entry__c userEntry6Update = TestDataService.createUserEntry(new User_Entry__c(
            Id=ue.Id,
            Staff_Status__c='Current',
            Time_Tracking_Required__c='Required'
        ));
        update userEntry6Update;
        Map<id,User_Entry__c> newUser6Entries = new Map<id,User_Entry__c>();
        newUser6Entries.put(userEntry6Update.id,userEntry6Update);
        UserTimeTrackingService.populateUserTimeTrackingsOnUserEntryUpdate(newUser6Entries,newUser5Entries);
        List<User_Time_Tracking__c> test2  = [select id, Name,Status__c from User_Time_Tracking__c where User_Entry__r.id=:ue.Id];
        System.assertEquals('Assign', test2[0].Status__c);
        
        
        User_Entry__c userEntry7Update = TestDataService.createUserEntry(new User_Entry__c(
            Id=ue.Id,
            Staff_Status__c='Long-Term Leave',
            Time_Tracking_Required__c='Not Required'
        ));
        update userEntry7Update;
        Map<id,User_Entry__c> newUser7Entries = new Map<id,User_Entry__c>();
        newUser7Entries.put(userEntry7Update.id,userEntry7Update);
        
        UserTimeTrackingService.populateUserTimeTrackingsOnUserEntryUpdate(newUser6Entries,newUser7Entries);
        User_Entry__c userEntry8Update = TestDataService.createUserEntry(new User_Entry__c(
            Id=ue.Id,
            Staff_Status__c='Current',
            Time_Tracking_Required__c='Not Required'
        ));
        update userEntry8Update;
        Map<id,User_Entry__c> newUser8Entries = new Map<id,User_Entry__c>();
        newUser8Entries.put(userEntry8Update.id,userEntry8Update);
        
        UserTimeTrackingService.populateUserTimeTrackingsOnUserEntryUpdate(newUser6Entries,newUser8Entries);
        List<User_Time_Tracking__c> test3  = [select id, Name,Status__c from User_Time_Tracking__c where User_Entry__r.id=:ue.Id];
        System.assertEquals('Assign', test3[0].Status__c);
    }
    
}