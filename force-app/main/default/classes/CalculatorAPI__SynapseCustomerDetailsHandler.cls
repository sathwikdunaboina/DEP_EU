global with sharing class SynapseCustomerDetailsHandler implements CalculatorAPI.ICustomerDetailsServiceHandler{
    
    global CalculatorAPI.CustomerDetailsWrapper getCustomerDetails(String siren,CalculatorAPI.CustomerDetailsWrapper wrapper, String countryCode, String accessToken,String brand,Synapse_Auth_Provider__mdt paymentDetails){
       String requestBody='{"CustomerDetailRequest": {"Header": {"MessageDateTime": "2016-01-12T17:17:25","MessageVersion": 2.5,"CallingSystem": "PriceManager","SourceSystems": { "SourceSystem": "SYNAPSE" },"CountryCode":"'+countrycode+'","MarketCode": "'+countrycode+'-'+brand+'","BusinessArea": "'+brand+'","CompanyId": "VFS LOCATION FRANCE SAS","UserId": "YFW0328"},"DetailRequest": {"CustomerId":"'+siren+'","CustomerNumber": '+siren+'}}}';
       HttpRequest req1 = new HttpRequest();
       HttpResponse res1 = new HttpResponse();
       Http http1 = new Http();         
       req1.setEndpoint('callout:SynapseAPI'+'/synapse/customercreditrating/CustomerDetail');
       String nameSpace = getNameSpace();
       if(String.isNotBlank(nameSpace)){
            req1.setEndpoint('callout:'+nameSpace+'__SynapseAPI'+'/synapse/customercreditrating/CustomerDetail');
       }
       req1.setMethod('POST');//accessToken
       req1.setHeader('Authorization', 'Bearer '+accessToken);
       req1.setHeader('Content-Type','application/json');
       
       req1.setHeader('X-Ibm-Client-Id',paymentDetails.Client_Id__c);
       req1.setHeader('X-Ibm-Client-Secret',paymentDetails.Client_Secret__c);
       req1.setTimeout( 120000 );
       req1.setBody(requestBody);
       res1 = http1.send(req1);
       System.debug('customerrequest'+res1.getStatusCode()+requestBody);
       
       if(res1.getStatusCode() == 200){
		string body = res1.getBody();
        System.debug('body is'+body);
        if(body.contains('<error>ConnectionError</error>')){
            wrapper.DetailResponse.ErrorOccured = 1;
        }else{
		wrapper=(CalculatorAPI.CustomerDetailsWrapper)JSON.deserialize(body,CalculatorAPI.CustomerDetailsWrapper.class);
		
        wrapper.countryName='France';
        }
	   }
        return wrapper;
    }

    global Map<String,Object> getCustomerCreditScore(String siren, String countryCode, String accessToken, String brand){
        System.debug('inside get customer');
       
        //System.debug('getCustomerCreditScore'+siren+countryCode+accessToken+brand);
        Synapse_Auth_Provider__mdt authDetails=[SELECT Access_Token_URL__c,Auth_Provider_Name__c,Client_Id__c,Client_Secret__c,DeveloperName,MasterLabel,Scope__c FROM Synapse_Auth_Provider__mdt where Auth_Provider_Name__c='Synapse Token'];
        Synapse_Auth_Provider__mdt paymentDetails=[SELECT Access_Token_URL__c,Auth_Provider_Name__c,Client_Id__c,Client_Secret__c,DeveloperName,MasterLabel,Scope__c FROM Synapse_Auth_Provider__mdt where Auth_Provider_Name__c='Monthly Payment'];
        String clientId=paymentDetails.Client_Id__c;
        String clientSecret=paymentDetails.Client_Secret__c;
       
        List<Account> acc=[Select id,Name,Phone,BillingPostalCode,BillingCity,BillingStreet,BillingCountry,CallingReferenceId__c,LastModifiedDate,Siret__c,Siren__c from Account where Siren__c=: siren OR Siret__c=: siren LIMIT 1];
        DateTime dt = DateTime.now();
        String referenceId= dt.format('MMddhhmmss');
        //System.debug('after CallingReferenceId__c='+acc[0].CallingReferenceId__c+clientId+' '+clientSecret);   //Get UniqueCallingReference Id to register new CallingReferenceId and Get Report2A response
        String strResp2B;
        String strResp2A;
        System.debug('accessToken'+accessToken);
       
		strResp2A = getReport2A(accessToken, siren, referenceId, countryCode, brand, clientId,clientSecret);
        System.debug('strResp2A'+strResp2A);
	    
        Map<String,Object> jsonParsedData =new Map<String,Object>();
        Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(strResp2A);  
        Object jsonMap1=jsonMap.get('GetReport2AResponse'); 
        Map<String,Object> rMap = (Map<String,Object>)jsonMap1;
        Map<String,Object> r1Map = (Map<String,Object>)rMap.get('Result');

       //  Map<String,Object> r1Map1 = (Map<String,Object>)rMap.get('Result');
       System.debug('2AResulterrorOccured='+r1Map.get('ErrorOccured'));
       try{
            if(r1Map.get('ErrorOccured')=='0'){
            Map<String,Object> jsonParsedData2A = parseGetReport2AResponseJSON(strResp2A,countryCode);
                System.debug('jsonParsedData2A'+jsonParsedData2A);
                System.debug('Error occured 2A='+jsonParsedData2A.get('ErrorOccured'));
                
                if((jsonParsedData2A.get('ErrorOccured') == '0') && (jsonParsedData2A.get('CreditRating')!=null) && (jsonParsedData2A.get('Cot. BDF')!=0)){  //if Cot .BDF!=0 then pass data to Bank of France
                    System.debug('inside cot bdf not 01');
                    jsonParsedData=jsonParsedData2A;
                }else if(jsonParsedData2A.get('Cot. BDF')==0 && (jsonParsedData2A.get('ErrorOccured') == 0) && (jsonParsedData2A.get('CreditRating')!=null) && (jsonParsedData2A.containsKey('Score @Rating'))){                   //if Cot .BDF=0 then pass data to Coface Rating
                    System.debug('inside cot bdf 0='+jsonParsedData2A.get('ErrorOccured')+((jsonParsedData2A.get('ErrorOccured') == 0) && (jsonParsedData2A.get('CreditRating')!=null) && (jsonParsedData2A.containsKey('Score @Rating'))));
                    jsonParsedData=jsonParsedData2A;
                 
                }else{
                    strResp2B = getReport2B(accessToken, siren, referenceId, countryCode, brand, clientId,clientSecret);
                    jsonParsedData = parseGetReport2BResponseJSON(strResp2B,countryCode); 
                }
            }
            else{
                    strResp2B = getReport2B(accessToken, siren, referenceId, countryCode, brand, clientId,clientSecret);
                    jsonParsedData = parseGetReport2BResponseJSON(strResp2B,countryCode); 
            }
            }catch(Exception e){
                    System.debug('Exception ='+e.getLineNumber()+e.getMessage());
            }
       return jsonParsedData; 
    }
	@TestVisible
    private static String getReport2A(String accessToken, String siren, String acc, String countryCode, String brand,String  clientId,String clientSecret){
        String requestBody2A = '{ "GetReport2ARequest": { "Header": { "MessageDateTime": "2016-01-12T17:34:15", "MessageVersion": 2.1, "CallingSystem": "PriceManager", "CallingReferenceId":"'+acc+'", "CountryCode": "'+countryCode+'", "BusinessArea":"'+ brand +'", "MarketCode": "'+countryCode+'-'+brand+'", "CompanyId": "SYSPERTEC COMMUNICATION", "UserId": "YFW0328"  },"Request": { "ReportId": "SYNAPSE", "ExternalCustomerId":'+siren+',"CustomerIsKnownByVFS": false,"CustomerHasGoodPaymentBehavior": true }}}';
  		System.debug('requestBody2A='+requestBody2A);
         HttpRequest req1 = new HttpRequest();
         HttpResponse res1 = new HttpResponse();
         Http http1 = new Http();         
         req1.setEndpoint('callout:SynapseAPI'+'/synapse/customercreditrating/GetReport2A');
         String nameSpace = getNameSpace();
         if(String.isNotBlank(nameSpace)){
            req1.setEndpoint('callout:'+nameSpace+'__SynapseAPI'+'/synapse/customercreditrating/GetReport2A');
         } 
         req1.setMethod('POST');
         req1.setHeader('Authorization', 'Bearer '+accessToken);
         req1.setHeader('Content-Type','application/json');
         req1.setHeader('X-Ibm-Client-Id', clientId);
         req1.setHeader('X-Ibm-Client-Secret', clientSecret);
         req1.setTimeout( 120000 );
         req1.setBody(requestBody2A);
         res1 = http1.send(req1);
         string strResp2A = res1.getBody();
         System.debug(res1.getStatusCode());
         System.debug('2AResponse='+strResp2A);
        
        return strResp2A;
    }

    public static string getNameSpace(){
         ApexClass cs =[select NamespacePrefix from ApexClass where Name =:'FinancePreApprovalController'];
         return cs.NamespacePrefix;
    }
	@TestVisible
    private static String getReport2B(String accessToken, String siren, String acc, String countryCode, String brand, String  clientId,String clientSecret){
        String requestBody2B = '{ "GetReport2BRequest": { "Header": { "MessageDateTime": "2016-01-12T17:34:15", "MessageVersion": 2.1, "CallingSystem": "PriceManager", "CallingReferenceId":"'+String.valueOf(acc)+'", "CountryCode": "'+countryCode+'", "BusinessArea":"'+ brand +'", "MarketCode": "'+countryCode+'-'+brand+'", "CompanyId": "SYSPERTEC COMMUNICATION", "UserId": "YFW0328"  },"Request": { "ReportId": "SYNAPSE", "ExternalCustomerId":'+siren+',"CustomerIsKnownByVFS": false,"CustomerHasGoodPaymentBehavior": true }}}';
                    System.debug('requestBody2B'+requestBody2B);
                    HttpRequest req2 = new HttpRequest();
                    HttpResponse res2 = new HttpResponse();
                    Http http2 = new Http();         
                    req2.setEndpoint('callout:SynapseAPI'+'/synapse/customercreditrating/GetReport2B');
                    String nameSpace = getNameSpace();
                    if(String.isNotBlank(nameSpace)){
                        req2.setEndpoint('callout:'+nameSpace+'__SynapseAPI'+'/synapse/customercreditrating/GetReport2B');
                    }
                    req2.setMethod('POST');
                    req2.setHeader('Authorization', 'Bearer '+accessToken);
                    req2.setHeader('Content-Type','application/json');
                    req2.setHeader('X-Ibm-Client-Id',clientId);
                    req2.setHeader('X-Ibm-Client-Secret',clientSecret);
                    req2.setTimeout( 120000 );
                    req2.setBody(requestBody2B);
                    res2 = http2.send(req2);
                    String strResp2B = res2.getBody();
                    System.debug('Report'+res2.getStatusCode());
                    System.debug('2BResponse='+strResp2B);
                
                
                 return strResp2B;
    }
    
    //Report2A response Parsing
    @TestVisible
	private static Map<String, Object> parseGetReport2AResponseJSON(String strResp, String countryCode){  
      	Map<string,Object> jsonParsedData = new Map<string,Object>();
		SynapseGetReport2AResponseJSON2Apex parsedJSON = SynapseGetReport2AResponseJSON2Apex.parse(strResp);
        if( Integer.valueOf(parsedJSON.GetReport2AResponse.Result.ErrorOccured) > 0){
			jsonParsedData.put( 'ErrorOccured' , parsedJSON.GetReport2AResponse.Result.ErrorOccured);
		}else{
            try{
                jsonParsedData.put( 'ErrorOccured' , parsedJSON.GetReport2AResponse.Result.ErrorOccured);
                jsonParsedData.put('ExternalCustomerId', parsedJSON.GetReport2AResponse.Result.Customer.ExternalCustomerId);
                jsonParsedData.put('MaxFinancedAmount', parsedJSON.GetReport2AResponse.Result.CreditInfo.MaxFinancedAmount);
                jsonParsedData.put('IsBlackListed', parsedJSON.GetReport2AResponse.Result.CreditInfo.IsBlackListed);
                jsonParsedData.put('MaxTerms', parsedJSON.GetReport2AResponse.Result.CreditInfo.MaxTerms);
                jsonParsedData.put('CreditRating', parsedJSON.GetReport2AResponse.Result.CreditInfo.CreditRating);
                for(SynapseGetReport2AResponseJSON2Apex.MinorField minorField : parsedJSON.GetReport2AResponse.Result.MinorFields.MinorField){
                    if(minorField.Name == 'Cot. BDF'){
                        jsonParsedData.put(minorField.Name, minorField.Value);
                    }
                    if(minorField.Name == 'Score @Rating'){
                        jsonParsedData.put(minorField.Name, minorField.Value);
                    }
                }
            }catch(Exception e){
                System.debug('2A parsing Error='+e.getLineNumber()+e.getMessage());
            }
        }
        jsonParsedData.put('Country', countryCode);
        System.debug('jsonParsedData 2A'+jsonParsedData);
        return jsonParsedData;
    }
    
    //Parse Report2B response
    @TestVisible
	private static Map<String, Object> parseGetReport2BResponseJSON(String strResp, String countryCode){  
      	Map<string,Object> jsonParsedData = new Map<string,Object>();
		SynapseGetReport2BResponseJSON2Apex parsedJSON = SynapseGetReport2BResponseJSON2Apex.parse(strResp);
        
        if( Integer.valueOf(parsedJSON.GetReport2BResponse.Result.ErrorOccured) > 0){
			jsonParsedData.put( 'ErrorOccured' , parsedJSON.GetReport2BResponse.Result.ErrorOccured);
		}else{
            try{
                jsonParsedData.put( 'ErrorOccured' , parsedJSON.GetReport2BResponse.Result.ErrorOccured);
                jsonParsedData.put('ExternalCustomerId', parsedJSON.GetReport2BResponse.Result.Customer.ExternalCustomerId);
                jsonParsedData.put('MaxFinancedAmount', parsedJSON.GetReport2BResponse.Result.CreditInfo.MaxFinancedAmount);
                jsonParsedData.put('IsBlackListed', parsedJSON.GetReport2BResponse.Result.CreditInfo.IsBlackListed);
                jsonParsedData.put('MaxTerms', parsedJSON.GetReport2BResponse.Result.CreditInfo.MaxTerms);
                jsonParsedData.put('CreditRating', parsedJSON.GetReport2BResponse.Result.CreditInfo.CreditRating);
                for(SynapseGetReport2BResponseJSON2Apex.MinorField minorField : parsedJSON.GetReport2BResponse.Result.MinorFields.MinorField){
                    if(minorField.Name == 'Cot. BDF'){
                        jsonParsedData.put(minorField.Name, minorField.Value);
                    }
                    if(minorField.Name == 'Score @Rating'){
                        jsonParsedData.put(minorField.Name, minorField.Value);  
                    }
                }
            }catch(Exception e){
               System.debug('2B parsing Error='+e.getLineNumber()+e.getMessage());
            }
        }
		jsonParsedData.put('Country', countryCode);
        System.debug('jsonParsedData 2B'+jsonParsedData);
		return jsonParsedData;
    }
    
}