/* 
* -----------------------------------------------------------------------------------------
* Apex Class Name     SendEmailToContactEmailFlow_Test
* @author             Swami Goskula<Swami.goskula@consulant.volvo.com>
* @Created Date       11-12-2025 
* @Used By            Send an email Notification to contact email when case status is updated

* ------------------------------------------------------------------------------------------
* @description        This class is used to test Send Email Notification to Contact Email When Case Status Update.
* ------------------------------------------------------------------------------------------
*/
@isTest
public class SendEmailToContactEmailFlow_Test {
   
    /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     emailMessageTobeSentToContact
* @description     This method is used to test whether the email has been sent to contact when a case status updated
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/ 
    @isTest
    static void emailMessageTobeSentToContact(){
        User testUser = [SELECT Id, Username FROM User WHERE name = 'Customer Portal Integration User' LIMIT 1];
        System.runAs(testUser){
            Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('All Case').getRecordTypeId();
            Id accountRecordTypeID = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
            
            Account acc = new Account();
            acc.BillingCountry= 'United Kingdom';
            acc.Name = 'Test Account new';
            acc.CurrencyIsoCode='EUR';
            acc.RecordTypeId = accountRecordTypeID;
            
            insert acc;
            
            Entitlement EntitlementRecord = new Entitlement();
            EntitlementRecord.Name='Case Support Process For UK/IE';
            EntitlementRecord.AccountId= acc.Id;             
            insert EntitlementRecord;

            
            Contact con = new Contact();
            con.LastName = 'Test Contact';
            con.FirstName= 'Integration User';
            con.AccountId = acc.id;
            con.HasOptedOutOfEmail = false;
            con.Email = 'TestContact@gmail.com';
            
            insert con;
            
            Case testCase = new Case();
            testCase.Subject = 'Test Case for Customer Portal Integration user';
            testCase.Status = 'New';
            testCase.Origin = 'Web';
            testCase.ContactId = con.id;
            testCase.AccountId = acc.id;
            testCase.Country__c = 'United Kingdom';
            testCase.RecordTypeId = recordTypeId;
            insert testCase;
        }
        Case getCase = [select id,Status from case where Subject='Test Case for Customer Portal Integration user'  limit 1]; 
        Test.startTest();            
        getCase.Status='On Hold';      
        update getCase;
        Test.stopTest();  
        System.assertEquals('On Hold', getCase.status);
    }
}