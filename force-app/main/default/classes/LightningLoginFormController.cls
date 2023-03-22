global class LightningLoginFormController {
    
    public LightningLoginFormController() 
    {
        
    }
    
    @AuraEnabled
    public static String login(String username, String password, String startUrl) 
    {
        try
        {
            ApexPages.PageReference lgn = Site.login(username, password, startUrl);
            aura.redirect(lgn);
            
            return null;
        }
        catch (Exception ex) 
        {
            return ex.getMessage();            
        }
    }
    
    @AuraEnabled
    public static Boolean getIsUsernamePasswordEnabled() 
    {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getUsernamePasswordEnabled();
    }
    
    @AuraEnabled
    public static Boolean getIsSelfRegistrationEnabled() 
    {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getSelfRegistrationEnabled();
    }
    
    @AuraEnabled
    public static String getSelfRegistrationUrl() 
    {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        if (authConfig.getSelfRegistrationEnabled()) 
        {
            return authConfig.getSelfRegistrationUrl();
        }
        return null;
    }
    
    @AuraEnabled
    public static String getForgotPasswordUrl() 
    {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getForgotPasswordUrl();
    }
    
    @TestVisible
    private static Auth.AuthConfiguration getAuthConfig()
    {
        Id networkId = Network.getNetworkId();
        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(networkId,'');
        return authConfig;
    }
    
    @AuraEnabled
    global static String setExperienceId(String expId) 
    {
        // Return null if there is no error, else it will return the error message 
        try 
        {
            if (expId != null) 
            {
                Site.setExperienceId(expId);
            }
            return null; 
        } 
        catch (Exception ex) 
        {
            return ex.getMessage();            
        }
    }
    
    @AuraEnabled
    public static List<Support_Desk__c> getServiceDesk(){
        Try{
            
            List<Support_Desk__c> supportDeskList = [SELECT Contact_Number__c , E_Mail__c , Country__c
                                                     FROM Support_Desk__c 
                                                     WHERE Type__c = 'Support'];
            //system.debug(supportDeskList);
            return supportDeskList;
        }
        catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage()+' '+ex.getCause()+' '+ex.getLineNumber()+' '+ex.getStackTraceString());
        }
        
    }    
}