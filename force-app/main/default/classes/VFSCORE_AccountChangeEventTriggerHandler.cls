/**
* Name of the class    VFSCORE_AccountChangeEventTriggerHandler
* Author               Alok Kumar
* Create Date  		   03-14-2024
* Used by 			   Trigger
* Trigger Name		   VFSCORE_AccountChangeEventTrigger
* SystemLayer		   Handler
* Description          From the Account Change Events we need to get the Accounts and send to VFSCORE_GlobalCustomerService
*/
public with sharing class VFSCORE_AccountChangeEventTriggerHandler {    
    List<AccountChangeEvent> accountChangeEvents;
    public VFSCORE_AccountChangeEventTriggerHandler(List<AccountChangeEvent> accountChangeEvents) {
        this.accountChangeEvents = accountChangeEvents;
    }
    
    //call the VFSCORE_GlobalCustomerService.SyncCustomers() method
    public void SyncCustomersToVFSSystems(){
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
    }
    
    private List<Id> getAccountIds(){                
        Set<Id> setAllAccountIds = new Set<Id>();   
        Set<Id> setAllAccountIdsTemp = new Set<Id>();
        for (AccountChangeEvent accountChange : this.accountChangeEvents) {
            // Get all Record Ids for this change and add to the set
            List<Id> recordIds = (List<Id>)accountChange.ChangeEventHeader.getRecordIds();            
            setAllAccountIdsTemp.addAll(recordIds);
        }
        for(Account acc : [SELECT Id,sourceSystemID__c FROM Account WHERE Id IN: setAllAccountIdsTemp WITH SECURITY_ENFORCED]){
            if(acc.sourceSystemID__c != null){
                String sourceSystemId = VFSCORE_Customer_ManagementCountryChecks__mdt.getInstance(acc.sourceSystemID__c.SubStringBefore('-')).DeveloperName;
                if(sourceSystemId != null){
                    setAllAccountIds.add(acc.Id);
                }
            }
        }
        System.debug('setAllAccountIds >> '+ setAllAccountIds);
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
    
}