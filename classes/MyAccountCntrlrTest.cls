@isTest
public class MyAccountCntrlrTest {
	   @TestSetup
    static void setup() 
    {
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
            //Id, Name, CompanyRegistrationNumber__c,Phone,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry
            Account accObj = new Account();
            accObj.Name = 'testAcc';
            accObj.CustomerID__c = 'test123';  
            accObj.CompanyRegistrationNumber__c = '1990' ;
            accObj.Phone = '989898989';
            accObj.BillingStreet = 'VIA VALLUMIDA';
            accObj.BillingCity = '1BIS';
            accObj.BillingState = 'Arezzo';
            accObj.BillingPostalCode = '14048';
            accObj.BillingCountry = 'Italy';
            insert accObj;
            
            Contact conObj = new Contact();
            conObj.LastName = 'testCon';
            conObj.AccountId = accObj.Id;
            conObj.Email = 'testuser98@testclass.org' ;
            insert conObj;
            
            UserLicense license = [SELECT Id FROM UserLicense WHERE Name = 'Customer Community Login'];
            Profile portalProfile = [SELECT Id FROM Profile WHERE UserLicenseId = :license.Id Limit 1];
            User portalUser = new User(
                ProfileId = portalProfile.Id,
                LastName = 'last',
                Email = 'testuser@testclass.org',
                Username = 'testuser@testclass.org' + System.currentTimeMillis(),
                CompanyName = 'TEST',
                Title = 'title',
                Alias = 'portal',
                ContactId = conObj.Id,
                TimeZoneSidKey = 'America/Chicago',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US'
            );
            insert portalUser;
        }
    }
    
    testMethod static void getAccount(){
        User portalUser = [SELECT Id FROM User WHERE Email = 'testuser@testclass.org' LIMIT 1];
        System.runAs(portalUser){
            System.assert(MyAccountCntrlr.getAccount() != null);
        } 
    }
}