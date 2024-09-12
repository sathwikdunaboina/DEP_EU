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
    
}