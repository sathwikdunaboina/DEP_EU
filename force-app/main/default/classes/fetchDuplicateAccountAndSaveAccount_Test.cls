/* 
* -----------------------------------------------------------------------------------------
* Apex Class Name     fetchDuplicateAccountAndSaveAccount_Test
* @author             Sugapriya Vanjiyappan <sugapriya.vanjiyappan@consultant.volvo.com> 
* @Created Date       12-06-2025        
* ------------------------------------------------------------------------------------------
* @description        This class is used to test fetchDuplicateAccountAndSaveAccount
* ------------------------------------------------------------------------------------------
*/
@IsTest(SeeAllData=false)
public class fetchDuplicateAccountAndSaveAccount_Test {
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
        Id iProfileId = [SELECT Id FROM Profile WHERE Name = 'Sales' LIMIT 1][0].Id;
        String sUniqueUserName = 'TestOpportunityAssigment' + DateTime.now().getTime() + '@testorg.com';
        User oTestUser = new User(Alias = 'tstcs', Email='testOpportunity@testorg.com',
                                  EmailEncodingKey='UTF-8', LastName='TestOpportunityAsgMent', LanguageLocaleKey='en_US',
                                  LocaleSidKey='en_GB', ProfileId = iProfileId,TimeZoneSidKey='Europe/Paris',
                                  Country = '',UserName=sUniqueUserName);
        insert oTestUser;
        
        System.runAs(new User(Id = UserInfo.getUserId())){ 
            Account testCustomerAccount = new Account();
            testCustomerAccount.Name = 'TestAccount';
            testCustomerAccount.BillingCountry = 'Spain';
            insert testCustomerAccount;
            
            Account testCustomerAccount2 = new Account();
            testCustomerAccount2.Name = 'TestAccount2';
            testCustomerAccount2.BillingCountry = 'Poland';
            testCustomerAccount2.BillingCity = 'Świnoujście';
            insert testCustomerAccount2;
        }
    } 
    /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     createANewAccount
* @description     This method is used to test Account Creation with no duplicates
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/  
    @isTest
    public static void createANewAccount(){
        Test.startTest();
        DateTime dt = DateTime.newInstance(2025,5,28,16,30,0);
        Map<String, Object> fieldMap = new Map<String, Object>{
            'Name'=>'New Test Account',
                'Is_Deleted_From_Backbone__c'=> true,
                'Credit_Assessment_Date__c'=>'2025-06-19',
                'CurrencyIsoCode'=> 'EUR',
                'Invoices_Fetched_On__c'=> dt,
                'Fleet_Size__c'=> 123456.78,
                'BillingCountry'=>'Spain',
                'NumberOfEmployees'=> 10
                };
                    String rawStateValue = 'Alicante';
        Id accountId = fetchDuplicateAccountAndSaveAccount.saveAccountRecord(fieldMap,rawStateValue);
        Test.stopTest();
    }
    
    /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     createANewAccountWithInvalidState
* @description     This method is used to test Account Creation with invalid state value
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/  
    @isTest
    public static void createANewAccountWithInvalidState(){
        Test.startTest();
        DateTime dt = DateTime.newInstance(2025,5,28,16,30,0);
        Map<String, Object> fieldMap = new Map<String, Object>{
            'Name'=>'Test Account State',
                'Is_Deleted_From_Backbone__c'=> true,
                'Credit_Assessment_Date__c'=>'2025-06-19',
                'CurrencyIsoCode'=> 'EUR',
                'Invoices_Fetched_On__c'=> dt,
                'Fleet_Size__c'=> 123456.78,
                'BillingCountry'=>'Belgium',
                'NumberOfEmployees'=> 10
                };
                    String rawStateValue = 'Luxem';
        try{
            Id accountId = fetchDuplicateAccountAndSaveAccount.saveAccountRecord(fieldMap,rawStateValue);
        }
        catch(Exception e){  
        }
        
        Test.stopTest();
    }
    /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     createADuplicateAccountAllow
* @description     This method is used to test Account Creation with Warning for Duplicates
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/
    @isTest
    public static void createADuplicateAccountAllow(){
        Map<String, Object> fieldMap = new Map<String, Object>{
            'Name'=>'TestAccount',
                'BillingCountry'=>'Spain'
                };
                    String rawStateValue = 'Alicante';
        Id accountIdTest = fetchDuplicateAccountAndSaveAccount.saveAccountRecord(fieldMap,rawStateValue);   
        Test.startTest();
        fetchDuplicateAccountAndSaveAccount.DuplicateRuleResult result = fetchDuplicateAccountAndSaveAccount.checkDuplicateRules(fieldMap);
        Test.stopTest();
    }
    /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     createADuplicateAccountBlock
* @description     This method is used to test Blocking of Account Creation with error for Duplicates
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/  
    @isTest
    public static void createADuplicateAccountBlock(){
        Map<String, Object> fieldMap = new Map<String, Object>{
            'Name'=>'TestAccount2',
                'BillingCountry'=>'Poland',
                'BillingCity'=>'Świnoujście'
                };
                    String rawStateValue = 'Lublin';
        try{
            Id accountIdTest = fetchDuplicateAccountAndSaveAccount.saveAccountRecord(fieldMap,rawStateValue);   
        }
        catch(Exception e){  
        }
        Test.startTest();
        fetchDuplicateAccountAndSaveAccount.DuplicateRuleResult result = fetchDuplicateAccountAndSaveAccount.checkDuplicateRules(fieldMap);
        Test.stopTest();
    }
    /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     fetchMatchingDuplicateAccounts
* @description     This method is used to test the functionality to fetch Duplicate Accounts based on duplicate rules
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/  
    @isTest
    public static void fetchMatchingDuplicateAccounts(){
        Map<String, Object> fieldMap = new Map<String, Object>{
            'Name'=>'TestAccount',
                'BillingCountry'=>'Spain'
                };
                    Test.startTest();
        fetchDuplicateAccountAndSaveAccount.DuplicateRuleResult result = fetchDuplicateAccountAndSaveAccount.checkDuplicateRules(fieldMap);
        List<Account> Duplicates = fetchDuplicateAccountAndSaveAccount.getMatchingDuplicates(fieldMap, result.ruleName);
        Test.stopTest();
    }
    
    /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     fetchRecordTypeDevName
* @description     This method is used to get the Record Type Developer Name
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/ 
    @isTest
    public static void testGetAccountRecordTypeDeveloperName() {
        String sObjectName = 'Account';
        Account testAc = new Account(
            Name = 'Test Account',
            BillingCountry = 'India',           
            BillingStreet = '123 Main St',
            BillingCity = 'Bangalore',
            BillingState = 'Karnataka'
        );
        insert testAc;
        Test.startTest();
        fetchDuplicateAccountAndSaveAccount.getRecordTypeDetails('Account');
        Test.stopTest();
        
    }
}