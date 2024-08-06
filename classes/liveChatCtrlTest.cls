@isTest
public class liveChatCtrlTest {
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
            Account accObj = new Account();
            accObj.Name = 'testAcc';
            accObj.CustomerID__c = 'test123';
            accObj.Phone = '123456787' ;
            accObj.BillingStreet = 'Street';
            accObj.BillingCity = 'Italy' ;
            accObj.BillingState = ' ';
            accObj.BillingPostalCode = ' ';           
            insert accObj;
            
            Contact conObj = new Contact();
            conObj.LastName = 'testCon';
            conObj.AccountId = accObj.Id;
            conObj.Email = 'Test@testing.com';
            conObj.Phone = '9876543211';
            conObj.MailingStreet = ' ';
            conObj.MailingCity = ' ';
            conObj.MailingState = ' ';
            conObj.MailingPostalCode = ' ';
            conObj.MailingCountry = ' ';
            insert conObj;
            
            UserLicense license = [SELECT Id FROM UserLicense WHERE Name = 'Customer Community Login'];
            Profile portalProfile = [SELECT Id FROM Profile WHERE UserLicenseId = :license.Id Limit 1];
            User portalUser = new User(
                ProfileId = portalProfile.Id,
                LastName = 'last',
                Email = 'testuser@testclass.org',
                Username = 'testuser@testclass.org' + System.currentTimeMillis(),
                CompanyName = 'TEST',
                Country='Italy',
                Alias = 'portal',
                ContactId = conObj.Id,
                TimeZoneSidKey = 'America/Chicago',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'it',
                LocaleSidKey = 'en_GB'
            );
            insert portalUser;
        }  
        
    }
    
    static testMethod void getContactDetailTest(){
        User portalUser = [SELECT Id FROM User WHERE Email = 'testuser@testclass.org' LIMIT 1];
        System.runAs(portalUser){
            System.assert((liveChatCtrl.getContactDetail() != null));
            
        }
    }
    
}