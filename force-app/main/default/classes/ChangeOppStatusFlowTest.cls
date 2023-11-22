@isTest
public class ChangeOppStatusFlowTest
{
    static testMethod void testOppStatusChange() {
        
                 //Test Data Creation 
         
        List<Factory_Order__c> updatedFos=New List<Factory_Order__c>();
        
        Id AccId = insertTestAccount();
        
       id FoId=insertFo();
        Id OppId = insertTestOpp(AccId,FoId);
        List<Factory_Order__c>foList=New List<Factory_Order__c>();
        foList=[Select id,Order_Status_Description__c,Name from Factory_Order__c where Name='Test Factory Order'];
        for (Factory_Order__c fo: foList )
        {
        fo.Order_Status_Description__c='Cancelled';
        updatedFos.add(fo);
        }
        update updatedFos;
        List<Opportunity> oppList =new List<Opportunity>();
           oppList= [SELECT ID, StageName, Lost_Reason__c From Opportunity Where Factory_Order__C =:FoId];
         System.debug('This is opp'+oppList);        

    }
    
    static testMethod void testQuoteChange() {
        test.startTest();
        Profile profileObj = [Select Id from Profile where name = 'System Administrator'];
        User u = new User(alias = 'standt', email='assignLeadsTest_Positive@testorg.com',
                         emailencodingkey='UTF-8', firstname='assignLeadsTest_Positive', lastname='Testing', languagelocalekey='en_US',
                         localesidkey='en_US', profileid = profileObj.Id,CountryCode = 'NL',
                         timezonesidkey='America/Los_Angeles', username='assignLeadsTest_Positive@testorg.com');
        insert u; 
        Account act = new Account();
        act.Customer_Number__c = '0635000';
        act.CustomerId__c = 'NL-X035000';
        act.Name = 'Test Account';
        act.BillingCountryCode = 'NL';
        act.CompanyRegistrationNumber__c='2222';
        insert act;
        Factory_Order__c obj=New Factory_Order__c();
        obj.Name='Test Factory Order';
        obj.Order_Status_Description__c='Confirmed';
        obj.Order_Id__c='1234';
        insert obj;
        VFS_Connect_Quote__c vfsQuote = new VFS_Connect_Quote__c();
        vfsQuote.Name = '12112';
        vfsQuote.Quote_Number__c = '12112';
        vfsQuote.Quote_Status__c = 'test';
        insert vfsQuote;
        Opportunity opp = new Opportunity();
        opp.AccountId = act.Id;
        opp.Amount = 12000;
        opp.CloseDate = System.today() + 3;
        opp.CurrencyIsoCode = 'EUR';
        opp.Name = 'John2';
        opp.VFS_Connect_Quote_Ref__c = vfsQuote.Id;
        opp.StageName = 'New';
        opp.OwnerId=u.Id;
        opp.Factory_Order__c=obj.Id;
        insert opp;
        
        vfsQuote.Quote_Status__c = 'Contract Activated';
        update vfsQuote;
        System.debug('This is opp'+vfsQuote.Quote_Status__c);
        System.debug('This is opp'+opp.StageName); 
        test.stopTest();
    }

    private static Id insertTestAccount(){
        Account act = new Account();
        act.Customer_Number__c = '0635000';
        act.CustomerId__c = 'NL-X035000';
        act.Name = 'Test Account';
        act.BillingCountryCode = 'NL';
        act.CompanyRegistrationNumber__c='2222';
        insert act;
        return act.Id;
    }

    
    
     private static id insertFO(){
       Factory_Order__c obj=New Factory_Order__c();
       obj.Name='Test Factory Order';
       obj.Order_Status_Description__c='Confirmed';
       obj.Order_Id__c='1234';
       insert obj;
       return obj.Id;
         
         
     }
    private static Id insertTestOpp(Id AccountId,Id FoId){
          Profile profileObj = [Select Id from Profile where name = 'System Administrator'];
        User u = new User(alias = 'standt', email='assignLeadsTest_Positive@testorg.com',
                         emailencodingkey='UTF-8', firstname='assignLeadsTest_Positive', lastname='Testing', languagelocalekey='en_US',
                         localesidkey='en_US', profileid = profileObj.Id,CountryCode = 'NL',
                         timezonesidkey='America/Los_Angeles', username='assignLeadsTest_Positive@testorg.com');
        insert u;        
        
        Opportunity opp = new Opportunity();
        opp.AccountId = AccountId;
        opp.Amount = 12000;
        opp.CloseDate = System.today() + 3;
        opp.CurrencyIsoCode = 'EUR';
        opp.Name = 'John2';
        opp.StageName = 'New';
        opp.OwnerId=u.Id;
        opp.Factory_Order__c=FoId;
        insert opp;
        return opp.Id;
    }

}