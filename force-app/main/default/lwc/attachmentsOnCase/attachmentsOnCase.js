import filterAttachmentsAdapter from '@salesforce/apex/AttachmentsOnCaseController.filterAttachments';
import { NavigationMixin } from 'lightning/navigation';
import { LightningElement, api, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { sortBy } from './sortHelper';

const headers = [
    { 
        label: 'Name', 
        fieldName: 'fileLink',
        type : 'button',
        typeAttributes: {
            label: { 
                fieldName: 'fileName' 
                }, 
            variant: 'base'
        },
        wrapText : true,
        sortable: false,
        cellAttributes: { alignment: 'left' }
    },
    {
        label: 'Size (KB)', fieldName: 'sizeInKB', 
        sortable: true, type : 'number',
        cellAttributes: { alignment: 'left' } 
    },
    {
        label: 'Created Date', fieldName : 'createdDate', type:'date', 
        sortable: true, 
        cellAttributes: { alignment: 'left' }
    }
];
export default class AttachmentsOnCase extends NavigationMixin(LightningElement) {
    @api recordId;
    filteredAttachments;
    columns = headers;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    selectedMinSize = '100';
    totalAttachments = 0;
    error;

    @wire(filterAttachmentsAdapter, {caseId : '$recordId', greaterThanKBs : '$selectedMinSize'}) 
    wiredFilteredAttachments({error, data}){
        if (error) {
            this.error = 'Error ';
            if (Array.isArray(error.body)) {
                this.error = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                this.error = error.body.message;
            }
            this.filteredAttachments = undefined;
        } else {
            this.filteredAttachments = data;
        }
    }

    @wire(filterAttachmentsAdapter, {caseId : '$recordId', greaterThanKBs : '0' }) 
    wiredTotalAttachments({error, data}){
        if (error) {
            this.error = 'Error';
            if (Array.isArray(error.body)) {
                this.error = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                this.error = error.body.message;
            }
        } else if (data) {
            this.totalAttachments = data.length;
        }
    }
    

    handleRowAction(event){
        const fileRef =  event.detail.row.fileRef; 
        if (event.detail.row.isClassicAttachment){
            window.open('/servlet/servlet.FileDownload?file='+fileRef);
        } else {
            this[NavigationMixin.Navigate]({  
                type: 'standard__namedPage',  
                attributes: {
                    pageName: 'filePreview'
                },
                state : {
                    selectedRecordId:fileRef
                }  
            })
        } 
    }
    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.filteredAttachments];

        cloneData.sort(sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.filteredAttachments = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }
    onSizeChange(event){
        console.log(event);
        this.selectedMinSize = event.detail.value;
        return refreshApex(this.filteredAttachments);
    }
    get sizeOptions() {
        return [
            { label: 'All', value: '0' },
            { label: '> 10 KB', value: '10' },
            { label: '> 100 KB', value: '100' },
            { label: '> 1 MB', value: '1024' }
        ];
    }
    handleUploadFinished(event){
        //temp to reload the page after upload
        //next veersion will be to use refreshApex to trigger comoponent reload
        window.location.reload();
    }
}