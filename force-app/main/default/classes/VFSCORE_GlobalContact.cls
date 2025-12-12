/** 
 * ------------------------------------------------------------------------------------------------------------------------------
 * @Name:           VFSCore_GlobalContact
 * @Author:         Infosys
 * @CreatedDate:    03rd March 2024
 * @UsedBy:         VFSCore_GlobalBusinesssAddress, VFSCore_GlobalCustomer
 * @SystemLayer: 
 * ------------------------------------------------------------------------------------------------------------------------------
 * @Description
 * 
 * Additional Info
 * ------------------------------------------------------------------------------------------------------------------------------
**/
public without sharing class VFSCORE_GlobalContact {

    public class VFSCORE_GlobalContact_Exception extends Exception{}

    // [PROPERTY] id
    @AuraEnabled
    public String id {get; set{ this.id = value; }}

    // [PROPERTY] username
    @AuraEnabled
    public String username {get; set{ this.username = value; }}

    // [PROPERTY] firstName
    @AuraEnabled
    public String firstName {get; set{ this.firstName = value; }}

    // [PROPERTY] middleName
    @AuraEnabled
    public String middleName {get; set{ this.middleName = value; }}

    // [PROPERTY] lastName
    @AuraEnabled
    public String lastName {get; set{ this.lastName = value; }}
 
    // [PROPERTY] email
    @AuraEnabled
    public String email {get; set{ this.email = value; }}

    // [PROPERTY] phone
    // E.164 format
    @AuraEnabled
    public String phone { get; set { this.phone = value; } }

    // [PROPERTY] salutation
    @AuraEnabled
    public String salutation {get; set{ this.salutation = value; }}

    // [PROPERTY] language
    @AuraEnabled
    public String language { get; set { this.language = value; } }

    // [PROPERTY] jobTitle
    @AuraEnabled
    public String jobTitle {get; set{ this.jobTitle = value; }}

    // [PROPERTY] dateOfBirth
    @AuraEnabled
    public Date dateOfBirth {get; set{ this.dateOfBirth = value; }}

    // [PROPERTY] address
    @AuraEnabled
    public VFSCore_GlobalAddress address {get; set{ this.address = value; }}
}