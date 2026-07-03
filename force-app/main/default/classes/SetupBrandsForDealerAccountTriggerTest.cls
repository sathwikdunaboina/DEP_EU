/*
* Test class for Trigger  SetupBrandsForDealerAccountTrigger
* 
* Created Date : 24th June 2026 
* Created By :Infosys
* This test class is for temprory fix SetupBrandsForDealerAccountTrigger
* 
* */

@IsTest
private class SetupBrandsForDealerAccountTriggerTest {

    private static Id getDealerRecordTypeId() {
        return Schema.SObjectType.Account
            .getRecordTypeInfosByDeveloperName()
            .get('Dealer_Account')
            .getRecordTypeId();
    }


    @IsTest
    static void testBeforeUpdateRestoreBranding() {

        Account acc = new Account(
            Name = 'Dealer Update Test',
            RecordTypeId = getDealerRecordTypeId(),
            Branding__c = 'Renault',
            BillingCountry='United Kingdom'
        );

        insert acc;

        acc.Branding__c = null;

        update acc;

        acc = [
            SELECT Branding__c
            FROM Account
            WHERE Id = :acc.Id
        ];

        System.assertEquals(
            'Renault',
            acc.Branding__c
        );
    }

}