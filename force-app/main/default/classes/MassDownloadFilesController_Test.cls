/***********************************************************************************************************
* Test class Name: "MassDownloadFilesController_Test"
* Class Name: MassDownloadFilesController - LWC - MassDownloadFiles
* Created Date: 14th September 2023
************************************************************************************************************
*******************************************   Changelog   **************************************************
S.No.    Date                      Developer Name              Azure Item Number
(1)      14th September 2023       Aswin Balaji - Infosys      TASK 
***********************************************************************************************************/
@isTest
public class MassDownloadFilesController_Test {
    static testMethod void queueOwner1() {
        Id UK_IE_Contract_Extensions = [SELECT Id, Name, DeveloperName, Email, Type 
                                        FROM Group where Type='Queue' And Name ='UK/IE-Contract Ext VT'].Id;
        
        Case cs_UK_IE_Contract_Extensions = new Case();
        cs_UK_IE_Contract_Extensions.Status = 'New';
        cs_UK_IE_Contract_Extensions.Origin = 'Email';
        cs_UK_IE_Contract_Extensions.Subject = 'test@1';
        cs_UK_IE_Contract_Extensions.OwnerId = UK_IE_Contract_Extensions;
        cs_UK_IE_Contract_Extensions.Type = 'End of term query';
        insert cs_UK_IE_Contract_Extensions;
        
        test.startTest();
        ContentVersion content=new ContentVersion(); 
        content.Title='Header_Picture1'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlobb=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlobb; 
        content.origin = 'H';
        insert content;
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=cs_UK_IE_Contract_Extensions.id;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
        MassDownloadFilesController.fetchRelatedFiles(cs_UK_IE_Contract_Extensions.id);
        test.stopTest();
    }
}