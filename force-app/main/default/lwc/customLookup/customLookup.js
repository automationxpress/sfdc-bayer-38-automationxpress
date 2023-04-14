import { LightningElement, api } from 'lwc';

export default class CustomLookup extends LightningElement {
    @api childObjectApiName;
    @api targetFieldApiName;
    @api value;
    @api required = false;

    handleChange(event) {
        const selectedEvent = new CustomEvent('valueselected', {
            detail: event.detail.value
        });
        this.dispatchEvent(selectedEvent);
    }

    @api isValid() {
        if (this.required) {
            this.template.querySelector('lightning-input-field').reportValidity();
        }
    }
}