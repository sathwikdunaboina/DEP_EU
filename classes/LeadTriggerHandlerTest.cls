@isTest
public class LeadTriggerHandlerTest {
    
    @isTest
    private static void updateParticipationTest(){
        List<Lead> lList= new List<Lead>();
        for(Integer i=0; i<202; i++){
            Lead l= new Lead();
            l.LastName='Test ' + i;
            l.Company='Test Company';
            l.Status='New';
            l.CurrencyIsoCode='EUR';
            lList.add(l);
        }
        insert lList;
        
        for(Integer i=0; i<202; i++){
            lList[i].Status='Converted';
            
        }
        Test.startTest();
        update lList;
        Test.stopTest();
        
        Lead l1= [Select Id,Status,Participated__c from Lead where Id=:lList[2].Id];
        System.assertEquals(lList[2].Status,l1.Status);
        
             
    }
    
    

}