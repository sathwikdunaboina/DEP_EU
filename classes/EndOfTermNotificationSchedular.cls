/*
* Created By: Rupal & Prabha
* Created Date: 15th Nov, 19
* Fetching custom setting value from End_of_Term_Notification_Settings__c
* Pass query to EndOfTermNotificationBatch Batch class to get all contracts whose end date is 90 days from today.
* */
global class EndOfTermNotificationSchedular implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        End_of_Term_Notification_Settings__c eot = End_of_Term_Notification_Settings__c.getInstance();
        String daysAhead_String = eot.Number_of_days_for_case_creation__c;
        System.debug('daysAhead_String ::'+daysAhead_String);
        Integer daysAhead = Integer.valueOf(daysAhead_String);
        //If daysAhead is 90, then calculate the 90 days from now.
        Date endDt = Date.today().addDays(daysAhead);
        List<String> typesToexclude = eot.Contract_Types_to_exclude__c.split(',');
        List<String> countryCodes = eot.Country_Code__c.replaceAll(' ','').split(',');
        String query = 'SELECT Id,Contract__c.Account__r.Id,End_Date__c,Contract__c.Account__r.BillingCountry FROM Contract__c WHERE End_Date__c =:endDt AND Type__c NOT in :typesToexclude AND Account__r.BillingCountryCode in :countryCodes';
        System.debug('query ::'+query);   
        EndOfTermNotificationBatch endterm = new EndOfTermNotificationBatch(query,endDt,typesToexclude, countryCodes);
        //Since the creation of case will call potential future methods (CMSAPI_ContractHandler) we restrict the batch size to 50 to avoid "Too Many future Calls 51 EXp"
        Database.executebatch(endterm,50); 
    }
}