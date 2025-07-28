import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

const FIELDS = ['Contract__c.Account__r.Customer_Number__c','Contract__c.Name','Contract__c.VIN_Number__c','Contract__c.Account__r.Name'];

export default class PaymentScheduleButtonOnContract extends LightningElement {
    @api recordId;
    accountCustomerNumber;
    contractName;
    contractVinNumber;
    customerName;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredContract({ error, data }) {
        if (data) {
            
            this.contractName=data.fields.Name.value;
            // eslint-disable-next-line no-console
            console.log("Customer Number:", this.contractName);
            this.contractVinNumber=data.fields.VIN_Number__c.value;
            this.accountCustomerNumber = data.fields.Account__r.value.fields.Customer_Number__c.value;
            this.customerName = data.fields.Account__r.value.fields.Name.value;

            // eslint-disable-next-line no-console
            console.log("Contract Name:", this.contractName, "VIN:", this.contractVinNumber);
            //eslint-disable-next-line no-console
      console.log( 'Account name ' ,this.accountCustomerNumber ); // logs entire object


        } else if (error) {
            this.accountCustomerNumber = null;
            this.contractName=null;
            this.contractVinNumber=null;
        }
    }

    handleProceed() {
        if (this.accountCustomerNumber) {
            const baseUrl = 'https://app.powerbi.com/groups/e2ac5d3f-23b9-4558-8f71-ef76236ad114/reports/3038db4e-fac8-4040-91b1-696c889ce5ef/2dfa53949a87a1887b1d';
            const filter = `filter=CONTRACTS/Contract_x0020_Number eq '${encodeURIComponent(this.contractName)}'` +
                ` and PAYMENT_SCHEDULES/Payee_x0020_ID eq '${encodeURIComponent(this.accountCustomerNumber)}'` +
                ` and CONTRACTS/VIN eq '${encodeURIComponent(this.contractVinNumber)}'`;
            
            const fullUrl = `${baseUrl}?experience=power-bi&${filter}`;
            
           // const filter = `CUSTOMERS/Client_x0020_ID eq '${this.customerNumber}' and PAYMENT_SCHEDULES/Payee_x0020_ID eq '${this.customerNumber}'`;
           // const url = `https://app.powerbi.com/groups/e2ac5d3f-23b9-4558-8f71-ef76236ad114/reports/f65457a6-d980-440d-b835-2a4125beab81/fc67cdfe53d097753af9?experience=power-bi&filter=${encodeURIComponent(filter)}`;
            window.open(fullUrl, '_blank');
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Redirecting...',
                    message: 'Opening external Power BI report in a new tab.',
                    variant: 'success'
                })
            );
        }

        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    get showSection() {
        return this.contractVinNumber && this.accountCustomerNumber;
    }
}