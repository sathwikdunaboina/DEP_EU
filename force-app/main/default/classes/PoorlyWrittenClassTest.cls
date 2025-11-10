@isTest
private class PoorlyWrittenClassTest {
    static testMethod void testCreateSingleContact() {
        Account acc = new Account(Name = 'Dummy');
        insert acc;

        PoorlyWrittenClass p = new PoorlyWrittenClass();
        Test.startTest();
        p.createSingleContact('TestFirst', acc.Id); // Pass valid AccountId
        Test.stopTest();
    }

    static testMethod void testUpdateSingleAccount() {
        Account acc = new Account(Name = 'UpdateMe');
        insert acc;

        PoorlyWrittenClass p = new PoorlyWrittenClass();
        Test.startTest();
        p.updateSingleAccount('UpdateMe');
        Test.stopTest();
    }

    static testMethod void testDeleteLeadByName() {
        Lead l = new Lead(FirstName = 'DeleteMe', LastName = 'Test', Company = 'TestCo');
        insert l;

        PoorlyWrittenClass p = new PoorlyWrittenClass();
        Test.startTest();
        p.deleteLeadByName('DeleteMe');
        Test.stopTest();
    }
}