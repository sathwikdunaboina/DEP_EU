/* 
* -----------------------------------------------------------------------------------------
* Apex Class Name     CLA_CalloutMock_Test
* @author             Sourabh Sharma <sourabh.sharma@consultant.volvo.com>
* @Created Date       06-18-2024 
* @Used By            CLA_ValidateCreditLineCustLwcCont_Test
* ------------------------------------------------------------------------------------------
* @description        This class is used for generating Mock response for callout.
* ------------------------------------------------------------------------------------------
*/
@isTest 
public class CLA_CalloutMock_Test implements HttpCalloutMock{

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     respond
* @description     Handles Mock response generation
* ------------------------------------------------------------------------------------------------------
* @param        req           httpsRequest  
* @return       HTTPResponse  Returns mock response 
* ------------------------------------------------------------------------------------------------------ 
*/

    public HTTPResponse respond(HTTPRequest req) { 
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"example":"test"}');
        res.setStatusCode(200);
        return res;
    } 

}