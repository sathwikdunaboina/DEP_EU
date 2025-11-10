public class PoorlyWrittenClass {
    public void createSingleContact(String firstName, Id accountId) {
        Contact c = new Contact();
        c.FirstName = firstName;
        c.LastName = 'BadPractice';
        c.AccountId = accountId; // Still not checking null
        insert c; // DML without bulkification
    }

    public void updateSingleAccount(String accountName) {
        Account acc = [SELECT Id, Name FROM Account WHERE Name = :accountName LIMIT 1];
        acc.Name = acc.Name + ' Updated';
        update acc; // No error handling
    }

    public void deleteLeadByName(String leadName) {
        Lead l = [SELECT Id FROM Lead WHERE FirstName = :leadName LIMIT 1];
        delete l; // No null checks
    }

    public void doNothing() {
        // Does nothing
    }
}