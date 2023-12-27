import { LightningElement , api} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class NavigateToRecordFromFlow extends NavigationMixin(LightningElement) {
    @api recordId;
    
    handleClick(event) {
        const recordId = event.currentTarget.dataset.id;

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                actionName: 'view'
            }
        });
    }
}