/** This test class has been created for flow test coverage for the following information
 * FlowName- OpportunityInlineAmountUpdate
 * User Required- System Admin
 * Object used - Amount , Opportunity
 * Use case- On creation or updating of opportunity record, once the record has amount field entered, there should be a possibility to directly modify the amount of an opportunity in the list view. As of now, this is not achievable through OOB in salesforce hence using custom field exclusively on list views and creation of bidirectional sync between custom field and standard amount field.
			US#7589**/

@isTest
public class OpportunityInlineAmountUpdateTest {
    
    @isTest
    static void checkAmountonOpportunity() {
        Account dTestAcc = new Account (Name='TestDealerAccount', CustomerID__c='1234', 
                                        BillingCountry='Italy');
        insert dTestAcc;
        List<Opportunity> oppList = new List<Opportunity>();
       
        for(integer i=1;i<12;i++)
        {
            Opportunity opp = new Opportunity();
            opp.Name='Bulk Test Opportunity';
            opp.AccountId= dTestAcc.id;
            opp.StageName='Need Analysis';
            opp.Amount=12345.00;
            oppList.add(opp);
            
        }
        Database.insert(oppList,false);
        
        for(Opportunity opp:oppList ){
            opp.Amount=34567888.00;
        }
        Test.startTest();
        Database.update(oppList,false);
        
        for(Opportunity opp:oppList ){
            opp.NetSalesPrice__c=123347888.00;
        }
        
        Database.update(oppList,false);
        Test.stopTest();

        
        for(Opportunity opp:[Select Id, Amount,NetSalesPrice__c from Opportunity where name='Bulk Test Opportunity'] ){
            Assert.areEqual(opp.Amount, opp.NetSalesPrice__c, 'Both the amount fields hold same value');
            
        }       
        
    }
    
}