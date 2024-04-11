@isTest
public class VFSCORE_GlobalCustomerService_Test {
    
    @TestSetup
    static void createData() {
        
        Id idAdminProfile = [Select Id from Profile where name = 'System Administrator' LIMIT 1][0].Id;
        Id idTmRole = [Select Id,DeveloperName From UserRole Where DeveloperName = 'IT_Territory_Manager' Limit 1][0].Id;
        Id idSalesProfile = [Select Id from Profile where Name = 'Sales' LIMIT 1][0].Id;


        User usrAdmin = new User(
            ProfileId = idAdminProfile,
            Username = 'admin@test.org' + System.currentTimeMillis(),
            Alias = 'adm',
            Email = 'admin@test.org',
            EmailEncodingKey = 'UTF-8',
            Firstname = 'Test',
            Lastname = 'Admin',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'Europe/Rome'
        );
        insert usrAdmin;

        System.runAs(usrAdmin) {

            User territoryManager1 = new User(
                ProfileId = idSalesProfile,
                UserRoleId = idTmRole,
                Username = 'territory@manager1.org' + System.currentTimeMillis(),
                Alias = 'tm1',
                Email = 'territory@manager1.org',
                EmailEncodingKey = 'UTF-8',
                Firstname = 'Territory',
                Lastname = 'Manager1',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'Europe/Rome'
            );
            insert territoryManager1;


            Id idAccRecordTypeCustAcc = Schema.SObjectType.account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();

            Account objCustAcc = new Account 
            (
                RecordTypeId = idAccRecordTypeCustAcc, 
                CustomerID__c = '1234',
                OwnerId = territoryManager1.Id, 
                BillingCountry = 'France', 
                BillingStreet = '345, Billng Street',
                BillingCity = 'Paris',
                // BillingState = 'ARA',
                BillingPostalCode = 'GYG6756',
                sourceSystemID__c = 'FR94',
                // legalEntity =  'FR94', // once the account field is finalized for this add it here
                name =  'TestCustomerAccount_VFSCORE',
                // code =  '12345HardCoded', // once the account field is finalized for this add it here
                businessName__c = 'BusinessName',
                groupCustomerNumber__c = 'hsdhb67567b',
                parmaCode__c = 'hsdhb67567b',   
                // volvoGroupPartnerCode =  '95405-HardCoded', // once the account field is finalized for this add it here
                isExcludedFromLatePaymentCalculation__c = True,
                // latePaymentCalculationModel =  'String_HardCoded', // once the account field is finalized for this add it here
                // operationalStatus =  'false_HardCoded', // once the account field is finalized for this add it here
                VATNumber__c = 'AP4500',
                CompanyRegistrationNumber__c = 'vrlap3453',
                companyRegistrationNumber2__c = 'vrlap3453',
                legalForm__c = 'daf546',
                defaultInvoiceDistributionModel__c = 'daf546',
                defaultInvoiceDistributionEmail__c = 'demo@demo.com',
                CurrencyIsoCode = 'EUR',
                isIndividual__c = false,
                defaultPaymentMethod__c = 'CQ',
                defaultPaymentTerms__c = 'dsf',
                // custInfo.language =  'FRA_HardCoded' , // once the account field is finalized for this add it here
                // custInfo.postingGroup =  'String_HardCoded', // once the account field is finalized for this add it here
                // custInfo.businessPostingGroup =  'String_HardCoded', // once the account field is finalized for this add it here
                // custInfo.VATBusinessPostingGroup =  'String_HardCoded', // once the account field is finalized for this add it here
                // custInfo.purchaseCard = 'String_HardCoded', // once the account field is finalized for this add it here
                // custInfo.fleetId = 'String_HardCoded', // once the account field is finalized for this add it here
                // custInfo.isGroupCustomer = true, // once the account field is finalized for this add it here
                // custInfo.intercompanyNumber = 'String_HardCoded', // once the account field is finalized for this add it here
                Phone = '7647887546'
                // custInfo.businessEmail = 'String_HardCoded@abera.fr' // once the account field is finalized for this add it here
            );
            insert objCustAcc;
            
            String cEmail = 'test@contact1.org' + System.currentTimeMillis();

            Contact objCont = new Contact (
                FirstName='first',
                MiddleName = 'Middle',
                LastName='TestCustomerContact_VFSCORE',
                Email=cEmail,
                OwnerId=territoryManager1.Id,
                AccountId = objCustAcc.Id,
                MailingCountry = 'France', 
                MailingStreet = '345, Billng Street',
                MailingCity = 'Paris',
                // MailingState = 'ARA',
                MailingPostalCode = 'GYG6756'

            );
            insert objCont;
            
            Bank_Account__c bankAccount = new Bank_Account__c (
                Name = 'Test Bank Account_VFSCORE'
            );
            insert bankAccount;
            
            Linked_Bank_Accounts__c linkedBankAccount = new Linked_Bank_Accounts__c (
                Bank_Account__c = bankAccount.Id,
                Account__c = objCustAcc.Id
            );
            insert linkedBankAccount;
            
            List<Bank_Account_Mandate__c> listBAM = new List<Bank_Account_Mandate__c>();
            Bank_Account_Mandate__c bankAccountMandate = new Bank_Account_Mandate__c (
                Bank_Account__c = bankAccount.Id,
                Is_Active__c = True,
                Name = 'Test bank account mandate_VFSCORE',
                Reference__c = 'bm_Reference'
            );
            listBAM.add(bankAccountMandate);


            Bank_Account_Mandate__c bankAccountMandate2 = new Bank_Account_Mandate__c (
                Bank_Account__c = bankAccount.Id,
                Is_Active__c = True,
                Name = 'Test bank account mandate_VFSCORE2',
                Reference__c = 'bm_Reference2'
            );
            listBAM.add(bankAccountMandate2);
            insert listBAM;
        }
    }

    @isTest
    static void runTestToInvoke() {

        HTTPMockFactory mock = new HTTPMockFactory(
        200,
        'OK',
        'I found it!',
        new Map<String, String>()
        );
        Test.setMock(HttpCalloutMock.class, mock);

        User tm2 = [Select Id,Name From User Where Email = 'territory@manager1.org' LIMIT 1][0];
        Account customerAccount = [SELECT Id,CustomerID__c FROM Account WHERE Name = 'TestCustomerAccount_VFSCORE'][0];
        customerAccount.CustomerID__c = '1233';
        update customerAccount;
        Test.getEventBus().deliver();
        Contact customerContact = [SELECT Id,FirstName FROM Contact WHERE LastName = 'TestCustomerContact_VFSCORE'][0];
        customerContact.FirstName = 'firstUpdate';
        update customerContact;
        Test.getEventBus().deliver();
        Bank_Account__c bankAccount = [SELECT Id,Name FROM Bank_Account__c WHERE Name = 'Test Bank Account_VFSCORE'][0];
        bankAccount.Name = 'Test Bank Account_VFSCOREUpdate';
        update bankAccount;
        Test.getEventBus().deliver();
        Linked_Bank_Accounts__c LBA = [SELECT Id,Account__c,Bank_Account__c,Account__r.sourceSystemID__c From Linked_Bank_Accounts__c Where Bank_Account__c =: bankAccount.Id];
        System.debug(LBA);
        Bank_Account_Mandate__c bankAccountMandate = [SELECT Id,Name FROM Bank_Account_Mandate__c WHERE Name = 'Test bank account mandate_VFSCORE'][0];
        bankAccountMandate.Name = 'Test bank account mandate_VFSCOREUpdate';
        update bankAccountMandate;
        Test.getEventBus().deliver();

        VFSCORE_GlobalAddress.toString(new VFSCore_GlobalAddress());
    }

    @isTest
    static void runTestToInvoke2() {

        HTTPMockFactory mock = new HTTPMockFactory(
        400,
        'Error',
        'did not find it!',
        new Map<String, String>()
        );
        Test.setMock(HttpCalloutMock.class, mock);

        User tm2 = [Select Id,Name From User Where Email = 'territory@manager1.org' LIMIT 1][0];
        Account customerAccount = [SELECT Id,CustomerID__c FROM Account WHERE Name = 'TestCustomerAccount_VFSCORE'][0];
        customerAccount.CustomerID__c = '1233';
        update customerAccount;
        Test.getEventBus().deliver();
        Contact customerContact = [SELECT Id,FirstName FROM Contact WHERE LastName = 'TestCustomerContact_VFSCORE'][0];
        customerContact.FirstName = 'firstUpdate';
        update customerContact;
        Test.getEventBus().deliver();
        Bank_Account__c bankAccount = [SELECT Id,Name FROM Bank_Account__c WHERE Name = 'Test Bank Account_VFSCORE'][0];
        bankAccount.Name = 'Test Bank Account_VFSCOREUpdate';
        update bankAccount;
        Test.getEventBus().deliver();
        Linked_Bank_Accounts__c LBA = [SELECT Id,Account__c,Bank_Account__c,Account__r.sourceSystemID__c From Linked_Bank_Accounts__c Where Bank_Account__c =: bankAccount.Id];
        System.debug(LBA);
        Bank_Account_Mandate__c bankAccountMandate = [SELECT Id,Name FROM Bank_Account_Mandate__c WHERE Name = 'Test bank account mandate_VFSCORE'][0];
        bankAccountMandate.Name = 'Test bank account mandate_VFSCOREUpdate';
        update bankAccountMandate;
        Test.getEventBus().deliver();

        VFSCORE_GlobalAddress.toString(new VFSCore_GlobalAddress());
    }
}