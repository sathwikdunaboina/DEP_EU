/***********************************************************************************************************
 * Test class Name                  : LeadConversionTest
 * Created Date                     : 09 Sept 2024
 * Used By                          : Lead Opportunity Flow Test Coverage
************************************************************************************************************
*******************************************   Changelog   **************************************************
S.No.    Date                    Developer Name         Azure Item Number
(1)                              Infosys                User Story-694893: Convert Lead To Opportunity
***********************************************************************************************************/


@isTest
public class LeadConversionTest {

    @isTest
    static void testLeadConversion() {
        // Set up test data
        Lead testLead = new Lead(
            FirstName = 'John',
            LastName = 'Doe',
            Company = 'Test Company',
            Status = 'Open - Not Contacted'
        );
        insert testLead;

        // Verify the lead is inserted and the initial IsConverted is false
        Lead insertedLead = [SELECT Id, Status, IsConverted FROM Lead WHERE Id = :testLead.Id];
        System.assertEquals(false, insertedLead.IsConverted, 'The lead should not be converted initially.');

        // Convert the lead
        Test.startTest();

        // Create a LeadConvert object and set the lead ID to convert
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(insertedLead.Id);
        lc.setConvertedStatus('Converted');


      

        // Perform the lead conversion
        Database.LeadConvertResult lcr = Database.convertLead(lc);


        Test.stopTest();

        // Verify the IsConverted field is true
        Lead resultLead = [SELECT Id, Status, IsConverted FROM Lead WHERE Id = :insertedLead.Id];
        System.assertEquals(true, resultLead.IsConverted, 'The IsConverted field should be true after conversion.');
    }
}