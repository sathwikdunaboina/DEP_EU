/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class MetadataWrapper {
    global String alternativeName {
        get;
        set;
    }
    global static String alternativeNameStatic {
        get;
        set;
    }
    global static String DeliveryTypeStatic {
        get;
        set;
    }
    global Boolean isSandbox {
        get;
        set;
    }
    global cadmus_core.MetadataWrapper.CadmusLocale locale {
        get;
        set;
    }
    global static cadmus_core.MetadataWrapper.CadmusLocale localeStatic {
        get;
        set;
    }
    global cadmus_core.MetadataWrapper.CadmusLocale numCurrLocale {
        get;
        set;
    }
    global static cadmus_core.MetadataWrapper.CadmusLocale numCurrLocaleStatic {
        get;
        set;
    }
    global String organizationId {
        get;
        set;
    }
    global String pdfActionType {
        get;
        set;
    }
    global static String pdfActionTypeStatic {
        get;
        set;
    }
    global String stage {
        get;
        set;
    }
    global String targetId {
        get;
        set;
    }
    global String targetName {
        get;
        set;
    }
    global String targetType {
        get;
        set;
    }
    global static String targetTypeStatic {
        get;
        set;
    }
    global cadmus_core.MetadataWrapper.USAGE_TYPE usageType {
        get;
        set;
    }
    global String userId {
        get;
        set;
    }
    global String userType {
        get;
        set;
    }
    global String version {
        get;
        set;
    }
    global MetadataWrapper() {

    }
    global MetadataWrapper(String targetName, String targetId) {

    }
global class CadmusLocale {
    global String country {
        get;
        set;
    }
    global String language {
        get;
        set;
    }
    global String locale {
        get;
        set;
    }
    global String timezone {
        get;
        set;
    }
    global CadmusLocale() {

    }
}
global enum USAGE_TYPE {BATCH, COMMUNITY, MASS_VOLUME, NORMAL}
}
