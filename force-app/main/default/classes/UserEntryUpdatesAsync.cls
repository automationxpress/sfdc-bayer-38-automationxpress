public class UserEntryUpdatesAsync implements Queueable, Database.AllowsCallouts {
    private List<User_Entry__c> userEntries;

    public UserEntryUpdatesAsync(List<User_Entry__c> userEntries) {
        this.userEntries = userEntries;
    }

    public void execute(QueueableContext context) {
        update userEntries;
    }
}