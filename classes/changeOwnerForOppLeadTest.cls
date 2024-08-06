@isTest
public class changeOwnerForOppLeadTest {
    
     static testmethod void dealerTest(){
         
         //Test Data Creation 
           Profile profileObj = [Select Id from Profile where name = 'System Administrator'];
        User u = new User(alias = 'standt', email='assignLeadsTest_Positive@testorg.com',
                         emailencodingkey='UTF-8', firstname='assignLeadsTest_Positive', lastname='Testing', languagelocalekey='en_US',
                         localesidkey='en_US', profileid = profileObj.Id,CountryCode = 'NL',
                         timezonesidkey='America/Los_Angeles', username='assignLeadsTest_Positive@testorg.com');
        insert u;
         
        User u2 = new User(alias = 'standt', email='assignLeadsTest_Positive2@testorg.com',
                         emailencodingkey='UTF-8', firstname='assignLeadsTest_Positive2', lastname='Testing2', languagelocalekey='en_US',
                         localesidkey='en_US', profileid = profileObj.Id,CountryCode = 'NL',
                         timezonesidkey='America/Los_Angeles', username='assignLeadsTest_Positive2@testorg.com');
        insert u2;
        
        Territory_Manager__c tm = new  Territory_Manager__c();
        tm.Name = 'assignLeadsTest_Positive';
        tm.Email__c = 'assignLeadsTest_Positive@testorg.com';
        tm.User__c = u.Id;
        tm.Country__c = 'Netherlands';
        insert tm;
         
         
        Territory_Manager__c tm2 = new  Territory_Manager__c();
        tm2.Name = 'assignLeadsTest_Positive2';
        tm2.Email__c = 'assignLeadsTest_Positive2@testorg.com';
        tm2.User__c = u2.Id;
        tm2.Country__c = 'Netherlands';
        insert tm2;
        
        DealerRecordTypeId__mdt namet=DealerRecordTypeId__mdt.getInstance('IdName');
        //String idName=namet;
        //Insert dummy Account
        Account act = new Account();
        act.Customer_Number__c = '035000';
        act.CustomerId__c = 'NL-X035000';
        act.Name = 'Test Account';
        act.BillingCountryCode = 'NL';
        act.Territory_Manager__c = tm.Id;
        act.RecordTypeId=namet.IdData__c;
        insert act;
         
        Factory_Order__c  facOrder = new Factory_Order__c();
        facOrder.Dealer_Number__c = '035000';
        facOrder.Dealer_Id__c = 'NL-X035000';
        facOrder.End_Customer_Name__c   = 'My Test Customer';
        facOrder.Country__c = 'NL';
        insert facOrder;
        
        Lead leadObj=new Lead();
        leadObj.Factory_Order__c=facOrder.Id;
        leadObj.Status='New';
        leadObj.OwnerId=tm.User__c;
        leadObj.LastName='Test Last Name';
        leadObj.Company='Test Company';
        insert leadObj;
        
        Opportunity opp=new Opportunity();
        opp.Factory_Order__c=facOrder.Id;
        opp.Name='Test Opp';
        opp.OwnerId=tm.User__c;
        opp.StageName='Quoted';
        opp.CloseDate=Date.today()+1;
        insert opp;
        
        List<Account> accList=new List<Account>();
        accList =[SELECT ID,NAME,Territory_Manager__c FROM Account Where NAME ='Test Account'];
        List<Territory_Manager__c> tmList=new List<Territory_Manager__c>();
        tmList=[SELECT ID,Name from Territory_Manager__c where Name ='assignLeadsTest_Positive2' ];
                 Test.startTest();

        List<Account> updatedAccList=new List<Account>();
        for(Account acc :accList)
        {
         acc.Territory_Manager__c=tmList.get(0).Id;
         updatedAccList.add(acc);
         }
         update updatedAccList;
         Test.stopTest(); 
         List<Lead> leadListCheck=new List<Lead>();
         List<Opportunity> oppListCheck=new List<Opportunity>();
         leadListCheck=[SELECT ID, OwnerId FROM Lead WHERE LastName='Test Last Name' ];
         oppListCheck =[SELECT ID, OwnerId FROM Opportunity WHERE Name='Test Opp' ];
         System.assert(leadObj.OwnerId !=leadListCheck.get(0).OwnerId);
         System.assert(opp.OwnerId !=oppListCheck.get(0).OwnerId);



    }

}