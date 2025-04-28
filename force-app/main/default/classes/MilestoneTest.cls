/**
* This class contains unit tests for validating the behavior of Apex classes
* and triggers.
*
* Unit tests are class methods that verify whether a particular piece
* of code is working properly. Unit test methods take no arguments,
* commit no data to the database, and are flagged with the testMethod
* keyword in the method definition.
*
* All test methods in an organization are executed whenever Apex code is deployed
* to a production organization to confirm correctness, ensure code
* coverage, and prevent regressions. All Apex classes are
* required to have at least 75% code coverage in order to be deployed
* to a production organization. In addition, all triggers must have some code coverage.
*
* The @isTest class annotation indicates this class only contains test
* methods. Classes defined with the @isTest annotation do not count against
* the organization size limit for all Apex scripts.
*
* See the Apex Language Reference for more information about Testing and Code Coverage.
*/
@isTest
private class MilestoneTest {
    
    Static map<String, String> mapCountryToSlaProcessName = new map<String, String>{'UK' => 'SLA for UK/IE', 
                                                                                    'FR' => 'entitlement for france_v4'};

    static map<String, String> mapCountryToEntitlementName = new map<String, String>{'UK' => 'Case Support Process For UK/IE',
                                                                                     'FR' => 'Case Support Process For France'};

    static testMethod void TestCompleteMilestoneCase(){

        List<Account> acts = new List<Account>();
        Account myAcc = new Account(Name='TestAct', phone='1001231234',BillingCountry='United Kingdom');
        acts.add(myAcc);
        
        Account busAcc = new Account(Name = 'TestForMS', phone='4567890999',BillingCountry='United Kingdom');
        acts.add(busAcc);
        insert acts;
        Contact cont = new Contact(FirstName = 'Test', LastName = 'LastName', phone='4567890999', accountid = busAcc.id);
        insert(cont);
        
        map<string, SlaProcess> mapSLANameToSLAProcess = new map<string, SlaProcess>();
        for (SlaProcess sla: [Select Id, Name From SlaProcess Where Name IN :mapCountryToSlaProcessName.values()]) {
            mapSLANameToSLAProcess.put(sla.Name, sla);
        }
        List<Entitlement> listEntitlement = new List<Entitlement>();
        Entitlement entUK = new Entitlement
        (
            Name = mapCountryToEntitlementName.get('UK'),
            AccountId = acts[0].Id,
            StartDate = Date.today().addDays(-1),
            Type = 'Phone Support',
            SlaProcessId = mapSLANameToSLAProcess.get(mapCountryToSlaProcessName.get('UK')).Id
        );
        listEntitlement.add(entUK);
        Insert listEntitlement;
        Id contactId = cont.Id;
        list<Group> listGroup = new list<Group>();
        Group group_UK_IE_CS_Operations = new Group
        (
            name = 'UK/IE - CS Operations',
            type = 'Queue'
        );
        listGroup.add(group_UK_IE_CS_Operations);
        Insert listGroup;

        Profile profileObj = [Select Id from Profile where name = 'System Administrator'];
        User objUser = new User(alias = 'standt', email='demo@testorg.com',
                            emailencodingkey='UTF-8', firstname='Demo_1', lastname='Demo_l', languagelocalekey='en_US',
                            localesidkey='en_US', profileid = profileObj.Id,CountryCode = 'NL',
                            timezonesidkey='America/Los_Angeles', username='Demo_1_l@testorg.com');

        Insert objUser;

        QueueSobject qs;
        System.runAs(objUser) {
            
            if(!listGroup.isEmpty()) {
                qs = new QueueSobject(QueueId=listGroup[0].Id, SobjectType='Case');
                Insert qs;
            }
        }
        
        List<Case> cases = new List<Case>{};
        if (!listEntitlement.isEmpty()) {
            Case c = new Case(Subject = 'Test Case with Entitlement ', Origin='Email', Status='New', OwnerId=listGroup[0].Id, 
            ContactId = contactId,Country__c='United Kingdom',Type='Change my details');
            cases.add(c);
        }
        if (!cases.isEmpty()) {
            insert cases;
            List<Case> updateCase = new List<Case>([Select Id, Status from Case where Id = :cases[0].Id]);
            List<Case> updateTheCases=new List<Case>();
            List<Id> caseIdss = new List<Id>();
            for(Case c: updateCase)
            { 
                c.Type='Settlement Query';
                c.Status='In Progress';
                c.SlaStartDate=System.now();
            
            }
            update updateCase;

            updateCase[0].Type = 'Settlement Query';
            updateCase[0].Status = 'Closed';
            updateCase[0].Status_Reason__c = 'Auto Closed' ;
            update updateCase;
        }
    }
}