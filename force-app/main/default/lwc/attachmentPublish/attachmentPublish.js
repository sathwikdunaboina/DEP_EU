import { LightningElement, api, wire } from 'lwc';
import getFiles from '@salesforce/apex/FilePublishController.getFiles';
import updatePublishStatus from '@salesforce/apex/FilePublishController.updatePublishStatus';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

const COLUMNS = [
    {
        label: 'File Name',
        fieldName: 'Title',
        type: 'text'
    },
    {
        label: 'File Type',
        fieldName: 'FileType',
        type: 'text'
    },
    {
        label: 'Published',
        fieldName: 'Publish_Attachments__c',
        type: 'boolean'
    },
    {
        type: 'button',
        typeAttributes: {
            label: { fieldName: 'buttonLabel' },
            name: 'togglePublish',
            variant: 'neutral'
        }
    }
];

export default class AttachmentPublish extends LightningElement {
    @api recordId;

    files = [];
    columns = COLUMNS;
    wiredResult;

    @wire(getFiles, { recordId: '$recordId' })
    wiredFiles(result) {
        this.wiredResult = result;

        if (result.data) {
            this.files = result.data.map(file => ({
                ...file,
                buttonLabel: file.Publish_Attachments__c
                    ? 'Unpublish'
                    : 'Publish'
            }));
        } else if (result.error) {
            console.error(result.error);
        }
    }

    handleRowAction(event) {
        const row = event.detail.row;

        updatePublishStatus({
            contentVersionId: row.Id,
            isPublished: !row.Publish_Attachments__c
        })
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: !row.Publish_Attachments__c
                        ? 'Attachment published successfully'
                        : 'Attachment unpublished successfully',
                    variant: 'success'
                })
            );

            return refreshApex(this.wiredResult);
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        });
    }
}