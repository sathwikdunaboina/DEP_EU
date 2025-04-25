/** 
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * @Name:               VFSCORE_GlobalCustomerService
 * @Author:             Infosys
 * @CreatedDate:        21st March 2024
 * @UsedBy:             VFSCORE_ContactChangeEventTriggerHandler, VFSCORE_BnkAccManChngeEvntTriggerHandler, VFSCORE_BnkAccChangeEventTriggerHandler, VFSCORE_AccountChangeEventTriggerHandler
 * @SystemLayer: 
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * @Description:        This class accepts the set od Account ids and queries them along with other related object records which 
 *                      are to be sent along with the acc to France Rental external system 
 * 
 * Additional Info: 
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 **/
public without sharing class VFSCORE_GlobalCustomerService {

    // Class level constants
    private String ACTIVE = 'active';
    private String INACTIVE = 'inactive';
    private String EMAIL = 'email';
    private String BANK_TRANSFER = 'BT';
    private String TEST_TYPE = 'TESTTYPE';
    private String ADDRESS_ID = 'ADDR_ID';
    private String MAIN = 'Main';
    private String NATIONAL = 'NATIONAL';
    private String INDIVIDUAL = 'Individual';
    private String VAT_NUMBER = '00000000';
    private String ADDRESSLINE1 = 'address1';
    // private String ZIPCODE = '000000';
    private String NA = 'NA';

    private String REFERENCE = 'ST10';
    private String NOT_AVAILABLE = 'NOTAVAILABLE';

    private Map<String, String> mapDefaultPayment = new Map<String, String> {
        'account' => 'A', 
        'bank transfer' => 'BT', 
        'cash' => 'H', 
        'credit card' => 'CT', 
        'cheque' => 'CQ', 
        'direct debit' => 'DD'
    };

    // Exception class definition
    public class VFSCORE_GlobalCustomerService_Exception extends Exception{}

    // Class level varible declaration
    // private addCustomer_Response response;
    private addCustomer_Request request;
    private List<Account> listAccount;
    private Set<Id> setAccId; 
    // private map<Id, List<Bank_Account__c>> mapAccIdToListBankAccount;
    private map<Id, List<Bank_Account_Mandate__c>> mapBankAccIdToListBankAccMandate;
    private map<Id, Linked_Bank_Accounts__c> mapBankAccIdToLinkedBankAcc;
    private map<Id, map<Id, List<Bank_Account_Mandate__c>>> mapAccIdToMapBankAccIdToListBankAccMandate;

    private List<ApiLog> listApiLog;



    public void syncCustomer(Set<Id> setAccId) {

        try {

            if(setAccId.isEmpty()) {

                throw new VFSCORE_GlobalCustomerService_Exception ('Account Id Set cannot be empty!!!');
            }   
            this.setAccId = setAccId;
            getAccountCustomers();
            createMaps();
            doCustomerCallouts();
            if(listApiLog != Null && !listApiLog.isEmpty()) {
                logApiExceptions();
            }
        } catch (Exception e) {
            ErrorLogUtil.createErrorLog('VFSCORE_GlobalCustomerService', e.getMessage(), '', e.getLineNumber(), 'syncCustomer', 
               e.getStackTraceString(), '', '', '');
        }
    }

    private void logApiExceptions() {

        List<ErrorLogUtil.LogMessage> listErrorLog = new List<ErrorLogUtil.LogMessage>();
        for(ApiLog al: listApiLog) {
            if(al !=null && al.objErrorLog != Null) {
                ErrorLogUtil.LogMessage logMsg = new ErrorLogUtil.LogMessage();
                logMsg.className = al.objErrorLog.className;
                logMsg.errorMessage = al.objErrorLog.errorMessage;
                logMsg.statusCode = al.objErrorLog.statusCode;
                logMsg.lineNumber = al.objErrorLog.lineNumber;
                logMsg.methodName = al.objErrorLog.methodName;
                logMsg.stackTrace = al.objErrorLog.stackTrace;
                logMsg.requestHeader = al.objErrorLog.requestHeader;
                logMsg.actualRequest = al.objErrorLog.actualRequest;
                logMsg.associatedRecord = al.objErrorLog.associatedRecord;
                logMsg.logType = 'error';
                logMsg.description = 'Integration';
                listErrorLog.add(logMsg);
            }
        }
        if(!listErrorLog.isEmpty()) {
            ErrorLogUtil.createLogs(listErrorLog);
        }
    }

    private void doCustomerCallouts() {

        listApiLog = new List<ApiLog>();
        ApiLog objApiLog;
        for(Account acc: listAccount) {

            try {
                objApiLog = new ApiLog();
                objApiLog.objErrorLog  = new ErrorLog();
                VFSCORE_GlobalCustomer objCustomer = createRequestBody(acc);

                addCustomer_Request request = createRequest(acc, objCustomer);
                System.debug('>>> request = ' + request);

                objApiLog = addCustomer(request);
                System.debug('>>> objApiLog = ' + objApiLog);
                
            } catch(Exception e) {
                System.debug('>>> exception: message = ' + e.getMessage() + ', lineNumber = ' + e.getLineNumber() + 
                ', stackTrace = ' + e.getStackTraceString() + ', className = VFSCORE_GlobalCustomerService, methodName = doCustomerCallouts');
                
                objApiLog.objErrorLog.className = 'VFSCORE_GlobalCustomerService';
                objApiLog.objErrorLog.errorMessage = e.getMessage();
                objApiLog.objErrorLog.statusCode = '';
                objApiLog.objErrorLog.lineNumber = e.getLineNumber();
                objApiLog.objErrorLog.methodName = 'doCustomerCallouts';
                objApiLog.objErrorLog.stackTrace = e.getStackTraceString();
                objApiLog.objErrorLog.requestHeader = '';
                objApiLog.objErrorLog.actualRequest = '';
                objApiLog.objErrorLog.associatedRecord = acc.Id;
            }
            listApiLog.add(objApiLog);
        }
    }

    private ApiLog addCustomer(addCustomer_Request req) {

        ApiLog objApiLog = new ApiLog();
        VFSCORE_GlobalCustomerApiClient objCustApiClient = new VFSCORE_GlobalCustomerApiClient();
        objApiLog = objCustApiClient.callApi(req);

        return objApiLog;
    }

    private addCustomer_Request createRequest(Account acc, VFSCORE_GlobalCustomer objCustomer) {

        addCustomer_Request req = new addCustomer_Request();
        req.legalx2dentity = objCustomer.legalEntity;
        req.customerId = acc.Id;
        req.body = objCustomer;
        req.requestBody = Json.serialize(objCustomer);

        return req;
    }

    private VFSCORE_GlobalCustomer createRequestBody(Account objAcc) {

        String requestBody = '';

        VFSCORE_GlobalCustomer custInfo = new VFSCORE_GlobalCustomer();
        custInfo.id =  objAcc.Id;
        custInfo.legalEntity =  objAcc.sourceSystemID__c.subStringBefore('-'); // there is no field mapping for this in the sheet 
        custInfo.sourceSystemID = objAcc.sourceSystemID__c.subStringBefore('-');
        custInfo.name =  objAcc.Name;
        // custInfo.code =  null;
        custInfo.businessName =  objAcc.businessName__c;
        custInfo.groupCustomerNumber =  objAcc.groupCustomerNumber__c;
        custInfo.parmaCode = objAcc.parmaCode__c;
        custInfo.volvoGroupPartnerCode =  null;
        custInfo.isExcludedFromLatePaymentCalculation = objAcc.isExcludedFromLatePaymentCalculation__c;
        custInfo.latePaymentCalculationModel =  null;
        custInfo.operationalStatus =  objAcc.Is_Deleted_From_Backbone__c ? INACTIVE : ACTIVE;
        custInfo.VATNumber = String.isNotBlank(objAcc.VATNumber__c) ? objAcc.VATNumber__c : VAT_NUMBER;
        custInfo.companyRegistrationNumber1 = objAcc.CompanyRegistrationNumber__c;
        custInfo.companyRegistrationNumber2 = objAcc.companyRegistrationNumber2__c;
        custInfo.legalForm = String.isNotBlank(objAcc.legalForm__c) ? objAcc.legalForm__c.subString((objAcc.legalForm__c.indexOf(' ') + 1)).replace(' ', '_') : INDIVIDUAL;
        custInfo.defaultInvoiceDistributionModel = String.isNotBlank(objAcc.defaultInvoiceDistributionModel__c) ? objAcc.defaultInvoiceDistributionModel__c : EMAIL;
        custInfo.defaultInvoiceDistributionEmail = objAcc.defaultInvoiceDistributionEmail__c;
        custInfo.defaultCurrency =  null; //objAcc.CurrencyIsoCode;
        custInfo.isIndividual = objAcc.isIndividual__c;
        system.debug('>>> objAcc.defaultPaymentMethod__c = ' + objAcc.defaultPaymentMethod__c);
        system.debug('>>> mapDefaultPayment = ' + mapDefaultPayment);
        custInfo.defaultPaymentMethod = String.isNotBlank(objAcc.defaultPaymentMethod__c) ? mapDefaultPayment.get(objAcc.defaultPaymentMethod__c.toLowerCase()) : BANK_TRANSFER;
        custInfo.defaultPaymentTerms = String.isNotBlank(objAcc.defaultPaymentTerms__c) ? objAcc.defaultPaymentTerms__c.replace(' ', '_') : objAcc.defaultPaymentTerms__c;
        custInfo.language =  null ;
        custInfo.postingGroup =  null;
        custInfo.businessPostingGroup =  null;
        custInfo.VATBusinessPostingGroup =  NATIONAL;
        
        custInfo.businessAddresses = getBusinessAddresses(objAcc);

        custInfo.purchaseCard = null;
        custInfo.fleetId = null;
        
        custInfo.bankAccounts = getBankAccounts(objAcc);

        custInfo.isGroupCustomer = true;
        custInfo.intercompanyNumber = null;
        custInfo.businessPhone = (objAcc.Phone != Null) ? objAcc.Phone.remove(' '): null;
        custInfo.businessEmail = null;

        if(objAcc.Contacts != null && !objAcc.Contacts.isEmpty()) {
            custInfo.contacts = getContacts(objAcc.Contacts); // to be discussed
        }
        
        // custInfo.getContacts();
        System.debug('>>> custInfo = ' + custInfo);
        return custInfo;
    }


    private List<VFSCORE_GlobalBankAccount> getBankAccounts(Account objAcc) {

        List<VFSCORE_GlobalBankAccount> bankAccounts = new List<VFSCORE_GlobalBankAccount>();
        if(objAcc.Bank_Accounts1__r != Null && !objAcc.Bank_Accounts1__r.isEmpty()) {

            for(Linked_Bank_Accounts__c lba: objAcc.Bank_Accounts1__r) {

                VFSCORE_GlobalBankAccount bankAccount = new VFSCORE_GlobalBankAccount();
                bankAccount.id = lba.Bank_Account__c;
                bankAccount.IBAN = lba.Bank_Account__r.IBAN__c;
                bankAccount.BIC = lba.Bank_Account__r.BIC__c;
                // bankAccount.currencies = lba.Bank_Account__r.CurrencyIsoCode;
                bankAccount.bankName = lba.Bank_Account__r.Name;
                bankAccount.isActive = lba.Bank_Account__r.Is_Active__c;
                bankAccount.bankCode = lba.Bank_Account__r.Bank_Code__c;
                bankAccount.BBAN = lba.Bank_Account__r.BBAN__c;
                bankAccount.bankBranchName = lba.Bank_Account__r.Bank_Branch_Name__c;
                // System.debug('>>> mapAccIdToMapBankAccIdToListBankAccMandate = ' + mapAccIdToMapBankAccIdToListBankAccMandate);
                bankAccount.mandates = getBankMandates(mapBankAccIdToListBankAccMandate.get(lba.Bank_Account__c));
                bankAccount.isDefault = lba.Default_Bank_Account__c;

                bankAccounts.add(bankAccount);
            }
        }
        return bankAccounts;        
    }

    private List<VFSCORE_GlobalBankMandate> getBankMandates(List<Bank_Account_Mandate__c> listBankAccountMandate){
    
        List<VFSCORE_GlobalBankMandate> listBankMandates = new List<VFSCORE_GlobalBankMandate>();
        if(listBankAccountMandate != Null && !listBankAccountMandate.isEmpty()) {

            for(Bank_Account_Mandate__c bam: listBankAccountMandate) {

                VFSCORE_GlobalBankMandate mandate = new VFSCORE_GlobalBankMandate();
                mandate.id = bam.Id;
                mandate.reference = String.isNotBlank(bam.Reference__c) ? bam.Reference__c : REFERENCE;
                mandate.type  = TEST_TYPE;
                mandate.signedDate = bam.Signed_Date__c;
                mandate.isActive = bam.Is_Active__c;

                listBankMandates.add(mandate);
            }
        }
        
        return listBankMandates;
    }

    private List<VFSCORE_GlobalBusinesssAddress> getBusinessAddresses(Account objAcc) {

        List<VFSCORE_GlobalBusinesssAddress> businessAddresses = new List<VFSCORE_GlobalBusinesssAddress>();
        VFSCORE_GlobalBusinesssAddress businessAddress;
        businessAddress = new VFSCORE_GlobalBusinesssAddress();
        businessAddress.id = ADDRESS_ID;
        businessAddress.type = MAIN;
        if(objAcc.BillingAddress != Null) {

            businessAddress.address = getAddress(objAcc);
        } 
        // businessAddress.contact = getContact(cont);
        businessAddress.contact = null;

        businessAddresses.add(businessAddress);
        return businessAddresses;
    }

    private List<VFSCORE_GlobalContact> getContacts(List<Contact> listContact) {

        List<VFSCORE_GlobalContact> listVfsGlobalContact = new List<VFSCORE_GlobalContact>();
        for(Contact cont: listContact) {
            listVfsGlobalContact.add(getContact(cont) );
        }
        return listVfsGlobalContact;
    }

    private VFSCORE_GlobalContact getContact(Contact cont) {
        VFSCORE_GlobalContact contact = new VFSCORE_GlobalContact();
        contact.id = cont.Id + cont.Email;
        contact.username = cont.Owner.Username;
        contact.firstName = cont.FirstName;
        contact.middleName = cont.MiddleName;
        contact.lastName = cont.LastName;
        contact.email = cont.Email;
        contact.phone = (cont.Phone != Null) ? cont.Phone.remove(' ') : ((cont.MobilePhone != Null) ? cont.MobilePhone.remove(' ') : null);
        contact.language = null;
        contact.dateOfBirth = cont.Birthdate;
        contact.salutation = cont.salutation;
        contact.jobTitle = cont.Title;
        
        
        if(cont.MailingAddress != Null) {

            contact.address = new VFSCore_GlobalAddress();
            contact.address.id = cont.Id;
            contact.address.addressLine1 = cont.MailingStreet;
            contact.address.addressLine2 = null;
            contact.address.addressLine3 = null;
            contact.address.city = cont.MailingCity; 
            contact.address.region = cont.MailingState;
            contact.address.zipCode = cont.MailingPostalCode;
            contact.address.country = cont.MailingCountryCode;
        }
        
        return contact;
    }

    private VFSCORE_GlobalAddress getAddress(Account objAcc) {

        VFSCORE_GlobalAddress address = new VFSCORE_GlobalAddress();
        address.id = ADDRESS_ID;
        address.addressLine1 = String.isNotBlank(objAcc.BillingStreet) ? objAcc.BillingStreet : NOT_AVAILABLE;
        address.addressLine2 = null;
        address.addressLine3 = null;
        address.city = objAcc.BillingCity;
        address.region = objAcc.BillingState;
        address.zipCode = String.isNotBlank(objAcc.BillingPostalCode) ? objAcc.BillingPostalCode :  NOT_AVAILABLE;
        address.country = String.isNotBlank(objAcc.BillingCountryCode) ? objAcc.BillingCountryCode : NA;
        return address;
    }

    private void getAccountCustomers() {

        listAccount = new List<Account>(
            [Select Id, sourceSystemID__c, Name, businessName__c, groupCustomerNumber__c, parmaCode__c, isExcludedFromLatePaymentCalculation__c, 
                    VATNumber__c, CompanyRegistrationNumber__c, companyRegistrationNumber2__c, legalForm__c, defaultInvoiceDistributionModel__c, 
                    defaultInvoiceDistributionEmail__c, CurrencyIsoCode, isIndividual__c, defaultPaymentMethod__c, defaultPaymentTerms__c, 
                    Phone, BillingAddress, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountryCode, Is_Deleted_From_Backbone__c, 
                    (Select Id, Birthdate, FirstName, MiddleName, LastName, Email, Phone, salutation, Title, Owner.Username, Owner.LanguageLocaleKey,  MailingAddress, MailingStreet, MailingCity, MailingState, MailingPostalCode, 
                    MailingCountryCode, MobilePhone From Contacts), 
                    (Select Id, Default_Bank_Account__c, Account__c, Account__r.Id, Bank_Account__c, Bank_Account__r.Id, Bank_Account__r.IBAN__c, Bank_Account__r.BIC__c, Bank_Account__r.CurrencyIsoCode, 
                            Bank_Account__r.Name, Bank_Account__r.Is_Active__c, Bank_Account__r.Bank_Code__c, Bank_Account__r.BBAN__c, 
                            Bank_Account__r.Bank_Branch_Name__c 
                     From Bank_Accounts1__r), 
                    (Select Account__c, Bank_Account__c, Id, Reference__c, Signed_Date__c, Registration_Date__c, Is_Active__c From Bank_Account_Mandates__r) 
             From Account 
             Where Id IN :setAccId]
        );
    }


    private void createMaps() {

        set<Id> setBankAccountId = new set<Id>();
        map<Id, Id> mapBankAccIdToAccountId = new map<Id, Id>();
        List<Bank_Account__c> listBankAccount = new List<Bank_Account__c>();
        // mapAccIdToListBankAccount = new Map<Id, List<Bank_Account__c>>();
        mapBankAccIdToLinkedBankAcc = new map<Id, Linked_Bank_Accounts__c>();
        // mapAccIdToMapBankAccIdToListBankAccMandate = new map<Id, map<Id, List<Bank_Account_Mandate__c>>> ();
        mapBankAccIdToListBankAccMandate = new map<Id, List<Bank_Account_Mandate__c>>();

        for(Account acc: listAccount) {

            if(acc.Bank_Accounts1__r != null && !acc.Bank_Accounts1__r.isEmpty()) {

                for(Linked_Bank_Accounts__c lba: acc.Bank_Accounts1__r) {
                    setBankAccountId.add(lba.Bank_Account__c);
                    mapBankAccIdToAccountId.put(lba.Bank_Account__c, lba.Account__c);
                    mapBankAccIdToLinkedBankAcc.put(lba.Bank_Account__c, lba);
                }
            }

            if(acc.Bank_Account_Mandates__r != Null && !acc.Bank_Account_Mandates__r.isEmpty()) {

                for(Bank_Account_Mandate__c bam: acc.Bank_Account_Mandates__r) {

                    if(mapBankAccIdToListBankAccMandate.isEmpty() || 
                       (!mapBankAccIdToListBankAccMandate.isEmpty() && !mapBankAccIdToListBankAccMandate.containsKey(bam.Bank_Account__c)) ) {

                        // map<Id, List<Bank_Account_Mandate__c>
                        mapBankAccIdToListBankAccMandate.put(bam.Bank_Account__c, new List<Bank_Account_Mandate__c>{bam});
                    } else if(!mapBankAccIdToListBankAccMandate.isEmpty() && mapBankAccIdToListBankAccMandate.containsKey(bam.Bank_Account__c)) {
                        
                        List<Bank_Account_Mandate__c> listBAM = mapBankAccIdToListBankAccMandate.get(bam.Bank_Account__c);
                        listBAM.add(bam);
                        mapBankAccIdToListBankAccMandate.put(bam.Bank_Account__c, listBAM);
                    }
                }
            }
        }

        if(!setBankAccountId.isEmpty() && mapBankAccIdToListBankAccMandate.isEmpty()) {

            for(Bank_Account_Mandate__c bam: [Select Account__c, Bank_Account__c, Id, Reference__c, Signed_Date__c, Registration_Date__c, Is_Active__c 
                                              From Bank_Account_Mandate__c Where Bank_Account__c IN :setBankAccountId]) {
                if(mapBankAccIdToListBankAccMandate.isEmpty() || 
                (!mapBankAccIdToListBankAccMandate.isEmpty() && !mapBankAccIdToListBankAccMandate.containsKey(bam.Bank_Account__c)) ) {

                    // map<Id, List<Bank_Account_Mandate__c>
                    mapBankAccIdToListBankAccMandate.put(bam.Bank_Account__c, new List<Bank_Account_Mandate__c>{bam});
                } else if(!mapBankAccIdToListBankAccMandate.isEmpty() && mapBankAccIdToListBankAccMandate.containsKey(bam.Bank_Account__c)) {
                    
                    List<Bank_Account_Mandate__c> listBAM = mapBankAccIdToListBankAccMandate.get(bam.Bank_Account__c);
                    listBAM.add(bam);
                    mapBankAccIdToListBankAccMandate.put(bam.Bank_Account__c, listBAM);
                }
            }
        }

        // if(!setBankAccountId.isEmpty()) {
        //     listBankAccount = [Select Id, IBAN__c, BIC__c, CurrencyIsoCode, Name, Is_Active__c, Bank_Code__c, BBAN__c, Bank_Branch_Name__c 
        //                        From Bank_Account__c Where Id IN :setBankAccountId];   

        //     for(Bank_Account__c bAcc: listBankAccount) {

        //         if(mapAccIdToListBankAccount.isEmpty() || (!mapAccIdToListBankAccount.isEmpty() && 
        //            !mapAccIdToListBankAccount.containsKey(mapBankAccIdToAccountId.get(bAcc.Id)))) {

        //             mapAccIdToListBankAccount.put(mapBankAccIdToAccountId.get(bAcc.Id), new List<Bank_Account__c>{bAcc});
        //         } else if(!mapAccIdToListBankAccount.isEmpty() && mapAccIdToListBankAccount.containsKey(mapBankAccIdToAccountId.get(bAcc.Id))) {

        //             List<Bank_Account__c> listBAcc = mapAccIdToListBankAccount.get(mapBankAccIdToAccountId.get(bAcc.Id));
        //             listBAcc.add(bAcc);
        //             mapAccIdToListBankAccount.put(mapBankAccIdToAccountId.get(bAcc.Id), listBAcc);
        //         } //else if(mapAccIdToListBankAccount.isEmpty())
        //     }
        // }
    }

    public class ApiLog {

        public ErrorLog objErrorLog;
        public httpResponse apiResponse;
    }
    

    public class ErrorLog {

        public string className;
        public string errorMessage;
        public string statusCode;
        public integer lineNumber;
        public string methodName;
        public string stackTrace;
        public string requestHeader;
        public string actualRequest;
        public string associatedRecord;
    }

    // Request parameters for operation: addCustomer
    public class addCustomer_Request {

        // [REQUEST] legal-entity
        // Legal entity of the requestor.
        public String legalx2dentity {get; set{ legalx2dentity = value; }}

        // [REQUEST] customerId
        // The ID of the customer
        public String customerId {get; set{ customerId = value; }}

        // [REQUEST] body
        // Customer object
        public VFSCore_GlobalCustomer body {get; set{ body = value; }}

        public String requestBody{get; set{ requestBody = value; }}
    }

}