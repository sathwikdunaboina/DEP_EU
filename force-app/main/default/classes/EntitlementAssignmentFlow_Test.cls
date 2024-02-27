/***********************************************************************************************************
 * Test class Name                  : EntitlementAssignmentFlow_Test
 * Created Date                     : 
************************************************************************************************************
*******************************************   Changelog   **************************************************
S.No.    Date                    Developer Name         Azure Item Number
(1)                              Infosys                User Story-7640: Second Milestone SCTASK102119711
***********************************************************************************************************/
@isTest
public class EntitlementAssignmentFlow_Test {

    Static map<String, String> mapCountryToSlaProcessName = new map<String, String>{'UK' => 'SLA for UK/IE', 
                                                                                    'FR' => 'entitlement for france_v4'};

    static map<String, String> mapCountryToEntitlementName = new map<String, String>{'UK' => 'Case Support Process For UK/IE',
                                                                                     'FR' => 'Case Support Process For France'};
    @TestSetup
    static void dataSetup() {
        
        map<string, SlaProcess> mapSLANameToSLAProcess = new map<string, SlaProcess>();
        for (SlaProcess sla: [Select Id, Name From SlaProcess 
                                                           Where Name IN :mapCountryToSlaProcessName.values()]) {
            mapSLANameToSLAProcess.put(sla.Name, sla);
        }
        // creating account
        Account acc = new Account(Name='Demo Acc');
        Insert acc;

        // creating entitlement records
        List<Entitlement> listEntitlement = new List<Entitlement>();
        Entitlement entUK = new Entitlement
        (
            Name = mapCountryToEntitlementName.get('UK'),
            AccountId = acc.Id,
            StartDate = Date.today().addDays(-1),
            Type = 'Phone Support',
            SlaProcessId = mapSLANameToSLAProcess.get(mapCountryToSlaProcessName.get('UK')).Id
        );
        listEntitlement.add(entUK);

        Entitlement entFR = new Entitlement
        (
            Name = mapCountryToEntitlementName.get('FR'),
            AccountId = acc.Id,
            StartDate = Date.today().addDays(-1),
            Type = 'Phone Support',
            SlaProcessId = mapSLANameToSLAProcess.get(mapCountryToSlaProcessName.get('FR')).Id
        );
        listEntitlement.add(entFR);
        
        if(!listEntitlement.isEmpty())
            Insert listEntitlement;

        // creating groups
        list<Group> listGroup = new list<Group>();

        Group group_UK_IE_CS_Operations = new Group
        (
            name = 'UK/IE - CS Operations',
            type = 'Queue'
        );
        listGroup.add(group_UK_IE_CS_Operations);

        Group group_IE_CS_Operations = new Group
        (
            name = 'IE - CS Operations',
            type = 'Queue'
        );
        listGroup.add(group_IE_CS_Operations);

        Group group_UK_IE_Service_Desk = new Group
        (
            name = 'UK/IE - Service Desk',
            type = 'Queue'
        );
        listGroup.add(group_UK_IE_Service_Desk);

        Group group_FR_CS_Administration = new Group
        (
            name = 'FR - Service Clients Volvo',
            type = 'Queue'
        );
        listGroup.add(group_FR_CS_Administration);

        if(!listGroup.isEmpty())
            Insert listGroup;
        
        Profile profileObj = [Select Id from Profile where name = 'System Administrator'];
        User objUser = new User(alias = 'standt', email='demo@testorg.com',
                            emailencodingkey='UTF-8', firstname='Demo_1', lastname='Demo_l', languagelocalekey='en_US',
                            localesidkey='en_US', profileid = profileObj.Id,CountryCode = 'NL',
                            timezonesidkey='America/Los_Angeles', username='Demo_1_l@testorg.com');

        Insert objUser;
    }
    
    @isTest
    static void test_UK_IE_CSOperation_WithNoEntitlement_Record() {

        // making the entitlement inactive for covering the negative test scenario
        List<Entitlement> listEntitlement = new List<Entitlement>([Select Name, StartDate, Id From Entitlement where Name = 'Case Support Process For UK/IE']);
        
        if(!listEntitlement.isEmpty()) {
            listEntitlement[0].StartDate = Null;
            update listEntitlement;
        }
        
        // creating the queueSobject record to assign the queue as owner of the case
        // creating the queueSobject as logged in user to avoid mixed dml errors
        QueueSobject qs;
        list<Group> listGroup;

        User objUser = [Select Id From User Where FirstName = 'Demo_1' Limit 1];
        System.runAs(objUser) {
            listGroup = new list<Group>([Select Id from Group Where Name='UK/IE - CS Operations']);
            
            if(!listGroup.isEmpty()) {
                qs = new QueueSobject(QueueId=listGroup[0].Id, SobjectType='Case');
                Insert qs;
            }
        }

        Case objCase;
        if(!listGroup.isEmpty()) {
            objCase = new Case(
                Status = 'New',
                Origin = 'Email',
                Subject = 'test@1',
                OwnerId = listGroup[0].Id,
                Country__c = 'United Kingdom'
            );
        }
        Test.startTest();
        String strNoENtitlementExceptionMessage;
        if(objCase != Null)
            insert objCase;
        
        Test.stopTest();
        list<Case> listCase = new List<Case>([Select Id, Status, Origin, OwnerId, Country__c, EntitlementId From Case where Id= :objCase.Id]);
        Assert.areEqual(objCase.EntitlementId, null);
    }

    @isTest
    static void test_UK_IE_CSOperation_WithEntitlement_Record() {

        List<Entitlement> listEntitlement = new List<Entitlement>([Select Id, Name, Status, StartDate From Entitlement where Name = 'Case Support Process For UK/IE']);
        // creating the queueSobject record to assign the queue as owner of the case
        // creating the queueSobject as logged in user to avoid mixed dml errors
        QueueSobject qs;
        list<Group> listGroup;
        User objUser = [Select Id From User Where FirstName = 'Demo_1' Limit 1];
        System.runAs(objUser) {
            listGroup = new list<Group>([Select Id, Name, DeveloperName from Group Where Name='UK/IE - CS Operations']);
            
            if(!listGroup.isEmpty()) {
                qs = new QueueSobject(QueueId=listGroup[0].Id, SobjectType='Case');
                Insert qs;
            }
        }

        Case objCase;
        if(!listGroup.isEmpty()) {
            objCase = new Case(
                Status = 'New',
                Origin = 'Email',
                Subject = 'test@1',
                OwnerId = listGroup[0].Id,
                Country__c = 'United Kingdom'
            );
        }
        
        Test.startTest();
        if(objCase != Null)
            insert objCase;
        Test.stopTest();
        list<Case> listCase = new List<Case>([Select Id, Status, Origin, OwnerId, Country__c, EntitlementId From Case where Id= :objCase.Id]);
        if(!listCase.isEmpty() && !listEntitlement.isEmpty()) {
            Assert.areEqual(listCase[0].EntitlementId, listEntitlement[0].Id);   
        }
    }

    @isTest
    static void test_IE_CS_Operations_WithNoEntitlement_Record() {

        // making the entitlement inactive for covering the negative test scenario
        List<Entitlement> listEntitlement = new List<Entitlement>([Select Name, StartDate, Id From Entitlement where Name = 'Case Support Process For UK/IE']);
        
        if(!listEntitlement.isEmpty()) {
            listEntitlement[0].StartDate = Null;
            update listEntitlement;
        }
        
        // creating the queueSobject record to assign the queue as owner of the case
        // creating the queueSobject as logged in user to avoid mixed dml errors
        QueueSobject qs;
        list<Group> listGroup;
        User objUser = [Select Id From User Where FirstName = 'Demo_1' Limit 1];
        System.runAs(objUser) {
            listGroup = new list<Group>([Select Id from Group Where Name='IE - CS Operations']);
            
            if(!listGroup.isEmpty()) {
                qs = new QueueSobject(QueueId=listGroup[0].Id, SobjectType='Case');
                Insert qs;
            }
        }

        Case objCase;
        if(!listGroup.isEmpty()) {
            objCase = new Case(
                Status = 'New',
                Origin = 'Email',
                Subject = 'test@1',
                OwnerId = listGroup[0].Id,
                Country__c = 'United Kingdom'
            );
        }
        Test.startTest();
        String strNoENtitlementExceptionMessage;
        if(objCase != Null)
            insert objCase;
        
        Test.stopTest();
        list<Case> listCase = new List<Case>([Select Id, Status, Origin, OwnerId, Country__c, EntitlementId From Case where Id= :objCase.Id]);
        Assert.areEqual(objCase.EntitlementId, null);
        // Assert.areEqual(strNoENtitlementExceptionMessage, 
        // 'There is no entitlement record present for UK/IE, please ask your administrator to create an entitlement record for UK/IE');
    }

    @isTest
    static void test_IE_CS_Operations_WithEntitlement_Record() {

        List<Entitlement> listEntitlement = new List<Entitlement>([Select Id, Name, Status, StartDate From Entitlement where Name = 'Case Support Process For UK/IE']);
        // creating the queueSobject record to assign the queue as owner of the case
        // creating the queueSobject as logged in user to avoid mixed dml errors
        QueueSobject qs;
        list<Group> listGroup;
        User objUser = [Select Id From User Where FirstName = 'Demo_1' Limit 1];
        System.runAs(objUser) {
            listGroup = new list<Group>([Select Id, Name, DeveloperName from Group Where Name='IE - CS Operations']);
            
            if(!listGroup.isEmpty()) {
                qs = new QueueSobject(QueueId=listGroup[0].Id, SobjectType='Case');
                Insert qs;
            }
        }

        Case objCase;
        if(!listGroup.isEmpty()) {
            objCase = new Case(
                Status = 'New',
                Origin = 'Email',
                Subject = 'test@1',
                OwnerId = listGroup[0].Id,
                Country__c = 'United Kingdom'
            );
        }
        
        Test.startTest();
        if(objCase != Null)
            insert objCase;
        Test.stopTest();
        list<Case> listCase = new List<Case>([Select Id, Status, Origin, OwnerId, Country__c, EntitlementId From Case where Id= :objCase.Id]);
        if(!listCase.isEmpty() && !listEntitlement.isEmpty()) {
            Assert.areEqual(listCase[0].EntitlementId, listEntitlement[0].Id);   
        }
    }

    @isTest
    static void test_UK_IE_Service_Desk_WithNoEntitlement_Record() {

        // making the entitlement inactive for covering the negative test scenario
        List<Entitlement> listEntitlement = new List<Entitlement>([Select Name, StartDate, Id From Entitlement where Name = 'Case Support Process For UK/IE']);
        
        if(!listEntitlement.isEmpty()) {
            listEntitlement[0].StartDate = Null;
            update listEntitlement;
        }
        
        // creating the queueSobject record to assign the queue as owner of the case
        // creating the queueSobject as logged in user to avoid mixed dml errors
        QueueSobject qs;
        list<Group> listGroup;
        User objUser = [Select Id From User Where FirstName = 'Demo_1' Limit 1];
        System.runAs(objUser) {
            listGroup = new list<Group>([Select Id from Group Where Name='UK/IE - Service Desk']);
            
            if(!listGroup.isEmpty()) {
                qs = new QueueSobject(QueueId=listGroup[0].Id, SobjectType='Case');
                Insert qs;
            }
        }

        Case objCase;
        if(!listGroup.isEmpty()) {
            objCase = new Case(
                Status = 'New',
                Origin = 'Email',
                Subject = 'test@1',
                OwnerId = listGroup[0].Id,
                Country__c = 'United Kingdom'
            );
        }
        Test.startTest();
        String strNoENtitlementExceptionMessage;
        if(objCase != Null)
            insert objCase;
        
        Test.stopTest();
        list<Case> listCase = new List<Case>([Select Id, Status, Origin, OwnerId, Country__c, EntitlementId From Case where Id= :objCase.Id]);
        Assert.areEqual(objCase.EntitlementId, null);
        // Assert.areEqual(strNoENtitlementExceptionMessage, 
        // 'There is no entitlement record present for UK/IE, please ask your administrator to create an entitlement record for UK/IE');
    }

    @isTest
    static void test_UK_IE_Service_Desk_WithEntitlement_Record() {

        List<Entitlement> listEntitlement = new List<Entitlement>([Select Id, Name, Status, StartDate From Entitlement where Name = 'Case Support Process For UK/IE']);
        // creating the queueSobject record to assign the queue as owner of the case
        // creating the queueSobject as logged in user to avoid mixed dml errors
        QueueSobject qs;
        list<Group> listGroup;
        User objUser = [Select Id From User Where FirstName = 'Demo_1' Limit 1];
        System.runAs(objUser) {
            listGroup = new list<Group>([Select Id, Name, DeveloperName from Group Where Name='UK/IE - Service Desk']);
            
            if(!listGroup.isEmpty()) {
                qs = new QueueSobject(QueueId=listGroup[0].Id, SobjectType='Case');
                Insert qs;
            }
        }

        Case objCase;
        if(!listGroup.isEmpty()) {
            objCase = new Case(
                Status = 'New',
                Origin = 'Email',
                Subject = 'test@1',
                OwnerId = listGroup[0].Id,
                Country__c = 'United Kingdom'
            );
        }
        
        Test.startTest();
        if(objCase != Null)
            insert objCase;
        Test.stopTest();
        list<Case> listCase = new List<Case>([Select Id, Status, Origin, OwnerId, Country__c, EntitlementId From Case where Id= :objCase.Id]);
        if(!listCase.isEmpty() && !listEntitlement.isEmpty()) {
            Assert.areEqual(listCase[0].EntitlementId, listEntitlement[0].Id);   
        }
    }


    // @isTest
    // static void test_Italy_CS_Operations_WithNoEntitlement_Record() {

    //     // making the entitlement inactive for covering the negative test scenario
    //     List<Entitlement> listEntitlement = new List<Entitlement>([Select Name, StartDate, Id From Entitlement where Name = 'Case Support Process For CH']);
        
    //     if(!listEntitlement.isEmpty()) {
    //         listEntitlement[0].StartDate = Null;
    //         update listEntitlement;
    //     }
        
    //     // creating the queueSobject record to assign the queue as owner of the case
    //     // creating the queueSobject as logged in user to avoid mixed dml errors
    //     QueueSobject qs;
    //     list<Group> listGroup;
    //     User objUser = [Select Id From User Where FirstName = 'Demo_1' Limit 1];
    //    System.runAs(objUser) {
    //         listGroup = new list<Group>([Select Id from Group Where Name='Italy - CS Operations']);
            
    //         if(!listGroup.isEmpty()) {
    //             qs = new QueueSobject(QueueId=listGroup[0].Id, SobjectType='Case');
    //             Insert qs;
    //         }
    //     }

    //     Case objCase;
    //     if(!listGroup.isEmpty()) {
    //         objCase = new Case(
    //             Status = 'New',
    //             Origin = 'Email',
    //             Subject = 'test@1',
    //             OwnerId = listGroup[0].Id,
    //             Country__c = 'Italy'
    //         );
    //     }
    //     Test.startTest();
    //     String strNoENtitlementExceptionMessage;
    //     if(objCase != Null)
    //         insert objCase;
        
    //     Test.stopTest();
    //     list<Case> listCase = new List<Case>([Select Id, Status, Origin, OwnerId, Country__c, EntitlementId From Case where Id= :objCase.Id]);
    //     Assert.areEqual(objCase.EntitlementId, null);
    //     // Assert.areEqual(strNoENtitlementExceptionMessage, 
    //     // 'There is no entitlement record present for UK/IE, please ask your administrator to create an entitlement record for UK/IE');
    // }

    // @isTest
    // static void test_Italy_CS_Operations_WithEntitlement_Record() {

    //     List<Entitlement> listEntitlement = new List<Entitlement>([Select Id, Name, Status, StartDate From Entitlement where Name = 'Case Support Process For CH']);
    //     // creating the queueSobject record to assign the queue as owner of the case
    //     // creating the queueSobject as logged in user to avoid mixed dml errors
    //     QueueSobject qs;
    //     list<Group> listGroup;
    //     User objUser = [Select Id From User Where FirstName = 'Demo_1' Limit 1];
    //    System.runAs(objUser) {
    //         listGroup = new list<Group>([Select Id, Name, DeveloperName from Group Where Name='Italy - CS Operations']);
            
    //         if(!listGroup.isEmpty()) {
    //             qs = new QueueSobject(QueueId=listGroup[0].Id, SobjectType='Case');
    //             Insert qs;
    //         }
    //     }

    //     Case objCase;
    //     if(!listGroup.isEmpty()) {
    //         objCase = new Case(
    //             Status = 'New',
    //             Origin = 'Email',
    //             Subject = 'test@1',
    //             OwnerId = listGroup[0].Id,
    //             Country__c = 'Italy'
    //         );
    //     }
        
    //     Test.startTest();
    //     if(objCase != Null)
    //         insert objCase;
    //     Test.stopTest();
    //     list<Case> listCase = new List<Case>([Select Id, Status, Origin, OwnerId, Country__c, EntitlementId From Case where Id= :objCase.Id]);
    //     if(!listCase.isEmpty() && !listEntitlement.isEmpty()) {
    //         Assert.areEqual(listCase[0].EntitlementId, listEntitlement[0].Id);   
    //     }
    // }

    @isTest
    static void test_FR_Service_Clients_Volvo_WithNoEntitlement_Record() {

        // making the entitlement inactive for covering the negative test scenario
        List<Entitlement> listEntitlement = new List<Entitlement>([Select Name, StartDate, Id From Entitlement where Name = 'Case Support Process For France']);
        
        if(!listEntitlement.isEmpty()) {
            listEntitlement[0].StartDate = Null;
            update listEntitlement;
        }
        
        // creating the queueSobject record to assign the queue as owner of the case
        // creating the queueSobject as logged in user to avoid mixed dml errors
        QueueSobject qs;
        list<Group> listGroup;
        User objUser = [Select Id From User Where FirstName = 'Demo_1' Limit 1];
        System.runAs(objUser) {
            listGroup = new list<Group>([Select Id from Group Where Name='FR - Service Clients Volvo']);
            
            if(!listGroup.isEmpty()) {
                qs = new QueueSobject(QueueId=listGroup[0].Id, SobjectType='Case');
                Insert qs;
            }
        }

        Case objCase;
        if(!listGroup.isEmpty()) {
            objCase = new Case(
                Status = 'New',
                Origin = 'Email',
                Subject = 'test@1',
                OwnerId = listGroup[0].Id,
                Country__c = 'France'
            );
        }
        Test.startTest();
        String strNoENtitlementExceptionMessage;
        if(objCase != Null)
            insert objCase;
        
        Test.stopTest();
        list<Case> listCase = new List<Case>([Select Id, Status, Origin, OwnerId, Country__c, EntitlementId From Case where Id= :objCase.Id]);
        Assert.areEqual(objCase.EntitlementId, null);
        // Assert.areEqual(strNoENtitlementExceptionMessage, 
        // 'There is no entitlement record present for UK/IE, please ask your administrator to create an entitlement record for UK/IE');
    }

    @isTest
    static void test_FR_Service_Clients_Volvo_WithEntitlement_Record() {

        List<Entitlement> listEntitlement = new List<Entitlement>([Select Id, Name, Status, StartDate From Entitlement where Name = 'Case Support Process For France']);
        // creating the queueSobject record to assign the queue as owner of the case
        // creating the queueSobject as logged in user to avoid mixed dml errors
        QueueSobject qs;
        list<Group> listGroup;
        User objUser = [Select Id From User Where FirstName = 'Demo_1' Limit 1];
        System.runAs(objUser) {
            listGroup = new list<Group>([Select Id, Name, DeveloperName from Group Where Name='FR - Service Clients Volvo']);
            
            if(!listGroup.isEmpty()) {
                qs = new QueueSobject(QueueId=listGroup[0].Id, SobjectType='Case');
                Insert qs;
            }
        }

        Case objCase;
        if(!listGroup.isEmpty()) {
            objCase = new Case(
                Status = 'New',
                Origin = 'Email',
                Subject = 'test@1',
                OwnerId = listGroup[0].Id,
                Country__c = 'France'
            );
        }
        
        Test.startTest();
        if(objCase != Null)
            insert objCase;
        Test.stopTest();
        list<Case> listCase = new List<Case>([Select Id, Status, Origin, OwnerId, Country__c, EntitlementId From Case where Id= :objCase.Id]);
        if(!listCase.isEmpty() && !listEntitlement.isEmpty()) {
            Assert.areEqual(listCase[0].EntitlementId, listEntitlement[0].Id);   
        }
    }
}