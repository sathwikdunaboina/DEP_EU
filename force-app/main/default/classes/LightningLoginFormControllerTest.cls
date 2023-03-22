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
    static void testIsUsernamePasswordEnabled() {
        System.assertEquals(true, LightningLoginFormController.getIsUsernamePasswordEnabled());
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
    
    /*@IsTest
    static void testcontractverification() {
        CCAN__c can=new CCAN__c();
        can.Tax_ID__c='9603';
        can.Billing_Zip__c='12345';
        can.Name='test';
        can.CCAN__c='1245';
        insert can;
        Account acc=new Account();
        acc.name='test';
        acc.CCAN__c=can.Id;
        insert acc;
        Contract_CS__c c=new Contract_CS__c();
        c.name='500-100';
        c.externalId__c='500-100';
        c.Account__c=acc.id;
        
        insert c;
        Equipment_CS__c e=new Equipment_CS__c();
        e.name='140553';
        e.Contract__c=c.id;
        e.externalId__c='23567';
        e.Vin_Serial__c='34567';
        insert e;
        Contact con=new Contact();
        con.accountId=acc.id;
        con.LastName='lastname12';
        con.Email='test12@abc.com';
        insert con;
        System.assertEquals(acc.id, LightningLoginFormController.verifyContract('2000008',can.Billing_Zip__c,can.Tax_ID__c,e.Vin_Serial__c));
        System.assertEquals(acc.id, LightningLoginFormController.verifyContract('2000008',can.Billing_Zip__c,can.Tax_ID__c,null));
        System.assertEquals(acc.id, LightningLoginFormController.verifyContract('2000008',can.Billing_Zip__c,null,e.Vin_Serial__c));
        System.assertEquals(acc.id, LightningLoginFormController.verifyContract('2000008',null,can.Tax_ID__c,e.Vin_Serial__c));
      
        System.assertEquals(acc.id, LightningLoginFormController.verifyContract(null,can.Billing_Zip__c,can.Tax_ID__c,e.Vin_Serial__c));
        
        System.assertEquals(false, LightningLoginFormController.CreateContact(acc.id,'firstname','lastname','123-123-1234','test@abc.com'));
        
       System.assertEquals(false, LightningLoginFormController.CreateContact(acc.id,'firstname12','lastname12','123-123-1234','test12@abc.com'));
    }*/
    
}