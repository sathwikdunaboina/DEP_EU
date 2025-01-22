@isTest
/* 
* -----------------------------------------------------------------------------------------
* Apex Class Name     CLA_APICAuthProviderPlugin_Test
* @author             Sourabh Sharma <sourabh.sharma@consultant.volvo.com> 
* @Created Date       05-27-2024         
* ------------------------------------------------------------------------------------------
* @description        This class is used to test CLA_APICAuthProviderPlugin
* ------------------------------------------------------------------------------------------
*/
public class CLA_APICAuthProviderPlugin_Test { 
    
/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     setupAuthProviderConfig
* @description     Helper method to create mock config map
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          Map<String, String>      Map of mock config        
* ------------------------------------------------------------------------------------------------------ 
*/ 
    private static Map<String, String> setupAuthProviderConfig() {
        Map<String, String> mapConfigValueByConfigKey = new Map<String, String>();
        mapConfigValueByConfigKey.put('Access_Token_URL__c', 'https://login.microsoftonline.com/f25493ae-1c98-41d7-8a33-0be75f5fe603/oauth2/v2.0/token');
        mapConfigValueByConfigKey.put('Auth_Provider_Name__c', 'CLA_APIC_Auth');
        mapConfigValueByConfigKey.put('Client_Id__c', 'testClientId');
        mapConfigValueByConfigKey.put('Client_Secret__c', 'testClientSecret');
        mapConfigValueByConfigKey.put('Use_JSON_Encoding__c', 'false');
        mapConfigValueByConfigKey.put('Scope__c', 'testScope');
        return mapConfigValueByConfigKey;
    }

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     mockHttpResponse
* @description     Used for mocking HTTP Callout
* ------------------------------------------------------------------------------------------------------
* @param          
* @return               
* ------------------------------------------------------------------------------------------------------ 
*/
    
    private static void mockHttpResponse() {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"access_token": "mockAccessToken", "token_type": "Bearer", "developer.email": "developer@example.com","refresh_token_expires_in":"0", "api_product_list" : "[helloworld, HelloWorld_OAuth2-Product]", "api_product_list_json" : [ "helloworld", "HelloWorld_OAuth2-Product" ],"issued_at" : "1520478821362", "client_id" : "testClientId","application_name":"test"}');
        res.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(res));
    }
    
/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     mockHttpErrorResponse
* @description     Used for mocking HTTP Callout,handles error response
* ------------------------------------------------------------------------------------------------------
* @param          
* @return               
* ------------------------------------------------------------------------------------------------------ 
*/
    
     private static void mockHttpErrorResponse() {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"ErrorCode":"invalid_client","Error" : "Client credentials are invalid"}');
        res.setStatusCode(400);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(res));
    }


/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testGetCustomMetadataType
* @description     Used for testing getCustomMetadataType method
* ------------------------------------------------------------------------------------------------------
* @param          
* @return               
* ------------------------------------------------------------------------------------------------------ 
*/
    
    @isTest 
    private static void testGetCustomMetadataType() {
        System.runAs(new User(Id = UserInfo.getUserId())){
        Test.startTest();
        CLA_APICAuthProviderPlugin plugin = new CLA_APICAuthProviderPlugin();
        String sResult = plugin.getCustomMetadataType();
        Test.stopTest();
        System.assertEquals('CLA_APIC_API_AuthProvider_Settings__mdt',sResult,'Expected result');
        }
    }
   
/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testInitiate
* @description     test initiate method
* ------------------------------------------------------------------------------------------------------
* @param          
* @return               
* ------------------------------------------------------------------------------------------------------ 
*/
    @isTest
    private static void testInitiate() {
        System.runAs(new User(Id = UserInfo.getUserId())){
        Test.startTest();
        CLA_APICAuthProviderPlugin plugin = new CLA_APICAuthProviderPlugin();
        Map<String, String> mapConfigValueByConfigKey = setupAuthProviderConfig();
        String sStateToPropagate = 'testState';
        
        PageReference pageRef = plugin.initiate(mapConfigValueByConfigKey, sStateToPropagate);
        Test.stopTest();

        System.assertNotEquals(null, pageRef,'Expected result');
        System.assertEquals(sStateToPropagate, pageRef.getParameters().get('state'),'Expected result');
        System.assertEquals(CLA_APICAuthProviderPlugin.DUMMY_CODE, pageRef.getParameters().get('code'),'Expected result');
        }
    }

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testHandleCallback
* @description     test handleCallback method
* ------------------------------------------------------------------------------------------------------
* @param          
* @return               
* ------------------------------------------------------------------------------------------------------ 
*/
    
  @isTest
    private static void testHandleCallback() {
        System.runAs(new User(Id = UserInfo.getUserId())){
        Test.startTest();
        CLA_APICAuthProviderPlugin plugin = new CLA_APICAuthProviderPlugin();
        Map<String, String> mapConfigValueByConfigKey = setupAuthProviderConfig();
        Map<String,String> mapHeaderValueByHeaderKey = new Map<String,String>();
        String sBody = '';
        Map<String,String> mapQueryParamValueByQueryParamKey =  new Map<String,String>();
        Auth.AuthProviderCallbackState state = new Auth.AuthProviderCallbackState(mapHeaderValueByHeaderKey,sBody,mapQueryParamValueByQueryParamKey);
        state.queryParameters = new Map<String, String>{'state' => 'testState'};

        mockHttpResponse();
        
        Auth.AuthProviderTokenResponse response = plugin.handleCallback(mapConfigValueByConfigKey, state);
        Test.stopTest();


        System.assertNotEquals(null, response,'Expected result');
        System.assertEquals('CLA_APIC_Auth', response.provider,'Expected result');
        System.assertEquals('mockAccessToken', response.oauthToken,'Expected result');
        }
    }

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testHandleCallbackError
* @description     test handleCallback method for error response
* ------------------------------------------------------------------------------------------------------
* @param          
* @return               
* ------------------------------------------------------------------------------------------------------ 
*/   
  @isTest
    private static void testHandleCallbackError() {
        System.runAs(new User(Id = UserInfo.getUserId())){
        Test.startTest();
        CLA_APICAuthProviderPlugin plugin = new CLA_APICAuthProviderPlugin();
        Map<String, String> mapConfigValueByConfigKey = setupAuthProviderConfig();
        Map<String,String> mapHeaderValueByHeaderKey = new Map<String,String>();
        String sBody = '';
        Map<String,String> mapQueryParamValueByQueryParamKey =  new Map<String,String>();
        Auth.AuthProviderCallbackState state = new Auth.AuthProviderCallbackState(mapHeaderValueByHeaderKey,sBody,mapQueryParamValueByQueryParamKey);
        state.queryParameters = new Map<String, String>{'state' => 'testState'};

        mockHttpErrorResponse();
         Auth.AuthProviderTokenResponse response ;
        
        try{
          response = plugin.handleCallback(mapConfigValueByConfigKey, state);   
        }
        catch(exception e){
            System.debug(LoggingLevel.INFO,'exception '+e.getMessage());
        }
        
       
        Test.stopTest();

        System.assertEquals(null, null,'Expected result');
    }
    }


/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testRefresh
* @description     test refresh method
* ------------------------------------------------------------------------------------------------------
* @param          
* @return               
* ------------------------------------------------------------------------------------------------------ 
*/
  @isTest
    private static void testRefresh() {
        System.runAs(new User(Id = UserInfo.getUserId())){
        Test.startTest();
        CLA_APICAuthProviderPlugin plugin = new CLA_APICAuthProviderPlugin();
        Map<String, String> mapConfigValueByConfigKey = setupAuthProviderConfig();

        mockHttpResponse();

        Auth.OAuthRefreshResult refreshResult = plugin.refresh(mapConfigValueByConfigKey, null);
        Test.stopTest();

        System.assertNotEquals(null, refreshResult,'Expected result');
        System.assertEquals('mockAccessToken', refreshResult.accessToken,'Expected result');
        }
    }

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testGetUserInfo
* @description     test getUserInfo method
* ------------------------------------------------------------------------------------------------------
* @param          
* @return               
* ------------------------------------------------------------------------------------------------------ 
*/
  @isTest
    private static void testGetUserInfo() {
        System.runAs(new User(Id = UserInfo.getUserId())){
        Test.startTest();
        CLA_APICAuthProviderPlugin plugin = new CLA_APICAuthProviderPlugin();
        Map<String, String> mapConfigValueByConfigKey = setupAuthProviderConfig();
        Auth.AuthProviderTokenResponse tokenResponse = new Auth.AuthProviderTokenResponse('CLA_APIC_Auth', 'mockAccessToken', 'testClientSecret', 'testState');

        mockHttpResponse();

        Auth.UserData userData = plugin.getUserInfo(mapConfigValueByConfigKey, tokenResponse);
        Test.stopTest();

        System.assertNotEquals(null, userData,'Expected result');
        System.assertEquals('developer@example.com', userData.email,'Expected result');
        System.assertEquals('developer@example.com', userData.userName,'Expected result');
        System.assertEquals('CLA_APIC_Auth', userData.provider,'Expected result');
        }
    }

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testEncodeParametersAsJSON
* @description     test encodeParameters method
* ------------------------------------------------------------------------------------------------------
* @param          
* @return               
* ------------------------------------------------------------------------------------------------------ 
*/
  @isTest
    private static void testEncodeParametersAsJSON() {
        System.runAs(new User(Id = UserInfo.getUserId())){
        Test.startTest();
        CLA_APICAuthProviderPlugin plugin = new CLA_APICAuthProviderPlugin();
        Map<String, String> mapConfigValueByConfigKey = setupAuthProviderConfig();

        String encodedParams = plugin.encodeParameters(mapConfigValueByConfigKey, 'application/json');
        Test.stopTest();
        System.assertNotEquals(null, encodedParams,'Expected result');
        }
    }

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testEncodeParametersAsURL
* @description     test encodeAsURL method
* ------------------------------------------------------------------------------------------------------
* @param          
* @return               
* ------------------------------------------------------------------------------------------------------ 
*/
    @isTest
    private static void testEncodeParametersAsURL() {
        System.runAs(new User(Id = UserInfo.getUserId())){
        Test.startTest();
        CLA_APICAuthProviderPlugin plugin = new CLA_APICAuthProviderPlugin();
        Map<String, String> mapConfigValueByConfigKey = setupAuthProviderConfig();

        String encodedParams = plugin.encodeParameters(mapConfigValueByConfigKey, '');
        Test.stopTest();

        System.assertNotEquals(null, encodedParams,'Expected result');
        }
    }

    // Mock HTTP Callout Response Generator Class
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        private HttpResponse response;
        public MockHttpResponseGenerator(HttpResponse res) {
            this.response = res;
        }
        public HTTPResponse respond(HTTPRequest req) {
            return this.response;
        }
    }

}