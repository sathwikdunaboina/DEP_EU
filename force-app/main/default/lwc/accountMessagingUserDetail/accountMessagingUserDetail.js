import { LightningElement , api } from 'lwc';
import getAccountMessagingUserDetails from '@salesforce/apex/AccountMessagingUserController.getAccountMessagingUserDetails';
import createMessagingUser from '@salesforce/apex/AccountMessagingUserController.createMessagingUser';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Account_Name from '@salesforce/label/c.Account_Name';
import Account_Phone from '@salesforce/label/c.Account_Phone';
import Account_Website from '@salesforce/label/c.Account_Website';
import IsEnabledForMessaging from '@salesforce/label/c.IsEnabledForMessagingLabel';
import Enabled from '@salesforce/label/c.EnabledLabel';




/*const columns = [
    { label: 'Account Name', fieldName: 'sAccName' },
    { label: 'Website', fieldName: 'sAccWebsite', type: 'url' },
    { label: 'Phone', fieldName: 'sAccPhone', type: 'phone' },
    {
        type: "button", label: 'Is Enabled For Messaging', typeAttributes: {
            label: {fieldName: 'sEnableOrNot'},
            name: {fieldName: 'sEnableOrNot'},
            title: {fieldName: 'sEnableOrNot'},
            disabled: {fieldName: 'bMessagingUserPresent'},
            value: {fieldName: 'sEnableOrNot'},
            iconPosition: 'left',
            variant:'success'
        }
    }
];
*/


export default class AccountMessagingUser extends LightningElement {

    
    @api listAccountIds ; 
    data = [];
    columns = [
        { label: Account_Name, fieldName: 'sAccName' },
        { label: Account_Phone, fieldName: 'sAccPhone', type: 'phone' },
        { label: Account_Website, fieldName: 'sAccWebsite', type: 'url' },
        {
            type: "button", label: IsEnabledForMessaging, typeAttributes: {
                label: {fieldName: 'sEnableOrNot'},
                name: {fieldName: 'sEnableOrNot'},
                title: {fieldName: 'sEnableOrNot'},
                disabled: {fieldName: 'bMessagingUserPresent'},
                value: {fieldName: 'sEnableOrNot'},
                iconPosition: 'left',
                variant:'success'
            }
        }
    ];;
    loadSpinner = true;

    async connectedCallback() {
       this.data = await getAccountMessagingUserDetails({ sSelectedAccountIds: this.listAccountIds });
       this.loadSpinner = false;
    }

    async callRowAction(event) {
        let result = await createMessagingUser({sAccId : event.detail.row.sAccId , sAccName : event.detail.row.sAccName, sAccPhone : event.detail.row.sAccPhone});
        if(result == true){
            let tempData = [... this.data];
            for(var key of tempData){
              if(key.sAccId == event.detail.row.sAccId){
                  key.bMessagingUserPresent = true;
                  key.sEnableOrNot = Enabled;
              }
        }
             this.data = [... tempData];
        }

       
    }
}