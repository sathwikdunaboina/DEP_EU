/* 
* -----------------------------------------------------------------------------------------
* Apex Class Name     ChangeDataCaptureErrorLogController_Test
* @author             Sourabh Sharma <sourabh.sharma@consultant.volvo.com>
* @Created Date       10-23-2025  
* @Used By             
* @SystemLayer        Test Class
* ------------------------------------------------------------------------------------------
* @description        This class is used to test ChangeDataCaptureErrorLogController
* ------------------------------------------------------------------------------------------
*/
@IsTest
private class ChangeDataCaptureErrorLogController_Test {

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     setupData
* @description     This method builds setup data.
* ------------------------------------------------------------------------------------------------------
* @param           
* @return         
* ------------------------------------------------------------------------------------------------------ 
*/
    @TestSetup
    static void setupData() {
        // Create a test Account
       Account acc = new Account();
                acc.Name = 'test account' ;
                acc.BillingCountry = 'Netherlands';
        insert acc;

        // Create a Contact related to Account
        Contact con = new Contact(LastName = 'Test Contact', AccountId = acc.Id);
        insert con;

        // Create Bank Account Mandate record
        Bank_Account_Mandate__c mandate = new Bank_Account_Mandate__c(
            Name = 'Test Mandate',
            Account__c = acc.Id
        );
        insert mandate;
        
          // Create Bank Account Mandate record
        Bank_Account__c bankAccount = new Bank_Account__c(
            Name = 'Test BankAccount'
        );
        insert bankAccount;
        
         Linked_Bank_Accounts__c linkedBankAccount = new Linked_Bank_Accounts__c(
            Account__c = acc.Id,
            Bank_Account__c = bankAccount.Id
        );
        insert linkedBankAccount;

        // Create Error_Log__c records
        insert new List<Error_Log__c>{
            new Error_Log__c(
                Type__c = 'Error',
                Associated_Record__c = acc.Id,
                Error_Message__c = 'Account integration failed'
            ),
            new Error_Log__c(
                Type__c = 'Error',
                Associated_Record__c = con.Id,
                Error_Message__c = 'Contact CDC issue'
            ),
            new Error_Log__c(
                Type__c = 'Error',
                Associated_Record__c = mandate.Id,
                Error_Message__c = 'Bank Account Mandate CDC issue'
            ),
             new Error_Log__c(
             Type__c = 'Error',
             Associated_Record__c = bankAccount.Id,
             Error_Message__c = 'Bank Account CDC issue'
            )
        };
    }

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testGetLatestRelevantError
* @description     This method test ChangeDataCaptureErrorLogController class
* ------------------------------------------------------------------------------------------------------
* @param           
* @return         
* ------------------------------------------------------------------------------------------------------ 
*/
    @IsTest
    static void testGetLatestRelevantError() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Bank_Account_Mandate__c bankAccountMandate = [SELECT Id FROM Bank_Account_Mandate__c LIMIT 1];
        Bank_Account__c bankAccount = [SELECT Id FROM Bank_Account__c LIMIT 1];

        Test.startTest();
        ChangeDataCaptureErrorLogController.ErrorResult result = ChangeDataCaptureErrorLogController.getLatestRelevantError(acc.Id, 'Account');
            ChangeDataCaptureErrorLogController.getLatestRelevantError(con.Id, 'Contact');
            ChangeDataCaptureErrorLogController.getLatestRelevantError(bankAccountMandate.Id, 'Bank_Account_Mandate__c');
            ChangeDataCaptureErrorLogController.getLatestRelevantError(bankAccount.Id, 'Bank_Account__c');
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.found, 'Expected found = true since error logs exist');
    }
    
}