/***********************************************************************************************************
 * Test Class Name: setCaseType_Test
 * Test class for: "setCaseType" process builder
 * Created Date: 17th August 2023
************************************************************************************************************
*******************************************   Changelog   **************************************************
S.No.    Date                    Developer Name              Azure Item Number
(1)      17th August 2023        Aswin Balaji - Infosys      TASK 6674: Create test class for setCaseType
***********************************************************************************************************/
@isTest
public class setCaseType_Test {
    
    static testMethod void queueOwner1() {
        Id UK_IE_Contract_Extensions = [SELECT Id, Name, DeveloperName, Email, Type 
                                        FROM Group where Type='Queue' And Name ='UK/IE-Contract Ext VT'].Id;
        System.debug('>>> UK_IE_Contract_Extensions = ' + UK_IE_Contract_Extensions);
        Case cs_UK_IE_Contract_Extensions = new Case();
        cs_UK_IE_Contract_Extensions.Status = 'New';
        cs_UK_IE_Contract_Extensions.Origin = 'Email';
        cs_UK_IE_Contract_Extensions.Subject = 'test@1';
        cs_UK_IE_Contract_Extensions.OwnerId = UK_IE_Contract_Extensions;
        cs_UK_IE_Contract_Extensions.Type = 'RFL'; // User Story-7542
        cs_UK_IE_Contract_Extensions.Sub_Type__c = 'Admin Fees Queries'; // User Story-7542
        cs_UK_IE_Contract_Extensions.Country__c = 'United Kingdom';
        insert cs_UK_IE_Contract_Extensions;
        System.debug('cs_UK_IE_Contract_Extensions'+cs_UK_IE_Contract_Extensions.Type);
        System.debug('cs_UK_IE_Contract_Extensions'+cs_UK_IE_Contract_Extensions.Sub_Type__c);
        System.debug('cs_UK_IE_Contract_Extensions'+cs_UK_IE_Contract_Extensions.Country__c);
        
        Id UK_IE_BRS = [SELECT Id, Name, DeveloperName, Email, Type FROM Group where Type='Queue' And Name ='UK/IE-Contract Ext BRS'].Id;
        Case cs_UK_IE_BRS = new Case();
        cs_UK_IE_BRS.Status = 'New';
        cs_UK_IE_BRS.Origin = 'Email';
        cs_UK_IE_BRS.Subject = 'test@1';
        cs_UK_IE_BRS.OwnerId = UK_IE_BRS;
        cs_UK_IE_BRS.Type = 'RFL'; // User Story-7542
        cs_UK_IE_BRS.Sub_Type__c = 'Admin Fees Queries'; // User Story-7542
        cs_UK_IE_BRS.Country__c = 'United Kingdom';
        insert cs_UK_IE_BRS;
        System.debug('cs_UK_IE_BRS'+cs_UK_IE_BRS.Type);
        System.debug('cs_UK_IE_BRS'+cs_UK_IE_BRS.Sub_Type__c);
        System.debug('cs_UK_IE_BRS'+cs_UK_IE_BRS.Country__c);
        assert.areEqual(UK_IE_BRS, cs_UK_IE_BRS.OwnerId);
        
        Id UK_IE_Contract_Extensions_VCE = [SELECT Id, Name, DeveloperName, Email, Type FROM Group where Type='Queue' And Name ='UK/IE-Contract Ext VCE'].Id;
        Case cs_UK_IE_Contract_Extensions_VCE = new Case();
        cs_UK_IE_Contract_Extensions_VCE.Status = 'New';
        cs_UK_IE_Contract_Extensions_VCE.Origin = 'Email';
        cs_UK_IE_Contract_Extensions_VCE.Subject = 'test@1';
        cs_UK_IE_Contract_Extensions_VCE.OwnerId = UK_IE_Contract_Extensions_VCE;
        cs_UK_IE_Contract_Extensions_VCE.Type = 'RFL'; // User Story-7542
        cs_UK_IE_Contract_Extensions_VCE.Sub_Type__c = 'Admin Fees Queries'; // User Story-7542
        cs_UK_IE_Contract_Extensions_VCE.Country__c = 'United Kingdom';
        insert cs_UK_IE_Contract_Extensions_VCE;
        System.debug('cs_UK_IE_Contract_Extensions_VCE'+cs_UK_IE_Contract_Extensions_VCE.Type);
        System.debug('cs_UK_IE_Contract_Extensions_VCE'+cs_UK_IE_Contract_Extensions_VCE.Sub_Type__c);
        System.debug('cs_UK_IE_Contract_Extensions_VCE'+cs_UK_IE_Contract_Extensions_VCE.Country__c);
        
        Id UK_IE_Contract_Extensions_RT = [SELECT Id, Name, DeveloperName, Email, Type FROM Group where Type='Queue' And Name ='UK/IE-Contract Ext RT'].Id;
        Case cs_UK_IE_Contract_Extensions_RT = new Case();
        cs_UK_IE_Contract_Extensions_RT.Status = 'New';
        cs_UK_IE_Contract_Extensions_RT.Origin = 'Email';
        cs_UK_IE_Contract_Extensions_RT.Subject = 'test@1';
        cs_UK_IE_Contract_Extensions_RT.OwnerId = UK_IE_Contract_Extensions_RT;
        cs_UK_IE_Contract_Extensions_RT.Type = 'RFL'; // User Story-7542
        cs_UK_IE_Contract_Extensions_RT.Sub_Type__c = 'Admin Fees Queries'; // User Story-7542
        cs_UK_IE_Contract_Extensions_RT.Country__c = 'United Kingdom';
        insert cs_UK_IE_Contract_Extensions_RT;
        System.debug('cs_UK_IE_Contract_Extensions_RT'+cs_UK_IE_Contract_Extensions_RT.Type);
        System.debug('cs_UK_IE_Contract_Extensions_RT'+cs_UK_IE_Contract_Extensions_RT.Sub_Type__c);
        System.debug('cs_UK_IE_Contract_Extensions_RT'+cs_UK_IE_Contract_Extensions_RT.Country__c);
    }
    
}