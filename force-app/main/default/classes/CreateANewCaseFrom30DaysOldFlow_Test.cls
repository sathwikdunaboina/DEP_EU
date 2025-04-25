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
        User testUser = [SELECT Id, Username FROM User WHERE lastname = 'VFS Salesforce Support' LIMIT 1];
        System.runAs(testUser){
            Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('All Case').getRecordTypeId();
            Id accountRecordTypeID = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
            Id queueId = [SELECT Id,Type FROM Group where DeveloperName ='UK_IE_CS_Operations' and Type='Queue' LIMIT 1].Id;
            
            //Create an Account Record
            Account acc= new Account();
            acc.name='Test Account for UK';
            acc.CurrencyIsoCode='EUR';
            acc.RecordTypeId=accountRecordTypeID; 
            acc.BillingCountry='United Kingdom';
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
            caseWithEmail.OwnerId=queueId;
            insert caseWithEmail;
            Test.startTest();            
            caseWithEmail.Status='New';
            update caseWithEmail;
            Test.stopTest();           
            Case newCasewithEmail = [SELECT id,RecordTypeId,OwnerId,Status,Subject,Country__c FROM Case WHERE Subject='Test Case Subject with Email' and Status='New' limit 1 ];            
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
        User otestUser = [SELECT Id, Username FROM User WHERE lastname = 'VFS Salesforce Support' LIMIT 1];
        System.runAs(otestUser){ 
            Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('All Case').getRecordTypeId();
            Id accountRecordTypeID = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
            Id queueId = [SELECT Id,Type FROM Group where DeveloperName ='UK_IE_CS_Operations' and Type='Queue' LIMIT 1].Id;
            
            //Create an Account Record
            Account acc= new Account();
            acc.name='Test Account For Ireland';
            acc.CurrencyIsoCode='EUR';
            acc.RecordTypeId=accountRecordTypeID;
            acc.BillingCountry='United Kingdom';
            
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
            caseWithoutEmail.OwnerId=queueId;
            insert caseWithoutEmail;  
            Test.startTest();     
            caseWithoutEmail.Status='New';
            update caseWithoutEmail;
            Test.stopTest();
            Case newCaseWithOutEmail = [SELECT id,SuppliedEmail,OwnerId,Status,Subject,Country__c FROM Case WHERE Subject='Test Case Subject without Email' and Status='New' limit 1 ];
            System.assertEquals(null,newCaseWithOutEmail.SuppliedEmail);
        }
    }
    /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     checkCountryForZA
* @description     To cover Create A New Case From 30 Days Old Closed Case when a new Case is created from 30 days old closed case for South Africa Country
* ------------------------------------------------------------------------------------------------------
*/
    @isTest
    static void checkCountryForZA(){
        User testUser = [SELECT Id, Username FROM User WHERE lastname = 'VFS Salesforce Support' LIMIT 1];
        System.runAs(testUser){
            Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('All Case').getRecordTypeId();
            Id accountRecordTypeID = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
            Id queueId = [SELECT Id,Type FROM Group where DeveloperName ='ZA_After_sales' and Type='Queue' LIMIT 1].Id;
            
            //Create an Account Record
            Account acc= new Account();
            acc.name='Test Account for ZA';
            acc.CurrencyIsoCode='EUR';
            acc.RecordTypeId=accountRecordTypeID; 
            acc.BillingCountry='South Africa';
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
            caseWithEmail.Subject='Test Case Subject with Country ZA';
            caseWithEmail.CreatedDate = Date.today().addDays(-32);
            caseWithEmail.ClosedDate=Date.today().addDays(-31);
            caseWithEmail.Country__c='South Africa'; 
            caseWithEmail.SuppliedEmail='testcaseza@gmail.com'; 
            caseWithEmail.OwnerId=queueId;
            insert caseWithEmail;
            Test.startTest();            
            caseWithEmail.Status='New';      
            update caseWithEmail;
            Test.stopTest();             
            Case newCasewithEmail = [SELECT id,RecordTypeId,OwnerId,Status,Subject,Country__c FROM Case WHERE Subject='Test Case Subject with Country ZA' and Status='New' limit 1 ];
            System.assertEquals(recordTypeId, newCasewithEmail.RecordTypeId);
            
        }
        
    }
      /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     emailMessageTobeSentToCustomer
* @description     To cover Create A New Case From 30 Days Old Closed Case when a new Case is created from 30 days old closed case and Email has been sent to the customer
* ------------------------------------------------------------------------------------------------------
*/
    
    @isTest
    static void emailMessageTobeSentWhenCaseFails(){
        User testUsertest = [SELECT Id, Username FROM User WHERE lastname = 'VFS Salesforce Support' LIMIT 1];
        System.runAs(testUsertest){
            Id recordTypeIdTest = Schema.SObjectType.Case.getRecordTypeInfosByName().get('All Case').getRecordTypeId();
            Id accountRecordTypeIDTest = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
            Id queueIdTest = [SELECT Id,Type FROM Group where DeveloperName ='UK_IE_CS_Operations' and Type='Queue' LIMIT 1].Id;
            
            //Create an Account Record
            Account accTest= new Account();
            accTest.name='Test Account for UK';
            accTest.CurrencyIsoCode='EUR';
            accTest.RecordTypeId=accountRecordTypeIDTest; 
            accTest.BillingCountry='United Kingdom';
            insert accTest;
            
            Entitlement EntitlementRecordTest = new Entitlement();
            EntitlementRecordTest.Name='Case Support Process For UK/IE';
            EntitlementRecordTest.AccountId= accTest.Id;             
            insert EntitlementRecordTest;
            
            Case caseWithEmailTest = new Case();
            caseWithEmailTest.Origin = 'Email';
            caseWithEmailTest.AccountId=accTest.id;
            caseWithEmailTest.RecordTypeId=recordTypeIdTest;
            caseWithEmailTest.Status = 'Closed';
            caseWithEmailTest.Type='Change my details';
            caseWithEmailTest.Sub_Type__c ='Company details';
            caseWithEmailTest.Status_Reason__c='No Action';
            caseWithEmailTest.Subject='Test Case Subject with Email';
            caseWithEmailTest.CreatedDate = Date.today().addDays(-32);
            caseWithEmailTest.ClosedDate=Date.today().addDays(-31);
            caseWithEmailTest.Country__c='United kingdom'; 
            caseWithEmailTest.SuppliedEmail='testcase@gmail.com'; 
            caseWithEmailTest.OwnerId=queueIdTest;
            insert caseWithEmailTest;
            Test.startTest();            
            caseWithEmailTest.Status='New';
            update caseWithEmailTest;
            EmailMessage testEmail = new EmailMessage();
            insert testEmail;
            Test.stopTest();           
            Case newCasewithEmailTest = [SELECT id,RecordTypeId,OwnerId,Status,Subject,Country__c FROM Case WHERE Subject='Test Case Subject with Email' and Status='New' limit 1 ];            
            System.assertEquals(recordTypeIdTest, newCasewithEmailTest.RecordTypeId);
        }
        
    }
}