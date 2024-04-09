/***********************************************************************************************************
 * Test Class Name: CaseCountryAssignmentFlow_Test
 * Test class for: "Case Country Assignment Flow" flow
 * Created Date: 22nd Feb 2024 
 * Code coverage for intended Artifact on 22nd Feb 2024: %
************************************************************************************************************
*******************************************   Changelog   **************************************************
S.No.    Date                    Developer Name         Azure Item Number
(1)      22 Feb 2024             Infosys                TASK 7894: Creation of flow for Case Country 
                                                                   Assignment
***********************************************************************************************************/
@isTest
public class CaseCountryAssignmentFlow_Test {
    
    @isTest
    static void countryAssignmentByQueueOwner() {

        Id ZA_ActivationRequest_QueueId = [SELECT Id, Name, DeveloperName, Email, Type 
                                        FROM Group where Type='Queue' And Name ='ZA - Activation request'].Id;
        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('All Case').getRecordTypeId();
        System.debug('>>> ZA_ActivationRequest_QueueId = ' + ZA_ActivationRequest_QueueId);
        Case objCaseZA = new Case();
        objCaseZA.Status = 'New';
        objCaseZA.Origin = 'Email';
        objCaseZA.Subject = 'test@1';
        objCaseZA.OwnerId = ZA_ActivationRequest_QueueId;
        objCaseZA.Type = 'End of term query';
        objCaseZA.Sub_Type__c = 'Extension request';
        objCaseZA.RecordTypeId = devRecordTypeId;
		
        Database.DMLOptions options = new Database.DMLOptions();
        options.assignmentRuleHeader.useDefaultRule = false;
        objCaseZA.setOptions(options);
        
        Test.startTest();
        insert objCaseZA;
        Test.stopTest();

        Case cs = [Select Id, Country__c From Case where Id = :objCaseZA.Id];
        Assert.areEqual('South Africa', cs.Country__c);
    }

    @isTest
    static void countryAssignmentByUserOwner() {

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
            TimeZoneSidKey = 'America/Chicago',
            Country = 'South Africa'
        );
        insert owner;

        Case objCaseZA;
        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('All Case').getRecordTypeId();
        System.runAs(owner) {

            objCaseZA = new Case();
            objCaseZA.Status = 'New';
            objCaseZA.Origin = 'Email';
            objCaseZA.Subject = 'test@1';
            objCaseZA.OwnerId = owner.Id;
            objCaseZA.Type = 'End of term query';
            objCaseZA.Sub_Type__c = 'Extension request';
            objCaseZA.RecordTypeId = devRecordTypeId;
            
            Database.DMLOptions options = new Database.DMLOptions();
            options.assignmentRuleHeader.useDefaultRule = false;
            objCaseZA.setOptions(options);
            
            Test.startTest();
            insert objCaseZA;
            Test.stopTest();

            Case cs = [Select Id, Country__c From Case where Id = :objCaseZA.Id];
            Assert.areEqual('South Africa', cs.Country__c);
        }
    }
}