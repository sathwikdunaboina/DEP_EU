/* 
* -----------------------------------------------------------------------------------------
* Apex Class Name     CLA_ValidateCreditLineCustLwcCont_Test
* @author             Sourabh Sharma <sourabh.sharma@consultant.volvo.com> 
* @Created Date       05-17-2024         
* ------------------------------------------------------------------------------------------
* @description        This class is used to test CLA_ValidateCreditLineCustLwcController
* ------------------------------------------------------------------------------------------
*/
@isTest
private class CLA_ValidateCreditLineCustLwcCont_Test { 

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
        System.runAs(new User(Id = UserInfo.getUserId())){
          CLA_TestDataFactory.createCreditLine(true);
        }
    } 

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testGetValidatedCustomerDetail
* @description     This method test CLA_ValidateCreditLineCustLwcController for valid scenario. 
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/ 

    @isTest static void testGetValidatedCustomerDetail() { 
        System.runAs(new User(Id = UserInfo.getUserId())){

        List<CLA_Credit_Line__c> listCreditLine = [SELECT Id,CLA_Credit_Line_identification_number__c 
        FROM CLA_Credit_Line__c LIMIT 1];

        List<CLA_Credit_Line_Account__c>listCreditLineCustomer = [SELECT Id,CLA_Credit_Line__c FROM CLA_Credit_Line_Account__c 
                                                                 WHERE CLA_Credit_Line__c =: listCreditLine[0].Id LIMIT 1];

        Test.setMock(HttpCalloutMock.class, new CLA_CalloutMock_Test());
        
        Test.startTest();
        String sResponseBody = CLA_ValidateCreditLineCustLwcController.getValidatedCustomerDetail(listCreditLineCustomer[0].Id);
        CLA_ValidateCreditLineCustLwcController.updateCreditLineCustomer(listCreditLineCustomer[0].Id,'1234567890');
        System.assertEquals(sResponseBody, '{"example":"test"}' , 'Expected result');
        Test.stopTest();
        }
    }

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testGetValidatedCustomerDetailMockFailure
* @description     This method test CLA_ValidateCreditLineCustLwcController for exception. 
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/ 

    @isTest static void testGetValidatedCustomerDetailMockFailure() { 
        System.runAs(new User(Id = UserInfo.getUserId())){

        List<CLA_Credit_Line__c> listCreditLine = [SELECT Id,CLA_Credit_Line_identification_number__c 
        FROM CLA_Credit_Line__c LIMIT 1];

        List<CLA_Credit_Line_Account__c>listCreditLineCustomer = [SELECT Id,CLA_Credit_Line__c FROM CLA_Credit_Line_Account__c 
                                                                 WHERE CLA_Credit_Line__c =: listCreditLine[0].Id LIMIT 1];

        Test.setMock(HttpCalloutMock.class, new CLA_CalloutMockFailure_Test());
        Test.startTest();
        try{
            String sResponseBody = CLA_ValidateCreditLineCustLwcController.getValidatedCustomerDetail(listCreditLineCustomer[0].Id);
            System.assertEquals(sResponseBody, '{"example":"test"}' , 'Expected result');
          
        }
        catch(Exception ex) {
           system.debug(LoggingLevel.INFO,ex.getCause());
        }
        Test.stopTest();
    }
    }

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testGetValidatedCustomerDetailBlankInput
* @description     This method test CLA_ValidateCreditLineCustLwcController for exception. 
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/

    @isTest static void testGetValidatedCustomerDetailBlankInput() { 
        System.runAs(new User(Id = UserInfo.getUserId())){

        Test.setMock(HttpCalloutMock.class, new CLA_CalloutMock_Test());
        Test.startTest();
        try{
        String sResponseBody = CLA_ValidateCreditLineCustLwcController.getValidatedCustomerDetail('');
        System.assertEquals(sResponseBody, '{"example":"test"}' , 'Expected result');
        }
        catch(Exception ex) {
        System.debug(LoggingLevel.INFO,ex.getCause());  
        }
        Test.stopTest();
    }
    }
}