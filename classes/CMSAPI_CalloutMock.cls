public class CMSAPI_CalloutMock implements HttpCalloutMock {
    
	public HTTPResponse respond(HTTPRequest req) {
        
        String endPoint = req.getEndpoint();
        system.debug('endPoint'+endPoint);
        HttpResponse response = new HttpResponse();
        String staticResourceName;
        system.debug(endPoint);
        //If its for the token api endpoint
        if (endPoint.contains('CMS_Token_API')) {
        	response.setBody('{"access_token": "testToken","token_type": "Bearer",  "expires_in": 7199}');
        } else if (endPoint.contains('CMS_Customer_API')) {
            //If the call is to fetch customer details
            staticResourceName = 'SampleCustomerAPIResponse';
        } else if (endPoint.contains('CMS_Contract_List_API')) {
            //If the call is to fetch contract list for a particular customer
            staticResourceName = 'SampleContractListAPIResponse';
        } else if (endPoint.contains('CMS_Contract_Detail_API')) {
            //If the call is to fetch contract detail for a particular contract
            staticResourceName = 'SampleContractDetailAPIResponse';
        } else if (endPoint.contains('InvoiceManagement')) {
            //If the call is to fetch contract detail for a particular contract
            staticResourceName = 'SampleInvoiceSearchAPIResponse';
        }
        if (staticResourceName!= null){
        	StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = :staticResourceName LIMIT 1];
        	response.setBody(sr.Body.toString());    
        }
        
        response.setStatusCode(200);
        return response;
        
    }
}