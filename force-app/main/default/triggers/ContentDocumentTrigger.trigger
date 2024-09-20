/**
* Name of the Trigger    ContentDocumentTrigger
* Author                 Sugapriya Vanjiyappan
* Create Date            13-09-2024
* SystemLayer            Trigger Class for ContentDocumentTriggerHandler
* Description            When an attachment is Deleted from Case Object, Has_Attachment__c field will get updated with 
                        'Yes' or 'No' based on the count of attachments in Case Object record
* Classes covered        N/A
**/
trigger ContentDocumentTrigger on ContentDocument (before delete, after delete){
    Boolean hasPermission = FeatureManagement.checkPermission('ByPassAttachmentTriggers');
    if(!hasPermission )
    {
        ContentDocumentTriggerHandler handler = new ContentDocumentTriggerHandler();
        Switch on Trigger.operationType{
            when BEFORE_DELETE{
                //Before deleting an attachment from Case Object,get the Case Id
                handler.onBeforeDelete(Trigger.OldMap);
            }
            when AFTER_DELETE{
                //After deleting an attachment,change the field Has_Attachment__c value on Case Object to 'Yes' or 'No'
                handler.onAfterDelete();
            }
        }
    }
}