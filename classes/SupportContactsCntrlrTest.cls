@isTest
public class SupportContactsCntrlrTest {
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
            TimeZoneSidKey = 'America/Chicago',
            Country  = 'Italy'
        );
        insert owner;
        
        System.runAs(owner) 
        {
            
      		Territory_Manager__c mngrObj = new Territory_Manager__c();
            mngrObj.Name = 'Test mngr' ;
            mngrObj.Phone__c = '99999999999';
            mngrObj.Email__c = 'test@test.com';
			insert mngrObj;
            
            Account accObj = new Account();
            accObj.Name = 'testAcc';
            accObj.CustomerID__c = 'test123';    
            accObj.Territory_Manager__c = mngrObj.id;
            insert accObj;
            
            //Account to check no territory mngr
            Account accObj2 = new Account();
            accObj2.Name = 'testAcc2';
            accObj2.CustomerID__c = 'test1234'; 
            insert accObj2;
            
            Contact conObj = new Contact();
            conObj.LastName = 'testCon';
            conObj.AccountId = accObj.Id;
            conObj.Email = 'testuser98@testclass.org' ;
            insert conObj;
            
            //2nd contact
            Contact conObj2 = new Contact();
            conObj2.LastName = 'testCon2';
            conObj2.AccountId = accObj2.Id;
            conObj2.Email = 'testuser987@testclass.org' ;
            insert conObj2;
            
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
            User portalUser2 = new User(
                ProfileId = portalProfile.Id,
                LastName = 'last',
                Email = 'testuser2@testclass.org',
                Username = 'testuser2@testclass.org' + System.currentTimeMillis(),
                CompanyName = 'TEST',
                Title = 'title',
                Alias = 'portal',
                ContactId = conObj2.Id,
                TimeZoneSidKey = 'America/Chicago',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US'
            );
            insert portalUser;
            insert portalUser2;
        }
    }
    
    testMethod static void getContactDetailTest(){
        User portalUser = [SELECT Id FROM User WHERE Email = 'testuser@testclass.org' LIMIT 1];
        System.runAs(portalUser){
            System.assert(SupportContactsCntrlr.getTerritoryMngr() != null);
        } 
    }
    testMethod static void getContactDetailTest2(){
        User portalUser = [SELECT Id FROM User WHERE Email = 'testuser2@testclass.org' LIMIT 1];
        System.runAs(portalUser){
            SupportContactsCntrlr.getTerritoryMngr();
        } 
    }
    
    testMethod static void getSupportContactDetailTest(){
        User portalUser = [SELECT Id FROM User WHERE Email = 'testuser@testclass.org' LIMIT 1];
        System.runAs(portalUser){
            System.assert(SupportContactsCntrlr.getServiceDesk() != null);
        } 
    }
    
    
}