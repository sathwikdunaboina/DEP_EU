/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class QueueItemPayload {
    @InvocableVariable( required=false)
    global String fieldSet;
    global Id invitationId;
    @InvocableVariable( required=false)
    global String medProgramId;
    global SObject obj;
    global String payloadType;
    @InvocableVariable( required=true)
    global Id recordId;
    @InvocableVariable( required=false)
    global String reportId;
    @InvocableVariable( required=false)
    global Boolean sendInvite;
    @InvocableVariable( required=false)
    global String sendInviteToRole;
    @InvocableVariable( required=true)
    global String service;
    @InvocableVariable( required=true)
    global Datetime whenToSend;
    global QueueItemPayload() {

    }
}
