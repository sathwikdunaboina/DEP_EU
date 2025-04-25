/** 
 * ------------------------------------------------------------------------------------------------------------------------------
 * @Name:           VFSCore_GlobalAddress
 * @Author:         Infosys
 * @CreatedDate:    03rd March 2024
 * @UsedBy:         VFSCore_GlobalBusinesssAddress, 
 * @SystemLayer:    
 * ------------------------------------------------------------------------------------------------------------------------------
 * @Description
 * 
 * Additional Info
 * ------------------------------------------------------------------------------------------------------------------------------
**/
public without sharing class VFSCORE_GlobalAddress {

    public class VFSCORE_GlobalAddress_Exception extends Exception{}
    // [PROPERTY] id
    @AuraEnabled
    public String id {
        get; 
        set {
            if(!Pattern.matches('^[0-9A-Za-z-_]+$', value)) { throw new VFSCORE_GlobalAddress_Exception('Address id does not match the acceptable pattern'); } 
            else { this.id = value; } 
        }
    }

 
    // [PROPERTY] addressLine1
    @AuraEnabled
    public String addressLine1 { get; 
        set { 
            if(string.isBlank(value)) {throw new VFSCORE_GlobalAddress_Exception('addressLine1 cannot be blank');}
            else {this.addressLine1 = value;}
        }
    }

    // [PROPERTY] addressLine2
    @AuraEnabled
    public String addressLine2 {get; set{ this.addressLine2 = value; }}

    // [PROPERTY] addressLine3
    @AuraEnabled
    public String addressLine3 {get; set{ this.addressLine3 = value; }}

    // [PROPERTY] city
    @AuraEnabled
    public String city {get; set{ this.city = value; }}

    // [PROPERTY] region
    // Region/State
    @AuraEnabled
    public String region {get; set{ this.region = value; }}

    // [PROPERTY] zipCode
    @AuraEnabled
    public String zipCode { get; 
        set { 
            if(string.isBlank(value)) {throw new VFSCORE_GlobalAddress_Exception('zipCode cannot be blank');}
            else if(!Pattern.matches('^[0-9A-Za-z-\\s]+$', value)) { throw new VFSCORE_GlobalAddress_Exception('Address zipCode does not match the acceptable pattern'); }
            else {this.zipCode = value;}
        }
    }

    // [PROPERTY] country
    // ISO country code
    @AuraEnabled
    public String country { get; 
        set { 
            if(string.isBlank(value)) {throw new VFSCORE_GlobalAddress_Exception('country cannot be blank');}
            else if(!Pattern.matches('^[0-9A-Za-z]+$', value)) { throw new VFSCORE_GlobalAddress_Exception('Address country does not match the acceptable pattern'); }
            else {this.country = value;}
        }
    }

    @AuraEnabled
    public static string toString(VFSCore_GlobalAddress objAddress) {
        try {
            return Json.Serialize(objAddress);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}