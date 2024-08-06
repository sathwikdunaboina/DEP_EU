/**
* @author Hari
* @date June 2022
* @description Test class for C3S_CMP44_EmailPdfController
* @group Tests
*/
@isTest
public class EmailPdfControllerTest {
	
    @isTest
    public static void getURLTest () {
        // Call fonction
        String domaine = EmailPdfController.getURL();
        
        // Test
        System.assertEquals(System.Url.getSalesforceBaseUrl().toExternalForm(), domaine);
    }
    
}