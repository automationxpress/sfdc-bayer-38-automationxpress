public with sharing class UserEntryOwnerChange {
    //Calling from Flow 'Create or Update UMA User' to change the owner of User Entry record
    @InvocableMethod(label='Change Owner')
    public static void changeOwners(List<OwnerChangeRequest> requests) {
        List<User_Entry__c> userEntries = new List<User_Entry__c>();
        for (OwnerChangeRequest request : requests) {
            userEntries.add(
                new User_Entry__c(
                    Id = request.userEntryId,
                    OwnerId = request.ownerId
                )
            );
        }
        System.enqueueJob(new UserEntryUpdatesAsync(userEntries));
    }

    public class OwnerChangeRequest {
        @InvocableVariable public Id userEntryId;
        @InvocableVariable public Id ownerId;
      }
}