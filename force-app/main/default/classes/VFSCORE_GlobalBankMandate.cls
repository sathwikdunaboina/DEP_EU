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
public without sharing class VFSCORE_GlobalBankMandate {

    public class VFSCORE_GlobalBankMandate_Exception extends Exception{}
    // [PROPERTY] id
    @AuraEnabled
    public String id {get; set{ this.id = value; }}

    // [PROPERTY] reference
    @AuraEnabled
    public String reference { get; 
        set { 
            if(string.isBlank(value)) {throw new VFSCORE_GlobalBankMandate_Exception('Bank mandate reference cannot be blank');}
            else {this.reference = value;}
        }
    }

    // [PROPERTY] type
    @AuraEnabled
    public String type { get; 
        set { 
            if(string.isBlank(value)) {throw new VFSCORE_GlobalBankMandate_Exception('Bank mandate type cannot be blank');}
            else {this.type = value;}
        }
    }

    // [PROPERTY] signedDate
    @AuraEnabled
    public Date signedDate {get; set{ this.signedDate = value; }}

    // [PROPERTY] isActive
    @AuraEnabled
    public Boolean isActive {get; set{ this.isActive = value; }}
}