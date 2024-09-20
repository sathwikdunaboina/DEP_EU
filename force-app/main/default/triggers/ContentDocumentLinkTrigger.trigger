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
            //After inserting an attachment,change the field Has_Attachment__c value on Case Object to 'Yes'
            handler.onAfterInsert(Trigger.NewMap);
        }
        when BEFORE_DELETE{
            //Before unlinking an attachment from Case Object,get the Case Id
            handler.onBeforeDelete(Trigger.OldMap);
        }
        when AFTER_DELETE{
            //After unlinking an attachment,change the field Has_Attachment__c value on Case Object to 'Yes' or 'No'
            handler.onAfterDelete();
        }
    }
    }
}