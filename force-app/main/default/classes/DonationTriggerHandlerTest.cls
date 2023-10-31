@isTest
public class DonationTriggerHandlerTest {
    @TestSetup
    static void setupTestData() {
        
        Account acc= TestDataService.getDefaultAccount();
        
        User requestor = TestDataService.getDefaultUser();
        
        Donation__c oldDonation = new Donation__c(
            Status__c = 'Draft',
            Focus_Area__c = 'Waste Management',
            Salutation__c = 'Mr.',
            Account__c= acc.id,
            Requestor__c = requestor.id,
            Overall_Net_Amount__c=5100,
            Organization_Type__c='Agency',
            Contact_First_Name__c='test',
            Contact_Last_Name__c='ing',
            Contact_Email__c='test@gmail.com',
            Bank__c='icic',
            IBAN__c='hhh',
            Business_Unit__c='BV-PH-VU'
        );
        insert oldDonation;
    }
    
    @isTest
    static void testMultipleFieldsUpdate(){
        Donation__c oldDonation = [SELECT Id, Name, Account__c, Contact_Email__c, Contact_First_Name__c, Contact_Last_Name__c, Status__c, Salutation__c, Requestor__c, Overall_Net_Amount__c, Organization_Type__c, Bank__c, IBAN__c, Business_Unit__c, Focus_Area__c FROM Donation__c LIMIT 1 ];
        Account accNew= TestDataService.getDefaultAccount();
        accNew.Name = 'Bayer - Donation';
        insert accNew;
        
        Profile platformEndUserProfile = UserUtils.getPlatformEndUserProfile();
        User requestor = TestDataService.createUser(new User(
            Username = 'test.requestor.ext@bayer.com',
            ProfileId = platformEndUserProfile.Id,
            FederationIdentifier = 'ADCBA'
        ));
        insert requestor;
        
        Donation__c newDonation = new Donation__c(
            id = oldDonation.id,
            Status__c = 'Approved',
            Focus_Area__c = 'Water Management',
            Salutation__c = 'Mrs.',
            Account__c= accNew.id,
            Requestor__c = requestor.id,
            Overall_Net_Amount__c= 50000,
            Organization_Type__c='HCO',
            Contact_First_Name__c='Test Donation',
            Contact_Last_Name__c='Contact',
            Contact_Email__c='TestContact@example.com',
            Bank__c='WBO',
            IBAN__c='23456',
            Business_Unit__c='BV-PH-GUOP'
        );
        update newDonation;
        
        List<Record_History__c> recordHistoryList = [SELECT Action__c, Field__c, Original_Value__c, New_Value__c,Donation__c FROM Record_History__c where Donation__c=:newDonation.Id];
        System.assertEquals(13, recordHistoryList.size(), 'Expected 13 Record_History__c records to be created for 13 field updates.');
        
    }
    
    
}