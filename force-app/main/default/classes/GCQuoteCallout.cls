/**
 * Contains methods to call Quote API and fetch Quote records in SF.
 * 
 * @author @author matei.lunca@fluidogroup.com 2022-07-28 changed objects, added wrappers, ErrorLog, formatting
 * @author VFS original pre 2022-07
 */
public with sharing class GCQuoteCallout {
    
	@InvocableMethod (label='createQuoteNew' description='This fetches Quotes from backend CMS')
    public static List<String> fetchInvoicesFromAPIForQuote(List<String> oppIds) {
		String runningUserName = UserInfo.getUserName();
        System.Debug('UserName-' + runningUserName);
        List<User> userObj = [SELECT FederationIdentifier FROM User WHERE Username = :runningUserName];
        String userFederationID = userObj[0].FederationIdentifier;
        System.debug('User Federation id = ' + userFederationID);
        System.debug('oppIds = ' + oppIds.get(0));
        List<Opportunity> opps = OpportunityWrapper.getOpportunities(oppIds);

        system.debug('This is the list'+opps[0].Account.BillingCountryCode);
        List<FactoryOrder__c> foList = FactoryOrderWrapper.getOrdersByOpportunity(opps);
        FactoryOrder__c fo = foList[0];

		for(FactoryOrderWrapper foObj : FactoryOrderWrapper.wrapList(foList)){
			System.debug('FactoryOrder: ' + foObj.toPrettyPrintString());
		}

        List<User> ownerObj = [SELECT FederationIdentifier FROM User WHERE Id IN (SELECT OwnerId FROM Opportunity WHERE Id = :oppIds.get(0))];
        List<Account> accObj = [SELECT Name, CustomerID__c FROM Account WHERE Id IN (SELECT AccountID FROM Opportunity WHERE Id = :oppIds.get(0))];
        string customerCmsId = accObj[0].CustomerID__c == null ? null : accObj[0].CustomerID__c.substringAfter('-');

        Map<String, Object> newObj = new Map<String, Object>();
        newObj.put('externalId', opps[0].Id);
        newObj.put('countryCode', opps[0].Account.BillingCountryCode);
        newObj.put('brand', fo.Brand__c);
        newObj.put('owner', ownerObj[0].FederationIdentifier);
        newObj.put('requestedBy', userFederationID);
        newObj.put('source','Sales Connect');

        Map<String, String> orderObj = new Map<String, String>();
        orderObj.put('id', fo.DealerId__c);
        orderObj.put('number', fo.DealerNumber__c);
        orderObj.put('statusDescription', fo.OrderStatusDescription__c);
        orderObj.put('registrationDate', string.valueofGmt(fo.FORegistrationDate__c));
        orderObj.put('cddDate', string.valueofGmt(fo.CDDDate__c));
        orderObj.put('disStatusCode', fo.DisStatusCode__c);
        newObj.put('order', orderObj);

        Map<String, String> custObj = new Map<String, String>();
        custObj.put('name', fo.EndCustomerName__c);
        custObj.put('address', fo.EndCustomerAddress1__c);
        custObj.put('phone', fo.EndCustomerPhone__c);
        custObj.put('city', fo.EndCustomerCity__c);
        custObj.put('postalCode', fo.EndCustomerPostalCode__c);
        custObj.put('countryCode', opps[0].Account.BillingCountryCode);
        custObj.put('CMS_ID', customerCmsId);
        newObj.put('customer', custObj);
        
		Map<String, String> objDeal = new Map<String, String>();
        objDeal.put('id', fo.DealerId__c);
        objDeal.put('number', fo.DealerNumber__c);
        objDeal.put('mainDealerName', fo.MainDealerName__c);
        objDeal.put('salesPersonName', fo.SalesPersonName__c);
        newObj.put('dealer',objDeal);
        
		Map<String, String> objAsse = new Map<String, String>();
        objAsse.put('axleArrangement', fo.AxleArrangement__c);
        objAsse.put('chassisType', fo.ChassisType__c);
        objAsse.put('engineVersion', fo.EngineVersion__c);
        objAsse.put('VINNumber', fo.VINNumber__c);
        objAsse.put('tChassis', fo.TChassis__c);
        objAsse.put('marketType', fo.MarketType15__c);
        objAsse.put('assemblyFactoryCode', fo.AssemblyFactoryCode__c);
        objAsse.put('assemblyFactoryName', fo.AssemblyFactoryName__c);
        newObj.put('asset', objAsse);
        
		Map<String, String> objFin = new Map<String, String>();
        objFin.put('amount', String.valueOf(opps[0].Amount.intvalue()));
        objFin.put('currencyCode', fo.CurrencyIsoCode);
        newObj.put('financials', objFin);
 
		//execute request-response
		HttpResponse response = sendfetchInvoicesRequest('callout:VFS_Global_APIs' + '/vfsconnect/quotation/v1.0/draft',
														'POST', JSON.serialize(newObj));
        
        List<String> requestResults = new List<String>();
        if(response.getStatusCode() == 200) {
            Map<String, String> values = (Map<String, String>)
            JSON.deserialize(response.getBody(), Map<String, String>.class);
            String quoteId = values.get('quoteId');
            
            String vfsConnectQuoteURL = values.get('vfsConnectQuoteURL');
            
            System.debug('This is success'+values.get('success'));
            System.debug('This is quoteId'+quoteId);
            system.debug('Thi is url'+vfsConnectQuoteURL);
            
            List<Opportunity> oppsUpdate = new List<Opportunity>();
            for (Opportunity o : opps) {
                o.QuoteId__c = quoteId;
                o.QuoteURL__c = vfsConnectQuoteURL;
                oppsUpdate.add(o);
            }
            update oppsUpdate;
            return requestResults;
        }   
        else {
            Map<String, String> errorValues = (Map<String, String>) JSON.deserialize(response.getBody(), Map<String, String>.class);
            String errorString = errorValues.get('errorMessage');
            System.debug('This is the error Msg: ' + errorString);
            system.debug('This is else');
            requestResults.add(errorString);

			GCErrorLogUtil.createErrorLog('GCQuoteCallout', 'Request error', null, null, 'fetchInvoicesFromAPIForQuote', errorString, null, null, '' + opps.get(0).Id);

            return requestResults;
        }
	}

	static HttpResponse sendfetchInvoicesRequest(String endpoint, String method, String body){
		//TODO move to GC settings
        //CMSAPI__c settings = CMSAPI_SettingsManager.get();
        CMSAPI1__c settings = CMSAPI1__c.getOrgDefaults();

        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod(method);
        request.setHeader('X-Ibm-Client-Id', settings.X_Ibm_Client_Id__c);
        request.setHeader('X-Ibm-Client-Secret', settings.X_Ibm_Client_Secret__c);
        request.setHeader('Content-Type', 'application/json; charset=utf-8');
        request.setHeader('Service-Id', 'SRV25720');

		//request.setHeader('Accept-Encoding', 'gzip,deflate');
        //request.setHeader('content-type', 'text/xml; charset=utf-8');
        //request.setHeader('Content-Length', String.valueOf(body.length()));
        request.setBody(body);
        System.debug('Request body: ' + request.getBody());
        System.debug('Request: ' + request);
        request.setTimeout(20000);

		HttpResponse response = new Http().send(request);
        //response.setTimeout(40000);
        System.debug('This is body code'+response.getStatusCode());
        System.debug('This is body body'+response.getBody());

		return response;
	}
}