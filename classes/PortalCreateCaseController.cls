public without sharing class PortalCreateCaseController {
    @AuraEnabled
    public static List<String> getTypeSelectList(String objectName, String fieldName){
        List<String> lstPickvals=new List<String>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objectName);
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType();
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
        List<Schema.PicklistEntry> pick_list_values = field_map.get(fieldName).getDescribe().getPickListValues(); 
        for (Schema.PicklistEntry a : pick_list_values) {
            lstPickvals.add(a.getValue());
        }
        lstPickvals.sort();
        return lstPickvals;
    }
    
    @AuraEnabled
    public static Case createUserCase(Case caseObj){
        try {
            Contact contactObj = PortalUtility.getContactDetail();
            AssignmentRule assignmentObj = new AssignmentRule();
            assignmentObj = [SELECT Id FROM AssignmentRule WHERE SobjectType = 'Case' AND Active = true LIMIT 1];
            Database.DMLOptions dmlOptnsObj = new Database.DMLOptions();
            dmlOptnsObj.assignmentRuleHeader.assignmentRuleId= assignmentObj.id;
            caseObj.setOptions(dmlOptnsObj);
            caseObj.ContactId = contactObj.Id;
            caseObj.Origin = 'Portal';
            //caseObj.Country__c = 'Italy';//Italy_Case_Country
            insert caseObj;
            return caseObj;
        }catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage()+' '+ex.getCause()+' '+ex.getLineNumber());
        }
    }
    
    @AuraEnabled
    public static void caseResponseEmail(Id caseId) {
        if(caseId != null) {
            Case c = [SELECT Id,ContactId,Contact.Email,Contact.FirstName FROM Case WHERE Id =: caseId];
            String emailTemplateName = System.Label.Case_Auto_Response_Email_Template;  // Added by Sumit
            EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE Name =: emailTemplateName];
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTemplateId(template.Id);
            mail.setSaveAsActivity(false);
            
            if (c.ContactId != null) {
                mail.setTargetObjectId(c.ContactId);
                mail.setWhatId(caseId); // Added By Sumit
                mail.setTreatTargetObjectAsRecipient(false);
                if (c.Contact.Email != null) {
                    List<String> adds = new List<String>();
                    adds.add(c.Contact.Email);
                    mail.setToAddresses(adds);
                }
            }
            List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
            allmsg.add(mail);
            Messaging.SendEmailResult[] result;
            result = Messaging.sendEmail(allmsg, false);
            if (result[0].success) {
                System.debug('The email was sent successfully.');
            } else {
                throw new AuraHandledException('The email failed to send: ' +result[0].errors[0].message);
            }
        }
    }
}