/** 
 * ------------------------------------------------------------------------------------------------------------------------------
 * @Name:           VFSCore_GlobalBankAccount
 * @Author:         Infosys
 * @CreatedDate:    03rd March 2024
 * @UsedBy:         VFSCore_GlobalCustomer
 * @SystemLayer:    
 * ------------------------------------------------------------------------------------------------------------------------------
 * @Description
 * 
 * Additional Info
 * ------------------------------------------------------------------------------------------------------------------------------
**/
public without sharing class VFSCORE_GlobalBankAccount {

    public class VFSCORE_GlobalBankAccount_Exception extends Exception{}
    // [PROPERTY] id
    @AuraEnabled
    public String id {
        get; 
        set { 
            if(String.isNotBlank(value) && !Pattern.matches('^[A-Za-z0-9-_]+', value)) { throw new VFSCORE_GlobalBankAccount_Exception('Bank Account id does not match the acceptable pattern'); }
            else { this.id = value; }
        }
    }

    // [PROPERTY] IBAN
    @AuraEnabled
    public String IBAN {
        get; 
        set { 
            if(String.isNotBlank(value) && !Pattern.matches('^[A-Z0-9]+$', value)) { throw new VFSCORE_GlobalBankAccount_Exception('Bank Account IBAN does not match the acceptable pattern'); }
            else { this.IBAN = value; }
        }
    }

    // [PROPERTY] BIC
    @AuraEnabled
    public String BIC {get; 
        set { 
            if(String.isNotBlank(value) && !Pattern.matches('^[A-Z0-9]+', value)) { throw new VFSCORE_GlobalBankAccount_Exception('Bank Account BIC does not match the acceptable pattern'); }
            else { this.BIC = value; }
        }
    }

    // [PROPERTY] currency
    // @AuraEnabled
    // public String currencies {
    //     get; 
    //     set { 
    //         if(String.isNotBlank(value) && !Pattern.matches('^[A-Z]{3}$', value)) { throw new VFSCORE_GlobalBankAccount_Exception('Bank Account currencies does not match the acceptable pattern'); }
    //         else { this.currencies = value; }
    //     }
    // }

    // [PROPERTY] bankName
    @AuraEnabled
    public String bankName {get; set{ this.bankName = value; }}

    // [PROPERTY] isActive
    @AuraEnabled
    public Boolean isActive {get; set{ this.isActive = value; }}

    // [PROPERTY] bankCode
    @AuraEnabled
    public String bankCode {
        get; 
        set { 
            if(String.isNotBlank(value) && !Pattern.matches('^[A-Za-z0-9-_ ]+', value)) { throw new VFSCORE_GlobalBankAccount_Exception('Bank Account bankCode does not match the acceptable pattern'); }
            else { this.bankCode = value; }
        }
    }

    // [PROPERTY] BBAN
    @AuraEnabled
    public String BBAN {
        get; 
        set { 
            if(String.isNotBlank(value) && !Pattern.matches('^[0-9]+$', value)) { throw new VFSCORE_GlobalBankAccount_Exception('Bank Account BBAN does not match the acceptable pattern'); }
            else { this.BBAN = value; }
        }
    }

    // [PROPERTY] bankBranchName
    @AuraEnabled
    public String bankBranchName {get; set{ this.bankBranchName = value; }}

    // [PROPERTY] mandates
    @AuraEnabled
    public List<VFSCore_GlobalBankMandate> mandates {get; set{ this.mandates = value; }}

    // [PROPERTY] isDefault
    @AuraEnabled
    public Boolean isDefault {get; set{ this.isDefault = value; }}
}