/**
* Name of the class    VFSCORE_BnkAccManChngeEvntTriggerHandler
* Author               Aswin Balaji M
* Create Date  		   03-15-2024
* Used by 			   Trigger
* Trigger Name		   VFSCORE_BnkAccManChngeEvntTrigger
* SystemLayer		   Handler
* Description          From the bank Account Mandate Change Events we need to get the related Accounts and send to VFSCORE_GlobalCustomerService
*/
public class VFSCORE_BnkAccManChngeEvntTriggerHandler {
    List<Bank_Account_Mandate__ChangeEvent> bankAccountMandateChangeEvents;
    public VFSCORE_BnkAccManChngeEvntTriggerHandler(List<Bank_Account_Mandate__ChangeEvent> bankAccountMandateChangeEvents) {
        this.bankAccountMandateChangeEvents = bankAccountMandateChangeEvents;
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
        }  catch(Exception e) { ErrorLogUtil.createErrorLog('VFSCORE_BnkAccManChngeEvntTriggerHandler', e.getMessage(), '', e.getLineNumber(), 'SyncCustomersToVFSSystems', e.getStackTraceString(), '', '', ''); }
    }
    
    private List<Id> getAccountIds() {   
        
        String associatedRecord = '';
        Set<Id> setAllAccountIds = new Set<Id>();
        try {

            Set<Id> setAllBankAccountMandateIds = new Set<Id>();  
            Set<Id> setAllBankAccountIds = new Set<Id>();
            for (Bank_Account_Mandate__ChangeEvent bankAccountMandateChange : this.bankAccountMandateChangeEvents) {
                // Get all Record Ids for this change and add to the set
                List<Id> listBankAccManRecordId = (List<Id>)bankAccountMandateChange.ChangeEventHeader.getRecordIds();            
                setAllBankAccountMandateIds.addAll(listBankAccManRecordId);
            }
            for(Bank_Account_Mandate__c bankAccMandate : [SELECT Id, Account__c,Account__r.sourceSystemID__c, Bank_Account__c 
                                                          FROM Bank_Account_Mandate__c Where Id IN: setAllBankAccountMandateIds WITH SYSTEM_MODE]){            
                setAllBankAccountIds.add(bankAccMandate.Bank_Account__c);
            }

            if(!setAllBankAccountIds.isEmpty()){
                for(Linked_Bank_Accounts__c linkedBankAccounts : [SELECT Id,Account__c,Account__r.sourceSystemID__c,Bank_Account__c From Linked_Bank_Accounts__c Where Bank_Account__c IN: setAllBankAccountIds]){
                    
                    associatedRecord = linkedBankAccounts.Id;
                    if(linkedBankAccounts.Account__c != null){
                        system.debug('>>> linkedBankAccounts.Account__r.sourceSystemID__c = ' + linkedBankAccounts.Account__r.sourceSystemID__c);
                        system.debug('>>> linkedBankAccounts.Account__r.sourceSystemID__c.SubStringBefore(\'-\') = ' + linkedBankAccounts.Account__r.sourceSystemID__c.SubStringBefore('-'));
                        system.debug('>>> VFSCORE_Customer_ManagementCountryChecks__mdt.getInstance(linkedBankAccounts.Account__r.sourceSystemID__c.SubStringBefore(\'-\')) = ' + 
                                     VFSCORE_Customer_ManagementCountryChecks__mdt.getInstance(linkedBankAccounts.Account__r.sourceSystemID__c.SubStringBefore('-')));
                        String sourceSystemId = VFSCORE_Customer_ManagementCountryChecks__mdt.getInstance(linkedBankAccounts.Account__r.sourceSystemID__c.SubStringBefore('-')).DeveloperName;
                        if(sourceSystemId != null){
                            setAllAccountIds.add(linkedBankAccounts.Account__c);
                        }
                    }
                }
            }
            System.debug('Size of accountids'+ setAllAccountIds.Size());
            System.debug('Size of allAccountIdsallAccountIds'+ setAllAccountIds);

            // modified code starts here
            // for(Bank_Account_Mandate__c bankAccMandate : [SELECT Id, Account__c,Account__r.sourceSystemID__c, Bank_Account__c 
            //                                             FROM Bank_Account_Mandate__c Where (Id IN: setAllBankAccountMandateIds AND Account__r.sourceSystemID__c <> NULL) 
            //                                             WITH SYSTEM_MODE]) {            
                
            //     associatedRecord = bankAccMandate.Id;
            //     if(VFSCORE_Customer_ManagementCountryChecks__mdt.getInstance(bankAccMandate.Account__r.sourceSystemID__c.SubStringBefore('-')).DeveloperName != null) {
            //         setAllAccountIds.add(bankAccMandate.Account__c);
            //     }
            // }

            
            System.debug('Size of accountids'+ setAllAccountIds.Size());
            System.debug('Size of allAccountIdsallAccountIds'+ setAllAccountIds);
            // modified code ends here
        } catch(Exception e) { ErrorLogUtil.createErrorLog('VFSCORE_BnkAccManChngeEvntTriggerHandler', e.getMessage(), '', e.getLineNumber(), 'getAccountIds', e.getStackTraceString(), '', '', associatedRecord); }
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
        for(Bank_Account_Mandate__ChangeEvent evt : this.bankAccountMandateChangeEvents){  
            ErrorLogUtil.LogMessage logMsg = new ErrorLogUtil.LogMessage();
            logMsg.className = 'VFSCORE_BnkAccManChangeEventTrigger';
            logMsg.errorMessage = JSON.serialize(evt);
            logMsg.logType = 'info';
            logMsg.description = 'Bank_Account_Mandate__ChangeEvent';            
            logMsgs.add(logMsg);
        }
        ErrorLogUtil.createLogs(logMsgs);
    }  
}