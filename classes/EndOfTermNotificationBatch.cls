/*
* Created By: Rupal
* Created Date: 15th Nov, 19
* Uses EndOfTermNotificationSchedular Scheduled Class to call this batch class.
* Creates Cases from Contract whose end date is 90 days from today.
* */
global class EndOfTermNotificationBatch implements Database.Batchable<SObject>{
    public string query {get; set;}
    public Date endDt {get; set;}
    public List<String> typesToExclude {get; set;}
    public List<Case> casesToDelete ; 
    public List<String> countryCodes ; 
    public EndOfTermNotificationBatch(String query, Date endDt, List<String> typesToExclude, List<String> countryCodes){
        this.query = query;
        this.endDt = endDt;
        this.typesToExclude = typesToExclude;
        this.countryCodes = countryCodes;
    }
    global Database.QueryLocator start (Database.BatchableContext getContracts){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext getContracts, List<Contract__c> contractList){
        List<Case> newCaseList = new List<Case>();
        End_of_Term_Notification_Settings__c eot = End_of_Term_Notification_Settings__c.getInstance();
        try{
            //Assigning cases based on current user's country
            Database.DMLOptions dmlOptnsObj = new Database.DMLOptions();
            AssignmentRule assignmentObj = [SELECT Id FROM AssignmentRule WHERE SobjectType = 'Case' AND Active = true LIMIT 1]; 
            dmlOptnsObj.assignmentRuleHeader.assignmentRuleId= assignmentObj.id;
            //check for contract list size
            if(contractList.size() > 0) {
                for(Contract__c cntrct : contractList) {
                    Case cas = new case();
                    cas.AccountId = cntrct.Account__r.Id;
                    cas.Contract__c = cntrct.Id;
                    cas.Country__c = cntrct.Account__r.BillingCountry;
                    cas.Origin = eot.Case_Origin__c;
                    cas.Subject = eot.Case_Subject__c;
                    cas.Description = eot.Case_Description__c;
                    cas.Status = 'New';
                    cas.Sub_Type__c = eot.Notification_Case_Sub_Type__c;
                    cas.Type = eot.Notification_Case_Type__c;
                    cas.setOptions(dmlOptnsObj);
                    //adding cases to the list
                    newCaseList.add(cas);
                    System.debug('newcasesList::'+newCaseList);
                }
            }
            //null check for newcase list
            if(newCaseList != null && !newCaseList.isEmpty()) {
                Database.SaveResult[] srList = Database.insert(newCaseList,false);
                for (Database.SaveResult sr : srList) {     
                    if (sr.isSuccess()) {
                        System.debug('Successfully inserted cases. Case ID: ' + sr.getId());
                    }
                    else {
                        for (Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                   
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Case fields that affected this error: ' + err.getFields());
                        }
                    }
                }
            }
        }
        
        catch (Exception ex) {
            
            throw new AuraHandledException(ex.getMessage()+' '+ex.getCause()+' '+ex.getLineNumber()+' '+ex.getStackTraceString());
        }
    }
    global void finish(Database.BatchableContext getContracts) {
        // method for debuging insert record and success count in logging object 
    }
}