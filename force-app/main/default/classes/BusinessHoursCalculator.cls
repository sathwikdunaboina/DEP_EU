/*
* Subject : Class For Calaulating Business HOurs 
* Created by: Hari Vyas 
* Date: 18/03/2026, 
*
 * @description
 *  This class is created for a flow calculate Agent email response time , where it takes 
 * start time and end time and business hour record and gives the response in minutes 
 */


public class BusinessHoursCalculator {

    @InvocableMethod(label='Calculate Business Hours Difference')
    public static List<OutputWrapper> calculate(List<InputWrapper> inputs) {

        List<OutputWrapper> results = new List<OutputWrapper>();

        for(InputWrapper input : inputs){

            Long diff = BusinessHours.diff(
                input.businessHoursId,
                input.startTime,
                input.endTime
            );

            OutputWrapper output = new OutputWrapper();
            output.minutes = diff / 60000;

            results.add(output);
             System.debug('This is business hours id '+input.businessHoursId);
                System.debug('This is Start hours id '+input.startTime);
        System.debug('This is end hours id '+input.endTime);
        }
        
       

        
       System.debug('This is result '+results);
        return results;
    }

    public class InputWrapper {

        @InvocableVariable(required=true)
        public Id businessHoursId;

        @InvocableVariable(required=true)
        public Datetime startTime;

        @InvocableVariable(required=true)
        public Datetime endTime;

    }

    public class OutputWrapper {

        @InvocableVariable
        public Decimal minutes;

    }
}