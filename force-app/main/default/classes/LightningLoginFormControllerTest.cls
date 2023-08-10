@IsTest
public with sharing class LightningLoginFormControllerTest {
    
    @IsTest(SeeAllData = true)
    static void testLoginWithInvalidCredentials() {
 	/* This test is decommissioned after Winter 21
     *
     * System.assertEquals('Argument 1 cannot be null', LightningLoginFormController.login('testUser', 'fakepwd', null));
	 */    
      System.assertEquals(null, LightningLoginFormController.login('testUser', 'fakepwd', null));
	}
    
    @IsTest(SeeAllData = true)
    static void lightningLoginFormControllerInstantiation() {
        LightningLoginFormController controller = new LightningLoginFormController();
        System.assertNotEquals(controller, null);
    }
    @IsTest(SeeAllData = true)
    static void lightningLoginFormControllerGetForgotPasswordUrl() {
        LightningLoginFormController.getForgotPasswordUrl();
    }
    
    @IsTest(SeeAllData = true)
    static void testIsUsernamePasswordEnabled() {
        Boolean isSandbox = [SELECT IsSandbox, Id FROM Organization].IsSandbox;
        if(isSandbox == true){
            System.assertEquals(true, LightningLoginFormController.getIsUsernamePasswordEnabled());
        }
        else{
            System.assertEquals(false, LightningLoginFormController.getIsUsernamePasswordEnabled());
        }
    }
    
    @IsTest(SeeAllData = true)
    static void testIsSelfRegistrationEnabled() {
        System.assertEquals(false, LightningLoginFormController.getIsSelfRegistrationEnabled());
    }
    
    @IsTest(SeeAllData = true)
    static void testGetSelfRegistrationURL() {
        System.assertEquals(null, LightningLoginFormController.getSelfRegistrationUrl());
    }
    
    @IsTest(SeeAllData = true)
    static void testAuthConfig() {
        Auth.AuthConfiguration authConfig = LightningLoginFormController.getAuthConfig();
        System.assertNotEquals(null, authConfig);
    }
    
    @IsTest(SeeAllData = true)
    static void testsetExperienceIdNull() {
        System.assertEquals(null, LightningLoginFormController.setExperienceId(null));
    }
    @IsTest(SeeAllData = true)
    static void testsetExperienceId() {
        System.assertNotEquals(null, LightningLoginFormController.setExperienceId('test'));
    }
    @IsTest(SeeAllData = true)
    static void getSupportContactDetailTest(){
        System.assert(LightningLoginFormController.getServiceDesk() != null);
    }
}