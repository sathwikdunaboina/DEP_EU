public with sharing class FilePublishController {

    @AuraEnabled(cacheable=true)
    public static List<ContentVersion> getFiles(Id recordId) {

        Set<Id> documentIds = new Set<Id>();

        for(ContentDocumentLink cdl : [
            SELECT ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :recordId
        ]){
            documentIds.add(cdl.ContentDocumentId);
        }

        if(documentIds.isEmpty()){
            return new List<ContentVersion>();
        }

        return [
            SELECT Id,
                   Title,
                   FileType,
                   Publish_Attachments__c,
                   ContentDocumentId
            FROM ContentVersion
            WHERE ContentDocumentId IN :documentIds
            AND IsLatest = true
            ORDER BY CreatedDate DESC
        ];
    }

    @AuraEnabled
    public static void updatePublishStatus(
        Id contentVersionId,
        Boolean isPublished
    ) {
        ContentVersion cv = new ContentVersion(
            Id = contentVersionId,
            Publish_Attachments__c = isPublished
        );

        update cv;
    }
}