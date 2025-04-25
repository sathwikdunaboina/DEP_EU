public class QuoteHandler {
    
    /*@future(callout=false) // Callout=false since we're not calling an external API in this method
    public static void processQuotesFuture(List<Id> quoteIds) {
        // Query the Quotes using the received IDs
        List<VFS_Connect_Quote__c> quotesToProcess = [SELECT Id,Quote_Number__c,Quote_Status__c FROM VFS_Connect_Quote__c WHERE Id IN :quoteIds];
 
        if (!quotesToProcess.isEmpty()) {
            processQuotes(quotesToProcess);
        }
    }
 
    public static void processQuotes(List<VFS_Connect_Quote__c> incomingQuotes) {
        Map<String, VFS_Connect_Quote__c> uniqueQuotesMap = new Map<String, VFS_Connect_Quote__c>();
 
        // Step 1: Remove duplicate QuoteNumbers from incoming data
        for (VFS_Connect_Quote__c q : incomingQuotes) {
            if (!uniqueQuotesMap.containsKey(q.Quote_Number__c)) {
                uniqueQuotesMap.put(q.Quote_Number__c, q);
            }
        }
 
        List<VFS_Connect_Quote__c> uniqueQuotesList = new List<VFS_Connect_Quote__c>(uniqueQuotesMap.values());
 
        // Step 2: Check for existing Quotes in Salesforce to prevent duplicate external ID errors
        Set<String> incomingQuoteNumbers = uniqueQuotesMap.keySet();
        Map<String, Id> existingQuotesMap = new Map<String, Id>();
 
        if (!incomingQuoteNumbers.isEmpty()) {
            for (VFS_Connect_Quote__c existing : [SELECT Id, Quote_Number__c FROM VFS_Connect_Quote__c WHERE Quote_Number__c IN :incomingQuoteNumbers]) {
existingQuotesMap.put(existing.Quote_Number__c, existing.Id);
            }
        }
 
        // Step 3: Assign existing IDs to avoid duplicate external ID errors
        for (VFS_Connect_Quote__c q : uniqueQuotesList) {
            if (existingQuotesMap.containsKey(q.Quote_Number__c)) {
q.Id = existingQuotesMap.get(q.Quote_Number__c);
            }
        }
 
        // Step 4: Perform upsert operation
        try {
            upsert uniqueQuotesList Quote_Number__c;
        } catch (DmlException e) {
            System.debug('Upsert failed: ' + e.getMessage());
        }
    }*/
    /*@future(callout=false)
    public static void processQuotesFuture(List<Id> quoteIds) {
        List<VFS_Connect_Quote__c> quotesToProcess = [SELECT Id, Quote_Number__c, 	Quote_Status__c FROM VFS_Connect_Quote__c WHERE Id IN :quoteIds];
 
        if (!quotesToProcess.isEmpty()) {
            processQuotes(quotesToProcess);
        }
    }
 
    public static void processQuotes(List<VFS_Connect_Quote__c> incomingQuotes) {
        Map<String, VFS_Connect_Quote__c> uniqueQuotesMap = new Map<String, VFS_Connect_Quote__c>();
 
        // Step 1: Remove duplicate QuoteNumbers from incoming data
        for (VFS_Connect_Quote__c q : incomingQuotes) {
            if (!uniqueQuotesMap.containsKey(q.Quote_Number__c)) {
                uniqueQuotesMap.put(q.Quote_Number__c, q);
            }
        }
 
        List<VFS_Connect_Quote__c> uniqueQuotesList = new List<VFS_Connect_Quote__c>(uniqueQuotesMap.values());
 
        // Step 2: Fetch existing Quotes from Salesforce
        Set<String> incomingQuoteNumbers = uniqueQuotesMap.keySet();
        Map<String, VFS_Connect_Quote__c> existingQuotesMap = new Map<String, VFS_Connect_Quote__c>();
 
        if (!incomingQuoteNumbers.isEmpty()) {
            for (VFS_Connect_Quote__c existing : [SELECT Id, Quote_Number__c, Quote_Status__c FROM VFS_Connect_Quote__c WHERE Quote_Number__c IN :incomingQuoteNumbers]) {
                existingQuotesMap.put(existing.Quote_Number__c, existing);
            }
        }
 
        // Step 3: Skip records where there is no change
        List<VFS_Connect_Quote__c> recordsToUpsert = new List<VFS_Connect_Quote__c>();
        for (VFS_Connect_Quote__c q : uniqueQuotesList) {
            if (existingQuotesMap.containsKey(q.Quote_Number__c)) {
                VFS_Connect_Quote__c existingQuote = existingQuotesMap.get(q.Quote_Number__c);
 
                // Compare existing and new values, skip if they are the same
                if (existingQuote.Quote_Status__c != q.Quote_Status__c) {
q.Id = existingQuote.Id; // Ensure it's an update, not insert
                    recordsToUpsert.add(q);
                }
            } else {
                // New Quote, add to the upsert list
                recordsToUpsert.add(q);
            }
        }
 
        // Step 4: Perform upsert only for changed records
        if (!recordsToUpsert.isEmpty()) {
            try {
                upsert recordsToUpsert Quote_Number__c;
            } catch (DmlException e) {
                System.debug('Upsert failed: ' + e.getMessage());
            }
        }
    }*/
    /*@future
    public static void processQuotesFuture(Set<String> quoteNumbers) {
        if (quoteNumbers.isEmpty()) return;
 
        List<VFS_Connect_Quote__c> quotesToProcess = [SELECT Id, Quote_Number__c, Quote_Status__c
                                       FROM VFS_Connect_Quote__c WHERE Quote_Number__c IN :quoteNumbers];
 
        Map<String, VFS_Connect_Quote__c> existingQuotesMap = new Map<String, VFS_Connect_Quote__c>();
        for (VFS_Connect_Quote__c q : quotesToProcess) {
            existingQuotesMap.put(q.Quote_Number__c, q);
        }
 
        List<VFS_Connect_Quote__c> recordsToUpsert = new List<VFS_Connect_Quote__c>();
        for (String quoteNumber : quoteNumbers) {
            VFS_Connect_Quote__c newQuote = new VFS_Connect_Quote__c(Quote_Number__c = quoteNumber);
 
            if (existingQuotesMap.containsKey(quoteNumber)) {
newQuote.Id = existingQuotesMap.get(quoteNumber).Id; // Ensure update, not insert
            }
 
            recordsToUpsert.add(newQuote);
        }
 
        if (!recordsToUpsert.isEmpty()) {
            Database.Upsert(recordsToUpsert, false); // allOrNone = false to prevent failures
        }
    }*/
    /*@future
    public static void processQuotesFuture(List<VFS_Connect_Quote__c> incomingQuotes) {
        if (incomingQuotes.isEmpty()) return;
 
        // Get unique Quote Numbers
        Set<String> quoteNumbers = new Set<String>();
        for (VFS_Connect_Quote__c q : incomingQuotes) {
            if (q.Quote_Number__c != null) {
                quoteNumbers.add(q.Quote_Number__c);
            }
        }
 
        // Fetch existing Quotes from Salesforce
        Map<String, VFS_Connect_Quote__c> existingQuotesMap = new Map<String, VFS_Connect_Quote__c>();
        for (VFS_Connect_Quote__c q : [SELECT Id, Quote_Number__c FROM VFS_Connect_Quote__c WHERE Quote_Number__c IN :quoteNumbers]) {
            existingQuotesMap.put(q.Quote_Number__c, q);
        }
 
        // Prepare list for upsert, ensuring only one record per QuoteNumber__c
        List<VFS_Connect_Quote__c> recordsToUpsert = new List<VFS_Connect_Quote__c>();
        for (VFS_Connect_Quote__c incomingQuote : incomingQuotes) {
            if (existingQuotesMap.containsKey(incomingQuote.Quote_Number__c)) {
incomingQuote.Id = existingQuotesMap.get(incomingQuote.Quote_Number__c).Id; // Convert to update
            }
 
            // Avoid duplicate entries in the same transaction
            if (!recordsToUpsert.contains(incomingQuote)) {
                recordsToUpsert.add(incomingQuote);
            }
        }
 
        // Perform bulk upsert with allOrNone = false to prevent failures
        if (!recordsToUpsert.isEmpty()) {
            Database.Upsert(recordsToUpsert, false);
        }
    }*/
    /*@future
    public static void processQuotesFuture(Set<String> quoteNumbers) {
        if (quoteNumbers.isEmpty()) return;
 
        // Fetch existing Quotes
        Map<String, VFS_Connect_Quote__c> existingQuotesMap = new Map<String, VFS_Connect_Quote__c>();
        for (VFS_Connect_Quote__c q : [SELECT Id, Quote_Number__c FROM VFS_Connect_Quote__c WHERE Quote_Number__c IN :quoteNumbers]) {
            existingQuotesMap.put(q.Quote_Number__c, q);
        }
 
        // Prepare list for upsert, ensuring one record per QuoteNumber__c
        List<VFS_Connect_Quote__c> recordsToUpsert = new List<VFS_Connect_Quote__c>();
        for (String quoteNumber : quoteNumbers) {
            VFS_Connect_Quote__c newQuote = new VFS_Connect_Quote__c(Quote_Number__c = quoteNumber);
 
            if (existingQuotesMap.containsKey(quoteNumber)) {
newQuote.Id = existingQuotesMap.get(quoteNumber).Id; // Convert to update
            }
 
            recordsToUpsert.add(newQuote);
        }
 
        // Perform bulk upsert with allOrNone = false to prevent failures
        if (!recordsToUpsert.isEmpty()) {
            Database.Upsert(recordsToUpsert, false);
        }
    }*/
    /*@future
    public static void processQuotesFuture(Set<String> quoteNumbers) {
        if (quoteNumbers.isEmpty()) return;
 
        // Fetch existing Quotes from Salesforce
        Map<String, VFS_Connect_Quote__c> existingQuotesMap = new Map<String, VFS_Connect_Quote__c>();
        for (VFS_Connect_Quote__c q : [SELECT Id, Quote_Number__c FROM VFS_Connect_Quote__c WHERE Quote_Number__c IN :quoteNumbers]) {
            existingQuotesMap.put(q.Quote_Number__c, q);
        }
 
        // Prepare records for upsert (ensure only one per Quote_Number__c)
        Map<String, VFS_Connect_Quote__c> uniqueQuotesMap = new Map<String, VFS_Connect_Quote__c>();
 
        for (String quoteNumber : quoteNumbers) {
            VFS_Connect_Quote__c newQuote = new VFS_Connect_Quote__c(Quote_Number__c = quoteNumber);
 
            if (existingQuotesMap.containsKey(quoteNumber)) {
newQuote.Id = existingQuotesMap.get(quoteNumber).Id; // Convert to update
            }
 
            uniqueQuotesMap.put(quoteNumber, newQuote); // Ensures only one record per QuoteNumber__c
        }
 
        // Process upserts in smaller batches to avoid conflicts
        List<VFS_Connect_Quote__c> recordsToUpsert = new List<VFS_Connect_Quote__c>(uniqueQuotesMap.values());
 
        // Process upserts in smaller batches
        Integer batchSize = 100; // Adjust batch size as needed
        List<VFS_Connect_Quote__c> batch = new List<VFS_Connect_Quote__c>();
 
        for (VFS_Connect_Quote__c q : recordsToUpsert) {
            batch.add(q);
            if (batch.size() == batchSize) {
                Database.Upsert(batch, false); // Upsert batch
                batch.clear(); // Clear batch for next set
            }
        }
 
        // Upsert remaining records if batch is not empty
        if (!batch.isEmpty()) {
            Database.Upsert(batch, false);
        }
    }*/
    
     public static void processQuotes(Set<String> quoteNumbers) {
        if (quoteNumbers.isEmpty()) return;
 
        // Fetch existing Quotes
        Map<String, VFS_Connect_Quote__c> existingQuotes = new Map<String, VFS_Connect_Quote__c>();
        for (VFS_Connect_Quote__c q : [SELECT Id, Quote_Number__c FROM VFS_Connect_Quote__c WHERE Quote_Number__c IN :quoteNumbers]) {
            existingQuotes.put(q.Quote_Number__c, q);
        }
 
        // Prepare records for upsert (ensure only one per QuoteNumber__c)
        Map<String, VFS_Connect_Quote__c> uniqueQuotes = new Map<String, VFS_Connect_Quote__c>();
 
        for (String quoteNumber : quoteNumbers) {
            if (!uniqueQuotes.containsKey(quoteNumber)) {
                VFS_Connect_Quote__c newQuote = new VFS_Connect_Quote__c(Quote_Number__c = quoteNumber);
                if (existingQuotes.containsKey(quoteNumber)) {
newQuote.Id = existingQuotes.get(quoteNumber).Id; // Convert to update
                }
                uniqueQuotes.put(quoteNumber, newQuote);
            }
        }
 
        // Convert map values to list for upsert
        List<VFS_Connect_Quote__c> recordsToUpsert = new List<VFS_Connect_Quote__c>(uniqueQuotes.values());
 
        // Check if list is empty
        if (recordsToUpsert.isEmpty()) {
            System.debug('No records to upsert');
            return;
        }
 
        //  Manual Loop Instead of `subList()`
        Integer batchSize = 100;
        for (Integer i = 0; i < recordsToUpsert.size(); i += batchSize) {
            List<VFS_Connect_Quote__c> batch = new List<VFS_Connect_Quote__c>();
 
            for (Integer j = i; j < Math.min(i + batchSize, recordsToUpsert.size()); j++) {
                batch.add(recordsToUpsert[j]);
            }
 
            try {
                upsert batch Quote_Number__c;
            } catch (DmlException e) {
                System.debug('Upsert failed: ' + e.getMessage());
            }
        }
    }
}