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
                    Customer_Account__r.Id, AccountId,Account.Name,Customer_Account__r.Name,
                    Factory_Order__r.VIN_Number__c, Factory_Order__r.Market_Type_1_5__c // Task-7323 code changes
                    FROM Opportunity 
                    WHERE ID =: oppId
                    AND StageName !='Closed Won' AND StageName != 'Closed Lost']; // if the opportunity is already closed (won or lost) it won't be quoted anymore;
        List<Opportunity> ThisOpportunityByCustomer = [SELECT Id, Name,
                    Amount,Dealer_Name__c,Brand__c,
                    Dealer_Delivery_Date__c,CloseDate,
                    Quote_Id__c,CurrencyIsoCode,DealerId__c,Account.Name,Customer_Account__r.Name,
                    Factory_Order__r.VIN_Number__c, Factory_Order__r.Market_Type_1_5__c // Task-7323 code changes
                    FROM Opportunity
                    WHERE Customer_Account__r.Id =: ThisOpportunity[0].Customer_Account__r.Id // to retrieve only the opportunities for the same Customer Account
                    AND AccountId =: ThisOpportunity[0].AccountId // check that the opportunities belongs to the same Dealer Account
                    AND Brand__c =: ThisOpportunity[0].Brand__c // only opportunities for the same Brand (VT or RT)
                    AND StageName !='Closed Won' AND StageName != 'Closed Lost' // if the opportunity is already closed (won or lost) it won't be quoted anymore
                    AND Account.CustomerID__c != null // CustomerID__c on Dealer Account
                    AND Customer_Account__r.Id != null
                    AND Quote_Id__c = null
                    AND Amount != null]; // Id of related Customer Account
             
        if(ThisOpportunityByCustomer.Size() > 1) {
            return ThisOpportunityByCustomer;
        } else {
            return ThisOpportunity;
        }

    }

    @AuraEnabled
    public static String getOppIds(List <String> ids){
       System.debug('List of strings'+ ids);
       //List <String> oppIdsList = new List<String>();
       //oppIdsList.add(Ids[0]);
       List<String> ErrorMsges = new List<String>();
       String ErrorMsg;
        if(ids.isEmpty() == True){
            ErrorMsg='Please select atleast 1 record';
        }
        else{
            ErrorMsges = quoteCalloutHandler.fetchFromAPIForQuote(ids);
        }
        for(String str : ErrorMsges){
            ErrorMsg = str;
            System.debug(str);
        }
        System.debug(ErrorMsg);
        return ErrorMsg;
    }
    
    @AuraEnabled
    public static List<VFS_Connect_Quote__c> getQuotes(String oppId){
        List <String> oppIdsList = new List<String>();
        //String customerNumber = [Select Id,Account.Customer_Number__c From Opportunity Where Id =: oppId].Account.Customer_Number__c;
        String customerNumber = [Select Customer_Account__r.Customer_Number__c From Opportunity Where Id =: oppId].Customer_Account__r.Customer_Number__c;
        String dealerID = [Select Id,Factory_Order__r.Dealer_Id__c From Opportunity Where Id =: oppId].Factory_Order__r.Dealer_Id__c;
        String brand = [Select Id,Factory_Order__r.Brand__c From Opportunity Where Id =: oppId].Factory_Order__r.Brand__c;
        String accountIdFromOpportunity = [Select Id,AccountId From Opportunity Where Id =: oppId].AccountId;
        List<Opportunity> oppList = [SELECT Id, Name,Amount,Dealer_Name__c,Brand__c,Dealer_Delivery_Date__c,CloseDate,Quote_Id__c,CurrencyIsoCode
                                     FROM Opportunity
                                     WHERE Account.Customer_Number__c =: customerNumber];
        System.debug(oppList.size());
        List<VFS_Connect_Quote__c> vfsConnect = [SELECT Name,Account_CMS_Number__c FROM VFS_Connect_Quote__c WHERE Account_CMS_Number__c =:customerNumber 
                                                 AND Quote_Status__c !='Cancelled' AND Id NOT IN (Select VFS_Connect_Quote_Ref__c From Opportunity Where Id IN:oppList)];
        System.debug(vfsConnect.size());
        System.debug(vfsConnect);
        system.debug('Opp.Account.Customer_Number__c'+customerNumber);
        if(customerNumber != null){
            return [SELECT Name,Account_CMS_Number__c,Quote_Status__c,Vin_Number__c,Financed_Amount__c,Delivery_Date__c,Make__c,Model__c FROM VFS_Connect_Quote__c WHERE Account_CMS_Number__c =:customerNumber AND Quote_Status__c !='Cancelled'];  
        }
        else{
            return null;
        }
        
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
            Opportunity opp = [SELECT Name,Quote_Id__c, CloseDate, StageName,OwnerId FROM Opportunity WHERE Id=:oppId];
            if(opp.Quote_Id__c == null || opp.Quote_Id__c ==''){
                opp.Quote_Id__c = quoteId;
                opp.Quote_Url__c = quoteUrl;
                //opp.Quote_Unique_Id__c = yet to confirm
                opp.StageName = 'Quoted';
                opp.VFS_Connect_Quote_Ref__c = quoteRecordId;
                update opp;
                System.debug('opp '+opp);
                msg = 'Updated Successfully!';
                List<CustomNotificationType > TemplateInfoDetail = [SELECT Id, DeveloperName FROM CustomNotificationType
                                                                    WHERE DeveloperName='Quote_created_notification'];
                
                Messaging.CustomNotification currNotification = new Messaging.CustomNotification();
                currNotification.setTitle('Quote Notification');
                
                currNotification.setBody(opp.Name + ' Opportunity was updated with Quote: ' + opp.Quote_Id__c +' on ' + system.today()+' by '+ userInfo.getName());
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
        return msg;
    }
}