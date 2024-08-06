public class LeadTriggerHandler {
    
    public static void updateParticipation(List<Lead> newlist,Map<Id,Lead> oldList){
        
        for (Lead l1:newlist){
            if(l1.Status=='Converted' && oldList!=null && l1.Status!=oldList.get(l1.Id).Status){
                l1.Participated__c='Yes';
                        
            }
        }
        
    }

}