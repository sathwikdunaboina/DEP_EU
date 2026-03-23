import { LightningElement, api, wire,track } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import getCaseComments from '@salesforce/apex/CaseCommentController.getCaseComments';
import createPrivateCommentWithEmail from '@salesforce/apex/CaseCommentController.createPrivateCommentWithEmail';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class CaseComments extends NavigationMixin(LightningElement) {
@api recordId; 
comments;
@track selectedComment = {};
@track filteredComments;
@track comments;
@track caseComments;
@track publishToCustomerCheckbox = false;
wiredCommentsResult; 
errorMessage;


isModalOpen = false; 

columns = [


{label: 'Created Date',fieldName: 'createdDateLocal',type: 'text'},
{ label: 'Body', fieldName: 'shortBody', type: 'text', wrapText: true },
{ label: 'Published', fieldName: 'IsPublished', type: 'boolean' },

{
    type: 'button',
    typeAttributes: {
        label: 'view',
        name: 'view',
        variant: 'neutral',           
        iconPosition: 'right' 
    }
}
];
connectedCallback() {
}

@wire(getCaseComments, { caseId: '$recordId' })
wiredComments(result) {
    
this.wiredCommentsResult = result; 
this.filteredComments = result.data;

if (result.data) {
    this.comments = result.data.map(comment => {
        const shortBody = comment.CommentBody
            ? comment.CommentBody.substring(0, 30) + (comment.CommentBody.length > 30 ? '...' : '')
            : '';
    const createdDateLocal = new Date(comment.CreatedDate).toLocaleString('en-GB', {
        day: '2-digit',
        month: '2-digit',
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
        timeZone: 'Europe/Paris', 
        hour12: false
    });

        return {
            ...comment,           
            shortBody,
            createdDateLocal
        };
    });

    this.filteredComments = [...this.comments]; 
    } 

}
handleComments(event){
    this.caseComments = event.target.value;
    this.errorMessage=false;
}
handleSearch(event) {
    this.searchTerm = event.target.value.toLowerCase();
    this.filteredComments = this.comments.filter(comment =>
        (comment.CommentBody && comment.CommentBody.toLowerCase().includes(this.searchTerm)) ||
        (comment.CreatedDate && comment.CreatedDate.toLowerCase().includes(this.searchTerm))
    );

}    
handleRowAction(event) {
    const actionName = event.detail.action.name;
    const row = event.detail.row;
    if (actionName === 'view') {
    this.selectedComment = { ...row };
    this.isModalOpen = true;
        

    }
}

handlePublishCheckbox(event){
    this.publishToCustomerCheckbox = event.target.checked;
}


handlePublishedChange(event) {

const isChecked = event.target.checked;

this.selectedComment = {
    ...this.selectedComment,
    IsPublished: isChecked
};

}
handleSubmit(){
    this.errorMessage =false;
    if(this.caseComments===null || !this.caseComments){
            this.errorMessage =false;

    this.dispatchEvent(
            new ShowToastEvent({
                title: 'Case Comment should not be empty',
                variant: 'Error'
            })
        );
        return;
    }
    


createPrivateCommentWithEmail ({caseId:this.recordId, commentBody: this.caseComments,IsPublished:this.publishToCustomerCheckbox})
    .then(result => {
    if (result.startsWith('Success')) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Case Comment was Saved',
                variant: 'success'
            })
        );
            this.caseComments = '';
this.errorMessage =false;
                this.publishToCustomerCheckbox = false;
                return refreshApex(this.wiredCommentsResult);  
    }  

if (result.startsWith('Error')) {        
            this.errorMessage = 'Character limit exceeded.';
    }

    })
    
.catch(error => {
    let errorMessage = 'An unexpected error occurred.';
                if (error && error.body && error.body.output && error.body.output.errors && error.body.output.errors.length > 0) {
                    errorMessage = error.body.output.errors[0].message;
                } else if (error.body && error.body.message) {
                    errorMessage = error.body.message; 
                }
    this.dispatchEvent(new ShowToastEvent({
        title: 'Error',
        variant: 'error',
        message: errorMessage,
        mode: 'sticky'


    }));
});

            }          

        
saveModal() {

const fields = {
    Id: this.selectedComment.Id,
    IsPublished: this.selectedComment.IsPublished
};


const recordInput = { fields };


updateRecord(recordInput)
    .then(() => {
        
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Case Comment was Saved',
                variant: 'success'
            })
        );
            this.isModalOpen = false;
        return refreshApex(this.wiredCommentsResult);           
                
    })
    .catch(error => {
 let errorMessage = 'An unexpected error occurred.';
                if (error && error.body && error.body.output && error.body.output.errors && error.body.output.errors.length > 0) {
                    errorMessage = error.body.output.errors[0].message;
                } else if (error.body && error.body.message) {
                    errorMessage = error.body.message; 
                }
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                variant: 'error',
                message: errorMessage,
                mode: 'sticky'
            })
        );
    });

}
closeModal() {
    this.isModalOpen = false;
    this.selectedComment = null;
}

handleError(event) {
const error = event.detail;
let message = 'Case Comment1 character limit exceeded';
if (error && error.body && error.body.output && error.body.output.errors) {
    const errors = error.body.output.errors;
    message = errors.map(e => e.message).join('\n');
}
this.dispatchEvent(
    new ShowToastEvent({
        title: 'Validation Error',
        message: message,
        variant: 'error',
    })
);
}
}