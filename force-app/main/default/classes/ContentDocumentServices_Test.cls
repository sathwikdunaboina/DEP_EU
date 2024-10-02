/* 
* -----------------------------------------------------------------------------------------
* Apex Class Name     ContentDocumentServices_Test
* @author             Sugapriya Vanjiyappan <sugapriya.vanjiyappan@consultant.volvo.com>
* @Created Date       18-09-2024 
* @Used By            ContentDocumentTrigger , ContentDocumentServices ,ContentDocumentTriggerHandler
* ------------------------------------------------------------------------------------------
* @description        This class is used to test ContentDocumentServices Class.
* ------------------------------------------------------------------------------------------
*/
@IsTest(SeeAllData=false)
public class ContentDocumentServices_Test {
    @testSetup static void setupmethod(){
        //Create a test Case and add an attachment
        Case testCaseWithAttachment = new Case();
        testCaseWithAttachment.Origin = 'Email';
        testCaseWithAttachment.Subject = 'Test Case With Attachment';
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
        
    }
    
    /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     DeleteAttachmentFromRecord
* @description     To cover AttachmentTriggerHandler when an attachment is Deleted from a Case 
* ------------------------------------------------------------------------------------------------------
*/     
    
    @IsTest
    public static void DeleteAttachmentFromRecord(){
        Case casewithAttachment = [SELECT id,Has_Attachment__c FROM Case WHERE Subject = 'Test Case With Attachment'];
        Integer AttachCount = [SELECT COUNT() FROM ContentDocumentLink WHERE LinkedEntityId =:casewithAttachment.Id];
        ContentVersion insertedContentVersion = [SELECT id,ContentDocumentId,Title FROM ContentVersion WHERE Title='TestFile.txt' ];
        ContentDocument deletedContedDocument = [SELECt Id FROM ContentDocument WHERE Id=:insertedContentVersion.ContentDocumentId];
        Test.startTest();
        delete deletedContedDocument;
        Test.stopTest();
        Case casewithAttachmentAfterUpdate = [SELECT id,Has_Attachment__c FROM Case WHERE Subject = 'Test Case With Attachment'];
        System.assertEquals('No',casewithAttachmentAfterUpdate.Has_Attachment__c);
        
    }
    
}