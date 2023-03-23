/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class CadmusHttpResponse {
    global List<cadmus_core.CadmusHttpResponse.ChildDocConfigResult> additionalDocs {
        get;
        set;
    }
    global String adminKey {
        get;
        set;
    }
    global String adminUserName {
        get;
        set;
    }
    global List<String> allowedStages {
        get;
        set;
    }
    global Blob base64 {
        get;
        set;
    }
    global String encryptKey {
        get;
        set;
    }
    global List<cadmus_core.CadmusHttpResponse.Issue> issues {
        get;
        set;
    }
    global String key {
        get;
        set;
    }
    global cadmus_core.MetadataWrapper metadata {
        get;
        set;
    }
    global String result {
        get;
        set;
    }
    global String userKey {
        get;
        set;
    }
    global CadmusHttpResponse() {

    }
global class ChildDocConfigResult {
    global String attachmentId {
        get;
        set;
    }
    global Blob base64 {
        get;
        set;
    }
    global String contentDocumentId {
        get;
        set;
    }
    global String contentDocumentLinkId {
        get;
        set;
    }
    global String contentVersionId {
        get;
        set;
    }
    global String customerDocumentConfigId {
        get;
        set;
    }
    global String targetName {
        get;
        set;
    }
    global ChildDocConfigResult() {

    }
}
global class Issue {
    global String description {
        get;
        set;
    }
    global String level {
        get;
        set;
    }
    global Issue() {

    }
}
}
