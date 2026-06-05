/* 
* -----------------------------------------------------------------------------------------
* Apex Class Name     VINValidatorBatch_Test
* @author             Sugapriya Vanjiyappan <sugapriya.vanjiyappan@consultant.volvo.com>
* @Created Date       25-11-2025 
* @Used By            VINValidatorBatch
* ------------------------------------------------------------------------------------------
* @description        This class is used to test VINValidatorBatch.
* ------------------------------------------------------------------------------------------
*/
@IsTest(SeeAllData=false)
public class VINValidatorBatch_Test {
    /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     setUpData
* @description     Used to prepare test setup data
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/ 
    @testSetup 
    static void setupmethod(){
        Id iProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1][0].Id;
        String sUniqueUserName = 'Test' + DateTime.now().getTime() + '@testorg.com';
        User oTestUser = new User(Alias = 'tsts', Email='test@testorg.com',
                                  EmailEncodingKey='UTF-8', LastName='TestLastName', LanguageLocaleKey='en_US',
                                  LocaleSidKey='en_GB', ProfileId = iProfileId,TimeZoneSidKey='Europe/Paris',
                                  Country = '',UserName=sUniqueUserName);
        insert oTestUser;
        System.runAs(oTestUser){
            //Create Test Account
            Account testAccount = new Account();
            testAccount.Name = 'Test Account';
            testAccount.BillingCountry = 'United Kingdom';
            insert testAccount;
            
            //Create Test Contract
            Contract__c testContract = new Contract__c();
            testContract.Contract_Number__c = 'TestContract';
            testContract.Account__c = testAccount.Id;
            testContract.Contract_Id__c = 'TestContract';
            testContract.DealerId__c = 'UKTest001';
            testContract.VIN_Number__c = 'YV2R0P0G1LA867358';
            insert testContract;
            
        }
    }
    
    /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     validateVINNumber
* @description     To cover the VINValidatorBatch
* ------------------------------------------------------------------------------------------------------
*/
    @isTest
    static void validateVINNumber(){
        List<Contract__c> retrieveExistingContract = [SELECT Id,VIN_Number__c,VIN_Format_Valid__c FROM Contract__c WHERE Contract_Number__c = 'TestContract'];
        Test.startTest();
        Database.executeBatch(new VINValidatorBatch(), 200);
        Test.stopTest();
        Contract__c afterValidation = [SELECT Id,VIN_Number__c,VIN_Format_Valid__c FROM Contract__c WHERE Contract_Number__c = 'TestContract'];
        System.assertEquals(TRUE, afterValidation.VIN_Format_Valid__c);
    }
    
    /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     validateVINNumber_DmlErrorCoverage
* @description     To cover the VINValidatorBatch DML Errors
* ------------------------------------------------------------------------------------------------------
*/
    @isTest
    static void validateVINNumber_DmlErrorCoverage() {
        VINValidatorBatch.forceDmlError = true;
        Test.startTest();
        Database.executeBatch(new VINValidatorBatch(), 1);
        Test.stopTest();
        VINValidatorBatch.forceDmlError = false;
    }
}