/**
 * -------------------------------------------------------------------------------
 * @Name            VFSCORE_GlobalCustAPICAuthProviderPlugin
 * @Author          Alok Kumar <alok.kumar.3@consultant.volvo.com>
 * @CreatedDate     12th March 2024
 * @UsedBy          Custom Auth Provider - VFSCORE_GlobalCust_APIC_AuthProvider
 * @SystemLayer     Service
 * ------------------------------------------------------------------------------
 * @Description
 * Auth Provider Plugin class to provision custom auth provider - "VFSCORE_GlobalCust_APIC_AuthProvider"
 * which can be used to authenticate to VFS Azure APIC endpoint using Oauth2.0 Client Credential flow and 
 * obtain the access token to request global Customer API. This plugin class refers 
 * Custom Metadata Type - VFSCORE_GlobalCustAPIAuthProviderSetting__mdt
 * -------------------------------------------------------------------------------  
 */
public with sharing class VFSCORE_GlobalCustAPICAuthProviderPlugin extends Auth.AuthProviderPluginClass {

    public static final String RESOURCE_CALLBACK = '/services/authcallback/';
    public static final String DEFAULT_TOKEN_TYPE = 'BearerToken';
    public static final String ENCODING_XML = 'application/x-www-form-urlencoded;charset=UTF-8';
    public static final String ENCODING_JSON = 'application/json';
    public static final String DUMMY_CODE = '999';
    public static final String DOUBLEQUOTE = '"';

    // This class is dependant on this Custom Metadata Type created to hold custom parameters
    public static final String CUSTOM_MDT_NAME = 'VFSCORE_GlobalCustAPIAuthProviderSetting__mdt'; 
    public static final String CMT_FIELD_CALLBACK_URL = 'Callback_URL__c';
    public static final String CMT_FIELD_PROVIDER_NAME = 'Auth_Provider_Name__c';
    public static final String CMT_FIELD_AUTHTOKEN_URL = 'Access_Token_URL__c';
    public static final String CMT_FIELD_CLIENT_ID = 'Client_Id__c';
    public static final String CMT_FIELD_CLIENT_SECRET = 'Client_Secret__c';
    public static final String CMT_FIELD_USE_JSON = 'Use_JSON_Encoding__c';
    public static final String CMT_FIELD_SCOPE = 'Scope__c';

    public static final String GRANT_TYPE_PARAM = 'grant_type';
    public static final String CLIENT_ID_PARAM = 'client_id';
    public static final String CLIENT_SECRET_PARAM = 'client_secret';
    public static final String SCOPE_PARAM = 'scope';
    public static final String GRANT_TYPE_CLIENT_CREDS = 'client_credentials';

    public VFSCORE_GlobalCustAPICAuthProviderPlugin() {
        super();
    }

    /**
     * ----------------------------------------------------------------------------
     * @Description
       Name of custom metadata type to store this auth provider configuration fields
       This method is required by its abstract parent class.
       ----------------------------------------------------------------------------
       @returns     String      API Name of the custom metadata type used by this custom auth provider plugin
    **/
    public String getCustomMetadataType() {
        return CUSTOM_MDT_NAME;
    } 

    /**
    * ----------------------------------------------------------------------------
    * @Description
    *  Implementation of the "initiate" method of the parent class. This is the first method invoked in the
    *  Authentication process. Since no End User authorization required in this client-credential flow so 
    *  skip straight to the access token request.The parent class requires the callback url to be defined.
    * Eg: https://test.salesforce.com/services/authcallback/<authprovidername>
    *  ----------------------------------------------------------------------------    
    *  @param1      config              Auth Provider configuration.Type : Map<string,string>. Required
    *  @param2      stateToPropagate    oauth state       
    *  @returns     String      API Name of the custom metadata type used by this custom auth provider plugin
    * -----------------------------------------------------------------------------
    **/
    public PageReference initiate(Map<string,string> config, String stateToPropagate) {        
        final PageReference pageRef = new PageReference(getCallbackUrl(config));
        pageRef.getParameters().put('state',stateToPropagate);
        pageRef.getParameters().put('code',DUMMY_CODE); // Empirically found this is required, but unused
        System.debug(pageRef.getUrl());
        return pageRef;
    } 
    /**
     * ------------------------------------------------------------------------------
     * @Description
     * This method composes the callback URL automatically UNLESS it has been overridden through Configuration.
     * Normally one should not override the callback URL, but it's there in case the generated URL doesn't work.
     * e.g.https://{salesforce-hostname}/services/authcallback/{urlsuffix}
     * -----------------------------------------------------------------------------
     * @param       config      Auth Provider configuration.Type : Map<string,string>. Required
     * @returns     string      auth provider's callback url
     * -------------------------------------------------------------------------------
    **/
    private String getCallbackUrl(Map<string,string> config) {       
        final String overrideUrl = config.get(CMT_FIELD_CALLBACK_URL);
        final String generatedUrl = URL.getOrgDomainUrl().toExternalForm() + RESOURCE_CALLBACK + config.get('Auth_Provider_Name__c');
        return String.isEmpty(overrideUrl) ? generatedUrl : overrideUrl;
    }
    /**
     * -------------------------------------------------------------------------------
     * @Description
     * Implementation of Handle callback method of the parent class(from initial loop back "code" step in the flow).
     * In the Client Credentials flow, this method retrieves the access token directly.Required by parent class.
     * Error handling here is a bit painful as the UI never displays the exception or error message supplied here.
     * The exception is thrown for Logging/Debugging purposes only. 
     * ------------------------------------------------------------------------------
     * @param       config                          Auth Provider configuration.Type : Map<string,string>. Required
     * @param       state                           oauth callback state
     * @returns     Auth.AuthProviderTokenResponse  Oauth authentication response having the access token
     * -------------------------------------------------------------------------------      
     */    
    public Auth.AuthProviderTokenResponse handleCallback(Map<string,string> config, Auth.AuthProviderCallbackState state ) {
        
        final TokenResponse response = retrieveToken(config);
        if (response.isError()) {
            throw new TokenException(response.getErrorMessage());
        }
        return new Auth.AuthProviderTokenResponse(config.get(CMT_FIELD_PROVIDER_NAME)
                                                  , response.access_token
                                                  , config.get(CMT_FIELD_CLIENT_SECRET) // No Refresh Token
                                                  , state.queryParameters.get('state'));
    } 
    /**
     * ----------------------------------------------------------------------------------
     * @Description
     * Implementation of the refresh() of the parent class.This is invoked to obtain new access token 
     * by the auth provider if the original Access Token has expired.In the Client Credentials flow, 
     * there is no Refresh token, so its implementation is exactly the same as the Initiate() step.
     * ---------------------------------------------------------------------------------
     * @param       config                  Auth Provider configuration.Type : Map<string,string>. Required
     * @param       refreshToken            Oauth refresh-token. Type:String. Not required     
     * @returns     Auth.OAuthRefreshResult Oauth refresh result having new access token
     * ---------------------------------------------------------------------------------
     */
    public override Auth.OAuthRefreshResult refresh(Map<String,String> config, String refreshToken) {
        System.debug('refresh');
        final TokenResponse response = retrieveToken(config);
        return new Auth.OAuthRefreshResult(response.access_token, response.token_type);
    }

    /**
     * ---------------------------------------------------------------------------------
     * @Description
     * Implementaton of getUserInfo() method from the parent class , but not fully supported by this provider.
     * Effectively the Client Credentials flow is only useful for Server-to-Server API integrations
     * and cannot be used for other contexts such as a Registration Handler for Communities
     * --------------------------------------------------------------------------------
     * @param       config                      Auth Provider configuration
     * @param       AuthProviderTokenResponse   authentication response having userinfo as obtained from the APIC
     * @returns     Auth.UserData               Authenticated Userinfo wrapped as Userdata which can be consumed by Salesforce for user registration
     * --------------------------------------------------------------------------------     
     */
    public Auth.UserData getUserInfo(Map<string,string> config, Auth.AuthProviderTokenResponse response) {
        System.debug('getUserInfo-was-called');
        final TokenResponse token = retrieveToken(config);

        final Auth.UserData userData = new Auth.UserData(
              token.application_name // identifier
            , null // firstName
            , null // lastName
            , null // fullName
            , token.developer_email // email
            , null // link
            , token.developer_email // userName
            , null  //locale
            , config.get(CMT_FIELD_PROVIDER_NAME) //provider
            , null // siteLoginUrl
            , new Map<String,String>());
        return userData;
    }
    
    /**
     * ----------------------------------------------------------------------------
     * @Description
     * Private method that invokes access token endpoint to obtain the Auth Token using the Client Credentials Flow
     * ----------------------------------------------------------------------------
     * @param       config          Auth Provider configuration
     * @returns     TokenResponse   Apex-Defined TokenResponse having access token
     * ----------------------------------------------------------------------------   
     */
     private TokenResponse retrieveToken(Map<String,String> config) {         
        System.debug('retrieveToken');

        final Boolean useJSONEncoding = Boolean.valueOf(config.get(CMT_FIELD_USE_JSON));        
        final HttpRequest req = new HttpRequest();
        final PageReference endpoint = new PageReference(config.get(CMT_FIELD_AUTHTOKEN_URL)); 

        // Determine whether or not to use JSON encoding
        final String encoding = useJSONEncoding ? ENCODING_JSON : ENCODING_XML;
        final String encodedParams = encodeParameters(config,encoding);

        System.debug('Endpoint: ' + endpoint.getUrl());
        System.debug('Content-Type:' + encoding);
        System.debug('Body:' + encodedParams);

        req.setEndpoint(endpoint.getUrl()); 
        req.setHeader('Content-Type',encoding); 
        req.setMethod('POST'); 
        req.setBody(encodedParams);

        final HTTPResponse res = new Http().send(req); 

        System.debug('Token Response Status: ' + res.getStatus() + ' ' + res.getStatusCode());
        final Integer statusCode = res.getStatusCode();

        if ( statusCode == 200) {
            TokenResponse token =  deserializeToken(res.getBody());
            // Ensure values for key fields
            token.token_type = (token.token_type == null) ? DEFAULT_TOKEN_TYPE : token.token_type;
            return token;

        } else  {
            return deserializeToken(res.getBody());
        }
    }
    
    //deserialise response and return token
    @testVisible
    private TokenResponse deserializeToken(String responseBody) {        
        System.debug('token response:' +responseBody);        
        // use default parsing for everything we can.
        System.debug('>>> responseBody = ' + responseBody);
        TokenResponse parsedResponse = (TokenResponse) System.JSON.deserialize(responseBody, TokenResponse.class);
        // explicitly parse out the developer.email property because it's an illegal identifier
        Map<String,Object> props = (Map<String,Object>) System.JSON.deserializeUntyped(responseBody);
        parsedResponse.developer_email = (String) props.get('developer.email');       
        return parsedResponse;
    }

    /**
        Conditionally encode parameters as URL-style or JSON
    **/
    @testVisible
    private String encodeParameters(Map<String,String> config,String encoding) {

        // Pull out the subset of configured parameters that will be sent
        Map<String,String> params = new Map<String,String>();
        params.put(GRANT_TYPE_PARAM,GRANT_TYPE_CLIENT_CREDS);
        params.put(CLIENT_ID_PARAM, config.get(CMT_FIELD_CLIENT_ID));
        params.put(CLIENT_SECRET_PARAM, config.get(CMT_FIELD_CLIENT_SECRET));
        final String scope = config.get(CMT_FIELD_SCOPE);
        if (!String.isEmpty(scope)) {
            params.put(SCOPE_PARAM,scope);
        }

        return encoding == ENCODING_JSON ? encodeAsJSON(params) : encodeAsURL(params);
    }

    private String encodeAsJSON(Map<String,String> params) {
        String output = '{';
        for (String key : params.keySet()) {
            output += (output == '{' ? '' : ', ');
            output += DOUBLEQUOTE + key + DOUBLEQUOTE + ':';
            output += DOUBLEQUOTE + params.get(key) + DOUBLEQUOTE;
        }
        output += '}';
        return output;
    }

    private String encodeAsURL(Map<String,String> params) {
        String output = '';
        for (String key : params.keySet()) {
            output += (String.isEmpty(output) ? '' : '&');
            output += key + '=' + params.get(key);
        }
        return output;
    }

    /**
    OAuth Response is a JSON body like this on a Successful call
    {
      "refresh_token_expires_in" : "0",
      "api_product_list" : "[helloworld, HelloWorld_OAuth2-Product]",
      "api_product_list_json" : [ "helloworld", "HelloWorld_OAuth2-Product" ],
      "organization_name" : "bobbywhite-eval",
      "developer.email" : "developer@example.com",
      "token_type" : "BearerToken",
      "issued_at" : "1520478821362",
      "client_id" : "someKey",
      "access_token" : "kRxqmPr2b223uzTUGnndQhXWv8F4",
      "application_name" : "47bc6c8d-34f3-4141-b9e6-f1679a8240e7",
      "scope" : "",
      "expires_in" : "3599",
      "refresh_count" : "0",
      "status" : "approved"
    }
    On failure, the following structure from Apigee Edge (cloud hosted Gateway)
    { 
      "ErrorCode" : "invalid_client"
    , "Error" : "Client credentials are invalid"
    }
    The following response class is the Union of all responses
    **/

    public class TokenResponse {
        public String refresh_token_expires_in {get;set;}
        public String api_product_list {get;set;}
        public List<String> api_product_list_json {get;set;}
        public String organization_name {get;set;}
        public String developer_email {get;set;}
        public String token_type {get;set;}
        public String issued_at {get;set;}
        public String client_id {get;set;}
        public String access_token {get;set;}
        public String application_name {get;set;}
        public String scope {get;set;}
        public String expires_in {get;set;}
        public String refresh_count {get;set;}
        public String status {get;set;}

        public String ErrorCode {get; set;}
        public String Error {get; set;}        
        public Fault fault {get; set;}

        public Boolean isError() {
            return Error != null || fault != null;
        }

        public String getErrorMessage() {
            if (Error != null) {
                return ErrorCode;
            }

            if (fault != null) {               
                return fault.faultString.replace('{0}',fault.detail.errorcode);
            }
            return null;
        }
    }

    public class Fault {
        public String faultstring {get;set;}
        public Detail detail {get;set;}
    }

    public class Detail {
        public String errorcode {get;set;}
    }

    /**
        Custom exception type so we can wrap and rethrow
    **/
    public class TokenException extends Exception {

    }
}