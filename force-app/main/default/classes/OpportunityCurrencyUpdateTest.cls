@isTest
public class OpportunityCurrencyUpdateTest {
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
        	// Add a dealer account
        	Id accountRecordType = Schema.SObjectType.account.getRecordTypeInfosByName().get('Dealer Account').getRecordTypeId();
        	Account dTestAcc = new Account (Name='TestDealerAccount', RecordTypeId = accountRecordType, CustomerID__c='1234', 
                OwnerId=territoryManager1.Id, BillingCountry='Poland');
        	insert dTestAcc;
                       
            // Add a customer account
            accountRecordType = Schema.SObjectType.account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
            Account cTestAcc = new Account (Name='TestCustomerAccount', RecordTypeId = accountRecordType, OwnerId=territoryManager1.Id, 
                BillingCountry='Poland');
            insert cTestAcc;
            
        	Factory_Order__c newFo = new Factory_Order__c(Dealer_Id__c='1234', Account__c=dTestAcc.Id, Main_Dealer_Name__c='Test Dealer',
                                                                 End_Customer_Name__c='Test Customer', Order_Id__c='1234'); 
        	insert newFo;
        }
    }
    
    @isTest
    static void OpportunityCurrency() {
        // check to see if the currency on the Opportunity is the same as that on the FactoryOrder after the FactoryOrder is updated
        Factory_Order__c fo = [Select Finance_Opportunity__r.Id, Finance_Opportunity__r.CurrencyIsoCode, CurrencyIsoCode, OwnerId From Factory_order__c Where Order_Id__c =: '1234' LIMIT 1][0];
        
        Assert.areEqual(fo.CurrencyIsoCode, 'EUR', 'Initial FO currency is EUR');
        Assert.areEqual(fo.Finance_Opportunity__r.CurrencyIsoCode, 'EUR', 'Initial FO currency is EUR');
        
        fo.CurrencyIsoCode = 'PLN';
        update fo;
        
        // select opportunity after update
        Opportunity opp = [Select CurrencyIsoCode From Opportunity Where Id =: fo.Finance_Opportunity__r.Id LIMIT 1][0];
        
        Assert.areEqual(opp.CurrencyIsoCode, 'PLN', 'Currency on Opp is PLN');
    }
}