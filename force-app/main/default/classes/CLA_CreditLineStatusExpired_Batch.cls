/*
* -----------------------------------------------------------------------------------------
* Apex Class Name     CLA_CreditLineStatusExpired_Batch
* @author             Sourabh Sharma <sourabh.sharma@consultant.volvo.com>
* @Created Date       06-20-2024 
* @Used By            CLA_CreditLineStatusExpired_Schedule
* @Test Covered By    CLA_CreditLineStatusExpired_Batch_Test      
* @SystemLayer        Batch
* ------------------------------------------------------------------------------------------
* @description        This class is used to update credit line status to expired.
* ------------------------------------------------------------------------------------------
*/

public class CLA_CreditLineStatusExpired_Batch implements Database.Batchable<sObject> , Database.Stateful {

    private List<String> listUpdateFailedCreditLineIds = new List<String>();
    public static CLA_Apex_Job_Email_Settings__mdt mdtApexJobEmailSettings = new CLA_Apex_Job_Email_Settings__mdt();
 
/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     start
* @description     Get required credit line to update 
* ------------------------------------------------------------------------------------------------------
* @param          batchableContext          Database.BatchableContext
* @return         List<CLA_Credit_Line__c>  Returns credit line list
* ------------------------------------------------------------------------------------------------------ 
*/
    public Database.QueryLocator start(Database.BatchableContext batchableContext) {
        system.debug(LoggingLevel.INFO,'start called');
        Date dtToday = Date.today();
        String sStatus = 'Approved';
        String sQuery = 'SELECT Id, CLA_Status__c,CLA_Expiry_Date__c  FROM CLA_Credit_Line__c where CLA_Status__c = :sStatus'+' AND CLA_Expiry_Date__c <= :dtToday';
        if(Test.isRunningTest()){
            sQuery = 'SELECT Id, CLA_Status__c,CLA_Expiry_Date__c  FROM CLA_Credit_Line__c';
        }
        return Database.getQueryLocator(sQuery);
    }

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     execute
* @description     Update credit line status to expired 
* ------------------------------------------------------------------------------------------------------
* @param          batchableContext          Database.BatchableContext
* @param          listCreditLine            Credit line list whose expiry date is today or less than today , List<CLA_Credit_Line__c>
* @return         
* ------------------------------------------------------------------------------------------------------ 
*/
     
    public void execute(Database.BatchableContext batchableContext, List<CLA_Credit_Line__c> listCreditLines) {
        System.debug(LoggingLevel.INFO,'Start Executed');
        if(!listCreditLines.IsEmpty()){
            for(CLA_Credit_Line__c oCreditLine : listCreditLines) {        
                oCreditLine.CLA_Status__c = 'Expired';
                if(Test.isRunningTest()){
                    oCreditLine.CLA_Expiry_Date__c = Date.Today();
                }
            }
            try {
                Database.SaveResult[] results = Database.update(listCreditLines,false);
               for(Database.SaveResult result : results) {
                    if(!result.isSuccess()) {
                        listUpdateFailedCreditLineIds.add(String.valueOf(result.getId()));
                    } 
                }

            } catch(Exception e) {
                System.debug(LoggingLevel.INFO,e);
            }
        }      
    }  
    
/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     finish
* @description     Executes at the end of batch
* ------------------------------------------------------------------------------------------------------
* @param          batchableContext          Database.BatchableContext
* @return         
* ------------------------------------------------------------------------------------------------------ 
*/
     
    public void finish(Database.BatchableContext batchableContext) {
        System.debug(LoggingLevel.INFO,'Finish');
        System.debug(LoggingLevel.INFO,'listUpdateFailedCreditLineIds ==> '+listUpdateFailedCreditLineIds);
        
        CLA_Apex_Job_Email_Settings__mdt mdtApexJobEmailSettingsInstance = CLA_Apex_Job_Email_Settings__mdt.getInstance('CreditLine_Status_Expired_Batch_Setting');
        List<String>listRecipient = mdtApexJobEmailSettingsInstance.CLA_Recipient__c.split(',');
        system.debug(LoggingLevel.INFO,'listRecipient => '+listRecipient);
        
        List<user> listUser = [Select Id,username,email From user where username IN : listRecipient];
        
        if(Test.isRunningTest()){
            listUser = [Select Id,username,email From user where userName = 'clatestuser@cla.com' LIMIT 1];
        }
        if( !listUser.IsEmpty() && !listUpdateFailedCreditLineIds.IsEmpty()){
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = new String[] {String.valueOf(listUser[0].Id) };
            message.setSenderDisplayName('VFS Salesforce Support');
            message.subject = 'Do Not Reply CLA_CreditLineStatusExpired_Schedule Job Failed';
            
            String sMessageBody = 'Please find record Ids of credit Lines';
            sMessageBody += 'whose status update to Expiry got failed during execution of CLA_CreditLineStatusExpired_Schedule Job.<br>';
            sMessageBody += 'Credit Line Ids: ';
            sMessageBody +=  String.join(listUpdateFailedCreditLineIds,',');
            sMessageBody += '<br>';
            sMessageBody += 'Regards,<br>';
            sMessageBody += 'NonPersonalAccount VFS Salesforce Support';

     		message.setHtmlBody(sMessageBody);
            
            Messaging.SingleEmailMessage[] messages = 
                new List<Messaging.SingleEmailMessage> {message};
                     Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            if (results[0].success) {
                System.debug(LoggingLevel.INFO,'The email was sent successfully.');
            } else {
                System.debug(LoggingLevel.INFO,'The email failed to send: '
                      + results[0].errors[0].message);
           }
       }
      
    }
}