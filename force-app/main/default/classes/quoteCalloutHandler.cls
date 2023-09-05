/*
* Subject: 1 quote for multiple Opportunities handler
* Created by: Aswin balaji
* Date: 29/08/2022, 15:33
* Description: Call the API and will receive the response of quote id and url. Updating the all selected Opportunites
* */   
public with sharing class quoteCalloutHandler {
    public static Boolean isTestClass = false;
    @AuraEnabled(cacheable=true)
    public static List<String> fetchFromAPIForQuote(List<String> oppIds) {
        //System.debug('This is the id' + oppIds);

        List<Opportunity> oppList = [SELECT Id, description, Quote_Id__c, Quote_Url__c, Amount, Factory_Order__c, Account.Name,
            Account.BillingCountryCode, Account.Customer_Number__c, Quote_Unique_Id__c, 
            Factory_Order__r.Assembly_Factory_Code__c, Factory_Order__r.Assembly_Factory_Name__c, Factory_Order__r.Axle_Arrangement__c,	
            Factory_Order__r.Brand__c, Factory_Order__r.CDD_Date__c, Factory_Order__r.Chassis_Type__c, Factory_Order__r.Contact_Last_Name__c,
            Factory_Order__r.Country__c, Factory_Order__r.CreatedById, Factory_Order__r.CurrencyIsoCode, Factory_Order__r.Dealer_Id__c,
            Factory_Order__r.Dealer_Number__c, Factory_Order__r.Dis_Status_Code__c, Factory_Order__r.End_Customer_Address1__c,
            Factory_Order__r.End_Customer_City__c, Factory_Order__r.End_Customer_Name__c, Factory_Order__r.End_Customer_Phone__c,
            Factory_Order__r.End_Customer_Postal_Code__c, Factory_Order__r.Engine_Version__c, Factory_Order__r.Name, 
            Factory_Order__r.FO_Registration_Date__c, Factory_Order__r.HP__c, Factory_Order__r.Main_Dealer_Name__c, Factory_Order__r.Market_Type_1_5__c,
            Factory_Order__r.Order_Id__c, Factory_Order__r.Order_Status_Description__c, Factory_Order__r.Sales_Person_Name__c, Factory_Order__r.Serial__c,
            Factory_Order__r.T_Chassis__c, Factory_Order__r.Vehicle_Status__c, Factory_Order__r.VIN_Number__c
            FROM Opportunity WHERE Id = :oppIds];

        List<String> resultList = new List<String>();
        
        List<String> validationResults = validateQuote(oppList);

        // exit on any validation issue
        if (validationResults.size() > 0) {
            //System.debug('Errors found. Exiting...');
            resultList = validationResults;
            return resultList;
        }
        
        // Generate an unique identifier as a reference for the quote
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,6) + oppList[0].Account.Customer_Number__c;

        quoteWrapperClass.wrapperClass quote = buildQuote(oppList, guid);
        
        HttpResponse response = sendQuote(quote);
        
        if (response != null && response.getStatusCode() == 200)
        {
            try{
                Map<String, String> values = (Map<String, String>)
                    JSON.deserialize(response.getBody(), Map<String, String>.class);
                
                String success = values.get('success');
                String quoteId = values.get('quoteId');          
                String vfsConnectQuoteURL = values.get('vfsConnectQuoteURL');
                
                //System.debug('HttpResponse was: ' + success);
                //System.debug('QuoteId: ' + quoteId);
                //System.debug('Request to: ' + vfsConnectQuoteURL);
                
                List <Opportunity> oppListUpt = new List<Opportunity>();
                
                // Create the quote and update the opportunities with it
                Id QuoteReferenceRecordId = quoteRecordCreate(oppList[0], quoteId, guid).Id;
                //System.debug('QuoteReferenceRecordId: ' + QuoteReferenceRecordId);
                
                for (Opportunity opp : oppList) {
                    opp.Quote_Id__c = quoteId;
                    opp.Quote_Url__c = vfsConnectQuoteURL;
                    opp.Quote_Unique_Id__c = guid;
                    opp.StageName = 'Quoted';
                    opp.VFS_Connect_Quote_Ref__c = QuoteReferenceRecordId;
                    oppListUpt.add(opp);
                }
                
                update oppListUpt;
                
                if(success == 'true'){
                    resultList.add('Quote created successfully');
                }
            }
            catch (Exception e) {
                //System.debug('The following exception has occurred: Try ' + e.getMessage()+'==+ :' + resultList);
                resultList.add(e.getMessage());
            }
        }
        else
        {
            try {
                Map<String, String> values = (Map<String, String>) JSON.deserialize(response.getBody(), Map<String, String>.class);
                String Error = values.get('errorMessage');
                Error += '; '+ values.get('message') == null ? '' : values.get('message');
                //System.debug('This is the error Msg: ' + Error);      
                resultList.add(Error);
                //System.debug(resultList);
            }
            catch (Exception e) {
                Boolean result = e.getMessage().contains('Unexpected character');
                if(result){
                    resultList.add('Cannot pass the security checks that are required by the target API or operation. Please try again later!');
                }
                else {
                    resultList.add(e.getMessage()); 
                }
            }
        }
        
		//System.debug(resultList);
        return resultList;
    }
    
    private static VFS_Connect_Quote__c quoteRecordCreate(Opportunity oppList,String quoteNumber,String uniqueId){
        VFS_Connect_Quote__c vfsConnectQuote = new VFS_Connect_Quote__c();
        vfsConnectQuote.Account_CMS_Number__c = oppList.Account.Customer_Number__c;
        vfsConnectQuote.Quote_Number__c = quoteNumber;
        vfsConnectQuote.Quote_Unique_Id__c = uniqueId;
        vfsConnectQuote.Name = quoteNumber;
        vfsConnectQuote.Quote_Status__c = 'In-Complete';
        insert vfsConnectQuote;
        return vfsConnectQuote;
    }

    private static HttpResponse sendQuote(quoteWrapperClass.wrapperClass quote) {
        CMSAPI1__c settings = CMSAPI1__c.getOrgDefaults();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('{!Environment.VFS_Global_API Endpoint Named Credentials}' + settings.Endpoint_QA__c);
        request.setMethod('POST');
        request.setHeader('X-Ibm-Client-Id', settings.X_Ibm_Client_Id__c);
        request.setHeader('X-Ibm-Client-Secret', settings.X_Ibm_Client_Secret__c);
        request.setHeader('Content-Type', 'application/json; charset=utf-8');
        request.setHeader('Service-Id', 'SRV25720');

        String jsonQuote = json.serialize(quote);
        request.setBody(jsonQuote);

        //System.debug('Json View: ' + jsonQuote);
        //System.debug('The request body is: ' + request.getBody());
        //System.debug('This is request: ' + request);

        request.setTimeout(120000);

        //System.debug('Sending request...');
        HttpResponse response = http.send(request);
        //System.debug('HttpResponse code: ' + response.getStatusCode());
        //System.debug('HttpResponse body: ' + response.getBody());

        return response;
    }

    private static String getUserFederation() {
        //New Addition Date 19th May
        String UserName1 = UserInfo.getUserName();//Returns the context user's login name.

        //System.debug('UserName-' + UserName1);

        User userObj = [SELECT Id,FederationIdentifier FROM User WHERE Username = :UserName1][0];
        String userFederationID = userObj.FederationIdentifier;

        //System.debug('This is user Federation id: ' + userFederationID);

        return userFederationID;
    }

    private static List<String> validateQuote(List<Opportunity> oppList) {
        List<String> errorList = new List<String>();

        if (oppList.size() < 1) {
            errorList.add('You need opportunies in order to create a quote');
        }

        for(Opportunity opp : oppList) {
            List<String> requiredFields = new List<String>();

            if (!String.isBlank(opp.Quote_Id__c)) {
                errorList.add('Quote already created for opportunity ' + opp.Id);
            }
            if (opp.Amount == null || opp.Amount == 0) {
                errorList.add('Opportunity, ' + opp.Id + ', needs an amount');
            }
            if (String.isBlank(opp.Factory_Order__r.Country__c)) {
                requiredFields.add('Country');
            }
            if (String.isBlank(opp.Factory_Order__r.Brand__c)) {
                requiredFields.add('Brand');
            }
            if (String.isBlank(opp.Factory_Order__r.CurrencyIsoCode)) {
                requiredFields.add('Currency');
            }
            if (String.isBlank(opp.Factory_Order__r.End_Customer_Name__c)) {
                requiredFields.add('Customer');
            }
            if (String.isBlank(opp.Factory_Order__r.Main_Dealer_Name__c)) {
                requiredFields.add('Dealer');
            }
            
            //System.debug(requiredFields);

            if (requiredFields.size() > 0) {
                string fields = string.join(requiredFields,',');
                errorList.add('You need values for fields ' + fields + ', on Factory Order (' + opp.Factory_Order__r.Assembly_Factory_Code__c + ')');
            }
        }

        // This might be useful to keep to see if any errors occurred
        if (errorList.size() > 0) {
            System.debug('Invalid');
            System.debug(errorList);
        }

        return errorList;   
    }

    private static quoteWrapperClass.wrapperClass buildQuote(List<Opportunity> oppList, String guid) {
        quoteWrapperClass.wrapperClass quotewrap = new quoteWrapperClass.wrapperClass();
        quoteWrapperClass.dealer dealer = new quoteWrapperClass.dealer();
        quoteWrapperClass.customer customer = new quoteWrapperClass.customer();

        Opportunity firstOpp = oppList[0];
        //System.debug('This is the id: ' + firstOpp.Id);

        //wrapper class-----------------------------------------------------------
       	quotewrap.externalId = guid;
        // the country code on the code needs to be as per Dealer
        quotewrap.countryCode = firstOpp.Factory_Order__r.Country__c;
        quotewrap.brand = firstOpp.Factory_Order__r.Brand__c;

        User ownerObj = [SELECT FederationIdentifier, Id FROM User WHERE Id in (SELECT OwnerId FROM Opportunity WHERE Id = :firstOpp.Id)][0];
        quotewrap.owner = ownerObj.FederationIdentifier;

        quotewrap.requestedBy = getUserFederation();
        quotewrap.Source = 'Sales Connect';
        quotewrap.version = '2';
        //System.debug('quotewrap: '+ quotewrap);
        List<quoteWrapperClass.order> quoteorder = new List<quoteWrapperClass.order>();

        for(Opportunity opp : oppList){
            quoteWrapperClass.order order = new quoteWrapperClass.order();
            quoteWrapperClass.financials financials = new quoteWrapperClass.financials();
            quoteWrapperClass.asset assetwrap = new quoteWrapperClass.asset();
            order.OpportunityId = opp.Id;
            assetwrap.axleArrangement = opp.Factory_Order__r.Axle_Arrangement__c;
            assetwrap.chassisType = opp.Factory_Order__r.Chassis_Type__c;
            assetwrap.engineVersion = opp.Factory_Order__r.Engine_Version__c;
            assetwrap.VINNumber = opp.Factory_Order__r.VIN_Number__c;
            assetwrap.tChassis = opp.Factory_Order__r.T_Chassis__c;
            assetwrap.marketType = opp.Factory_Order__r.Market_Type_1_5__c;
            assetwrap.assemblyFactoryCode = opp.Factory_Order__r.Assembly_Factory_Code__c;
            assetwrap.assemblyFactoryName = opp.Factory_Order__r.Assembly_Factory_Name__c; 
            financials.amount = String.valueOf(opp.Amount.longValue());
            financials.currencyCode = opp.Factory_Order__r.CurrencyIsoCode;
            order.Orderid = opp.Factory_Order__r.Order_Id__c;
            order.orderNumber = opp.Factory_Order__r.Dealer_Number__c;
            order.statusDescription = opp.Factory_Order__r.Order_Status_Description__c;
            order.registrationDate = string.valueofGmt(opp.Factory_Order__r.FO_Registration_Date__c);
            order.cddDate = string.valueofGmt(opp.Factory_Order__r.CDD_Date__c);
            order.disStatusCode = opp.Factory_Order__r.Dis_Status_Code__c;
            //System.debug('assetwrap: ' + assetwrap);	
            //System.debug('order: ' + order);
            order.financials = financials;
            order.asset = assetwrap;
            quoteorder.add(order);
            //System.debug('assetwrap: ' + quoteorder);
            //System.debug('quotewrap.asset: ' + quoteorder);
        }

        quotewrap.order = quoteorder;
        //System.debug('quotewrap.asset: '+quotewrap.order);

        dealer.id = firstOpp.Factory_Order__r.Dealer_Id__c;
        //currently it is in number but it was not used now because identifier error is causing so changed to dealer number
        dealer.dealerNumber = firstOpp.Factory_Order__r.Dealer_Number__c;
        dealer.mainDealerName = firstOpp.Factory_Order__r.Main_Dealer_Name__c;
        dealer.salesPersonName = firstOpp.Factory_Order__r.Sales_Person_Name__c;
        //System.debug('dealer: ' + dealer);

        customer.name = firstOpp.Factory_Order__r.End_Customer_Name__c;
        customer.address = firstOpp.Factory_Order__r.End_Customer_Address1__c;
        customer.phone = firstOpp.Factory_Order__r.End_Customer_Phone__c;
        customer.city = firstOpp.Factory_Order__r.End_Customer_City__c;
        customer.postalCode = firstOpp.Factory_Order__r.End_Customer_Postal_Code__c;
        customer.countryCode = firstOpp.Account.BillingCountryCode;

        Account accObj = [SELECT Name, Customer_Number__c FROM Account WHERE Id in (SELECT AccountID FROM Opportunity WHERE Id = :firstOpp.Id)][0];
        customer.CMS_ID = accObj.Customer_Number__c;

        //System.debug('customer: ' + customer);

        quotewrap.dealer = dealer;
        quotewrap.customer = customer;
        //System.debug('lstwrapeer: ' + quotewrap);

        return quotewrap;
    }
}