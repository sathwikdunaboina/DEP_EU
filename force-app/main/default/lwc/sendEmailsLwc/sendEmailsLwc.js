import { LightningElement, api, track } from 'lwc';
import sendEmailsToContacts from '@salesforce/apex/SendEmailsLwcController.sendEmailsToContacts';
import getEmailTemplateDetails from '@salesforce/apex/SendEmailsLwcController.getEmailTemplateDetails';
import Send_Email_to_Contacts from '@salesforce/label/c.Send_Email_to_Contacts';
import Subject from '@salesforce/label/c.Subject';
import Send_Email from '@salesforce/label/c.Send_Email';
import Emails_Sent_Successfully from '@salesforce/label/c.Emails_Sent_Successfully';
import Failed_to_send_Emails from '@salesforce/label/c.Failed_to_send_Emails';



export default class SendEmailsLwc extends LightningElement {
    @api emailBody;  // pre-filled from flow
    @api emailTemplateId;
    @api contactIds; // passed from flow as a list of Ids
    @track emailSubject = '';

    @track showSuccess = false;
    @track showError = false;
    errorMessage = '';
    isRendered = false;

    label = {
      Send_Email_to_Contacts , 
      Subject , 
      Send_Email , 
      Failed_to_send_Emails , 
      Emails_Sent_Successfully
    }

    connectedCallback() {
        this.loadTemplate();
    }
    
      loadTemplate() {
        if (this.emailTemplateId) {
          getEmailTemplateDetails({ templateId: this.emailTemplateId })
            .then((result) => {
              this.emailSubject = result.sSubject;
              this.emailBody = result.sHtmlBody;
            })
            .catch((error) => {
              console.error('Error loading template', error);
            });
        }
      }

    handleBodyChange(event) {
        this.emailBody = event.detail.value;
    }
    handleSubjectChange(event) {
        this.emailSubject = event.detail.value;
    }

    async handleSendEmail() {
        this.showSuccess = false;
        this.showError = false;
        
        try {
            await sendEmailsToContacts({
                listContactIds: this.contactIds,
                sBaseEmailBody: this.emailBody,
                sSubject : this.emailSubject
            });
            this.showSuccess = true;
        } catch (error) {
            this.errorMessage = error.body?.message || 'Unknown error';
            this.showError = true;
        }
    }
}