@isTest
public class PortalCreateCaseControllerTest {
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
            insert accObj;
            
            Contact conObj = new Contact();
            conObj.LastName = 'testCon';
            conObj.Email = 'testCon@test.com';
            conObj.AccountId = accObj.Id;
            insert conObj;
            
            Profile portalProfile = [SELECT Id FROM Profile WHERE Name ='Self Service Portal User'];
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
                LocaleSidKey = 'en_US',
                Country='Italy'
            );
            insert portalUser;
        }
    }
    
    testMethod static void getTypeSelectListTest(){
        System.assert(PortalCreateCaseController.getTypeSelectList('Case', 'Type') != null);
    }
    
    testMethod static void createUserCaseTest(){
        Contact con = [SELECT Id FROM Contact WHERE LastName = 'testCon'];
        Case caseObj = new Case(Status='New', ContactId=con.Id);
        User portalUser = [SELECT Id FROM User WHERE Email = 'testuser@testclass.org' LIMIT 1];
        System.runAs(portalUser){
            System.assert(PortalCreateCaseController.createUserCase(caseObj) != null);
        } 
    }
    
    testMethod static void caseResponseEmailTest(){
        Contact con = [SELECT Id FROM Contact WHERE LastName = 'testCon'];
        Case caseObj = new Case(Status='New', ContactId=con.Id);
        User portalUser = [SELECT Id FROM User WHERE Email = 'testuser@testclass.org' LIMIT 1];
        System.runAs(portalUser){
            insert caseObj;
            System.assert(PortalCreateCaseController.caseResponseEmail(caseObj.Id) == null);
        } 
    }
    
}