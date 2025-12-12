/*trigger APTemplateTaskTrigger on APTemplateTask__c (after insert, after update) {
    Set<Id> queueIds = new Set<Id>();

    // Collect Assigned_To_Id__c values that start with '00G' (Queue Ids)
    for (APTemplateTask__c task : Trigger.new) {
        if (task.Assigned_To_Id__c != null && String.valueOf(task.Assigned_To_Id__c).startsWith('00G')
           ) {
            queueIds.add(task.Assigned_To_Id__c);
        }
    }

    if (!queueIds.isEmpty()) {
        // Query QueueSObject to get Queue Names
        Map<Id, Group> queueMap = new Map<Id, Group>(
            [SELECT Id, Name FROM Group WHERE Id IN :queueIds AND Type = 'Queue']
        );

        List<APTemplateTask__c> recordsToUpdate = new List<APTemplateTask__c>();

        for (APTemplateTask__c task : Trigger.new) {
            if (
                task.Assigned_To_Id__c != null &&
                queueMap.containsKey(task.Assigned_To_Id__c)
            ) {
                String queueName = queueMap.get(task.Assigned_To_Id__c).Name;

                // Update only if different
                if (task.Assigned_To_Name__c != queueName) {
                    APTemplateTask__c updatedTask = new APTemplateTask__c(
                        Id = task.Id,
                        Assigned_To_Name__c = queueName
                    );
                    recordsToUpdate.add(updatedTask);
                }
            }
        }

        if (!recordsToUpdate.isEmpty()) {
            update recordsToUpdate;
        }
    }
}*/
/***********************************************************************************************************
 * Class Name: APTemplateTaskTrigger  
 *  class for: Assigning the name of queue to Template Tasks Assigned Name field to show on Action Plan template detail VF page
 * Created Date: 11th Aug 2025
************************************************************************************************************
*******************************************   Changelog   **************************************************
S.No.    Date                    Developer Name         Azure Item Number
(1)      11th Aug 2025           Infosys                
***********************************************************************************************************/
trigger APTemplateTaskTrigger on APTemplateTask__c (after insert, after update) {
    Set<Id> queueIds = new Set<Id>();

    for (APTemplateTask__c task : Trigger.new) {
        // Handle insert: if Assigned_To_Id__c is a Queue
        if (Trigger.isInsert && task.Assigned_To_Id__c != null && 
            String.valueOf(task.Assigned_To_Id__c).startsWith('00G')) {
            queueIds.add(task.Assigned_To_Id__c);
        }

        // Handle update: if Assigned_To_Id__c has changed and new value is a Queue
        if (Trigger.isUpdate) {
            APTemplateTask__c oldTask = Trigger.oldMap.get(task.Id);
            if (task.Assigned_To_Id__c != oldTask.Assigned_To_Id__c &&
                task.Assigned_To_Id__c != null &&
                String.valueOf(task.Assigned_To_Id__c).startsWith('00G')) {
                queueIds.add(task.Assigned_To_Id__c);
            }
        }
    }

    if (!queueIds.isEmpty()) {
        Map<Id, Group> queueMap = new Map<Id, Group>(
            [SELECT Id, Name FROM Group WHERE Id IN :queueIds AND Type = 'Queue']
        );

        List<APTemplateTask__c> recordsToUpdate = new List<APTemplateTask__c>();

        for (APTemplateTask__c task : Trigger.new) {
            Boolean shouldUpdate = false;

            // For insert: directly update if valid queue
            if (Trigger.isInsert && 
                task.Assigned_To_Id__c != null &&
                queueMap.containsKey(task.Assigned_To_Id__c)) {
                shouldUpdate = true;
            }

            // For update: update only if Assigned_To_Id__c has changed
            if (Trigger.isUpdate) {
                APTemplateTask__c oldTask = Trigger.oldMap.get(task.Id);
                if (task.Assigned_To_Id__c != oldTask.Assigned_To_Id__c &&
                    task.Assigned_To_Id__c != null &&
                    queueMap.containsKey(task.Assigned_To_Id__c)) {
                    shouldUpdate = true;
                }
            }

            if (shouldUpdate) {
                String queueName = queueMap.get(task.Assigned_To_Id__c).Name;

                if (task.Assigned_To_Name__c != queueName) {
                    recordsToUpdate.add(new APTemplateTask__c(
                        Id = task.Id,
                        Assigned_To_Name__c = queueName
                    ));
                }
            }
        }

        if (!recordsToUpdate.isEmpty()) {
            update recordsToUpdate;
        }
    }
}