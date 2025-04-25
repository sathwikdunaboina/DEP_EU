public class QuoteUpsertBatch implements Database.Batchable<sObject> {
    private List<VFS_Connect_Quote__c> quotesToProcess;
 
    public QuoteUpsertBatch(List<VFS_Connect_Quote__c> quotes) {
        this.quotesToProcess = quotes;
    }
 
    public Database.QueryLocator start(Database.BatchableContext context) {
        return null; // This batch will use the execute() method directly
    }
 
    public void execute(Database.BatchableContext context, List<VFS_Connect_Quote__c> scope) {
        try {
            if (!scope.isEmpty()) {
                Database.Upsert(scope, false); // Partial success enabled
            }
        } catch (Exception e) {
            System.debug('Batch Upsert Error: ' + e.getMessage());
        }
    }
 
    public void finish(Database.BatchableContext context) {
        System.debug('Batch Upsert Completed.');
    }
}