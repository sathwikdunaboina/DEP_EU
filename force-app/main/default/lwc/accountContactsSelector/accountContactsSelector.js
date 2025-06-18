import { LightningElement, api, track } from 'lwc';
import getAccountsWithContacts from '@salesforce/apex/AccountContactsSelectorController.getAccountsWithContacts';
import Selects_Contacts from '@salesforce/label/c.Selects_Contacts';
import Select from '@salesforce/label/c.Select';
import Name from '@salesforce/label/c.Name';
import Email from '@salesforce/label/c.Email';
import No_Contacts_Available from '@salesforce/label/c.No_contacts_available';
import This_account_doesn_t_have_any_related_contacts from '@salesforce/label/c.This_account_doesn_t_have_any_related_contacts';
export default class AccountContactsSelector extends LightningElement {

 
  @api accountIds;
  @api selectedContactIdsList = []; // output to flow
  
  @track accountsWithContacts = [];
  @track isLoading = true;
  @track error;

  connectedCallback() {
    this.loadAccounts();
  }
  
  label = {
    Selects_Contacts , 
    Select , 
    Name ,
    Email , 
    No_Contacts_Available , 
    This_account_doesn_t_have_any_related_contacts
  }

  loadAccounts() {
    this.isLoading = true;
    getAccountsWithContacts({ accountIds: this.accountIds })
      .then((result) => {
        // Add selected property to each contact
        this.accountsWithContacts = result.map(acc => ({
          ...acc,
          Contacts: (acc.Contacts || []).map(contact => ({
            ...contact,
            selected: this.selectedContactIdsList.includes(contact.Id)  
          }))
        }));
        this.error = null;
      })
      .catch((err) => {
        this.error = err;
      })
      .finally(() => {
        this.isLoading = false;
      });
  }

  handleCheckboxChange(event) {
    const contactId = event.target.dataset.id;
    const checked = event.target.checked;

    // Update selectedContactIds array
    if (checked) {
      if (!this.selectedContactIdsList.includes(contactId)) {
        this.selectedContactIdsList = [...this.selectedContactIdsList, contactId];
      }
    } else {
      this.selectedContactIdsList = this.selectedContactIdsList.filter(id => id !== contactId);
    }

    // Update the contact's selected property in local state
    this.accountsWithContacts = this.accountsWithContacts.map(acc => ({
      ...acc,
      Contacts: acc.Contacts.map(contact => ({
        ...contact,
        selected: this.selectedContactIdsList.includes(contact.Id)
      }))
    }));
    
    this.selectedContactId = this.selectedContactIdsList.join('-')
  }
  
}