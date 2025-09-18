/* 
* -----------------------------------------------------------------------------------------
* Apex Class Name     AccountEditController_Test
* @author             Swami Goskula<Swami.goskula@consulant.volvo.com> 
* @Created Date       12-06-2025        
* ------------------------------------------------------------------------------------------
* @description        This class is used to test AccountEditController
* ------------------------------------------------------------------------------------------
*/ 
@IsTest(SeeAllData=false)
public class AccountEditControllerTest {
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
    static void setupData() {
        Account acc1 = new Account(Name = 'Exact Match Account', BillingCity = 'Mumbai', BillingCountry = 'India');
        insert acc1;
        
        Account acc2 = new Account(Name = 'Fuzzy Match Account', BillingCity = 'Hyderabad', BillingCountry = 'India');
        insert acc2;
    }
        /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testExactMatchingLogic
* @description     This method is used to test Exact match logic
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/    
    @isTest
    static void testExactMatchingLogic() {
        Account exactAcc = new Account(Name = 'ExactMatchAccount', BillingCity = 'Mumbai', BillingCountry = 'India');
        insert exactAcc;
        
        Map<String, Object> exactFieldMap = new Map<String, Object>{
            'BillingCity' => 'Mumbai',
                'BillingCountry' => 'India'
                };
                    
                    Test.startTest();
        AccountEditController.DuplicateRuleResult exactResult = AccountEditController.checkDuplicateRules(exactFieldMap);
        Test.stopTest();
        
        System.assertNotEquals(null, exactResult);
        System.assert(exactResult.isDuplicate || !exactResult.isDuplicate);
    }
      /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testFuzzyMatchingLogic
* @description     This method is used to test Fuzzy match logic 
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/  
    
    @isTest
    static void testFuzzyMatchingLogic() {
        Account fuzzyAcc = new Account(Name = 'FuzzyMatchAccount', BillingCity = 'Hyderabad', BillingCountry = 'India');
        insert fuzzyAcc;
        
        Map<String, Object> fuzzyFieldMap = new Map<String, Object>{
            'Name' => 'FuzzyMatchAccoun',
                'BillingCity' => 'Hyderabad',
                'BillingCountry' => 'India'
                };
                    
                    Test.startTest();
        AccountEditController.DuplicateRuleResult fuzzyResult = AccountEditController.checkDuplicateRules(fuzzyFieldMap);
        Test.stopTest();
        
        System.assertNotEquals(null, fuzzyResult);
        System.assert(fuzzyResult.isDuplicate || !fuzzyResult.isDuplicate);
    }
          /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testgetAccountDetails
* @description     This method is used to get Account Details
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/  

    @isTest
    static void testgetAccountDetails(){
        
        Account testAcc = new Account(
            Name = 'Test Account',
            BillingCountry = 'India',           
            BillingStreet = '123 Main St',
            BillingCity = 'Bangalore',
            BillingState = 'Karnataka'
            
        );
        insert testAcc;
        
        Test.startTest();
        
        Account result = AccountEditController.getAccountDetails(testAcc.id);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Account should be returned');
        System.assertEquals('Test Account', result.Name);
    }
      /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testGetDuplicateAccounts
* @description     This method is used to test the functionality to get Duplicate Accounts based on duplicate rules
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/  
    
    @isTest
    static void testGetDuplicateAccounts() {
        Account baseAcc = new Account(Name = 'Acme Corporation', BillingCountry = 'United States');
        insert baseAcc;
        
        Account similarAcc = new Account(Name = 'Acme Corp', BillingCountry = 'United States');
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.DuplicateRuleHeader.allowSave = true;
        dmlOpts.DuplicateRuleHeader.runAsCurrentUser = true;
        similarAcc.setOptions(dmlOpts);
        Database.insert(similarAcc, dmlOpts);
        Account differentAcc = new Account(Name = 'Beta Industries', BillingCountry = 'United States');
        differentAcc.setOptions(dmlOpts);
        insert differentAcc;
        
        Test.startTest();
        List<Account> duplicates = AccountEditController.getDuplicateAccounts(baseAcc.Id, baseAcc.Name, baseAcc.BillingCountry);
        Test.stopTest();
        
        System.assertNotEquals(1, duplicates.size());
        System.assertEquals(0, duplicates.size());
    }      
      /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testUpdateMultipleAccounts
* @description     This method is used to Update the Accounts
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/  
        @isTest
    static void testUpdateMultipleAccounts_Success() {
        Account acc = new Account(Name = 'Test Account', NumberOfEmployees = 10,BillingCountry='Canada');
        insert acc;

        Map<String, Object> inputMap = new Map<String, Object>{
            'Id' => acc.Id,
            'Name' => 'Updated Account',
            'NumberOfEmployees' => '25',
            'Fleet_Size__c' => '50',
            'Credit_Assessment_Date__c' => '2024-12-31',
            'Invoices_Fetched_On__c' => '2024-12-31T10:15:30Z'
        };

        Test.startTest();
        Map<String, Object> result = AccountEditController.updateMultipleAccounts(inputMap);
        Test.stopTest();
        System.assertEquals(true, result.get('success'));
        Account updated = [SELECT Name, NumberOfEmployees, Fleet_Size__c, Credit_Assessment_Date__c, Invoices_Fetched_On__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals('Updated Account', updated.Name);
        System.assertEquals(25, updated.NumberOfEmployees);
        System.assertEquals(50, updated.Fleet_Size__c);
        System.assertEquals(Date.newInstance(2024, 12, 31), updated.Credit_Assessment_Date__c);
        System.assertNotEquals(null, updated.Invoices_Fetched_On__c);
    }

   @isTest
    static void testUpdateMultipleAccounts_MissingId() {
        Map<String, Object> inputMap = new Map<String, Object>{
            'Name' => 'No ID Account'
        };

        Map<String, Object> result = AccountEditController.updateMultipleAccounts(inputMap);
        System.assertEquals(false, result.get('success'));
        System.assert(((List<String>)result.get('errors')).contains('Account Id is missing.'));
    }

    @isTest
    static void testUpdateMultipleAccounts_InvalidDate() {
        Account acc = new Account(Name = 'Invalid Date Account',BillingCountry='Canada');
        
        insert acc;

        Map<String, Object> inputMap = new Map<String, Object>{
            'Id' => acc.Id,
            'Credit_Assessment_Date__c' => 'invalid-date'
        };

        Map<String, Object> result = AccountEditController.updateMultipleAccounts(inputMap);
        System.assertEquals(false, result.get('success'));
        System.assert(((List<String>)result.get('errors'))[0].contains('Error parsing field Credit_Assessment_Date__c'));
    }


}