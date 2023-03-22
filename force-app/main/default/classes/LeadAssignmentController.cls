/*
* Created: Rupal
* This is invoked by 'Lead Assignment' process builder
* On basis of dealer number mapped to account, it allocates lead owner as Territory manager user/unallocated lead queue
* */
Public class LeadAssignmentController {
    
    @InvocableMethod
    Public static void assignLeads(List<String> leadId){
        
        List<Lead> listLead = New List<Lead>();
        List<Lead> updateLead = New List<Lead>();
        List<String> listDealerIds = new List<String>();   
        Map<String,Account> accMap = new Map<String,Account>();
        
        try{
            system.debug('Inside assignLeads...');
            //fetches lead record based on the Id passed by process builder 
            listLead = [SELECT Id, OwnerId, Factory_Order__c, 
                        	Factory_Order_Number__c, Factory_Order__r.Dealer_Id__c, 
                        	Email, Country
                        FROM Lead
                        WHERE Id IN : leadId];
            system.debug('Incoming Leads are -> '+ listLead);
            
            //Collecting dealer identifier (eg: 12345) . 
            for(Lead ld  : listLead){
                if (ld.Factory_Order__c != null && !String.isEmpty(ld.Factory_Order__r.Dealer_Id__c)){
                	listDealerIds.add(ld.Factory_Order__r.Dealer_Id__c);  
                }
            }
            //query all account related to dealer number
            for (Account acc : [SELECT Id, Territory_Manager_User_Id__c, CustomerId__c
                                FROM Account
                                WHERE CustomerId__c IN : listDealerIds
                               		AND Territory_Manager__c != null]){
                                    
                                    accMap.put(acc.CustomerId__c,acc);
                                    
                                }
            system.debug('accMap -> '+ accMap);
            // query and store the queue id in a local variable
            String unAllocatedQueue = Lead_Assignment_Settings__c.getInstance().Unallocated_Queue__c;
            Group uQ = [Select Id , Name, DeveloperName from Group Where DeveloperName = :unAllocatedQueue][0];
            for (Lead ld : listLead) {
                //checks for all null condition
                if (ld.Factory_Order__c != null && ld.Factory_Order__r.Dealer_Id__c != null
                    && accMap.containsKey(ld.Factory_Order__r.Dealer_Id__c)
                    && !String.isEmpty(accMap.get(ld.Factory_Order__r.Dealer_Id__c).Territory_Manager_User_Id__c)){
                        
                        ld.OwnerId = accMap.get(ld.Factory_Order__r.Dealer_Id__c).Territory_Manager_User_Id__c;
                        updateLead.add(ld);
                        System.debug('updateLead::'+updateLead);
                        
                    } else {
            			system.debug('Unallocated_Leads = ' + uQ.Id);
                        ld.OwnerId = uQ.Id;
                        updateLead.add(ld);
                    }
            }
            Database.SaveResult[] srList = Database.update(updateLead,false);
        }
        
        catch (Exception ex) {
            
            System.debug('Catch Exception' + ex.getMessage());
            System.debug('Exception' + ex.getStackTraceString());
        }
        
    }
}