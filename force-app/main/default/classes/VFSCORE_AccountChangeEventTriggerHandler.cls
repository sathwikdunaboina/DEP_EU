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
    
    public class VFSCORE_AccountChangeEventTriggerHandler_Exception extends Exception {}

    List<AccountChangeEvent> accountChangeEvents;
    public VFSCORE_AccountChangeEventTriggerHandler(List<AccountChangeEvent> accountChangeEvents) {
        this.accountChangeEvents = accountChangeEvents;
    }
    
    //call the VFSCORE_GlobalCustomerService.SyncCustomers() method
    public void SyncCustomersToVFSSystems() {
        
        try {
            System.debug('I am here');
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
        } catch(Exception e) { ErrorLogUtil.createErrorLog('VFSCORE_AccountChangeEventTriggerHandler', e.getMessage(), '', e.getLineNumber(), 'SyncCustomersToVFSSystems', e.getStackTraceString(), '', '', ''); }
    }
    
    private List<Id> getAccountIds() {
        
        String associatedRecord = '';
        Set<Id> setAllAccountIds = new Set<Id>();
        try {

            Set<Id> setAllAccountIdsTemp = new Set<Id>();
            for (AccountChangeEvent accountChange : this.accountChangeEvents) {
                // Get all Record Ids for this change and add to the set
                
                List<Id> recordIds = (List<Id>)accountChange.ChangeEventHeader.getRecordIds();              
               EventBus.ChangeEventHeader header = accountChange.ChangeEventHeader;
               System.debug('Received Change Event for ' + header.entityName + ' for the ' + header.changeType + ' operation.');                
                List<String> changedFieldsString=header.changedFields;
                System.debug('This is the changed field '+changedFieldsString);
                System.debug('These records came in this loop'+recordIds);
                System.debug(changedFieldsString.contains('LastModifiedDate'));
                //if(changedFieldsString.size()!=0)
                //{
                if (header.changeType == 'UPDATE' && changedFieldsString.contains('LastModifiedDate') && changedFieldsString.size() == 1) {
                    System.debug(' I am here in if block as the change type is Update and Field is LastModified Date ');
                 
                 //}
                
                }
                
                else{
                    System.debug(' I am here in else as changeType is ' + header.changeType +' And Changed Field is ' + changedFieldsString);
                setAllAccountIdsTemp.addAll(recordIds);
                }
            }
                  System.debug('I am here at line 55');
            System.debug('This is the record list at the end '+setAllAccountIdsTemp);
            System.debug('And This is the size of the list ' +setAllAccountIdsTemp.size());

            for(Account acc : [SELECT Id,sourceSystemID__c FROM Account WHERE Id IN: setAllAccountIdsTemp WITH SECURITY_ENFORCED]) {
                associatedRecord = acc.Id;
                if(acc.sourceSystemID__c != null){
                    String sourceSystemId = VFSCORE_Customer_ManagementCountryChecks__mdt.getInstance(acc.sourceSystemID__c.SubStringBefore('-')).DeveloperName;
                    if(sourceSystemId != null){
                        setAllAccountIds.add(acc.Id);
                    }
                }
            }
            System.debug('setAllAccountIds >> '+ setAllAccountIds);
        } catch(Exception e) { ErrorLogUtil.createErrorLog('VFSCORE_AccountChangeEventTriggerHandler', e.getMessage(), '', e.getLineNumber(), 'getAccountIds', e.getStackTraceString(), '', '', associatedRecord); }
        return new List<Id>(setAllAccountIds);
    }
    
    @future(callout=true)
    private static void SyncCustomers(List<Id> listAccountIds) {

        System.Debug('Accounts modified size >> '+listAccountIds.size());
        System.debug('Accounts modified >> '+ listAccountIds);
        Set<Id> setAccountIdsSet = new Set<Id>(listAccountIds);
        VFSCORE_GlobalCustomerService globalService = new VFSCORE_GlobalCustomerService();
        globalService.syncCustomer(setAccountIdsSet);
    }

    public void logEvents(){
        List<ErrorLogUtil.LogMessage> logMsgs = new List<ErrorLogUtil.LogMessage>();
        for(AccountChangeEvent evt : this.accountChangeEvents) {
            System.debug('>>> evt = ' + evt);   
            ErrorLogUtil.LogMessage logMsg = new ErrorLogUtil.LogMessage();
            logMsg.className = 'VFSCORE_AccountChangeEventTrigger';
            logMsg.errorMessage = JSON.serialize(evt);
            logMsg.logType = 'info';
            logMsg.description = 'AccountChangeEvent';            
            logMsgs.add(logMsg);
        }
        ErrorLogUtil.createLogs(logMsgs);
    }    
}