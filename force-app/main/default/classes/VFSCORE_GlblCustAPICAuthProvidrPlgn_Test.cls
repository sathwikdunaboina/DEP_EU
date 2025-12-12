@isTest
public class VFSCORE_GlblCustAPICAuthProvidrPlgn_Test {
    
    
            
    private static final String RESOURCE_CALLBACK = '/services/authcallback/';
    private static final String DEFAULT_TOKEN_TYPE = 'BearerToken';
    private static final String ENCODING_XML = 'application/x-www-form-urlencoded;charset=UTF-8';
    private static final String ENCODING_JSON = 'application/json';
    private static final String DUMMY_CODE = '999';
    private static final String DOUBLEQUOTE = '"';


    private static final String AUTH_URL = 'http://www.dummy.com/authurl'; 
    private static final String CALLBACK_URL = 'http://www.dummycallback.com/authurl';
    private static final String CLIENT_ID = 'demo_clientId';
    private static final String SECRET = 'demoSecret';
    private static final String SCOPE = 'demoScope';
    private static final String ACCESS_TOKEN = 'nhgabu67q8rt43wejmgbi38o48wfimou.dhuebtt7we74867';
    private static final String PROVIDER = 'VFSCORE_GlobalCustAPICAuthProviderPlugin';
    private static final String OAUTH_TOKEN = ACCESS_TOKEN;


    private static final String CUSTOM_MDT_NAME = 'VFSCORE_GlobalCustAPIAuthProviderSetting__mdt'; 
    private static final String CMT_FIELD_CALLBACK_URL = 'Callback_URL__c';
    private static final String CMT_FIELD_PROVIDER_NAME = 'Auth_Provider_Name__c';
    private static final String CMT_FIELD_AUTHTOKEN_URL = 'Access_Token_URL__c';
    private static final String CMT_FIELD_CLIENT_ID = 'Client_Id__c';
    private static final String CMT_FIELD_CLIENT_SECRET = 'Client_Secret__c';
    private static final String CMT_FIELD_USE_JSON = 'Use_JSON_Encoding__c';
    private static final String CMT_FIELD_SCOPE = 'Scope__c';

    private static final String GRANT_TYPE_PARAM = 'grant_type';
    private static final String CLIENT_ID_PARAM = 'client_id';
    private static final String CLIENT_SECRET_PARAM = 'client_secret';
    private static final String SCOPE_PARAM = 'scope';
    private static final String GRANT_TYPE_CLIENT_CREDS = 'client_credentials';

    private static final String STATE_TO_PROPOGATE = 'testState';
            
    // In the real world scenario, the key and value would be read 
    // from the (custom fields in) custom metadata type record. 
    private static Map<String,String> setupAuthProviderConfig () 
    { 
        Map<String,String> config = new Map<String,String>(); 
        config.put(CMT_FIELD_CALLBACK_URL, CALLBACK_URL); 
        config.put(CMT_FIELD_USE_JSON, ENCODING_JSON);
        config.put(CMT_FIELD_AUTHTOKEN_URL, AUTH_URL);
        config.put(CMT_FIELD_CLIENT_ID, CLIENT_ID);
        config.put(CMT_FIELD_CLIENT_SECRET, SECRET);
        config.put(CMT_FIELD_SCOPE, SCOPE);
        config.put('State_c', STATE_TO_PROPOGATE);
        config.put(CMT_FIELD_PROVIDER_NAME, PROVIDER);

        // config.put('Auth_Url__c', AUTH_URL); 
        // config.put('Secret__c', SECRET); 
        // config.put('Access_Token_Url__c', ACCESS_TOKEN_URL); 
        // config.put('API_User_Url__c',API_USER_URL); 
        // config.put('API_User_Version_Url__c',
        // API_USER_VERSION_URL); 
        // config.put('Redirect_Url__c',REDIRECT_URL); 
        return config; 
    
    } 
    
    @isTest
    static void getCustomMetadataType_Test() {
        VFSCORE_GlobalCustAPICAuthProviderPlugin obj = new VFSCORE_GlobalCustAPICAuthProviderPlugin();
        obj.getCustomMetadataType();
    }

    @isTest
    static void testInitiateMethod() 
    { 
        String stateToPropagate = 'mocktestState'; 
        Map<String,String> config = setupAuthProviderConfig(); 
        VFSCORE_GlobalCustAPICAuthProviderPlugin objVFSCORE_GlobalCustAPICAuthProviderPlugin = new VFSCORE_GlobalCustAPICAuthProviderPlugin(); 
        // objVFSCORE_GlobalCustAPICAuthProviderPlugin.redirectUrl = config.get('Redirect_Url__c'); 
        PageReference expectedUrl = new PageReference(config.get(CMT_FIELD_CALLBACK_URL)); 
        expectedUrl.getParameters().put('state',STATE_TO_PROPOGATE);
        expectedUrl.getParameters().put('code',DUMMY_CODE);
        System.debug('>>> config.get(CMT_FIELD_CALLBACK_URL) = ' + config.get(CMT_FIELD_CALLBACK_URL));
        PageReference actualUrl = objVFSCORE_GlobalCustAPICAuthProviderPlugin.initiate(config, STATE_TO_PROPOGATE); 
        System.assertEquals(expectedUrl.getUrl(), actualUrl.getUrl());
    } 
    
    static testMethod void testHandleCallback() 
    { 
        Map<String,String> config = setupAuthProviderConfig(); 
        VFSCORE_GlobalCustAPICAuthProviderPlugin objVFSCORE_GlobalCustAPICAuthProviderPlugin = new VFSCORE_GlobalCustAPICAuthProviderPlugin(); 
        // objVFSCORE_GlobalCustAPICAuthProviderPlugin.redirectUrl = config.get
        // ('Redirect_Url_c'); 
    
        VFSCORE_GlobalCustAPICAuthProviderPlugin.TokenResponse objTknRes = new VFSCORE_GlobalCustAPICAuthProviderPlugin.TokenResponse();
        objTknRes.refresh_token_expires_in = '3599';
        objTknRes.api_product_list = 'apiprodlist';
        objTknRes.api_product_list_json = new List<String>{'list_json'};
        objTknRes.organization_name = 'org_name';
        objTknRes.developer_email = 'demo@demo.com';
        objTknRes.token_type = 'bearer';
        objTknRes.issued_at = 'issuedAt';
        objTknRes.client_id = CLIENT_ID;
        objTknRes.access_token = ACCESS_TOKEN;
        objTknRes.application_name = 'applnname';
        objTknRes.scope = SCOPE;
        objTknRes.expires_in = '3599';
        objTknRes.refresh_count = '4';
        objTknRes.status = 'ok';
        // objTknRes.
        String strResponseBody = JSON.serialize(objTknRes);
        HTTPMockFactory mock = new HTTPMockFactory(
        200,
        'OK',
        strResponseBody,
        new Map<String, String>()
        );
        Test.setMock(HttpCalloutMock.class, mock); 
    
        Map<String,String> queryParams = new Map<String,String>(); 
        queryParams.put('code','code'); 
        queryParams.put('state',config.get('State_c')); 
        Auth.AuthProviderCallbackState cbState = new Auth.AuthProviderCallbackState(null,null,queryParams); 
        System.debug('>>> cbState = ' + cbState);

        Auth.AuthProviderTokenResponse actualAuthProvResponse = objVFSCORE_GlobalCustAPICAuthProviderPlugin.handleCallback(config, cbState);
        System.debug('>>> actualAuthProvResponse = ' + actualAuthProvResponse);
        
        // AuthProviderTokenResponse:[oauthSecretOrRefreshToken=demoSecret, oauthToken=nhgabu67q8rt43wejmgbi38o48wfimou.dhuebtt7we74867, provider=null, state=testState]


        Auth.AuthProviderTokenResponse expectedAuthProvResponse = new Auth.AuthProviderTokenResponse(PROVIDER, ACCESS_TOKEN, SECRET, STATE_TO_PROPOGATE); 
    
        System.assertEquals(expectedAuthProvResponse.provider, actualAuthProvResponse.provider); 
        System.assertEquals(expectedAuthProvResponse.oauthToken, actualAuthProvResponse.oauthToken); 
        System.assertEquals(expectedAuthProvResponse.oauthSecretOrRefreshToken, actualAuthProvResponse.oauthSecretOrRefreshToken); 
        System.assertEquals(expectedAuthProvResponse.state, actualAuthProvResponse.state); 

    }
    
    
    static testMethod void testHandleCallback2() 
    { 
        Map<String,String> config = setupAuthProviderConfig(); 
        VFSCORE_GlobalCustAPICAuthProviderPlugin objVFSCORE_GlobalCustAPICAuthProviderPlugin = new VFSCORE_GlobalCustAPICAuthProviderPlugin(); 
        // objVFSCORE_GlobalCustAPICAuthProviderPlugin.redirectUrl = config.get
        // ('Redirect_Url_c'); 
    
        VFSCORE_GlobalCustAPICAuthProviderPlugin.TokenResponse objTknRes = new VFSCORE_GlobalCustAPICAuthProviderPlugin.TokenResponse();
        objTknRes.refresh_token_expires_in = '3599';
        objTknRes.api_product_list = 'apiprodlist';
        objTknRes.api_product_list_json = new List<String>{'list_json'};
        objTknRes.organization_name = 'org_name';
        objTknRes.developer_email = 'demo@demo.com';
        objTknRes.token_type = 'bearer';
        objTknRes.issued_at = 'issuedAt';
        objTknRes.client_id = CLIENT_ID;
        objTknRes.access_token = 'nhgabu67q8rt43wejmgbi38o48wfimou.dhuebtt7we74867';
        objTknRes.application_name = 'applnname';
        objTknRes.scope = SCOPE;
        objTknRes.expires_in = '3599';
        objTknRes.refresh_count = '4';
        objTknRes.status = 'ok';
        objTknRes.ErrorCode = '400';
        objTknRes.Error = 'error';
        String strResponseBody = JSON.serialize(objTknRes);
        HTTPMockFactory mock = new HTTPMockFactory(
        200,
        'OK',
        strResponseBody,
        new Map<String, String>()
        );
        Test.setMock(HttpCalloutMock.class, mock); 
    
        Map<String,String> queryParams = new Map<String,String>(); 
        queryParams.put('code','code'); 
        queryParams.put('state',config.get('State_c')); 
        Auth.AuthProviderCallbackState cbState = new Auth.AuthProviderCallbackState(null,null,queryParams); 
        System.debug('>>> cbState = ' + cbState);

        Auth.AuthProviderTokenResponse actualAuthProvResponse;
        
        try{
            actualAuthProvResponse = objVFSCORE_GlobalCustAPICAuthProviderPlugin.handleCallback(config, cbState);
        } catch(Exception e) {

        }
        
        System.debug('>>> actualAuthProvResponse = ' + actualAuthProvResponse);
    }
     
    
    static testMethod void testHandleCallback3() 
    { 
        Map<String,String> config = setupAuthProviderConfig(); 
        VFSCORE_GlobalCustAPICAuthProviderPlugin objVFSCORE_GlobalCustAPICAuthProviderPlugin = new VFSCORE_GlobalCustAPICAuthProviderPlugin(); 
        // objVFSCORE_GlobalCustAPICAuthProviderPlugin.redirectUrl = config.get
        // ('Redirect_Url_c'); 
    
        VFSCORE_GlobalCustAPICAuthProviderPlugin.TokenResponse objTknRes = new VFSCORE_GlobalCustAPICAuthProviderPlugin.TokenResponse();
        objTknRes.refresh_token_expires_in = '3599';
        objTknRes.api_product_list = 'apiprodlist';
        objTknRes.api_product_list_json = new List<String>{'list_json'};
        objTknRes.organization_name = 'org_name';
        objTknRes.developer_email = 'demo@demo.com';
        objTknRes.token_type = 'bearer';
        objTknRes.issued_at = 'issuedAt';
        objTknRes.client_id = CLIENT_ID;
        objTknRes.access_token = 'nhgabu67q8rt43wejmgbi38o48wfimou.dhuebtt7we74867';
        objTknRes.application_name = 'applnname';
        objTknRes.scope = SCOPE;
        objTknRes.expires_in = '3599';
        objTknRes.refresh_count = '4';
        objTknRes.status = 'ok';
        objTknRes.ErrorCode = '400';
        objTknRes.Error = 'error';
        String strResponseBody = JSON.serialize(objTknRes);
        HTTPMockFactory mock = new HTTPMockFactory(
        400,
        'OK',
        strResponseBody,
        new Map<String, String>()
        );
        Test.setMock(HttpCalloutMock.class, mock); 
    
        Map<String,String> queryParams = new Map<String,String>(); 
        queryParams.put('code','code'); 
        queryParams.put('state',config.get('State_c')); 
        Auth.AuthProviderCallbackState cbState = new Auth.AuthProviderCallbackState(null,null,queryParams); 
        System.debug('>>> cbState = ' + cbState);

        Auth.AuthProviderTokenResponse actualAuthProvResponse;
        
        try{
            actualAuthProvResponse = objVFSCORE_GlobalCustAPICAuthProviderPlugin.handleCallback(config, cbState);
        } catch(Exception e) {

        }
        System.debug('>>> actualAuthProvResponse = ' + actualAuthProvResponse);
    }

    static testMethod void testHandleCallback4() 
    { 
        Map<String,String> config = setupAuthProviderConfig(); 
        VFSCORE_GlobalCustAPICAuthProviderPlugin objVFSCORE_GlobalCustAPICAuthProviderPlugin = new VFSCORE_GlobalCustAPICAuthProviderPlugin(); 
        // objVFSCORE_GlobalCustAPICAuthProviderPlugin.redirectUrl = config.get
        // ('Redirect_Url_c'); 
        VFSCORE_GlobalCustAPICAuthProviderPlugin.Detail objDetail = new VFSCORE_GlobalCustAPICAuthProviderPlugin.Detail();
        objDetail.errorcode = '400';
        VFSCORE_GlobalCustAPICAuthProviderPlugin.Fault objFault = new VFSCORE_GlobalCustAPICAuthProviderPlugin.Fault();
        objFault.faultstring = 'dsfgdhj';
        objFault.detail = objDetail;

        VFSCORE_GlobalCustAPICAuthProviderPlugin.TokenResponse objTknRes = new VFSCORE_GlobalCustAPICAuthProviderPlugin.TokenResponse();
        objTknRes.refresh_token_expires_in = '3599';
        objTknRes.api_product_list = 'apiprodlist';
        objTknRes.api_product_list_json = new List<String>{'list_json'};
        objTknRes.organization_name = 'org_name';
        objTknRes.developer_email = 'demo@demo.com';
        objTknRes.token_type = 'bearer';
        objTknRes.issued_at = 'issuedAt';
        objTknRes.client_id = CLIENT_ID;
        objTknRes.access_token = 'nhgabu67q8rt43wejmgbi38o48wfimou.dhuebtt7we74867';
        objTknRes.application_name = 'applnname';
        objTknRes.scope = SCOPE;
        objTknRes.expires_in = '3599';
        objTknRes.refresh_count = '4';
        objTknRes.status = 'ok';
        objTknRes.fault = objFault;
        String strResponseBody = JSON.serialize(objTknRes);
        HTTPMockFactory mock = new HTTPMockFactory(
        400,
        'OK',
        strResponseBody,
        new Map<String, String>()
        );
        Test.setMock(HttpCalloutMock.class, mock); 
    
        Map<String,String> queryParams = new Map<String,String>(); 
        queryParams.put('code','code'); 
        queryParams.put('state',config.get('State_c')); 
        Auth.AuthProviderCallbackState cbState = new Auth.AuthProviderCallbackState(null,null,queryParams); 
        System.debug('>>> cbState = ' + cbState);

        Auth.AuthProviderTokenResponse actualAuthProvResponse;
        
        try{
            actualAuthProvResponse = objVFSCORE_GlobalCustAPICAuthProviderPlugin.handleCallback(config, cbState);
        } catch(Exception e) {

        }
        System.debug('>>> actualAuthProvResponse = ' + actualAuthProvResponse);
    }

    static testMethod void testrefresh() 
    { 
        Map<String,String> config = setupAuthProviderConfig(); 
        VFSCORE_GlobalCustAPICAuthProviderPlugin objVFSCORE_GlobalCustAPICAuthProviderPlugin = new VFSCORE_GlobalCustAPICAuthProviderPlugin(); 
        VFSCORE_GlobalCustAPICAuthProviderPlugin.TokenResponse objTknRes = new VFSCORE_GlobalCustAPICAuthProviderPlugin.TokenResponse();
        objTknRes.refresh_token_expires_in = '3599';
        objTknRes.api_product_list = 'apiprodlist';
        objTknRes.api_product_list_json = new List<String>{'list_json'};
        objTknRes.organization_name = 'org_name';
        objTknRes.developer_email = 'demo@demo.com';
        objTknRes.token_type = 'bearer';
        objTknRes.issued_at = 'issuedAt';
        objTknRes.client_id = CLIENT_ID;
        objTknRes.access_token = ACCESS_TOKEN;
        objTknRes.application_name = 'applnname';
        objTknRes.scope = SCOPE;
        objTknRes.expires_in = '3599';
        objTknRes.refresh_count = '4';
        objTknRes.status = 'ok';
        // objTknRes.
        String strResponseBody = JSON.serialize(objTknRes);
        HTTPMockFactory mock = new HTTPMockFactory(
        200,
        'OK',
        strResponseBody,
        new Map<String, String>()
        );
        Test.setMock(HttpCalloutMock.class, mock); 

        Auth.OAuthRefreshResult actualAuthRefreshResult = objVFSCORE_GlobalCustAPICAuthProviderPlugin.refresh(config, ACCESS_TOKEN);
        Auth.OAuthRefreshResult expectedAuthRefreshResult = new Auth.OAuthRefreshResult(objTknRes.ACCESS_TOKEN, 'bearer');
        System.assertEquals(expectedAuthRefreshResult.accessToken, actualAuthRefreshResult.accessToken);
        System.assertEquals(expectedAuthRefreshResult.error, actualAuthRefreshResult.error);
        System.assertEquals(expectedAuthRefreshResult.refreshToken, actualAuthRefreshResult.refreshToken);
    }

    static testMethod void testGetUserInfo() 
    { 
        Map<String,String> config = setupAuthProviderConfig(); 
        VFSCORE_GlobalCustAPICAuthProviderPlugin objVFSCORE_GlobalCustAPICAuthProviderPlugin = new VFSCORE_GlobalCustAPICAuthProviderPlugin(); 
    
        VFSCORE_GlobalCustAPICAuthProviderPlugin.TokenResponse objTknRes = new VFSCORE_GlobalCustAPICAuthProviderPlugin.TokenResponse();
        objTknRes.refresh_token_expires_in = '3599';
        objTknRes.api_product_list = 'apiprodlist';
        objTknRes.api_product_list_json = new List<String>{'list_json'};
        objTknRes.organization_name = 'org_name';
        objTknRes.developer_email = 'demo@demo.com';
        objTknRes.token_type = 'bearer';
        objTknRes.issued_at = 'issuedAt';
        objTknRes.client_id = CLIENT_ID;
        objTknRes.access_token = 'nhgabu67q8rt43wejmgbi38o48wfimou.dhuebtt7we74867';
        objTknRes.application_name = 'applnname';
        objTknRes.scope = SCOPE;
        objTknRes.expires_in = '3599';
        objTknRes.refresh_count = '4';
        objTknRes.status = 'ok';
        objTknRes.ErrorCode = '400';
        objTknRes.Error = 'error';
        String strResponseBody = JSON.serialize(objTknRes);
        HTTPMockFactory mock = new HTTPMockFactory(
        200,
        'OK',
        strResponseBody,
        new Map<String, String>()
        );
        Test.setMock(HttpCalloutMock.class, mock); 
    
        Auth.AuthProviderTokenResponse response = new Auth.AuthProviderTokenResponse(PROVIDER, OAUTH_TOKEN ,SECRET, STATE_TO_PROPOGATE);

        Auth.UserData actualUserData = objVFSCORE_GlobalCustAPICAuthProviderPlugin.getUserInfo(
        config, response) ; 
    
        System.debug('>>> actualUserData = ' + actualUserData);


        Map<String,String> provMap = new Map<String,String>(); 
        provMap.put('key1', 'value1'); 
        provMap.put('key2', 'value2'); 
    
        // Auth.UserData expectedUserData = new Auth.UserData(LOGIN_ID, 
        // FIRST_NAME, LAST_NAME, FULL_NAME, EMAIL_ADDRESS, 
        // null, LOCALE_NAME, null, PROVIDER, null, provMap); 
        // System.debug('>>> expectedUserData = ' + expectedUserData);
        // System.assertNotEquals(expectedUserData,null); 
        // System.assertEquals(expectedUserData.firstName, 
        // actualUserData.firstName); 
        // System.assertEquals(expectedUserData.lastName, 
        // actualUserData.lastName); 
        // System.assertEquals(expectedUserData.fullName, 
        // actualUserData.fullName); 
        // System.assertEquals(expectedUserData.email, 
        // actualUserData.email); 
        // System.assertEquals(expectedUserData.username, 
        // actualUserData.username); 
        // System.assertEquals(expectedUserData.locale, 
        // actualUserData.locale); 
        // System.assertEquals(expectedUserData.provider, 
        // actualUserData.provider); 
        // System.assertEquals(expectedUserData.siteLoginUrl, 
        // actualUserData.siteLoginUrl); 
    } 
}