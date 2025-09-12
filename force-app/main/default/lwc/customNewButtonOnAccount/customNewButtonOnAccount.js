import { LightningElement, track, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import BILLING_STATECODE_FIELD from '@salesforce/schema/Account.BillingStateCode';
import saveAccountRecord from '@salesforce/apex/fetchDuplicateAccountAndSaveAccount.saveAccountRecord';
import checkDuplicateRules from '@salesforce/apex/fetchDuplicateAccountAndSaveAccount.checkDuplicateRules';
import getMatchingDuplicates from '@salesforce/apex/fetchDuplicateAccountAndSaveAccount.getMatchingDuplicates';
import updateState from '@salesforce/apex/fetchDuplicateAccountAndSaveAccount.updateState';
import { COUNTRY_PICKLIST } from 'c/globalCountryPicklist';
import USER_ID from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';

export default class CustomNewButtonOnAccount extends NavigationMixin(LightningElement) {
    @api recordTypeId;
    @track recordTypeName = '';
    @track showForm = true;
    @track isCustomer = false;
    @track isDealer = false;
    @track saveAndNew = false;
    @track billingAddress = {};
    mode = '';
    @track showDuplicateAlert = false;
    @track showDuplicateList = false;
    @track duplicateBlock = false;
    @track duplicates = [];
    @track duplicateAccounts = [];
    @track dismissedDuplicateAlert = false;
    @track allowSaveOnNextClick = false;
    modalHeaderStyle;
    alertMessageStyle;
    modalHeaderClass = '';
    alertMessageClass = '';
    selectCountryValue = '';
    selectCountryFilter = [];
    CountryPicklistOptions = COUNTRY_PICKLIST;
    isReadOnly = true;

     // Fetch current user's CountryCode field
    @wire(getRecord, { recordId: USER_ID, fields: ['User.CountryCode'] })
    wiredUser({ error, data }) {
        if (data) {
            const userCountryCode = data.fields?.CountryCode?.value || '';
            // Only prefill if user actually has a country code and it matches an option
            if (userCountryCode && this.CountryPicklistOptions.some(opt => opt.value === userCountryCode)) {
                this.selectCountryValue = userCountryCode;
                if (this.selectCountryValue != '') {
            this.selectCountryFilter.push(this.selectCountryValue);
        } else {
            this.selectCountryFilter = [];
        }
            }
        } else if (error) {
            console.error('Error fetching user country code:', error);
        }
    }

    handleCountrySelect(event) {
        this.selectCountryFilter = [];
        this.selectCountryValue = event.detail.value;
        if (this.selectCountryValue != '') {
            this.selectCountryFilter.push(this.selectCountryValue);
        } else {
            this.selectCountryFilter = [];
        }
    }

    handleAddressChange(event) {
        this.billingAddress = event.detail;
        this.isReadOnly = false;
    }

    @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
    objectInfo({ data, error }) {
        if (data) {
            const urlParams = new URL(window.location.href).searchParams;
            this.recordTypeId = urlParams.get('recordTypeId');

            if (this.recordTypeId && data.recordTypeInfos) {
                const rtInfo = Object.values(data.recordTypeInfos).find(rt => rt.recordTypeId === this.recordTypeId);
                if (rtInfo) {
                    this.recordTypeName = rtInfo.name;
                    if (this.recordTypeName === 'Customer Account') {
                        this.isCustomer = true;
                    } else if (this.recordTypeName === 'Dealer Account') {
                        this.isDealer = true;
                    }
                }
            }
        } else if (error) {
            console.error('Error loading object info:', error);
        }
    }

    async handleSaveAndNew() {
        this.mode = 'saveAndNew';
        const inputFields = this.template.querySelectorAll('lightning-input-field');
        let fieldMap = {};
        inputFields.forEach(field => {
            const apiName = field.fieldName;
            fieldMap['RecordTypeId'] = this.recordTypeId;
            fieldMap[apiName] = field.value;
        });
        // Add address fields
        fieldMap.BillingStreet = this.billingAddress.street;
        fieldMap.BillingCity = this.billingAddress.city;
        fieldMap.BillingPostalCode = this.billingAddress.postalCode;
        fieldMap.BillingCountry = this.billingAddress.country;

        // if user already clicked Save once and was warned, now allow save
        if (this.allowSaveOnNextClick) {
            await this.performSave(fieldMap);
            return;
        }

        try {
            const duplicateResult = await checkDuplicateRules({ fieldMap });
            if (duplicateResult.isDuplicate) {
                this.showDuplicateAlert = true;
                if (duplicateResult.isAllow) {
                    // soft block — allow save on next click
                    this.duplicateBlock = false;
                    this.allowSaveOnNextClick = true;
                } else {
                    // hard block — do not allow save
                    this.duplicateBlock = true;
                    this.allowSaveOnNextClick = false;
                }
                return;
            }
            // if no duplicates, proceed to save
            await this.performSave(fieldMap);
        } catch (error) {
            let errorMessage = 'An unknown error occurred';
            if (error && error.body && error.body.message) {
                errorMessage = error.body.message;
            } else if (error && error.message) {
                errorMessage = error.message;
            }
            this.showToast('Error', errorMessage, 'error');
        }
    }

    handleViewDuplicatesClick() {
        this.showDuplicateList = true;
        if (this.duplicateBlock) {
            this.modalHeaderClass = 'error-header';
            this.alertMessageClass = 'alert-error';
        } else {
            this.modalHeaderClass = 'warning-header';
            this.alertMessageClass = 'alert-warning';
        }
    }

    handleOpenRecord(event) {
        const recordId = event.target.dataset.id;
        const recordLink = `/lightning/r/Account/${recordId}/view`; //  Generates clickable link
        window.open(recordLink, '_blank'); //  Opens the record in a new tab
    }

    closeDuplicateModal() {
        this.showDuplicateList = false;
    }
    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }

    get alertIcon() {
        return this.duplicateBlock ? 'utility:error' : 'utility:warning';
    }

    get alertVariant() {
        return this.duplicateBlock ? 'error' : 'warning';
    }

    get alertClass() {
        return this.duplicateBlock ? 'duplicate-alert error' : 'duplicate-alert warning';
    }

    get duplicateAlertClass() {
        return this.duplicateBlock ?
            'duplicate-alert duplicate-error' :
            'duplicate-alert duplicate-warning';
    }
    handleCancel() {
        window.history.back(); // Simulate cancel by going back
    }

    handleViewDuplicates() {
        this.showDuplicateList = true;
        const inputFields = this.template.querySelectorAll('lightning-input-field');
        let fieldMap = {};
        inputFields.forEach(field => {
            const apiName = field.fieldName;
            fieldMap[apiName] = field.value;
        });

        // Add address fields
        fieldMap.BillingStreet = this.billingAddress.street;
        fieldMap.BillingCity = this.billingAddress.city;
        fieldMap.BillingPostalCode = this.billingAddress.postalCode;
        fieldMap.BillingCountry = this.billingAddress.country;
        getMatchingDuplicates({ fieldMap: fieldMap, ruleName: this.ruleName })
            .then(result => {
                this.duplicateAccounts = result;
            })
            .catch(error => {
                console.error(' Error fetching duplicates:', error);
            });
    }

    get duplicateHeaderMessage() {
        return this.duplicateBlock ?
            'Similar Records Exist (Blocked)' :
            'Similar Records Exist';
    }

    get allowSave() {
        return !this.duplicateBlock;
    }

    handleCloseAlert() {
        this.showDuplicateAlert = false;
        this.dismissedDuplicateAlert = true;
    }
    getRecordUrl(id) {
        return '/' + id;
    }

    get modalHeadeComputedClass() {
        return 'slds-modal__header $ {this.modalHeaderClass}';
    }

    get alertMessageComputedClass() {
        return 'slds-text-body_regular $ {this.alertMessageClass}';
    }

    resetState() {
        this.showDuplicateModal = false;
        this.duplicates = [];
        this.duplicateBlock = false;
        this.pendingFields = null;
    }

    async handleSave(event) {
        event.preventDefault();
        this.mode = 'save';
        const inputFields = this.template.querySelectorAll('lightning-input-field');
        let fieldMap = {};
        inputFields.forEach(field => {
            const apiName = field.fieldName;
            fieldMap['RecordTypeId'] = this.recordTypeId;
            fieldMap[apiName] = field.value;
        });
        // Add address fields
        fieldMap.BillingStreet = this.billingAddress.street;
        fieldMap.BillingCity = this.billingAddress.city;
        fieldMap.BillingPostalCode = this.billingAddress.postalCode;
        fieldMap.BillingCountry = this.billingAddress.country;

        // if user already clicked Save once and was warned, now allow save
        if (this.allowSaveOnNextClick) {
            await this.performSave(fieldMap);
            return;
        }

        try {
            const duplicateResult = await checkDuplicateRules({ fieldMap });
            if (duplicateResult.isDuplicate) {
                this.ruleName = duplicateResult.ruleName; //  Save matched rule name
                this.showDuplicateAlert = true;
                if (duplicateResult.isAllow) {
                    // soft block — allow save on next click
                    this.duplicateBlock = false;
                    this.allowSaveOnNextClick = true;
                } else {
                    // hard block — do not allow save
                    this.duplicateBlock = true;
                    this.allowSaveOnNextClick = false;
                }
                return;
            }
            // if no duplicates, proceed to save
            await this.performSave(fieldMap);
        } catch (error) {
            let errorMessage = 'An unknown error occurred';
            if (error && error.body && error.body.message) {
                errorMessage = error.body.message;
            } else if (error && error.message) {
                errorMessage = error.message;
            }
            this.showToast('Error', errorMessage, 'error');
        }
    }

    async performSave(fieldMap) {
        try {
            const result = await saveAccountRecord({ fields: fieldMap });
            const stateUpdate = {};
            stateUpdate[BILLING_STATECODE_FIELD.fieldApiName] = this.billingAddress.province;
            stateUpdate.Id = result;
            updateState({ acc: stateUpdate })
            if (result) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Account created successfully',
                        variant: 'success'
                    })
                );
                setTimeout(() => {
                    if (this.mode === 'save') {
                        this[NavigationMixin.Navigate]({
                            type: 'standard__recordPage',
                            attributes: {
                                recordId: result,
                                objectApiName: 'Account',
                                actionName: 'view'
                            }
                        });
                    } else if (this.mode === 'saveAndNew') {
                        this.showForm = false;
                        this[NavigationMixin.Navigate]({
                            type: 'standard__objectPage',
                            attributes: {
                                objectApiName: 'Account',
                                actionName: 'new'
                            },
                            state: {
                                nooverride: '1',
                                useRecordTypeCheck: '1'
                            }
                        });
                    }

                }, 300);
            }
        } catch (error) {
            let errorMessage = 'An unknown error occurred';
            if (error && error.body && error.body.message) {
                errorMessage = error.body.message;
            } else if (error && error.message) {
                errorMessage = error.message;
            }
            this.showToast('Error', errorMessage, 'error');
        }
    }
}