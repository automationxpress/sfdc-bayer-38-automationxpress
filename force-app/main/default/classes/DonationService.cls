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
            Map<String, Schema.SObjectField> donationSchema = Schema.Donation__c.SObjectType.getDescribe().fields.getMap();
            
            //Track Status__c field
            if (newDonation.Status__c != oldDonationMap.get(newDonation.Id).Status__c){
                Schema.DescribeFieldResult statusDescription = donationSchema.get('Status__c').getDescribe();
                addRecordHstoryList(recordHistoryList, statusDescription.getLabel(), oldDonationMap.get(newDonation.Id).Status__c, newDonation.Status__c, newDonation.Id);
            }
            //Track Overall_Net_Amount__c field
            if (newDonation.Overall_Net_Amount__c != oldDonationMap.get(newDonation.Id).Overall_Net_Amount__c){
                Schema.DescribeFieldResult overallNetAmountDescription = donationSchema.get('Overall_Net_Amount__c').getDescribe();
                addRecordHstoryList(recordHistoryList, overallNetAmountDescription.getLabel(), String.valueOf(oldDonationMap.get(newDonation.Id).Overall_Net_Amount__c)+'€', String.valueOf(newDonation.Overall_Net_Amount__c)+'€', newDonation.Id);
            }
      
            //Track Organization_Type__c field
            if (newDonation.Organization_Type__c != oldDonationMap.get(newDonation.Id).Organization_Type__c){
                Schema.DescribeFieldResult organizationTypeDescription = donationSchema.get('Organization_Type__c').getDescribe();
                addRecordHstoryList(recordHistoryList, organizationTypeDescription.getLabel(), oldDonationMap.get(newDonation.Id).Organization_Type__c, newDonation.Organization_Type__c, newDonation.Id);
            }
            //Track Focus_Area__c field
            if (newDonation.Focus_Area__c != oldDonationMap.get(newDonation.Id).Focus_Area__c){
                 Schema.DescribeFieldResult focusAreaDescription = donationSchema.get('Focus_Area__c').getDescribe();
                addRecordHstoryList(recordHistoryList, focusAreaDescription.getLabel(), oldDonationMap.get(newDonation.Id).Focus_Area__c, newDonation.Focus_Area__c, newDonation.Id);
            }
            //Track Salutation__c field
            if (newDonation.Salutation__c != oldDonationMap.get(newDonation.Id).Salutation__c){
                 Schema.DescribeFieldResult salutationDescription = donationSchema.get('Salutation__c').getDescribe();
                addRecordHstoryList(recordHistoryList,salutationDescription.getLabel(), oldDonationMap.get(newDonation.Id).Salutation__c, newDonation.Salutation__c, newDonation.Id);
            }
            //Track Contact_First_Name__c field
            if (newDonation.Contact_First_Name__c != oldDonationMap.get(newDonation.Id).Contact_First_Name__c){
                Schema.DescribeFieldResult firstNameDescription = donationSchema.get('Contact_First_Name__c').getDescribe();
                addRecordHstoryList(recordHistoryList, firstNameDescription.getLabel(), oldDonationMap.get(newDonation.Id).Contact_First_Name__c, newDonation.Contact_First_Name__c, newDonation.Id);
            }
            //Track Contact_Last_Name__c field
            if (newDonation.Contact_Last_Name__c != oldDonationMap.get(newDonation.Id).Contact_Last_Name__c){
                Schema.DescribeFieldResult lastNameDescription = donationSchema.get('Contact_Last_Name__c').getDescribe();
                addRecordHstoryList(recordHistoryList, lastNameDescription.getLabel(), oldDonationMap.get(newDonation.Id).Contact_Last_Name__c, newDonation.Contact_Last_Name__c, newDonation.Id);
            }
            //Track Contact_Email__c field
            if (newDonation.Contact_Email__c != oldDonationMap.get(newDonation.Id).Contact_Email__c){
                Schema.DescribeFieldResult emailDescription = donationSchema.get('Contact_Email__c').getDescribe();
                addRecordHstoryList(recordHistoryList, emailDescription.getLabel(), oldDonationMap.get(newDonation.Id).Contact_Email__c, newDonation.Contact_Email__c, newDonation.Id);
            }
            //Track Bank__c field
            if (newDonation.Bank__c != oldDonationMap.get(newDonation.Id).Bank__c){
                Schema.DescribeFieldResult bankDescription = donationSchema.get('Bank__c').getDescribe();
                addRecordHstoryList(recordHistoryList, bankDescription.getLabel(), oldDonationMap.get(newDonation.Id).Bank__c, newDonation.Bank__c, newDonation.Id);
            }
            //Track IBAN__c field
            if (newDonation.IBAN__c != oldDonationMap.get(newDonation.Id).IBAN__c){
                Schema.DescribeFieldResult ibanDescription = donationSchema.get('IBAN__c').getDescribe();
                addRecordHstoryList(recordHistoryList, ibanDescription.getLabel(), oldDonationMap.get(newDonation.Id).IBAN__c, newDonation.IBAN__c, newDonation.Id);
            }
            //Track Requestor__c field
            if (newDonation.Requestor__c != oldDonationMap.get(newDonation.Id).Requestor__c){
                Schema.DescribeFieldResult requestorDescription = donationSchema.get('Requestor__c').getDescribe();
                addRecordHstoryList(recordHistoryList, requestorDescription.getLabel(), UserUtils.getUserById(oldDonationMap.get(newDonation.Id).Requestor__c)?.Name , UserUtils.getUserById(newDonation.Requestor__c)?.Name, newDonation.Id);
            }
            //Track Business_Unit__c field
            if (newDonation.Business_Unit__c != oldDonationMap.get(newDonation.Id).Business_Unit__c){
                Schema.DescribeFieldResult businessUnitDescription = donationSchema.get('Business_Unit__c').getDescribe();
                addRecordHstoryList(recordHistoryList, businessUnitDescription.getLabel(), oldDonationMap.get(newDonation.Id).Business_Unit__c, newDonation.Business_Unit__c, newDonation.Id);
            }
            //Track Origin_of_Funding__c field
            if (newDonation.Origin_of_Funding__c != oldDonationMap.get(newDonation.Id).Origin_of_Funding__c){
                Schema.DescribeFieldResult originofFundingDescription = donationSchema.get('Origin_of_Funding__c').getDescribe();
                addRecordHstoryList(recordHistoryList, originofFundingDescription.getLabel(), oldDonationMap.get(newDonation.Id).Origin_of_Funding__c, newDonation.Origin_of_Funding__c, newDonation.Id);
            }
            //Track Tax_ID_Number__c field
            if (newDonation.Tax_ID_Number__c != oldDonationMap.get(newDonation.Id).Tax_ID_Number__c){
                Schema.DescribeFieldResult taxIDNumberDescription = donationSchema.get('Tax_ID_Number__c').getDescribe();
                addRecordHstoryList(recordHistoryList, taxIDNumberDescription.getLabel(), oldDonationMap.get(newDonation.Id).Tax_ID_Number__c, newDonation.Tax_ID_Number__c, newDonation.Id);
            }
            //Track Address__c field
            if (newDonation.Address__c != oldDonationMap.get(newDonation.Id).Address__c){
                Schema.DescribeFieldResult addressDescription = donationSchema.get('Address__c').getDescribe();
                String richTextNewAddress= newDonation.Address__c;
                String richTextOldAddress= oldDonationMap.get(newDonation.Id).Address__c;
                if(oldDonationMap.get(newDonation.Id).Address__c==null){
                    addRecordHstoryList(recordHistoryList, addressDescription.getLabel(), oldDonationMap.get(newDonation.Id).Address__c, richTextNewAddress.replace('<br>', ' ,'), newDonation.Id);
                    
                }
                else{
                    addRecordHstoryList(recordHistoryList, addressDescription.getLabel(), richTextOldAddress.replace('<br>', ' ,'), richTextNewAddress.replace('<br>', ' ,'), newDonation.Id);
                }
            }
            //Track Account_Name__c field
            if (newDonation.Account_Name__c != oldDonationMap.get(newDonation.Id).Account_Name__c){
                Schema.DescribeFieldResult accountNameDescription = donationSchema.get('Account_Name__c').getDescribe();
                addRecordHstoryList(recordHistoryList, accountNameDescription.getLabel(), oldDonationMap.get(newDonation.Id).Account_Name__c, newDonation.Account_Name__c, newDonation.Id);
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