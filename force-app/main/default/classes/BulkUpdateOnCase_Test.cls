@isTest
public class BulkUpdateOnCase_Test {
    @isTest
    static void testUpdateCases() {
        // Create test data
        List<Case> cases = new List<Case>();
        for (Integer i = 0; i < 5; i++) {
            cases.add(new Case(
                Subject = 'Test Case ' + i,
                Status = 'New',
                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('All Case').getRecordTypeId()
            ));
        }
        insert cases;
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('MEDALLIACLF Alert Cases').getRecordTypeId();
        
        // Prepare the request
        BulkUpdateOnCase.CaseUpdateRequest request = new BulkUpdateOnCase.CaseUpdateRequest();
        request.CaseIds = new List<Id>();
        for (Case c : cases) {
            request.CaseIds.add(c.Id);
        }
        request.Type = 'Contract Hire';
        request.SubType = 'Not Applicable';
        request.Status = 'In Progress';
        request.StatusReason = 'To be checked';
        request.Brand = 'Bus';
        
        List<BulkUpdateOnCase.CaseUpdateRequest> requests = new List<BulkUpdateOnCase.CaseUpdateRequest>{ request };
            
            // Call the method
            Test.startTest();
        List<BulkUpdateOnCase.CaseUpdateRequest> response = BulkUpdateOnCase.updateCases(requests);
        Test.stopTest();
        
        // Verify the results
        for (BulkUpdateOnCase.CaseUpdateRequest res : response) {
            System.assertEquals('', res.ErrorMessage, 'There should be no error messages');
        }
        
        // Verify the cases were updated
        cases = [SELECT Id, Type, Sub_Type__c, Status, Status_Reason__c, Brand__c FROM Case WHERE Id IN :request.CaseIds];
        for (Case c : cases) {
            System.assertEquals('Contract Hire', c.Type, 'Type should be updated');
            System.assertEquals('Not Applicable', c.Sub_Type__c, 'SubType should be updated');
            System.assertEquals('In Progress', c.Status, 'Status should be updated');
            System.assertEquals('To be checked', c.Status_Reason__c, 'Status Reason should be updated');
            System.assertEquals('Bus', c.Brand__c, 'Brand should be updated');
        }
    }
    @isTest
    static void testUpdateCasesWithErrors() {
        // Create test data
        List<Case> cases = new List<Case>();
        for (Integer i = 0; i < 5; i++) {
            cases.add(new Case(
                Subject = 'Test Case ' + i,
                Status = 'New',
                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('All Case').getRecordTypeId()
            ));
        }
        insert cases;
        
        // Prepare the request with missing mandatory fields
        BulkUpdateOnCase.CaseUpdateRequest request = new BulkUpdateOnCase.CaseUpdateRequest();
        request.CaseIds = new List<Id>();
        for (Case c : cases) {
            request.CaseIds.add(c.Id);
        }
        request.Status = 'Closed'; // Missing Type and SubType
        
        List<BulkUpdateOnCase.CaseUpdateRequest> requests = new List<BulkUpdateOnCase.CaseUpdateRequest>{ request };
            
            // Call the method
            Test.startTest();
        List<BulkUpdateOnCase.CaseUpdateRequest> response = BulkUpdateOnCase.updateCases(requests);
        Test.stopTest();
        
        // Verify the results
        for (BulkUpdateOnCase.CaseUpdateRequest res : response) {
            System.assertNotEquals('', res.ErrorMessage, 'There should be error messages');
            System.assert(res.ErrorMessage.contains('Type and SubType is mandatory when Status is Closed'), 'Error message should indicate missing Type and SubType');
        }
    }
    
    @isTest
    static void testUpdateCasesWithBrandError() {
        // Create test data
        List<Case> cases = new List<Case>();
        for (Integer i = 0; i < 5; i++) {
            cases.add(new Case(
                Subject = 'Test Case ' + i,
                Status = 'New',
                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('All Case').getRecordTypeId()
            ));
        }
        insert cases;
        
        // Prepare the request with missing Brand for non-System Admin user
        BulkUpdateOnCase.CaseUpdateRequest request = new BulkUpdateOnCase.CaseUpdateRequest();
        request.CaseIds = new List<Id>();
        for (Case c : cases) {
            request.CaseIds.add(c.Id);
        }
        request.Status = 'Closed';
        request.Type = 'Contract Hire';
       // request.SubType = 'Not Applicable';
        request.StatusReason = 'No Action';
        // Missing Brand
        
        List<BulkUpdateOnCase.CaseUpdateRequest> requests = new List<BulkUpdateOnCase.CaseUpdateRequest>{ request };
            
            // Call the method
            Test.startTest();
        List<BulkUpdateOnCase.CaseUpdateRequest> response = BulkUpdateOnCase.updateCases(requests);
        Test.stopTest();
        
        // Verify the results
        for (BulkUpdateOnCase.CaseUpdateRequest res : response) {
            System.assertNotEquals('', res.ErrorMessage, 'There should be error messages');
            System.assert(res.ErrorMessage.contains('SubType is mandatory when Status is Closed'), 'Error message should indicate missing SubType');
        }
    }
}