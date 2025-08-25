import { LightningElement, api, wire } from 'lwc';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import LightningConfirm from "lightning/confirm";
import ID_FIELD from '@salesforce/schema/Opportunity.Id';
import QUOTE_ID_FIELD from '@salesforce/schema/Opportunity.Quote_Id__c';
import VFS_CONNECT_QUOTE_REF_FIELD from '@salesforce/schema/Opportunity.VFS_Connect_Quote_Ref__c';
import QUOTE_UNIQUE_ID_FIELD from '@salesforce/schema/Opportunity.Quote_Unique_Id__c';
import QUOTE_URL_FIELD from '@salesforce/schema/Opportunity.Quote_Url__c';

const FIELDS = [
    QUOTE_ID_FIELD,
    VFS_CONNECT_QUOTE_REF_FIELD,
    QUOTE_UNIQUE_ID_FIELD,
    QUOTE_URL_FIELD
];

export default class UnlinkQuoteFromOpportunity extends LightningElement {
    @api recordId;
    isLoading = false;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredOpportunity({ error }) {
        console.log('wire')
        if (error) {
            this.showToast('Error loading record', error.body?.message || 'Unknown error', 'error');
            this.closeQuickAction();
        }
    }

    connectedCallback() {
        // Delay to allow @wire to run first
         this.isLoading = true;
        setTimeout(() => this.updateFields(), 300);
    }
    hasRun = false;

    // renderedCallback() {
    //     // Ensure the logic runs only once
    //     if (this.hasRun) return;
    //     this.hasRun = true;
    //     this.updateFields();
    // }
    async updateFields() {
        // const confirmClear = confirm('Are you sure you want to remove the quote from this Opportunity?');
        // if (!confirmClear) {
        //     this.isLoading = false;
        //     this.closeQuickAction();
        //     return;
        // }
        const result = await LightningConfirm.open({
            message: 'Are you sure you want to remove the quote from this Opportunity?',
            variant: "default", // headerless
            label: "Confirm to link"
        });
        if (!result) {
            this.isLoading = false;
            this.closeQuickAction();
            return;
        }
        console.log('update')
        const fields = {
            [ID_FIELD.fieldApiName]: this.recordId,
            [QUOTE_ID_FIELD.fieldApiName]: null,
            [VFS_CONNECT_QUOTE_REF_FIELD.fieldApiName]: null,
            [QUOTE_UNIQUE_ID_FIELD.fieldApiName]: null,
            [QUOTE_URL_FIELD.fieldApiName]: null
        };

        try {
            await updateRecord({ fields });
             this.isLoading = false;
            this.showToast('Success', 'Quote successfully removed from this Opportunity', 'success');
        } catch (error) {
            console.log(error,'error')
             this.isLoading = false;
            this.showToast('Error updating record', error.body?.message || 'Unknown error', 'error');
        } finally {
            this.closeQuickAction();
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}