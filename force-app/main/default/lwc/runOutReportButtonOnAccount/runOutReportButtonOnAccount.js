import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

const FIELDS = ['Account.Customer_Number__c','Account.Name'];

export default class RunOutReportButtonOnAccount extends LightningElement {
    @api recordId;
    customerNumber;
    customerName;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredAccount({ error, data }) {
        if (data) {
            this.customerNumber = data.fields.Customer_Number__c.value;
            this.customerName=data.fields.Name.value;
        } else if (error) {
            this.customerNumber = null;
            this.customerName=null;
        }
    }

    handleProceed() {
        if (this.customerNumber) {
          
            const filter = `CUSTOMERS/Client_x0020_ID eq '${this.customerNumber}' and PAYMENT_SCHEDULES/Payee_x0020_ID eq '${this.customerNumber}'`;
            const url = `https://app.powerbi.com/groups/e2ac5d3f-23b9-4558-8f71-ef76236ad114/reports/f65457a6-d980-440d-b835-2a4125beab81/fc67cdfe53d097753af9?experience=power-bi&filter=${encodeURIComponent(filter)}`;
            window.open(url, '_blank');
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
}