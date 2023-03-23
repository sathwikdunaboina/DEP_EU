/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class CadmusKeyValue {
    @AuraEnabled
    @InvocableVariable(label='Unique Key for the value.' required=false)
    global String key;
    @AuraEnabled
    @InvocableVariable(label='Boolean value' required=false)
    global Boolean valueBoolean;
    @AuraEnabled
    @InvocableVariable(label='Date value' required=false)
    global Date valueDate;
    @AuraEnabled
    @InvocableVariable(label='DateTime value' required=false)
    global Datetime valueDateTime;
    @AuraEnabled
    @InvocableVariable(label='Double value' required=false)
    global Double valueDouble;
    @AuraEnabled
    @InvocableVariable(label='Multi Select Picklist value (list split by "; ")' required=false)
    global String valueMultiSelect;
    @AuraEnabled
    @InvocableVariable(label='String value' required=false)
    global String valueString;
    global CadmusKeyValue() {

    }
}
