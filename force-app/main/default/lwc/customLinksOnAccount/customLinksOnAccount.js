import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = ['Account.Name'];

export default class CustomLinksOnAccount extends LightningElement {
    @api recordId; 
    selectedAccountName;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredAccount({ error, data }) {
        if (data) {
            this.selectedAccountName = data.fields.Name.value;
        } else if (error) {
        }
    }

    get googleNewsUrl() {
        return `https://news.google.com/search?q=${encodeURIComponent(this.selectedAccountName)}`;
    }

    get googleSearchUrl() {
        return `https://www.google.com/search?q=${encodeURIComponent(this.selectedAccountName)}`;
    }

    handleGoogleNewsRedirect(event) {
        event.preventDefault();
        const userConfirmedNews = window.confirm(
            `You’re being redirected to: ${this.googleNewsUrl}\n\nDo you want to leave this page?`
        );
        if (userConfirmedNews) {
            window.open(this.googleNewsUrl, '_blank');
        }
    }

    handleGoogleSearchRedirect(event) {
        event.preventDefault();
        const userConfirmedSearch = window.confirm(
            `You’re being redirected to: ${this.googleSearchUrl}\n\nDo you want to leave this page?`
        );
        if (userConfirmedSearch) {
            window.open(this.googleSearchUrl, '_blank');
        }
    }
    get googleMapsUrl() {
        return `https://www.google.com/maps?q=${encodeURIComponent(this.selectedAccountName)}`;
    }
    handleGoogleMapsRedirect(event) {
    event.preventDefault(); // Stop default link action
    
    const userConfirmed = window.confirm(
        `You’re being redirected to: ${this.googleMapsUrl}\n\nDo you want to leave this page?`
    );
    
    if (userConfirmed) {
        window.open(this.googleMapsUrl, '_blank');
    }
    }
}