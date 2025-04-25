import { LightningElement, api, wire } from 'lwc';

import { publish, MessageContext } from 'lightning/messageService';

import CUSTOMER_ASSIGNED_MESSAGE from '@salesforce/messageChannel/CustomerAssigned__c';

export default class CustomerListItem extends LightningElement {
    @api customer;

    @wire(MessageContext) messageContext;

    handleCustomerClick(event) {
        publish(this.messageContext, CUSTOMER_ASSIGNED_MESSAGE, {
            detail: this.customer.Id
        });
    }
}