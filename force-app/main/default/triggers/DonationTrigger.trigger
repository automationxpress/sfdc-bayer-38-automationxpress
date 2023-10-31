trigger DonationTrigger on Donation__c (after update) {
   new DonationTriggerhandler().run();
}