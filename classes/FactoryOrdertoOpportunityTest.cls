@isTest
public class FactoryOrdertoOpportunityTest {
    private static String SalesPersonFirstname = 'Tim';
    private static String SalesPersonLastname = 'Hook';
    
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
            
        	// Add a dealer account
        	Id accountRecordType = Schema.SObjectType.account.getRecordTypeInfosByName().get('Dealer Account').getRecordTypeId();
        	Account dTestAcc = new Account (Name='TestDealerAccount', RecordTypeId = accountRecordType, CustomerID__c='1234', 
                OwnerId=territoryManager1.Id, BillingCountry='Italy');
        	insert dTestAcc;
            
            String cEmail = 'test@contact1.org' + System.currentTimeMillis();
            Contact c = new Contact(FirstName=SalesPersonFirstname,LastName=SalesPersonLastname,Email=cEmail,OwnerId=tm2.Id);//, AccountId=dTestAcc.Id);
	    	insert c;
            
            // Add a customer account
            accountRecordType = Schema.SObjectType.account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
            Account cTestAcc = new Account (Name='TestCustomerAccount', RecordTypeId = accountRecordType, OwnerId=territoryManager1.Id, 
                BillingCountry='Italy');
            insert cTestAcc;
        }
    }
    
    @isTest
    static void insertFo_NoCheckNoSalesPerson() {
        // Dealer_Id__c on FO matches a CustomerID__c on Acc
        Account dealer = [Select Id From Account Where Name = 'TestDealerAccount'][0];

        Factory_Order__c foWithSalesPerson = new Factory_Order__c(Dealer_Id__c='1234', Account__c=dealer.Id, Main_Dealer_Name__c='Test Dealer',
                                                                 End_Customer_Name__c='Test Customer', Order_Id__c='1234'); 
        insert foWithSalesPerson;
        
        // Pause to allow flow to work
        Long startTime = DateTime.now().getTime();
        Long finalTime = DateTime.now().getTime();
        Long millisecondsToWait = 3000; // vary this depending on your "sleep" needs
        while (finalTime - startTime < millisecondsToWait) {
        	finalTime = DateTime.now().getTime();
        }
        
        Factory_Order__c fo = [Select Finance_Opportunity__c, OwnerId From Factory_order__c Where Id =: foWithSalesPerson.Id LIMIT 1][0];
        if (fo.Finance_Opportunity__c != null) {
            Id oppOwnerid = [Select OwnerId From Opportunity Where Id =: fo.Finance_Opportunity__c][0].OwnerId;
            User territoryManager1 = [Select Id,Name From User Where Email = 'territory@manager1.org' LIMIT 1][0];

            Assert.areEqual(oppOwnerid, territoryManager1.Id, 'Opp. owner is the same as account owner');
        } else {
         	Assert.fail('No Opportunity created');   
        }
    }
    
    @isTest
    static void insertFo_WithCheckWithSalesPerson() {
        // Dealer_Id__c on FO matches a CustomerID__c on Acc
        Account dealer = [Select Id From Account Where Name = 'TestDealerAccount'][0];
        
        // This is a setting to match the Sales person with a contact
        dealer.Check_on_dealer_sales_person__c = true;
        update dealer;
        
        Factory_Order__c foWithSalesPerson = new Factory_Order__c(Dealer_Id__c='1234', Account__c=dealer.Id, Main_Dealer_Name__c='Test Dealer',
                                                                  End_Customer_Name__c='Test Customer', Order_Id__c='1234',
                                                                  Sales_Person_Name__c=SalesPersonFirstname + ' ' + SalesPersonLastname);
        insert foWithSalesPerson;
        
        // Pause to allow flow to work
        Long startTime = DateTime.now().getTime();
        Long finalTime = DateTime.now().getTime();
        Long millisecondsToWait = 3000; // vary this depending on your "sleep" needs
        while (finalTime - startTime < millisecondsToWait) {
            finalTime = DateTime.now().getTime();
        }
        
        Factory_Order__c fo = [Select Finance_Opportunity__c, OwnerId From Factory_order__c Where Id =: foWithSalesPerson.Id LIMIT 1][0];
        if (fo.Finance_Opportunity__c != null) {
            Id oppOwnerid = [Select OwnerId From Opportunity Where Id =: fo.Finance_Opportunity__c][0].OwnerId;
            User territoryManager2 = [Select Id,Name From User Where Email = 'territory@manager2.org' LIMIT 1][0];
            
            Assert.areEqual(oppOwnerid, territoryManager2.Id, 'Opp. owner is the same as account owner');
        } else {
            Assert.fail('No Opportunity created');   
        }
    }
    
    @isTest
    static void insertFo_WithCheckNoSalesPerson() {
        // Dealer_Id__c on FO matches a CustomerID__c on Acc
        Account dealer = [Select Id From Account Where Name = 'TestDealerAccount'][0];
        
        // This is a setting to match the Sales person with a contact
        dealer.Check_on_dealer_sales_person__c = true;
        update dealer;
        
        Factory_Order__c foWithSalesPerson = new Factory_Order__c(Dealer_Id__c='1234', Account__c=dealer.Id, Main_Dealer_Name__c='Test Dealer',
                                                                  End_Customer_Name__c='Test Customer', Order_Id__c='1234');
        insert foWithSalesPerson;
        
        // Pause to allow flow to work
        Long startTime = DateTime.now().getTime();
        Long finalTime = DateTime.now().getTime();
        Long millisecondsToWait = 3000; // vary this depending on your "sleep" needs
        while (finalTime - startTime < millisecondsToWait) {
            finalTime = DateTime.now().getTime();
        }
        
        Factory_Order__c fo = [Select Finance_Opportunity__c, OwnerId From Factory_order__c Where Id =: foWithSalesPerson.Id LIMIT 1][0];
        if (fo.Finance_Opportunity__c != null) {
            Id oppOwnerid = [Select OwnerId From Opportunity Where Id =: fo.Finance_Opportunity__c][0].OwnerId;
            User territoryManager1 = [Select Id,Name From User Where Email = 'territory@manager1.org' LIMIT 1][0];
            
            Assert.areEqual(oppOwnerid, territoryManager1.Id, 'Opp. owner is the same as account owner');
        } else {
            Assert.fail('No Opportunity created');   
        }
    }
    
    @isTest
    static void insertFo_NoCheckWithSalesPerson() {
        // Dealer_Id__c on FO matches a CustomerID__c on Acc
        Account dealer = [Select Id From Account Where Name = 'TestDealerAccount'][0];
        
        Factory_Order__c foWithSalesPerson = new Factory_Order__c(Dealer_Id__c='1234', Account__c=dealer.Id, Main_Dealer_Name__c='Test Dealer',
                                                                  End_Customer_Name__c='Test Customer', Order_Id__c='1234',
                                                                  Sales_Person_Name__c=SalesPersonFirstname + ' ' + SalesPersonLastname);
        insert foWithSalesPerson;
        
        // Pause to allow flow to work
        Long startTime = DateTime.now().getTime();
        Long finalTime = DateTime.now().getTime();
        Long millisecondsToWait = 3000; // vary this depending on your "sleep" needs
        while (finalTime - startTime < millisecondsToWait) {
            finalTime = DateTime.now().getTime();
        }
        
        Factory_Order__c fo = [Select Finance_Opportunity__c, OwnerId From Factory_order__c Where Id =: foWithSalesPerson.Id LIMIT 1][0];
        if (fo.Finance_Opportunity__c != null) {
            Id oppOwnerid = [Select OwnerId From Opportunity Where Id =: fo.Finance_Opportunity__c][0].OwnerId;
            User territoryManager1 = [Select Id,Name From User Where Email = 'territory@manager1.org' LIMIT 1][0];
            
            Assert.areEqual(oppOwnerid, territoryManager1.Id, 'Opp. owner is the same as account owner');
        } else {
            Assert.fail('No Opportunity created');   
        }
    }
    
    @isTest
    static void insertFo_CustomerAccount() {
        // Dealer_Id__c on FO does not match any CustomerID__c on Acc
        Account customer = [Select Id From Account Where Name = 'TestCustomerAccount'][0];

        Factory_Order__c fo = new Factory_Order__c(Dealer_Id__c='1111', Account__c=customer.Id, Main_Dealer_Name__c='Test Customer',
                                                                 End_Customer_Name__c='Test Customer', Order_Id__c='12345');
        insert fo;
        
        // Pause to allow flow to work
        Long startTime = DateTime.now().getTime();
        Long finalTime = DateTime.now().getTime();
        Long millisecondsToWait = 3000; // vary this depending on your "sleep" needs
        while (finalTime - startTime < millisecondsToWait) {
        	finalTime = DateTime.now().getTime();
        }
        
        fo = [Select Finance_Opportunity__c, OwnerId From Factory_order__c Where Id =: fo.Id LIMIT 1][0];
        
        Assert.isNull(fo.Finance_Opportunity__c, 'No Opportunity created');
    }
}