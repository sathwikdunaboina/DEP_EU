@isTest
public class UpdateOppCloseDateFlowTest {

    @isTest
    static void testOpportunityWithFactoryOrderWithCDD() {
        // Create Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opp with Factory Order and CDD',
            StageName = 'Prospecting',
            CloseDate = System.today()
        );
        insert opp;

        // Create related Factory Order with CDD__c populated
        Factory_Order__c fo = new Factory_Order__c(
            Finance_Opportunity__c = opp.Id,
            Name = 'Factory Order 1',
            CDD_Date__c = System.today()
        );
        insert fo;

        // Simulate update (to trigger the flow)
        opp = [SELECT Id, Name,CloseDate FROM Opportunity WHERE Id = :opp.Id];
        update opp;

        // Verify that Opportunity ClosedDate is updated to CDD__c
        Opportunity updatedOpp = [SELECT Id, CloseDate FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(fo.CDD_Date__c, updatedOpp.CloseDate, 'ClosedDate should match CDD__c from Factory Order');
    }

    @isTest
    static void testOpportunityWithFactoryOrderWithoutCDD() {
        // Create Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opp with Factory Order but no CDD',
            StageName = 'Prospecting',
            CloseDate = System.today().addDays(10)
        );
        insert opp;

        // Create related Factory Order without CDD__c
        Factory_Order__c fo = new Factory_Order__c(
            Finance_Opportunity__c = opp.Id,
            Name = 'Factory Order 2'
            // CDD__c left blank
        );
        insert fo;

        // Simulate update (to trigger the flow)
        opp = [SELECT Id, Name FROM Opportunity WHERE Id = :opp.Id];
        update opp;

        // Verify that Opportunity ClosedDate is updated to today
        Opportunity updatedOpp = [SELECT Id, CloseDate FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(System.today(), updatedOpp.CloseDate, 'ClosedDate should be set to today when CDD__c is blank');
    }

    @isTest
    static void testOpportunityStageClosedWon() {
        // Create Opportunity without Factory Order
        Opportunity opp = new Opportunity(
            Name = 'Test Opp Closed Won',
            StageName = 'Prospecting',
            //CloseDate = System.today().addDays(10)
            CloseDate = System.today()

        );
        insert opp;

        // Update StageName to Closed Won
        opp.StageName = 'Closed Won';
        update opp;

        // Verify that Opportunity ClosedDate is updated to today
        Opportunity updatedOpp = [SELECT Id, CloseDate, StageName FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(System.today(), updatedOpp.CloseDate, 'ClosedDate should be set to today when Stage is Closed Won');
    }

    @isTest
    static void testOpportunityStageClosedLost() {
        // Create Opportunity without Factory Order
        Opportunity opp = new Opportunity(
            Name = 'Test Opp Closed Lost',
            StageName = 'Prospecting',
           // CloseDate = System.today().addDays(10)
            CloseDate = System.today()

        );
        insert opp;

        // Update StageName to Closed Lost
        opp.StageName = 'Closed Lost';
        update opp;

        // Verify that Opportunity ClosedDate is updated to today
        Opportunity updatedOpp = [SELECT Id, CloseDate, StageName FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(System.today(), updatedOpp.CloseDate, 'ClosedDate should be set to today when Stage is Closed Lost');
    }
}