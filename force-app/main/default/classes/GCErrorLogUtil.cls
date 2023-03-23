/**
 * Writes to the GC ErrorLog object.
 * 
 * @author matei.lunca@fluidogroup.com 2022-07-28 changed objects
 * @author VFS original pre 2022-07
 */
public without sharing class GCErrorLogUtil {
    public static void createErrorLog(string className, string errorMessage, string statusCode, integer lineNumber, string methodName, string stackTrace, string requestHeader, string actualRequest, string associatedRecord){
        ErrorLog__c errorLog = new ErrorLog__c(
			ClassName__c = className,
			ErrorMessage__c = errorMessage,
			HTTPStatusCode__c = statusCode,
			LineNumber__c = lineNumber, 
			MethodName__c = methodName,
			StackTrace__c = stackTrace,
			RequestHeaders__c = requestHeader,
			Request__c = actualRequest,
			AssociatedRecord__c = associatedRecord
        );

		try {
			insert errorLog;	
		} catch (Exception ex) {
			System.debug('Inserting ErrorLog failed: ' + ex);
			System.debug('ErrorLog: ' + errorLog);
		}
        
    }
}