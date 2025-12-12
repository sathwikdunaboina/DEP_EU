/**
* Name of the class    VFSCORE_ContactChangeEventTriggerHandler
* Author               Aswin Balaji M
* Create Date  		   03-15-2024
* Used by 			   Trigger
* Trigger Name		   VFSCORE_ContactChangeEventTrigger
* SystemLayer		   Handler
* Description          From the contact Change Events we need to get the related Accounts and send to VFSCORE_GlobalCustomerService
*/
public class VFSCORE_ContactChangeEventTriggerHandler {
    List<ContactChangeEvent> ContactChangeEvents;
    public VFSCORE_ContactChangeEventTriggerHandler(List<ContactChangeEvent> ContactChangeEvents) {
        this.ContactChangeEvents = ContactChangeEvents;
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
        } catch(Exception e) { ErrorLogUtil.createErrorLog('VFSCORE_ContactChangeEventTriggerHandler', e.getMessage(), '', e.getLineNumber(), 'SyncCustomersToVFSSystems', e.getStackTraceString(), '', '', ''); }
    }
    
    private List<Id> getAccountIds() { 
        
        String associatedRecord = '';
        Set<Id> setAllAccountIds = new Set<Id>();
        
        try {

            Set<Id> setAllContactIds = new Set<Id>();        
            for (ContactChangeEvent contactChange : this.ContactChangeEvents) {
                // Get all Record Ids for this change and add to the set
                List<Id> listContactRecordId = (List<Id>)contactChange.ChangeEventHeader.getRecordIds();            
                setAllContactIds.addAll(listContactRecordId);
            }
            for(Contact con : [Select AccountId,Account.sourceSystemID__c From Contact Where Id IN: setAllContactIds WITH SYSTEM_MODE]) {

                associatedRecord = con.Id;
                //** Bug Fix 1245524 START **/  
                    if(con.AccountId != null && String.isNotBlank(con.Account.sourceSystemID__c)){
                    String sysIdPrefix = con.Account.sourceSystemID__c.SubStringBefore('-');
                    VFSCORE_Customer_ManagementCountryChecks__mdt country = VFSCORE_Customer_ManagementCountryChecks__mdt.getInstance(sysIdPrefix);
                    if(country!= null && String.isNotBlank(country.DeveloperName)){
                        String sourceSystemID = country.DeveloperName;
                        setAllAccountIds.add(con.AccountId);
                        System.debug('Added AccountId to sync list' + con.AccountId);
                    }
                }
               //** Bug Fix 1245524 END **/   
            }
            System.debug('Size of accountids'+ setAllAccountIds.Size());
        } catch(Exception e) { ErrorLogUtil.createErrorLog('VFSCORE_ContactChangeEventTriggerHandler', e.getMessage(), '', e.getLineNumber(), 'getAccountIds', e.getStackTraceString(), '', '', associatedRecord); }
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
        for(ContactChangeEvent evt : this.ContactChangeEvents){  
            ErrorLogUtil.LogMessage logMsg = new ErrorLogUtil.LogMessage();
            logMsg.className = 'VFSCORE_ContactChangeEventTrigger';
            logMsg.errorMessage = JSON.serialize(evt);
            logMsg.logType = 'info';
            logMsg.description = 'ContactChangeEvents';            
            logMsgs.add(logMsg);
        }
        ErrorLogUtil.createLogs(logMsgs);
    } 
    
}