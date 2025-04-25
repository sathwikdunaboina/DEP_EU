/* 
* -----------------------------------------------------------------------------------------
* Apex Class Name     UpdateFieldOnEmailMessage_Test
* @author             Sugapriya Vanjiyappan <sugapriya.vanjiyappan@consultant.volvo.com>
* @Created Date       04-12-2024 
* @Used By            Update Has Attachment Field on Email Message when a case is created through Email-to-Case
* ------------------------------------------------------------------------------------------
* @description        This class is used to test Update Has Attachment Field on Email Message when a case is created.
* ------------------------------------------------------------------------------------------
*/
@IsTest(SeeAllData=false)
public class UpdateFieldOnEmailMessage_Test {
    
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
    static void setupmethod(){
        Id iProfileId = [SELECT Id FROM Profile WHERE Name = 'CS operations' LIMIT 1][0].Id;
        String sUniqueUserName = 'TestCaseAssigment' + DateTime.now().getTime() + '@testorg.com';
        User oTestUser = new User(Alias = 'tstcs', Email='testcaseassignment@testorg.com',
                                  EmailEncodingKey='UTF-8', LastName='TestCaseAsgMent', LanguageLocaleKey='en_US',
                                  LocaleSidKey='en_GB', ProfileId = iProfileId,TimeZoneSidKey='Europe/Paris',
                                  Country = '',UserName=sUniqueUserName);
        insert oTestUser;
        
        System.runAs(oTestUser){
            //Create a case without Attachment and Email Message with Attachment
            Case testCase = new Case();
            testCase.Origin = 'Email';
            testCase.Subject = 'Test Case With Email Attachment';
            insert testCase;
            
            EmailMessage eMessage = new EmailMessage();
            eMessage.Subject ='Test Email with Attachment';
            eMessage.ParentId = testCase.Id;
            insert eMessage;
            
            ContentVersion testcontentversion = new ContentVersion();
            testcontentversion.Title = 'TestFile.txt';
            testcontentversion.PathOnClient = 'TestFile.txt';
            testcontentversion.VersionData = Blob.valueOf('This is a test file');
            insert testcontentversion;
            
            ContentVersion testinsertedContentVersion =[SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id=:testcontentversion.Id];
            Test.startTest();
            ContentDocumentLink testcontentDocumentLink = new ContentDocumentLink();
            testcontentDocumentLink.LinkedEntityId = eMessage.Id;
            testcontentDocumentLink.ContentDocumentId = testinsertedContentVersion.ContentDocumentId;
            testcontentDocumentLink.ShareType = 'V';
            testcontentDocumentLink.Visibility = 'AllUsers';
            insert testcontentDocumentLink;
            
            //Create a case without Attachment and Email Message without Attachment
            Case testCaseWithoutAttachment = new Case();
            testCaseWithoutAttachment.Origin = 'Email';
            testCaseWithoutAttachment.Subject = 'Test Case Without Any Attachments';
            insert testCaseWithoutAttachment;
            
            EmailMessage emailMessageWithoutAttachment = new EmailMessage();
            emailMessageWithoutAttachment.Subject ='Test Email without Any Attachments';
            emailMessageWithoutAttachment.ParentId = testCaseWithoutAttachment.Id;
            insert emailMessageWithoutAttachment;
            
        }
    }
    
    /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     emailHasAttachment
* @description     To cover Update On Email Message when a Case is created through Email-to-case with Attachment
* ------------------------------------------------------------------------------------------------------
*/
    
    @isTest
    static void emailHasAttachment(){
        Test.startTest();
        EmailMessage oemailMessage = [SELECT Id,Subject,Has_Attachment__c FROM EmailMessage WHERE Subject = 'Test Email with Attachment' LIMIT 1];
        // Pause to allow flow to work
        /*Long startTime = DateTime.now().getTime();
        Long finalTime = DateTime.now().getTime();
        Long millisecondsToWait = 120000; // vary this depending on your "sleep" needs
        while (finalTime - startTime < millisecondsToWait) {
            finalTime = DateTime.now().getTime();
        }*/
        Test.stopTest();
        System.assertEquals('Yes',oemailMessage.Has_Attachment__c);
       
    }
    
    /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     emailWithoutAttachment
* @description     To cover Update Case File Status On Email Message Update Flow when a Case is created through Email-to-case without Attachment and Case record 
without Attachment
* ------------------------------------------------------------------------------------------------------
*/
    
    @isTest
    static void emailWithoutAttachment(){
        Test.startTest();
        EmailMessage oemailMessageWithoutAttachment = [SELECT Id,Subject,Has_Attachment__c FROM EmailMessage WHERE Subject = 'Test Email without Any Attachments' LIMIT 1];
        Test.stopTest();
        System.assertEquals('No',oemailMessageWithoutAttachment.Has_Attachment__c);
    }
    
}