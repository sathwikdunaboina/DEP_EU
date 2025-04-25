public with sharing class CustomerController {
    @AuraEnabled(Cacheable=true scope='global')
    public static List<Account> getAllCustomers() {
        Id customerRecordTypeId = [SELECT Id FROM RecordType where DeveloperName = 'Customer_Account'][0].Id;
        List<Account> customers = [SELECT Id, Name, Customer_Number__c, BillingStreet, BillingCity FROM Account WHERE RecordTypeId = :customerRecordTypeId];
        return customers;
    }
    
    @AuraEnabled(Cacheable=true scope='global')
    public static List<Account> getCustomersByOpportunityId(Id opportunityId) {
        // Get the relating Factory Orders for these Opportunities
        List<string> customerNames = new List<string>();
        List<Factory_Order__c> factoryOrders = [SELECT End_Customer_Name__c FROM Factory_Order__c WHERE Finance_Opportunity__r.Id = :opportunityId];
        for (Factory_Order__c factoryOrder: factoryOrders) {
            customerNames.add('%' + factoryOrder.End_Customer_Name__c + '%');
        }
        // Now retrieve Accounts based off of the End_Customer_Name__c on Factory Orders
        Id customerRecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Customer_Account'][0].Id;
        List<Account> customers = [SELECT Id, Name, Customer_Number__c, BillingStreet, BillingCity FROM Account WHERE RecordTypeId = :customerRecordTypeId AND Name LIKE :customerNames LIMIT 10];
        return customers;
    }
    
    @AuraEnabled(Cacheable=true scope='global')
    public static List<Account> getCustomersByName(string name) {
        Id customerRecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Customer_Account'][0].Id;
        string searchString = '%' + name + '%';
        List<Account> customers = [SELECT Id, Name, Customer_Number__c, BillingStreet, BillingCity from Account where RecordTypeId = :customerRecordTypeId AND (Name LIKE :searchString OR Customer_Number__c LIKE :searchString) LIMIT 10];
        return customers;
    }
}