public with sharing class AttachmentsOnCaseController {
    static final Integer BitesInKB = 1024;
    @AuraEnabled(cacheable=true)
    public static List<CaseEmailAttachment> filterAttachments(Id caseId, Integer greaterThanKBs){
        try {
            
            if (String.isBlank(caseId)) return null;
            List<CaseEmailAttachment> filteredAttachments = new List<CaseEmailAttachment>();
            List<Id> docParentIds = new List<Id>();
            //Get list of email messages for the case
            //map.keyset returns readonly collection.
            docParentIds.addAll(new Map<Id, EmailMessage> ([SELECT Id 
                                    FROM EmailMessage
                                    WHERE ParentId = :caseId]).keySet());
            //Make sure any direct attachments to case is also fetched
            docParentIds.add(caseId);
            Integer minimumSizeInBytes = (greaterThanKBs * BitesInKB);
            //Fetching all the contents attached to the Case/EmailMessage
            for (ContentDocumentLink cdl : [
                    SELECT ContentDocumentId, ContentDocument.Title,
                        ContentDocument.ContentSize,
                        ContentDocument.CreatedDate
                    FROM ContentDocumentLink 
                    WHERE LinkedEntityId IN :docParentIds
                        AND ContentDocument.ContentSize >= :minimumSizeInBytes
                    ORDER BY ContentDocument.ContentSize DESC]){

                filteredAttachments.add(
                    new CaseEmailAttachment(
                        cdl.ContentDocument.Title, 
                        Integer.valueOf( Math.ceil(cdl.ContentDocument.ContentSize / BitesInKB)), 
                        cdl.ContentDocumentId,
                        Date.valueOf(cdl.ContentDocument.CreatedDate)
                    )
                );

            }
            //Some orgs may use Attachments (not Files) for email-to-case.
            //Fetching all the Attachments attached to the Case/EmailMessage
            for (Attachment atch : [
                    SELECT Id, ParentId, Name, BodyLength, CreatedDate
                    FROM Attachment 
                    WHERE ParentId IN :docParentIds
                        AND BodyLength >= :minimumSizeInBytes
                    ORDER BY BodyLength DESC]){

                filteredAttachments.add(
                    new CaseEmailAttachment(
                        atch.Name, 
                        Integer.valueOf(Math.ceil(atch.BodyLength / BitesInKB)), 
                        atch.Id,
                        Date.valueOf(atch.CreatedDate),
                        true
                    )
                );               

            }
            return filteredAttachments.isEmpty() ? null : filteredAttachments;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class CaseEmailAttachment{
        @AuraEnabled public String fileName {get;set;}
        @AuraEnabled public Integer sizeInKB {get;set;}
        @AuraEnabled public Id fileRef {get;set;}
        @AuraEnabled public Date createdDate {get; set;}
        @AuraEnabled public Boolean isClassicAttachment {get; set;}

        CaseEmailAttachment(String fileName, Integer sizeInKB, Id fileRef, Date createdDate){
            this.fileName = fileName;
            this.sizeInKB = sizeInKB;
            this.fileRef = fileRef;
            this.createdDate = createdDate;
        }
        CaseEmailAttachment(String fileName, Integer sizeInKB, Id fileRef, Date createdDate, boolean isClassicAttachment){
            this(fileName, sizeInKB, fileRef, createdDate);
            this.isClassicAttachment = isClassicAttachment;
        }
    }
}