/***********************************************************************************************************
 * Test Class Name: CreateTaskOnCaseCreationFlow_Test
 * Test class for: "Create_Task_when_Case_is_created_via_Dataloader" flow
 * Created Date: 11th August 2023 
 * Code coverage for intended Artifact on 11th August 2023: 100%
************************************************************************************************************
*******************************************   Changelog   **************************************************
S.No.    Date                    Developer Name         Azure Item Number
(1)      11th August 2023        Infosys                TASK 6651: Create test class for Create Task when 
																   Case is created via Dataloader
***********************************************************************************************************/
@isTest
public class CreateTaskOnCaseCreationFlow_Test {
	
    @TestSetup
    static void setup() {
        
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Profile profileObj = [Select Id from Profile where name = 'System Administrator'];
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
    static void createTaskOnCaseCreation_Test() {
        
        User usrObj = [Select Id From User Where Email = 'admin@testclass.org' limit 1];
        
        System.runAs(usrObj) {
            Contact cont = [SELECT Id FROM Contact WHERE LastName = 'demoContact'];
            
            Test.startTest();
            Case caseObj = new Case(Status='New', ContactId=cont.Id, Task_Due_Date__c=Date.today(), 
                                    Task_Name__c = 'DemoTaskName', Is_Dataloader__c = True);
            Insert caseObj;
            Task tskObj = [Select ActivityDate, OwnerId, Subject, status, whatId from Task limit 1];
            Test.stopTest();
            system.assert(tskObj != null, 'Tasks are not created on case creation');
        }
        
    }
}