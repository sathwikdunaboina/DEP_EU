import { LightningElement, api, wire, track } from 'lwc';
import getLeadList from '@salesforce/apex/BulkLeadConvertController.getLeadList';
import convert from '@salesforce/apex/BulkLeadConvertController.convert';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const columns = [
    { label: 'Company', fieldName: 'Company' },
    { label: 'Name', fieldName: 'Name' },
    { label: 'Sales Person Name', fieldName: 'Sales_Person_Name__c' },
    { label: 'Product Name', fieldName: 'Product_Name__c' },
    { label: 'Axile Arrangement', fieldName: 'Axle_Arrangement__c' },
    { label: 'Chassis Type', fieldName: 'Chassis_Type__c' },
    { label: 'Dealer Name', fieldName: 'Dealer_Name__c' },
    { label: 'Lead Status', fieldName: 'Status' },
    { label: 'Vehicle Status', fieldName: 'Vehicle_Status__c' },
    { label: 'Dealer Delivery Date', fieldName: 'Dealer_Delivery_Date__c', type: 'date' },
    { label: 'Owner', fieldName: 'Owner.Name' },
    { label: 'Lead Source', fieldName: 'LeadSource' }
];

export default class BulkLeadConvert extends LightningElement {
    @track leadIds = [];
    @track leadListToConvert = [];
    columns = columns;
    @track accountId; 
    @track contactId;
    isProcessing = false;
    get leadsToConvert(){
        return this.leadIds;
    }

    @api set leadsToConvert(value){
        this.leadIds = value;
    }
    
    @wire (getLeadList, {leadIds : '$leadIds'})
    wiredLeadList({ error, data }) {
        console.log(JSON.stringify(data));
        console.log(JSON.stringify(error));
        if (data) {
            this.leadListToConvert = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.leadListToConvert = undefined;
        }
    }
    convertSelected(){
        this.isProcessing = true;
        console.log('this.accountId ' + this.accountId);
        console.log('this.contactId' + this.contactId);
        convert({
            leadIds : this.leadIds,
            accountId : this.accountId,
            contactId : this.contactId
        }).then(result =>{
            this.isProcessing = false;
            if (result){
                this.showNotification('Converted Successfully', 'The selected leads are converted successfully' , 'success');
                this.close();
            } else {
                this.showNotification('Error when converting', 'Please contact admin' , 'error');
            }
        }).catch(error =>{
            this.showNotification('Error when converting', error.body.message, 'error');
            this.isProcessing = false;
        });
    }
    handleChange(event) {
        this.isProcessing = true;
        const field = event.target.name;
        console.log(field);
        if (field === 'accountId') {
            this.accountId = event.target.value || null;
            console.log(this.accountId);
            //this.template.querySelector(`[data-id="contactId"]`).value='holding';
        } else if (field === 'contactId') {
            this.contactId = event.target.value || null;;
            console.log(this.contactId);
        } 
        this.isProcessing = false;
    }    
    close(){
        // Creates the event to share to parent.
        const closeEvent = new CustomEvent('close', { });
        // Dispatches the event.
        this.dispatchEvent(closeEvent);
    }
    showNotification(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
}