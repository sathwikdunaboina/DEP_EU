/* 
* -----------------------------------------------------------------------------------------
* Apex Class Name     UpdCseOriginandBrandOnEMCreate_Test
* @author             Sugapriya Vanjiyappan <sugapriya.vanjiyappan@consultant.volvo.com>
* @Created Date       26-3-2025 
* @Used By            Update Case Origin and Brand Fields based on the Custom metadata created through email-to-case
* ------------------------------------------------------------------------------------------
* @description        This class is used to test Update Case Origin and Brand Fields On Email Message Create Flow.
* ------------------------------------------------------------------------------------------
*/
@IsTest(SeeAllData=false)
public class UpdCseOriginandBrandOnEMCreate_Test{
/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     setUpData
* @description     Used to prepare test setup data
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/ 
    @testSetup 
    static void setupmethod(){
        Id iProfileId = [SELECT Id FROM Profile WHERE Name = 'CS Operations' LIMIT 1][0].Id;
        String sUniqueUserName = 'TestCaseAssigment' + DateTime.now().getTime() + '@testorg.com';
        User oTestUser = new User(Alias = 'tstcs', Email='testcaseassignment@testorg.com',
                                  EmailEncodingKey='UTF-8', LastName='TestCaseAsgMent', LanguageLocaleKey='en_US',
                                  LocaleSidKey='en_GB', ProfileId = iProfileId,TimeZoneSidKey='Europe/Paris',
                                  Country = '',UserName=sUniqueUserName);
        insert oTestUser;
        System.runAs(oTestUser){
            //Create Case and Email Message with To Address of Email in Custom metadata
            Case testCasewithEmailOnMetadata = new Case();
            testCasewithEmailOnMetadata.Origin = 'Email - Volvo';
            testCasewithEmailOnMetadata.Brand__c = null;
            testCasewithEmailOnMetadata.Subject = 'Test Case Email Volvo';
            insert testCasewithEmailOnMetadata;
            testCasewithEmailOnMetadata.Last_Email_Message_Received_Date__c = System.now().addMinutes(5);
            update testCasewithEmailOnMetadata;
            Test.setCreatedDate(testCasewithEmailOnMetadata.Id, System.now());
            
            
            EmailMessage testEmailMessageInMetadata = new EmailMessage();
            testEmailMessageInMetadata.Subject = 'Email Message with Metadata';
            testEmailMessageInMetadata.ParentId = testCasewithEmailOnMetadata.Id;
            testEmailMessageInMetadata.ToAddress = 'vfs.extensions.vce@volvo.com';
            testEmailMessageInMetadata.Incoming = true;
            insert testEmailMessageInMetadata;
            
            //Create Case and Email Message with To Address of Email not in Custom metadata
            Case testCasewithoutEmailOnMetadata = new Case();
            testCasewithoutEmailOnMetadata.Origin = 'Email';
            testCasewithoutEmailOnMetadata.Brand__c = null;
            testCasewithoutEmailOnMetadata.Subject = 'Test Case Email';
            insert testCasewithoutEmailOnMetadata;
            testCasewithoutEmailOnMetadata.Last_Email_Message_Received_Date__c = System.now().addMinutes(5);
            update testCasewithoutEmailOnMetadata;
            Test.setCreatedDate(testCasewithoutEmailOnMetadata.Id, System.now());
            
            EmailMessage testEmailMessageNotInMetadata = new EmailMessage();
            testEmailMessageNotInMetadata.Subject = 'Email Message without Metadata';
            testEmailMessageNotInMetadata.ParentId = testCasewithoutEmailOnMetadata.Id;
            testEmailMessageNotInMetadata.ToAddress = 'vfs.operations.be@volvo.com';
             testEmailMessageNotInMetadata.Incoming = true;
            insert testEmailMessageNotInMetadata;
            
            
        }
        
    }
/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     updateBrandAndCaseOriginFromCustomMetadata
* @description     To cover the flow elements which Updates the Brand and Case Origin
* ------------------------------------------------------------------------------------------------------
*/
    @isTest
    static void updateBrandAndCaseOriginFromCustomMetadata(){
        EmailMessage createdEmailMessage = [SELECT Id,ToAddress,ParentId FROM EmailMessage WHERE Subject='Email Message with Metadata'];
        Case createdCase = [SELECT Id,Brand__c,Origin FROM Case WHERE Subject ='Test Case Email Volvo'];
        Test.StartTest();
        System.assertEquals('VCE',createdCase.Brand__c);
        System.assertEquals('Email',createdcase.Origin);
        Test.StopTest();
    }
    
/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     updateCaseOriginNotFromCustomMetadata
* @description     To cover the flow elements which Updates the Brand and Case Origin
* ------------------------------------------------------------------------------------------------------
*/
    @isTest
    static void updateCaseOriginNotFromCustomMetadata(){
        EmailMessage createdEmailMessageNotFromMetadata = [SELECT Id,ToAddress,ParentId FROM EmailMessage WHERE Subject='Email Message without Metadata'];
        Case createdEmailOriginCase = [SELECT Id,Brand__c,Origin FROM Case WHERE Subject ='Test Case Email'];
        Test.StartTest();
        System.assertEquals(null,createdEmailOriginCase.Brand__c);
        System.assertEquals('Email',createdEmailOriginCase.Origin);
        Test.StopTest();
    }
    
}