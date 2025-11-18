/* 
* -----------------------------------------------------------------------------------------
* Apex Class Name     ChangeDataCaptureErrorLogController
* @author             Sourabh Sharma <sourabh.sharma@consultant.volvo.com>
* @Created Date       10-23-2025  
* @Used By             
* @Test Covered By    ChangeDataCaptureErrorLogController_Test
* @SystemLayer        Controller
* ------------------------------------------------------------------------------------------
* @description        This class is used as Controller for ChangeDataCaptureErrorLog
* ------------------------------------------------------------------------------------------
*/

public with sharing class ChangeDataCaptureErrorLogController {

    public class ErrorResult {
        @AuraEnabled public Boolean found { get; set; }
        @AuraEnabled public List<ErrorItem> errors { get; set; }

        public ErrorResult() {
            found  = false;
            errors = new List<ErrorItem>();
        }
    }

    
    public class ErrorItem {
        @AuraEnabled public Id errorLogId { get; set; }
        @AuraEnabled public String errorMessage { get; set; }
        @AuraEnabled public Datetime errorCreatedDate { get; set; }
        @AuraEnabled public String associatedRecordId { get; set; }
        @AuraEnabled public String associatedSObjectType { get; set; }
        @AuraEnabled public String associatedRecordName { get; set; }
        @AuraEnabled public String errorLogName { get; set; }
    }

   
/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     getLatestRelevantError
* @description     This method gets relevant error logs for account/contact/bank account mandate.
* ------------------------------------------------------------------------------------------------------
* @param           recordId       sObject record Id, Id
* @param           objectApiName  object api Name , String
* @return          ErrorResult    returns error result wrapper class
* ------------------------------------------------------------------------------------------------------ 
*/
    @AuraEnabled(cacheable = true)
    public static ErrorResult getLatestRelevantError(Id recordId, String objectApiName) {
        ErrorResult result = new ErrorResult();

        if (recordId == null || String.isBlank(objectApiName)) {
            return result;
        }

        Id accountId = resolveAccountId(recordId, objectApiName);
        if (accountId == null) {
            return result;
        }

        Datetime latestModified = calculateLatestModifiedDate(accountId);
        Set<Id> relatedIds = gatherRelatedRecordIds(accountId);

        List<Error_Log__c> logs = queryErrorLogs(relatedIds, latestModified);
        
        if (logs.isEmpty()) {
            return result;
        }

        for (Error_Log__c log : logs) {
            ErrorItem item = buildErrorItem(log);
            result.errors.add(item);
        }

        result.found = !result.errors.isEmpty();
        return result;
    }

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     resolveAccountId
* @description     This method gets the account Id from related records
* ------------------------------------------------------------------------------------------------------
* @param           recordId       sObject record Id, Id
* @param           objectApiName  object api Name , String
* @return          Id    returns accountId
* ------------------------------------------------------------------------------------------------------ 
*/   
    private static Id resolveAccountId(Id recordId, String objectApiName) {
        try {
            if (objectApiName == 'Account') {
                return recordId;
            }
            if (objectApiName == 'Contact') {
                Contact c = [SELECT AccountId FROM Contact WHERE Id = :recordId LIMIT 1];
                return c.AccountId;
            }
            if (objectApiName == 'Bank_Account_Mandate__c') {
                Bank_Account_Mandate__c bm = [
                    SELECT Account__c FROM Bank_Account_Mandate__c WHERE Id = :recordId LIMIT 1
                ];
                return bm.Account__c;
            }
            if (objectApiName == 'Bank_Account__c') {
                Linked_Bank_Accounts__c lba = [
                     SELECT Id,Account__c,Bank_Account__c,Account__r.sourceSystemID__c From Linked_Bank_Accounts__c Where Bank_Account__c = :recordId LIMIT 1
                ];
                return lba.Account__c;
            }
        } catch (Exception e) {
            System.debug('Exception  :'+e.getLineNumber()); 
        }
        return null;
    }

 /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     calculateLatestModifiedDate
* @description     This method gets the latest last modified record among the account,contact,bank account,bank account mandate
* ------------------------------------------------------------------------------------------------------
* @param           Id        account Id
* @return          DateTime  return latest last modified date
* ------------------------------------------------------------------------------------------------------ 
*/    
    private static Datetime calculateLatestModifiedDate(Id accountId) {
        Datetime latestModified = Datetime.newInstanceGmt(1970, 1, 1, 0, 0, 0);

        Account acc = [SELECT LastModifiedDate FROM Account WHERE Id = :accountId LIMIT 1];
        latestModified = acc.LastModifiedDate;
       

        for (Contact c : [SELECT LastModifiedDate FROM Contact WHERE AccountId = :accountId]) {
            if (c.LastModifiedDate > latestModified) {
                latestModified = c.LastModifiedDate;
            }
        }

        for (Bank_Account_Mandate__c bm :
            [SELECT LastModifiedDate FROM Bank_Account_Mandate__c WHERE Account__c = :accountId]
        ) {
            if (bm.LastModifiedDate > latestModified) {
                latestModified = bm.LastModifiedDate;
            }
        }
       
        for (Linked_Bank_Accounts__c lba :
            [SELECT Id,Account__c,Bank_Account__r.LastModifiedDate FROM Linked_Bank_Accounts__c WHERE Account__c = :accountId]
        ) {
            if (lba.Bank_Account__r.LastModifiedDate > latestModified) {
                latestModified = lba.Bank_Account__r.LastModifiedDate;
            }
        }

        return latestModified;
    }

 /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     gatherRelatedRecordIds
* @description     This method gets the all related record Ids to get associated error log records
* ------------------------------------------------------------------------------------------------------
* @param           Id        account Id
* @return          Set<Id>   return all related records Ids
* ------------------------------------------------------------------------------------------------------ 
*/    
    private static Set<Id> gatherRelatedRecordIds(Id accountId) {
        Set<Id> ids = new Set<Id>{ accountId };

        for (Contact c : [SELECT Id FROM Contact WHERE AccountId = :accountId]) {
            ids.add(c.Id);
        }

        for (Bank_Account_Mandate__c bm :
            [SELECT Id FROM Bank_Account_Mandate__c WHERE Account__c = :accountId]
        ) {
            ids.add(bm.Id);
        }
        
        for (Linked_Bank_Accounts__c lba :
            [SELECT Id,Account__c,Bank_Account__c FROM Linked_Bank_Accounts__c WHERE Account__c = :accountId]
        ) {
             ids.add(lba.Bank_Account__c);
        }

        return ids;
    }

 /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     gatherRelatedRecordIds
* @description     This method gets the all related record Ids to get associated error log records
* ------------------------------------------------------------------------------------------------------
* @param           Id        account Id
* @return          Set<Id>   return all related records Ids
* ------------------------------------------------------------------------------------------------------ 
*/    
    private static List<Error_Log__c> queryErrorLogs(Set<Id> relatedIds, Datetime latestModified) {
        if (relatedIds.isEmpty()) {
            return new List<Error_Log__c>();
        }
        return [
            SELECT Id, Name, Associated_Record__c, Error_Message__c, CreatedDate
            FROM Error_Log__c
            WHERE Type__c = 'Error'
              AND Associated_Record__c IN :relatedIds
              AND CreatedDate >= :latestModified
            ORDER BY CreatedDate DESC
        ];
    }

    
    private static ErrorItem buildErrorItem(Error_Log__c log) {
        ErrorItem item = new ErrorItem();
        item.errorLogId        = log.Id;
        item.errorMessage      = log.Error_Message__c;
        item.errorCreatedDate  = log.CreatedDate;
        item.associatedRecordId = log.Associated_Record__c;
        item.errorLogName      = log.Name;

        if (!String.isBlank(log.Associated_Record__c) && log.Associated_Record__c.length() == 18) {
            populateAssociatedRecordDetails(item);
        }
        return item;
    }

  /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     populateAssociatedRecordDetails
* @description     This method populates associated detail into Error Log
* ------------------------------------------------------------------------------------------------------
* @param           ErrorItem      ErrorLog Wrapper Class
* ------------------------------------------------------------------------------------------------------ 
*/    
    private static void populateAssociatedRecordDetails(ErrorItem item) {
        try {
            Id assocId = (Id)item.associatedRecordId;
            Schema.SObjectType sType = assocId.getSObjectType();
            String apiName = sType.getDescribe().getName();
            item.associatedSObjectType = apiName;

            String query = 'SELECT Name FROM ' + apiName + ' WHERE Id = :assocId LIMIT 1';
            List<SObject> recs = Database.query(query);
            if (!recs.isEmpty()) {
                item.associatedRecordName = String.valueOf(recs[0].get('Name'));
            }
        } catch (Exception e) {
           System.debug('Exception  :'+e.getLineNumber()); 
        }
    }
}