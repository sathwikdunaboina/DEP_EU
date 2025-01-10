/* 
* -----------------------------------------------------------------------------------------
* Apex Class Name     CreateANewCaseFrom30DaysOldFlow_Test
* @author             Swami Goskula<Swami.goskula@consulant.volvo.com>
* @Created Date       12-02-2024 
* @Used By            Create A New Case From 30 Days Old Closed Case

* ------------------------------------------------------------------------------------------
* @description        This class is used to test Create A New Case From 30 Days Old Closed Case.
* ------------------------------------------------------------------------------------------
*/
@IsTest(SeeAllData=false)
public class CreateANewCaseFrom30DaysOldFlow_Test {
    
    /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     emailMessageTobeSentToCustomer
* @description     To cover Create A New Case From 30 Days Old Closed Case when a new Case is created from 30 days old closed case and Email has been sent to the customer
* ------------------------------------------------------------------------------------------------------
*/
    
    @isTest
    static void emailMessageTobeSentToCustomer(){
        User testUser = [SELECT Id, Username FROM User WHERE Email = 'vfs.support.salesforce@volvo.com' LIMIT 1];
        System.runAs(testUser){
            Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('All Case').getRecordTypeId();
            Id accountRecordTypeID = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
            
            //Create an Account Record
            Account acc= new Account();
            acc.name='Test Account for 30';
            acc.CurrencyIsoCode='EUR';
            acc.RecordTypeId=accountRecordTypeID;  
            insert acc;
            Entitlement EntitlementRecord = new Entitlement();
            EntitlementRecord.Name='Case Support Process For UK/IE';
            EntitlementRecord.AccountId= acc.Id;             
            insert EntitlementRecord;
            
            Case caseWithEmail = new Case();
            caseWithEmail.Origin = 'Email';
            caseWithEmail.AccountId=acc.id;
            caseWithEmail.RecordTypeId=recordTypeId;
            caseWithEmail.Status = 'Closed';
            caseWithEmail.Type='Change my details';
            caseWithEmail.Sub_Type__c ='Company details';
            caseWithEmail.Status_Reason__c='No Action';
            caseWithEmail.Subject='Test Case Subject with Email';
            caseWithEmail.CreatedDate = Date.today().addDays(-32);
            caseWithEmail.ClosedDate=Date.today().addDays(-31);
            caseWithEmail.Country__c='United kingdom'; 
            caseWithEmail.SuppliedEmail='testcase@gmail.com';  
            insert caseWithEmail;
            Test.startTest();            
            caseWithEmail.Status='New';      
            update caseWithEmail;
            Test.stopTest();           
            Case newCasewithEmail = [SELECT id,Casenumber,SuppliedEmail,RecordTypeId,OwnerId,Status,ClosedDate,CreatedDate,Subject,Country__c FROM Case WHERE Country__c='United Kingdom' and Status='New' limit 1 ];
            Id queueId = [SELECT Id,Type FROM Group where DeveloperName ='UK_IE_CS_Operations' and Type='Queue' LIMIT 1].Id;
            System.assertEquals(queueId, newCasewithEmail.OwnerId); 
            System.assertEquals(recordTypeId, newCasewithEmail.RecordTypeId);
            
        }
        
    }
    /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     emailMessageNotSentToCustomer
* @description     To cover Create A New Case From 30 Days Old Closed Case when a new Case is created from 30 days old case without email it will not send an email 
with Attachment
* ------------------------------------------------------------------------------------------------------
*/
    
    @isTest
    static void emailMessageNotSentToCustomer(){
        User otestUser = [SELECT Id, Username FROM User WHERE Email = 'vfs.support.salesforce@volvo.com' LIMIT 1];
        System.runAs(otestUser){ 
            Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('All Case').getRecordTypeId();
            Id accountRecordTypeID = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
            
            //Create an Account Record
            Account acc= new Account();
            acc.name='Test Account for 30';
            acc.CurrencyIsoCode='EUR';
            acc.RecordTypeId=accountRecordTypeID;  
            insert acc;
            Entitlement EntitlementRecord = new Entitlement();
            EntitlementRecord.Name='Case Support Process For UK/IE';
            EntitlementRecord.AccountId= acc.Id;             
            insert EntitlementRecord;
            
            Case caseWithoutEmail = new Case();
            caseWithoutEmail.Origin = 'Email';
            caseWithoutEmail.AccountId=acc.id;
            caseWithoutEmail.RecordTypeId=recordTypeId;
            caseWithoutEmail.Status = 'Closed';
            caseWithoutEmail.Type='Change my details';
            caseWithoutEmail.Sub_Type__c ='Company details';
            caseWithoutEmail.Status_Reason__c='No Action';
            caseWithoutEmail.Subject='Test Case Subject without Email';
            caseWithoutEmail.CreatedDate = Date.today().addDays(-32);
            caseWithoutEmail.ClosedDate=Date.today().addDays(-31);
            caseWithoutEmail.Country__c='Ireland';       
            insert caseWithoutEmail;  
            System.debug('caseWithoutEmail'+caseWithoutEmail);
            Test.startTest();     
            caseWithoutEmail.Status = 'New';
            update caseWithoutEmail;
            Test.stopTest();
            Case newCaseWithOutEmail = [SELECT id,Casenumber,SuppliedEmail,OwnerId,Status,Subject,Country__c FROM Case WHERE Country__c='United Kingdom' and Status='New' limit 1 ];
            Id queueId = [SELECT Id,Type FROM Group where DeveloperName ='UK_IE_CS_Operations' and Type='Queue' LIMIT 1].Id;
            System.assertEquals(queueId, newCaseWithOutEmail.OwnerId); 
            System.assertEquals(null,newCaseWithOutEmail.SuppliedEmail);
        }
    }
}