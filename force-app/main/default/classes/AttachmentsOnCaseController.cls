public with sharing class AttachmentsOnCaseController {

    static final Integer BitesInKB = 1024;

    @AuraEnabled(cacheable=true)
    public static List<CaseEmailAttachment> filterAttachments(Id caseId, Integer greaterThanKBs) {
        try {
            if (String.isBlank(caseId)) return null;

            List<CaseEmailAttachment> filteredAttachments = new List<CaseEmailAttachment>();
            List<Id> docParentIds = new List<Id>();

            docParentIds.addAll(new Map<Id, EmailMessage>([SELECT Id FROM EmailMessage WHERE ParentId = :caseId]).keySet());
            docParentIds.add(caseId);

            Integer minimumSizeInBytes = greaterThanKBs * BitesInKB;

            for (ContentDocumentLink cdl : [SELECT ContentDocumentId, ContentDocument.Title, ContentDocument.ContentSize, ContentDocument.CreatedDate FROM ContentDocumentLink WHERE LinkedEntityId IN :docParentIds AND ContentDocument.ContentSize >= :minimumSizeInBytes ORDER BY ContentDocument.ContentSize DESC]) {
                filteredAttachments.add(new CaseEmailAttachment(
                    cdl.ContentDocument.Title,
                    Integer.valueOf(Math.ceil(cdl.ContentDocument.ContentSize / BitesInKB)),
                    cdl.ContentDocumentId,
                    Date.valueOf(cdl.ContentDocument.CreatedDate)
                ));
            }

            for (Attachment atch : [SELECT Id, ParentId, Name, BodyLength, CreatedDate FROM Attachment WHERE ParentId IN :docParentIds AND BodyLength >= :minimumSizeInBytes ORDER BY BodyLength DESC]) {
                filteredAttachments.add(new CaseEmailAttachment(
                    atch.Name,
                    Integer.valueOf(Math.ceil(atch.BodyLength / BitesInKB)),
                    atch.Id,
                    Date.valueOf(atch.CreatedDate),
                    true
                ));
            }

            return filteredAttachments.isEmpty() ? null : filteredAttachments;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class CaseEmailAttachment {
        @AuraEnabled public String fileName {get;set;}
        @AuraEnabled public Integer sizeInKB {get;set;}
        @AuraEnabled public Id fileRef {get;set;}
        @AuraEnabled public Date createdDate {get;set;}
        @AuraEnabled public Boolean isClassicAttachment {get;set;}

        CaseEmailAttachment(String fileName, Integer sizeInKB, Id fileRef, Date createdDate) {
            this.fileName = fileName;
            this.sizeInKB = sizeInKB;
            this.fileRef = fileRef;
            this.createdDate = createdDate;
        }

        CaseEmailAttachment(String fileName, Integer sizeInKB, Id fileRef, Date createdDate, Boolean isClassicAttachment) {
            this(fileName, sizeInKB, fileRef, createdDate);
            this.isClassicAttachment = isClassicAttachment;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<CaseAttachmentDetails> getAllAttachments(Id caseId) {

        List<CaseAttachmentDetails> results = new List<CaseAttachmentDetails>();
        if (caseId == null) return results;

        Case c = [SELECT Id, CaseNumber FROM Case WHERE Id = :caseId LIMIT 1];

        Map<Id, EmailMessage> emailMap = new Map<Id, EmailMessage>([SELECT Id, Subject FROM EmailMessage WHERE ParentId = :caseId]);

        List<Id> docParentIds = new List<Id>();
        docParentIds.addAll(emailMap.keySet());
        docParentIds.add(caseId);

        for (ContentDocumentLink cdl : [SELECT LinkedEntityId, ContentDocumentId, ContentDocument.Title, ContentDocument.FileExtension, ContentDocument.ContentSize, ContentDocument.LastModifiedDate, ContentDocument.Description, ContentDocument.CreatedDate, ContentDocument.CreatedById, ContentDocument.CreatedBy.Name, ContentDocument.LatestPublishedVersion.IsAssetEnabled FROM ContentDocumentLink WHERE LinkedEntityId IN :docParentIds ORDER BY ContentDocument.LastModifiedDate DESC]) {

            Integer sizeInKB = Integer.valueOf(Math.ceil(Decimal.valueOf(cdl.ContentDocument.ContentSize) / BitesInKB));

            String sourceName;
            Id sourceId;
            String sourceType;

            if (cdl.LinkedEntityId == caseId) {
                sourceName = c.CaseNumber;
                sourceId = caseId;
                sourceType = 'Case';
            } else if (emailMap.containsKey(cdl.LinkedEntityId)) {
                EmailMessage emailMsg = emailMap.get(cdl.LinkedEntityId);
                sourceName = String.isBlank(emailMsg.Subject) ? 'Email Message' : emailMsg.Subject;
                sourceId = emailMsg.Id;
                sourceType = 'EmailMessage';
            }

            CaseAttachmentDetails detail = new CaseAttachmentDetails(
                cdl.ContentDocument.Title,
                sizeInKB,
                cdl.ContentDocumentId,
                cdl.ContentDocument.FileExtension,
                cdl.ContentDocument.LastModifiedDate,
                cdl.ContentDocument.CreatedById,
                cdl.ContentDocument.CreatedBy.Name,
                sourceName,
                sourceId,
                sourceType,
                false,
                cdl.ContentDocument.LatestPublishedVersion.IsAssetEnabled
            );

            detail.description = cdl.ContentDocument.Description;
            detail.createdDateTime = cdl.ContentDocument.CreatedDate;
            results.add(detail);
        }

        for (Attachment atch : [SELECT Id, ParentId, Name, BodyLength, LastModifiedDate, CreatedById, CreatedBy.Name FROM Attachment WHERE ParentId IN :docParentIds ORDER BY LastModifiedDate DESC]) {

            Integer sizeInKB = Integer.valueOf(Math.ceil(Decimal.valueOf(atch.BodyLength) / BitesInKB));

            String fileExtension = null;
            if (String.isNotBlank(atch.Name) && atch.Name.contains('.')) {
                fileExtension = atch.Name.substringAfterLast('.');
            }

            String sourceName;
            Id sourceId;
            String sourceType;

            if (atch.ParentId == caseId) {
                sourceName = c.CaseNumber;
                sourceId = caseId;
                sourceType = 'Case';
            } else if (emailMap.containsKey(atch.ParentId)) {
                EmailMessage emailMsg = emailMap.get(atch.ParentId);
                sourceName = String.isBlank(emailMsg.Subject) ? 'Email Message' : emailMsg.Subject;
                sourceId = emailMsg.Id;
                sourceType = 'EmailMessage';
            }

            results.add(new CaseAttachmentDetails(
                atch.Name,
                sizeInKB,
                atch.Id,
                fileExtension,
                atch.LastModifiedDate,
                atch.CreatedById,
                atch.CreatedBy.Name,
                sourceName,
                sourceId,
                sourceType,
                true,
                false
            ));
        }

        return results;
    }

    @AuraEnabled
    public static void updateFileDetails(Id fileId, String newTitle, String description, Boolean isClassicAttachment) {

        if (fileId == null) throw new AuraHandledException('File Id is required.');
        if (String.isBlank(newTitle)) throw new AuraHandledException('Title is required.');

        try {
            if (isClassicAttachment == true) {
                Attachment atch = [SELECT Id, Name, Description FROM Attachment WHERE Id = :fileId LIMIT 1];
                atch.Name = newTitle.trim();
                atch.Description = description;
                update atch;
            } else {
                ContentDocument document = [SELECT Id, Title, Description FROM ContentDocument WHERE Id = :fileId LIMIT 1];
                document.Title = newTitle.trim();
                document.Description = description;
                update document;
            }
        } catch (Exception e) {
            throw new AuraHandledException('Unable to update file details: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void removeFileFromRecord(Id contentDocumentId, Id caseId) {

        if (contentDocumentId == null || caseId == null) {
            throw new AuraHandledException('File Id and Case Id are required.');
        }

        try {
            List<Id> parentIds = new List<Id>();
            parentIds.add(caseId);

            for (EmailMessage emailMsg : [SELECT Id FROM EmailMessage WHERE ParentId = :caseId]) {
                parentIds.add(emailMsg.Id);
            }

            List<ContentDocumentLink> linksToRemove = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId = :contentDocumentId AND LinkedEntityId IN :parentIds];

            if (linksToRemove.isEmpty()) {
                throw new AuraHandledException('This file is not linked to the Case.');
            }

            delete linksToRemove;

        } catch (AuraHandledException e) {
            throw e;
        } catch (Exception e) {
            throw new AuraHandledException('Unable to remove file from record: ' + e.getMessage());
        }
    }

    public class CaseAttachmentDetails {

        @AuraEnabled public String fileName {get;set;}
        @AuraEnabled public String fileExtension {get;set;}
        @AuraEnabled public Integer sizeInKB {get;set;}
        @AuraEnabled public String sizeDisplay {get;set;}
        @AuraEnabled public Id fileRef {get;set;}
        @AuraEnabled public Datetime LastModifiedDate {get;set;}
        @AuraEnabled public String description {get;set;}
        @AuraEnabled public Datetime createdDateTime {get;set;}
        @AuraEnabled public String createdByName {get;set;}
        @AuraEnabled public Id createdById {get;set;}
        @AuraEnabled public Id sourceId {get;set;}
        @AuraEnabled public String sourceType {get;set;}
        @AuraEnabled public String sourceCase {get;set;}
        @AuraEnabled public Boolean isClassicAttachment {get;set;}
        @AuraEnabled public Boolean isAssetEnabled {get;set;}

        public CaseAttachmentDetails(
            String fileName,
            Integer sizeInKB,
            Id fileRef,
            String fileExtension,
            Datetime LastModifiedDate,
            Id createdById,
            String createdByName,
            String sourceCase,
            Id sourceId,
            String sourceType,
            Boolean isClassicAttachment,
            Boolean isAssetEnabled
        ) {
            this.fileName = fileName;
            this.fileExtension = fileExtension;
            this.sizeInKB = sizeInKB;
            this.sizeDisplay = sizeInKB + ' KB';
            this.fileRef = fileRef;
            this.LastModifiedDate = LastModifiedDate;
            this.createdByName = createdByName;
            this.createdById = createdById;
            this.sourceCase = sourceCase;
            this.sourceId = sourceId;
            this.sourceType = sourceType;
            this.isClassicAttachment = isClassicAttachment;
            this.isAssetEnabled = isAssetEnabled;
        }
    }

    @AuraEnabled
    public static void uploadNewFileVersion(Id contentDocumentId, String fileName, String base64Data, String reasonForChange) {

        if (contentDocumentId == null) throw new AuraHandledException('Content Document Id is required.');
        if (String.isBlank(fileName)) throw new AuraHandledException('File name is required.');
        if (String.isBlank(base64Data)) throw new AuraHandledException('File data is required.');

        try {
            String cleanBase64 = base64Data;

            if (cleanBase64.contains(',')) {
                cleanBase64 = cleanBase64.substringAfter(',');
            }

            Blob fileBody = EncodingUtil.base64Decode(cleanBase64);

            ContentDocument existingDocument = [SELECT Id, Title FROM ContentDocument WHERE Id = :contentDocumentId LIMIT 1];

            ContentVersion newVersion = new ContentVersion();
            newVersion.ContentDocumentId = existingDocument.Id;
            newVersion.Title = existingDocument.Title;
            newVersion.PathOnClient = fileName;
            newVersion.VersionData = fileBody;

            if (!String.isBlank(reasonForChange)) {
                newVersion.ReasonForChange = reasonForChange.trim();
            }

            insert newVersion;

        } catch (Exception e) {
            throw new AuraHandledException('Unable to upload new version: ' + e.getMessage());
        }
    }
}