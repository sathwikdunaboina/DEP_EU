/* 
* -----------------------------------------------------------------------------------------
* Apex Class Name     UpdContactIdWhenContactCreateOrUpd_Test
* @author             Sugapriya Vanjiyappan <sugapriya.vanjiyappan@consultant.volvo.com> 
* @Created Date       03-03-2026       
* ------------------------------------------------------------------------------------------
* @description        This class is used to test Update Contact Unique Id When Contact Create/Update Flow
* ------------------------------------------------------------------------------------------
*/
@IsTest(SeeAllData=false)
public class UpdContactIdWhenContactCreateOrUpd_Test {
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
        String sUniqueUserName = 'TestContactId' + DateTime.now().getTime() + '@testorg.com';
        User oTestUser = new User(Alias = 'tstcs', Email='testContact@testorg.com',
                                  EmailEncodingKey='UTF-8', LastName='TestContactId', LanguageLocaleKey='en_US',
                                  LocaleSidKey='en_GB', ProfileId = iProfileId,TimeZoneSidKey='Europe/Paris',
                                  Country = '',UserName=sUniqueUserName);
        insert oTestUser;
        
        System.runAs(new User(Id = UserInfo.getUserId())){ 
            Account testCustomerAccount = new Account();
            testCustomerAccount.Name = 'TestAccount';
            testCustomerAccount.BillingCountry = 'United Kingdom';
            testCustomerAccount.CustomerID__c = 'GB-4567';
            insert testCustomerAccount;
            
            Contact testContact = new Contact();
            testContact.LastName = 'TestUser';
            testContact.Email = 'test@volvo.com';
            testContact.AccountId = testCustomerAccount.Id;
            insert testContact;
                    }
    }
    
    /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     createANewContact
* @description     This method is used to test ContactId update on Contact Creation
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/  
    
    @isTest
    public static void createANewContact(){
        Contact fetchCreatedContact = [SELECT Id,Email,AccountId,ContactId__c FROM Contact WHERE LastName='TestUser'];
        Test.startTest();
        System.assertEquals('GB-4567-test@volvo.com',fetchCreatedContact.ContactId__c);
        Test.stopTest();
    }
}