/* 
* -----------------------------------------------------------------------------------------
* Apex Class Name     CLA_CreditLineConsumptionService_Test
* @author             Sourabh Sharma <sourabh.sharma@consultant.volvo.com> 
* @Created Date       05-17-2024         
* ------------------------------------------------------------------------------------------
* @description        This class is used to test CLA_CreditLineConsumptionService , CLA_CreditLineConsumptionTriggerHandler
* ------------------------------------------------------------------------------------------
*/
@isTest
private class CLA_CreditLineConsumptionService_Test { 

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
         CLA_TestDataFactory.createCreditLineConsumptions(true); 
        }
    } 

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testGetCreditLineConsumptionsValidCreditLine
* @description     This method test CLA_CreditLineConsumptionService for valid Creditline. 
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/ 
    @isTest
    private static void testGetCreditLineConsumptionsValidCreditLine(){

        User oIntegrationUser = [Select Id FROM user where Username = 'clatestuser@cla.com' LIMIT 1];

        System.runAs(oIntegrationUser){
        List<CLA_Credit_Line__c> listCreditLines = [SELECT Id,CLA_Credit_Line_identification_number__c 
        FROM CLA_Credit_Line__c LIMIT 1];
      
        String sRequestURI = '/services/apexrest/credit-lines/'+listCreditLines[0].CLA_Credit_Line_identification_number__c+'/consumptions';
        RestResponse res =  CLA_TestUtility.getTestResponse(sRequestURI , 'GET');

        Test.startTest();
        CLA_CreditLineConsumptionService.getCreditLineConsumptions();
        Test.stopTest();

        System.assertEquals(200, res.statusCode, 'Expected status code is 200 for valid creditline identification number.');
        System.assert(res.responseBody.toString().contains('CLA_Company_Identification_Number__c'), 'Expected "Keys present" in response body.');
        }
    }

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testGetCreditLineConsumptionsInvalidCreditLine
* @description     This method test CLA_CreditLineConsumptionService for invalid Creditline. 
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/ 

    @isTest
    private static void testGetCreditLineConsumptionsInvalidCreditLine(){
        User oIntegrationUser = [Select Id FROM user where Username = 'clatestuser@cla.com' LIMIT 1];

        System.runAs(oIntegrationUser){
       
        String sRequestURI = '/services/apexrest/credit-lines/'+'1234567890'+'/consumptions';
        RestResponse res =  CLA_TestUtility.getTestResponse(sRequestURI , 'GET');

        Test.startTest();
        CLA_CreditLineConsumptionService.getCreditLineConsumptions();
        Test.stopTest();

        System.assertEquals(404, res.statusCode, 'Expected status code is 404 for invalid creditline identification number.');
        System.assert(res.responseBody.toString().contains('No consumption records found for the provided Credit Line Identification Number'), 'Expected "No consumption records found for the provided Credit Line Identification Number" in response body.');
        }
    }

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testGetCreditLineConsumptionsBlankCreditLine
* @description     This method test CLA_CreditLineConsumptionService for blank Creditline. 
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/

    @isTest
    private static void testGetCreditLineConsumptionsBlankCreditLine(){
        
        User oIntegrationUser = [Select Id FROM user where Username = 'clatestuser@cla.com' LIMIT 1];

        System.runAs(oIntegrationUser){
        
        String sRequestURI = '/services/apexrest/credit-lines/'+''+'/consumptions';
        RestResponse res =  CLA_TestUtility.getTestResponse(sRequestURI , 'GET');

        Test.startTest();
        CLA_CreditLineConsumptionService.getCreditLineConsumptions();
        Test.stopTest();

        System.assertEquals(400, res.statusCode, 'Expected status code is 400 for blank creditline identification number.');
        System.assert(res.responseBody.toString().contains('Bad Request'), 'Expected "Bad Request" in response body.');
        }
    }
}