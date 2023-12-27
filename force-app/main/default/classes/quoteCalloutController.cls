/*
* Subject: Fetch records to show on UI
* Created by: Aswin balaji
* Date: 29/08/2022, 12:48
* Description: Based on Opportunity>Account.CMSId getting the related opportunites and show it on UI which doesn't have quote and stage doesn't = Closed
* 
*
* September 2023 Updates: 
* Author: Erin A. 
*
* New Lead Process update Opportunity Ownership to Dealer Accounts. 
* Customer Accounts are now a Lookup on the Opportuntiy
*
* */ 
public with sharing class quoteCalloutController {
    @AuraEnabled
    /**NEW this method is used to return the list of Opportunities also associated with this 
    *  opportunity Customer Account Id**/
    public static List<opportunity> getOpportunities(String oppId){
        
        /**NEW Updated to use Customer Account Id and reduce the amount of queries**/
        //Local Variables
        List<Opportunity> ThisOpportunity = [SELECT Id, Name,
                    Amount,Dealer_Name__c,Brand__c,
                    Dealer_Delivery_Date__c,CloseDate,
                    Quote_Id__c,CurrencyIsoCode,DealerId__c, 
                    Customer_Account__r.Id, AccountId
                    FROM Opportunity 
                    WHERE ID =: oppId];
        List<Opportunity> ThisOpportunityByCustomer = [SELECT Id, Name,
                    Amount,Dealer_Name__c,Brand__c,
                    Dealer_Delivery_Date__c,CloseDate,
                    Quote_Id__c,CurrencyIsoCode,DealerId__c
                    FROM Opportunity
                    WHERE Customer_Account__r.Id =: ThisOpportunity[0].Customer_Account__r.Id // to retrieve only the opportunities for the same Customer Account
                    AND AccountId =: ThisOpportunity[0].AccountId // check that the opportunities belongs to the same Dealer Account
                    AND Brand__c =: ThisOpportunity[0].Brand__c // only opportunities for the same Brand (VT or RT)
                    AND StageName !='Closed Won' AND StageName != 'Closed Lost' // if the opportunity is already closed (won or lost) it won't be quoted anymore
                    AND Account.CustomerID__c != null // CustomerID__c on Dealer Account
                    AND Customer_Account__r.Id != null]; // Id of related Customer Account
             
        if(ThisOpportunityByCustomer.Size() > 1) {
            return ThisOpportunityByCustomer;
        } else {
            return ThisOpportunity;
        }
       
        
        
        
        //Old Code
        /** 
        List <String> oppIdsList = new List<String>();
        String customerNumber = [Select Id,Account.Customer_Number__c From Opportunity Where Id =: oppId].Account.Customer_Number__c;
         String DealerID = [Select Id,Factory_Order__r.Dealer_Id__c From Opportunity Where Id =: oppId].Factory_Order__r.Dealer_Id__c;


        String brand = [Select Id,Factory_Order__r.Brand__c From Opportunity Where Id =: oppId].Factory_Order__r.Brand__c;
        String AccountIdFromOpportunity = [Select Id,AccountId From Opportunity Where Id =: oppId].AccountId;
        
   
        List<Opportunity> oppList = [SELECT Id, Name,Amount,Dealer_Name__c,Brand__c,Dealer_Delivery_Date__c,CloseDate,Quote_Id__c,CurrencyIsoCode
        FROM Opportunity
        WHERE Account.Customer_Number__c =: customerNumber];
        
        System.debug(oppList.size());
        system.debug('Opp.Account.Customer_Number__c'+customerNumber);
        
        if(customerNumber != null){
            return [SELECT Id, Name,Amount,Dealer_Name__c,Brand__c,Dealer_Delivery_Date__c,CloseDate,Quote_Id__c,CurrencyIsoCode,DealerId__c
                    FROM Opportunity
                    WHERE Account.Customer_Number__c =: customerNumber 
                    AND Factory_Order__r.Dealer_Id__c =: DealerID
                    AND Factory_Order__r.Brand__c =: brand
                    AND StageName !='Closed Won' AND StageName != 'Closed Lost' 
                    AND AccountId =: AccountIdFromOpportunity 
                    AND Account.Customer_Number__c !=null];  
        }
        else{
            return [SELECT Id, Name,Amount,Dealer_Name__c,Brand__c,Dealer_Delivery_Date__c,CloseDate,Quote_Id__c,CurrencyIsoCode,DealerId__c
                    FROM Opportunity
                    WHERE Id =:oppId AND StageName !='Closed Won' AND StageName != 'Closed Lost'];
        }**/

    }

    @AuraEnabled
    public static String getOppIds(List <String> Ids){
       System.debug('List of strings'+ Ids);
       //List <String> oppIdsList = new List<String>();
       //oppIdsList.add(Ids[0]);
       List<String> ErrorMsges = new List<String>();
       String ErrorMsg;
        if(Ids.isEmpty() == True){
            ErrorMsg='Please select atleast 1 record';
        }
        else{
            ErrorMsges = quoteCalloutHandler.fetchFromAPIForQuote(Ids);
        }
        for(String str : ErrorMsges){
            ErrorMsg = str;
            System.debug(str);
        }
        System.debug(ErrorMsg);
        return ErrorMsg;
    }
}