trigger LeadTrigger on Lead (before update) {
    
    if(Trigger.isUpdate){
        if(Trigger.isBefore){
            Boolean hasPermission = FeatureManagement.checkPermission('GoldenCopy');
            if(!hasPermission )
             { LeadTriggerHandler.updateParticipation(Trigger.new,Trigger.oldMap);
             }
            
        }
    }

}