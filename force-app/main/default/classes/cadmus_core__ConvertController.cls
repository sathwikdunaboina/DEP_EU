/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class ConvertController {
    global ConvertController() {

    }
    webService static String convert(cadmus_core.ConvertController.ConvertDataModel data) {
        return null;
    }
    @AuraEnabled
    global static String convertAura(cadmus_core.ConvertController.ConvertDataModel data) {
        return null;
    }
    @AuraEnabled
    global static String convertStandaloneDocToPDF(String fileName, Blob document, String pdfAction) {
        return null;
    }
    webService static String convertToDocx(Id docConfigId, Id objectId) {
        return null;
    }
    @AuraEnabled
    global static String convertToDocxAura(Id docConfigId, Id objectId) {
        return null;
    }
    webService static String convertToPdf(Id docConfigId, Id objectId) {
        return null;
    }
    @AuraEnabled
    global static String convertToPdfAura(Id docConfigId, Id objectId) {
        return null;
    }
    webService static cadmus_core.DocGenerationWrapper convertWithWrapper(cadmus_core.ConvertController.ConvertDataModel data) {
        return null;
    }
    global static cadmus_core.DocGenerationWrapper convertWithWrapperAndInputMap(cadmus_core.ConvertController.ConvertDataModel data, Map<String,Object> inputMap) {
        return null;
    }
global class ConvertDataModel {
    webService String alternativeName {
        get;
        set;
    }
    webService String country {
        get;
        set;
    }
    webService String deliveryOverwrite {
        get;
        set;
    }
    webService Id docConfigId {
        get;
        set;
    }
    webService List<Id> docConfigIds {
        get;
        set;
    }
    webService String language {
        get;
        set;
    }
    webService String locale {
        get;
        set;
    }
    webService String numCurrLocale {
        get;
        set;
    }
    webService Id objectId {
        get;
        set;
    }
    webService Id packId {
        get;
        set;
    }
    @WebService
    webService cadmus_core.CadmusParameters parameters;
    webService String pdfActionType {
        get;
        set;
    }
    webService String targetType {
        get;
        set;
    }
    webService String timeZone {
        get;
        set;
    }
    global ConvertDataModel() {

    }
}
}
