/*
* Created: Prabha
* Orchastrates oAuth 'client_credentials' flow for CMS API
* unable to use named credentials, because of 'client_cred' headless flow.
* 
* */
public class CMSAPI_oAuthHandler{
    
    private static final String TOKEN_CACHE_KEY = 'cmsApiToken';
    
    public static String getAccessToken(){
        CMSAPI__c settings = CMSAPI_SettingsManager.get();
        //Check if the token is present in platform cache.
        String token = getCachedToken(settings);
        if (String.isBlank(token)){
            //no luck fetching cached token, so making actual call
            HttpResponse response = HttpCallout.send('callout:CMS_Token_API', 'POST', null, 
                                                     'client_id='+settings.ClientId__c
                                                     +'&client_secret='+settings.ClientSecret__c
                                                     +'&grant_type='+settings.GrantType__c
                                                     +'&scope='+settings.Scope__c);
            Integer statusCode = response.getStatusCode();
            if ( statusCode == 200 ){
                //using the inner class to deserialize
                CMS_AccessToken accessToken = (CMS_AccessToken)JSON.deserialize(response.getBody(), CMS_AccessToken.class);
                if (accessToken!=null && !String.isBlank(accessToken.access_token)){
                    token = accessToken.access_token;
                    //The token is cached at the end of the customer api callout
                } else {
                    ErrorLogUtil.createErrorLog('CMSAPI_oAuthHandler', response.getBody(), ''+statusCode, null , 'getAccessToken', null,null,null, 'client_id='+settings.ClientId__c);
            	}    
            } else {
                ErrorLogUtil.createErrorLog('CMSAPI_oAuthHandler', response.getBody(), ''+statusCode, null , 'getAccessToken', null, null, null, 'client_id='+settings.ClientId__c);
            }          
        }
        return token;
    }
    
    private static String getCachedToken(CMSAPI__c settings){
        //If the token has not timedout, since we last fetched the token
        //valid token present in platform cache
        //converting timeout from seconds to milli seconds (999 for reassuring)
        if (settings.LastTokenTime__c != null && settings.TimeOut__c != null &&
            System.now().getTime() - settings.LastTokenTime__c.getTime() < (settings.TimeOut__c * 999 )){ 
                return (String)CXPCacheManager.get(TOKEN_CACHE_KEY);
            }
        return null;	  
    }
    public static void setCachedToken(String token){
        //We have a new toke to update into platform cache.
        CXPCacheManager.put(TOKEN_CACHE_KEY, token);
        CMSAPI__c settings = CMSAPI_SettingsManager.get();
        settings.LastTokenTime__c = System.now();
        CMSAPI_SettingsManager.set(settings);     
        
    }
    
    public class CMS_AccessToken{
        public String access_token;
        public String token_type;
        public String expires_in;
    }
}