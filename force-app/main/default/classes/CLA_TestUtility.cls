/* 
* -----------------------------------------------------------------------------------------
* Apex Class Name     CLA_TestUtility
* @author             Sourabh Sharma <sourabh.sharma@consultant.volvo.com> 
* @Created Date       05-17-2024      
* @Used By            CLA_CreditLineConsumptionService_Test,CLA_CreditLineControlsService_Test,CLA_CreditLineCreateConsumption_Test
*                     CLA_CreditlineSearchService,CLA_CreditLineService
* @Test Covered By    CLA_TestUtility_Test     
* ------------------------------------------------------------------------------------------
* @description        Utility class for test classes
* ------------------------------------------------------------------------------------------
*/
public with sharing class CLA_TestUtility { 

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     getTestResponse
* @description     Prepare response 
* ------------------------------------------------------------------------------------------------------
* @param           sRequestURI       request URL, String
* @param           sRequestMethod    http method, String
* @return          RestResponse      response
* ------------------------------------------------------------------------------------------------------ 
*/
    
    public static RestResponse getTestResponse(String sRequestURI,String sRequestMethod){

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = sRequestURI;
        req.httpMethod = sRequestMethod;
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = res;

        return res; 

    }

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     getTestResponse
* @description     Prepare response 
* ------------------------------------------------------------------------------------------------------
* @param           sRequestURI       request URL, String
* @param           sRequestMethod    http method, String
* @return          RestResponse      response
* ------------------------------------------------------------------------------------------------------ 
*/

    public static RestResponse getTestResponse(String sRequestURI,String sRequestMethod,String sRequestBody){

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = sRequestURI;
        req.requestBody = Blob.valueOf(sRequestBody);
        req.httpMethod = sRequestMethod;
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = res;

        return res;

    }
}