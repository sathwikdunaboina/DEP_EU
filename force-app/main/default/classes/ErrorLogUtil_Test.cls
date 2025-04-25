/* 
* -----------------------------------------------------------------------------------------
* Apex Class Name     ErrorLogUtil
* @author             Aswin Balaji<aswin.balaji.m@consultant.volvo.com>
* @Created Date       20-03-2025 
* @Used By            ErrorLogUtil Apex Class
* ------------------------------------------------------------------------------------------
* @description        This class is used to test ErrorLogUtil Apex Class.
* ------------------------------------------------------------------------------------------
*/
@IsTest(SeeAllData=false)
public class ErrorLogUtil_Test {
    public class CustomException extends Exception {}
    
/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     errorLogSync
* @description     To cover createErrorLog and asyncLogErrorForNonCatch methods in ErrorLogUtil Apex Class
* ------------------------------------------------------------------------------------------------------
*/
    static testMethod void errorLogSync(){
        ErrorLogUtil.createErrorLog('TestClassName', 'TestErrorMessage', '500' , 1, 'TestMethodName', 'TestStackTrace', 'TestReqHeader', 'TestActualReq', 'TestAssociatedRec');
        ErrorLogUtil.asyncLogErrorForNonCatch('TestClassName','TestMethodName','TestErrorMessage','TestObject','TestRecordId',1,'TestException');
    }
    
/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     async
* @description     To cover logError and asyncLogError methods in ErrorLogUtil Apex Class which uses Exception as a Parameter
* ------------------------------------------------------------------------------------------------------
*/
    
    static testMethod void async(){
        try {
            throw new CustomException('First exception');
        } 
        catch (CustomException e) { 
            ErrorLogUtil.logError(e,'TestObjectRecord','TestRecordId');
            ErrorLogUtil.asyncLogError(e,'TestObjectRecord','TestRecordId');
        }
    } 
}