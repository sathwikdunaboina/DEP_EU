trigger QuoteTrigger on VFS_Connect_Quote__c (after insert, after update) {
/*if (Trigger.isAfter) {
        List<Id> quoteIds = new List<Id>();
for (VFS_Connect_Quote__c q : Trigger.new) {
quoteIds.add(q.Id);
        }
 
        // Call the future method to process quotes asynchronously
        QuoteHandler.processQuotesFuture(quoteIds);
    }*/
    /*Set<String> quoteNumbers = new Set<String>();
    
for (VFS_Connect_Quote__c q : Trigger.new) {
        if (q.Quote_Number__c != null) {
            quoteNumbers.add(q.Quote_Number__c);
        }
    }
 
    if (!quoteNumbers.isEmpty()) {
        QuoteHandler.processQuotesFuture(quoteNumbers);
    }*/
     /*Set<String> quoteNumbers = new Set<String>();
    
for (VFS_Connect_Quote__c q : Trigger.new) {
        if (q.Quote_Number__c != null) {
            quoteNumbers.add(q.Quote_Number__c);
        }
    }
 
    if (!quoteNumbers.isEmpty()) {
        QuoteHandler.processQuotesFuture(quoteNumbers);
    }*/
    /*Map<String, VFS_Connect_Quote__c> uniqueQuotes = new Map<String, VFS_Connect_Quote__c>();
 
for (VFS_Connect_Quote__c q : Trigger.new) {
        if (q.Quote_Number__c != null) {
            uniqueQuotes.put(q.Quote_Number__c, q); // Ensures one record per QuoteNumber__c
        }
    }
 
    if (!uniqueQuotes.isEmpty()) {
        System.enqueueJob(new QuoteUpsertQueueable(new List<VFS_Connect_Quote__c>(uniqueQuotes.values())));
    }*/
    /*Set<String> quoteNumbers = new Set<String>();
 
for (VFS_Connect_Quote__c q : Trigger.new) {
        if (q.Quote_Number__c != null) {
            quoteNumbers.add(q.Quote_Number__c);
        }
    }
 
    if (!quoteNumbers.isEmpty()) {
        List<VFS_Connect_Quote__c> quotesToProcess = [SELECT Id, Quote_Number__c FROM VFS_Connect_Quote__c WHERE Quote_Number__c IN :quoteNumbers];
 
        for (VFS_Connect_Quote__c q : quotesToProcess) {
            System.enqueueJob(new QuoteUpsertSingleQueueable(q)); // Enqueue each quote individually
        }
    }*/
    /*Set<String> quoteNumbers = new Set<String>();
 
for (VFS_Connect_Quote__c q : Trigger.new) {
        if (q.Quote_Number__c != null) {
            quoteNumbers.add(q.Quote_Number__c);
        }
    }
 
    if (!quoteNumbers.isEmpty()) {
        List<VFS_Connect_Quote__c> quotesToProcess = [SELECT Id, Quote_Number__c FROM VFS_Connect_Quote__c WHERE Quote_Number__c IN :quoteNumbers];
 
        for (VFS_Connect_Quote__c q : quotesToProcess) {
            System.enqueueJob(new QuoteUpsertSingleQueueable(q)); // Enqueue each quote individually
        }
    }*/
     Set<String> quoteNumbers = new Set<String>();
 
for (VFS_Connect_Quote__c q : Trigger.new) {
        if (q.Quote_Number__c != null) {
            quoteNumbers.add(q.Quote_Number__c);
        }
    }
 
    if (!quoteNumbers.isEmpty()) {
        QuoteHandler.processQuotes(quoteNumbers);
    }
}