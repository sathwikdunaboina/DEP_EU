import { LightningElement, api, wire } from 'lwc';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getTypeSubTypes from '@salesforce/apex/CaseTypeMetadataService.getTypeSubTypes';

import TYPE_FIELD from '@salesforce/schema/Case.Type';
import SUBTYPE_FIELD from '@salesforce/schema/Case.Sub_Type__c';
import COUNTRY_FIELD from '@salesforce/schema/Case.Country__c';
import RECORDTYPE_NAME_FIELD from '@salesforce/schema/Case.RecordType.DeveloperName';

const FIELDS = [TYPE_FIELD, SUBTYPE_FIELD, COUNTRY_FIELD, RECORDTYPE_NAME_FIELD];

export default class CaseTypeSelector extends LightningElement {
    @api recordId;

    country;
    selectedType = '';
    selectedSubType = '';
    recordTypeName = '';
    typeOptions = [];
    subTypeOptions = [];
    typeMap = {};
    originalType = '';
    originalSubType = '';

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredCase({ error, data }) {
        if (data) {
            console.log('data'+JSON.stringify(data));
            console.log('recordId'+this.recordId);
            this.country = data.fields.Country__c?.value || '';
            this.selectedType = data.fields.Type?.value || '';
            this.selectedSubType = data.fields.Sub_Type__c?.value || '';
            this.recordTypeName = data.fields.RecordType.value.fields.DeveloperName?.value || '';
            this.originalType = this.selectedType;
            this.originalSubType = this.selectedSubType;
            if (this.country) {
                this.loadTypeData();
            }
        } else if (error) {
            console.log('error'+error);
            this.showToast('Error', 'Error loading case fields', 'error');
        }
    }

    get hasChanged() {
        return (
            this.selectedType !== this.originalType ||
            this.selectedSubType !== this.originalSubType
        );
    }

    loadTypeData() {
        getTypeSubTypes({ country: this.country, recordTypeDevName: this.recordTypeName })
            .then(result => {
                this.typeMap = result;
                console.log(this.typeMap);
                // Build Type options
                this.typeOptions = Object.keys(result).map(type => ({
                    label: type,
                    value: type
                }));
                if (this.typeOptions.length === 0) {
                this.showToast('Warning', 'No available Type options for the selected Country and Record Type.', 'warning');
                }
                // If existing Type from Case matches, pre-fill subtypes
                if (this.selectedType && result[this.selectedType]) {
                    const subTypes = result[this.selectedType];
                    this.subTypeOptions = subTypes.map(st => ({
                        label: st,
                        value: st
                    }));

                    //Explicitly reset selectedSubType if value exists in options
                    const match = subTypes.find(st => st === this.selectedSubType);
                    this.selectedSubType = match || '';
                } else {
                    this.subTypeOptions = [];
                    this.selectedSubType = '';
                }
            })
            .catch(error => {
                this.showToast('Error', error.body.message, 'error');
            });

        console.log('Country:', this.country);
        console.log('Selected Type:', this.selectedType);
        console.log('Selected SubType:', this.selectedSubType);
        console.log('Available subTypes:', this.subTypeOptions);
        console.log('this.typeOptions:', this.typeOptions);
    }


    handleTypeChange(event) {
        this.selectedType = event.detail.value;
        this.selectedSubType = ''; // reset

        const subTypes = this.typeMap[this.selectedType] || [];
        this.subTypeOptions = subTypes.map(st => ({
            label: st,
            value: st
        }));
    }

    handleSubTypeChange(event) {
        this.selectedSubType = event.detail.value;
    }

    handleSave() {
        const fields = {
            Id: this.recordId,
            [TYPE_FIELD.fieldApiName]: this.selectedType,
            [SUBTYPE_FIELD.fieldApiName]: this.selectedSubType
        };

        updateRecord({ fields })
            .then(() => {
                this.showToast('Success', 'Case updated successfully', 'success');
            })
            .catch(error => {
                this.showToast('Error', error.body.message, 'error');
            });
    }

    get isSubTypeDisabled() {
        return !this.subTypeOptions.length;
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({ title, message, variant })
        );
    }
}