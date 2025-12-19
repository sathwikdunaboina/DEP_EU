/* 
* -----------------------------------------------------------------------------------------
* Apex Class Name     RemoveRecordsBatchClass
* @author             Sugapriya Vanjiyappan <sugapriya.vanjiyappan@consultant.volvo.com>
* @Created Date       25-11-2025 
* ------------------------------------------------------------------------------------------
* @description        This class is to Remove Records From Org as Part of Cleanup which uses query from RemoveRecordsBatchClassConfiguration 
                      custom metadata
* ------------------------------------------------------------------------------------------
*/
public class RemoveRecordsBatchClass implements Database.Batchable<SObject>,Database.Stateful,Database.RaisesPlatformEvents {
    List<RemoveRecordsBatchClassConfiguration__mdt> fetchMetadata;
    Integer index = 0;
    String currentQuery;
    String currentMetadataName;
    Integer ideletedErrorLogCount = 0;
    public RemoveRecordsBatchClass() {
        // No Order__c — fetch all metadata, any order acceptable
        fetchMetadata = [
            SELECT DeveloperName, Dynamic_Query__c
            FROM RemoveRecordsBatchClassConfiguration__mdt
        ];
    }
    
    //Start Method
    public Database.QueryLocator start(Database.BatchableContext bc) {
        // If all metadata records processed → return empty query
        if (index >= fetchMetadata.size()) {
            return Database.getQueryLocator('SELECT Id FROM Error_Log__c WHERE Id = null');
        }
        RemoveRecordsBatchClassConfiguration__mdt md = fetchMetadata[index];
        currentMetadataName = md.DeveloperName;
        currentQuery = md.Dynamic_Query__c;
        return Database.getQueryLocator(currentQuery);
        
    }
    
    //Execute Method
    public void execute(Database.BatchableContext bc, List<SObject> records) {
        if (records.isEmpty()) return;
        delete records;
        ideletedErrorLogCount += records.size();
        
    }
    
    //Finish Method
    public void finish(Database.BatchableContext bc) {
        sendSummaryEmail();
        ideletedErrorLogCount = 0;
        index++; // move to next metadata record
        if (index < fetchMetadata.size()) {
            // chain next batch execution
            Database.executeBatch(this, 2000);
            return;
        }
    }
    
    //Send Email With Deletion Details
    private void sendSummaryEmail() {
        // Get Org-Wide Email Address ID
        OrgWideEmailAddress owe = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'vfs.support.salesforce@volvo.com'];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setOrgWideEmailAddressId(owe.Id);
        mail.setToAddresses(new List<String>{ 'vfs.support.salesforce@volvo.com' });
        mail.setSubject('Records Cleanup Summary');
        mail.setPlainTextBody('Metadata Processed: '+ currentMetadataName  + '.\n' +
                              'Total records deleted:' + ideletedErrorLogCount + '.\n\n'+
                              'Regards,\n' +
                              'VFS Salesforce Support');
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
    }
    
}