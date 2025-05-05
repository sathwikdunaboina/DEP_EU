import { LightningElement, api, track, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import Account from '@salesforce/schema/Account';
import getAccounts from '@salesforce/apex/AccountBulkUpdateController.getAccounts';
import updateAccounts from '@salesforce/apex/AccountBulkUpdateController.updateAccounts';
import searchAccountOwners from '@salesforce/apex/AccountBulkUpdateController.searchAccountOwners';
import AccountOwner from "@salesforce/schema/Account.OwnerId";
export default class AccountBulkUpdate extends LightningElement {
    @wire(getObjectInfo, { objectApiName: Account })
    accountInfo;

    @api recordIds;
    @track showFields = false;

    // Owner Lookup
    @track ownerOptions = [];
    selectedOwnerName = '';

    @track accounts = [];
    @track ownerId = '';
    @track transferOpportunities = false;
    @track isSaving = false;
    @track error;
    @track isFinance = false;
    @track showToast = false;
    @track toastMessage = '';
    @track toastVariant = 'success';


    get accountOwnerHelpText() {
        try {
            return this.accountInfo.data.fields[AccountOwner.fieldApiName].inlineHelpText || 'No help text available';
        } catch (error) {
            return 'No help text available';
        }
    }

    get recordTypeCounts() {
        const counts = { Dealer: 0, Customer: 0 };
        if (this.accounts) {
            this.accounts.forEach(acc => {
                const rtName = acc.RecordType && acc.RecordType.Name;
                if (rtName === 'Dealer Account') counts.Dealer++;
                if (rtName === 'Customer Account') counts.Customer++;
            });
        }
        return counts;
    }

    handleFieldChange(event) {
        const fieldName = event.target.name;
        const fieldValue = event.target.value;

        if (event.target.name === 'OwnerId') {
            this.selectedOwnerName = event.target.value;
        }

        let updatedAccounts = this.accounts.map(acc => {
            let updatedAcc = {...acc };
            // If "None" is selected, remove the field from the update
            if (fieldValue === '') {
                delete updatedAcc[fieldName]; // Prevents updating the field
            } else {
                updatedAcc[fieldName] = fieldValue; // Normal update
            }
            return updatedAcc;
        });
        this.accounts = updatedAccounts;
    }

    // Search Account Owner (Users)
    handleOwnerSearch(event) {
        const searchTerm = event.target.value.trim();
        this.selectedOwnerName = '';

        if (searchTerm.length < 1) {
            this.ownerOptions = [];
            this.selectedOwnerName = '';
            this.handleFieldChange(event);
            return;
        }
        searchAccountOwners({ searchTerm: searchTerm + '%' }) // Fetch users starting with this letter
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
        // Update accounts using handleFieldChange logic
        this.accounts = this.accounts.map(acc => {
            return {...acc, OwnerId: selectedId };
        });

    }
    handleCheckboxChange(event) {
        this.transferOpportunities = event.target.checked;
    }

    connectedCallback() {
        getAccounts({ sSelectedAccountIds: this.recordIds })
            .then(result => {
                if (result.length === 0) {
                    this.error = 'No valid accounts found.';
                    return;
                }
                this.accounts = result;
                this.showFields = true;
            })
            .catch(error => {
                console.error('Error details:', JSON.stringify(error));
                this.error = 'Error fetching accounts: ' + (error.body ? JSON.stringify(error.body) : JSON.stringify(error));
            });
    }

    handleSave() {
        try {
            if (this.selectedOwnerName !== '') {
                updateAccounts({ accounts: this.accounts, transferOpportunities: this.transferOpportunities })
                    .then(() => {
                        this.showCustomToast('Records updated successfully', 'success');
                        setTimeout(() => window.history.back(), 2000);
                    })
                    .catch(error => {
                        this.showCustomToast('Error while updating Records', 'error');
                        setTimeout(() => window.history.back(), 2000);
                    });
            } else {
                this.showCustomToast('No Changes to Update', 'warning');
                setTimeout(() => window.history.back(), 2000);
            }
        } catch (error) {
            console.error('Unexpected error in handleSave:', error);
            this.showCustomToast('Unexpected error occurred', 'error');
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