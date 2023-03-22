/*
* Created: Prabha & Sumit
* Uses CMSAPI_oAuthHandler class to get the accesstoken
* Fetches customer details from CMS API & upserts into Salesforce
* 
* */
public class CMSAPI_CustomerDetailsHandler {
    
    @InvocableMethod(label='Update Accounts and Contacts from API' description='Update Accounts and Contacts from API')
    public static void fetchCustomerDetails(List<String> customerIds){      // Modified by Sumit for bulking using Process builder
        if(!System.isFuture()){
         //Fetching the name from customerID; modified by Goldy   
            List<Account> accList=[SELECT Id, CustomerID__c, Name, BillingCountryCode 
                                   FROM Account 
                                   WHERE CustomerID__c in :customerIds];
            
            //System.assert(customerIds!=null && customerIds.size()<50, 'Too many customer Ids to fetch. Possible error!!!');
            for(Account acc: accList){      // Modified by Sumit for bulk processing
                enrichFromAPI(acc.CustomerID__c, acc.BillingCountryCode);
            }  
        }        
    }
    
    @future(callout=true)
    private static void enrichFromAPI(String customerId,String countryCode){
        try{
            String token = CMSAPI_oAuthHandler.getAccessToken(); //Token is cached, so token api is called only the first time
            if (!String.isBlank(token) && !String.isBlank(CustomerId) 
               		&& !String.isBlank(countryCode)) {
                //Prepare the HttpRequest needed to fetch the customer detail from the API
                /* The below headers are added for temp testing purposes
                    ,'X-Ibm-Client-Id' => '5c7a28a8cae7dd791f0b3624d8213709'
                    ,'X-Ibm-Client-Secret' => '6d8497c5220dcfeee633be5f472a8b6c'
                */
                CMSAPI__c settings = CMSAPI_SettingsManager.get();
                HttpResponse response = HttpCallout.send('callout:CMS_Customer_API'+'/'+customerId, 'GET', 
                                                         new Map<String, String> {
                                                             'Authorization' => 'Bearer '+token
                                                            , 'x-legal-entity' => 'vfs_'+countryCode.toLowerCase()
                                                            ,'Content-Type' => settings.Content_ID__c
                                                            ,'X-Ibm-Client-Id' => settings.X_Ibm_Client_Id__c
                                                            ,'X-Ibm-Client-Secret' => settings.X_Ibm_Client_Secret__c
                                                         }
                                                        );
                Integer statusCode = response.getStatusCode();
                if ( statusCode == 200 ){
                    CMSAPI_CustomerDetail customerDetail = (CMSAPI_CustomerDetail) JSON.deserialize(response.getBody(), CMSAPI_CustomerDetail.class);
                    //Assuming JSON parsing is cool,
                    //carving out the account data from response obj.
                    Account account = customerDetail.parseAccountData();
                    account.CustomerID__c = customerId;
                    
                    upsert account CustomerId__c;
                    
                    //carving out the contact data
                    List<Contact> contacts = customerDetail.parseContactData(account.Id, customerId);
                    if (contacts != null && !contacts.isEmpty()) {
                        //upserting based on email of the contact!! 
                        upsert contacts ContactId__c;
                    }
                    CMSAPI_oAuthHandler.setCachedToken(token);
                } else {
                    ErrorLogUtil.createErrorLog('CMSAPI_CustomerDetailsHandler', response.getBody(), ''+statusCode, null , 'enrichFromAPI', null,'vfs_'+countryCode.toLowerCase(),'callout:CMS_Customer_API'+'/'+customerId,customerId);
                }  
            } else {
                    ErrorLogUtil.createErrorLog('CMSAPI_CustomerDetailsHandler', 'Unable to use token', null, null , 'enrichFromAPI', null, null, null,customerId);
            }  
        } catch (Exception exp){
            ErrorLogUtil.createErrorLog('CMSAPI_CustomerDetailsHandler', exp.getMessage(), null, exp.getLineNumber() , 'enrichFromAPI', exp.getStackTraceString(), null, null,customerId);
        }
        
    }
    
}