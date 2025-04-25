/***********************************************************************************************************
 * Test Class Name: MEDALLIACLF_Field_Update_Test
 * Test class for: "On Closed Loop Problem Area and Action Taken Field Update" flow
 * Created Date: 12 June 2024 
 * Code coverage for intended Artifact on 12 June 2024: 100%
************************************************************************************************************
*******************************************   Changelog   **************************************************
S.No.    Date                    Developer Name        
(1)      12 June 2024             Infosys                
***********************************************************************************************************/
@isTest
public class MEDALLIACLF_FieldUpdate_Test {
    @testSetup
    static void setup() {
        // Create a user
        String uniqueUserName = 'TestCaseAssigment' + DateTime.now().getTime() + '@testorg.com';
        Profile prof = [SELECT Id FROM Profile WHERE Name = 'CS Operations' LIMIT 1]; 
        User testUser = new User(Alias = 'tstcs', Email='testcaseassignment@testorg.com',
                                 EmailEncodingKey='UTF-8', LastName='TestCaseAsgMent', LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_GB', ProfileId = prof.Id,TimeZoneSidKey='Europe/Paris',
                                 Country = '',UserName=uniqueUserName);
        insert testUser;
 
        // Ensure the permission set exists
        PermissionSet permSet = [SELECT Id FROM PermissionSet WHERE Name ='MedalliaCLF_Permission_set' LIMIT 1]; 
        if (permSet == null) {
            System.assert(false, 'Permission Set not found');
        }
 
        // Assign the permission set to the user
        PermissionSetAssignment psa = new PermissionSetAssignment(
        PermissionSetId = permSet.Id,
        AssigneeId = testUser.Id
        );
        insert psa;
    }

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name        testPurchaseAlertTypeRecords
* @description        Create 20 Case records with Problem Area and Actions Taken field value as Other and then 
                      update that to some other value to make the Problem Areas Other and Actions Taken Other field to Blank
* @expected Outcome   Problem Areas Other and Actions Taken Other should be Blank
* ------------------------------------------------------------------------------------------------------ 
*/
    @isTest
    static void testPurchaseAlertTypeRecords() {
        // Run as test user
        User testUser = [SELECT Id FROM User WHERE LastName LIKE 'TestCaseAsgMent' LIMIT 1];
        System.runAs(testUser) {
            // Create 20 cases for Purchase Type
            List<Case> testCases = new List<Case>();
            for (Integer i = 0; i < 20; i++) {
            Case purchaseCase = new Case();
            purchaseCase.Subject= 'TestPurchaseCase'+i;
            purchaseCase.Status= 'New';
            purchaseCase.MEDALLIACLF_alert_type__c='Purchase - Contact Me';
            purchaseCase.MEDALLIACLF_PURCHASE_ACTIONS_TAKEN__c='99';
            purchaseCase.MEDALLIACLF_PURCHASE_ACTIONS_TAKEN_OTHER__c='CLF Purchase Actions Taken';
            purchaseCase.MEDALLIACLF_PURCHASE_PROBLEM_AREAS__c='99';
            purchaseCase.MEDALLIACLF_PURCHASE_PROBLEM_AREAS_OTHER__c='CLF Purchase Problem Areas';
            testCases.add(purchaseCase);
            }
            
            insert testCases;
 
            // Update the cases to trigger the flow
            for (Case c : testCases) {
                c.MEDALLIACLF_PURCHASE_ACTIONS_TAKEN__c = '6';
                c.MEDALLIACLF_PURCHASE_PROBLEM_AREAS__c = '6';
            }
            Test.startTest();
            update testCases;
            Test.stopTest();
            // Verify the flow updated the dependent fields
            List<Case> updatedCases = [SELECT MEDALLIACLF_PURCHASE_ACTIONS_TAKEN_OTHER__c,MEDALLIACLF_PURCHASE_PROBLEM_AREAS_OTHER__c FROM Case WHERE Id IN :testCases];
            for (Case c : updatedCases) {
                System.assertEquals(null, c.MEDALLIACLF_PURCHASE_ACTIONS_TAKEN_OTHER__c, 'The Purchase Actions Taken should be blank');
                System.assertEquals(null, c.MEDALLIACLF_PURCHASE_PROBLEM_AREAS_OTHER__c, 'The Purchase Problem Areas should be blank');
            }
            
        }
    }
/*
* ------------------------------------------------------------------------------------------------------
* @Method Name        testRelationshipAlertTypeRecords
* @description        Create 20 Case records with Problem Area and Actions Taken field value as Other and then 
                      update that to some other value to make the Problem Areas Other and Actions Taken Other field to Blank
* @expected Outcome   Problem Areas Other and Actions Taken Other should be Blank
* ------------------------------------------------------------------------------------------------------ 
*/
        
    @isTest
    static void testRelationshipAlertTypeRecords() {
        // Run as test user
        User testUser = [SELECT Id FROM User WHERE LastName LIKE 'TestCaseAsgMent' LIMIT 1];
        System.runAs(testUser) {
            // Create 20 cases for Relationship Type
            List<Case> testCases = new List<Case>();
            for(Integer i=0;i<=20;i++){
            Case RelationshipCase = new Case();
            RelationshipCase.Subject= 'TestRelationshipCase'+i;
            RelationshipCase.Status= 'New';
            RelationshipCase.MEDALLIACLF_alert_type__c='Relationship - Contact Me';
            RelationshipCase.MEDALLIACLF_RELATIONSHIP_ACTIONS_TAKEN__c='99';
            RelationshipCase.MEDALLIACLF_REL_ACTIONS_TAKEN_OTHER__c='CLF Relationship Actions Taken';
            RelationshipCase.MEDALLIACLF_RELATIONSHIP_PROBLEM_AREAS__c='99';
            RelationshipCase.MEDALLIACLF_RELATIONSHP_PROB_AREAS_OTHER__c='CLF Relationship Problem Areas';
            testCases.add(RelationshipCase);
            }
            insert testCases;
 
            // Update the cases to trigger the flow
            for (Case c : testCases) {
                c.MEDALLIACLF_RELATIONSHIP_ACTIONS_TAKEN__c = '6';
                c.MEDALLIACLF_RELATIONSHIP_PROBLEM_AREAS__c = '6';
            }
            Test.startTest();
            update testCases;
             Test.stopTest();
            // Verify the flow updated the dependent fields
            List<Case> updatedCases = [SELECT MEDALLIACLF_REL_ACTIONS_TAKEN_OTHER__c,MEDALLIACLF_RELATIONSHP_PROB_AREAS_OTHER__c FROM Case WHERE Id IN :testCases];
            for (Case c : updatedCases) {
                System.assertEquals(null, c.MEDALLIACLF_REL_ACTIONS_TAKEN_OTHER__c, 'The Relationship Actions Taken should be blank');
                System.assertEquals(null, c.MEDALLIACLF_RELATIONSHP_PROB_AREAS_OTHER__c, 'The Relationship Problem Areas should be blank');
            }
            
        }
    }

}