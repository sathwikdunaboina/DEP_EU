@IsTest
public with sharing class BulkLeadConvertControllerTest {

    @IsTest
    static void testLeadConvert_happy(){
        
        /*insert new Lead_Assignment_Settings__c(Unallocated_Queue__c = 'Unallocated_Leads');
        Profile profileObj = [Select Id from Profile where name = 'System Administrator'];
        User u = new User(alias = 'standt', email='searchLeadsTest_Positive@testorg.com',
            			 emailencodingkey='UTF-8', firstname='assignLeadsTest_Positive', lastname='Testing', languagelocalekey='en_US',
            			 localesidkey='en_US', profileid = profileObj.Id,CountryCode = 'NL',
            			 timezonesidkey='America/Los_Angeles', username='assignLeadsTest_Positive@testorg.com');        
        System.runAs(u){*/
            
            Test.startTest();
            insertTestFactoryOrders();
            Test.stopTest();
            //Assert
            List<Id> allLeads = new List<Id>(
            	new Map<Id, Lead> ([SELECT Id FROM Lead WHERE Dealer_Name__c = 'Bulk X Transport']).keySet()
        	);
            Boolean success = BulkLeadConvertController.convert(allLeads, null, null);
            
            system.assert(success);
        //}
    }
    
    @IsTest
    static void testLeadConvert_ExistingAccount(){
        
        /*insert new Lead_Assignment_Settings__c(Unallocated_Queue__c = 'Unallocated_Leads');
        Profile profileObj = [Select Id from Profile where name = 'System Administrator'];
        User u = new User(alias = 'standt', email='searchLeadsTest_Positive@testorg.com',
            			 emailencodingkey='UTF-8', firstname='assignLeadsTest_Positive', lastname='Testing', languagelocalekey='en_US',
            			 localesidkey='en_US', profileid = profileObj.Id,CountryCode = 'NL',
            			 timezonesidkey='America/Los_Angeles', username='assignLeadsTest_Positive@testorg.com');        
        System.runAs(u){*/
            
            Test.startTest();
            insertTestFactoryOrders();
            Id accountId = insertTestAccount();
            Id contactId = insertTestContact(accountId);
            Test.stopTest();
            //Assert
            List<Id> allLeads = new List<Id>(
            	new Map<Id, Lead> ([SELECT Id FROM Lead WHERE Dealer_Name__c = 'Bulk X Transport']).keySet()
        	);
            List<Lead> leadList = BulkLeadConvertController.getLeadList(allLeads);
            Boolean success = BulkLeadConvertController.convert(allLeads, accountId, contactId);
            system.assert(success);
        //}
    }
    
    
    @IsTest
    static void testLeadConvert_noLeads(){
        try{
        	Boolean success = BulkLeadConvertController.convert(null, null, null);   
            system.assert(false);
        }catch(Exception exp){
            system.assert(true);
        }
    }
    
    private static void insertTestFactoryOrders(){
        //Insert Factory Orders. This will create Leads
            Factory_Order__c fo1 = new Factory_Order__c (
                Brand__c = 'RT',
                Contact_Last_Name__c = 'John',
                Country__c = 'NL',
                Dealer_Id__c = 'NL-0987654321',
                End_Customer_Address1__c = 'My Street',
                End_Customer_Name__c = 'DHL',
                End_Customer_Phone__c = '12345',
                End_Customer_City__c = 'Utrecht',
                Name = '09876543',
                Main_Dealer_Name__c = 'Bulk X Transport',
                OwnerId = UserInfo.getUserId()
            );
            //Insert Factory Orders. This will create Leads
            Factory_Order__c fo2 = new Factory_Order__c (
                Brand__c = 'VT',
                Contact_Last_Name__c = 'John2',
                Country__c = 'NL',
                Dealer_Id__c = 'NL-09876543212',
                Dealer_Number__c = '09876543212',
                End_Customer_Address1__c = 'My Street',
                End_Customer_Name__c = 'DHL',
                End_Customer_Phone__c = '12345',
                End_Customer_City__c = 'Utrecht',
                Name = '098765432',
                Main_Dealer_Name__c = 'Bulk X Transport',
                OwnerId = UserInfo.getUserId()
            );
            insert new List<Factory_Order__c> {fo1, fo2};
    }
    
    private static Id insertTestAccount(){
        Account act = new Account();
        act.Customer_Number__c = '035000';
        act.CustomerId__c = 'NL-X035000';
        act.Name = 'Test Account';
        act.BillingCountryCode = 'NL';
        insert act;
        return act.Id;
    }
    
    private static Id insertTestContact(Id actId){
        Contact cont = new Contact();
        cont.AccountId = actId;
        cont.Email = 'testConvert@bulk.com';
        cont.LastName = 'Test Contact';
        insert cont;
        return cont.Id;
    }
}