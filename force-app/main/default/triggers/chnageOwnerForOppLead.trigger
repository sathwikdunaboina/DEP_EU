trigger chnageOwnerForOppLead on Account (after update) {
    List<Account> accListNew=new List<Account>();
    List<Account> accListOld=new List<Account>();
    List<String> idList=new List<String>();
    List<Lead> updatedOwnerLeadList=new List<Lead>();
    List<Opportunity> updatedOwnerOppList=new List<Opportunity>();
    List<Account> accListFinal=new List<Account>();
    List<Lead> leadList=new List<Lead>();
    List<Opportunity> oppList=new List<Opportunity>();
    List<Factory_Order__c> factoryOrderList=new List<Factory_Order__c>(); 
    Map<ID,Schema.RecordTypeInfo> rt_Map = Account.sObjectType.getDescribe().getRecordTypeInfosById();
    Map<String,Id > custIDTmMap=new Map<String,Id>();
     Boolean hasPermission = FeatureManagement.checkPermission('ByPassAccTrigger');
            system.debug('check for permission');
            System.debug('This is the value' +hasPermission );
            if(!hasPermission )
            {
    for (Account acc : Trigger.old)
    {
     	Account accIn=new Account();
     	accIn.id=acc.id;
    	accIn.CustomerID__c=acc.CustomerID__c;
     	accIn.Territory_Manager__c=acc.Territory_Manager__c;
        accListOld.add(accIn);  
    }
        System.debug('This is line 17');
     Dealer_Record_Type__mdt namet=Dealer_Record_Type__mdt.getInstance('Name');
    for (Account acc : Trigger.New)
    {
        if(rt_map.get(acc.recordTypeID).getName().containsIgnoreCase(namet.RecordTypeName__c)){
             
          
     	Account accIn=new Account();
     	accIn.id=acc.id;
    	accIn.CustomerID__c=acc.CustomerID__c;
     	accIn.Territory_Manager__c=acc.Territory_Manager__c;
        accListNew.add(accIn);  
        }
    }    
     
    System.debug('This is line 27');
    if(accListNew.size()>0)
    {
    accListFinal=[SELECT Id, Territory_Manager_User_Id__c, CustomerId__c FROM Account WHERE ID IN : accListNew];
    
    for(integer i=0 ; i <accListFinal.size(); i++)
        
    {
     if (accListNew.get(i).Territory_Manager__c !=accListOld.get(i).Territory_Manager__c)
     {
      custIDTmMap.put(accListFinal.get(i).CustomerID__c, accListFinal.get(i).Territory_Manager_User_Id__c);
       system.debug('This is the customer id '+accListNew.get(i).CustomerID__c);
      idList.add(accListNew.get(i).CustomerID__c);
       system.debug('This is the customer id2 '+accListNew.get(i).CustomerID__c);

    }
    
    }
    System.debug('This is old one '+accListOld);
    System.debug('This is new  one '+accListNew);
   
    
    factoryOrderList=[SELECT Id FROM Factory_Order__c WHERE Dealer_Id__c =:idList];
    leadList =[SELECT ID,OwnerId,Factory_Order__r.Dealer_Id__c ,Unqualified_Reason__c FROM Lead Where Factory_Order__c =:factoryOrderList AND isConverted != TRUE];
    if(!leadList.isEmpty())
    {
    for(Lead leadfoIn : leadList)  
     {
       leadfoIn.OwnerId=custIDTmMap.get(leadfoIn.Factory_Order__r.Dealer_Id__c);
       leadfoIn.Unqualified_Reason__c='other';
       updatedOwnerLeadList.add(leadfoIn);
        
    }
    }
    oppList =[SELECT ID,OwnerId ,Factory_Order__r.Dealer_Id__c FROM Opportunity Where Factory_Order__c =:factoryOrderList];
        if(!oppList.isEmpty())
        {
     for(Opportunity oppfoIn : oppList)  
     {
       oppfoIn.OwnerId=custIDTmMap.get(oppfoIn.Factory_Order__r.Dealer_Id__c);
       updatedOwnerOppList.add(oppfoIn);
     }
        }
     system.debug('This is the opp list'+updatedOwnerOppList);
     System.debug('This is the lead list'+updatedOwnerLeadList);
     update updatedOwnerOppList;
     update updatedOwnerLeadList;
    }
   
}
}