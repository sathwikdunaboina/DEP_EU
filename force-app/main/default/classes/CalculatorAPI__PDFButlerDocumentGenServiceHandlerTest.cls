@isTest
public class PDFButlerDocumentGenServiceHandlerTest {

    @TestSetup
    public static void init_data(){
        Account a=new Account();
        a.Name='test';
        a.Siren__c='768765432';
        a.Siret__c='76876543298765';
        a.Phone='6767';
        a.BillingPostalCode='0987';
        a.BillingCity='test city';
        a.BillingStreet='test street';
        a.CallingReferenceId__c='768765432101';
        insert a;
        
        Opportunity opp1 = new Opportunity();
        opp1.Name = 'Test Opportunity88';
        opp1.Accountid = a.id;
        opp1.StageName = 'Prospecting';
        opp1.CloseDate = system.Today()+3;
        insert opp1;
        
        Quote quote=new Quote();
        quote.Name='TestQuote';
        quote.OpportunityId=opp1.Id;
        quote.Approval_Status__c='Approved';
        insert quote;
        
        String pf = UserInfo.getProfileId(); 
        
        User user3=new User(firstname = 'ABC', 
                         lastName = 'XYZ', 
                         email = 'testUser333@gmail.com', 
                         Username = 'testtst11@gmail.com', 
                         EmailEncodingKey = 'ISO-8859-1', 
                         Alias = 'user3', 
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US', 
                         ProfileId = pf,
                            Brand__c='Renault Trucks'
                        ); 
          insert user3;
        
          Brand__c brand2 = new  Brand__c(Name='Renault Trucks');
          insert brand2;
        
        cadmus_core__Doc_Config__c cdm=new cadmus_core__Doc_Config__c();
        cdm.Name='Renault Trucks - Approved';
        insert cdm;
       
        
    }
    
    static testMethod void getLoggedInUserBrandTest(){
        User u=[Select id, Brand__c from User where lastName='XYZ']; 
        Brand__c loggedInUserBrand=[Select id,Name from Brand__c where Name=:u.Brand__c];
        PDFButlerDocumentGenServiceHandler.getLoggedInUserBrand();
        //System.assertEquals(loggedInUserBrand.Name, PDFButlerDocumentGenServiceHandler.getLoggedInUserBrand());
     }
   
    @isTest
    public static void getQuotePDFContentTest(){
         Opportunity opp = [select Id,Name from Opportunity where Name = 'Test Opportunity88' LIMIT 1];
         Quote quote=[Select Id,Approval_Status__c from Quote where OpportunityId=:opp.Id];
        try{
            User u=[Select id, Brand__c from User where Id=:userInfo.getUserId()]; 
            Brand__c loggedInUserBrand=[Select id,Name from  Brand__c where Name=:u.Brand__c];
            System.assertEquals(loggedInUserBrand.Name, PDFButlerDocumentGenServiceHandler.getLoggedInUserBrand());
			cadmus_core.ConvertController.ConvertDataModel cdm=new cadmus_core.ConvertController.ConvertDataModel();
            PDFButlerDocumentGenServiceHandler docHandler=new PDFButlerDocumentGenServiceHandler();
       		docHandler.getQuotePDFContent(opp.Id, quote.Approval_Status__c);
           }catch(Exception e){
              System.debug('Exception'+e);
        }
    }

}