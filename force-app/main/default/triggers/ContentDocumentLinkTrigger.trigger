trigger ContentDocumentLinkTrigger on ContentDocumentLink (before insert,after insert,before delete,after delete) {
    Boolean hasPermission = FeatureManagement.checkPermission('ByPassAttachmentTriggers');
    if(!hasPermission )
    {
    
    ContentDocumentLinkTriggerHandler handler = new ContentDocumentLinkTriggerHandler();
    Switch on Trigger.operationType{
        when BEFORE_INSERT{
            
            for (ContentDocumentLink cLink : Trigger.New){
                //If the document is attached to the contract record, 
                //then the external users who has access to the contract record
                //should also have access to the document.
                if('Contract__c'.equalsIgnoreCase(cLink.LinkedEntityId.getSObjectType().getDescribe().getName())){
                    cLink.Visibility = 'AllUsers';
                    cLink.ShareType = 'I';
                }
            }
            
            handler.onBeforeInsert(Trigger.New);
        }
        when AFTER_INSERT{
            handler.onAfterInsert(Trigger.NewMap);
        }
        when BEFORE_DELETE{
            //do nothing
        }
        when AFTER_DELETE{
            handler.onAfterDelete(Trigger.OldMap);
        }
    }
    }
}