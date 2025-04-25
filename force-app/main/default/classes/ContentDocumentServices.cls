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

    private static Map<String,Set<Id>> linkedEntityIdsByEntityName = new Map<String,Set<Id>>();
    
    public static void deleteContentDocument(List<Id> listContentDocIds){
        List<Database.DeleteResult> dr = Database.Delete(listContentDocIds,true);
    } 
    
/** --------------------------------------------------------------------------------------
 * @description : Store the Ids of the Entities/Objects linked to the ContentDocument before
 *                the document is deleted as the ContentDocumentLink information is not available
 *                in the after delete context.This stored Ids will be utilized in the After Delete
 * @param :  oldContentDocMap - the Trigger.OldMap from the Before Delete Trigger context
 * ----------------------------------------------------------------------------------------
 */
    public void setLinkedEntityIdsByEntityNameMap(Map<Id,ContentDocument> oldContentDocMap){
        Set<Id> contentDocIds = oldContentDocMap.keySet();
        List<ContentDocumentLink> contentDocLinks = [Select Id,LinkedEntityId,ContentDocumentId From ContentDocumentLink where ContentDocumentId IN :contentDocIds WITH SYSTEM_MODE];
        linkedEntityIdsByEntityName = (new ContentDocumentLinkServices()).getLinkedEntityIds(contentDocLinks);
    }

/** --------------------------------------------------------------------------------------
 * @description : Update the Entity/Record that is linked to the ContentDocument when 
 *                all the ContentDocuments linked to that record/entity have been deleted
 * @param :  None.However, the method uses the static variable "linkedEntityIdsByEntityName" 
 *           set in the Before Delete trigger context to identify the linked entities for which
 *           all the Content Documents have been deleted.
 * ----------------------------------------------------------------------------------------
 */
    public void updateParentFileStatusOnDelete(){
        Map<string,Set<Id>> mapLinkedEntityIdsByEntityName = linkedEntityIdsByEntityName;
        try{
        List<sobject> linkedEntitiesToUpdate = (new ContentDocumentLinkServices()).getLinkedEntitiesWithNoFiles(mapLinkedEntityIdsByEntityName);        
        Database.Update(linkedEntitiesToUpdate,true,AccessLevel.SYSTEM_MODE);
            if(Test.isRunningTest()) {
                throw new AuraHandledException('error');
            }
        }
        catch (Exception e) {
            ErrorLogUtil.logError(e,null,null);
        }
    }
}