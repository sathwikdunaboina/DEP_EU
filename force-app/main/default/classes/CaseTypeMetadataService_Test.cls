@isTest
public class CaseTypeMetadataService_Test {

    @isTest
    static void testGetTypeSubTypes() {
        List<Country_Type_Subtype__mdt> countryTypeSubList = [SELECT Country__c, Type__c, Sub_Type__c, RecordTypes_Allowed__c FROM Country_Type_Subtype__mdt];
        List<CaseTypeMetadataService.TypeSubTypeWrapper> results =
            CaseTypeMetadataService.getTypeSubTypes('United Kingdom', 'All_Case');
		system.debug(results);
        System.assert(results.size() > 0, 'At least one type should be returned.');
        CaseTypeMetadataService.TypeSubTypeWrapper first = results[0];

        System.assertNotEquals(null, first.typeMaster, 'Type master should not be null');
        System.assertNotEquals(null, first.typeLabel, 'Type label should not be null');
        System.assert(first.subTypes.size() > 0, 'Subtype list should not be empty');

        CaseTypeMetadataService.SubTypeWrapper sub = first.subTypes[0];
        System.assertNotEquals(null, sub.subTypeMaster, 'Subtype master should not be null');
        System.assertNotEquals(null, sub.subTypeLabel, 'Subtype label should not be null');
    }

    @isTest
    static void testGetTypeSubTypes_NoResults() {
        Test.startTest();
        List<CaseTypeMetadataService.TypeSubTypeWrapper> results =
            CaseTypeMetadataService.getTypeSubTypes('Germany', 'UnknownRT');
        Test.stopTest();

        System.assertEquals(0, results.size(), 'Should return empty list when no matching metadata.');
    }
}