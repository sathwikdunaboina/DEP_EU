/* 
* -----------------------------------------------------------------------------------------
* Apex Class Name     CLA_CreditLineCreateConsumptionService
* @author             Sourabh Sharma <sourabh.sharma@consultant.volvo.com>
* @Created Date       05-14-2024 
* @Used By     
* @Test Covered By    CLA_CreditLineCreateConsumption_Test        
* @SystemLayer        Service
* @URL Mapping        credit-lines/{creditLineIdentificationNumber}/consumption
* ------------------------------------------------------------------------------------------
* @description        This class is used to get consumption records.
* ------------------------------------------------------------------------------------------
* @Updates             Added Credit Line Description field upon consumption creation.
* Date                 15-07-2025
*----------------------------------------------------------------------------------------
* @Updates             Added Consumption Type field upon consumption creation.
* Date                 01-08-2025
*/

@RestResource(urlMapping='/credit-lines/*/consumption')
global with sharing class CLA_CreditLineCreateConsumptionService {

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     createCreditLineConsumption
* @description     Handles POST request to create creditline consumption record from API request body. 
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/

@HttpPost
global static void createCreditLineConsumption(){ 
  
    RestRequest request = RestContext.request;
    RestResponse response = RestContext.response;

   
    try{
        Map<String, Object> mapRequestParamValueByKey = (Map<String,Object>) JSON.deserializeUntyped(request.requestBody.toString());
        String sCreditLineIdentificationNumber = extractCreditLineIdentificationNumber(request.requestURI);
        
        if (validateRequestBody(mapRequestParamValueByKey)) {
            setResponse(response, 400, '{"error":"Bad Request"}');
            return;
        }

        List<CLA_Credit_Line__c> listCreditLineRecords = fetchCreditLineRecords(sCreditLineIdentificationNumber);
        if (listCreditLineRecords.isEmpty()) {
            setResponse(response, 404, '{"error":"Credit line not found"}');
            return;
        }
        if(validateCreditLineFields(listCreditLineRecords)){
            setResponse(response, 404, '{"error":"Can not create Consumption,Invalid creditline"}');
            return;
        }
        if(validateDrawnAmount(listCreditLineRecords,mapRequestParamValueByKey)){
            setResponse(response, 405, '{"error":"Requested amount is too high"}');
            return;
        }
        
        sObject oConsumption = createCreditLineConsumptionRecord(listCreditLineRecords,mapRequestParamValueByKey);
        if(oConsumption != null){
            setResponse(response, 200, JSON.serialize(oConsumption));
        }
        else{
            setResponse(response,404,'{"error":"Can not create consumption"}');
        }
        
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
* @return          String           Return creditline identification number
* ------------------------------------------------------------------------------------------------------ 
*/

private static String extractCreditLineIdentificationNumber(String sRequestURI) {
    String sCreditLineIdentificationNumber = sRequestURI.subString( sRequestURI.lastIndexOf('/',sRequestURI.lastIndexOf('/') - 1) + 1 , sRequestURI.lastIndexOf('/'));
    return (sCreditLineIdentificationNumber !=  '') ? sCreditLineIdentificationNumber : null;
}

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     createCreditLineConsumptionRecord
* @description     Create consumption record from request body.
* ------------------------------------------------------------------------------------------------------
* @param           listCreditLineRecords      Creditline list,List<CLA_Credit_Line__c>
* @param           mapRequestParamValueByKey             Request body map, Map<String, Object>
* @return          SObject                    Creditline consumption
* ------------------------------------------------------------------------------------------------------ 
*/

private static SObject createCreditLineConsumptionRecord(List<CLA_Credit_Line__c> listCreditLineRecords,Map<String, Object> mapRequestParamValueByKey) {

    String sQuoteNumber = getRequestParamValue(mapRequestParamValueByKey,'quoteNumber');
    String sQuoteMarket = getRequestParamValue(mapRequestParamValueByKey,'quoteMarket');
    String sCompanyIdentificationNumber = getRequestParamValue(mapRequestParamValueByKey,'companyIdentificationNumber');
    String sOrigin = getRequestParamValue(mapRequestParamValueByKey,'origin');
    String sdrawnDate = getRequestParamValue(mapRequestParamValueByKey,'drawnDate');
    Decimal dDrawnAmount = mapRequestParamValueByKey.get('drawnAmount') != null && mapRequestParamValueByKey.get('drawnAmount') != '' ?   (Decimal) mapRequestParamValueByKey.get('drawnAmount') : null;
    
 
    CLA_Credit_Line_Consumption__c oConsumption = new CLA_Credit_Line_Consumption__c();

    oConsumption.CLA_Company_Identification_Number__c = sCompanyIdentificationNumber;
    oConsumption.CLA_Quote_Number__c = sQuoteNumber;
    oConsumption.CLA_Quote_Market__c = sQuoteMarket;
    oConsumption.CLA_Quote_Origin__c = sOrigin;
    oConsumption.CLA_Drawn_Date__c = sdrawnDate;
    oConsumption.CLA_Status__c = 'Confirmed';
    oConsumption.CLA_Credit_Line__c = listCreditLineRecords[0].Id;
    oConsumption.CLA_Drawn_Amount__c = dDrawnAmount;
    oConsumption.CLA_Consumption_Type__c = 'Automatic';
    oConsumption.CLA_Credit_Line_Description__c = listCreditLineRecords[0].CLA_Credit_Line_Description__c;
    
    
    try{
        SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.CREATABLE, new CLA_Credit_Line_Consumption__c[] { oConsumption });
        system.debug(LoggingLevel.INFO,'securityDecision ==> '+securityDecision);
        insert securityDecision.getRecords()[0];
        
        List<CLA_Credit_Line_Consumption__c> listConsumptions = [Select Id,CLA_Company_Identification_Number__c,CLA_Quote_Number__c,CLA_Quote_Market__c,CLA_Consumption_Identification_Number__c,
                                                                CLA_Quote_Origin__c,CLA_Drawn_Date__c,CLA_Status__c,CLA_Drawn_Amount__c FROM CLA_Credit_Line_Consumption__c 
                                                                WHERE Id =: securityDecision.getRecords()[0].Id WITH USER_MODE LIMIT 1];

        if(!listConsumptions.IsEmpty()){
            return listConsumptions[0];
        }  
        else{
            return null;
        }                                                        
    }
    catch(exception ex){
      system.debug(LoggingLevel.INFO,ex.getMessage());
      return null;
    }

 }

private static List<CLA_Credit_Line__c> fetchCreditLineRecords(String sCreditLineIdentificationNumber) {
    return [
        SELECT Id,CLA_Credit_Line_identification_number__c,CLA_Status__c,CLA_Remaining_Amount__c,CLA_Total_Drawn_Amount__c,	CLA_Max_Allowed_Group_Exposure__c,CLA_Expiry_Date__c , CLA_Credit_Line_Description__c
        FROM CLA_Credit_Line__c WHERE CLA_Credit_Line_identification_number__c =: sCreditLineIdentificationNumber WITH USER_MODE  LIMIT 1
    ];
}

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     validateCreditLineFields
* @description     Validates credit line fields
* ------------------------------------------------------------------------------------------------------
* @param           listCreditLineRecords      Creditline list,List<CLA_Credit_Line__c>
* @return          Boolean                    Returns result of validation
* ------------------------------------------------------------------------------------------------------ 
*/

private static  Boolean validateCreditLineFields(List<CLA_Credit_Line__c> listCreditLineRecords) {
    if(listCreditLineRecords[0].CLA_Status__c != 'Approved' || listCreditLineRecords[0].CLA_Expiry_Date__c <= Date.today() ){
          return true;  
    }
    else{
        return false;
    }
}

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     validateDrawnAmount
* @description     Validates creditline remaining amount
* ------------------------------------------------------------------------------------------------------
* @param           listCreditLineRecords      Creditline list,List<CLA_Credit_Line__c>
* @return          Boolean                    Returns result of validation
* ------------------------------------------------------------------------------------------------------ 
*/

private static  Boolean validateDrawnAmount(List<CLA_Credit_Line__c> listCreditLineRecords , Map<String, Object> mapRequestParamValueByKey) {

    Decimal dRemainingBalance = 0;
    Decimal dDrawnAmount = mapRequestParamValueByKey.get('drawnAmount') != null ?   (Decimal) mapRequestParamValueByKey.get('drawnAmount') : 0;
    dRemainingBalance = listCreditLineRecords[0].CLA_Remaining_Amount__c - dDrawnAmount ;  
    
    if(dRemainingBalance < 0 || dDrawnAmount > 100000000){
        return true;
    }
    else{
        return false;
    }
    
}

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     validateRequestBody
* @description     Validates request body
* ------------------------------------------------------------------------------------------------------
* @param           mapRequestParamValueByKey        Map of request body,Map<String, Object>
* @return          Boolean               Returns result of validation
* ------------------------------------------------------------------------------------------------------ 
*/

private static Boolean validateRequestBody( Map<String, Object> mapRequestParamValueByKey){

    String sQuoteNumber = getRequestParamValue(mapRequestParamValueByKey,'quoteNumber');
    String sQuoteMarket = getRequestParamValue(mapRequestParamValueByKey,'quoteMarket');
    String sCompanyIdentificationNumber = getRequestParamValue(mapRequestParamValueByKey,'companyIdentificationNumber');
    String sOrigin = getRequestParamValue(mapRequestParamValueByKey,'origin');
    String sdrawnDate = getRequestParamValue(mapRequestParamValueByKey,'drawnDate');
    Decimal dDrawnAmount = mapRequestParamValueByKey.get('drawnAmount') != null && mapRequestParamValueByKey.get('drawnAmount') != '' ?   (Decimal) mapRequestParamValueByKey.get('drawnAmount') : null;
    

     if ( sQuoteMarket != null && sQuoteNumber != null && sCompanyIdentificationNumber != null && sOrigin != null &&
          sdrawnDate != null && dDrawnAmount != null) {
        return false;
     }
     else{
        return true;
     }
}

private static String getRequestParamValue( Map<String, Object> mapRequestParamValueByKey,String sKey){
    String sValue = mapRequestParamValueByKey.get(sKey) != null && mapRequestParamValueByKey.get(sKey) != '' ?  String.valueOf(mapRequestParamValueByKey.get(sKey)) : null;
    return sValue;
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