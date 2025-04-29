/***********************************************************************************************************
 * Test Class Name: CaptureFirstOwnerOfCaseTest
 * Test class for: "Capture_Case_First_Owner" flow
 * Created Date: 28th Feb 2024
 * Code coverage for intended Artifact on 28th Feb 2024: 100%
************************************************************************************************************
*******************************************   Changelog   **************************************************
S.No.    Date                    Developer Name         Azure Item Number
(1)      28th Feb 2024           Infosys                TASK 7966: Create test class for capturing first owner name 
***********************************************************************************************************/
@isTest
public class CaptureFirstOwnerOfCaseTest {

@TestSetup
    static void setup() {
        
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Profile profileObj = [Select Id from Profile where name = 'System Administrator'];
        User owner = new User(
            ProfileId = profileObj.Id,
            UserRoleId = portalRole.Id,
            Username = 'admin@testclass.org' + System.currentTimeMillis(),
            Alias = 'admin',
            FirstName='Firstname',
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
            accObj.BillingCountry = 'United Kingdom';
            insert accObj;
            
            Contact conObj = new Contact();
            conObj.LastName = 'demoContact';
            conObj.Email = 'demoContact@test.com';
            conObj.AccountId = accObj.Id;
            insert conObj;
            
            
        }
    }
    static testMethod void PutFirstOwnerNameTest()
{
     
     User usrObj = [Select Id From User Where Email = 'admin@testclass.org' limit 1];
        
        System.runAs(usrObj) {
            Contact cont = [SELECT Id FROM Contact WHERE LastName = 'demoContact'];
            
            Test.startTest();
            Case caseObj = new Case(Status='New', ContactId=cont.Id,Subject='TestForFirstOwnerName');
            Insert caseObj;
            Case caseObjWithFirstOwner=[Select Status,Subject,First_Owner__C from Case Where Subject='TestForFirstOwnerName'limit 1];
            Test.stopTest();
            String FirstOwnerName=caseObjWithFirstOwner.First_Owner__C;
            Assert.areEqual(FirstOwnerName, 'Firstname admin');
        }
        
    }
  }