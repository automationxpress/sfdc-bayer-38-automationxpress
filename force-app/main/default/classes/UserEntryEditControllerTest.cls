@isTest
private class UserEntryEditControllerTest {
    @TestSetup
    private static void setupTestData() {

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
        
        MyLearning_Program__c mlp1 = TestDataService.getDefaultMyLearningProgram();
        mlp1.Name = 'Test ML Program2';
        mlp1.ID__c = 'PH_RD_CUR_141';
        insert mlp1;

        Role_Matrix_ML__c rmmlp = new Role_Matrix_ML__c(
            Role_Matrix__c = roleMatrix.Id,
            MyLearning_Program__c = mlp1.Id
        );
        insert rmmlp;
        
        Prima_Role__c pr1 = TestDataService.getDefaultPrimaRole();
        pr1.Name = 'Test Prima Role1';
        insert pr1;
        
        Role_Matrix_Prima_Role__c rmpr1 = new Role_Matrix_Prima_Role__c(
            Role_Matrix__c = roleMatrix.Id,
            Prima_Role__c = pr1.Id
        );
        insert rmpr1;
        
        Prima_Security_Group__c psg1 = TestDataService.getDefaultPrimaSecurityGroup();
        psg1.Name = 'Test Prima Security Group1';
        insert psg1;
        
        Role_Matrix_Prima_SG__c rmprsg1 = new Role_Matrix_Prima_SG__c(
            Role_Matrix__c = roleMatrix.Id,
            Prima_Security_Group__c = psg1.Id
        );
        insert rmprsg1;
        
        Profile endUserProfile = UserUtils.getPlatformEndUserProfile();
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        List<User> users = new List<User>();

        User u = TestDataService.getDefaultUser();
        //u.ProfileId = endUserProfile.Id;
        //users.add(u);

        User u2 = TestDataService.getDefaultUser();
        u2.Username = 'resmgr1@example.com.bayer';
        u2.Email = 'testuser1@example.com';
        u2.ProfileId = adminProfile.Id;
        users.add(u2);

        insert users;
        
        User_Entry__c ue = (User_Entry__c) TestDataService.createUserEntry(new User_Entry__c(
                Primary_Job_Role__c = roleMatrix.Job_Role__c,
                MAPV_Department__c = roleMatrix.MAPV_Department__c,
                MAPV_Group__c = roleMatrix.MAPV_Group__c,
                Uma_Company__c = roleMatrix.Uma_Company__c,
                Resource_Manager__c = u2.Id
                ));
        insert ue;
        
        MyLearning_Program__c mlp = TestDataService.getDefaultMyLearningProgram();
        mlp.ID__c = 'PH_RD_CUR_140';
        insert mlp;

        User_MyLearning_Program__c umlp = new User_MyLearning_Program__c(
            User_Entry__c = ue.Id,
            MyLearning_Program__c = mlp.Id,
            Status__c = 'Assign'
        );
        insert umlp;
        
        Job_Role__c additionJobRole1 = new Job_Role__c(
            Name = 'Test Additional Job Role1',
            Main_Role_Add_on__c = JobRoleUtils.ROLE_Add_ON
        );
        insert additionJobRole1;
    
        User_Additional_Role__c uar1 = new User_Additional_Role__c(
            User_Entry__c = ue.Id,
            Job_Role__c = additionJobRole1.Id
        );
        insert uar1;
        
      }
    
    @isTest
    static void testGetUserEntryData() {
        User_Entry__c ue = [SELECT Id, Name, Is_Locked__c, Approval_Status__c, Staff_Status__c, Primary_Job_Role__c, Primary_Job_Role__r.Name, 
                       MAPV_Department__c, MAPV_Department__r.Name, MAPV_Group__c, MAPV_Group__r.Name, Uma_Company__c,
                       Resource_Manager__c, Deputy_Manager__c,Locations__c,
                        (SELECT Id, MyLearning_Program__c, MyLearning_Program__r.Name, Status__c FROM User_MyLearning_Programs__r),
                        (SELECT Id, Prima_Role__c, Prima_Role__r.Name, Status__c FROM User_Prima_Roles__r),
                        (SELECT Id, Prima_Security_Group__c, Prima_Security_Group__r.Name, Status__c FROM User_Prima_Security_Groups__r),
                        (SELECT Id, Job_Role__c, Job_Role__r.Name FROM User_Additional_Roles__r)
                        FROM User_Entry__c Limit 1];
        

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
        
        UserEntryData ueData = UserEntryEditController.getUserEntryData(ue.Id);
        system.assertEquals(true, ueData.userEntryId!=null);
        UserEntryData refreshedUEData = UserEntryEditController.refreshRoleMatricesData(ueData);
        ueData.primaryJobRole = ueData.primaryJobRoleId;
        
        User_MyLearning_Program__c u_ML = [SELECT Id, Status__c,User_Entry__c FROM User_MyLearning_Program__c where User_Entry__c=: ue.Id];
        u_ML.Status__c = 'Assign';
        update u_ML;
        
        
        Job_Role__c additionJobRole = new Job_Role__c(
            Name = 'Test Additional Job Role',
            Main_Role_Add_on__c = JobRoleUtils.ROLE_Add_ON
        );
        insert additionJobRole;
    
        User_Additional_Role__c uar = new User_Additional_Role__c(
            User_Entry__c = ue.Id,
            Job_Role__c = additionJobRole.Id
        );
        insert uar;
        
        UserEntryEditController.saveUserEntryData(ueData);
       
        
    }
    
    @isTest
    static void testGetLocationOptions(){
        List<String> locationNames = UserEntryEditController.getLocationOptions('Iran');
        System.assertEquals(true, locationNames.contains('Iran'));
    }
   
    @isTest
    static void testGetJobRoleRecords(){
        System.assertEquals(true, UserEntryEditController.getJobRoleRecords('','Test').size()>0);
        JobRoleUtils.getJobRole(UserEntryEditController.getJobRoleRecords('','Test')[0].recordId);
    }
    
    @isTest
    static void testSubmitForApproval(){
        User_Entry__c userEntry = [SELECT Id, Is_Bayer_User__c FROM User_Entry__c Limit 1];
        
        Test.startTest();

        UserEntryEditController.submitForApproval(userEntry.Id);
        
        Test.stopTest();
        
        List<ProcessInstance> ap = [SELECT Id, Status FROM ProcessInstance WHERE TargetObjectId = :userEntry.Id];
        System.assertEquals(1, ap.size());
        if(userEntry.Is_Bayer_User__c){
            System.assertEquals('Approved', ap[0].Status);
        } else {
            System.assertEquals('Pending', ap[0].Status);
        } 
    }
    
     @isTest
    static void testSaveUserEntryData(){
        List<String> locationNames = UserEntryEditController.getLocationOptions('Iran');
        System.assertEquals(true, locationNames.contains('Iran'));
    }
    
     @isTest
    static void testGetAllRecords(){
        List<MAPV_Department__c> allRecords = UserEntryEditController.getAllRecords('MAPV_Department__c');
        System.assertEquals(true, allRecords.size()>0);
    }

}