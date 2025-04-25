/*
* -----------------------------------------------------------------------------------------
* Apex Class Name     CLA_CreditLineService
* @author             Sourabh Sharma <sourabh.sharma@consultant.volvo.com>
* @Created Date       05-14-2024 
* @Used By             
* @Test Covered By    CLA_CreditLineService_Test
* @SystemLayer        Service
* @URL Mapping        credit-lines/{creditLineIdentificationNumber}
* ------------------------------------------------------------------------------------------
* @description        This class is used to get creditline reocrds.
* ------------------------------------------------------------------------------------------
*/

@RestResource(urlMapping='/credit-lines/*')
global with sharing class CLA_CreditLineService {

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     createCreditLineConsumption
* @description     Handles Get request to get creditline record along with customer data. 
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/

@HttpGet 
global static void getCreditLines() {

    RestRequest request = RestContext.request;
    RestResponse response = RestContext.response;

    try {

        String sCreditLineIdentificationNumber = extractCreditLineIdentificationNumber(request.requestURI);
        if (String.isBlank(sCreditLineIdentificationNumber) || sCreditLineIdentificationNumber == null) {
            setResponse(response, 400, '{"error":"Bad Request"}');
            return;
        }

        List<CLA_Credit_Line__c> listCreditLineRecords = fetchCreditLineRecords(sCreditLineIdentificationNumber);
      
        if (listCreditLineRecords.isEmpty()) {
            setResponse(response, 404, '{"error":"Credit line not found"}');
            return;
        }

        List<SObject> listTransformedCreditLinesRecords = getTransformedCreditLineRecords(listCreditLineRecords);
        setResponse(response, 200, JSON.serialize(listTransformedCreditLinesRecords[0]));
    }
    catch (Exception e) {
        setResponse(response, 500, '{"error":"Internal Server error"}');
    }
}

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     extractCreditLineIdentificationNumber
* @description     Get creditline identification number from request URI.
* ------------------------------------------------------------------------------------------------------
* @param           sRequestURI      Request URI from API request , String
* @return          String           Return Creditline odentification number
* ------------------------------------------------------------------------------------------------------ 
*/

private static String extractCreditLineIdentificationNumber(String sRequestURI) {
    String sCreditLineIdentificationNumber = sRequestURI.subString( sRequestURI.lastIndexOf('/',sRequestURI.lastIndexOf('/') )+1);
    return (sCreditLineIdentificationNumber !=  '') ? sCreditLineIdentificationNumber : null;
}


/* 
* ------------------------------------------------------------------------------------------------------
* @Method Name     fetchCreditLineRecords
* @description     Get creditline records for creditline identification number.
* ------------------------------------------------------------------------------------------------------
* @param           sCreditLineIdentificationNumber      Creditline identification number, String
* @return          List<CLA_Credit_Line__c>             Creditline list
* ------------------------------------------------------------------------------------------------------ 
*/

private static List<CLA_Credit_Line__c> fetchCreditLineRecords(String sCreditLineIdentificationNumber) {
   
    return [
        SELECT Id,CLA_Credit_Line_identification_number__c,CLA_Activation_Date__c,CLA_Approval_Date__c, CLA_Approved_Limit__c ,CLA_Country__c,CLA_Credit_Line_Description__c,CLA_Currency__c,CLA_Expiry_Date__c,CLA_Max_Allowed_Group_Exposure__c,CLA_Remaining_Amount__c,CLA_Status__c,CLA_Type__c,
        (SELECT CLA_Company_Identification_Number__c,CLA_Credit_Bureau_Number__c,CLA_Credit_Line__c,CLA_Credit_line_Grade__c,Name,CLA_Use_ACE_Grade__c,CLA_VFS_Customer_Number__c  FROM Credit_Line_Customers__r 
        WHERE CLA_Credit_Line__r.CLA_Credit_Line_identification_number__c =: sCreditLineIdentificationNumber) 
        FROM CLA_Credit_Line__c WHERE CLA_Credit_Line_identification_number__c =: sCreditLineIdentificationNumber WITH USER_MODE  LIMIT 1
    ];

}


/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     getTransformedCreditLineRecords
* @description     Get transformed records by assigning default values to blank fields and 
                   adds them in record list.
* ------------------------------------------------------------------------------------------------------
* @param           listCreditLineRecords               Creditline list , List<CLA_Credit_Line__c>
* @return          List<SObject>                       Transformed Creditline control list
* ------------------------------------------------------------------------------------------------------ 
*/

private static List<SObject> getTransformedCreditLineRecords(List<CLA_Credit_Line__c> listCreditLineRecords) {
    Set<String> setFields = new Set<String>{
        'Id','CLA_Credit_Line_identification_number__c','CLA_Activation_Date__c','CLA_Approval_Date__c', 'CLA_Approved_Limit__c' ,'CLA_Country__c','CLA_Credit_Line_Description__c',
        'CLA_Currency__c','CLA_Expiry_Date__c','CLA_Max_Allowed_Group_Exposure__c','CLA_Remaining_Amount__c','CLA_Status__c','CLA_Type__c'
    };

    Set<String> setRelatedFields = new Set<String>{
        'CLA_Company_Identification_Number__c','CLA_Credit_Bureau_Number__c','CLA_Credit_Line__c','CLA_Credit_line_Grade__c','Name','CLA_Use_ACE_Grade__c',
        'CLA_VFS_Customer_Number__c'
      };

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