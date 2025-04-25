import { LightningElement , track,wire,api} from 'lwc';
import {CurrentPageReference} from 'lightning/navigation';
import getValidatedCustomerDetail from '@salesforce/apex/CLA_ValidateCreditLineCustLwcController.getValidatedCustomerDetail';
import updateCreditLineCustomer from '@salesforce/apex/CLA_ValidateCreditLineCustLwcController.updateCreditLineCustomer';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';

const columns = [ { label: 'Name', fieldName: 'name',wrapText:true},
                  { label: 'Registration Number', fieldName: 'registrationNumber',wrapText:true},
                  { label: 'Credit Bureau Id', fieldName: 'creditBureauId',wrapText:true},
                  { label: 'Address', fieldName: 'address',wrapText:true} 
                ]; 


export default class CLA_ValidateCreditLineCustomerLWC  extends NavigationMixin(LightningElement){

    error;
    @track columns = columns;
    @wire(CurrentPageReference)
    currentPageReference;
    resultData = [];
    showTable = false;
    showError = false;
    showSpinner = true;
    errorMessage = 'Customer Data is not available.'; 
    currentSelectedRowCreditBureauId = '';
    selectedRows = [];
   
    connectedCallback(){  
       getValidatedCustomerDetail({sRecordId : this.currentPageReference.state.recordId})
		.then(result => {
            if(result != null || result != undefined){
                let resultParse  = JSON.parse(result);
                this.flattenResponse(resultParse);
                this.showTable = true;
                if( this.resultData.length === 1){
                    this.selectedRows.push(this.resultData[0].creditBureauId);
                }
                this.showSpinner = false;
            }
            else{
                this.showError = true;
                this.showSpinner = false;
            }
        })
		.catch(error => {
            this.error = error;
            this.showError = true;
            this.showSpinner = false;
		})
    }

    flattenResponse(resultParse){

        let rsultDataTemp = [];
        for(let x of resultParse){
              let tempObj = {}
              tempObj.name = x.name;
              tempObj.registrationNumber = x.registrationNumber;
              tempObj.creditBureauId = x.creditBureauId;
              for(let address of x.addresses){
                 if(address.addressType == 'Main'){
                    tempObj.address = '';
                    if(address.addressLine1 != undefined && address.addressLine1 != '' && address.addressLine1 != 'Unknown'){
                        tempObj.address += address.addressLine1;
                    }
                    if(address.addressLine1 != undefined && address.addressLine1 != '' && address.addressLine1 != 'Unknown' && 
                       address.city != undefined && address.city != '' && address.city != 'Unknown'){
                        tempObj.address += ', '+address.city;
                    }
                    if( ( address.addressLine1 != undefined || address.addressLine1 != '' || address.addressLine1 != 'Unknown' )  && 
                          address.city != undefined && address.city != '' && address.city != 'Unknown'){
                         tempObj.address += address.city;
                     }

                    break;
                 }
              }
              rsultDataTemp.push(tempObj);
        }

        this.resultData = [... rsultDataTemp];
        console.log(' this.resultData ==> '+JSON.stringify(this.resultData));

    }

    handleRowSelection(event){
      let selectedRows=event.detail.selectedRows;
      this.currentSelectedRowCreditBureauId = selectedRows[0].creditBureauId;
     
      /*let selectedRows=event.detail.selectedRows;
      if(event.detail.config.action == 'selectAllRows' && selectedRows.length > 1){
        let el = this.template.querySelector('lightning-datatable');
        this.showNotification('Info','Only one row can be selected','warning','pester');
        el.selectedRows = [];
      }
 
     
      if(selectedRows.length == 1){
         this.currentSelectedRowCreditBureauId = selectedRows[0].creditBureauId;
       }
      if(event.detail.config.action != 'selectAllRows' && selectedRows.length>1)
      {
          let el = this.template.querySelector('lightning-datatable');
          el.selectedRows = el.selectedRows.filter(item => item !== this.currentSelectedRowCreditBureauId)
          this.currentSelectedRowCreditBureauId =  el.selectedRows[0]; 
          //this.showNotification('Info','Only one row can be selected','warning','pester');
          event.preventDefault();
          return;
      }
    */
    }



    handleValidate(){
        
        updateCreditLineCustomer({sRecordId : this.currentPageReference.state.recordId , sCreditBureauId : this.currentSelectedRowCreditBureauId})
		.then(result => {
            this.showNotification('Success','Validatation Success','success','dismissable');
            this.dispatchEvent(new CloseActionScreenEvent());
            notifyRecordUpdateAvailable([{recordId: this.currentPageReference.state.recordId}]);

        })
		.catch(error => {
            this.showNotification('Error',error.body.message,'error','dismissable');
            this.dispatchEvent(new CloseActionScreenEvent());
		})

    }

    showNotification(title,message,variant,mode) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(event);
    }


    
}