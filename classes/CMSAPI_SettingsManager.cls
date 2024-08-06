/* 
 * Created: Prabha
 * Single point of access for the CMSAPI custom settings.
 * All classes, refer to this, instead of the custom setting.
 * Makes writing test classses easier.
 * 
 * */
public class CMSAPI_SettingsManager {
    private static CMSAPI__c cmsApiSettings;
    public static CMSAPI__c get(){
        if (cmsApiSettings == null) {
            if (Test.isRunningTest()) {
            	cmsApiSettings = new CMSAPI__c();
                cmsApiSettings.ClientId__c='dummyId';
                cmsApiSettings.ClientSecret__c = 'dummyKey';
                cmsApiSettings.GrantType__c= 'client_credentials';
                cmsApiSettings.Name='CMS_API';
                cmsApiSettings.TimeOut__c=1;
                cmsApiSettings.X_Ibm_Client_Id__c ='dummyXId';
                cmsApiSettings.X_Ibm_Client_Secret__c ='dummyXSecret';
                cmsApiSettings.Content_ID__c = 'dummyContentId';
                cmsApiSettings.Invoice_Resource__c = '/InvoiceManagement/v1/';
            } else {
                cmsApiSettings = CMSAPI__c.getOrgDefaults();    
            }
        }
        return cmsApiSettings;
    }
    public static void set(CMSAPI__c settings){
        cmsApiSettings = settings;
        if (!Test.isRunningTest()){
            update cmsApiSettings;
        }
    }
}