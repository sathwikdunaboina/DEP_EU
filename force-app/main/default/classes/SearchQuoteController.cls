public with sharing class SearchQuoteController {
    
    /**
* Method to get all Quote records from Integartion for a customer

* @return List<CustomerOrderHistoryResponseWrapper.data>
*/
    @AuraEnabled(cacheable=true)
    public static List<searchQuotewrapper.data> getsearchQuote(String oppId){
        Opportunity opportunityId = new Opportunity();
        opportunityId = [Select Id, AccountID From Opportunity Where Id =: oppId];
        Account accountCustomerId = new Account();
        accountCustomerId = [Select Id, Customer_Number__c From Account Where Id =: opportunityId.AccountId];
        List<searchQuotewrapper.data> returnList = new List<searchQuotewrapper.data>();
        
        //try{
        if(accountCustomerId.Customer_Number__c != '' && accountCustomerId.Customer_Number__c != NULL )
        {
             //returnList = new searchQuoteHandler().methodName(accountCustomerId.Customer_Number__c);
        }
       
        return returnList;
        //}
        //catch(Exception exp){
        //    throw new AuraHandledException(exp.getMessage());
        //}
    }
    @AuraEnabled
    public static String updateQuoteOnOpportunity(String oppId, String quoteId){
        String returnmessage;
        List<Opportunity> updateoppList = new List<Opportunity>();
        for(Opportunity op : [select id,Name,StageName,Quote_Id__c from Opportunity where id =: oppId]){
            op.StageName = 'Quoted';
            op.Quote_Id__c = quoteId;
            updateoppList.add(op);
        }
        if(updateoppList != NULL && !updateoppList.isEmpty()){
            Database.SaveResult[] srList = Database.update(updateoppList, false);
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    // This condition will be executed for successful records and will fetch
                    // the ids of successful records
                    System.debug('Successfully updated Invoice. Invoice ID is : ' + sr.getId());
                    returnmessage = 'Success';
                } else {
                    // This condition will be executed for failed records
                    for(Database.Error objErr : sr.getErrors()) {
                        System.debug('The following error has occurred.');

                        // Printing error message in Debug log
                        System.debug(objErr.getStatusCode() + ': ' + objErr.getMessage());
                        System.debug('Invoice oject field which are affected by the error:' + objErr.getFields());
                        returnmessage = objErr.getMessage();
                    }
                }
            }
        }
        return returnmessage;
    }
}