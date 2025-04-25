public class QuoteUpsertQueueable implements Queueable {
    private List<VFS_Connect_Quote__c> quotesToUpsert;
 
    // Constructor receives the list of Quotes
    public QuoteUpsertQueueable(List<VFS_Connect_Quote__c> quotes) {
        this.quotesToUpsert = quotes;
    }
 
    public void execute(QueueableContext context) {
        if (!quotesToUpsert.isEmpty()) {
            try {
                Database.upsert(quotesToUpsert, false); // Partial success enabled
            } catch (Exception e) {
                System.debug('Error during upsert: ' + e.getMessage());
            }
        }
    }
}