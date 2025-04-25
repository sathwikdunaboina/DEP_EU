/* 
* -----------------------------------------------------------------------------------------
* Apex Class Name     CLA_CreditLineConsumptionSevice
* @author             Sourabh Sharma <sourabh.sharma@consultant.volvo.com>
* @Created Date       05-14-2024 
* @Used By             
* @Test Covered By    CLA_CreditLineConsumptionService_Test
* @SystemLayer        Service
* @URL Mapping        credit-lines/{creditLineIdentificationNumber}/consumptions
* ------------------------------------------------------------------------------------------
* @description        This class is used for getting cusumption records for a credit line.
* ------------------------------------------------------------------------------------------
*/

@RestResource(urlMapping='/credit-lines/*/consumptions')
global with sharing class CLA_CreditLineConsumptionService {

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     getCreditLineConsumptions
* @description     Handles GET request to get creditline consumptions records for a specific credit line.
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/ 

@HttpGet
global static void getCreditLineConsumptions() {
    RestRequest request = RestContext.request;
    RestResponse response = RestContext.response;

    try {
        String sCreditLineIdentificationNumber = extractCreditLineIdentificationNumber(request.requestURI);
        
        if (String.isBlank(sCreditLineIdentificationNumber)) {
            setResponse(response, 400, '{"error":"Bad Request"}');
            return;
        }

        List<CLA_Credit_Line_Consumption__c> listConsumptionRecords = fetchConsumptionRecords(sCreditLineIdentificationNumber);

        if (listConsumptionRecords.isEmpty()) {
            setResponse(response, 404, '{"error":"No consumption records found for the provided Credit Line Identification Number"}');
            return;
        }

        List<SObject> listTransformedConsumptionRecords = getTransformedConsumptionRecords(listConsumptionRecords);
        setResponse(response, 200, JSON.serialize(listTransformedConsumptionRecords));

    } catch (Exception e) {
        //Log Error using error login framework
        setResponse(response, 500, '{"error":"Internal Server error"}');
    }
}

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     extractCreditLineIdentificationNumber
* @description     Get creditline identification number from request URI.
* ------------------------------------------------------------------------------------------------------
* @param           requestURI      Request URI from API request , String
* @return          String          Creditline identification number
* ------------------------------------------------------------------------------------------------------ 
*/

private static String extractCreditLineIdentificationNumber(String sRequestURI) {
    String sCreditLineIdentificationNumber =sRequestURI.subString( sRequestURI.lastIndexOf('/',sRequestURI.lastIndexOf('/') - 1) + 1 , sRequestURI.lastIndexOf('/'));
    return (sCreditLineIdentificationNumber !=  '') ? sCreditLineIdentificationNumber : null;
}

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     fetchConsumptionRecords
* @description     Get consumption records for creditline identification number.
* ------------------------------------------------------------------------------------------------------
* @param           sCreditLineIdentificationNumber         Creditline identification number from request URI , String
* @return          List<CLA_Credit_Line_Consumption__c>    Creditline consumption list
* ------------------------------------------------------------------------------------------------------ 
*/

private static List<CLA_Credit_Line_Consumption__c> fetchConsumptionRecords(String sCreditLineIdentificationNumber) {
    return [
        SELECT Id, CLA_Company_Identification_Number__c, CLA_Consumption_Identification_Number__c, CLA_Drawn_Amount__c, 
               CLA_Drawn_Date__c, CLA_Quote_Market__c, CLA_Quote_Number__c, CLA_Quote_Origin__c, CLA_Status__c, 
               CLA_Credit_Line__r.CLA_Credit_Line_identification_number__c
        FROM CLA_Credit_Line_Consumption__c 
        WHERE CLA_Credit_Line__r.CLA_Credit_Line_identification_number__c = :sCreditLineIdentificationNumber AND 
              CLA_Status__c = 'Confirmed'
        WITH USER_MODE LIMIT 49999
    ];
}

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     getTransformedConsumptionRecords
* @description     Get transformed records by assigning default values to blank fields and 
                   adds them in record list.
* ------------------------------------------------------------------------------------------------------
* @param           listConsumptionRecords       Creditline consumption list , List<CLA_Credit_Line_Consumption__c>
* @return          List<SObject>                Transformed Creditline consumption list
* ------------------------------------------------------------------------------------------------------ 
*/

private static List<SObject> getTransformedConsumptionRecords(List<CLA_Credit_Line_Consumption__c> listConsumptionRecords) {
    Set<String> setFields = new Set<String>{
        'Id', 'CLA_Company_Identification_Number__c', 'CLA_Consumption_Identification_Number__c', 'CLA_Drawn_Amount__c', 
        'CLA_Drawn_Date__c', 'CLA_Quote_Market__c', 'CLA_Quote_Number__c', 'CLA_Quote_Origin__c', 'CLA_Status__c'
    };

    CLA_UtilityService.InputParameters inputParametersInstance = new CLA_UtilityService.InputParameters();
    inputParametersInstance.sObjectName = 'CLA_Credit_Line_Consumption__c';
    inputParametersInstance.listSObjects = listConsumptionRecords;
    inputParametersInstance.setFields = setFields;

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