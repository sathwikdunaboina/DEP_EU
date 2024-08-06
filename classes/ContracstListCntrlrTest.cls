@isTest
public class ContracstListCntrlrTest {
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
            accObj.Branding__c = 'Volvo';
            accObj.CustomerID__c = 'test123';           
            insert accObj;
            
            Contact conObj = new Contact();
            conObj.LastName = 'testCon';
            conObj.AccountId = accObj.Id;
            insert conObj;
            
            Contract__c contObj = new Contract__c();
            contObj.Account__c = accObj.Id;
            contObj.Contract_Id__c = 'cont1234';
            insert contObj;
            
            Payment_Plan__c payPlnObj = new Payment_Plan__c();
            payPlnObj.Contract__c = contObj.Id;
            insert payPlnObj;            
            
            Profile portalProfile = [SELECT Id FROM Profile WHERE Name='Self Service Portal User' Limit 1];
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
    
    static testMethod void getContractSummariesByContractIdTest(){
        User portalUser = [SELECT Id FROM User WHERE Email = 'testuser@testclass.org' LIMIT 1];
        System.runAs(portalUser){
            System.assert((ContracstListCntrlr.getContractSummariesByContractId('Due Date', 'ASC', 0, 10, '') != null));
            System.assert((ContracstListCntrlr.getContractSummariesByContractId('Maturity Date', 'ASC', 0, 10, '') != null));
            System.assert((ContracstListCntrlr.getContractSummariesByContractId('', 'ASC', 0, 10, '') != null));
            System.assert((ContracstListCntrlr.getContractSummariesByContractId('', 'ASC', 0, 10, 'test') != null));
        }
    }
    
    static testMethod void getContractRecordsTest(){
        User portalUser = [SELECT Id FROM User WHERE Email = 'testuser@testclass.org' LIMIT 1];
        System.runAs(portalUser){
            System.assert((ContracstListCntrlr.getContractRecords('Due Date', 'ASC', '1', '') != null));
            System.assert((ContracstListCntrlr.getContractRecords('Number', 'ASC', '1', '') != null));
            System.assert((ContracstListCntrlr.getContractRecords('Maturity Date', 'ASC', '1', '') != null));
            System.assert((ContracstListCntrlr.getContractRecords('', 'ASC', '1', '') != null));
            System.assert((ContracstListCntrlr.getContractRecords('', 'ASC', '2', '') != null));
            System.assert((ContracstListCntrlr.getContractRecords('', 'ASC', '2', 'cont1234') != null));
        }
    }
        
    static testMethod void getContractRecordsTotalTest(){
        User portalUser = [SELECT Id FROM User WHERE Email = 'testuser@testclass.org' LIMIT 1];
        System.runAs(portalUser){
            System.assert((ContracstListCntrlr.getContractRecordsTotal() > 0));
        }
    }
}