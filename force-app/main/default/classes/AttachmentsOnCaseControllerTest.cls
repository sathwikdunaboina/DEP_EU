@IsTest
public with sharing class AttachmentsOnCaseControllerTest {

    @TestSetup
    static void setUpCaseData() {

        Account acc = new Account(
            BillingCountryCode = 'IE',
            CustomerId__c = 'FR-UNIQUE_AttachmentsOnCaseControllerTest',
            Name = 'Test French Customer'
        );
        insert acc;

        Entitlement entitlementRecord = new Entitlement(
            Name = 'Case Support Process For UK/IE',
            AccountId = acc.Id
        );
        insert entitlementRecord;

        Case caseWithAttach = new Case(
            Origin = 'Email',
            Subject = 'This has attachments',
            AccountId = acc.Id
        );
        insert caseWithAttach;

        EmailMessage emailMsg = new EmailMessage(
            Subject = 'Email Subject',
            TextBody = 'This Email has an attachment',
            ParentId = caseWithAttach.Id
        );
        insert emailMsg;

        StaticResource emailAttachBody = [SELECT Body FROM StaticResource WHERE Name = 'SampleEmailMessageBody' LIMIT 1];

        ContentVersion cv = new ContentVersion(
            Title = 'testDoc',
            PathOnClient = '/testDoc.txt',
            VersionData = emailAttachBody.Body,
            Origin = 'H'
        );
        insert cv;

        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];

        ContentDocumentLink contentLink = new ContentDocumentLink(
            LinkedEntityId = emailMsg.Id,
            ContentDocumentId = cv.ContentDocumentId,
            ShareType = 'V'
        );
        insert contentLink;

        Attachment caseAttachment = new Attachment(
            Name = 'CaseAttach.txt',
            Body = emailAttachBody.Body,
            ParentId = caseWithAttach.Id
        );
        insert caseAttachment;

        Case caseWithoutAttach = new Case(
            Origin = 'Email',
            Subject = 'This has NO attachments',
            AccountId = acc.Id
        );
        insert caseWithoutAttach;
    }

    @IsTest
    static void attachmentHappyFlow() {

        Id caseId = [SELECT Id FROM Case WHERE Subject = 'This has attachments' LIMIT 1].Id;

        Test.startTest();
        List<AttachmentsOnCaseController.CaseEmailAttachment> attachs = AttachmentsOnCaseController.filterAttachments(caseId, 0);
        Test.stopTest();

        System.assertNotEquals(null, attachs);
        System.assertEquals(2, attachs.size());

        Boolean foundFile = false;
        Boolean foundClassic = false;

        for (AttachmentsOnCaseController.CaseEmailAttachment item : attachs) {
            System.assertNotEquals(null, item.fileName);
            System.assertNotEquals(null, item.fileRef);
            System.assertNotEquals(null, item.createdDate);
            System.assert(item.sizeInKB >= 0);

            if (item.fileName == 'testDoc') {
                foundFile = true;
                System.assertEquals(null, item.isClassicAttachment);
            }

            if (item.fileName == 'CaseAttach.txt') {
                foundClassic = true;
                System.assertEquals(true, item.isClassicAttachment);
            }
        }

        System.assertEquals(true, foundFile);
        System.assertEquals(true, foundClassic);
    }

    @IsTest
    static void noAttachments() {

        Id caseId = [SELECT Id FROM Case WHERE Subject = 'This has NO attachments' LIMIT 1].Id;

        Test.startTest();
        List<AttachmentsOnCaseController.CaseEmailAttachment> attachs = AttachmentsOnCaseController.filterAttachments(caseId, 0);
        Test.stopTest();

        System.assertEquals(null, attachs);
    }

    @IsTest
    static void noAttachmentsGreaterThan1MB() {

        Id caseId = [SELECT Id FROM Case WHERE Subject = 'This has attachments' LIMIT 1].Id;

        Test.startTest();
        List<AttachmentsOnCaseController.CaseEmailAttachment> attachs = AttachmentsOnCaseController.filterAttachments(caseId, 1024);
        Test.stopTest();

        System.assertEquals(null, attachs);
    }

    @IsTest
    static void filterAttachmentsNullCaseId() {

        Test.startTest();
        List<AttachmentsOnCaseController.CaseEmailAttachment> attachs = AttachmentsOnCaseController.filterAttachments(null, 0);
        Test.stopTest();

        System.assertEquals(null, attachs);
    }

    @IsTest
    static void getAllAttachmentsHappyFlow() {

        Case testCase = [SELECT Id, CaseNumber FROM Case WHERE Subject = 'This has attachments' LIMIT 1];

        Test.startTest();
        List<AttachmentsOnCaseController.CaseAttachmentDetails> results = AttachmentsOnCaseController.getAllAttachments(testCase.Id);
        Test.stopTest();

        System.assertNotEquals(null, results);
        System.assertEquals(2, results.size());

        Boolean foundSalesforceFile = false;
        Boolean foundClassicAttachment = false;

        for (AttachmentsOnCaseController.CaseAttachmentDetails detail : results) {

            System.assertNotEquals(null, detail.fileName);
            System.assertNotEquals(null, detail.fileRef);
            System.assertNotEquals(null, detail.sizeInKB);
            System.assertNotEquals(null, detail.sizeDisplay);
            System.assertEquals(detail.sizeInKB + ' KB', detail.sizeDisplay);
            System.assertNotEquals(null, detail.LastModifiedDate);
            System.assertNotEquals(null, detail.createdById);

            if (detail.fileName == 'testDoc') {
                foundSalesforceFile = true;
                System.assertEquals(false, detail.isClassicAttachment);
                System.assertEquals('Email Subject', detail.sourceCase);
                System.assertEquals('EmailMessage', detail.sourceType);
                System.assertNotEquals(null, detail.sourceId);
                System.assertEquals(false, detail.isAssetEnabled);
                System.assertNotEquals(null, detail.createdDateTime);
            }

            if (detail.fileName == 'CaseAttach.txt') {
                foundClassicAttachment = true;
                System.assertEquals(true, detail.isClassicAttachment);
                System.assertEquals(testCase.CaseNumber, detail.sourceCase);
                System.assertEquals('Case', detail.sourceType);
                System.assertEquals(testCase.Id, detail.sourceId);
                System.assertEquals(false, detail.isAssetEnabled);
                System.assertEquals('txt', detail.fileExtension);
            }
        }

        System.assertEquals(true, foundSalesforceFile);
        System.assertEquals(true, foundClassicAttachment);
    }

    @IsTest
    static void getAllAttachmentsNoAttachments() {

        Id caseId = [SELECT Id FROM Case WHERE Subject = 'This has NO attachments' LIMIT 1].Id;

        Test.startTest();
        List<AttachmentsOnCaseController.CaseAttachmentDetails> results = AttachmentsOnCaseController.getAllAttachments(caseId);
        Test.stopTest();

        System.assertNotEquals(null, results);
        System.assertEquals(0, results.size());
    }

    @IsTest
    static void getAllAttachmentsNullCaseId() {

        Test.startTest();
        List<AttachmentsOnCaseController.CaseAttachmentDetails> results = AttachmentsOnCaseController.getAllAttachments(null);
        Test.stopTest();

        System.assertNotEquals(null, results);
        System.assertEquals(0, results.size());
    }

    @IsTest
    static void testCaseAttachmentDetailsConstructor() {

        User currentUser = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
        Case testCase = [SELECT Id, CaseNumber FROM Case WHERE Subject = 'This has attachments' LIMIT 1];

        Datetime testDate = System.now();

        // UPDATED: Constructor now has all 12 parameters
        AttachmentsOnCaseController.CaseAttachmentDetails detail =
            new AttachmentsOnCaseController.CaseAttachmentDetails(
                'ConstructorTest.txt',
                25,
                testCase.Id,
                'txt',
                testDate,
                currentUser.Id,
                currentUser.Name,
                testCase.CaseNumber,
                testCase.Id,
                'Case',
                false,
                true
            );

        System.assertEquals('ConstructorTest.txt', detail.fileName);
        System.assertEquals('txt', detail.fileExtension);
        System.assertEquals(25, detail.sizeInKB);
        System.assertEquals('25 KB', detail.sizeDisplay);
        System.assertEquals(testCase.Id, detail.fileRef);
        System.assertEquals(testDate, detail.LastModifiedDate);
        System.assertEquals(currentUser.Id, detail.createdById);
        System.assertEquals(currentUser.Name, detail.createdByName);
        System.assertEquals(testCase.CaseNumber, detail.sourceCase);
        System.assertEquals(testCase.Id, detail.sourceId);
        System.assertEquals('Case', detail.sourceType);
        System.assertEquals(false, detail.isClassicAttachment);
        System.assertEquals(true, detail.isAssetEnabled);
    }

    @IsTest
    static void updateSalesforceFileDetailsTest() {

        ContentDocument doc = [SELECT Id, Title, Description FROM ContentDocument WHERE Title = 'testDoc' LIMIT 1];

        Test.startTest();
        AttachmentsOnCaseController.updateFileDetails(
            doc.Id,
            'UpdatedTestDoc',
            'Updated Salesforce File Description',
            false
        );
        Test.stopTest();

        ContentDocument updatedDoc = [SELECT Id, Title, Description FROM ContentDocument WHERE Id = :doc.Id LIMIT 1];

        System.assertEquals('UpdatedTestDoc', updatedDoc.Title);
        System.assertEquals('Updated Salesforce File Description', updatedDoc.Description);
    }

    @IsTest
    static void updateClassicAttachmentDetailsTest() {

        Attachment atch = [SELECT Id, Name, Description FROM Attachment WHERE Name = 'CaseAttach.txt' LIMIT 1];

        Test.startTest();
        AttachmentsOnCaseController.updateFileDetails(
            atch.Id,
            'UpdatedCaseAttach.txt',
            'Updated Classic Attachment Description',
            true
        );
        Test.stopTest();

        Attachment updatedAtch = [SELECT Id, Name, Description FROM Attachment WHERE Id = :atch.Id LIMIT 1];

        System.assertEquals('UpdatedCaseAttach.txt', updatedAtch.Name);
        System.assertEquals('Updated Classic Attachment Description', updatedAtch.Description);
    }

    @IsTest
    static void updateFileDetailsNullIdTest() {

        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            AttachmentsOnCaseController.updateFileDetails(null, 'Test', 'Description', false);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assertEquals(true, exceptionThrown);
    }

    @IsTest
    static void updateFileDetailsBlankTitleTest() {

        ContentDocument doc = [SELECT Id FROM ContentDocument WHERE Title = 'testDoc' LIMIT 1];
        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            AttachmentsOnCaseController.updateFileDetails(doc.Id, '', 'Description', false);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assertEquals(true, exceptionThrown);
    }

    @IsTest
    static void removeFileFromRecordTest() {

        Case testCase = [SELECT Id FROM Case WHERE Subject = 'This has attachments' LIMIT 1];
        EmailMessage emailMsg = [SELECT Id FROM EmailMessage WHERE ParentId = :testCase.Id LIMIT 1];
        ContentDocumentLink link = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :emailMsg.Id LIMIT 1];

        Id documentId = link.ContentDocumentId;

        Test.startTest();
        AttachmentsOnCaseController.removeFileFromRecord(documentId, testCase.Id);
        Test.stopTest();

        Integer linkCount = [SELECT COUNT() FROM ContentDocumentLink WHERE ContentDocumentId = :documentId AND LinkedEntityId = :emailMsg.Id];

        System.assertEquals(0, linkCount);
    }

    @IsTest
    static void removeFileFromRecordNullIdTest() {

        Id caseId = [SELECT Id FROM Case WHERE Subject = 'This has attachments' LIMIT 1].Id;
        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            AttachmentsOnCaseController.removeFileFromRecord(null, caseId);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assertEquals(true, exceptionThrown);
    }
@IsTest
static void removeUnlinkedFileTest() {
    Id caseId = [SELECT Id FROM Case WHERE Subject = 'This has NO attachments' LIMIT 1].Id;
    ContentDocument doc = [SELECT Id FROM ContentDocument WHERE Title = 'testDoc' LIMIT 1];

    Boolean exceptionThrown = false;

    Test.startTest();
    try {
        AttachmentsOnCaseController.removeFileFromRecord(doc.Id, caseId);
    } catch (AuraHandledException e) {
        exceptionThrown = true;
    }
    Test.stopTest();

    System.assertEquals(true, exceptionThrown, 'Exception should be thrown when file is not linked to the Case.');
}
    @IsTest
static void uploadNewFileVersionTest() {
    ContentDocument doc = [SELECT Id, Title FROM ContentDocument WHERE Title = 'testDoc' LIMIT 1];
    Integer versionCountBefore = [SELECT COUNT() FROM ContentVersion WHERE ContentDocumentId = :doc.Id];
    String base64Data = EncodingUtil.base64Encode(Blob.valueOf('This is the updated file content'));

    Test.startTest();
    AttachmentsOnCaseController.uploadNewFileVersion(doc.Id, 'testDoc.txt', base64Data, 'Updated from Apex test');
    Test.stopTest();

    List<ContentVersion> versions = [SELECT Id, ContentDocumentId, Title, PathOnClient, ReasonForChange, VersionNumber, IsLatest FROM ContentVersion WHERE ContentDocumentId = :doc.Id ORDER BY VersionNumber DESC];

    System.assertEquals(versionCountBefore + 1, versions.size());
    System.assertEquals(true, versions[0].IsLatest);
    System.assertEquals('testDoc', versions[0].Title);
    System.assertEquals('testDoc.txt', versions[0].PathOnClient);
    System.assertEquals('Updated from Apex test', versions[0].ReasonForChange);
}

@IsTest
static void uploadNewFileVersionWithDataUrlTest() {
    ContentDocument doc = [SELECT Id FROM ContentDocument WHERE Title = 'testDoc' LIMIT 1];
    String base64Data = EncodingUtil.base64Encode(Blob.valueOf('New version using data URL'));
    String dataUrl = 'data:text/plain;base64,' + base64Data;

    Test.startTest();
    AttachmentsOnCaseController.uploadNewFileVersion(doc.Id, 'testDoc.txt', dataUrl, 'Data URL Test');
    Test.stopTest();

    ContentVersion latestVersion = [SELECT Id, ReasonForChange, IsLatest FROM ContentVersion WHERE ContentDocumentId = :doc.Id AND IsLatest = true LIMIT 1];

    System.assertEquals(true, latestVersion.IsLatest);
    System.assertEquals('Data URL Test', latestVersion.ReasonForChange);
}

@IsTest
static void uploadNewFileVersionWithoutReasonTest() {
    ContentDocument doc = [SELECT Id FROM ContentDocument WHERE Title = 'testDoc' LIMIT 1];
    String base64Data = EncodingUtil.base64Encode(Blob.valueOf('Version without reason'));

    Test.startTest();
    AttachmentsOnCaseController.uploadNewFileVersion(doc.Id, 'testDoc.txt', base64Data, null);
    Test.stopTest();

    ContentVersion latestVersion = [SELECT Id, ReasonForChange, IsLatest FROM ContentVersion WHERE ContentDocumentId = :doc.Id AND IsLatest = true LIMIT 1];

    System.assertEquals(true, latestVersion.IsLatest);
    System.assertEquals(null, latestVersion.ReasonForChange);
}

@IsTest
static void uploadNewFileVersionValidationTest() {
    ContentDocument doc = [SELECT Id FROM ContentDocument WHERE Title = 'testDoc' LIMIT 1];

    Boolean nullDocumentException = false;
    Boolean blankFileNameException = false;
    Boolean blankDataException = false;

    Test.startTest();

    try {
        AttachmentsOnCaseController.uploadNewFileVersion(null, 'test.txt', 'ABC', null);
    } catch (AuraHandledException e) {
        nullDocumentException = true;
    }

    try {
        AttachmentsOnCaseController.uploadNewFileVersion(doc.Id, '', 'ABC', null);
    } catch (AuraHandledException e) {
        blankFileNameException = true;
    }

    try {
        AttachmentsOnCaseController.uploadNewFileVersion(doc.Id, 'test.txt', '', null);
    } catch (AuraHandledException e) {
        blankDataException = true;
    }

    Test.stopTest();

    System.assertEquals(true, nullDocumentException);
    System.assertEquals(true, blankFileNameException);
    System.assertEquals(true, blankDataException);
}
}