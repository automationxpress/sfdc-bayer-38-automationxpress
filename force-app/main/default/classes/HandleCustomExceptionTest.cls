@isTest
public class HandleCustomExceptionTest {
    @isTest
    public static void testExceptionLogging() {
        Profile p = UserUtils.getPlatformEndUserProfile();

        User u = TestDataService.getDefaultUser();
        u.ProfileId = p.Id;
        insert u;

        System.runAs(u) {
            try {
                insert new Account();
            } catch (Exception e) {
                HandleCustomException.LogException(e);
                List<Custom_Exception__c> resultExceptions = [SELECT Id FROM Custom_Exception__c];

                System.assertEquals(true, e != null, 'Exception should be thrown.');
                System.assertEquals(true, resultExceptions.size() > 0, 'Exception should be logged as a custom object record.');
            }
        }
    } 
}