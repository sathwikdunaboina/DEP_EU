/* 
* -----------------------------------------------------------------------------------------
* Apex Class Name     CaseCommentController_Test
* @author             Swami Goskula<Swami.goskula@consulant.volvo.com>
* @Created Date       04-10-2025 
* ---------------------------------------------------------------------------------------------------------------------------------------------------------
* @description       This class is used to test CaseCommentController
* -----------------------------------------------------------------------------------------------------------------------------------------------------------
*/
@isTest
public class CaseCommentController_Test {
/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     setUpData
* @description     Used to prepare test setup data
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/

   @testSetup
    static void setupData() {
        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'New',
            Origin = 'Web'
        );
        insert testCase;

        CaseComment comment = new CaseComment(
            ParentId = testCase.Id,
            CommentBody = 'Initial comment',
            IsPublished = false,
            IsNotificationSelected = false
        );
        insert comment;
    }
/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testGetCaseComments
* @description     This method is used to test GetCaseComments from case
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/ 
    @isTest
    static void testGetCaseComments() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];

        List<CaseComment> comments = CaseCommentController.getCaseComments(testCase.Id);

        System.assertNotEquals(0, comments.size(), 'Expected at least one comment');
        System.assertEquals(testCase.Id, comments[0].ParentId, 'ParentId should match the test case');
    }
        /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testCreatePrivateCommentWithEmail_Success
* @description     This method is used to test createPrivateCommentWithEmail
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/ 
    @isTest
    static void testCreatePrivateCommentWithEmail_Success() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];

        String result = CaseCommentController.createPrivateCommentWithEmail(
            testCase.Id,
            'New private comment',
            false,
            true
        );

        System.assert(result.startsWith('Success'), 'Expected success message');
    }
        /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testCreatePrivateCommentWithEmail_Error
* @description     This method is used to test Case Comment body is required when creating a case comment.
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/ 
    @isTest
    static void testCreatePrivateCommentWithEmail_Error() {
        String result = CaseCommentController.createPrivateCommentWithEmail(
            null,
            '',
            false,
            false
        );

        System.assertEquals('Error: Case ID and comment body are required.', result);
    }
        /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testCreatePrivateCommentWithEmail_InsertFailure
* @description     This method is used to cover Error condition 
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/   
@isTest
static void testCreatePrivateCommentWithEmail_InsertFailure() {
   Case testCase1 = new Case(
            Subject = 'Test Case',
            Status = 'New',
            Origin = 'Web'
        );
        insert testCase1;
    
    delete testCase1;

    Id fakeCaseId = testCase1.id;
    String result = CaseCommentController.createPrivateCommentWithEmail(
        fakeCaseId,
        'Valid comment',
        false,
        false
    );

    System.assert(result.startsWith('Error:'), 'Expected error message due to invalid Case ID');
}
 
}