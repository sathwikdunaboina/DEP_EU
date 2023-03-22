trigger LeadTrigger on Lead (before update) {
    
    if(Trigger.isUpdate){
        if(Trigger.isBefore){
            Boolean hasPermission = FeatureManagement.checkPermission('GoldenCopy');
            system.debug('check for permission');
            System.debug('This is the value' +hasPermission );
            if(!hasPermission )
            {
            system.debug(' has no permission');
            LeadTriggerHandler.updateParticipation(Trigger.new,Trigger.oldMap);
           }
           
            
        }
    }

}