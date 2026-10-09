import { LightningElement, wire } from 'lwc';
import {IsConsoleNavigation,getFocusedTabInfo, openSubtab,setTabLabel,setTabIcon} from 'lightning/platformWorkspaceApi';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { deleteRecord } from 'lightning/uiRecordApi';
import getAllAttachments from '@salesforce/apex/AttachmentsOnCaseController.getAllAttachments';
import updateFileDetails from '@salesforce/apex/AttachmentsOnCaseController.updateFileDetails';
import uploadNewFileVersion from '@salesforce/apex/AttachmentsOnCaseController.uploadNewFileVersion';
import removeFileFromRecord from '@salesforce/apex/AttachmentsOnCaseController.removeFileFromRecord';
import { refreshApex } from '@salesforce/apex';

const actions = [
{ label: 'View File', name: 'view' },
{ label: 'Edit File Details', name: 'editDetails' },
{ label: 'Upload New Version', name: 'uploadVersion' },
{ label: 'Delete', name: 'delete' },
{ label: 'Remove from Record', name: 'remove' }
];

const DEFAULT_COLUMNS = [
{
    label: 'S.No',
    fieldName: 'rowNumber',
    type: 'number',
    initialWidth: 20,
    cellAttributes: {
        alignment: 'left'
    }
},
{
    label: 'Title',
    fieldName: 'fileUrl',
    type: 'url',
    sortable: true,
    initialWidth: 320,
    typeAttributes: {
        label: { fieldName: 'fileName' },
        target: '_self'
    },
    cellAttributes: {
        iconName: { fieldName: 'fileIcon' },
        iconPosition: 'left'
    }
},
{
    label: 'Last Modified',
    fieldName: 'LastModifiedDate',
    type: 'date',
    sortable: true,
    initialWidth: 120,
    typeAttributes: {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit',
        timeZone: 'Europe/Paris',
        hour12: false
    }
},
{
    label: 'Created By',
    fieldName: 'createdByUrl',
    type: 'url',
    sortable: true,
    initialWidth: 250,
    typeAttributes: {
        label: { fieldName: 'createdByName' }
    }
},
{
    label: 'Content Size',
    fieldName: 'sizeDisplay',
    type: 'text',
    sortable: true,
    initialWidth: 90
},
{
    label: 'Source',
    fieldName: 'sourceUrl',
    type: 'url',
    sortable: true,
    initialWidth: 300,
    typeAttributes: {
        label: { fieldName: 'sourceCase' },
        target: '_self'
    },
    cellAttributes: {
        iconName: { fieldName: 'sourceIcon' },
        iconPosition: 'left'
    }
},
{
    type: 'action',
    initialWidth: 70,
    typeAttributes: {
        rowActions: actions
    }
}
];

export default class ViewAllAttachments extends LightningElement {

recordId;
allAttachments = [];
selectedAttachments = [];
isRefreshing = false;
allAttachmentsOriginal = [];

showQuickFilter = false;

filterTitle = '';
filterType = '';
filterStartDate = '';
filterEndDate = '';
filterCreatedBy = '';
filterFileType = '';
filterFileExtension = '';
filterSource = '';
filterAssetFile = '';
showEditFileModal = false;

editFileId = null;
editFileTitle = '';
editOriginalFileTitle = '';
editFileExtension = '';
editIsClassicAttachment = false;
editFileDescription = '';
editFileCreatedDate = null;
editFileLastModifiedDate = null;

isSavingFileDetails = false;
showUploadVersionModal = false;

versionFileId = null;
versionFileTitle = '';
versionFileExtension = '';

selectedVersionFile = null;
versionDescription = '';

isUploadingVersion = false;
columns = DEFAULT_COLUMNS.map(column => ({
    ...column
}));

showDatatable = true;
disableResetColumnWidths = true;
isResettingColumnWidths = false;

wiredAttachmentsResult;
sortedBy = 'LastModifiedDate';
sortDirection = 'desc';

@wire(CurrentPageReference)
getStateParameters(pageRef) {
    if (pageRef) {
        this.recordId = pageRef.state.c__recordId;
    }
}

@wire(IsConsoleNavigation)
async wiredConsoleNavigation({ data, error }) {

    if (error) {
        console.error(
            'Error checking console navigation:',
            JSON.stringify(error)
        );
        return;
    }

    if (!data) {
        return;
    }

    try {
        const tabInfo = await getFocusedTabInfo();

        console.log(
            'Focused Tab Info:',
            JSON.stringify(tabInfo)
        );

        await setTabLabel(
            tabInfo.tabId,
            'Attachments'
        );

        await setTabIcon(
            tabInfo.tabId,
            'standard:file',
            {
                iconAlt: 'Attachments'
            }
        );

    } catch (error) {
        console.error(
            'Error updating Attachments tab:',
            error
        );
    }
}

getFileIcon(fileExtension) {

    if (!fileExtension) {
        return 'doctype:unknown';
    }

    const ext = fileExtension.toLowerCase();

    switch (ext) {

        case 'xls':
        case 'xlsx':
            return 'doctype:excel';

        case 'doc':
        case 'docx':
            return 'doctype:word';

        case 'pdf':
            return 'doctype:pdf';

        case 'ppt':
        case 'pptx':
            return 'doctype:ppt';

        case 'png':
        case 'jpg':
        case 'jpeg':
        case 'gif':
        case 'bmp':
            return 'doctype:image';

        case 'csv':
            return 'doctype:csv';

        case 'txt':
            return 'doctype:txt';

        case 'zip':
        case 'rar':
        case '7z':
            return 'doctype:zip';

        case 'xml':
            return 'doctype:xml';

        case 'html':
        case 'htm':
            return 'doctype:html';

        default:
            return 'doctype:unknown';
    }
}

@wire(getAllAttachments, { caseId: '$recordId' })
wiredAttachments(result) {

    this.wiredAttachmentsResult = result;

    const { error, data } = result;
    if (data) {
        let records = data.map(item => {

            const fileIcon =
                this.getFileIcon(
                    item.fileExtension
                );

            const sourceIcon =
                item.sourceType === 'EmailMessage'
                    ? 'standard:email'
                    : 'standard:case';

            return {
                ...item,

                fileIcon: fileIcon,
                sourceIcon: sourceIcon,

                fileUrl:
                    '/lightning/r/ContentDocument/' +
                    item.fileRef +
                    '/view',

                createdByUrl:
                    '/lightning/r/User/' +
                    item.createdById +
                    '/view',

                sourceUrl:
                    item.sourceType === 'EmailMessage'
                        ? '/lightning/r/EmailMessage/' +
                            item.sourceId +
                            '/view'
                        : '/lightning/r/Case/' +
                            item.sourceId +
                            '/view',

                titleSort:
                    item.fileName || '',

                createdBySort:
                    item.createdByName || '',

                sourceSort:
                    item.sourceCase || ''
            };
        });

        records.sort((a, b) => {
            return (
                new Date(b.LastModifiedDate) -
                new Date(a.LastModifiedDate)
            );
        });

        const processedRecords = records.map((record, index) => {
return {
    ...record,
    rowNumber: index + 1
};
});

this.allAttachmentsOriginal = [...processedRecords];
this.allAttachments = [...processedRecords];
        console.log(
            'Processed attachments:',
            JSON.stringify(
                this.allAttachments
            )
        );

    } else if (error) {

    }
}

handleRowSelection(event) {

    this.selectedAttachments =
        event.detail.selectedRows;
}

handleRowAction(event) {

    const actionName =
        event.detail.action.name;

    const row =
        event.detail.row;

    switch (actionName) {

        case 'view':
            this.viewFile(row);
            break;

        case 'uploadVersion':
            this.openUploadVersionModal(row);
            break;

        case 'download':
            this.downloadFile(row);
            break;
        case 'editDetails':
            this.openEditFileModal(row);
            break;
        case 'details':
            this.viewDetails(row);
            break;

        case 'delete':
            this.deleteFile(row);
            break;

        case 'remove':
            this.removeFromRecord(row);
            break;

        default:
            break;
    }
}

async viewFile(row) {

try {

    const tabInfo = await getFocusedTabInfo();

    const parentTabId = tabInfo.isSubtab
        ? tabInfo.parentTabId
        : tabInfo.tabId;

    await openSubtab(parentTabId, {
        pageReference: {
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state: {
                recordIds: row.fileRef,
                selectedRecordId: row.fileRef
            }
        },
        focus: true,
        label: row.fileName,
        icon: 'standard:file',
        iconAlt: 'File'
    });

} catch (error) {

}
}    async deleteFile(row) {

    try {

        if (!row.fileRef) {
            throw new Error(
                'File Id is missing.'
            );
        }

        await deleteRecord(
            row.fileRef
        );

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message:
                    `${row.fileName} deleted successfully.`,
                variant: 'success'
            })
        );

        await refreshApex(
            this.wiredAttachmentsResult
        );

    } catch (error) {


        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message:
                    error.body?.message ||
                    error.message ||
                    'Unable to delete the file.',
                variant: 'error'
            })
        );
    }
}

async removeFromRecord(row) {

    if (row.isClassicAttachment) {

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Not Available',
                message:
                    'Remove from Record is available only for Salesforce Files.',
                variant: 'warning'
            })
        );

        return;
    }

    try {
        await removeFileFromRecord({
            contentDocumentId:
                row.fileRef,
            caseId:
                this.recordId
        });

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message:
                    `${row.fileName} was removed from this Case.`,
                variant: 'success'
            })
        );

        await refreshApex(
            this.wiredAttachmentsResult
        );

    } catch (error) {

        console.error(
            'Error removing file:',
            error
        );

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message:
                    error.body?.message ||
                    error.message ||
                    'Unable to remove the file from this Case.',
                variant: 'error'
            })
        );
    }
}

downloadSelectedAttachments() {

    if (
        !this.selectedAttachments ||
        this.selectedAttachments.length === 0
    ) {

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'No Files Selected',
                message:
                    'Please select at least one attachment to download.',
                variant: 'error',
                mode: 'sticky'
            })
        );

        return;
    }

    this.selectedAttachments.forEach(
        file => {

            const iframe =
                document.createElement(
                    'iframe'
                );

            iframe.style.display =
                'none';

            iframe.src =
                '/sfc/servlet.shepherd/document/download/' +
                file.fileRef;

            document.body.appendChild(
                iframe
            );

            setTimeout(() => {
                iframe.remove();
            }, 5000);
        }
    );

    this.dispatchEvent(
        new ShowToastEvent({
            title: 'Download Started',
            message:
                `${this.selectedAttachments.length} file(s) are being downloaded.`,
            variant: 'success',
        })
    );

    this.selectedAttachments = [];

    const datatable =
        this.template.querySelector(
            'lightning-datatable'
        );

    if (datatable) {
        datatable.selectedRows = [];
    }
}

async handleUploadFinished(event) {

    const uploadedFiles =
        event.detail.files;

    try {

        await refreshApex(
            this.wiredAttachmentsResult
        );

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Upload Successful',
                message:
                    uploadedFiles.length +
                    ' file(s) uploaded.',
                variant: 'success'
            })
        );

    } catch (error) {

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Refresh Error',
                message:
                    error.body?.message ||
                    error.message ||
                    'File uploaded, but attachment list could not be refreshed.',
                variant: 'warning'
            })
        );
    }
}

handleSort(event) {

    const fieldName =
        event.detail.fieldName;

    const sortDirection =
        event.detail.sortDirection;

    this.sortedBy =
        fieldName;

    this.sortDirection =
        sortDirection;

    let actualSortField =
        fieldName;

    switch (fieldName) {

        case 'fileUrl':
            actualSortField =
                'fileName';
            break;

        case 'createdByUrl':
            actualSortField =
                'createdByName';
            break;

        case 'sourceUrl':
            actualSortField =
                'sourceCase';
            break;

        case 'sizeDisplay':
            actualSortField =
                'sizeDisplay';
            break;

        case 'LastModifiedDate':
            actualSortField =
                'LastModifiedDate';
            break;

        default:
            actualSortField =
                fieldName;
    }

    const sortedData = [
        ...this.allAttachments
    ];

    sortedData.sort((a, b) => {

        let valueA =
            a[actualSortField];

        let valueB =
            b[actualSortField];

        if (
            valueA === null ||
            valueA === undefined
        ) {
            valueA = '';
        }

        if (
            valueB === null ||
            valueB === undefined
        ) {
            valueB = '';
        }

        if (
            actualSortField ===
            'LastModifiedDate'
        ) {

            valueA =
                valueA
                    ? new Date(valueA).getTime()
                    : 0;

            valueB =
                valueB
                    ? new Date(valueB).getTime()
                    : 0;

        } else {

            valueA =
                String(valueA)
                    .toLowerCase();

            valueB =
                String(valueB)
                    .toLowerCase();
        }

        let comparison = 0;

        if (valueA > valueB) {
            comparison = 1;
        } else if (valueA < valueB) {
            comparison = -1;
        }

        return sortDirection === 'asc'
            ? comparison
            : -comparison;
    });

    this.allAttachments =
        sortedData.map(
            (record, index) => {
                return {
                    ...record,
                    rowNumber:
                        index + 1
                };
            }
        );
}

async handleRefresh() {

if (!this.wiredAttachmentsResult) {
    return;
}

try {
    this.isRefreshing = true;
    await refreshApex(this.wiredAttachmentsResult);
} catch (error) {

    console.error(
        'Error refreshing attachments:',
        error
    );

    this.dispatchEvent(
        new ShowToastEvent({
            title: 'Refresh Failed',
            message:
                error.body?.message ||
                error.message ||
                'Unable to refresh attachments.',
            variant: 'error'
        })
    );

} finally {
    this.isRefreshing = false;
}
}
get fileTypeOptions() {

return [
    { label: 'All', value: '' },
    { label: 'Excel', value: 'excel' },
    { label: 'Word', value: 'word' },
    { label: 'PDF', value: 'pdf' },
    { label: 'PowerPoint', value: 'powerpoint' },
    { label: 'Image', value: 'image' },
    { label: 'CSV', value: 'csv' },
    { label: 'Text', value: 'text' },
    { label: 'ZIP', value: 'zip' }
];
}
get tableContainerClass() {
return this.showQuickFilter
    ? 'table-with-filter'
    : 'table-full-width';
}
toggleQuickFilter() {
this.showQuickFilter = !this.showQuickFilter;
}

handleFilterTitleChange(event) {
this.filterTitle = event.target.value;
}

handleFilterTypeChange(event) {
this.filterType = event.target.value;
}

handleStartDateChange(event) {
this.filterStartDate = event.target.value;
}

handleEndDateChange(event) {
this.filterEndDate = event.target.value;
}

handleCreatedByChange(event) {
this.filterCreatedBy = event.target.value;
}

handleFileTypeChange(event) {
this.filterFileType = event.detail.value;
}

handleFileExtensionChange(event) {
this.filterFileExtension = event.target.value;
}

handleSourceChange(event) {
this.filterSource = event.target.value;
}
applyQuickFilter() {

let filtered = [
    ...this.allAttachmentsOriginal
];


// Title
if (this.filterTitle) {

    const value =
        this.filterTitle
            .toLowerCase()
            .trim();

    filtered = filtered.filter(item =>
        (item.fileName || '')
            .toLowerCase()
            .includes(value)
    );
}


// Type
if (this.filterType) {

    const value =
        this.filterType
            .toLowerCase()
            .trim();

    filtered = filtered.filter(item =>
        (item.sourceType || '')
            .toLowerCase()
            .includes(value)
    );
}


// Created By
if (this.filterCreatedBy) {

    const value =
        this.filterCreatedBy
            .toLowerCase()
            .trim();

    filtered = filtered.filter(item =>
        (item.createdByName || '')
            .toLowerCase()
            .includes(value)
    );
}


// File Extension
if (this.filterFileExtension) {

    const value =
        this.filterFileExtension
            .toLowerCase()
            .trim()
            .replace('.', '');

    filtered = filtered.filter(item =>
        (item.fileExtension || '')
            .toLowerCase() === value
    );
}


// Source
if (this.filterSource) {

    const value =
        this.filterSource
            .toLowerCase()
            .trim();

    filtered = filtered.filter(item =>
        (item.sourceCase || '')
            .toLowerCase()
            .includes(value)
    );
}


// Last Modified Start Date
if (this.filterStartDate) {

    const startDate =
        new Date(
            this.filterStartDate +
            'T00:00:00'
        );

    filtered = filtered.filter(item =>
        new Date(
            item.LastModifiedDate
        ) >= startDate
    );
}


// Last Modified End Date
if (this.filterEndDate) {

    const endDate =
        new Date(
            this.filterEndDate +
            'T23:59:59.999'
        );

    filtered = filtered.filter(item =>
        new Date(
            item.LastModifiedDate
        ) <= endDate
    );
}


// File Type
if (this.filterFileType) {

    filtered = filtered.filter(item => {

        const ext =
            (item.fileExtension || '')
                .toLowerCase();

        switch (this.filterFileType) {

            case 'excel':
                return [
                    'xls',
                    'xlsx'
                ].includes(ext);

            case 'word':
                return [
                    'doc',
                    'docx'
                ].includes(ext);

            case 'pdf':
                return ext === 'pdf';

            case 'powerpoint':
                return [
                    'ppt',
                    'pptx'
                ].includes(ext);

            case 'image':
                return [
                    'png',
                    'jpg',
                    'jpeg',
                    'gif',
                    'bmp'
                ].includes(ext);

            case 'csv':
                return ext === 'csv';

            case 'text':
                return ext === 'txt';

            case 'zip':
                return [
                    'zip',
                    'rar',
                    '7z'
                ].includes(ext);

            default:
                return true;
        }
    });
}

if (this.filterAssetFile === 'checked') {
    filtered = filtered.filter(item =>
        item.isAssetEnabled === true
    );

} else if (
    this.filterAssetFile === 'notChecked'
) {

    filtered = filtered.filter(item =>
        item.isAssetEnabled === false
    );
}


this.allAttachments =
    filtered.map(
        (record, index) => ({
            ...record,
            rowNumber: index + 1
        })
    );
}

clearQuickFilter() {

this.filterTitle = '';
this.filterType = '';
this.filterStartDate = '';
this.filterEndDate = '';
this.filterCreatedBy = '';
this.filterFileType = '';
this.filterFileExtension = '';
this.filterSource = '';
this.filterAssetFile = '';

this.allAttachments =
    this.allAttachmentsOriginal.map(
        (record, index) => ({
            ...record,
            rowNumber: index + 1
        })
    );
}

handleColumnResize(event) {

if (this.isResettingColumnWidths) {
    return;
}
this.disableResetColumnWidths = false;
}
handleListViewControl(event) {

    const selectedAction =
        event.detail.value;

    if (
        selectedAction ===
        'resetWidths'
    ) {

        this.resetColumnWidths();
    }
}

resetColumnWidths() {

this.isResettingColumnWidths = true;
this.showDatatable = false;

this.columns = DEFAULT_COLUMNS.map(column => ({
    ...column
}));

requestAnimationFrame(() => {

    this.showDatatable = true;

    requestAnimationFrame(() => {

        this.isResettingColumnWidths = false;

        this.disableResetColumnWidths = true;
    });
});
}
get attachmentCount() {

    return this.allAttachments
        ? this.allAttachments.length
        : 0;
}

get assetFileOptions() {

return [
    {
        label: 'Checked',
        value: 'checked'
    },
    {
        label: 'Not Checked',
        value: 'notChecked'
    }
];
}
handleAssetFileChange(event) {

this.filterAssetFile =
    event.detail.value;
}
openEditFileModal(row) {

this.editFileId =
    row.fileRef;

this.editFileTitle =
    row.fileName || '';

this.editOriginalFileTitle =
    row.fileName || '';

this.editFileDescription =
    row.description || '';

this.editFileCreatedDate =
    row.createdDateTime;

this.editFileLastModifiedDate =
    row.LastModifiedDate;

this.editFileExtension =
    row.fileExtension || '';

this.editIsClassicAttachment =
    row.isClassicAttachment === true;

this.showEditFileModal = true;
}
handleEditDescriptionChange(event) {

this.editFileDescription =
    event.target.value;
}

handleEditFileTitleChange(event) {

this.editFileTitle =
    event.target.value;
}
closeEditFileModal() {

if (this.isSavingFileDetails) {
    return;
}

this.resetEditFileModal();
}
resetEditFileModal() {

this.showEditFileModal = false;

this.editFileId = null;
this.editFileTitle = '';
this.editOriginalFileTitle = '';
this.editFileDescription = '';

this.editFileCreatedDate = null;
this.editFileLastModifiedDate = null;

this.editFileExtension = '';
this.editIsClassicAttachment = false;
}
async saveFileDetails() {

const newTitle =
    this.editFileTitle
        ? this.editFileTitle.trim()
        : '';

if (!newTitle) {

    this.dispatchEvent(
        new ShowToastEvent({
            title: 'Title Required',
            message:
                'Please enter a file title.',
            variant: 'error'
        })
    );

    return;
}

try {

    this.isSavingFileDetails = true;

    await updateFileDetails({
        fileId:
            this.editFileId,

        newTitle:
            newTitle,

        description:
            this.editFileDescription,

        isClassicAttachment:
            this.editIsClassicAttachment
    });

    this.dispatchEvent(
        new ShowToastEvent({
            title: 'Success',
            message:
                'File details updated successfully.',
            variant: 'success',
            mode: 'dismissible'
        })
    );

    this.resetEditFileModal();

    await refreshApex(
        this.wiredAttachmentsResult
    );

} catch (error) {

    console.error(
        'Error updating file details:',
        error
    );

    this.dispatchEvent(
        new ShowToastEvent({
            title: 'Unable to Update File',
            message:
                error.body?.message ||
                error.message ||
                'Unable to update file details.',
            variant: 'error',
            mode: 'sticky'
        })
    );

} finally {

    this.isSavingFileDetails = false;
}
}
openUploadVersionModal(row) {

if (row.isClassicAttachment) {

    this.dispatchEvent(
        new ShowToastEvent({
            title: 'Not Available',
            message:
                'Upload New Version is available only for Salesforce Files.',
            variant: 'warning'
        })
    );

    return;
}

this.versionFileId =
    row.fileRef;

this.versionFileTitle =
    row.fileName || '';

this.versionFileExtension =
    row.fileExtension || '';

this.selectedVersionFile = null;
this.versionDescription = '';

this.showUploadVersionModal = true;
}
handleVersionFileSelected(event) {

const files =
    event.target.files;

if (!files || files.length === 0) {
    this.selectedVersionFile = null;
    return;
}

this.selectedVersionFile =
    files[0];

}
handleVersionDescriptionChange(event) {

this.versionDescription =
    event.target.value;
}
closeUploadVersionModal() {

if (this.isUploadingVersion) {
    return;
}

this.resetUploadVersionModal();
}
resetUploadVersionModal() {

this.showUploadVersionModal = false;

this.versionFileId = null;
this.versionFileTitle = '';
this.versionFileExtension = '';

this.selectedVersionFile = null;
this.versionDescription = '';
}
readFileAsBase64(file) {

return new Promise((resolve, reject) => {

    const reader =
        new FileReader();

    reader.onload = () => {

        const result =
            reader.result;

        const base64 =
            result.split(',')[1];

        resolve(base64);
    };

    reader.onerror = () => {
        reject(reader.error);
    };

    reader.readAsDataURL(file);
});
}
async handleUploadNewVersion() {

if (!this.selectedVersionFile) {

    this.dispatchEvent(
        new ShowToastEvent({
            title: 'File Required',
            message:
                'Please select a file to upload.',
            variant: 'error'
        })
    );

    return;
}

try {

    this.isUploadingVersion = true;

    const base64Data =
        await this.readFileAsBase64(
            this.selectedVersionFile
        );

    await uploadNewFileVersion({

        contentDocumentId:
            this.versionFileId,

        fileName:
            this.selectedVersionFile.name,

        base64Data:
            base64Data,

        reasonForChange:
            this.versionDescription
    });

    this.dispatchEvent(
        new ShowToastEvent({
            title: 'Success',
            message:
                'New file version uploaded successfully.',
            variant: 'success',
            mode: 'dismissible'
        })
    );

    this.resetUploadVersionModal();

    await refreshApex(
        this.wiredAttachmentsResult
    );

} catch (error) {

    console.error(
        'Upload New Version Error:',
        error
    );

    this.dispatchEvent(
        new ShowToastEvent({
            title: 'Upload Failed',
            message:
                error.body?.message ||
                error.message ||
                'Unable to upload the new version.',
            variant: 'error',
            mode: 'sticky'
        })
    );

} finally {

    this.isUploadingVersion = false;
}
}
}