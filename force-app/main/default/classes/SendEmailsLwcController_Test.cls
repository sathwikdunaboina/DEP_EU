/*
* -----------------------------------------------------------------------------------------
* Apex Class Name     SendEmailsLwcController_Test
* @author             Sourabh Sharma <sourabh.sharma@consultant.volvo.com>
* @Created Date       29 May 2025 
* @SystemLayer        Test
* ------------------------------------------------------------------------------------------
* @description       This class is used for testing SendEmailsLwcController class
* ------------------------------------------------------------------------------------------
*/
@isTest
private class SendEmailsLwcController_Test {


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
        // Create test Contacts
        List<Contact> contactList = new List<Contact>();
        for (Integer i = 0; i < 2; i++) {
            contactList.add(new Contact(
                FirstName = 'TestFirst' + i,
                LastName = 'TestLast' + i,
                Email = 'test' + i + '@example.com'
            ));
        }
        insert contactList;
          User thisUser = [
            SELECT Id 
            FROM User 
            WHERE Id = :UserInfo.getUserId()
        ];
        
        System.runAs ( thisUser ) {

        // Create test Email Template
        EmailTemplate emailTemplate = new EmailTemplate(
            Name = 'TestTemplate',
            DeveloperName = 'Test_Template',
            Subject = 'Test Subject',
            HtmlValue = '<p>Test Body</p>',
            TemplateType = 'custom',
            FolderId = UserInfo.getUserId()
        );
        insert emailTemplate;
       }
    }

   /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testSendEmailsToContacts
* @description     Used to test sendEmailsToContacts method 
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/ 
    @isTest
    static void testSendEmailsToContacts() {
        List<Id> contactIds = new List<Id>();
        for (Contact con : [SELECT Id FROM Contact]) {
            contactIds.add(con.Id);
        }

        Test.startTest();
        // This assumes the OrgWideEmailAddress already exists in the org.
        SendEmailsLwcController.sendEmailsToContacts(contactIds, 'This is a test body', 'Test Subject');
        Test.stopTest();
    }

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testGetEmailTemplateDetails
* @description     Used to test getEmailTemplateDetails method 
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/ 
    @isTest
    static void testGetEmailTemplateDetails() {
        Id templateId = [SELECT Id FROM EmailTemplate LIMIT 1].Id;

        Test.startTest();
        SendEmailsLwcController.EmailTemplateWrapper result = SendEmailsLwcController.getEmailTemplateDetails(templateId);
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assertNotEquals(null, result.sSubject);
        System.assertNotEquals(null, result.sHtmlBody);
    }



}