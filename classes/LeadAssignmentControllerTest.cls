@isTest
public class LeadAssignmentControllerTest {
    
    testMethod static void assignLeadsTest_Positive(){
        
        Profile profileObj = [Select Id from Profile where name = 'System Administrator'];
        User u = new User(alias = 'standt', email='assignLeadsTest_Positive@testorg.com',
            			 emailencodingkey='UTF-8', firstname='assignLeadsTest_Positive', lastname='Testing', languagelocalekey='en_US',
            			 localesidkey='en_US', profileid = profileObj.Id,CountryCode = 'NL',
            			 timezonesidkey='America/Los_Angeles', username='assignLeadsTest_Positive@testorg.com');
        insert u;
        
        insert new Lead_Assignment_Settings__c(Unallocated_Queue__c = 'Unallocated_Leads');
        
        Territory_Manager__c tm = new  Territory_Manager__c();
        tm.Name = 'assignLeadsTest_Positive';
        tm.Email__c = 'assignLeadsTest_Positive@testorg.com';
        tm.User__c = u.Id;
        tm.Country__c = 'Netherlands';
        insert tm;
        
        


        //Insert dummy Account
        Account act = new Account();
        act.Customer_Number__c = '035000';
        act.CustomerId__c = 'NL-X035000';
        act.Name = 'Test Account';
        act.BillingCountryCode = 'NL';
        act.Territory_Manager__c = tm.Id;
        
        insert act;
        
        List<Account> accListatm= new List<Account>();
        accListatm=[Select Id from Account where Name='Test Account'];
        
        AccountTeamMember atmobj= new AccountTeamMember();
        atmobj.AccountId=accListatm.get(0).ID;
        atmobj.TeamMemberRole='Renault TM';
        List<User> userList=new List<User>();
        userList=[SELECT ID FROM User where username='assignLeadsTest_Positive@testorg.com'];
        
        atmobj.UserId=userList.get(0).ID;
        insert atmobj;
        
        System.runAs(u){
        Test.startTest();
        
        //Insert Factory Order
        Factory_Order__c  facOrder = new Factory_Order__c();
        facOrder.Dealer_Number__c = '035000';
        facOrder.Dealer_Id__c = 'NL-X035000';
        facOrder.End_Customer_Name__c	= 'My Test Customer';
        facOrder.Country__c = 'NL';
        facOrder.Brand__c='RT';
        insert facOrder;
        
        Test.stopTest(); 
             
            //Assert
            List <Lead> automaticLeads = [SELECT Id, OwnerId, Factory_Order__C 
                                          FROM Lead 
                                          WHERE Factory_Order__c =:facOrder.Id];
            // User Story-7542 code changes start                                          
            // System.assert(automaticLeads !=null && !automaticLeads.isEmpty());
            // System.assert(automaticLeads.size() == 1 );
            // System.assert(automaticLeads[0].OwnerId ==  u.Id  );
            // User Story-7542 code changes end
        }
    }
    
    testMethod static void assignLeadsTest_unAllocated(){
        
        Profile profileObj = [Select Id from Profile where name = 'System Administrator'];
        User u = new User(alias = 'standt', email='standarduser6@testorg.com2',
            			 emailencodingkey='UTF-8', firstname='fake', lastname='Testing', languagelocalekey='en_US',
            			 localesidkey='en_US', profileid = profileObj.Id, CountryCode = 'NL',
            			 timezonesidkey='America/Los_Angeles', username='standarduser6@testorg.com2');
        insert u;
        
        insert new Lead_Assignment_Settings__c(Unallocated_Queue__c = 'Unallocated_Leads');
        System.runAs(u){
        Test.startTest();
        //Insert Factory Order
        Factory_Order__c  facOrder = new Factory_Order__c();
        facOrder.Dealer_Number__c = '035000_unallocated';
        facOrder.End_Customer_Name__c	= 'My Test Customer 2';
        facOrder.Country__c = 'NL';
        insert facOrder;
        
        Test.stopTest(); 
         
            //Assert
            List <Lead> automaticLeads = [SELECT Id, OwnerId, Factory_Order__C 
                                          FROM Lead 
                                          WHERE Factory_Order__c =:facOrder.Id];
            // System.assert(automaticLeads !=null && !automaticLeads.isEmpty()); // User Story-7542
            // System.assert(automaticLeads.size() == 1 ); // User Story-7542
            
            String unAllocatedQueue = Lead_Assignment_Settings__c.getInstance().Unallocated_Queue__c;
            Group uQ = [Select Id , Name, DeveloperName from Group Where DeveloperName = :unAllocatedQueue][0];
            
            // System.assert(automaticLeads[0].OwnerId ==  uQ.Id  ); // User Story-7542
               
        }
    }
    testMethod static void assignLeadsTest_WithoutTeamMember(){
        
        Profile profileObj = [Select Id from Profile where name = 'System Administrator'];
        User u = new User(alias = 'standt', email='assignLeadsTest_Positive@testorg.com',
            			 emailencodingkey='UTF-8', firstname='assignLeadsTest_Positive', lastname='Testing', languagelocalekey='en_US',
            			 localesidkey='en_US', profileid = profileObj.Id,CountryCode = 'NL',
            			 timezonesidkey='America/Los_Angeles', username='assignLeadsTest_Positive@testorg.com');
        insert u;
        
        insert new Lead_Assignment_Settings__c(Unallocated_Queue__c = 'Unallocated_Leads');
        
        Territory_Manager__c tm = new  Territory_Manager__c();
        tm.Name = 'assignLeadsTest_Positive';
        tm.Email__c = 'assignLeadsTest_Positive@testorg.com';
        tm.User__c = u.Id;
        tm.Country__c = 'Netherlands';
        insert tm;
        
        


        //Insert dummy Account
        Account act = new Account();
        act.Customer_Number__c = '035000';
        act.CustomerId__c = 'NL-X035000';
        act.Name = 'Test Account';
        act.BillingCountryCode = 'NL';
        act.Territory_Manager__c = tm.Id;
        insert act;
        
        List<Account> accListatm= new List<Account>();
        accListatm=[Select Id from Account where Name='Test Account'];

        
        System.runAs(u){
        Test.startTest();
        
        //Insert Factory Order
        Factory_Order__c  facOrder = new Factory_Order__c();
        facOrder.Dealer_Number__c = '035000';
        facOrder.Dealer_Id__c = 'NL-X035000';
        facOrder.End_Customer_Name__c	= 'My Test Customer';
        facOrder.Country__c = 'NL';
        insert facOrder;
        
        Test.stopTest(); 
             
            //Assert
            List <Lead> automaticLeads = [SELECT Id, OwnerId, Factory_Order__C 
                                          FROM Lead 
                                          WHERE Factory_Order__c =:facOrder.Id];
            // User Story-7542 code changes start                                          
            // System.assert(automaticLeads !=null && !automaticLeads.isEmpty());
            // System.assert(automaticLeads.size() == 1 );
            // System.assert(automaticLeads[0].OwnerId ==  u.Id  );
            // User Story-7542 code changes end
        }
    }
}