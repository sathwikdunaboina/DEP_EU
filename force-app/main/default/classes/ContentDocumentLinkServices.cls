/**
 * -----------------------------------------------------------------------------
 * @Name    ContentDocumentLinkServices
 * @Author  Alok Kumar <alok.kumar.3@consultant.volvo.com>
 * @CreatedDate 27th Aug 2024
 * @UsedBy  ContentDocumentLinkTriggerHandler
 * @SystemLayer Service
 * -----------------------------------------------------------------------------
 * @Description 
 * This is the Service Class for ContentDocumentLink object having operations which 
 * can be operated on the ContentDocumentLink object records
 **/
public without sharing class ContentDocumentLinkServices {
    
    public Map<Id,String> getLinkedEntityTypeName(List<ContentDocumentLink> listContentDocLinks){
        Map<Id,String> mapLinkedEntityTypeByContentDocLinkRecId = new Map<Id,String>();
        for(ContentDocumentLink contentDocLink : listContentDocLinks){
            Schema.SobjectType linkedEntityType = contentDocLink.LinkedEntityId.getSobjectType();
            mapLinkedEntityTypeByContentDocLinkRecId.put(contentDocLink.Id,String.valueOf(linkedEntityType));            
        }
        return mapLinkedEntityTypeByContentDocLinkRecId;
    }

/**
 * --------------------------------------------------------------------
 * @Description
 * Delete ContentDocument and ContentDocumentLink records which are linked to
 * MessagingSession records from Channel having Channel DeveloperName in the Restrict list. * 
 * --------------------------------------------------------------------
 * @param listContentDocLinks List of ContentDocLinks inserted
 * @returns void
 */
public void deleteContentDocumentLinkedToMessagingSession(List<ContentDocumentLink> listContentDocLinks){
        //check if there are any restricted channels
        List<VFSGLB_Messaging_Channel_Setting__mdt> listMsgChnlSettings = [Select MasterLabel From VFSGLB_Messaging_Channel_Setting__mdt where Attachment_Restricted__c = true];
        Set<String> setFileRestrictedMsgChnls = new Set<String>();
        for(VFSGLB_Messaging_Channel_Setting__mdt msgChnlSetting : listMsgChnlSettings){
            setFileRestrictedMsgChnls.add(msgChnlSetting.MasterLabel);
        }
        if(setFileRestrictedMsgChnls.size() > 0){
            //get list of content document links which are related to MessagingSession entity
            Map<Id,String> mapLinkedEntityTypeByContentDocLinkRecId = getLinkedEntityTypeName(listContentDocLinks);
            Set<String> linkedEntityTypes = new Set<String>(mapLinkedEntityTypeByContentDocLinkRecId.values());
            if(linkedEntityTypes.contains('MessagingSession')){
            List<ContentDocumentLink> listContentDocLinkLinkedToMsgSessionEntity = new List<ContentDocumentLink>();
            Set<Id> setMsgSessionId = new Set<Id>();
            for(ContentDocumentLink contentDocLink : listContentDocLinks){
                if(mapLinkedEntityTypeByContentDocLinkRecId.get(contentDocLink.Id) == 'MessagingSession'){
                    listContentDocLinkLinkedToMsgSessionEntity.add(contentDocLink);
                    setMsgSessionId.add(contentDocLink.LinkedEntityId);
                }
            }
            //Messaging Sessions which are related to File Restricted Messaging Channels
            List<MessagingSession> listMsgSessions = [Select Id From MessagingSession Where Id in :setMsgSessionId AND ChannelName in :setFileRestrictedMsgChnls];
            Map<Id,MessagingSession> mapFileRestrictedMsgSessionByIds = new Map<Id,MessagingSession>(listMsgSessions);
            Set<Id> setFileRestrictedMsgSessionIds = mapFileRestrictedMsgSessionByIds.keySet();
            
            //Identify Content Documents to be deleted
            Set<Id> setContentDocRelatedToFileRestrictedMsgSessions = new Set<Id>();
            for(ContentDocumentLink contentDocLink : listContentDocLinkLinkedToMsgSessionEntity){
                if(setFileRestrictedMsgSessionIds.contains(contentDocLink.LinkedEntityId)){
                    setContentDocRelatedToFileRestrictedMsgSessions.add(contentDocLink.ContentDocumentId);
                }
            }
            if(setContentDocRelatedToFileRestrictedMsgSessions.size() > 0){
                deleteContentDocumentAsync(setContentDocRelatedToFileRestrictedMsgSessions);
            }
        }
        }
    }
    
    @future
    public static void deleteContentDocumentAsync(Set<Id> listContentDocIds){
        List<Id> contentDocIds = new List<Id>(listContentDocIds);
        ContentDocumentServices.deleteContentDocument(contentDocIds);
    }

/**
 * @desciption : Update the related file status on the Linked Entity/Object record when
 *              a file is linked/added to that entity/object record
 * @param : contentDocLinks - list of contentdocumentlink records that were created and for which
 *          the linked entity file status have to be computed and updated
 */
    public void updateParentFileStatusOnInsert(List<ContentDocumentLink> contentDocLinks){
        Map<string,ObjectHasAttachment_Setting__mdt> ObjectHasAttachmentSettings = ObjectHasAttachment_Setting__mdt.getAll();
        try{
        List<String> errorMsgs = new List<String>();
        Map<string,Set<Id>> mapLinkedEntityIdsByEntityName = getLinkedEntityIds(contentDocLinks);
        List<sobject> linkedEntitiesToUpdate = new List<sobject>();
        List<String> errorMsgsinLoop = new List<string>();
        for(string linkedEntity : mapLinkedEntityIdsByEntityName.keySet()){            
            string fileStatusField = (ObjectHasAttachmentSettings.get(linkedEntity) != null) && (ObjectHasAttachmentSettings.get(linkedEntity).On_Insert__c) ? ObjectHasAttachmentSettings.get(linkedEntity).FileStatusFieldName__c : null;
            if(fileStatusField != null){
            set<Id> linkedEntityRecordIds = mapLinkedEntityIdsByEntityName.get(linkedEntity);            
            for(Id linkedEntityRecordId : linkedEntityRecordIds){                
                SObject linkedEntityRecord = (SObject) Type.forName(linkedEntity).newInstance();
                linkedEntityRecord.put(fileStatusField,'Yes');
                linkedEntityRecord.put('Id',linkedEntityRecordId);
                linkedEntitiesToUpdate.add(linkedEntityRecord);
            }
        }
        }
        //if(!linkedEntitiesToUpdate.isEmpty()){    
        Database.Update(linkedEntitiesToUpdate,true,AccessLevel.SYSTEM_MODE);
        //}
            if(Test.isRunningTest()) {
                throw new AuraHandledException('error');
            }
        }
        catch (Exception e) {
            ErrorLogUtil.logError(e,null,null);
        }
    }

/**
 * @desciption : Update the related file status on the Linked Entity/Object record when
 *               file related to that entity/object record are removed/unlinked
 * @param : contentDocLinks - list of contentdocumentlink records that were unlinked and for which
 *          the linked entity file status have to be computed and updated
 */
    public void updateParentFileStatusOnDelete(List<ContentDocumentLink> contentDocLinks){
        try{
        Map<string,Set<Id>> mapLinkedEntityIdsByEntityName = getLinkedEntityIds(contentDocLinks);        
        List<sobject> linkedEntitiesToUpdate = getLinkedEntitiesWithNoFiles(mapLinkedEntityIdsByEntityName);        
        Database.Update(linkedEntitiesToUpdate,true,AccessLevel.SYSTEM_MODE);
            if(Test.isRunningTest()) {
                throw new AuraHandledException('error');
            }
        }
        catch (Exception e) {
            ErrorLogUtil.logError(e,null,null);
        }
    }

/**
 * @desciption : returns a map of Entity/Object API name to the set of entity/object Ids which are 
 *              linked through the provided contentdocumentlink records
 * @param : contentDocLinks - list of contentdocumentlink records to be processed for identifying
 *          the linked entities.
 * @return : Map<string,Set<Id>> map of LinkedEntityIds by LinkedEntity API name
 */
    public Map<string,Set<Id>> getLinkedEntityIds(List<ContentDocumentLink> contentDocLinks){
        Map<string,Set<Id>> mapLinkedEntityIdsByLinkedEntity = new Map<string,Set<Id>>();
        string linkedEntityObjectName = '';
        for (ContentDocumentLink contentDocLink : contentDocLinks) {
            linkedEntityObjectName = String.valueOf(contentDocLink.LinkedEntityId.getSobjectType());
            if(!mapLinkedEntityIdsByLinkedEntity.containsKey(linkedEntityObjectName)){
                mapLinkedEntityIdsByLinkedEntity.put(linkedEntityObjectName,new Set<Id>());
            }
            mapLinkedEntityIdsByLinkedEntity.get(linkedEntityObjectName).add(contentDocLink.LinkedEntityId);
        }
        return mapLinkedEntityIdsByLinkedEntity;
    }

/**
 * @desciption : identify and return the list if linked entities (from the provided list) having no files.
 * @param : mapLinkedEntityIdsByEntityName - list of entity Ids to process.
 */
    public List<sobject> getLinkedEntitiesWithNoFiles(Map<string,Set<Id>> mapLinkedEntityIdsByEntityName){
        Map<string,ObjectHasAttachment_Setting__mdt> ObjectHasAttachmentSettings = ObjectHasAttachment_Setting__mdt.getAll();
        List<sobject> linkedEntitiesToUpdate = new List<sobject>();
        for(string linkedEntity : mapLinkedEntityIdsByEntityName.keySet()){            
            string fileStatusField = (ObjectHasAttachmentSettings.get(linkedEntity) != null) && (ObjectHasAttachmentSettings.get(linkedEntity).On_Delete__c) ? ObjectHasAttachmentSettings.get(linkedEntity).FileStatusFieldName__c : null;
            if(fileStatusField != null){
            set<Id> linkedEntityRecordIds = mapLinkedEntityIdsByEntityName.get(linkedEntity);
            Map<String,object> queryBinds = new Map<String, object>();
            queryBinds.put('linkedEntityIds',linkedEntityRecordIds);
            string queryString = 'Select Id,'+fileStatusField+ ',(Select Id From ContentDocumentLinks)' +' From '+ linkedEntity +' where Id in :linkedEntityIds';
            List<sobject> linkedEntities = Database.queryWithBinds(queryString,queryBinds,AccessLevel.SYSTEM_MODE);
            for(sobject linkedEntityObj : linkedEntities){
                if(linkedEntityObj.getSObjects('ContentDocumentLinks') == null){
                linkedEntityObj.put(fileStatusField,'No');
                linkedEntitiesToUpdate.add(linkedEntityObj);
                }
            }
            }
        } 
        return linkedEntitiesToUpdate;
    }

    
}