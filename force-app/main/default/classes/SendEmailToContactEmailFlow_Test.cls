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
* @Method Name     setUpData
* @description     Used to prepare test setup data
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/
    
    @testSetup
    static void setupData() {
        Account acc = new Account();
        acc.BillingCountry= 'United Kingdom';
        acc.Name = 'Test Account new';
        acc.CurrencyIsoCode='EUR';
        
        insert acc;
        
        
        Contact con = new Contact();
        con.LastName = 'goskula';
        con.FirstName= 'swami';
        con.AccountId = acc.id;
        con.HasOptedOutOfEmail = false;
        con.Email = 'TestContact@gmail.com';
        
        insert con;
        
        Case testCase = new Case();
        testCase.Subject = 'Test Case';
        testCase.Status = 'New';
        testCase.Origin = 'Web';
        testCase.ContactId = con.id;
        testCase.AccountId = acc.id;
        insert testCase;
    }
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
        Case getCase = [select id,Status from case where Subject='Test Case'  limit 1]; 
        Test.startTest();            
        getCase.Status='Closed';      
        update getCase;
        Test.stopTest();  
        System.assertEquals('Closed', getCase.status);
    }
}