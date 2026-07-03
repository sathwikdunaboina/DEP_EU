/*
* Trigger for setting up brand if the brand sent as null from DBB 
* Brands are setup by the users
* Created Date : 24th June 2026 
* Created By :Infosys
* Test Class - SetupBrandsForDealerAccountTriggerTest - Coverage - 96%
* This trigger is a temprory fix 
* 
* */

trigger SetupBrandsForDealerAccountTrigger on Account (before update) {

    Id dealerRecordTypeId = Schema.SObjectType.Account
        .getRecordTypeInfosByDeveloperName()
        .get('Dealer_Account')
        .getRecordTypeId();

    for (Account acc : Trigger.new) {

        if (acc.RecordTypeId != dealerRecordTypeId) {
            continue;
        }



        // BEFORE UPDATE
        Account oldAcc = Trigger.oldMap.get(acc.Id);

        if (
            String.isBlank(acc.Branding__c) && (acc.Branding__c != oldAcc.Branding__c)) 
        {
             acc.Branding__c=oldAcc.Branding__c;
           
        }

    }
    
    
}