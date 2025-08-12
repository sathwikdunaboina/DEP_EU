trigger SetLeadRecordTypeOnTask on Task (before insert, before update) {
    TaskTriggerHandler.handleTasks(Trigger.new);
}