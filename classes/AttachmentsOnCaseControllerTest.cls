@IsTest
public with sharing class AttachmentsOnCaseControllerTest {
    @TestSetup
    static void setUpCaseData(){
        // Because this functionality is packaged, no contextUser is used in the tests. 

        //insert an Account
        Account acc = new Account();
        acc.BillingCountryCode = 'IE';
        acc.CustomerId__c = 'FR-UNIQUE_AttachmentsOnCaseControllerTest';
        acc.Name = 'Test French Customer';
        insert acc;
            
        //Create a case
        Case caseWithAttach = new Case (Origin='Email', Subject ='This has attachments', AccountId = acc.Id);
        insert caseWithAttach;

        //insert an emailMessage with attachment
        EmailMessage  emailMsg = new EmailMessage ();
        emailMsg.Subject = 'Email Subject';
        emailMsg.TextBody= 'This Email has an attachment';
        emailMsg.ParentId = caseWithAttach.Id;
        insert emailMsg;

        StaticResource emailAtachBody = [SELECT Body FROM StaticResource WHERE Name = 'SampleEmailMessageBody'];
        ContentVersion cv = new ContentVersion(
            Title='testDoc', 
            PathOnClient ='/testDoc.txt',
            VersionData = emailAtachBody.body, 
            origin = 'H'
        );
        insert cv;
        cv = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = emailMsg.Id;
        contentlink.ContentDocumentId = cv.ContentDocumentId;
        contentlink.ShareType = 'V';
        insert contentlink;


        //insert direct attachment to case using older Attachment obj
        Attachment caseAttachment = new Attachment(Name='CaseAttach', Body = emailAtachBody.body, ParentId = caseWithAttach.Id);
        insert caseAttachment;

        //case without any atachment
        Case caseWithoutAttach = new Case (Origin='Email', Subject ='This has NO attachments', AccountId = acc.Id);
        insert caseWithoutAttach;
    }

    @IsTest
    static void attachmentHappyFlow(){
        Id caseId = [SELECT Id
                    FROM Case
                    WHERE Subject ='This has attachments' Limit 1].Id;

        Test.startTest();
        List<AttachmentsOnCaseController.CaseEmailAttachment> attachs = AttachmentsOnCaseController.filterAttachments(caseId, 0);
        Test.stopTest();
        System.assert(attachs!= null && attachs.size()>0, 'Attachments are not retrieved correctly');
        System.assert(attachs.size() == 2, 'Not all Attachments are retrieved correctly');
    }

    @IsTest
    static void noAttachments(){
        Id caseId = [SELECT Id
                    FROM Case
                    WHERE Subject ='This has NO attachments' Limit 1].Id;

        Test.startTest();
        List<AttachmentsOnCaseController.CaseEmailAttachment> attachs = AttachmentsOnCaseController.filterAttachments(caseId, 0);
        Test.stopTest();
        System.assert(attachs == null || attachs.size() == 0, 'Attachments should be empty');
        
    }

    @IsTest
    static void noAttachmentsGreaterThan1MB(){
        Id caseId = [SELECT Id
                    FROM Case
                    WHERE Subject ='This has attachments' Limit 1].Id;

        Test.startTest();
        List<AttachmentsOnCaseController.CaseEmailAttachment> attachs = AttachmentsOnCaseController.filterAttachments(caseId, 1024);
        Test.stopTest();
        System.assert(attachs == null || attachs.size() == 0, 'Attachments should be empty');
        
    }

}