@isTest
public class TestDataService {

    public static User getDefaultUser(){
        return new User(
            Username = 'testuser@example.com.bayer',
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Alias = 'test',
            TimeZoneSidKey = 'Europe/Berlin',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
    }

    public static User createUser(User prototype){
        User defaultUser = getDefaultUser();
        return (User) create(prototype, defaultUser);
    }

    public static Account getDefaultAccount(){
        return new Account(
            Name = 'Bayer'
        );
    }

    public static Account createAccount(Account prototype){
        Account defaultAccount = getDefaultAccount();
        return (Account) create(prototype, defaultAccount);
    }

    public static User_Entry__c getDefaultUserEntry(){
        return new User_Entry__c(
            First_Name__c = 'John',
            Last_Name__c = 'Test',
            Email__c = 'john.test@bayer.com',
            CWID__c = 'BYXXF',
            Staff_Status__c = UserEntryUtils.STAFF_STATUS_CURRENT,
            Locations__c = UserEntryUtils.LOCATION_GERMANY_BERLIN,
            Grant_access_to_UMA__c = UserEntryUtils.GRANT_ACCESS_TO_UMA_NO,
            Time_Tracking_Required__c = UserEntryUtils.TIME_TRACKING_NOT_REQUIRED
        );
    }

    public static User_Entry__c createUserEntry(User_Entry__c prototype){
        User_Entry__c defaultUserEntry = getDefaultUserEntry();
        return (User_Entry__c) create(prototype, defaultUserEntry);
    }

    public static Job_Role__c getDefaultJobRole(){
        return new Job_Role__c(
            Name = 'Test Job Role',
            Main_Role_Add_on__c = JobRoleUtils.ROLE_MAIN
        );
    }

    public static MAPV_Department__c getDefaultMapvDepartment(){
        return new MAPV_Department__c(
            Name = 'Test Department'
        );
    }

    public static MAPV_Group__c getDefaultMapvGroup(){
        return new MAPV_Group__c(
            Name = 'Test Group'
        );
    }

    public static MyLearning_Program__c getDefaultMyLearningProgram(){
        return new MyLearning_Program__c(
            Name = 'Test ML Program',
            ID__c = 'TEST_ML'
        );
    }

    public static MyLearning_Program__c createMyLearningProgram(MyLearning_Program__c prototype){
        MyLearning_Program__c defaultMyLearningProgram = getDefaultMyLearningProgram();
        return (MyLearning_Program__c) create(prototype, defaultMyLearningProgram);
    }

    public static Prima_Role__c getDefaultPrimaRole(){
        return new Prima_Role__c(
            Name = 'Test Prima Role'
        );
    }

    public static Prima_Security_Group__c getDefaultPrimaSecurityGroup(){
        return new Prima_Security_Group__c(
            Name = 'Test Prima Security Group'
        );
    }

    public static Role_Matrix__c getDefaultRoleMatrix(){
        return new Role_Matrix__c(
        	Role_Matrix_Type__c = '4-Criteria Role Matrix'
        );
    }

    public static Role_Matrix__c createRoleMatrix(Role_Matrix__c prototype){
        Role_Matrix__c defaultRoleMatrix = getDefaultRoleMatrix();
        return (Role_Matrix__c) create(prototype, defaultRoleMatrix);
    }
    
    public static User_Time_Tracking__c getDefaultUserTimeTracking(){
        return new User_Time_Tracking__c(
            Status__c = 'Assign',
            Name__c = 'User Time Tracking'
        );
    }
    
    public static User_Time_Tracking__c createUserTimeTracking(User_Time_Tracking__c prototype){
        User_Time_Tracking__c defaultUserTimeTracking = getDefaultUserTimeTracking();
        return (User_Time_Tracking__c) create(prototype, defaultUserTimeTracking);
    }
    
    public static User_MyLearning_Program__c getDefaultUserMyLearningProgram(){
        return new User_MyLearning_Program__c(
            Status__c = 'Assign'
        );
    }
    
    public static User_MyLearning_Program__c createUserMyLearningProgram(User_MyLearning_Program__c prototype){
        User_MyLearning_Program__c defaultUserMyLearningProgram = getDefaultUserMyLearningProgram();
        return (User_MyLearning_Program__c) create(prototype, defaultUserMyLearningProgram);
    }
    
    public static Role_Matrix_ML__c createRoleMatrixMyLearningProgram(Role_Matrix_ML__c rmmlp){
        return new Role_Matrix_ML__c(
            MyLearning_Program__c = rmmlp.MyLearning_Program__c,
            Role_Matrix__c = rmmlp.Role_Matrix__c
        );
    }

    private static SObject create(SObject prototype, SObject defaultObject){
        Map<String, Object> prototypeFields = prototype.getPopulatedFieldsAsMap();
        for(String fieldName : prototypeFields.keySet()){
            defaultObject.put(fieldName, prototypeFields.get(fieldName));
        }

        return defaultObject;
    }
}