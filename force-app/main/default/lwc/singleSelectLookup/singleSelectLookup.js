import { LightningElement, api, track, wire } from 'lwc';
import getJobRoleRecords from '@salesforce/apex/UserEntryEditController.getJobRoleRecords';
import getUserEntryData from '@salesforce/apex/UserEntryEditController.getUserEntryData';

export default class SingleSelectLookup extends LightningElement {
    recordsList;
    searchKey = "";
    error;
    message;
    isFieldRequired = true;
    isValid = true;

    @api selectedValue;
    @api selectedRecordId;
    @api iconName;
    @api lookupLabel;
    @api filterCondition;
    @api userEntryId;


    connectedCallback() {
        getUserEntryData({ userEntryId: this.userEntryId })
            .then(result => {
                this.selectedValue = result.primaryJobRole;
            }).catch(error => {
                this.showError(error.body.message);
            });
    }

    onLeave(event) {
        setTimeout(() => {
            this.searchKey = "";
            this.recordsList = null;
        }, 1000);
    }

    handleKeyChange(event) {
        if (event.target.value.startsWith(' ')) {
            if (event.target.value.length == 1) {
                this.searchKey = '';
            } else {
                this.searchKey = event.target.value.substr(1);
            }
        } else {
            this.searchKey = event.target.value;
        }

        this.getLookupResult();
    }

    getLookupResult() {
        getJobRoleRecords({
            filter: this.filterCondition,
            searchKey: this.searchKey,
        })
            .then((result) => {
                if (result.length === 0) {
                    this.recordsList = [];
                    this.message = "No Records Found";
                } else {
                    this.recordsList = result;
                    this.message = "";
                }
                this.error = undefined;
            })
            .catch((error) => {
                this.error = error;
                this.recordsList = undefined;
            });

        if (this.isValid) {
            this.searchKey = " ";
        }
    }

    onRecordSelection(event) {
        this.selectedRecordId = event.target.dataset.key;
        this.selectedValue = event.target.dataset.name;


        this.searchKey = "";
        this.isValid = true;
        this.onSeletedRecordUpdate();
    }

    removeRecordOnLookup(event) {
        this.searchKey = "";
        this.selectedValue = null;
        this.selectedRecordId = null;
        this.recordsList = null;
        this.onSeletedRecordUpdate();
    }

    onSeletedRecordUpdate() {
        const custEvent = new CustomEvent('recordselection', {
            detail: { selectedRecordId: this.selectedRecordId, selectedValue: this.selectedValue }
        });
        this.dispatchEvent(custEvent);
    }

    @api
    validateFields() {
        this.template.querySelectorAll('lightning-input').forEach(element => {
            if (!element.reportValidity()) {
                this.isValid = false;
            }
        });
    }
}