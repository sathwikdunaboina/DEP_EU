import { LightningElement, track,api, wire } from 'lwc';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import CASE_OBJECT from '@salesforce/schema/Case';
import TYPE_FIELD from '@salesforce/schema/Case.Type';
import STATUS_FIELD from '@salesforce/schema/Case.Status';
import SUBTYPE_FIELD from '@salesforce/schema/Case.Sub_Type__c';
import STATUS_REASON_FIELD from '@salesforce/schema/Case.Status_Reason__c';
import BRAND_FIELD from '@salesforce/schema/Case.Brand__c';
import getSelectedCases from '@salesforce/apex/CaseBulkUpdateController.getSelectedCases';
import validateRecordTypes from '@salesforce/apex/CaseBulkUpdateController.validateRecordTypes';
import validateParentCase from '@salesforce/apex/CaseBulkUpdateController.validateParentCase';
import getCurrentUserProfile from '@salesforce/apex/CaseBulkUpdateController.getCurrentUserProfile';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'; 
//import { FlowNavigationNextEvent } from 'lightning/flowSupport';

const CASE_RECORD_TYPE_ID = 'Case.RecordTypeId';

export default class CaseFieldDependency extends LightningElement {
@track typeOptions ;
@track subtypeOptions ;
@track statusOptions ;
@track statusReasonOptions ;
@track brandOptions ;
@track typeValue = '' ;
@track subtypeValue = '' ;
@track statusValue = '';
@track statusReasonValue = '';
@track brandValue = '';
@track defaultRecordTypeId;
@track selectedRecordType;
@track medalliaRecordTypeId;
@track isSubtypeDisabled = false;
@track isStatusReasonDisabled = false;
@track isSaveDisabled = false;
@api selectedRecordTypeIds =[];
@api recordIds; 
@track filteredSubtypeOptions = [];
@track filteredStatusReasonOptions =[];
@track isBrandFieldVisible = true;  
@track isBrandFieldRequired = true; 
@track isSystemAdmin = false; 
@track isValidationComplete = false; 
@track showModal = false;
@track updatedFields = ''; 
@api message;
@api errorMessageVar = '';
@api header;
@api isFlowVar = false;
@track modalMessage = '';
recordTypeMaps = new Map(); 
recordTypeMap = new Map(); 
@track showToast = false;
@track toastMessage = '';
@track toastVariant = '';
@track selectedcases = '';
@track error;
@track caseNumbers = [];
@track showFields = false;
recordTypeOptions = [];
value = '';
@track showError = false;
recordSaved = false; 
isRecordFetched = false; 

connectedCallback() {
    if (this.recordSaved) {
        return; 
    }
    validateRecordTypes({ caseIds: this.recordIds })
        .then(result => {
            if (result) {
                this.error = result;
                this.showError = true;
                console.log('Error:', this.error);
                this.isValidationComplete = true; 
                return;
            } else {
                this.showError = false;
                this.error = '';
                this.showFields = true;
            }
        })
        .catch(error => {
        });
        getSelectedCases({ caseIds: this.recordIds })
        .then(data => {
            this.caseNumbers = data.map(caseRecord => caseRecord.CaseNumber).join(', ');

        })
        .catch(error => {
        });

    getCurrentUserProfile()
    .then(profileName => {
        if (profileName === 'System Administrator') {
            this.isSystemAdmin = true;

            this.isBrandFieldRequired = false;
        }
    })
    .catch(error => {
    });
        
}  
@wire(getRecord, { recordId: '$selectedRecordId', fields: [CASE_RECORD_TYPE_ID,TYPE_FIELD,SUBTYPE_FIELD,STATUS_FIELD,STATUS_REASON_FIELD,BRAND_FIELD] })

wiredRecord({ error, data }) {
    if (this.recordSaved) {
        return; 
    }
if (data) {
        
    this.selectedRecordType = data.fields.RecordTypeId.value;
    this.recordTypeMap.set(this.selectedRecordId, data.fields.RecordTypeId.value);
    this.validateRecordTypes();
    this.updateFieldVisibility();


} else if (error) {
console.error('Error fetching RecordTypeId', error);
}
}
get selectedRecordId() {
    return this.recordIds.length ? this.recordIds[0] : null;

    }
    


@wire(getObjectInfo, { objectApiName: CASE_OBJECT })
wiredCaseInfo({ error, data }) {
    if (data) {
        this.defaultRecordTypeId = data.defaultRecordTypeId;
        const recordTypes = data.recordTypeInfos;
        for (let key in recordTypes) {
            if (recordTypes[key].name === 'MEDALLIACLF Alert Cases') {
                this.medalliaRecordTypeId = key;
            }
        }
        
    } else if (error) {
        console.error('Error fetching record types:', error);
    }
}
updateFieldVisibility() {
    if (this.selectedRecordType) { 
        this.isBrandFieldVisible = this.selectedRecordType !== this.medalliaRecordTypeId;
    }
}
validateRecordTypes() {
    const recordTypeIds = Array.from(this.recordTypeMap.values());
    const uniqueRecordTypeIds = new Set(recordTypeIds);
    if (uniqueRecordTypeIds.size > 1) {
        this.errorMessage = 'Error: Different record types selected for cases.';
    } else {
        this.errorMessage = '';
    }
}

@wire(getPicklistValues, { recordTypeId: '$selectedRecordType', fieldApiName: TYPE_FIELD })
typePicklistValues({ error, data }) {
    if (data) {
    this.typeOptions = [ { label: '--None--', value:''}, ...data.values ];     
    } else if (error) {
        console.error('Error fetching type picklist values:', error);
    }
}

@wire(getPicklistValues, { recordTypeId: '$selectedRecordType', fieldApiName: SUBTYPE_FIELD })
subtypePicklistValues({ error, data }) {
if (data) {
    this.subtypeOptions = data.values.map(item => ({
        label: item.label,
        value: item.value,
        validFor: item.validFor
    }));
} else if (error) {
    console.error('Error fetching subtype picklist values:', error);
}
}
@wire(getPicklistValues, { recordTypeId: '$selectedRecordType', fieldApiName: STATUS_FIELD })
statusPicklistValues({ error, data }) {
    if (data) {
        this.statusOptions = [{ label: '--None', value: '' }, ...data.values.map(item => ({
            label: item.label,
            value: item.value
        }))];
    } else if (error) {
        console.error('Error fetching status picklist values:', error);
    }
}

@wire(getPicklistValues, { recordTypeId: '$selectedRecordType', fieldApiName: STATUS_REASON_FIELD })
statusReasonPicklistValues({ error, data }) {
    if (data) {
        this.statusReasonOptions = data.values.map(item => ({
            label: item.label,
            value: item.value,
            validFor: item.validFor
        }));
    } else if (error) {
        console.error('Error fetching status reason picklist values:', error);
    }
}

@wire(getPicklistValues, { recordTypeId: '$selectedRecordType', fieldApiName: BRAND_FIELD })
brandPicklistValues({ error, data }) {
    if (data) {
        this.brandOptions =  [{ label: '--None', value: '' }, ...data.values.map(item => ({
            label: item.label,
            value: item.value
        }))];
    } else if (error) {
        console.error('Error fetching brand picklist values:', error);
    }
}

handleTypeChange(event) {
    this.typeValue = event.detail.value;
    this.subtypeValue= ''; 
    this.updateFilteredSubtypeOptions();
}

updateFilteredSubtypeOptions() {
    this.filteredSubtypeOptions = [{ label: '--None--', value: ''}];
    if (!this.typeValue || this.typeValue === '') {
    this.isSubtypeDisabled = true;
    return;
    }
    
    const actualTypeOptions = this.typeOptions.filter(option => option.value !== ''); // Ignore None
    const actualIndex = actualTypeOptions.findIndex(option => option.value === this.typeValue);    
    const originalIndex = this.typeOptions.findIndex(option => option.value === this.typeValue);    
    
    if (actualIndex !== -1) {
    this.filteredSubtypeOptions = [{ label: '--None--', value: ''}, ...this.subtypeOptions
    .filter(option => option.validFor.includes(actualIndex))
    .map(option => ({
    label: option.label,
    value: option.value
    }))];
    
    console.log('Filtered Subtype Options:', JSON.stringify(this.filteredSubtypeOptions));
            
this.isSubtypeDisabled = this.filteredSubtypeOptions.length === 0;
    } else {
    console.log(' No matching Type found! Check Type options and values.');
    }
    
    }
    
handleStatusChange(event) {
    this.statusValue = event.detail.value;
    this.statusReasonValue = '';
    const disabledStatuses = ['New', 'Escalated', 'Duplicate'];
    this.isStatusReasonDisabled = disabledStatuses.includes(this.statusValue);
    this.updateFilteredStatusReasonOptions();
}
handleSubtypeChange(event){
    this.subtypeValue = event.detail.value;

}
handleStatusReasonChange(event){
    this.statusReasonValue = event.detail.value;
}
handleBrandChange(event){
    this.brandValue = event.detail.value;
}
updateFilteredStatusReasonOptions() {
        
        if (!this.statusValue || this.statusValue === '') {
            this.isStatusReasonDisabled = true;
            return;
            }
            
            const actualStatusOptions = this.statusOptions.filter(option => option.value !== ''); // Ignore None
            const actualStatusIndex = actualStatusOptions.findIndex(option => option.value === this.statusValue);
            
            console.log('Actual Index (Excluding None):', actualStatusIndex);
            
            const originalStatusIndex = this.statusOptions.findIndex(option => option.value === this.statusValue);
            console.log('Original Index (For validFor Matching):', originalStatusIndex);
            
            
            if (actualStatusIndex !== -1) {
            this.filteredStatusReasonOptions = [{ label: '--None--', value: ''}, ...this.statusReasonOptions
            .filter(option => option.validFor.includes(actualStatusIndex))
            .map(option => ({
            label: option.label,
            value: option.value
            }))];
            
            console.log('Filtered Subtype Options:', JSON.stringify(this.filteredStatusReasonOptions.length));
        } else {
        console.log(' No matching Type found! Check Type options and values.');
        }

        }
        

    
handleUpdateCase() {
this.showToast = false;
this.toastMessage = '';

if(this.typeValue === '' && this.subtypeValue === '' && this.statusValue === '' && this.statusReasonValue === '' && this.brandValue === ''){
    this.toastMessage = 'Please select values when updating a case';
    this.toastVariant = 'error';
    this.showToast = false;
    setTimeout(() => {
        this.showToast = true;
    }, 100);

    return;
}
if(this.statusValue === '' || !this.statusValue){
this.toastMessage = 'Status is Mandatory when updating a case';
this.toastVariant = 'error';
this.showToast = false;
setTimeout(() => {
    this.showToast = true;
}, 100);
return;
}


if (!this.brandValue || this.brandValue === '') {
    if(this.selectedRecordType !== this.medalliaRecordTypeId && !this.isSystemAdmin){
    this.toastMessage = 'Brand is Mandatory when updating a case';
    this.toastVariant = 'error';
    this.showToast = false;
    setTimeout(() => {
        this.showToast = true;
    }, 100);
    return;
}
}

    if(this.statusValue === 'Closed' && (this.brandValue !== '' || this.brandValue === '') && (!this.typeValue ||this.typeValue === '')){
        this.toastMessage = 'Type is Mandatory when closing a case';
        this.toastVariant = 'error';
        this.showToast = false;
        setTimeout(() => {
            this.showToast = true;
        }, 100);

        return;
    }
        if(this.statusValue === 'Closed' && (this.brandValue !== '' || this.brandValue === '') && this.typeValue !== '' && (!this.subtypeValue ||this.subtypeValue === '')){
        this.toastMessage = 'Subtype is Mandatory when closing a case';
        this.toastVariant = 'error';
        this.showToast = false;
        setTimeout(() => {
            this.showToast = true;
        }, 100);

        return; 
        }
            if (this.statusValue === 'Duplicate') {
                console.log('Status =====> Duplicate');
                validateParentCase({ caseIds: this.recordIds, status: this.statusValue })
                    .then(result => {
                        
                            if (result.length > 0) {
                                this.toastMessage = `The following cases do not have a parent case: ${result.join(', ')}`;
                                this.toastVariant = 'error';
                                this.showToast = false;
                                setTimeout(() => {
                                    this.showToast = true;
                                }, 100);
                
                                return;
                            }
                        else{
                            this.showModal = true;
                            const selectedFields = [];
                            if (this.typeValue) selectedFields.push('Type');
                            if (this.statusValue) selectedFields.push('Status');
                            if (this.subtypeValue) selectedFields.push('Sub Type');
                            if (this.statusReasonValue) selectedFields.push('Status Reason');
                            if (this.brandValue) selectedFields.push('Brand');
                            this.modalMessage = `Update ${this.recordIds.length} records and change these fields: ${selectedFields.join(', ')}?`;
        
                        }
                    }
                    )}

else{
    const selectedFields = [];
    if (this.typeValue) selectedFields.push('Type');
    if (this.statusValue) selectedFields.push('Status');
    if (this.subtypeValue) selectedFields.push('Sub Type');
    if (this.statusReasonValue) selectedFields.push('Status Reason');
    if (this.brandValue) selectedFields.push('Brand');
    this.modalMessage = `Update ${this.recordIds.length} records and change these fields: ${selectedFields.join(', ')}?`;
    this.showModal = true;
}      

}
handleConfirm() {
    console.log('Confirm button clicked');
    this.showModal = false;
    if (!this.recordIds || this.recordIds.length === 0) {
    console.error('No record IDs found for update.');
    return;
    }

    this.recordIds.forEach(recordId => {

        const fields = { Id: recordId };

        if (this.typeValue && this.typeValue !== '') fields[TYPE_FIELD.fieldApiName] = this.typeValue;
        if (this.statusValue && this.statusValue !== '') fields[STATUS_FIELD.fieldApiName] = this.statusValue;
        if (this.subtypeValue && this.subtypeValue !== '') fields[SUBTYPE_FIELD.fieldApiName] = this.subtypeValue;
        if (this.statusReasonValue && this.statusReasonValue !== '') fields[STATUS_REASON_FIELD.fieldApiName] = this.statusReasonValue;
        if (this.brandValue && this.brandValue !== '') fields[BRAND_FIELD.fieldApiName] = this.brandValue;

        if ((this.statusValue === 'New' || this.statusValue === 'On Hold' || this.statusValue === 'In Progress') && this.statusReasonValue === '' ) {
            console.log('Status === NEW || on Hold || In Progress then ==> status Reason Empty');
            fields[STATUS_REASON_FIELD.fieldApiName] = null;
        }
        if(this.typeValue !== '' && this.subtypeValue ===''){
            console.log('if type is not null and subtype is null then Subtype field becomes null');
            fields[SUBTYPE_FIELD.fieldApiName] = null;
        }
        

    
    
    const recordInput = { fields };
    
    console.log('Updating record:', JSON.stringify(recordInput));
    this.recordSaved = true;

    
    updateRecord(recordInput)
    .then(() => {
    })
    this.toastMessage = 'Case Record Updated Succesfully';
    console.log('this.ToastMEssage',this.toastMessage);
        this.toastVariant = 'success';
    this.showToast = false;
    setTimeout(() => {
            this.showToast = true;
        }, 200); 
    });
    setTimeout(() => {
        window.history.back();
    }, 3000);        
}
handleCancel(){
this.showModal = false;

}
handleCancelButton(){
window.history.back(); 

}
}