import { LightningElement, api, wire } from 'lwc';
import { getRecord, updateRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { subscribe, MessageContext } from 'lightning/messageService';
import { refreshApex } from "@salesforce/apex";
import ID_FIELD from "@salesforce/schema/Opportunity.Id";
import CUSTOMER_ACCOUNT_FIELD from '@salesforce/schema/Opportunity.Customer_Account__c';
import CUSTOMER_ACCOUNT_NAME_FIELD from '@salesforce/schema/Opportunity.Customer_Account__r.Name';
import getCustomersByOpportunityId from '@salesforce/apex/CustomerController.getCustomersByOpportunityId';
import getCustomersByName from '@salesforce/apex/CustomerController.getCustomersByName';
import CUSTOMER_ASSIGNED_MESSAGE from '@salesforce/messageChannel/CustomerAssigned__c';

const fields = [CUSTOMER_ACCOUNT_NAME_FIELD];

export default class CustomerSearch extends LightningElement {
    @api recordId;
    timeout;
    searchString;

    @wire(getRecord, { recordId: '$recordId', fields })
    opportunity;
    get opportunityCustomer() {
        return getFieldValue(this.opportunity.data, CUSTOMER_ACCOUNT_NAME_FIELD);
    }

    @wire(getCustomersByOpportunityId, {
        opportunityId: '$recordId'
    })
    customers;

    @wire(getCustomersByName,  {
        name: '$searchString'
    })
    filteredCustomers;

    changeHandler(event) {
        const current = this;
        // only start searching after a delay after the last key press
        window.clearTimeout(current.timeout);
        current.timeout = window.setTimeout(function() {
            current.searchString = event.detail.value;
        }, 700);
    }

    @wire(MessageContext) messageContext;

    customerAssignedSubscription;

    connectedCallback() {
        // Subscribe to ProductsFiltered message
        this.customerAssignedSubscription = subscribe(
            this.messageContext,
            CUSTOMER_ASSIGNED_MESSAGE,
            (message) => this.handleCustomerAssigned(message)
        );
    }

    handleCustomerAssigned(message) {
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.recordId;
        fields[CUSTOMER_ACCOUNT_FIELD.fieldApiName] = message.detail;
        
        const recordInput = { fields };

        updateRecord(recordInput)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Success",
                        message: "Customer assigned",
                        variant: "success"
                    })
                );
                // Display fresh data in the form
                return refreshApex(this.opportunity);
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error assigning customer",
                        message: error.body.message,
                        variant: "error"
                    })
                );
            });
    }

    get errors() {
        const errors = [this.opportunity.error, this.customers.error, this.filteredCustomers.error].filter(
            (error) => error
        );
        return errors.length ? errors : undefined;
    }

    get hasNoCustomers() {
        // don't break if nothing has been assigned yet
        if (!this.customers || !this.customers.data) {
            return false;
        }
        return this.customers.data.length === 0;
    }

    get hasNoFilteredCustomers() {
        // don't break if nothing has been assigned yet
        if (!this.filteredCustomers || !this.filteredCustomers.data) {
            return false;
        }
        return this.filteredCustomers.data.length === 0;
    }
}