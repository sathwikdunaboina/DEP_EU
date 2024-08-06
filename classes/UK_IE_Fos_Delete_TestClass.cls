@isTest 
public  class UK_IE_Fos_Delete_TestClass {
    
    static testMethod void validate () {
       Factory_Order__c obj = new Factory_Order__c();
       obj.Dealer_Id__c='IT-1234';
       obj.Main_Dealer_Name__c='Thomas Hardie Commercials Ltd';
       obj.Order_Status_Description__c='InvoicedAllLevels';
       obj.country__c='GB';
       insert obj;
       List <Factory_Order__c> foList= [SELECT Id FROM Factory_Order__c WHERE (Main_Dealer_Name__c LIKE '%Thomas Hardie Commercials Ltd%' or Main_Dealer_Name__c LIKE '%Dennison Commercials Ltd%' )AND Order_Status_Description__c NOT IN ('Firm Planned','FirmPlanned', 'InvoicedFirstLevel', 'Confirmed', 'Produced')];
       Lead leadObj=new Lead();
       leadObj.Factory_Order__c= foList.get(0).Id;
        leadObj.LastName='Test';
        leadObj.Company='Test';
       //leadObj.Dealer_Name__c='Thomas Hardie Commercials Ltd';
       insert leadObj;
       Opportunity objOpp=new Opportunity();
       objOpp.Factory_Order__c=foList.get(0).Id;
        objOpp.Name='Test';
        objOpp.StageName='New';
        
    DateTime dT = System.now();
    Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
        objOpp.CloseDate=myDate;
       insert objOpp;
        Test.startTest();
        FoUKIEDeleteSchedulerClass objsch=new FoUKIEDeleteSchedulerClass();
        String sch = '0 0 23 * * ?';
		system.schedule('Test status Check', sch, objsch );
		Test.stopTest();
        
        
       
       
        
       
      }
}