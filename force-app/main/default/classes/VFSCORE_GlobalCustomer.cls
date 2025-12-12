/** 
 * ------------------------------------------------------------------------------------------------------------------------------
 * @Name:
 * @Author:
 * @CreatedDate: 
 * @UsedBy:
 * @SystemLayer: 
 * ------------------------------------------------------------------------------------------------------------------------------
 * @Description
 * 
 * Additional Info
 * ------------------------------------------------------------------------------------------------------------------------------
**/
public without sharing class VFSCORE_GlobalCustomer {
   
    public class VFSCORE_GlobalCustomer_Exception extends Exception{}
    // [PROPERTY] id
    // Customer Number/Identifier in source system
    @AuraEnabled
    public String id { 
        get; 
        set { 
            if(String.isNotBlank(value) && (!Pattern.matches('^[0-9A-Za-z-_]+$', value))) { throw new VFSCORE_GlobalCustomer_Exception('Customer Id does not match the acceptable pattern'); }
            else { this.id = value; }
        }
    }

    // [PROPERTY] legalEntity
    @AuraEnabled
    public String legalEntity { get; 
        set { 
            if(string.isBlank(value)) {throw new VFSCORE_GlobalCustomer_Exception('legalEntity cannot be blank');}
            else if(!Pattern.matches('^[A-Z]{2}\\d{2}$', value)) { throw new VFSCORE_GlobalCustomer_Exception('Customer legalEntity does not match the acceptable pattern'); }
            else {this.legalEntity = value;}
        }
    }

    // [PROPERTY] sourceSystemID
    // The CMS system which is the source of the customer.  Following pattern LEGAL_MARKET-CMS_NAME_VERSION ie PL04-LEO4
    @AuraEnabled
    public String sourceSystemID { get; 
        set { 
            if(string.isBlank(value)) {throw new VFSCORE_GlobalCustomer_Exception('sourceSystemID cannot be blank');}
            else if(!Pattern.matches('^[A-Z]+(\\d{1,2})?$', value)) { throw new VFSCORE_GlobalCustomer_Exception('Customer sourceSystemID does not match the acceptable pattern'); }
            else {this.sourceSystemID = value;}
        }
    }
    // [PROPERTY] name
    // Customer Name (Legal Name)
    @AuraEnabled
    public String name { get; 
        set { 
            if(string.isBlank(value)) {throw new VFSCORE_GlobalCustomer_Exception('Customer name cannot be blank');}
            else if(!Pattern.matches('.+', value)) { throw new VFSCORE_GlobalCustomer_Exception('Customer name does not match the acceptable pattern'); }
            else {this.name = value;}
        }
    }
    // [PROPERTY] code
    // is it Symbol from LEO?
    @AuraEnabled
    public String code { 
        get; 
        set { 
            if(String.isNotBlank(value) && (!Pattern.matches('^[0-9A-Za-z-_\\s]+$', value))) { throw new VFSCORE_GlobalCustomer_Exception('Customer code does not match the acceptable pattern'); }
            else { this.code = value; } 
        }
    }

    // [PROPERTY] businessName
    // Customer Business Name (doing business as name)
    @AuraEnabled
    public String businessName { 
        get; 
        set {
            if(String.isNotBlank(value) && (!Pattern.matches('.+', value))) { throw new VFSCORE_GlobalCustomer_Exception('Customer businessName does not match the acceptable pattern'); } 
            else { this.businessName = value; } 
        }
    }

    // [PROPERTY] groupCustomerNumber
    // Indicates if a Customer is grouped with other customers
    @AuraEnabled
    public String groupCustomerNumber {
        get; 
        set {
            if(String.isNotBlank(value) && (!Pattern.matches('^[0-9A-Za-z-_\\s]+$', value))) 
            { throw new VFSCORE_GlobalCustomer_Exception('Customer groupCustomerNumber does not match the acceptable pattern'); }
            else { this.groupCustomerNumber = value; } 
        }
    }

    // [PROPERTY] parmaCode
    // Unique customer number across all Volvo
    @AuraEnabled
    public String parmaCode {
        get; 
        set { 
            if(String.isNotBlank(value) && (!Pattern.matches('^[0-9A-Za-z-_\\s]+$', value))) 
            { throw new VFSCORE_GlobalCustomer_Exception('Customer groupCustomerNumber does not match the acceptable pattern'); }
            else { this.parmaCode = value; } 
        }
    }

    // [PROPERTY] volvoGroupPartnerCode
    // Partner company  code to indicate other Volvo company code for reporting
    @AuraEnabled
    public String volvoGroupPartnerCode {
        get; 
        set { 
            if(String.isNotBlank(value) && (!Pattern.matches('^[0-9A-Za-z-]+$', value))) 
            { throw new VFSCORE_GlobalCustomer_Exception('Customer groupCustomerNumber does not match the acceptable pattern'); }
            else { this.volvoGroupPartnerCode = value; }
        }
    }


    // [PROPERTY] isExcludedFromLatePaymentCalculation
    // Exclude from Late payment calculation
    @AuraEnabled
    public Boolean isExcludedFromLatePaymentCalculation { get; set { this.isExcludedFromLatePaymentCalculation = value; }}

    // [PROPERTY] latePaymentCalculationModel
    // Type of late payment calculation. Dictionary / enumeration value.
    @AuraEnabled
    public String latePaymentCalculationModel {
        get; 
        set { 
            if(String.isNotBlank(value) && (!Pattern.matches('^[0-9A-Za-z-_]+$', value))) 
            { throw new VFSCORE_GlobalCustomer_Exception('Customer groupCustomerNumber does not match the acceptable pattern'); }
            else { this.latePaymentCalculationModel = value; }
        }
    }

    // [PROPERTY] operationalStatus
    // Status of customer for operational purposes. Different to current BC status's. Dictionary / enumeration value.
    @AuraEnabled
    public String operationalStatus {
        get; 
        set { 
            if(String.isNotBlank(value) && (!Pattern.matches('^[0-9A-Za-z-_]+$', value))) 
            { throw new VFSCORE_GlobalCustomer_Exception('Customer groupCustomerNumber does not match the acceptable pattern'); }
            else { this.operationalStatus = value; }
        }
    }

    // [PROPERTY] VATNumber
    // Vat number of Customer (Federal Tax ID)
    @AuraEnabled
    public String VATNumber { get; 
        set { 
            if(string.isBlank(value)) {throw new VFSCORE_GlobalCustomer_Exception('VATNumber cannot be blank');}
            else if(!Pattern.matches('^([A-Z]{2})?[0-9-]+$', value)) { throw new VFSCORE_GlobalCustomer_Exception('Customer VATNumber does not match the acceptable pattern'); }
            else {this.VATNumber = value;}
        }
    }

    // [PROPERTY] companyRegistrationNumber1
    // Registration number of Customer
    @AuraEnabled
    public String companyRegistrationNumber1 { get; 
        set { 
            if(string.isBlank(value)) {throw new VFSCORE_GlobalCustomer_Exception('companyRegistrationNumber1 cannot be blank');}
            else if(!Pattern.matches('^[0-9A-Za-z-_]+$', value)) { throw new VFSCORE_GlobalCustomer_Exception('Customer companyRegistrationNumber1 does not match the acceptable pattern'); }
            else {this.companyRegistrationNumber1 = value;}
        }
    }

    // [PROPERTY] companyRegistrationNumber2
    @AuraEnabled
    public String companyRegistrationNumber2 {
        get; 
        set { 
            if(String.isNotBlank(value) && (!Pattern.matches('^[0-9A-Za-z-_]+$', value))) 
            { throw new VFSCORE_GlobalCustomer_Exception('Customer companyRegistrationNumber2 does not match the acceptable pattern'); }
            else { this.companyRegistrationNumber2 = value; }
        }
    }

    // [PROPERTY] legalForm
    // Type of company. Dictionary / enum value
    @AuraEnabled
    public String legalForm { get; 
        set { 
            if(string.isBlank(value)) {throw new VFSCORE_GlobalCustomer_Exception('legalForm cannot be blank');}
            else if(!Pattern.matches('^[0-9A-Za-z-_]+$', value)) { throw new VFSCORE_GlobalCustomer_Exception('Customer legalForm does not match the acceptable pattern'); }
            else {this.legalForm = value;}
        }
    }

    // [PROPERTY] defaultInvoiceDistributionModel
    // How the customer would like to receive their invoices.
    @AuraEnabled
    public String defaultInvoiceDistributionModel {
        get;
        set { 
            if(string.isBlank(value)) {throw new VFSCORE_GlobalCustomer_Exception('defaultInvoiceDistributionModel cannot be blank');}
            else if(!Pattern.matches('^[0-9A-Za-z-_]+$', value)) 
            { throw new VFSCORE_GlobalCustomer_Exception('Customer defaultInvoiceDistributionModel does not match the acceptable pattern'); }
            else { this.defaultInvoiceDistributionModel = value; }
        }
    }

    // [PROPERTY] defaultInvoiceDistributionEmail
    // The default email for invoice distribution in case distribution model is email.
    @AuraEnabled
    public String defaultInvoiceDistributionEmail {get; set{ this.defaultInvoiceDistributionEmail = value; }}

    // [PROPERTY] defaultCurrency
    // Default currency we invoice Customer.
    @AuraEnabled
    public String defaultCurrency {
        get; 
        set { 
            if(String.isNotBlank(value) && (!Pattern.matches('^[A-Z]{3}$', value))) 
            { throw new VFSCORE_GlobalCustomer_Exception('Customer defaultCurrency does not match the acceptable pattern'); }
            else { this.defaultCurrency = value; }
        }
    }

    // [PROPERTY] isIndividual
    @AuraEnabled
    public Boolean isIndividual {get; set{ this.isIndividual = value; }}

    // [PROPERTY] defaultPaymentMethod
    // Dictionary /enum value, Values are taken from dictionary, Payment Method,Payment Method code, Table ID, Description (English), CQ, Cheque/Check, DD, Direct Debit, SO, Standing Order, 
    // CT, Credit Transfer, PP, Pre-Payment, VN, Volvo Netting, BT, Bank Transfer
    @AuraEnabled
    public String defaultPaymentMethod {
        get; 
        set { 
            if(String.isNotBlank(value) && (!Pattern.matches('^[0-9A-Za-z-_]+$', value))) 
            { throw new VFSCORE_GlobalCustomer_Exception('Customer defaultPaymentMethod does not match the acceptable pattern'); }
            else { this.defaultPaymentMethod = value; }
        }
    }

    // [PROPERTY] defaultPaymentTerms
    // Dictionary /enum value
    @AuraEnabled
    public String defaultPaymentTerms {
        get; 
        set { 
            if(String.isNotBlank(value) && (!Pattern.matches('^[0-9A-Za-z-_]+$', value))) 
            { throw new VFSCORE_GlobalCustomer_Exception('Customer defaultPaymentTerms does not match the acceptable pattern'); }
            else { this.defaultPaymentTerms = value; }
        }
    }

    // [PROPERTY] language
    // Language for documents / Invoices. Following BCP 47 language tag format, Some common codes adopted by Microsoft (Business Central), https://learn.microsoft.com/en-us/openspecs/office_standards/ms-oe376/6c085406-a698-4e12-9d4d-c3b0ee3dbc4a, 
    // Removed the pattern regExpression (^[a-z]{2}-[A-Z]{2}$) due to the complexity of considering all possible cases.
    @AuraEnabled
    public String language {
        get; 
        set { 
            if(String.isNotBlank(value) && (!Pattern.matches('^[a-z-A-Z]+$', value))) 
            { throw new VFSCORE_GlobalCustomer_Exception('Customer language does not match the acceptable pattern'); }
            else { this.language = value; }
        }
    }

    // [PROPERTY] postingGroup
    // Required for VAT Posting. Dictionary / enum value.
    @AuraEnabled
    public String postingGroup {
        get; 
        set { 
            if(String.isNotBlank(value) && (!Pattern.matches('^[0-9A-Za-z-_]+$', value))) 
            { throw new VFSCORE_GlobalCustomer_Exception('Customer postingGroup does not match the acceptable pattern'); }
            else { this.postingGroup = value; }
        }
    }

    // [PROPERTY] businessPostingGroup
    // General Business Posting Group
    // Required for Sales Account Posting
    @AuraEnabled
    public String businessPostingGroup {
        get; 
        set { 
            if(String.isNotBlank(value) && (!Pattern.matches('^[0-9A-Za-z-_]+$', value))) 
            { throw new VFSCORE_GlobalCustomer_Exception('Customer businessPostingGroup does not match the acceptable pattern'); }
            else { this.businessPostingGroup = value; }
        }
    }

    // [PROPERTY] VATBusinessPostingGroup
    // Required for VAT Posting
    @AuraEnabled
    public String VATBusinessPostingGroup {get; set{ this.VATBusinessPostingGroup = value; }}

    // [PROPERTY] businessAddresses
    @AuraEnabled
    public List<VFSCore_GlobalBusinesssAddress> businessAddresses {get; 
        set {
            if(value == Null || value.isEmpty()) {throw new VFSCORE_GlobalCustomer_Exception('businessAddresses cannot be empty');}
            else {this.businessAddresses = value; }
        }
    }

    // [PROPERTY] purchaseCard
    // PSF - purchase card
    @AuraEnabled
    public String purchaseCard {
        get; 
        set { 
            if(String.isNotBlank(value) && (!Pattern.matches('^[0-9A-Za-z-_/\\\\]+$', value))) 
            { throw new VFSCORE_GlobalCustomer_Exception('Customer purchaseCard does not match the acceptable pattern'); }
            else { this.purchaseCard = value; }
        }
    }

    // [PROPERTY] fleetId
    // PSF - Fleet ID
    @AuraEnabled
    public String fleetId {
        get; 
        set { 
            if(String.isNotBlank(value) && (!Pattern.matches('^[0-9A-Za-z-_]+$', value))) 
            { throw new VFSCORE_GlobalCustomer_Exception('Customer fleetId does not match the acceptable pattern'); }
            else { this.fleetId = value; }
        }
    }

    // [PROPERTY] VFSVirtualBankAccounts
    // customer can have multiple, but one account per currency
    // @AuraEnabled
    // public List<SyncCustomer_VirtualBankAccount> VFSVirtualBankAccounts {get; set{ this.VFSVirtualBankAccounts = value; }}

    // [PROPERTY] bankAccounts
    @AuraEnabled
    public List<VFSCore_GlobalBankAccount> bankAccounts {get; set{ this.bankAccounts = value; }}

    // [PROPERTY] isGroupCustomer
    @AuraEnabled
    public Boolean isGroupCustomer {get; set{ this.isGroupCustomer = value; }}

    // [PROPERTY] intercompanyNumber
    @AuraEnabled
    public String intercompanyNumber {get; set{ this.intercompanyNumber = value; }}

    // [PROPERTY] individualOwner
    @AuraEnabled
    public VFSCore_GlobalContact individualOwner {get; set{ this.individualOwner = value; }}

    // // [PROPERTY] industrialClassificationCodes
    // @AuraEnabled
    // public String industrialClassificationCodes {get; set{ this.industrialClassificationCodes = value; }}

    // [PROPERTY] contacts
    @AuraEnabled
    public List<VFSCore_GlobalContact> contacts {get; set{ this.contacts = value; }}

    // // [PROPERTY] tradeName
    // @AuraEnabled
    // public String tradeName {get; set{ this.tradeName = value; }}

    // // [PROPERTY] isVindicated
    // @AuraEnabled
    // public Boolean isVindicated {get; set{ this.isVindicated = value; }}

    // [PROPERTY] businessPhone
    @AuraEnabled
    public String businessPhone {get; set{ this.businessPhone = value; }}

    // [PROPERTY] businessEmail
    @AuraEnabled
    public String businessEmail {get; set{ this.businessEmail = value; }}

    // // [PROPERTY] website
    // @AuraEnabled
    // public String website {get; set{ this.website = value; }}

    // // [PROPERTY] creditRating
    // @AuraEnabled
    // public String creditRating {get; set{ this.creditRating = value; }}

    // // [PROPERTY] size
    // @AuraEnabled
    // public String size {get; set{ this.size = value; }}
}