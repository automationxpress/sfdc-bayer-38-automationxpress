public class PrimaUpdatesAsync implements Queueable, Database.AllowsCallouts {
    private Integer nrOfAttempts;
    private List<User_Entry__c> userEntries;

    public PrimaUpdatesAsync(List<User_Entry__c> userEntries){
        this.nrOfAttempts = 1;
        this.userEntries = userEntries;
    }
    
    public PrimaUpdatesAsync(List<User_Entry__c> userEntries, Integer nrOfAttempts){
        this.nrOfAttempts = nrOfAttempts;
        this.userEntries = userEntries;
    }

    public void execute(QueueableContext context) {
        PrimaService.sendPrimaUpdates(userEntries, nrOfAttempts);
    }
}