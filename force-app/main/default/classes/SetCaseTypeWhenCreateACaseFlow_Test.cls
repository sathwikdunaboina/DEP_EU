/* 
* -----------------------------------------------------------------------------------------
* Apex Class Name     SetCaseTypeWhenCreateACaseFlow_Test
* @author             Swami Goskula<Swami.goskula@consulant.volvo.com>
* @Created Date       03-03-2026 
* @Used By            Set Casetype and Subtype when create a new case

* -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* @description        This class is used to test Set Case Type When Create A Case flow and it will create a new case and update case type and sub type and country based on Case owner
.
* -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
@isTest
public class SetCaseTypeWhenCreateACaseFlow_Test {
    
@testSetup  
    static void setup(){
        Id accountRecordTypeID = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('All Case').getRecordTypeId();
        Id queueId = [SELECT Id,Type FROM Group where DeveloperName ='UK_IE_Contract_Extensions' and Type='Queue' LIMIT 1].Id;
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
        
    }
    /*
* ---------------------------------------------------------------------------------------------------------------------------------------------
* @Method Name     createACaseForVT
* @description     This method is used to update Case Type and Sub type and Country values when case owner is equals to UK/IE-Contract Ext VT
* --------------------------------------------------------------------------------------------------------------------------------------------
*/    
@isTest
    static void createACaseForVT(){
        Id accountRecordTypeID = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('All Case').getRecordTypeId();
        Id queueId = [SELECT Id,Type FROM Group where DeveloperName ='UK_IE_Contract_Extensions' and Type='Queue' LIMIT 1].Id;
        Account acc= [select id from Account where name='Test Account for UK'];
        
        case NewCase =new case();
        NewCase.Origin = 'Email';
        NewCase.RecordTypeId=recordTypeId;
        NewCase.OwnerId=queueId;
        NewCase.AccountId=acc.id;
        NewCase.Subject= 'Test case for UK/IE-Contract Ext VT';
        Test.startTest();            
        insert NewCase;
        Test.stopTest();
        
        Case getCaseTypeandSubtype = [SELECT id,Type,Sub_Type__c,Country__c FROM Case  WHERE id= :NewCase.Id ];            
        System.assertEquals('United Kingdom', getCaseTypeandSubtype.Country__c );
        System.assertEquals('Finance - EOT', getCaseTypeandSubtype.Type );
        System.assertEquals('Extension request', getCaseTypeandSubtype.Sub_Type__c );
    }
    /*
* ---------------------------------------------------------------------------------------------------------------------------------------------
* @Method Name     createACaseForRT
* @description     This method is used to update Case Type and Sub type and Country values when case owner is equals to UK/IE-Contract Ext RT
* --------------------------------------------------------------------------------------------------------------------------------------------
*/     
    @isTest
    static void createACaseForRT(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('All Case').getRecordTypeId();
        Id queueId = [SELECT Id,Type FROM Group where DeveloperName ='UK_IE_Contract_Extensions_RT' and Type='Queue' LIMIT 1].Id;
        Account acc= [select id from Account where name='Test Account for UK'];

        case NewCase =new case();
        NewCase.Origin = 'Email';
        NewCase.RecordTypeId=recordTypeId;
        NewCase.OwnerId=queueId;
        NewCase.Subject= 'Test case for UK/IE-Contract Ext RT';
        Test.startTest();            
        insert NewCase;
        Test.stopTest();
        
        Case getCaseTypeandSubtype = [SELECT id,Type,Sub_Type__c,Country__c FROM Case  WHERE id= :NewCase.Id ];            
        System.assertEquals('United Kingdom', getCaseTypeandSubtype.Country__c );
        System.assertEquals('Finance - EOT', getCaseTypeandSubtype.Type );
        System.assertEquals('Extension request', getCaseTypeandSubtype.Sub_Type__c );


    }
    /*
* ---------------------------------------------------------------------------------------------------------------------------------------------
* @Method Name     createACaseForRT
* @description     This method is used to update Case Type and Sub type and Country values when case owner is equals to UK/IE-Contract Ext VCE
* --------------------------------------------------------------------------------------------------------------------------------------------
*/    
        @isTest
    static void createACaseForVCE(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('All Case').getRecordTypeId();
        Id queueId = [SELECT Id,Type FROM Group where DeveloperName ='UK_IE_Contract_Extensions_VCE' and Type='Queue' LIMIT 1].Id;
        Account acc= [select id from Account where name='Test Account for UK'];

        case NewCase =new case();
        NewCase.Origin = 'Email';
        NewCase.RecordTypeId=recordTypeId;
        NewCase.OwnerId=queueId;
        NewCase.Subject= 'Test case for UK/IE-Contract Ext VCE';
        Test.startTest();            
        insert NewCase;
        Test.stopTest();
        
        Case getCaseTypeandSubtype = [SELECT id,Type,Sub_Type__c,Country__c FROM Case  WHERE id= :NewCase.Id ];            
        System.assertEquals('United Kingdom', getCaseTypeandSubtype.Country__c );
        System.assertEquals('Finance - EOT', getCaseTypeandSubtype.Type );
        System.assertEquals('Extension request', getCaseTypeandSubtype.Sub_Type__c );

    }
    /*
* ---------------------------------------------------------------------------------------------------------------------------------------------
* @Method Name     createACaseForRT
* @description     This method is used to update Case Type and Sub type and Country values when case owner is equals to UK/IE-Contract Ext BRS
* --------------------------------------------------------------------------------------------------------------------------------------------
*/    
        @isTest
    static void createACaseForBRS(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('All Case').getRecordTypeId();
        Id queueId = [SELECT Id,Type FROM Group where DeveloperName ='UK_IE_BRS' and Type='Queue' LIMIT 1].Id;
        Account acc= [select id from Account where name='Test Account for UK'];

        case NewCase =new case();
        NewCase.Origin = 'Email';
        NewCase.RecordTypeId=recordTypeId;
        NewCase.OwnerId=queueId;
        NewCase.Subject= 'Test case for UK/IE-Contract Ext BRS';
        Test.startTest();            
        insert NewCase;
        Test.stopTest();
        
        Case getCaseTypeandSubtype = [SELECT id,Type,Sub_Type__c,Country__c FROM Case WHERE id= :NewCase.Id];            
        System.assertEquals('United Kingdom', getCaseTypeandSubtype.Country__c );
        System.assertEquals('Finance - EOT', getCaseTypeandSubtype.Type );
        System.assertEquals('Extension request', getCaseTypeandSubtype.Sub_Type__c );

    }
}