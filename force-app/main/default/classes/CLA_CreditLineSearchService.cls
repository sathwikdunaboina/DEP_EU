/*
* -----------------------------------------------------------------------------------------
* Apex Class Name     CLA_CreditLineSearchService
* @author             Sourabh Sharma <sourabh.sharma@consultant.volvo.com>
* @Created Date       05-14-2024 
* @Used By           
* @Test Covered By    CLA_CreditLineSearchService_Test
* @SystemLayer        Service
* @URL Mapping        credit-lines/search
* ------------------------------------------------------------------------------------------
* @description        This class is used to get creditline records based of matching conditions.
* ------------------------------------------------------------------------------------------
*/

@RestResource(urlMapping='/credit-lines/search')
global with sharing class CLA_CreditLineSearchService {

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     getMatchedCreditLines
* @description     Handles POST request to get creditline records based on matching conditions. 
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/

@HttpPost
global static void getMatchedCreditLines() {

    RestRequest request = RestContext.request;
    RestResponse response = RestContext.response;

    Map<String, Object> mapRequestParamValueByKey = (Map<String,Object>) JSON.deserializeUntyped(request.requestBody.toString());

    try {
        
        if (validateRequestBody(mapRequestParamValueByKey)) {
            setResponse(response, 400, '{"error":"Bad Request"}');
            return;
        }

        List<CLA_Credit_Line__c> listCreditLineRecords = fetchCreditLineRecords(mapRequestParamValueByKey);
        if (listCreditLineRecords.isEmpty()) {
            setResponse(response, 404, '{"error":"Credit line not found"}');
            return;
        }

        List<SObject> listTransformedCreditLinesRecords = getTransformedCreditLineRecords(listCreditLineRecords);
        setResponse(response, 200, JSON.serialize(listTransformedCreditLinesRecords));
    }
    catch (Exception e) {
        setResponse(response, 500, '{"error":"Internal Server error"}');
    }
}

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     validateRequestBody
* @description     Validates request body
* ------------------------------------------------------------------------------------------------------
* @param           mapRequestParamValueByKey        Map of request body,Map<String, Object>
* @return          Boolean                          Returns result of validation
* ------------------------------------------------------------------------------------------------------ 
*/

private static Boolean validateRequestBody( Map<String, Object> mapRequestParamValueByKey){

    
    String sBussinessArea = mapRequestParamValueByKey.get('businessArea') != null ?  String.valueOf(mapRequestParamValueByKey.get('businessArea')) : '';
    String sCountry = mapRequestParamValueByKey.get('country') != null ?  String.valueOf(mapRequestParamValueByKey.get('country')) : '';
    String sCompanyIdentificationNumber = mapRequestParamValueByKey.get('companyIdentificationNumber') != null ?  String.valueOf(mapRequestParamValueByKey.get('companyIdentificationNumber')) : '';
    String sVfsCustomerNumber = mapRequestParamValueByKey.get('vfsCustomerNumber') != null ?  String.valueOf(mapRequestParamValueByKey.get('vfsCustomerNumber')) : '';

     if ( sBussinessArea != '' && sCountry != '' && (sCompanyIdentificationNumber != '' || sVfsCustomerNumber != '')  ) {
        return false;
     }
     else{
        return true;
     }
}

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     getTransformedConsumptionRecords
* @description     Get transformed records by assigning default values to blank fields and 
                   adds them in record list.
* ------------------------------------------------------------------------------------------------------
* @param           listCreditLineRecords               Creditline list , List<CLA_Credit_Line__c>
* @return          List<SObject>                       Transformed Creditline control list
* ------------------------------------------------------------------------------------------------------ 
*/

private static List<SObject> getTransformedCreditLineRecords(List<CLA_Credit_Line__c> listCreditLineRecords) {
    Set<String> setFields = new set<String>{
        'Id','CLA_Credit_Line_identification_number__c','CLA_Activation_Date__c','CLA_Approval_Date__c', 'CLA_Approved_Limit__c' ,'CLA_Country__c','CLA_Credit_Line_Description__c',
        'CLA_Currency__c','CLA_Expiry_Date__c','CLA_Max_Allowed_Group_Exposure__c','CLA_Remaining_Amount__c','CLA_Status__c','CLA_Type__c'
    };

    Set<String> setRelatedFields = new Set<String>{
        'CLA_Company_Identification_Number__c','CLA_Credit_Bureau_Number__c','CLA_Credit_Line__c','CLA_Credit_line_Grade__c','Name','CLA_Use_ACE_Grade__c',
        'CLA_VFS_Customer_Number__c'
      };

    //InputParameters inputParametersInstance = new InputParameters();
    CLA_UtilityService.InputParameters inputParametersInstance = new CLA_UtilityService.InputParameters();
    inputParametersInstance.sObjectName = 'CLA_Credit_Line__c';
    inputParametersInstance.sRelatedObjectName = 'CLA_Credit_Line_Account__c';
    inputParametersInstance.sRelatedRelationshipName = 'Credit_Line_Customers__r'; 
    inputParametersInstance.listSObjects = listCreditLineRecords;
    inputParametersInstance.setFields = setFields;
    inputParametersInstance.setRelatedFields = setRelatedFields;
   
    return CLA_UtilityService.transformSObjectToApicFormat( inputParametersInstance);
}

/* 
* ------------------------------------------------------------------------------------------------------
* @Method Name     fetchCreditLineRecords
* @description     Get creditline records with matching conditions.
* ------------------------------------------------------------------------------------------------------
* @param           mapRequestParamValueByKey           Map of request body,Map<String, Object>
* @return          List<CLA_Credit_Line__c>            Creditline list
* ------------------------------------------------------------------------------------------------------ 
*/ 

private static List<CLA_Credit_Line__c> fetchCreditLineRecords(Map<String, Object> mapRequestParamValueByKey) {

    String sBussinessArea = mapRequestParamValueByKey.get('businessArea') != null ?  String.valueOf(mapRequestParamValueByKey.get('businessArea')) : '';
    String sCountry = mapRequestParamValueByKey.get('country') != null ?  String.valueOf(mapRequestParamValueByKey.get('country')) : '';
    String sCompanyIdentificationNumber = mapRequestParamValueByKey.get('companyIdentificationNumber') != null ?  String.valueOf(mapRequestParamValueByKey.get('companyIdentificationNumber')) : '';
    String sVfsCustomerNumber = mapRequestParamValueByKey.get('vfsCustomerNumber') != null ?  String.valueOf(mapRequestParamValueByKey.get('vfsCustomerNumber')) : '';

    List<CLA_Credit_Line__c> listCreditLineRecords = new List<CLA_Credit_Line__c>();
    
    if(sCompanyIdentificationNumber != '' && sVfsCustomerNumber != ''){
         listCreditLineRecords = [
            SELECT Id ,
            (SELECT CLA_Credit_Line__c,CLA_VFS_Customer_Number__c,CLA_Company_Identification_Number__c  FROM Credit_Line_Customers__r 
             WHERE CLA_Company_Identification_Number__c =: sCompanyIdentificationNumber OR CLA_VFS_Customer_Number__c =: sVfsCustomerNumber) ,
            (SELECT Id  FROM Credit_Line_Controls__r WHERE CLA_Business_Area__c =: sBussinessArea ) 
             FROM CLA_Credit_Line__c 
             WHERE CLA_Country__c =: sCountry AND CLA_Activation_Date__c <= TODAY AND CLA_Status__c = 'Approved' AND
             CLA_Remaining_Amount__c > 0 AND CLA_Expiry_Date__c > TODAY WITH USER_MODE LIMIT 49999
        ];
       }
    else if(sCompanyIdentificationNumber != '' && sVfsCustomerNumber == ''){
       
        listCreditLineRecords = [
            SELECT Id ,
            (SELECT CLA_Credit_Line__c,CLA_VFS_Customer_Number__c,CLA_Company_Identification_Number__c  FROM Credit_Line_Customers__r 
             WHERE CLA_Company_Identification_Number__c =: sCompanyIdentificationNumber) ,
            (SELECT Id  FROM Credit_Line_Controls__r WHERE CLA_Business_Area__c =: sBussinessArea ) 
             FROM CLA_Credit_Line__c 
             WHERE CLA_Country__c =: sCountry AND CLA_Activation_Date__c <= TODAY AND CLA_Status__c = 'Approved' AND
             CLA_Remaining_Amount__c > 0 AND CLA_Expiry_Date__c > TODAY  WITH USER_MODE LIMIT 49999
        ];
    }
    else if(sVfsCustomerNumber != '' && sCompanyIdentificationNumber == ''){
        listCreditLineRecords = [
            SELECT Id ,
            (SELECT CLA_Credit_Line__c,CLA_VFS_Customer_Number__c,CLA_Company_Identification_Number__c  FROM Credit_Line_Customers__r 
             WHERE CLA_VFS_Customer_Number__c =: sVfsCustomerNumber) ,
            (SELECT Id  FROM Credit_Line_Controls__r WHERE CLA_Business_Area__c =: sBussinessArea ) 
             FROM CLA_Credit_Line__c 
             WHERE CLA_Country__c =: sCountry AND CLA_Activation_Date__c <= TODAY AND CLA_Status__c = 'Approved' AND
             CLA_Remaining_Amount__c > 0 AND CLA_Expiry_Date__c > TODAY  WITH USER_MODE LIMIT 49999
        ];
    }
    
    
    List<CLA_Credit_Line__c> listCreditLineFilteredRecords = new List<CLA_Credit_Line__c>();
    if(listCreditLineRecords.IsEmpty()){
      return listCreditLineFilteredRecords;
    }
    listCreditLineFilteredRecords = filterCreditLineRecords(listCreditLineRecords);
    return listCreditLineFilteredRecords;
}

/* 
* ------------------------------------------------------------------------------------------------------
* @Method Name     filterCreditLineRecords
* @description     Filter creditline records.
* ------------------------------------------------------------------------------------------------------
* @param           listCreditLineRecords               Creditline list
* @return          List<CLA_Credit_Line__c>            Creditline list
* ------------------------------------------------------------------------------------------------------ 
*/

private static  List<CLA_Credit_Line__c> filterCreditLineRecords(List<CLA_Credit_Line__c> listCreditLineRecords){
    List<CLA_Credit_Line__c> listCreditLineFilteredRecords = new List<CLA_Credit_Line__c>();
    Set<Id>setCreditLineId = new Set<Id>();
    if(!listCreditLineRecords.IsEmpty()){
       for(CLA_Credit_Line__c oCreditLine : listCreditLineRecords){
            if( (oCreditLine.Credit_Line_Controls__r.size() > 0) && (oCreditLine.Credit_Line_Customers__r.size() > 0)){
                setCreditLineId.add(oCreditLine.Id);
            }

       }
    }

    listCreditLineFilteredRecords =  [
        SELECT Id,CLA_Credit_Line_identification_number__c,CLA_Activation_Date__c,CLA_Approval_Date__c, CLA_Approved_Limit__c ,CLA_Country__c,CLA_Credit_Line_Description__c,CLA_Currency__c,CLA_Expiry_Date__c,CLA_Max_Allowed_Group_Exposure__c,CLA_Remaining_Amount__c,CLA_Status__c,CLA_Type__c,
        (SELECT CLA_Company_Identification_Number__c,CLA_Credit_Bureau_Number__c,CLA_Credit_Line__c,CLA_Credit_line_Grade__c,Name,CLA_Use_ACE_Grade__c,CLA_VFS_Customer_Number__c  FROM Credit_Line_Customers__r ) 
         FROM CLA_Credit_Line__c WHERE Id IN :  setCreditLineId  WITH USER_MODE LIMIT 49999
    ];
    
    return listCreditLineFilteredRecords;
}


/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     setResponse
* @description     This method sets response.
* ------------------------------------------------------------------------------------------------------
* @param           response               API Response , RestResponse
* @param           iStatusCode            Response status code to set , Integer
* @param           sResponseBody          Response body converted to string
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/

private static void setResponse(RestResponse response, Integer iStatusCode, String sResponseBody) {
    response.addHeader('Content-Type', 'application/json');
    response.statusCode = iStatusCode;
    response.responseBody = Blob.valueOf(sResponseBody);
}
}