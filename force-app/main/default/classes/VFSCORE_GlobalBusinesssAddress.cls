/** 
 * ------------------------------------------------------------------------------------------------------------------------------
 * @Name:           VFSCore_GlobalBusinesssAddress
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
public without sharing class VFSCORE_GlobalBusinesssAddress {

    public class VFSCORE_GlobalBusinesssAddress_Exception extends Exception{}
    // [PROPERTY] id
    @AuraEnabled
    public String id { get; set { this.id = value; } }

    // [PROPERTY] type
    @AuraEnabled
    public String type { get; 
        set { 
            if(string.isBlank(value)) {throw new VFSCORE_GlobalBusinesssAddress_Exception('Business Address type cannot be blank');}
            else {this.type = value;}
        }
    }

    // [PROPERTY] address
    @AuraEnabled
    public VFSCore_GlobalAddress address { get; 
        set { 
            if(value == Null) {throw new VFSCORE_GlobalBusinesssAddress_Exception('address cannot be empty');}
            else {this.address = value;}
        }
    }

    // [PROPERTY] contact
    @AuraEnabled
    public VFSCore_GlobalContact contact {get; set{ this.contact = value; }}
}