/***********************************************************************************************************
* Test Class Name:CaseCreateOnHandlerFlowTest
* Test class for: " Case on Create" flow
* Created Date: 23th Nov 2023
* Code coverage for intended Artifact on 17th November 2023: %
************************************************************************************************************
*******************************************   Changelog   **************************************************
S.No.    Date                    Developer Name         Azure Item Number
(1)      23th Nov 2023        Infosys Aswin Balaji      TASK 6978: Managing inbound emails - Setup Case queues 
***********************************************************************************************************
Flow Name: Case On create
***********************************************************************************************************/
@isTest
public class CaseCreateOnHandlerFlowTest {
    @TestSetup
    static void setup() {
        
        UserRole portalRole = [Select Id,DeveloperName From UserRole Where DeveloperName = 'UK_IE_Service_Representative_Service_Contracts' Limit 1];
        Profile profileObj = [Select Id from Profile where name = 'System Administrator' LIMIT 1];
        permissionSet permissionSetData = [SELECT Id, Name FROM PermissionSet Where Name = 'VFS_Dealer_Cases'LIMIT 1];
        User owner = new User(
            ProfileId = profileObj.Id,
            UserRoleId = portalRole.Id,
            Username = 'admin@testclass.org' + System.currentTimeMillis(),
            Alias = 'admin',
            Email = 'admin@testclass.org',
            EmailEncodingKey = 'UTF-8',
            Lastname = 'admin',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Chicago'
        );
        insert owner;
        User owner1 = new User(
            ProfileId = profileObj.Id,
            //UserRoleId = portalRole.Id,
            Username = 'admin@testclass1.org' + System.currentTimeMillis(),
            Alias = 'admin1',
            Email = 'admin@testclass1.org',
            EmailEncodingKey = 'UTF-8',
            Lastname = 'admin1',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Chicago'
        );
        insert owner1;
        PermissionSetAssignment psa = new PermissionSetAssignment
            (PermissionSetId = permissionSetData.Id, AssigneeId = owner1.Id);
        insert psa;   
        System.runAs(owner) 
        {
            Account accObj = new Account();
            accObj.Name = 'demoAcc';
            accObj.CustomerID__c = 'demo123';           
            insert accObj;
            
            Contact conObj = new Contact();
            conObj.LastName = 'demoContact';
            conObj.Email = 'demoContact@test.com';
            conObj.AccountId = accObj.Id;
            insert conObj;
            
            
        }
    }
    
    @isTest 
    static void createCaseCreation_Test() {
        User usrObj = [Select Id From User Where Email = 'admin@testclass.org' limit 1];
        User usrObj1 = [Select Id From User Where Email = 'admin@testclass1.org' limit 1];
        Id QueueId = [Select Id From Group Where Name = 'UK/IE - Service Desk'].Id;
        System.runAs(usrObj) {
            Test.startTest();
            Case caseObj1 = new Case(Subject='testCase',Status='New',Origin='Email',OwnerId = QueueId);
            Insert caseObj1;
            Assert.areEqual(QueueId, caseObj1.OwnerId, 'Case created');
            Case caseObj2 = new Case(Subject = 'testCase',Status = 'New',Origin = 'Email',OwnerId = usrObj.Id);
            Insert caseObj2;
            Assert.areEqual(usrObj.Id, caseObj2.OwnerId, 'Case created');
            system.debug(caseObj1.OwnerId);
            system.debug(caseObj2.OwnerId);
            Test.stopTest();
        }
        System.runAs(usrObj1){
            Case caseObj = new Case(Subject='testCase',Status='New',Origin='Email',Type = 'Change my details',Sub_Type__c = 'Change Bank details',Country__c = 'Italy',OwnerId = usrObj1.Id);
            Insert caseObj;
            Assert.areEqual('Change Bank details', caseObj.Sub_Type__c, 'Case created');
            Case caseObj3 = new Case(Subject='testCase',Status='New',Origin='Email',Type = 'Change my details',Sub_Type__c = 'Vehicle information',Country__c = 'Italy');
            Insert caseObj3;
            Assert.areEqual('Change my details', caseObj3.Type, 'Case created');
            Case caseObj4 = new Case(Subject='testCase',Status='New',Origin='Email',Type = 'Financial Contract query',Sub_Type__c = 'Amendment Restructure',Country__c = 'Italy',OwnerId = usrObj1.Id);
            Insert caseObj4;
            Assert.areEqual('Financial Contract query', caseObj4.Type, 'Case created'); 
            system.debug(caseObj3.OwnerId);
            system.debug(caseObj4.OwnerId);
            system.debug(caseObj.OwnerId);
        }
    }
}