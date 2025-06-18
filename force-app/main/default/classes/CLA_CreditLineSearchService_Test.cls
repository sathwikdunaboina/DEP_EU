/* 
* -----------------------------------------------------------------------------------------
* Apex Class Name     CLA_CreditLineSearchService_Test
* @author             Sourabh Sharma <sourabh.sharma@consultant.volvo.com> 
* @Created Date       05-17-2024         
* ------------------------------------------------------------------------------------------
* @description        This class is used to test CLA_CreditLineSearchService
* ------------------------------------------------------------------------------------------
*/
@isTest
private  class CLA_CreditLineSearchService_Test {
    
/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     setUpData
* @description     Used to prepare test setup data
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/ 
    @testSetup static void setUpData() {
        
         User oIntegrationUser = CLA_TestDataFactory.createUser('Minimum Access - API Only Integrations');
        PermissionSet ps = [SELECT Id 
                    FROM PermissionSet 
                    WHERE Name = 'CLA_Credit_Manager_PS'];

        try {
            insert new PermissionSetAssignment(AssigneeId = oIntegrationUser.Id, PermissionSetId = ps.Id);
        } catch(DmlException e) {
            System.debug(LoggingLevel.INFO,'The following exception has occurred: ' + e.getMessage());
        }

        System.runAs(oIntegrationUser){ 
            CLA_TestDataFactory.createCreditLine(true,true);
        }
    } 

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testGetMatchedCreditLinesValidCreditLine
* @description     This method test CLA_CreditLineSearchService for valid Creditline. 
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/

    @isTest
    private static void testGetMatchedCreditLinesValidCreditLine(){

        User oIntegrationUser = [Select Id , country FROM user where Username = 'clatestuser@cla.com' LIMIT 1];
        System.runAs(oIntegrationUser){
            
        String requestBody = '{"country":"NL","businessArea":"VT","companyIdentificationNumber":"1234","vfsCustomerNumber":"1234567890"}';
        String sRequestURI = '/services/apexrest/credit-lines/search';
        RestResponse res =  CLA_TestUtility.getTestResponse(sRequestURI , 'POST',requestBody);

        Test.startTest();
        CLA_CreditLineSearchService.getMatchedCreditLines();
        Test.stopTest();

        System.assertEquals(200, res.statusCode, 'Expected status code is 200.');
        System.assert(res.responseBody.toString().contains('CLA_Credit_Line_Description__c'), 'Expected "Keys present" in response body.');
        }
    }

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testGetMatchedCreditLinesValidCreditLineAndVFSBlank
* @description     This method test CLA_CreditLineSearchService for valid Creditline and blank VFS Number. 
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/

    @isTest
    private static void testGetMatchedCreditLinesValidCreditLineAndVFSBlank(){

        User oIntegrationUser = [Select Id FROM user where Username = 'clatestuser@cla.com' LIMIT 1];
        System.runAs(oIntegrationUser){
        List<CLA_Credit_Line__c> listCreditLine = [SELECT Id,CLA_Credit_Line_identification_number__c ,CLA_Company_Identification_Number__c,CLA_VFS_Customer_Number__c
                                                   FROM CLA_Credit_Line__c 
                                                   WHERE CLA_Status__c = 'Approved' LIMIT 1];

        String requestBody = '{"country":"NL","businessArea":"VT","companyIdentificationNumber":'+'"'+listCreditLine[0].CLA_Company_Identification_Number__c +'"'+',"vfsCustomerNumber":""}';
        String sRequestURI = '/services/apexrest/credit-lines/search';
        RestResponse res =  CLA_TestUtility.getTestResponse(sRequestURI , 'POST',requestBody);

        Test.startTest();
        CLA_CreditLineSearchService.getMatchedCreditLines();
        Test.stopTest();

        System.assertEquals(200, res.statusCode, 'Expected status code is 200.');
        System.assert(res.responseBody.toString().contains('CLA_Credit_Line_Description__c'), 'Expected "Keys present" in response body.');
        }
    }
    

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testGetMatchedCreditLinesValidCreditLineAndCIDBlank
* @description     This method test CLA_CreditLineSearchService for valid Creditline and blank company identification number. 
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/

    @isTest
    private static void testGetMatchedCreditLinesValidCreditLineAndCIDBlank(){

        User oIntegrationUser = [Select Id FROM user where Username = 'clatestuser@cla.com' LIMIT 1];
        System.runAs(oIntegrationUser){
        String requestBody = '{"country":"NL","businessArea":"VT","companyIdentificationNumber":"","vfsCustomerNumber":"1234567890"}';
        String sRequestURI = '/services/apexrest/credit-lines/search';
        RestResponse res =  CLA_TestUtility.getTestResponse(sRequestURI , 'POST',requestBody);

        Test.startTest();
        CLA_CreditLineSearchService.getMatchedCreditLines();
        Test.stopTest();

        System.assertEquals(200, res.statusCode, 'Expected status code is 200.');
        System.assert(res.responseBody.toString().contains('CLA_Credit_Line_Description__c'), 'Expected "Keys present" in response body.');
        }
    }

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testGetMatchedCreditLinesInvalidCreditline
* @description     This method test CLA_CreditLineSearchService for invalid Creditline. 
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/

@isTest
private static void testGetMatchedCreditLinesInvalidCreditline(){

    User oIntegrationUser = [Select Id FROM user where Username = 'clatestuser@cla.com' LIMIT 1];
    System.runAs(oIntegrationUser){

    String requestBody = '{"country":"NL","businessArea":"VT","companyIdentificationNumber":"12345678901234","vfsCustomerNumber":"12345678901212122"}';
    String sRequestURI = '/services/apexrest/credit-lines/search';
    RestResponse res =  CLA_TestUtility.getTestResponse(sRequestURI , 'POST',requestBody);

    Test.startTest();
    CLA_CreditLineSearchService.getMatchedCreditLines();
    Test.stopTest();

    System.assertEquals(404, res.statusCode, 'Expected status code is 404.');
    System.assert(res.responseBody.toString().contains('Credit line not found'), 'Expected "Credit line not found" in response body.');
    }
}

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testGetMatchedCreditLinesInvalidRequestBody
* @description     This method test CLA_CreditLineSearchService for invalid requestbody. 
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/

@isTest
private static void testGetMatchedCreditLinesInvalidRequestBody(){

    User oIntegrationUser = [Select Id FROM user where Username = 'clatestuser@cla.com' LIMIT 1];
    System.runAs(oIntegrationUser){

    String requestBody = '{"country":"","businessArea":"","companyIdentificationNumber":"12345678901234","vfsCustomerNumber":"12345678901212122"}';
    String sRequestURI = '/services/apexrest/credit-lines/search';
    RestResponse res =  CLA_TestUtility.getTestResponse(sRequestURI , 'POST',requestBody);

    Test.startTest();
    CLA_CreditLineSearchService.getMatchedCreditLines();
    Test.stopTest();

    System.assertEquals(400, res.statusCode, 'Expected status code is 400.');
    System.assert(res.responseBody.toString().contains('Bad Request'), 'Expected "Bad Request" in response body.');
    }
}
}