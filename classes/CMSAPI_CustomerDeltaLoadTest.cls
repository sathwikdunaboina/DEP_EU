@IsTest
public class CMSAPI_CustomerDeltaLoadTest {
    public static testmethod void customerDeltaLoadTest(){
        Profile apiProf = [SELECT Id FROM Profile WHERE Name='API Only'][0];
        User apiUser = new User (LastName = 'API User', Username='cmsapi_customerDelta@test.com',ProfileId = apiProf.Id,
                                Email='cmsapi_customerDelta@test.com', Alias='cmsapi',
                                CommunityNickname='cmsapi',TimeZoneSidKey='Europe/Amsterdam',
                                LocaleSidKey='en_GB', EmailEncodingKey='ISO-8859-1',
                                LanguageLocaleKey='en_US');
        insert apiUser;
        Test.setMock(System.HttpCalloutMock.class, new CMSAPI_CalloutMock());
        Test.startTest();
        system.runAs(apiUser){
            insert new Account (
            	Name='123123',
                CustomerID__c ='123123',
                BillingCountryCode = 'IT'
            );
            CMSAPI_CustomerDetailsHandler.fetchCustomerDetails(new List<String> {'123123'});
        }
        Test.stopTest();
        //The static resource has 1 Account and 1 contact.
        //make sure the upsert, updated the 1 account and created 1 new contact.
        List<Account> acc = [SELECT Id FROM Account WHERE CreatedById =: apiUser.Id];
        System.assertEquals(1, acc.size(), 'More than 1 Account presetn. The API Call created a new one, istead of updating the old one.');
        System.assertEquals(1, [SELECT Id FROM Contact WHERE AccountId =: acc[0].Id ].size(), 'The API Call didnt upsert the contacts properly.');
    } 
}