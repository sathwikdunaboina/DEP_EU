@isTest
public class ClosedWonUsiingQuoteStatus
{
    static testMethod void quoterecordUpdate() {
        Id AccId = insertTestAccount();
        Id OppId = insertTestOpp(AccId);
        VFS_Connect_Quote__c vfsConnectQuote = new VFS_Connect_Quote__c();
        vfsConnectQuote.Account_CMS_Number__c = '0635000';
        vfsConnectQuote.Quote_Number__c = '910000';
        vfsConnectQuote.Quote_Unique_Id__c = '1qw30635000';
        vfsConnectQuote.Name = '910000';
        vfsConnectQuote.Quote_Status__c = 'In-Complete';
        insert vfsConnectQuote;
        
        List<VFS_Connect_Quote__c> quoteRecord = [SELECT Id,Name FROM VFS_Connect_Quote__c WHERE Id = :vfsConnectQuote.Id];
        quoteRecord[0].Quote_Status__c = 'Contract Activated';
        update quoteRecord;
    }
    
    private static Id insertTestAccount(){
        Account act = new Account();
        act.Customer_Number__c = '0635000';
        act.CustomerId__c = 'NL-X035000';
        act.Name = 'Test Account';
        act.BillingCountryCode = 'NL';
        insert act;
        return act.Id;
    }
    
    private static Id insertTestOpp(Id AccountId){
        Opportunity opp = new Opportunity();
        opp.AccountId = AccountId;
        opp.Amount = 12000;
        opp.CloseDate = System.today() + 3;
        opp.CurrencyIsoCode = 'EUR';
        opp.Name = 'John2';
        opp.StageName = 'New';
        insert opp;
        return opp.Id;
    }
}