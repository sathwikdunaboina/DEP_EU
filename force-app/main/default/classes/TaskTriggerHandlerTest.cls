/* 
* -----------------------------------------------------------------------------------------
* Apex Class Name     TaskTriggerHandlerTest
* @author             Swami Goskula<Swami.goskula@consulant.volvo.com>
* @Created Date       08-04-2025 
* @Used By            New Task Global action button on Lead and Opportunity
* ------------------------------------------------------------------------------------------
* @description        Used in New Task Global action button on Lead and Opportunity to display Subject Picklist values based on record type
* ------------------------------------------------------------------------------------------------------------------------------------------
*/

@isTest
public class TaskTriggerHandlerTest {
     /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     setUpData
* @description     Used to prepare test setup data
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/          
@testSetup
static void setupData() {
    RecordType financeRT = [SELECT Id FROM RecordType WHERE SObjectType = 'Lead' AND DeveloperName = 'Finance' LIMIT 1];
    RecordType insuranceRT = [SELECT Id FROM RecordType WHERE SObjectType = 'Lead' AND DeveloperName = 'Insurance' LIMIT 1];
    RecordType financeOppRT = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' AND DeveloperName = 'Finance' LIMIT 1];
    RecordType insuranceOppRT = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' AND DeveloperName = 'Insurance_Opportunity' LIMIT 1];

    Lead financeLead = new Lead(
        FirstName = 'Finance',
        LastName = 'Lead',
        Company = 'Test Company',
        RecordTypeId = financeRT.Id
    );
    Lead insuranceLead = new Lead(
        FirstName = 'Insurance',
        LastName = 'Lead',
        Company = 'Test Company',
        RecordTypeId = insuranceRT.Id
    );
    insert new List<Lead>{ financeLead, insuranceLead };
        
        
        insert new List<Opportunity>{
            new Opportunity(Name = 'Finance Opportunity', StageName = 'Prospecting', CloseDate = Date.today().addDays(30), RecordTypeId = financeOppRT.Id),
            new Opportunity(Name = 'Insurance Opportunity', StageName = 'Prospecting', CloseDate = Date.today().addDays(30), RecordTypeId = insuranceOppRT.Id)
        };

}
/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testFinanceLeadSubjectRestrictions
* @description     This method is used to restrict subject picklist values on Lead Finance record type 
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/      
    @isTest
    static void testFinanceLeadSubjectRestrictions() {
        Lead financeLead = [SELECT Id FROM Lead WHERE FirstName = 'Finance' LIMIT 1];

        List<Task> tasks = new List<Task>{
            new Task(Subject = 'Picked Up', WhoId = financeLead.Id),
            new Task(Subject = 'No Answer', WhoId = financeLead.Id),
            new Task(Subject = 'Assistant', WhoId = financeLead.Id),
            new Task(Subject = 'Voice Mail', WhoId = financeLead.Id)
        };

        Test.startTest();
        try {
            insert tasks;
            System.assert(false, 'Expected validation errors for Finance Lead subjects');
        } catch (DmlException e) {
            System.debug('Finance Lead validation errors: ' + e.getMessage());
            System.assert(e.getMessage().contains('Picked Up'), 'Picked Up should be restricted');
        }
        Test.stopTest();
    }
/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testInsuranceLeadSubjectRestrictions
* @description     This method is used to restrict subject picklist values on Lead Insurance record type 
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/      
    @isTest
    static void testInsuranceLeadSubjectRestrictions() {
        Lead insuranceLead = [SELECT Id FROM Lead WHERE FirstName = 'Insurance' LIMIT 1];

        List<Task> tasks = new List<Task>{
            new Task(Subject = 'Send Letter', WhoId = insuranceLead.Id),
            new Task(Subject = 'Send Quote', WhoId = insuranceLead.Id)
        };

        Test.startTest();
        try {
            insert tasks;
            System.assert(false, 'Expected validation errors for Insurance Lead subjects');
        } catch (DmlException e) {
            System.debug('Insurance Lead validation errors: ' + e.getMessage());
            System.assert(e.getMessage().contains('Send Letter'), 'Send Letter should be restricted');
        }
        Test.stopTest();
    }
/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testAllowedSubjectForFinanceLead
* @description     This method is used to allow subject picklist values for Lead Finance record type 
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/   
    @isTest
    static void testAllowedSubjectForFinanceLead() {
        Lead financeLead = [SELECT Id FROM Lead WHERE FirstName = 'Finance' LIMIT 1];

        Task allowedTask = new Task(
            Subject = 'Call',
            WhoId = financeLead.Id
        );

        Test.startTest();
        insert allowedTask;
        Test.stopTest();

        System.assertNotEquals(null, allowedTask.Id, 'Allowed subject should be inserted successfully');
    }
/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testFinanceOpportunitySubjectRestrictions
* @description     This method is used to restrict subject picklist values on Opportunity Finance record type 
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/      
    
    @isTest
    static void testFinanceOpportunitySubjectRestrictions() {
        Opportunity financeOpp = [SELECT Id FROM Opportunity WHERE Recordtype.developername = 'Finance' LIMIT 1];

        List<Task> tasks = new List<Task>{
            new Task(Subject = 'Picked Up', WhatId = financeOpp.Id),
            new Task(Subject = 'No Answer', WhatId = financeOpp.Id),
            new Task(Subject = 'Assistant', WhatId = financeOpp.Id),
            new Task(Subject = 'Voice Mail', WhatId = financeOpp.Id)
        };

        Test.startTest();
        try {
            insert tasks;
            System.assert(false, 'Expected validation errors for Finance Opportunity subjects');
        } catch (DmlException e) {
            System.debug('Finance Opportunity validation errors: ' + e.getMessage());
            System.assert(e.getMessage().contains('Picked Up'), 'Picked Up should be restricted');
        }
        Test.stopTest();
    }

}