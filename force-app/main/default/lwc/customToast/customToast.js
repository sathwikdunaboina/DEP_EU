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
        this.showToast = true;
 
        setTimeout(() => {
            this.showToast = false;
        }, this.duration);
    }
 
    setStyle() {
        if (this.variant === 'success') {
            this.iconName = 'utility:success';
            this.toastClass += ' slds-theme_success'; // Green background
        } else if (this.variant === 'error') {
            this.iconName = 'utility:error';
            this.toastClass += ' slds-theme_error'; // Red background
        } else if (this.variant === 'warning') {
            this.iconName = 'utility:warning';
            this.toastClass += ' slds-theme_warning'; // Yellow background
        }
    }
}