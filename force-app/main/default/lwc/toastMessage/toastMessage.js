import { LightningElement, api, track } from 'lwc';

export default class CustomToast extends LightningElement {

    @api message = 'Operation Successful';

    @api variant = 'success'; // success, error, warning

    @api duration = 3000;

    @track showToast = false;

    toastClass = 'slds-notify slds-notify_toast';

    iconName;

    connectedCallback() {

        this.setStyle();
        console.log('Connected Call back in toastMesage');

        this.showToast = true;

        setTimeout(() => {

            this.showToast = false;
console.log('set time out');
        }, this.duration);

    }

    setStyle() {
        console.log('Entered in style');
        console.log('Variant:', this.variant); // Add this log to check the variant value


        if (this.variant === 'success') {
            console.log('Success');

            this.iconName = 'utility:success';

            this.toastClass += ' slds-theme_success'; // Green background

        } else if (this.variant === 'error') {

            console.log('Error');
            this.iconName = 'utility:error';

            this.toastClass += ' slds-theme_error'; // Red background

        } else if (this.variant === 'warning') {

            console.log('Warning');
            this.iconName = 'utility:warning';

            this.toastClass += ' slds-theme_warning'; // Yellow background

        }
        else{
            console.log('no condition');
        }

    }

}