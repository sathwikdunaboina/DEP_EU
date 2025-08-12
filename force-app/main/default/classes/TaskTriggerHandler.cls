/* 
* -----------------------------------------------------------------------------------------
* Apex Class Name     TaskTriggerHandler
* @author             Swami Goskula<Swami.goskula@consulant.volvo.com>
* @Created Date       08-04-2025 
* @Used By            New Task Global action button on Lead and Opportunity
* ------------------------------------------------------------------------------------------
* @description        Used in New Task Global action button on Lead and Opportunity to display Subject Picklist values based on record type
* ------------------------------------------------------------------------------------------------------------------------------------------
*/
public class TaskTriggerHandler {
    public static void handleTasks(List<Task> taskList) {
        List<New_task__mdt> restrictions = [
            SELECT Subject__c, ObjectType__c, RecordTypeDevName__c, IsRestricted__c, ErrorMessage__c
            FROM New_task__mdt
            WHERE IsRestricted__c = true
        ];

        Set<Id> leadIds = new Set<Id>();
        Set<Id> oppIds = new Set<Id>();

        for (Task t : taskList) {
            if (t.WhoId != null && t.WhoId.getSObjectType() == Lead.SObjectType) {
                leadIds.add(t.WhoId);
            }
            if (t.WhatId != null && t.WhatId.getSObjectType() == Opportunity.SObjectType) {
                oppIds.add(t.WhatId);
            }
        }

        Map<Id, Lead> leadMap = leadIds.isEmpty() ? new Map<Id, Lead>() :
            new Map<Id, Lead>([SELECT Id, RecordType.DeveloperName FROM Lead WHERE Id IN :leadIds]);

        Map<Id, Opportunity> oppMap = oppIds.isEmpty() ? new Map<Id, Opportunity>() :
            new Map<Id, Opportunity>([SELECT Id, RecordType.DeveloperName FROM Opportunity WHERE Id IN :oppIds]);

        for (Task t : taskList) {
            String subject = t.Subject;
            if (String.isBlank(subject)) continue;

            for (New_task__mdt rule : restrictions) {
                if (!rule.Subject__c.equalsIgnoreCase(subject)) continue;

                // Lead validation
                if (rule.ObjectType__c == 'Lead' && t.WhoId != null && leadMap.containsKey(t.WhoId)) {
                    String leadRT = leadMap.get(t.WhoId).RecordType.DeveloperName;
                    if (leadRT.equalsIgnoreCase(rule.RecordTypeDevName__c)) {
                        t.Subject.addError(rule.ErrorMessage__c);
                    }
                }

                // Opportunity validation
                if (rule.ObjectType__c == 'Opportunity' && t.WhatId != null && oppMap.containsKey(t.WhatId)) {
                    String oppRT = oppMap.get(t.WhatId).RecordType.DeveloperName;
                    if (oppRT.equalsIgnoreCase(rule.RecordTypeDevName__c)) {
                        t.Subject.addError(rule.ErrorMessage__c);
                    }
                }
            }
        }
    }
}