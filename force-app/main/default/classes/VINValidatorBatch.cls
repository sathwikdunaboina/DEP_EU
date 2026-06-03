/* 
* -----------------------------------------------------------------------------------------
* Apex Class Name     VINValidatorBatch
* @author             Sugapriya Vanjiyappan <sugapriya.vanjiyappan@consultant.volvo.com>
* @Created Date       14-05-2026
* ------------------------------------------------------------------------------------------
* @description        This class is to find whether a VIN number in any contracts is Valid or NOT with VINValidator Class
* ------------------------------------------------------------------------------------------
*/
public class VINValidatorBatch implements Database.Batchable<SObject>, Database.Stateful,Database.RaisesPlatformEvents {
    
    // ── Stateful counters (persist across batch chunks) ──────────────────────
    public Integer totalProcessed = 0;
    public Integer totalValid = 0;
    public Integer totalInvalid = 0;
    public Integer totalDmlErrors = 0; // records rejected by the partial update
    
    //Store Failed record details for CSV
    public List<String> failedRecordsCsv = new List<String>();
    
    //Constructor
    public VINValidatorBatch(){
        
        //CSV Header
        failedRecordsCsv.add('RecordId,VIN,ErrorCode,ErrorMessage');
    }
    
    // ── 1. Fetch all Contracts with a VIN ────────────────────────────────────
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, VIN_Number__c, VIN_Format_Valid__c
            FROM Contract__c
            WHERE VIN_Number__c != null
        ]);
    }
    
    // ── 2. Process each chunk ─────────────────────────────────────────────────
    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        
        List<Contract__c> contracts = (List<Contract__c>) scope;
        new ContractVINValidationService().validateVIN(contracts);
        
        for(Contract__c con:contracts){
            if(con.VIN_Format_Valid__c == TRUE){
                totalValid++;
            }
            else{
                totalInvalid++;
            }
        }
        
        // allOrNone = false: one bad record will not roll back the whole chunk
        List<Database.SaveResult> saveResults = Database.update(contracts, false);
        
        
        // FIX: count DML-level errors separately so they are visible in finish()
        for(Integer i=0; i<saveResults.size();i++){
            Database.SaveResult sr= saveResults[i];
            if (!sr.isSuccess()) {
                totalDmlErrors++;
                for (Database.Error e : sr.getErrors()) {
                    String errorMessage = e.getMessage() != null
                        ?e.getMessage().replace('"', '""')
                        :'';
                    
                    String csvRow =
                        '"'+contracts[i].Id + '",'+
                        '"'+contracts[i].VIN_Number__c + '",'+
                        '"'+String.valueOf(e.getStatusCode()) + '",'+
                        '"'+ errorMessage + '"';
                    failedRecordsCsv.add(csvRow);
                }
            }
        }
        
        totalProcessed += contracts.size();
    }
    
    // ── 3. Finish — log summary to debug log ──────────────────────────────────
    public void finish(Database.BatchableContext bc) {
        sendSummaryEmail();
        //Send Email With Deletion Details
    }
    
    private void sendSummaryEmail() {
        // Get Org-Wide Email Address ID
        OrgWideEmailAddress owe = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'vfs.support.salesforce@volvo.com'];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setOrgWideEmailAddressId(owe.Id);
        mail.setToAddresses(new List<String>{ 'vfs.support.salesforce@volvo.com' });
        mail.setSubject('VIN Validation Summary for Contracts');
        mail.setPlainTextBody('TotalRecordsProcessed : '+ totalProcessed  + '\n' +
                              'Valid VINs : ' + totalValid + '\n'+
                              'InValid VINs : ' + totalInvalid + '\n'+
                              'DML Failures : ' + totalDmlErrors + '\n\n'+
                              'Please Refer the Report : Report to Monitor Invalid VINs'+'\n\n'+
                              'Regards,\n' +
                              'VFS Salesforce Support');
        //Attach CSV only if Failure Exist
        if(failedRecordsCsv.size()>1){
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setFileName('VIN_Validation_Errors.csv');
            attachment.setContentType('text/csv');
            attachment.setBody(Blob.valueOf(String.join(failedRecordsCsv, '\n')));
            mail.setFileAttachments(new List<Messaging.EmailFileAttachment>{
                attachment
            });
        }
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
    }
}