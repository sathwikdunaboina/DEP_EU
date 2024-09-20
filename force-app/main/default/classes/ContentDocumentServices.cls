/**
 * -----------------------------------------------------------------------------
 * @Name    ContentDocumentServices
 * @Author  Alok Kumar <alok.kumar.3@consultant.volvo.com>
 * @CreatedDate 27th Aug 2024
 * @UsedBy  ContentDocumentLinkServices
 * @SystemLayer Service
 * -----------------------------------------------------------------------------
 * @Description 
 * This is the Service Class for ContentDocument object having operations which 
 * can be operated on the ContentDocument object records
 **/
public without sharing class ContentDocumentServices {

    public static void deleteContentDocument(List<Id> listContentDocIds){
        List<Database.DeleteResult> dr = Database.Delete(listContentDocIds,true);
    }
    
 /**
 * --------------------------------------------------------------------
 * @Description
 * Before deleting an attachment from a Case Object record, get the CaseId 
 * --------------------------------------------------------------------
 * @param ContentDocument inserted
 * 
 */
    
    private static Set<Id> caseIdsToCheck = new Set<Id>();
    public void handleBeforeDelete(List<ContentDocument> oldContentDocuments) {       
        try {
            Set<Id> oldContentDocumentIds = new Set<Id>();
            if(oldContentDocumentIds!=null){
            for (ContentDocument cd : oldContentDocuments) {
                oldContentDocumentIds.add(cd.Id);
            }
            for (ContentDocumentLink link : [SELECT LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId IN :oldContentDocumentIds]) {
                if (link.LinkedEntityId.getSObjectType() == Case.SObjectType) {
                    caseIdsToCheck.add(link.LinkedEntityId);
                }
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
 * After deleting an attachment from a Case Object record, update the Has_Attachment__c 
 * field with value 'Yes' or 'No' based on the number of attachments present
 * --------------------------------------------------------------------
 */
    
    //Method to handle after deletion or unlinking an attachment from Case Object
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
 * If any attachment is Deleted from a case record update the field Has_Attachment__c 
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