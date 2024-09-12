/**
 * -----------------------------------------------------------------------------
 * @Name    ContentDocumentLinkTriggerHandler
 * @Author  Alok Kumar <alok.kumar.3@consultant.volvo.com>
 * @CreatedDate 27th Aug 2024
 * @UsedBy  ContentDocumentLinkTrigger
 * @SystemLayer Handler
 * -----------------------------------------------------------------------------
 * @Description 
 * This is the Trigger Handler Class for Apex Trigger on ContentDocumentLink object
 **/
public class ContentDocumentLinkTriggerHandler {


    public void onBeforeInsert(List<ContentDocumentLink> listNewContentDocLinks){
        //do nothing
    }

    public void onAfterInsert(Map<Id,ContentDocumentLink> mapNewContentDocLinksById){

        ContentDocumentLinkServices contentDocLinkService = new ContentDocumentLinkServices();
        contentDocLinkService.deleteContentDocumentLinkedToMessagingSession(mapNewContentDocLinksById.values());

    }
}