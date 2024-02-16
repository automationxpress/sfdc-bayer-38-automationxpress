/**********************************************************
*  DonationTriggerHandler
* 
*  Created Date: - 10/30/2023
* 
*  Description: Hander class for Donation Trigger
*  
* *********************************************************/

public class DonationTriggerHandler extends TriggerHandler {
    
    //overrides the afterUpdate method to record RecordHistory related to Donations
     public override void afterUpdate(Map<Id, SObject> newRecords, Map<Id, SObject> oldRecords) {
        Map<Id, Donation__c> newDonations = (Map<Id, Donation__c>) newRecords;
        Map<Id, Donation__c> oldDonationMap = (Map<Id, Donation__c>) oldRecords;
        DonationService.createRecordHistoryOnDonationUpdate(newDonations,oldDonationMap );
system.debug('This is for testing github action files v1');
    }
    

}