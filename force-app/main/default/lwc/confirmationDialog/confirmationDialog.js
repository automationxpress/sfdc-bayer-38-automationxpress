import { LightningElement, api } from 'lwc';
import Cancel from '@salesforce/label/c.Cancel';

export default class ConfirmationDialog extends LightningElement {
    @api title;
    @api message;
    @api confirmationAction;
    label = {
        Cancel
    };

    handleCancel(){
        const cancelEvent = new CustomEvent('cancel');
        this.dispatchEvent(cancelEvent);
    }

    handleConfirmationAction(){
        const confirmationEvent = new CustomEvent('confirmation');
        this.dispatchEvent(confirmationEvent);

    }
}