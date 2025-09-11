import { LightningElement, api,wire,track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord} from 'lightning/uiRecordApi';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import getAccountDetails from '@salesforce/apex/AccountEditController.getAccountDetails';
import updateMultipleAccounts from '@salesforce/apex/AccountEditController.updateMultipleAccounts';
import checkDuplicateRules from '@salesforce/apex/AccountEditController.checkDuplicateRules';
import BILLING_STATECODE_FIELD from '@salesforce/schema/Account.BillingStateCode';
import { COUNTRY_PICKLIST } from 'c/globalCountryPicklist';

const FIELDS = ['Account.RecordTypeId','Account.CreatedBy.Name','Account.Customer_Number__c','Account.CustomerID__c','Account.LastModifiedBy.Name','Account.Owner.Alias','Account.CreatedDate','Account.LastModifiedDate','Account.RecordType.Name','Account.OwnerId','Account.BillingCountry','Account.BillingStreet','Account.BillingCity','Account.BillingStateCode','Account.BillingState','Account.BillingCountryCode','Account.BillingPostalCode','Account.Name'];

export default class EditButtonOnAccount extends NavigationMixin(LightningElement) {
@api recordId;
@track showDuplicateAlert = false;
@track duplicateAccounts = [];
@track isDuplicate = false;
@track createdBy;
@track showForm = true; 
@track successHandled = false;
@track billingAddress = {}; 
@track showDuplicateModal = false; 
@track duplicateBlock = false;

recordTypeId;
recordTypeName;
selectedAccountName;
accountName;
selectedCompanyRegistrationNumber;
selectedCustomerId;
selectedBillingAddress;
selectedAccountBillingCountry;
selectedBillingCity;
selectedBillingStreet;
selectedBillingState;
selectedBillingPostalCode;    
createdByDetails;
CreatedDate;
lastModifiedByDetails;
lastModifiedBy;
mode = '';
allowSave = false; 
duplicateAccounts = [];
isUpdated = false; 
ownerName;
isSaveAndNew = false;
modalHeaderClass = '';
alertMessageClass = '';
selectCountryValue = '';
selectCountryFilter = [];
CountryPicklistOptions = COUNTRY_PICKLIST;
isReadOnly = true;


    
@wire(getAccountDetails, { recordId: '$recordId' })
wiredAccount({ data, error }) {
if (data) {
    this.billingAddress = {
        street: data.BillingStreet,
        city: data.BillingCity,
        province: data.BillingState,
        country: data.BillingCountry,
        postalCode: data.BillingPostalCode
    };
    
  
} 
}
    
connectedCallback() {

}

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) {
    if (data && !this.isUpdated && !this.successHandled) {
        this.accountData = data;

const createdRaw = data.fields.CreatedDate?.value;
const modifiedRaw = data.fields.LastModifiedDate?.value;

const formatDate = (rawDate) => {
    if (!rawDate) return '';
    return new Intl.DateTimeFormat('en-GB', {
        day: '2-digit',
        month: '2-digit',
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
        hour12: false,
        timeZone: 'Europe/Paris' 
    }).format(new Date(rawDate));
};

    this.createdDate = formatDate(createdRaw);
    this.lastModifiedDate = formatDate(modifiedRaw);
    this.ownerName = data.fields.Owner.value.fields.Name?.value; 
    this.recordTypeName = data.fields.RecordType?.displayValue;
    this.selectedAccountName = data.fields.Name?.value;
    this.selectedCompanyRegistrationNumber = data.fields.CompanyRegistrationNumber__c?.value;
    this.selectedCustomerId = data.fields.CustomerID__c?.value;
    this.selectedAccountBillingCountry = data.fields.BillingCountry?.value;
    this.selectedBillingCity = data.fields.BillingCity?.value;
    this.selectedBillingStreet = data.fields.BillingStreet?.value;
    this.selectedBillingState = data.fields.BillingState?.value;
    this.selectedBillingPostalCode = data.fields.BillingPostalCode?.value;
    this.selectedBillingAddress = data.fields.BillingAddress?.value;
    this.createdBy = data.fields.CreatedBy.value.fields.Name?.value; 
    this.lastModifiedBy = data.fields.LastModifiedBy.value.fields.Name?.value;
    this.createdByDetails = ` ${this.createdBy} , ${this.createdDate}`;
    this.lastModifiedByDetails = ` ${this.lastModifiedBy} , ${this.lastModifiedDate}`;
                 if(data.fields.BillingCountryCode.value != null){
                this.selectCountryValue = data.fields.BillingCountryCode.value;
                // alert(data.fields.BillingCountryCode.value);
                console.log(data.fields.BillingCountryCode.value+'data.fields.BillingCountryCode.value');
                this.selectCountryFilter.push(this.selectCountryValue);
            }

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
this.selectedAccountBillingCountry = event.detail.country;
this.selectedBillingStreet = event.detail.street;
this.selectedBillingCity = event.detail.city;
this.selectedBillingState = event.detail.province;
this.selectedBillingPostalCode = event.detail.postalCode;
this.isReadOnly = false;


}
 handleSave() {
    this.mode = 'save';
    this.isSaveAndNew = false;
    this.initiateDuplicateCheckAndSave();
}

handleSaveAndNew() {
    this.mode = 'saveAndNew';
    this.isSaveAndNew = true;
    this.initiateDuplicateCheckAndSave();
}
async initiateDuplicateCheckAndSave() {
    const inputFields = this.template.querySelectorAll('lightning-input-field');
    let fieldMap = {};
    inputFields.forEach(field => {
        const apiName = field.fieldName;
        fieldMap[apiName] = field.value;
    });
    const accountName = fieldMap['Name'];
    const fieldMapAll = {
        Id: this.recordId,
        BillingStreet: this.selectedBillingStreet,
        BillingCity: this.selectedBillingCity,
        BillingPostalCode: this.selectedBillingPostalCode,
        BillingCountry: this.selectedAccountBillingCountry,
    };

    fieldMap = { ...fieldMapAll, ...fieldMap };
    if (this.allowSave) {
        this.submitForm();
        return;
    }

    const duplicateResult = await checkDuplicateRules({ fieldMap });

    if (duplicateResult.isDuplicate) {
        this.showDuplicateModal = true;
        this.duplicateAccounts = duplicateResult.matchedAccounts || [];

        if (duplicateResult.isAllow) {
            this.duplicateBlock = false;
            this.allowSave = true;
        } else {
            this.duplicateBlock = true;
            this.allowSave = false;
        }
        return;
    }

    this.allowSave = true;
    this.submitForm();
}

submitForm() {
    this.successHandled = true;

    const inputFields = this.template.querySelectorAll('lightning-input-field');
    let fieldMap = { Id: this.recordId };

    inputFields.forEach(field => {
        const apiName = field.fieldName;
        fieldMap[apiName] = field.value;
    });

    fieldMap.BillingStreet = this.selectedBillingStreet;
    fieldMap.BillingCity = this.selectedBillingCity;
    fieldMap.BillingPostalCode = this.selectedBillingPostalCode;
    fieldMap.BillingCountry = this.selectedAccountBillingCountry;

    const accountName = fieldMap['Name'];

    updateMultipleAccounts({ acc: fieldMap })
        .then((result) => {
            if (result && result.success) {
                this.handleUpdateState();
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: `Account "${accountName}" was saved.`,
                        variant: 'success'
                    })
                    
                );
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: this.recordId,
                        objectApiName: 'Account',
                        actionName: 'view'
                    }
                    
                });
                this.isReadOnly = true;

               getRecordNotifyChange([{ recordId: this.recordId }]);

                        }
                         if (this.mode === 'saveAndNew') {
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
            getRecordNotifyChange([{ recordId: this.recordId }]);

                } 

                        
        })
        .catch(error => {
           let message = 'An unexpected error occurred.';
            if (error && error.body && typeof error.body.message === 'string') {
                message = error.body.message;
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
        stateUpdate[BILLING_STATECODE_FIELD.fieldApiName] = this.selectedBillingState;
        stateUpdate.Id = this.recordId;
        stateUpdate.Name = this.accountName;

        updateMultipleAccounts({ acc: stateUpdate})
                .then((result) => {
             
 this.allowSave = true;
 this.showDuplicateModal = false; 
 this.duplicateAccounts = []; 
 this.showSaveButton = false;
}
);
          }
        handleOpenRecord(event) {
            const recordId = event.target.dataset.id;
            const recordLink = `/lightning/r/Account/${recordId}/view`; 
            window.open(recordLink, '_blank'); 
        }
        handleViewDuplicates(event) {
            event.preventDefault(); //         
                    this.showDuplicateAlert = true;
                    this.showDuplicateModal = false;
        return;
        }
        handleCancelAlert()
        {
            
    this.showDuplicateAlert = false;
    if(this.duplicateBlock){
    this.allowSave = false; 
    }
        }
        
        
        handleCancel(){
            this.showDuplicateModal=false;

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
        handleCancelIcon() {
            window.history.back(); 
        }
        handleCloseAlert(){            
            this.showDuplicateModal = false;
            this.successHandled = true;
           // return;
                }  
        closeDuplicateModal(){
            this.showDuplicateAlert = false; 
        }
        get modalHeadeComputedClass() {
            return 'slds-modal__header $ {this.modalHeaderClass}';
        }
    
        get alertMessageComputedClass() {
            return 'slds-text-body_regular $ {this.alertMessageClass}';
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
        get duplicateHeaderMessage() {
            return this.duplicateBlock ?
                'Similar Records Exist (Blocked)' :
                'Similar Records Exist';
        }   

    get googleMapsUrl() {
        return `https://www.google.com/maps?q=${encodeURIComponent(this.selectedAccountName)}`;
    }
handleGoogleMapsRedirect(event) {
    event.preventDefault(); // Stop default link action

    const userConfirmed = window.confirm(
        `You’re being redirected to: ${this.googleMapsUrl}\n\nDo you want to leave this page?`
    );

    if (userConfirmed) {
        window.open(this.googleMapsUrl, '_blank');
    }
}

get googleNewsUrl() {
        return `https://news.google.com/search?q=${encodeURIComponent(this.selectedAccountName)}`;
    } 
handleGoogleNewsRedirect(event) {
event.preventDefault(); // Stop default link action

const userConfirmedNews = window.confirm(
    `You’re being redirected to: ${this.googleNewsUrl}\n\nDo you want to leave this page?`
);

if (userConfirmedNews) {
    window.open(this.googleNewsUrl, '_blank');
}
}

    get googleSearchUrl() {
        return `https://www.google.com/search?q=${encodeURIComponent(this.selectedAccountName)}`;
    }
handleGoogleSearchRedirect(event) {
    event.preventDefault(); // Stop default link action

    const userConfirmedSearch = window.confirm(
        `You’re being redirected to: ${this.googleSearchUrl}\n\nDo you want to leave this page?`
    );

    if (userConfirmedSearch) {
        window.open(this.googleSearchUrl, '_blank');
    }
}
get isCustomerAccount() {
    return this.recordTypeName === 'Customer Account';
}

get isDealerAccount() {
    return this.recordTypeName === 'Dealer Account';
}

handleCancel() {
window.history.back();
}

handleError(event) {
    const error = event.detail;
    let message = 'An error occurred while saving the record.';
    if (error && error.body && error.body.output && error.body.output.errors) {
        const errors = error.body.output.errors;
        message = errors.map(e => e.message).join('\n');
    }
    this.dispatchEvent(
        new ShowToastEvent({
            title: 'Validation Error',
            message: message,
            variant: 'error',
            mode: 'sticky'
        })
    );
}


}