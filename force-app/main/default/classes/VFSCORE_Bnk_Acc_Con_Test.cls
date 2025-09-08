/**
* Name of the class    VFSCORE_Bnk_Acc_Con_Test
* Author               Aswin Balaji M
* Create Date  		   03-20-2024
* Used by 			   Handler
* SystemLayer		   Test class
* Description          Test class to cover Change data capture of Account,Contact,Bank Account and Bank Account Mandate
* Classes covered	   VFSCORE_AccountChangeEventTriggerHandler, VFSCORE_ContactChangeEventTriggerHandler, 
					   VFSCORE_BnkAccChangeEventTriggerHandler, VFSCORE_BnkAccManChngeEvntTriggerHandler
*/
@isTest
public class VFSCORE_Bnk_Acc_Con_Test {
    @testSetup 
    static void setup() {
        Id tmRoleId = [Select Id,DeveloperName From UserRole Where DeveloperName = 'IT_Territory_Manager' Limit 1][0].Id;
        Id salesProfileId = [Select Id from Profile where Name = 'Sales' LIMIT 1][0].Id;
        
        User territoryManager1 = new User(
            ProfileId = salesProfileId,
            UserRoleId = tmRoleId,
            Username = 'territory@manager1.org' + System.currentTimeMillis(),
            Alias = 'tm1',
            Email = 'territory@manager1.org',
            EmailEncodingKey = 'UTF-8',
            Firstname = 'Territory',
            Lastname = 'Manager1',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'Europe/Rome'
        );
        insert territoryManager1;
        
        User territoryManager2 = new User(
            ProfileId = salesProfileId,
            UserRoleId = tmRoleId,
            Username = 'territory@manager2.org' + System.currentTimeMillis(),
            Alias = 'tm2',
            Email = 'territory@manager2.org',
            EmailEncodingKey = 'UTF-8',
            Firstname = 'Territory',
            Lastname = 'Manager2',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'Europe/Rome'
        );
        insert territoryManager2;
        
        Id adminProfileId = [Select Id from Profile where name = 'System Administrator' LIMIT 1][0].Id;
        
        User admin = new User(
            ProfileId = adminProfileId,
            UserRoleId = tmRoleId,
            Username = 'admin@test.org' + System.currentTimeMillis(),
            Alias = 'adm',
            Email = 'admin@test.org',
            EmailEncodingKey = 'UTF-8',
            Firstname = 'Test',
            Lastname = 'Admin',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'Europe/Rome'
        );
        insert admin;
        
        System.runAs(admin) 
        {
            User tm2 = [Select Id,Name From User Where Email = 'territory@manager2.org' LIMIT 1][0];
            
            Id accountRecordType = Schema.SObjectType.account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
            Account custTestAcc = new Account (Name='TestCustomerAccount_VFSCORE', RecordTypeId = accountRecordType, CustomerID__c='1234', 
                                               OwnerId=territoryManager1.Id, BillingCountry='France', sourceSystemID__c = 'FR94-SF',CompanyRegistrationNumber__c = '12345678901234'
 );
            insert custTestAcc;
            
            String cEmail = 'test@contact1.org' + System.currentTimeMillis();
            Contact c = new Contact(FirstName='first',LastName='TestCustomerContact_VFSCORE',Email=cEmail,OwnerId=tm2.Id,
                                    AccountId = custTestAcc.Id);
            insert c;
            
            Bank_Account__c bankAccount = new Bank_Account__c (Name = 'Test Bank Account_VFSCORE');
            insert bankAccount;
            
            Linked_Bank_Accounts__c linkedBankAccount = new Linked_Bank_Accounts__c(Bank_Account__c = bankAccount.Id,
                                                                                    Account__c = custTestAcc.Id);
            insert linkedBankAccount;
            
            Bank_Account_Mandate__c bankAccountMandate = new Bank_Account_Mandate__c(Bank_Account__c = bankAccount.Id,
                                                                                     Is_Active__c = True,
                                                                                     Name = 'Test bank account mandate_VFSCORE');
            insert bankAccountMandate;
        }
    }
    @isTest
    static void runTestToInvoke() {
        User tm2 = [Select Id,Name From User Where Email = 'territory@manager2.org' LIMIT 1][0];
        Account customerAccount = [SELECT Id,CustomerID__c FROM Account WHERE Name = 'TestCustomerAccount_VFSCORE'][0];
        customerAccount.CustomerID__c = '1233';
        update customerAccount;
        Test.getEventBus().deliver();
        Contact customerContact = [SELECT Id,FirstName FROM Contact WHERE LastName = 'TestCustomerContact_VFSCORE'][0];
        customerContact.FirstName = 'firstUpdate';
        update customerContact;
        Test.getEventBus().deliver();
        Bank_Account__c bankAccount = [SELECT Id,Name FROM Bank_Account__c WHERE Name = 'Test Bank Account_VFSCORE'][0];
        bankAccount.Name = 'Test Bank Account_VFSCOREUpdate';
        update bankAccount;
        Test.getEventBus().deliver();
        Linked_Bank_Accounts__c LBA = [SELECT Id,Account__c,Bank_Account__c,Account__r.sourceSystemID__c From Linked_Bank_Accounts__c Where Bank_Account__c =: bankAccount.Id];
        System.debug(LBA);
        Bank_Account_Mandate__c bankAccountMandate = [SELECT Id,Name FROM Bank_Account_Mandate__c WHERE Name = 'Test bank account mandate_VFSCORE'][0];
        bankAccountMandate.Name = 'Test bank account mandate_VFSCOREUpdate';
        update bankAccountMandate;
        Test.getEventBus().deliver();
    }
}