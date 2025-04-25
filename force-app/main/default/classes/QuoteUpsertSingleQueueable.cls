public class QuoteUpsertSingleQueueable implements Queueable {
    private VFS_Connect_Quote__c quoteToUpsert;
 
    // Constructor receives a single Quote record
    public QuoteUpsertSingleQueueable(VFS_Connect_Quote__c quoteRecord) {
        this.quoteToUpsert = quoteRecord;
    }
 
    public void execute(QueueableContext context) {
        try {
            if (quoteToUpsert != null) {
                upsert quoteToUpsert; // Upserts a single record, avoiding bulk duplicate errors
            }
        } catch (Exception e) {
            System.debug('Error during upsert: ' + e.getMessage());
        }
    }
}