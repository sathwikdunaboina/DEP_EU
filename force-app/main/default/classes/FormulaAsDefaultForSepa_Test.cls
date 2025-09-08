/**
* Name of the class    FormulaAsDefaultForSepa_Test
* Author               Sugapriya Vanjiyappan
* Create Date  		   10-07-2024
* Used by 			   Trigger Flow - Assign Value To Field Sepa If Blank On Bank Account Mandate Create
* SystemLayer		   Test class
* Description          While creating a Bank Account Mandate, if the field Sepa(Reference__c) is Blank 
                       then Set it to a calculated value based on the formula defined
* Classes covered	   N/A
*/

@isTest
public class FormulaAsDefaultForSepa_Test {
    
    @testSetup 
    static void setupmethod(){
        Id iProfileId = [SELECT Id FROM Profile WHERE Name = 'CS operations' LIMIT 1][0].Id;
        String sUniqueUserName = 'TestCaseAssigment' + DateTime.now().getTime() + '@testorg.com';
        User oTestUser = new User(Alias = 'tstcs', Email='testcaseassignment@testorg.com',
                                  EmailEncodingKey='UTF-8', LastName='TestCaseAsgMent', LanguageLocaleKey='en_US',
                                  LocaleSidKey='en_GB', ProfileId = iProfileId,TimeZoneSidKey='Europe/Paris',
                                  Country = '',UserName=sUniqueUserName);
        insert oTestUser;
        
        System.runAs(oTestUser){
            Bank_Account__c oBankAccount = new Bank_Account__c();
            oBankAccount.Name = 'Test Bank Account';
            insert oBankAccount;
            
            
            List<Account> testAccounts = new List<Account>();
            Account oAccount = new Account();
            oAccount.Name = 'Test Account';
            oAccount.BillingCountry = 'France';
            oAccount.companyRegistrationNumber2__c = '66612345678989';
            testAccounts.add(oAccount);
            
            Account oAccountWithFR94 = new Account();
            oAccountWithFR94.sourceSystemID__c = 'FR94-SF';
            oAccountWithFR94.Name = 'Test Account with FR94-SF';
            oAccountWithFR94.BillingCountry = 'France';
            oAccountWithFR94.companyRegistrationNumber2__c = '777';
            testAccounts.add(oAccountWithFR94);
            insert testAccounts;
        }
    }
    
    
/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     isSepaBlankWithoutAccountSSID
* @description     To cover Sepa field when it is Null And Account without Source System ID
* ------------------------------------------------------------------------------------------------------
*/ 
    @isTest
    static void isSepaBlankWithoutAccountSSID(){
        Bank_Account__c oBankAccount = [SELECT Id FROM Bank_Account__c WHERE Name = 'Test Bank Account' LIMIT 1];
        Account oAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Bank_Account_Mandate__c oBankMandate = new Bank_Account_Mandate__c();
        oBankMandate.Name = 'Test Bank Account Mandate';
        oBankMandate.Bank_Account__c = oBankAccount.Id;
        oBankMandate.Signed_Date__c = Date.newInstance(2024, 7, 10);
        oBankMandate.Account__c = oAccount.Id;
        Test.startTest();
        insert oBankMandate;
        Test.stopTest();
        Long startTime = DateTime.now().getTime();
        Long finalTime = DateTime.now().getTime();
        Long millisecondsToWait = 3000; 
        while (finalTime - startTime < millisecondsToWait) {
        	finalTime = DateTime.now().getTime();
        }
        Bank_Account_Mandate__C oNewBankMandate =[SELECT Id,Reference__c from Bank_Account_Mandate__c WHERE Id=:oBankMandate.Id ];
        System.debug('Reference'+ oNewBankMandate.Reference__c);
        Assert.areEqual('FR9466612345678989CORE7102024',oNewBankMandate.Reference__c , 'Reference field value is not same as Formula'); 

        
    }
    
/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     isSepaBlankWithAccountSSID
* @description     To cover Sepa field when it is Null And Account with Source System ID
* ------------------------------------------------------------------------------------------------------
*/ 
    @isTest
    static void isSepaBlankWithAccountSSID(){
        Bank_Account__c oBankAccount = [SELECT Id FROM Bank_Account__c WHERE Name = 'Test Bank Account' LIMIT 1];
        Account oAccount = [SELECT Id FROM Account WHERE Name = 'Test Account with FR94-SF' LIMIT 1];
        Bank_Account_Mandate__c oBankMandate = new Bank_Account_Mandate__c();
        oBankMandate.Name = 'Test Bank Account Mandate';
        oBankMandate.Bank_Account__c = oBankAccount.Id;
        oBankMandate.Signed_Date__c = Date.newInstance(2024, 7, 10);
        oBankMandate.Account__c = oAccount.Id;
        Test.startTest();
        insert oBankMandate;
        Test.stopTest();
        Long startTime = DateTime.now().getTime();
        Long finalTime = DateTime.now().getTime();
        Long millisecondsToWait = 3000; 
        while (finalTime - startTime < millisecondsToWait) {
        	finalTime = DateTime.now().getTime();
        }
        Bank_Account_Mandate__C oNewBankMandate =[SELECT Id,Reference__c from Bank_Account_Mandate__c WHERE Id=:oBankMandate.Id ];
        System.debug('Reference'+ oNewBankMandate.Reference__c);
        Assert.areEqual('FR9466612345678989CORE7102024',oNewBankMandate.Reference__c , 'Reference field value is not same as Formula'); 
 
    }
    
    
}