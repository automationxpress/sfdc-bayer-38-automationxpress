/**********************************************************
*  DonationService
* 
*  Created Date: - 10/30/2023
* 
*  Description: Service class for Donation
*  
* *********************************************************/
public class DonationService {
	public static final String ACTION_FIELD_UPDATE = 'Field Updated';    
    
    public static void createRecordHistoryOnDonationUpdate(Map<Id, Donation__c> newDonations, Map<Id, Donation__c> oldDonationMap){
        List<Record_History__c> recordHistoryList = new List<Record_History__c>();
        for (Donation__c newDonation :newDonations.values()) {
            
            //Track Status__c field
            if (newDonation.Status__c != oldDonationMap.get(newDonation.Id).Status__c){
                addRecordHstoryList(recordHistoryList, 'Status', oldDonationMap.get(newDonation.Id).Status__c, newDonation.Status__c, newDonation.Id);
            }
            //Track Overall_Net_Amount__c field
            if (newDonation.Overall_Net_Amount__c != oldDonationMap.get(newDonation.Id).Overall_Net_Amount__c){
                addRecordHstoryList(recordHistoryList, 'Overall NetAmount', String.valueOf(oldDonationMap.get(newDonation.Id).Overall_Net_Amount__c)+'€', String.valueOf(newDonation.Overall_Net_Amount__c)+'€', newDonation.Id);
            }
            //Track Organization_Type__c field
            if (newDonation.Organization_Type__c != oldDonationMap.get(newDonation.Id).Organization_Type__c){
                addRecordHstoryList(recordHistoryList, 'Organization Type', oldDonationMap.get(newDonation.Id).Organization_Type__c, newDonation.Organization_Type__c, newDonation.Id);
            }
            //Track Focus_Area__c field
            if (newDonation.Focus_Area__c != oldDonationMap.get(newDonation.Id).Focus_Area__c){
                addRecordHstoryList(recordHistoryList, 'Focus Area', oldDonationMap.get(newDonation.Id).Focus_Area__c, newDonation.Focus_Area__c, newDonation.Id);
            }
            //Track Salutation__c field
            if (newDonation.Salutation__c != oldDonationMap.get(newDonation.Id).Salutation__c){
                addRecordHstoryList(recordHistoryList, 'Salutation', oldDonationMap.get(newDonation.Id).Salutation__c, newDonation.Salutation__c, newDonation.Id);
            }
            //Track Contact_First_Name__c field
           if (newDonation.Contact_First_Name__c != oldDonationMap.get(newDonation.Id).Contact_First_Name__c){
                addRecordHstoryList(recordHistoryList, 'Contact FirstName', oldDonationMap.get(newDonation.Id).Contact_First_Name__c, newDonation.Contact_First_Name__c, newDonation.Id);
            }
            //Track Contact_Last_Name__c field
            if (newDonation.Contact_Last_Name__c != oldDonationMap.get(newDonation.Id).Contact_Last_Name__c){
                addRecordHstoryList(recordHistoryList, 'Contact LastName', oldDonationMap.get(newDonation.Id).Contact_Last_Name__c, newDonation.Contact_Last_Name__c, newDonation.Id);
            }
            //Track Contact_Email__c field
            if (newDonation.Contact_Email__c != oldDonationMap.get(newDonation.Id).Contact_Email__c){
                addRecordHstoryList(recordHistoryList, 'Contact Email', oldDonationMap.get(newDonation.Id).Contact_Email__c, newDonation.Contact_Email__c, newDonation.Id);
            }
            //Track Bank__c field
            if (newDonation.Bank__c != oldDonationMap.get(newDonation.Id).Bank__c){
                addRecordHstoryList(recordHistoryList, 'Bank', oldDonationMap.get(newDonation.Id).Bank__c, newDonation.Bank__c, newDonation.Id);
            }
            //Track IBAN__c field
            if (newDonation.IBAN__c != oldDonationMap.get(newDonation.Id).IBAN__c){
                addRecordHstoryList(recordHistoryList, 'IBAN', oldDonationMap.get(newDonation.Id).IBAN__c, newDonation.IBAN__c, newDonation.Id);
            }
            //Track Requestor__c field
            if (newDonation.Requestor__c != oldDonationMap.get(newDonation.Id).Requestor__c){
                addRecordHstoryList(recordHistoryList, 'Requestor', UserUtils.getUserById(oldDonationMap.get(newDonation.Id).Requestor__c)?.Name , UserUtils.getUserById(newDonation.Requestor__c)?.Name, newDonation.Id);
            }
            //Track Account__c field
            if (newDonation.Account__c != oldDonationMap.get(newDonation.Id).Account__c){
                system.debug('@@DonationService.createRecordHistoryOnDonationUpdate> Account= '+ AccountUtils.getAccountById(oldDonationMap.get(newDonation.Id).Account__c));
                addRecordHstoryList(recordHistoryList, 'Account', AccountUtils.getAccountById(oldDonationMap.get(newDonation.Id).Account__c)?.Name , AccountUtils.getAccountById(newDonation.Account__c)?.Name, newDonation.Id);
            }
            //Track Business_Unit__c field
            if (newDonation.Business_Unit__c != oldDonationMap.get(newDonation.Id).Business_Unit__c){
                addRecordHstoryList(recordHistoryList, 'Business Unit', oldDonationMap.get(newDonation.Id).Business_Unit__c, newDonation.Business_Unit__c, newDonation.Id);
            }
           
        }
        
        system.debug('@@DonationService.createRecordHistoryOnDonationUpdate> recordHistoryList= '+ recordHistoryList);
        //Insert Record_History__c records related to Donation
         if (!recordHistoryList.isEmpty()) {
              insert recordHistoryList;
         }
        
    }
    
    //Adds a new record to a Record History list
    private static List<Record_History__c> addRecordHstoryList(List<Record_History__c> recordHistoryList, String fieldToTrack, String oldValue, String newValue, Id donationId){
        recordHistoryList.add(new Record_History__c(
                    Action__c = ACTION_FIELD_UPDATE, 
                    Field__c= fieldToTrack,
                    Original_Value__c = oldValue, 
                    New_Value__c = newValue,
                    User__c = UserInfo.getUserId(),
                    Date__c = System.now(),
                    Donation__c = donationId
                ));
        
         return recordHistoryList;
    }
    
  

 
    
}