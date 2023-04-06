/*
* Subject: 1 quote for multiple Opportunities handler
* Created by: Aswin balaji
* Date: 29/08/2022, 15:33
* Description: Call the API and will receive the response of quote id and url. Updating the all selected Opportunites
* */   
public with sharing  class quoteCalloutHandler {
    @AuraEnabled(cacheable=true)
    public static List<String> fetchFromAPIForQuote( List<String> oppIds){
        //New Addition Date 19th May
        String UserName1 = UserInfo.getUserName();//Returns the context user's login name.
        System.Debug('UserName-' + UserName1);
        List<User> userObj =new List<User>();
        userObj =  [SELECT Id,FederationIdentifier FROM User WHERE Username = : UserName1 ];
        String userFederationID=userObj[0].FederationIdentifier;
        System.debug('This is user Federation id'+userFederationID);
        System.debug('This is the id'+oppIds);
        System.debug('This is the id'+oppIds.get(0));
        List<Opportunity> oppList=new List<Opportunity>();
        List<Opportunity> oppList1=new List<Opportunity>();
        List<Opportunity> oppListAll=new List<Opportunity>();
        quoteWrapperClass.wrapperClass quotewrap = new quoteWrapperClass.wrapperClass();
        //quoteWrapperClass.asset assetwrap = new quoteWrapperClass.asset();
        quoteWrapperClass.dealer dealer = new quoteWrapperClass.dealer();
        quoteWrapperClass.customer customer = new quoteWrapperClass.customer();
        //quoteWrapperClass.order order = new quoteWrapperClass.order();
        //quoteWrapperClass.financials financials = new quoteWrapperClass.financials();
        List<String> foIds = new List<String>();
        oppList =[Select Id,Amount ,Factory_Order__c,Account.Name ,Account.BillingCountryCode,Account.Customer_Number__c from Opportunity where Id = : oppIds.get(0)];
        oppListAll =[Select Id,Amount ,Factory_Order__c,Account.Name ,Account.BillingCountryCode,Quote_Unique_Id__c from Opportunity where Id IN : oppIds];
        for(Opportunity factoryOrderIds : oppListAll){
            foIds.add(factoryOrderIds.Id);
        }
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,6)+oppList[0].Account.Customer_Number__c;
        System.debug('foIds'+foIds);
        oppList1 =[Select Id,description,Quote_Id__c,Quote_Url__c from Opportunity where Id =  : oppIds];
        String foId = oppList[0].Factory_Order__c;
        system.debug('This is the list'+oppList[0].Account.BillingCountryCode);
        List<Factory_Order__c> foList=new List<Factory_Order__c>();
        List<Factory_Order__c> foListAll=new List<Factory_Order__c>();
        
        foList=[select Assembly_Factory_Code__c,Assembly_Factory_Name__c,Axle_Arrangement__c,	
                Brand__c,CDD_Date__c,Chassis_Type__c,Contact_Last_Name__c,Country__c,		
                CreatedById,CurrencyIsoCode,Dealer_Id__c,Dealer_Number__c,		 
                Dis_Status_Code__c,End_Customer_Address1__c,End_Customer_City__c,
                End_Customer_Name__c,End_Customer_Phone__c,End_Customer_Postal_Code__c,	
                Engine_Version__c,Name,	FO_Registration_Date__c	,HP__c,Main_Dealer_Name__c,	
                Market_Type_1_5__c,Order_Id__c,Order_Status_Description__c,Sales_Person_Name__c,
                Serial__c,T_Chassis__c,	Vehicle_Status__c,VIN_Number__c	from Factory_Order__c
                where Id = : oppList[0].Factory_Order__c ];
        
        System.debug('This is FO details'+foList);
        system.debug('This is 1st element '+foList[0].Assembly_Factory_Code__c);
        List<User> ownerObj =new List<User>();
        ownerObj = [SELECT FederationIdentifier, Id FROM User WHERE Id in (SELECT OwnerId FROM Opportunity WHERE Id = :oppIds.get(0))];
        List<Account> accObj = new List<Account>();
        accObj = [SELECT Name, Customer_Number__c FROM Account WHERE Id in (SELECT AccountID FROM Opportunity WHERE Id = :oppIds.get(0))];
        string customerCmsId = accObj[0].Customer_Number__c;
        //wrapper class-----------------------------------------------------------
       	quotewrap.externalId = guid; 
        quotewrap.countryCode = oppList[0].Account.BillingCountryCode;
        quotewrap.brand = foList[0].Brand__c;
        quotewrap.owner = ownerObj[0].FederationIdentifier;
        quotewrap.requestedBy = userFederationID;
        quotewrap.Source = 'Sales Connect';
        quotewrap.version = '2';
        System.debug('quotewrap: '+quotewrap);
        List<quoteWrapperClass.order> quoteorder = new List<quoteWrapperClass.order>();
        //quoteWrapperClass.order quoteOrder= new quoteWrapperClass.order();
        for(Opportunity foFetchList : [select Id,Amount,Name,Factory_Order__r.Assembly_Factory_Code__c,Factory_Order__r.Assembly_Factory_Name__c,Factory_Order__r.Axle_Arrangement__c,Factory_Order__r.Brand__c,Factory_Order__r.CDD_Date__c,Factory_Order__r.Chassis_Type__c,Factory_Order__r.Contact_Last_Name__c,Factory_Order__r.Country__c,Factory_Order__r.CurrencyIsoCode,Factory_Order__r.Dealer_Id__c,Factory_Order__r.Dealer_Number__c,Factory_Order__r.Dis_Status_Code__c,Factory_Order__r.End_Customer_Address1__c,Factory_Order__r.End_Customer_City__c,Factory_Order__r.End_Customer_Name__c,Factory_Order__r.End_Customer_Phone__c,Factory_Order__r.End_Customer_Postal_Code__c,Factory_Order__r.Engine_Version__c,Factory_Order__r.Name,Factory_Order__r.FO_Registration_Date__c,Factory_Order__r.HP__c,Factory_Order__r.Main_Dealer_Name__c,Factory_Order__r.Market_Type_1_5__c,Factory_Order__r.Order_Id__c,Factory_Order__r.Order_Status_Description__c,Factory_Order__r.Sales_Person_Name__c,Factory_Order__r.Serial__c,Factory_Order__r.T_Chassis__c,Factory_Order__r.Vehicle_Status__c,Factory_Order__r.VIN_Number__c from Opportunity where Id IN: oppIds]){
                                                quoteWrapperClass.order order = new quoteWrapperClass.order();
        										quoteWrapperClass.financials financials = new quoteWrapperClass.financials();
            									quoteWrapperClass.asset assetwrap = new quoteWrapperClass.asset();
            									order.OpportunityId = foFetchList.Id;
            									assetwrap.axleArrangement = foFetchList.Factory_Order__r.Axle_Arrangement__c;
                                                assetwrap.chassisType = foFetchList.Factory_Order__r.Chassis_Type__c;
                                                assetwrap.engineVersion = foFetchList.Factory_Order__r.Engine_Version__c;
                                                assetwrap.VINNumber = foFetchList.Factory_Order__r.VIN_Number__c;
                                                assetwrap.tChassis = foFetchList.Factory_Order__r.T_Chassis__c;
                                                assetwrap.marketType = foFetchList.Factory_Order__r.Market_Type_1_5__c;
                                                assetwrap.assemblyFactoryCode = foFetchList.Factory_Order__r.Assembly_Factory_Code__c;
                                                assetwrap.assemblyFactoryName = foFetchList.Factory_Order__r.Assembly_Factory_Name__c; 
                                                financials.amount = String.valueOf(foFetchList.Amount.longValue());
                                                financials.currencyCode = foFetchList.Factory_Order__r.CurrencyIsoCode;
            									order.Orderid = foFetchList.Factory_Order__r.Order_Id__c;
                                                order.orderNumber = foFetchList.Factory_Order__r.Dealer_Number__c;
                                                order.statusDescription = foFetchList.Factory_Order__r.Order_Status_Description__c;
                                                order.registrationDate = string.valueofGmt(foFetchList.Factory_Order__r.FO_Registration_Date__c);
                                                order.cddDate = string.valueofGmt(foFetchList.Factory_Order__r.CDD_Date__c);
                                                order.disStatusCode = foFetchList.Factory_Order__r.Dis_Status_Code__c;
                                                System.debug('assetwrap: '+assetwrap);	
            									System.debug('order: '+order);
                                                order.financials = financials;
                                                order.asset = assetwrap;
            									quoteorder.add(order);
                                                System.debug('assetwrap: '+quoteorder);
                                                System.debug('quotewrap.asset: '+quoteorder);
                                            }
        quotewrap.order = quoteorder;
        System.debug('quotewrap.asset: '+quotewrap.order);
        dealer.id = foList[0].Dealer_Id__c;
        dealer.dealerNumber = foList[0].Dealer_Number__c;//currently it is in number but it was not used now because identifier error is causing so changed to dealer number
        dealer.mainDealerName = foList[0].Main_Dealer_Name__c;
        dealer.salesPersonName = foList[0].Sales_Person_Name__c;
        System.debug('dealer: '+dealer);
        customer.name = foList[0].End_Customer_Name__c;
        customer.address = foList[0].End_Customer_Address1__c;
        customer.phone = foList[0].End_Customer_Phone__c;
        customer.city = foList[0].End_Customer_City__c;
        customer.postalCode = foList[0].End_Customer_Postal_Code__c;
        customer.countryCode = oppList[0].Account.BillingCountryCode;
        customer.CMS_ID = customerCmsId;
        System.debug('customer: '+customer);
        quotewrap.dealer = dealer;
        quotewrap.customer = customer;
        System.debug('lstwrapeer: '+quotewrap);
		String fullString=json.serialize(quotewrap.order);

        CMSAPI1__c settings = CMSAPI1__c.getOrgDefaults();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:VFS_Global_APIs'+settings.Endpoint_QA__c);
        request.setMethod('POST');
        request.setHeader( 'X-Ibm-Client-Id',settings.X_Ibm_Client_Id__c);
        request.setHeader('X-Ibm-Client-Secret' , settings.X_Ibm_Client_Secret__c);
        request.setHeader('Content-Type', 'application/json; charset=utf-8');
        request.setHeader('Service-Id', 'SRV25720');

        String finalJson=json.serialize(quotewrap);
        request.setBody(finalJson);
        System.debug('Json View'+finalJson);
        System.debug('The rquest body is'+request.getBody());
        System.debug('This is request'+request);
        request.setTimeout(120000);
        List<String> listStr=new List<String> ();
        //listStr.add('false');
        //return listStr;//dummy return
        System.debug('Sending request anfet the timeout');
        HttpResponse response = http.send(request);
        System.debug('This is body code'+response.getStatusCode());
        System.debug('This is body body'+response.getBody());
        
        if(response.getStatusCode()==200)
        {
            try{
            Map<String, String> values = (Map<String, String>)
                JSON.deserialize(response.getBody(), Map<String, String>.class);
            String success = values.get('success');
            String quoteId = values.get('quoteId');
            
            String vfsConnectQuoteURL = values.get('vfsConnectQuoteURL');
            
            System.debug('This is success'+success);
            System.debug('This is quoteId'+quoteId);
            system.debug('Thi is url'+vfsConnectQuoteURL);
            //listStr.add(success);
            List <Opportunity> oppListUpt=new List<Opportunity>();
            for (Opportunity opp :oppList1) 
            {
                opp.Quote_Id__c = quoteId;
                opp.Quote_Url__c = vfsConnectQuoteURL;
                opp.Quote_Unique_Id__c = guid;
                opp.StageName = 'Quoted';
                oppListUpt.add(opp);
            }
            update oppListUpt;
                if(success == 'true'){
                    listStr.add('Quote created successfully');
                }
            return listStr;
            }
            catch (Exception e) {
            System.debug('The following exception has occurred:Try ' + e.getMessage()+'==+ :'+listStr);
            listStr.add(e.getMessage());
            return listStr;
            }
            
        }
        else
        {
            try{
                Map<String, String> values = (Map<String, String>) JSON.deserialize(response.getBody(), Map<String, String>.class);
                String Error = values.get('errorMessage');
                Error += '; '+values.get('message') == null ? '':values.get('message');
                System.debug('This is the error Msg'+Error);      
                system.debug('This is else');
                listStr.add(Error);
                system.debug(listStr);
            }
            catch (Exception e) {
                Boolean result=e.getMessage().contains('Unexpected character');
                if(result){
                    listStr.add('Cannot pass the security checks that are required by the target API or operation. Please try again later!');
                }
                else{
                   listStr.add(e.getMessage()); 
                }
            }
            return listStr;
        }
    }
}