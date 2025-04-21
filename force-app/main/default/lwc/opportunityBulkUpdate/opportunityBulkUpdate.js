import { LightningElement, api, track, wire } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import Opportunity from '@salesforce/schema/Opportunity';
import getOpportunities from '@salesforce/apex/OpportunityBulkUpdateController.getOpportunities';
import updateOpportunities from '@salesforce/apex/OpportunityBulkUpdateController.updateOpportunities';
import searchOpportunityOwners from '@salesforce/apex/OpportunityBulkUpdateController.searchOpportunityOwners';
import searchCustomerAccounts from '@salesforce/apex/OpportunityBulkUpdateController.searchCustomerAccounts';
import { NavigationMixin } from 'lightning/navigation';
import StageName from "@salesforce/schema/Opportunity.StageName";
import OpportunityType from "@salesforce/schema/Opportunity.Opportunity_Type__c";
import LostReason from "@salesforce/schema/Opportunity.Lost_Reason__c";
import Reason from "@salesforce/schema/Opportunity.Reason__c";
import SubStage from "@salesforce/schema/Opportunity.Sub_Stage__c";
import Probability from "@salesforce/schema/Opportunity.Probability";
import NetSalesPrice from "@salesforce/schema/Opportunity.Amount";
import OpportunityOwner from "@salesforce/schema/Opportunity.OwnerId";
import CustomerAccount from "@salesforce/schema/Opportunity.Customer_Account__c";
import OpportunityTypeFinance from "@salesforce/schema/Opportunity.Type";

export default class BulkUpdateOpportunities extends NavigationMixin(LightningElement) {
    @wire(getObjectInfo, { objectApiName: Opportunity })
    opportunityInfo;

    @track value = '';
    @track OpportunityTypePicklistValue;
    @track OpportunityTypeFinancePicklistValue;
    @track stageOptions = [];
    @track lostReasonOptions = [];
    @track subStageOptions = [];
    @track reasonOptions = [];
    @api recordIds;
    @track opportunities = [];
    @track recordType = '';
    @track isLCVOpportunity = false;
    @track showFields = false;
    @track isSaving = false;
    @track error;
    @track isFinance = false;
    @track showToast = false;
    @track toastMessage = '';
    @track toastVariant = 'success';
    // Owner Lookup
    @track ownerOptions = [];
    selectedOwnerName = '';
    // Account Lookup
    @track accountOptions = [];
    selectedAccountName = '';
    subStage = '';
    lostReason = '';
    reason = '';
    probabilityValue = '';
    netSalesPriceValue = '';
    selectedStage = '';
    selectedLostReason = '';
    defaultRecordTypeId;
    lcvOpportunityRecordTypeId;
    allLostReasonValues = {};
    allSubStageValues = {};
    allReasonValues = {}; // Store all Reason values
    controllingFieldMapping = {};
    subStageControllingMapping = {};
    reasonControllingMapping = {}; // Store Lost Reason to Reason mapping
    dependentPicklistFieldMetadata;
    subStagePicklistFieldMetadata;
    reasonPicklistFieldMetadata; // Store metadata for Reason field

    @wire(getPicklistValues, {
        recordTypeId: '$opportunityInfo.data.defaultRecordTypeId',
        fieldApiName: OpportunityType
    })
    getOpportunityTypePicklistValues(result) {
        if (result.data) {
            this.OpportunityTypePicklistValue = [{ label: '--None--', value: '' }, ...result.data.values];
            this.opportunityType = '';
        } else if (result.error) {
            alert('ERROR');
        }
    }


    @wire(getPicklistValues, {
        recordTypeId: '$opportunityInfo.data.defaultRecordTypeId',
        fieldApiName: OpportunityTypeFinance
    })
    getOpportunityTypeFinancePicklistValues(result) {
        if (result.data) {
            this.OpportunityTypeFinancePicklistValue = [{ label: '--None--', value: '' }, ...result.data.values];
            this.opportunityTypeFinance = '';
        } else if (result.error) {
            alert('ERROR');
        }
    }

    get lostReasonHelpText() {
        try {
            return this.opportunityInfo.data.fields[LostReason.fieldApiName].inlineHelpText || 'No help text available';
        } catch (error) {
            return 'No help text available';
        }
    }
    get probabilityHelpText() {
        try {
            return this.opportunityInfo.data.fields[Probability.fieldApiName].inlineHelpText || 'No help text available';
        } catch (error) {
            return 'No help text available';
        }
    }
    get netSalesPriceHelpText() {
        try {
            return this.opportunityInfo.data.fields[NetSalesPrice.fieldApiName].inlineHelpText || 'No help text available';
        } catch (error) {
            return 'No help text available';
        }
    }
    get opportunityOwnerHelpText() {
        try {
            return this.opportunityInfo.data.fields[OpportunityOwner.fieldApiName].inlineHelpText || 'No help text available';
        } catch (error) {
            return 'No help text available';
        }
    }
    get customerAccountHelpText() {
        try {
            return this.opportunityInfo.data.fields[CustomerAccount.fieldApiName].inlineHelpText || 'No help text available';
        } catch (error) {
            return 'No help text available';
        }
    }
    get reasonHelpText() {
        try {
            return this.opportunityInfo.data.fields[Reason.fieldApiName].inlineHelpText || 'No help text available';
        } catch (error) {
            return 'No help text available';
        }
    }

    // Fetch Record Type IDs
    @wire(getObjectInfo, { objectApiName: Opportunity })
    wiredOpportunityInfo({ error, data }) {
        if (data) {
            this.defaultRecordTypeId = data.defaultRecordTypeId;

            // Find **LCV Opportunity** Record Type dynamically
            const recordTypes = data.recordTypeInfos;
            for (let key in recordTypes) {
                if (recordTypes[key].name === 'LCV Opportunity') {
                    this.lcvOpportunityRecordTypeId = key;
                }
            }
        } else if (error) {
            console.error('Error fetching record types:', error);
        }
    }

    // Fetch picklist values for **default Record Type**
    @wire(getPicklistValuesByRecordType, { objectApiName: Opportunity, recordTypeId: '$defaultRecordTypeId' })
    wiredPicklists({ error, data }) {
        if (data) {
            this.stageOptions = [{ label: '--None--', value: '' }, ...data.picklistFieldValues[StageName.fieldApiName].values];

            // Lost Reason dependency mapping
            this.dependentPicklistFieldMetadata = data.picklistFieldValues[LostReason.fieldApiName];

            this.allLostReasonValues = this.dependentPicklistFieldMetadata.values.reduce((acc, item) => {
                acc[item.value] = item.label;
                return acc;
            }, {});
            this.controllingFieldMapping = this.dependentPicklistFieldMetadata.controllerValues;

            // Reason dependency mapping
            this.reasonPicklistFieldMetadata = data.picklistFieldValues[Reason.fieldApiName];
            this.allReasonValues = this.reasonPicklistFieldMetadata.values.reduce((acc, item) => {
                acc[item.value] = item.label;
                return acc;
            }, {});
            this.reasonControllingMapping = this.reasonPicklistFieldMetadata.controllerValues;
        } else if (error) {
            console.error(error);
        }
    }

    // Fetch picklist values for **LCV Record Type**
    @wire(getPicklistValuesByRecordType, { objectApiName: Opportunity, recordTypeId: '$lcvOpportunityRecordTypeId' })
    wiredLCVPicklists({ error, data }) {
        if (data) {
            this.subStagePicklistFieldMetadata = data.picklistFieldValues[SubStage.fieldApiName];
            this.allSubStageValues = this.subStagePicklistFieldMetadata.values.reduce((acc, item) => {
                acc[item.value] = item.label;
                return acc;
            }, {});
            this.subStageControllingMapping = this.subStagePicklistFieldMetadata.controllerValues;
        } else if (error) {
            console.error(error);
        }
    }

    handleStageChange(event) {
        this.selectedStage = event.target.value;
        this.subStage = '';
        this.lostReason = '';
        this.reason = '';
        this.opportunities = this.opportunities.map(opp => ({
            ...opp,
            Sub_Stage__c: '',
            Lost_Reason__c: '',
            Reason__c: ''
        }));
        // Call handleFieldChange to update the field in Opportunity
        this.handleFieldChange(event);
        const lostReasonKey = this.controllingFieldMapping[this.selectedStage];
        this.lostReasonOptions = [{ label: '--None--', value: '' }, ...(lostReasonKey !== undefined ?
            this.dependentPicklistFieldMetadata.values
            .filter(item => item.validFor.includes(lostReasonKey))
            .map(item => ({ label: item.label, value: item.value })) : []
        )];
        // Clear Reason when Stage changes
        this.reasonOptions = [];
        // Update Sub Stage picklist options from **LCV Opportunity Record Type**
        const subStageKey = this.subStageControllingMapping[this.selectedStage];
        this.subStageOptions = [{ label: '--None--', value: '' }, ...(subStageKey !== undefined ?
            this.subStagePicklistFieldMetadata.values
            .filter(item => item.validFor.includes(subStageKey))
            .map(item => ({ label: item.label, value: item.value })) : []
        )];

    }

    handleLostReasonChange(event) {
        this.selectedLostReason = event.target.value;
        this.reason = '';
        this.opportunities = this.opportunities.map(opp => ({
            ...opp,
            Reason__c: ''
        }));
        // Call handleFieldChange to update the field in Opportunity
        this.handleFieldChange(event);
        // Update Reason picklist options based on Lost Reason
        const reasonKey = this.reasonControllingMapping[this.selectedLostReason];
        this.reasonOptions = [{ label: '--None--', value: '' }, ...(reasonKey !== undefined ?
            this.reasonPicklistFieldMetadata.values
            .filter(item => item.validFor.includes(reasonKey))
            .map(item => ({ label: item.label, value: item.value })) : []
        )];
    }

    handleFieldChange(event) {
        const fieldName = event.target.name;
        const fieldValue = event.target.value;
        if (event.target.name === 'Sub_Stage__c') {
            this.subStage = event.target.value;
        }
        if (event.target.name === 'Lost_Reason__c') {
            this.lostReason = event.target.value;
        }
        if (event.target.name === 'Reason__c') {
            this.reason = event.target.value;
        }
        if (event.target.name === 'Probability') {
            this.probabilityValue = event.target.value;
        }
        if (event.target.name === 'Amount') {
            this.netSalesPriceValue = event.target.value;
        }
        if (event.target.name === 'OwnerId') {
            this.selectedOwnerName = event.target.value;
        }
        if (event.target.name === 'Customer_Account__c') {
            this.selectedAccountName = event.target.value;
        }
        if (event.target.name === 'Opportunity_Type__c') {
            this.opportunityType = event.target.value;
        }
        if (event.target.name === 'Type') {
            this.opportunityTypeFinance = event.target.value;
        }

        let updatedOpportunities = this.opportunities.map(opp => {
            let updatedOpp = {...opp };
            // If "None" is selected, remove the field from the update
            if (fieldValue === '') {
                delete updatedOpp[fieldName]; // Prevents updating the field
            } else {
                updatedOpp[fieldName] = fieldValue; // Normal update
            }
            return updatedOpp;
        });
        this.opportunities = updatedOpportunities;
    }

    get isLostReasonDisabled() {
        return this.selectedStage === '' || this.lostReasonOptions.length === 1;
    }

    get isSubStageDisabled() {
        return this.selectedStage === '' || this.subStageOptions.length === 1;
    }
    get isReasonDisabled() {

        return !this.selectedStage || this.selectedStage === ' ' || !this.selectedLostReason || this.reasonOptions.length <= 1;
    }


    // Search Opportunity Owner (Users)
    handleOwnerSearch(event) {
        const searchTerm = event.target.value.trim();
        this.selectedOwnerName = '';

        if (searchTerm.length < 1) {
            this.ownerOptions = [];
            this.selectedOwnerName = '';
            this.handleFieldChange(event);
            return;
        }
        searchOpportunityOwners({ searchTerm: searchTerm + '%' }) // Fetch users starting with this letter
            .then(result => {
                this.ownerOptions = result.map(user => ({
                    Id: user.Id,
                    Name: user.Name
                }));

            })

        .catch(error => {
            console.error('Error fetching users:', error);
            this.ownerOptions = [];
        });
    }

    selectOwner(event) {

        const selectedId = event.target.dataset.id;
        const selectedName = event.target.dataset.name;
        this.selectedOwnerName = selectedName; // Display selected name
        this.showOwnerDropdown = false; // Hide dropdown
        this.ownerOptions = [];
        // Update opportunities using handleFieldChange logic
        this.opportunities = this.opportunities.map(opp => {
            return {...opp, OwnerId: selectedId };
        });

    }

    // Search Customer Account (Accounts)
    handleAccountSearch(event) {
        const searchTerm = event.target.value.trim();
        this.selectedAccountName = '';

        if (searchTerm.length < 1) {
            this.accountOptions = [];
            this.selectedAccountName = '';
            this.handleFieldChange(event);
            return;
        }

        searchCustomerAccounts({ searchTerm: searchTerm + '%' }) // Fetch accounts starting with this letter
            .then(result => {
                this.accountOptions = result.map(account => ({
                    Id: account.Id,
                    Name: account.Name
                }));
            })
            .catch(error => {
                console.error('Error fetching accounts:', error);
                this.accountOptions = [];
            });
    }

    selectAccount(event) {

        const selectedId = event.target.dataset.id;
        const selectedName = event.target.dataset.name;
        this.selectedAccountName = selectedName; // Display selected name
        this.showAccountDropdown = false; // Hide dropdown
        this.accountOptions = [];
        // // Update opportunities using handleFieldChange logic
        this.opportunities = this.opportunities.map(opp => {
            return {...opp, Customer_Account__c: selectedId };
        });
    }

    connectedCallback() {
        getOpportunities({ sSelectedOpportunityIds: this.recordIds })
            .then(result => {
                if (result.length === 0) {

                    this.error = 'No valid opportunities found.';
                    return;
                }
                const recordTypeSet = new Set(result.map(opp => opp.RecordType.Name));
                if (recordTypeSet.size > 1) {
                    this.error = 'Please select records with the same Record Type.';

                    return;
                }

                this.opportunities = result;
                this.recordType = result[0].RecordType.Name;

                this.showFields = true;
                if (result[0].RecordType.Name === 'LCV Opportunity') {
                    this.isLCVOpportunity = true;
                    return;
                }
                if (result[0].RecordType.Name === 'Finance') {
                    this.isFinance = true;
                }
            })
            .catch(error => {
                console.error('Error details:', JSON.stringify(error));
                this.error = 'Error fetching opportunities: ' + (error.body ? JSON.stringify(error.body) : JSON.stringify(error));
            });
    }

    handleSave() {
        if (this.selectedStage !== '' || this.selectedAccountName !== '' || this.selectedOwnerName !== '' || this.opportunityType !== '' ||
            this.opportunityTypeFinance !== '' || this.probabilityValue !== '' || this.netSalesPriceValue !== '') {
            updateOpportunities({ opportunities: this.opportunities })
                .then(() => {
                    this.showCustomToast('Records updated successfully', 'success');
                    setTimeout(() => window.history.back(), 2000);
                })
        } else {
            this.showCustomToast('No Changes to Update', 'warning');
            setTimeout(() => window.history.back(), 2000);
        }

    }

    showCustomToast(message, variant) {
        this.toastMessage = message;
        this.toastVariant = variant;
        this.showToast = true;

        setTimeout(() => {
            this.showToast = false;
        }, 4000);
    }

    handleCancel() {
        window.history.back();
    }
}