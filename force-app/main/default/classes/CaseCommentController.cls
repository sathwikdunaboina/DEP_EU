/* 
* -----------------------------------------------------------------------------------------
* Apex Class Name     CaseCommentController
* @author             Swami Goskula<Swami.goskula@consulant.volvo.com>
* @Created Date       04-10-2025 
* @Used By            LWC Component on CaseComments
* ---------------------------------------------------------------------------------------------------------------------------------------------------------
* @description        Used in LWC Component which is used in CaseComment secton on Case Record Page to Let the users to Create a Case comments and publish.
* -----------------------------------------------------------------------------------------------------------------------------------------------------------
*/
public with sharing class CaseCommentController {
    @AuraEnabled(cacheable=true)
    public static List<CaseComment> getCaseComments(Id caseId) {
        
        return [
            SELECT Id, CommentBody, CreatedDate, IsPublished,ParentId
            FROM CaseComment
            WHERE ParentId = :caseId
            ORDER BY CreatedDate DESC
        ];
        
    }
    
    @AuraEnabled
    public static String createPrivateCommentWithEmail(Id caseId, String commentBody, Boolean IsPublished) {
        
        if (caseId == null || String.isBlank(commentBody)) {
            
            return 'Error: Case ID and comment body are required.';
            
        }
        
        
        CaseComment newComment = new CaseComment();
        newComment.ParentId = caseId;
        newComment.CommentBody = commentBody;
        newComment.IsPublished = IsPublished; 
        
        try {  
            insert newComment;
            return 'Success: ' + newComment.Id;
            
        } catch (DmlException e) {
            return 'Error: ' + e.getDmlMessage(0);
            
        } catch (Exception e) {
            return 'Exception: ' + e.getMessage();
        }
    }
    
}