public class QuoteController {
   
    @AuraEnabled
    public static Map<String,String> getResponseData(String recordId){
      Map<String,String> result = new Map<String,String>();

        System.debug('oppId => '+recordId);
       
        if(String.isBlank(recordId)){
           result.put('error','No valid Opportunity id passed.');
        }
       
        List<Opportunity> oppRecord = [Select Id,Name,Account.CustomerID__c,Account.Name from Opportunity where Id =: recordId];
        System.debug('oppRecord =>'+oppRecord);
       
        if(oppRecord == null || oppRecord.isEmpty() || String.isBlank(oppRecord[0].Account.CustomerID__c)){
           result.put('error','Invalid Customer ID on Account.');
        }
       
        String resdata = getQuoteFromVFS(oppRecord[0].Account.CustomerID__c);
        System.debug('resdata =>'+resdata);
        //return resdata;//JSON.serialize(resdata)
        result.put('resdata',resdata);
        return result;
    }
   
    public static String getQuoteFromVFS(String customerId){//String body
        integer statusCode;
        String token = generateToken();
        String params= '{ "CustomerID":'+ customerId +'}';
        System.debug('token ===>>'+token);
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://AP24.salesforce.com/services/apexrest/AccessQuote');
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + token);
        req.setHeader('Content-Type', 'application/json');
        req.setBody(params);
        HttpResponse response = h.send(req);
        System.debug('responseBody =>'+response.getBody());
        String strResponse = response.getBody();
        statusCode = response.getStatusCode();
       
        return strResponse;
    }
   
    public static String generateToken(){
        String token;
        //Education_Event_Settings__c e = settingRecord('Docebo Token');
        String clientKey = '3MVG9fe4g9fhX0E7YSXj1m4lNxs0VJVFU5EFP4gNa0v.QwwQppAG7or6Wz25zbZaXX7Cqrm9dEYaAoGTAHLnj';
        String clientSecret = 'F4F5949AB95F49CAF45601E6F6A33204CF83B22D409147FE423F17F3ED2C12EA';
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://login.salesforce.com/services/oauth2/token');
        req.setMethod('POST');
        //req.setTimeout(setTime);
        req.setBody('username='+'data.destination1@gmail.com'+'&password='+'Lovely1234MGQaNZXZYld3zEw1tGenhQf4'+'&grant_type='+'password'+'&client_id='+clientKey+'&client_secret='+clientSecret);
        HttpResponse response = h.send(req);
        System.debug('Status Code=>'+response.getStatusCode());
        if (response.getStatusCode() == 200) {
            Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            token = (String)results.get('access_token');
            system.debug('token => '+token);
        }
        return token;
    }
   
    @AuraEnabled
    public static void updateQuote(String recordId,String quoteNumber){
        System.debug('recordId =>>>'+recordId);
        Opportunity opp = new Opportunity();
        opp.Id = recordId;
        opp.Quote_Id__c = quoteNumber;
        Update opp;
    }
    public class QuoteControllerException extends Exception{}
}