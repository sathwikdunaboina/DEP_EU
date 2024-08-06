/*
* Contains methods to call Invoice API and fetch Invoice records in SF.
* 
* */
public without sharing class CMSAPI_InvoiceHandler {
    
    @InvocableMethod (label='fetchInvoicesFromAPI' description='This fetches Invoices from backend CMS')
    public static List<InvoiceAPIResultSummary> fetchInvoicesFromAPI(List<Id> accountIds){
        try{
            List<InvoiceAPIResultSummary> invoiceResults = new List<InvoiceAPIResultSummary>();
            for (Id accountId : accountIds){
                system.debug(accountIds);
                Account accTest = [Select id from account limit 1];
                system.debug('test -- '+accTest);
                Account acc = [SELECT BillingCountryCode, CustomerId__c , (SELECT Id FROM Invoices__r)
                                , Invoices_Fetched_On__c
                                FROM Account
                                WHERE Id =:accountId];
                //Check if Account has all necessary Params to make API Call
                if (acc == NULL 
                        || String.isEmpty(acc.BillingCountryCode) 
                        || String.isEmpty(acc.CustomerId__c) )
                        {
                    ErrorLogUtil.createErrorLog('CMSAPI_InvoiceHandler', 'Unable to retrieve Account Details for '+accountId, null , 15 , 'fetchInvoicesFromAPI', null, null, null, accountId);
                    throw new InvoiceAPIException('Unable to retrieve Account Details for '+accountId);
                }
    
                CMSAPI__c settings = CMSAPI_SettingsManager.get();
                //Make the sync callout.
                HttpResponse response = HttpCallout.send('callout:VFS_Global_APIs'+'/'+ settings.Invoice_Resource__c
                                                            , 'POST'
                                                            , new Map<String, String> { //headers
                                                            'X-legal_entity' => 'vfs_'+acc.BillingCountryCode.toLowerCase()
                                                            ,'X-Ibm-Client-Id' => settings.X_Ibm_Client_Id__c
                                                            ,'X-Ibm-Client-Secret' => settings.X_Ibm_Client_Secret__c
                                                            ,'Content-Type' => 'application/json'
                                                            }
                                                            , JSON.serialize(new InvoiceSearchQuery(acc.CustomerId__c)) //body
                                                        );
                Integer statusCode = response.getStatusCode();
                system.debug('statusCode-'+statusCode);
                if ( statusCode != 200 ){
                    throw new InvoiceAPIException('Unable to retrieve invoices. Status='+statusCode);
                }
                //Serialize result for parsing.
                system.debug('response.getBody() '+ response.getBody());
                InvoiceSearchResults respBody = (InvoiceSearchResults) JSON.deserialize(response.getBody(), InvoiceSearchResults.class);
                List<Invoice__c> invList= parseInvoiceList(respBody.results);
                //dml
                List<Database.UpsertResult> results = Database.upsert (invList, Invoice__c.Invoice_Id__c, false);
                InvoiceAPIResultSummary resultSummary = new InvoiceAPIResultSummary();
                resultSummary.totalInvoicesFromAPI = invList != null ? invList.size() : 0;
                for (Database.UpsertResult result : results){
                	if (result.isSuccess()){
                    	resultSummary.totalInvoicesSaved ++;    
                    } else {
                        resultSummary.isSuccess = false;
                        System.debug(result.getErrors());
                    }
                }
                acc.Invoices_Fetched_On__c = DateTime.now();
                update acc;
                system.debug(resultSummary);
                invoiceResults.add(resultSummary);
        	}
        	return invoiceResults;
        } catch (Exception exp){
            ErrorLogUtil.createErrorLog('CMSAPI_InvoiceHandler', exp.getMessage(), null , null , 'fetchInvoicesFromAPI', exp.getStackTraceString(), null, null, String.valueOf(accountIds));
            throw new InvoiceAPIException('Unable to retrieve invoices. Please try again later.');
        }
    }
    public static List<Invoice__c> parseInvoiceList (List<CMSAPI_InvoiceData> apiResult){
        List<Invoice__c> invList = new List<Invoice__c>();
        for (CMSAPI_InvoiceData invData : apiResult){
            invList.add(invData.parseToInvoiceObj());
        }
        return invList;
    }

    //Based on swagger received from API team
    public class InvoiceSearchQuery {
        
        InvoiceQuery query;
        InvoiceSearchQuery( String customerNumber){
            query = new InvoiceQuery();
            query.customerNumber = customerNumber;
        }
    }
    public class InvoiceQuery{
        String customerNumber;
    }
    public class InvoiceSearchResults{
        List<CMSAPI_InvoiceData> results;        
    }
    public class InvoiceAPIException extends Exception {}
    
    public class InvoiceAPIResultSummary {
    	
        @InvocableVariable public boolean isSuccess = true;
        @InvocableVariable public Integer totalInvoicesFromAPI = 0;
        @InvocableVariable public Integer totalInvoicesSaved = 0;
    }
}