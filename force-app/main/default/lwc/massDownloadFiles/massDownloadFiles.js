import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchRelatedFiles from '@salesforce/apex/MassDownloadFilesController.fetchRelatedFiles';  
import { NavigationMixin } from 'lightning/navigation';

export default class MassDownloadFiles extends NavigationMixin ( LightningElement ) {
    
    @api recordId;

    @api invoke() {

        fetchRelatedFiles( { strRecordId : this.recordId } )    
            .then( result => {  
                
                console.log( 'result is', JSON.stringify( result ) );
                if ( result.length > 0 ) {

                    let filesDownloadUrl = '/sfc/servlet.shepherd/version/download';

                    result.forEach( item => {
                        filesDownloadUrl += '/' + item
                    });

                    console.log( 'filesDownloadUrl is', filesDownloadUrl );

                    this[ NavigationMixin.Navigate ]( {
                        type: 'standard__webPage',
                        attributes: {
                            url: filesDownloadUrl
                        }
                    }, false );

                    this.dispatchEvent(
                        new ShowToastEvent( {
                            title: 'File(s) Download',
                            message: 'File(s) Download Successfully!!!',
                            variant: 'success'
                        } ),
                    );
                    setTimeout(() => { document.location.reload(); }, 1000);
                } else {

                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'File(s) Download',
                            message: 'File(s) Download failed!!!',
                            variant: 'error'
                        }),
                    );

                }
    
            } )  
            .catch( error => {  

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'File(s) Download Failed',
                        message: 'System Error Occurred',
                        variant: 'error'
                    }),
                );
    
            } );   

    }

}