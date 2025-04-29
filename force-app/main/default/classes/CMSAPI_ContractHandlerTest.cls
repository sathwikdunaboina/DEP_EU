@isTest
public class CMSAPI_ContractHandlerTest {
    @TestSetup
    public static void setupAccount(){
        
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Profile profileObj = [Select Id from Profile where name = 'System Administrator'];
        User owner = new User(
            ProfileId = profileObj.Id,
            UserRoleId = portalRole.Id,
            Username = 'admin@testclass.org' + System.currentTimeMillis(),
            Alias = 'admin',
            Email = 'admin@testclass.org',
            EmailEncodingKey = 'UTF-8',
            Lastname = 'admin',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Chicago'
        );
        insert owner;
        
        System.runAs(owner) 
        {
            //dummy account1
            Account acc = new Account();
            acc.Name = 'Account1Test';
            acc.CustomerID__c = '1234567890';
            acc.BillingCountry = 'Italy';
            Database.insert(acc,true);
            
            //dummy account2 to check failed condition
            Account acc2 = new Account();
            acc2.Name = 'TestAccount2';
            acc2.CustomerID__c = '1234567834';
            acc2.BillingCountry = 'Italy';
            Database.insert(acc2,true);
            
            //dummy contact1
            Contact contact = new Contact(LastName='testPortalUser@cmsapi.com', AccountId = acc.Id, Email = 'cmsapi_contractHandlercntct@test.com');
            insert contact;
            //Inserting a dummy contract to test the contract detail callout
            insert new Contract__c (Account__c = acc.Id, Contract_Id__c = '1234567890-con1234', Contract_Number__c ='con1234');
            
            
            //dummy contact2 to check failed condition
            Contact contact2 = new Contact(LastName='testPortalUser2@cmsapi.com', AccountId = acc2.Id, Email = 'cmsapi_contractHandlercntct2@test.com');
            insert contact2;
            //Inserting a dummy contract to test the contract detail callout
            insert new Contract__c (Account__c = acc2.Id, Contract_Id__c = '1234567834-con12345', Contract_Number__c ='con12345');
            
            /*********************************************below code being commented due to profile is been deleted from org*************************/
            
            /*Profile portalProfile = [SELECT Id FROM Profile WHERE Name='Self Service Portal User'][0];
User portalUser = new User (LastName = 'Portal User', Username='cmsapi_contractHandler@test.com',ProfileId = portalProfile.Id,
ContactId = contact.Id, Email='cmsapi_contractHandler@test.com', Alias='cmsapi',
CommunityNickname='cmsapi',TimeZoneSidKey='Europe/Amsterdam', isActive=True, 
LocaleSidKey='en_GB', EmailEncodingKey='ISO-8859-1',
LanguageLocaleKey='en_US');
insert portalUser;
User portalUser2 = new User (LastName = 'Portal User2', Username='cmsapi_contractHandler2@test.com',ProfileId = portalProfile.Id,
ContactId = contact2.Id, Email='cmsapi_contractHandler2@test.com', Alias='cmsapi2',
CommunityNickname='cmsapi2',TimeZoneSidKey='Europe/Amsterdam', isActive=True, 
LocaleSidKey='en_GB', EmailEncodingKey='ISO-8859-1',
LanguageLocaleKey='en_US');
insert portalUser2;*/
        }
    }  
    
    
    public static testmethod void fetchContractList(){
        
        //User portalUser = [SELECT Id FROM User WHERE Username = 'cmsapi_contractHandler@test.com'][0]; code being commented due to profile is been deleted from org
        
        User portalUser = [SELECT Id FROM User WHERE Email = 'admin@testclass.org'][0];
        Test.setMock(System.HttpCalloutMock.class, new CMSAPI_CalloutMock());
        Test.startTest();
        
        //fetching contracts from portal (as portal user) for the same account
        system.runAs(portalUser){
            CMSAPI_ContractHandler.invokeContractApi(new List<String> {'1234567890'});
        }
        Test.stopTest();
        List<Contract__c> contracts = [SELECT Id FROM Contract__c WHERE Account__r.CustomerId__c = '1234567890'];
        System.assertNotEquals(0, contracts.size(), 'No contracts fetched successfully');
    } 
    
    public static testmethod void fetchContractDetail(){
        Map<String, String> headers =new Map<String, String>();
        
        //User portalUser2 = [SELECT Id FROM User WHERE Username = 'cmsapi_contractHandler2@test.com'][0];code being commented due to profile is been deleted from org
        
        User portalUser2 = [SELECT Id FROM User WHERE Email = 'admin@testclass.org'][0];
        Test.setMock(System.HttpCalloutMock.class, new CMSAPI_CalloutMock());
        
        Test.startTest();
        List<Contract__c> contracts = [SELECT Id, Account__c FROM Contract__c WHERE Account__r.CustomerId__c = '1234567834'];
        system.runAs(portalUser2){
            
            FetchContractListController.getContractList(contracts[0].Account__c);
            //fetching contract detail from portal (as portal user) for the same account
            FetchContractDetailController.getContractDetail(contracts[0].Id);
            System.assertNotEquals(0, contracts.size(), 'No contracts fetched successfully'); 
            
        }
        Test.stopTest();
        
    } 
    public static testmethod void fetchContractDetail2(){
        
        Map<String, String> headers =new Map<String, String>();
        
        //User portalUser = [SELECT Id FROM User WHERE Username = 'cmsapi_contractHandler@test.com'][0];code being commented due to profile is been deleted from org
        
        User portalUser = [SELECT Id FROM User WHERE Email = 'admin@testclass.org'][0];
        Test.setMock(System.HttpCalloutMock.class, new CMSAPI_CalloutMock());
        
        Test.startTest();
        List<Contract__c> contracts = [SELECT Id, Account__c FROM Contract__c WHERE Account__r.CustomerId__c = '1234567890'];
        system.runAs(portalUser){
            
            FetchContractListController.getContractList(contracts[0].Account__c);
            //fetching contract detail from portal (as portal user) for the same account
            FetchContractDetailController.getContractDetail(contracts[0].Id);
            System.assertNotEquals(0, contracts.size(), 'No contracts fetched successfully'); 
        }
        Test.stopTest();
        
    } 
}