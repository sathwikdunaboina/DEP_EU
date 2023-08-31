/*
* Subject: Fetch records to show on UI
* Created by: Aswin balaji
* Date: 03/07/2023, 12:48
* Description: Create or Search quote for related opportunites and show it on UI where stage doesn't = Closed
* */ 
public with sharing class quoteCalloutController {
    @AuraEnabled
    public static List<opportunity> getOpportunities(String oppId){
        List <String> oppIdsList = new List<String>();
        String customerNumber = [Select Id,Account.Customer_Number__c From Opportunity Where Id =: oppId].Account.Customer_Number__c;
        String dealerID = [Select Id,Factory_Order__r.Dealer_Id__c From Opportunity Where Id =: oppId].Factory_Order__r.Dealer_Id__c;
        String brand = [Select Id,Factory_Order__r.Brand__c From Opportunity Where Id =: oppId].Factory_Order__r.Brand__c;
        String accountIdFromOpportunity = [Select Id,AccountId From Opportunity Where Id =: oppId].AccountId;
        List<Opportunity> oppList = [SELECT Id, Name,Amount,Dealer_Name__c,Brand__c,Dealer_Delivery_Date__c,CloseDate,Quote_Id__c,CurrencyIsoCode
                                     FROM Opportunity
                                     WHERE Account.Customer_Number__c =: customerNumber];
        System.debug(oppList.size());
        system.debug('Opp.Account.Customer_Number__c'+customerNumber);
        if(customerNumber != null){
            return [SELECT Id, Name,Amount,Dealer_Name__c,Brand__c,Dealer_Delivery_Date__c,CloseDate,Quote_Id__c,CurrencyIsoCode,DealerId__c
                    FROM Opportunity
                    WHERE Account.Customer_Number__c =: customerNumber 
                    AND Factory_Order__r.Dealer_Id__c =: dealerID
                    AND Factory_Order__r.Brand__c =: brand
                    AND StageName !='Closed Won' AND StageName != 'Closed Lost' 
                    AND AccountId =: accountIdFromOpportunity 
                    AND Account.Customer_Number__c !=null];  
        }
        else{
            return [SELECT Id, Name,Amount,Dealer_Name__c,Brand__c,Dealer_Delivery_Date__c,CloseDate,Quote_Id__c,CurrencyIsoCode,DealerId__c
                    FROM Opportunity
                    WHERE Id =:oppId AND StageName !='Closed Won' AND StageName != 'Closed Lost'];
        }
        
    }
    @AuraEnabled
    public static List<VFS_Connect_Quote__c> getQuotes(String oppId){
        List <String> oppIdsList = new List<String>();
        String customerNumber = [Select Id,Account.Customer_Number__c From Opportunity Where Id =: oppId].Account.Customer_Number__c;
        String dealerID = [Select Id,Factory_Order__r.Dealer_Id__c From Opportunity Where Id =: oppId].Factory_Order__r.Dealer_Id__c;
        String brand = [Select Id,Factory_Order__r.Brand__c From Opportunity Where Id =: oppId].Factory_Order__r.Brand__c;
        String accountIdFromOpportunity = [Select Id,AccountId From Opportunity Where Id =: oppId].AccountId;
        List<Opportunity> oppList = [SELECT Id, Name,Amount,Dealer_Name__c,Brand__c,Dealer_Delivery_Date__c,CloseDate,Quote_Id__c,CurrencyIsoCode
                                     FROM Opportunity
                                     WHERE Account.Customer_Number__c =: customerNumber];
        System.debug(oppList.size());
        system.debug('Opp.Account.Customer_Number__c'+customerNumber);
        if(customerNumber != null){
            return [SELECT Name,Account_CMS_Number__c FROM VFS_Connect_Quote__c WHERE Account_CMS_Number__c =:customerNumber AND Quote_Status__c !='Cancelled' AND Id NOT IN(SELECT VFS_Connect_Quote_Ref__c From Opportunity)];  
        }
        else{
            return null;
        }
        
    }
    
    @AuraEnabled
    public static String getOppIds(List <String> ids){
        System.debug('List of strings'+ ids);
        //List <String> oppidsList = new List<String>();
        //oppidsList.add(ids[0]);
        List<String> errorMsges = new List<String>();
        String errorMsg;
        if(ids.isEmpty() == True){
            errorMsg='Please select atleast 1 record';
        }
        else{
            errorMsges = quoteCalloutHandler.fetchFromAPIForQuote(ids);
        }
        for(String str : errorMsges){
            errorMsg = str;
            System.debug(str);
        }
        System.debug(errorMsg);
        return errorMsg;
    }
    
    @AuraEnabled
    public static String getQuoteId(String quoteId,String oppId){
        //String url = [SELECT Quote_Url__c,Quote_Id__c FROM Opportunity WHERE Quote_Id__c =:quoteId LIMIT 1].Quote_Url__c;
        Id quoteRecordId = [SELECT Id FROM VFS_Connect_Quote__c WHERE Quote_Number__c =:quoteId LIMIT 1].Id;
        //String quoteNumber = [SELECT Name FROM VFS_Connect_Quote__c WHERE Quote_Number__c =:quoteId LIMIT 1].Name;
        String msg;
        CMSAPI1__c settings = CMSAPI1__c.getOrgDefaults();
        if(quoteId != null){
            String quoteUrl = settings.SearchQuoteEndpoint__c+'QuotationId='+quoteId+'&ExternalSystem=SalesConnect';
            Opportunity opp = [SELECT Name,Quote_Id__c, CloseDate,OwnerId, StageName FROM Opportunity WHERE Id=:oppId];
            if(opp.Quote_Id__c == null || opp.Quote_Id__c ==''){
                opp.Quote_Id__c = quoteId;
                opp.Quote_Url__c = quoteUrl;
                //opp.Quote_Unique_Id__c = yet to confirm
                opp.StageName = 'Quoted';
                opp.VFS_Connect_Quote_Ref__c = quoteRecordId;
                update opp;
                System.debug('opp '+opp);
                msg = 'Successfully saved!';
                List<CustomNotificationType > TemplateInfoDetail = [SELECT Id, DeveloperName FROM CustomNotificationType
                                                                    WHERE DeveloperName='Quote_created_notification'];
                
                Messaging.CustomNotification currNotification = new Messaging.CustomNotification();
                currNotification.setTitle('Quote Notification');
                
                currNotification.setBody(opp.Name + ' Opportunity Quote is been merged with ' + opp.Quote_Id__c +' on ' + system.today());
                currNotification.setNotificationTypeId(TemplateInfoDetail[0].Id);
                currNotification.setTargetId(opp.Id);
                currNotification.send(new Set<String>{ opp.OwnerId });
            }
            else{
                msg = 'Info: Quote was already created for this Opportunity!';
            }
            
        }
        else{
            msg = 'Warning: Quote Id not found for the selected Record!';
        }
        System.debug('quoteId'+quoteId);
        System.debug('oppId'+oppId);
        System.debug('msg'+msg);
        return msg;
    }
}