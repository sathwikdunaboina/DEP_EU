public class uK_IE_FOs_Delete {

     public void  getData(){
     List <Factory_Order__c> foList= [SELECT Id,Main_Dealer_Name__c FROM Factory_Order__c WHERE (Main_Dealer_Name__c LIKE '%Thomas Hardie Commercials Ltd%' or Main_Dealer_Name__c LIKE '%Dennison Commercials Ltd%' )AND Order_Status_Description__c NOT IN ('Firm Planned','FirmPlanned', 'InvoicedFirstLevel', 'Confirmed', 'Produced')  and Country__c='GB'];   
     System.debug('This is the foList'+foList);
        
     List<Lead> leadList=[SELECT Factory_Order__c,Id FROM Lead where Factory_Order__c =: foList ];
     
     System.debug('This is Lead List'+leadList);
     
     List<Opportunity> oppList =[SELECT Factory_Order__c,Id FROM Opportunity where Factory_Order__c =: foList ];
     System.debug('This is Opp List '+oppList);
        
     Delete oppList;
     Delete leadList;
     Delete foList;
    }
}