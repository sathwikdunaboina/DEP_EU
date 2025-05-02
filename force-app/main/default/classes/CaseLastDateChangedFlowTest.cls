@isTest
private class CaseLastDateChangedFlowTest {
    
    Static map<String, String> mapCountryToSlaProcessName = new map<String, String>{'UK' => 'SLA for UK/IE', 
                                                                                    'FR' => 'entitlement for france_v4'};

    static map<String, String> mapCountryToEntitlementName = new map<String, String>{'UK' => 'Case Support Process For UK/IE',
                                                                                     'FR' => 'Case Support Process For France'};
    static testMethod void TestLastDateChangedCase(){
        
        List<Account> acts = new List<Account>();
        Account myAcc = new Account(Name='TestAct', phone='1001231234',BillingCountry = 'United Kingdom');
        acts.add(myAcc);
        
        Account busAcc = new Account(Name = 'TestForMS', phone='4567890999',BillingCountry = 'United Kingdom');
        acts.add(busAcc);
        insert acts;
        Contact cont = new Contact(FirstName = 'Test', LastName = 'LastName', phone='4567890999', accountid = busAcc.id);
        insert(cont);
        map<string, SlaProcess> mapSLANameToSLAProcess = new map<string, SlaProcess>();
        for (SlaProcess sla: [Select Id, Name From SlaProcess 
                                                           Where Name IN :mapCountryToSlaProcessName.values()]) {
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
        List<Group> listGroup = new List<Group>();
        Group group_UK_IE_CS_Operations = new Group
        (
            name = 'UK/IE - CS Operations',
            type = 'Queue'
        );
        listGroup.add(group_UK_IE_CS_Operations);
        if(!listGroup.isEmpty())
            Insert listGroup;
        QueueSobject qs;
        
        Profile profileObj = [Select Id from Profile where name = 'System Administrator'];
        User objUser = new User(alias = 'standt', email='demo@testorg.com',
                            emailencodingkey='UTF-8', firstname='Demo_1', lastname='Demo_l', languagelocalekey='en_US',
                            localesidkey='en_US', profileid = profileObj.Id,CountryCode = 'GB',
                            timezonesidkey='America/Los_Angeles', username='Demo_1_l@testorg.com');
        
        Profile profileObj2 = [Select Id from Profile where name = 'CS Operations'];
        User objUser2 = new User(alias = 'standt2', email='demo2@testorg.com',
                            emailencodingkey='UTF-8', firstname='Demo_2', lastname='Demo_2', languagelocalekey='en_US',
                            localesidkey='en_US', profileid = profileObj2.Id,CountryCode = 'GB', CurrencyISOCode='EUR',
                            timezonesidkey='America/Los_Angeles', username='Demo_2_l@testorg.com');

        Insert objUser2;

        Insert objUser;
        System.runAs(objUser) {
            qs = new QueueSobject(QueueId=listGroup[0].Id, SobjectType='Case');
                    Insert qs;
        }
        List<Case> cases = new List<Case>();
        Database.DMLOptions dmo = new Database.DMLOptions();
		dmo.assignmentRuleHeader.useDefaultRule= false;
        system.runAs(objUser2) {
            
            Case c = new Case(Subject = 'Test Case with Entitlement',Status = 'On Hold',SuppliedEmail='volvo-mkt-prod2@adobe-campaign.com',
                                  Origin='Email', Country__c = 'United Kingdom', OwnerId = listGroup[0].Id);
            c.setOptions(dmo);
            cases.add(c);
            
            insert cases;
            
        }
        	System.debug('>>> cases[0].Id = ' + cases[0].Id);

            EmailMessage newEmailMsg= new EmailMessage();
            
            newEmailMsg.Status='3';
        	newEmailMsg.setOptions(dmo);
            newEmailMsg.ParentId=cases[0].id;
            
            insert newEmailMsg;
            
            EmailMessage newEmailMsg2= new EmailMessage();
            
            newEmailMsg2.Status='0';
            newEmailMsg2.ParentId=cases[0].id;
            newEmailMsg2.Incoming=true;
        	newEmailMsg2.setOptions(dmo);
            insert newEmailMsg2;
            
            List<Id> caseIds = new List<Id>();
            for (Case cL : cases){
                caseIds.add(cL.Id);
            }
            
            List<Case> updateCaseT = new List<Case>([Select Status,LastModifiedDate,Last_Changed_Date__c from Case where Id In :caseIds]);
            List<EmailMessage> emailMeg= new List<EmailMessage>([Select CreatedDate,Id from EmailMessage where ParentId In :caseIds]);
            
            //Assert.areEqual(updateCaseT[0].LastModifiedDate,updateCaseT[0].Last_Changed_Date__c);   
        
    }
}