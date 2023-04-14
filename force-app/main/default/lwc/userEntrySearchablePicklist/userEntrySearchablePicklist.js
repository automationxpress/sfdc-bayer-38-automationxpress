import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAllRecords from '@salesforce/apex/UserEntryEditController.getAllRecords';
import getUserEntryData from '@salesforce/apex/UserEntryEditController.getUserEntryData';
import Name from '@salesforce/label/c.Name';
import NoResults from '@salesforce/label/c.NoResults';

export default class UserEntrySearchablePicklist extends LightningElement {
    @api objectLabel;
    @api objectApiName;
    @api searchPlaceholder;
    @api iconName;
    @api userEntryId;

    searchValue;
    allRecords = [];
    filteredRecords;
    error;
    selectedId = '';
    selectedName = '';
    searchResultsFound = false;
    noResultsFound = false;
    optionSelected = false;
    isValid = true;

    label = {
        Name,
        NoResults
    };

    connectedCallback() {
        getUserEntryData({ userEntryId: this.userEntryId })
            .then(result => {
                if (this.objectApiName == 'MAPV_Department__c' && result.MAPVDepartment) {
                    this.selectedId = result.MAPVDepartment;
                    this.selectedName = result.MAPVDepartmentName;
                    this.optionSelected = true;
                } else if (this.objectApiName == 'MAPV_Group__c' && result.MAPVGroup) {
                    this.selectedId = result.MAPVGroup;
                    this.selectedName = result.MAPVGroupName;
                    this.optionSelected = true;
                } else if (this.objectApiName == 'Account' && result.company) {
                    this.selectedId = result.company;
                    this.selectedName = result.companyName;
                    this.optionSelected = true;
                }
                this.getAllRecords();
            }).catch(error => {
                this.showError(error.body.message);
            });
    }

    getAllRecords() {
        getAllRecords({ objectApiName: this.objectApiName })
            .then(result => {
                this.allRecords = result;
                this.filteredRecords = result;
            }).catch(error => {
                this.showError(error.body.message);
            });
    }

    handleChange(event) {
        this.noResultsFound = false;
        if (event.target.value.startsWith(' ')) {
            if (event.target.value.length == 1) {
                this.searchValue = '';
            } else {
                this.searchValue = event.target.value.substr(1);
            }
        } else {
            this.searchValue = event.target.value;
        }
        this.selectedName = this.searchValue;
        this.handleSearch();
    }

    handleSearch(event) {
        if (this.searchValue) {
            if (this.objectApiName == 'MAPV_Department__c' || this.objectApiName == 'MAPV_Group__c') {
                this.filteredRecords = this.allRecords.filter(
                    r => (
                        r.Name.toLowerCase().includes(this.searchValue.toLowerCase()) ||
                        (r.Abbreviation__c && r.Abbreviation__c.toLowerCase().includes(this.searchValue.toLowerCase()))
                    )
                );
            } else {
                this.filteredRecords = this.allRecords.filter(r => r.Name.toLowerCase().includes(this.searchValue.toLowerCase()));
            }
        } else {
            this.filteredRecords = this.allRecords;
        }

        if (this.isValid) {
            this.selectedName = ' ';
        }

        if (this.filteredRecords && this.filteredRecords.length > 0) {
            this.searchResultsFound = true;
        } else {
            this.noResultsFound = true;
            this.searchResultsFound = false;
        }
    }

    handleSelect(event) {
        this.searchResultsFound = false;
        this.optionSelected = true;
        this.isValid = true;
        this.selectedId = event.currentTarget.dataset.id;
        this.selectedName = event.currentTarget.dataset.name;

        const selectedEvent = new CustomEvent('recordselected', {
            detail: { selectedId: this.selectedId, objectName: this.objectApiName }
        });
        this.dispatchEvent(selectedEvent);
    }

    handleClearSelection() {
        this.selectedId = '';
        this.selectedName = '';
        this.optionSelected = false;
        this.noResultsFound = false;

        const removedEvent = new CustomEvent('recordremoved', {
            detail: { selectedId: this.selectedId, objectName: this.objectApiName }
        });
        this.dispatchEvent(removedEvent);
    }

    handleFocusOut() {
        setTimeout(() => {
            this.searchResultsFound = false;
        }, 500);
    }

    handleKeyPress(event) {
        var keyCode = (event.keyCode ? event.keyCode : event.which);

        if (this.searchValue == '' && (keyCode == 8 || keyCode == 46)) {
            event.preventDefault();
        }
    }

    @api
    validateFields() {
        this.template.querySelectorAll('lightning-input').forEach(element => {
            if (element.reportValidity()) {
                this.isValid = true;
            } else {
                this.isValid = false;
            }
        });
    }

    showError(message) {
        const evt = new ShowToastEvent({
            message: message,
            variant: 'error'
        });
        this.dispatchEvent(evt);
    }
}