/* 
* -----------------------------------------------------------------------------------------
* Apex Class Name     UpdateFieldOnCase_Test
* @author             Sugapriya Vanjiyappan <sugapriya.vanjiyappan@consultant.volvo.com>
* @Created Date       30-09-2024 
* @Used By            Update Case File Status On Email Message Update Flow
* ------------------------------------------------------------------------------------------
* @description        This class is used to test Update Case File Status On Email Message Update Flow.
* ------------------------------------------------------------------------------------------
*/
@IsTest(SeeAllData=false)
public class UpdateFieldOnCase_Test {
    
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
            testCase.Has_Attachment__c = 'No';
            insert testCase;
            
            EmailMessage eMessage = new EmailMessage();
            eMessage.Subject ='Test Email with Attachment';
            eMessage.Has_Attachment__c = 'No';
            eMessage.ParentId = testCase.Id;
            insert eMessage;
            
            //Create a case with Attachment and Email Message without Attachment
            Case testCaseWithAttachment = new Case();
            testCaseWithAttachment.Origin = 'Email';
            testCaseWithAttachment.Subject = 'Test Case without Email Attachment';
            testCaseWithAttachment.Has_Attachment__c = 'Yes';
            insert testCaseWithAttachment;
            
            ContentVersion testcontentversion = new ContentVersion();
            testcontentversion.Title = 'TestFile.txt';
            testcontentversion.PathOnClient = 'TestFile.txt';
            testcontentversion.VersionData = Blob.valueOf('This is a test file');
            insert testcontentversion;
            
            ContentVersion testinsertedContentVersion =[SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id=:testcontentversion.Id];
            Test.startTest();
            ContentDocumentLink testcontentDocumentLink = new ContentDocumentLink();
            testcontentDocumentLink.LinkedEntityId = testCaseWithAttachment.Id;
            testcontentDocumentLink.ContentDocumentId = testinsertedContentVersion.ContentDocumentId;
            testcontentDocumentLink.ShareType = 'V';
            testcontentDocumentLink.Visibility = 'AllUsers';
            insert testcontentDocumentLink;
            
            EmailMessage messageWithoutAttachment = new EmailMessage();
            messageWithoutAttachment.Subject ='Test Email without Attachment';
            messageWithoutAttachment.Has_Attachment__c = 'Yes';
            messageWithoutAttachment.ParentId = testCaseWithAttachment.Id;
            insert messageWithoutAttachment;
            
            //Create a case without Attachment and Email Message without Attachment
            Case testCaseWithoutAttachment = new Case();
            testCaseWithoutAttachment.Origin = 'Email';
            testCaseWithoutAttachment.Subject = 'Test Case Without Any Attachments';
            testCaseWithoutAttachment.Has_Attachment__c = 'No';
            insert testCaseWithoutAttachment;
            
            EmailMessage emailMessageWithoutAttachment = new EmailMessage();
            emailMessageWithoutAttachment.Subject ='Test Email without Any Attachments';
            emailMessageWithoutAttachment.Has_Attachment__c = 'Yes';
            emailMessageWithoutAttachment.ParentId = testCaseWithoutAttachment.Id;
            insert emailMessageWithoutAttachment;
            
        }
    }
    
    /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     insertAttachment
* @description     To cover Update Case File Status On Email Message Update Flow when a Case is created through Email-to-case with Attachment and Case record 
without Attachment
* ------------------------------------------------------------------------------------------------------
*/
    
    @isTest
    static void emailHasAttachment(){
        EmailMessage oemailMessage = [SELECT Id,Subject,Has_Attachment__c FROM EmailMessage WHERE Subject = 'Test Email with Attachment' LIMIT 1];
        Case otestCase = [SELECT id,Has_Attachment__c FROM Case WHERE Subject = 'Test Case With Email Attachment'];
        oemailMessage.Has_Attachment__c = 'Yes';
        Test.startTest();
        update oemailMessage;
        Test.stopTest();
        Case casewithEmailAttachment = [SELECT id,Has_Attachment__c FROM Case WHERE Subject = 'Test Case With Email Attachment'];
        System.assertEquals('Yes',casewithEmailAttachment.Has_Attachment__c);
    }
    
    
    /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     insertAttachment
* @description     To cover Update Case File Status On Email Message Update Flow when a Case is created through Email-to-case without Attachment and Case record 
with Attachment
* ------------------------------------------------------------------------------------------------------
*/
    @isTest
    static void emailWithoutAttachment(){
        Test.startTest();
        EmailMessage oemailMessageWithoutAttachment = [SELECT Id,Subject,Has_Attachment__c FROM EmailMessage WHERE Subject = 'Test Email without Attachment' LIMIT 1];
        Case otestCaseWithAttachment = [SELECT id,Has_Attachment__c FROM Case WHERE Subject = 'Test Case without Email Attachment'];
        oemailMessageWithoutAttachment.Has_Attachment__c = 'No';
        update oemailMessageWithoutAttachment;
        Test.stopTest();
        Case casewithEmailAttachment = [SELECT id,Has_Attachment__c FROM Case WHERE Subject = 'Test Case without Email Attachment'];
        System.assertEquals('Yes',casewithEmailAttachment.Has_Attachment__c);
    }
    
    /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     insertAttachment
* @description     To cover Update Case File Status On Email Message Update Flow when a Case is created through Email-to-case without Attachment and Case record 
without Attachment
* ------------------------------------------------------------------------------------------------------
*/
    
    @isTest
    static void caseAndEmailWithoutAttachment(){
        Test.startTest();
        EmailMessage oemailMessageWithoutAttachment = [SELECT Id,Subject,Has_Attachment__c FROM EmailMessage WHERE Subject = 'Test Email without Any Attachments' LIMIT 1];
        Case otestCaseWithAttachment = [SELECT id,Has_Attachment__c FROM Case WHERE Subject = 'Test Case Without Any Attachments'];
        oemailMessageWithoutAttachment.Has_Attachment__c = 'No';
        update oemailMessageWithoutAttachment;
        Test.stopTest();
        Case casewithEmailAttachment = [SELECT id,Has_Attachment__c FROM Case WHERE Subject = 'Test Case Without Any Attachments'];
        System.assertEquals('No',casewithEmailAttachment.Has_Attachment__c);
    }
    
}