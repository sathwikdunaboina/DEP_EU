/*
* Subject : Test class for BusinessHoursCalculator
* Created by: Hari Vyas 
* Date: 18/03/2026, 

 */


@IsTest
private class BusinessHoursCalculatorTest {

    @IsTest
    static void testCalculateBusinessHours() {

        // Get existing Business Hours
        BusinessHours bh = [SELECT Id FROM BusinessHours LIMIT 1];

        // Create input wrapper
        BusinessHoursCalculator.InputWrapper input = new BusinessHoursCalculator.InputWrapper();
        input.businessHoursId = bh.Id;
        input.startTime = Datetime.newInstance(2026, 3, 10, 16, 38, 0);
        input.endTime = Datetime.newInstance(2026, 3, 11, 8, 38, 0);

        List<BusinessHoursCalculator.InputWrapper> inputs = new List<BusinessHoursCalculator.InputWrapper>();
        inputs.add(input);

        Test.startTest();
        List<BusinessHoursCalculator.OutputWrapper> results =
            BusinessHoursCalculator.calculate(inputs);
        Test.stopTest();

        // Assertions
        System.assertEquals(1, results.size(), 'One result should be returned');
        System.assertNotEquals(null, results[0].minutes, 'Minutes should not be null');

        System.debug('Calculated minutes: ' + results[0].minutes);
    }
}