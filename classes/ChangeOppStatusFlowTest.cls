@isTest
public class ChangeOppStatusFlowTest {
    @TestSetup
    static void setup() {
        
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Profile profileObj = [Select Id from Profile where name = 'System Administrator'];
        User owner = new User(
            ProfileId = profileObj.Id,
            UserRoleId = portalRole.Id,
            Username = 'admin@testclass.org' + System.currentTimeMillis(),
            Alias = 'admin',
            Email = 'admin@testclass.org',
            EmailEncodingKey = 'UTF-8',
            Lastname = 'admin',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Chicago',
            Enable_Bell_Notification__c = 'Opportunity Notification;Factory Order Notification'
        );
        insert owner;
        PermissionSet permission= [SELECT Id, Name FROM PermissionSet WHERE Name = 'Custom_notification_permission'];
        system.debug(permission);
        PermissionSetAssignment psa = new PermissionSetAssignment
            (PermissionSetId = permission.Id, AssigneeId = owner.id);
        insert psa;  
        System.runAs(owner) 
        {
            Account act = new Account();
            act.Customer_Number__c = '0635000';
            act.CustomerId__c = 'NL-X035000';
            act.Name = 'Test Account';
            act.BillingCountryCode = 'NL';
            act.CompanyRegistrationNumber__c='2222';
            insert act;
            Factory_Order__c obj=New Factory_Order__c();
            obj.Name='Test@FO2OppNameChange';
            obj.Order_Status_Description__c='Confirmed';
            obj.Order_Id__c='1234';
            obj.End_Customer_Name__c = 'test Opp Name';
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
            opp.OwnerId=owner.Id;
            opp.Factory_Order__c=obj.Id;
            insert opp;
            obj.Finance_Opportunity__c = opp.Id;
            update obj;
        }
    }
    static testMethod void testOppNameChange() {
        Factory_Order__c FO = [Select Id,Name,Order_Status_Description__c From Factory_Order__c Where Name = 'Test@FO2OppNameChange'];
        FO.Order_Status_Description__c = 'Cancelled';
        update FO;
    }
}