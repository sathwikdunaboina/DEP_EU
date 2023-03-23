import { LightningElement, api, track } from 'lwc';
import getDatalist from '@salesforce/apex/QuoteController.getResponseData';
import updateQuote from '@salesforce/apex/QuoteController.updateQuote';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
export default class searchOrCreateQuote extends LightningElement {
 
    @track opportunities = [];
    @track quoteNumber = '';
    @track isdisplaySearchQuote = true;
    @track isdisplaycreatequote = false;

    _recordId;

    @api set recordId(value) {
        this._recordId = value;
        this.getRecords();   
    }

    get recordId() {
        return this._recordId;
    }

    getRecords(){
        getDatalist({ recordId : this._recordId })  //
            .then((result) => {
                if(result.error){
                    this.error = result.error;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: JSON.stringify(error),
                            variant: 'error'
                        })
                    );
                }else{
                    this.opportunities = JSON.parse(result.resdata);
                }
            })
            .catch((error) => {
                this.error = error;
                console.log('error :'+ JSON.stringify(error));
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: JSON.stringify(error),
                        variant: 'error'
                    })
                );
            });
    }

    handleupdatedValue(event){
        this.quoteNumber = event.target.dataset.id;
        console.log('quoteNumber :'+ this.quoteNumber);
        console.log('_recordId :'+ this._recordId);
        updateQuote({ recordId : this._recordId, quoteNumber : this.quoteNumber })  //
                    .then((result) => {
                       this.handleSuccess(event);
                       this.dispatchEvent(new CloseActionScreenEvent());
                       eval("$A.get('e.force:refreshView').fire();");
                    })
                    .catch((error) => {
                        this.error = error;
                        console.log('error :'+ JSON.stringify(error));
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error',
                                message: JSON.stringify(error),
                                variant: 'error'
                            })
                        );
                    });
        
    }

    closePopup(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleSuccess(event) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Opportunity Record Updated!',
                    variant: 'success'
                })
            );
    }
    onClickCreateQuote(){
        this.isdisplaySearchQuote = false;
        this.isdisplaycreatequote = true;

       }
}