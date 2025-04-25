/*
* Contains methods to call Quote API and fetch Quote records in SF.
* 
* */
public without sharing  class quoteCallout {
    
    @InvocableMethod (label='createQuoteNew' description='This fetches Quotes from backend CMS')
    public static List<String> fetchInvoicesFromAPIForQuote( List<String> factoryOrderId){
        //New Addition Date 19th May
        String UserName1 = UserInfo.getUserName();//Returns the context user's login name.
        System.Debug('UserName-' + UserName1);
        List<User> userObj =new List<User>();
        userObj =  [SELECT FederationIdentifier FROM User WHERE Username = : UserName1 ];
        String userFederationID=userObj[0].FederationIdentifier;
        System.debug('This is user Federation id'+userFederationID);
        System.debug('This is the id'+factoryOrderId.get(0));
        List<Opportunity> oppList=new List<Opportunity>();
        List<Opportunity> oppList1=new List<Opportunity>();

        oppList =[Select Id,Amount ,Factory_Order__c,Account.Name ,Account.BillingCountryCode from Opportunity where Id =  : factoryOrderId.get(0)];
        oppList1 =[Select Id,Quote_Id__c,Quote_Url__c from Opportunity where Id =  : factoryOrderId.get(0)];
        String foId =oppList[0].Factory_Order__c;
        system.debug('This is the list'+oppList[0].Account.BillingCountryCode);
        List<Factory_Order__c> foList=new List<Factory_Order__c>();
        
        foList=[select Assembly_Factory_Code__c,Assembly_Factory_Name__c,Axle_Arrangement__c,   
                Brand__c,CDD_Date__c,Chassis_Type__c,Contact_Last_Name__c,Country__c,       
                CreatedById,CurrencyIsoCode,Dealer_Id__c,Dealer_Number__c,       
                Dis_Status_Code__c,End_Customer_Address1__c,End_Customer_City__c,
                    End_Customer_Name__c,End_Customer_Phone__c,End_Customer_Postal_Code__c, 
                Engine_Version__c,Name, FO_Registration_Date__c ,HP__c,Main_Dealer_Name__c, 
                Market_Type_1_5__c,Order_Id__c,Order_Status_Description__c,Sales_Person_Name__c,
                Serial__c,T_Chassis__c, Vehicle_Status__c,VIN_Number__c from Factory_Order__c
                where Id = : oppList[0].Factory_Order__c ];
        
        System.debug('This is FO details'+foList);
        system.debug('This is 1st element '+foList[0].Assembly_Factory_Code__c);

        List<User> ownerObj =new List<User>();
        ownerObj = [SELECT FederationIdentifier, Id FROM User WHERE Id in (SELECT OwnerId FROM Opportunity WHERE Id = :factoryOrderId.get(0))];
        List<Account> accObj = new List<Account>();
        accObj = [SELECT Name, Customer_Number__c FROM Account WHERE Id in (SELECT AccountID FROM Opportunity WHERE Id = :factoryOrderId.get(0))];
        string customerCmsId = accObj[0].Customer_Number__c;

        Map<String ,Object> newObj= new Map<String ,Object>();
        newObj.put('externalId',oppList[0].Id);
        newObj.put('countryCode',oppList[0].Account.BillingCountryCode);
        newObj.put('brand',foList[0].Brand__c);
        newObj.put('owner',ownerObj[0].FederationIdentifier);
        newObj.put('requestedBy',userFederationID);

        newObj.put('source','Sales Connect');
        Map<String,String> orderObj=new Map<String,String>();
        orderObj.put('id',foList[0].Dealer_Id__c);
        orderObj.put('number',foList[0].Dealer_Number__c);
        orderObj.put('statusDescription', foList[0].Order_Status_Description__c);
        orderObj.put('registrationDate', string.valueofGmt(foList[0].FO_Registration_Date__c));
        orderObj.put('cddDate', string.valueofGmt(foList[0].CDD_Date__c));
        orderObj.put('disStatusCode',foList[0].Dis_Status_Code__c);
        newObj.put('order',orderObj); 
        Map<String,String> custObj=new Map<String,String>();
        custObj.put('name', foList[0].End_Customer_Name__c);
        custObj.put('address',foList[0].End_Customer_Address1__c);
        custObj.put('phone',foList[0].End_Customer_Phone__c);
        custObj.put('city',foList[0].End_Customer_City__c);
        custObj.put('postalCode',foList[0].End_Customer_Postal_Code__c);
        custObj.put('countryCode',oppList[0].Account.BillingCountryCode);
        custObj.put('CMS_ID',customerCmsId);
        newObj.put('customer',custObj);
        Map<String,String> objDeal =new Map<String,String>();
        objDeal.put('id',foList[0].Dealer_Id__c);
        objDeal.put('number',foList[0].Dealer_Number__c);
        objDeal.put('mainDealerName',foList[0].Main_Dealer_Name__c);
        objDeal.put('salesPersonName',foList[0].Sales_Person_Name__c);
        newObj.put('dealer',objDeal);
        Map<String,String> objAsse =new Map<String,String>();
        objAsse.put('axleArrangement', foList[0].Axle_Arrangement__c);
        objAsse.put('chassisType', foList[0].Chassis_Type__c);
        objAsse.put('engineVersion', foList[0].Engine_Version__c);
        objAsse.put('VINNumber',foList[0].VIN_Number__c);
        objAsse.put('tChassis',foList[0].T_Chassis__c);
        objAsse.put('marketType', foList[0].Market_Type_1_5__c);
        objAsse.put('assemblyFactoryCode',foList[0].Assembly_Factory_Code__c);
        objAsse.put('assemblyFactoryName',foList[0].Assembly_Factory_Name__c);
        newObj.put('asset',objAsse);
        Map<String,String> objFin=new Map<String,String>();
        
        //objFin.put('amount', String.valueOf(oppList[0].Amount.longValue()));
        objFin.put('amount', String.valueOf(oppList[0].Amount));
        objFin.put('currencyCode', foList[0].CurrencyIsoCode);
        newObj.put('financials',objFin);
 
        //CMSAPI__c settings = CMSAPI_SettingsManager.get();
        CMSAPI1__c settings = CMSAPI1__c.getOrgDefaults();

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:VFS_Global_APIs1'+'/vfsconnect/quotation/v1.0/draft');
        request.setMethod('POST');
        request.setHeader( 'X-Ibm-Client-Id',settings.X_Ibm_Client_Id__c);
        request.setHeader('X-Ibm-Client-Secret' , settings.X_Ibm_Client_Secret__c);
        request.setHeader('Content-Type', 'application/json; charset=utf-8');
        request.setHeader('Service-Id', 'SRV25720');

        //request.setHeader('Accept-Encoding', 'gzip,deflate');
        //request.setHeader('content-type', 'text/xml; charset=utf-8');
        //request.setHeader('Content-Length', String.valueOf(body.length()));
        String finalJson=json.serialize(newObj);
        request.setBody(finalJson);
        System.debug('The rquest body is'+request.getBody());
        System.debug('This is request'+request);
        request.setTimeout(120000);
        List<String> listStr=new List<String> ();
                //listStr.add('false');
                //return listStr;
                //
        System.debug('Sending request anfet the timeout');
 
        HttpResponse response = http.send(request);
        //response.setTimeout(40000);
        System.debug('This is body code'+response.getStatusCode());
        System.debug('This is body body'+response.getBody());
      
        if(response.getStatusCode()==200)
        {
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
                opp.Quote_Id__c=quoteId;
                opp.Quote_Url__c=vfsConnectQuoteURL;
                oppListUpt.add(opp);
            }
            update oppListUpt;
            return listStr;
        }   
        else
        {
            Map<String, String> values = (Map<String, String>) JSON.deserialize(response.getBody(), Map<String, String>.class);
            String Error = values.get('errorMessage');
            System.debug('This is the error Msg'+Error);      
            system.debug('This is else');
            listStr.add(Error);
            return listStr;
        }
    }     
}