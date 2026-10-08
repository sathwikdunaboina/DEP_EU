import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

const FIELDS = ['Account.Customer_Number__c','Account.Name'];

export default class statementOfAccountsButton extends LightningElement {
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

            const filter = `SALES_INVOICES/Recipient_x0020_ID eq '${this.customerNumber}'`;

         const url = `//app.powerbi.com/groups/e2ac5d3f-23b9-4558-8f71-ef76236ad114/reports/432f5650-3d3a-4af3-97fe-cc08177a0159/6ff35c4de1a9552760dd?filter=${encodeURIComponent(filter)}`;
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