/**
Author: Bennie 
Date: Sep 2023
Test class for Customer Controller

**/
@isTest
public class CustomerControllerTest {
    @testSetup static void setup() {
        // Add a customer account
        Id accountRecordType = Schema.SObjectType.account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
        
        Account singleTestAcc = new Account (Name='TestCustomerAccount', RecordTypeId = AccountRecordType);
        insert singleTestAcc;
        
        // Add a dealer account
        accountRecordType = Schema.SObjectType.account.getRecordTypeInfosByName().get('Dealer Account').getRecordTypeId();        
        singleTestAcc = new Account (Name='TestDealerAccount', RecordTypeId = AccountRecordType);
        insert singleTestAcc;
        
        // Add a factory order with a valid End_Customer_Name
        Factory_Order__c singleTestFacOrd = new Factory_Order__c (Name = 'Test Order1',
                                                                  End_Customer_Name__c = 'TestCustomerAccount');
        insert singleTestFacOrd;
        
        // Add opportunity for the dealer account (the last account added)
        Opportunity singleTestOpp = new Opportunity(Name='TestOpp1', 
                                        Account = singleTestAcc,
                                        CloseDate = Date.today(),
                                        StageName ='New');
        insert singleTestOpp;
        
        // Link the opportunity to the FO
        singleTestFacOrd.Finance_Opportunity__c = singleTestOpp.Id;
        update singleTestFacOrd;
        
        // Add a factory order with an invalid End_Customer_Name (Adding the dealer account here, but anything besides TestCustomerAccount will do)
        singleTestFacOrd = new Factory_Order__c (Name = 'Test Order2',
                                    			End_Customer_Name__c = 'TestDealerAccount');
        insert singleTestFacOrd; 
        
        // Add opportunity for the dealer account (the last account added)
        singleTestOpp = new Opportunity(Name='TestOpp2', 
                                        Account = singleTestAcc,
                                        CloseDate = Date.today(),
                                        StageName ='New');
        insert singleTestOpp;
        
        // Link the opportunity to the FO
        singleTestFacOrd.Finance_Opportunity__c = singleTestOpp.Id;
        update singleTestFacOrd;
    }
    
    @isTest
    static void getAllCustomers() {
        // We added two customers but only one is of Customer Account
        List<Account> theTestAccs = CustomerController.getAllCustomers();
        System.debug('The Accounts '+ theTestAccs);
        System.Assert.areEqual(theTestAccs[0].Name , 'TestCustomerAccount');
        System.Assert.areEqual(theTestAccs.size(), 1);
    }
    
    @isTest
    static void getCustomersByOpportunityIdValid() {
        // The FO for this opportunity has a valid End_Customer_Name
        Id singleTestOppId = [SELECT Id FROM Opportunity WHERE Name = 'TestOpp1'][0].Id;
        List<Account> theTestAccs = CustomerController.getCustomersByOpportunityId(singleTestOppId);
        System.debug('The Accounts '+ theTestAccs);
        System.Assert.areEqual(theTestAccs[0].Name , 'TestCustomerAccount');
        System.Assert.areEqual(theTestAccs.size(), 1);
    }
    
    @isTest
    static void getCustomersByOpportunityIdInvalid() {
        // The FO for this opportunity has an invalid End_Customer_Name
        Id singleTestOppId = [SELECT Id FROM Opportunity WHERE Name = 'TestOpp2'][0].Id;
        List<Account> theTestAccs = CustomerController.getCustomersByOpportunityId(singleTestOppId);
        System.debug('The Accounts '+ theTestAccs);
        System.Assert.areEqual(theTestAccs.size(), 0);
    }
    
    @isTest
    static void getCustomersByNameCustomer() {
        // Test, Customer or Account will work as it is all contained in TestCustomerAccount
        List<Account> theTestAccs = CustomerController.getCustomersByName('Customer');
        System.debug('The Accounts '+ theTestAccs);
        System.Assert.areEqual(theTestAccs[0].Name , 'TestCustomerAccount');
        System.Assert.areEqual(theTestAccs.size(), 1);
    }
    
    @isTest
    static void getCustomersByNameDealer() {
        // Adding Dealer here, but anything besides Test, Customer or Account will do to pass this test
        List<Account> theTestAccs = CustomerController.getCustomersByName('Dealer');
        System.debug('The Accounts '+ theTestAccs);
        System.Assert.areEqual(theTestAccs.size(), 0);
    }
}