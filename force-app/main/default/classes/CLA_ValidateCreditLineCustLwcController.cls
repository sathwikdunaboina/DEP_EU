/*
* -----------------------------------------------------------------------------------------
* Apex Class Name     CLA_ValidateCreditLineCustLwcController
* @author             Sourabh Sharma <sourabh.sharma@consultant.volvo.com>
* @Created Date       05-25-2024 
* @Used By            cLA_ValidateCreditLineCustomerLwc
* @Test Covered By    CLA_ValidateCreditLineCustLwcCont_Test
* @SystemLayer        Controller
* ------------------------------------------------------------------------------------------
* @description        Controller class for cLA_ValidateCreditLineCustomerLwc, used to handle credit line
                      customer validation
* ------------------------------------------------------------------------------------------
* Update 
* @Date               12-06-2024
* @author             By Sourabh Sharma <sourabh.sharma@consultant.volvo.com>
* Description         Updated Request Endpoint to handle sandbox and production environment
*/       

public with sharing class CLA_ValidateCreditLineCustLwcController {
    
   

    private final static String REQUEST_ENDPOINT = '/vcs/creditbureau/api/v1.0/credit-bureaus/companies/search'; 
    private final static String EXCEPTION_MESSAGE = 'Customer Data Not Available';
    private final static String EXCEPTION_UPDATE_MESSAGE = 'Update failed,Please contact you adminstrator.'; 
   
/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     getValidatedCustomerDetail
* @description     Make call out to get credit line customer credit bureau result and
*                  return to LWC 
* ------------------------------------------------------------------------------------------------------
* @param          sRecordId         Creditline customer record Id,String
* @return         String            Returns response JSON
* ------------------------------------------------------------------------------------------------------ 
*/ 
    @AuraEnabled
    public static  String  getValidatedCustomerDetail(String sRecordId){ 

            if(sRecordId != ''){
                String sRequestBody = getRequestBody(sRecordId);
                HTTPResponse response = validateCreditLineCustomer(sRequestBody);
                system.debug('response ==> '+response);
                if(response.getStatusCode() == 200){
                    return response.getBody();
                }
                else{
                    return null;
                  //  throw new AuraHandledException(EXCEPTION_MESSAGE);
                }
            }
            else{
                throw new AuraHandledException(EXCEPTION_MESSAGE); 
            } 
    
    }

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     getRequestBody
* @description     Prepare request body for callout from creditline custoer fields
* ------------------------------------------------------------------------------------------------------
* @param          sRecordId         Creditline customer record Id,String
* @return         String            Returns request body JSON,String
* ------------------------------------------------------------------------------------------------------ 
*/ 

    public static String getRequestBody(String sRecordId){
       
                LIST<CLA_Credit_Line_Account__c> listCreditLineCustomers = [SELECT Id,Name,CLA_Company_Identification_Number__c ,CLA_Credit_Line__r.CLA_Country__c 
                                                                        FROM  CLA_Credit_Line_Account__c WHERE Id =: sRecordId WITH USER_MODE LIMIT 1]; 
                String sRequestBody = '';
                if(!listCreditLineCustomers.isEmpty()){

                    Map<String,String> mapRequestParamValueByKey = new Map<String,String>();
                    mapRequestParamValueByKey.put('name',  listCreditLineCustomers[0].Name != null ?  listCreditLineCustomers[0].Name : '');
                    mapRequestParamValueByKey.put('companyIdentificationNumber',  listCreditLineCustomers[0].CLA_Company_Identification_Number__c != null ?  listCreditLineCustomers[0].CLA_Company_Identification_Number__c : '');
                    mapRequestParamValueByKey.put('country', listCreditLineCustomers[0].CLA_Credit_Line__r.CLA_Country__c != null ?  listCreditLineCustomers[0].CLA_Credit_Line__r.CLA_Country__c : ''  );

                    sRequestBody = JSON.serialize(mapRequestParamValueByKey);
               }
                return sRequestBody;
    }

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     validateCreditLineCustomer
* @description     Make call out to get credit line customer credit bureau result 
* ------------------------------------------------------------------------------------------------------
* @param          sRequestBody      Requestbody JSON,String
* @return         String            Returns request body JSON
* ------------------------------------------------------------------------------------------------------ 
*/ 

    public static HTTPResponse validateCreditLineCustomer(String sRequestBody){

            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:CLA_APIC_Named_Creds' + REQUEST_ENDPOINT);
            request.setMethod('POST');
            request.setBody(sRequestBody);
            request.setTimeout(120000);
            //request.setBody('{"name": "WINCANTON HOLDINGS LIMITED","companyIdentificationNumber": "02155951","country": "GB"}');
            //request.setBody('{"name": "WINCANTON HOLDINGS","companyIdentificationNumber": "","country": "GB"}');
            //request.setBody('{"name": "WINCANTON HOLDINGS","companyIdentificationNumber": "","country": ""}');

            Http http = new Http();
            HTTPResponse response = http.send(request);
            return response;
       }

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     updateCreditLineCustomer
* @description     Update creditline customer credit bureau information 
* ------------------------------------------------------------------------------------------------------
* @param          sRecordId            Creditline customer record Id,String
* @param          sCreditBureauId      Selected credit bureau Id by user,String
* @return         
* ------------------------------------------------------------------------------------------------------ 
*/ 

    @AuraEnabled
    public static void updateCreditLineCustomer(String sRecordId , String sCreditBureauId){
       
             CLA_Credit_Line_Account__c oCreditLineCustomer = new CLA_Credit_Line_Account__c();
             oCreditLineCustomer.CLA_Credit_Bureau_Number__c= sCreditBureauId;
             oCreditLineCustomer.CLA_Validation_Type__c= 'Credit Service';
             oCreditLineCustomer.Id = sRecordId;


            if(Schema.sObjectType.CLA_Credit_Line_Account__c.isupdateable() && 
                Schema.sObjectType.CLA_Credit_Line_Account__c.fields.CLA_Credit_Bureau_Number__c.isUpdateable() && 
                Schema.sObjectType.CLA_Credit_Line_Account__c.fields.CLA_Validation_Type__c.isUpdateable() 
                ){
                    try{                    
                    update oCreditLineCustomer;
                    }
                    catch(exception ex){
                         System.debug(LoggingLevel.INFO,'Exception type caught: ' + ex.getTypeName());    
                         System.debug(LoggingLevel.INFO,'Message: ' + ex.getMessage());    
                         System.debug(LoggingLevel.INFO,'Cause: ' + ex.getCause());    
                         System.debug(LoggingLevel.INFO,'Line number: ' + ex.getLineNumber());    
                         System.debug(LoggingLevel.INFO,'Stack trace: ' + ex.getStackTraceString());
                        throw new AuraHandledException(EXCEPTION_UPDATE_MESSAGE); 
                    }
            }
            else{
                throw new AuraHandledException(EXCEPTION_UPDATE_MESSAGE); 
            }
    }

}