/* 
* -----------------------------------------------------------------------------------------
* Apex Class Name     CLA_CreditLineControlsService_Test
* @author             Sourabh Sharma <sourabh.sharma@consultant.volvo.com> 
* @Created Date       05-17-2024         
* ------------------------------------------------------------------------------------------
* @description        This class is used to test CLA_CreditLineControlsService , CLA_CreditLineControlTriggerHandler
* ------------------------------------------------------------------------------------------
*/
@isTest
private class CLA_CreditLineControlsService_Test {

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
            CLA_TestDataFactory.createCreditLineControls(true); 
        }
    }

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testGetCreditLinesControlsWithValidCreditLine
* @description     This method test CLA_CreditLineControlsService for  getting all creditline controld for creditline.
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/

    @isTest
    private static void testGetCreditLinesControlsWithValidCreditLine(){

        User oIntegrationUser = [Select Id FROM user where Username = 'clatestuser@cla.com' LIMIT 1];
        System.runAs(oIntegrationUser){

        List<CLA_Credit_Line_Control__c> listCreditLineControl = [SELECT Id,CLA_Credit_Line__r.CLA_Credit_Line_identification_number__c,CLA_CreditLineControlIdentificationNumbe__c
                                                                  FROM CLA_Credit_Line_Control__c];

        String sRequestURI = '/services/apexrest/credit-lines/'+listCreditLineControl[0].CLA_Credit_Line__r.CLA_Credit_Line_identification_number__c +'/controls';
        RestResponse res =  CLA_TestUtility.getTestResponse(sRequestURI , 'GET');
        
        Test.startTest();
        CLA_CreditLineControlsService.getCreditLineControls();
        Test.stopTest();

        System.assertEquals(200, res.statusCode, 'Expected status code is 200 for invalid creditline identification number.');
        System.assert(res.responseBody.toString().contains('CLA_CreditLineControlIdentificationNumbe__c'), 'Expected "CLA_CreditLineControlIdentificationNumbe__c" message in response body.');
        }

    }

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testGetCreditLinesControlsSpecificWithValidCreditLine
* @description     This method test CLA_CreditLineControlsService for getting specific creditline control.
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/ 
    @isTest
    private static void testGetCreditLinesControlsSpecificWithValidCreditLine(){

        User oIntegrationUser = [Select Id FROM user where Username = 'clatestuser@cla.com' LIMIT 1];
        System.runAs(oIntegrationUser){

        List<CLA_Credit_Line_Control__c> listCreditLineControl = [SELECT Id,CLA_Credit_Line__r.CLA_Credit_Line_identification_number__c,CLA_CreditLineControlIdentificationNumbe__c
                                                                  FROM CLA_Credit_Line_Control__c];

        String sRequestURI = '/services/apexrest/credit-lines/'+listCreditLineControl[0].CLA_Credit_Line__r.CLA_Credit_Line_identification_number__c +'/controls/'+listCreditLineControl[0].CLA_CreditLineControlIdentificationNumbe__c;
        RestResponse res =  CLA_TestUtility.getTestResponse(sRequestURI , 'GET');
        
        Test.startTest();
        CLA_CreditLineControlsService.getCreditLineControls();
        Test.stopTest();

        System.assertEquals(200, res.statusCode, 'Expected status code is 200 for invalid creditline identification number.');
        System.assert(res.responseBody.toString().contains('CLA_CreditLineControlIdentificationNumbe__c'), 'Expected "CLA_CreditLineControlIdentificationNumbe__c" message in response body.');
        }

    }

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testGetCreditLinesControlsWithInvalidCreditLine
* @description     This method test CLA_CreditLineControlsService for invalid creditline.
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/ 

    @isTest
    private static void testGetCreditLinesControlsWithInvalidCreditLine(){

        User oIntegrationUser = [Select Id FROM user where Username = 'clatestuser@cla.com' LIMIT 1];
        System.runAs(oIntegrationUser){

        String sRequestURI = '/services/apexrest/credit-lines/'+'1234567890'+'/controls/';
        RestResponse res =  CLA_TestUtility.getTestResponse(sRequestURI , 'GET');
       
        Test.startTest();
        CLA_CreditLineControlsService.getCreditLineControls();
        Test.stopTest();

        System.assertEquals(404, res.statusCode, 'Expected status code is 404 for invalid creditline identification number.');
        System.assert(res.responseBody.toString().contains('Credit line control not found'), 'Expected "Credit line control not found" message in response body.');
        }

    }

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testGetCreditLinesControlsWithBlankCreditLine
* @description     This method test CLA_CreditLineControlsService for blank creditline.
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/

    @isTest
    private static void testGetCreditLinesControlsWithBlankCreditLine(){

        User oIntegrationUser = [Select Id FROM user where Username = 'clatestuser@cla.com' LIMIT 1];
        System.runAs(oIntegrationUser){

        String sRequestURI = '/services/apexrest/credit-lines/'+''+'/controls/';
        RestResponse res =  CLA_TestUtility.getTestResponse(sRequestURI , 'GET');

        Test.startTest();
        CLA_CreditLineControlsService.getCreditLineControls();
        Test.stopTest();

        System.assertEquals(400, res.statusCode, 'Expected status code is 400 for blank creditline identification number.');
        System.assert(res.responseBody.toString().contains('Bad Request'), 'Expected "Bad Request" message in response body.');
        }

    }


     
}