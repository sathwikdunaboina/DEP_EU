/***********************************************************************************************************
 * Test Class Name: APTaskTrigger_UpdateAssignedName_Test helper class
 * Test class for: "APTaskTrigger_UpdateAssignedName" Trigger
 * Created Date: 11th Aug 2025
 * Code coverage for intended Artifact on 11th Aug 2025: 100%
************************************************************************************************************
*******************************************   Changelog   **************************************************
S.No.    Date                    Developer Name         Azure Item Number
(1)      11th Aug 2025           Infosys                
***********************************************************************************************************/


public class APTaskTestHelper {
    public static List<APTask__c> createNonSetupData(Id queueId, Id userId) {
        
        //
              
        Group beEotQueue = [
    SELECT Id, Name, DeveloperName, Email
    FROM Group
    WHERE Type = 'Queue'
    AND DeveloperName = 'BE_EOT' // API name of the queue, underscores instead of spaces
    LIMIT 1
];
   
        //
        Account accObj = new Account(
            Name = 'demoAcc',
            CustomerID__c = 'demo123',
            BillingCountry = 'United Kingdom'
        );
        insert accObj;
        
        Contact conObj = new Contact(
            LastName = 'demoContact',
            Email = 'demoContact@test.com',
            AccountId = accObj.Id
        );
        insert conObj;

        
     Entitlement ent = new Entitlement(
    Name = 'Test Entitlement',
    AccountId = accObj.Id,
    StartDate = Date.today(),
    EndDate = Date.today().addYears(1),
    Type = 'Standard' // match valid picklist in your org
);
insert ent;
        Case newCase = new Case(
            Subject = 'Test Case for Account and Contact',
            Description = 'Case created programmatically with linked Contact & Account.',
            Origin = 'Phone',
            Status = 'New',
            Priority = 'Medium',
            EntitlementId = ent.Id,
            Country__c='Netherlands'

        );
        insert newCase;
        //Case c=[Select id, CaseNumber from Case where Subject='Test Case for Account and Contact'];
        ActionPlan__c ap = new ActionPlan__c(
            Name='Test Ap Name',
            Related_Object__c='Case',
            case__c=newCase.Id
        );
        insert ap;

        ActionPlan__c ap2 = new ActionPlan__c(
            Name='Test Ap Name2',
            case__c=newCase.id
            //Related_Record__c='c.CaseNumber

        );
        insert ap2;

        List<APTask__c> tasks = new List<APTask__c>{
            new APTask__c(
                Name = 'Queue Assigned Task',
                Assigned_To_Id__c=beEotQueue.Id,
               // Assigned_To_Id__c = queueId,
                Action_Plan__c = ap.Id,
                Priority__c='High',
                Status__c='In Progress',
                Subject__c='Test Subject'
            ),
            new APTask__c(
                Name = 'User Assigned Task',
                User__c = userId,
                Action_Plan__c = ap2.Id,
                Priority__c='High',
                Status__c='In Progress',
                Subject__c='Test Subject'
            )
        };
        System.debug('Came in helper method');
        insert tasks;
        return tasks;
    }
}