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
                handler.onBeforeDelete(Trigger.OldMap);
            }
            when AFTER_DELETE{
                handler.onAfterDelete();
            }
        }
    }
}