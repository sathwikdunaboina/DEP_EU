//Copied from US.
public class ErrorLogUtil {
    public static void createErrorLog(string className, string errorMessage, string statusCode, integer lineNumber, string methodName, string stackTrace, string requestHeader, string actualRequest, string associatedRecord){
        Error_Log__c errorLog = new Error_Log__c
            (
                Class_Name__c = className, Error_Message__c = errorMessage, HTTP_Status_Code__c = statusCode, Line_Number__c = lineNumber, 
                Method_Name__c = methodName, Stack_Trace__c = stackTrace, Request_Headers__c = requestHeader, Request__c = actualRequest, Associated_Record__c = associatedRecord
            );
        INSERT errorLog;
    }
}