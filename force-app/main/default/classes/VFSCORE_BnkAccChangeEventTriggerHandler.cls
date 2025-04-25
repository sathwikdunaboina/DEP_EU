/**
* Name of the class    VFSCORE_BnkAccChangeEventTriggerHandler
* Author               Aswin Balaji M
* Create Date  		   03-15-2024
* Used by 			   Trigger
* Trigger Name		   VFSCORE_BnkAccChangeEventTrigger
* SystemLayer		   Handler
* Description          From the bank Account Change Events we need to get the related Accounts and send to VFSCORE_GlobalCustomerService
*/
public class VFSCORE_BnkAccChangeEventTriggerHandler {
    List<Bank_Account__ChangeEvent> bankAccountChangeEvents;
    public VFSCORE_BnkAccChangeEventTriggerHandler(List<Bank_Account__ChangeEvent> bankAccountChangeEvents) {
        this.bankAccountChangeEvents = bankAccountChangeEvents;
    }
    
    //call the VFSCORE_GlobalCustomerService.SyncCustomers() method
    public void SyncCustomersToVFSSystems() {

        try {

            List<Id> listAccountIds =  new List<Id>(getAccountIds());       
            Integer iCountofAccountIds = listAccountIds.size();
            Integer iNumOfFutureCalls = iCountofAccountIds/100;
            for(Integer i = 0;i<iNumOfFutureCalls;i++){
                List<Id> listAccountIdsBatch = ListService.slice(listAccountIds,100*i,100*(i+1));
                if(listAccountIdsBatch.size() > 0){
                    System.debug('listAccountIdsBatch>>>'+ listAccountIdsBatch.Size());
                    SyncCustomers(listAccountIdsBatch);
                }           
            }
            List<Id> accountIdsLastBatch = ListService.slice(listAccountIds,100*iNumOfFutureCalls,iCountofAccountIds);
            if(accountIdsLastBatch.size() > 0){
                SyncCustomers(accountIdsLastBatch);
            }
        } catch(Exception e) { ErrorLogUtil.createErrorLog('VFSCORE_BnkAccChangeEventTriggerHandler', e.getMessage(), '', e.getLineNumber(), 'SyncCustomersToVFSSystems', e.getStackTraceString(), '', '', ''); }
        
    }
    
    private List<Id> getAccountIds() {                
        
        String associatedRecord = '';
        Set<Id> setAllAccountIds = new Set<Id>(); 

        try {

            Set<Id> setAllBankAccountIds = new Set<Id>();
            for (Bank_Account__ChangeEvent bankAccountChange : this.bankAccountChangeEvents) {
                // Get all Record Ids for this change and add to the set
                List<Id> listBnkAccRecordId = (List<Id>)bankAccountChange.ChangeEventHeader.getRecordIds();           
                setAllBankAccountIds.addAll(listBnkAccRecordId);
            }
            for(Linked_Bank_Accounts__c linkedBankAccounts : [SELECT Id,Account__c,Bank_Account__c,Account__r.sourceSystemID__c From Linked_Bank_Accounts__c Where Bank_Account__c IN: setAllBankAccountIds WITH SYSTEM_MODE]){
                
                associatedRecord = linkedBankAccounts.Id;
                if(linkedBankAccounts.Account__c != null) {
                    
                    System.debug('>>> linkedBankAccounts.Account__r.sourceSystemID__c = ' + linkedBankAccounts.Account__r.sourceSystemID__c);
                    System.debug('>>> linkedBankAccounts.Account__c = ' + linkedBankAccounts.Account__c);
                    String sourceSystemId = VFSCORE_Customer_ManagementCountryChecks__mdt.getInstance(linkedBankAccounts.Account__r.sourceSystemID__c.SubStringBefore('-')).DeveloperName;
                    if(sourceSystemId != null){
                        setAllAccountIds.add(linkedBankAccounts.Account__c);
                    }
                }
            }
            System.debug('setAllAccountIds>>>'+setAllAccountIds);
        } catch(Exception e) { ErrorLogUtil.createErrorLog('VFSCORE_BnkAccChangeEventTriggerHandler', e.getMessage(), '', e.getLineNumber(), 'getAccountIds', e.getStackTraceString(), '', '', associatedRecord); }
        return new List<Id>(setAllAccountIds);
    }
    
    @future(callout=true)
    private static void SyncCustomers(List<Id> listAccountIds){
        System.Debug('Accounts modified size >> '+listAccountIds.size());
        System.debug('Accounts modified >> '+ listAccountIds);
        Set<Id> setAccountIdsSet = new Set<Id>(listAccountIds);
        VFSCORE_GlobalCustomerService globalService = new VFSCORE_GlobalCustomerService();
        globalService.syncCustomer(setAccountIdsSet);
    }

    public void logEvents(){
        List<ErrorLogUtil.LogMessage> logMsgs = new List<ErrorLogUtil.LogMessage>();
        for(Bank_Account__ChangeEvent evt : this.bankAccountChangeEvents){  
            ErrorLogUtil.LogMessage logMsg = new ErrorLogUtil.LogMessage();
            logMsg.className = 'VFSCORE_BankAccountChangeEventTrigger';
            logMsg.errorMessage = JSON.serialize(evt);
            logMsg.logType = 'info';
            logMsg.description = 'Bank_Account__ChangeEvent';            
            logMsgs.add(logMsg);
        }
        ErrorLogUtil.createLogs(logMsgs);
    }  
}