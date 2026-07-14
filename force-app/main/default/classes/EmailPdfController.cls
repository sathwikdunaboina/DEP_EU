/**
* @author Hari
* @date June 2022
* @description Use by EmailPDF
* @group Lightning
*/
public with sharing class EmailPdfController {

    /**
    * @author Hari
	* @date June 2022
    * @description Get the URL
    * @return String of domain name
    */
    @AuraEnabled
    public static String getURL () {
        return System.Url.getSalesforceBaseUrl().toExternalForm();
    }
}