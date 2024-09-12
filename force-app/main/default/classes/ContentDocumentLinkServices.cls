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
    
    @future
    public static void deleteContentDocumentAsync(Set<Id> listContentDocIds){
        List<Id> contentDocIds = new List<Id>(listContentDocIds);
        ContentDocumentServices.deleteContentDocument(contentDocIds);
    }
}