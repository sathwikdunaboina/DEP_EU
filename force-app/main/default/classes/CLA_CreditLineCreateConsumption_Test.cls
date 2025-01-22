/* 
* -----------------------------------------------------------------------------------------
* Apex Class Name     CLA_CreditLineCreateConsumption_Test
* @author             Sourabh Sharma <sourabh.sharma@consultant.volvo.com> 
* @Created Date       05-17-2024         
* ------------------------------------------------------------------------------------------
* @description        This class is used to test CLA_CreditLineCreateConsumptionService
* ------------------------------------------------------------------------------------------
*/
@isTest
private class CLA_CreditLineCreateConsumption_Test {

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
        
         PermissionSet ps = [SELECT Id 
                    FROM PermissionSet 
                    WHERE Name = 'CLA_Credit_Manager_PS'];

        try {
            insert new PermissionSetAssignment(AssigneeId = UserInfo.getUserId(), PermissionSetId = ps.Id);
        } catch(DmlException e) {
            System.debug(LoggingLevel.INFO,'The following exception has occurred: ' + e.getMessage());
        }
        
        System.runAs(new User(Id = UserInfo.getUserId())){ 
            CLA_TestDataFactory.createCreditLine(true);
            CLA_TestDataFactory.createCreditLine(true,true);
        }
    } 

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testCreateCreditLineConsumptionValidRequestBody
* @description     This method test CLA_CreditLineCreateConsumptionService for valid requestbody. 
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/ 

    @isTest
    private static void testCreateCreditLineConsumptionValidRequestBody(){

        User oIntegrationUser = [Select Id FROM user where Username = 'clatestuser@cla.com' LIMIT 1];
        System.runAs(oIntegrationUser){
        List<CLA_Credit_Line__c> listCreditLine = [SELECT Id,CLA_Credit_Line_identification_number__c 
                                                   FROM CLA_Credit_Line__c 
                                                   WHERE CLA_Status__c = 'Approved' LIMIT 1];

        String requestBody = '{"consumptionIdentificationNumber": "","quoteNumber": "956878","quoteMarket": "NL-VT","companyIdentificationNumber": "2342424234","origin": "ACE","drawnDate": "2024-03-01","drawnAmount": 100.00,"drawnStatus": "Confirmed"}';
        String sRequestURI = '/services/apexrest/credit-lines/'+listCreditLine[0].CLA_Credit_Line_identification_number__c+'/consumption';
        RestResponse res =  CLA_TestUtility.getTestResponse(sRequestURI , 'POST',requestBody);

        Test.startTest();
        CLA_CreditLineCreateConsumptionService.createCreditLineConsumption();
        Test.stopTest();

        System.assertEquals(200, res.statusCode, 'Expected status code is 200.');
        System.assert(res.responseBody.toString().contains('CLA_Company_Identification_Number__c'), 'Expected "Keys present" in response body.');
        }
    }

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testCreateCreditLineConsumptionInvalidRequestBody
* @description     This method test CLA_CreditLineCreateConsumptionService for invalid requestbody and approved creditline. 
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/ 

    @isTest
    private static void testCreateCreditLineConsumptionInvalidRequestBody(){

        User oIntegrationUser = [Select Id FROM user where Username = 'clatestuser@cla.com' LIMIT 1];
        System.runAs(oIntegrationUser){
        String requestBody = '{"consumptionIdentificationNumber":"","quoteNumber":"","quoteMarket":"","companyIdentificationNumber":"2342424234","origin": "ACE","drawnDate":"2024-03-01","drawnAmount":100.00,"drawnStatus":"Confirmed"}';
        String sRequestURI = '/services/apexrest/credit-lines/'+'1234567890'+'/consumption';
        RestResponse res =  CLA_TestUtility.getTestResponse(sRequestURI , 'POST',requestBody);

        Test.startTest();
        CLA_CreditLineCreateConsumptionService.createCreditLineConsumption();
        Test.stopTest();

        System.assertEquals(400, res.statusCode, 'Expected status code is 400.');
        System.assert(res.responseBody.toString().contains('Bad Request'), 'Expected "Bad Request" in response body.');
        }
    }

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testCreateCreditLineConsumptionBlankCreditLine
* @description     This method test CLA_CreditLineCreateConsumptionService for blank creditline. 
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/ 
    
    @isTest
    private static void testCreateCreditLineConsumptionBlankCreditLine(){

        User oIntegrationUser = [Select Id FROM user where Username = 'clatestuser@cla.com' LIMIT 1];
        System.runAs(oIntegrationUser){
        String requestBody = '{"consumptionIdentificationNumber":"","quoteNumber":"1234","quoteMarket":"1234","companyIdentificationNumber":"2342424234","origin": "ACE","drawnDate":"2024-03-01","drawnAmount":100.00,"drawnStatus":"Confirmed"}';
        String sRequestURI = '/services/apexrest/credit-lines/'+''+'/consumption';
        RestResponse res =  CLA_TestUtility.getTestResponse(sRequestURI , 'POST',requestBody);

        Test.startTest();
        CLA_CreditLineCreateConsumptionService.createCreditLineConsumption();
        Test.stopTest();

        System.assertEquals(404, res.statusCode, 'Expected status code is 404 for valid creditline identification number.');
        System.assert(res.responseBody.toString().contains('Credit line not found'), 'Expected "Credit line not found" in response body.');
        }
    }

  
/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testCreateCreditLineConsumptionUnApprovedCreditLine
* @description     This method test CLA_CreditLineCreateConsumptionService for unapproved creditline. 
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/
    @isTest
    private static void testCreateCreditLineConsumptionUnApprovedCreditLine(){

        user oIntegrationUser = [Select Id FROM user where Username = 'clatestuser@cla.com' LIMIT 1];
        System.runAs(oIntegrationUser){
        List<CLA_Credit_Line__c> listCreditLine = [SELECT Id,CLA_Credit_Line_identification_number__c 
                                                   FROM CLA_Credit_Line__c 
                                                   WHERE CLA_Status__c != 'Approved' LIMIT 1
                                                   ];

        String requestBody = '{"consumptionIdentificationNumber": "","quoteNumber": "956878","quoteMarket": "NL-VT","companyIdentificationNumber": "2342424234","origin": "ACE","drawnDate": "2024-03-01","drawnAmount": 100.00,"drawnStatus": "Confirmed"}';
        String sRequestURI = '/services/apexrest/credit-lines/'+listCreditLine[0].CLA_Credit_Line_identification_number__c+'/consumption';
        RestResponse res =  CLA_TestUtility.getTestResponse(sRequestURI , 'POST',requestBody);

        Test.startTest();
        CLA_CreditLineCreateConsumptionService.createCreditLineConsumption();
        Test.stopTest();

        System.assertEquals(404, res.statusCode, 'Expected status code is 404.');
        System.assert(res.responseBody.toString().contains('Can not create Consumption'), 'Expected "Can not create Consumption" in response body.');
        }
    }

/*
* ------------------------------------------------------------------------------------------------------
* @MethodName      testCreateCreditLineConsumptionHighDrawnAmount{
* @description     This method test CLA_CreditLineCreateConsumptionService for high drawn amount consumption. 
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/

    @isTest
    private static void testCreateCreditLineConsumptionHighDrawnAmount(){

        user oIntegrationUser = [Select Id FROM user where Username = 'clatestuser@cla.com' LIMIT 1];
        System.runAs(oIntegrationUser){

        List<CLA_Credit_Line__c> listCreditLine = [SELECT Id,CLA_Credit_Line_identification_number__c 
                                                   FROM CLA_Credit_Line__c 
                                                   WHERE CLA_Status__c = 'Approved' LIMIT 1
                                                   ];

        String requestBody = '{"consumptionIdentificationNumber": "","quoteNumber": "956878","quoteMarket": "NL-VT","companyIdentificationNumber": "2342424234","origin": "ACE","drawnDate": "2024-03-01","drawnAmount": 10000000.00,"drawnStatus": "Confirmed"}';
        String sRequestURI = '/services/apexrest/credit-lines/'+listCreditLine[0].CLA_Credit_Line_identification_number__c+'/consumption';
        RestResponse res =  CLA_TestUtility.getTestResponse(sRequestURI , 'POST',requestBody);

        Test.startTest();
        CLA_CreditLineCreateConsumptionService.createCreditLineConsumption();
        Test.stopTest();

        System.assertEquals(405, res.statusCode, 'Expected status code is 405.');
        System.assert(res.responseBody.toString().contains('Requested amount is too high'), 'Expected "Requested amount is too high" in response body.');
        }
    }
   
}