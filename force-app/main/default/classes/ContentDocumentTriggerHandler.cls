/**
 * -----------------------------------------------------------------------------
 * @Name             ContentDocumentTriggerHandler
 * @Author           Sugapriya Vanjiyappan <sugapriya.vanjiyappan@consultant.volvo.com>
 * @CreatedDate      18th Sep 2024
 * @UsedBy           ContentDocumentTrigger
 * @SystemLayer Handler
 * -----------------------------------------------------------------------------
 * @Description 
 * This is the Trigger Handler Class for Apex Trigger on ContentDocument object
 **/
public class ContentDocumentTriggerHandler {
    
    public void onBeforeDelete(Map<Id,ContentDocument> mapOldContentDocsById){        
        ContentDocumentServices contentDocService = new ContentDocumentServices();
        contentDocService.setLinkedEntityIdsByEntityNameMap(mapOldContentDocsById);
    }

    public void onAfterDelete(){        
        ContentDocumentServices contentDocService = new ContentDocumentServices();
        contentDocService.updateParentFileStatusOnDelete();
    }    
}