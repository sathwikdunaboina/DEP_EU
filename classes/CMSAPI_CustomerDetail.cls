/*
* Created: Prabha & Sumit
* Data container. Contains methods to parse response into SF Standard objects.
* 
* */
public class CMSAPI_CustomerDetail {
    
    public Account parseAccountData(){
        Account account = new Account();
        account.Name = CompanyName;
        account.CompanyRegistrationNumber__c = String.isBlank(RegisterCourtNumber) ? ChambreOfCommerce : RegisterCourtNumber;
        account.Customer_Number__c = CustomerNumber;
        //account.PrimaryEmail__c = Email;
        account.Website = WebSite;
        account.Phone = Phone;
        account.FiscalCode__c = OrganizationNumber;
        account.VATNumber__c = VatNumber;  
        //This is temporarly commeted, because the API is not sending GroupCode correctly.
        /*account.Branding__c = Label.Renault_Group_Code.equalsIgnoreCase(GroupCode)
            ? Label.Branding_Renault : Label.Branding_Volvo;*/
        if (Addresses != null && !Addresses.isEmpty()){
            Address mainAddress = parseMainAddressFromList(Addresses);
            account.BillingCity = mainAddress.City;
            //The Integration Value is 3Digit ISO code. eg: ITA for Italy.
            //The country is already coming in through Delta load, so this country is  ignored.
            //account.BillingCountry = mainAddress.CountryCode;
            account.BillingPostalCode = mainAddress.ZipCode;
            //account.BillingStateCode = mainAddress.StateCode; this is temporarly ignored as API is sending wrong statecodes.
            account.BillingStreet = clean(mainAddress.Prefix) + clean(mainAddress.HouseNumber) + clean(mainAddress.Address1)
                                        + clean(mainAddress.Address2) + clean(mainAddress.Address3);
        }
        return account;
    }
    
    public List<Schema.Contact> parseContactData(Id accId, String customerId){
        List<Schema.Contact> contactsToUpdate = new List<Schema.Contact>();
        if (this.Contacts == null) 
            return contactsToUpdate;
        for(CMSAPI_CustomerDetail.Contact data : Contacts){
            Schema.Contact contact = new Schema.Contact();
            contact.AccountId = accId;
            contact.ContactId__c = customerId+'-'+clean(data.Email);
            contact.FirstName = data.FirstName;
            contact.LastName = String.isBlank(data.LastName) ? data.Name : data.LastName; 
            contact.MiddleName = data.MiddleName;
            contact.Email = data.Email;
            contact.Phone = data.Phone;
            contact.Fax = data.Fax;
            contact.MobilePhone = data.Mobile;
            //TODO: Address Details based on Address type
            contactsToUpdate.add(contact);
        }
        return contactsToUpdate;
    }
    public Address parseMainAddressFromList(List<Address> Addresses){
        //Find the Address with type as Main.
        for (Address a : Addresses){
            if ('Main'.equalsIgnoreCase(a.AddressType)){
                return a;
            }
        }
        //If no Main address type found, then just use the first address.
        return Addresses[0];
    } 
    String clean(String s){
        return s==null ? '' : s;
    }
    private  String CompanyName;
    private  String RegisterCourtNumber;
    private  String Email;
    private  String Website;
    private  String GroupCode; //notmapped yet
    private  String Phone;
    private  String Mobile; //notmapped yet
    private  String ChambreOfCommerce;
    private  String VatNumber;
    private  String CustomerNumber;
    private  String CommunicationLanguage;
    private  String ExecutedPrivacyConsent;
    private  String VerbalPrivacyConsent;
    private  String OrganizationNumber;
    private  List<Address> Addresses;
    private  List<CMSAPI_CustomerDetail.Contact> Contacts;
    class Contact{
        private String Name;
        private String FirstName;
        private String MiddleName;
        private String LastName;
        private String SecondLastName;
        private String Gender;
        private String Salutation;
        private String Title;
        private String Profession;
        private String Phone;
        private String Fax;
        private String Mobile;
        private String Email;
        private String Note;
        private Address address; //Not found in API?
        private String MainContact;
        private ContactTypes ContactTypes;
        private String ContactNumber;
        private String CustomerNumber;
        private String FiscalCode;
        private String VatNumber;
        private String ChambreOfCommerce;
        private String IdentificationNumber;
        private String Nationality;
    }    
    class Address{
        private String AddressType;
        private String Prefix;
        private String HouseNumber;
        private String Address1;
        private String Address2;
        private String Address3;
        private String ZipCode;
        private String City;
        private String StateCode;
        private String CountryCode;
    }
    class ContactTypes{
        private String ContactTypes;
    }
}