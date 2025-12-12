/*
* -----------------------------------------------------------------------------------------
* Apex Class Name     CLA_CreditLineControlsService
* @author             Sourabh Sharma <sourabh.sharma@consultant.volvo.com>
* @Created Date       05-14-2024 
* @Used By    
* @Test Covered By     CLA_CreditLineControlsService_Test         
* @SystemLayer        Service
* @URL Mapping        credit-lines/{creditLineIdentificationNumber}/controls/{creditLineControlIdentificationNumber}
* ------------------------------------------------------------------------------------------
* @description        This class is used for getting credit line control records for a credit line or specific credit line based on 
                      credit line control identification number.
* ------------------------------------------------------------------------------------------
 Update 
* @Date               04-16-2025
* @author             By Sourabh Sharma <sourabh.sharma@consultant.volvo.com>
* Description         Updated to accomodate credit securities with credit controls result
*/

@RestResource(urlMapping='/credit-lines/*/controls/*')
global with sharing class CLA_CreditLineControlsService { 

/*  
* ------------------------------------------------------------------------------------------------------
* @Method Name     getCreditLineControls
* @description     Handles GET request to get creditline control records for a specific credit line or 
                   specific credit line based on credit line control identification number.
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/ 

@HttpGet
global static void getCreditLineControls(){

    RestRequest request = RestContext.request;
    RestResponse response = RestContext.response;
    String sRequestURI = request.requestURI;
    String sIdentifier = sRequestURI.subString( sRequestURI.lastIndexOf('/',sRequestURI.lastIndexOf('/') - 1) + 1 , sRequestURI.lastIndexOf('/'));

    try {
        String sCreditLineIdentificationNumber = extractCreditLineIdentificationNumber(request.requestURI,sIdentifier);
        String sCreditLineControlIdentificationNumber = extractCreditLineControlIdentificationNumber(request.requestURI,sIdentifier);
        
        if (String.isBlank(sCreditLineIdentificationNumber) || sCreditLineIdentificationNumber == null) {
            setResponse(response, 400, '{"error":"Bad Request"}');
            return;
        }

        List<CLA_Credit_Line_Control__c> listCreditLineControls = fetchCreditLineControlsRecords(sCreditLineControlIdentificationNumber,sCreditLineIdentificationNumber,sIdentifier);
        if (listCreditLineControls.isEmpty()) {
            setResponse(response, 404, '{"error":"Credit line control not found"}');
            return;
        }

        List<SObject> listTransformedCreditLinesControlRecords = getTransformedCreditLineControlRecords(listCreditLineControls);
        if(sIdentifier == 'controls'){
            setResponse(response, 200, JSON.serialize(listTransformedCreditLinesControlRecords[0]));
        }
        else{
            setResponse(response, 200, JSON.serialize(listTransformedCreditLinesControlRecords));
        }
       
      
    }
    catch(Exception e){
        setResponse(response, 500, '{"error":"Internal Server error"}');
    }
}


/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     extractCreditLineIdentificationNumber
* @description     Get creditline identification number from request URI.
* ------------------------------------------------------------------------------------------------------
* @param           sRequestURI      Request URI from API request , String
  @param           sIdentifier      Parameter to distuinguish between specific control request or all controls for credit line , String
* @return          String           Return creditline identification number
* ------------------------------------------------------------------------------------------------------ 
*/

private static String extractCreditLineIdentificationNumber(String sRequestURI, String sIdentifier) {
    String sCreditLineIdentificationNumber = '';
    if(sIdentifier == 'controls'){
        sCreditLineIdentificationNumber = sRequestURI.subString( sRequestURI.lastIndexOf('/',sRequestURI.lastIndexOf('/',sRequestURI.lastIndexOf('/',sRequestURI.lastIndexOf('/') - 1)- 1)) + 1, 
        sRequestURI.lastIndexOf('/',sRequestURI.lastIndexOf('/',sRequestURI.lastIndexOf('/') - 1)));
        
        return  (sCreditLineIdentificationNumber !=  '') ? sCreditLineIdentificationNumber : null;
    }else{
        sCreditLineIdentificationNumber = sRequestURI.subString( sRequestURI.lastIndexOf('/',sRequestURI.lastIndexOf('/') - 1) + 1 , sRequestURI.lastIndexOf('/'));
        return  (sCreditLineIdentificationNumber !=  '') ? sCreditLineIdentificationNumber : null;
    }
}

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     extractCreditLineControlIdentificationNumber
* @description     Get creditline control identification number from request URI.
* ------------------------------------------------------------------------------------------------------
* @param           sRequestURI      Request URI from API request , String
  @param           sIdentifier      Parameter to distuinguish between specific control request or all controls for creditline , String
* @return          String           Return Creditline identification number
* ------------------------------------------------------------------------------------------------------ 
*/

private static String extractCreditLineControlIdentificationNumber(String sRequestURI, String sIdentifier) {
    String sCreditLineControlIdentificationNumber = '';
    if(sIdentifier == 'controls'){
        sCreditLineControlIdentificationNumber = sRequestURI.substring(sRequestURI.lastIndexOf('/')+1);
        return  (sCreditLineControlIdentificationNumber !=  '') ? sCreditLineControlIdentificationNumber : null;
     }else{
        return null;
   }
}

/* 
* ------------------------------------------------------------------------------------------------------
* @Method Name     fetchCreditLineControlsRecords
* @description     Get creditline control records for creditline identification number.
* ------------------------------------------------------------------------------------------------------
* @param           sCreditLineControlIdentificationNumber      Creditline control identification number, String
  @param           sCreditLineIdentificationNumber             Creditline  identification number, String
* @return          List<CLA_Credit_Line_Control__c>            Creditline control list
* ------------------------------------------------------------------------------------------------------ 
*/

private static List<CLA_Credit_Line_Control__c> fetchCreditLineControlsRecords(String sCreditLineControlIdentificationNumber,String sCreditLineIdentificationNumber, String sIdentifier) {

    /*if(sIdentifier == 'controls'){
        return [SELECT Id,CLA_Allow_Dealer_Lease_Line__c,CLA_Allow_Non_Standard_Payment__c,CLA_Allow_VAT_Deferral__c,CLA_Allowed_Maximum_RV_Percent__c,CLA_Allowed_Minimum_Down_Payment_Percent__c	,CLA_Asset_Category__c,CLA_Asset_Segment__c,CLA_Asset_Type__c,CLA_Business_Area__c,CLA_Chassis__c,CLA_Control_Description__c,CLA_CreditLineControlIdentificationNumbe__c,CLA_Engine_Type__c,CLA_Financial_Product_Type__c,CLA_Force_Referral__c,CLA_Max_Unit_Price__c,CLA_Term_From__c,CLA_Term_To__c
        FROM CLA_Credit_Line_Control__c WHERE 	CLA_CreditLineControlIdentificationNumbe__c =: sCreditLineControlIdentificationNumber AND CLA_Credit_Line__r.CLA_Credit_Line_identification_number__c =: sCreditLineIdentificationNumber WITH USER_MODE LIMIT 49999 ];
    }else{
        return [SELECT Id,CLA_Allow_Dealer_Lease_Line__c,CLA_Allow_Non_Standard_Payment__c,CLA_Allow_VAT_Deferral__c,CLA_Allowed_Maximum_RV_Percent__c,CLA_Allowed_Minimum_Down_Payment_Percent__c	,CLA_Asset_Category__c,CLA_Asset_Segment__c,CLA_Asset_Type__c,CLA_Business_Area__c,CLA_Chassis__c,CLA_Control_Description__c,CLA_CreditLineControlIdentificationNumbe__c,CLA_Engine_Type__c,CLA_Financial_Product_Type__c,CLA_Force_Referral__c,CLA_Max_Unit_Price__c,CLA_Term_From__c,CLA_Term_To__c
        FROM CLA_Credit_Line_Control__c WHERE CLA_Credit_Line__r.CLA_Credit_Line_identification_number__c =: sCreditLineIdentificationNumber WITH USER_MODE LIMIT 49999 ];
    }*/
    
    if(sIdentifier == 'controls'){
        return [SELECT Id,CLA_Allow_Dealer_Lease_Line__c,CLA_Allow_Non_Standard_Payment__c,CLA_Allow_VAT_Deferral__c,CLA_Allowed_Maximum_RV_Percent__c,CLA_Allowed_Minimum_Down_Payment_Percent__c	,CLA_Asset_Category__c,CLA_Asset_Segment__c,CLA_Asset_Type__c,CLA_Business_Area__c,CLA_Chassis__c,CLA_Control_Description__c,CLA_CreditLineControlIdentificationNumbe__c,CLA_Engine_Type__c,CLA_Financial_Product_Type__c,CLA_Force_Referral__c,CLA_Max_Unit_Price__c,CLA_Term_From__c,CLA_Term_To__c ,
                (SELECT Id,	CLA_Credit_Security_Name__c , CLA_Partner_Identification_Number__c , CLA_Partner_Name__c , CLA_Partner_VFS_Number__c FROM Credit_Line_Securities_Controls__r)
        FROM CLA_Credit_Line_Control__c WHERE 	CLA_CreditLineControlIdentificationNumbe__c =: sCreditLineControlIdentificationNumber AND CLA_Credit_Line__r.CLA_Credit_Line_identification_number__c =: sCreditLineIdentificationNumber WITH USER_MODE LIMIT 49999 ];
    }else{
        return [SELECT Id,CLA_Allow_Dealer_Lease_Line__c,CLA_Allow_Non_Standard_Payment__c,CLA_Allow_VAT_Deferral__c,CLA_Allowed_Maximum_RV_Percent__c,CLA_Allowed_Minimum_Down_Payment_Percent__c	,CLA_Asset_Category__c,CLA_Asset_Segment__c,CLA_Asset_Type__c,CLA_Business_Area__c,CLA_Chassis__c,CLA_Control_Description__c,CLA_CreditLineControlIdentificationNumbe__c,CLA_Engine_Type__c,CLA_Financial_Product_Type__c,CLA_Force_Referral__c,CLA_Max_Unit_Price__c,CLA_Term_From__c,CLA_Term_To__c , 
                (SELECT Id,CLA_Credit_Security_Name__c , CLA_Partner_Identification_Number__c , CLA_Partner_Name__c , CLA_Partner_VFS_Number__c FROM Credit_Line_Securities_Controls__r)
        FROM CLA_Credit_Line_Control__c WHERE CLA_Credit_Line__r.CLA_Credit_Line_identification_number__c =: sCreditLineIdentificationNumber WITH USER_MODE LIMIT 49999 ];
    }
    
    
}

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     getTransformedConsumptionRecords
* @description     Get transformed records by assigning default values to blank fields and 
                   adds them in record list.
* ------------------------------------------------------------------------------------------------------
* @param           listCreditLineControlRecords               Creditline control list , List<CLA_Credit_Line_Control__c>
* @return          List<SObject>                              Transformed Creditline control list
* ------------------------------------------------------------------------------------------------------ 
*/

private static List<SObject> getTransformedCreditLineControlRecords(List<CLA_Credit_Line_Control__c> listCreditLineControlRecords) {
    Set<String> setFields = new Set<String>{
        'Id','CLA_Allow_Dealer_Lease_Line__c','CLA_Allow_Non_Standard_Payment__c','CLA_Allow_VAT_Deferral__c','CLA_Allowed_Maximum_RV_Percent__c',
        'CLA_Allowed_Minimum_Down_Payment_Percent__c','CLA_Asset_Category__c','CLA_Asset_Segment__c','CLA_Asset_Type__c','CLA_Business_Area__c',
        'CLA_Chassis__c','CLA_Control_Description__c','CLA_CreditLineControlIdentificationNumbe__c','CLA_Engine_Type__c','CLA_Financial_Product_Type__c',
        'CLA_Force_Referral__c','CLA_Max_Unit_Price__c','CLA_Term_From__c','CLA_Term_To__c'
    };
        
        Set<String> setRelatedFields = new Set<String>{
        'CLA_Partner_Identification_Number__c',
        'CLA_Partner_Name__c' , 'CLA_Partner_VFS_Number__c' , 
        'CLA_Credit_Security_Name__c'
      };

    CLA_UtilityService.InputParameters inputParametersInstance = new CLA_UtilityService.InputParameters();
    inputParametersInstance.sObjectName = 'CLA_Credit_Line_Control__c';
    inputParametersInstance.listSObjects = listCreditLineControlRecords;
    inputParametersInstance.setFields = setFields;
    inputParametersInstance.sRelatedObjectName = 'CLA_Credit_Line_Security_Control__c';
    inputParametersInstance.sRelatedRelationshipName = 'Credit_Line_Securities_Controls__r';
    inputParametersInstance.setRelatedFields = setRelatedFields;

    return CLA_UtilityService.transformSObjectToApicFormat(inputParametersInstance);
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