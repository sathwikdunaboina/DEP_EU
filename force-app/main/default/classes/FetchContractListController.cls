public with sharing class FetchContractListController {
	@AuraEnabled
    public static void getContractList(Id accountId){
        Account account = [Select CustomerId__c FROM Account WHERE Id =:accountId LIMIT 1];
        if (account == null  || String.isBlank(account.CustomerId__c)){
        //    throw new Exception ('Unable to get ')
        }
        CMSAPI_ContractHandler.fetchContractList(account.CustomerId__c);
    }
}