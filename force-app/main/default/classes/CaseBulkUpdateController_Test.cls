/* 
* ----------------------------------------------------------------------------------
* Apex Class Name     CaseBulkUpdateController_Test
* @author             Swami Goskula<Swami.goskula@consulant.volvo.com>
* @Created Date       21-04-2025 

* ----------------------------------------------------------------------------------
* @description        This class is used to test CaseBulkUpdateController class
* ----------------------------------------------------------------------------------
*/

@IsTest(SeeAllData=false)
public class CaseBulkUpdateController_Test {
    @testSetup
    static void setup() {
        Id accountRecordTypeID = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
        
        
        Account acc= new Account();
        acc.name='Test Account for UK Case';
        acc.CurrencyIsoCode='EUR';
        acc.RecordTypeId=accountRecordTypeID; 
        acc.BillingCountry='United Kingdom';
        insert acc;
        
        
        Entitlement EntitlementRecord = new Entitlement();
        EntitlementRecord.Name='Case Support Process For UK/IE';
        EntitlementRecord.AccountId= acc.Id;             
        insert EntitlementRecord;
        
        List<Case> cases = new List<Case>();
        for (Integer i = 0; i < 5; i++) {
            cases.add(new Case(
                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('All Case').getRecordTypeId()
            ));
        }
        insert cases;
        
        Case parentCase = new Case(
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('All Case').getRecordTypeId()
        );
        insert parentCase;
        
        List<Case> childCases = new List<Case>();
        for (Integer i = 0; i < 5; i++) {
            childCases.add(new Case(
                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('All Case').getRecordTypeId(),
                ParentId = parentCase.Id
            ));
        }
        insert childCases;
    }
/*
* ------------------------------------------------------------------------
* @Method Name     testGetSelectedCases
* @description     This test is used to cover getSelectedCases method 
* --------------------------------------------------------------------------
*/
    
    @isTest
    static void testGetSelectedCases() {
        List<Case> testCases = [SELECT Id FROM Case LIMIT 5];
        List<Id> caseIds = new List<Id>();
        for (Case c : testCases) {
            caseIds.add(c.Id);
        }
        
        Test.startTest();
        List<Case> selectedCases = CaseBulkUpdateController.getSelectedCases(caseIds);
        Test.stopTest();
        
        System.assertEquals(5, selectedCases.size(), 'Expected 5 cases to be returned');
        for (Case c : selectedCases) {
            System.assert(caseIds.contains(c.Id), 'Returned case ID should be in the list of input IDs');
        }
    }
/*
* -----------------------------------------------------------------------------------------------------------
* @Method Name     testGetSelectedCases
* @description     This test is used to cover validateParentCase method to get the Cases without parentCase
* ------------------------------------------------------------------------------------------------------------
*/
    
    @isTest
    static void testValidateParentCase() {
        List<Case> testCases = [SELECT Id FROM Case LIMIT 10];
        List<Id> caseIds = new List<Id>();
        for (Case c : testCases) {
            caseIds.add(c.Id);
        }
        
        Test.startTest();
        List<String> casesWithoutParent = CaseBulkUpdateController.validateParentCase(caseIds, 'Duplicate');
        system.debug(casesWithoutParent +'casesWithoutParent');
        Test.stopTest();
        
        System.assertEquals(6, casesWithoutParent.size(), 'Expected 5 cases without parent to be returned');
        for (String caseNumber : casesWithoutParent) {
            Case c = [SELECT Id, CaseNumber,ParentId FROM Case WHERE CaseNumber = :caseNumber LIMIT 1];
            System.assert(c.ParentId == null, 'Returned case should have no parent case');
        }
    }
 /*
* -----------------------------------------------------------------------------------------------------------
* @Method Name     testGetCurrentUserProfile
* @description     This test is used to cover getCurrentUserProfile method to get the current profileName
* ------------------------------------------------------------------------------------------------------------
*/   
    
    @isTest
    static void testGetCurrentUserProfile() {
        Test.startTest();
        String profileName = CaseBulkUpdateController.getCurrentUserProfile();
        Test.stopTest();
        
        System.assertNotEquals(null, profileName);
    }
/*
* -----------------------------------------------------------------------------------------------------------
* @Method Name     testValidateRecordTypes
* @description     This test is used to cover validateRecordTypes method to check selected Recordtypes
* ------------------------------------------------------------------------------------------------------------
*/   
    
    
    @isTest
    static void testValidateRecordTypes() {
        List<Case> cases = [SELECT Id FROM Case LIMIT 5];
        List<Id> caseIds = new List<Id>();
        for (Case c : cases) {
            caseIds.add(c.Id);
        }
        
        Test.startTest();
        String validationMessage = CaseBulkUpdateController.validateRecordTypes(caseIds);
        Test.stopTest();
        
        System.assert(validationMessage == null || validationMessage.contains('No cases selected.'));
    }
    
    
    
}