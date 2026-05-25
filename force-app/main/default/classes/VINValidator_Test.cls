/* 
* -----------------------------------------------------------------------------------------
* Apex Class Name     VINValidator_Test
* @author             Sugapriya Vanjiyappan <sugapriya.vanjiyappan@consultant.volvo.com>
* @Created Date       19-05-2026
* @Used By            VINValidator
* ------------------------------------------------------------------------------------------
* @description        This class is used to test VINValidator Apex Class
* ------------------------------------------------------------------------------------------
*/
@isTest(SeeAllData=false)
private class VINValidator_Test {
    /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testValidEMEAVin
* @description     To Validate the Region
* ------------------------------------------------------------------------------------------------------
*/
    
    @isTest
    static void testValidEMEAVin() {
        List<String> vins = new List<String>{ 'WBA12345678901234' };
            List<VINValidator.VINResult> results = VINValidator.validateBulk(vins);
        System.assertEquals('EMEA', results[0].region);
        System.assertEquals(true, results[0].isValid);
    }
    
    /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testValidEMEAVin
* @description     To Validate the Length of VIN Number
* ------------------------------------------------------------------------------------------------------
*/
    @isTest
    static void testInvalidLength() {
        List<String> vins = new List<String>{ 'WBA123' };
            List<VINValidator.VINResult> results = VINValidator.validateBulk(vins);
        System.assertEquals(false, results[0].isValid);
    }
    
    /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testValidEMEAVin
* @description     To Validate if the VIN Contains the forbidden Characters
* ------------------------------------------------------------------------------------------------------
*/
    @isTest
    static void testForbiddenChars() {
        List<String> vins = new List<String>{ 'WBA1234O678901234' }; // O is forbidden
            List<VINValidator.VINResult> results = VINValidator.validateBulk(vins);
        System.assertEquals(false, results[0].isValid);
    }
    
    /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testValidEMEAVin
* @description     To Validate if the Contract have no VIN
* ------------------------------------------------------------------------------------------------------
*/
    @isTest
    static void testNullVin() {
        List<String> vins = new List<String>{ null };
            List<VINValidator.VINResult> results = VINValidator.validateBulk(vins);
        System.assertEquals(false, results[0].isValid);
    }
    
    /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testValidEMEAVin
* @description     To Validate the Bulk Load
* ------------------------------------------------------------------------------------------------------
*/
    @isTest
    static void testBulkLoad() {
        List<String> vins = new List<String>();
        for (Integer i = 0; i < 200; i++) {
            vins.add('WBA12345678901234');
        }
        List<VINValidator.VINResult> results = VINValidator.validateBulk(vins);
        System.assertEquals(200, results.size());
    }
}