@IsTest
private class ContractNovationAfterInsertHandlerTest {

    private static Account makeAccount(String name) {
        Account a = new Account(Name = name);
        insert a;
        return a;
    }

    // Creates an "old" contract that already exists in DB
    private static Contract__c makeOldContract(Id acctId, String contractId) {
        Contract__c c = new Contract__c();
        c.Name = 'OLD';
        c.Account__c = acctId;
        c.Contract_Id__c = contractId; // formula key derives from this
        c.Down_Payment__c = 111;
        c.Amount_Including_Tax__c = 123;
        c.Start_Date__c = Date.today();
        insert c;
        return c;
    }

    // Creates a "new" contract that should be treated as novation duplicate
    private static Contract__c makeNewContract(Id acctId, String contractId) {
        Contract__c c = new Contract__c();
        c.Name = 'NEW';
        c.Account__c = acctId;
        c.Contract_Id__c = contractId; // formula key derives from this
        c.Down_Payment__c = 9999;
        c.Amount_Including_Tax__c = 999;
        c.Start_Date__c = Date.today().addDays(5);
        return c;
    }

    @IsTest
    static void testNovation_UpdatesOldAndDeletesNew() {
        Account oldAcc = makeAccount('Old Account');
        Account newAcc = makeAccount('New Account');

        // Both of these produce the same formula key "IE-111"
        // Country part: "IE-" (LEFT includes the dash)
        // Last part: "111"
        Contract__c oldC = makeOldContract(oldAcc.Id, 'IE-111-111');
        Contract__c newC = makeNewContract(newAcc.Id, 'IE-222-111');

        Test.startTest();
        insert newC; // should invoke after-insert handler via trigger
        Test.stopTest();

        // Old should be updated with values from NEW
        Contract__c oldAfter = [
            SELECT Id, Name, Account__c, Contract_Id__c, Down_Payment__c, Amount_Including_Tax__c, Start_Date__c
            FROM Contract__c
            WHERE Id = :oldC.Id
        ];

        System.assertEquals(newAcc.Id, oldAfter.Account__c, 'Old contract should now point to new account');
        System.assertEquals('IE-222-111', oldAfter.Contract_Id__c, 'Old contract external id should be replaced with new one');
        System.assertEquals(9999, oldAfter.Down_Payment__c, 'Old contract field should copy from new');
        System.assertEquals(999, oldAfter.Amount_Including_Tax__c, 'Old contract field should copy from new');

        // New should be deleted
        System.assertEquals(
            0,
            [SELECT COUNT() FROM Contract__c WHERE Id = :newC.Id],
            'New duplicate contract should be deleted'
        );
    }

    @IsTest
    static void testGenuineInsert_NoOldMatch_NotDeleted() {
        Account acc = makeAccount('Account');

        // Old has key "IE-111"
        makeOldContract(acc.Id, 'IE-111-111');

        // New has key "IE-222" => no match => should remain inserted
        Contract__c newC = makeNewContract(acc.Id, 'IE-555-222');

        Test.startTest();
        insert newC;
        Test.stopTest();

        System.assertEquals(
            1,
            [SELECT COUNT() FROM Contract__c WHERE Id = :newC.Id],
            'Genuine insert should not be deleted'
        );
    }

}