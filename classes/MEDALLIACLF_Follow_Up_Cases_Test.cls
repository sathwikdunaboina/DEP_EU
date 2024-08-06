/** This test class has been created for flow test coverage for the following information
* FlowName- MEDALLIACLF_Sync_CLF_Case_Updates_To_Medallia,MEDALLIACLF_Update_Alert_Status_From_Response,MEDALLIACLF_On_Closed_Loop_Case_Owner_Change
* User Required- System Admin
* Object used - medallia_xm__Medallia_Feedback__c,Case
* Use case- On creation or updating of medallia_xm__Medallia_Feedback__c record, a follow up case is created and updated
**/
@isTest
public class MEDALLIACLF_Follow_Up_Cases_Test {
    @isTest
    static void createResponse() {
        
        //Prepare Test User
        Id accountRecordType = Schema.SObjectType.account.getRecordTypeInfosByName().get('Dealer Account').getRecordTypeId();
        Id caseRecordType = Schema.SObjectType.case.getRecordTypeInfosByName().get('MEDALLIACLF Alert Cases').getRecordTypeId();
        String uniqueUserName = 'TestCaseAssigment' + DateTime.now().getTime() + '@testorg.com';        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User testUser = new User(Alias = 'tstcs', Email='testcaseassignment@testorg.com',
                                 EmailEncodingKey='UTF-8', LastName='TestCaseAsgMent', LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_GB', ProfileId = p.Id,TimeZoneSidKey='Europe/Paris',
                                 Country = '',UserName=uniqueUserName);
        Account testAcc = new Account (Name='TestDealerAccount', RecordTypeId = accountRecordType, CustomerID__c='1234', 
                                       BillingCountry='Italy');
        insert testAcc;
        
        String cEmail = 'test@contact1.org' + System.currentTimeMillis();
        Contact testCon = new Contact(FirstName='SalesPersonFirstname',LastName='SalesPersonLastname',Email=cEmail, AccountId=testAcc.Id);
        insert testCon;
        
        //Invoke Functionality
        System.runAs(testUser){
            //Prepare Test Data For Functionality
            medallia_xm__Medallia_Feedback__c testPurchaseResponse = new medallia_xm__Medallia_Feedback__c(
                medallia_xm__Account_Id__c=testAcc.id
                ,medallia_xm__Alert_Type__c='Purchase - Contact Me',
                medallia_xm__Alert_Yn_Flag__c='Yes',
                medallia_xm__Contact_Email__c='swati.bansal@consultant.volvo.com',
                medallia_xm__Contact_Id__c=testCon.id,
                medallia_xm__Record_Creation_date__c=System.now(),
                medallia_xm_Survey_Type__c='Purchase',
                medallia_xm__Record_Medallia_Id__c='357086',
                medallia_xm__Response_Date__c=System.now(),
                medallia_xm_Alert_Creation_Date__c=System.now(),medallia_xm__Response_Main_score__c=2,
                medallia_xm__Response_Main_score_comment__c='testclassrceation',alert_country__c='UK');
            Test.startTest();
            insert testPurchaseResponse;
            
            
            Case testCase = new Case();
            testCase.medallia_xm__Medallia_Feedback_id__c = testPurchaseResponse.id;
            testCase.Subject= 'TestMedalliaCase';
            testCase.Status= 'New';
            testCase.MEDALLIACLF_alert_type__c='Purchase - Contact Me';
            testCase.RecordTypeId= caseRecordType;
            testCase.AccountId= testAcc.id;
            testCase.ContactId= testCon.id;
            insert testCase;
            Test.stopTest();
            List<case> casesToUpdate = new List<case>();
            casesToUpdate.add(testCase);
            VFSCORE_CaseService.ApplyCaseAssignmentRule(casesToUpdate);      
        }
        
        //Assert functionality
        medallia_xm__Medallia_Feedback__c testResponse =[Select id from medallia_xm__Medallia_Feedback__c];
        Case caseCreated =[Select Owner.Name,status,medallia_xm__Medallia_Feedback_id__c, subject from Case];
        Assert.areEqual(caseCreated.medallia_xm__Medallia_Feedback_id__c,testResponse.id , 'Follow up case created from test Response');
        Assert.areEqual('New',caseCreated.Status , 'Follow up case status is new');
        
        
        //Assert functionality for flow: MEDALLIACLF_Update_Alert_Status_From_Response
        testResponse.medallia_xm_Alert_Status__c='Overdue';
        update testResponse;
        Case caseUpdated =[Select status from Case];
        Assert.areEqual('Overdue',caseUpdated.Status , 'Follow up case status is overdue');
        
        //Assert functionality for flow: MEDALLIACLF_Update_Alert_Status_From_Response
        testResponse.medallia_xm_Alert_Status__c='Escalated';
        update testResponse;
        Case casestatusUpdated =[Select status from Case];
        Assert.areEqual('Escalated',casestatusUpdated.Status , 'Follow up case status is Escalated');
        
        
        
        
        //Assert functionality for flow: MEDALLIACLF_Sync_CLF_Case_Updates_To_Medallia
        caseUpdated.MEDALLIACLF_PURCHASE_ACTIONS_TAKEN__c= '6';
        update caseUpdated;
        Assert.areEqual('6',caseUpdated.MEDALLIACLF_PURCHASE_ACTIONS_TAKEN__c , 'Follow up case is updated');
        
        
        // Prepare the Flow variables
       
       /* Map<String, Object> params = new Map<String, Object>();
        params.put('Case', caseUpdated);
        
        // Instantiate and start the Flow
        Flow.Interview.MEDALLIACLF_Send_Custom_Notification_To_Case_Owners testFlow = new Flow.Interview.MEDALLIACLF_Send_Custom_Notification_To_Case_Owners(params);
        testFlow.start(); */
        
        
    }
    
 
    
}