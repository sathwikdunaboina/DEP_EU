/* 
* -----------------------------------------------------------------------------------------
* Apex Class Name     CLA_CreditLineService_Test
* @author             Sourabh Sharma <sourabh.sharma@consultant.volvo.com> 
* @Created Date       05-17-2024         
* ------------------------------------------------------------------------------------------
* @description        This class is used to test CLA_CreditLineService , CLA_CreditLineTriggerHandler
* ------------------------------------------------------------------------------------------
*/

@isTest
private class CLA_CreditLineService_Test { 

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
        CLA_TestDataFactory.createUser('Minimum Access - API Only Integrations');
        System.runAs(new User(Id = UserInfo.getUserId())){ 
            CLA_TestDataFactory.createCreditLine(true);
        }
    }

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testGetCreditLinesWithInvalidCreditLine
* @description     This method test CLA_CreditLineService for valid Creditline. 
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/

    @isTest
    private static void testGetCreditLinesWithInvalidCreditLine(){

        User oIntegrationUser = [Select Id FROM user where Username = 'clatestuser@cla.com' LIMIT 1];
        System.runAs(oIntegrationUser){
        String sRequestURI = '/services/apexrest/credit-lines/1234567890';
        RestResponse res =  CLA_TestUtility.getTestResponse(sRequestURI , 'GET');

        Test.startTest();
        CLA_CreditLineService.getCreditLines();
        Test.stopTest();

         System.assertEquals(404, res.statusCode, 'Expected status code is 404.');
         System.assert(res.responseBody.toString().contains('Credit line not found'), 'Expected "Credit line not found" message in response body.');
        }

    }

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testGetCreditLinesWithBlankCreditLine
* @description     This method test CLA_CreditLineService for blank Creditline. 
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/
    
    @isTest
    private static void testGetCreditLinesWithBlankCreditLine(){

        User oIntegrationUser = [Select Id FROM user where Username = 'clatestuser@cla.com' LIMIT 1];
        System.runAs(oIntegrationUser){
       
        String sRequestURI = '/services/apexrest/credit-lines/'+'';
        RestResponse res =  CLA_TestUtility.getTestResponse(sRequestURI , 'GET');
       
        Test.startTest();
        CLA_CreditLineService.getCreditLines();
        Test.stopTest();

        System.assertEquals(400, res.statusCode, 'Expected status code is 404 for blank creditline identification number.');
        System.assert(res.responseBody.toString().contains('Bad Request'), 'Expected "Bad Request" message in response body.');
        }

    }

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testGetCreditLinesWithValidCreditLine
* @description     This method test CLA_CreditLineService for valid Creditline. 
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/
    @isTest
    private static void testGetCreditLinesWithValidCreditLine(){

        User oIntegrationUser = [Select Id FROM user where Username = 'clatestuser@cla.com' LIMIT 1];
        System.runAs(oIntegrationUser){
       
        List<CLA_Credit_Line__c> listCreditLine = [SELECT Id,CLA_Credit_Line_identification_number__c 
                                                   FROM CLA_Credit_Line__c LIMIT 1];

        String sRequestURI = '/services/apexrest/credit-lines/'+ listCreditLine[0].CLA_Credit_Line_identification_number__c;
        RestResponse res =  CLA_TestUtility.getTestResponse(sRequestURI , 'GET');

        Test.startTest();
        CLA_CreditLineService.getCreditLines();
        Test.stopTest();

        System.assertEquals(200, res.statusCode, 'Expected status code is 200.');
        System.assert(res.responseBody.toString().contains('CLA_Company_Identification_Number__c'), 'Expected "Keys present" in response body.');
        }

    }
   
}