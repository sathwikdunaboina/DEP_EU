/***********************************************************************************************************
 * Class Name: MassDownloadFilesController - LWC - MassDownloadFiles
 * Test class Name: "MassDownloadFilesController_Test"
 * Created Date: 14th September 2023
************************************************************************************************************
*******************************************   Changelog   **************************************************
S.No.    Date                      Developer Name              Azure Item Number
(1)      14th September 2023       Aswin Balaji - Infosys      TASK 
***********************************************************************************************************/
public with sharing class MassDownloadFilesController {
    
    @AuraEnabled( cacheable = true )
    public static List < Id > fetchRelatedFiles( Id strRecordId ) {
        List < Id > listFileIds = new List < Id >();
        for (ContentDocumentLink objCDL: [SELECT ContentDocument.LatestPublishedVersionId FROM ContentDocumentLink WHERE LinkedEntityId =: strRecordId]) {
            listFileIds.add( objCDL.ContentDocument.LatestPublishedVersionId );
        }
        return listFileIds;        
    }
}