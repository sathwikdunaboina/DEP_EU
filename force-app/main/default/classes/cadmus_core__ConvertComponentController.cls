/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class ConvertComponentController {
    global ConvertComponentController() {

    }
    @AuraEnabled
    global static String convert(Id docConfigId, String docConfigIds, Id objectId, String locale, String alternative, String targetType) {
        return null;
    }
    @AuraEnabled
    global static String convert(Id docConfigId, String docConfigIds, Id objectId, String locale, String alternative, String targetType, String pdfActionType, String contentDocumentIds, Id packId) {
        return null;
    }
    @AuraEnabled
    global static String convert(Id docConfigId, String docConfigIds, Id objectId, String locale, String alternative, String targetType, String pdfActionType, String contentDocumentIds, Id packId, String DeliveryTypeOverwrite) {
        return null;
    }
    @AuraEnabled
    global static String convert(Id docConfigId, String docConfigIds, Id objectId, String locale, String numCurrLocale, String alternative, String targetType, String pdfActionType, String contentDocumentIds, Id packId, String DeliveryTypeOverwrite) {
        return null;
    }
    @AuraEnabled
    global static String convert(Id docConfigId, String docConfigIds, Id objectId, String locale, String numCurrLocale, String alternative, String targetType, String pdfActionType, String contentDocumentIds, Id packId, String DeliveryTypeOverwrite, String paramsAsJson) {
        return null;
    }
    @AuraEnabled
    global static String convert(Id docConfigId, String docConfigIds, Id objectId, String locale, String numCurrLocale, String alternative, String targetType, String pdfActionType, String contentDocumentIds, Id packId, String DeliveryTypeOverwrite, String paramsAsJson, Boolean base64Required) {
        return null;
    }
    @AuraEnabled
    global static String convertFromDocument(String docConfigIdsAsString, Id objectId, Id packId, String documentAsString) {
        return null;
    }
    @AuraEnabled
    global static String initServer(String docConfigIds) {
        return null;
    }
    @AuraEnabled
    global static String initServer(String docConfigIds, String packDocConfigId) {
        return null;
    }
    @AuraEnabled
    global static String initServer(String docConfigIds, String packDocConfigId, String docConfigTranslationDataSourceId) {
        return null;
    }
    @AuraEnabled
    global static String initServer(String docConfigIds, String packDocConfigId, String docConfigTranslationDataSourceId, String packDocConfigIds) {
        return null;
    }
    @AuraEnabled
    global static String initServerFileSelector(String objectId, String packDocConfigIds) {
        return null;
    }
    @AuraEnabled
    global static String initServerFileSelector(String objectId, String packDocConfigIds, Integer maxNrOfFiles) {
        return null;
    }
    @AuraEnabled
    global static String initServerPreview(String docConfigIds, String packDocConfigIds) {
        return null;
    }
    @AuraEnabled
    global static String initServerPreviewCached(String docConfigIds, String packDocConfigIds) {
        return null;
    }
    @AuraEnabled
    global static String saveFromDocument(Id objectId, String documentAsString) {
        return null;
    }
global class InitData {
    global User currentUser {
        get;
        set;
    }
    global List<cadmus_core__Doc_Config__c> docConfigs {
        get;
        set;
    }
    global List<cadmus_core.CadmusHttpResponse.ChildDocConfigResult> files {
        get;
        set;
    }
    global String instanceName;
    global Boolean isSite {
        get;
        set;
    }
    global cadmus_core__Pack__c pack {
        get;
        set;
    }
    global List<cadmus_core__Pack__c> packs {
        get;
        set;
    }
    global String sessionId;
    global cadmus_core__Cadmus_Setting__c settings;
    global String sitePrefix {
        get;
        set;
    }
    global String translationJson {
        get;
        set;
    }
    global InitData() {

    }
}
}
