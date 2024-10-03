/* 
* -----------------------------------------------------------------------------------------
* Apex Class Name     ContentDocumentLinkServices_Test
* @author             Sourabh Sharma <sourabh.sharma@consultant.volvo.com>
* @Created Date       10-09-2024 
* @Used By            ContentDocumentLinkTrigger , ContentDocumentLinkServices , ContentDocumentServices , ContentDocumentLinkTriggerHandler
* ------------------------------------------------------------------------------------------
* @description        This class is used to test ContentDocumentLinkServices Class.
* ------------------------------------------------------------------------------------------
*/
@IsTest
private class ContentDocumentLinkServices_Test {
 
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
    private static void setUpData(){
        
        
        Id accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer_Account').getRecordTypeId();
        
        Account oAccount = new Account();
        oAccount.Name = 'test account';
        oAccount.RecordTypeId = accountRecordTypeId;
        insert oAccount; 
       
        Contract__c oContract = new Contract__c();
        oContract.Account__c = oAccount.Id;
        oContract.Contract_Id__c = '12345';
        insert oContract; 
        
        ContentVersion oCV = new ContentVersion();
        oCV.Description  = 'test description';
        oCV.PathOnClient ='test_file.txt';
        oCV.Title = 'test file '+DateTime.now();
        oCV.versiondata=Blob.valueOf('test file body');
        insert oCV;
        
        ContentDocumentLink oCdl = new ContentDocumentLink();
        oCdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: oCV.Id].ContentDocumentId;
        oCdl.LinkedEntityId = oContract.Id ; 
        oCdl.ShareType = 'V';
        insert oCdl;
        
        //Creating a test Case without Attachment
        Case testCaseWithoutAttachment = new Case();
        testCaseWithoutAttachment.Origin = 'Email';
        testCaseWithoutAttachment.Subject = 'Test Case Without Attachment';
        testCaseWithoutAttachment.Has_Attachment__c = 'No';
        insert testCaseWithoutAttachment;
        
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
* @Method Name     testContentDocumentLinkServiceClass
* @description     This method test ContentDocumentLinkServices. 
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/ 
    
    @IsTest private static void testContentDocumentLinkServiceClass(){
        
        List<ContentDocument> listContentDocument = [Select Id FROM ContentDocument];
        Set<Id> setContentDocumentIds = new Set<Id>();
        setContentDocumentIds.add(listContentDocument[0].ID);
        
        List<ContentDocumentLink> listContentDocumentLink = [Select Id,ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId =: listContentDocument[0].Id];
        
        Test.startTest();
            ContentDocumentLinkServices contentDocumentLinkService = new ContentDocumentLinkServices(); 
            contentDocumentLinkService.deleteContentDocumentLinkedToMessagingSession(listContentDocumentLink);
            ContentDocumentLinkServices.deleteContentDocumentAsync(setContentDocumentIds);
        Test.stopTest();
     
    }
    
/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     insertAttachment
* @description     To cover AttachmentTriggerHandler when an attachment is added to a Case 
* ------------------------------------------------------------------------------------------------------
*/ 
    @IsTest
    public static void insertAttachment(){
        Case casewithoutAttachment = [SELECT id,Has_Attachment__c FROM Case WHERE Subject = 'Test Case Without Attachment'];
        ContentVersion contentversion = new ContentVersion();
        contentversion.Title = 'TestFile.txt';
        contentversion.PathOnClient = 'TestFile.txt';
        contentversion.VersionData = Blob.valueOf('This is a test file');
        insert contentversion;
        
        ContentVersion insertedContentVersion =[SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id=:contentversion.Id];
        Test.startTest();
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
        contentDocumentLink.LinkedEntityId = casewithoutAttachment.Id;
        contentDocumentLink.ContentDocumentId = insertedContentVersion.ContentDocumentId;
        contentDocumentLink.ShareType = 'V';
        contentDocumentLink.Visibility = 'AllUsers';
        insert contentDocumentLink;
        Test.stopTest();
        Case casewithoutAttachmentAfterUpdate = [SELECT id,Has_Attachment__c FROM Case WHERE Subject = 'Test Case Without Attachment'];
        
        System.assertEquals('Yes',casewithoutAttachmentAfterUpdate.Has_Attachment__c);
    }
    
/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     RemoveAttachmentFromRecord
* @description     To cover AttachmentTriggerHandler when an attachment is unlinked from a Case 
* ------------------------------------------------------------------------------------------------------
*/     
    @IsTest
    public static void RemoveAttachmentFromRecord(){
        Case casewithAttachment = [SELECT id,Has_Attachment__c FROM Case WHERE Subject = 'Test Case With Attachment'];
        Integer AttachCount = [SELECT COUNT() FROM ContentDocumentLink WHERE LinkedEntityId =:casewithAttachment.Id];
        
        ContentDocumentLink removeLink = [SELECT ContentDocumentId,LinkedEntityId FROM 
                                          ContentDocumentLink WHERE LinkedEntityId=:casewithAttachment.Id];
        Test.startTest();
        delete removeLink;
        Test.stopTest();
        
        Case casewithAttachmentAfterUpdate = [SELECT id,Has_Attachment__c FROM Case WHERE Subject = 'Test Case With Attachment'];
        
        System.assertEquals('No',casewithAttachmentAfterUpdate.Has_Attachment__c);
    }
    
}