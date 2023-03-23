/*
* Subject: Fetch records to show on UI
* Created by: Aswin balaji
* Date: 29/08/2022, 12:48
* Description: Based on Opportunity>Account.CMSId getting the related opportunites and show it on UI which doesn't have quote and stage doesn't = Closed
* */ 
public with sharing class quoteCalloutController {
    @AuraEnabled
    public static List<opportunity> getOpportunities(String oppId){
        List <String> oppIdsList = new List<String>();
        String customerNumber = [Select Id,Account.Customer_Number__c From Opportunity Where Id =: OppId].Account.Customer_Number__c;
        String DealerID = [Select Id,Factory_Order__r.Dealer_Id__c From Opportunity Where Id =: OppId].Factory_Order__r.Dealer_Id__c;
        String AccountIdFromOpportunity = [Select Id,AccountId From Opportunity Where Id =: OppId].AccountId;
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
                    AND (StageName !='Closed Won' OR StageName != 'Closed Lost') 
                    AND AccountId =: AccountIdFromOpportunity 
                    AND Account.Customer_Number__c !=null];  
        }
        else{
            return [SELECT Id, Name,Amount,Dealer_Name__c,Brand__c,Dealer_Delivery_Date__c,CloseDate,Quote_Id__c,CurrencyIsoCode,DealerId__c
                    FROM Opportunity
                    WHERE Id =:oppId AND (StageName !='Closed Won' OR StageName != 'Closed Lost')];
        }

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