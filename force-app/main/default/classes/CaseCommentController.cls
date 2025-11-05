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
            SELECT Id, CommentBody, CreatedDate, IsPublished,ParentId,IsNotificationSelected
            FROM CaseComment
            WHERE ParentId = :caseId
            ORDER BY CreatedDate DESC
        ];
        
    }
    
    @AuraEnabled
    public static String createPrivateCommentWithEmail(Id caseId, String commentBody, Boolean IsPublished, Boolean IsNotificationSelected) {
      
        if (caseId == null || String.isBlank(commentBody)) {
            
            return 'Error: Case ID and comment body are required.';
            
        }
        
        // Create DML options to trigger internal email
        Database.DMLOptions dmlOptions = new Database.DMLOptions();
        dmlOptions.EmailHeader.triggerUserEmail = true; 
        
        CaseComment newComment = new CaseComment();
        newComment.ParentId = caseId;
        newComment.CommentBody = commentBody;
        newComment.IsPublished = IsPublished; 
        newComment.IsNotificationSelected = IsNotificationSelected;
        
        try {
            // Insert the new comment with the specified DML options
            database.SaveResult result = Database.insert(newComment, dmlOptions);
            
            if (result.isSuccess()) {
                return 'Success: ' + result.getId(); 
            }
            else {
                Database.Error error = result.getErrors()[0];
                String statusCode = error.getStatusCode().name(); 
                String message = error.getMessage();
                return 'Error:' + statusCode + ': ' + message;
            }
            
        } catch (Exception e) {
            return 'Exception: ' + e.getMessage();
        }
        
    }
}