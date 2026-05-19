import { LightningElement, api, track, wire } from 'lwc';
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import Opportunity from '@salesforce/schema/Opportunity';
import getOpportunities from '@salesforce/apex/OpportunityBulkUpdateController.getOpportunities';
import updateOpportunities from '@salesforce/apex/OpportunityBulkUpdateController.updateOpportunities';
import searchOpportunityOwners from '@salesforce/apex/OpportunityBulkUpdateController.searchOpportunityOwners';
import { NavigationMixin } from 'lightning/navigation';
import StageName from '@salesforce/schema/Opportunity.StageName';
import LostReason from '@salesforce/schema/Opportunity.Lost_Reason__c';
import Reason from '@salesforce/schema/Opportunity.Reason__c';
import SubStage from '@salesforce/schema/Opportunity.Sub_Stage__c';
import FinanceHouse from '@salesforce/schema/Opportunity.Finance_Houses__c';
import getStageProbabilities from '@salesforce/apex/OpportunityBulkUpdateController.getStageProbabilities';

export default class BulkUpdateOpportunities extends NavigationMixin(LightningElement) {
    @api recordIds;

    // =====================================================
    // TRACK
    // =====================================================
    @track opportunities = [];
    @track error;
    @track showFields = false;
    @track isFinance = false;
    @track isLCVOpportunity = false;
    @track recordType = '';

    // =====================================================
    // CHANGED FIELDS — only fields user has set with a non-empty value
    // =====================================================
    @track changedFields = {};

    // =====================================================
    // TOAST
    // =====================================================
    @track showToast = false;
    @track toastMessage = '';
    @track toastVariant = 'success';

    // =====================================================
    // OWNER
    // =====================================================
    @track ownerOptions = [];
    selectedOwnerName = '';

    // =====================================================
    // RECORD TYPE
    // =====================================================
    @track selectedRecordTypeId;

    // =====================================================
    // OPTIONS
    // =====================================================
    @track stageOptions = [];
    @track lostReasonOptions = [];
    @track reasonOptions = [];
    @track subStageOptions = [];
    @track financeHouseOptions = [];

    // =====================================================
    // DISABLED
    // =====================================================
    @track isLostReasonDisabled = true;
    @track isReasonDisabled = true;
    @track isSubStageDisabled = true;
    @track isFinanceHouseDisabled = true;

    // =====================================================
    // SELECTED VALUES
    // =====================================================
    selectedStage = '';
    selectedLostReason = '';
    selectedReason = '';
    selectedSubStage = '';
    selectedFinanceHouse = '';

    // =====================================================
    // GETTERS
    // =====================================================
    get disableAdditionalDetails() {
        return this.selectedStage !== 'Closed Lost';
    }

    get disableLostToField() {
        return (this.selectedStage !== 'Closed Lost' || this.isFinanceHouseDisabled);
    }

    get lostToHelpMessage() {
        if (this.selectedStage !== 'Closed Lost') {
            return '';
        }

        const countries = this.opportunities.map(opp => opp.Country__c);
        const validCountries = countries.filter(c => c);
        const uniqueCountries = [...new Set(validCountries)];

        // DIFFERENT COUNTRIES
        if (uniqueCountries.length > 1) {
            return 'Selected Opportunities belong to different Countries.';
        }

        if (validCountries.length === 0) {
            return 'Selected Opportunities do not have Country Populated ';
        }

        // COUNTRY CONFIGURATION MISSING
        if (uniqueCountries.length === 1) {
            const country = uniqueCountries[0];
            const controllingIndex = this.financeHouseControllerValues[country];
            const hasConfiguredValues = this.financeHouseMetadata?.values?.some(
                item => item.validFor.includes(controllingIndex)
            );
            if (!hasConfiguredValues) {
                return 'Lost To values are not configured for the selected Country.';
            }
        }

        // SOME OPPORTUNITIES WITHOUT COUNTRY
        if (countries.some(c => !c) && validCountries.length > 0) {
            return 'Some selected Opportunities do not have Country populated.';
        }

        return '';
    }

    // =====================================================
    // METADATA
    // =====================================================
    lostReasonMetadata;
    reasonMetadata;
    subStageMetadata;
    financeHouseMetadata;

    // =====================================================
    // CONTROLLERS
    // =====================================================
    lostReasonControllerValues = {};
    reasonControllerValues = {};
    subStageControllerValues = {};
    financeHouseControllerValues = {};
    stageProbabilityMap = {};

    // =====================================================
    // CONNECTED CALLBACK
    // =====================================================
    connectedCallback() {
        // Validation: no record IDs passed
        if (!this.recordIds || this.recordIds.length === 0) {
            this.error = 'Please select an Opportunity.';
            return;
        }

        getOpportunities({ sSelectedOpportunityIds: this.recordIds })
            .then(result => {
                if (!result || result.length === 0) {
                    this.error = 'Please select an Opportunity.';
                    return;
                }

                // SAME RECORD TYPE CHECK
                const recordTypeIds = [...new Set(result.map(opp => opp.RecordTypeId))];
                if (recordTypeIds.length > 1) {
                    this.error = 'Please select same Record Type Opportunities';
                    return;
                }

                this.opportunities = result;
                this.selectedRecordTypeId = result[0].RecordTypeId;
                this.recordType = result[0].RecordType.Name;
                this.isFinance = this.recordType === 'Finance';
                this.isLCVOpportunity = this.recordType === 'LCV Opportunity';
                this.showFields = true;
            })
            .catch(error => {
                console.error(error);
                this.error = JSON.stringify(error);
            });
    }

    // Wire for Probability change when Stage changes
    @wire(getStageProbabilities)
    wiredStageProbabilities({ data, error }) {
        if (data) {
            this.stageProbabilityMap = data;
        } else if (error) {
            console.error(error);
        }
    }

    // =====================================================
    // PICKLISTS
    // =====================================================
    @wire(getPicklistValuesByRecordType, {
        objectApiName: Opportunity,
        recordTypeId: '$selectedRecordTypeId'
    })
    wiredPicklists({ error, data }) {
        if (data) {
            // STAGE
            this.stageOptions = [
                { label: '--None--', value: '' },
                ...data.picklistFieldValues[StageName.fieldApiName].values.map(item => ({
                    label: item.label,
                    value: item.value
                }))
            ];

            // LOST REASON
            this.lostReasonMetadata = data.picklistFieldValues[LostReason.fieldApiName];
            this.lostReasonControllerValues = this.lostReasonMetadata.controllerValues;

            // REASON
            this.reasonMetadata = data.picklistFieldValues[Reason.fieldApiName];
            this.reasonControllerValues = this.reasonMetadata.controllerValues;

            // SUB STAGE
            if (data.picklistFieldValues[SubStage.fieldApiName]) {
                this.subStageMetadata = data.picklistFieldValues[SubStage.fieldApiName];
                this.subStageControllerValues = this.subStageMetadata.controllerValues;
            }

            // FINANCE HOUSE
            if (data.picklistFieldValues[FinanceHouse.fieldApiName]) {
                this.financeHouseMetadata = data.picklistFieldValues[FinanceHouse.fieldApiName];
                this.financeHouseControllerValues = this.financeHouseMetadata.controllerValues;
                this.evaluateFinanceHouseDependency();
            }
        } else if (error) {
            console.error(error);
        }
    }

    // =====================================================
    // OWNER SEARCH
    // =====================================================
    handleOwnerSearch(event) {
        const searchTerm = event.target.value.trim();
        this.selectedOwnerName = '';

        if (!searchTerm) {
            this.ownerOptions = [];
            // If cleared, remove OwnerId from changedFields
            const updated = { ...this.changedFields };
            delete updated['OwnerId'];
            this.changedFields = updated;
            return;
        }

        searchOpportunityOwners({ searchTerm: searchTerm + '%' })
            .then(result => {
                this.ownerOptions = result.map(user => ({ Id: user.Id, Name: user.Name }));
            })
            .catch(error => {
                console.error(error);
                this.ownerOptions = [];
            });
    }

    // =====================================================
    // SELECT OWNER
    // =====================================================
    selectOwner(event) {
        const selectedId = event.target.dataset.id;
        const selectedName = event.target.dataset.name;
        this.selectedOwnerName = selectedName;
        this.ownerOptions = [];

        if (selectedId) {
            this.changedFields = { ...this.changedFields, OwnerId: selectedId };
        } else {
            const updated = { ...this.changedFields };
            delete updated['OwnerId'];
            this.changedFields = updated;
        }
    }

    // =====================================================
    // FIELD CHANGE
    // =====================================================
    handleFieldChange(event) {
        const fieldName = event.target.fieldName;
        let fieldValue = event.detail.value;

        // LOOKUP FIELD FIX
        if (Array.isArray(fieldValue)) {
            fieldValue = fieldValue.length > 0 ? fieldValue[0] : null;
        }

        // Only track if non-empty; remove from changedFields if cleared
        if (fieldValue !== null && fieldValue !== undefined && fieldValue !== '') {
            this.changedFields = { ...this.changedFields, [fieldName]: fieldValue };
        } else {
            const updated = { ...this.changedFields };
            delete updated[fieldName];
            this.changedFields = updated;
        }
    }

    // =====================================================
    // STAGE CHANGE
    // =====================================================
    handleStageChange(event) {
        const fieldValue = event.detail.value;
        this.selectedStage = fieldValue;

        // Reset dependent selected values and options
        this.selectedLostReason = '';
        this.selectedReason = '';
        this.selectedSubStage = '';
        this.reasonOptions = [];
        this.subStageOptions = [];
        this.isReasonDisabled = true;
        this.isSubStageDisabled = true;

        // Remove all dependent fields from changedFields on stage change
        const updated = { ...this.changedFields };
        delete updated['Lost_Reason__c'];
        delete updated['Reason__c'];
        delete updated['Sub_Stage__c'];
        delete updated['Finance_Houses__c'];
        delete updated['Additional_Details__c'];

        if (fieldValue) {
            updated['StageName'] = fieldValue;
            const probability = this.stageProbabilityMap[fieldValue];
            if (probability !== undefined) {
                updated['Probability'] = probability;
            }
        } else {
            delete updated['StageName'];
            delete updated['Probability'];
        }

        this.changedFields = updated;

        if (!fieldValue) {
            this.lostReasonOptions = [];
            this.isLostReasonDisabled = true;
            return;
        }

        // LOST REASON options
        const controllingIndex = this.lostReasonControllerValues[fieldValue];
        if (controllingIndex !== undefined && this.lostReasonMetadata) {
            this.lostReasonOptions = [{ label: '--None--', value: '' }];
            this.lostReasonMetadata.values.forEach(item => {
                if (item.validFor.includes(controllingIndex)) {
                    this.lostReasonOptions.push({ label: item.label, value: item.value });
                }
            });
            this.isLostReasonDisabled = this.lostReasonOptions.length <= 1;
        } else {
            this.lostReasonOptions = [];
            this.isLostReasonDisabled = true;
        }

        // SUB STAGE options
        if (this.subStageMetadata) {
            const subStageIndex = this.subStageControllerValues[fieldValue];
            if (subStageIndex !== undefined) {
                this.subStageOptions = [
                    { label: '--None--', value: '' },
                    ...this.subStageMetadata.values
                        .filter(item => item.validFor.some(v => v === subStageIndex))
                        .map(item => ({ label: item.label, value: item.value }))
                ];
                this.isSubStageDisabled = this.subStageOptions.length <= 1;
            } else {
                this.subStageOptions = [];
                this.isSubStageDisabled = true;
            }
        }
    }

    // =====================================================
    // LOST REASON CHANGE
    // =====================================================
    handleLostReasonChange(event) {
        const fieldValue = event.detail.value;
        this.selectedLostReason = fieldValue;
        this.selectedReason = '';

        const updated = { ...this.changedFields };
        delete updated['Reason__c'];

        if (fieldValue) {
            updated['Lost_Reason__c'] = fieldValue;
        } else {
            delete updated['Lost_Reason__c'];
        }

        this.changedFields = updated;

        if (!fieldValue) {
            this.reasonOptions = [];
            this.isReasonDisabled = true;
            return;
        }

        // REASON options
        const controllingIndex = this.reasonControllerValues[fieldValue];
        if (controllingIndex !== undefined && this.reasonMetadata) {
            this.reasonOptions = [
                { label: '--None--', value: '' },
                ...this.reasonMetadata.values
                    .filter(item => item.validFor.some(v => v === controllingIndex))
                    .map(item => ({ label: item.label, value: item.value }))
            ];
            this.isReasonDisabled = this.reasonOptions.length <= 1;
        } else {
            this.reasonOptions = [];
            this.isReasonDisabled = true;
        }
    }

    // =====================================================
    // REASON CHANGE
    // =====================================================
    handleReasonChange(event) {
        const fieldValue = event.detail.value;
        this.selectedReason = fieldValue;

        if (fieldValue) {
            this.changedFields = { ...this.changedFields, Reason__c: fieldValue };
        } else {
            const updated = { ...this.changedFields };
            delete updated['Reason__c'];
            this.changedFields = updated;
        }
    }

    // =====================================================
    // SUB STAGE CHANGE
    // =====================================================
    handleSubStageChange(event) {
        const fieldValue = event.detail.value;
        this.selectedSubStage = fieldValue;

        if (fieldValue) {
            this.changedFields = { ...this.changedFields, Sub_Stage__c: fieldValue };
        } else {
            const updated = { ...this.changedFields };
            delete updated['Sub_Stage__c'];
            this.changedFields = updated;
        }
    }

    // =====================================================
    // FINANCE HOUSE DEPENDENCY
    // =====================================================
    evaluateFinanceHouseDependency() {
        if (!this.financeHouseMetadata) {
            return;
        }

        const countries = this.opportunities.map(opp => opp.Country__c);

        // BLANK COUNTRY
        if (countries.some(c => !c)) {
            this.financeHouseOptions = [];
            this.isFinanceHouseDisabled = true;
            return;
        }

        // MULTIPLE COUNTRIES
        const uniqueCountries = [...new Set(countries)];
        if (uniqueCountries.length > 1) {
            this.financeHouseOptions = [];
            this.isFinanceHouseDisabled = true;
            return;
        }

        const country = uniqueCountries[0];
        const controllingIndex = this.financeHouseControllerValues[country];

        if (controllingIndex !== undefined) {
            this.financeHouseOptions = [
                { label: '--None--', value: '' },
                ...this.financeHouseMetadata.values
                    .filter(item => item.validFor.some(v => v === controllingIndex))
                    .map(item => ({ label: item.label, value: item.value }))
            ];
            this.isFinanceHouseDisabled = this.financeHouseOptions.length <= 1;
        } else {
            this.financeHouseOptions = [];
            this.isFinanceHouseDisabled = true;
        }
    }

    // =====================================================
    // FINANCE HOUSE CHANGE
    // =====================================================
    handleFinanceHouseChange(event) {
        const fieldValue = event.detail.value;
        this.selectedFinanceHouse = fieldValue;

        if (fieldValue) {
            this.changedFields = { ...this.changedFields, Finance_Houses__c: fieldValue };
        } else {
            const updated = { ...this.changedFields };
            delete updated['Finance_Houses__c'];
            this.changedFields = updated;
        }
    }

    // =====================================================
    // SAVE
    // =====================================================
    handleSave() {
        // Validation: no opportunities selected
        if (!this.opportunities || this.opportunities.length === 0) {
            this.showCustomToast('Please select an Opportunity.', 'error');
            return;
        }

        // Validation: no fields changed
        if (Object.keys(this.changedFields).length === 0) {
            this.showCustomToast('Please update at least one field before saving.', 'error');
            return;
        }

        // Build minimal update payloads — only Id + changed fields
        const oppsToUpdate = this.opportunities.map(opp => ({
            Id: opp.Id,
            ...this.changedFields
        }));

        updateOpportunities({ opportunities: oppsToUpdate })
            .then(() => {
                this.showCustomToast('Records updated successfully', 'success');
                setTimeout(() => {
                    window.history.back();
                }, 2000);
            })
            .catch(error => {
                console.error(JSON.stringify(error));
                const message = error?.body?.message ?? 'Unknown Error';
                this.showCustomToast(message, 'error');
            });
    }

    // =====================================================
    // TOAST
    // =====================================================
    showCustomToast(message, variant) {
        this.toastMessage = message;
        this.toastVariant = variant;
        this.showToast = true;
        setTimeout(() => {
            this.showToast = false;
        }, 4000);
    }

    // =====================================================
    // CANCEL
    // =====================================================
    handleCancel() {
        window.history.back();
    }
}