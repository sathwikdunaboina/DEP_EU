@IsTest
private class FilePublishControllerTest {

    @TestSetup
    static void setupData() {
        // Create a test Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        // Create a ContentVersion
        ContentVersion cv = new ContentVersion(
            Title = 'Test File',
            PathOnClient = 'TestFile.pdf',
            VersionData = Blob.valueOf('Test Content'),
            Publish_Attachments__c = false
        );
        insert cv;

        // Get ContentDocumentId
        cv = [
            SELECT Id, ContentDocumentId
            FROM ContentVersion
            WHERE Id = :cv.Id
        ];

        // Link file to Account
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = cv.ContentDocumentId,
            LinkedEntityId = acc.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert cdl;
    }

    @IsTest
    static void testGetFiles_WithFiles() {

        Account acc = [
            SELECT Id
            FROM Account
            LIMIT 1
        ];

        Test.startTest();
        List<ContentVersion> files =
            FilePublishController.getFiles(acc.Id);
        Test.stopTest();

        System.assertEquals(1, files.size());
        System.assertEquals('Test File', files[0].Title);
    }

    @IsTest
    static void testGetFiles_NoFiles() {

        Account acc = new Account(Name = 'No File Account');
        insert acc;

        Test.startTest();
        List<ContentVersion> files =
            FilePublishController.getFiles(acc.Id);
        Test.stopTest();

        System.assertEquals(0, files.size());
    }

    @IsTest
    static void testUpdatePublishStatus() {

        ContentVersion cv = [
            SELECT Id,
                   Publish_Attachments__c
            FROM ContentVersion
            LIMIT 1
        ];

        Test.startTest();
        FilePublishController.updatePublishStatus(
            cv.Id,
            true
        );
        Test.stopTest();

        ContentVersion updatedCv = [
            SELECT Id,
                   Publish_Attachments__c
            FROM ContentVersion
            WHERE Id = :cv.Id
        ];

        System.assertEquals(
            true,
            updatedCv.Publish_Attachments__c,
            'Publish status should be updated to true'
        );
    }
}