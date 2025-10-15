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
            console.log('data' + JSON.stringify(data));
            console.log('recordId' + this.recordId);
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
            console.log('error' + error);
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
                // Save result in a local variable for later use
                this.typeMap = result;

                // Build type options
                this.typeOptions = result.map(t => ({
                    label: t.typeLabel,   // translated label
                    value: t.typeMaster   // English master
                }));

                if (this.selectedType) {
                    const matchedType = result.find(t => t.typeMaster === this.selectedType);
                    if (matchedType) {
                        this.subTypeOptions = matchedType.subTypes.map(st => ({
                            label: st.subTypeLabel,   // translated label
                            value: st.subTypeMaster   // English master
                        }));

                        const match = matchedType.subTypes.find(st => st.subTypeMaster === this.selectedSubType);
                        this.selectedSubType = match ? match.subTypeMaster : '';
                    }
                }
            })
            .catch(error => {
                this.showToast('Error', error.body.message, 'error');
            });
    }




    handleTypeChange(event) {
        this.selectedType = event.detail.value;
        this.selectedSubType = ''; // reset

        const matchedType = this.typeMap.find(t => t.typeMaster === this.selectedType);
        if (matchedType) {
            this.subTypeOptions = matchedType.subTypes.map(st => ({
                label: st.subTypeLabel,  // translated
                value: st.subTypeMaster  // English
            }));
        } else {
            this.subTypeOptions = [];
        }
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
                setTimeout(() => {
                    document.location.reload();
                }, 1000);
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