/***********************************************************************************************************
 * Class Name: APTaskTrigger_UpdateAssignedName  helper class
 *  class for: Assigning the name of queue to Task Assigned Name field to show on Action Plan VF page
 * Created Date: 11th Aug 2025
************************************************************************************************************
*******************************************   Changelog   **************************************************
S.No.    Date                    Developer Name         Azure Item Number
(1)      11th Aug 2025           Infosys                
***********************************************************************************************************/


trigger APTaskTrigger_UpdateAssignedName on APTask__c (after insert, after update) {
    Set<Id> queueIds = new Set<Id>();
    Set<Id> userIds = new Set<Id>();

    // Collect Queue Ids
    for (APTask__c task : Trigger.new) {
        if (task.Assigned_To_Id__c != null && String.valueOf(task.Assigned_To_Id__c).startsWith('00G')) {
            queueIds.add(task.Assigned_To_Id__c);
        }
        if (task.User__c != null && String.valueOf(task.User__c).startsWith('005')) {
            userIds.add(task.User__c);
        }
    }
    
    // Query queues
    Map<Id, Group> queueMap = new Map<Id, Group>();
    if (!queueIds.isEmpty()) {
        queueMap = new Map<Id, Group>([
            SELECT Id, Name FROM Group WHERE Id IN :queueIds AND Type = 'Queue'
        ]);
    }

    // Query users
    Map<Id, User> userMap = new Map<Id, User>();
    if (!userIds.isEmpty()) {
        userMap = new Map<Id, User>([
            SELECT Id, Name FROM User WHERE Id IN :userIds
        ]);
    }

    // Use Map to avoid duplicate Ids
    Map<Id, APTask__c> updateMap = new Map<Id, APTask__c>();

    for (APTask__c task : Trigger.new) {
        if (task.Assigned_To_Id__c != null && queueMap.containsKey(task.Assigned_To_Id__c)) {
            String queueName = queueMap.get(task.Assigned_To_Id__c).Name;
            if (task.Assigned_To_Name__c != queueName) {
                updateMap.put(task.Id, new APTask__c(
                    Id = task.Id,
                    Assigned_To_Name__c = queueName
                ));
            }
        } else if (task.User__c != null && userMap.containsKey(task.User__c)) {
            String userName = userMap.get(task.User__c).Name;
            if (task.Assigned_To_Name__c != userName) {
                updateMap.put(task.Id, new APTask__c(
                    Id = task.Id,
                    Assigned_To_Name__c = userName
                ));
            }
        }
    }

    if (!updateMap.isEmpty()) {
        update updateMap.values();
    }
}