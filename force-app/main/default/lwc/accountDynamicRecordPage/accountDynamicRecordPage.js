import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LOCALE from '@salesforce/i18n/locale';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import ACCOUNT_ID_FIELD from '@salesforce/schema/Account.Id';
import ACCOUNT_NAME from '@salesforce/schema/Account.Name';
import CUSTOMER_ID from '@salesforce/schema/Account.CustomerID__c';
import CUSTOMER_NUMBER from '@salesforce/schema/Account.Customer_Number__c';
import ACCOUNT_OWNER_ALIAS from '@salesforce/schema/Account.Owner.Alias';
import BILLING_STREET_FIELD from '@salesforce/schema/Account.BillingStreet';
import BILLING_CITY_FIELD from '@salesforce/schema/Account.BillingCity';
import BILLING_STATE_FIELD from '@salesforce/schema/Account.BillingState';
import BILLING_POSTAL_CODE_FIELD from '@salesforce/schema/Account.BillingPostalCode';
import BILLING_COUNTRY_FIELD from '@salesforce/schema/Account.BillingCountry';
import BILLING_COUNTRY_CODE_FIELD from '@salesforce/schema/Account.BillingCountryCode';
import BILLING_STATECODE_FIELD from '@salesforce/schema/Account.BillingStateCode';
import updateMultipleAccounts from '@salesforce/apex/AccountEditController.updateMultipleAccounts';
import getDuplicateAccounts from '@salesforce/apex/AccountEditController.getDuplicateAccounts';
import { COUNTRY_PICKLIST } from 'c/globalCountryPicklist';


export default class AccountInlineEdit extends LightningElement {
    @api recordId;
    @track billingAddress = [];
    @track mapMarkers = [];
    @track mapCenter = [];
    @track showSaveButton = false;
    @track showDuplicateAlert = false;
    @track showDuplicateModal = false;
    @track duplicateAccounts = [];
    selectCountryValue = '';
    selectCountryFilter = [];
    CountryPicklistOptions = COUNTRY_PICKLIST;

    getStreet;
    getCity;
    getState;
    getZipCode;
    getCountry;
    billingState = '';
    billingCountry = '';
    billingStateCode;
    selectedAccountName;
    selectedCustomerId;
    selectedAccountOwnerName;
    duplicateAccounts = [];
    userLocale = LOCALE;
    allowSave = false;
    isReadOnly = true;


    @wire(getRecord, { recordId: '$recordId', fields: [ACCOUNT_NAME, CUSTOMER_ID, CUSTOMER_NUMBER, ACCOUNT_OWNER_ALIAS, BILLING_STREET_FIELD, BILLING_CITY_FIELD, BILLING_STATE_FIELD, BILLING_STATECODE_FIELD, BILLING_POSTAL_CODE_FIELD, BILLING_COUNTRY_FIELD, BILLING_COUNTRY_CODE_FIELD] })
    wiredAccount({ error, data }) {
        if (data) {
            this.selectedAccountName = data.fields.Name.value;
            this.selectedCustomerId = data.fields.CustomerID__c.value;
            //this.selectedAccountOwnerName = data.fields.Owner.Name.value;
            if(data.fields.BillingCountryCode.value != null){
                this.selectCountryValue = data.fields.BillingCountryCode.value;
                // alert(data.fields.BillingCountryCode.value);
                console.log(data.fields.BillingCountryCode.value+'data.fields.BillingCountryCode.value');
                this.selectCountryFilter.push(this.selectCountryValue);
            }
            this.billingAddress = {
                street: data.fields.BillingStreet.value,
                city: data.fields.BillingCity.value,
                province: data.fields.BillingState.value,
                postalCode: data.fields.BillingPostalCode.value,
                country: data.fields.BillingCountry.value,
            };
            this.mapMarkers = [{
                location: {
                    Street: this.billingAddress.street,
                    City: this.billingAddress.city,
                    State: this.billingAddress.province,
                    PostalCode: this.billingAddress.postalCode,
                    Country: this.billingAddress.country
                },
                title: 'Existing Location',
                description: 'Current billing address'
            }];

        } else if (error) {}
    }

    handleCountrySelect(event) {
        this.selectCountryFilter = [];
        this.selectCountryValue = event.detail.value;
        if (this.selectCountryValue != '') {
            this.selectCountryFilter.push(this.selectCountryValue);
        } else {
            this.selectCountryFilter = [];
        }
        console.log('this.selectCountryFilter' + this.selectCountryFilter);
    }

    handleAddressChange(event) {
        this.getStreet = event.detail.street;
        this.getCity = event.detail.city;
        this.getState = event.detail.province;
        this.getZipCode = event.detail.postalCode;
        this.getCountry = event.detail.country;
        this.showSaveButton = !!this.getCountry;
        this.isReadOnly = false;
        console.log('event' + event);
    }

    handleSave() {

        const accountToUpdate = {};
        accountToUpdate[ACCOUNT_ID_FIELD.fieldApiName] = this.recordId;
        accountToUpdate[BILLING_STREET_FIELD.fieldApiName] = this.getStreet;
        accountToUpdate[BILLING_CITY_FIELD.fieldApiName] = this.getCity
        accountToUpdate[BILLING_POSTAL_CODE_FIELD.fieldApiName] = this.getZipCode;
        accountToUpdate[BILLING_COUNTRY_FIELD.fieldApiName] = this.getCountry;


        if (this.getCountry === null || !this.getCountry) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Billing Country is Mandatory',
                    variant: 'error'
                })
            );
            return;
        }

        if (!this.allowSave) {
            getDuplicateAccounts({
                    accountId: this.recordId,
                    accountName: this.selectedAccountName,
                    billingCountry: this.getCountry
                })
                .then(result => {
                    if (result.length > 0) {
                        this.duplicateAccounts = result;
                        this.showDuplicateModal = true;
                        this.allowSave = true;
                        return;
                    }

                    this.allowSave = true;
                    this.handleSave();
                })
                .catch(error => {});

            return;
        }

        updateMultipleAccounts({ acc: accountToUpdate })
            .then((result) => {

                this.handleUpdateState();
                getRecordNotifyChange([{ recordId: this.recordId }]);
            })
            .catch(error => {
                console.error('Caught error from Apex:', JSON.stringify(error));

                let message = 'An unexpected error occurred.';
                if (error && error.body && typeof error.body.message === 'string') {
                    message = error.body.message;
                    console.log('message', JSON.stringify(message));
                }

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: message,
                        variant: 'error',
                        mode: 'sticky'
                    })
                );
            });

    }
    handleUpdateState() {
        const stateUpdate = {};
        stateUpdate[BILLING_STATECODE_FIELD.fieldApiName] = this.getState;
        stateUpdate.Id = this.recordId;
        console.log(this.getState+'this.getState');
        updateMultipleAccounts({ acc: stateUpdate })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Billing Address updated successfully',
                        variant: 'success'
                    })
                );
                this.isReadOnly = true;
                getRecordNotifyChange([{ recordId: this.recordId }]);

                this.allowSave = false;
                this.showDuplicateModal = false;
                this.duplicateAccounts = [];
                this.showSaveButton = false;

                this.mapMarkers = [{
                    location: {
                        Street: this.getStreet,
                        City: this.getCity,
                        State: this.getState,
                        PostalCode: this.getZipCode,
                        Country: this.getCountry,
                    },
                    title: 'SelectedLocation',
                    description: this.getStreet + ', ' + this.getCity + ', ' + this.getState + ', ' + this.getZipCode + ', ' + this.getCountry
                }];
            });
    }

    handleOpenRecord(event) {
        const recordId = event.target.dataset.id;
        const recordLink = `/lightning/r/Account/${recordId}/view`;
        window.open(recordLink, '_blank');
    }
    handleViewDuplicates(event) {
        event.preventDefault();
        this.showDuplicateAlert = true;

    }

    handleCancel() {

        this.showDuplicateAlert = false;
    }
    showDuplicateAlertCancel() {
        this.showDuplicateAlert = false;
    }

    handleCloseAlert() {
        this.showDuplicateModal = false;
    }

    get duplicateHeaderMessage() {
        return this.duplicateBlock ?
            'Similar Records Exist (Blocked)' :
            'Similar Records Exist';
    }

    get allowSave() {
        return !this.duplicateBlock;
    }


    handleError(error) {
        if (error.body && error.body.output && error.body.output.errors) {
            let duplicateError = error.body.output.errors.find(err => err.errorCode === 'DUPLICATES_DETECTED');

            if (duplicateError) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Duplicate Error',
                        message: duplicateError.message,
                        variant: 'error',
                        mode: 'sticky'
                    })
                );
                return;
            }
        }

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: 'Failed to update record.',
                variant: 'error'
            })
        );
    }
}