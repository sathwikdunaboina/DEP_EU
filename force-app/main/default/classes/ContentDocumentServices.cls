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
}