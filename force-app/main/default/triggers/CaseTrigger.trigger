trigger CaseTrigger on Case (after insert,after Update) {
    if(Trigger.IsAfter && Trigger.IsInsert){
        system.debug('SourceId'+Trigger.new[0].SourceId);
        system.debug('IsInsert');
    }
    if(Trigger.IsAfter && Trigger.IsUpdate){
        system.debug('SourceId'+Trigger.new[0].SourceId);
        system.debug('IsUpdate');
    }
    
}