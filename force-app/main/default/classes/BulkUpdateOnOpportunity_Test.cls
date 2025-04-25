@isTest
public class BulkUpdateOnOpportunity_Test {
    @testSetup
    static void setupData() {
        Id iProfileId = [SELECT Id FROM Profile WHERE Name = 'CS Operations' LIMIT 1][0].Id;
        String sUniqueUserName = 'TestOppAssigment' + DateTime.now().getTime() + '@testorg.com';
        User oTestUser = new User(Alias = 'tstcs', Email='testOpp@testorg.com',
                                  EmailEncodingKey='UTF-8', LastName='TestOppAsgMent', LanguageLocaleKey='en_US',
                                  LocaleSidKey='en_GB', ProfileId = iProfileId,TimeZoneSidKey='Europe/Paris',
                                  Country = '',UserName=sUniqueUserName);
        insert oTestUser;
        System.runAs(oTestUser){
            
        List<Opportunity> opps = new List<Opportunity>();
        Account testAccount = new Account();
        testAccount.Name = 'Test Account';
        insert testAccount;
        
        for (Integer i = 1; i <= 3; i++) {
            opps.add(new Opportunity(
                Name = 'Test Opportunity ' + i,
                StageName = 'Needs Analysis',
                Customer_Account__c = testAccount.Id,
                Type = 'Finance',
                OwnerId = oTestUser.Id,
                Opportunity_Type__c = 'Parts',
                Amount = 500,
                Lost_Reason__c = 'Too poor speed of execution',
                Reason__c = 'Credit',
                Probability = 35,
                Sub_Stage__c = 'Follow Up'
            ));
        }
        
        insert opps;
    }
    }
    
    @isTest
    static void testMassUpdateOpportunities() {
        // Fetch existing opportunities
        List<Opportunity> existingOpps = [SELECT Id, StageName, Customer_Account__c,Type,Amount,Lost_Reason__c,Reason__c,Probability,Sub_Stage__c,Opportunity_Type__c
                                          FROM Opportunity];
        Account testingAccount = new Account();
        testingAccount.Name = 'Test LCV';
        insert testingAccount;
        
        String uniqueUserName = 'TestOpportunityAssigment' + DateTime.now().getTime() + '@testorg.com';        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User testUser = new User(Alias = 'tstop', Email='testOpportunityassignment@testorg.com',
                                 EmailEncodingKey='UTF-8', LastName='TestOpportunity', LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_GB', ProfileId = p.Id,TimeZoneSidKey='Europe/Paris',
                                 Country = '',UserName=uniqueUserName);
        insert testUser;
        
        List<Id> oppIds = new List<Id>();
        for (Opportunity opp : existingOpps) {
            oppIds.add(opp.Id);
        }
        
        // Prepare update request
        BulkUpdateOnOpportunity.OpportunityUpdateRequest req = new BulkUpdateOnOpportunity.OpportunityUpdateRequest();
        req.opportunityIds = oppIds;
        req.stageName = 'Quoted';
        req.probability = 40;
        req.ownerId = testUser.Id;
        req.customerAccount = testingAccount.Id;
        req.opportunityType = 'Insurance';
        req.netSalesPrice = 1000;
        req.opportunityTypeLCV = 'Parts';
        req.lostReason = 'Not available for financing';
        req.reason = 'Demo unit';
        req.subStageNeedsAnalysis = 'Awaiting Info';
        req.subStageQuoted = 'With Credit';
        
        // Call invocable method
        Test.startTest();
        BulkUpdateOnOpportunity.updateOpportunities(new List<BulkUpdateOnOpportunity.OpportunityUpdateRequest>{ req });
        Test.stopTest();
        
        // Assert updated values
        List<Opportunity> updatedOpps = [SELECT StageName, Probability FROM Opportunity WHERE Id IN :oppIds];
        for (Opportunity updated : updatedOpps) {
            System.assertEquals('Quoted', updated.StageName);
            System.assertEquals(40, updated.Probability);
        }
    }
}