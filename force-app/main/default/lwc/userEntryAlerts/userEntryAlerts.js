import { LightningElement, api } from 'lwc';
import doesUserEntryNeedApproval from '@salesforce/apex/UserEntryController.doesUserEntryNeedApproval';
import UserEntryNeedsToBeSubmitted from '@salesforce/label/c.UserEntryNeedsToBeSubmitted';

export default class UserEntryAlerts extends LightningElement {
    @api recordId;
    isNeedApprovalAlertVisible = false;
    label = {
        UserEntryNeedsToBeSubmitted
    };

    connectedCallback() {
        doesUserEntryNeedApproval({ userEntryId: this.recordId })
            .then(result => {
                this.isNeedApprovalAlertVisible = result;
            }).catch(error => {
                console.log(error.body.message);
            });
    }
}