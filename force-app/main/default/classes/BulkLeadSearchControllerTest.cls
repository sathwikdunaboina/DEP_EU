@IsTest
public class BulkLeadSearchControllerTest {
    
    @IsTest
    static void testLeadSearch(){
        
        insert new Lead_Assignment_Settings__c(Unallocated_Queue__c = 'Unallocated_Leads');
        Profile profileObj = [Select Id from Profile where name = 'System Administrator'];
        User u = new User(alias = 'standt', email='searchLeadsTest_Positive@testorg.com',
            			 emailencodingkey='UTF-8', firstname='assignLeadsTest_Positive', lastname='Testing', languagelocalekey='en_US',
            			 localesidkey='en_US', profileid = profileObj.Id,CountryCode = 'NL',
            			 timezonesidkey='America/Los_Angeles', username='assignLeadsTest_Positive@testorg.com');
        
        System.runAs(u){
            
            Test.startTest();
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
                Main_Dealer_Name__c = 'Bulk X Transport'
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
                Main_Dealer_Name__c = 'Bulk X Transport'
            );
            insert new List<Factory_Order__c> {fo1, fo2};
                
            Test.stopTest();
            //Assert
            
            List<Lead> allLeads = BulkLeadSearchController.fetchAllLeads ('Bulk' , '', 10);
            List<Lead> myLeads = BulkLeadSearchController.fetchMyLeads ('Bulk' , '', 10);

            system.assert(allLeads != null && allLeads.size()>0);
            system.assert(myLeads == null || myLeads.size() == 0);
        }
    }    
    
    @IsTest
    static void testFetchAccountsOfLeads(){
        
        insert new Lead_Assignment_Settings__c(Unallocated_Queue__c = 'Unallocated_Leads');
        Profile profileObj = [Select Id from Profile where name = 'System Administrator'];
        User u = new User(alias = 'standt', email='searchLeadsTest_Positive@testorg.com',
            			 emailencodingkey='UTF-8', firstname='assignLeadsTest_Positive', lastname='Testing', languagelocalekey='en_US',
            			 localesidkey='en_US', profileid = profileObj.Id,CountryCode = 'NL',
            			 timezonesidkey='America/Los_Angeles', username='assignLeadsTest_Positive@testorg.com');
        
        System.runAs(u){
            
            Test.startTest();
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
                Main_Dealer_Name__c = 'Bulk X Transport'
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
                Main_Dealer_Name__c = 'Bulk X Transport'
            );
            insert new List<Factory_Order__c> {fo1, fo2};
                
            Test.stopTest();
            //Assert
            
            List<String> allAccounts = BulkLeadSearchController.fetchAccountsOfLeads ('Bulk', false);
            List<String> myAccounts = BulkLeadSearchController.fetchAccountsOfLeads ('Bulk', true);

            system.assert(allAccounts != null && allAccounts.size() > 0);
            system.assert(myAccounts == null || myAccounts.size() == 0);
        }
    } 
}