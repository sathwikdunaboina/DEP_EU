@isTest
public class SynapseCustomerDetailsHandlerTest {

	@TestSetup
    public static void init_data(){
		String pf = UserInfo.getProfileId(); 
			User user4=new User(firstname = 'Test', 
                         lastName = 'User123', 
                         email = 'testUser444@gmail.com', 
                         Username = 'testtst12@gmail.com', 
                         EmailEncodingKey = 'ISO-8859-1', 
                         Alias = 'user4', 
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US', 
                         ProfileId = pf,
					     Brand__c='Volvo Trucks',
                         Country='France'
                        ); 
        insert user4;
    }
    public class SynapseReport2AWebServiceHelperClassCalloutMock implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest req1){
          HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            res.setBody('{"GetReport2AResponse":{"Header":{"MessageDateTime":"2016-01-12T17:34:15","MessageVersion":2.1,"CallingSystem":"PriceManager","CallingReferenceId":445404312101,"CountryCode":"FR","BusinessArea":"VT","MarketCode":"FR-VT","CompanyId":"SYSPERTEC COMMUNICATION","UserId":"YFW0328"},"Result":{"ErrorOccured":"0","Report":{"Customer":"","ReportInfo":""},"ReportInfo":{"ProductId":31084,"ReportId":"SYNAPSE","ReportDate":"2022-10-13T11:32:52"},"Customer":{"Name":[{"$":"SARL TRANSPORTS ALAIN BARRAU"},{"$":"SARL TRANSPORTS ALAIN BARRAU"}],"ExternalCustomerId":445404312,"ChambreOfCommerce":445404312,"CustomerType":"Company","NatureOfBusiness":"4941A","RegisterCourtDate":"2000-06-16"},"CreditInfo":{"CreditDecision":{"Approved":1,"Description":""},"MaxFinancedAmount":250000,"MaxTerms":60,"CreditRating":"A"},"MinorFields":{"MinorField":[{"Name":"FIBEN 27","Value":"depuis le 08/01/2022"},{"Name":"revue le","Value":""},{"Name":"Cot. BDF","Value":"1-"},{"Name":"Niv. tivité","Value":"F"},{"Name":"Code NAF","Value":"4941A TRANSPORTS ROUTIERS DE FRET INTERURBAINS"},{"Name":"Forme Jur.","Value":"SARL"},{"Name":"Création","Value":"16/06/2000"},{"Name":"IP BDF 2Trim","Value":"0,00 EUR"},{"Name":"Score @Rating","Value":"10 / 10"},{"Name":"FCC PM","Value":"N.A."},{"Name":"FIBEN 51","Value":"2022-10-13T11:32:56"},{"Name":"Cot. Gérant 1","Value":"000"},{"Name":"Cot. Gérant 2","Value":"000"},{"Name":"FCC PP1","Value":"Non recensé"},{"Name":"FCC PP2","Value":"Non recensé"},{"Name":"FICP PP1","Value":"Non recensé"},{"Name":"FICP PP2","Value":"Non recensé"},{"Name":"Cot. Interne","Value":"Sain"},{"Name":"Cot. Int. groupe","Value":"N.A."},{"Name":"Black List","Value":"non"},{"Name":"Nbr. demandes","Value":"0"}]}}}}');
            return res;
        }
       }
    public class SynapseReport2BWebServiceHelperClassCalloutMock implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest req1){
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            res.setBody('{"GetReport2BResponse":{"Header":{"MessageDateTime":"2016-01-12T17:34:15","MessageVersion":2.1,"CallingSystem":"PriceManager","CallingReferenceId":445404312,"CountryCode":"FR","BusinessArea":"VT","MarketCode":"FR-VT","CompanyId":"SYSPERTEC COMMUNICATION","UserId":"YFW0328"},"Result":{"ErrorOccured":0,"Report":{"Customer":"","ReportInfo":""},"ReportInfo":{"ProductId":31084,"ReportId":"SYNAPSE","ReportDate":"2022-10-13T11:32:52"},"Customer":{"Name":[{"$":"SARL TRANSPORTS ALAIN BARRAU"},{"$":"SARL TRANSPORTS ALAIN BARRAU"}],"ExternalCustomerId":445404312,"ChambreOfCommerce":445404312,"CustomerType":"Company","NatureOfBusiness":"4941A","RegisterCourtDate":"2000-06-16"},"CreditInfo":{"CreditDecision":{"Approved":1,"Description":""},"MaxFinancedAmount":250000,"MaxTerms":60,"CreditRating":"A"},"MinorFields":{"MinorField":[{"Name":"FIBEN 27","Value":"depuis le 08/01/2022"},{"Name":"revue le","Value":""},{"Name":"Cot. BDF","Value":"1-"},{"Name":"Niv. tivité","Value":"F"},{"Name":"Code NAF","Value":"4941A TRANSPORTS ROUTIERS DE FRET INTERURBAINS"},{"Name":"Forme Jur.","Value":"SARL"},{"Name":"Création","Value":"16/06/2000"},{"Name":"IP BDF 2Trim","Value":"0,00 EUR"},{"Name":"Score @Rating","Value":"10 / 10"},{"Name":"FCC PM","Value":"N.A."},{"Name":"FIBEN 51","Value":"2022-10-13T11:32:56"},{"Name":"Cot. Gérant 1","Value":"000"},{"Name":"Cot. Gérant 2","Value":"000"},{"Name":"FCC PP1","Value":"Non recensé"},{"Name":"FCC PP2","Value":"Non recensé"},{"Name":"FICP PP1","Value":"Non recensé"},{"Name":"FICP PP2","Value":"Non recensé"},{"Name":"Cot. Interne","Value":"Sain"},{"Name":"Cot. Int. groupe","Value":"N.A."},{"Name":"Black List","Value":"non"},{"Name":"Nbr. demandes","Value":"0"}]}}}}');
            return res;
        }
       }
    //public Synapse_Auth_Provider__mdt getCustomMetadataRecord(String myName) {
        
    //}
    @isTest
    public static void SynapseCustomerDetailsHandlerTest(){
         User u=[Select id,firstName,lastName from User where lastName = 'User123'];
         String accessToken='eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6Ii1LSTNROW5OUjdiUm9meG1lWm9YcWJIWkdldyIsImtpZCI6Ii1LSTNROW5OUjdiUm9meG1lWm9YcWJIWkdldyJ9.eyJhdWQiOiJhcGk6Ly9lYjIyNmNlMS03ZmRjLTQ4MDgtOTllZC1hNWYxY2ExOTM5YmQiLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC9mMjU0OTNhZS0xYzk4LTQxZDctOGEzMy0wYmU3NWY1ZmU2MDMvIiwiaWF0IjoxNjczNTIyMDI2LCJuYmYiOjE2NzM1MjIwMjYsImV4cCI6MTY3MzUyNTkyNiwiYWlvIjoiRTJaZ1lKQlp4TFpkNTVnUXo2MnovWHJmbHRmekFnQT0iLCJhcHBpZCI6IjhlOTBmOTA1LWE4MTgtNDBkYi04NzhhLTE2NGViOWE4MWQ1NyIsI';
        System.runAs(u){
        String siren='44525782700029'; 
            
        String customerDeatils = '{"CustomerDetailResponse": {"Header": {"MessageDateTime": "2016-01-12T17:17:25","MessageVersion": "2.5","CallingSystem": "PriceManager","SourceSystems": {"SourceSystem": "SYNAPSE"},"countryName": "FR","MarketCode": "FR-RT","BusinessArea": "RT","CompanyId": "VFS LOCATION FRANCE SAS","UserId": "YFW0328"},"DetailResponse": {"ErrorOccured": "1","DetailCustomer": {"CompanyName": "TRANS LOGISTIQUE SERVICES","ChambreOfCommerce": "81096003900024","NatureOfBusiness": "4941A","Addresses": {"Address": {"Address1": "297 Avenue de Digne","ZipCode": "83130","City": "LA GARDE"}},"Phone": "0494652730","CustomerNumber": "810960039","CustomerId": "810960039"}}}}';
        CustomerDetailsWrapper customerDetailsWrapper=(CustomerDetailsWrapper)JSON.deserialize(customerDeatils,CustomerDetailsWrapper.class);
             
        Synapse_Auth_Provider__mdt theRecord = new Synapse_Auth_Provider__mdt();
        theRecord.DeveloperName = 'Test';
        theRecord.Auth_Provider_Name__c='Monthly Payment';
        theRecord.Client_Id__c='3298fe6ea62435ed0389554f704b1893';
        theRecord.Client_Secret__c='04c944de8ea3b89841901aca506d5d45';
        //Id=m021j000000TdGlAAK;
        theRecord.Label='Monthly Payment';
        theRecord.MasterLabel='Monthly Payment';
        
        SynapseCustomerDetailsHandler handler=new SynapseCustomerDetailsHandler();
            
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SynapseReport2AWebServiceHelperClassCalloutMock());
    
        String str2AResponse=SynapseCustomerDetailsHandler.getReport2A(accessToken,siren,'445404312786547','FR','VT','86eb07a91324714803e55f7642eaf4cf','2d84f1d30c0c40b4e205d2902eac6dec');   
        handler.getCustomerCreditScore(siren, 'FR', accessToken, 'VT');
            SynapseCustomerDetailsHandler.parseGetReport2AResponseJSON(str2AResponse,'FR');
        
        Test.setMock(HttpCalloutMock.class, new SynapseReport2BWebServiceHelperClassCalloutMock());
        String str2BResponse=SynapseCustomerDetailsHandler.getReport2B(accessToken,siren,'445404312786547','FR','VT','86eb07a91324714803e55f7642eaf4cf','2d84f1d30c0c40b4e205d2902eac6dec');   
        SynapseCustomerDetailsHandler.parseGetReport2BResponseJSON(str2BResponse,'FR');
      
        handler.getCustomerDetails(siren, customerDetailsWrapper, 'FR', accessToken, 'VT',theRecord);
        
        
        Test.stopTest();
        }
       }
    
   
    
    
}