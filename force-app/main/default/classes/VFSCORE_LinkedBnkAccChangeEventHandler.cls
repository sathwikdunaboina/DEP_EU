/**
* Name of the class    VFSCORE_LinkedBnkAccChangeEventHandler
* Author               Aswin Balaji
* Create Date  		   03-18-2024
* Used by 			   Trigger
* Trigger Name		   VFSCORE_LinkedBankAccountsChangeEventTrigger
* SystemLayer		   Handler
* Description          From the Linked Bank Account Change Events we need to get the Accounts and send to VFSCORE_GlobalCustomerService
*/
public class VFSCORE_LinkedBnkAccChangeEventHandler {
    List<Linked_Bank_Accounts__ChangeEvent> linkedBankAccountChangeEvents;
    public VFSCORE_LinkedBnkAccChangeEventHandler(List<Linked_Bank_Accounts__ChangeEvent> linkedBankAccountChangeEvents) {
        this.linkedBankAccountChangeEvents = linkedBankAccountChangeEvents;
    }
    
    //call the VFSCORE_GlobalCustomerService.SyncCustomers() method
    public void SyncCustomersToVFSSystems(){
        
        List<Id> accountIds =  new List<Id>(getAccountIds());       
        Integer countofAccountIds = accountIds.size();
        Integer numOfFutureCalls = countofAccountIds/100;
        for(Integer i = 0;i<numOfFutureCalls;i++){
            List<Id> accountIdsBatch = ListService.slice(accountIds,100*i,100*(i+1));
            //if accountIdsBatch.size() > 0 then @future call 
            if(accountIdsBatch.size() > 0){
                SyncCustomers(accountIdsBatch);
            }           
        }
        List<Id> accountIdsLastBatch = ListService.slice(accountIds,100*numOfFutureCalls,countofAccountIds);
        if(accountIdsLastBatch.size() > 0){
            SyncCustomers(accountIdsLastBatch);
        }
        
    }
    
    private List<Id> getAccountIds(){                
        Set<Id> allAccountIds = new Set<Id>();
        Set<Id> allLinkedBankAccountIds = new Set<Id>();
        for (Linked_Bank_Accounts__ChangeEvent linkedBankAccountChange : this.linkedBankAccountChangeEvents) {
            // Get all Record Ids for this change and add to the set
            List<Id> recordIds = (List<Id>)linkedBankAccountChange.ChangeEventHeader.getRecordIds();            
            allLinkedBankAccountIds.addAll(recordIds);
        }
        for(Linked_Bank_Accounts__c linkedBankAcc : [SELECT Id, Account__c,Account__r.sourceSystemID__c, Bank_Account__c FROM Linked_Bank_Accounts__c WHERE Id IN:allLinkedBankAccountIds WITH SECURITY_ENFORCED]){
            if(CustomSettingCheck().contains(linkedBankAcc.Account__r.sourceSystemID__c)){
                allAccountIds.add(linkedBankAcc.Account__c);
            }
        }
        return new List<Id>(allAccountIds);
    }
    
    @future(callout=true)
    private static void SyncCustomers(List<Id> accountIds){
        System.Debug('Accounts modified size >> '+accountIds.size());
        System.debug('Accounts modified >> '+ accountIds);
        //call the VFSCORE_GlobalCustomerService.SyncCustomers() method
    }
    
    Private Set<String> CustomSettingCheck(){
        List<VFSCORE_Customer_ManagementCountryChecks__mdt> mcs = VFSCORE_Customer_ManagementCountryChecks__mdt.getall().values();
        Set<String> allcMCC = new Set<String>();
        for(VFSCORE_Customer_ManagementCountryChecks__mdt cMCC : mcs){
            allcMCC.add(cMCC.DeveloperName);
        }
        return allcMCC;
    }
}