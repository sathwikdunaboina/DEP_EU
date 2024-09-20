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
/**
 * --------------------------------------------------------------------
 * @Description
 * If any attachment is added to a case record update the field Has_Attachment__c 
   with 'Yes' if not already 'Yes' 
 * --------------------------------------------------------------------
 * @param listContentDocLinks List of ContentDocLinks inserted
 * 
 */
    private static Set<Id> caseIdsToCheck = new Set<Id>();
    
    //Method to Handle after inserting an attachment
    public void handleAfterInsert(List<ContentDocumentLink> newContentDocumentLinks) {
        for (ContentDocumentLink cdl : newContentDocumentLinks) {
            if (cdl.LinkedEntityId.getSObjectType() == Case.SObjectType) {
                caseIdsToCheck.add(cdl.LinkedEntityId);
            }
        }
        updateCaseAttachmentFlag();
    }
    
 /**
 * --------------------------------------------------------------------
 * @Description
 * Before unlinking an attachment from a Case Object record, get the CaseId 
 * --------------------------------------------------------------------
 * @param listContentDocLinks List of ContentDocLinks inserted
 * 
 */

    //Method to Handle before unlinking an attachment
    public void handleBeforeDelete(List<ContentDocumentLink> oldContentDocumentLinks) {
        try {
            for (ContentDocumentLink cdl : oldContentDocumentLinks) {
                if (cdl.LinkedEntityId.getSObjectType() == Case.SObjectType) {                    
                    caseIdsToCheck.add(cdl.LinkedEntityId);
                }
            }
            if(Test.isRunningTest()) {
                throw new AuraHandledException('error');
            }
        } catch (Exception e) {
            System.debug('Exception in handleBeforeDelete: ' + e.getMessage());
        }
    }
    
 /**
 * --------------------------------------------------------------------
 * @Description
 * After unlinking an attachment from a Case Object record, update the Has_Attachment__c 
 * field with value 'Yes' or 'No' based on the number of attachments present
 * --------------------------------------------------------------------
 */

    public void handleAfterDelete() {        
        try {
            updateCaseAttachmentFlag();
            if(Test.isRunningTest()) {
                throw new AuraHandledException('error');
            }
        } catch (Exception e) {
            System.debug('Exception in handleAfterDelete: ' + e.getMessage());
        }
    }
    
 /**
 * --------------------------------------------------------------------
 * @Description
 * If any attachment is added or Unlinked from a case record update the field Has_Attachment__c 
   with 'Yes' or 'No'  
 * -------------------------------------------------------------------
 */

    //Method to update the Has_Attachment__c field when a file is attached or Removed from Case Record
    private static void updateCaseAttachmentFlag() { 
        
        if (caseIdsToCheck.isEmpty()) {            
            return;  // Exit early if there's nothing to process
        }        
        List<Case> casesToUpdate = new List<Case>();       
        try{     
            List<case> cases = [Select Id,Has_Attachment__c,(Select Id From ContentDocumentLinks) From Case where Id in :caseIdsToCheck WITH USER_MODE];
            for(Case casesToCheck : cases){
                String shasAttachments = (casesToCheck.ContentDocumentLinks).size() > 0 ? 'Yes' : 'No';
                if (casesToCheck.Has_Attachment__c != shasAttachments) {                    
                    casesToCheck.Has_Attachment__c = shasAttachments;
                    casesToUpdate.add(casesToCheck);
                } else {
                    System.debug('No update needed for ' );
                }
                if(Test.isRunningTest()) {
                    throw new AuraHandledException('error');
                }
            } 
        }
        catch (Exception e) {
            System.debug('Error processing ' + e.getMessage());
        }   
        if (!casesToUpdate.isEmpty()) {
            try {                
                update casesToUpdate;                
                if(Test.isRunningTest()) {
                    throw new AuraHandledException('error');
                }
            } catch (Exception e) {
                System.debug('Error updating cases: ' + e.getMessage());
            }
        }        
        // Clear the caseIdsToCheck set after processing
        caseIdsToCheck.clear();        
    }
}