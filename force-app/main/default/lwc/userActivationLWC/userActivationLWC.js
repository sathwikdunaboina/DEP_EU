import { LightningElement, track, wire } from 'lwc';
import getUsers from '@salesforce/apex/UserManagementController.getUsers';
import updateUserStatus from '@salesforce/apex/UserManagementController.updateUserStatus';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class UserManagement extends LightningElement {
    @track users = [];
    @track selectedUsers = [];
    selectedUserIds = new Set();
    searchKey = '';

    columns = [
        { label: 'Name', fieldName: 'Name' },
        { label: 'Email', fieldName: 'Email' },
        { label: 'Profile Name', fieldName: 'ProfileName'},
        { label: 'Status', fieldName: 'IsActive', type: 'boolean' }
    ];

    // Fetch users based on search input
    @wire(getUsers, { searchKey: '$searchKey' })
    wiredUsers({ error, data }) {
        if (data) {
            this.users = data.map(user => ({
                ...user,
                ProfileName: user.Profile ? user.Profile.Name : 'N/A',
                _selected: this.selectedUserIds.has(user.Id) // Retain selection
            }));
        } else if (error) {
            this.showToast('Error', 'Error fetching users', 'error');
        }
    }

    handleSearch(event) {
        this.searchKey = event.target.value;
    }

    handleRowSelection(event) {
        const selectedRows = event.detail.selectedRows;
        const deselectedRows = event.detail.config.action;
        console.log(selectedRows,'**selectedRows**');
        console.log(deselectedRows,'**deselectedRows**');
        // if(deselectedRows == 'rowSelect'){
        selectedRows.forEach(user => {
            if (!this.selectedUserIds.has(user.Id)) {
                this.selectedUsers = [...this.selectedUsers, user];
                this.selectedUserIds.add(user.Id);
                // console.log(this.selectedUserIds,'**selectedUserIds**')
            }
        });
        // }
        // if(deselectedRows == 'rowDeselect'){
        //     indexselectedUserIds = this.selectedUserIds.indexOf(event.detail.config.value);
        //         if (indexselectedUserIds !== -1) {
        //             array.splice(indexselectedUserIds, 1);
        //         }
        //     indexselectedUsers = this.selectedUsers.indexOf(event.detail.config.value);
        //         if (indexselectedUsers !== -1) {
        //             array.splice(indexselectedUsers, 1);
        //         }
        // }


        // deselectedRows.forEach(user => {
        //     if (!this.selectedUserIds.has(user.Id)) {
        //         this.selectedUsers = [...this.selectedUsers, user];
        //         this.selectedUserIds.remove(user.Id);
        //         console.log(this.selectedUserIds,'**selectedUserIds**')
        //     }
        // });
    }

    updateUsersStatus(isActive) {
        if (this.selectedUsers.length === 0) {
            this.showToast('Warning', 'Select at least one user', 'warning');
            return;
        }

        const userIds = this.selectedUsers.map(user => user.Id);

        updateUserStatus({ userIds, isActive })
            .then(() => {
                this.showToast('Success', 'User status updated successfully', 'success');
                this.selectedUsers = [];
                this.selectedUserIds.clear();
                //return refreshApex(this.wiredUsers);
                //window.location.reload();
                setTimeout(() => { document.location.reload(); }, 2000);
            })
            .catch(error => {
                this.showToast('Error', 'Error updating users', 'error');
                console.error(error);
            });
    }

    activateUsers() {
        this.updateUsersStatus(true);
    }

    deactivateUsers() {
        this.updateUsersStatus(false);
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}