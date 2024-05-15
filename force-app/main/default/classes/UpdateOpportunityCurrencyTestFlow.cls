/**
* Name of the class    UpdateOpportunityCurrencyTestFlow
* Author               Aswin Balaji M
* Create Date  		   13-05-2024
* Used by 			   Trigger Flow - Update Opportunity Currency
* SystemLayer		   Test class
* Description          Test class to cover currency update from customer account if it not null and if the opportunity 
					   currency and customer currency is not equals same then the flow trigger's and update the currencyIsoCode
* Classes covered	   N/A
*/
@isTest
public class UpdateOpportunityCurrencyTestFlow {
    private static String sSalesPersonFirstname = 'Tim';
    private static String sSalesPersonLastname = 'Hook';
    
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
            
            String sEmail = 'test@contact1.org' + System.currentTimeMillis();
            Contact c = new Contact(FirstName=sSalesPersonFirstname,LastName=sSalesPersonLastname,Email=sEmail,OwnerId=tm2.Id);//, AccountId=dTestAcc.Id);
            insert c;
            
            // Add a customer account
            accountRecordType = Schema.SObjectType.account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
            Account cTestAcc = new Account (Name='TestCustomerAccount', RecordTypeId = accountRecordType, OwnerId=territoryManager1.Id, 
                                            BillingCountry='Italy', CurrencyISOCode = 'GBP');
            insert cTestAcc;
        }
    }
    
    @isTest
    static void updateOpportunity() {
        // Dealer_Id__c on FO matches a CustomerID__c on Acc
        Account dealer = [Select Id From Account Where Name = 'TestDealerAccount'][0];
        Account customer = [Select Id From Account Where Name = 'TestCustomerAccount'][0];
        Factory_Order__c foWithSalesPerson = new Factory_Order__c(Dealer_Id__c='1234', Account__c=dealer.Id, Main_Dealer_Name__c='Test Dealer',
                                                                  End_Customer_Name__c='Test Customer', Order_Id__c='1234'); 
        insert foWithSalesPerson;
        
        // Pause to allow flow to work
        Long lStartTime = DateTime.now().getTime();
        Long lFinalTime = DateTime.now().getTime();
        Long millisecondsToWait = 3000; // vary this depending on your "sleep" needs
        while (lFinalTime - lStartTime < millisecondsToWait) {
            lFinalTime = DateTime.now().getTime();
        }
        System.debug(foWithSalesPerson);
        Factory_Order__c fo = [Select Finance_Opportunity__c, OwnerId From Factory_order__c Where Id =: foWithSalesPerson.Id LIMIT 1][0];
        if (fo.Finance_Opportunity__c != null) {
            Opportunity opp = [Select OwnerId,Customer_Account__c From Opportunity Where Id =: fo.Finance_Opportunity__c LIMIT 1];
            opp.Customer_Account__c = customer.Id;
            update opp;
            System.debug(fo.Finance_Opportunity__c);
            System.assertEquals(customer.Id, opp.Customer_Account__c, 'Customer matched');
        } else {
            Assert.fail('No Opportunity created');   
        }
    }
}