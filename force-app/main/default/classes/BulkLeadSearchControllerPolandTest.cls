@IsTest
public class BulkLeadSearchControllerPolandTest {
    
    @IsTest
    static void testLeadSearch(){
        
        insert new Lead_Assignment_Settings__c(Unallocated_Queue__c = 'Unallocated_Leads');
        Profile profileObj = [Select Id from Profile where name = 'System Administrator'];
        User u = new User(alias = 'standt', email='searchLeadsTest_Positive@testorg.com',
            			 emailencodingkey='UTF-8', firstname='assignLeadsTest_Positive', lastname='Testing', languagelocalekey='en_US',
            			 localesidkey='en_US', profileid = profileObj.Id,CountryCode = 'PL',Golden_Copy_User__c = True,
            			 timezonesidkey='America/Los_Angeles', username='assignLeadsTest_Positive@testorg.com');
        
        System.runAs(u){
            
            Test.startTest();
            //Insert Factory Orders. This will create Leads
            FactoryOrder__c fo1 = new FactoryOrder__c (
                Brand__c = 'RT',
                ContactLastName__c = 'John',
                Country__c = 'PL',
                DealerId__c = 'PL-0987654321',
                EndCustomerAddress__c = 'My Street',
                EndCustomerName__c = 'DHL',
                EndCustomerPhone__c = '12345',
                EndCustomerCity__c = 'Utrecht',
                Name = '09876543',
                MainDealerName__c = 'Bulk X Transport'
            );
            //Insert Factory Orders. This will create Leads
            FactoryOrder__c fo2 = new FactoryOrder__c (
                Brand__c = 'VT',
                ContactLastName__c = 'John2',
                Country__c = 'PL',
                DealerId__c = 'PL-09876543212',
                DealerNumber__c = '09876543212',
                EndCustomerAddress__c = 'My Street',
                EndCustomerName__c = 'DHL',
                EndCustomerPhone__c = '12345',
                EndCustomerCity__c = 'Utrecht',
                Name = '098765432',
                MainDealerName__c = 'Bulk X Transport'
            );
            insert new List<FactoryOrder__c> {fo1, fo2};
                
            Test.stopTest();
            //Assert
            
            List<Lead> allLeads = BulkLeadSearchControllerPoland.fetchAllLeads ('Bulk' , '', 10);
            List<Lead> myLeads = BulkLeadSearchControllerPoland.fetchMyLeads ('Bulk' , '', 10);

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
            			 localesidkey='en_US', profileid = profileObj.Id,CountryCode = 'PL',Golden_Copy_User__c = True,
            			 timezonesidkey='America/Los_Angeles', username='assignLeadsTest_Positive@testorg.com');
        
        System.runAs(u){
            
            Test.startTest();
            //Insert Factory Orders. This will create Leads
            FactoryOrder__c fo1 = new FactoryOrder__c (
                Brand__c = 'RT',
                ContactLastName__c = 'John',
                Country__c = 'PL',
                DealerId__c = 'PL-0987654321',
                EndCustomerAddress__c = 'My Street',
                EndCustomerName__c = 'DHL',
                EndCustomerPhone__c = '12345',
                EndCustomerCity__c = 'Utrecht',
                Name = '09876543',
                MainDealerName__c = 'Bulk X Transport'
            );
            //Insert Factory Orders. This will create Leads
            FactoryOrder__c fo2 = new FactoryOrder__c (
                Brand__c = 'VT',
                ContactLastName__c = 'John2',
                Country__c = 'PL',
                DealerId__c = 'PL-09876543212',
                DealerNumber__c = '09876543212',
                EndCustomerAddress__c = 'My Street',
                EndCustomerName__c = 'DHL',
                EndCustomerPhone__c = '12345',
                EndCustomerCity__c = 'Utrecht',
                Name = '098765432',
                MainDealerName__c = 'Bulk X Transport'
            );
            insert new List<FactoryOrder__c> {fo1, fo2};
                
            Test.stopTest();
            //Assert
            
            List<String> allAccounts = BulkLeadSearchControllerPoland.fetchAccountsOfLeads ('Bulk', false);
            List<String> myAccounts = BulkLeadSearchControllerPoland.fetchAccountsOfLeads ('Bulk', true);

            system.assert(allAccounts != null && allAccounts.size() > 0);
            system.assert(myAccounts == null || myAccounts.size() == 0);
        }
    } 
}