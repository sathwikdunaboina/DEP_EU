/***********************************************************************************************************
 *  Class Name: TaskTrigger_UpdateOwner
 *class for: Updating the owner on taks if it has Action Plan Task
 * Created Date: 6th Aug 2025
************************************************************************************************************
*******************************************   Changelog   **************************************************
S.No.    Date                    Developer Name         Azure Item Number
(1)      11th Aug 2025           Infosys                
***********************************************************************************************************/


trigger TaskTrigger_UpdateOwner on Task (after insert, after update) {
    Set<Id> apTaskIds = new Set<Id>();

    // Collect related APTask__c record Ids from Tasks where TaskAPTask__c is not null
    for (Task t : Trigger.new) {
        if (t.TaskAPTask__c != null) {
            apTaskIds.add(t.TaskAPTask__c);
        }
    }

    if (!apTaskIds.isEmpty()) {
        // Query APTask__c records and get Assigned_To__c
        Map<Id, APTask__c> apTaskMap = new Map<Id, APTask__c>(
            [SELECT Id, Assigned_To_Id__c FROM APTask__c WHERE Id IN :apTaskIds]
        );

        List<Task> tasksToUpdate = new List<Task>();

        for (Task t : Trigger.new) {
            if (t.TaskAPTask__c != null && apTaskMap.containsKey(t.TaskAPTask__c)) {
                Id assignedTo = apTaskMap.get(t.TaskAPTask__c).Assigned_To_Id__c;

                // Update only if OwnerId is different from Assigned_To__c
                if (assignedTo != null && t.OwnerId != assignedTo) {
                    Task updatedTask = new Task(
                        Id = t.Id,
                        OwnerId = assignedTo
                    );
                    tasksToUpdate.add(updatedTask);
                }
            }
        }

        if (!tasksToUpdate.isEmpty()) {
            update tasksToUpdate;
        }
    }
}