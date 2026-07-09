/* 
* Created: Prabha
* Methods for every resource in the Contract API.
* 1. ContractList resource
* 2. ContractDetail resource
* 
*/
public without sharing class CMSAPI_ContractHandler {
    @future(callout=true)
    public static void fetchContractList(String customerId){
        try{
            if (String.isBlank(customerId)){
                ErrorLogUtil.createErrorLog('CMSAPI_ContractHandler', 'Empty Customer ID', null, null , 'fetchContractList', null,null,null,customerId);
                return ;
            }
            Account account = [SELECT Id, CustomerId__c, BillingCountryCode FROM Account WHERE CustomerId__c = :customerId];
            if (account == null || String.isBlank(account.BillingCountryCode) ){
                ErrorLogUtil.createErrorLog('CMSAPI_ContractHandler', 'Bad Customer ID / CountryCode', null, null , 'fetchContractList', null,null,null,customerId);
                return ;
            }
            String token = CMSAPI_oAuthHandler.getAccessToken(); //Token is cached, so token api is called only the first time
            if (String.isBlank(token)) {
                ErrorLogUtil.createErrorLog('CMSAPI_ContractHandler', 'Unable to use token', null, null , 'fetchContractList', null,null,null,customerId);
                return;
            }
            //Prepare the HttpRequest needed to fetch the customer detail from the API
            //https://api-qa.volvo.com/vfs/sandbox/cxp-customer-api/v1.0/customers
            CMSAPI__c settings = CMSAPI_SettingsManager.get();
            HttpResponse response = HttpCallout.send('callout:CMS_Contract_List_API'+'/'+customerId+'/contracts', 'GET',
                                                     new Map<String , String>{
                                                         'Authorization' => 'Bearer '+token
                                                             ,'X-Ibm-Client-Id' => settings.X_Ibm_Client_Id__c
                                                             ,'X-Ibm-Client-Secret' => settings.X_Ibm_Client_Secret__c
                                                             ,'Content-Type' => settings.Content_ID__c
                                                             ,'x-legal-entity' => 'vfs_'+account.BillingCountryCode.toLowerCase()
                                                             }
                                                    );
 
            Integer statusCode = response.getStatusCode();
            if ( statusCode != 200 ){
                ErrorLogUtil.createErrorLog('CMSAPI_ContractHandler', response.getBody(), ''+statusCode, null , 'fetchContractList', null, 'vfs_'+account.BillingCountryCode , 'callout:CMS_Contract_List_API'+'/'+customerId+'/contracts', customerId);
                return ;
            }
            List<CMSAPI_ContractDetail> cmsContracts = (List<CMSAPI_ContractDetail>) JSON.deserialize(response.getBody(), List<CMSAPI_ContractDetail>.class);
            List<Contract__c> contracts = parseCMSContractList(cmsContracts, customerId);
            upsert contracts Contract_Id__c;
            CMSAPI_oAuthHandler.setCachedToken(token);
            /* Removing the old contracts, that are not in API call.
delete [SELECT Id 
FROM Contract__c 
WHERE Id NOT IN :contracts 
AND Account__r.CustomerId__c = :customerId];
*/
            //Saving the contract list api called time.
            update new Account (Id = account.Id, Contract_API_Last_Called__c = System.now());
        } Catch (Exception exp){
            ErrorLogUtil.createErrorLog('CMSAPI_ContractHandler', exp.getMessage(), null, exp.getLineNumber() , 'fetchContractList', exp.getStackTraceString(), 'vfs_'+account.BillingCountryCode , 'callout:CMS_Contract_List_API'+'/'+customerId+'/contracts', customerId);
        }
    }
    
    public static Boolean fetchContractDetail(Id contractId){
        try{
            Contract__c contract = [SELECT Contract_Id__c, Contract_Number__c, Account__r.CustomerId__c, Account__r.BillingCountryCode 
                                    FROM Contract__c 
                                    WHERE Id =:contractId];
            //Not a valid contract to fetch!!!
            if (contract == null || contract.Account__c == null 
                || String.isBlank(contract.Account__r.CustomerId__c)
                || String.isBlank(contract.Account__r.BillingCountryCode)
                || String.isBlank(contract.Contract_Id__c)
                || String.isBlank(contract.Contract_Number__c)){
                    //ToDo: Write to error log
                    return false;
                }
            String token = CMSAPI_oAuthHandler.getAccessToken(); //Token is cached, so token api is called only the first time
            if (String.isBlank(token)) {
                ErrorLogUtil.createErrorLog('CMSAPI_ContractHandler', 'Unable to use token', null, null , 'fetchContractDetail', null,null,null,contractId);
                return false;
            }
            //Prepare the HttpRequest needed to fetch the customer detail from the API
            CMSAPI__c settings = CMSAPI_SettingsManager.get();            
            HttpResponse response = HttpCallout.send('callout:CMS_Contract_Detail_API'
                                                     + '/' +contract.Account__r.CustomerId__c
                                                     + '/contracts/'
                                                     + contract.Contract_Number__c, 'GET',
                                                     new Map<String , String>{
                                                         'Authorization' => 'Bearer '+token
                                                             ,'X-Ibm-Client-Id' => settings.X_Ibm_Client_Id__c
                                                             ,'X-Ibm-Client-Secret' => settings.X_Ibm_Client_Secret__c
                                                             ,'Content-Type' => settings.Content_ID__c
                                                             ,'x-legal-entity' => 'vfs_'+contract.Account__r.BillingCountryCode.toLowerCase()
                                                             }
                                                    );
            Integer statusCode = response.getStatusCode();
            
            if ( statusCode != 200 ){
                ErrorLogUtil.createErrorLog('CMSAPI_ContractHandler', response.getBody(), ''+statusCode, null , 'fetchContractDetail', null, 'vfs_'+contract.Account__r.BillingCountryCode.toLowerCase() , 'callout:CMS_Contract_Detail_API'
                                                     + '/' +contract.Account__r.CustomerId__c
                                                     + '/contracts/'
                                                     + contract.Contract_Number__c, contractId);
                return false;
            }   
            CMSAPI_ContractDetail cmsContract = (CMSAPI_ContractDetail) JSON.deserialize(response.getBody(), CMSAPI_ContractDetail.class);
            contract = cmsContract.parseFullDetails(contract.Account__r.CustomerId__c);
            contract.Id = contractId;
            update contract;
            //Parsing out the payment plans and upserting it.
            List<Payment_Plan__c> plans = cmsContract.parsePlans(contract.Id);
            insert plans;
            delete [SELECT Id
                    FROM Payment_Plan__c
                    WHERE Contract__c = :contract.Id
                    AND Id NOT IN :plans];
            //TODO: Move to status check success.
            CMSAPI_oAuthHandler.setCachedToken(token);
            return true;
        } Catch (Exception exp){
            ErrorLogUtil.createErrorLog('CMSAPI_ContractHandler', exp.getMessage(), null, exp.getLineNumber() , 'fetchContractDetail', exp.getStackTraceString(),null,null,contractId);
            return false;
        }
    }
    @InvocableMethod(label='fetchContractList' description='Makes an API call, asynchronously to get the Contracts related to CustomerId')
    public static void invokeContractApi(List<String> customerIds){
        //System.assert(customerIds!=null && customerIds.size()<50, 'Too many customer Ids to fetch. Possible error!!!');
        if(!System.isFuture()){
            for(String custId: customerIds){
                fetchContractList(custId);
            } 
        }
    }
    public static List<Contract__c> parseCMSContractList (List<CMSAPI_ContractDetail> cmsContracts, String customerId){
        List<Contract__c> contracts = new List<Contract__c>();
        if(cmsContracts!=null){
            for (CMSAPI_ContractDetail cmsContract : cmsContracts ){
                Contract__c contract = cmsContract.parseBasicDetails(customerId);
                contracts.add(contract);
            }   
        }
        return contracts;
    } 
}