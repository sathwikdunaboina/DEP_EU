/** 
 * ------------------------------------------------------------------------------------------------------------------------------
 * @Name:               VFSCORE_GlobalCustomerApiClient
 * @Author:             Infosys
 * @CreatedDate:        21st March 2024
 * @UsedBy:             VFSCORE_GlobalCustomerService
 * @SystemLayer: 
 * ------------------------------------------------------------------------------------------------------------------------------
 * @Description:        This class is reponsible for making the REST callout 
 * 
 * Additional Info:     
 * ------------------------------------------------------------------------------------------------------------------------------
 **/
public without sharing class VFSCORE_GlobalCustomerApiClient {

    public VFSCORE_GlobalCustomerService.ApiLog callApi(VFSCORE_GlobalCustomerService.addCustomer_Request objAddRequest) {

        VFSCORE_GlobalCustomerService.ApiLog objApiLog = new VFSCORE_GlobalCustomerService.ApiLog();
        objApiLog.objErrorLog = new VFSCORE_GlobalCustomerService.ErrorLog();
        httpresponse res;
        try {
            httpRequest request = new httpRequest();
            Integrtion_Parameter__mdt mdtIntegrationParameterFranceRental = Integrtion_Parameter__mdt.getInstance('France_Rental_Integration');
            request.setTimeout((Integer) mdtIntegrationParameterFranceRental.Timeout__c); // configurable
            request.setMethod(mdtIntegrationParameterFranceRental.Method_Name__c); // configurable
            String strUrlExtension = mdtIntegrationParameterFranceRental.URL1__c + objAddRequest.legalx2dentity + // URL1, URL2, URL3 - comment 
            mdtIntegrationParameterFranceRental.URL2__c + objAddRequest.customerId + mdtIntegrationParameterFranceRental.URL3__c;
            System.debug('>>> strUrlExtension = ' + strUrlExtension);
            request.setEndpoint('callout:CustomerAPI_NC' + strUrlExtension);
            System.debug('>>> objAddRequest.requestBody = ' + objAddRequest.requestBody);
            String reqBody = objAddRequest.requestBody;
            request.setBody(reqBody);

            http http = new http();
            res = http.send(request);
            System.debug('>>> res in VFSCORE_GlobalCustomerApiClient.callApi() = ' + res);
            System.debug('>>> res body = ' + res.getBody());

            objApiLog.apiResponse = res;

            if(res.getStatusCode() != 200) {

                objApiLog.objErrorLog.className = 'VFSCORE_GlobalCustomerApiClient';
                objApiLog.objErrorLog.errorMessage = res.getStatus();
                objApiLog.objErrorLog.statusCode = String.valueOf(res.getStatusCode());
                objApiLog.objErrorLog.lineNumber = res.getStatusCode();
                objApiLog.objErrorLog.methodName = 'callApi';
                objApiLog.objErrorLog.stackTrace = res.getStatus();
                objApiLog.objErrorLog.requestHeader = '';
                objApiLog.objErrorLog.actualRequest = objAddRequest.requestBody;
                objApiLog.objErrorLog.associatedRecord = objAddRequest.customerId;
            }
        } catch (Exception e) {
            objApiLog.objErrorLog.className = 'VFSCORE_GlobalCustomerApiClient'; objApiLog.objErrorLog.errorMessage = e.getMessage(); objApiLog.objErrorLog.statusCode = ''; 
            objApiLog.objErrorLog.lineNumber = e.getLineNumber(); objApiLog.objErrorLog.methodName = 'callApi'; objApiLog.objErrorLog.stackTrace = e.getStackTraceString();
            objApiLog.objErrorLog.requestHeader = ''; objApiLog.objErrorLog.actualRequest = objAddRequest.requestBody; objApiLog.objErrorLog.associatedRecord = objAddRequest.customerId;
        }
        return objApiLog;
    }
}