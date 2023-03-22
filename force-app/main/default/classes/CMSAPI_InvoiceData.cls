/*
* Data container. Contains methods to parse response into SF Standard objects.
* 
* */
public with sharing class CMSAPI_InvoiceData {

    public String customerNumber;
    public String invoiceNumber;
    public String dueDate;
    public String invoiceDate;
    public Amount invoiceAmount;
    public Amount clearedAmount;
    public String status;
    public String invoiceType;
    public String invoiceSubType;
    public String invoiceReferenceInformation;
    
    public Invoice__c parseToInvoiceObj(){

        Invoice__c inv = new Invoice__c();
        inv.Account__r = new Account(CustomerId__c = this.customerNumber);
        inv.Name = this.invoiceNumber;
        inv.Due_Date__c = Date.valueOf(this.dueDate);
        inv.Cleared_Amount__c = this.clearedAmount.amount;
        inv.Status__c = this.status;
        inv.Invoice_Date__c = Date.valueOf(this.invoiceDate);
        inv.Invoice_Amount__c = this.invoiceAmount.amount;
        inv.CurrencyIsoCode = this.invoiceAmount.currencyCode;
        inv.Type__c = this.invoiceType;
        inv.Sub_Type__c = this.invoiceSubType;
        inv.Reference__c = this.invoiceReferenceInformation;
        inv.Invoice_Id__c = customerNumber + '-' + inv.Invoice_Date__c.YEAR() + '-' + invoiceNumber;
        return inv;
    }
    public Class Amount{
        public Decimal amount;
        public String currencyCode;
    }
}