//Copied from US.
public class ErrorLogUtil {

    public static final String DMLEXCEPTIONTYPE = 'DmlException';
    public static void asyncLogError(Exception e,String objectRecordName,String objectRecordId){
        String stackTrace = e.getStackTraceString().substringBefore('\n');
        string errorMessage = e.getMessage();
        decimal errorLineNumber = e.getLineNumber();
        string errorType = e.getTypeName();
        asyncCreateErrorLog(stackTrace,errorMessage,errorLineNumber,objectRecordName,objectRecordId,errorType);
    }
    public static void asyncLogErrorForNonCatch(String className,String MethodName,String ErrorMessage,String objectRecordName,String objectRecordId,Decimal lineNumber,string errorType){
        asyncCreateErrorLog(className+'.'+MethodName,ErrorMessage,lineNumber,objectRecordName,objectRecordId,errorType);
    }
    @future
    private static void asyncCreateErrorLog(string stackTrace,string errorMsg,decimal errorLineNumber,String objectRecordName,String objectRecordId,string errorType){
        String className = stackTrace.substringAfter('.').substringBefore('.');
        String methodName = stackTrace.substringBefore(':').substringAfter(className).substringAfter('.');
        Error_Log__c errorLog = new Error_Log__c(
            Class_Name__c = className,
            Error_Message__c = errorMsg,
            Line_Number__c = errorLineNumber,
            Method_Name__c = methodName,
            Stack_Trace__c = stackTrace,
            Associated_Record__c = objectRecordId + ' - '+objectRecordName,
            Type__c = 'error',
            ExceptionType__c = errorType
        );
        Database.Insert(errorLog,true,AccessLevel.SYSTEM_MODE);
    }

    public static void logError(Exception e,String objectRecordName,String objectRecordId){
       
        String stackTrace = e.getStackTraceString().substringBefore('\n');
        String className = stackTrace.substringAfter('.').substringBefore('.');  
        String methodName = stackTrace.substringBefore(':').substringAfter(className).substringAfter('.');
        
        Error_Log__c errorLog = new Error_Log__c(
         Class_Name__c = className,
         Error_Message__c = e.getMessage(),
         Line_Number__c = e.getLineNumber(), 
         Method_Name__c = methodName,
         Stack_Trace__c = e.getStackTraceString(),
         Associated_Record__c = objectRecordId + ' - '+objectRecordName,
         Type__c = 'error',
         ExceptionType__c = e.getTypeName()
         );
        Database.Insert(errorLog,true,AccessLevel.SYSTEM_MODE);
     }

    public static void createErrorLog(string className, string errorMessage, string statusCode, integer lineNumber, string methodName, string stackTrace, string requestHeader, string actualRequest, string associatedRecord){
        
        LogMessage logMsg = new LogMessage();
        logMsg.className = className;
        logMsg.errorMessage = errorMessage;
        logMsg.statusCode = statusCode;
        logMsg.lineNumber = lineNumber;
        logMsg.methodName = methodName;
        logMsg.stackTrace = stackTrace;
        logMsg.requestHeader = requestHeader;
        logMsg.actualRequest = actualRequest;
        logMsg.associatedRecord = associatedRecord;
        logMsg.logType = 'error';
        logMsg.description = 'Application';

        List<LogMessage> logMsgs = new List<LogMessage>();
        logMsgs.add(logMsg);
        createLogs(logMsgs);
    }

    public static void createLogs(List<LogMessage> logMsgs){
        List<Error_Log__c> logs = new List<Error_Log__c>();
        Map<string,LoggingFramework_Setting__mdt> mapLogFrameworkSettingsBySettingName = LoggingFramework_Setting__mdt.getAll();          
        for(LogMessage msg : logMsgs){
        boolean loggingEnabled = mapLogFrameworkSettingsBySettingName.get(msg.className) != null ? mapLogFrameworkSettingsBySettingName.get(msg.className).EnableLogging__c : true;
         if(loggingEnabled){
           Error_Log__c errorLog = new Error_Log__c
            (
                Class_Name__c = msg.className,
                Error_Message__c = msg.errorMessage,
                HTTP_Status_Code__c = msg.statusCode,
                Line_Number__c = msg.lineNumber, 
                Method_Name__c = msg.methodName,
                Stack_Trace__c = msg.stackTrace,
                Request_Headers__c = msg.requestHeader,
                Request__c = msg.actualRequest,
                Associated_Record__c = msg.associatedRecord,
                Type__c = msg.logType,
                Description__c = msg.description
            );
            logs.add(errorLog);  
          }          
        }
        if(logs.size() > 0){
        Database.Insert(logs,false);
        }
    } 

    public class LogMessage{
        public string className;
        public string errorMessage;
        public string statusCode;
        public integer lineNumber;
        public string methodName;
        public string stackTrace;
        public string requestHeader;
        public string actualRequest;
        public string associatedRecord;
        public string logType;
        public string description;
    }
}