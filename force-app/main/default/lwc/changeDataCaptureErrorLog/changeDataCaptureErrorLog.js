import { LightningElement, api, track } from 'lwc';
import getLatestRelevantError from '@salesforce/apex/ChangeDataCaptureErrorLogController.getLatestRelevantError';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ChangeDataCaptureErrorLog extends LightningElement {
    @api recordId;
    @api objectApiName;

    @track loading = true;
    @track error;
    @track data = { found: false, errors: [] };

    columns = [
        {
            label: 'Error Log Name',
            fieldName: 'errorLogLink',
            type: 'url',
            typeAttributes: {
                label: { fieldName: 'errorLogName' },
                target: '_blank'
            },
            sortable: true,
            initialWidth: 180
        },
        {
            label: 'Error Message',
            fieldName: 'errorMessage',
            type: 'text',
            wrapText: true
        },
        {
            label: 'Associated Record',
            fieldName: 'associatedRecordLink',
            type: 'url',
            typeAttributes: {
                label: { fieldName: 'associatedRecordName' },
                target: '_blank'
            }
        },
        {
            label: 'Object Type',
            fieldName: 'associatedSObjectType',
            type: 'text',
            initialWidth: 160
        },
        {
            label: 'Created Date',
            fieldName: 'errorCreatedDate',
            type: 'date',
            typeAttributes: {
                year: 'numeric',
                month: 'short',
                day: '2-digit',
                hour: '2-digit',
                minute: '2-digit'
            },
            initialWidth: 180
        }
    ];

    connectedCallback() {
        this.fetchErrors();
    }

    fetchErrors() {
        console.log('fetch errors');
        this.loading = true;
        this.error = null;

        getLatestRelevantError({ recordId: this.recordId, objectApiName: this.objectApiName })
            .then((res) => {
                console.log('response called');
                console.log('response => '+JSON.stringify(res));
                this.loading = false;
                if (res && Array.isArray(res.errors)) {
                    const enhanced = res.errors.map(e => ({
                        ...e,
                        associatedRecordLink: e.associatedRecordId ? '/' + e.associatedRecordId : '#',
                        associatedRecordName: e.associatedRecordName || e.associatedRecordId,
                        errorLogLink: e.errorLogId ? '/' + e.errorLogId : '#',
                        errorLogName: e.errorLogName || 'Error Log'
                    }));

                    this.data = {
                        found: res.found === true || enhanced.length > 0,
                        errors: enhanced
                    };

                    if (enhanced.length > 0) {
                        this.showToast('Success', 'Error logs loaded successfully.', 'success');
                    } else {
                        this.showToast('Info', 'No recent CDC errors found.', 'info');
                    }
                } else {
                    this.data = { found: false, errors: [] };
                    this.showToast('Info', 'No recent CDC errors found.', 'info');
                }
            })
            .catch((err) => {
                this.loading = false;
                this.error = err;
                this.data = { found: false, errors: [] };
                this.showToast('Error', 'Failed to fetch CDC errors.', 'error');
                console.error('Error fetching logs', err);
            });
    }

    get hasErrors() {
        return this.data && Array.isArray(this.data.errors) && this.data.errors.length > 0;
    }

    get noErrors() {
        return !this.loading && !this.hasErrors;
    }

    handleRefresh() {
        this.fetchErrors();
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }
}